local fw = _G.Framework;
if fw == nil then return false end;
require "math"
require "os"

fw.Engine = {};

function love.load(arg)
	fw.Engine.Arguments = arg;
end

fw.Engine.Tick = fw.new('BUILTIN::Event');
fw.Engine.Render = fw.new('BUILTIN::Event');
fw.Engine.ClientMessage = fw.new('BUILTIN::Event');

fw.Engine.ClientWidth = 0;
fw.Engine.ClientHeight = 0;

fw.Engine.ManualRender = function(dt)
	if love.graphics and love.graphics.isActive() then
		love.graphics.origin()
		love.graphics.clear(love.graphics.getBackgroundColor())
		fw.Engine.Render:Fire(dt);

		if love.draw then love.draw() end

		love.graphics.present()
	end
end

fw.Engine.ManualTick = function(dt)
	if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
	fw.Engine.ClientWidth, fw.Engine.ClientHeight = love.window.getMode();
	fw.Engine.Tick:Fire(dt);
end

fw.Engine.ManualMessage = function()
	if love.event then
        love.event.pump();
        for name, a,b,c,d,e,f in love.event.poll() do
            if name == "quit" then
                if not love.quit or not love.quit() then
                    fw.Engine.ClientMessage:Fire(name,a,b,c,d,e,f);
                    fw.Engine.Running = false;
                end
            end
            fw.Engine.ClientMessage:Fire(name,a,b,c,d,e,f);
            love.handlers[name](a,b,c,d,e,f)
        end
    end
end

fw.Engine.Running = true;
fw.Engine.Paused = false;

fw.Engine.MAX_FPS=60
fw.Engine.MAX_UPDATE=30
fw.Engine.MAX_TICK=30

love.window.setMode(1200,600,{resizable = true});

return true;