-- 文件上传后，入库接口
-- http://pcapi.qingk.cn/v1/finishUpload POST
-- 参数 appId&create_time&wait_time&begin_time&end_time&duration&file_name&file_size&file_long&file_type&component&msg&s_list_imgname&sequenceid&creator&media_type&file_original_name&status&classify
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

local msg = ""
    
-- 获取请求体中的参数
local args = ngx.req.get_uri_args()
local appId = args.appId or ""
local create_time = args.create_time or ""
local wait_time = args.wait_time or ""
local begin_time = args.begin_time or ""
local end_time = args.end_time or ""
local duration = args.duration or ""
local file_name = args.file_name or ""
local file_size = args.file_size or ""
local file_long = args.file_long or ""
local file_type = args.file_type or ""
local component = args.component or ""
local classify = args.classify or ""
local status = args.status or ""
local file_original_name = args.file_original_name or ""
local msg = args.msg or ""
local s_list_imgname = args.s_list_imgname or ""
local sequenceid = args.sequenceid or ""
local creator = args.creator or ""
local media_type = args.media_type or ""

-- 创建mysql实例
local db = mysql:new()

--查询sql
local insert_sql = "INSERT INTO t_transcoding ( app_information_key, create_time, wait_time, begin_time, end_time, duration, file_name, file_size, file_long, file_type, component, classify, STATUS, file_original_name, msg, s_list_imgname, sequenceid, creator, media_type ) VALUES ( '"..appId.."', '"..create_time.."', '"..wait_time.."', '"..begin_time.."', '"..end_time.."', '"..duration.."', '"..file_name.."', '"..file_size.."', '"..file_long.."', '"..file_type.."', '"..component.."', '"..classify.."', '"..status.."', '"..file_original_name.."', '"..msg.."', '"..s_list_imgname.."', '"..sequenceid.."', '"..creator.."', '"..media_type.."' );commit;"

local res, err, errno, sqlstate = db:query(insert_sql)
if not res then
    ngx.log(ngx.CRIT, "select error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)
    db:close()
    
    -- 返回插入错误的相应体
    local request_body = {
        code = 200;
        msg = "false";
    }
    local data = cjson.encode(request_body)
    ngx.say(data)
    return data
end
ngx.log(ngx.CRIT, "---------"..insert_sql)

db:close()

-- 定义相应体
local request_body = {
    code = 200;
    msg = "true";
}
local data = cjson.encode(request_body)
ngx.say(data)

return data


