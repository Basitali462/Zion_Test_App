//
//  WeatherModelClass.swift
//  weather
//
//  Created by Sajid Nawaz on 6/18/19.
//  Copyright © 2019 Sajid Nawaz. All rights reserved.
//

class WeatherModelClass{
    
    var curlat: Double!
    var curlng: Double!
    var locationName: String!
    var temp: String!
    
    init(curlat : Double, curlng : Double , locationName: String,temp: String) {
        self.curlat = curlat
        self.curlng = curlng
        self.locationName = locationName
        self.temp = temp
    }
    
}

