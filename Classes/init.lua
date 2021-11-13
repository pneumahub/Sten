require('OBJECT LIBRARY');

getfenv().game = Instance.new('Game');

for i, v in pairs(love.filesystem.getDirectoryItems('Classes/FullList')) do
	if string.find(v, '.lua') then
		require('Classes/FullList/'..string.gsub(v, '.lua', ''));
	end
end
