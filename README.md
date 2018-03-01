# Installing and using Kong via Vagrant file

```
$ git clone https://github.com/omarysadek/kong-gp-jwt-redis
$ cd kong-vagrant/
$ vagrant up
$ vagrant ssh
```

###### _Configure and Start Kong_

```
$ kong migrations up
$ kong start
```

# Using Mockbin as API

```
$ cd /home/vagrant/mockbin
$ npm config set mockbin:port 80
$ npm start
$ curl -X GET --url http://localhost:80
```

# Using Lumen as API (used in this tuto)

###### _Installing via composor_

```
$ sudo apt install php7.1 php7.1-common php7.1-cli php7.1-fpm php7.1-zip php7.1-xml php7.1-mbstring zip unzip
$ composer global require "laravel/lumen-installer"
$ lumen new blog
```

#### Edit entery point of the API to return all headers as json

###### An exemple of how doing it on lumen _routes\web.php_

```
<?php

/*
|--------------------------------------------------------------------------
| Application Routes
|--------------------------------------------------------------------------
|
| Here is where you can register all of the routes for an application.
| It is a breeze. Simply tell Lumen the URIs it should respond to
| and give it the Closure to call when that URI is requested.
|
*/

$router->get('/', function () use ($router) {
    return response()->json(app('request')->header());
});

```

#### Start a local server

```
$ sudo php -S localhost:80 -t /lumen/blog/public
```

# Making sure the API is callable from the vagrant box

```
$ curl -X GET --url http://localhost

```

> {"user-agent":["curl\/7.35.0"],"host":["localhost"],"accept":["*\/*"]}

# Add an API on Kong

* ### Accessible via Host
```
$ curl -i -X POST \
  --url http://localhost:8001/apis/ \
  --data 'name=lumen-api' \
  --data 'hosts=lumen-api' \
  --data 'upstream_url=http://localhost'
```

  > HTTP/1.1 201 Created
  > Date: Wed, 28 Feb 2018 22:18:48 GMT
  > Content-Type: application/json; charset=utf-8
  > Transfer-Encoding: chunked
  > Connection: keep-alive
  > Access-Control-Allow-Origin: *
  > Server: kong/0.12.1
  > 
  > {"created_at":1519856328775,"strip_uri":true,"id":"ec9bfdf2-4b1a-45a0-9ba0-bdcc70e0cfdc","hosts":["lumen-api"],"name":"lumen-api","http_if_terminated":false,"preserve_host":false,"upstream_url":"http:\/\/localhost","upstream_connect_timeout":60000,"upstream_send_timeout":60000,"upstream_read_timeout":60000,"retries":5,"https_only":false}

* ### Accessible via Uris (used in this tuto)
```
$ curl -i -X POST \
  --url http://localhost:8001/apis/ \
  --data 'name=lumen-api' \
  --data 'uris=/lumen-api' \
  --data 'upstream_url=http://localhost'
```

  > HTTP/1.1 201 Created
  > Date: Wed, 28 Feb 2018 22:20:54 GMT
  > Content-Type: application/json; charset=utf-8
  > Transfer-Encoding: chunked
  > Connection: keep-alive
  > Access-Control-Allow-Origin: *
  > Server: kong/0.12.1
  > 
  > {"created_at":1519856454640,"strip_uri":true,"id":"731f9cc9-691e-401f-a42b-4a91fb60a29d","name":"lumen-api","http_if_terminated":false,"preserve_host":false,"upstream_url":"http:\/\/localhost","uris":["\/lumen-api"],"upstream_connect_timeout":60000,"upstream_send_timeout":60000,"upstream_read_timeout":60000,"retries":5,"https_only":false}


#### _Delete an API on kong (if needed)_

```
$ curl -X DELETE --url http://localhost:8001/apis/lumen-api
```

# Accessing API via Kong

* ### Via Host

```
$ curl -k -X GET https://localhost:8443/ \
  --header 'Host: lumen-api'
```

> {"host":["localhost"],"connection":["keep-alive"],"x-forwarded-for":["127.0.0.1"],"x-forwarded-proto":["https"],"x-forwarded-host":["lumen-api"],"x-forwarded-port":["8443"],"x-real-ip":["127.0.0.1"],"user-agent":["curl\/7.35.0"],"accept":["*\/*"]}

* ### Via Uris

```
$ curl -k -X GET https://localhost:8443/lumen-api
```

> {"host":["localhost"],"connection":["keep-alive"],"x-forwarded-for":["127.0.0.1"],"x-forwarded-proto":["https"],"x-forwarded-host":["lumen-api"],"x-forwarded-port":["8443"],"x-real-ip":["127.0.0.1"],"user-agent":["curl\/7.35.0"],"accept":["*\/*"]}

# Basic authentication

* ### Configuration

```
$ curl -X POST http://localhost:8001/apis/lumen-api/plugins \
    --data "name=basic-auth"
```

> {"created_at":1519856909000,"config":{"hide_credentials":false,"anonymous":""},"id":"df981ed9-b254-4611-808d-77537324d299","name":"basic-auth","api_id":"8134a600-103b-4cf2-8c91-028aa616b2b7","enabled":true}

