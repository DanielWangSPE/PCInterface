-- gearman创建、初始化、连接池

local gearman = require "resty.gearman"

local config = {
    host = "10.10.49.11",
    port = 3306
}

local _M = {}


function _M.new(self)
    local gm, err = gearman:new()
    if not gm then
        ngx.say("gearman new error")
        return
    end
    gm:set_timeout(1000) -- 1 sec

    local ok, err = gm:connect(config)

    if not ok then
        ngx.say("gearman connect error")
        return
    end

    gm.close = close
    return gm
end

function _M.close(gm)
    if not gm then
        return
    else    
        -- put it into the connection pool of size 100,
        -- with 0 idle timeout
        local ok, err = gm:set_keepalive(0, 100)
        if not ok then
            ngx.say("failed to set keepalive: ", err)
            return
        end
    end
end

return _M