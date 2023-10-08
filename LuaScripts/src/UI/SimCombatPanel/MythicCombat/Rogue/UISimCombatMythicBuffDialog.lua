require("UI.UIBasePanel")
UISimCombatMythicBuffDialog = class("UISimCombatMythicBuffDialog", UIBasePanel)
UISimCombatMythicBuffDialog.__index = UISimCombatMythicBuffDialog
local self = UISimCombatMythicBuffDialog
function UISimCombatMythicBuffDialog:ctor(csPanel)
  UISimCombatMythicBuffDialog.super:ctor(csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UISimCombatMythicBuffDialog:OnInit(root)
  self.super.SetRoot(UISimCombatMythicBuffDialog, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.curBuffItem = nil
  self.buffItemList = {}
  local thisPanel = self
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(self.super.mCSPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.gameObject).onClick = function()
    UIManager.CloseUI(self.super.mCSPanel)
  end
  self:SetBuffList()
end
function UISimCombatMythicBuffDialog:OnShowStart()
  self.ui.mAnimator_Root:SetTrigger("FadeIn")
end
function UISimCombatMythicBuffDialog:OnHide()
  self.ui.mAnimator_Root:SetTrigger("FadeOut")
  self.isHide = true
end
function UISimCombatMythicBuffDialog:SetBuffList()
  local curBuffs = NetCmdSimCombatRogueData.RogueStage.Buffs
  if curBuffs.Count == 0 then
    setactive(self.ui.mTrans_Empty, true)
    setactive(self.ui.mTrans_Center, false)
    return
  end
  setactive(self.ui.mTrans_Empty, false)
  setactive(self.ui.mTrans_Center, true)
  for i = 0, curBuffs.Count - 1 do
    do
      local item = SimCombatMythicBuffItem.New()
      item:InitCtrl(self.ui.mScrollListChild_Content)
      item:SetData(curBuffs[i])
      table.insert(self.buffItemList, item)
      UIUtils.GetButtonListener(item.ui.mBtn_Self.gameObject).onClick = function()
        self:OnClickBuffItem(item)
      end
    end
  end
  self:OnClickBuffItem(self.buffItemList[1])
end
function UISimCombatMythicBuffDialog:OnClickBuffItem(buff)
  if self.curBuffItem ~= nil then
    self.curBuffItem:SetSelect(false)
  end
  buff:SetSelect(true)
  self.curBuffItem = buff
  self.ui.mTextFit_Description.text = buff.rogueBuffData.BuffDescription
  self.ui.mText_Name.text = buff.rogueBuffData.Name
end
