require("UI.UIBaseCtrl")
RewardListItem = class("RewardListItem", UIBaseCtrl)
RewardListItem.__index = RewardListItem
function RewardListItem:__InitCtrl()
end
function RewardListItem:InitCtrl(root, Ob)
  local obj = instantiate(Ob)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  setactive(obj, true)
end
function RewardListItem:SetData(TypeId, List)
  self.ui.mText_Name.text = TableData.listItemTypeDescDatas:GetDataById(TypeId).name.str
  if TypeId == 21 then
    for i = 1, #List do
      local itemData = TableData.GetItemData(List[i])
      local item = UICommonItem.New()
      item:InitCtrl(self.ui.mTrans_Content)
      local data = UIWeaponGlobal:GetWeaponModSimpleData(CS.GunWeaponModData(List[i]))
      item:SetPartData(data)
      TipsManager.Add(item.ui.mBtn_Part.gameObject, itemData, 1, false, nil, nil, nil, nil, false)
    end
  else
    for i = 1, #List do
      local item = UICommonItem.New()
      item:InitCtrl(self.ui.mTrans_Content)
      item:SetItemData(List[i], nil, nil, true)
    end
  end
  self.ui.mFade_Script:InitFade()
end
