require("UI.UIBasePanel")
UIWeaponBreakSuccPanel = class("UIWeaponBreakSuccPanel", UIBasePanel)
UIWeaponBreakSuccPanel.__index = UIWeaponBreakSuccPanel
UIWeaponBreakSuccPanel.stageItem = nil
UIWeaponBreakSuccPanel.attributeList = {}
function UIWeaponBreakSuccPanel:ctor(csPanel)
  UIWeaponBreakSuccPanel.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIWeaponBreakSuccPanel:Close()
  self = UIWeaponBreakSuccPanel
  UIManager.CloseUI(UIDef.UIWeaponBreakSuccPanel)
  if self.callback then
    self.callback()
  end
end
function UIWeaponBreakSuccPanel:OnRelease()
  self = UIWeaponBreakSuccPanel
  if UIWeaponBreakSuccPanel.stageItem then
    UIWeaponBreakSuccPanel.stageItem:OnRelease()
    UIWeaponBreakSuccPanel.stageItem = nil
  end
  UIWeaponBreakSuccPanel.attributeList = {}
end
function UIWeaponBreakSuccPanel:OnInit(root, data)
  self = UIWeaponBreakSuccPanel
  UIWeaponBreakSuccPanel.super.SetRoot(UIWeaponBreakSuccPanel, root)
  self.lvUpData = data[1]
  self.callback = data[2]
  self:InitView(root)
  UIWeaponBreakSuccPanel.super.SetPosZ(UIWeaponBreakSuccPanel)
  self:UpdatePanel()
end
function UIWeaponBreakSuccPanel:InitView(root)
  self.mUIRoot = root
  self.mBtn_Close = UIUtils.GetRectTransform(root, "Root/GrpBg/Btn_Close")
  self.mTrans_Stage = UIUtils.GetRectTransform(root, "Root/GrpDialog/GrpCenter/GrpLevelUp/GrpStage")
  self.mText_LevelUp = UIUtils.GetText(root, "Root/GrpDialog/GrpCenter/GrpLevelUp/Text_LevelUp")
  self.mTrans_Skill = UIUtils.GetRectTransform(root, "Root/GrpDialog/GrpCenter/GrpPowerUp/AttributeList/Viewport/Content/Trans_WeaponBreakSkill")
  self.mTrans_AttrList = UIUtils.GetRectTransform(root, "Root/GrpDialog/GrpCenter/GrpPowerUp/AttributeList/Viewport/Content")
  self.mImage_SkillIcon = UIUtils.GetImage(root, "Root/GrpDialog/GrpCenter/GrpPowerUp/AttributeList/Viewport/Content/Trans_WeaponBreakSkill/GrpContent/GrpList/Trans_GrpIcon/Img_Icon")
  self.mText_SkillName = UIUtils.GetText(root, "Root/GrpDialog/GrpCenter/GrpPowerUp/AttributeList/Viewport/Content/Trans_WeaponBreakSkill/GrpContent/GrpList/Text_Name")
  self.mText_SkillValue = UIUtils.GetText(root, "Root/GrpDialog/GrpCenter/GrpPowerUp/AttributeList/Viewport/Content/Trans_WeaponBreakSkill/GrpContent/Trans_GrpNumRight/Text_NumNow")
  self.mText_SkillUpValue = UIUtils.GetText(root, "Root/GrpDialog/GrpCenter/GrpPowerUp/AttributeList/Viewport/Content/Trans_WeaponBreakSkill/GrpContent/Trans_GrpNumRight/Text_NumAfter")
  self.mTrans_EffectBg = UIUtils.GetRectTransform(root, "Root/GrpDialog/GrpTittle/GrpBg/ImgBg1")
  self:InitStage()
  UIUtils.GetButtonListener(self.mBtn_Close.gameObject).onClick = function()
    self:Close()
  end
end
function UIWeaponBreakSuccPanel:InitStage()
  if self.stageItem == nil then
    self.stageItem = UICommonStageItem.New(UIWeaponGlobal.MaxStar)
    self.stageItem:InitCtrl(self.mTrans_Stage, true)
  end
end
function UIWeaponBreakSuccPanel:UpdatePanel()
  if self.lvUpData then
    self.stageItem:SetData(self.lvUpData.lastBreakTimes)
    self.stageItem:SetWeaponEffect(self.lvUpData.lastBreakTimes, self.lvUpData.breakTime, 1.33, 1.76)
    if self.lvUpData.attrList then
      for i = 1, #self.lvUpData.attrList do
        local item
        if i <= #self.attributeList then
          item = self.attributeList[i]
        else
          item = UICommonPropertyItem.New()
          item:InitCtrl(self.mTrans_AttrList)
          table.insert(self.attributeList, item)
        end
        item:SetData(self.lvUpData.attrList[i].data, self.lvUpData.attrList[i].value, false, true, true, false)
        item:SetValueUp(self.lvUpData.attrList[i].upValue)
      end
    end
    if self.lvUpData.skillList and #self.lvUpData.skillList > 0 then
      for i = 1, #self.lvUpData.skillList do
        local skill = self.lvUpData.skillList[i]
        self.mImage_SkillIcon.sprite = IconUtils.GetSkillIconSprite(skill.icon)
        self.mText_SkillName.text = skill.name.str
        self.mText_SkillUpValue.text = GlobalConfig.SetLvText(skill.level)
        self.mText_SkillValue.text = GlobalConfig.SetLvText(skill.level - 1)
      end
      setactive(self.mTrans_Skill, true)
      self.mTrans_Skill:SetAsLastSibling()
    else
      setactive(self.mTrans_Skill, false)
    end
  end
end
function UIWeaponBreakSuccPanel:SetEffectSortOrder(root)
  UIUtils.SetMeshRenderSortOrder(root.gameObject, UIManager.GetTopPanelSortOrder())
end
