require("UI.AdjutantPanel.AdjutantItem.AdjutantAssistantChangeTabItem")
require("UI.UIBasePanel")
UIAdjutantAssistantChangeDialog = class("UIAdjutantAssistantChangeDialog", UIBasePanel)
UIAdjutantAssistantChangeDialog.__index = UIAdjutantAssistantChangeDialog
local self = UIAdjutantAssistantChangeDialog
function UIAdjutantAssistantChangeDialog:ctor(obj)
  UIAdjutantAssistantChangeDialog.super.ctor(self)
  obj.HideSceneBackground = false
end
function UIAdjutantAssistantChangeDialog:OnInit(root)
  self.super.SetRoot(UIAdjutantAssistantChangeDialog, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.adjutantType = UIAdjutantGlobal.CommandAdjutantType.Adjutant
  self.AssistantCount = UIAdjutantGlobal.AssistantCount
  self.adjutantList = {}
  self.adjutantDataList = {}
  self.curAdjutantIndex = 0
  self.adjutantSkinList = {}
  self.adjutantSkinItemDataList = {}
  self.curSelectPosItem = nil
  self.curSelectPos = 0
  self.characterId = 0
  self.curAdjutantSkinIndex = 0
  self.cannotChangeHint = TableData.GetHintById(113011)
  self.tmpTabItemList = {}
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    self:OnClickCloseBtn()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:OnClickCloseBtn()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Change.gameObject).onClick = function()
    self:OnClickChangeBtn()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    self:OnClickChangeBtn()
  end
  self:InitAdjutantList()
  self:InitFilter()
  UIAdjutantGlobal.PlayAdjutantCamera(UIAdjutantGlobal.AdjutantACTriggerName.AssistantFadeIn)
end
function UIAdjutantAssistantChangeDialog:InitFilter()
  setactive(self.ui.mTrans_BtnScreen.gameObject, false)
  setactive(self.ui.mTrans_Screen.gameObject, false)
