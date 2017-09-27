//
//  LoginRegister.swift
//  WolfVideo
//
//  Created by 石文文 on 2017/4/25.
//
//
import PerfectLib
import PerfectHTTPServer
import PerfectHTTP
import MySQLStORM
import PerfectLogger
import Foundation
import PerfectSMTP

struct LoginRegister {
    
    /// 启动
    ///
    /// - Returns: 加载的路由
    static func start() -> Routes {
        var baseRoutes = Routes(baseUri: "/account")
        let login = Login()
        let register = Register()
        let info = Info()
        let updateInfo = UpdateInfo()
        
        baseRoutes.add(login.start())
        baseRoutes.add(register.start())
        baseRoutes.add(info.start())
        baseRoutes.add(updateInfo.start())
        return baseRoutes
    }
    
    /// 登录
    struct Login {
        func start() -> Route {
            let route = Route(method: .post, uri: "/login") { (request, response) in
                defer{
                    response.completed()
                }
                let json = try! request.postParams.first!.0.jsonDecode() as! [String:Any]
                let data = json["data"] as! [String:Any]
                let user = User()
                
                do{
                    try user.find([("mobile",data["mobile"] ?? "")])
                    guard user.rows().count > 0 else{
                        let body = Tools.responseJson(data: [:], txt: "该手机号未注册", status:.mobileHasNoRegister)
                        try response.setBody(json:body)
                        return;
                    }
                    if user.rows().first!.status < 1 {
                        let body = Tools.responseJson(data: [:], txt: "该账号使用了错误的订单号,已经被禁用!", status:.forbidden)
                        try response.setBody(json:body)
                        return;
                    }
                    var isRegsitDevice = false
                    for us in user.rows() {
                        if us.uuid == data["uuid"] as? String {
                            isRegsitDevice = true
                        }
                    }
                    
                    if isRegsitDevice || (data["reset"] as? Int ?? 1) == 1{
                        let account =  user.rows().first!
                        if account.password == data["password"] as! String {
                            let body = Tools.responseJson(data: ["mobile":account.mobile,"name":account.name,"userId":account.id], txt: "登录成功", status:.success)
                            try response.setBody(json:body)
                            account.uuid = data["uuid"] as! String
                            try account.save()
                        }else{
                            let body = Tools.responseJson(data: [:], txt: "密码错误", status:.passwordError)
                            try response.setBody(json:body)
                        }
                    }else{
                        let body = Tools.responseJson(data: [:], txt: "该设备非注册设备", status:.diviceNotReg)
                        try response.setBody(json:body)
                    }
                    
                    
                    
                    
                }catch{
                    LogFile.error("\(error)")
                    let _ = try? response.setBody(json:Tools.responseJson(data: [:], txt: nil, status: nil, code: .defaultError, msg: "请求失败"))
                }
            }
            
            return route
        }
        
    }
    
