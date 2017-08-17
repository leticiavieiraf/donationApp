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
    var detailViewController : DetailViewController = DetailViewController()
    var selectedInstitutionUser : InstitutionUser?
    
    let ref = Database.database().reference(withPath: "features")
    var institutions : [Institution] = [Institution]()
    var pins = [Institution]()
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
            verifiyIfWasOrderSelection();
            getInstitutionsAndLoadMap()
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
        
        SVProgressHUD.dismiss(withDelay: 9.0)
        
        self.getInstitutions(onSuccess: { (institutions) in
          
            if let userLocation = self.mapView.userLocation.location {
                
                self.getUserLocationCity(userLocation, onSuccess: { userLocationCity in
                    self.drawInstitutionPinsForCity(userLocationCity, institutions)
                    
                }, onFailure: {error in
                    self.drawInstitutionPinsForCity("Belo Horizonte", institutions)
                })
                
            } else {
                self.drawInstitutionPinsForCity("Belo Horizonte", institutions)
            }
        })
    }
    
    func getInstitutions(onSuccess: @escaping (_ institutions: [Institution]) -> ()) {
        ref.observe(.value, with: { snapshot in
            
            for item in snapshot.children {
                let institution = Institution(snapshot: item as! DataSnapshot)
                self.institutions.append(institution)
                
            }
            onSuccess(self.institutions)
        })
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
    
    // MARK: - Setup methods
    func setupDelegates() {
        self.mapView.delegate = self
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: GestureRecognizer
    func addTapGestureRecognizerToMapView() {
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapOnMapView))
        doubleTapGesture.delegate = self
        doubleTapGesture.numberOfTapsRequired = 2
        self.mapView.addGestureRecognizer(doubleTapGesture)
    }
    
    func handleDoubleTapOnMapView() {
        collapseDetails()
    }
    
    // MARK: Map Setup
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
    
    func setupMapCamera(coordinate: CLLocationCoordinate2D) {
        let camera = MKMapCamera(lookingAtCenter: coordinate, fromDistance: 300, pitch: 30, heading: 90)
        mapView.setCamera(camera, animated: true)
    }
    
    func drawInstitutionPinsForCity(_ city: String?, _ institutions: [Institution]) {
        var count = 0
        var errorCount = 0
        
        for institution in institutions {
            if institution.city == city {
                
                let address = Helper.institutionAddress(institution)
                self.getGeolocation(address, onSuccess: { location in
                    
                    institution.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                                                    longitude: location.coordinate.longitude)
                    self.mapView.addAnnotation(institution)
                    self.pins.append(institution)
                    
                    if (count == 0) {
                        self.setInitialMapLocation(institution)
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
    
    func drawInstitutionPinIfNeeded(_ pinCoordinate: CLLocationCoordinate2D, _ institutionUser : InstitutionUser) {
        var pinExists = false
        for pin in self.pins {
            if (pin.coordinate.latitude == pinCoordinate.latitude && pin.coordinate.longitude == pinCoordinate.longitude) {
                pinExists = true
            }
        }
        
        if pinExists == false {
            let selectedInstitution = Institution(name: institutionUser.name,
                                                  info: institutionUser.info,
                                                  email: institutionUser.email,
                                                  contact: institutionUser.contact,
                                                  phone: institutionUser.phone,
                                                  bank: institutionUser.bank,
                                                  agency: institutionUser.agency,
                                                  accountNumber: institutionUser.accountNumber,
                                                  address: institutionUser.address,
                                                  district: institutionUser.district,
                                                  city: institutionUser.city,
                                                  state: institutionUser.state,
                                                  zipCode: institutionUser.zipCode,
                                                  group: institutionUser.group,
                                                  coordinate: pinCoordinate)
            self.mapView.addAnnotation(selectedInstitution)
            self.pins.append(selectedInstitution)
        }
    }
    
    // MARK: - Detail Container methods
    func verifiyIfWasOrderSelection() {
        if let selectedInstitutionUser = self.selectedInstitutionUser {
            //self.tabBarController?.selectedIndex = 1
            showDetailsFor(selectedInstitutionUser)
        }
    }
    
    func showDetailsFor(_ selectedInstitutionUser: InstitutionUser) {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()
        
        let address = Helper.institutionUserAddress(selectedInstitutionUser)
        if (address != "-") {
            self.getGeolocation(address, onSuccess: { location in
                SVProgressHUD.dismiss()
                
                let selectedInstitutionCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                                                           longitude: location.coordinate.longitude)
                self.drawInstitutionPinIfNeeded(selectedInstitutionCoordinate, selectedInstitutionUser)
                
                self.expandDetails()
                
                self.centerMapAtLocation(coordinate: selectedInstitutionCoordinate, regionRadius: 200)
                self.setupMapCamera(coordinate: selectedInstitutionCoordinate)
                
                self.detailViewController.institutionUser = selectedInstitutionUser
                self.detailViewController.loadData()
                
            }, onFailure: {error in
                print(error.localizedDescription)
                SVProgressHUD.dismiss()
                
                self.showAlert(title: "Ops..", message: "Algo errado aconteceu, tente novamente.", handler: { () in

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
        detailViewController.institutionUser = nil
        
        containerHeightConstraint.constant = 0;
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    //MARK: Tooltip methods
    func presentToolTip() {
        let xPosition: CGFloat = self.mapView.frame.size.width/2
        let yPosition: CGFloat = self.mapView.frame.origin.y + 350
        
        tooltip.frame = CGRect(x: xPosition,
                               y: yPosition,
                               width: tooltip.frame.size.width,
                               height: tooltip.frame.size.height)
        tooltip.center = CGPoint(x: self.mapView.center.x , y:self.mapView.center.y)
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
            setupMapCamera(coordinate: tappedInstitution.coordinate);
            
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
