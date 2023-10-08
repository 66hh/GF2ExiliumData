require("UI.UIBaseCtrl")
DarkMainPanelInGameQuickItem = class("DarkMainPanelInGameQuickItem", UIBaseCtrl)
DarkMainPanelInGameQuickItem.__index = DarkMainPanelInGameQuickItem
function DarkMainPanelInGameQuickItem:InitCtrl(root, parent)
  local com = root:GetComponent(typeof(CS.ScrollListChild))
  self.obj = instantiate(com.childItem)
  if root then
    CS.LuaUIUtils.SetParent(self.obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(self.obj, self.ui)
  self:SetRoot(self.obj.transform)
  self.ui.mBtn_Select.onClick:AddListener(function()
    if self.mData ~= nil then
      CS.PbProxyMgr.dzOpProxy:SendCureCS_DarkZoneOp(self.mData.itemID)
      parent:ClickQuickItemArrow()
      CS.UnityEngine.Debug.Log("select item" .. self.mData.itemID)
    end
  end)
end
function DarkMainPanelInGameQuickItem:SetData(Data)
  self.mData = Data
  self.ui.mImg_Item.sprite = ResSys:GetUIResAIconSprite(self.mData.itemdata.icon_path .. "/" .. self.mData.itemdata.icon .. ".png")
  self.ui.mText_Num.text = self.mData.num
end
function DarkMainPanelInGameQuickItem:OnRelease()
  self.ui = nil
  self.mview = nil
  self.mData = nil
end
