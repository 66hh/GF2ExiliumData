ClearSysData = {}
function ClearSysData.Clear()
  if UIChapterGlobal then
    UIChapterGlobal:RecordChapterId(nil)
  end
end
