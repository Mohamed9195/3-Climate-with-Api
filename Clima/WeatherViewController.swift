// use  in proporty list it Privacy - Location Usage Description  and Privacy - Location When In Use Usage Description and write any message
// and use it to use http not https     <key>NSAppTransportSecurity</key><dict><key>NSExceptionDomains</key><dict><key>openweathermap.org</key><dict><key>NSIncludesSubdomains</key><true/><key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key><true/></dict></dict></dict>

//<key>NSLocationUsageDescription</key>
//<string>We Need Your Location To Obtain Your Current Weather Conditions </string>
//<key>NSLocationWhenInUseUsageDescription</key>
//<string>We Need Your Location To Obtain Your Current Weather Conditions </string>

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import SVProgressHUD
import UserNotifications


class WeatherViewController: UIViewController, CLLocationManagerDelegate , ChangeCityDelegate {
    
    
    
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    //  let myapp_id = "1db4e1a4eb15bd9835b8fad195c79bc5"
    
    
    //TODO: Declare instance variables here
    let locationManger = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var ChangType: UISwitch!
    
    
    @IBAction func PressCahngType(_ sender: UISwitch) {
        if sender.isOn  != true {
            temperatureLabel.text = String(weatherDataModel.temperature + 273) + "°f"
            
        }
        else
        {
            temperatureLabel.text = String(weatherDataModel.temperature ) + "°c"
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert , .badge , .sound ]) { (didAllow, error) in }
        
        //TODO:Set up the location manager here.
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManger.requestWhenInUseAuthorization()
        locationManger.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking from alamofire send to server by API
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url: String ,parameters: [String : String]){
        SVProgressHUD.show(withStatus: "Loading....")
        Alamofire.request(url , method: .get , parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                //  print("Success! Got the Weather data")
                
                let weatherJSON: JSON = JSON(response.result.value!)
                // print(weatherJSON)
                self.updateWeatherData(json: weatherJSON)
            }
            else {
                SVProgressHUD.dismiss()
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
                self.temperatureLabel.text = "?!"
            }
        }
    }
    
    
    
    //MARK: - JSON Parsing resive from server by API
    /***************************************************************/
    
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json : JSON){
        
        if let tempResult = json["main"]["temp"].double {
            weatherDataModel.temperature = Int(tempResult - 273.15)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            updateUIWithWeatherDate()
        }
        else
        {
            SVProgressHUD.dismiss()
            cityLabel.text = "weather Unavilable"
            self.temperatureLabel.text = "?!"
        }
    }
    
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func  updateUIWithWeatherDate() {
        SVProgressHUD.dismiss()
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = String(weatherDataModel.temperature) + "°c"
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManger.stopUpdatingLocation()
            locationManger.delegate = nil
            
            //print("longitude = \(location.coordinate.longitude) , latitude = \(location.coordinate.latitude)")
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let params: [String : String] = ["lat": latitude , "lon": longitude , "appid": APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
            //showMapKit(lat:  , lon: )
        }
    }
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unvilable"
        temperatureLabel.text = "?!"
        
    }
    
    
    
    
    
    
    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredAnewCityName(city: String) {
        let params : [String : String] = ["q" : city , "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            let destinationVC = segue.destination as? ChangeCityViewController
            destinationVC?.delegate = self
            
        }
    }
    

    
}


