UIRewardBubbleItem = class("UIRewardBubbleItem", UIBaseCtrl)
UIRewardBubbleItem.__index = UIRewardBubbleItem
function UIRewardBubbleItem:__InitCtrl()
end
function UIRewardBubbleItem:InitObj(parent)
  self:SetRoot(parent.transform)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self:__InitCtrl()
end
function UIRewardBubbleItem:SetData(itemId)
  local itemData = TableData.GetItemData(itemId)
  if itemData.type == GlobalConfig.ItemType.Weapon then
    local weaponData = TableData.listGunWeaponDatas:GetDataById(itemData.args[0])
    if weaponData ~= nil then
      self.ui.mImg_Icon.sprite = IconUtils.GetWeaponSprite(weaponData.res_code)
    end
  else
    self.ui.mImg_Icon.sprite = IconUtils.GetItemIconSprite(itemId)
  end
  self.ui.mImg_QualityCor.color = TableData.GetGlobalGun_Quality_Color2(itemData.rank)
end
