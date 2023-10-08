require("UI.UIBaseCtrl")
require("UI.Common.UICommonItem")
UIDarkZoneSeasonQuestItem = class("UIDarkZoneSeasonQuestItem", UIBaseCtrl)
UIDarkZoneSeasonQuestItem.__index = UIDarkZoneSeasonQuestItem
function UIDarkZoneSeasonQuestItem:__InitCtrl()
end
function UIDarkZoneSeasonQuestItem:InitCtrl(root)
  local itemPrefab = root:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self:SetRoot(instObj.transform)
  if root then
    CS.LuaUIUtils.SetParent(instObj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self.comItem = {}
end
function UIDarkZoneSeasonQuestItem:SetData(data)
  self.mData = data
  if data ~= nil then
    self.ui.mText_Tittle.text = data.name.str
    self.ui.mText_Content.text = data.description.str
    self.maxNum = data.condition_num
    self:SetRewardItem()
    local questCountNum = NetCmdDarkZoneSeasonData:CheckQuestCounterByID(self.mData)
    self:SetProgress(questCountNum)
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
function UIDarkZoneSeasonQuestItem:SetRewardItem()
  for i = 1, #self.comItem do
    self.comItem[i]:SetActive(false)
  end
  local sortTable = UIUtils.GetKVSortItemTable(self.mData.reward_list)
  for i, v in ipairs(sortTable) do
    if self.comItem[i] == nil then
      self.comItem[i] = UICommonItem.New()
      self.comItem[i]:InitCtrl(self.ui.mTrans_Item)
    end
    local itemID = v.id
    local itemNum = v.num
    self.comItem[i]:SetItemData(itemID, itemNum)
  end
end
function UIDarkZoneSeasonQuestItem:SetProgress(num)
  self.ui.mAnimator_Root:SetBool("Finshed", num >= self.maxNum)
  local str = TableData.GetHintById(16)
  if num >= self.maxNum then
    str = TableData.GetHintById(17)
  end
  if num > self.maxNum then
    num = self.maxNum
  end
  local n = num / self.maxNum
  self.ui.mText_ProgressNum.text = string_format(TableData.GetHintById(112016), math.floor(num), self.maxNum)
  self.ui.mImg_ProgressBar.fillAmount = n
  self.ui.mText_UnFinish.text = str
end
function UIDarkZoneSeasonQuestItem:OnRelease(isDestroy)
  self:ReleaseCtrlTable(self.comItem, true)
  self.comItem = nil
  self.mData = nil
  self.ui = nil
  self.super.OnRelease(self, true)
end
