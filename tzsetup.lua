-- copyright: not finished, use it whatever you want!

Util = require('util')

--[[ default file paths ]]

_PATH_ZONETAB	=	'/usr/share/zoneinfo/zone1970.tab'
_PATH_ISO3166	=	'/usr/share/misc/iso3166'
_PATH_ZONEINFO	=	'/usr/share/zoneinfo'
_PATH_LOCALTIME	=	'/etc/localtime'
_PATH_DB	=	'/var/db/zoneinfo'
_PATH_WALL_CMOS_CLOCK	=	'/etc/wall_cmos_clock'

--[[ wrapper class ]]

-- for use in describing more exotic behaviors
--- @class
--- @param init table
--- 	init.prompt: string,  
---		init.title: string,  
---		init.data: ant,  
---		init.fire: function<DialogMenuItem -> number>
function DialogMenuItem(init)
	local r = {
		prompt = init.prompt,
		title = init.title,
		data = init.data
	}
	r.fire = function() return init.fire(r) end
	return r
end

function usage()
	Util.fprintf(io.stderr, 'usage: tzsetup [-nrs] [-C chroot_directory]'..
	' [zoneinfo_file | zoneinfo_name]\n')
	os.exit(1)
end
