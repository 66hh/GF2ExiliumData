require("UI.PVP.Item.UIPVPRewardItem")
require("UI.UIBasePanel")
require("UI.PVP.Item.UIPVPRankItem")
require("UI.PVP.Item.UIPVPRankDialogTabItem")
UIPVPRewardDialog = class("UIPVPRewardDialog", UIBasePanel)
UIPVPRewardDialog.__index = UIPVPRewardDialog
local self = UIPVPRewardDialog
function UIPVPRewardDialog:ctor(obj)
  UIPVPRewardDialog.super.ctor(self)
  obj.Type = UIBasePanelType.Dialog
  self.leftTabItems = {}
end
function UIPVPRewardDialog:OnInit(root)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIPVPRewardDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIPVPRewardDialog)
  end
  for i = 1, TableData.listNrtpvpRewardDatas.Count do
    local leftTabItem = UIPVPRewardItem.New()
    leftTabItem:InitCtrl(self.ui.mTrans_Content, TableData.listNrtpvpRewardDatas[i - 1])
    table.insert(self.leftTabItems, leftTabItem)
  end
end
function UIPVPRewardDialog:OnShowStart()
end
function UIPVPRewardDialog:OnHide()
  self.isHide = true
end
function UIPVPRewardDialog:OnClose()
  self:ReleaseCtrlTable(self.leftTabItems)
end
