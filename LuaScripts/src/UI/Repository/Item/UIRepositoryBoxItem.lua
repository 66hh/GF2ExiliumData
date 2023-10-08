require("UI.UIUnitInfoPanel.UIUnitInfoPanel")
UIRepositoryBoxItem = class("UIRepositoryBoxItem", UIBaseCtrl)
UIRepositoryBoxItem.__index = UIRepositoryBoxItem
function UIRepositoryBoxItem:ctor()
end
UIRepositoryBoxItem.mObj = nil
function UIRepositoryBoxItem:__InitCtrl()
end
function UIRepositoryBoxItem:InitCtrl(obj, parent)
  local instantObj = instantiate(obj, parent)
  self:__InitCtrl()
  self.ui = {}
  self:LuaUIBindTable(instantObj, self.ui)
  setactive(self.ui.mTrans_Select, false)
  self.isSelect = false
  self.itemId = nil
  self.itemNum = 0
  self.ui.mTrans_Select.alpha = 1
end
function UIRepositoryBoxItem:SetData(itemid, num, itemTableData, parentUI)
  self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(itemTableData.Rank)
  self.ui.mText_Num.text = num
  self.itemNum = num
  self.ui.mText_Name.text = itemTableData.name.str
  self.itemId = itemid
  UIUtils.GetButtonListener(self.ui.mTrans_Root.gameObject).onClick = function()
    self:OnClick(parentUI)
  end
  if itemTableData.type == GlobalConfig.ItemType.GunType then
    self.ui.mImage_Icon.sprite = IconUtils.GetItemIconSprite(itemid)
    UIUtils.GetButtonListener(self.ui.mBtn_Select.gameObject).onClick = function()
      UIUnitInfoPanel.Open(UIUnitInfoPanel.ShowType.GunItem, tonumber(itemid))
    end
  elseif itemTableData.type == GlobalConfig.ItemType.Weapon then
    self.ui.mImage_Icon.sprite = IconUtils.GetWeaponSprite(itemTableData.icon)
    TipsManager.Add(self.ui.mBtn_Select.gameObject, itemTableData, 1, false, nil, nil, nil, nil, true)
  else
    self.ui.mImage_Icon.sprite = IconUtils.GetItemIconSprite(itemid)
    TipsManager.Add(self.ui.mBtn_Select.gameObject, itemTableData, 1, false)
  end
end
function UIRepositoryBoxItem:OnClick(parentUI)
  if parentUI.totalNum > 1 then
    if parentUI.nowNum < parentUI.totalNum and not self.isSelect then
      parentUI.nowNum = parentUI.nowNum + 1
      setactive(self.ui.mTrans_Select, true)
      self.isSelect = true
    elseif self.isSelect then
      setactive(self.ui.mTrans_Select, false)
      self.isSelect = false
      parentUI.nowNum = parentUI.nowNum - 1
    else
      CS.PopupMessageManager.PopupString(TableData.GetHintById(1073))
    end
  else
    for i = 1, #parentUI.itemList do
      setactive(parentUI.itemList[i].ui.mTrans_Select, false)
      parentUI.itemList[i].isSelect = false
    end
    parentUI.nowNum = 1
    setactive(self.ui.mTrans_Select, true)
    self.isSelect = true
  end
  parentUI.ui.mText_SelectNum.text = string_format(TableData.GetHintById(1071), parentUI.nowNum, parentUI.totalNum)
end
