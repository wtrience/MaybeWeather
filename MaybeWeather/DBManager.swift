//
//  DBManager.swift
//  MaybeWeather
//
//  Created by wtrience on 15/12/3.
//  Copyright © 2015年 wtrience. All rights reserved.
//

import UIKit

class DBManager: NSObject {
    
    var db: COpaquePointer = nil
    
    let dbName = "/Users/wtrience/Desktop/MaybeWeather/MAYBE.db"
    
    let sql1 = "create table IF NOT EXISTS Province (" +
        "id INTEGER PRIMARY KEY AUTOINCREMENT," +
        "province_name TEXT," +
    "province_code TEXT) "
    
    let sql2 = "CREATE TABLE IF NOT EXISTS City ( " +
        "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
        "city_name TEXT, " +
        "city_code TEXT, " +
    "province_name TEXT )"
    
    let sql3 = "CREATE TABLE IF NOT EXISTS County ( " +
        "id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, " +
        "county_name TEXT NOT NULL, " +
        "county_code TEXT NOT NULL, " +
    "city_name TEXT )"
    
    private override init() {
        
        if sqlite3_open(dbName, &db) == SQLITE_OK {
            print("打开数据库成功")
            
            let r1 = sqlite3_exec(db, sql1.cStringUsingEncoding(NSUTF8StringEncoding)!, nil, nil, nil) == SQLITE_OK
            let r2 = sqlite3_exec(db, sql2.cStringUsingEncoding(NSUTF8StringEncoding)!, nil, nil, nil) == SQLITE_OK
            let r3 = sqlite3_exec(db, sql3.cStringUsingEncoding(NSUTF8StringEncoding)!, nil, nil, nil) == SQLITE_OK
            
            if (r1 && r2 && r3) {
                print("创表成功")
                //                // TODO: 测试查询数据
                //                let sql = "SELECT id, DepartmentNo, Name FROM T_Department;"
                //                recordSet(sql)
            } else {
                print("创表失败")
            }
        } else {
            print("打开数据库失败")
        }
    }
    

    class var sharedInstance : DBManager {
        struct Static {
            static let instance : DBManager = DBManager()
            }
        return Static.instance
    }
    
    

//     func openDatabase(dbname: String) -> Bool {
//
//        let path = dbname
//        print(path)
//
//        if sqlite3_open(path, &db) == SQLITE_OK {
//            print("打开数据库成功")
//
//            if createTable() {
//                print("创表成功")
////                // TODO: 测试查询数据
////                let sql = "SELECT id, DepartmentNo, Name FROM T_Department;"
////                recordSet(sql)
//            } else {
//                print("创表失败")
//            }
//        } else {
//            print("打开数据库失败")
//        }
//        return false
//    }
//    
//    
//    // 一次性创建
//    private func createTable() -> Bool {
//
//        let sql1 = "create table IF NOT EXISTS Province (" +
//            "id INTEGER PRIMARY KEY AUTOINCREMENT," +
//            "province_name TEXT," +
//            "province_code TEXT) "
//        
//        let sql2 = "CREATE TABLE IF NOT EXISTS City ( " +
//            "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
//            "city_name TEXT, " +
//            "city_code TEXT, " +
//            "province_name TEXT )"
//        
//        let sql3 = "CREATE TABLE IF NOT EXISTS County ( " +
//            "id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, " +
//            "county_name TEXT NOT NULL, " +
//            "county_code TEXT NOT NULL, " +
//            "city_name TEXT )"
//        
//        let r1 = execSQL(sql1)
//        let r2 = execSQL(sql2)
//        let r3 = execSQL(sql3)
//        
//        return r1 && r2 && r3
//    }
    
    
    
    func execSQL(sql: String) -> Bool {
        
        return sqlite3_exec(db, sql.cStringUsingEncoding(NSUTF8StringEncoding)!, nil, nil, nil) == SQLITE_OK
    }
    
    
    ///  执行 SQL 返回一个结果集(对象数组)
    ///
    ///  :param: sql SQL 字符串
    func recordSet(sql: String) {
        // 1. 准备语句
        var stmt: COpaquePointer = nil
        /**
        1. 数据库句柄
        2. SQL 的 C 语言的字符串
        3. SQL 的 C 语言的字符串长度 strlen，-1 会自动计算
        4. stmt 的指针
        5. 通常传入 nil
        */
        if sqlite3_prepare_v2(db, sql.cStringUsingEncoding(NSUTF8StringEncoding)!, -1, &stmt, nil) == SQLITE_OK {
            // 单步获取SQL执行的结果 -> sqlite3_setup 对应一条记录
            while sqlite3_step(stmt) == SQLITE_ROW {
                // 获取每一条记录的数据
                recordData(stmt)
            }
        }
    }
    ///  获取每一条数据的记录
    ///
    ///  :param: stmt prepared_statement 对象
    func recordData(stmt: COpaquePointer) -> String {
        // 获取到记录
        let count = sqlite3_column_count(stmt)
        var str : String = ""
        print("获取到记录，共有多少列 \(count)")
        // 遍历每一列的数据
        for i in 0..<count {
            
//            let type = sqlite3_column_type(stmt, i)
            // 根据字段的类型，提取对应列的值
//            switch type {
//            case SQLITE_INTEGER:
//                print("整数 \(sqlite3_column_int64(stmt, i))")
//            case SQLITE_FLOAT:
//                print("小树 \(sqlite3_column_double(stmt, i))")
//            case SQLITE_NULL:
//                print("空 \(NSNull())")
//            case SQLITE_TEXT:
                let chars = UnsafePointer<CChar>(sqlite3_column_text(stmt, i))
                str =  String(CString: chars, encoding: NSUTF8StringEncoding)!
//            String(CString: chars, encoding: NSUTF8StringEncoding)!
            
//                print("字符串 \(str)")
//            case let type:
//                print("不支持的类型 \(type)")
//            }
        }
        return str
    }
    
