//
//  User.swift
//  WolfVideo
//
//  Created by 石文文 on 2017/4/25.
//
//

import MySQLStORM
import StORM

class User: MySQLStORM {
    var id : Int = 0
    var name : String = ""
    var mobile : String = ""
    var password : String = ""
    var uuid : String = ""
    var email : String = ""
    var avatar : String = ""
    var create_time : String = ""
    var recharge_time : String = ""
    var isPermanent : Int = 0
    var status : Int = 0
    var tradeNo : String = ""
    override func table() -> String {
        return Sql_Users_table
    }
    override func to(_ this: StORMRow) {
        if this.data["id"] is Int64 {
            id = Int(this.data["id"] as! Int64)
        }else{
            id = this.data["id"] as! Int
        }
        
        name = this.data["name"] as! String
        mobile = this.data["mobile"] as! String
        password = this.data["password"] as! String
        uuid = this.data["uuid"] as? String ?? ""
        email = this.data["email"] as! String
        avatar = this.data["avatar"] as? String ?? "nil"
        avatar = avatar.characters.count < 1 ? "nil" : avatar
        create_time = this.data["create_time"] as? String ?? ""
        recharge_time = this.data["recharge_time"] as? String ?? ""
        if this.data["isPermanent"] is Int32 {
            isPermanent = Int(this.data["isPermanent"] as! Int32)
        }else{
            isPermanent = this.data["isPermanent"] as! Int
        }
        if this.data["status"] is Int32 {
            status = Int(this.data["status"] as! Int32)
        }else{
            status = this.data["status"] as! Int
        }
        tradeNo = this.data["tradeNo"] as? String ?? ""
    }
    
    func rows() -> [User] {
        var rows = [User]()
        for i in 0..<self.results.rows.count {
            let row = User()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
}
