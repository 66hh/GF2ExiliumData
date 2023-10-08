UIChapterGlobal = {}
UIChapterGlobal.MaxChallengeNum = 3
UIChapterGlobal.CanReceiveColor = ColorUtils.StringToColor("F0AF14")
UIChapterGlobal.CanNotReceiveColor = ColorUtils.StringToColor("EFEFEF")
UIChapterGlobal.CurChapterId = nil
UIChapterGlobal.Difficulty = {Normal = 1, Hard = 2}
UIChapterGlobal.RewardState = {
  UnFinish = 0,
  Receive = 1,
  Finish = 2
}
UIChapterGlobal.StageStartPoint = {
  Top = 1,
  Right = 2,
  Bottom = 3,
  Left = 4
}
function UIChapterGlobal:RecordChapterId(chapterId)
  UIChapterGlobal.CurChapterId = chapterId
end
function UIChapterGlobal:GetRecordChapterId()
  return UIChapterGlobal.CurChapterId
end
function UIChapterGlobal:GetTensDigitNum(num)
  if num then
    return num < 10 and "0" .. num or num
  end
end
function UIChapterGlobal:GetNormalChapterId(chapterId)
  return chapterId < 100 and chapterId or chapterId - 100
end
function UIChapterGlobal:GetRandomNum()
  local num1 = math.random(100, 999)
  local num2 = math.random(100, 999)
  local num3 = math.random(100, 999)
  return "D" .. num1 .. "-" .. num2 .. "-" .. num3
end
function UIChapterGlobal:GetRandomNumWithOutIDStr()
  local num1 = math.random(1000, 9999)
  local num2 = math.random(100, 999)
  local num3 = math.random(100, 999)
  return num1 .. "-" .. num2 .. "-" .. num3
end
