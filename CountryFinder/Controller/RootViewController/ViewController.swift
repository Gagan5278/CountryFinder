//
//  ViewController.swift
//  CountryFinder
//
//  Created by Mac on 21/11/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

//Create notification name
let notificationName = Notification.Name("UserLocationNotificationIdentifier")

//Create keys for dictionary in compltetion handler
let countryCode =  "countryCode"
let countryName = "countryName"

class ViewController: UIViewController {

    //Mapview instance
    @IBOutlet weak var mapView: MKMapView!
    
    //Appdelegate object for calling kmlparser object
    let objAppDel = UIApplication.shared.delegate as! AppDelegate

    //Create objet for Custom location manager
    let customLocationManagerObject = CustomLocationManager.sharedInstance

    //MARK:-View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //Add notification observer from location update delegate
        NotificationCenter.default.addObserver(self, selector: #selector(getCountryName), name:notificationName, object: nil)
        //Initialize LocationManager Object & Call Start update location
        customLocationManagerObject.creatLocationManagerObject()
        customLocationManagerObject.startUpdatingUserLocation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: get countryname & contry code
    func getCountryName()
    {
        //Remove earlier added annotation if any
        self.removeAnnotationFromMap()
        //Set map zoom
        customLocationManagerObject.zoomMapView(mapView: self.mapView)
       //get coutry name
        weak var weakSelf = self
        customLocationManagerObject.findCountryNameFromUserCurrentLocation() {
            (isSuccess : Bool ,  dict : [String : AnyObject]) in
            if isSuccess
            {
                //Add annotation on user's current location
                let annotation = MKPointAnnotation()
                annotation.coordinate = (weakSelf?.customLocationManagerObject.userCurrentLocation?.coordinate)!
                annotation.title = dict[countryName] as! String?
                annotation.subtitle = dict[countryCode] as! String?
                self.mapView.addAnnotation(annotation)
            }
            else{
                print("Error in getting country name is : \(countryName)")
            }
        }
     }

    //MARK:- Remove All Annotation before adding new one
    func removeAnnotationFromMap()
    {
        self.mapView.removeAnnotations(self.mapView.annotations)
    }
}

//MARK:- mapView Delegate
extension ViewController : MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      return  self.objAppDel.kmlParserObejct.view(for: annotation)
    }
}
