//
//  ViewController.swift
//  PokemanSearch
//
//  Created by Vincent  on 10/26/16.
//  Copyright © 2016 Vincent . All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

import Firebase

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    @IBOutlet weak var myMapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var mapHasCenteredOnce = false
    var geoFire: GeoFire!
    var geoFireRef: FIRDatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        myMapView.delegate = self
        myMapView.userTrackingMode = MKUserTrackingMode.follow
        
        geoFireRef = FIRDatabase.database().reference()
        geoFire = GeoFire(firebaseRef: geoFireRef)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationAuthStatus()
    }
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .
            authorizedWhenInUse{
            myMapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            myMapView.showsUserLocation = true
        }
    }
    
    func centerMapOnLocation(location: CLLocation){
        let coordinatedRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
        
        myMapView.setRegion(coordinatedRegion, animated: true)
        
        
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        if let loc = userLocation.location{
            if !mapHasCenteredOnce {
                centerMapOnLocation(location: loc)
                mapHasCenteredOnce = true
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation:
        MKAnnotation) -> MKAnnotationView? {
        
        var annotationView: MKAnnotationView?
        
        if annotation.isKind(of: MKUserLocation.self){
            annotationView = MKAnnotationView(annotation: annotation,
                                              reuseIdentifier: "User")
            annotationView?.image = UIImage(named: "ash")
        }
        
        return annotationView
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createPokemanSighting(forLocation location:
        CLLocation, withPokeman pokeId: Int) {
        
        geoFire.setLocation(location, forKey: "\(pokeId)")
    }

    @IBAction func seeRandomPokeman(_ sender: AnyObject) { //spotting Random Pokeman
    }

}

