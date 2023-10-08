require("UI.UIBaseCtrl")
DarkZoneFavorItem = class("DarkZoneTeamItem", UIBaseCtrl)
DarkZoneFavorItem.__index = DarkZoneFavorItem
function DarkZoneFavorItem:__InitCtrl()
end
function DarkZoneFavorItem:InitCtrl(root, obj)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
end
function DarkZoneFavorItem:SetData(id, num, index)
  self:SetActive(true)
  setactive(self.ui.mTrans_Bg, index % 2 ~= 0)
  self.ui.mText_Name.text = TableData.listDarkzoneNpcDatas:GetDataById(id).name.str
  local str = ""
  if 0 < num then
    str = "+" .. tostring(num)
    self.ui.mText_Num.color = ColorUtils.BlueColor2
  else
    str = tostring(num)
    self.ui.mText_Num.color = ColorUtils.RedColor
  end
  self.ui.mText_Num.text = str
end
function DarkZoneFavorItem:OnClose()
  self:DestroySelf()
  self.ui = nil
end
