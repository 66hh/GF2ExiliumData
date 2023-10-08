require("UI.UIBaseCtrl")
UIDarkZoneSeasonQuestTabItem = class("UIDarkZoneSeasonQuestTabItem", UIBaseCtrl)
UIDarkZoneSeasonQuestTabItem.__index = UIDarkZoneSeasonQuestTabItem
function UIDarkZoneSeasonQuestTabItem:__InitCtrl()
end
function UIDarkZoneSeasonQuestTabItem:InitCtrl(root)
  local itemPrefab = root:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self:SetRoot(instObj.transform)
  if root then
    CS.LuaUIUtils.SetParent(instObj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Root.gameObject).onClick = function()
    self:OnClick()
  end
end
function UIDarkZoneSeasonQuestTabItem:SetData(data)
  self.mData = data
  if data ~= nil then
    self.ui.mText_Name.text = data.type.str
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
function UIDarkZoneSeasonQuestTabItem:SetClickFunction(func)
  self.clickFunction = func
end
function UIDarkZoneSeasonQuestTabItem:OnClick()
  if self.clickFunction then
    self.clickFunction(self)
  end
end
function UIDarkZoneSeasonQuestTabItem:OnRelease(isDestroy)
  self.super.OnRelease(self, true)
end