###### _In order to use the plugin, you first need to create a consumer to associate one or more credentials to. The Consumer represents a developer using the final service/API._

* ### Create a Consumer

```
$ curl -d "username=dev" http://localhost:8001/consumers/
```

> {"created_at":1519335449000,"username":"dev","id":"f4cbab97-b8d7-497b-b132-45b6415ca91f"}

* ### Create a Credential

```
$ curl -X POST http://localhost:8001/consumers/dev/basic-auth \
    --data "username=dev@guidepointglobal.com" \
    --data "password=newfeb"
```

> {"created_at":1519335551000,"id":"4d4dd676-9721-4d8a-a68d-b420163db7ea","username":"dev@guidepointglobal.com","password":"4dc4521b384813ce9e489a36cccace200adbb759","consumer_id":"f4cbab97-b8d7-497b-b132-45b6415ca91f"}

* ### Using the Credential

_The authorization header must be base64 encoded. For example, if the credential uses dev@guidepointglobal.com as the username and newfeb as the password, then the field's value is the base64-encoding of dev@guidepointglobal.com:newfeb, or ZGV2QGd1aWRlcG9pbnRnbG9iYWwuY29tOm5ld2ZlYg==_

```
$ curl -k https://localhost:8443/lumen-api \
    -H 'Authorization: Basic ZGV2QGd1aWRlcG9pbnRnbG9iYWwuY29tOm5ld2ZlYg=='
```

> {"host":["localhost"],"connection":["keep-alive"],"x-forwarded-for":["127.0.0.1"],"x-forwarded-proto":["https"],"x-forwarded-host":["localhost"],"x-forwarded-port":["8443"],"x-real-ip":["127.0.0.1"],"user-agent":["curl\/7.35.0"],"accept":["*\/*"],"authorization":["Basic ZGV2QGd1aWRlcG9pbnRnbG9iYWwuY29tOm5ld2ZlYg=="],"x-consumer-id":["8a98075d-037e-4b36-90b0-3613014e7b30"],"x-consumer-username":["dev"],"x-credential-username":["dev@guidepointglobal.com"],"php-auth-user":["dev@guidepointglobal.com"],"php-auth-pw":["newfeb"]}

