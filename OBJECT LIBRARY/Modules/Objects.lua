local fw = _G.Framework;
if fw == nil then return false end;

local unique = tostring({});

fw.isObject = function(obj)
	if typeof(obj) == 'userdata' and getmetatable(obj).__getunique() == unique then
		return true
	end
	return false;
end

local stack = {};
local registry = {};

local getreg = fw.Memoize(function(classo, shouldErr)
	local split = string.split(classo, '::');

	local lib = #split > 1 and {} or nil;
	if lib then
		for i = 1, #split - 1, 1 do
			table.insert(lib, split[i]);
		end
	end
	local class = #split > 1 and split[#split] or split[1];

	local reg;
	for i = 1, #registry, 1 do
		local r = registry[i];
		local slib = false;
		if lib ~= nil then
			local lib2 = string.split(r.Library.Value and r.Library.Value or 'UNSORTED', '::');
			for i = 1, #lib, 1 do
				if lib2[i] == nil or lib[i] ~= lib2[i] then
					slib = false;
					break;
				else
					slib = true;
				end
			end
		else
			slib = true;
		end
		if slib and r.Class.Value == class then
			reg = r;
			break;
		end
	end

	if reg == nil and shouldErr then
		error('Invalid class: '..((lib ~= nil and lib.Library) and lib.Library.Value.."::" or "")..classo..' is not a valid registered class', 2);
	end
	return reg
end)

fw.isRegistered = function(class)
	if getreg(class) then
		return true;
	end
	return false;
end

