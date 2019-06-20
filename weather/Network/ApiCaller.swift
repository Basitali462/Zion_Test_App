//
//  ApiCaller.swift
//  weather
//
//  Created by Sajid Nawaz on 6/18/19.
//  Copyright © 2019 Sajid Nawaz. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration

import Foundation

class APICaller: NSObject, NSURLConnectionDelegate
{
    
    var responseData:Data? = nil
    let apiRequestTimeOut : TimeInterval    = 50 //seconds
    
    func sendAPICall(_ type : String, methodNameWithBaseURL method : String, params param: AnyObject?, completed : @escaping (_ succeeded: Bool, _ result: AnyObject?) -> Void) {
        
        
            switch type {
            case "Get":
                
                sendGetCall(method, postCompleted: {(succeeded: Bool, msg: AnyObject) -> () in
                    
                    if(succeeded) {
                        
                        let responseResult  = msg as! NSDictionary
                        completed(true, responseResult)
                    }
                        
                    else {
                        
                        completed(false, msg)
                    }
                })
               
            default:
               break
        }
    }
        
    //GET
    func sendGetCall( _ url : String, postCompleted : @escaping (_ succeeded: Bool, _ result: AnyObject) -> ()) {
        
        var request = URLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        request.httpMethod = "GET"
        request.timeoutInterval = apiRequestTimeOut
        
        //var err: NSError?
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            print("Response: \(String(describing: response))")
            
            let httpURLResponse =  response as? HTTPURLResponse;
            if let statusCode = httpURLResponse?.statusCode {
                
                switch (statusCode) {
                    
                case 200:                   // Authorized
                    
                    break;
                case 401:                   // Unauthorized
                    
                    postCompleted(false, ["Error" : 401] as AnyObject)
                    return
                case 404:                   // Unauthorized when URL Changed
                    
                    postCompleted(false, ["Error" : 404] as AnyObject)
                    return
                default:
                    
                    break;
                }
            }
            
            if (data == nil) {
                
                postCompleted(false, "Error" as AnyObject)
                
            } else {
                
                let responseResult = self.parseDataToJSON(data!)
                
                if responseResult == nil {
                    
                    postCompleted(false, "Error" as AnyObject)
                    
                }else{
                    
                    postCompleted(true, responseResult! as AnyObject)
                }
            }
            
            
            
        })
        
        task.resume()
    }

    
    private func parseDataToJSON(_ data:Data) -> NSDictionary? {
        
        //var err: NSError?
        //var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                print(json)
                
                return json
            } else {
                // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                let jsonStr = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                print("Error could not parse JSON: \(String(describing: jsonStr))")
                return nil
            }
            
        } catch {
            
            print(error)
            let jsonStr = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            print("Error could not parse JSON: '\(String(describing: jsonStr))'")
            return nil
            
        }
        
    }
}
    

