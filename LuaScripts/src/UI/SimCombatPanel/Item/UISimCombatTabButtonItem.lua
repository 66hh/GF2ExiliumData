require("UI.UIBaseCtrl")
UISimCombatTabButtonItem = class("UISimCombatTabButtonItem", UIBaseCtrl)
UISimCombatTabButtonItem.__index = UISimCombatTabButtonItem
function UISimCombatTabButtonItem:__InitCtrl()
  self.mText_CommonTabButtonItem_TabButtonNormal_TabName = self:GetText("GrpText/Text_Name")
  self.mText_CommonTabButtonItem_TabButtonNormal_TabName2 = self:GetText("GrpText/Text_ENName")
  self.mBtn_ClickTab = self:GetSelfButton()
end
function UISimCombatTabButtonItem:ctor()
  self.data = nil
  self.tagId = 0
  self.systemId = 0
  self.isChoose = false
  self.callback = nil
  self.isLock = false
end
function UISimCombatTabButtonItem:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
end
function UISimCombatTabButtonItem:SetName(id, name, en_name)
  if name then
    self.tagId = id
    self.mText_CommonTabButtonItem_TabButtonNormal_TabName.text = name
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
function UISimCombatTabButtonItem:SetItemState(isChoose)
  self.isChoose = isChoose
  self.mBtn_ClickTab.interactable = not isChoose
end
function UISimCombatTabButtonItem:UpdateRedPoint()
  printstack(self.data.type)
  local hasNew = NetCmdQuestData:CheckIshaveGetReward(self.data.type)
  setactive(self.mTrans_CommonTabButtonItem_RedPoint, hasNew)
end
function UISimCombatTabButtonItem:UpdateSystemLock()
  if self.systemId == 0 or self.systemId == nil then
    self.isLock = false
  else
    self.isLock = not AccountNetCmdHandler:CheckSystemIsUnLock(self.systemId)
  end
  setactive(self.mTrans_Locked, self.isLock)
end
function UISimCombatTabButtonItem:UpdateAchieveTag()
  setactive(self.mTrans_CommonTabButtonItem_RedPoint, false)
end
function UISimCombatTabButtonItem:SetEnable(enable)
  setactive(self.mUIRoot, enable)
end
