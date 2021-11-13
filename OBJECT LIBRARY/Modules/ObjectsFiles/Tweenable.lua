local fw = _G.Framework;
if fw == nil then return false end;

local reg = fw.new.Register('TweenEase');
reg.Library = 'BUILTIN';
reg.InheritOnly = true;

reg.Constructor = function(obj, con)

    con.Tween = function()

    end
    con.Tween.Locked = true;

end

fw.new.Register('TweenSettings');
reg.Library = 'BUILTIN';

reg.Constructor = function(obj, con)

    con.Direction = 'Sine';
    

end

local step = function(self, dt)

end

fw.new.Register('Tweenable');
reg.Library = 'BUILTIN';
reg.InheritOnly = true;

reg.Constructor = function(obj, con)
    local tick = fw.Love.Tick;

    con.Interpolate = function(dt)

    end
    con.Tween.Locked = true;

end

local to, tc = fw.new()
tc.__call = function(self, ...)
    --Members <table>
    --Ease <BUILTIN::TweenStyle.Direction>
    --Time <number>
    --Speed <number> (-0 : UNKNOWN) (0-1 : SLOWED DOWN) (1+ : SPEED UP)
    --Override <boolean> -- Whether or not to interrupt any tweens interpolating the same members.
        -- EXAMPLE:
        --[Previous]   [Override]
        -- Tween1       Tween2 
        -- Size         Size        -- The only change is Tween1 will no longer modify Size
        -- Background               -- Background will continue to tween.
        -- NOTE(Pneuma): Potentially may allow for a function. A table of the running properties will be passed 
        --               and the caller can control the overrides
    --Callback 
    local arg1, arg2, arg3, arg4, arg5 = table.unpack({...});

end

tc.Style = {};
tc.Style.Locked = true;

getfenv().Tween = to