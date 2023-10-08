require("UI.UIBaseCtrl")
UAVBreakAttributeItem = class("UAVBreakAttributeItem", UIBaseCtrl)
UAVBreakAttributeItem.__index = UAVBreakAttributeItem
function UAVBreakAttributeItem:__InitCtrl()
end
function UAVBreakAttributeItem:InitCtrl(root)
  local com = root:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  setactive(self.ui.mText_Num, false)
  setactive(self.ui.mTrans_GrpNumRight, true)
end
function UAVBreakAttributeItem:SetData(Data)
  self.ui.mText_Name.text = Data.name
  self.ui.mText_NumNow.text = Data.now
  self.ui.mText_NumAfter.text = Data.next
end
