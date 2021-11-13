local fw = _G.Framework;
if fw == nil then return false end;

local reg = fw.new.Register('UDim');
reg.Library = "BUILTIN::Datatypes";

reg.Constructor = function(obj, con, scale, offset)
    con.Scale = scale or 0;
    con.Scale.Locked = true;

    con.Offset = offset or 0;
    con.Offset.Locked = true;
end

local reg = fw.new.Register('UDim2');
reg.Library = "BUILTIN::Datatypes";

reg.Constructor = function(obj, con, xs, xo, ys, yo)
    con.X = fw.new('BUILTIN::UDim', xs, xo);
    con.X.Locked = true;
    con.Y = fw.new('BUILTIN::UDim', ys, yo);
    con.Y.Locked = true;
end

local reg = fw.new.Register('Vector2');
reg.Library = "BUILTIN::Datatypes";

reg.Constructor = function(obj, con, x, y)
    con.X = x or 0;
    con.X.Locked = true;

    con.Y = y or 0;
    con.Y.Locked = true;
end

reg = fw.new.Register('2DPolygon');
reg.Library = "BUILTIN::Datatypes";

reg.Constructor = function(obj, con)
    local polygon = {};
    con.getPoints = function()
        return table.clone(polygon);
    end

    con.clearPoints = function()
        for i = #polygon, 1, -1 do
            polygon[i] = nil;
        end
    end

    con.addPoint = function(p)
        table.insert(polygon, p);
    end
end

local reg = fw.new.Register('RGB');
reg.Library = "BUILTIN::Datatypes";

reg.Constructor = function(obj, con, r, g, b)
    local function l(i, v)
        con[i] = v or 0;
        con[i].Whitelist();
    end

    con.R = r or 0;
    con.R.Whitelist();

    con.G = g or 0;
    con.G.Whitelist();

    con.B = b or 0;
    con.B.Whitelist();

    con.A = 1;
    con.A.Whitelist();
end

return true;