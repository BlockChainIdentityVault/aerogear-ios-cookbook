/*
* JBoss, Home of Professional Open Source.
* Copyright Red Hat, Inc., and individual contributors
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/
import UIKit
import CoreLocation

import AeroGearHttp

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager:CLLocationManager = CLLocationManager()
    let session = Http()
    
    @IBOutlet var loadingIndicator : UIActivityIndicatorView? = nil
    @IBOutlet var icon : UIImageView?
    @IBOutlet var temperature : UILabel?
    @IBOutlet var loading : UILabel?
    @IBOutlet var location : UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.loadingIndicator?.startAnimating()
        self.view.backgroundColor = UIColor.white

        locationManager.requestAlwaysAuthorization()
        
        locationManager.startUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateWeatherInfo(_ latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        
        session.request(method: .get, path: "http://api.openweathermap.org/data/2.5/weather", parameters:  ["APPID": "1cbe434326367a7b5baed20ffaa4cf2c", "lat":latitude, "lon":longitude, "cnt":0], completionHandler: { (response: Any?, error: NSError?) -> Void in
            if error != nil {
                print("Error retrieving Weather \(error!)")
                return
            }
            if response != nil {
                // TODO refactor once AGIOS-13 is ready (object serialization)
                if let resp = response as? NSDictionary! {
                    print("JSON: " + resp.description)
                    DispatchQueue.main.async(execute: {
                        self.updateUISuccess(resp)
                    })
                }
            }
        })

    }
    
    
    func updateUISuccess(_ jsonResult: NSDictionary!) {
        self.loading?.text = nil
        self.loadingIndicator?.isHidden = true
        self.loadingIndicator?.stopAnimating()
        
        func temperatureUnit(_ country: String?, temperature: Double) -> Double {
            if (country == "US") {
                // Convert temperature to Fahrenheit if user is within the US
                return round(((temperature - 273.15) * 1.8) + 32)
            }
            else {
                // Otherwise, convert temperature to Celsius
                return round(temperature - 273.15)
            }
        }
        
        if let temperatureResult = ((jsonResult["main"] as! NSDictionary)["temp"] as? Double) {
            if let sys = (jsonResult["sys"] as? NSDictionary) {
                let temperature = temperatureUnit(sys["country"] as? String, temperature: temperatureResult)
                self.temperature?.text = "\(temperature)°"
                self.location?.text =  jsonResult["name"] as? String
                
                if let weather = jsonResult["weather"] as? NSArray {
                    let condition = (weather[0] as! NSDictionary)["id"] as! Int
                    let sunrise = sys["sunrise"] as! Double
                    let sunset = sys["sunset"] as! Double
                    var nightTime = false
                    let now = Date().timeIntervalSince1970
                    if (now < sunrise || now > sunset) {
                        nightTime = true
                    }
                    updateWeatherIcon(condition, nightTime: nightTime)
                    return
                }
            }
        }
        self.loading?.text = "Weather info is not available!"
    }
    
    /*
    *  To pick the right icon go check weather table
    *  http://bugs.openweathermap.org/projects/api/wiki/Weather_Condition_Codes
    */
    func updateWeatherIcon(_ condition: Int, nightTime: Bool) {
        var imageName: String
        switch (condition) {
        case let x where x < 300: imageName = "11"
        case let x where x < 500: imageName = "09"
        case let x where x < 504: imageName = "10"
        case let x where x < 532: imageName = "09"
        case let x where x < 623: imageName = "13"
        case let x where x < 800: imageName = "50"
        case let x where x == 800: imageName = "01"
        case let x where x == 801: imageName = "02"
        case let x where x == 802: imageName = "03"
        case let x where x == 803: imageName = "03"
        case let x where x == 804: imageName = "04"
        case let x where x < 1000: imageName = "11"
        case _: imageName = "dunno"
        }
        let night = "n"
        let day = "d"
        self.icon?.image = UIImage(named: "\(imageName)\(nightTime ? night : day ).png")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location:CLLocation = locations[locations.count-1] 
        
        if (location.horizontalAccuracy > 0) {
            self.locationManager.stopUpdatingLocation()
            print(">>\(location.coordinate)")
            updateWeatherInfo(location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        self.loading?.text = "Can't get your location!"
    }
}

