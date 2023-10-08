require("UI.UIBaseCtrl")
UIBarrackSuitDropdownItem = class("UIBarrackSuitDropdownItem", UIBaseCtrl)
UIBarrackSuitDropdownItem.__index = UIBarrackSuitDropdownItem
function UIBarrackSuitDropdownItem:ctor()
  self.setId = 0
end
function UIBarrackSuitDropdownItem:__InitCtrl()
  self.mBtn_Suit = self:GetSelfButton()
  self.mText_Name = self:GetText("GrpText/Text_SuitName")
  self.mText_Num = self:GetText("GrpText/Text_SuitNum")
  self.mTrans_GrpSet = self:GetRectTransform("GrpSel")
  self.mImage_Element = self:GetImage("Trans_GrpElement/ImgIcon")
  self.textcolor = self.mUIRoot.transform:GetComponent("TextImgColor")
end
function UIBarrackSuitDropdownItem:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("Character/ChrEquipSuitDropdownItemV2.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, false)
  end
  self:SetRoot(obj.transform)
  self:__InitCtrl()
end
function UIBarrackSuitDropdownItem:SetData(setId)
  self.setId = setId
  if setId then
    local data = TableData.listEquipSetDatas:GetDataById(setId)
    self.mText_Name.text = data.name.str
    self.mText_Num.text = NetCmdEquipData:GetEquipListBySetId(data.id).Count
    setactive(self.mText_Num.gameObject, true)
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
function UIBarrackSuitDropdownItem:SetWeaponTypeData(typeId)
  self.setId = typeId
  if typeId then
    if typeId == 0 then
      self.mText_Name.text = TableData.GetHintById(101006)
    else
      local data = TableData.listGunWeaponTypeDatas:GetDataById(typeId)
      self.mText_Name.text = data.name.str
      self.mImage_Element.sprite = IconUtils.GetGunCharacterIcon(data.icon)
    end
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
function UIBarrackSuitDropdownItem:SetWeaponPartTypeData(typeId)
  self.setId = typeId
  if typeId then
    if typeId == 0 then
      self.mText_Name.text = TableData.GetHintById(101006)
    else
      local data = TableData.listWeaponModTypeDatas:GetDataById(typeId)
      self.mText_Name.text = data.name.str
      self.mImage_Element.sprite = IconUtils.GetWeaponPartIcon(data.icon)
    end
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
function UIBarrackSuitDropdownItem:SetWeaponPartSuitData(suitId, index)
  self.setId = suitId
  self.index = index
  if suitId then
    if suitId == 0 then
      self.mText_Name.text = TableData.GetHintById(1062)
    else
      local data = TableData.listModPowerDatas:GetDataById(suitId)
      self.mText_Name.text = data.name.str
      self.mImage_Element.sprite = IconUtils.GetWeaponPartIcon(data.image)
    end
    setactive(self.mText_Num.gameObject, true)
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
function UIBarrackSuitDropdownItem:HideNum()
  setactive(self.mText_Num.gameObject, false)
end
function UIBarrackSuitDropdownItem:SetSelect(isSelect)
  if isSelect then
    self.mText_Name.color = self.textcolor.AfterSelected
    self.mText_Num.color = self.textcolor.AfterSelected
  else
    self.mText_Name.color = self.textcolor.BeforeSelected
    self.mText_Num.color = self.textcolor.BeforeSelected
  end
  setactive(self.mTrans_GrpSet, isSelect)
end
function UIBarrackSuitDropdownItem:GetTypeName()
  return self.mText_Name.text
end
function UIBarrackSuitDropdownItem:GetTypeSprite()
  return self.mImage_Element.sprite
end
function UIBarrackSuitDropdownItem:UpdatePartCount(typeId)
  if self.setId == 0 then
    self.mText_Num.text = NetCmdWeaponPartsData:GetSuitCount(typeId, 0)
  else
    self.mText_Num.text = NetCmdWeaponPartsData:GetSuitCount(typeId, self.setId)
  end
end
function UIBarrackSuitDropdownItem:SetVisible(visible)
  setactive(self.mUIRoot, visible)
end
