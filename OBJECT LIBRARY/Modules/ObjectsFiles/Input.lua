local fw = _G.Framework;
if fw == nil then return false end;

local reg = fw.new.Register('Input');
reg.Library = "BUILTIN::Input";

local MousePressed = fw.new('BUILTIN::Event');
local MouseReleased = fw.new('BUILTIN::Event');
local KeyPressed = fw.new('BUILTIN::Event');
local KeyReleased = fw.new('BUILTIN::Event');
local TextInput = fw.new('BUILTIN::Event');

love.keypressed = function(...)
   KeyPressed:Fire(...);
end
 
love.keyreleased = function(...)
    KeyReleased:Fire(...);
end

love.mousepressed = function(...)
    MousePressed:Fire(...);
end

love.mousereleased = function(...)
    MouseReleased:Fire(...);
end

love.textinput = function(...)
    TextInput:Fire(...);
end

reg.Constructor = function(obj, con)
    con.KeyPressed = KeyPressed;
    con.KeyPressed.Locked = true;

    con.KeyReleased = KeyReleased;
    con.KeyReleased.Locked = true;

    con.MousePressed = MousePressed;
    con.MousePressed.Locked = true;

    con.MouseReleased = MouseReleased;
    con.MouseReleased.Locked = true;

    con.TextInput = TextInput
    con.TextInput.Locked = true;
    
    con.TextInputEnabled = love.keyboard.hasTextInput;
    con.TextInputEnabled.Whitelist();
    con.TextInputEnabled.Changed:Connect(function()
        love.keyboard.setTextInput(obj.TextInput);
    end)
end