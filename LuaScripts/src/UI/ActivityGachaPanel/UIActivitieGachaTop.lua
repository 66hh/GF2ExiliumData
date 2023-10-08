require("UI.UIBaseCtrl")
UIActivitieGachaTop = class("UIActivitieGachaTop", UIBaseCtrl)
UIActivitieGachaTop.__index = UIActivitieGachaTop
UIActivitieGachaTop.ui = nil
UIActivitieGachaTop.mData = nil
function UIActivitieGachaTop:ctor(csPanel)
  self.super.ctor(self, csPanel)
end
function UIActivitieGachaTop:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab(ActivityGachaGlobal.GachaTopPrefabPath, self))
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, true)
  end
  self:SetRoot(obj.transform)
  self.ui = {}
  self.mData = nil
  self:LuaUIBindTable(obj, self.ui)
end
function UIActivitieGachaTop:Refresh(group)
  self.ui.mText_Num.text = TableData.GetHintById(270117 + group - 1)
  self.ui.mImg_Num.sprite = IconUtils.GetAtlasV2(ActivityGachaGlobal.DaiyanIconPath, ActivityGachaGlobal.GachaGroupIcon .. group)
end
