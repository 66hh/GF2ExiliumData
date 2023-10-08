ChrBarrackSkillItem = class("ChrBarrackSkillItem", UIBaseCtrl)
ChrBarrackSkillItem.__index = ChrBarrackSkillItem
function ChrBarrackSkillItem:ctor()
  self.mBattleSkillData = nil
end
function ChrBarrackSkillItem:InitCtrl(parent, obj)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj
  if obj == nil then
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
function ChrBarrackSkillItem:SetData(skillId, callback)
  self.mBattleSkillData = TableData.listBattleSkillDatas:GetDataById(skillId)
  local skillData = self.mBattleSkillData
  self.ui.mText_SkillLevel.text = string_format(TableData.GetHintById(160039), skillData.level)
  self.ui.mImg_SkillIcon.sprite = IconUtils.GetSkillIconByAttr(skillData.icon, skillData.icon_attr_type)
  self.ui.mBtn_ChrBarrackSkillItemV2.interactable = callback ~= nil
  local elementTag = CS.GF2.Battle.SkillUtils.GetDisplaySkillElement(self.mBattleSkillData.id)
  if elementTag < 0 then
    elementTag = CS.GF2.Battle.SkillUtils.GetSkillElement(self.mBattleSkillData.id)
  end
  setactive(self.ui.mTrans_Element, 0 < elementTag)
  if 0 < elementTag then
    local elementData = TableData.listLanguageElementDatas:GetDataById(elementTag)
    self.ui.mImg_Element.sprite = IconUtils.GetElementIcon(elementData.icon .. "_Weakpoint")
  end
  setactive(self.ui.mTrans_ImgFrame, self.mBattleSkillData.IsPassiveSkill == false)
  UIUtils.GetButtonListener(self.ui.mBtn_ChrBarrackSkillItemV2.gameObject).onClick = function()
    if callback ~= nil then
      callback()
    end
  end
end
function ChrBarrackSkillItem:SetRedPoint(enabled)
  local redPoint = self.ui.mObj_GrpSkillRedPoint.transform
  setactive(redPoint, enabled)
  setactive(redPoint.parent, enabled)
end
function ChrBarrackSkillItem:OnClose()
end
function ChrBarrackSkillItem:OnRelease()
  self.super.OnRelease(self)
end
