require("UI.UIBaseCtrl")
require("UI.MonopolyActivity.ActivityTourGlobal")
ActivityTourNumberTipsItem = class("ActivityTourNumberTipsItem", UIBaseCtrl)
ActivityTourNumberTipsItem.__index = ActivityTourNumberTipsItem
ActivityTourNumberTipsItem.ui = nil
ActivityTourNumberTipsItem.mData = nil
ActivityTourNumberTipsItem.showType = ActivityTourGlobal.NumberTip
function ActivityTourNumberTipsItem:ctor(csPanel)
  self.super.ctor(self, csPanel)
end
function ActivityTourNumberTipsItem:InitCtrl(com, parent)
  local obj = instantiate(com.childItem, parent)
  self:SetRoot(obj.transform)
  self.ui = {}
  self.mData = nil
  self:LuaUIBindTable(obj, self.ui)
  self.ui.mImg_PointsIcon.sprite = IconUtils.GetActivityTourIcon(MonopolyWorld.MpData.levelData.token_icon)
  ActivityTourGlobal.ReplaceAllColor(self.mUIRoot)
end
function ActivityTourNumberTipsItem:Refresh(data)
  local bufPoint = 0
  local listBuf = {}
  if data.BuffTrigger then
    for i = 0, data.BuffTrigger.BuffTrigger_.Count - 1 do
      local buffEffect = data.BuffTrigger.BuffTrigger_[i]
      bufPoint = bufPoint + buffEffect.Points
      table.insert(listBuf, buffEffect.Buff)
    end
  end
  self.ui.mText_Num.text = data.Points_
  setactive(self.ui.mText_AddNum.gameObject, 0 < bufPoint)
  self.ui.mText_AddNum.text = "+" .. bufPoint
  setactive(self.ui.mText_SubNum.gameObject, bufPoint < 0)
  self.ui.mText_SubNum.text = bufPoint
  setactive(self.ui.mText_Content.gameObject, 0 < #listBuf)
  self.ui.mText_Content.text = ""
  if 0 < #listBuf then
    local buffData = TableData.listMonopolyEffectDatas:GetDataById(listBuf[1].Id)
    if buffData then
      self.ui.mText_Content.text = buffData.desc.str
    end
  end
end
