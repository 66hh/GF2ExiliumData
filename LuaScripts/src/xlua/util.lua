local unpack = unpack or table.unpack
local async_to_sync = function(async_func, callback_pos)
  return function(...)
    local _co = coroutine.running() or error("this function must be run in coroutine")
    local rets
    local waiting = false
    local cb_func = function(...)
      if waiting then
        assert(coroutine.resume(_co, ...))
      else
        rets = {
          ...
        }
      end
    end
    local params = {
      ...
    }
    table.insert(params, callback_pos or #params + 1, cb_func)
    async_func(unpack(params))
    if rets == nil then
      waiting = true
      rets = {
        coroutine.yield()
      }
    end
    return unpack(rets)
  end
end
local coroutine_call = function(func)
  return function(...)
    local co = coroutine.create(func)
    assert(coroutine.resume(co, ...))
  end
end
local move_end = {}
local generator_mt = {
  __index = {
    MoveNext = function(self)
      self.Current = self.co()
      if self.Current == move_end then
        self.Current = nil
        return false
      else
        return true
      end
    end,
    Reset = function(self)
      self.co = coroutine.wrap(self.w_func)
    end
  }
}
local cs_generator = function(func, ...)
  local params = {
    ...
  }
  local generator = setmetatable({
    w_func = function()
      func(unpack(params))
      return move_end
    end
  }, generator_mt)
  generator:Reset()
  return generator
end
local loadpackage = function(...)
  for _, loader in ipairs(package.searchers) do
    local func = loader(...)
    if type(func) == "function" then
      return func
    end
  end
end
local auto_id_map = function()
  local hotfix_id_map = require("hotfix_id_map")
  local org_hotfix = xlua.hotfix
  function xlua.hotfix(cs, field, func)
    local map_info_of_type = hotfix_id_map[typeof(cs):ToString()]
    if map_info_of_type then
      if func == nil then
        func = false
      end
      local tbl = type(field) == "table" and field or {
        [field] = func
      }
      for k, v in pairs(tbl) do
        local map_info_of_methods = map_info_of_type[k]
        local f = type(v) == "function" and v or nil
        for _, id in ipairs(map_info_of_methods or {}) do
          CS.XLua.HotfixDelegateBridge.Set(id, f)
        end
      end
      xlua.private_accessible(cs)
    else
      return org_hotfix(cs, field, func)
    end
  end
end
local hotfix_ex = function(cs, field, func)
  assert(type(field) == "string" and type(func) == "function", "invalid argument: #2 string needed, #3 function needed!")
  local function func_after(...)
    xlua.hotfix(cs, field, nil)
    local ret = {
      func(...)
    }
    xlua.hotfix(cs, field, func_after)
    return unpack(ret)
  end
  xlua.hotfix(cs, field, func_after)
end
local bind = function(func, obj)
  return function(...)
    return func(obj, ...)
  end
end
local enum_or_op = debug.getmetatable(CS.System.Reflection.BindingFlags.Public).__bor
local enum_or_op_ex = function(first, ...)
  for _, e in ipairs({
    ...
  }) do
    first = enum_or_op(first, e)
  end
  return first
end
local createdelegate = function(delegate_cls, obj, impl_cls, method_name, parameter_type_list)
  local flag = enum_or_op_ex(CS.System.Reflection.BindingFlags.Public, CS.System.Reflection.BindingFlags.NonPublic, CS.System.Reflection.BindingFlags.Instance, CS.System.Reflection.BindingFlags.Static)
  local m = parameter_type_list and typeof(impl_cls):GetMethod(method_name, flag, nil, parameter_type_list, nil) or typeof(impl_cls):GetMethod(method_name, flag)
  return CS.System.Delegate.CreateDelegate(typeof(delegate_cls), obj, m)
end
local state = function(csobj, state)
  local csobj_mt = getmetatable(csobj)
  for k, v in pairs(csobj_mt) do
    rawset(state, k, v)
  end
  local csobj_index, csobj_newindex = state.__index, state.__newindex
  function state.__index(obj, k)
    return rawget(state, k) or csobj_index(obj, k)
  end
  function state.__newindex(obj, k, v)
    if rawget(state, k) ~= nil then
      rawset(state, k, v)
    else
      csobj_newindex(obj, k, v)
    end
  end
  debug.setmetatable(csobj, state)
  return state
end
local print_func_ref_by_csharp = function()
  local registry = debug.getregistry()
  for k, v in pairs(registry) do
    if type(k) == "number" and type(v) == "function" and registry[v] == k then
      local info = debug.getinfo(v)
      local logPath = CS.LoggerHelperExtension.Convert2HerfPath("Assets/XLua/LuaScripts/src/" .. info.short_src, info.linedefined)
      CS.UnityEngine.Debug.LogError(string.format("引用未释放！\n%s，Lua引用被C#持有", logPath))
    end
  end
end
local __g = _G
setmetatable(__g, {
  __newindex = function(_, name, value)
    rawset(__g, name, value)
  end,
  __index = function(_, name)
    return rawget(__g, name)
  end
})
return {
  async_to_sync = async_to_sync,
  coroutine_call = coroutine_call,
  cs_generator = cs_generator,
  loadpackage = loadpackage,
  auto_id_map = auto_id_map,
  hotfix_ex = hotfix_ex,
  bind = bind,
  createdelegate = createdelegate,
  state = state,
  print_func_ref_by_csharp = print_func_ref_by_csharp
}
