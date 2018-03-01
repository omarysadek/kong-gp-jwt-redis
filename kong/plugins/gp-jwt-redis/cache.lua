local M = {}

function M.connect(pluginConf)
  local redis = require "resty.redis"

  local red = redis:new()

  red:set_timeout(pluginConf.redisTimeout)
  
  local ok, err = red:connect(pluginConf.redisHost, pluginConf.redisPort)
  if err then
    return nil, err
  end

  ok, err = red:select(pluginConf.redisDB)
  if err then
    return nil, err
  end

  return red
end

return M