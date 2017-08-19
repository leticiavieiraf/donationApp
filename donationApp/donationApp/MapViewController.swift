//
//  MapViewController.swift
//  donationApp
//
//  Created by Letícia on 21/07/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseDatabase
import FacebookLogin
import FacebookCore
import SVProgressHUD

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    // outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    @IBOutlet var tooltip: UIView!
    
    // variables
    var institutions: [Institution] = []
    var locationManager = CLLocationManager()
    
    // detail container variables
    var detailViewController: DetailViewController = DetailViewController()
    var selectedInstitutionUser: InstitutionUser?
    var isShowingOrderDetail: Bool = false
    
    // firebase variable
    let ref = Database.database().reference(withPath: "features")
    
    // MARK: - Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTabBarController()
        
        if userLoggedIn() {
            if let selectedInstitutionUser = self.selectedInstitutionUser {
                isShowingOrderDetail = true
                showDetailsFor(selectedInstitutionUser)
            } else {
                isShowingOrderDetail = false
                if (institutions.count > 0) {
                    loadMap()
                } else {
                    getInstitutionsAndLoadMap()
                }
            }
        } else {
            Helper.redirectToLogin()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }
    
    // MARK: - Check Login methods
    func userLoggedIn() -> Bool {
        let institutionUserLoggedIn = Helper.institutionUserLoggedIn()
        var isLogged = true
        
        if !institutionUserLoggedIn {
            isLogged = false
            print("Firebase: User IS NOT logged in!")
        }
        return isLogged
    }
    
    // MARK: - Setup TabBarController methods
    func setupTabBarController() {
        var barButtonItem: UIBarButtonItem? = UIBarButtonItem()
        
        if isShowingOrderDetail {
            barButtonItem = UIBarButtonItem(image: UIImage(named: "arrow-back"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(goBackToOrders))
            self.tabBarController?.tabBar.isHidden = true
        } else {
            barButtonItem = nil
            self.tabBarController?.tabBar.isHidden = false
        }
        self.tabBarController?.title = "Instituições"
        self.tabBarController?.navigationItem.leftBarButtonItem = barButtonItem
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    // MARK: - Navigation methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "expandDetails" {
            let detailVC = segue.destination as! DetailViewController
            self.detailViewController = detailVC
        }
    }
    
    func goBackToOrders() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Firebase methods
    func getInstitutionsAndLoadMap() {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()
        SVProgressHUD.dismiss(withDelay: 4.0)
        
        self.getInstitutions(onSuccess: { () in
            self.loadMap()
        })
    }
    
    func getInstitutions(onSuccess: @escaping () -> ()) {
        ref.observe(.value, with: { snapshot in
            self.institutions.removeAll()
            
            for item in snapshot.children {
                let institution = Institution(snapshot: item as! DataSnapshot)
                self.institutions.append(institution)
            }
            
            if self.institutions.count > 0 {
                onSuccess()
            } else {
                self.showAlert(title: "Erro", message: "Não foi possível buscar as Instituições com sucesso.", handler: nil)
            }
        })
    }
    
    // MARK: - Map Setup methods
    func loadMap() {
        if let userLocation = self.mapView.userLocation.location {
            self.getUserLocationCity(userLocation, onSuccess: { userLocationCity in
                self.drawPinsForCity(userLocationCity, self.institutions)
            
            }, onFailure: {error in
                self.drawPinsForCity("Belo Horizonte", self.institutions)
            })
        } else {
            self.drawPinsForCity("Belo Horizonte", self.institutions)
        }
    }
    
    func drawPinsForCity(_ city: String?, _ institutions: [Institution]) {
        var count = 0
        var errorCount = 0
        mapView.removeAnnotations(mapView.annotations)
        
        for institution in institutions {
            if institution.city == city {
                
                let address = Helper.institutionAddress(institution)
                if (address != "-") {
                    self.getGeolocation(address, onSuccess: { location in
                        
                        institution.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                                                        longitude: location.coordinate.longitude)
                        self.mapView.addAnnotation(institution)
                        
                        if (count == 0) {
                            self.setInitialMapLocation(institution)
                            self.setupMapCamera(institution.coordinate, distance: 9000, pitch: 35)
                            count += 1
                        }
                        
                    }, onFailure: {error in
                        if (errorCount == 0) {
                            self.presentToolTip()
                            errorCount += 1
                        }
                        print("GEOLOCATION ERROR: " + error.localizedDescription)
                    })
                }
            }
        }
    }
    
    func setInitialMapLocation(_ firstInstitution: Institution) {
        let initialLocation : CLLocation?
        
        if (self.mapView.userLocation.location != nil) {
            initialLocation = self.mapView.userLocation.location
        } else {
            initialLocation = CLLocation(latitude: firstInstitution.coordinate.latitude, longitude: firstInstitution.coordinate.longitude)
        }
        
        self.centerMapAtLocation(initialLocation!.coordinate, regionRadius: 2000)
    }
    
    func centerMapAtLocation(_ coordinate: CLLocationCoordinate2D, regionRadius: CLLocationDistance) {
        if valid(coordinate) {
            let region = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius, regionRadius)
            let adjustedRegion = self.mapView.regionThatFits(region)
            mapView.setRegion(adjustedRegion, animated: true)
        }
    }
    
    func setupMapCamera(_ coordinate: CLLocationCoordinate2D, distance: CLLocationDistance, pitch: CGFloat) {
        if valid(coordinate) {
            let camera = MKMapCamera(lookingAtCenter: coordinate, fromDistance: distance, pitch: pitch, heading: 45)
            mapView.setCamera(camera, animated: true)
        }
    }
    
    func setupDelegates() {
        self.mapView.delegate = self
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Detail Container methods
    func showDetailsFor(_ institutionUser: InstitutionUser) {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()
        
        let address = Helper.institutionUserAddress(institutionUser)
        if (address != "-") {
            self.getGeolocation(address, onSuccess: { location in
                SVProgressHUD.dismiss()
                
                let institution = Helper.institution(from: institutionUser)
                institution.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                
                self.mapView.addAnnotation(institution)
                self.mapView.selectAnnotation(self.mapView.annotations.first!, animated: true)
                
                self.expandDetails()
                
                self.centerMapAtLocation(institution.coordinate, regionRadius: 200)
                self.setupMapCamera(institution.coordinate, distance: 300, pitch: 10)
                
                self.detailViewController.institutionUser = institutionUser
                self.detailViewController.loadData()
            }, onFailure: {error in
                print(error.localizedDescription)
                SVProgressHUD.dismiss()
                
                self.showAlert(title: "Ops..",
                               message: "Não foi possível localizar essa instituição no mapa, tente novamente.",
                               handler: { () in
                                    self.goBackToOrders()
                               })
            })
        }
    }
    
    func expandDetails() {
        if isShowingOrderDetail {
            detailViewController.hideButtonCollapseDetails()
        } else {
            detailViewController.showButtonCollapseDetails()
        }
        
        containerHeightConstraint.constant = UIScreen.main.bounds.height * 0.56;
        
        UIView.animate(withDuration: 0.6, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func collapseDetails() {
        if !isShowingOrderDetail {
            containerHeightConstraint.constant = 0;
            
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
            setupMapCamera(detailViewController.institution.coordinate, distance: 9000, pitch: 35)
        }
    }
    
    // MARK: - Location methods
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func getUserLocationCity(_ location: CLLocation, onSuccess: @escaping (_ userLocationCity: String?) -> (), onFailure: @escaping (_ error: Error) -> ()) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarksOptional, error) in
            
            if let placemarks = placemarksOptional {
                if let placemark = placemarks.first {
                    onSuccess(placemark.locality)
                }
            } else {
                onFailure(error!)
            }
        }
    }
    
    func getGeolocation(_ address : String, onSuccess: @escaping (_ location: CLLocation) -> (), onFailure: @escaping (_ error: Error) -> ())  {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarksOptional, error) -> Void in
            
            if let placemarks = placemarksOptional {
                if let location = placemarks.first?.location {
                    onSuccess(location)
                }
            } else {
                onFailure(error!)
            }
        }
    }
    
    func valid(_ coordinate: CLLocationCoordinate2D) -> Bool {
        var isValid = true
        
        if (coordinate.latitude == 0 || coordinate.longitude == 0) {
            isValid = false
        }
        return isValid
    }
    
    //MARK: - Tooltip
    func presentToolTip() {
        let xPosition: CGFloat = self.mapView.frame.size.width/2
        let yPosition: CGFloat = self.mapView.frame.size.height/2
        
        tooltip.frame = CGRect(x: xPosition,
                               y: yPosition,
                               width: tooltip.frame.size.width,
                               height: tooltip.frame.size.height)
        
        tooltip.center = CGPoint(x: self.mapView.center.x + 20, y:self.mapView.center.y - 170)
        tooltip.alpha = 0
        self.mapView.addSubview(tooltip)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.tooltip.alpha = 1
        }) { (finished) in
            if finished {
                self.removeTooltip()
            }
        }
    }
    
    func removeTooltip() {
        let when = DispatchTime.now() + 4
        DispatchQueue.main.asyncAfter(deadline: when, execute: {
            UIView.animate(withDuration: 0.5, animations: {
                self.tooltip.alpha = 0
            }) { (finished) in
                self.tooltip.removeFromSuperview()
            };
        })
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        if let annotation = view.annotation as? Institution {
//            print("Your annotation title: \(annotation.title)");
//        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        collapseDetails()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Institution {
            let identifier = "pin"
            var view: MKPinAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 8)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let tappedInstitution = view.annotation as? Institution {
            expandDetails()
            
            centerMapAtLocation(tappedInstitution.coordinate, regionRadius: 200)
            setupMapCamera(tappedInstitution.coordinate, distance: 300, pitch: 10)
            
            detailViewController.institutionUser = nil
            detailViewController.institution = tappedInstitution
            detailViewController.loadData()
            
            /*
            let detailVC = UIStoryboard(name: "Donators", bundle:nil).instantiateViewController(withIdentifier: "detailPopUp") as! DetailInstitutionViewController
            detailVC.institution = annotation
            self.addChildViewController(detailVC)
            detailVC.view.frame = self.view.frame
            self.view.addSubview(detailVC.view)
            detailVC.didMove(toParentViewController: self)
             //print("Your annotation title: \(annotation.title)");
            */
        }
    }
}
