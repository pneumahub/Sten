local fw = _G.Framework;
if fw == nil then return false end;

local reg = fw.new.Register('Mouse');
reg.Library = "BUILTIN::Input";

reg.Constructor = function(obj, con)
    con.Confined = false;
    con.Confined.Whitelist();

    con.Visible = true;
    con.Visible.Whitelist();

    con.RelativeMode = love.mouse.getRelativeMode();
    con.RelativeMode.Whitelist();

    con.X = love.mouse.getX();
    con.X.Locked = true;

    con.Y = love.mouse.getY();
    con.Y.Locked = true;

    con.Move = fw.new('BUILTIN::Event');
    con.Move.Locked = true;

    local previous = {};
    local function changed(prop, val)
        if previous[prop] == val then
            return false
        end
        previous[prop] = val;
        return true;
    end

    con.Enabled = true;
    con.Enabled.Whitelist();

    con.Tick = function(...)
        if obj.Enabled == false then return end;
        if changed('MouseX', love.mouse.getX()) then
            con.X = love.mouse.getX();
            obj.Move:Fire(obj.X, obj.Y);
        end
        if changed('MouseY', love.mouse.getY()) then
            con.Y = love.mouse.getY();
            obj.Move:Fire(obj.X, obj.Y);
        end
    end
    con.Tick.Locked = true;
end

return true;