require("UI.UIBaseCtrl")
DarkZoneLeftTaskRootItem = class("DarkZoneLeftTaskRootItem", UIBaseCtrl)
DarkZoneLeftTaskRootItem.__index = DarkZoneLeftTaskRootItem
function DarkZoneLeftTaskRootItem:__InitCtrl()
end
function DarkZoneLeftTaskRootItem:InitCtrl(root, obj)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self.isShowChild = true
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self.ui.mBtn_Self.onClick:AddListener(function()
    self:OnClickBtn()
  end)
end
function DarkZoneLeftTaskRootItem:SetData(HintID)
  self.ui.mText_TextTittle.text = TableData.GetHintById(HintID)
end
function DarkZoneLeftTaskRootItem:OnClickBtn(select)
  if select ~= nil then
    self.isShowChild = select
  else
    self.isShowChild = not self.isShowChild
  end
  self.ui.mAnimator_Self:SetBool("Selected", self.isShowChild)
  setactive(self.ui.mTrans_Content, self.isShowChild)
end
function DarkZoneLeftTaskRootItem:OnClose()
  self:DestroySelf()
  self.ui = nil
  self.isShowChild = nil
end
