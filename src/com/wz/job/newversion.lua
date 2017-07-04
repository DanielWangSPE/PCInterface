-- 当前系统最新版本
-- http://pcapi.qingk.cn/v1/newversion GET
-- 参数 userId
-- 返回 
--[[
    {
        "code": 200,
        "msg": "成功",
        "results": {
            "version":2.0,
            "url":"http://dl.qingk.cn/lvsdsa"
        }
    }
]]

-- 引入依赖库
local cjson = require "cjson"
local mysql = require "mysqlInit"

cjson.encode_empty_table_as_object(false)

local newversion = {}

-- 创建mysql实例
local db = mysql:new()

--查询sql
local version_sql = "SELECT client_version AS version, package_url AS url FROM t_upload_client WHERE status = 'publish' ORDER BY create_time DESC limit 1"
local res, err, errno, sqlstate = db:query(version_sql)
if not res then
ngx.say("select error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)
end

if res then
    for i, row in ipairs(res) do
        newversion.version = row.version
        newversion.url = row.url
    end
end
db:close()

-- 定义响应体
local request_body = {
    code = 200;
    msg = "成功";
    results = {   
        version = newversion.version;
        url = newversion.url;
    }
}
local data = cjson.encode(request_body)
ngx.say(data)

return data