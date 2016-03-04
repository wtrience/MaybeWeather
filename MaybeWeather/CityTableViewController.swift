//
//  CityTableViewController.swift
//  MaybeWeather
//
//  Created by wtrience on 15/12/5.
//  Copyright © 2015年 wtrience. All rights reserved.
//

import UIKit

class CityTableViewController: UITableViewController {
    
    //MARK:Property
    var areas = [String]()
    var province : String = ""
    var selectedArea : String = ""
    let dbManager = DBManager.sharedInstance

    override func viewDidLoad() {
        self.tableView.delegate=self;
        super.viewDidLoad()

        loadAreas()
    }
    
    func loadAreas() {
        
        if(dbManager.getCities(province) != []){
            for var i in dbManager.getCities(province){
                areas.append(i)
            }
        }else{
            httpRequestCity(province)
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
        
        let cellIdentifier = "CityTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CityTableViewCell
        
        // Fetches the appropriate meal for the data source layout.
        let area = areas[indexPath.row]
        
        cell.cityName.text = area
        
        return cell
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    func httpRequestCity(provinceName : String){
        
        let provinceCode = dbManager.getAreaCode("Province",areaName: provinceName,selection: "province_name",column: "province_code")
        let url = NSURL(string: "http://www.weather.com.cn/data/list3/city\(provinceCode).xml")
        print(url);
        
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: url!)
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            
            var NSstr = NSString.init(data:data!,encoding:NSUTF8StringEncoding)
            var str = NSstr as! String
            var subStr = str.componentsSeparatedByString(",")
            for var i in subStr{
                var temp = i.componentsSeparatedByString("|")
                var city = City()
                city.provinceName = self.province
                city.cityCode = temp[0]
                city.cityName = temp[1]
                
                self.dbManager.saveCity(city)
                
//                if(!self.dbManager.saveCity(city)){
//                    print("存储失败")
//                    return
//                }
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowCounties" {
            let countyViewController = segue.destinationViewController as! ListTableViewController
            
            // Get the cell that generated this segue.
            if let selectedCountyCell = sender as? CityTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedCountyCell)!
                let cityName = areas[indexPath.row]
                countyViewController.city = cityName
            }
        }
    }
    
    
}
