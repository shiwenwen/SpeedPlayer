//
//  authCode.swift
//  WolfVideo
//
//  Created by 石文文 on 2017/4/30.
//
//

import MySQLStORM
import StORM
class TradeNo: MySQLStORM {
    
    var trade_no : String = ""
    var create_time : String = ""
    override init(){
        super.init()
    }
    override func table() -> String {
        return Sql_TradeNo_tblle
    }
    override func to(_ this: StORMRow) {
        
        
        trade_no = this.data["trade_no"] as! String
        create_time = this.data["create_time"] as? String ?? ""
    }
    
    func rows() -> [TradeNo] {
        var rows = [TradeNo]()
        for i in 0..<self.results.rows.count {
            let row = TradeNo()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
}

