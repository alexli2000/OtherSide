//
//  ViewController.swift
//  OtherSide
//
//  Created by Alexander Li on 2015-09-13.
//  Copyright © 2015 Alexander Li. All rights reserved.
//

import UIKit
import MapKit
import Social
import WebKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var otherSideButton: UIButton!
    @IBOutlet weak var throughCoreSwitch: UISwitch!
    
    var goThroughCore = false
    
    var locationManager: CLLocationManager = CLLocationManager()
    var usersLocation:CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
        locationManager.requestAlwaysAuthorization()
        otherSideButton.enabled = false
        currentLocationButton.enabled = false
        formatButtons()
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        self.usersLocation = userLocation.coordinate
        mapView.showsUserLocation = false
        moveToUsersLocation()
    }
    
    @IBAction func currentLocationButtonTapped(sender: AnyObject) {
        moveToUsersLocation()
    }
    
    @IBAction func otherSideButtonTapped(sender: AnyObject) {
        if usersLocation != nil {
            let otherSideLocation = otherSideOfCoordinates(mapView.centerCoordinate)
            moveMapToCoordinates(otherSideLocation)
            createAnnotationForCoordinates(otherSideLocation, subtitle: "The Other Side")
        }
    }
    
    func otherSideOfCoordinates(original:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        var newLon:Double
        if original.longitude >= 0 {
            newLon = original.longitude - 180
        } else {
            newLon = original.longitude + 180
        }
        if throughCoreSwitch.on == true {
        var newLat:Double
        if original.latitude >= 0 {
            newLat = original.latitude - 90
        } else {
            newLat = original.latitude + 90
        }
            return CLLocationCoordinate2D(latitude: newLat, longitude: newLon)

        }
        return CLLocationCoordinate2D(latitude: original.latitude, longitude: newLon)
    }
    
    func moveToUsersLocation() {
        if usersLocation != nil {
            moveMapToCoordinates(usersLocation!)
            createAnnotationForCoordinates(usersLocation!, subtitle: "Current Location")
        }
    }
    
    func moveMapToCoordinates(coordinates:CLLocationCoordinate2D) {
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(coordinates, CLLocationDistance(1000000), CLLocationDistance(1000000)), animated: true)
    }
    
    func createAnnotationForCoordinates(coordinates:CLLocationCoordinate2D, subtitle:String) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)) { (placemarks, error) -> Void in
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            let placemark = placemarks![0]
            
            var title:String = ""
            if placemark.locality != nil {
                title = placemark.locality! + ", "
            }
            if placemark.country != nil {
                title.appendContentsOf(placemark.country!)
            } else if placemark.ocean != nil {
                title = placemark.ocean!
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            annotation.title = title
            annotation.subtitle = subtitle
            self.mapView.addAnnotation(annotation)
            print("annotation added")
            
            self.currentLocationButton.enabled = true
            self.otherSideButton.enabled = true
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        if annotation.isKindOfClass(MKPointAnnotation) {
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("CustomPinAnnotationView") as? MKPinAnnotationView
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "CustomPinAnnotationView")
                pinView?.canShowCallout = true
                pinView?.draggable = false
                pinView?.pinColor = MKPinAnnotationColor.Purple
                pinView?.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
                
                let leftButton = UIButton(frame: CGRectMake(0, 0, 25, 25))
                leftButton.setImage(UIImage(named: "Upload-100"), forState: .Normal)
                pinView?.leftCalloutAccessoryView = leftButton
            } else {
                pinView?.annotation = annotation
            }
            return pinView
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.leftCalloutAccessoryView {
            let annotationTitle = "If I were to dig a hole through the center of the Earth, I would be in " + view.annotation!.title!!
            
            let activityController = UIActivityViewController(activityItems: [annotationTitle], applicationActivities: nil)
            activityController.excludedActivityTypes = [UIActivityTypeMail]
            
            self.presentViewController(activityController, animated: true, completion: { () -> Void in
                
            })
        } else if control == view.rightCalloutAccessoryView {
            let detailView = DetailView()
            //Remove comma and spaces, add in plus
            var text = view.annotation?.title!!
            
            text = text?.stringByReplacingOccurrencesOfString(" ", withString: "+")
            text = text?.stringByReplacingOccurrencesOfString(",", withString: "")
            detailView.searchText = text
            self.presentViewController(detailView, animated: true, completion: nil)
        }
    }
    
    func formatButtons() {
        currentLocationButton.layer.backgroundColor = UIColor.whiteColor().CGColor
        currentLocationButton.layer.cornerRadius = currentLocationButton.bounds.width/2
        currentLocationButton.layer.borderWidth = 1
        currentLocationButton.layer.borderColor = UIColor.blueColor().CGColor
        
        otherSideButton.layer.backgroundColor = UIColor.whiteColor().CGColor
        otherSideButton.layer.cornerRadius = otherSideButton.bounds.width/2
        otherSideButton.layer.borderWidth = 1
        otherSideButton.layer.borderColor = UIColor.blueColor().CGColor
    }
}

