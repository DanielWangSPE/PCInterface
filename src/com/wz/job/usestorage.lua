-- 使用存储空间大小
-- http://pcapi.qingk.cn/v1/usestorage GET
-- 参数 userId&appId&type
-- 返回 
--[[
    {
        "code": 200,
        "msg": "成功",
        "results": {
            "count": 50,
            "usestorage":10000
        }
    }
]]

-- 引入依赖库
local cjson = require "cjson"
local mysql = require "mysqlInit"

cjson.encode_empty_table_as_object(false)

-- pc端登录用户的共享内存
local pclogin_store = ngx.shared.pclogin_store

-- 获取get参数列表
local args = ngx.req.get_uri_args()
local appId = args.appId
local type = args.type

-- 统计信息表
local statistics = {
    count = 0;
    usestorage = 0;
}

-- 查询sql表
local table_sql = {}

-- 创建mysql实例
local db = mysql:new()

--查询sql
local video_sql = "SELECT count(*) AS count, IFNULL(sum(file_size), 0) AS usestorage FROM t_video WHERE app_information_key = '"..appId.."' AND content_type = 'video'"
local audio_sql = "SELECT count(*) AS count, IFNULL(sum(file_size), 0) AS usestorage FROM t_audio WHERE app_information_key = '"..appId.."'"
local category_video_sql = "SELECT count(*) AS count, IFNULL(sum(file_size), 0) AS usestorage FROM t_video WHERE app_information_key = '"..appId.."' AND content_type = 'categoryVideo'"
local video_other_sql = "SELECT count(*) AS count, IFNULL(sum(file_size), 0) AS usestorage FROM t_video_others WHERE app_information_key = '"..appId.."'"
if type == "1" then
    table.insert(table_sql, video_sql)
elseif type == "2" then
    table.insert(table_sql, audio_sql)
elseif type == "3" then
    table.insert(table_sql, category_video_sql)
elseif type == "4" then
    table.insert(table_sql, video_other_sql)
elseif type == "0" then
    table.insert(table_sql, video_sql)
    table.insert(table_sql, audio_sql)
    table.insert(table_sql, category_video_sql)
    table.insert(table_sql, video_other_sql)
end

for i=1, #table_sql do
    local res, err, errno, sqlstate = db:query(table_sql[i])
    if not res then
        ngx.say("select error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)
    end
    if res then
        for i, row in ipairs(res) do
            statistics.count = statistics.count + row.count
            statistics.usestorage = statistics.usestorage + row.usestorage
        end
    end
end

db:close()


-- 定义响应体
local request_body = {
    code = 200;
    msg = "成功";
    results = {
        count = statistics.count;
        usestorage = statistics.usestorage;
    }
}
local data = cjson.encode(request_body)
ngx.say(data)

return data