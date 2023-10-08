require("UI.UIBaseCtrl")
CommanderBgItem = class("CommanderBgItem", UIBaseCtrl)
CommanderBgItem.__index = CommanderBgItem
function CommanderLeftTab:ctor()
  self.id = 0
  self.panel = nil
end
function CommanderBgItem:__InitCtrl()
end
function CommanderBgItem:InitCtrl(parent)
  local obj
  obj = instantiate(UIUtils.GetGizmosPrefab("CommandCenter/Btn_CommandCenterBgChangeItem.prefab", self))
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self:__InitCtrl()
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, false)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Self.gameObject).onClick = function()
    self:OnClickSelf()
  end
end
function CommanderBgItem:OnRelease()
  self:DestroySelf()
end
function CommanderBgItem:SetData(data, panel)
  self.id = data.id
  self.panel = panel
  self.ui.mText_Name.text = data.name.str
  self.ui.mImg_Pic.sprite = IconUtils.GetAdjutantRoomPic(data.pic)
  setactive(self.ui.mTrans_Type, data.type == 1)
  self:UpdateData()
end
function CommanderBgItem:UpdateData()
  setactive(self.ui.mTrans_Selected, self.id == NetCmdCommandCenterData.Background)
  local bgData = TableData.listCommandBackgroundDatas:GetDataById(self.id)
  self.isUnlock = true
  if tonumber(bgData.args) ~= 0 then
    local unlock = tonumber(bgData.args)
    self.isUnlock = NetCmdAchieveData:CheckComplete(unlock)
  end
  if self.id == NetCmdCommandCenterData.Background and bgData.type ~= 1 and not NetCmdCommandCenterData:IsBackgroundViewed(self.id) then
    NetCmdCommandCenterData:ViewBackground(self.id)
    setactive(self.ui.mTrans_RedPoint, false)
  end
  setactive(self.ui.mTrans_RedPoint, bgData.type ~= 1 and self.isUnlock and not NetCmdCommandCenterData:IsBackgroundViewed(self.id))
  setactive(self.ui.mTrans_Locked, not self.isUnlock)
end
function CommanderBgItem:OnClickSelf()
  if self.panel ~= nil then
    self.panel:OnSelectItem(self.id)
  end
end
function CommanderBgItem:SetSelect(isSelected)
  if self.id ~= NetCmdCommandCenterData.Background and isSelected and self.isUnlock and not NetCmdCommandCenterData:IsBackgroundViewed(self.id) then
    NetCmdCommandCenterData:ViewBackground(self.id)
    setactive(self.ui.mTrans_RedPoint, false)
  end
  self.ui.mBtn_Self.interactable = not isSelected
end
