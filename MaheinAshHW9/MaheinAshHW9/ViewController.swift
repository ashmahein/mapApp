//
//  ViewController.swift
//  MaheinAshHW9
//
//  Created by Ash Mahein on 3/23/18.
//  Copyright © 2018 Ash Mahein. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager: CLLocationManager!
    var geoCoder = CLGeocoder()
    
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var mapkitView: MKMapView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        searchTextField.delegate = self
        initializeLocation()
    }
    
    func initializeLocation() { // called from start up method
        locationManager = CLLocationManager()
        locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            startLocation()
        case .denied, .restricted:
            print("location not authorized")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if ((status == .authorizedAlways) || (status == .authorizedWhenInUse)) {
            self.startLocation()
        }
        else {
            self.stopLocation()
        }
    }
    func startLocation () {
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        mapkitView.showsUserLocation = true
        mapkitView.userTrackingMode = .follow
    }
    func stopLocation () {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lookupLocation() //contniously ask where we are.
        let location = locations.last
        if let latitude = location?.coordinate.latitude {
            let lat = String(format: "%.6f", latitude)
            self.latitudeLabel.text = "Latitude: \(lat)"
        }
        if let longitude = location?.coordinate.longitude {
            let long = String(format: "%.6f", longitude)
            self.longitudeLabel.text = "Longitude \(long)"
        }
    }
    // Delegate method called if location unavailable (recommended)
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        NSLog("locationManager error: \(error.localizedDescription)")
    }
    
    func lookupLocation() {
        if let location = locationManager.location {
            geoCoder.reverseGeocodeLocation(location, completionHandler: geoCodeHandler)
        }
    }
    func geoCodeHandler (placemarks: [CLPlacemark]?, error: Error?){
        if let placemark = placemarks?.first {
            if let name = placemark.name {
                infoLabel.text = "Info: \(name)"
            //print("place name = \(name)")
            }
        }
    }
    
    func findSearch() {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchTextField.text!
        request.region = mapkitView.region
        let search = MKLocalSearch(request: request)
        search.start(completionHandler: searchHandler)
    }
    func searchHandler (response: MKLocalSearchResponse?, error: Error?) {
        if let err = error {
        print("Error occured in search: \(err.localizedDescription)")
        }
        else if let resp = response {
            print("\(resp.mapItems.count) matches found")
            self.mapkitView.removeAnnotations(self.mapkitView.annotations)
            for item in resp.mapItems {
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                self.mapkitView.addAnnotation(annotation)
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        findSearch()
        return true
    }
}