local createobj;
createobj = function(reg)
	local interface = newproxy(true);
	local controller = newproxy(true);
	
	local class = reg and reg.Class and reg.Class.Value or "OBJECT";		
	
	local internal = {}

	local function createProperty(name, args)
		fw.verifyarg(name, 'string', error, nil, 2);
		fw.verifyarg(args, 'table', error, nil, 2);
		local tmp = {};
		local function v(index, t, r)
			if args[index] then
				tmp[index] = fw.verifyarg(args[index], t, 'warn') and args[index] or r;
			else
				tmp[index] = r;
			end
		end
		
		v('Whitelist', 'table', setmetatable(args.Whitelist or {}, {
			__call = function(tble, val)
				if val == nil then
					if fw.isObject(tmp.Value) then
						val = (tmp.Value.getLibrary() and tmp.Value.getLibrary()..'::' or '')..tmp.Value.ClassName;
					else
						val = typeof(tmp.Value);
					end
				end
				table.insert(tble, val);
			end	
		}));
		
		v('Hidden', 'boolean', false);
		v('Locked', 'boolean', false);
		v('Internal', 'boolean', false);
		v('Remove', 'function', function()
			if tmp['Internal'] == true then
				error('Cannot remove member: Member is internal', 2);
			end
			table.clear(tmp.Whitelist);
			table.clear(tmp);
			internal[name] = nil;
		end)
		v('Tags', 'table', setmetatable(args.Tags or {}, {
			__call = function(tble, val)
				table.insert(tble, val);
			end	
		}));

		tmp.Value = args.Value;
		
		internal[name] = tmp;
	end
	
	createProperty('ClassName', {Locked = true; Internal = true; Value = class});
	
	createProperty('Clone', {Locked = true; Internal = true; Value = function()
		if internal.__CloneCallback.Value ~= nil then
			local return_i, return_c = fw.new(class);
			internal.__CloneCallback.Value(return_i, return_c);
			return return_i;
		else
			error(class..' cannot be cloned.', 3);
		end
	end});
	
	createProperty('IsA', {Locked = true; Internal = true; Value = function(c)
		local checkreg;
		local cr = getreg(c);
		if cr == nil then return false end;
		if cr == reg then return true end;
		checkreg = function(r)
			for i = 1, #r.InheritRegs.Value, 1 do
				if r.InheritRegs.Value[i] == nil then goto continue end;
				if cr == r.InheritRegs.Value[i] then
					return true;
				end
				::continue::
			end
			for i = 1, #r.InheritRegs.Value, 1 do
				if r.InheritRegs.Value[i] == nil then goto continue end;
				if checkreg(r.InheritRegs.Value[i]) then
					return true;
				end
				::continue::
			end
			return false;
		end

		return checkreg(reg) or false;
	end});
	
	createProperty('Destroy', {Locked = true; Internal = true; Value = function()
		if internal.__DestroyCallback.Value ~= nil then
			internal.__DestroyCallback.Value();
		else
			error(class..' cannot be destroyed.', 3);
		end
	end});
	
	createProperty('getLibrary', {Locked = true; Internal = true; Value = function()
		return reg.Library.Value;
	end});
	
	createProperty('__DestroyCallback', {Hidden = true; Internal = true; Whitelist = {'function'}});
	createProperty('__index', {Hidden = true; Internal = true; Whitelist = {'function'}});
	createProperty('__newindex', {Hidden = true; Internal = true; Whitelist = {'function'}});
	createProperty('__call', {Hidden = true; Internal = true; Whitelist = {'function'}});
	
	getmetatable(interface).__index = function(tble, index)
		if internal[index] ~= nil and internal[index]['Hidden'] ~= true then
			return internal[index]['Value'];
		end
		if internal['__index'].Value ~= nil then
			return internal['__index'].Value(index);
		end
		if type(index) == 'number' then
			return safesearch(index);
		end
	end
	
	getmetatable(interface).__newindex = function(tble, index, new) 
		if internal[index] == nil or internal[index]['Hidden'] then
			if internal[index] == nil and internal['__newindex'].Value ~= nil then
				return internal['__newindex'].Value(index, new);
			end
			return error(tostring(index)..' is not a valid member of '..tostring(internal.ClassName.Value), 2);
		end
		
		if internal[index]['Locked'] then
			return error('Cannot modify '..index..': Member is locked.', 2);
		end
		
		if #internal[index]['Whitelist'] > 0 then
			fw.verifyarg(new, internal[index]['Whitelist'], 'error', nil, 3);
		end
		
		if internal[index]['Value'] == new then return end;
		
		internal[index]['Value'] = new;
				
		if internal['Changed'] then
			internal['Changed'].Value:Fire(index, new);
		end
		
		if internal[index]['Changed'] then
			internal[index]['Changed']:Fire();
		end
	end
	
	getmetatable(controller).__newindex = function(tble, index, new)
		
		if internal[index] == nil then
			if internal[index] == nil and internal['__newindex'].Value ~= nil then
				return internal['__newindex'].Value(index, new);
			end
			return createProperty(index, {Value = new});
		end
		if internal[index]['Internal'] and internal[index]['Locked'] then
			error('Cannot modify '..index..': Member is locked.', 2);
		end
		if internal[index]['Internal'] and #internal[index]['Whitelist'] > 0 then
			fw.verifyarg(new, internal[index]['Whitelist'], 'error', nil, 3);
		end
		
		if internal[index]['Value'] == new then return end;
		
		internal[index]['Value'] = new;
		
		if internal['Changed'] and internal[index]['Hidden'] == false then
			controller.Changed.Value:Fire(index, new);
		end
		
		if internal[index]['Changed'] then
			internal[index]['Changed']:Fire();
		end
	end
	
	getmetatable(controller).__index = function(tble, index)
		if internal[index] == nil then
			return;
		end
		return setmetatable({}, {
			__index = function(tble, i)
				if i == 'Changed' and internal[index]['Changed'] == nil then
					internal[index]['Changed'] = fw.new('BUILTIN::Event');
				end
				return internal[index][i];
			end,
			__newindex = function(tble, i, new)
				if internal[index][i] == nil and i ~= 'Value' then
					error(tostring(i)..' is not a valid Member setting', 2);
				end
				if (internal[index]['Internal'] == true and i ~= 'Value') or i == 'Changed' then
					error('Cannot modify '..index..'.'..i..': Member setting is locked.', 2);
				end
				if i ~= 'Value' then fw.verifyarg(new, typeof(internal[index][i]), nil, 2) end;
				internal[index][i] = new;
			end
		});
	end
	
	local function createOverload(name, func)
		getmetatable(interface)[name] = func;
		getmetatable(controller)[name] = func;
		createProperty(name, {Hidden = true; Internal = true; Whitelist = {'function'}; Value = nil});
	end
	
	createOverload('__getTypeof', function(self)
		return '<'..(self == interface and 'interface' or 'controller')..'> '..reg.Class.Value;
	end);
	
	createOverload('__call', function(self, ...)
		if internal['__call'].Value then
			return internal['__call'].Value(...);
		else
			error('Attempt to call a userdata value', 2);
		end
	end);

	createOverload('__pairs', function(self)
		if internal['__pairs'].Value then return internal['__pairs'].Value(self) end;
		if self == interface then return function(_, k)
			local v
			repeat
				k, v = next(internal, k)
			until k == nil or v.Hidden == false
				return k, v.Value
		end, t, nil end

		if self == controller then return function(_, k)
			local v
			repeat
				k, v = next(internal, k)
			until k == nil or v.Hidden == false
				return k, v.Value
		end, t, nil end
	end);
		
	return interface, controller;
end

local function initObj(lib)

	local obj_i, obj_c = createobj(lib);
	table.insert(stack, obj_i);
	table.insert(stack, obj_c);
	
	getmetatable(obj_i).__getunique = function()
		return unique;
	end
	getmetatable(obj_c).__getunique = function()
		return unique;
	end
	
	local link = tostring({});
	getmetatable(obj_i).__getLink = function()
		return link;
	end
	getmetatable(obj_c).__getLink = function()
		return link;
	end
	
	return obj_i, obj_c;
end

local restrictedLibs = {};

