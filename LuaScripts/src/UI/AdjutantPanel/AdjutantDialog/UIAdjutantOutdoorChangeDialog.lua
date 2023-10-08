require("UI.UIBasePanel")
UIAdjutantOutdoorChangeDialog = class("UIAdjutantOutdoorChangeDialog", UIBasePanel)
UIAdjutantOutdoorChangeDialog.__index = UIAdjutantOutdoorChangeDialog
local self = UIAdjutantOutdoorChangeDialog
function UIAdjutantOutdoorChangeDialog:ctor(obj)
  UIAdjutantOutdoorChangeDialog.super.ctor(self)
  obj.HideSceneBackground = false
end
function UIAdjutantOutdoorChangeDialog:OnInit(root)
  self.super.SetRoot(UIAdjutantOutdoorChangeDialog, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.backgroundType = UIAdjutantGlobal.CommandBackGroundType.Out
  self.backgroundList = {}
  self.backgroundItemList = {}
  self.curBackgroundItem = nil
  self.curUseBackgroundItem = nil
  SceneSys.currentScene:EnableAssistants(false)
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    self:OnClickCloseBtn()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:OnClickCloseBtn()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Change.gameObject).onClick = function()
    self:OnClickChangeBtn()
  end
  local tmpList = NetCmdCommandCenterAdjutantData:GetBackgroundByType(self.backgroundType)
  for i = 0, tmpList.Count - 1 do
    table.insert(self.backgroundList, tmpList[i])
  end
  self.ui.mVirtualListEx_List.itemProvider = self.ItemProvider
  self.ui.mVirtualListEx_List.itemRenderer = self.ItemRenderer
  self.ui.mVirtualListEx_List:Refresh()
  self.ui.mVirtualListEx_List.numItems = tmpList.Count
end
function UIAdjutantOutdoorChangeDialog.ItemProvider()
  local itemView = AdjutantRoomChangeItem.New()
  itemView:InitCtrl(self.ui.mTrans_Content)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIAdjutantOutdoorChangeDialog.ItemRenderer(index, itemData)
  local data = self.backgroundList[index + 1]
  local item = itemData.data
  table.insert(self.backgroundItemList, item)
  item:SetCommandBackgroundData(data)
  UIUtils.GetButtonListener(item.ui.mBtn_Self.gameObject).onClick = function()
    self:OnClickItem(item)
  end
  local backgroundOutSide = self:GetCurBackground()
  if item.commandBackground.CommandBackgroundData.Id == backgroundOutSide.CommandBackgroundData.Id and self.curBackgroundItem == nil then
    self.curBackgroundItem = item
    self.curUseBackgroundItem = item
    self.curUseBackgroundItem:SetCurSelected(true)
    self:OnClickItem(self.curBackgroundItem)
    self:UpdateChangeBtn()
  end
end
function UIAdjutantOutdoorChangeDialog:OnClickItem(item)
  if item == nil then
    return
  end
  self.curBackgroundItem:SetSelected(false)
  self.curBackgroundItem = item
  self.ui.mText_Name.text = item.commandBackground.CommandBackgroundData.Name.str
  self:UpdateChangeBtn()
  if item.commandBackground.CommandBackgroundData.Id ~= UIAdjutantGlobal.CurOutDoorId then
    TimerSys:DelayCall(0.2, function()
      SceneSys.currentScene:StopOutside()
    end)
    self.ui.mAnimator_Root:SetTrigger("BlackTransition_FadeIn")
    TimerSys:DelayCall(0.5, function()
      SceneSys.currentScene:ChangeBackground(item.commandBackground.CommandBackgroundData.Type, item.commandBackground)
    end)
  end
  item:SetSelected(true)
end
function UIAdjutantOutdoorChangeDialog:GetCurBackground()
  return NetCmdCommandCenterAdjutantData:GetCurBackgroundByType(UIAdjutantGlobal.CommandBackGroundType.Out)
end
function UIAdjutantOutdoorChangeDialog:OnClickChangeBtn()
  NetCmdCommandCenterAdjutantData:GetCS_BackgroundChange(0, self.curBackgroundItem.commandBackground.CommandBackgroundData.Id, function(ret)
    if ret == ErrorCodeSuc then
      NetCmdCommandCenterAdjutantData:UpdateBackground(0, self.curBackgroundItem.commandBackground.CommandBackgroundData.Id)
      self:UpdateList()
      self:OnClickCloseBtn()
    end
  end)
end
function UIAdjutantOutdoorChangeDialog:UpdateList()
  self.ui.mVirtualListEx_List:Refresh()
  self.curUseBackgroundItem:SetCurSelected(false)
  self.curUseBackgroundItem = self.curBackgroundItem
  self.curUseBackgroundItem:SetCurSelected(true)
  self:UpdateChangeBtn()
end
function UIAdjutantOutdoorChangeDialog:UpdateChangeBtn()
  local backgroundOutSide = self:GetCurBackground()
  local isCurBackground = self.curBackgroundItem.commandBackground.CommandBackgroundData.Id == backgroundOutSide.CommandBackgroundData.Id
  setactive(self.ui.mTrans_Using.gameObject, isCurBackground)
  setactive(self.ui.mTrans_BtnChange.gameObject, not isCurBackground)
end
function UIAdjutantOutdoorChangeDialog:OnClickCloseBtn()
  local closeThisUI = function()
    UIManager.CloseUI(UIDef.UIAdjutantOutdoorChangeDialog)
    SceneSys.currentScene:EnableAssistants(true)
  end
  if self:ReSetBackground() then
    TimerSys:DelayCall(0.5, function()
      closeThisUI()
    end)
  else
    closeThisUI()
  end
end
function UIAdjutantOutdoorChangeDialog:ReSetBackground()
  local curBackground = self:GetCurBackground()
  if UIAdjutantGlobal.CurOutDoorId ~= curBackground.CommandBackgroundData.Id then
    UIAdjutantGlobal.CurOutDoorId = curBackground.CommandBackgroundData.Id
    self.ui.mAnimator_Root:SetTrigger("BlackTransition_FadeIn")
    TimerSys:DelayCall(0.2, function()
      SceneSys.currentScene:StopOutside()
    end)
    TimerSys:DelayCall(0.5, function()
      SceneSys.currentScene:ChangeBackground(2)
    end)
    return true
  end
  return false
end
function UIAdjutantOutdoorChangeDialog:OnShowStart()
  UIAdjutantGlobal.PlayAdjutantCamera(UIAdjutantGlobal.AdjutantACTriggerName.OutdoorFadeIn)
end
function UIAdjutantOutdoorChangeDialog:OnHide()
  self.isHide = true
  UIAdjutantGlobal.PlayAdjutantCamera(UIAdjutantGlobal.AdjutantACTriggerName.OutdoorFadeOut)
end
