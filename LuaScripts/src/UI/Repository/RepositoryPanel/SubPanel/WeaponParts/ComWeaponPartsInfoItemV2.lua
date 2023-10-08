ComWeaponPartsInfoItemV2 = class("ComWeaponPartsInfoItemV2", UIBaseCtrl)
function ComWeaponPartsInfoItemV2:ctor(parent)
  self.super.ctor(parent)
  local obj = self:InstanceUIPrefab("UICommonFramework/ComWeaponPartsInfoItemV2.prefab", parent, false)
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self.isChoose = false
  self.hasTip = false
end
function ComWeaponPartsInfoItemV2:SetByData(data)
  if not data then
    setactive(self.ui.mUIRoot, false)
    return
  end
  self.mData = data
  self.ui.mImage_Icon.sprite = IconUtils.GetWeaponPartIconSprite(data.icon)
  UIUtils.GetButtonListener(self.ui.mBtn_Part.gameObject).onClick = function()
    self:OnClickItem()
  end
  self.ui.mText_Level.text = GlobalConfig.SetLvText(data.level)
  self.ui.mImage_Rank2.sprite = IconUtils.GetWeaponQuiltyByRank(data.rank)
  self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(data.rank)
  local dataSuit = TableData.listModPowerDatas:GetDataById(data.suitId)
  if dataSuit then
    self.ui.mImage_SuitIcon.sprite = IconUtils.GetWeaponPartIcon(dataSuit.image)
  end
  setactive(self.ui.mTrans_Equiped, data.equipWeapon ~= 0)
  setactive(self.ui.mTrans_Lock, data.IsLocked)
  if self.hasTip then
    TipsManager.Add(self:GetRoot().gameObject, data.des)
  end
  setactive(self.mUIRoot, true)
end
function ComWeaponPartsInfoItemV2:OnClickItem(obj)
  local param = {
    self.mData.id,
    UIWeaponGlobal.WeaponPartPanelTab.Info,
    true
  }
  UIManager.OpenUIByParam(UIDef.UIWeaponPartPanel, param)
end
function ComWeaponPartsInfoItemV2:Release()
  self.mData = nil
  self.ui.mImage_Icon.sprite = nil
  UIUtils.GetButtonListener(self.ui.mBtn_Part.gameObject).onClick = nil
  self.ui.mText_Level.text = nil
  self.ui.mImage_Rank2.sprite = nil
end
