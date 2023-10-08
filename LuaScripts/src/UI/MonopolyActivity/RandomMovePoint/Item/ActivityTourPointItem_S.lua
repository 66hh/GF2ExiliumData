require("UI.UIBaseCtrl")
require("UI.MonopolyActivity.ActivityTourGlobal")
ActivityTourPointItem_S = class("ActivityTourPointItem_S", UIBaseCtrl)
ActivityTourPointItem_S.__index = ActivityTourPointItem_S
ActivityTourPointItem_S.ui = nil
ActivityTourPointItem_S.mData = nil
function ActivityTourPointItem_S:ctor(csPanel)
  self.super.ctor(self, csPanel)
end
function ActivityTourPointItem_S:InitCtrl(parent)
  local com = parent:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem, parent)
  self:SetRoot(obj.transform)
  self.ui = {}
  self.mData = nil
  self:LuaUIBindTable(obj, self.ui)
  self.oriColor = ColorUtils.StringToColor("AFAFAF")
  self.selColor = ColorUtils.StringToColor("EFEFEF")
  self.finalColor = ColorUtils.StringToColor("0F1A1E")
end
function ActivityTourPointItem_S:Refresh(point)
  self.ui.mImg_Point.sprite = ActivityTourGlobal.GetActivityTourSprite(ActivityTourGlobal.PointPath .. point)
  self.ui.mImg_Point.color = self.oriColor
  setactive(self.ui.mImg_Select.gameObject, false)
  setactive(self.ui.mImg_SelectFinal.gameObject, false)
end
function ActivityTourPointItem_S:RefreshEmpty(bEmpty)
  setactive(self.ui.mImg_SelectFinal.gameObject, false)
  setactive(self.ui.mTrans_Empty.gameObject, bEmpty)
  setactive(self.ui.mTrans_Content.gameObject, not bEmpty)
end
function ActivityTourPointItem_S:SelectPoint(bSelect)
  setactive(self.ui.mImg_Select.gameObject, bSelect)
  self.ui.mImg_Point.color = bSelect and self.selColor or self.oriColor
end
function ActivityTourPointItem_S:SetFinalColor(bSelect)
  self.ui.mImg_Point.color = bSelect and self.finalColor or self.oriColor
  setactive(self.ui.mImg_SelectFinal.gameObject, bSelect)
  setactive(self.ui.mImg_Select.gameObject, false)
end
