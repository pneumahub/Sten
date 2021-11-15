local reg = Instance.new.Register('Window');
reg.Library = "DEBUG";
reg.Inherits "BUILTIN::Frame";

reg.Constructor = function(obj, con)
    obj.Color.R = 12;
    obj.Color.B = 12;
    obj.Color.G = 12;

    obj.Size = UDim2.new(0,400,0,300);
end