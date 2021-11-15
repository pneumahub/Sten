---------------------------------------------------------------------------------
--- PneumaLib -- Developed by Pneuma#2149 ---------------------------------------
--- ===================================== ---------------------------------------
-- TODO(Pneuma): Organize this mess
-- NOTE(Pneuma): I need to put these in their own module(s).

if getfenv().Instance ~= nil then
	return getfenv().Instance
else
	_G.Framework = {};
end

local fw = _G.Framework;
fw.DebugMode = false;

fw.__TEMPORARY = {};
fw.Running = true;

fw.Memoize = function(fun)
	local previousError = error;
	getfenv(fun).error = function(msg, lvl)
		lvl = lvl or 1;
		lvl = lvl > 0 and lvl + 1 or lvl;
		previousError(msg, lvl);
	end

	local saved = setmetatable({}, {__mode = "v"});

	local function checkvals(tble, vals)
		for i = 1, #tble do
			if tble[i] ~= vals[i] then
				return false;
			end
		end
		return true;
	end

	return function(...)
		for i = 1, #saved do
			local v = saved[i];
			if v == nil then goto continue end
			if checkvals(v.Args, {...}) then
				return table.unpack(v.Results);
			end
			::continue::
		end
		local saving = {
			Args = {...},
			Results = table.pack(fun(...));
		};
		if #saving.Results ~= 0 then
			table.insert(saved, saving);
		end
		return table.unpack(saving.Results);
	end
end

getfenv().typeof = function(obj)
	if fw.isObject(obj) then
		return 'Object';
	else
		return type(obj);
	end
end

getfenv().UDim2 = {new = function(...) return fw.new('BUILTIN::UDim2', ...) end}
getfenv().UDim = {new = function(...) return fw.new('BUILTIN::UDim', ...) end} 
getfenv().Vector2 = {new = function(...) return fw.new('BUILTIN::Vector2', ...) end}

-- TODO(Pneuma): Implement classes
getfenv().Vector3 = {new = function(...) return fw.new('BUILTIN::Vector2', ...) end} 

local oldpairs = pairs;
getfenv().pairs = function(...) 
	local a = {...};
	local obj = a[1];
	if type(getmetatable(obj)) == 'table' and type(getmetatable(obj).__pairs) == 'function' then
		return getmetatable(obj).__pairs(...);
	end
	return oldpairs(...);
end

string.split = function(s, delimiter)
    result = {}
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

table.pack = function(...)
	return {...}
end

table.unpack = function(...)
	local str = [[
		return %s
	]]
	local f = "";
	local temp = {};
	for i, v in pairs({...}) do
		for _, v in pairs(v) do
			local ii = #temp + 1;
			temp[ii] = v;
			f = f~='' and f..', ' or f;
			f = f..'temp['..ii..']';
		end
	end
	f = loadstring(string.format(str, f));
	getfenv(f).temp = temp;
	return f()
end

table.find = function(tble, val)
	for i, v in next, tble do
		if v == val then
			return i;
		end
	end
end

table.clone = function(tble)
	local returning = {};
	for i, v in pairs(tble) do
		returning[i] = v;
	end
	return returning;
end

fw.verifyarg = function(a, t, r, m, l)
	if t == nil then
		error('Missing argument #2: type [table | string]', 2);
	end	
	
	if type(t) ~= 'table' and type(t) ~= 'string' then
		error('Invalid argument #2: Expected [table | string], got '..type(t), 2);
	end
	
	local metType = false;
	if type(t) == 'table' then
		for i, v in pairs(t) do
			local isa = false;
			if fw.isObject(a) then 
				if a.IsA == nil or a.IsA(v) == false then
					goto continue;
				end
				metType = true;
				break;
			end
			if (type(a) == v) then
				metType = true;
				break;
			end
			::continue::
		end
	else
		if type(a) == t then
			metType = true;
		end
	end
	
	if metType == false then
		if m == nil then
			m = m or 'Invalid type: Expected ';
			if type(t) == 'table' and #t > 1 then
				m = m..'[';
				for i, v in pairs(t) do
					m = m..'"'..v..'" | ';
				end
				m = string.sub(m, 0,-4);
				m = m..']';
			else
				m = m..'"'..(type(t) == 'string' and t or t[1])..'"';
			end
			local t = type(a);
			if type(a) == 'userdata' and fw.isObject then
				t = (a.getLibrary() and a.getLibrary()..'::' or '')..a.ClassName;
			end
			m = m..', got "'..t..'".';	
		end
		if r == 'error' then
			fw.verifyarg(l, 'number', error, nil, 2);
			l = l or 2;
			l = (l <= 1 and l ~= 0) and l + 1 or l == 0 and 0 or l;
			error(m, l);
		elseif r == 'warn' then
			warn(m);
		end	
	end
	
	return metType;
end

fw.isvalue = fw.Memoize(function(val, match, callback, ...)
	fw.verifyarg(match, 'table', error, nil, 2);
	for i, v in pairs(match) do
		if v == val then
			if callback ~= nil then
				fw.verifyarg(callback, 'function', error, nil, 2);
				callback(val, ...);
			end
			return true;
		end
	end
	return false;
end)

fw.verifymember = function(obj, member)
	if fw.verifyarg(obj, {'Instance', 'table', 'userdata'}, error, nil, 2) then
		
	end
end

for i, v in pairs(love.filesystem.getDirectoryItems('OBJECT LIBRARY/Modules')) do
	if string.find(v, '.lua') then
		require('OBJECT LIBRARY/Modules/'..string.gsub(v, '.lua', ''));
	end
end

require('OBJECT LIBRARY/initEngine');

fw.Loaded:Fire();

getfenv().Instance = fw;

return fw;
