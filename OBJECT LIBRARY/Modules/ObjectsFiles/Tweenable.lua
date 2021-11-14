local fw = _G.Framework;
if fw == nil then return false end;

local reg = fw.new.Register('TweenStyle');
reg.Library = 'BUILTIN';

reg.Constructor = function(obj, con)

    con.Tween = function()

    end
    con.Tween.Locked = true;

end

fw.new.Register('TweenSettings');
reg.Library = 'BUILTIN';

reg.Constructor = function(obj, con)

    con.Style = Tween.Style.Sine;
    con.Style.Whitelist();

    con.Members = {};
    con.Members.Whitelist();

    
end

local step = function(self, dt)

end

fw.new.Register('Tweenable');
reg.Library = 'BUILTIN';
reg.InheritOnly = true;

reg.Constructor = function(obj, con)
    con.Interpolate = function(dt)

    end
    con.Tween.Locked = true;
end

local to, tc = fw.new();
tc.__call = function(tween, ...)
    fw.verifyarg(tween, 'BUILTIN::Tweenable', error)
    local Members, Style, Time, Speed, Override, Callback = table.unpack({...});
    
    if typeof(Members) == 'Object' and Members:IsA('BUILTIN::TweenSettings') then
        local ts = Members;
        Members = ts.Members;
        Style = ts.Style;
        Time = ts.Time;
        Speed = ts.Speed;
        Override = ts.Override;
        Callback = ts.Callback;
    elseif type(Members) == 'Table' then
        local ts = Members;
        Members = ts.Members;
        Style = ts.Style;
        Time = ts.Time;
        Speed = ts.Speed;
        Override = ts.Override;
        Callback = ts.Callback;
    end

    Members = fw.verifyarg(Members, 'table', print) and Members or {};
    Style = fw.verifyarg(Style, 'BUILTIN::TweenStyle', print) and Style or Tween.Style.Sine;
    Time = fw.verifyarg(Time, 'number', print) and Time or 1;
    Speed = fw.verifyarg(Speed, 'number', print) and Speed or 1;
    Override = fw.verifyarg(Override, 'boolean', print) and Override or true;
    
    local connection;
    connection = fw.Engine.Tick:Connect(function(dt)
    end)
end

tc.Style = {};
tc.Style.Locked = true;

getfenv().Tween = to