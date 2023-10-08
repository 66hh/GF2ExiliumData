require("UI.UIBaseCtrl")
DZComItem = class("DZChrItem", UIBaseCtrl)
DZComItem.__index = DZComItem
function DZComItem:__InitCtrl()
end
function DZComItem:InitCtrl(root)
  local com = ResSys:GetUIGizmos("UICommonFramework/ComItemV2.prefab", false)
  local obj = instantiate(com)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
end
function DZComItem:SetData(Data, Num)
  self.ui.mImage_Bg.sprite = IconUtils.GetQuiltyByRank(Data.rank)
  if 1 < Num then
    self.ui.mText_Num.text = Num
  else
    setactive(self.ui.mTrans_Num, false)
  end
  self.ui.mImage_Icon.sprite = ResSys:GetAtlasSprite("Icon/Item/" .. Data.icon)
  self.ui.mBtn_Select.interactable = false
end
