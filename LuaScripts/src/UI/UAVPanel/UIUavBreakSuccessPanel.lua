require("UI.UAVPanel.UIUavBreakSuccessPanelView")
require("UI.UIBasePanel")
UIUavBreakSuccessPanel = class("UIUavBreakSuccessPanel", UIBasePanel)
UIUavBreakSuccessPanel.__index = UIUavBreakSuccessPanel
UIUavBreakSuccessPanel.mview = nil
function UIUavBreakSuccessPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIUavBreakSuccessPanel:OnAwake(root, data)
  self:SetRoot(root)
  self.mview = UIUavBreakSuccessPanelView.New()
  self.ui = {}
  self.mview:InitCtrl(root, self.ui)
  self.itemViewTable = {}
end
function UIUavBreakSuccessPanel:OnInit(root, data)
  self.data = data
  self.ui.mText_NowLevel.text = tostring(data.fromlv)
  self.ui.mText_NextLevel.text = tostring(data.tolv)
  setactive(self.ui.mTrans_Skip, false)
  TimerSys:DelayCall(1.75, function(data)
    setactive(self.ui.mTrans_Skip, true)
    self:AddCloseBtnListener()
  end)
  for i = 1, #self.data[1] do
    local item = UAVBreakAttributeItem.New()
    local data = {}
    data.name = self.data[1][i].name
    data.now = self.data[1][i].nownum
    data.next = self.data[1][i].tonum
    item:InitCtrl(self.ui.mTrans_Content)
    item:SetData(data)
    table.insert(self.itemViewTable, item)
  end
end
function UIUavBreakSuccessPanel:OnShowStart()
  self:SetEffectSortOrder(self.ui.mTrans_EffectBg)
end
function UIUavBreakSuccessPanel:OnClose()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = nil
  self:ReleaseCtrlTable(self.itemViewTable, true)
end
function UIUavBreakSuccessPanel:OnRelease()
  self.ui = nil
  self.mview = nil
  self.data = nil
end
function UIUavBreakSuccessPanel:AddCloseBtnListener()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIUavBreakSuccessPanel)
  end
end
function UIUavBreakSuccessPanel:SetEffectSortOrder(root)
  local sortorder = self.mview.mUIRoot.gameObject:GetComponent("Canvas").sortingOrder
  if sortorder ~= nil then
    UIUtils.SetMeshRenderSortOrder(root.gameObject, sortorder)
  end
end
