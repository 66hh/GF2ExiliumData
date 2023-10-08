require("UI.AdjutantPanel.AdjutantItem.AdjutantChrChangeItem")
require("UI.AdjutantPanel.AdjutantItem.AdjutantChrChangeItemData")
require("UI.AdjutantPanel.UIAdjutantGlobal")
require("UI.UIBasePanel")
UIAdjutantChrChangeDialog = class("UIAdjutantChrChangeDialog", UIBasePanel)
UIAdjutantChrChangeDialog.__index = UIAdjutantChrChangeDialog
local self = UIAdjutantChrChangeDialog
function UIAdjutantChrChangeDialog:ctor(obj)
  UIAdjutantChrChangeDialog.super.ctor(self)
  obj.HideSceneBackground = false
  obj.Is3DPanel = true
end
function UIAdjutantChrChangeDialog:OnInit(root)
  NetCmdCommandCenterAdjutantData:GetAllAdjutant()
  UIAdjutantGlobal.InitAdjutantCameraAC()
  UIAdjutantGlobal.InitCurBackground()
  self.super.SetRoot(UIAdjutantChrChangeDialog, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.adjutantType = UIAdjutantGlobal.CommandAdjutantType.Adjutant
  self.adjutantList = {}
  self.adjutantDataList = {}
  self.curAdjutantIndex = 0
  self.adjutantSkinList = {}
  self.adjutantSkinItemDataList = {}
  self.adjutantSkinItemList = {}
  self.curAdjutantSkinItem = nil
  self.characterId = 0
  self.curAdjutantSkinIndex = 0
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    self:OnClickCloseBtn()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:OnClickCloseBtn()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_ChangeSkin.gameObject).onClick = function()
    self:OnClickChangeBtn()
  end
  self:InitAdjutantList()
  self:InitFilter()
  UIAdjutantGlobal.PlayAdjutantCamera(UIAdjutantGlobal.AdjutantACTriggerName.ChrFadeIn)
end
function UIAdjutantChrChangeDialog:InitFilter()
  setactive(self.ui.mTrans_BtnScreen.gameObject, false)
  setactive(self.ui.mTrans_Screen.gameObject, false)
end
function UIAdjutantChrChangeDialog:InitAdjutantList()
  setactive(self.ui.mTrans_ChrList, true)
  setactive(self.ui.mTrans_SkinList, true)
  setactive(self.ui.mVirtualListEx_SkinList.gameObject, false)
  self.adjutantType = UIAdjutantGlobal.CommandAdjutantType.Adjutant
  local tmpList = NetCmdCommandCenterAdjutantData.AllAdjutantDic
  self.adjutantList = {}
  self.adjutantDataList = {}
  for i, v in pairs(tmpList) do
    local tmpAdjutant = TableData.listAdjutantDatas:GetDataById(v[0])
    if tmpAdjutant.AdjutantDropbackSwitch == 0 or tmpAdjutant.AdjutantDropbackSwitch == 1 then
      table.insert(self.adjutantList, {characterId = i, adjutantIds = v})
    end
  end
  for i, v in ipairs(self.adjutantList) do
    local adjutantChrChangeItemData = AdjutantChrChangeItemData.New()
    adjutantChrChangeItemData:SetAdjutantListData(v, 0)
    table.insert(self.adjutantDataList, adjutantChrChangeItemData)
  end
  table.sort(self.adjutantDataList, function(a, b)
    return a.adjutantData.Index < b.adjutantData.Index
  end)
  self.ui.mVirtualListEx_ChrList.itemProvider = self.AdjutantChrItemProvider
  self.ui.mVirtualListEx_ChrList.itemRenderer = self.AdjutantChrItemRenderer
  self.ui.mVirtualListEx_ChrList:Refresh()
  self.ui.mVirtualListEx_ChrList.numItems = #self.adjutantList
