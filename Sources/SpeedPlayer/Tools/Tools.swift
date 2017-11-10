//
//  Tools.swift
//  MyAPPServer
//
//  Created by 石文文 on 2016/11/9.
//
//
import PerfectLib
import PerfectCrypto
import PerfectLogger
import PerfectHTTP
let HandleSuccessTxt = "处理成功"
let HandleFailedTxt = "处理失败"
let ResponseSuccessMsg = "请求成功"


class Tools {
    
    
    /// response json
    ///
    /// - Parameters:
    ///   - data: data
    ///   - status: status
    ///   - code: code
    ///   - msg: msg
    /// - Returns: json
    class func responseJson(data:[String:Any],txt:String? = HandleSuccessTxt,status:ResponseStatus? = .success, code:ResponseCode = .success,msg:String = ResponseSuccessMsg) -> [String:Any] {
        
        var json:[String:Any] = [
            "code":code.rawValue,
            "msg":msg,
            ]
        
        if code == .success {
            var tempData = data
//            for item in tempData {
//                if let value = item.value as? String,value == "nil"{
//                    tempData[item.key] = "<null>"
//                }
//                
//            }

//            过滤nil
            var keys = [String]()
            for item in tempData {
                if let value = item.value as? String,value == "nil"{
                    keys.append(item.key)
                }
                
            }
            for key in keys {
                tempData.removeValue(forKey: key)
            }
            
            tempData["txt"] = txt
            tempData["status"] = status?.rawValue
            json["data"] = tempData
        }
        
        return json
    }
    
    /// signatureVerification
    ///
    /// - Parameters:
    ///   - params: params
    ///   - sign: sign
    /// - Returns: signature verification result
    class func signatureVerification(paramsString:String, sign:String?) -> Bool{
        var paramsString = paramsString
        guard sign != nil else {
            
            return false
            
        }
        if paramsString.count < 2 {
            return false
        }
        paramsString.remove(at: paramsString.startIndex)
        paramsString.remove(at: paramsString.index(before: paramsString.endIndex))
        
        guard let range1 = paramsString.range(of: "{") else {
            return false
        }
        paramsString.removeSubrange(paramsString.startIndex ..< range1.lowerBound)
        guard let range2 = paramsString.range(of: "}", options: String.CompareOptions.backwards, range: nil, locale: nil) else {
            return false
        }
        paramsString.removeSubrange(range2.upperBound ..< paramsString.endIndex)
        guard let md5Byte = (paramsString + MD5_KEY).digest(.md5), let hexBytes = md5Byte.encode(.hex), let md5 = String(validatingUTF8:hexBytes) else {
            return false
        }
        LogFile.info("originString = \(paramsString)---sign = \(md5)")
        if md5 != sign{
            
            return false
        }
        
        return true
    }
    
}
enum SqlError : Error {
    case connect(Int32,String)
    /// A insert error code and message.
    case insert(Int32, String)
    
}
/*
extension MySQL {
    
    /// insert data to MySQL
    ///
    /// - Parameters:
    ///   - table: table
    ///   - columns: columns
    ///   - values: values
    /// - Returns: result
    /// - Throws: error
    func insert(table:String,columns:[String]?,values:[Any]) throws -> Bool{
        var sql = "insert into \(table)"
        if let columns = columns {
            guard columns.count == values.count else{
                throw SqlError.insert(1, "colmumns count is not equal values count")
            }
            var keys = ""
            var vals = ""
            for i in 0 ..< columns.count {
                let key = columns[i]
                let val = values[i]
                if i < columns.count - 1 {
                    keys += "\(key),"
                    vals += val is String ? "'\(val)'," : "\(val),"
                }else{
                    keys += columns[i]
                    vals += val is String ? "'\(val)'" : "\(val)"
                }
                
            }
            sql += " (" + keys + ")" + " values (" + vals + ");"
        }else{
            var vals = ""
            for i in 0 ..< values.count {
                let val = values[i]
                if i < values.count - 1 {
                    vals += val is String ? "'\(val)'," : "\(val),"
                }else{
                    vals += val is String ? "'\(val)'" : "\(val)"
                }
            }
            sql += " values (" + vals + ");"
        }
        LogFile.info(sql)
        let result = self.query(statement: sql)
        return result
    }
    
    /// insert data to MySQL
    ///
    /// - Parameters:
    ///   - table: table
    ///   - collumnsAndValues: collumnsAndValues
    /// - Returns: result
    func insert(table:String,collumnsAndValues data:[String:Any]) -> Bool{
        var sql = "insert into \(table)"
        var keys = ""
        var vals = ""
        for (key,value) in data {
            keys += "\(key),"
            vals += value is String ? "'\(value)'," : "\(value),"
        }
        keys.remove(at: keys.index(before: keys.endIndex))
        vals.remove(at: vals.index(before: vals.endIndex))
        sql += " (" + keys + ")" + " values (" + vals + ");"
        LogFile.info(sql)
        return self.query(statement: sql)
    }
    
    
}
 */
extension HTTPResponse {
    @discardableResult
    func setBodyNullable(json: JSONConvertible, skipContentType: Bool = false) throws -> Self {
        let string = try json.jsonEncodedString()
        if !skipContentType {
            setHeader(.contentType, value: "application/json")
        }
        let replacStr = string.replacingOccurrences(of: "\"nil\"", with: "null");
        return setBody(string: replacStr)
    }
}
