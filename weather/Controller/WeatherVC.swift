//
//  MapVC.swift
//  weather
//
//  Created by Sajid Nawaz on 6/18/19.
//  Copyright © 2019 Sajid Nawaz. All rights reserved.
//

import UIKit

class WeatherVC: UIViewController {
    // ------------------------------------------------
    // MARK: outlets
    // ------------------------------------------------
    
    @IBOutlet weak var locationNamelbl: UILabel!
    @IBOutlet weak var templbl: UILabel!
    
    
    // ------------------------------------------------
    // MARK: variable
    // ------------------------------------------------
    
    var location_namestr = "" , tempstr = ""
    
    // ------------------------------------------------
    // MARK: View life cycle method
    // ------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationNamelbl.text = location_namestr
        templbl.text = tempstr
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
    // MARK: IBAction method
    // ------------------------------------------------
    
    @IBAction func backbtntpd(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

