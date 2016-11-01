//
//  ViewController.swift
//  PokemonSearch
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
        
        let annoIdentifier = "Pokemon"
        var annotationView: MKAnnotationView?
        
        if annotation.isKind(of: MKUserLocation.self){
            annotationView = MKAnnotationView(annotation: annotation,
                                              reuseIdentifier: "User")
            annotationView?.image = UIImage(named: "ash")
        } else if let deqAnno = myMapView.dequeueReusableAnnotationView(withIdentifier: annoIdentifier){
            annotationView = deqAnno
        }
        
        return annotationView
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createPokemonSighting(forLocation location:
        CLLocation, withPokemon pokeId: Int) {
        
        geoFire.setLocation(location, forKey: "\(pokeId)")
    }
    
    func showSightingsOnMap(location: CLLocation) {
        let circleQuery = geoFire!.query(at: location, withRadius: 2.5)
        
        _ = circleQuery?.observe(GFEventType.keyEntered, with: { (key, location) in
            
            if let key = key, let location = location {
                let anno = PokemonAnnotate(coordinate: location.coordinate, pokemonNumber: Int(key)!)
                self.myMapView.addAnnotation(anno)
            }
        })
    }

    @IBAction func seeRandomPokemon(_ sender: AnyObject) { //spotting Random Pokemon
        
        let loc = CLLocation(latitude: myMapView.centerCoordinate.latitude, longitude: myMapView.centerCoordinate.longitude)
        
        let rand = arc4random_uniform(151) + 1
        createPokemonSighting(forLocation: loc, withPokemon: Int(rand))
    }

}

