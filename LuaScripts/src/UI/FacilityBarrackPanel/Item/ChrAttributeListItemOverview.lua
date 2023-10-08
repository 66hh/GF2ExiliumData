require("UI.UIBaseCtrl")
ChrAttributeListItemOverview = class("ChrAttributeListItemOverview", UIBaseCtrl)
ChrAttributeListItemOverview.__index = ChrAttributeListItemOverview
function ChrAttributeListItemOverview:ctor()
  self.mLanguagePropertyData = nil
  self.mData = nil
end
function ChrAttributeListItemOverview:InitCtrl(parent, obj)
  local instObj
  if obj == nil then
    local itemPrefab = parent.gameObject:GetComponent(typeof(CS.ScrollListChild))
    instObj = instantiate(itemPrefab.childItem)
  else
    instObj = obj
  end
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
end
function ChrAttributeListItemOverview:SetData(data, value)
  if data then
    self.mLanguagePropertyData = data
    self.mData = data
    self.value = value
    if self.mLanguagePropertyData.show_type == 2 then
      value = FacilityBarrackGlobal.PercentValue(value, 0)
    end
    self.ui.mText_TextNum.text = value
    self.ui.mImg_Icon.sprite = IconUtils.GetAttributeIcon(self.mLanguagePropertyData.icon .. "_64")
  else
    self.mLanguagePropertyData = nil
    self.mData = nil
  end
end
