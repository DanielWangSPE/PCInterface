-- 用户退出接口
-- http://pcapi.qingk.cn/v1/pcquit POST
-- 参数 userId
-- 返回 
--[[
    {
        "code": 200,
        "msg": "true"
    }
]]

-- 引入依赖库
local cjson = require "cjson"
local mysql = require "mysqlInit"
cjson.encode_empty_table_as_object(false)

-- pc端登录用户的共享内存
local pclogin_store = ngx.shared.pclogin_store

-- 获取请求体中的参数
local args = ngx.req.get_uri_args()
local userId = args.userId

-- 从共享内存删除登录信息
pclogin_store:delete(userId)

-- 定义响应体
local request_body = {
    code = 200;
    msg = "成功";
}
local data = cjson.encode(request_body)
ngx.say(data)
return data
