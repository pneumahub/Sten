local fw = _G.Framework;
if fw == nil then return false end;

local reg = fw.new.Register('Event');
reg.Library = "BUILTIN::Datatypes";

reg.Constructor = function(object, control)
	
	local connected = {};
	control.Connect = function(self, fun)
		if self ~= object and self ~= control then
			error("Expected ':' not '.' calling member function Connect", 2);
		end
		if connected == nil then
			return;
		end
		fw.verifyarg(fun, 'function', error, nil, 2);
		table.insert(connected, fun);
		local con, con_c = fw.new();
		con_c.Connected = true;
		con_c.Connected.Locked = true;
		
		con_c.Disconnect = function(self)
			if self ~= con and self ~= con_c then
				error("Expected ':' not '.' calling member function Disconnect", 2);
			end
			if con.Connected == false then
				return;
			end
			table.remove(connected, table.find(connected, fun));
			con_c.Connected = false;
		end
		
		return con;
	end
	control.Connect.Locked = true;
	local waiting = {};
	control.Fire = function(self, ...)
		if self ~= object and self ~= control then
			return function(...) object:Fire(...) end
		end
		if connected == nil then return end;
		
		for i = 1, #connected do
			local success, response = pcall(connected[i]);
			if success == false then
				coroutine.wrap(error)(response, -1);
			end
		end
	end
	control.Fire.Locked = true;
	
	control.__DestroyCallback = function()
		if connected == nil then return end
		for i = #connected, 1, -1 do
			connected[i] = nil;
		end
		for i = 1, #waiting, -1 do
			waiting[i] = nil;
		end
		connected = nil;
		object = nil;
		control = nil;
	end
end
return true;
