require("UI.Common.UICommonSimpleView")
require("UI.UIBasePanel")
UIDarkZoneAirValueDialog = class("UIDarkZoneAirValueDialog", UIBasePanel)
UIDarkZoneAirValueDialog.__index = UIDarkZoneAirValueDialog
function UIDarkZoneAirValueDialog:ctor(csPanel)
  UIDarkZoneAirValueDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneAirValueDialog:OnInit(root, data)
  self:InitBaseData()
  self.mView:InitCtrl(root, self.ui)
  self:AddBtnListen()
  self:InitUI(data)
  setactive(self.ui.mTrans_Content, false)
end
function UIDarkZoneAirValueDialog:OnShowStart()
  self:RefreshDialog()
end
function UIDarkZoneAirValueDialog:OnClose()
  self.ui = nil
  self.mView = nil
  self.mData = nil
  if self.desItemLs ~= nil then
    for i = 1, #self.desItemLs do
      gfdestroy(self.desItemLs[i].mTrans_AirItem.gameObject)
    end
    self.desItemLs = nil
  end
end
function UIDarkZoneAirValueDialog:OnRelease()
  self.super.OnRelease(self)
end
function UIDarkZoneAirValueDialog:CloseFunction()
end
function UIDarkZoneAirValueDialog:InitBaseData()
  self.mView = UICommonSimpleView.New()
  self.ui = {}
end
function UIDarkZoneAirValueDialog:AddBtnListen()
  local func = function()
    UIManager.CloseUISelf(self)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = func
  UIUtils.GetButtonListener(self.ui.mBtn_BGClose.gameObject).onClick = func
end
function UIDarkZoneAirValueDialog:InitUI(data)
  setactive(self.ui.mTrans_AirItem, false)
  local endLessId = data.endlessId
  local tbData = TableData.listDarkzoneSystemEndlessDatas:GetDataById(endLessId)
  self.questId = tbData.map
end
function UIDarkZoneAirValueDialog:RefreshDialog()
  local endlessData = TableData.listDzEndlessModeDatas:GetDataById(self.questId)
  self.segmentNum = endlessData.result_divide
  self.TextLs = {}
  self.desItemLs = {}
  for i = self.segmentNum, 0, -1 do
    local prefabObj = self.ui.mTrans_AirItem.gameObject
    local instObj = instantiate(prefabObj, self.ui.mTrans_Content)
    local itemUI = {}
    self:LuaUIBindTable(instObj, itemUI)
    self:SetSegmentDes(endlessData, i, itemUI)
    setactive(instObj, true)
    self.desItemLs[self.segmentNum - i + 1] = itemUI
  end
  setactive(self.ui.mTrans_Content, true)
end
function UIDarkZoneAirValueDialog:SetSegmentDes(endlessData, index, itemUI)
  local desStr
  if index == 0 then
    desStr = string.split(endlessData.result_desc1, "|")
  elseif index == 1 then
    desStr = string.split(endlessData.result_desc2, "|")
  elseif index == 2 then
    desStr = string.split(endlessData.result_desc3, "|")
  elseif index == 3 then
    desStr = string.split(endlessData.result_desc4, "|")
  elseif index == 4 then
    desStr = string.split(endlessData.result_desc5, "|")
  elseif index == 5 then
    desStr = string.split(endlessData.result_desc6, "|")
  end
  if desStr == nil or #desStr ~= 2 then
    itemUI.mText_Name.text = "Error !"
    itemUI.mText_Description.text = "Check Config !"
  else
    itemUI.mText_Name.text = desStr[1]
    itemUI.mText_Description.text = desStr[2]
  end
end
