require("UI.UIBasePanel")
require("UI.PVP.Item.UIPVPChallengeItemV2")
UIPVPChallengeRecordDialog = class("UIPVPChallengeRecordDialog", UIBasePanel)
UIPVPChallengeRecordDialog.__index = UIPVPChallengeRecordDialog
local self = UIPVPChallengeRecordDialog
function UIPVPChallengeRecordDialog:ctor(obj)
  UIPVPChallengeRecordDialog.super.ctor(self)
  obj.Type = UIBasePanelType.Dialog
end
function UIPVPChallengeRecordDialog:OnInit(root)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  setactive(self.ui.mTrans_RewardItem1.gameObject, false)
  UIUtils.GetButtonListener(self.ui.mBtn_BtnBack.gameObject).onClick = function()
    UIPVPGlobal.IsOpenPVPChallengeDialog = 0
    UIManager.CloseUI(UIDef.UIPVPChallengeRecordDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnHome.gameObject).onClick = function()
    UIPVPGlobal.IsOpenPVPChallengeDialog = 0
    UIManager.CloseUI(UIDef.UIPVPChallengeRecordDialog)
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnDescription.gameObject).onClick = function()
  end
  function self.ui.mVirtualListEx_List.itemProvider()
    return self:ItemProvider()
  end
  function self.ui.mVirtualListEx_List.itemRenderer(...)
    self:ItemRenderer(...)
  end
end
function UIPVPChallengeRecordDialog:OnShowStart()
  NetCmdPVPData:ReqPvpHistory(CS.ProtoCsmsg.CS_NrtPvpHistory.Types.PvpHistoryInfoType.Brief, 0, function(ret)
    if ret == ErrorCodeSuc then
      self:UpdateListPanel()
    end
  end)
end
function UIPVPChallengeRecordDialog:UpdateListPanel()
  local isEmpty = NetCmdPVPData.PvpHistoryInfo.Count == 0
  setactive(self.ui.mTrans_Empty, isEmpty)
  if isEmpty then
    AudioUtils.PlayCommonAudio(1020005)
  else
    AudioUtils.PlayCommonAudio(1020048)
  end
  self.ui.mVirtualListEx_List.numItems = NetCmdPVPData.PvpHistoryInfo.Count
  self.ui.mVirtualListEx_List:Refresh()
end
function UIPVPChallengeRecordDialog:ItemProvider()
  local itemView = UIPVPChallengeItemV2.New()
  itemView:InitCtrl(self.ui.mScrollListChild_Content)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIPVPChallengeRecordDialog:ItemRenderer(index, itemData)
  local pvpHistoryInfo = NetCmdPVPData.PvpHistoryInfo[index]
  local item = itemData.data
  item:SetData(pvpHistoryInfo, UIPVPGlobal.ButtonType.History)
end
function UIPVPChallengeRecordDialog:OnRelease()
end
