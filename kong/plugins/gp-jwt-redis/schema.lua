local cache = require "kong.plugins.gp-jwt-redis.cache"
local Errors = require "kong.dao.errors"

return {
  no_consumer = true,
  fields = {
    redisHost    = {type = "string", required = false, default  = "172.16.100.160"},
    redisPort    = {type = "number", required = false, default  = 6379},
    redisDB      = {type = "number", required = false, default  = 13},
    redisTimeout = {type = "number", required = false, default  = 1000}
  },
  self_check = function(schema, plugin_t, dao, is_updating)
    local ok, err = cache.connect(plugin_t)
    if not ok then
      
      return false, Errors.schema "Redis Host unreachable: " .. err
    end

    return true
  end
}