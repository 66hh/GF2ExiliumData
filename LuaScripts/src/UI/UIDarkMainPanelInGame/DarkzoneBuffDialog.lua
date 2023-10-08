require("UI.UIDarkMainPanelInGame.DarkzoneBuffDialogView")
require("UI.UIBasePanel")
require("UI.UIDarkMainPanelInGame.DarkzoneBuffLeftTabItem")
require("UI.UIDarkMainPanelInGame.DarkzoneBuffListItem")
DarkzoneBuffDialog = class("DarkzoneBuffDialog", UIBasePanel)
DarkzoneBuffDialog.__index = DarkzoneBuffDialog
function DarkzoneBuffDialog:ctor(csPanel)
  DarkzoneBuffDialog.super.ctor(self, csPanel)
end
function DarkzoneBuffDialog:OnInit(root, data)
  DarkzoneBuffDialog.super.SetRoot(DarkzoneBuffDialog, root)
  self:InitBaseData(root, data)
  self:AddBtnListen()
  self:AddMsgListener()
  self:InitUI(data)
end
function DarkzoneBuffDialog:InitBaseData(root, data)
  self.mview = DarkzoneBuffDialogView.New()
  self.ui = {}
  self.ui.charLs = {}
  self.mview:InitCtrl(root, self.ui)
  function self.CloseFun()
    UIManager.CloseUI(UIDef.DarkzoneBuffDialog)
  end
  self.allBuffLs = {}
end
function DarkzoneBuffDialog:AddBtnListen()
  self.ui.mBtn_Close.onClick:AddListener(self.CloseFun)
  self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_Close)
end
function DarkzoneBuffDialog:AddMsgListener()
end
function DarkzoneBuffDialog:InitUI(data)
  local guns = data
  for i = 0, guns.Length - 1 do
    local gunId = guns[i]
    local darkzoneBuffLeftTabItem = DarkzoneBuffLeftTabItem.New()
    darkzoneBuffLeftTabItem:InitCtrl(self.ui.mTran_CharRoot.childItem, self.ui.mTran_CharRoot.transform)
    local showHelper = CS.SysMgr.dzPlayerMgr.MainPlayerData:GetGunShowBuffHelper(gunId)
    darkzoneBuffLeftTabItem:SetData(showHelper, self)
    self.ui.charLs[gunId] = darkzoneBuffLeftTabItem
  end
  local leader = CS.SysMgr.dzPlayerMgr.MainPlayerData.Leader
  self:ShowTarget(leader)
end
function DarkzoneBuffDialog:OnShowStart()
  local leader = CS.SysMgr.dzPlayerMgr.MainPlayerData.Leader
  self:ShowTarget(leader)
end
function DarkzoneBuffDialog:ShowTarget(target)
  for k, v in pairs(self.ui.charLs) do
    local select = target == k
    v:SetTarget(select)
    if select then
      self:ShowBuffDetail(v.mData)
    end
  end
end
function DarkzoneBuffDialog:ShowBuffDetail(showHelper)
  if showHelper.ShowBuffLs.Count == 0 then
    setactive(self.ui.mText_BuffEmpty.gameObject, true)
    setactive(self.ui.mTran_BuffRoot.gameObject, false)
  else
    setactive(self.ui.mText_BuffEmpty.gameObject, false)
    setactive(self.ui.mTran_BuffRoot.gameObject, false)
    self:RefreshBuffDetail(showHelper)
  end
end
function DarkzoneBuffDialog:RefreshBuffDetail(showHelper)
  setactive(self.ui.mTran_BuffRoot.gameObject, true)
  self.ui.mTran_BuffRoot.verticalNormalizedPosition = 1
  local allBuff = showHelper.ShowBuffLs
  for i = 1, #self.allBuffLs do
    local buffDetailItem = self.allBuffLs[i]
    buffDetailItem:SetNull()
  end
  local viewIndex = 1
  for i = allBuff.Count - 1, 0, -1 do
    local showData = allBuff[i]
    local buffDetailItem = self.allBuffLs[viewIndex]
    if buffDetailItem == nil then
      buffDetailItem = DarkzoneBuffListItem.New()
      buffDetailItem:InitCtrl(self.ui.mTran_BuffLs.childItem, self.ui.mTran_BuffLs.transform)
      self.allBuffLs[viewIndex] = buffDetailItem
    end
    buffDetailItem:SetData(showData)
    viewIndex = viewIndex + 1
  end
end
function DarkzoneBuffDialog:OnClose()
  self:UnRegistrationKeyboard(nil)
  self.ui.mBtn_Close.onClick:RemoveListener(self.CloseFun)
  self.CloseFun = nil
  for i = 1, #self.allBuffLs do
    local buffDetailItem = self.allBuffLs[i]
    buffDetailItem:OnClose()
  end
  self.allBuffLs = nil
  for k, v in pairs(self.ui.charLs) do
    v:OnClose()
  end
  self.ui.charLs = nil
  self.ui = nil
  self.mview = nil
end
