-- 云存储PC端用户登录接口
-- http://pcapi.qingk.cn/v1/pclogin POST
-- 参数 username&pwd
-- 返回 
--[[
    {
        "code": 200,
        "msg": "成功",
        "results": {
            "appId": "bxssuxfouctossdawcedcsaspqqeeeot",
            "daomain": "dzsjt" ,
            "logo": "http://pic.qingk.cc/image/127/cac7a0141a25498096d254916e0713ae.jpg",
            "userName": "张三",
            "userId": "bxssuxfouctossdawcedcsaspqqeeeot",
            "role_key":"29372d1a35ca4a8383992046e30afdf3"
        }
    }
]]

-- 引入依赖库
local cjson = require "cjson"
local mysql = require "mysqlInit"

-- table为空，则返回数组
cjson.encode_empty_table_as_object(false)

-- pc端登录用户的共享内存
local pclogin_store = ngx.shared.pclogin_store

-- 获取请求体中的参数
local args = ngx.req.get_uri_args()
local username = args.username
local pwd = args.pwd
ngx.log(ngx.CRIT, username..pwd)

-- 创建mysql实例
local db = mysql:new()

-- 用户信息查询sql
local select_user_sql = "SELECT t.platform_user_key AS userId, t.app_information_key AS appId, t.role_key AS role_key, t.password, a.url AS domain, ifnull(a.logo, '') as logo FROM t_platform_user t INNER JOIN t_app_information a ON t.app_information_key = a.app_information_key WHERE login_name = '"..username.."'"
local res, err, errno, sqlstate = db:query(select_user_sql)
if not res then
   ngx.say("select error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)
end
local userId = ""
local appId = ""
local role_key = ""
local password = ""
local domain = ""
local logo = ""
if res then
    for i, row in ipairs(res) do
        userId = row.userId
        appId = row.appId
        role_key = row.role_key
        password = row.password
        domain = row.domain
        logo = row.logo
    end
end
-- 关闭数据库连接
db:close()

-- 定义响应体
local request_body = {}
if password ~= pwd then
    request_body = {
        code = 403;
        msg = "用户名或密码错误";
    }
else
    request_body = {
        code = 200;
        msg = "成功";
        results = { 
            appId = appId;
            daomain = domain;
            logo = logo;
            username = username;
            userId = userId;
            role_key = role_key;
        }
    }

    -- 登录成功后，登录信息写入共享内存
    local user_info_arr = {userId, appId, domain, role_key, logo}
    local user_info_data = cjson.encode(user_info_arr)
    pclogin_store:set(userId, user_info_data)
end

local data = cjson.encode(request_body)
ngx.say(data)
return data