end
function UIAdjutantChrChangeDialog.AdjutantChrItemProvider()
  local itemView = AdjutantChrChangeItem.New()
  itemView:InitCtrl(self.ui.mScrollListChild_ChrContent)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIAdjutantChrChangeDialog.AdjutantChrItemRenderer(index, itemData)
  local data = self.adjutantDataList[index + 1]
  local item = itemData.data
  item:ShowIndex(false)
  item:SetAdjutantListData(data)
  UIUtils.GetButtonListener(item.ui.mBtn_Self.gameObject).onClick = function()
    self:OnClickItem(item)
    self:OnClickAdjutantChrItem(index + 1)
  end
  item:SetSelected(data.isOnClick)
  item:SetCurSelected(data.isOnClick)
  if data.isOnClick then
    self:OnClickItem(item)
    self:OnClickAdjutantChrItem(index + 1)
  end
end
function UIAdjutantChrChangeDialog:OnClickItem(item)
  if self.curAdjutantSkinItem ~= nil then
    self.curAdjutantSkinItem:SetSelected(false)
  end
  self.characterId = item.data.characterId
  self.curAdjutantSkinItem = item
  self.curAdjutantSkinItem:SetSelected(true)
end
function UIAdjutantChrChangeDialog:OnClickAdjutantChrItem(index)
  self.curAdjutantIndex = index
  self.ui.mText_Name.text = self.adjutantDataList[self.curAdjutantIndex].adjutantData.Name
  local tmpAdjutantId = NetCmdCommandCenterAdjutantData:GetAdjutantIdByCharacterId(self.characterId)
  SceneSys.currentScene:ChangeAssistants(0, tmpAdjutantId)
  local tmpAdjutantChrChangeItemData = self.adjutantDataList[self.curAdjutantIndex]
  local isLock = tmpAdjutantChrChangeItemData.isLock
  local adjutantData = self:GetCurAdjutant()
  local isCurAdjutant = tmpAdjutantChrChangeItemData.adjutantData.id == adjutantData.id
  setactive(self.ui.mTrans_Lock, isLock)
  setactive(self.ui.mTrans_Using.gameObject, isCurAdjutant)
  setactive(self.ui.mBtn_ChangeSkin.gameObject, not isCurAdjutant and not isLock)
end
function UIAdjutantChrChangeDialog:UpdateAdjutantChrList()
  self.ui.mVirtualListEx_ChrList:Refresh()
  self:OnClickAdjutantChrItem(self.curAdjutantIndex)
end
function UIAdjutantChrChangeDialog:OnClickChangeBtn()
  local tmpIndex = 0
  local tmpAdjutantId = NetCmdCommandCenterAdjutantData:GetAdjutantIdByCharacterId(self.characterId)
  NetCmdCommandCenterAdjutantData:GetCS_BackAdjutantSet(0, tmpAdjutantId, function(ret)
    if ret == ErrorCodeSuc then
      if tmpIndex ~= -1 then
        SceneSys.currentScene:ChangeAssistants(tmpIndex)
      else
        SceneSys.currentScene:ChangeAssistants(0)
      end
      local hint = TableData.GetHintById(113010)
      CS.PopupMessageManager.PopupPositiveString(hint)
      UIManager.CloseUI(UIDef.UIAdjutantChrChangeDialog)
    end
  end)
end
function UIAdjutantChrChangeDialog:GetCurAdjutant()
  return NetCmdCommandCenterAdjutantData.AdjutantDatas[0]
end
function UIAdjutantChrChangeDialog:OnClickCloseBtn()
  setactive(self.ui.mTrans_ChrList, true)
  self.curAdjutantSkinIndex = 0
  self.adjutantType = UIAdjutantGlobal.CommandAdjutantType.Adjutant
  self:UpdateAdjutantChrList()
  SceneSys.currentScene:ChangeAssistants(0)
  UIManager.JumpToMainPanel()
end
function UIAdjutantChrChangeDialog:OnShow()
end
function UIAdjutantChrChangeDialog:OnCameraStart()
  return 0.01
end
function UIAdjutantChrChangeDialog:OnCameraBack()
  return 0.01
end
function UIAdjutantChrChangeDialog:OnHide()
  self.isHide = true
  UIAdjutantGlobal.PlayAdjutantCamera(UIAdjutantGlobal.AdjutantACTriggerName.ChrFadeOut)
end
function UIAdjutantChrChangeDialog:OnRelease()
  UIAdjutantGlobal.ResetAdjutantCameraAC()
end
function UIAdjutantChrChangeDialog:OnClose()
end
