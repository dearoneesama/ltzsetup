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

-- why use a socalled nullptr? because if a table value is nil,
-- it is the same as the key does not exist
NULLPTR = false

function Object(o)
	-- left blank, may be useful like adding get/set
	return o
end

--- @param filename string
--- @param callback function
function flines(filename, callback)
	local fp, errmsg, errno = io.open(filename, 'r')
	if not fp then
		Util.err(1, errmsg, errno, '%s', filename)
	end

	local lineno = 0
	for line in fp:lines('l') do
		lineno = lineno+1
		-- skip comments starting with #
		if line:match('^%s*#') then goto continue end
		-- skip blanks
		if line:match('^%s*$') then goto continue end
		callback(line, lineno)
		::continue::
	end
	fp:close()
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
	return Object(r)
end

--- @class Continent
--- @field menu DialogMenuItem[]
--- @field nitems integer
--- @param init table
--- @return Continent
function Continent(init)
	return Object {
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
	return Object {
		name = init.name,
		tlc = init.tlc,
		nzones = init.nzones or 1,
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
	return Object {
		link = init.link,
		desc = init.desc,
		filename = init.filename,
		continent = init.continent
	}
end

--[[ main drivers ]]

--- @class TZDBSetup
--- @param path_iso3166 string
--- @param path_zonetab string
--- @return TZDBSetup
function TZDBSetup(path_iso3166, path_zonetab)

	-- keys are like 'AF', 'DZ', ...
	--- @type table<string, Country>
	local Countries = {}

	--- @type table<..., Continent>
	local Continents = {
		Africa = NULLPTR,
		America = NULLPTR,
		Antarctica = NULLPTR,
		Asia = NULLPTR,
		Atlantic = NULLPTR,
		Australia = NULLPTR,
		Europe = NULLPTR,
		Indian = NULLPTR,
		Pacific = NULLPTR,
		UTC = NULLPTR
	}

	local function read_iso3166_table()
		flines(path_iso3166, function(line, lineno)
			-- example line:
			-- AF	AFG	004	Afghanistan
			local code2, _, _, name
			    = line:match('^(%u%u)\t(%u%u%u)\t(%d%d%d)\t(.+)')
			if not code2 then
				Util.errx(1, '%s:%d: invalid format', path_iso3166, lineno)
			end
			if Countries[code2] then
				Util.errx(1, "%s:%d: country code `%s' multiply defined: %s",
				    path_iso3166, lineno, code2, name)
			end
			-- if you can combine initialization into one step doit
			Countries[code2] = Country { name=name, tlc=code2 }
		end)
	end

	local function add_zone_to_country(...)
	end

	local function read_zone1970()
		flines(path_zonetab, function(line, lineno)
			--- example line:
			--- AR	-2828-06547	America/Argentina/Catamarca	Catamarca (CT); Chubut (CH)
			local code2s, _, contname, _, comment
			    = line:match('^([%u,]+)\t([%d+-]-)\t(%w+)/(.-)\t?(.*)')
			-- code2s=AR
			-- _=-2828-06547
			-- contname=America
			-- _=Argentina/Catamarca
			-- comment=Catamarca (CT); Chubut (CH)
			if not code2s then
				Util.errx('%s:%d: invalid format', path_zonetab, lineno)
			end
			for c in code2s:gmatch('[^,]+') do
				if #c ~= 2 then
					Util.errx(1, "%s:%d: invalid country code `%s'",
					    path_zonetab, lineno, c)
				end
			end
			if Continents[contname] == nil then
				Util.errx(1, "%s:%d: invalid region `%s'",
				    path_zonetab, lineno, contname)
			end
			add_zone_to_country(lineno, code2s:sub(-2), comment, contname)
			-- tzsetup.c:526
		end)
	end

end


function usage()
	Util.fprintf(io.stderr, 'usage: tzsetup [-nrs] [-C chroot_directory]'..
	' [zoneinfo_file | zoneinfo_name]\n')
	os.exit(1)
end
