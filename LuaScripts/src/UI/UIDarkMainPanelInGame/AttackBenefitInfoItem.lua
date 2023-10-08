require("UI.UIBaseCtrl")
AttackBenefitInfoItem = class("AttackBenefitInfoItem", UIBaseCtrl)
AttackBenefitInfoItem.__index = AttackBenefitInfoItem
function AttackBenefitInfoItem:InitCtrl(root, rootPanle)
  self.obj = instantiate(root.childItem, root.transform)
  self.ui = {}
  self:LuaUIBindTable(self.obj, self.ui)
  self.rootPanle = rootPanle
  if self.rootPanle == 1 then
    self.TextLs = {
      903477,
      903478,
      903479
    }
  elseif self.rootPanle == 2 then
    self.TextLs = {
      903466,
      903467,
      903468
    }
  end
  self.SpriteLs = {
    "Darkzone/Icon_AttackBenefit_Behind",
    "Darkzone/Icon_AttackBenefit_Cover",
    "Darkzone/Icon_AttackBenefit_BestDistance"
  }
end
function AttackBenefitInfoItem:SetDetail(type, target)
  setactive(self.obj.gameObject, true)
  self.ui.mImg_Icon.sprite = IconUtils.GetAtlasIcon(self.SpriteLs[type])
  if self.rootPanle == 1 then
    if type == 1 then
      local effectNum = TableData.GlobalDarkzoneData.DzShootRangeEffect[target.monsterTabledata.monster_type - 1]
      self.ui.mText_Attack.text = string_format(TableData.GetHintById(self.TextLs[type]), effectNum)
    elseif type == 2 then
      self.ui.mText_Attack.text = TableData.GetHintById(self.TextLs[type])
    elseif type == 3 then
      self.ui.mText_Attack.text = TableData.GetHintById(self.TextLs[type])
    end
  elseif self.rootPanle == 2 then
    self.ui.mText_Attack.text = TableData.GetHintById(self.TextLs[type])
  end
end
function AttackBenefitInfoItem:Close()
  setactive(self.obj.gameObject, false)
end
function AttackBenefitInfoItem:OnRelease()
  self.ui = nil
  gfdestroy(self.obj.gameObject)
  self.obj = nil
  self.TextLs = nil
  self.SpriteLs = nil
end
