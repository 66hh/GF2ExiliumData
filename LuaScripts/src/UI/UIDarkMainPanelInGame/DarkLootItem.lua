require("UI.UIBaseCtrl")
DarkLootItem = class("DarkLootItem", UIBaseCtrl)
DarkLootItem.__index = DarkLootItem
local self = DarkLootItem
function DarkLootItem:__InitCtrl()
end
function DarkLootItem:InitCtrl(parent, data)
  self.parent = parent.gameObject:GetComponent(typeof(CS.UnityEngine.RectTransform))
  self.data = data
  local instObj = data.View
  self.trans = instObj.gameObject:GetComponent(typeof(CS.UnityEngine.RectTransform))
  self:AddAsset(instObj)
  CS.LuaUIUtils.SetParent(instObj.gameObject, parent.gameObject, false)
  self:SetRoot(instObj.transform)
end
function DarkLootItem:UpdatePos()
  local pos = CS.SysMgr.dzGameMapMgr:LootTipPosByHostPos(self.data.DarkLootData.pos, self.parent)
  self.trans.anchoredPosition = pos
end
function DarkLootItem:RemoveSelf()
  GameObject.Destroy(self.trans.gameObject)
end
