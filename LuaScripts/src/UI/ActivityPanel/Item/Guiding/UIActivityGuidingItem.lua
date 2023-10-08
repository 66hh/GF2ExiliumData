require("UI.UIBaseCtrl")
require("UI.ActivityPanel.Item.UIActivityItemBase")
require("UI.UniTopbar.Item.ResourcesCommonItem")
require("UI.ActivityPanel.Item.Guiding.UIActivityGuidingGetWayItem")
UIActivityGuidingItem = class("UIActivityGuidingItem", UIActivityItemBase)
UIActivityGuidingItem.__index = UIActivityGuidingItem
function UIActivityGuidingItem:OnInit()
end
function UIActivityGuidingItem:OnShow()
  self.ui.mText_Name.text = self.mActivityTableData.name.str
  self.ui.mTextFit_Info.text = self.mActivityTableData.desc.str
  if self.currency == nil then
    self.currency = {}
    local item = ResourcesCommonItem.New()
    item:InitCtrl(self.ui.mTrans_Currency, true)
    item:SetData({id = 1})
    item:UpdateNum(100)
    table.insert(self.currency, item)
  end
  self:InitGetWays()
end
function UIActivityGuidingItem:InitGetWays()
  local getWays = TableDataBase.listEventMediumGroupDatas:GetList()
  local isFirst = self.getWayList == nil
  if isFirst then
    self.getWayList = {}
  end
  for i = 1, getWays.Count do
    local getWay = getWays[i - 1]
    local item
    if isFirst then
      item = UIActivityGuidingGetWayItem.New()
      item:InitCtrl(self.ui.mObj_GetWay.gameObject, self.ui.mTrans_GetWay)
      table.insert(self.getWayList, item)
    else
      item = self.getWayList[i]
    end
    item:SetData(getWay)
  end
end
function UIActivityGuidingItem:OnHide()
end
function UIActivityGuidingItem:OnTop()
  self:OnShow()
end
function UIActivityGuidingItem:OnClose()
  self:ReleaseCtrlTable(self.currency, true)
  self.currency = nil
  self:ReleaseCtrlTable(self.getWayList, true)
  self.getWayList = nil
end
