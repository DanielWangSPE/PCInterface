-- 登录接口不做登录校验
if ngx.var.uri == "/v1/pclogin" then
    return
end

-- pc端登录用户的共享内存
local pclogin_store = ngx.shared.pclogin_store
local args
local request_method = ngx.var.request_method
if "GET" == request_method then
    args = ngx.req.get_uri_args() 
elseif "POST" == request_method then
    ngx.req.read_body()
    args = ngx.req.get_post_args()
end
local userId = args.userId
local login = pclogin_store:get(userId)
if not login then
    ngx.exit(403)
else
    return
end