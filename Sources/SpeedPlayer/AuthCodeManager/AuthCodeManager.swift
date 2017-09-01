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



struct AuthCodeManager {
    
    static func start() -> Routes {
        var baseRoutes = Routes(baseUri: "/authCodeManager")
        let get = getAuthList()
        let add = addNewAuthCodes()
        baseRoutes.add(get.start())
        baseRoutes.add(add.start())
        
        return baseRoutes
    }
    
    struct getAuthList {
        func start() -> Route {
            let route = Route(method: .get, uri: "/getAuthList") { (request, response) in
                defer{
                    response.completed()
                }
                let pageNum = request.param(name: "pageNum", defaultValue: "0")!
                let pageSize = request.param(name: "pageSize", defaultValue: "50")!
                do{
                    let authCode = AuthCode()
                    let thisCursor = StORMCursor(
                        limit: Int(pageSize)!,
                        offset:Int(pageNum)! * Int(pageSize)!
                    )
                    try authCode.select(whereclause: "", params: [], orderby: ["status"],cursor:thisCursor)
                    var authCodes = [[String:Any]]()
                    for code in authCode.rows() {
                        authCodes.append(["authCode":code.authCode,
                                          "status":code.status])
                    }
                    let body = Tools.responseJson(data: ["authCodes":authCodes])
                    try response.setBody(json:body)
                    return
                }catch{
                    LogFile.error("\(error)")
                    let _ = try? response.setBody(json:Tools.responseJson(data: [:], txt: nil, status: nil, code: .defaultError, msg: "请求失败"))
                }
            }
            
            return route
        }
        
    }
    struct addNewAuthCodes {
        func start() -> Route {
            let route = Route(method: .post, uri: "/addNewAuthCodes") { (request, response) in
                
                defer{
                    response.completed()
                }
                let json = try! request.postParams.first!.0.jsonDecode() as! [String:Any]
                let data = json["data"] as! [String:Any]
                
                do{
                    guard let authCodes = data["authCodes"] as? [String] else {
                        let body = Tools.responseJson(data: [:], txt: "邀请码不能为空", status:.defaulErrortStatus)
                        try response.setBody(json:body)
                        return;
                    }
                    for code in authCodes {
                        let authCode = AuthCode()
                        authCode.authCode = code
                        try authCode.save(set: { (id) in
                            authCode.id = id as! Int
                        })
                    }
                    let body = Tools.responseJson(data: [:])
                    try response.setBody(json:body)
                }catch{
                    LogFile.error("\(error)")
                    let _ = try? response.setBody(json:Tools.responseJson(data: [:], txt: nil, status: nil, code: .defaultError, msg: "请求失败"))
                }
                
                
                
            }
            
            return route
        }
    }
}
