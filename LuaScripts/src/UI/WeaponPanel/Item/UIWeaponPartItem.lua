require("UI.UIBaseCtrl")
UIWeaponPartItem = class("UIWeaponPartItem", UIBaseCtrl)
UIWeaponPartItem.__index = UIWeaponPartItem
function UIWeaponPartItem:ctor()
  self.partData = nil
  self.ui = {}
end
function UIWeaponPartItem:__InitCtrl()
end
function UIWeaponPartItem:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComWeaponInfoItem.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, true)
  end
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self:__InitCtrl()
end
function UIWeaponPartItem:InitObj(obj)
  if obj then
    self:LuaUIBindTable(obj, self.ui)
    self:SetRoot(obj.transform)
    self:__InitCtrl()
  end
end
function UIWeaponPartItem:SetData(partData, needShowLevel)
  if partData == nil then
    setactive(self.mUIRoot, false)
    return
  end
  setactive(self.ui.mTrans_Level, needShowLevel ~= false)
  self.partData = partData
  self:UpdatePartInfo()
  if partData.isSelect == nil then
    setactive(self.ui.mTrans_Select, false)
  else
    setactive(self.ui.mTrans_Select, partData.isSelect)
  end
  setactive(self.ui.mTrans_PartInfo, true)
  setactive(self.ui.mTrans_Add, false)
  setactive(self.mUIRoot, true)
end
function UIWeaponPartItem:SetReceiveData(partData)
  if partData == nil then
    setactive(self.mUIRoot, false)
    return
  end
  self.partData = partData
  self:UpdateReceivePartInfo()
  setactive(self.ui.mTrans_PartInfo, true)
  setactive(self.ui.mTrans_Add, false)
  setactive(self.mUIRoot, true)
end
function UIWeaponPartItem:SetDisplay(partData)
  if partData == nil then
    setactive(self.mUIRoot, false)
    return
  end
  self.partData = partData
  self:UpdateDisplayInfo()
  setactive(self.ui.mTrans_PartInfo, true)
  setactive(self.ui.mTrans_Add, false)
  setactive(self.ui.mUIRoot, true)
end
function UIWeaponPartItem:UpdateDisplayInfo()
  local suitData = TableData.listModPowerDatas:GetDataById(self.partData.suitId)
  self.ui.mImage_Icon.sprite = IconUtils.GetWeaponPartIcon(self.partData.icon)
  self.ui.mImage_Rank2.sprite = IconUtils.GetWeaponQuiltyByRank(self.partData.rank)
  self.ui.mImage_SuitIcon.sprite = IconUtils.GetWeaponPartIcon(suitData.image)
  setactive(self.ui.mTrans_Level, false)
  self:SetQualityLine(false)
end
function UIWeaponPartItem:UpdatePartInfo()
  local suitData = TableData.listModPowerDatas:GetDataById(self.partData.suitId, true)
  self.ui.mImage_Icon.sprite = IconUtils.GetWeaponPartIcon(self.partData.icon)
  self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(self.partData.rank)
  self.ui.mImage_Rank2.sprite = IconUtils.GetWeaponQuiltyByRank(self.partData.rank)
  if suitData ~= nil then
    setactive(self.ui.mTrans_SuitRoot, true)
    setactive(self.ui.mImage_SuitIcon.gameObject, true)
    self.ui.mImage_SuitIcon.sprite = IconUtils.GetWeaponPartIcon(suitData.image)
  else
    setactive(self.ui.mTrans_SuitRoot, false)
    setactive(self.ui.mImage_SuitIcon.gameObject, false)
  end
  self.ui.mText_Level.text = GlobalConfig.SetLvText(self.partData.level)
  self.ui.mBtn_Part.interactable = not self.partData.isSelect
  if self.partData.isLock == nil then
    setactive(self.ui.mTrans_Lock, self.partData.IsLocked)
  else
    setactive(self.ui.mTrans_Lock, self.partData.isLock)
  end
  if self.partData.weaponId == nil then
    setactive(self.ui.mTrans_Equiped, self.partData.equipWeapon > 0)
  else
    setactive(self.ui.mTrans_Equiped, self.partData.weaponId > 0)
  end
end
function UIWeaponPartItem:UpdateReceivePartInfo()
  self.ui.mImage_Icon.sprite = IconUtils.GetWeaponPartIcon(self.partData.icon)
  self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(self.partData.rank)
  self.ui.mImage_Rank2.sprite = IconUtils.GetWeaponQuiltyByRank(self.partData.rank)
end
function UIWeaponPartItem:SetItemSelect(isSelect)
  self.ui.mBtn_Part.interactable = not isSelect
  setactive(self.ui.mTrans_Select, isSelect)
end
function UIWeaponPartItem:SetNowEquip(isEquip)
  setactive(self.ui.mTrans_Black, isEquip)
end
function UIWeaponPartItem:SetReceived(isReceived)
  setactive(self.ui.mTrans_Received, isReceived)
end
function UIWeaponPartItem:SetLevel(isOn)
  setactive(self.ui.mTrans_Level, isOn)
end
function UIWeaponPartItem:SetQualityLine(isOn)
  setactive(self.ui.mTrans_QualityLine, isOn)
end
function UIWeaponPartItem:EnableButton(enable)
  self.ui.mBtn_Part.interactable = enable
end
