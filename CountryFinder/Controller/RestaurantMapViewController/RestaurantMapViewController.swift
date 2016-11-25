//
//  RestaurantMapViewController.swift
//  CountryFinder
//
//  Created by Mac on 22/11/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class RestaurantMapViewController: UIViewController {
    
    //MapView Objects for Restaurants
    @IBOutlet weak var mapViewRestaurant: MKMapView!
    //Activity indicator to show load of maop
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    //Array of restaurant items 
    var arrayOfRecors = Array<Dictionary<String, AnyObject>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //set map zoom
        CustomLocationManager.sharedInstance.zoomMapView(mapView: self.mapViewRestaurant)
        //call to add annotation on mapview
        self.createArrayForMapWithRecords(records: self.arrayOfRecors)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- Create an array with name & lat-lon from records
    func createArrayForMapWithRecords(records : Array<Dictionary<String, AnyObject>>)
    {
        for dictData in records
        {
            guard let locationDict = dictData["location"] as? Dictionary<String, AnyObject> else
            {
                continue
            }
            let newLocation = CLLocationCoordinate2DMake((locationDict[restaurantLat] as? Double)!, (locationDict[restaurantLng] as? Double)!)
            if CLLocationCoordinate2DIsValid(newLocation)
            {
                // Drop a pin
                let annotation = MKPointAnnotation()
                annotation.coordinate.latitude = newLocation.latitude
                annotation.coordinate.longitude = newLocation.longitude
                annotation.title = (dictData[restaurantName] as? String)!
                self.mapViewRestaurant.addAnnotation(annotation)
            }
            else{
                continue
            }
        }
        self.activityIndicator.stopAnimating()
    }
 }

