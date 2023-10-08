require("UI.UIBaseCtrl")
Btn_ActivityTourEnemyHeadItem = class("Btn_ActivityTourEnemyHeadItem", UIBaseCtrl)
Btn_ActivityTourEnemyHeadItem.__index = Btn_ActivityTourEnemyHeadItem
function Btn_ActivityTourEnemyHeadItem:ctor()
end
function Btn_ActivityTourEnemyHeadItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self.ui.mTrans_ActivityTourEnemyHeadItem.sizeDelta = vector2zero
  self:SetRoot(instObj.transform)
end
function Btn_ActivityTourEnemyHeadItem:SetBtnSelect(isSelect)
  self.ui.mBtn_Root.interactable = not isSelect
end
function Btn_ActivityTourEnemyHeadItem:SetData(id)
  local enemyData = TableData.listMonopolyEnemyDatas:GetDataById(id)
  if enemyData then
    self.ui.mImg_ChrHead.sprite = IconUtils.GetTourCharacterSprite(enemyData.chess_icon)
    self.ui.mImg_TeamColor.color = ColorUtils.StringToColor("d45133")
  end
end
function Btn_ActivityTourEnemyHeadItem:SetPlayerData(data)
  local playerData = TableData.listGunDatas:GetDataById(data.Id)
  if playerData then
    self.ui.mImg_ChrHead.sprite = IconUtils.GetTourCharacterSprite("Avatar_Head_" .. playerData.en_name.str)
    self.ui.mImg_TeamColor.color = ColorUtils.StringToColor("239cd6")
  end
end
function Btn_ActivityTourEnemyHeadItem:UpdateShow(isshow)
  setactive(self.ui.mTrans_ActivityTourEnemyHeadItem.gameObject, isshow)
end
function Btn_ActivityTourEnemyHeadItem:SetBtnEnable(isEnable)
  self.ui.mBtn_Root.enabled = isEnable
end
