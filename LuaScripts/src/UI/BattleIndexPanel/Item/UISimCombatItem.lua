require("UI.UIBaseCtrl")
UISimCombatItem = class("UISimCombatItem", UIBaseCtrl)
UISimCombatItem.__index = UISimCombatItem
UISimCombatItem.mImage_SimCombat_IconImage = nil
UISimCombatItem.mImage_SimCombat_SimCombatAward_SimCombatAwardIcon = nil
UISimCombatItem.mText_SimCombat_SimCombatName = nil
UISimCombatItem.mText_SimCombat_TitleText = nil
UISimCombatItem.mText_SimCombatName = nil
UISimCombatItem.mTrans_SimCombat_SimCombatNewbg = nil
UISimCombatItem.mTrans_SimCombat_LockMask = nil
UISimCombatItem.mTrans_OpenTime = nil
UISimCombatItem.mType = nil
function UISimCombatItem:__InitCtrl()
  self.mImage_SimCombat_IconImage = self:GetImage("GrpContent/GrpBgScene/Img_Bg")
  self.mText_SimCombat_SimCombatName = self:GetText("GrpContent/GrpText/Text_Name")
  self.mText_SimCombatName = self:GetText("GrpContent/OpenTime/Text")
  self.mTrans_SimCombat_LockMask = self:GetRectTransform("GrpContent/GrpState/Trans_GrpLocked")
  self.mTrans_OpenTime = self:GetRectTransform("GrpContent/OpenTime")
  self.mTrans_SimCombat = self:GetSelfRectTransform()
  self.mTrans_RedPoint = self:GetRectTransform("GrpContent/GrpState/Trans_GrpRedPoint")
end
function UISimCombatItem:InitCtrl(parent)
  local instObj = instantiate(UIUtils.GetGizmosPrefab("BattleIndex/SimCombatChapterItemV2.prefab", self))
  CS.LuaUIUtils.SetParent(instObj.gameObject, parent.gameObject)
  self:SetRoot(instObj.transform)
  self:__InitCtrl()
end
function UISimCombatItem:SetData(data)
  if data then
    self.mType = data.unlock
    self.mImage_SimCombat_IconImage.sprite = IconUtils.GetStageIcon(data.image)
    self.mText_SimCombat_SimCombatName.text = data.name.str
    self.mText_SimCombatName.text = data.open_time.str
    self:CheckSimCombatIsUnLock()
    setactive(self.mUIRoot.gameObject, true)
    self:UpdateRedPoint()
    UIUtils.ForceRebuildLayout(self.mTrans_OpenTime)
  else
    setactive(self.mUIRoot.gameObject, false)
  end
end
function UISimCombatItem:CheckSimCombatIsUnLock()
  local isLock = AccountNetCmdHandler:CheckSystemIsUnLock(self.mType)
  setactive(self.mTrans_SimCombat_LockMask, not isLock)
end
function UISimCombatItem:UpdateRedPoint()
  if self.mType == CS.GF2.Data.SystemList.BattleSimTutorial then
    local b = NetCmdSimulateBattleData:CheckTeachingRewardRedPoint() or NetCmdSimulateBattleData:CheckTeachingUnlockRedPoint()
    setactive(self.mTrans_RedPoint, b)
  end
end
function UISimCombatItem:CheckSimCombatIsNew()
  return false
end
