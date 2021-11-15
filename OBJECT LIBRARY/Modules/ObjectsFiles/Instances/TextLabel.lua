local fw = _G.Framework;
if fw == nil then return false end;

local reg = fw.new.Register('TextLabel');
reg.Library = "BUILTIN::GuiObject";
reg.Inherits 'BUILTIN::Frame';

reg.Constructor = function(obj, con)
    con.Text = "TextLabel";
    con.Text.Whitelist();

    con.TextColor = Instance.new('BUILTIN::RGB');
    con.TextColor.Locked = true;

    con.Font = nil;
    con.Font.Hidden = true;
end