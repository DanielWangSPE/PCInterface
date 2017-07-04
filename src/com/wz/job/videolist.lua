-- 电视点播栏目列表接口
-- http://pcapi.qingk.cn/v1/videolist GET
-- 参数 userId&role_key&component_type
-- 返回 
--[[
    {
        "code": 200,
        "msg": "成功",
        "results": {
            "list":[
                {
                    "channelKey":"b54abb9d451a49489a9e8a8cb1be3de0",
                    "channelName":"点播",
                    "columnKey":"114abb9d451a49489a9e8a8cb1be3d11",
                    "columnName":"宿迁新闻",
                    "componentKey":"114abb9d451a49489a9e8a8cb1be3d11",
                    "componentName":"组件名称"
                },
                {
                    "channelKey":"b54abb9d451a49489a9e8a8cb1be3de0",
                    "channelName":"点播",
                    "columnKey":"224abb9d451a49489a9e8a8cb1be3d22",
                    "columnName":"楚风夜话",
                    "componentKey":"114abb9d451a49489a9e8a8cb1be3d11",
                    "componentName":"组件名称"
                },
                {
                    "channelKey":"b54abb9d451a49489a9e8a8cb1be3de0",
                    "channelName":"点播",
                    "columnKey":"334abb9d451a49489a9e8a8cb1be3d33",
                    "columnName":"楚风夜话",
                    "componentKey":"114abb9d451a49489a9e8a8cb1be3d11",
                    "componentName":"组件名称"
                }
            ]
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
local userId = args.userId
local role_key = args.role_key
local component_type = args.component_type
ngx.log(ngx.CRIT, userId..role_key..component_type)

-- 判断该userId的登录状态
local login = pclogin_store:get(userId)
--login数据格式：{userId, appId, domain, role_key, logo}
local list = {}

-- 创建mysql实例
local db = mysql:new()
local login_data = cjson.decode(login)
local appId = login_data[2]
--查询sql
local videolist_sql = "SELECT columnKey, columnName, channelKey, channelName, t.component_key AS componentKey, t.title AS componentName FROM ( SELECT t.classify_key AS columnKey, t.classify_name AS columnName, t.parent_key AS channelKey, c.classify_name AS channelName, t.app_component_key FROM ( SELECT c.classify_key, c.classify_name, c.parent_key, c.app_component_key FROM ( SELECT app_component_key FROM t_app_component WHERE app_information_key = '"..appId.."' AND component_type IN ( '"..component_type.."', '"..component_type.."tui' )) t INNER JOIN t_classify c ON t.app_component_key = c.app_component_key AND c.parent_key != '0' AND c. STATUS = 0 ) t INNER JOIN t_classify c ON t.parent_key = c.classify_key ) tmp LEFT JOIN t_app_component t ON tmp.app_component_key = t.app_component_key"
if role_key ~= "app_role" then
    videolist_sql = "SELECT tmp.channelKey, tmp.channelName, tmp.columnKey, tmp.columnName, t.component_key AS componentKey, t.title AS componentName FROM ( SELECT tmp.channel_key AS channelKey, c.classify_name AS channelName, tmp.column_key AS columnKey, tmp.column_name AS columnName, c.app_component_key FROM ( SELECT c.classify_key AS column_key, c.classify_name AS column_name, c.parent_key AS channel_key FROM t_role_classify rc INNER JOIN t_classify c ON rc.classify_key = c.classify_key WHERE role_key = '"..role_key.."' AND component_type = '"..component_type.."' AND c. STATUS = '0' ) tmp INNER JOIN t_classify c ON tmp.channel_key = c.classify_key ) tmp LEFT JOIN t_app_component t ON tmp.app_component_key = t.app_component_key"
end
ngx.log(ngx.CRIT, videolist_sql)
local res, err, errno, sqlstate = db:query(videolist_sql)
if not res then
ngx.say("select error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)
end

if res then
    for i, row in ipairs(res) do
        local video = {}
        video.channelKey = row.channelKey
        video.channelName = row.channelName
        video.columnKey = row.columnKey
        video.columnName = row.columnName
        video.componentKey = row.componentKey
        video.componentName = row.componentName
        list[i] = video
    end
end
db:close()

-- 定义响应体
local request_body = {
    code = 200;
    msg = "成功";
    results = { 
        list = list;
    }
}

local data = cjson.encode(request_body)
ngx.say(data)

return data