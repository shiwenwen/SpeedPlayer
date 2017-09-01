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
        if this.data["id"] is Int64 {
            id = Int(this.data["id"] as! Int64)
        }else{
            id = this.data["id"] as! Int
        }
        if this.data["status"] is Int32 {
            status = Int(this.data["status"] as! Int32)
        }else{
            status = this.data["status"] as! Int
        }
        
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

