//
//  ViewController.swift
//  MaybeWeather
//
//  Created by wtrience on 15/11/30.
//  Copyright © 2015年 wtrience. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, NSURLSessionDataDelegate,NSXMLParserDelegate{
    
    //MARK:Properties
    @IBOutlet weak var areaName: UILabel!
    @IBOutlet weak var weatherInfo: UILabel!
    @IBOutlet weak var releaseTtime: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var temp: UILabel!
    @IBAction func refresh(sender: UIBarButtonItem) {
        self.getWeatherCode(selectedCounty)
    }
    
    var weatherDic : [String: String] = [:]
    var selectedCounty = "010101"
    
    let locationManager:CLLocationManager = CLLocationManager()
    var urlSession:NSURLSession = NSURLSession()
    var countyCode : String = ""
    let dbManager = DBManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if(ios8()){
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.startUpdatingLocation()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func ios8() -> Bool{
        let versionCode:String = UIDevice.currentDevice().systemVersion
        let start:String.Index = versionCode.startIndex.advancedBy(0)
        let end:String.Index = versionCode.startIndex.advancedBy(1)
        let range = Range<String.Index>(start: start, end: end)
        let version = NSString(string: UIDevice.currentDevice().systemVersion.substringWithRange(range)).doubleValue
        return version >= 8.0
    }
    
    //MARK: CoreLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let location:CLLocation = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude

            let address = "http://api.map.baidu.com/geocoder?location=\(latitude),\(longitude)&output=json&key=28bcdd84fae25699606ffad27f8da77b"
            locationManager.stopUpdatingLocation()

            requestLocalWeather(address)

        }
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError){
        print(error)
    }


    func requestLocalWeather(address:String){
        let url = NSURL(string: address)
        print(url);
        
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: url!)
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print("http request error \(error)")
                return
            }
            
            let json : AnyObject! = try? NSJSONSerialization
                .JSONObjectWithData(data!, options:NSJSONReadingOptions.AllowFragments)
            print("Json Object:");
            
            
            let currentAreaName : AnyObject = json.objectForKey("result")!.objectForKey("addressComponent")!.objectForKey("city")!
            print(currentAreaName as? String)
            
            let temp = currentAreaName as? String
            let areaName = (temp! as NSString).substringToIndex(2)

            
            let areaCode = self.dbManager.getAreaCode("County",areaName: areaName as String,selection: "county_name",column: "county_code")
            if(areaName == ""){
                
            }
            self.requestWeatherByCode("101010100")
        })
        task.resume()
        
    }
    
    func parceJson(jsonResult:AnyObject){
        
        let city : AnyObject = jsonResult.objectForKey("weatherinfo")!.objectForKey("city")!
        let time : AnyObject = jsonResult.objectForKey("weatherinfo")!.objectForKey("ptime")!
        let weather : AnyObject = jsonResult.objectForKey("weatherinfo")!.objectForKey("weather")!
        let temp1 : AnyObject = jsonResult.objectForKey("weatherinfo")!.objectForKey("temp1")!
        let temp2 : AnyObject = jsonResult.objectForKey("weatherinfo")!.objectForKey("temp2")!
        let temp = (temp2 as? String)! + "  ~  " + (temp1 as? String)!
        
        weatherDic = ["city":(city as? String)!,"weather":(weather as? String)!,"time":(time as? String)!,"temp":temp]
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            dispatch_sync(dispatch_get_main_queue(),{
                self.updateUI(self.weatherDic)
            })
        })
    
    }
    
    func updateUI(weatherDic: [String:String] ){
    
        areaName.text = weatherDic["city"]
        releaseTtime.text = weatherDic["time"]
        weatherInfo.text = weatherDic["weather"]
        if(weatherDic["weather"] == "晴"){
            weatherIcon.image=UIImage(named:"qing")
        }else if(weatherDic["weather"] == "小雨" || weatherDic["weather"] == "中雨"){
            weatherIcon.image=UIImage(named:"yu")
        }else if(weatherDic["weather"] == "多云" || weatherDic["weather"] == "阴"){
            weatherIcon.image=UIImage(named:"yin")
        }
        else{
            weatherIcon.image=UIImage(named:"weizhi")
        }
        temp.text = weatherDic["temp"]
    }
    
    func getWeatherCode(areaCode :String){
        
        let url = NSURL(string: "http://www.weather.com.cn/data/list3/city\(areaCode).xml")
        print(url);
        
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: url!)
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            
            let NSstr = NSString.init(data:data!,encoding:NSUTF8StringEncoding)
            let str = NSstr as! String
            let subStr = str.componentsSeparatedByString("|")
            self.requestWeatherByCode(subStr[1])
        })
        task.resume()
    }
    
    func requestWeatherByCode(weatherCode : String){
        
        let url = NSURL(string: "http://www.weather.com.cn/data/cityinfo/\(weatherCode).html")
        print(url);
        
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: url!)
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            
            let json : AnyObject! = try? NSJSONSerialization
                .JSONObjectWithData(data!, options:NSJSONReadingOptions.AllowFragments)
            print("Json Object:");
            self.parceJson(json)
        })
        task.resume()
    }
    
}