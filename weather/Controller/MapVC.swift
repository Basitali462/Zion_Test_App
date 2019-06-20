//
//  ViewController.swift
//  weather
//
//  Created by Sajid Nawaz on 6/18/19.
//  Copyright © 2019 Sajid Nawaz. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController ,MKMapViewDelegate, CLLocationManagerDelegate {

    // ------------------------------------------------
    // MARK: outlets
    // ------------------------------------------------
    
     @IBOutlet weak var mapView: MKMapView!
    
    // ------------------------------------------------
    // MARK: variable
    // ------------------------------------------------
   
    let apiCaller = APICaller()
    let locationManager = CLLocationManager()
    var curlat = 0.0 , curlng = 0.0
    var location_namestr = "" , tempstr = ""
    let cache = NSCache<NSString, AnyObject>()
    var waetherarr = [WeatherModelClass]()
    
    // ------------------------------------------------
    // MARK: View life cycle method
    // ------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //for location
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest //kCLLocationAccuracyNearestTenMeters
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        //add tap gesture to map
        self.mapView.isZoomEnabled = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapMap))
        tapGesture.numberOfTapsRequired = 2
        self.mapView.addGestureRecognizer(tapGesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // ------------------------------------------------
    // MARK: Delegate method
    // ------------------------------------------------
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        curlat = locations.last!.coordinate.latitude
        curlng = locations.last!.coordinate.longitude
        let meters: Int = 5 * 3300
        let region: MKCoordinateRegion = MKCoordinateRegion(center: locations.last!.coordinate, latitudinalMeters: CLLocationDistance(meters), longitudinalMeters: CLLocationDistance(meters))
        mapView.setRegion(region, animated: false)
    }
    
    
    
    // ------------------------------------------------
    // MARK: custom method
    // ------------------------------------------------
    
    @objc func tapMap(_ sender: UITapGestureRecognizer) {
        
        let location = sender.location(in: self.mapView)
        let locValue = self.mapView.convert(location, toCoordinateFrom: self.mapView)
       
        let meters: Int = 5 * 3300
        let region: MKCoordinateRegion = MKCoordinateRegion(center: locValue, latitudinalMeters: CLLocationDistance(meters), longitudinalMeters: CLLocationDistance(meters))
        mapView.setRegion(region, animated: false)
        curlat = locValue.latitude
        curlng = locValue.longitude
        getWeatherUpdate()
        
    }
    
    // ------------------------------------------------
    // MARK: Api Call method
    // ------------------------------------------------
    
    private func getWeatherUpdate() {
        
        let url = "\(baseUrl)data/2.5/weather?lat=\(curlat)&lon=\(curlng)&appid=0a04048b63045f06ebe828e4cd3aa4db"
        
        
        if(HelperFuntions.isInternetAvailable())
        {
            
            LoadingOverlay.shared.showOverlay(view: UIApplication.shared.keyWindow!)
            
            apiCaller.sendAPICall("Get",
                                  methodNameWithBaseURL: url,
                                  params: nil,
                                  completed: {(succeeded:Bool, responseResult: AnyObject?)-> () in
                                    
                                    if(succeeded){
                                        
                                        DispatchQueue.main.async(execute: { () -> Void in
                                            
                                            LoadingOverlay.shared.hideOverlayView()
                                            if let status = responseResult?.object(forKey: "cod") as? Int {
                                                
                                                if status == 200 {
                                                    // get temprature of given cordinate
                                                    if let maindic = responseResult?.object(forKey: "main") as? NSDictionary {
                                                        if let temp = maindic.object(forKey: "temp") as? Double {
                                                            let celcius = temp - 273.15
                                                            self.tempstr = "Temperature: " + String(format: "%.0f", celcius) + "°C"
                                                        }
                                                    }
                                                    //get city name
                                                    if let name = responseResult?.object(forKey: "name") as? String {
                                                        self.location_namestr = "Location: \(name)"
                                                    }
                                                    
                                                    // store object in waether array for offline work
                                                    let waetherobj = WeatherModelClass(curlat: (Double(String(format: "%.2f", self.curlat)))!, curlng: (Double(String(format: "%.2f", self.curlat)))!, locationName: self.location_namestr, temp: self.tempstr)
                                                    if self.waetherarr.contains(where: {
                                                        waether in
                                                        waether.curlat == waetherobj.curlat
                                                            && waether.curlng == waetherobj.curlng
                                                            && waether.locationName == waetherobj.locationName
                                                            && waether.temp == waetherobj.temp
                                                        
                                                    })
                                                    {
                                                        print("exists in the array")
                                                    }
                                                    else {
                                                        self.waetherarr.append(waetherobj)
                                                    }
                                                    // show temprature and location
                                                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WeatherVC") as? WeatherVC
                                                    {
                                                        vc.location_namestr = self.location_namestr
                                                        vc.tempstr = self.tempstr
                                                        self.navigationController?.pushViewController(vc, animated: true)
                                                    }
                                                    
                                                   
                                                    
                                                }else {
                                                    
                                                }
                                            }
                                        })
                                        
                                        
                                    } else {
                                        
                                        DispatchQueue.main.async(execute: { () -> Void in
                                            
                                            LoadingOverlay.shared.hideOverlayView()
                                            
                                        })
                                    }
                                    
            })
            
        }
        else
        {
            HelperFuntions.DisplayMessageHelperWithcallbackOk(userMessage: internetNot, title: "Alert", myController: self, completion: { (bool) in
                // if internet is not available then check previous record if contain then show
               let weatherobj = self.waetherarr.filter {
                $0.curlat == (Double(String(format: "%.2f", self.curlat)))! &&
                $0.curlng == (Double(String(format: "%.2f", self.curlat)))!
                }
                if(weatherobj.count>0)
                {
                    // show temprature and location
                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WeatherVC") as? WeatherVC
                    {
                        vc.location_namestr = weatherobj[0].locationName
                        vc.tempstr = weatherobj[0].temp
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            })
        }
        
     
    }
    
}

