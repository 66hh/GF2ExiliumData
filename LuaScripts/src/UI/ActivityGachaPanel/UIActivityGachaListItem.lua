require("UI.UIBaseCtrl")
require("UI.ActivityGachaPanel.ActivityGachaGlobal")
UIActivityGachaListItem = class("UIActivityGachaListItem", UIBaseCtrl)
UIActivityGachaListItem.__index = UIActivityGachaListItem
UIActivityGachaListItem.ui = nil
UIActivityGachaListItem.mData = nil
function UIActivityGachaListItem:ctor(csPanel)
  self.super.ctor(self, csPanel)
end
function UIActivityGachaListItem:InitCtrl(parent)
  local com = parent:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem)
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, true)
  end
  self:SetRoot(obj.transform)
  self.ui = {}
  self.mData = nil
  self.listItem = {}
  self.listCommonItem = {}
  self:LuaUIBindTable(obj, self.ui)
  self.fadeManager = self.ui.mTrans_GrpItemList.gameObject:GetComponent(typeof(CS.GF2.UI.AutoScrollFade))
  setactive(self.ui.mScrollListChild_GrpItem.gameObject, false)
end
function UIActivityGachaListItem:SetData(type, rewardData)
  self.ui.mText_Name.text = type == ActivityGachaGlobal.TargteType and TableData.GetHintById(270014) or TableData.GetHintById(270015)
  setactive(self:GetRoot().gameObject, rewardData ~= nil)
  if not rewardData then
    return
  end
  table.sort(rewardData, function(a, b)
    return a.id < b.id
  end)
  local curNum = 0
  local totalNum = 0
  local isInfinite = false
  for i = 1, #rewardData do
    curNum = curNum + rewardData[i].curNum
    totalNum = totalNum + rewardData[i].totalNum
    if rewardData[i].totalNum >= 999999 then
      isInfinite = true
    end
  end
  if isInfinite then
    self.ui.mText_Residue.text = TableData.GetHintById(270316)
  else
    self.ui.mText_Residue.text = string_format(TableData.GetHintById(270113), curNum .. "/" .. totalNum)
  end
  self.ui.mText_Num.text = string_format(TableData.GetHintById(270113), curNum)
  for i = 1, #rewardData do
    local data = TableData.listActivityGachaRewardDatas:GetDataById(rewardData[i].id)
    local showData = UIUtils.GetKVSortItemTable(data.reward_item)
    local item = self.listItem[i]
    if not item then
      item = instantiate(self.ui.mScrollListChild_GrpItem.gameObject)
      CS.LuaUIUtils.SetParent(item.gameObject, self.ui.mTrans_GrpItemList.gameObject, true)
      self.listItem[i] = item
      local commonItem = UICommonItem.New()
      commonItem:InitCtrl(item)
      for p, q in pairs(showData) do
        local itemData = TableData.GetItemData(q.id)
        if itemData then
          commonItem:SetItemData(q.id, q.num)
        end
        break
      end
      self.listCommonItem[i] = commonItem
    else
      for p, q in pairs(showData) do
        local itemData = TableData.GetItemData(q.id)
        if itemData then
          self.listCommonItem[i]:SetItemData(q.id, q.num)
        end
        break
      end
    end
    setactive(item, true)
    self.listCommonItem[i]:SetBlackMask(0 >= rewardData[i].curNum)
    self.listCommonItem[i]:SetReceivedIcon(0 >= rewardData[i].curNum)
    local binding = {}
    self:LuaUIBindTable(item, binding)
    if rewardData[i].totalNum >= 999999 then
      binding.mText_Num.text = TableData.GetHintById(270316)
    else
      binding.mText_Num.text = string_format(TableData.GetHintById(270113), rewardData[i].curNum)
    end
    binding = {}
    local group = item:GetComponent(typeof(CS.UnityEngine.CanvasGroup))
    if not LuaUtils.IsNullOrDestroyed(group) then
      group.alpha = 0
    end
  end
  for i = #rewardData + 1, #self.listItem do
    setactive(self.listItem[i].gameObject, false)
  end
  if self.fadeManager then
    self.fadeManager:DoScrollFade()
  end
end
function UIActivityGachaListItem:OnRelease()
  self:ReleaseCtrlTable(self.listCommonItem, true)
  for i = 1, #self.listItem do
    gfdestroy(self.listItem[i])
  end
  self.listItem = nil
  self.listCommonItem = nil
  self.ui = nil
  self.fadeManager = nil
  self.super.OnRelease(self, true)
end