    /// 注册
    struct Register {
        func start() -> Route {
            
            let route = Route(method: .post, uri: "/register") { (request, response) in
                
                defer{
                    response.completed()
                }
                let json = try! request.postParams.first!.0.jsonDecode() as! [String:Any]
                let data = json["data"] as! [String:Any]
                let user = User()
                let blackList = BlackList()
                do{
                    try blackList.find([("uuid",data["uuid"] as? String ?? "")])
                    if blackList.results.foundSetCount > 0 && blackList.rows().first!.errorCount > 2 {
                        let body = Tools.responseJson(data: [:], txt: "该手机由于恶意注册已被封，不得再注册", status:.inBlackList)
                        try response.setBody(json:body)
                        return;
                        
                    }
                    try user.find([("mobile",data["mobile"] ?? "")])
                    if user.results.foundSetCount > 0 {
                        let body = Tools.responseJson(data: [:], txt: "该手机号已经注册", status:.mobileHasRegister)
                        try response.setBody(json:body)
                        return;
                    }
                    let tradeNo = TradeNo()
                    try tradeNo.find([("trade_no",data["tradeNo"] ?? "")])
                    if tradeNo.results.foundSetCount > 0 {
                        let body = Tools.responseJson(data: [:], txt: "该订单号已经使用", status:.tradeNoUsed)
                        try response.setBody(json:body)
                        return;
                    }
                    
                    
                    user.name = data["name"] as? String ?? ""
                    user.mobile = data["mobile"] as? String ?? ""
                    user.tradeNo = data["tradeNo"] as? String ?? ""
                    user.uuid = data["uuid"] as? String ?? ""
                    let password = data["password"] as? String ?? ""
                    user.email = data["email"] as? String ?? ""
                    user.password = password
                    user.isPermanent = 0
                    user.status = 0
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let dataStr = formatter.string(from: Date())
                    user.create_time = dataStr
                    user.recharge_time = dataStr
                    
                    tradeNo.trade_no = data["tradeNo"] as? String ?? ""
                    tradeNo.create_time = dataStr
                    try tradeNo.save()
                    
                    try user.save(set: { (id) in
                        user.id = id as! Int
                    })
                    self.sendEmail(content: data ,time: dataStr)
                    let body = Tools.responseJson(data: [
                        "name":user.name,
                        "mobile":user.mobile,
                        "userId":user.id
                        ], txt: "注册成功", status:.success)
                    try response.setBody(json:body)
                }catch{
                    LogFile.error("\(error)")
                    let _ = try? response.setBody(json:Tools.responseJson(data: [:], txt: nil, status: nil, code: .defaultError, msg: "请求失败"))
                }
                
                
                
            }
            
            return route
        }
        //MARK:  发送邮件
         func sendEmail(content: [String : Any],time: String) {
            let client = SMTPClient(url: emailServer, username: emailAddress, password: emailPsd)
            let email = EMail(client: client)
            email.subject = "新用户注册\(content["mobile"] as? String ?? "")"
            let recipient = Recipient(name: "shiwenwen", address: "s13731984233@163.com")
            email.from = recipient
            email.content = """
                昵称:\(content["name"] as? String ?? "")\n
                手机号:\(content["mobile"] as? String ?? "")\n
                订单号:\(content["tradeNo"] as? String ?? "")\n
                时间:\(time)\n
                邮箱:\(content["email"] as? String ?? "")\n
                UUID:\(content["uuid"] as? String ?? "")\n
            """
            email.to.append(Recipient(name: "shiwenwenDev", address: "shiwenwendevelop@163.com"))
            //email.cc.append(Recipient(name: "shiwenwenQQ", address: "1152164614@qq.com"))
            //email.attachments.append("./webroot/01.png")
            do{
                try email.send(completion: { (code, header, body) in
                    print(code)
                    print(header)
                    print(body)
                })
            }catch let error {
                print(error)
            }
        }
    }
    
    /// 个人信息
    struct Info {
        func start() -> Route {
            let route = Route(method: .get, uri: "/info") { (request, response) in
                defer{
                    response.completed()
                }
                
                let user = User()
                
                do{
                    try user.find([("id",request.param(name: "userId",defaultValue: "0")!)])
                    guard user.rows().count > 0 else {
                        let body = Tools.responseJson(data: [:], txt: "该用户不存在或者已禁用", status:.defaulErrortStatus)
                        try response.setBody(json:body)
                        return;
                    }
                    let info =  user.rows().first!
                    let data:[String : Any] = ["mobile":info.mobile,"name":info.name,"userId":info.id,"avatar":info.avatar,"email":info.email]
                    let body = Tools.responseJson(data:data)
                    try response.setBody(json:body)
                    
                    
                }catch{
                    LogFile.error("\(error)")
                    let _ = try? response.setBody(json:Tools.responseJson(data: [:], txt: nil, status: nil, code: .defaultError, msg: "请求失败"))
                }
            }
            
            return route
        }
        
    }
    /// 更新个人信息
    struct UpdateInfo {
        func start() -> Route {
            let route = Route(method: .post, uri: "/updateInfo") { (request, response) in
                defer{
                    response.completed()
                }
                
                let user = User()
                
                do{
                    let json = try request.postParams.first!.0.jsonDecode() as! [String:Any]
                    let data = json["data"] as! [String:Any]
                    guard let userId = data["userId"] else {
                        let body = Tools.responseJson(data: [:], txt: "该用户不存在或者已禁用", status:.defaulErrortStatus)
                        try response.setBody(json:body)
                        return
                    }
                    try user.find([("id","\(userId)")])
                    guard user.rows().count > 0 else {
                        let body = Tools.responseJson(data: [:], txt: "该用户不存在或者已禁用", status:.defaulErrortStatus)
                        try response.setBody(json:body)
                        return;
                    }
                    let info =  user.rows().first!
                    if let name = data["name"] as? String{
                        info.name = name
                    }
                    if let mobile = data["mobile"] as? String {
                        info.mobile = mobile
                    }
                    if let email = data["email"] as? String {
                        info.email = email
                    }
                    try info.save()
                    let responseData:[String : Any] = ["mobile":info.mobile,"name":info.name,"userId":info.id,"avatar":info.avatar,"email":info.email]
                    let body = Tools.responseJson(data:responseData)
                    try response.setBody(json:body)
                    
                    
                }catch{
                    LogFile.error("\(error)")
                    let _ = try? response.setBody(json:Tools.responseJson(data: [:], txt: nil, status: nil, code: .defaultError, msg: "请求失败"))
                }
            }
            
            return route
        }
        
    }
 
    /// 确认注册信息
    struct ConfirmationOfRegistrationInformation {
    
    
    }
}
