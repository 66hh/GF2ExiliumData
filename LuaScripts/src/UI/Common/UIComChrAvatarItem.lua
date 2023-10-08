UIComChrAvatarItem = class("UIComChrAvatarItem", UIBaseCtrl)
function UIComChrAvatarItem:ctor()
end
function UIComChrAvatarItem:InitCtrl(parent, onClick)
  local instObj = self:Instantiate("UICommonFramework/Btn_ComChrAvatarItem.prefab", parent)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  self.ui.mBtn_Root.onClick:AddListener(function()
    if onClick then
      onClick(self.gunCmdData)
    else
      self:OnClickGunAvatar()
    end
  end)
  self:SetRoot(instObj.transform)
end
function UIComChrAvatarItem:SetData(gunCmdData, isShowAdd)
  self.gunCmdData = gunCmdData
  if gunCmdData == nil then
    if isShowAdd then
      setactive(self.ui.mTrans_Add, true)
      setactive(self.ui.mTrans_PlayerInfo, false)
      setactive(self.ui.mTrans_Empty, false)
      self.ui.mBtn_Root.interactable = true
    else
      setactive(self.ui.mTrans_Add, false)
      setactive(self.ui.mTrans_PlayerInfo, false)
      setactive(self.ui.mTrans_Empty, true)
      self.ui.mBtn_Root.interactable = false
    end
    return
  else
    setactive(self.ui.mTrans_Add, false)
    setactive(self.ui.mTrans_PlayerInfo, true)
    setactive(self.ui.mTrans_Empty, false)
    self.ui.mBtn_Root.interactable = true
  end
  local gunData = TableData.listGunDatas:GetDataById(gunCmdData.Id)
  self.ui.mImg_Avatar.sprite = IconUtils.GetCharacterHeadSprite(IconUtils.cCharacterAvatarType_Avatar, gunData.Code)
  self.ui.mImg_Duty.sprite = IconUtils.GetGunTypeIconByDuty(self.gunCmdData.TabGunData.duty)
  self.ui.mImg_Color.color = TableData.GetGlobalGun_Quality_Color2(gunData.Rank)
  self.ui.mText_Level.text = TableData.GetHintReplaceById(80057, gunCmdData.Level)
end
function UIComChrAvatarItem:EnableGrpIcon(enable)
  setactive(self.ui.mTrans_Duty, enable)
end
function UIComChrAvatarItem:OnClickGunAvatar()
  if self.gunCmdData == nil then
    return
  end
  CS.RoleInfoCtrlHelper.Instance:InitSysPlayerAttrData(self.gunCmdData)
end
function UIComChrAvatarItem:OnRelease()
  self.ui.mBtn_Root.onClick = nil
  self.gunCmdData = nil
  self.ui = nil
  self.super.OnRelease(self)
end
