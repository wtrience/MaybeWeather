//
//  ListTableViewController.swift
//  MaybeWeather
//
//  Created by wtrience on 15/12/3.
//  Copyright © 2015年 wtrience. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    
    // MARK: Properties
    
    var areas = [String]()
    var dbManager = DBManager.sharedInstance
    var selectedArea : String = ""
    var city : String = ""
    
    override func viewDidLoad() {
        self.tableView.delegate=self;
        super.viewDidLoad()
    
        loadAreas()
    }
    
    func loadAreas() {

        if(dbManager.getCounties(city) != []){
            for var i in dbManager.getCounties(city){
                areas.append(i)
            }
        }else{
            httpRequestCounties(city)
        }
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return areas.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "ListTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ListTableViewCell
        
        // Fetches the appropriate meal for the data source layout.
        let area = areas[indexPath.row]
        
        cell.areaName.text = area

        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowWeather" {
            let weatherViewController = segue.destinationViewController as! ViewController
            
            // Get the cell that generated this segue.
            if let selectedCountyCell = sender as? ListTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedCountyCell)!
                let countyName = areas[indexPath.row]
                let countyCode = self.dbManager.getAreaCode("County",areaName: countyName as String,selection: "county_name",column: "county_code")
                weatherViewController.selectedCounty = countyCode
                weatherViewController.getWeatherCode(countyCode)
            }
        }
    }
    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        
//            selectedArea  = areas[indexPath.row]
//            switch currentLevel{
//                //provinceLevel
//            case 0 :
//                areas = dbManager.getCities(selectedArea)
//                if(areas == []){
//                    
//                }
//                tableView.reloadData()
//                currentLevel = 1
//                break
//            case 1 :
//                areas = dbManager.getCounties(selectedArea)
//                selectedArea  = areas[indexPath.row]
//                currentLevel = 2
//                break
////            case 2 :
////                areas = dbManager.getCounties(selectedArea)
////                selectedArea  = areas[indexPath.row]
//            default:
//                break
//            }
//        
//    }
    
    func httpRequestCounties(cityName : String){
        
        let cityCode = dbManager.getAreaCode("City",areaName: cityName,selection: "city_name",column: "city_code")
        let url = NSURL(string: "http://www.weather.com.cn/data/list3/city\(cityCode).xml")
        print(url);
        
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: url!)
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            
            var NSstr = NSString.init(data:data!,encoding:NSUTF8StringEncoding)
            var str = NSstr as! String
            var subStr = str.componentsSeparatedByString(",")
            for var i in subStr{
                var temp = i.componentsSeparatedByString("|")
                var county = County()
                county.cityName = self.city
                county.countyCode = temp[0]
                county.countyName = temp[1]
                if(!self.dbManager.saveCounty(county)){
                    print("存储失败")
                    return
                }
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                dispatch_sync(dispatch_get_main_queue(),{
                    self.loadAreas()
                    self.tableView.reloadData()
                })
            })
        })
        task.resume()
    }
}
