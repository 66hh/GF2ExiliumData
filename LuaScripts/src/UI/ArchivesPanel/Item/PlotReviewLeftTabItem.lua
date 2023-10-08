require("UI.Common.UICommonLeftTabItemV2")
require("UI.UIBaseCtrl")
PlotReviewLeftTabItem = class("PlotReviewLeftTabItem", UIBaseCtrl)
PlotReviewLeftTabItem.__index = PlotReviewLeftTabItem
function PlotReviewLeftTabItem:__InitCtrl()
end
function PlotReviewLeftTabItem:InitCtrl(root)
  local com = root:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self.ui.mBtn_Self.interactable = false
  local red = self.ui.mTrans_RedPoint:GetComponent(typeof(CS.ScrollListChild)).childItem
  instantiate(red, self.ui.mTrans_RedPoint)
end
function PlotReviewLeftTabItem:SetData(data)
  self.ui.mText_RandomNum.text = UICommonLeftTabItemV2.GetRandomNum()
  self.ui.mText_Name.text = TableData.GetHintById(110015)
end
