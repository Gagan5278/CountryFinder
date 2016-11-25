//
//  RestaurantFinderViewController.swift
//  CountryFinder
//
//  Created by Mac on 22/11/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

//Cell Identifier
let cellIdentifier = "customCellIdentifier"

//MARK:- Constant used to fetch record from data coming from responce
let restaurantName = "name"
let restuarantAddress = "address"
let restuarantIcon = "icon"
let iconPrefix = "prefix"
let iconSuffix = "suffix"
let restuarantLocation = "location"
let categories = "categories"
let iconSize = "100"
let restaurantLat = "lat"
let restaurantLng = "lng"


class RestaurantFinderViewController: UIViewController {
    //Show progress while downloading. This time, Avoiding to add any HUDView to show request processing. Otherwise HudView is the best UI for Server response wait time
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var restaurantTableView: UITableView!
    //Array of records
    var arrayOfRestaurant = Array<Dictionary<String, AnyObject>>()
    //Dict to save images downloding from server
    //Note: Since we have to show only 10 record in tableview, so using Dictionary to save images. Otherwise we have to use any database for image saving
    var dictOfImages = Dictionary<String, AnyObject>()
    
    //Create objet for Custom location manager
    let customLocationManagerObject = CustomLocationManager.sharedInstance
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customLocationManagerObject.getVenuesWithLocation { (isSuccess : Bool, arrayOfData : [AnyObject]) in
            if isSuccess
            {
                //print("response is : \(arrayOfData)")
                if arrayOfData is [Dictionary<String, AnyObject>]
                {
                    self.arrayOfRestaurant = (arrayOfData as? [Dictionary<String, AnyObject>])!
                    weak var weakSelf = self
                    DispatchQueue.main.async {
                        weakSelf?.restaurantTableView.reloadData()
                        weakSelf?.activityIndicator.stopAnimating()
                    }
                }
            }
            else{
                let errorString = arrayOfData[0] as! String
               let alertController = UIAlertController(title: "Message", message: errorString, preferredStyle:.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Async download of images in cell icon
    func asyncDonloadImagesAtIndexpath(indexPath : IndexPath, completion: @escaping  (_ isSucess : Bool ,  _ image : UIImage) -> Void)
    {
        guard let dictTemp = self.arrayOfRestaurant[indexPath.row][categories], let arrayTemp = dictTemp as? Array<Dictionary<String, AnyObject>> else{
            return
        }
        guard let firstObject = arrayTemp[0]  as Dictionary<String, AnyObject>? , let iconDict = firstObject[restuarantIcon] as? Dictionary<String, AnyObject> else
        {
            return
        }
        
        //Create URL
        let urlString = (iconDict[iconPrefix] as! String)+iconSize+(iconDict[iconSuffix]as! String)
        
        if let url = URL(string: urlString) {
            let request = NSMutableURLRequest(url: url as URL)
            request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data {
                    if  let image =  UIImage(data: data)
                    {
                        completion(true,image)
                    }
                  }
                else if error != nil
                {
                    completion(false,UIImage(named: "defaultImage")!)
                }
            })
            task.resume()
        }
    }
    
     // MARK: - Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let mapViewForRestuarantObject = segue.destination as! RestaurantMapViewController
        mapViewForRestuarantObject.arrayOfRecors = self.arrayOfRestaurant
     }
}

//MARK:- TableView Delegate
extension RestaurantFinderViewController : UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

//MARK:- Tableview DataSource

extension RestaurantFinderViewController : UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfRestaurant.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CustomTableViewCell
        cell.backgroundColor = UIColor.gray    //Image were not displaying so added background color
        cell.restaurantTitleLabel.text = self.arrayOfRestaurant[indexPath.row][restaurantName] as? String
        cell.restaurantDetailLabel.text = self.arrayOfRestaurant[indexPath.row][restuarantLocation]?[restuarantAddress] as? String
        let keyValue = "\(indexPath.row)"
        if (self.dictOfImages[keyValue] != nil)
        {
            cell.restaurantIconImageView.image = self.dictOfImages[keyValue] as! UIImage?
        }
        else{
            self.asyncDonloadImagesAtIndexpath(indexPath: indexPath ) { (isSuccess, image) in
                DispatchQueue.main.async {
                    cell.restaurantIconImageView.image = image
                    self.dictOfImages[keyValue] = image
                }
            }
        }
        return cell
    }
}

