require("UI.UIBaseCtrl")
UIWeaponSlotItem = class("UIWeaponSlotItem", UIBaseCtrl)
UIWeaponSlotItem.__index = UIWeaponSlotItem
function UIWeaponSlotItem:ctor()
  self.partData = nil
  self.typeId = 0
  self.slotId = 0
  self.ui = {}
end
function UIWeaponSlotItem:__InitCtrl()
  setactive(self.ui.mTrans_Select, false)
end
function UIWeaponSlotItem:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComWeaponInfoItem.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, false)
  end
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self:__InitCtrl()
end
function UIWeaponSlotItem:SetData(partData, typeId, slotId)
  if partData == nil and typeId == nil then
    self.partData = nil
    self.typeId = nil
    self.slotId = 0
    setactive(self.mUIRoot, false)
    return
  end
  self.partData = partData
  self.typeId = typeId
  self.slotId = slotId
  if self.partData == nil then
    local slotData = TableData.listWeaponModTypeDatas:GetDataById(typeId)
    self.ui.mImage_Shadow.sprite = IconUtils.GetWeaponPartIcon(slotData.icon)
    setactive(self.ui.mImage_SuitIcon.gameObject, false)
    setactive(self.ui.mTrans_Lock, false)
    setactive(self.ui.mTrans_RedPoint, NetCmdWeaponPartsData:HasHeigherNotUsedMod(self.typeId, 0))
  else
    self:UpdatePartInfo()
    setactive(self.ui.mTrans_RedPoint, NetCmdWeaponPartsData:HasHeigherNotUsedMod(self.typeId, self.partData.stcId))
  end
  self:ShowPartData(self.partData ~= nil)
  setactive(self.ui.mTrans_Add, self.partData == nil)
  setactive(self.mUIRoot, true)
end
function UIWeaponSlotItem:UpdatePartInfo()
  local suitData = TableData.listModPowerDatas:GetDataById(self.partData.suitId)
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
  setactive(self.ui.mTrans_Lock, self.partData.IsLocked)
end
function UIWeaponSlotItem:ShowPartData(boolean)
  setactive(self.ui.mTrans_Line, boolean)
  setactive(self.ui.mTrans_Level, boolean)
  setactive(self.ui.mTrans_Icon, boolean)
  setactive(self.ui.mTrans_GrpContentBg, boolean)
end
function UIWeaponSlotItem:SetItemSelect(isSelect)
  self.ui.mBtn_Part.interactable = not isSelect
  setactive(self.ui.mTrans_Select, isSelect)
end
