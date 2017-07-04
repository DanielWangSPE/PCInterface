-- 分类视频分类列表接口
-- http://pcapi.qingk.cn/v1/categoryVideoList GET
-- 参数 userId&role_key&component_type
-- 返回 
--[[
    {
        "code": 200,
        "results": {
        "list":[
            {
                "columnKey":"114abb9d451a49489a9e8a8cb1be3d11",
                "columnName":"宿迁新闻"
            },
            {
                "columnKey":"224abb9d451a49489a9e8a8cb1be3d22",
                "columnName":"楚风夜话"
            },
            {
                "columnName":"334abb9d451a49489a9e8a8cb1be3d33",
                "columnName":"走起，新生活！"
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
local userId = args.userId
local role_key = args.role_key
local component_type = args.component_type
ngx.log(ngx.CRIT, userId..role_key..component_type)

local list = {}

-- 创建mysql实例
local db = mysql:new()

--查询sql
local categoryVideoList_sql = "SELECT c.classify_key AS columnKey, c.classify_name AS columnName FROM t_role_classify rc INNER JOIN t_classify c ON rc.classify_key = c.classify_key WHERE role_key = '"..role_key.."' AND component_type = '"..component_type.."'"
local res, err, errno, sqlstate = db:query(categoryVideoList_sql)
if not res then
ngx.say("select error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)
end

if res then
    for i, row in ipairs(res) do
        local categoryVideo = {}
        categoryVideo.columnKey = row.columnKey
        categoryVideo.columnName = row.columnName
        list[i] = categoryVideo
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