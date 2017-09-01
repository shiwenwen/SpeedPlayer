//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import MySQLStORM
import PerfectRequestLogger
import PerfectLogger
import PerfectCrypto
// 初始化一个日志记录器
let myLogger = RequestLogger()
RequestLogFile.location = "./log.log"
MySQLConnector.host = Sql_Host
MySQLConnector.username = Sql_user
MySQLConnector.password = Sql_passwoed
MySQLConnector.port = Sql_port
MySQLConnector.database = Sql_db

// 初始化加密
PerfectCrypto.isInitialized = true

var server = HTTPServer()
server.serverName = "localhost"
server.serverPort = 8181

//--------------------------------资源根目录
let webroot = Dir("./webroot")
if !webroot.exists {
    do{
        try webroot.create()
    }catch{
        LogFile.error("创建./webroot失败:\(error)")
    }
    
}

server.documentRoot = "./webroot"

//-------------------------------路由
let baseUrl = "/wolfVideo"

var routes = Routes(baseUri: baseUrl)
//登录注册
routes.add(LoginRegister.start())
//文件上传
routes.add(UpLoad.start())
//邀请码管理
routes.add(AuthCodeManager.start())
//收藏
routes.add(VideoCollects.start())




routes.add(method: .get, uri: "/**", handler: {
    request, response in
    StaticFileHandler(documentRoot: request.documentRoot).handleRequest(request: request, response: response)
})
server.addRoutes(routes)
//----------------------------------- 增加过滤器
// 首先增加高优先级的过滤器
server.setRequestFilters([(myLogger, .high),(RequestCheckFilter(),.high)])
server.setResponseFilters([(ResponseCheckFilter(),.high)])



do{
    try server.start()
    LogFile.info("服务启动成功")
}catch{
    LogFile.error("\(error)")
}