local inherit;
inherit = function(t,c,rh, ...)
	local rv = typeof(rh) == 'table' and rh or rh.InheritList.Value;
	for i = 1, #rv, 1 do
		local r = getreg(rv[i]);
		if r then
			print(type(rh))
			if type(rh) == 'Object' then
				rh.InheritRegs.Value[i] = r;
			end
			if r.Constructor.Value == nil then
				error('No constructor set for '..(r.Library.Value ~= nil and r.Library.Value.."::" or "")..r.ClassName.Value, 3);
			end
			inherit(t,c,r, ...);
			r.Constructor.Value(t, c, ...);
		end
	end
end

local newFunctions = {
	Extension = function(extensionName, props)
		--TODO(Pneuma): Coming soon
	end,
	Inherit = function(lib, ...)
		fw.verifyarg(lib, {'table', 'string'}, error, nil, 2);
		lib = typeof(lib) == 'table' and lib or {lib};
		local io, ic = fw.new();
		inherit(io, ic, lib, ...);
		return io;
	end,
	Register = function(classname)
		local t_obj, t_con = initObj(classname, 'BUILTIN');
		t_con.InheritList = {};
		t_con.InheritList.Hidden = true;
		
		t_con.Inherits = function(val)
			fw.verifyarg(val, 'string', 'error', nil, 2);
			table.insert(t_con.InheritList.Value, val);
		end;
		t_con.Inherits.Locked = true;
		
		t_con.InheritOnly = false;
		t_con.InheritOnly.Whitelist();
		
		t_con.Library = nil;
		t_con.Library.Whitelist();
		t_con.Library.Whitelist('string');
		
		t_con.Class = classname;
		t_con.Class.Locked = true;
		
		t_con.InheritRegs = {};
		t_con.InheritRegs.Hidden = true;
		
		getmetatable(t_obj).__len = function() 
			local amt = 0;
			for i = 1, #registry do
				local v = registry[i];
				if v.Class.Value == t_con.Class.Value then
					amt = amt + 1;
				end
			end
			return amt;
		end

		local prevIndex = getmetatable(t_obj).__newindex;
		getmetatable(t_obj).__newindex = function(tble, index, new)
			if index == "Library" and new ~= nil then
				fw.verifyarg(new, 'string', error, nil, 2);
				
				-- It is not recommended to remove this line of code to lift the BUILTIN or PneumaLib restriction for yourself.
				-- It will be readded every update automatically.
				-- If wish to lift it without it being replaced, use "SET_LIBRARY_LOCK(false)" in the command bar.
				if table.find(restrictedLibs, string.split(new, '::')[1]) then
					error('Cannot assign Object '..classname..' to Library '..new..': LIBRARY IS RESTRICTED.', 2);
				end
				local r = getreg((new and new..'::' or '')..classname);
				if r ~= nil and new ~= 'UNSORTED' and r ~= t_con then
					print((new and new..'::' or '')..classname)
					error('Cannot assign Object '..classname..' to Library '..new..': LIBRARY ALREADY CONTAINS CLASS.', 2);
				end
			end
			prevIndex(tble, index, new);
		end
		
		t_con.Constructor = nil;
		t_con.Constructor.Whitelist('function');
		table.insert(registry, t_con);
		return t_obj;
	end
};

fw.new = newproxy(true);
getmetatable(fw.new).__call = function(self, class, ...)
	if class == nil then
		return initObj();
	end
	
	local reg = getreg(class, true);
	
	if reg.InheritOnly.Value then
		error((reg.Library.Value ~= nil and reg.Library.Value.."::" or "")..reg.ClassName.Value..' cannot be instantiated, it must be inherited', 2);
	end
	
	local t_obj, t_con = initObj(reg);
	
	-------------------------------------------------------------------------------
	--- Built in events
	-------------------------------------------------------------------------------
	do --Changed
		local e = getreg('BUILTIN::Event');
		local o, c = initObj('BUILTIN::Event');
		getfenv(e.Constructor.Value).self = o;
		e.Constructor.Value(o,c);
		t_con.Changed = o;
		t_con.Changed.Locked = true;
	end
	
	-------------------------------------------------------------------------------
	--- Constructors
	-------------------------------------------------------------------------------

	inherit(t_obj, t_con, reg, ...);
	-- Base 
	if reg.Constructor.Value == nil then
		error('No constructor set for '..(reg.Library.Value ~= nil and reg.Library.Value.."::" or "")..reg.ClassName.Value, 3);
	end
	getfenv(reg.Constructor.Value).self = t_obj;
	reg.Constructor.Value(t_obj, t_con, ...);
	
	return t_obj;
end

getmetatable(fw.new).__index = function(tble, index)
	return newFunctions[index];
end

for i, v in pairs(love.filesystem.getDirectoryItems('OBJECT LIBRARY/Modules/ObjectsFiles')) do
	if string.find(v, '.lua') then
		require('OBJECT LIBRARY/Modules/ObjectsFiles/'..string.gsub(v, '.lua', ''));
	end
end

fw.Loaded = fw.new('BUILTIN::Event');

fw.Loaded:Connect(function()
	table.insert(restrictedLibs, 'BUILTIN');
	table.insert(restrictedLibs, 'UNSORTED');
end)

return true;
