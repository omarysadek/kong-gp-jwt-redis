local M = {}

function M.extractToken(req)
  local authorizationToken = req.get_headers()["authorization"]

  if authorizationToken then
    local iterator, err = ngx.re.gmatch(authorizationToken, "\\s*[Bb]earer\\s+(.+)")
    if not iterator then
      return nil, err
    end
    
    local m, err = iterator()
    if err then
      return nil, err
    end
    
    if m and #m > 0 then
      return string.lower(m[1])
    end
  end
end

return M