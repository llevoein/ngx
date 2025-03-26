local template = io.open("/var/www/web/img/image.html", "r")
if not template then
    ngx.say("Failed to open template file")
    return
end
local html_content = template:read("*a")
template:close()

local http = require "resty.http"
local lfs = require "lfs"
local io = require "io"
local cjson = require "cjson"

local remote_base_url = "https://evilive.run.place/img/massive/"
local image_dir = "/var/www/web/img/massive/"
local cache_file = "/tmp/cache/nginx/cache.json"
local allowed_extensions = {".jpg", ".jpeg", ".png", ".webp", ".gif"}

local function load_cache()
    local file = io.open(cache_file, "r")
    if not file then return {} end
    
    local content = file:read("*a")
    file:close()
    
    local ok, cache = pcall(cjson.decode, content)
    if not ok then
        ngx.log(ngx.ERR, "Failed to parse cache file: ", cache)
        return {}
    end
    
    return cache or {}
end

local function save_cache(cache)
    local file = io.open(cache_file, "w")
    if not file then
        ngx.log(ngx.ERR, "Failed to open cache file for writing")
        return false
    end
    
    file:write(cjson.encode(cache))
    file:close()
    return true
end

local function is_image(filename)
    filename = filename:lower()
    for _, ext in ipairs(allowed_extensions) do
        if filename:sub(-#ext) == ext then
            return true
        end
    end
    return false
end

local image_cache = load_cache()

local httpc = http.new()
local res, err = httpc:request_uri(remote_base_url, {
    method = "GET",
    ssl_verify = false
})

if not res or res.status ~= 200 then
    ngx.log(ngx.ERR, "Failed to fetch remote file list: ", err)
    ngx.exit(500)
end

for filename in res.body:gmatch('href="([^"]+)"') do
    if is_image(filename) then
        local remote_url = remote_base_url .. filename
        local local_path = image_dir .. filename

        if not image_cache[filename] then
            local file_attrs = lfs.attributes(local_path)
            if file_attrs then
                image_cache[filename] = {
                    path = local_path,
                    timestamp = os.time()
                }
                save_cache(image_cache)
            else
                ngx.log(ngx.INFO, "Downloading: " .. filename)

                local img_res, img_err = httpc:request_uri(remote_url, {
                    method = "GET",
                    ssl_verify = false,
                    timeout = 5000
                })

                if not img_res or img_res.status ~= 200 then
                    ngx.log(ngx.ERR, "Failed to download: ", filename, " error: ", img_err or "unknown")
                    goto continue
                end

                local file, err = io.open(local_path, "wb")
                if not file then
                    ngx.log(ngx.ERR, "Failed to save: ", filename, " error: ", err)
                    goto continue
                end

                file:write(img_res.body)
                file:close()

                image_cache[filename] = {
                    path = local_path,
                    timestamp = os.time(),
                    size = #img_res.body
                }
                save_cache(image_cache)             
                ngx.log(ngx.INFO, "Saved and cached: " .. filename)
            end
        else
            ngx.log(ngx.INFO, "Image in cache: " .. filename)
        end
        ::continue::
    end
end

ngx.header["Content-Type"] = "text/html"
ngx.say(html_content)