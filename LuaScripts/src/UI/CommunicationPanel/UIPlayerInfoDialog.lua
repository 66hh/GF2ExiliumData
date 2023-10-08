require("UI.CommanderInfoPanel.Item.UIPlayerInfoItem")
require("UI.UIBasePanel")
UIPlayerInfoDialog = class("UIPlayerInfoDialog", UIBasePanel)
UIPlayerInfoDialog.__index = UIPlayerInfoDialog
UIPlayerInfoDialog.playerInfoItem = nil
UIPlayerInfoDialog.playerInfo = nil
UIPlayerInfoDialog.robotInfo = nil
UIPlayerInfoDialog.isSearch = false
function UIPlayerInfoDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIPlayerInfoDialog.Close()
  UIManager.CloseUI(UIDef.UIPlayerInfoDialog)
end
function UIPlayerInfoDialog:OnInit(root, data)
  self.super.SetRoot(UIPlayerInfoDialog, root)
  if data[1] == nil then
    return
  end
  self.playerInfo = data[1]
  self.robotInfo = data[2]
  self.isSearch = data[3] or false
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  if self.playerInfoItem == nil then
    self.playerInfoItem = UIPlayerInfoItem.New()
    self.playerInfoItem.ui = {}
    self.playerInfoItem:SetRoot(self.mUIRoot.transform)
    self.playerInfoItem:LuaUIBindTable(self.mUIRoot, self.playerInfoItem.ui)
    self.playerInfoItem:ComCtrl()
  end
  function self.addBlackFunc(msg)
    self:Close()
  end
  MessageSys:AddListener(CS.GF2.Message.FriendEvent.AddBlack, self.addBlackFunc)
  MessageSys:AddListener(CS.GF2.Message.FriendEvent.FriendDel, self.addBlackFunc)
  MessageSys:AddListener(CS.GF2.Message.FriendEvent.FriendListChange, self.addBlackFunc)
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:Close()
  end
  self:UpdatePanel()
end
function UIPlayerInfoDialog:UpdatePanel()
  if self.playerInfoItem ~= nil then
    self.playerInfoItem:SetRobotData(self.robotInfo or nil)
    self.playerInfoItem:SetData(self.playerInfo)
    if self.isSearch then
      self.playerInfoItem:UpdateSearchInteractive()
    end
  end
end
function UIPlayerInfoDialog:OnClose()
  self.playerInfoItem:OnRelease()
  self.playerInfoItem = nil
  self.playerInfo = nil
  self.robotInfo = nil
  self.isSearch = false
  MessageSys:RemoveListener(CS.GF2.Message.FriendEvent.FriendDel, self.addBlackFunc)
  MessageSys:RemoveListener(CS.GF2.Message.FriendEvent.FriendListChange, self.addBlackFunc)
  MessageSys:RemoveListener(CS.GF2.Message.FriendEvent.AddBlack, self.addBlackFunc)
end
