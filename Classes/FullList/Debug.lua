getfenv().game = Instance.new('BUILTIN::Game');

local explorer = Instance.new('BUILTIN::Frame');
explorer.Size = Instance.new('BUILTIN::UDim2', 0, 200, 1, 0);
explorer.Parent = game;

explorer.Color.R = 20
explorer.Color.G = 20
explorer.Color.B = 20

explorer.Position = Instance.new('BUILTIN::UDim2', 1, 0);
explorer.AnchorPoint = Instance.new('BUILTIN::Vector2', 1,0);

local explorerTopbar = Instance.new('BUILTIN::Frame');
explorerTopbar.Parent = explorer;
explorerTopbar.Size = Instance.new('BUILTIN::UDim2', 1,0,0,30);

explorerTopbar.Color.R = 255;
explorerTopbar.Color.G = 255;
explorerTopbar.Color.B = 255;

--NOTE(Pneuma): Not rendering, will fix after I get off work