local plugin = require("kong.plugins.base_plugin"):extend()
local cache = require "kong.plugins.gp-jwt-redis.cache"
local utilities = require "kong.plugins.gp-jwt-redis.utilities"

plugin.PRIORITY = 1000

function plugin:new()
  plugin.super.new(self, "gp-jwt-redis")
end

function plugin:access(pluginConf)
  plugin.super.access(self)

  local responses = require "kong.tools.responses"

  local token, err = utilities.extractToken(ngx.req)
  if err then
    ngx.log(ngx.ERR, "Failed to extract token: ", err)
    return responses.send(400, err)
  end

  local red, err = cache.connect(pluginConf)
  if err then
    ngx.log(ngx.ERR, "Failed to connect to Redis: ", err)
    return responses.send(500, err)
  end

  local ok = red:hget(token, "username")
  if not ok or ok == ngx.null then
    ngx.log(ngx.ERR, "Failed to find user on Redis : ", err)
    return responses.send(401, err)
  end

  ngx.req.set_header("username", ok)
end

return plugin
