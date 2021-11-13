local fw = _G.Framework;
if fw == nil then return false end;

local reg = fw.new.Register('Instance');
reg.Library = "BUILTIN::Datatypes";
reg.InheritOnly = true;

reg.Constructor = function(obj, con)
    local function p(name, val)
        con[name] = val;
        con[name].Whitelist();
    end

    local function l(name, val)
        con[name] = val;
        con[name].Locked = true;
    end

    local children = setmetatable({}, {__index = function(self, index)
        for i = 1, #self do
            local i = rawget(self, i);
            if i.Name == index then return i end;
        end
    end});

    -------------------------------------------------------------------------------------------------------------------------
    --- Properties
    -------------------------------------------------------------------------------------------------------------------------
    p('Name', 'Instance');
    
    local pp = nil;
    p('Parent', nil);
    con.Parent.Whitelist();
    con.Parent.Whitelist('BUILTIN::Instance');
    con.Parent.Changed:Connect(function()
        if pp ~= nil then
            pp:RemoveChild(obj);
        end
        if obj.Parent ~= nil then 
            obj.Parent:AddChild(obj);
        end
        pp = obj.Parent;
    end)

    -------------------------------------------------------------------------------------------------------------------------
    --- Functions
    -------------------------------------------------------------------------------------------------------------------------
    l('GetChildren', function(self)
        return table.clone(children);
    end)

    l('AddChild', function(self, inst)
        fw.verifyarg(inst, 'BUILTIN::Instance', error, nil, 2);
        table.insert(children, inst);
        obj.ChildAdded:Fire(obj);
    end)

    l('RemoveChild', function(self, inst)
        fw.verifyarg(inst, 'BUILTIN::Instance', error, nil, 2);
        pp.ChildRemoving:Fire(obj);
        table.remove(children, table.find(children, inst));
        pp.ChildRemoved:Fire(obj);
    end)

    -------------------------------------------------------------------------------------------------------------------------
    --- Events
    -------------------------------------------------------------------------------------------------------------------------
    l('ChildAdded', fw.new('BUILTIN::Event'));
    l('ChildRemoving', fw.new('BUILTIN::Event'));
    l('ChildRemoved', fw.new('BUILTIN::Event'));

    l('DescendantAdded', fw.new('BUILTIN::Event'));
    l('DescendantRemoving', fw.new('BUILTIN::Event'));
    l('DescendantRemoved', fw.new('BUILTIN::Event'));

    l('GetPropertyChangedSignal', function(index)
        if con[index] == nil then return nil end
        return con[index].Changed.Connect;
    end);

    con.Tick = function(...)
        local c = obj:GetChildren();
        for i = 1, #c do
            c[i].Tick(...);
        end
    end;
    con.Tick.Locked = true;

    con.Render = function(...)
        local c = obj:GetChildren();
        for i = 1, #c do
            c[i].Render(...);
        end
    end;
    con.Render.Locked = true;

    con.__index = function(index)
        return children[index];
    end
    --TODO(Pneuma): Finish callbacks
end

for i, v in pairs(love.filesystem.getDirectoryItems('OBJECT LIBRARY/Modules/ObjectsFiles/Instances')) do
	if string.find(v, '.lua') then
		require('OBJECT LIBRARY/Modules/ObjectsFiles/Instances/'..string.gsub(v, '.lua', ''));
	end
end