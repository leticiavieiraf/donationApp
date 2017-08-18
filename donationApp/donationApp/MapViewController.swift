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
    
    // detail container variables
    var detailViewController: DetailViewController = DetailViewController()
    var selectedInstitutionUser: InstitutionUser?
    var isShowingOrderDetail: Bool = false
    
    // firebase variable
    let ref = Database.database().reference(withPath: "features")

    var locationManager = CLLocationManager()
    
    // MARK: - Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser == nil {
            print("Facebook: User IS NOT logged in!")
            print("Firebase: User IS NOT logged in!")
            
            // Redireciona para tela de login
            let loginNav = UIStoryboard(name: "Main", bundle:nil).instantiateInitialViewController()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = loginNav
            
        } else {
            setupDelegates()
            addTapGestureRecognizerToMapView();
            
            if let selectedInstitutionUser = self.selectedInstitutionUser {
                isShowingOrderDetail = true
                showDetailsFor(selectedInstitutionUser)
            } else {
                isShowingOrderDetail = false
                getInstitutionsAndLoadMap()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.title = "Instituições"
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "expandDetails" {
            let detailVC = segue.destination as! DetailViewController
            self.detailViewController = detailVC
        }
    }
    
    // MARK: - Firebase methods
    func getInstitutionsAndLoadMap() {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()
        
        SVProgressHUD.dismiss(withDelay: 5.0)
        
        self.getInstitutions(onSuccess: { (institutions) in
          
            if let userLocation = self.mapView.userLocation.location {
                
                self.getUserLocationCity(userLocation, onSuccess: { userLocationCity in
                    self.drawPinsForCity(userLocationCity, institutions)
                    
                }, onFailure: {error in
                    self.drawPinsForCity("Belo Horizonte", institutions)
                })
                
            } else {
                self.drawPinsForCity("Belo Horizonte", institutions)
            }
        })
    }
    
    func getInstitutions(onSuccess: @escaping (_ institutions: [Institution]) -> ()) {
        ref.observe(.value, with: { snapshot in
            self.institutions.removeAll()
            
            for item in snapshot.children {
                let institution = Institution(snapshot: item as! DataSnapshot)
                self.institutions.append(institution)
            }
            
            if self.institutions.count > 0 {
                onSuccess(self.institutions)
            } else {
                self.showAlert(title: "Erro", message: "Não foi possível buscar as Instituições com sucesso.", handler: nil)
            }
        })
    }
    
    // MARK: Map Setup methods
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
                            self.setupMapCamera(coordinate: institution.coordinate, distance: 9000)
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
        
        self.centerMapAtLocation(coordinate: initialLocation!.coordinate, regionRadius: 2000)
    }
    
    func centerMapAtLocation(coordinate: CLLocationCoordinate2D, regionRadius: CLLocationDistance) {
        let region = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius, regionRadius)
        let adjustedRegion = self.mapView.regionThatFits(region)
        mapView.setRegion(adjustedRegion, animated: true)
    }
    
    func setupMapCamera(coordinate: CLLocationCoordinate2D, distance: CLLocationDistance) {
        let camera = MKMapCamera(lookingAtCenter: coordinate, fromDistance: distance, pitch: 35, heading: 45)
        mapView.setCamera(camera, animated: true)
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
                
                self.expandDetails()
                
                self.centerMapAtLocation(coordinate: institution.coordinate, regionRadius: 200)
                self.setupMapCamera(coordinate: institution.coordinate, distance: 300)
                
                self.detailViewController.institutionUser = institutionUser
                self.detailViewController.loadData()
                
            }, onFailure: {error in
                print(error.localizedDescription)
                SVProgressHUD.dismiss()
                
                self.showAlert(title: "Ops..", message: "Não foi possível localizar essa instituição no mapa, tente novamente.", handler: { () in
                    
                    if let orderViewController = self.navigationController?.viewControllers.first {
                        self.navigationController?.setViewControllers([orderViewController], animated: true)
                    }
                    //self.tabBarController?.selectedIndex = 0
                })
            })
        }
    }
    
    func expandDetails() {
        containerHeightConstraint.constant = UIScreen.main.bounds.height * 0.55;
        
        UIView.animate(withDuration: 0.6, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func collapseDetails() {
        containerHeightConstraint.constant = 0;
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
        
        if isShowingOrderDetail {
            isShowingOrderDetail = false
            getInstitutionsAndLoadMap()
        } else {
            self.setupMapCamera(coordinate: detailViewController.institution.coordinate, distance: 9000)
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
    
    // MARK: - MapGestureRecognizer
    func addTapGestureRecognizerToMapView() {
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapOnMapView))
        doubleTapGesture.delegate = self
        doubleTapGesture.numberOfTapsRequired = 2
        self.mapView.addGestureRecognizer(doubleTapGesture)
    }
    
    func handleDoubleTapOnMapView() {
        collapseDetails()
    }
    
    //MARK: Tooltip methods
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
        let when = DispatchTime.now() + 8
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
        //if let annotation = view.annotation as? Institution {
            //print("Your annotation title: \(annotation.title)");
        //}
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
            
            centerMapAtLocation(coordinate: tappedInstitution.coordinate, regionRadius: 200)
            setupMapCamera(coordinate: tappedInstitution.coordinate, distance: 300)
            
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
