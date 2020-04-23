-- copyright: not finished, use it whatever you want!

Abstk = require('abstk')
Util = require('util')

Abstk.set_mode('curses')

--[[ default file paths ]]

_PATH_ZONETAB	=	'/usr/share/zoneinfo/zone1970.tab'
_PATH_ISO3166	=	'/usr/share/misc/iso3166'
_PATH_ZONEINFO	=	'/usr/share/zoneinfo'
_PATH_LOCALTIME	=	'/etc/localtime'
_PATH_DB	=	'/var/db/zoneinfo'
_PATH_WALL_CMOS_CLOCK	=	'/etc/wall_cmos_clock'

-- [[ more utils ]]

function Object(o)
	-- left blank, may be useful
	return o
end

--[[ wrapper class ]]

-- for use in describing more exotic behaviors
--- @class DialogMenuItem
--- @field prompt string
--- @field title string
--- @field data any
--- @field fire function<()->integer>
--- @param init table
--- @return DialogMenuItem
function DialogMenuItem(init)
	local r = {
		prompt = init.prompt,
		title = init.title,
		data = init.data
	}
	r.fire = function() return init.fire(r) end
	return r
end

--- @class Continent
--- @field menu DialogMenuItem[]
--- @field nitems integer
--- @param init table
--- @return Continent
function Continent(init)
	return {
		menu = init.menu,
		nitems = init.nitems
	}
end

--- @class Country
--- @field name string
--- @field tlc string
--- @field nzones integer
--- @field filename string?
--- @field continent Continent?
--- @field zones Zone[]?
--- @field submenu Continent?
--- @param init table
--- @return Country
function Country(init)
	return {
		name = init.name,
		tlc = init.tlc,
		nzones = init.nzones,
		filename = init.filename,	-- use iff nzones < 0
		continent = init.continent,	-- use iff nzones < 0
		zones = init.zones,	-- use iff nzones > 0
		submenu = init.submenu	-- use iff nzones > 0
	}
end

--- @class Zone
--- @field link Zone
--- @field desc string
--- @field filename string
--- @field continent Continent
--- @param init table
--- @return Zone
function Zone(init)
	return {
		link = init.link,
		desc = init.desc,
		filename = init.filename,
		continent = init.continent
	}
end

--[[ main drivers ]]

--- @class TZDBSetup
--- @param path_iso3166 string
--- @return TZDBSetup
function TZDBSetup(path_iso3166)

	-- keys are like 'AM', 'AQ', ...
	--- @type table<string, Country>
	local Contries = {}

	local function read_iso3166_table()
		local fp, errmsg, errno = io.open(path_iso3166, 'r')
		if not fp then
			Util.err(1, errmsg, errno, '%s', path_iso3166)
		end
		fp:close()
	end

end

function usage()
	Util.fprintf(io.stderr, 'usage: tzsetup [-nrs] [-C chroot_directory]'..
	' [zoneinfo_file | zoneinfo_name]\n')
	os.exit(1)
end
