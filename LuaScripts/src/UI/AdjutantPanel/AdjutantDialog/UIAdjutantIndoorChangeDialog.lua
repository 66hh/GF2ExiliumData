require("UI.UIBasePanel")
UIAdjutantIndoorChangeDialog = class("UIAdjutantIndoorChangeDialog", UIBasePanel)
UIAdjutantIndoorChangeDialog.__index = UIAdjutantIndoorChangeDialog
function UIAdjutantIndoorChangeDialog:ctor(obj)
  UIAdjutantIndoorChangeDialog.super.ctor(self)
  obj.HideSceneBackground = false
end
function UIAdjutantIndoorChangeDialog:OnInit(root, data)
  self.super.SetRoot(UIAdjutantIndoorChangeDialog, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.backgroundType = UIAdjutantGlobal.CommandBackGroundType.In
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
function UIAdjutantIndoorChangeDialog.ItemProvider()
  self = UIAdjutantIndoorChangeDialog
  local itemView = AdjutantRoomChangeItem.New()
  itemView:InitCtrl(self.ui.mTrans_Content)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIAdjutantIndoorChangeDialog.ItemRenderer(index, itemData)
  self = UIAdjutantIndoorChangeDialog
  local data = self.backgroundList[index + 1]
  local item = itemData.data
  table.insert(self.backgroundItemList, item)
  item:SetCommandBackgroundData(data)
  UIUtils.GetButtonListener(item.ui.mBtn_Self.gameObject).onClick = function()
    self:OnClickItem(item)
  end
  local backgroundInSide = self:GetCurBackground()
  if item.commandBackground.CommandBackgroundData.Id == backgroundInSide.CommandBackgroundData.Id and self.curBackgroundItem == nil then
    self.curBackgroundItem = item
    self.curUseBackgroundItem = item
    self.curUseBackgroundItem:SetCurSelected(true)
    self:OnClickItem(self.curBackgroundItem)
    self:UpdateChangeBtn()
  end
end
function UIAdjutantIndoorChangeDialog:OnClickItem(item)
  if item == nil then
    return
  end
  self.curBackgroundItem:SetSelected(false)
  self.curBackgroundItem = item
  self.ui.mText_Name.text = self.curBackgroundItem.commandBackground.CommandBackgroundData.Name.str
  self:UpdateChangeBtn()
  if item.commandBackground.CommandBackgroundData.Id ~= UIAdjutantGlobal.CurInDoorId then
    self.ui.mAnimator_Root:SetTrigger("BlackTransition_FadeIn")
    TimerSys:DelayCall(0.2, function()
      SceneSys.currentScene:ChangeBackground(item.commandBackground.CommandBackgroundData.Type, item.commandBackground, function()
        self.ui.mAnimator_Root:SetTrigger("BlackTransition_FadeOut_1")
      end)
    end)
  end
  item:SetSelected(true)
end
function UIAdjutantIndoorChangeDialog:GetCurBackground()
  return NetCmdCommandCenterAdjutantData:GetCurBackgroundByType(UIAdjutantGlobal.CommandBackGroundType.In)
end
function UIAdjutantIndoorChangeDialog:OnClickChangeBtn()
  NetCmdCommandCenterAdjutantData:GetCS_BackgroundChange(self.curBackgroundItem.commandBackground.CommandBackgroundData.Id, 0, function(ret)
    if ret == ErrorCodeSuc then
      NetCmdCommandCenterAdjutantData:UpdateBackground(self.curBackgroundItem.commandBackground.CommandBackgroundData.Id, 0)
      self:UpdateList()
      self:OnClickCloseBtn()
    end
  end)
end
function UIAdjutantIndoorChangeDialog:UpdateList()
  self.ui.mVirtualListEx_List:Refresh()
  self.curUseBackgroundItem:SetCurSelected(false)
  self.curUseBackgroundItem = self.curBackgroundItem
  self.curUseBackgroundItem:SetCurSelected(true)
  self:UpdateChangeBtn()
end
function UIAdjutantIndoorChangeDialog:UpdateChangeBtn()
  local backgroundInSide = self:GetCurBackground()
  local isCurBackground = self.curBackgroundItem.commandBackground.CommandBackgroundData.Id == backgroundInSide.CommandBackgroundData.Id
  setactive(self.ui.mTrans_Using.gameObject, isCurBackground)
  setactive(self.ui.mTrans_BtnChange.gameObject, not isCurBackground)
end
function UIAdjutantIndoorChangeDialog:OnClickCloseBtn()
  self:ReSetBackground()
  UIManager.CloseUI(UIDef.UIAdjutantIndoorChangeDialog)
  SceneSys.currentScene:EnableAssistants(true)
end
function UIAdjutantIndoorChangeDialog:ReSetBackground()
  local curBackground = self:GetCurBackground()
  if UIAdjutantGlobal.CurInDoorId ~= curBackground.CommandBackgroundData.Id then
    UIAdjutantGlobal.CurInDoorId = curBackground.CommandBackgroundData.Id
    self.ui.mAnimator_Root:SetTrigger("BlackTransition_FadeIn")
    TimerSys:DelayCall(0.2, function()
      SceneSys.currentScene:ChangeBackground(1, nil, function()
        self.ui.mAnimator_Root:SetTrigger("BlackTransition_FadeOut_1")
      end)
    end)
  end
end
function UIAdjutantIndoorChangeDialog:OnShowStart()
  UIAdjutantGlobal.PlayAdjutantCamera(UIAdjutantGlobal.AdjutantACTriggerName.IndoorFadeIn)
end
function UIAdjutantIndoorChangeDialog:OnHide()
  self.isHide = true
  UIAdjutantGlobal.PlayAdjutantCamera(UIAdjutantGlobal.AdjutantACTriggerName.IndoorFadeOut)
end
