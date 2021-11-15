local fw = _G.Framework;
if fw == nil then return false end;

local reg = fw.new.Register('Game');
reg.Library = "BUILTIN";
reg.Inherits "BUILTIN::Instance"

reg.Constructor = function(obj, con)
    local oRender = con.Render.Value;
    local oTick = con.Tick.Value
    local oClientMessage = con.ClientMessage.Value;

    con.Parent = nil;
    con.Parent.Locked = true;

    con.Render = fw.new('BUILTIN::Event');
    con.Render.Locked = true;

    con.Tick = fw.new('BUILTIN::Event');
    con.Tick.Locked = true;

    con.ClientMessage = fw.new('BUILTIN::Event');
    con.ClientMessage.Locked = true;

    con.Mouse = fw.new('BUILTIN::Mouse');
    con.Mouse.Locked = true;

    con.Input = fw.new('BUILTIN::Input');
    con.Input.Locked = true;

    con.Tick.Value:Connect(function(...)
        obj.Mouse.Tick(...);
        oTick(...);
    end)

    con.Render.Value:Connect(oRender);
    con.ClientMessage.Value:Connect(oClientMessage)

    con.WindowWidth = 0;
    con.WindowWidth.Locked = true;

    con.WindowHeight = 0;
    con.WindowHeight.Locked = true;

    fw.Engine.ClientMessage:Connect(con.ClientMessage.Value:Fire());
    fw.Engine.Render:Connect(con.Render.Value.Fire());
    fw.Engine.Tick:Connect(con.Tick.Value.Fire());
end

return true;