require("UI.UIBaseCtrl")
DZWeaponPartItem = class("DZWeaponPartItem", UIBaseCtrl)
DZWeaponPartItem.__index = DZWeaponPartItem
function DZWeaponPartItem:__InitCtrl()
end
function DZWeaponPartItem:InitCtrl(root)
  local child = root:GetComponent(typeof(CS.ScrollListChild))
  local com = instantiate(child.childItem)
  local obj = instantiate(com)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
end
function DZWeaponPartItem:SetData(Data, Level, stcData)
  if not Data then
    return
  end
  setactive(self.ui.mTrans_Lock, false)
  setactive(self.ui.mTrans_Equipped_HasParts, false)
  setactive(self.ui.mTrans_Equipped_InWeapon, false)
  setactive(self.ui.mImage_Head, false)
  local dataSuit = TableData.listModPowerDatas:GetDataById(Data.suitId)
  if dataSuit then
    self.ui.mImage_SuitIcon.sprite = IconUtils.GetWeaponPartIcon(dataSuit.image)
    setactive(self.ui.mTrans_SuitRoot, true)
  end
  self.ui.mImage_Rank2.sprite = IconUtils.GetWeaponQuiltyByRank(Data.rank)
  self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(Data.rank)
  self.ui.mImage_Icon.sprite = ResSys:GetAtlasSprite("Icon/WeaponPart/" .. Data.icon)
  if Data.level then
    self.ui.mText_Count.text = GlobalConfig.SetLvText(Data.level)
    setactive(self.ui.mText_Count.gameObject, true)
  else
    setactive(self.ui.mText_Count.gameObject, false)
  end
  if stcData then
    TipsManager.Add(self.ui.mBtn_Part.gameObject, stcData)
  end
end
