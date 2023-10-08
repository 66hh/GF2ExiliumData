require("UI.UIBaseCtrl")
DZQuoteItem = class("DZQuoteItem", UIBaseCtrl)
DZQuoteItem.__index = DZQuoteItem
function DZQuoteItem:__InitCtrl()
end
function DZQuoteItem:InitCtrl(root, prefab)
  local obj = instantiate(prefab)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  setactive(obj, true)
end
function DZQuoteItem:SetData(Data)
  self.mData = Data
  self.ui.mText_Name.text = Data.Name
  if Data.Range > 1000 then
    self.ui.mText_Num.text = math.floor((Data.Range - 1000) / 10) .. "%"
  else
    self.ui.mText_Num.text = math.floor((1000 - Data.Range) / 10) .. "%"
  end
end
function DZQuoteItem:OnUpdate()
  if self.mData ~= nil then
    if self.mData.Range > 1000 then
      self.ui.mAnim_Root:SetBool("Rise", true)
    else
      self.ui.mAnim_Root:SetBool("Rise", false)
    end
  end
end
