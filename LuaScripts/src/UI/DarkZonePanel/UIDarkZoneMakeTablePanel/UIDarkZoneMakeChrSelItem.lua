require("UI.UIBaseCtrl")
UIDarkZoneMakeChrSelItem = class("UIDarkZoneMakeChrSelItem", UIBaseCtrl)
UIDarkZoneMakeChrSelItem.__index = UIDarkZoneMakeChrSelItem
UIDarkZoneMakeChrSelItem.ui = nil
UIDarkZoneMakeChrSelItem.mData = nil
function UIDarkZoneMakeChrSelItem:ctor(csPanel)
  self.super.ctor(self, csPanel)
end
function UIDarkZoneMakeChrSelItem:InitCtrl(parent)
  local com = parent:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem)
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, true)
  end
  self:SetRoot(obj.transform)
  self.ui = {}
  self.gunId = 0
  self:LuaUIBindTable(obj, self.ui)
  self.callBack = nil
  UIUtils.GetButtonListener(self.ui.mBtn_Click.gameObject).onClick = function()
    self:OnBtnSelect()
  end
end
function UIDarkZoneMakeChrSelItem:SetData(formulaId, gunId, callBack)
  self.formulaId = formulaId
  self.gunId = gunId
  self.callBack = callBack
  self:RefreshContent()
end
function UIDarkZoneMakeChrSelItem:OnRelease()
  self.gunId = 0
  self.callBack = nil
  self.super.OnRelease(self)
  self.ui = nil
end
function UIDarkZoneMakeChrSelItem:RefreshContent()
  setactive(self.ui.mTrans_Info.gameObject, self.gunId > 0)
  setactive(self.ui.mTrans_None.gameObject, self.gunId <= 0)
  if self.gunId <= 0 then
    return
  end
  local data
  for i = 0, TableData.listDarkzoneWishCreateCharacterDatas.Count - 1 do
    local tempData = TableData.listDarkzoneWishCreateCharacterDatas:GetDataByIndex(i)
    if tempData.gun_id == self.gunId and tempData.create_id == self.formulaId then
      data = tempData
      break
    end
  end
  self.ui.mText_Des.text = data and data.des.str or TableData.GetHintById(240106)
  local gunData = TableData.GetGunData(self.gunId)
  if gunData then
    self.ui.mImg_Icon.sprite = IconUtils.GetCharacterHeadSprite(gunData.code)
    self.ui.mText_Name.text = gunData.name.str
    local dutyData = TableData.listGunDutyDatas:GetDataById(gunData.duty)
    self.ui.mText_Type.text = string_format(TableData.GetHintById(240105), dutyData.name.str)
  end
end
function UIDarkZoneMakeChrSelItem:OnBtnSelect()
  if not self.callBack then
    return
  end
  self.callBack(self.gunId)
end
function UIDarkZoneMakeChrSelItem:SetSelect(selectId)
  self.ui.mBtn_Click.interactable = selectId ~= self.gunId
end
