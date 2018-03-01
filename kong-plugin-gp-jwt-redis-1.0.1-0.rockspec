package = "kong-plugin-gp-jwt-redis"  -- TODO: rename, must match the info in the filename of this rockspec!
                                  -- as a convention; stick to the prefix: `kong-plugin-`
version = "1.0.1-0"               -- TODO: renumber, must match the info in the filename of this rockspec!
-- The version '0.1.0' is the source code version, the trailing '1' is the version of this rockspec.
-- whenever the source version changes, the rockspec should be reset to 1. The rockspec version is only
-- updated (incremented) when this file changes, but the source remains the same.

-- TODO: This is the name to set in the Kong configuration `custom_plugins` setting.
-- Here we extract it from the package name.

supported_platforms = {"linux", "macosx"}
source = {
  url = "git://github.com/omarysadek/gp-jwt-redis",
  tag = "1.0.1-0"
}

description = {
  summary = "Kong is a scalable and customizable API Management Layer built on top of Nginx.",
  homepage = "http://getkong.org",
  license = "MIT"
}

dependencies = {
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.gp-jwt-redis.handler"] = "kong/plugins/gp-jwt-redis/handler.lua",
    ["kong.plugins.gp-jwt-redis.schema"] = "kong/plugins/gp-jwt-redis/schema.lua",
    ["kong.plugins.gp-jwt-redis.cache"] = "kong/plugins/gp-jwt-redis/cache.lua",
    ["kong.plugins.gp-jwt-redis.utilities"] = "kong/plugins/gp-jwt-redis/utilities.lua",
  }
}