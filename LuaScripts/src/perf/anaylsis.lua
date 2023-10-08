root_path = CS.DebugCenter.Instance:GetReportRootPath(true)
local take_before = function()
  local take_before_mem = require("perf.memory")
  collectgarbage("collect")
  take_before_mem.m_cMethods.DumpMemorySnapshot(rootPath, "1-Before", -1)
end
local take_after = function()
  local take_after_mem = require("perf.memory")
  collectgarbage("collect")
  take_after_mem.m_cMethods.DumpMemorySnapshot(rootPath, "2-After", -1)
end
local compare = function()
  local take_compare = require("perf.memory")
  take_compare.m_cMethods.DumpMemorySnapshotComparedFile(rootPath, "Compared", -1, "LuaMemRefInfo-All-[1-Before].txt", "LuaMemRefInfo-All-[2-After].txt")
end
return {
  take_before = take_before,
  take_after = take_after,
  compare = compare
}