## Using gp-jwt-redis home made plugin

  ```
  $ cd /kong-plugin
  ```

  #### The package file to include all depencies and files
  ###### _kong-plugin-gp-jwt-redis-1.0.0.rockspec_

  ```
  package = "kong-plugin-gp-jwt-redis"  -- TODO: rename, must match the info in the filename of this rockspec!
                                    -- as a convention; stick to the prefix: `kong-plugin-`
  version = "1.0.0"               -- TODO: renumber, must match the info in the filename of this rockspec!
  -- The version '0.1.0' is the source code version, the trailing '1' is the version of this rockspec.
  -- whenever the source version changes, the rockspec should be reset to 1. The rockspec version is only
  -- updated (incremented) when this file changes, but the source remains the same.

  -- TODO: This is the name to set in the Kong configuration `custom_plugins` setting.
  -- Here we extract it from the package name.

  supported_platforms = {"linux", "macosx"}
  source = {
    url = "git://github.com/omarysadek/gp-jwt-redis",
    tag = "1.0.0"
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

  ```

  ### Packaging sources
  ```
  $ luarocks make
  ```
  > kong-plugin-gp-jwt-redis 1.0.1-0 is now installed in /usr/local (license: MIT)

    ```
    $ luarocks pack kong-plugin-gp-jwt-redis 1.0.1-0
    ```

    > adding: doc/ (stored 0%)
    > adding: doc/LICENSE (deflated 65%)
    > adding: doc/README.md (deflated 66%)
    > adding: lua/ (stored 0%)
    > adding: lua/kong/ (stored 0%)
    > adding: lua/kong/plugins/ (stored 0%)
    > adding: lua/kong/plugins/gp-jwt-redis/ (stored 0%)
    > adding: lua/kong/plugins/gp-jwt-redis/schema.lua (deflated 53%)
    > adding: lua/kong/plugins/gp-jwt-redis/handler.lua (deflated 61%)
    > adding: lua/kong/plugins/gp-jwt-redis/cache.lua (deflated 54%)
    > adding: lua/kong/plugins/gp-jwt-redis/utilities.lua (deflated 51%)
    > adding: kong-plugin-gp-jwt-redis-1.0.1-0.rockspec (deflated 57%)
    > adding: rock_manifest (deflated 45%)
    > Packed: /kong-plugin/kong-plugin-gp-jwt-redis-1.0.1-0.all.rock

  ### Installing the plugin
  ```
  $ luarocks install kong-plugin-gp-jwt-redis-1.0.1-0.all.rock
  ```
  > kong-plugin-gp-jwt-redis 1.0.1-0 is now installed in /usr/local (license: MIT)

  ### Load the plugin
  ```
  $ export KONG_CUSTOM_PLUGINS=gp-jwt-redis
  ```

  ### Attached the plugin to the Lumen API

  * #### Using default value for Redis to connect to dev env (IP/PORT/DDB)

  ```
  $ curl -X POST http://localhost:8001/apis/lumen-api/plugins \
      --data "name=gp-jwt-redis"
  ```

  > {"created_at":1519858310000,"config":{"redisPort":6379,"redisHost":"172.16.100.160","redisTimeout":1000,"redisDB":13},"id":"1a966643-8f54-4bfe-9824-edf0923ae871","name":"gp-jwt-redis","api_id":"8134a600-103b-4cf2-8c91-028aa616b2b7","enabled":true}

  * #### Personalize the setting to connect to Redis (IP/PORT/DDB)

  ```
  $ curl -X POST http://localhost:8001/apis/lumen-api/plugins \
    --data "name=myplugin" \
    --data "config.redisHost=172.16.100.160" \
    --data "config.redisPort=6399" \
    --data "config.redisDB=13"
  ```

  > {"created_at":1519918148000,"config":{"redisPort":6399,"redisHost":"172.16.100.160","redisDB":13,"redisTimeout":1000},"id":"8cfefb29-0719-4b3e-a228-3ffc2cb43d57","name":"myplugin","api_id":"8134a600-103b-4cf2-8c91-028aa616b2b7","enabled":true}


  ### Start the server
  ```
  $ kong start
  ```

  ### Test it!
  ```
  $ curl -k https://localhost:8443/lumen-api
  ```
  > {"message":"Unauthorized"}

  ```
  $ curl -k https://localhost:8443/lumen-api \
    --header 'Authorization:bearer <JWT TOKEN HERE>'
  ```
  > {"host":["localhost"],"connection":["keep-alive"],"x-forwarded-for":["127.0.0.1"],"x-forwarded-proto":["https"],"x-forwarded-host":["localhost"],"x-forwarded-port":["8443"],"x-real-ip":["127.0.0.1"],"user-agent":["curl\/7.35.0"],"accept":["*\/*"],"authorization":["bearer eyjhbgcioijsuzi1niisinr5cci6ikpxuyj9.eyj1c2vybmftzsi6imrldkbndwlkzxbvaw50z2xvymfslmnvbsisimv4cci6mtuxotk1odm3mswiaxaioiixmc4xljewmc4ymzailcjzcmmioijduk1fqvbjx1rps0voiiwiyxv0af90exblijoidxnlcm5hbwvfcgfzc3dvcmqilcjncmfkzsi6inbyzw1pdw0ilcjpyxqioiixnte5ote1mja1in0=.m1qf9hbpgzqrdpiwmvby42xkpno1xtjatp2s7ysnsxtz3givcaeuejavnsiqbh7ush+hach4mezqvq5xvaefojuuw+skfn+1guiozihr6lqo+fdammlap3yxqrenzsd1rtav4qliug0o\/iqi8g+lrm1x2hbaq9kdkdjx8vrksch5znbef35jl2v2zsqnrft6ctltorfm\/xszsn0ehvwsi7ncybo\/1b2eemebl7dwjlmfbe+e4djgrx4ayqgjuvandg6ttdglcs28wwbgszekqcb3if64ix0mlliuvfgzzylnoulmppafnvweadaassxwq2bybzonda3s2+tykr300lxzppa\/lgiuydgfer05ldrpto2jmdgsg+jnr1ewh20w5gehh655pvwxnhhvrlg9v\/34rmhzv5o8psvy8xfdojjgcztuytg89qrwyco26acuapk2szqlbfgsxnt+7mw4goboniise\/vlcz4emjbcsik\/gwrjdni5pdwkldbrz6sunhl0\/k3bii6hznqtpkggovzype2szpthbulwizxzpvhq3kcpekdska24fog68\/iqic\/\/p9o1gwwadt4cetzxgm\/fpbdd6llso+q7w7kmu9bytfkr9yhq2ibrozabo2u798qmywlhc8ydnixlnwz6aasd6lb1qddps25ae27xgsu="],"username":["dev@guidepointglobal.com"]}

  ### Delete a plugin
  ```
  $ curl -X GET http://localhost:8001/apis/lumen-api/plugins/
  ```
  > {"total":1,"data":[{"created_at":1519760369000,"config":{},"id":"655449e3-b719-4ac7-91b7-99879705e9c1","enabled":true,"api_id":"50aa0180-2329-4ece-ad9e-75a575044c37","name":"gp-jwt-redis"}]}

  ```
  $ curl -X DELETE http://localhost:8001/apis/lumen-api/plugins/<id> = 655449e3-b719-4ac7-91b7-99879705e9c1
  ```

  ```
  $ luarocks remove kong-plugin-gp-jwt-redis-1.0.1-0.all.rock
  ```
  > Checking stability of dependencies in the absence of
  > kong-plugin-gp-jwt-redis 1.0.1-0...
  > 
  > Removing kong-plugin-gp-jwt-redis 1.0.1-0...
  > Removal successful.

  ```
  $ rm kong-plugin-gp-jwt-redis-1.0.1-0.all.rock
  ```

  # Unit testing

  ```
  $ kong-plugin
  $ bin/busted spec/
  ```

  > ●●
  > 2 successes / 0 failures / 0 errors / 0 pending : 14.566919 seconds
