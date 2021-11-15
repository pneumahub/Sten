require('Classes')

function gameMainTaskLoop(maxCallsPerSecond,eventFunct)
	local deltaTime=0
	local elapsedTime=0
	-- sorry but os.time return seconds not ms as would be more appropiate
	local newTime = love.timer.getTime();
	deltaTime, elapsedTime = newTime-elapsedTime, newTime
	if (deltaTime>(maxCallsPerSecond/60)) then
		eventFunct(deltaTime)
	end
	callsPerSecond = deltaTime/60
	return deltaTime, elapsedTime, callsPerSecond
end

while(Instance.Engine.Running) do 
    repeat love.timer.sleep(0) until Instance.Engine.Paused == false
    local sleepTime = 0
    dt,_,ups = gameMainTaskLoop(Instance.Engine.MAX_UPDATE, Instance.Engine.ManualMessage)
    sleepTime = (Instance.Engine.MAX_UPDATE/60)-dt
    dt,_,tps = gameMainTaskLoop(Instance.Engine.MAX_TICK, Instance.Engine.ManualTick)
    sleepTime = math.min(sleepTime,(Instance.Engine.MAX_TICK/60)-dt)
    dt,_,fps = gameMainTaskLoop(Instance.Engine.MAX_FPS, Instance.Engine.ManualRender)
    sleepTime = math.min(sleepTime,(Instance.Engine.MAX_FPS/60)-dt)
    if love.timer then love.timer.sleep(math.max(0,sleepTime)) end
end