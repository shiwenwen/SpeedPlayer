//
//  Params.swift
//  WolfVideo
//
//  Created by 石文文 on 2017/4/25.
//
//




//MARK: localMySql 开发
//let Local_Host = "http://192.168.31.208:8181"
// let Sql_Host = "127.0.0.1"
// let Sql_user = "root"
// let Sql_passwoed = "sww"
// let Sql_db = "MyAppDB"
//
//MARK: 生产
let Local_Host = "http://47.94.175.119:8181"
let Sql_Host = "127.0.0.1"
let Sql_user = "root"
let Sql_passwoed = "sww"
let Sql_db = "SpeedPlayer"
//
//
let Sql_port = 3306
let Sql_Users_table = "users_tbl"
let Sql_AuthCodes_table = "authCodes_tbl"
let Sql_Collects_table = "collects_tbl"
let MD5_KEY = "2edJwjL9Rwcb5dtUH32NdbINSP0kOqoIcIy6yWDT99hgmBeoCUtPtJo4YidbISC6"


//MARK: Response Code

enum ResponseCode : String{
    case requestParamsError = "4000" //请求参数错误
    case signError = "4001" //签名错误
    case abnormal = "4002" //异常
    case success = "0000" //成功
    case defaultError = "9999"
}
//MARK: Response Status
enum ResponseStatus : String{
    case success = "B0000" //处理成功
    case mobileHasRegister = "B0010" //手机号已注册
    case mobileHasNoRegister = "B0011" //手机号未注册
    case authCodeNotFound = "B0012" //注册码未找到
    
    case authCodeUsed = "B0013" //该注册码已使用
    case diviceNotReg = "B0014" //该设备未注册
    case passwordError = "B0015" //注册码未找到
    
    case defaulErrortStatus = "B9999"
}
