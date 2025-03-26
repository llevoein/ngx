# ngx
ngx lua preview

[ first server https://evilive.run.place/ displays information about the site visitor ] 

[ https://evilive.run.place/img contains a number of images ]

[ https://evilimg.run.place/img takes images from the site https://evilive.run.place/img and caches them locally ]

[ I made the following changes:
  *  401 code handler. [ https://evilive.run.place/401.html ]

  *  added file https://github.com/llevoein/ngx/blob/main/srv02/data/conf.d/lua/checker.lua
which adds logic for parsing image downloads and caching.
]
