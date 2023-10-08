require("UI.UIBaseCtrl")
require("UI.Common.UICommonItem")
UIDarkZoneSeasonQuestRewardItem = class("UIDarkZoneSeasonQuestRewardItem", UIBaseCtrl)
UIDarkZoneSeasonQuestRewardItem.__index = UIDarkZoneSeasonQuestRewardItem
function UIDarkZoneSeasonQuestRewardItem:__InitCtrl()
end
function UIDarkZoneSeasonQuestRewardItem:InitCtrl(instObj)
  self:SetRoot(instObj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self:SetActive(true)
  self.comItem = UICommonItem.New()
  self.comItem:InitCtrl(self.ui.mTrans_ItemRoot)
  self.alphaNum = self.ui.mText_Num.color.a
  self.lightRichText = "<color=#efefef>{0}</color>"
end
function UIDarkZoneSeasonQuestRewardItem:SetData(data)
  self.mData = data
  if data ~= nil then
    self.comItem:SetItemData(data)
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
function UIDarkZoneSeasonQuestRewardItem:SetGetNum(num, maxNum)
  local textColor = ColorUtils.TextWhiteColor
  self.maxNum = maxNum
  self.curNum = num
  local s1 = UIUtils.ChangeNumByDigit(self.curNum)
  local s2 = UIUtils.ChangeNumByDigit(self.maxNum)
  if maxNum <= num then
    textColor = ColorUtils.OrangeColor
  else
    textColor.a = self.alphaNum
    if self.curNum > 0 then
      s1 = string_format(self.lightRichText, s1)
    end
  end
  self.ui.mText_Num.text = string_format(TableData.GetHintById(112016), s1, s2)
  self.ui.mText_Num.color = textColor
end
function UIDarkZoneSeasonQuestRewardItem:SetCurNum(num)
  self.curNum = self.curNum + num
  self:SetGetNum(self.curNum, self.maxNum)
end
function UIDarkZoneSeasonQuestRewardItem:PlayAnim()
  self.ui.mAnimator_TextNum:SetTrigger("TextNum_Add")
end
function UIDarkZoneSeasonQuestRewardItem:OnRelease(isDestroy)
  self.comItem:OnRelease(true)
  self.comItem = nil
  self.maxNum = nil
  self.mData = nil
  self.super.OnRelease(self, true)
end
