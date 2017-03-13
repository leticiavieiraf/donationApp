//
//  InstitutionsViewController.swift
//  donationApp
//
//  Created by Natalia Sheila Cardoso de Siqueira on 11/03/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseDatabase
import FacebookLogin
import FacebookCore

class InstitutionsViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    let ref = FIRDatabase.database().reference(withPath: "features")
    var institutions: [Institution] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AccessToken.current == nil || FIRAuth.auth()?.currentUser == nil {
            print("Facebook: User IS NOT logged in!")
            print("Firebase: User IS NOT logged in!")
            
            // Redireciona para tela de login
            let loginNav = UIStoryboard(name: "Main", bundle:nil).instantiateInitialViewController()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = loginNav
            
        } else {

            // Busca Instituições
            ref.observe(.value, with: { snapshot in
                
                //print(snapshot.value)
                for item in snapshot.children {
                    let institution = Institution(snapshot: item as! FIRDataSnapshot)
                    self.institutions.append(institution)
                }
            
                var count = 0
                for item in self.institutions {
                    
                    if item.city == "Belo Horizonte" {
                        let itemAdress = item.address + " " + item.district + ", " + item.city + " - " + item.state
                        self.geolocalisation(fromAddress: itemAdress, onSuccess: { location in
                            
                            item.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                                                     longitude: location.coordinate.longitude)
                            
                            self.mapView.addAnnotation(item)
                            
                            if count == 0 {
                                // set initial location
                                let initialLocation = CLLocation(latitude: item.coordinate.latitude, longitude: item.coordinate.longitude)
                                self.centerMapOnLocation(location: initialLocation)
                                
                                count += 1
                            }
                        }) { error in
                            print(error)
                        }
                    }
                }
            })
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.title = "Instituições"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }
    
    func geolocalisation(fromAddress address: String, onSuccess: @escaping (_ location: CLLocation) -> (), onFailure: @escaping (_ error: Error) -> ())  {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarksOptional, error) -> Void in
            
            if let placemarks = placemarksOptional {
                print("placemark| \(placemarks.first)")
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
    var locationManager = CLLocationManager()
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
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
