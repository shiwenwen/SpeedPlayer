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
struct UpLoad {
    
    static func start() -> Routes {
        var baseRoutes = Routes(baseUri: "/upload")
        let authCode = AuthCode()
        let avatar = Avatar()
        
        baseRoutes.add(authCode.start())
        baseRoutes.add(avatar.start())
        return baseRoutes
    }
    
    struct AuthCode {
        func start() -> Route {
            let route = Route(method: .post, uri: "/authcode") { (request, response) in
                defer{
                    response.completed()
                }
                
                // 通过操作fileUploads数组来掌握文件上传的情况
                // 如果这个POST请求不是分段multi-part类型，则该数组内容为空
                // 创建路径用于存储已上传文件
                let fileDir = Dir(Dir.workingDir.path + "files/config/")
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
                            let _ = try thisFile.moveTo(path: fileDir.path + upload.fileName, overWrite: true)
                            try response.setBody(json: Tools.responseJson(data:["url":Local_Host+"files/config/"+upload.fileName]))
                            LogFile.info("文件上传成功:\(fileDir.path + upload.fileName)")
                        } catch {
                            LogFile.error("\(error)")
                            let _ = try? response.setBody(json:Tools.responseJson(data: [:], txt: nil, status: nil, code: .defaultError, msg: "上传失败"))
                        }
                    }
                    
                }else{
                    let _ = try? response.setBody(json:Tools.responseJson(data: [:], txt: nil, status: nil, code: .defaultError, msg: "上传失败"))
                    
                }
                
                
                
            }
            
            return route
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
                        let thisFile = File(upload["tmpFileName"] as! String )
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
