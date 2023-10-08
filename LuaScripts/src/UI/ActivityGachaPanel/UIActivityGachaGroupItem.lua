require("UI.UIBaseCtrl")
UIActivityGachaGroupItem = class("UIActivityGachaGroupItem", UIBaseCtrl)
UIActivityGachaGroupItem.__index = UIActivityGachaGroupItem
UIActivityGachaGroupItem.ui = nil
UIActivityGachaGroupItem.mData = nil
function UIActivityGachaGroupItem:ctor(csPanel)
  self.super.ctor(self, csPanel)
end
function UIActivityGachaGroupItem:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab(ActivityGachaGlobal.GachaGroupItemPrefabPath, self))
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, true)
  end
  self:SetRoot(obj.transform)
  self.ui = {}
  self.mData = nil
  self:LuaUIBindTable(obj, self.ui)
  self.group = 0
  self.selectGroup = 0
  self.gachaId = 0
  UIUtils.GetButtonListener(self.ui.mBtn_ActivitieGachaTurnItem.gameObject).onClick = function()
    self:OnBtnClick()
  end
end
function UIActivityGachaGroupItem:SetData(gachaId, group, data, selectCallBack)
  self.gachaId = gachaId
  self.group = group
  self.selectCallBack = selectCallBack
  if not data then
    return
  end
  local haveSave = NetCmdActivityGachaData:HaveSaveGroupPrefs(gachaId, group)
  setactive(self.ui.mObj_RedPoint.gameObject, data.state == ActivityGachaGlobal.GroupState_Doing and not haveSave)
  setactive(self.ui.mTrans_Doing.gameObject, data.state == ActivityGachaGlobal.GroupState_Doing)
  setactive(self.ui.mTrans_Closed.gameObject, data.state == ActivityGachaGlobal.GroupState_Close)
  setactive(self.ui.mTrans_CanOpen.gameObject, false)
  self.ui.mText_Num.text = TableData.GetHintById(270117 + group - 1)
  self.ui.mImg_Num.sprite = IconUtils.GetAtlasV2(ActivityGachaGlobal.DaiyanIconPath, ActivityGachaGlobal.GachaGroupIcon .. group)
end
function UIActivityGachaGroupItem:SetSelect(group)
  self.selectGroup = group
  self.ui.mBtn_ActivitieGachaTurnItem.interactable = self.group ~= group
  if self.group == group then
    self:RefreshRedPoint()
  end
end
function UIActivityGachaGroupItem:OnBtnClick()
  if self.selectGroup == self.group then
    return
  end
  if not self.selectCallBack then
    return
  end
  self.selectCallBack(self.group)
end
function UIActivityGachaGroupItem:RefreshRedPoint()
  if not self.ui.mObj_RedPoint.gameObject.activeSelf then
    return
  end
  setactive(self.ui.mObj_RedPoint.gameObject, false)
  NetCmdActivityGachaData:SetGroupPrefs(self.gachaId, self.group)
end