end
function UIAdjutantAssistantChangeDialog:InitAdjutantList()
  setactive(self.ui.mTrans_ChrList, true)
  setactive(self.ui.mTrans_SkinList, false)
  self.adjutantType = UIAdjutantGlobal.CommandAdjutantType.Adjutant
  local tmpList = NetCmdCommandCenterAdjutantData.AllAdjutantDic
  self.adjutantList = {}
  self.adjutantDataList = {}
  for i, v in pairs(tmpList) do
    local tmpAdjutant = TableData.listAdjutantDatas:GetDataById(v[0])
    if tmpAdjutant.AdjutantDropbackSwitch == 0 or tmpAdjutant.AdjutantDropbackSwitch == 2 then
      table.insert(self.adjutantList, {characterId = i, adjutantIds = v})
    end
  end
  for i, v in ipairs(self.adjutantList) do
    local adjutantChrChangeItemData = AdjutantChrChangeItemData.New()
    adjutantChrChangeItemData:SetAdjutantListData(v)
    table.insert(self.adjutantDataList, adjutantChrChangeItemData)
  end
  setactive(self.ui.mTrans_Empty, #self.adjutantDataList == 0)
  table.sort(self.adjutantDataList, function(a, b)
    return a.adjutantData.Index < b.adjutantData.Index
  end)
  self.ui.mVirtualListEx_ChrList.itemProvider = self.AdjutantChrItemProvider
  self.ui.mVirtualListEx_ChrList.itemRenderer = self.AdjutantChrItemRenderer
  self.ui.mVirtualListEx_ChrList:Refresh()
  self.ui.mVirtualListEx_ChrList.numItems = #self.adjutantList
  local hint = TableData.GetHintById(20007)
  for i = 1, self.AssistantCount do
    do
      local tmpTabItem = AdjutantAssistantChangeTabItem.New()
      tmpTabItem:InitCtrl(self.ui.mScrollListChild_TabBtn)
      tmpTabItem:SetData(i)
      tmpTabItem.ui.mText_Name.text = string_format(hint, i)
      UIUtils.GetButtonListener(tmpTabItem.ui.mBtn_Self.gameObject).onClick = function()
        self:OnClickAdjutantTabItem(tmpTabItem)
      end
      if i == 1 then
        self.curSelectPosItem = tmpTabItem
        self:OnClickAdjutantTabItem(tmpTabItem, true)
      end
      table.insert(self.tmpTabItemList, tmpTabItem)
    end
  end
end
function UIAdjutantAssistantChangeDialog.AdjutantChrItemProvider()
  local itemView = AdjutantChrChangeItem.New()
  itemView:InitCtrl(self.ui.mScrollListChild_ChrContent)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIAdjutantAssistantChangeDialog.AdjutantChrItemRenderer(index, itemData)
  local data = self.adjutantDataList[index + 1]
  local item = itemData.data
  item:ShowIndex(true)
  item:SetAdjutantListData(data)
  UIUtils.GetButtonListener(item.ui.mBtn_Self.gameObject).onClick = function()
    local tmpAdjutantData = NetCmdCommandCenterAdjutantData.AdjutantDatas[0]
    if item.data.adjutantData.Id == tmpAdjutantData.Id then
      CS.PopupMessageManager.PopupString(self.cannotChangeHint)
      return
    end
    self:OnClickAdjutantChrItem(index + 1)
    self.characterId = item.data.characterId
    self:InitAdjutantSkinList()
  end
end
function UIAdjutantAssistantChangeDialog:OnClickAdjutantTabItem(item, isFirst)
  self.curSelectPos = item.pos
  self.curSelectPosItem:SetSelected(false)
  item:SetSelected(true)
  self.curSelectPosItem = item
  if not isFirst then
    UIAdjutantGlobal.PlayAdjutantCamera(UIAdjutantGlobal.AdjutantACTriggerName["Assistant0" .. item.pos])
  end
  local adjutantData = self:GetCurTabAdjutant()
  if adjutantData == nil then
    self.ui.mText_Name.text = ""
    setactive(self.ui.mTrans_None.gameObject, true)
  else
    self.ui.mText_Name.text = adjutantData.Name
    setactive(self.ui.mTrans_None.gameObject, false)
  end
end
function UIAdjutantAssistantChangeDialog:OnClickAdjutantChrItem(index)
  self.curAdjutantIndex = index
  self.ui.mText_Name.text = self.adjutantDataList[self.curAdjutantIndex].adjutantData.Name
end
function UIAdjutantAssistantChangeDialog:UpdateAdjutantChrList()
  self.ui.mVirtualListEx_ChrList:Refresh()
  self:OnClickAdjutantChrItem(self.curAdjutantIndex)
end
function UIAdjutantAssistantChangeDialog:InitAdjutantSkinList()
  setactive(self.ui.mTrans_ChrList, false)
  setactive(self.ui.mTrans_SkinList, true)
  self.adjutantType = UIAdjutantGlobal.CommandAdjutantType.Skin
  self.adjutantSkinList = NetCmdCommandCenterAdjutantData.AllAdjutantDicTableData[self.characterId]
  self.adjutantSkinItemDataList = {}
  for i = 0, self.adjutantSkinList.Count - 1 do
    local adjutantSkinChangeItemData = AdjutantSkinChangeItemData.New()
    adjutantSkinChangeItemData:SetAdjutantSkinListData(self.characterId, self.adjutantSkinList[i])
    table.insert(self.adjutantSkinItemDataList, adjutantSkinChangeItemData)
    if 0 < self.adjutantDataList[self.curAdjutantIndex].pos then
      local tmpAdjutant = self:GetCurCharacterAdjutant()
      if tmpAdjutant ~= nil and adjutantSkinChangeItemData.adjutantId == tmpAdjutant.Id then
        self.adjutantDataList[self.curAdjutantIndex].isOnClick = true
        self.curAdjutantSkinIndex = i + 1
      end
    end
  end
  self.ui.mVirtualListEx_SkinList.itemProvider = self.AdjutantSkinItemProvider
  self.ui.mVirtualListEx_SkinList.itemRenderer = self.AdjutantSkinItemRenderer
  self.ui.mVirtualListEx_SkinList:Refresh()
  self.ui.mVirtualListEx_SkinList.numItems = #self.adjutantSkinItemDataList
  self.ui.mVirtualListEx_SkinList:AddOnLayoutDone(self.OnLayoutDone)
end
function UIAdjutantAssistantChangeDialog.OnLayoutDone(objs)
  if self.curAdjutantSkinIndex == 0 then
    self:OnClickAdjutantSkinItem(1)
  else
    self:OnClickAdjutantSkinItem(self.curAdjutantSkinIndex)
  end
end
function UIAdjutantAssistantChangeDialog.AdjutantSkinItemProvider()
  local itemView = AdjutantSkinChangeItem.New()
  itemView:InitCtrl(self.ui.mScrollListChild_SkinContent)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIAdjutantAssistantChangeDialog.AdjutantSkinItemRenderer(index, itemData)
  local data = self.adjutantSkinItemDataList[index + 1]
  local item = itemData.data
  item:SetAdjutantSkinListData(data)
  UIUtils.GetButtonListener(item.ui.mBtn_Self.gameObject).onClick = function()
    self:OnClickAdjutantSkinItem(index + 1)
  end
  item:SetSelected(data.isOnClick)
end
function UIAdjutantAssistantChangeDialog:OnClickAdjutantSkinItem(index)
  if self.curAdjutantSkinIndex ~= 0 then
    self.adjutantSkinItemDataList[self.curAdjutantSkinIndex].isOnClick = false
    self.ui.mVirtualListEx_SkinList:RefreshItem(self.curAdjutantSkinIndex - 1)
  end
  self.curAdjutantSkinIndex = index
  self.adjutantSkinItemDataList[self.curAdjutantSkinIndex].isOnClick = true
  self.ui.mVirtualListEx_SkinList:RefreshItem(self.curAdjutantSkinIndex - 1)
  self.ui.mText_Name.text = self.adjutantSkinItemDataList[self.curAdjutantSkinIndex].adjutantData.Name
  self.ui.mText_SkinName.text = TableData.listGunDatas:GetDataById(self.adjutantSkinItemDataList[self.curAdjutantSkinIndex].adjutantData.DetailId).Name.str
  local adjutantData = self:GetCurCharacterAdjutant()
  SceneSys.currentScene:ChangeAssistants(self.curSelectPos, self.adjutantSkinItemDataList[self.curAdjutantSkinIndex].adjutantId)
  local isLock = self.adjutantSkinItemDataList[self.curAdjutantSkinIndex].isLock
  if isLock then
    setactive(self.ui.mTrans_Lock.gameObject, true)
    setactive(self.ui.mTrans_Using.gameObject, false)
    setactive(self.ui.mBtn_Change.gameObject, false)
    setactive(self.ui.mBtn_Confirm.gameObject, false)
    self.ui.mText_UnLockText.text = self.adjutantSkinItemDataList[self.curAdjutantSkinIndex].adjutantData.LockDes
    return
  end
  local isSetting = self.curSelectPos == self.adjutantDataList[self.curAdjutantIndex].pos and adjutantData ~= nil and self.adjutantSkinItemDataList[self.curAdjutantSkinIndex].adjutantId == adjutantData.Id
  if isSetting then
    setactive(self.ui.mTrans_Lock.gameObject, false)
    setactive(self.ui.mTrans_Using.gameObject, true)
    setactive(self.ui.mBtn_Change.gameObject, false)
    setactive(self.ui.mBtn_Confirm.gameObject, false)
    return
  end
  local isUsingOtherPos = false
  for i = 1, self.AssistantCount do
    local tmpAdjutantData = NetCmdCommandCenterAdjutantData.AdjutantDatas[i]
    if tmpAdjutantData ~= nil and self.adjutantSkinItemDataList[self.curAdjutantSkinIndex].adjutantId == tmpAdjutantData.Id then
      isUsingOtherPos = true
      break
    end
  end
  setactive(self.ui.mTrans_Lock.gameObject, false)
  setactive(self.ui.mTrans_Using.gameObject, false)
  setactive(self.ui.mBtn_Change.gameObject, isUsingOtherPos)
  setactive(self.ui.mBtn_Confirm.gameObject, not isUsingOtherPos)
end
function UIAdjutantAssistantChangeDialog:UpdateAdjutantSkinList()
  self.ui.mVirtualListEx_SkinList:Refresh()
  self:OnClickAdjutantSkinItem(self.curAdjutantSkinIndex)
end
function UIAdjutantAssistantChangeDialog:OnClickChangeBtn()
  local tmpIndex = NetCmdCommandCenterAdjutantData:GetAdjutantPosById(self.adjutantSkinItemDataList[self.curAdjutantSkinIndex].adjutantData.Id)
  local hint2
  if tmpIndex ~= -1 and tmpIndex ~= self.curSelectPos then
    local hint = TableData.GetHintById(113009)
    local content = MessageContent.New(hint, MessageContent.MessageType.DoubleBtn, function()
      hint2 = TableData.GetHintById(113010)
      self:ChangeAssistant(hint2)
      SceneSys.currentScene:ChangeAssistants(tmpIndex)
    end)
    MessageBoxPanel.Show(content)
  else
    hint2 = TableData.GetHintById(113008)
    self:ChangeAssistant(hint2)
  end
end
function UIAdjutantAssistantChangeDialog:ChangeAssistant(hint)
  NetCmdCommandCenterAdjutantData:GetCS_BackAdjutantSet(self.curSelectPos, self.adjutantSkinItemDataList[self.curAdjutantSkinIndex].adjutantData.Id, function(ret)
    if ret == ErrorCodeSuc then
      SceneSys.currentScene:ChangeAssistants(self.curSelectPos)
      self:UpdateAdjutantChrList()
      CS.PopupMessageManager.PopupPositiveString(hint)
      UIManager.CloseUI(UIDef.UIAdjutantAssistantChangeDialog)
    end
  end)
end
function UIAdjutantAssistantChangeDialog:GetCurCharacterAdjutant()
  if self.adjutantDataList[self.curAdjutantIndex].pos > 0 then
    local tmpAdjutant = NetCmdCommandCenterAdjutantData.AdjutantDatas[self.adjutantDataList[self.curAdjutantIndex].pos]
    if NetCmdTeamData:GetGunByID(tmpAdjutant.DetailId) ~= nil or tmpAdjutant.Unlock == 1 then
      return tmpAdjutant
    end
  end
  return nil
end
function UIAdjutantAssistantChangeDialog:GetCurTabAdjutant()
  local tmpAdjutant = NetCmdCommandCenterAdjutantData.AdjutantDatas[self.curSelectPos]
  if tmpAdjutant ~= nil and (NetCmdTeamData:GetGunByID(tmpAdjutant.DetailId) ~= nil or tmpAdjutant.Unlock == 1) then
    return tmpAdjutant
  end
  return nil
end
function UIAdjutantAssistantChangeDialog:GetAssistants()
  local tmpList = {}
  for i = 1, self.AssistantCount do
    table.insert(tmpList, NetCmdCommandCenterAdjutantData.AdjutantDatas[i])
  end
  return tmpList
end
function UIAdjutantAssistantChangeDialog:OnClickCloseBtn()
  if self.adjutantType == UIAdjutantGlobal.CommandAdjutantType.Skin then
    setactive(self.ui.mTrans_ChrList, true)
    setactive(self.ui.mTrans_SkinList, false)
    self.curAdjutantSkinIndex = 0
    self.adjutantType = UIAdjutantGlobal.CommandAdjutantType.Adjutant
    self:UpdateAdjutantChrList()
    SceneSys.currentScene:ChangeAssistants(self.curSelectPos)
  elseif self.adjutantType == UIAdjutantGlobal.CommandAdjutantType.Adjutant then
    UIManager.CloseUI(UIDef.UIAdjutantAssistantChangeDialog)
  end
end
function UIAdjutantAssistantChangeDialog:OnHide()
  self.isHide = true
  UIAdjutantGlobal.PlayAdjutantCamera(UIAdjutantGlobal.AdjutantACTriggerName.AssistantFadeOut)
  self.ui.mVirtualListEx_SkinList:RemoveOnLayoutDone(self.OnLayoutDone)
  SceneSys.currentScene:EnableAssistants(true, 0)
end
function UIAdjutantAssistantChangeDialog:OnClose()
  self:ReleaseCtrlTable(self.tmpTabItemList)
  self:ReleaseCtrlTable(self.itemView)
end
