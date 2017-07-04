-- 已上传文件列表
-- http://pcapi.qingk.cn/v1/categoryUploadVideoList GET
-- 参数 userId&appId&type
-- 返回 
--[[
    {
        "code": 200,
        "msg": "成功",
        "results": {
        "totalCount": 1024,
        "list":[
                 {
                     "name":"快乐向前冲第1集.mp4",
                     "fileSize":100,
                     "resolution":"848x480",
                     "bitrate":"32Kbps",
                     "time_long":"00:23:45",
                     "creator":"张三",
                     "createTime":"2017.2.22 15:38:00"
                 },
                 {
                    "name":"快乐向前冲第2集.mp4",
                     "fileSize":100,
                     "resolution":"848x480",
                     "bitrate":"32Kbps",
                     "time_long":"00:23:45",
                     "creator":"张三",
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
local type = args.type

-- 文件列表表
local list = {}

-- 创建mysql实例
local db = mysql:new()

--查询sql
local common_sql = "SELECT t.file_original_name AS name, t.file_size AS fileSize, IFNULL(t.resolution, 0) AS resolution, IFNULL(t.bitrate, 0) AS bitrate, SEC_TO_TIME(t.file_long) AS time_long, p.user_name AS creator, t.create_time AS createTime FROM t_transcoding t LEFT JOIN t_platform_user p ON t.creator = p.platform_user_key WHERE t.app_information_key = '"..appId.."' AND t.media_type"
local type_content
local upload_file_sql

if type == "1" then
    type_content = " = 'video'"
    upload_file_sql = common_sql..type_content
elseif type == "2" then
    type_content = " = 'audio'"
    upload_file_sql = common_sql..type_content
elseif type == "3" then
    type_content = " = 'categoryVideo'"
    upload_file_sql = common_sql..type_content
elseif type == "4" then
    type_content = " = 'other'"
    upload_file_sql = common_sql..type_content
elseif type == "0" then
    type_content = " IN ('video', 'audio', 'categoryVideo', 'other')"
    upload_file_sql = common_sql..type_content
end

local res, err, errno, sqlstate = db:query(upload_file_sql)
if not res then
    ngx.say("select error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)
end
if res then
    for i, row in ipairs(res) do
        local record = {}
        record.name = row.name
        record.fileSize = row.fileSize
        record.resolution = row.resolution
        record.bitrate = row.bitrate
        record.time_long = row.time_long
        record.creator = row.creator
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