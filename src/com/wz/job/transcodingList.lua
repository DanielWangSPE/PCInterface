-- 24小时之内上传的音视频的转码状态列表
-- http://pcapi.qingk.cn/v1/transcodingList GET
-- 参数 userId&appId
-- 返回 
--[[
    {
        "code": 200,
        "msg": "成功",
        "results": {
            "totalCount": 1024,
            "list":[
                 {
                     "name":"快乐向前冲第2集.mp4",
                     "fileSize":100,
                     "time_long":"00:23:45",
                     "category":"电视点播",
                     "type":"视频",
                     "status":"成功",
                     "useTime":"00:23:45",
                     "createTime":"2017.2.22 15:37:15"
                 },
                 {
                    "name":"快乐向前冲第2集.mp4",
                     "fileSize":100,
                     "time_long":"00:23:45",
                     "category":"电视点播",
                     "type":"视频",
                     "status":"成功",
                     "useTime":"00:23:45",
                     "createTime":"2017.2.22 15:37:15"
                 }
            ]
        }
    }
]]

-- 引入依赖库
local cjson = require "cjson"
local mysql = require "mysqlInit"

cjson.encode_empty_table_as_object(false)

-- 获取get参数列表
local args = ngx.req.get_uri_args()
local appId = args.appId

-- 文件列表表
local list = {}

-- 创建mysql实例
local db = mysql:new()

--查询sql
local transcoding_sql = "SELECT file_original_name AS name, SEC_TO_TIME(file_long) AS time_long, IFNULL(file_size, 0) AS fileSize, CASE media_type WHEN 'video' THEN '电视点播' WHEN 'audio' THEN '广播点播' WHEN 'categoryVideo' THEN '分类视频' WHEN 'other' THEN '其它影音' END AS category, CASE LOWER(file_type) WHEN 'mp4' THEN '视频' ELSE '音频' END AS type, CASE status WHEN 'sucess' THEN '成功' WHEN 'needless' THEN '成功' WHEN 'fail' THEN '失败' END AS status, SEC_TO_TIME( DATEDIFF(end_time, begin_time)) AS useTime, create_time AS createTime FROM t_transcoding WHERE app_information_key = '"..appId.."' AND media_type IN ( 'video', 'audio', 'categoryVideo', 'other' ) AND DATEDIFF(CURTIME(), create_time) <= 1"

local res, err, errno, sqlstate = db:query(transcoding_sql)
if not res then
    ngx.say("select error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)
end
if res then
    for i, row in ipairs(res) do
        local record = {}
        record.name = row.name
        record.fileSize = row.fileSize
        record.time_long = row.time_long
        record.category = row.category
        record.type = row.type
        record.status = row.status
        record.useTime = row.useTime
        record.createTime = row.createTime
        list[i] = record
    end
end

db:close()


-- 定义响应体
local request_body = {
    code = 200;
    msg = "成功";
    results = {
        totalCount = #list;
        list = list;
    }
}
local data = cjson.encode(request_body)
ngx.say(data)

return data