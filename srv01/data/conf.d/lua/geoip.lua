local geo = require "resty.maxminddb"
if not geo.initted() then
    geo.init("/etc/nginx/conf.d/GeoLite2-City.mmdb")
end
local res,err = geo.lookup(ngx.var.arg_ip or ngx.var.remote_addr)
--ngx.say("IP: ", ngx.var.remote_addr)
--ngx.say("Country: ", res.country.names.en or "Unknown")
--ngx.say("City: ", res.city.names.en or "Unknown")

local template = io.open("/var/www/web/index.html", "r")
if not template then
    ngx.say("Failed to open template file")
    return
end
local html_content = template:read("*a")
template:close()

if res and res.country and res.country.names and res.country.names.en ~= nil then
    html_content = html_content:gsub("{{ country }}", res.country.names.en)
else
    html_content = html_content:gsub("{{ country }}", "Unknown")
end
if res and res.city and res.city.names and res.city.names.en ~= nil then
    html_content = html_content:gsub("{{ city }}", res.city.names.en)
else
    html_content = html_content:gsub("{{ city }}", "Unknown")
end
ngx.header["Content-Type"] = "text/html"
ngx.say(html_content)

--ngx.say("Latitude: ", res.location.latitude or "Unknown")
--ngx.say("Longitude: ", res.location.longitude or "Unknown")