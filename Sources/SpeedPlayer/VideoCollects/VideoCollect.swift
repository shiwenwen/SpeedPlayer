//
//  Collect.swift
//  WolfVideo
//
//  Created by 石文文 on 2017/4/30.
//
//


import MySQLStORM
import StORM
class VideoCollect: MySQLStORM {
    var id : Int = 0
    var userId : Int = 0// -- 用户id
    var videoId : String = "" //-- 视频id
    var barcode : String = "" //-- 番号
    var title : String = "" //-- 标题
    var sys_ctime : String = "" //-- 系统时间
    var cover : String = "" //-- 封面
    var playcover : String = "" //-- 宽图
    var category : String = "" //-- 分类
    var startdate : String = "" //-- 开始时间
    var up_time : String = "" //-- 上传时间
    var player : String = "" //-- 标题
    var play_count : String = "" //-- 数量
    var cat : String = "" //-- 分类
    var cat_text : String = "" //-- 有码无码
    
    override func table() -> String {
        return Sql_Collects_table
    }
    override func to(_ this: StORMRow) {

        id = Int("\(this.data["id"]!)")!
        userId = Int("\(this.data["userId"]!)")!
        videoId = this.data["videoId"] as! String
        barcode = this.data["barcode"] as! String
        title = this.data["title"] as! String
        sys_ctime = this.data["sys_ctime"] as! String
        cover = this.data["cover"] as! String
        playcover = this.data["playcover"] as! String
        category = this.data["category"] as! String
        
        startdate = this.data["startdate"] as? String ?? ""
        up_time = this.data["up_time"] as? String ?? ""
        player = this.data["player"] as? String ?? ""
        play_count = this.data["play_count"] as? String ?? ""
        cat = this.data["cat"] as? String ?? ""
        cat_text = this.data["cat_text"] as? String ?? ""
    }
    
    func rows() -> [VideoCollect] {
        var rows = [VideoCollect]()
        for i in 0..<self.results.rows.count {
            let row = VideoCollect()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
}
