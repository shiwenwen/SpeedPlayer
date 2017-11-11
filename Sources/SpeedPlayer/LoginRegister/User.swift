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
    var authCode : String = ""
    var uuid : String = ""
    var email : String = ""
    var avatar : String = ""
    var create_time : String = ""
    
    override func table() -> String {
        return Sql_Users_table
    }
    override func to(_ this: StORMRow) {
        id = Int("\(this.data["id"]!)")!
        name = this.data["name"] as! String
        mobile = this.data["mobile"] as! String
        password = this.data["password"] as! String
        authCode = this.data["authCode"] as! String
        uuid = this.data["uuid"] as? String ?? ""
        email = this.data["email"] as! String
        avatar = this.data["avatar"] as? String ?? "nil"
        avatar = avatar.count < 1 ? "nil" : avatar
        create_time = this.data["create_time"] as? String ?? ""
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
