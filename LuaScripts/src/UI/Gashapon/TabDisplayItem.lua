require("UI.UIBaseCtrl")
TabDisplayItem = class("TabDisplayItem", UIBaseCtrl)
TabDisplayItem.__index = TabDisplayItem
TabDisplayItem.mImage_Normal = nil
TabDisplayItem.mImage_Highlighted = nil
TabDisplayItem.mImage_Selected = nil
TabDisplayItem.mText_Name = nil
TabDisplayItem.mBtn_GachaEventBtn = nil
function TabDisplayItem:__InitCtrl()
  self.mImage_Normal = self:GetImage("Image_Normal")
  self.mImage_Highlighted = self:GetImage("Image_Highlighted")
  self.mImage_Selected = self:GetImage("Image_Selected")
  self.mText_Name = self:GetText("Text_Name")
  self.mBtn_GachaEventBtn = self:GetSelfButton()
end
TabDisplayItem.mEventData = nil
function TabDisplayItem:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
end
function TabDisplayItem:InitData(data)
  self.mEventData = data
  self.mText_Name.text = data.Name
  self:SetSelect(false)
end
function TabDisplayItem:SetSelect(isSelect)
  self.mBtn_GachaEventBtn.interactable = not isSelect
end
