//
//  UpLoad.swift
//  WolfVideo
//
//  Created by 石文文 on 2017/4/28.
//
//
import PerfectLib
import PerfectHTTPServer
import PerfectHTTP
import PerfectLogger
import CSV
import Foundation
struct UpLoad {
    
    static func start() -> Routes {
        var baseRoutes = Routes(baseUri: "/upload")
        let tradeNo = TradeNo()
        let avatar = Avatar()
        
        baseRoutes.add(tradeNo.start())
        baseRoutes.add(avatar.start())
        return baseRoutes
    }
    
    struct TradeNo {
        func start() -> Route {
            let route = Route(method: .post, uri: "/tradeNo") { (request, response) in
                defer{
                    response.completed()
                }
                // 通过操作fileUploads数组来掌握文件上传的情况
                // 如果这个POST请求不是分段multi-part类型，则该数组内容为空
                // 创建路径用于存储已上传文件
                let fileDir = Dir(Dir.workingDir.path + "data/tradeNo/")
                LogFile.info("path:\(fileDir.path)")
                if !fileDir.exists {
                    do {
                        try fileDir.create()
                    } catch {
                        LogFile.error("\(error)")
                    }
                }
                if let uploads = request.postFileUploads, uploads.count > 0 {
                    // 创建一个字典数组用于检查已经上载的内容
                    var ary = [[String:Any]]()
                    
                    for upload in uploads {
                        ary.append([
                            "fieldName": upload.fieldName,  //字段名
                            "contentType": upload.contentType, //文件内容类型
                            "fileName": upload.fileName,    //文件名
                            "fileSize": upload.fileSize,    //文件尺寸
                            "tmpFileName": upload.tmpFileName   //上载后的临时文件名
                            ])
                        let thisFile = File(upload.tmpFileName)
                        do {
                            guard upload.fileName.contains(string: ".csv") && upload.contentType == "text/csv" else {
                                let html = """
                                <!DOCTYPE html>
                                <html>
                                <head>
                                <meta charset="UTF-8">
                                <title>上传失败</title>
                                </head>
                                <body>
                                <h1>文件类型不符合，请上传csv账单文件</h1>
                                </body>
                                </html>
                                """
                                response.setBody(string: html)
                                return
                            }
                            let _ = try thisFile.moveTo(path: fileDir.path + "tradeNo.csv", overWrite: true)
                            let html = """
                                <!DOCTYPE html>
                                <html>
                                <head>
                                <meta charset="UTF-8">
                                <title>上传成功</title>
                                </head>
                                <body>
                                <h1>账单上传成功</h1>
                                </body>
                                </html>
                                """
                            response.setBody(string: html)
                            LogFile.info("文件上传成功:\(fileDir.path + "tradeNo.csv")")
                            self.checkTrade(tradePath: fileDir.path + "tradeNo.csv")
                        } catch {
                            LogFile.error("\(error)")
                            let html = """
                                <!DOCTYPE html>
                                <html>
                                <head>
                                <meta charset="UTF-8">
                                <title>上传失败</title>
                                </head>
                                <body>
                                <h1>文件类型不符合，请上传csv账单文件</h1>
                                </body>
                                </html>
                                """
                            response.setBody(string: html)
                        }
                    }
                    
                }else{
                    let html = """
                                <!DOCTYPE html>
                                <html>
                                <head>
                                <meta charset="UTF-8">
                                <title>上传失败</title>
                                </head>
                                <body>
                                <h1>文件类型不符合，请上传csv账单文件</h1>
                                </body>
                                </html>
                                """
                    response.setBody(string: html)
                    
                }
                
                
                
            }
            
            return route
        }
        
