------------------------------------------------------------------------------------------------
--- TOOLBELT
------------------------------------------------------------------------------------------------
-- NOTE(Pneuma): 

local fw = _G.Framework;
if fw == nil then return false end;

local reg = fw.new.Register('Toolbelt');
reg.Library = 'BUILTIN';

reg.Constructor = function(obj, con)

end 

return true;