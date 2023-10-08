UISimCombatWeaponModWishItem = class("UISimCombatWeaponModWishItem", UIBaseCtrl)
UISimCombatWeaponModWishItem.__index = UISimCombatWeaponModWishItem
function UISimCombatWeaponModWishItem:__InitCtrl()
end
function UISimCombatWeaponModWishItem:InitCtrl(itemPrefab)
  if itemPrefab == nil then
    return
  end
  local obj = instantiate(itemPrefab.childItem, itemPrefab.transform)
  self:InitCtrlWithoutInstantiate(obj)
end
function UISimCombatWeaponModWishItem:InitCtrlWithoutInstantiate(obj, setToZero)
  self:SetRoot(obj.transform)
  self:__InitCtrl()
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self.iconList = {}
  UIUtils.AddBtnClickListener(self.ui.mBtn_Self.gameObject, function()
    self:ClickFunction()
  end)
end
function UISimCombatWeaponModWishItem:SetData(suitID, index)
  for i, v in ipairs(self.iconList) do
    setactive(v.obj, false)
  end
  self.itemIndex = index
  self.suitID = suitID
  self.modSuitPlanIDList = TableData.listModPowerBySuitPlanIdDatas:GetDataById(suitID).Id
end
function UISimCombatWeaponModWishItem:SetItemName(str)
  self.ui.mText_Name.text = str
  self.suitName = str
end
function UISimCombatWeaponModWishItem:SetSelectState(selectIndex)
  local isSelect = selectIndex == self.itemIndex
  self.isSelect = isSelect
  self.ui.mBtn_Self.interactable = isSelect == false
end
function UISimCombatWeaponModWishItem:SetClickFunction(func)
  self.clickFunction = func
end
function UISimCombatWeaponModWishItem:ClickFunction()
  if self.isSelect ~= true then
    self.clickFunction(self)
  end
end
