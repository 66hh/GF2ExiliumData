require("UI.DarkZonePanel.UIDarkZoneCraftPanel.Item.DZCraftPartItem")
require("UI.UIBaseCtrl")
DZCraftItem = class("DZCraftItem", UIBaseCtrl)
DZCraftItem.__index = DZCraftItem
function DZCraftItem:__InitCtrl()
end
function DZCraftItem:InitCtrl(root)
  local com = root:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self.itemList = {}
  self.mData = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  setactive(obj, true)
end
function DZCraftItem:SetData(Data, func)
  self.mData = Data
  self.clickFunc = func
  self:SetBaseData()
  self.ui.mText_Name.text = self.mData.itemData.plan_name.str
  self.ui.mBtn_Self.onClick:AddListener(function()
    self:ClickFunction()
  end)
end
function DZCraftItem:ClickFunction()
  if self.mData.mIsUnLock == false then
    local hint = TableData.GetHintById(self.mData.itemData.prompt)
    PopupMessageManager.PopupString(hint)
    return
  end
  if self.clickFunc then
    self.clickFunc(self.mData, self)
  end
end
function DZCraftItem:SetBaseData()
  for i = 1, #self.itemList do
    self.itemList[i]:SetActive(false)
  end
  setactive(self.ui.mTrans_Locked, self.mData.mIsUnLock == false)
  setactive(self.ui.mTrans_CanMake, self.mData.canMakeMaxNum > 0 and self.mData.mIsUnLock == true)
  setactive(self.ui.mTrans_UnMake, self.mData.canMakeMaxNum <= 0 and self.mData.mIsUnLock == true)
  for i = 0, self.mData.itemData.type.Count - 1 do
    if not self.itemList[i + 1] then
      self.itemList[i + 1] = DZCraftPartItem.New()
      self.itemList[i + 1]:InitCtrl(self.ui.mTrans_PartContent)
    end
    self.itemList[i + 1]:SetActive(true)
    self.itemList[i + 1]:SetData(self.mData.itemData.type[i])
  end
end
function DZCraftItem:OnClose()
  self:DestroySelf()
  self.mData = nil
  self.clickFunc = nil
  for i = 1, #self.itemList do
    self.itemList[i]:OnClose()
  end
  self.itemList = nil
end
