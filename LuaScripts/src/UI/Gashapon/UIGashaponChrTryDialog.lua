require("UI.UIBasePanel")
require("UI.Gashapon.UIGashaponChrTryDialogView")
UIGashaponChrTryDialog = class("UIGashaponChrTryDialog", UIBasePanel)
UIGashaponChrTryDialog.__index = UIGashaponChrTryDialog
UIGashaponChrTryDialog.mView = nil
UIGashaponChrTryDialog.mStageItems = nil
function UIGashaponChrTryDialog:ctor(csPanel)
  self.super.ctor(self)
  self.csPanel = csPanel
  csPanel.Is3DPanel = true
end
function UIGashaponChrTryDialog.Open()
  UIManager.OpenUI(UIDef.UIGashaponChrTryDialog)
end
function UIGashaponChrTryDialog.Close()
  UIManager.CloseUIByChangeScene(UIDef.UIGashaponChrTryDialog)
end
function UIGashaponChrTryDialog:OnRecover()
  FacilityBarrackGlobal:SwitchCameraPos(BarrackCameraStand.Base, false)
  CS.UIBarrackModelManager.Instance:SetCurModelLock(false)
end
function UIGashaponChrTryDialog:OnCameraStart()
  return 0.01
end
function UIGashaponChrTryDialog:OnCameraBack()
  return 0.01
end
function UIGashaponChrTryDialog:OnInit(root, data)
  self.super.SetRoot(UIGashaponChrTryDialog, root)
  self.mData = data
  gfwarning(self.mData.name.str)
  self.mView = UIGashaponChrTryDialogView.New()
  self.ui = {}
  self.mView:LuaUIBindTable(self.mUIRoot, self.ui)
  self.mView:InitCtrl(root, self.ui)
  self.ui.mBtn_Close.interactable = true
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIGashaponChrTryDialog)
  end
  self:InitStage()
end
function UIGashaponChrTryDialog:InitStage()
  local template = self.ui.mScrollListChild_Content.childItem
  local strList = string.split(self.mData.gun_up_character_stage, ",")
  self.mStageItems = {}
  for _, id in pairs(strList) do
    local stageData = TableData.listStageDatas:GetDataById(tonumber(id))
    local go = instantiate(template, self.ui.mScrollListChild_Content.transform)
    local textName = go.transform:Find("Text"):GetComponent("Text")
    textName.text = stageData.name.str
    UIUtils.GetButtonListener(go).onClick = function()
      SceneSys:OpenBattleSceneForGacha(stageData)
    end
    table.insert(self.mStageItems, go)
  end
end
function UIGashaponChrTryDialog:OnClose()
  for i = 1, #self.mStageItems do
    gfdestroy(self.mStageItems[i])
  end
  self.mStageItems = {}
  if FacilityBarrackGlobal.EffectNumAnimator ~= nil then
    setactive(FacilityBarrackGlobal.EffectNumAnimator, true)
  end
end
