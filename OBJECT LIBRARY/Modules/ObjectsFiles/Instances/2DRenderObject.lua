local fw = _G.Framework;
if fw == nil then return false end;

local reg = fw.new.Register('2DRenderObject');
reg.Library = "BUILTIN";
reg.Inherits 'BUILTIN::Instance';

reg.Constructor = function(obj, con)
    con.Bounds = fw.new('BUILTIN::2DPolygon');
    con.Bounds.Whitelist();

    con.Visible = true;
    con.Visible.Whitelist();

    con.Color = fw.new('BUILTIN::RGB');
    con.Color.Whitelist();

    local oldRender = obj.Render;
    con.Render = function(...)
        local p = table.clone(obj.Bounds);
        if #p >= 3 then
            love.graphics.setColor(obj.Color.R/255, obj.Color.G/255, obj.Color.B/255, obj.Color.A);
            love.graphics.polygon('fill', table.unpack(table.unpack(p)));
        end

        oldRender(...);
    end
end

return true;