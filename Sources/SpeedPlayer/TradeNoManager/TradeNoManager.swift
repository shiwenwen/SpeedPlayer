//
//  AuthCodeManager.swift
//  WolfVideo
//
//  Created by 石文文 on 2017/4/30.
//
//

import PerfectLib
import PerfectHTTPServer
import PerfectHTTP
import MySQLStORM
import PerfectLogger
import StORM



struct TradeNoManager {
    
    static func start() -> Routes {
        let baseRoutes = Routes(baseUri: "/tradeNoManager")
        
        return baseRoutes
    }
    

}
