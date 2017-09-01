//
//  Collects.swift
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
import CryptoSwift
import StORM

struct VideoCollects {
    
    static func start() -> Routes {
        var baseRoutes = Routes(baseUri: "/collects")
        let ColList = getCollectsList()
        let addCol = addNewCollect()
        let cancelCol = cancelCollect()
        let ColCount = getCollectsCount()
        let check = CheckIsCollect()
        baseRoutes.add(ColList.start())
        baseRoutes.add(addCol.start())
        baseRoutes.add(cancelCol.start())
        baseRoutes.add(ColCount.start())
        baseRoutes.add(check.start())
        return baseRoutes
    }
    
    /// 获取收藏数量
    struct getCollectsCount {
        func start() -> Route {
            let route = Route(method: .get, uri: "/getCollectsCount") { (request, response) in
                defer{
                    response.completed()
                }
                
                let userId = request.param(name: "userId")!
                do{
                    let videoCollect = VideoCollect()
                    try videoCollect.find([("userId",userId)])
                    let body = Tools.responseJson(data: ["collectCount":videoCollect.results.foundSetCount])
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
    
    /// 检测是否收藏
    struct CheckIsCollect {
        func start() -> Route {
            let route = Route(method: .get, uri: "/checkIsCollect") { (request, response) in
                defer{
                    response.completed()
                }
                
                let userId = request.param(name: "userId")!
                let videoId = request.param(name: "videoId")!
                do{
                    let videoCollect = VideoCollect()
                    try videoCollect.find([("userId",userId),("videoId",videoId)])
                    //                    try videoCollect.select(whereclause: "userId = ? AND videoId = ?", params: [userId,videoId], orderby: [])
                    let body = Tools.responseJson(data: ["isCollect":videoCollect.results.foundSetCount > 0 ? 1 : 0])
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
    /// 获取收藏列表
    struct getCollectsList {
        func start() -> Route {
            let route = Route(method: .get, uri: "/getCollectList") { (request, response) in
                defer{
                    response.completed()
                }
                let userId = request.param(name: "userId")!
                let pageNum = request.param(name: "pageNum", defaultValue: "0")!
                let pageSize = request.param(name: "pageSize", defaultValue: "50")!
                do{
                    
                    let thisCursor = StORMCursor(
                        limit: Int(pageSize)!,
                        offset:Int(pageNum)! * Int(pageSize)!
                    )
                    
                    let videoCollect = VideoCollect()
                    //                    try videoCollect.find([("userId",userId)])
                    try videoCollect.select(whereclause: "userId = ?", params: [userId], orderby: ["create_time"],cursor:thisCursor)
                    var collectsArrary = [[String:String]]()
                    for col in videoCollect.rows() {
                        let colDic = [
                            "videoId":col.videoId,
                            "barcode":col.barcode,
                            "title":col.title,
                            "sys_ctime":col.sys_ctime,
                            "cover":col.cover,
                            "playcover":col.playcover,
                            "category":col.category,
                            "startdate":col.startdate,
                            "up_time":col.up_time,
                            "player":col.player,
                            "play_count":col.player,
                            "cat":col.cat,
                            "cat_text":col.cat_text
                        ]
                        collectsArrary.append(colDic)
                    }
                    let body = Tools.responseJson(data: ["collects":collectsArrary])
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
    //    /// 添加收藏
    struct addNewCollect {
        func start() -> Route {
            let route = Route(method: .post, uri: "/addNewCollect") { (request, response) in
                
                defer{
                    response.completed()
                }
                let json = try! request.postParams.first!.0.jsonDecode() as! [String:Any]
                let data = json["data"] as! [String:Any]
                
                
                do{
                    let collectsArray = data["collects"] as! [[String:Any]]
                    for col in collectsArray {
                        let userId = col["userId"] as! Int
                        let videoId = col["videoId"] as! String
                        let barcode = col["barcode"] as! String
                        let title = col["title"] as! String
                        let sys_ctime = col["sys_ctime"] as! String
                        let cover = col["cover"] as! String
                        let playcover = col["playcover"] as! String
                        let category = col["category"] as! String
                        let startdate = col["startdate"] as! String
                        let up_time = col["up_time"] as! String
                        let player = col["player"] as! String
                        let play_count = col["play_count"] as! String
                        let cat = col["cat"] as! String
                        let cat_text = col["cat_text"] as! String
                        let videoCollect = VideoCollect()
                        videoCollect.userId = userId
                        videoCollect.videoId = videoId
                        videoCollect.barcode = barcode
                        videoCollect.title = title
                        videoCollect.sys_ctime = sys_ctime
                        videoCollect.cover = cover
                        videoCollect.playcover = playcover
                        videoCollect.category = category
                        videoCollect.startdate = startdate
                        videoCollect.up_time = up_time
                        videoCollect.player = player
                        videoCollect.play_count = play_count
                        videoCollect.cat = cat
                        videoCollect.cat_text = cat_text
                        try videoCollect.save(set: { (id) in
                            videoCollect.id = id as! Int
                        })
                    }
                    let body = Tools.responseJson(data: [:], txt: collectsArray.count > 1 ? "收藏同步成功":"收藏成功", status: .success, code: .success, msg: ResponseSuccessMsg)
                    try response.setBody(json:body)
                }catch{
                    LogFile.error("\(error)")
                    let _ = try? response.setBody(json:Tools.responseJson(data: [:], txt: nil, status: nil, code: .defaultError, msg: "请求失败"))
                }
                
                
                
            }
            
            return route
        }
    }
    
    /// 取消收藏
    struct cancelCollect {
        func start() -> Route {
            let route = Route(method: .post, uri: "/cancelCollect") { (request, response) in
                
                defer{
                    response.completed()
                }
                let json = try! request.postParams.first!.0.jsonDecode() as! [String:Any]
                let data = json["data"] as! [String:Any]
                let userId = data["userId"] as! Int
                let videoId = data["videoId"] as! String
                do{
                    let videoCollect = VideoCollect()
                    try videoCollect.find([("userId","\(userId)"),("videoId",videoId)])
                    for col in videoCollect.rows() {
                        try col.delete()
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


