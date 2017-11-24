//
//  OpenWeatherAppClient.swift
//  Do I Need My Jacket
//
//  Created by Duy Le on 11/20/17.
//  Copyright © 2017 Duy Le. All rights reserved.
//

import Foundation

class OpenWeatherAppClient{
    static func getCurrentWeather(cityName: String, completeHandler: @escaping (_ result: [String:Any],_ error: String) -> Void){
        
        let request = NSMutableURLRequest(url: buildUrl(cityName: cityName))
        let session = URLSession.shared
        
        let task = session.dataTask(with: (request as? URLRequest)!, completionHandler: { (data, respond, error) in
            if error == nil {
                var parsedData: [String:AnyObject] = [:]
                do {
                    try parsedData = (JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:AnyObject])!
                    completeHandler(parsedData, "")
                }
                catch {
                    print("parse data err")
                    completeHandler([:],error.localizedDescription)
                }
            }
            else {
                print(error?.localizedDescription)
                completeHandler([:], "task err")
            }
        })
        task.resume()
    }
    private static func buildUrl(cityName: String) ->  URL {
        var urlDictionary = [String:String]()
        urlDictionary[OpenWeatherAppConstant.RequestParameter.AppId] = OpenWeatherAppConstant.API.key
        urlDictionary[OpenWeatherAppConstant.RequestParameter.Name] = cityName
        
    
        let urlString = "\(OpenWeatherAppConstant.APIBaseUrl)\(escapedParameter(parameter: urlDictionary))"
        let url = URL(string: urlString)
        return url!
    }
    
    private static func escapedParameter(parameter: [String:String]) -> String{
        if parameter.isEmpty {
            return ""
        }
        var parameterArr = [String]()
        for (key,value) in parameter {
            let stringValue = "\(value)"
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            parameterArr.append(key + "=" + "\(escapedValue!)")
        }
        return parameterArr.joined(separator: "&")
    }
}
