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

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    
    // variables
    var detailViewController : DetailViewController = DetailViewController()
    var selectedInstitution = Institution()
    
    let ref = Database.database().reference(withPath: "features")
    var institutions : [Institution] =  [Institution]()
    var locationManager = CLLocationManager()

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
            
            self.mapView.delegate = self
            self.locationManager.delegate = self
            self.locationManager.requestWhenInUseAuthorization()
            
            // Busca Instituições
            SVProgressHUD.setDefaultStyle(.dark)
            SVProgressHUD.show()
            
            ref.observe(.value, with: { snapshot in
                
                var count = 0
                for item in snapshot.children {
                    let institution = Institution(snapshot: item as! DataSnapshot)
                    
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
                                
                                /*
                                 let region : MKCoordinateRegion = MKCoordinateRegionMakeWithDistance (self.mapView.userLocation.location!.coordinate, 50, 50);
                                 let adjustedRegion = self.mapView.regionThatFits(region)
                                 self.mapView.setRegion(adjustedRegion, animated:true)
                                 */
                            }
                        }) { error in
                            print(error)
                        }
                    }
                    
                    self.institutions.append(institution)
                }
                
                SVProgressHUD.dismiss()
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
    
    // MARK:Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetails" {
            let detailVC = segue.destination as! DetailViewController
            self.detailViewController = detailVC
        }
        
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
        
        if let tappedInstitution = view.annotation as? Institution {
            self.detailViewController.institution = tappedInstitution
            
            containerHeightConstraint.constant = 340;
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
            
            self.detailViewController.tableView.reloadData()
            
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
