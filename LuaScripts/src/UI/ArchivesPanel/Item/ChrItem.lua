require("UI.UIBaseCtrl")
ChrItem = class("ChrItem", UIBaseCtrl)
ChrItem.__index = ChrItem
function ChrItem:__InitCtrl()
end
function ChrItem:InitCtrl(root)
  local com = root:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
end
function ChrItem:SetData(Data, uiRoleFileDetailPanel)
  self.uiRoleFileDetailPanel = uiRoleFileDetailPanel
  self.ui.mImg_Rank.color = TableData.GetGlobalGun_Quality_Color2(Data.rank)
  self.ui.mImg_Avatar.sprite = ResSys:GetAtlasSprite("Icon/Avatar/Avatar_Bust_" .. Data.code)
  local gun = NetCmdTeamData:GetGunByID(Data.Id)
  local IsUnlock = false
  if gun ~= nil then
    IsUnlock = true
  else
    IsUnlock = false
  end
  if IsUnlock then
    setactive(self.ui.mTrans_Locked, false)
  else
    setactive(self.ui.mTrans_Locked, true)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Self.gameObject).onClick = function()
    self:OnClickSelf(IsUnlock, Data)
  end
end
function ChrItem:OnClickSelf(IsUnlock, Data)
  if IsUnlock then
    if self.uiRoleFileDetailPanel.LastChrItem ~= nil then
      self.uiRoleFileDetailPanel.LastChrItem.ui.mBtn_Self.interactable = true
    end
    self.ui.mBtn_Self.interactable = false
    self.uiRoleFileDetailPanel.LastChrItem = self
    self.uiRoleFileDetailPanel.GunId = Data.Id
    self.uiRoleFileDetailPanel.ui.mText_Name.text = Data.Name.str
    self.uiRoleFileDetailPanel.ui.mImg_Avatar.sprite = ResSys:GetAtlasSprite("Icon/Avatar/Avatar_Whole_" .. Data.code)
  else
    UIUtils.PopupHintMessage(110018)
  end
end
