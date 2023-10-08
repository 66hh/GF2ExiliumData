UIPVPRankGunAvatarItem = class("UIPVPRankGunAvatarItem", UIBaseCtrl)
function UIPVPRankGunAvatarItem:ctor()
end
function UIPVPRankGunAvatarItem:InitCtrl(parent)
  local instObj = self:Instantiate("PVP/Btn_PVPChrAvatarRankItem.prefab", parent)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  self.ui.mBtn_PVPChrAvatarRankItem.onClick:AddListener(function()
    self:OnClickGunAvatar()
  end)
  self:SetRoot(instObj.transform)
end
function UIPVPRankGunAvatarItem:SetData(gunCmdData, user)
  self.gunCmdData = gunCmdData
  self.user = user
  if gunCmdData == nil then
    setactive(self.ui.mTrans_PlayerInfo, false)
    setactive(self.ui.mTrans_Empty, true)
    self.ui.mBtn_PVPChrAvatarRankItem.interactable = false
    return
  else
    setactive(self.ui.mTrans_PlayerInfo, true)
    setactive(self.ui.mTrans_Empty, false)
    self.ui.mBtn_PVPChrAvatarRankItem.interactable = true
  end
  local gunData = TableData.listGunDatas:GetDataById(gunCmdData.Id)
  self.ui.mImg_Avatar.sprite = IconUtils.GetCharacterHeadSprite(IconUtils.cCharacterAvatarType_Avatar, gunData.Code)
  self.ui.mImg_Duty.sprite = IconUtils.GetGunTypeIconByDuty(self.gunCmdData.TabGunData.duty)
  self.ui.mImg_Color.color = TableData.GetGlobalGun_Quality_Color2(gunData.Rank)
  self.ui.mText_Level.text = TableData.GetHintReplaceById(80057, gunCmdData.Level)
end
function UIPVPRankGunAvatarItem:OnClickGunAvatar()
  if self.gunCmdData == nil then
    return
  end
  CS.RoleInfoCtrlHelper.Instance:InitSysPlayerAttrData(self.gunCmdData)
end
function UIPVPRankGunAvatarItem:OnRelease()
  self.ui.mBtn_PVPChrAvatarRankItem.onClick = nil
  self.gunCmdData = nil
  self.user = nil
  self.ui = nil
  self.super.OnRelease(self)
end
