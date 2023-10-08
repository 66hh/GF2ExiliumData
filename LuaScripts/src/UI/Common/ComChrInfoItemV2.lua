require("UI.UIBaseCtrl")
ComChrInfoItemV2 = class("ComChrInfoItemV2", UIBaseCtrl)
ComChrInfoItemV2.__index = ComChrInfoItemV2
function ComChrInfoItemV2:ctor()
end
function ComChrInfoItemV2:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
end
function ComChrInfoItemV2:RefreshData(data)
  self.ui.mText_Level.text = data.Level
  self.ui.mImg_Icon.sprite = IconUtils.GetEnemyCharacterBustSprite(data.RobotTableData.character_pic)
  local color = TableData.GetGlobalGun_Quality_Color2(data.Rank)
  self.ui.mImg_Rank.color = color
end
