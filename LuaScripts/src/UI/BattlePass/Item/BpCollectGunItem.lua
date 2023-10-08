require("UI.Common.UICommonDutyItem")
require("UI.UIBaseCtrl")
BpCollectGunItem = class("BpCollectGunItem", UIBaseCtrl)
function BpCollectGunItem:ctor(parent)
  local go = self:Instantiate("UICommonFramework/ComChrInfoItemV2.prefab", parent)
  self:SetRoot(go.transform)
  self.ui = UIUtils.GetUIBindTable(go)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Self.gameObject, function()
    self:OnClickSelf()
  end)
  setactive(self.ui.mTrans_RedPoint, false)
  setactive(self:GetRoot(), true)
end
function BpCollectGunItem:InitByGunCmdData(storeId)
  self.mStoreId = storeId
  self.mStoreGoodData = TableData.listStoreGoodDatas:GetDataById(storeId)
  if self.mStoreGoodData == nil then
    return
  end
  local isLockGun = NetCmdTeamData:GetGunByStcId(self.mStoreGoodData.Frame) == nil
  self.gunCmdData = NetCmdTeamData:GetLockGunData(self.mStoreGoodData.Frame, true)
  setactive(self.ui.mTrans_Name, true)
  self.ui.mText_Name.text = self.gunCmdData.TabGunData.Name.str
  self.ui.mImg_Icon.sprite = IconUtils.GetCharacterBustSprite(IconUtils.cCharacterAvatarType_Avatar, self.gunCmdData.TabGunData.code)
  setactive(self.ui.mTrans_NotCollected, isLockGun)
  if self.dutyItem == nil then
    self.dutyItem = UICommonDutyItem.New()
    self.dutyItem:InitCtrl(self.ui.mTrans_Duty)
  end
  local dutyData = TableData.listGunDutyDatas:GetDataById(self.gunCmdData.TabGunData.duty)
  self.dutyItem:SetData(dutyData)
  self.ui.mImg_Rank.color = TableData.GetGlobalGun_Quality_Color2(self.gunCmdData.TabGunData.rank)
end
function BpCollectGunItem:AddBtnClickListener(callback)
  self.callback = callback
end
function BpCollectGunItem:Refresh()
  local isLockGun = NetCmdTeamData:GetGunByStcId(self.mStoreGoodData.Frame) == nil
  setactive(self.ui.mTrans_NotCollected, isLockGun)
  if not self.gunCmdData then
    setactive(self.ui.mUIRoot, false)
    return
  end
end
function BpCollectGunItem:OnRelease()
  self.gunCmdData = nil
  self.callback = nil
  self.ui = nil
  self.super.OnRelease(self)
end
function BpCollectGunItem:OnClickSelf()
  if self.callback then
    self.callback(self.gunCmdData)
  end
end
