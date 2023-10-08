BpCollectWeaponItem = class("BpCollectWeaponItem", UIBaseCtrl)
BpCollectWeaponItem.__index = BpCollectWeaponItem
function BpCollectWeaponItem:ctor()
  self.gunCmdData = nil
  self.weaponCmdData = nil
  self.isLockWeapon = false
  self.isSelected = false
  self.redPointCount = 0
end
function BpCollectWeaponItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    CS.LuaUIUtils.SetParent(instObj.gameObject, parent.gameObject, true)
  end
  self:SetRoot(instObj.transform)
end
function BpCollectWeaponItem:SetData(storeId, callback)
  self.mStoreId = storeId
  self.mStoreGoodData = TableData.listStoreGoodDatas:GetDataById(storeId)
  if self.mStoreGoodData == nil then
    return
  end
  local weaponStcId = self.mStoreGoodData.Frame
  self.weaponCmdData = NetCmdWeaponData:GetWeaponByStcId(weaponStcId)
  self.isLockWeapon = NetCmdWeaponData:GetWeaponListByStcId(self.weaponCmdData.stc_id).Count == 0
  if self.isLockWeapon then
    self.weaponCmdData = NetCmdWeaponData:GetWeaponByStcId(weaponStcId)
  end
  self.ui.mText_Name.text = self.weaponCmdData.Name
  self.ui.mImg_QualityLine.color = TableData.GetGlobalGun_Quality_Color2(self.weaponCmdData.Rank, self.ui.mImg_QualityLine.color.a)
  self.ui.mImg_QualityColor.color = TableData.GetGlobalGun_Quality_Color2(self.weaponCmdData.Rank, self.ui.mImg_QualityColor.color.a)
  self.ui.mImg_Icon.sprite = IconUtils.GetWeaponNormalSprite(self.weaponCmdData.StcData.res_code)
  self.ui.mBtn_ChrWeaponListItemV3.enabled = callback ~= nil
  setactive(self.ui.mTrans_NotCollected, self.isLockWeapon)
  UIUtils.GetButtonListener(self.ui.mBtn_ChrWeaponListItemV3.gameObject).onClick = function()
    if callback ~= nil then
      callback()
    end
  end
end
function BpCollectWeaponItem:Refresh()
  local weaponStcId = self.mStoreGoodData.Frame
  self.weaponCmdData = NetCmdWeaponData:GetWeaponByStcId(weaponStcId)
  self.isLockWeapon = NetCmdWeaponData:GetWeaponListByStcId(self.weaponCmdData.stc_id).Count == 0
  setactive(self.ui.mTrans_NotCollected, self.isLockWeapon)
end
function BpCollectWeaponItem:UpdateStar()
  local canShowBreakTimes = self.weaponCmdData ~= nil and self.weaponCmdData.BreakTimes ~= 0 and self.weaponCmdData.Rank >= 4 and not self.weaponCmdData.IsLocked
  setactive(self.ui.mTrans_BreakNum, canShowBreakTimes)
  if canShowBreakTimes then
    self.ui.mImg_BreakNum.sprite = IconUtils.GetUIWeaponBreakNum("Img_BreakNum" .. self.weaponCmdData.BreakTimes .. "_S")
  end
end
function BpCollectWeaponItem:UpdateRedPoint()
  setactive(self.ui.mObj_RedPoint.gameObject, false)
  setactive(self.ui.mObj_RedPoint.transform.parent.gameObject, false)
end
function BpCollectWeaponItem:SetSelect(boolean)
  self.isSelected = boolean
  UIUtils.SetInteractive(self.mUIRoot, not boolean)
end
function BpCollectWeaponItem:OnClose()
end
function BpCollectWeaponItem:OnRelease()
  self.super.OnRelease(self)
end
