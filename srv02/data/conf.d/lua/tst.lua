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


local remote_base_url = "https://evilive.run.place/img/massive/"
local image_dir = "/var/www/web/img/massive/"

local allowed_extensions = {".jpg", ".jpeg", ".png", ".webp", ".gif"}

local function is_image(filename)
    filename = filename:lower()
    for _, ext in ipairs(allowed_extensions) do
        if filename:sub(-#ext) == ext then
            return true
        end
    end
    return false
end

local httpc = http.new()
local res, err = httpc:request_uri(remote_base_url, {
    method = "GET",
    ssl_verify = false
})

if not res or res.status ~= 200 then
    ngx.log(ngx.ERR, "Failed to fetch remote file list: ", err)
    ngx.exit(500)
end

--ngx.say(ngx.INFO, "Status: ", res.status)
--ngx.say(ngx.INFO, "Body length: ", #res.body)

for filename in res.body:gmatch('href="([^"]+)"') do
    if is_image(filename) then
        local remote_url = remote_base_url .. filename
        local local_path = image_dir .. filename

        local file_attrs = lfs.attributes(local_path)
        if not file_attrs then
            ngx.log(ngx.INFO, "Downloading: " .. filename)

            local img_res, img_err = httpc:request_uri(remote_url, {
                method = "GET",
                ssl_verify = false,
                timeout = 5000  -- Таймаут 5 сек
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
            ngx.log(ngx.INFO, "Saved: " .. filename)
        else
            ngx.log(ngx.INFO, "Already exists: " .. filename)
        end

        ::continue::
    end
end
ngx.header["Content-Type"] = "text/html"
ngx.say(html_content)