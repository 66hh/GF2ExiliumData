local get_time = os.clock
local sethook = xlua.sethook or debug.sethook
local func_info_map, start_time
local create_func_info = function(db_info)
  return {
    db_info = db_info,
    count = 0,
    total_time = 0
  }
end
local on_hook = function(event, func_info_id, source)
  local func_info = func_info_map[func_info_id]
  if not func_info then
    func_info = create_func_info(debug.getinfo(2, "nS"))
    func_info_map[func_info_id] = func_info
  end
  if event == "call" then
    func_info.call_time = get_time()
    func_info.count = func_info.count + 1
    func_info.return_time = nil
  elseif event == "return" or event == "tail return" then
    local now = get_time()
    if func_info.call_time then
      func_info.total_time = func_info.total_time + (now - func_info.call_time)
      func_info.call_time = nil
    else
      func_info.total_time = func_info.total_time + (now - (func_info.return_time or now))
      func_info.count = func_info.count + 1
    end
    func_info.return_time = now
    if source and func_info.count == 1 then
      func_info.db_info.short_src = source
    end
  end
end
local start = function()
  func_info_map = {}
  start_time = get_time()
  sethook(on_hook, "cr")
end
local pause = function()
  sethook()
end
local resume = function()
  sethook(on_hook, "cr")
end
local stop = function()
  sethook()
  func_info_map = nil
  start_time = nil
end
local report_output_line = function(rp, stat_interval)
  local source = rp.db_info.short_src or "[NA]"
  local linedefined = rp.db_info.linedefined and rp.db_info.linedefined >= 0 and string.format(":%i", rp.db_info.linedefined) or ""
  source = source .. linedefined
  local name = rp.db_info.name or "[anonymous]"
  local total_time = string.format("%4.3f", rp.total_time * 1000)
  local average_time = string.format("%4.3f", rp.total_time / rp.count * 1000)
  local relative_time = string.format("%3.2f%%", rp.total_time / stat_interval * 100)
  local count = string.format("%7i", rp.count)
  return string.format("|%-40.40s: %-50.50s: %-12s: %-12s: %-12s: %-12s|\n", name, source, total_time, average_time, relative_time, count)
end
local sort_funcs = {
  TOTAL = function(a, b)
    return a.total_time > b.total_time
  end,
  AVERAGE = function(a, b)
    return a.average > b.average
  end,
  CALLED = function(a, b)
    return a.count > b.count
  end
}
local report = function(sort_by)
  sethook()
  local sort_func = type(sort_by) == "function" and sort_by or sort_funcs[sort_by]
  local FORMAT_HEADER_LINE = "|%-40s: %-50s: %-12s: %-12s: %-12s: %-12s|\n"
  local header = string.format(FORMAT_HEADER_LINE, "FUNCTION", "SOURCE", "TOTAL(MS)", "AVERAGE(MS)", "RELATIVE", "CALLED")
  local stat_interval = get_time() - (start_time or get_time())
  local report_list = {}
  for _, rp in pairs(func_info_map) do
    table.insert(report_list, {
      total_time = rp.total_time,
      count = rp.count,
      average = rp.total_time / rp.count,
      output = report_output_line(rp, stat_interval)
    })
  end
  table.sort(report_list, sort_func or sort_funcs.TOTAL)
  local output = header
  for i, rp in ipairs(report_list) do
    output = output .. rp.output
  end
  sethook(on_hook, "cr")
  return output
end
return {
  start = start,
  report = report,
  stop = stop
}
