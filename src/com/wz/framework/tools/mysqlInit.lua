-- mysql创建、初始化、连接池

local mysql = require "resty.mysql"

local config = {
    host = "10.10.49.11",
    port = 3306,
    database = "mmsdb_formaldev",
    user = "root",
    password = "123abc"
}

local _M = {}


function _M.new(self)
    local db, err = mysql:new()
    if not db then
        ngx.say("mysql new error")
        return
    end
    db:set_timeout(1000) -- 1 sec

    local ok, err, errno, sqlstate = db:connect(config)

    if not ok then
        ngx.say("mysql connect error")
        return
    end
    db.close = close
    return db
end

function close(self)
    local sock = self.sock
    if not sock then
        return nil, "not initialized"
    end
    if self.subscribed then
        return nil, "subscribed state"
    end
    return sock:setkeepalive(30000, 100)
end

return _M