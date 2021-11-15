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

reg.Constructor = function(obj, con, ...)
    local polygon = {};
    local args = {...};
    for i = 1, #args do
        local v = args[i];
        if type(v) == 'number' then
            local v2 = args[i + 1];
            
            table.insert(polygon, v);
            table.insert(polygon, type(v2) == 'number' and v2 or 0);
            
            if type(v2) == 'number' then
                i=i+1;
            end
            goto continue;
        end

        if type(v) == 'table' then
            local x,y = v[1] or v.X or v.x or 0, v[2] or v.Y or v.y or 0
            table.insert(polygon, type(x) == 'number' and x or 0);
            table.insert(polygon, type(y) == 'number' and y or 0);
        end

        ::continue::
    end

    con.__pairs = function(t)
        local k = 0;
        return function()
            if #polygon == 0 then return end;
            k = k + 1;
            return k ~= #polygon/2 + 1 and k or nil, obj[k];
		end, t, nil
    end

    con.__len = function()
        return #polygon / 2;
    end

    con.__index = function(index)
        if type(index) ~= 'number' then return end;
        return {polygon[(index*2)-1], polygon[index*2]};
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

local reg = fw.new.Register('Font');
reg.Library = "BUILTIN::Datatypes";

reg.Constructor = function(obj, con, path)
    local OBJECT = love.graphics.newFont(path);

    con.getAscent = OBJECT.getAscent;
    con.getAscent.Locked = true;

    con.getBaseline = OBJECT.getBaseline;
    con.getBaseline.Locked = true;
    
    con.getDPIScale = OBJECT.getDPIScale;
    con.getDPIScale.Locked = true;

    con.getDescent = OBJECT.getDescent;
    con.getDescent.Locked = true;

    con.getFilter = OBJECT.getFilter;
    con.getFilter.Locked = true;

    con.getHeight = OBJECT.getHeight;
    con.getHeight.Locked = true;

    con.getLineHeight = OBJECT.getLineHeight;
    con.getLineHeight.Locked = true;

    con.getWidth = OBJECT.getWidth;
    con.getWidth.Locked = true;

    con.getWrap = OBJECT.getWrap;
    con.getWrap.Locked = true;

    con.hasGlyphs = OBJECT.hasGlyphs;
    con.hasGlyphs.Locked = true;

    con.setFallbacks = OBJECT.setFallbacks;
    con.setFallbacks.Locked = true;

    con.setFilter = OBJECT.setFilter;
    con.setFilter.Locked = true;

    con.setLineHeight = OBJECT.setLineHeight;
    con.setLineHeight.Locked = true;

    local oldCb = con.__DestroyCallback.Value;
    con.__DestroyCallback = function()
        OBJECT:release();
        for i, v in pairs(con) do
            v.Changed:Destroy();
        end
        oldCb();
    end
end

return true;