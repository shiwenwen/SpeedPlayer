//
//  BlackList.swift
//  SpeedPlayer
//
//  Created by 石文文 on 2017/9/27.
//

import MySQLStORM
import StORM
class BlackList: MySQLStORM {
    
    var errorCount : Int = 0
    var uuid : String = ""
    override init(){
        super.init()
    }
    override func table() -> String {
        return Sql_BlackList_tblle
    }
    override func to(_ this: StORMRow) {
        if this.data["errorCount"] is Int32 {
            errorCount = Int(this.data["errorCount"] as! Int32)
        }else{
            errorCount = this.data["errorCount"] as! Int
        }
        
        uuid = this.data["uuid"] as? String ?? ""
    }
    
    func rows() -> [BlackList] {
        var rows = [BlackList]()
        for i in 0..<self.results.rows.count {
            let row = BlackList()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
}
