local have_lrocks, lrocks = pcall(require,"luarocks.loader")
local have_socket, socket = pcall(require,"socket")
local modname = ...
local M = {}
_G[modname] = M
package.loaded[modname] = M
local mt = {}

local ffi = require("ffi")
ffi.cdef[[
  int poll(struct pollfd *fds, unsigned long nfds, int timeout);
]]
M.sleep = function(seconds)
  ffi.C.poll(nil, 0, seconds * 1000)
end

M.printtable = function(t, str)
  local str = str or string.format("printing table %p", t)
  print(str)
  if not t then return end
  table.foreach(t, print)
end

M.copytable = function(table)
  local copy = {}
  for k,v in pairs(table) do
    copy[k] = v
  end
  return copy
end


M.printcdata = function(cdata, size, split)
  split = split or 1
  for i = 0, size-1 do
    if i % split == 0 then
      io.write("\n")
    end
    io.write(cdata[i], "\t")
  end
  print()
end

M.printarray = function(array, string)
  print(string)
  M.printcdata(array.data, array.size, array.strides[0])
end


M.isSubsetOf = function(t1, t2)
  for k,v in pairs(t1) do
    if v ~= t2[k] then return false end
  end
  return true
end

function M.waitInput(message)
  local mess = message or "continue with this operation (Y/n)? "
  local answer
  repeat
    io.stdout:write(mess)
    io.stdout:flush()
    answer=io.stdin:read()
  until answer==""
end
function M.unique(t)
  local entries = {}
  for k,v in pairs(t) do
    if entries[v] then return false end
    entries[v] = true
  end
  return true
end
function M.copytable(t)
  local entries = {}
  for k,v in pairs(t) do
    entries[k] = v
  end
  return entries
end

function M.isPermutation(t, s)
  local entries = M.copytable(s)
  local entries2 = M.copytable(s)
  table.sort(entries)
  table.sort(entries2)
  return M.compareTables(entries, entries2)
end 

--[[
function M.wrap(class)

  local wrapper = {}
  wrapper.counter = {}
  function wrapper._keyWrapper(t,key)
    wrapper.counter[key] = (wrapper.counter[key] or 0 ) + 1
    return class[key]
  end
  setmetatable(wrapper, {__index = wrapper._keyWrapper} )
  
  return wrapper
end
]]--
function M.wrap(class)

  local function _print(self)
    local meta = getmetatable(self)
    --print("counts")
    if meta.data.class then print(meta.data:class(), "accessed members") end
    --for k,v in pairs(meta.data) do print(k,v) end
    for k,v in pairs(meta.counter) do print(k,v) end
    print("finalized")
  end
  local wrapper = newproxy(true)

  local mt = getmetatable(wrapper)
  mt.counter = {}
  mt.data = class
  mt.__index = function(tab, key) 
    local meta = getmetatable(tab)
    meta.counter[key] = (meta.counter[key] or 0) + 1
    return meta.data[key] 
  end
  mt.__gc = _print

  return wrapper
end




function M.timer(fn, name)
  
  local proxy = newproxy(true)
  local handle = {}
  handle.proxy = proxy
  handle.fn = fn
  handle.counter = {}
  local mt = getmetatable(proxy)
  mt.__gc = function() M.printtable(handle.counter) end
  return function(...)
    local name = debug.getinfo(1, 'n').name
    if have_socket then
      local time = socket.gettime()
    end
    local val = {handle.fn(...)}
    handle.counter[name] = (handle.counter[name] or 0 ) + (socket.gettime() - time)
    return unpack(val)
  end


end
