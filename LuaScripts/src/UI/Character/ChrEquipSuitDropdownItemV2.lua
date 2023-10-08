ChrEquipSuitDropdownItemV2 = class("ChrEquipSuitDropdownItemV2", UIBaseCtrl)
ChrEquipSuitDropdownItemV2.__index = ChrEquipSuitDropdownItemV2
ChrEquipSuitDropdownItemV2.mText_SuitName = nil
ChrEquipSuitDropdownItemV2.mText_SuitNum = nil
function ChrEquipSuitDropdownItemV2:__InitCtrl()
  self.mText_SuitName = self:GetText("GrpText/Text_SuitName")
  self.mText_SuitNum = self:GetText("GrpText/Text_SuitNum")
  self.mTrans_GrpSet = self:GetRectTransform("GrpSel")
  self.mSp_Icon = self:GetImage("Trans_GrpElement/ImgIcon")
  self.mTrans_IconRoot = self:GetRectTransform("Trans_GrpElement")
end
ChrEquipSuitDropdownItemV2.sortId = nil
function ChrEquipSuitDropdownItemV2:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
  self.mBtn_Select = self:GetSelfButton()
end
function ChrEquipSuitDropdownItemV2:SetData(data, callback)
  self.mData = data
  self.mText_SuitName.text = data.name.str
  self.mText_SuitNum.text = #UIRepositoryDecomposePanelV2.listToTable(NetCmdEquipData:GetEquipListBySetId(data.id))
  UIUtils.GetButtonListener(self.mBtn_Select.gameObject).onClick = function()
    if callback then
      callback(self)
    end
  end
end
function ChrEquipSuitDropdownItemV2:SetZeroData(num, callback)
  self.id = 0
  self.mText_SuitName.text = TableData.GetHintById(1051)
  self.mText_SuitNum.text = num
  UIUtils.GetButtonListener(self.mBtn_Select.gameObject).onClick = function()
    if callback then
      callback(self)
    end
  end
end
function ChrEquipSuitDropdownItemV2:SetIconSprite(sprite)
  self.mSp_Icon.sprite = sprite
end
function ChrEquipSuitDropdownItemV2:SetIconVisible(visible)
  setactive(self.mTrans_IconRoot, visible)
end
function ChrEquipSuitDropdownItemV2:SetVisible(visible)
  setactive(self.mUIRoot, visible)
end
function ChrEquipSuitDropdownItemV2:OnRelease()
  self.super.OnRelease(self)
end
