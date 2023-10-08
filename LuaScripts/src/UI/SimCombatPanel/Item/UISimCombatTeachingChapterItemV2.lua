require("UI.UIBaseCtrl")
UISimCombatTeachingChapterItemV2 = class("UISimCombatTeachingChapterItemV2", UIBaseCtrl)
UISimCombatTeachingChapterItemV2.__index = UISimCombatTeachingChapterItemV2
function UISimCombatTeachingChapterItemV2:__InitCtrl()
end
UISimCombatTeachingChapterItemV2.mData = nil
UISimCombatTeachingChapterItemV2.stageData = nil
UISimCombatTeachingChapterItemV2.isUnLock = false
UISimCombatTeachingChapterItemV2.OrangeColor = Color(0.9647058823529412, 0.44313725490196076, 0.09803921568627451, 1.0)
UISimCombatTeachingChapterItemV2.WhiteColor = Color(1, 1, 1, 0.6)
function UISimCombatTeachingChapterItemV2:InitCtrl(root)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:__InitCtrl()
end
function UISimCombatTeachingChapterItemV2:SetData(data)
  if data then
    self.mData = data
    setactive(self.ui.mUIRoot.gameObject, true)
    self.ui.mImg_Bg.sprite = IconUtils.GetAtlasV2("SimCombatTeaching", data.StcData.chapter_Bg)
    self.ui.mImg_Icon.sprite = IconUtils.GetAtlasV2("SimCombatTeaching", data.StcData.chapter_icon)
    self.ui.mTxt_Name.text = data.StcData.chapter_name.str
    if data.IsUnlocked and data.IsPrevCompleted then
      setactive(self.ui.mTrans_Lock, false)
      setactive(self.ui.mTxt_TextLock.gameObject, false)
      setactive(self.ui.mTrans_Progress, true)
      if data.Progress < 100 then
        setactive(self.ui.mTrans_Finish, false)
        setactive(self.ui.mTrans_Progress, true)
        self.ui.mTxt_Progress.text = TableData.GetHintById(103038) .. ": " .. data.Progress .. "%"
      else
        setactive(self.ui.mTrans_Finish, true)
        setactive(self.ui.mTrans_Progress, false)
      end
      setactive(self.ui.mTrans_Guide, false)
      local completeIds = data:GetCompleteIds()
      local completeTutorialIds = data:GetCompletedTutorials()
      if completeIds.Count > 0 and completeTutorialIds.Count > 0 then
        setactive(self.ui.mTrans_Guide, true)
      else
        setactive(self.ui.mTrans_Guide, false)
      end
      UIUtils.GetButtonTipsHelper(self.ui.mBtn_Guide.gameObject).onClick = function()
        self:ShowGuide(data)
      end
    else
      setactive(self.ui.mTrans_Lock, true)
      setactive(self.ui.mTxt_TextLock.gameObject, true)
      setactive(self.ui.mTrans_Progress, false)
    end
    self:UpdateRedPoint()
  else
    setactive(self.ui.mUIRoot.gameObject, false)
  end
end
function UISimCombatTeachingChapterItemV2:UpdateRedPoint()
  if self.mData:CheckRedPoint() then
    setactive(self.ui.mTrans_RedPoint, true)
  else
    setactive(self.ui.mTrans_RedPoint, false)
  end
end
function UISimCombatTeachingChapterItemV2:UpdateLockState()
  if self.mData.unlock == 1 then
    return true
  elseif self.mData.unlock == 2 then
    return NetCmdSimulateBattleData:CheckStageIsUnLock(self.mData.unlock_detail)
  elseif self.mData.unlock == 3 then
  end
end
function UISimCombatTeachingChapterItemV2:SetDisable()
  self.ui.mBtn_SelfBtn.interactable = false
end
function UISimCombatTeachingChapterItemV2:ShowGuide(data)
  local completeIds = data:GetCompletedTutorials()
  UIManager.OpenUIByParam(UIDef.UISysGuideWindow, completeIds)
end
