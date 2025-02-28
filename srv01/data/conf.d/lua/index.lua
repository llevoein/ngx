--local name = ngx.var.arg_name or "Anonymous"
--ngx.say("Hello, ", name, "!")
ngx.say('Hello,world!')
ngx.header.content_type = 'text/plain'
ngx.header["X-My-Header"] = 'location/City'
ngx.say("Host: ", ngx.req.get_headers()["Host"])
ngx.say("Location: ", ngx.req.get_headers()["X-My-Header"])

-- sudo sh -c "echo /usr/local/lib  >> /etc/ld.so.conf.d/local.conf"
-- ldconfig