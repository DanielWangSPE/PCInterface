-- 通过子请求方式将post请求转为get请求

local var = ngx.var

-- 判断请求方式，取参数列表
local uri = var.uri
local request_method = var.request_method
local args
if "GET" == request_method then
    args = ngx.req.get_uri_args()   
elseif "POST" == request_method then
    ngx.req.read_body()
    args = ngx.req.get_post_args()
end

-- 发起get子请求
local res = ngx.location.capture("/v2"..uri, {method = ngx.HTTP_GET, args = args})
ngx.say(res.body)
