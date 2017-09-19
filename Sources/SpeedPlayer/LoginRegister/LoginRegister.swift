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
                    try user.find([("uuid",data["uuid"] ?? "")])
                    var isRegsitDevice = false
                    for us in user.rows() {
                        if us.uuid == data["uuid"] as! String {
                            isRegsitDevice = true
                        }
                    }
                    try user.find([("mobile",data["mobile"] ?? "")])
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
                
                do{
                    try user.find([("mobile",data["mobile"] ?? "")])
                    if user.results.foundSetCount > 0 {
                        let body = Tools.responseJson(data: [:], txt: "该手机号已经注册", status:.mobileHasRegister)
                        try response.setBody(json:body)
                        return;
                    }
                    try user.find([("authCode",data["authCode"] ?? "")])
                    if user.results.foundSetCount > 0 {
                        let body = Tools.responseJson(data: [:], txt: "该邀请码已经注册", status:.authCodeUsed)
                        try response.setBody(json:body)
                        return;
                    }
                    let authCodeManager = AuthCode()
                    
                    try authCodeManager.find([("authCode",data["authCode"] ?? "")])
                    guard authCodeManager.results.foundSetCount > 0 else {
                        let body = Tools.responseJson(data: [:], txt: "该邀请码无效", status:.authCodeNotFound)
                        try response.setBody(json:body)
                        return;
                    }
                    for row in authCodeManager.rows() {
                        row.status = 1
                        try row.save()
                    }
                    user.name = data["name"] as? String ?? ""
                    user.mobile = data["mobile"] as? String ?? ""
                    user.authCode = data["authCode"] as? String ?? ""
                    user.uuid = data["uuid"] as? String ?? ""
                    let password = data["password"] as? String ?? ""
                    user.email = data["email"] as? String ?? ""
                    user.password = password
                    try user.save(set: { (id) in
                        user.id = id as! Int
                    })
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
                        info.name = mobile
                    }
                    if let email = data["email"] as? String {
                        info.email = email
                    }
                    try info.save()
                    let responseData:[String : Any] = ["mobile":info.mobile,"name":info.name,"userId":info.id,"avatar":info.avatar]
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
}
