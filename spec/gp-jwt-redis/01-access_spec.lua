local helpers = require "spec.helpers"

describe("gp-jwt-redis", function()
  local proxy_client
  local admin_client

  setup(function()
    local api1 = assert(helpers.dao.apis:insert { 
        name = "lumen-api", 
        hosts = { "lumen-api" }, 
        upstream_url = "http://localhost"
    })

    assert(helpers.dao.plugins:insert {
      api_id = api1.id,
      name = "gp-jwt-redis"
    })

    assert(helpers.start_kong {custom_plugins = "gp-jwt-redis"})

    admin_client = helpers.admin_client()
  end)

  teardown(function()
    if admin_client then
      admin_client:close()
    end

    helpers.stop_kong()
  end)

  before_each(function()
    proxy_client = helpers.proxy_client()
  end)

  after_each(function()
    if proxy_client then proxy_client:close() end
  end)

  describe("Auth with a invalid token", function()
    it("Should return 401", function()

      local res = assert(proxy_client:send {
        method = "GET",
        path   = "/",
        headers = {
          ["Host"] = "lumen-api",
          ["Authorization"] = "bearer aBadToken",
        }
      })

      local body = assert.res_status(401, res)

      --print()
      --print(body)
      --print()
    end)
  end)

  describe("Auth with a valid token", function()
    it("Should return 200", function()

      local res = assert(proxy_client:send {
        method = "GET",
        path   = "/",
        headers = {
          ["Host"] = "lumen-api",
          ["Authorization"] = "Bearer eyjhbgcioijsuzi1niisinr5cci6ikpxuyj9.eyj1c2vybmftzsi6imrldkbndwlkzxbvaw50z2xvymfslmnvbsisimv4cci6mtuxotk1odm3mswiaxaioiixmc4xljewmc4ymzailcjzcmmioijduk1fqvbjx1rps0voiiwiyxv0af90exblijoidxnlcm5hbwvfcgfzc3dvcmqilcjncmfkzsi6inbyzw1pdw0ilcjpyxqioiixnte5ote1mja1in0=.m1qf9hbpgzqrdpiwmvby42xkpno1xtjatp2s7ysnsxtz3givcaeuejavnsiqbh7ush+hach4mezqvq5xvaefojuuw+skfn+1guiozihr6lqo+fdammlap3yxqrenzsd1rtav4qliug0o/iqi8g+lrm1x2hbaq9kdkdjx8vrksch5znbef35jl2v2zsqnrft6ctltorfm/xszsn0ehvwsi7ncybo/1b2eemebl7dwjlmfbe+e4djgrx4ayqgjuvandg6ttdglcs28wwbgszekqcb3if64ix0mlliuvfgzzylnoulmppafnvweadaassxwq2bybzonda3s2+tykr300lxzppa/lgiuydgfer05ldrpto2jmdgsg+jnr1ewh20w5gehh655pvwxnhhvrlg9v/34rmhzv5o8psvy8xfdojjgcztuytg89qrwyco26acuapk2szqlbfgsxnt+7mw4goboniise/vlcz4emjbcsik/gwrjdni5pdwkldbrz6sunhl0/k3bii6hznqtpkggovzype2szpthbulwizxzpvhq3kcpekdska24fog68/iqic//p9o1gwwadt4cetzxgm/fpbdd6llso+q7w7kmu9bytfkr9yhq2ibrozabo2u798qmywlhc8ydnixlnwz6aasd6lb1qddps25ae27xgsu=",
        }
      })

      local body = assert.res_status(200, res)

      --print()
      --print(body)
      --print()
    end)
  end)

end)