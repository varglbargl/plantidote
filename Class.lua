local Class = {}
Class.__index = Class

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
  return name == typeOf(self)
end

function Class:new(name)
  assert(name, "Classes must be given a name.")

  local cls = {}
  setmetatable(cls, self)
  self.__index = self
  cls.__type = name
  return cls
end

return Class