    func getAreaCode(table : String,areaName :String ,selection : String ,column : String) -> String{
        
        var areaCode : String = ""
        let sql = "select \(column) from \(table) where \(selection) = '\(areaName)'"
        
        var stmt: COpaquePointer = nil
    
        if sqlite3_prepare_v2(db, sql.cStringUsingEncoding(NSUTF8StringEncoding)!, -1, &stmt, nil) == SQLITE_OK {

            while sqlite3_step(stmt) == SQLITE_ROW {

                let count = sqlite3_column_count(stmt)
                print("获取到记录，共有多少列 \(count)")
                // 遍历每一列的数据
                for i in 0..<count {
                    let chars = UnsafePointer<CChar>(sqlite3_column_text(stmt, i))
                    let str = String(CString: chars, encoding: NSUTF8StringEncoding)!
                    areaCode = str
                    print(str)
                }
            }
        }
        return areaCode
    }
    
    func getProvinces() ->[String]{
        
        var provinces = [String]()
        
        let sql = "select province_name from Province"
        
        var stmt: COpaquePointer = nil
        
        if sqlite3_prepare_v2(db, sql.cStringUsingEncoding(NSUTF8StringEncoding)!, -1, &stmt, nil) == SQLITE_OK {
            
            while sqlite3_step(stmt) == SQLITE_ROW {
                
                provinces.append(recordData(stmt))
                
//                let count = sqlite3_column_count(stmt)
//                print("获取到记录，共有多少列 \(count)")
//                // 遍历每一列的数据
//                for i in 0..<count {
//                    let chars = UnsafePointer<CChar>(sqlite3_column_text(stmt, i))
//                    let str = String(CString: chars, encoding: NSUTF8StringEncoding)!
//                    areaCode = str
//                    print(str)
//                }
            }
        }
        return provinces
    }
    
    func getCities(provinceName: String) ->[String]{
        
        var cities = [String]()
        
        let sql = "select city_name from City where province_name = '\(provinceName)'"
        
        var stmt: COpaquePointer = nil
        
        if sqlite3_prepare_v2(db, sql.cStringUsingEncoding(NSUTF8StringEncoding)!, -1, &stmt, nil) == SQLITE_OK {
            
            while sqlite3_step(stmt) == SQLITE_ROW {
                
                cities.append(recordData(stmt))
                
            }
        }
        return cities
    }
    
    func getCounties(cityName: String) ->[String]{
        
        var counties = [String]()
        
        let sql = "select county_name from County where city_name = '\(cityName)'"
        
        var stmt: COpaquePointer = nil
        
        if sqlite3_prepare_v2(db, sql.cStringUsingEncoding(NSUTF8StringEncoding)!, -1, &stmt, nil) == SQLITE_OK {
            
            while sqlite3_step(stmt) == SQLITE_ROW {
                
                counties.append(recordData(stmt))
                
                //                let count = sqlite3_column_count(stmt)
                //                print("获取到记录，共有多少列 \(count)")
                //                // 遍历每一列的数据
                //                for i in 0..<count {
                //                    let chars = UnsafePointer<CChar>(sqlite3_column_text(stmt, i))
                //                    let str = String(CString: chars, encoding: NSUTF8StringEncoding)!
                //                    areaCode = str
                //                    print(str)
                //                }
            }
        }
        return counties
    }
    
    func saveProvince(province : Province) -> Bool{
        let provinceCode : String = province.provinceCode
        let provinceName : String = province.provinceName
        let sql = "INSERT INTO Province(province_name,province_code) VALUES('\(provinceName)','\(provinceCode)')";
        return self.execSQL(sql)
    }
    
    func saveCity(city : City) -> Bool{
        let cityName : String = city.cityName!
        let cityCode : String = city.cityCode!
        let provinceName  : String = city.provinceName!
        let sql = "INSERT INTO City(city_name,city_code,province_name) VALUES('\(cityName)','\(cityCode)','\(provinceName)')";
        
        return self.execSQL(sql)
    }
    
    func saveCounty(county : County) -> Bool{
        let countyName : String = county.countyName!
        let countyCode : String = county.countyCode!
        let cityName : String = county.cityName!
        let sql = "INSERT INTO County(county_name,county_code,city_name) VALUES('\(countyName)','\(countyCode)','\(cityName)')";
        return self.execSQL(sql)
    }
}
