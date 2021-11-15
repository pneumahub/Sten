local fw = _G.Framework;
if fw == nil then return false end;

local reg = fw.new.Register('Frame');
reg.Library = "BUILTIN::GuiObject";
reg.Inherits 'BUILTIN::2DRenderObject';

reg.Constructor = function(obj, con)
    con.AnchorPoint = fw.new('BUILTIN::Vector2');
    con.AnchorPoint.Whitelist();

    con.Size = fw.new('BUILTIN::UDim2');
    con.Size.Whitelist();

    con.Position = fw.new('BUILTIN::UDim2');
    con.Position.Whitelist();

    con.AbsolutePosition = fw.new('BUILTIN::Vector2');
    con.AbsolutePosition.Locked = true;
    
    con.AbsoluteSize = fw.new('BUILTIN::Vector2');
    con.AbsoluteSize.Locked = true;

    local function updatePoints()
        con.Bounds = Instance.new('2DPolygon',
                                    {X = obj.AbsolutePosition.X, Y = obj.AbsolutePosition.Y},
                                    {X = obj.AbsolutePosition.X + obj.AbsoluteSize.X, Y = obj.AbsolutePosition.Y},
                                    {X = obj.AbsolutePosition.X + obj.AbsoluteSize.X, Y = obj.AbsolutePosition.Y + obj.AbsoluteSize.Y},
                                    {X = obj.AbsolutePosition.X, Y = obj.AbsolutePosition.Y + obj.AbsoluteSize.Y});
    end

    local function updateAbs()
        local p = obj.Parent or {};
        local parentp = p.AbsolutePosition or fw.new('BUILTIN::Vector2');
        local parents = p.AbsoluteSize or fw.new('BUILTIN::Vector2', love.graphics.getWidth(), love.graphics.getHeight());

        con.AbsoluteSize = fw.new('BUILTIN::Vector2', 
            (parents.X * obj.Size.X.Scale) + obj.Size.X.Offset, 
            (parents.Y * obj.Size.Y.Scale) + obj.Size.Y.Offset);
        con.AbsolutePosition = fw.new('BUILTIN::Vector2', 
            parentp.X + (parents.X * obj.Position.X.Scale) + obj.Position.X.Offset - (obj.AbsoluteSize.X * obj.AnchorPoint.X),
            parentp.Y + (parents.Y * obj.Position.Y.Scale) + obj.Position.Y.Offset - (obj.AbsoluteSize.Y * obj.AnchorPoint.Y));
        
        local c = obj:GetChildren();
        for i = 1, #c do
            if c[i].UpdateAbsoluteValues then
                c[i].UpdateAbsoluteValues();
            end
        end
    end

    con.AnchorPoint.Changed:Connect(updateAbs);
    con.Position.Changed:Connect(updateAbs);
    con.Size.Changed:Connect(updateAbs);

    con.AbsoluteSize.Changed:Connect(updatePoints);
    con.AbsolutePosition.Changed:Connect(updatePoints);

    local oldTick = con.Tick.Value;
    con.Tick.Value = function(...)
        updateAbs();
        oldTick(...);
    end

    con.UpdateAbsoluteValues = updateAbs;
    con.UpdateAbsoluteValues.Locked = true;
end

return true;