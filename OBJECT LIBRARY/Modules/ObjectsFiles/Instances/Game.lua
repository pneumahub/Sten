local fw = _G.Framework;
if fw == nil then return false end;

local reg = fw.new.Register('Game');
reg.Library = "BUILTIN";
reg.Inherits "BUILTIN::Instance"

reg.Constructor = function(obj, con)
    obj.Name = 'Game';

    con.Parent = nil;
    con.Parent.Locked = true;

    con.Render = fw.new('BUILTIN::Event');
    con.Render.Locked = true;

    con.Tick = fw.new('BUILTIN::Event');
    con.Tick.Locked = true;

    con.Mouse = fw.new('BUILTIN::Mouse');
    con.Mouse.Locked = true;

    con.Tick.Value:Connect(function(...)
        obj.Mouse.Tick(...);
        local c = obj:GetChildren();
        for i = 1, #obj:GetChildren() do
            c[i].Tick(...);
        end
    end)

    con.Render.Value:Connect(function(...)
        local c = obj:GetChildren();
        for i = 1, #obj:GetChildren() do
            c[i].Render(...);
        end
    end)
    
    fw.Love.Render:Connect(con.Render.Value.Fire());
    fw.Love.Tick:Connect(con.Tick.Value.Fire());
end

return true;