for i, v in pairs(love.filesystem.getDirectoryItems('Classes/FullList/DEBUGLIB')) do
	if string.find(v, '.lua') then
		require('Classes/FullList/DEBUGLIB/'..string.gsub(v, '.lua', ''));
	end
end

local w = Instance.new('DEBUG::Window');
w.Parent = game;
w.Size = UDim2.new(0, 100, 0, 100);
w.Color.R = 255;
--NOTE(Pneuma): Not rendering, will fix after I get off work