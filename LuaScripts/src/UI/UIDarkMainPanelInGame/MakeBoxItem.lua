require("UI.UIBaseCtrl")
local EnumDarkzoneProperty = require("UI.UIDarkMainPanelInGame.DarkzoneProperty")
MakeBoxItem = class("MakeBoxItem", UIBaseCtrl)
MakeBoxItem.__index = MakeBoxItem
local self = MakeBoxItem
local CostItemType = {
  None = 0,
  Property = 1,
  Item = 2
}
function MakeBoxItem:__InitCtrl()
end
function MakeBoxItem:InitCtrl(parent)
  local instObj = instantiate(parent.childItem, parent.gameObject.transform, false)
  self:SetRoot(instObj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self.context = nil
  self.data = nil
  self.ui.mBtn_Make.onClick:AddListener(function()
    self.context:MakeItem(self.data)
  end)
end
function MakeBoxItem:SetData(data, index, context)
  self.context = context
  self.data = data
  local cost = data.Costs[0]
  local output = data.OutPuts[0]
  cost:CheckCostIsEnough()
  output:CheckCostIsEnough()
  self.ui.mImg_ItemIcon = ResSys:GetUIResAIconSprite(output.itemData.IconPath)
  self.ui.mText_ItemName.text = output.itemData.Name
  if cost.type.value__ == CostItemType.Property then
    if cost.itemData.Id == EnumDarkzoneProperty.Property.DzEnergy1Now then
      setactive(self.ui.mImg_ItemCostRed.gameObject, true)
      setactive(self.ui.mImg_ItemCostBlue.gameObject, false)
    elseif cost.itemData.Id == EnumDarkzoneProperty.Property.DzEnergy2Now then
      setactive(self.ui.mImg_ItemCostRed.gameObject, false)
      setactive(self.ui.mImg_ItemCostBlue.gameObject, true)
    else
      setactive(self.ui.mImg_ItemCostRed.gameObject, false)
      setactive(self.ui.mImg_ItemCostBlue.gameObject, false)
    end
  else
    setactive(self.ui.mImg_ItemCostRed.gameObject, false)
    setactive(self.ui.mImg_ItemCostBlue.gameObject, false)
  end
  local enough = cost:CheckCostIsEnough()
  if enough then
    self.ui.mText_ItemCost.text = cost.currentValue .. "/" .. cost.needNum
  else
    self.ui.mText_ItemCost.text = "<color=#ce4848>" .. cost.currentValue .. "</color>/" .. cost.needNum
  end
  self.ui.mAni_CanMake:SetBool("Locked", not enough)
end
function MakeBoxItem:OnRelease()
  self.ui.mBtn_Make.onClick:RemoveAllListeners()
  self.ui = nil
  self.context = nil
  self.data = nil
end
