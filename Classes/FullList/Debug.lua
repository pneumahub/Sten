for i, v in pairs(love.filesystem.getDirectoryItems('Classes/FullList/DEBUGLIB')) do
	if string.find(v, '.lua') then
		require('Classes/FullList/DEBUGLIB/'..string.gsub(v, '.lua', ''));
	end
end
Instance.Debug = Instance.new('BUILTIN::Game');
Instance.Debug.Name = 'Debug';

local testing = Instance.new('Window');
testing.Parent = Instance.Debug;
testing.Size = UDim2.new(0.7,0,0.7);
testing.Color.R = 255;
testing.Color.G = 255;