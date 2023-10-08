require("UI.UIBaseCtrl")
UIPVPChrAvatarRankItem = class("UIPVPChrAvatarRankItem", UIBaseCtrl)
UIPVPChrAvatarRankItem.__index = UIPVPChrAvatarRankItem
function UIPVPChrAvatarRankItem:ctor()
end
function UIPVPChrAvatarRankItem:InitCtrl(parent, fullGunCmdData)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  self:SetData(fullGunCmdData)
end
function UIPVPChrAvatarRankItem:SetData(fullGunCmdData)
  self.fullGunCmdData = fullGunCmdData
  if fullGunCmdData == nil then
    setactive(self.ui.mTrans_PlayerInfo, true)
    setactive(self.ui.mTrans_Empty, false)
    return
  elseif fullGunCmdData.id == 0 then
    setactive(self.ui.mTrans_PlayerInfo, false)
    setactive(self.ui.mTrans_Empty, true)
    UIUtils.GetButton(self.ui.mBtn_PVPChrAvatarRankItem.transform).enabled = false
    return
  else
    setactive(self.ui.mTrans_PlayerInfo, true)
    setactive(self.ui.mTrans_Empty, false)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_PVPChrAvatarRankItem.gameObject).onClick = function()
    CS.RoleInfoCtrlHelper.Instance:InitSysPlayerAttrData(self.fullGunCmdData)
  end
  self.ui.mText_Level.text = "Lv." .. fullGunCmdData.level
  local sprite = IconUtils.GetCharacterHeadSprite(IconUtils.cCharacterAvatarType_Avatar, fullGunCmdData.TabGunData.code)
  self.ui.mImg_Avatar.sprite = sprite
  self.ui.mImg_Color.color = TableData.GetGlobalGun_Quality_Color2(fullGunCmdData.TabGunData.rank)
  self.ui.mImg_Duty.sprite = IconUtils.GetGunTypeIconByDuty(fullGunCmdData.TabGunData.duty)
end
function UIPVPChrAvatarRankItem:SetDataByGunCmdData(gunCmdData, callback)
  self.ui.mText_Level.text = string_format(TableData.GetHintById(80057), gunCmdData.level)
  local sprite = IconUtils.GetCharacterHeadSprite(IconUtils.cCharacterAvatarType_Avatar, gunCmdData.TabGunData.code)
  self.ui.mImg_Avatar.sprite = sprite
  self.ui.mImg_Color.color = TableData.GetGlobalGun_Quality_Color2(gunCmdData.TabGunData.rank)
  self.ui.mImg_Duty.sprite = IconUtils.GetGunTypeIconByDuty(gunCmdData.TabGunData.duty)
end