        /// 检查订单
        func checkTrade(tradePath: String) {
            let stream = InputStream(fileAtPath: tradePath)!
            let csv = try! CSVReader(stream: stream)
            var tradsNoArr = [[String]]()
            
            while let row = csv.next() {
                if row.count > 1 {
                    tradsNoArr.append([row.first!,row[1]])
                }
            }
            let user = User()
            do {
                try user.find([("status","0")])
                for us in user.rows() {
                    for trade in tradsNoArr {
                        if us.tradeNo == trade.first {
                                //已审核
                            us.status = 1
                            if Double(trade[1]) ?? 0 == 50 {
                                //永久
                                us.isPermanent = 1
                            }
                            try us.save()
                        }
                    }
                    if us.status == 0 {
                        us.status = -1
                        try us.save()
                    }
                    let blackList = BlackList()
                    try blackList.find([("uuid",us.uuid)])
                    if blackList.rows().count > 0 {
                        
                        for black in blackList.rows() {
                            black.errorCount += 1
                            try black.save()
                        }
                    } else {
                        LogFile.info("新黑名单")
                        
                        blackList.uuid = us.uuid
                        blackList.errorCount = 1
                        try! blackList.save(set: { id in
                            blackList.id = id as! Int
                        })
                        
                    }
                    
                    
                }
            } catch  {
                LogFile.error("\(error)")
            }
            //查出未审核的
            
            
            
        }
        
    }
    struct Avatar {
        func start() -> Route {
            let route = Route(method: .post, uri: "/avatar") { (request, response) in
                defer{
                    response.completed()
                }
                
                // 通过操作fileUploads数组来掌握文件上传的情况
                // 如果这个POST请求不是分段multi-part类型，则该数组内容为空
                // 创建路径用于存储已上传文件
                let fileDir = Dir(webroot.path + "files/userData/info/avatars")
                LogFile.info("path:\(fileDir.path)")
                if !fileDir.exists {
                    do {
                        try fileDir.create()
                        
                    } catch {
                        LogFile.error("\(error)")
                    }
                }
                if let uploads = request.postFileUploads, uploads.count > 0 {
                    // 创建一个字典数组用于检查已经上载的内容
                    var ary = [[String:Any]]()
//                    var ary = [MimeReader.BodySpec]()
                    
                    var userId:String = ""
                    for upload in uploads {
                        
                        // 是文件
                        if upload.fileSize > 0 {
                            
                            ary.append([
                                "fieldName": upload.fieldName,  //字段名
                                "contentType": upload.contentType, //文件内容类型
                                "fileName": upload.fileName,    //文件名
                                "fileSize": upload.fileSize,    //文件尺寸
                                "tmpFileName": upload.tmpFileName   //上载后的临时文件名
                                ])
//                            ary.append(upload)
                        } else {
                            if upload.fieldName == "data[userId]" || upload.fieldName == "userId" {
                                userId = upload.fieldValue
                            }
                            
                        }
                        
                    }
                    LogFile.debug("\(ary)")
                    
                    do {
                        guard ary.count > 0 else {
                            let body = Tools.responseJson(data: [:], txt: "文件无效", status:.defaulErrortStatus)
                            try response.setBody(json:body)
                            return;
                        }
                        let upload = ary.first!
                        let thisFile = File(upload["tmpFileName"] as! String)
                        let _ = try thisFile.moveTo(path: fileDir.path + ( upload["fileName"] as! String ), overWrite: true)
                        
                        let user = User()
                        try user.find([("id",userId)])
                        guard user.rows().count > 0 else {
                            let body = Tools.responseJson(data: [:], txt: "该用户不存在或者已禁用", status:.defaulErrortStatus)
                            try response.setBody(json:body)
                            return;
                        }
                        let info =  user.rows().first!
                        let url = Local_Host+"/files/userData/info/avatars/" + ( upload["fileName"] as! String )
                        info.avatar = url
                        try info.save()
                        try response.setBody(json: Tools.responseJson(data:["avatar":url]))
                        LogFile.info("文件上传成功:\(fileDir.path + ( upload["fileName"] as! String ))")
                    } catch {
                        LogFile.error("\(error)")
                        let _ = try? response.setBody(json:Tools.responseJson(data: [:], txt: nil, status: nil, code: .defaultError, msg: "处理失败\(error)"))
                    }
                    
                    
                }else{
                    let _ = try? response.setBody(json:Tools.responseJson(data: [:], txt: nil, status: nil, code: .defaultError, msg: "上传失败"))
                    
                }
                
                
                
            }
            
            return route
        }
        
    }
    
}
