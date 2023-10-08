require("UI.UIBaseCtrl")
DZChrItemV2 = class("DZChrItemV2", UIBaseCtrl)
DZChrItemV2.__index = DZChrItemV2
function DZChrItemV2:__InitCtrl()
end
function DZChrItemV2:InitCtrl(root)
  local com = root:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  setactive(self.ui.mTrans_None, true)
  setactive(self.ui.mTrans_StaminaBar, false)
  setactive(self.ui.mTrans_Chr, false)
  setactive(self.ui.mTrans_LV, false)
  setactive(self.ui.mTrans_Progress, false)
end
function DZChrItemV2:SetData(gunCmdData)
  setactive(self.ui.mTrans_None, false)
  setactive(self.ui.mTrans_StaminaBar, true)
  setactive(self.ui.mTrans_Chr, true)
  self.ui.mText_ChrName.text = gunCmdData.TabGunData.Name.str
  local str = string_format(TableData.GetHintById(102250), gunCmdData.level)
  self.ui.mText_Lv.text = str
  local sprite = IconUtils.GetCharacterHeadSprite(IconUtils.cCharacterAvatarType_Avatar, gunCmdData.TabGunData.code)
  self.ui.mImg_Chr.sprite = sprite
  local str2 = string_format(TableData.GetHintById(112016), gunCmdData.DarkZoneEnergy, TableData.GlobalDarkzoneData.DarkzoneEnergylimit)
  self.ui.mText_StaminaNum.text = str2
end
