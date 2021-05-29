local Class = {}
Class.__index = Class
Class.__type = "Class"

function typeOf(obj)
  if type(obj) == "table" and obj.__type then
    return obj.__type
  else
    return type(obj)
  end
end

function Class:type()
  return typeOf(self)
end

function Class:typeOf(name)
  if name == typeOf(self) then
    return true
  elseif getmetatable(self) then
    return getmetatable(self):typeOf(name)
  else
    return false
  end
end

function Class:new(name)
  assert(name, "Classes must be given a name.")

  local cls = {}

  Class.extend(cls, Class)
  cls.__type = name

  return cls
end

function Class.extend(obj, super)
  setmetatable(obj, super)
  super.__index = super

  return obj
end

return Class
