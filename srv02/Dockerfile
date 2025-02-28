FROM openresty/openresty:xenial

RUN apt-get update -y \
&& mkdir -p /tmp/cache/nginx \
&& apt-get install wget -y \
&& /usr/local/openresty/luajit/bin/luarocks install lbase64 \
&& /usr/local/openresty/luajit/bin/luarocks install lzlib 0.4.work3-1 \
&& /usr/local/openresty/luajit/bin/luarocks install xml \
&& /usr/local/openresty/luajit/bin/luarocks install lua-resty-http \
&& /usr/local/openresty/luajit/bin/luarocks install lua-resty-maxminddb \
&& sh -c "echo /usr/local/lib  >> /etc/ld.so.conf.d/local.conf" \
&& ldconfig 
