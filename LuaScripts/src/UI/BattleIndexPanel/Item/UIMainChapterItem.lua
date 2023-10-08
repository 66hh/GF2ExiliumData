require("UI.UIBaseCtrl")
UIMainChapterItem = class("UIMainChapterItem", UIBaseCtrl)
UIMainChapterItem.__index = UIMainChapterItem
UIMainChapterItem.mBtn_StoryChapter = nil
UIMainChapterItem.mImage_FrameImage = nil
UIMainChapterItem.mImage_IconImage = nil
UIMainChapterItem.mText_ChapterCount = nil
UIMainChapterItem.mText_ChapterName = nil
UIMainChapterItem.mText_ChapterNumber = nil
UIMainChapterItem.mText_StoryChapterSchedule_Schedule = nil
UIMainChapterItem.mText_StoryChapterSchedule_ChapterScheduleCount = nil
UIMainChapterItem.mTrans_RedPoint = nil
UIMainChapterItem.mTrans_Normal = nil
UIMainChapterItem.mTrans_ChapterSignImage = nil
UIMainChapterItem.mTrans_ChapterNew = nil
UIMainChapterItem.mTrans_LockMask = nil
UIMainChapterItem.PrefabPath = "BattleIndex/PlotCombatChapterItemV2.prefab"
function UIMainChapterItem:ctor()
  self.pointObj = nil
  self.index = 0
end
function UIMainChapterItem:__InitCtrl()
  self.mRectTransform = self:GetSelfRectTransform()
  self.mBtn_StoryChapter = self:GetSelfButton()
  self.mImage_IconImage = self:GetImage("GrpContent/GrpBgScene/Img_Bg")
  self.mImage_ChapterNumber = self:GetImage("GrpContent/GrpChapterNum/GrpNum/Img_Bg")
  self.mImage_ChapterNumberBG = self:GetImage("GrpContent/GrpChapterNum/GrpBg/Img_Bg")
  self.mText_ChapterCount = self:GetText("GrpContent/ChapterText/Text_Name")
  self.mText_ChapterName = self:GetText("GrpContent/ChapterText/Text_Name")
  self.mText_ChapterScheduleCount = self:GetText("GrpContent/ProgressNum/Text_Progress")
  self.mTrans_RedPoint = self:GetRectTransform("GrpContent/GrpState/Trans_GrpRedPoint")
  self.mTrans_Next = self:GetRectTransform("GrpContent/GrpState/Trans_GrpNowProgress")
  self.mTrans_LockMask = self:GetRectTransform("GrpContent/GrpState/Trans_GrpLocked")
end
function UIMainChapterItem:InitCtrl(parent)
  local instObj = instantiate(UIUtils.GetGizmosPrefab(self.PrefabPath, self))
  CS.LuaUIUtils.SetParent(instObj.gameObject, parent.gameObject)
  self:SetRoot(instObj.transform)
  self:__InitCtrl()
end
function UIMainChapterItem:SetData(data, isHard, index)
  if data ~= nil then
    setactive(self.mUIRoot, true)
    self.data = data
    self.index = index
    self.isUnLock = NetCmdDungeonData:UnCompletePrevChapterId(data.id)
    self.isHard = isHard
    self.isNext = self.isUnLock == 0 and 0 < NetCmdDungeonData:UpdateChapterRedPoint(data.id)
    self.isNew = not AccountNetCmdHandler:IsWatchedChapter(data.id)
    self:UpdateChapterItem()
    self:InitChapterPos(data.mPosition)
  else
    setactive(self.mUIRoot, false)
  end
end
function UIMainChapterItem:UpdateChapterItem()
  local chapterNum = self.data.id > 100 and self.data.id - 100 or self.data.id
  self.mImage_ChapterNumber.sprite = IconUtils.GetAtlasV2("Icon/BattleIndexPic", "Img_BattleIndex_Chapter" .. chapterNum)
  self.mImage_IconImage.sprite = IconUtils.GetStageIcon(self.data.background)
  self.mText_ChapterCount.text = self.data.name.str
  setactive(self.mTrans_LockMask, self.isUnLock > 0)
  setactive(self.mTrans_Next, self.isNext)
  self:CalculatePercent()
  self:SetLocked()
end
function UIMainChapterItem:SetLocked()
  if self.isUnLock > 0 then
    self.mImage_ChapterNumber.color = ColorUtils.StringToColor("A0A0A0")
    self.mImage_IconImage.color = ColorUtils.StringToColor("A0A0A0")
    self.mText_ChapterScheduleCount.color = ColorUtils.StringToColor("A0A0A0")
    self.mImage_ChapterNumberBG.color = ColorUtils.StringToColor("333333")
  end
end
function UIMainChapterItem:CalculatePercent()
  local data = TableData.GetStorysByChapterID(self.data.id)
  local total = data.Count * 3
  local stars = NetCmdDungeonData:GetCurStarsByChapterID(self.data.id) + NetCmdDungeonData:GetFinishChapterStoryCountByChapterID(self.data.id) * 3
  self.mText_ChapterScheduleCount.text = tostring(math.ceil(stars / total * 100)) .. "%"
  if stars / total < 1 then
    self.mText_ChapterScheduleCount.color = ColorUtils.WhiteColor
  end
end
function UIMainChapterItem:InitChapterPos(pos)
  if pos then
    local rect = self:GetSelfRectTransform()
    rect.anchoredPosition = Vector2(pos.x + rect.rect.size.x, pos.y)
  end
end
function UIMainChapterItem:GetItemSize()
  local rect = self:GetSelfRectTransform()
  return rect.rect.size
end
function UIMainChapterItem:UpdateRedPoint()
  if self.data == nil then
    return
  end
  setactive(self.mTrans_RedPoint, self.isUnLock == 0 and 0 < NetCmdDungeonData:UpdateChatperRewardRedPoint(self.data.id))
end
