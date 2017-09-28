//
//  authCode.swift
//  WolfVideo
//
//  Created by 石文文 on 2017/4/30.
//
//

import MySQLStORM
import StORM
class AuthCode: MySQLStORM {
    var id : Int = 0
    var status : Int = 0
    var authCode : String = ""
    override init(){
        super.init()
    }
    override func table() -> String {
        return Sql_AuthCodes_table
    }
    override func to(_ this: StORMRow) {
        
        id = Int("\(this.data["id"]!)")!
        status = Int("\(this.data["status"]!)")!
        
        authCode = this.data["authCode"] as! String
    }
    
    func rows() -> [AuthCode] {
        var rows = [AuthCode]()
        for i in 0..<self.results.rows.count {
            let row = AuthCode()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
}

