//
//  CustomLocationManager.swift
//  CountryFinder
//
//  Created by Mac on 21/11/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import CoreLocation

//Four Square APIURL, Query ClientID & Secret
let client_ID = "QTRRHCUL0CP54CSHGRYNINWVYWHN41WJQP221LMKHJQN40GK"
let client_Secret = "FCDLDO1QKXNHY543OYHWLDN2LBXX2NYS35GOXWYDM3D4OJN4"
let API_URl = "https://api.foursquare.com/v2/"
let queryObject = "restaurant"   //Change here your query

class CustomLocationManager: NSObject, CLLocationManagerDelegate {
    
    //Singlton Object for the class
    static let sharedInstance =  CustomLocationManager()
    
    //location manager instance
    var locationManager : CLLocationManager?
    
    //User's current location
    var userCurrentLocation : CLLocation?
    
    //initialize location manager instance
    func creatLocationManagerObject()
    {
        if self.locationManager == nil  {
            self.locationManager = CLLocationManager()
            self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager?.distanceFilter = 100   //100 meter update
            self.locationManager?.delegate = self
            if (self.locationManager?.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)))!
            {
                self.locationManager?.requestWhenInUseAuthorization()
            }
        }
    }
    
    //start updating user's current location
    func startUpdatingUserLocation()
    {
        self.locationManager?.startUpdatingLocation()
    }
    
    //stop updating user location
    func stopUpdatingUserLocation()
    {
        self.locationManager?.stopUpdatingLocation()
    }
    
    //MARK:- Location manager delegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print ("Error in getting location :\(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation =  locations.first
        if  CLLocationCoordinate2DIsValid((userLocation?.coordinate)!) && ( self.userCurrentLocation?.coordinate.latitude != self.locationManager?.location?.coordinate.latitude ||  self.userCurrentLocation?.coordinate.longitude != self.locationManager?.location?.coordinate.longitude)
        {
            self.userCurrentLocation = userLocation
            NotificationCenter.default.post(name: notificationName, object: nil)  //Send notfication on location update
        }
    }
    
    //MARK:- fetch coutry name from current location
    func findCountryNameFromUserCurrentLocation(completion:  @escaping  (_ isSucess : Bool ,  _ dictData : [String : AnyObject]) -> Void)
    {
       let geocoder = CLGeocoder()
        let location = self.userCurrentLocation
       
        //Reverse Geocode to get location details like country, city,locality etc
        geocoder.reverseGeocodeLocation(location!) { (placemark:[CLPlacemark]?, error : Error?) in
            var dataDict = [String : String]()
            if error == nil && (placemark?.count)!>0
            {
                let tempPlaceMark = placemark?.last
                if tempPlaceMark?.country != nil
                {
                    dataDict[countryName] = tempPlaceMark?.country! ?? "Name N/A"
                    dataDict[countryCode] = tempPlaceMark?.isoCountryCode! ?? "Code N/A"
                    completion(true, dataDict as [String : AnyObject])
                }
            }
            else{
                dataDict["Error"] = error?.localizedDescription
                completion(false,dataDict as [String : AnyObject] )
            }
        }
    }
    
    //MARK:- get near by restaurant from FourSqaure API. I have created an app on FourSquare account
    func getVenuesWithLocation(completion:  @escaping  (_ isSucess : Bool ,  _ arrayOfData : [AnyObject]) -> Void) {
        //Create date string in yyyymmdd format. We have to pas this as a parameter in FourSquare API call
        let dateToday = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyymmdd"
        let dateString =  formatter.string(from: dateToday as Date)
        
        let urlString = API_URl + "venues/search?=v=\(dateString)&client_id=\(client_ID) &client_secret=\(client_Secret)&ll=\((self.userCurrentLocation?.coordinate.latitude)!),\((self.userCurrentLocation?.coordinate.longitude)!)&query=\(queryObject)&limit=10".replacingOccurrences(of: " ", with: "")
        
        if let url = URL(string: urlString) {
            let request = NSMutableURLRequest(url: url as URL)
            request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data {
                    if let resultInfo = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject> {
                        if let metaDict = resultInfo? ["meta"] as? Dictionary<String, AnyObject>
                        {
                            if (metaDict ["code"] as! Int) == 200
                            {
                                if  let responseArray = resultInfo? ["response"] as? Dictionary<String, AnyObject>
                                {
                                    let arrayOfVenues = responseArray["venues"]
                                    completion(true,arrayOfVenues as! [AnyObject] )
                                }
                            }
                            else{
                                completion(false, [metaDict["errorDetail"] as AnyObject])
                               }
                        }
                    }
                }
               else if error != nil
                {
                    completion(false, [error?.localizedDescription as AnyObject])
                }
            })
            task.resume()
        }
    }
    
   //MARK:- Map Zoom
    func zoomMapView(mapView : MKMapView)
    {
        var span = MKCoordinateSpan()
        span.latitudeDelta = 0.50
        span.longitudeDelta = 0.50
        //Set region
        var region = MKCoordinateRegion()
        region.span = span
        region.center = (self.userCurrentLocation?.coordinate)!
        //Set mapview region
        mapView.setRegion(region, animated: true)
    }
}
