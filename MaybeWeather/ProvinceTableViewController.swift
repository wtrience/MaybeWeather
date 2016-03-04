//
//  ProvinceTableViewController.swift
//  MaybeWeather
//
//  Created by wtrience on 15/12/5.
//  Copyright © 2015年 wtrience. All rights reserved.
//

import UIKit

class ProvinceTableViewController: UITableViewController{
    
    //MARK: Properties
    var areas = [String]()
    var selectedArea : String = ""
    let dbManager = DBManager.sharedInstance
    


    override func viewDidLoad() {
        
        self.tableView.delegate=self;

        super.viewDidLoad()

        loadAreas()
    }

    func loadAreas() {
        
        if(dbManager.getProvinces() != []){
            for var i in dbManager.getProvinces(){
                areas.append(i)
            }
        }else{
            httpRequestProvinces()
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
        
        let cellIdentifier = "ProvinceTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ProvinceTableViewCell
        
        // Fetches the appropriate meal for the data source layout.
        let area = areas[indexPath.row]
        
        cell.provinceName.text = area
        
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowCities" {
            let cityViewController = segue.destinationViewController as! CityTableViewController
            
            // Get the cell that generated this segue.
             if let selectedCityCell = sender as? ProvinceTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedCityCell)!
                let provinceName = areas[indexPath.row]
                cityViewController.province = provinceName
            }
        }
    }
    

    func httpRequestProvinces(){
        
        let url = NSURL(string: "http://www.weather.com.cn/data/list3/city.xml")
        print(url);
        
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: url!)
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            
            let NSstr = NSString.init(data:data!,encoding:NSUTF8StringEncoding)
            let str = NSstr as! String
            let subStr = str.componentsSeparatedByString(",")
            for var i in subStr{
                var temp = i.componentsSeparatedByString("|")
                var province = Province()
                province.provinceCode = temp[0]
                province.provinceName = temp[1]
                if(!self.dbManager.saveProvince(province)){
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
