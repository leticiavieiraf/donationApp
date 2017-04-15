//
//  InstitutionsViewController.swift
//  donationApp
//
//  Created by Letícia Fernandes on 11/03/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseDatabase
import FacebookLogin
import FacebookCore

class InstitutionsViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    let ref = FIRDatabase.database().reference(withPath: "features")
    var institutions : [Institution] =  [Institution]()
    var locationManager = CLLocationManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if FIRAuth.auth()?.currentUser == nil {
            print("Facebook: User IS NOT logged in!")
            print("Firebase: User IS NOT logged in!")
            
            // Redireciona para tela de login
            let loginNav = UIStoryboard(name: "Main", bundle:nil).instantiateInitialViewController()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = loginNav
            
        } else {
            
            self.mapView.delegate = self
            self.locationManager.delegate = self
            self.locationManager.requestWhenInUseAuthorization()

            // Busca Instituições
            ref.observe(.value, with: { snapshot in
                
                var count = 0
                for item in snapshot.children {
                    let institution = Institution(snapshot: item as! FIRDataSnapshot)
                    
                    if institution.city == "Rio de Janeiro"/*Belo Horizonte"*/ {
                        
                        let adress = institution.address + " " + institution.district + ", " + institution.city + " - " + institution.state
                        self.geolocalisation(fromAddress: adress, onSuccess: { location in
                            
                            institution.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                                                       longitude: location.coordinate.longitude)
                            
                            self.mapView.addAnnotation(institution)
                            
                            
                            //Set initial location
                            if count == 0 {
                                 let initialLocation = self.mapView.userLocation.location != nil ? self.mapView.userLocation.location :
                                    CLLocation(latitude: institution.coordinate.latitude, longitude: institution.coordinate.longitude)
                                
                                self.centerMapOnLocation(location: initialLocation!)
                                count += 1
                            }
                        }) { error in
                            print(error)
                        }
                    }
                    
                    self.institutions.append(institution)
                }
            })
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

    
    func geolocalisation(fromAddress address: String, onSuccess: @escaping (_ location: CLLocation) -> (), onFailure: @escaping (_ error: Error) -> ())  {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarksOptional, error) -> Void in
            
            if let placemarks = placemarksOptional {
                //print("placemark| \(placemarks.first)")
                if let location = placemarks.first?.location {
                    onSuccess(location)
                }
            } else {
                onFailure(error!)
            }
        }
    }
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: - location manager to authorize user location for Maps app
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    // Mark: MKMapViewDelegate
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let annotation = view.annotation as? Institution {
            print("Your annotation title: \(annotation.title)");
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Institution {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let annotation = view.annotation as? Institution {
            //print("Your annotation title: \(annotation.title)");
            
            let detailVC = UIStoryboard(name: "Donators", bundle:nil).instantiateViewController(withIdentifier: "detailPopUp") as! DetailInstitutionViewController
            detailVC.institution = annotation
            self.addChildViewController(detailVC)
            detailVC.view.frame = self.view.frame
            self.view.addSubview(detailVC.view)
            detailVC.didMove(toParentViewController: self)
            
            
        }
        
    }

    
    
    
    //    func geoCodeAddress(_ address:NSString){
    //
    //        let geocoder = CLGeocoder()
    //        geocoder.geocodeAddressString(address as String, completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
    //
    //            if (error != nil) {
    //                print(error!.localizedDescription)
    //            }
    //            else{
    //
    //                if let placemark = placemarks?.first {
    //
    //                    print("placemark| \(placemark)")
    //
    //                    if let location = placemark.location {
    //                        print(location)
    //                    }
    //                }
    //                else {
    //
    //                     print("invalid address: \(address)")
    //
    //                }
    //            }
    //            
    //            } as! CLGeocodeCompletionHandler)
    //    }
    //
    
    
}
