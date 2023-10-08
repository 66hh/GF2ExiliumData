require("UI.UIBaseCtrl")
UIPVPMainLeftTabItem = class("UIPVPMainLeftTabItem", UIBaseCtrl)
UIPVPMainLeftTabItem.__index = UIPVPMainLeftTabItem
local self = UIPVPMainLeftTabItem
function UIPVPMainLeftTabItem:ctor()
  self.leftTab = UIPVPGlobal.LeftTabList.Rank
end
function UIPVPMainLeftTabItem:InitCtrl(obj, leftTab)
  self.leftTab = leftTab
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self.systemID = self:GetSystemID()
  if self.systemID < 0 then
    setactive(self.ui.mTrans_ImgLocked.gameObject, true)
    setactive(self.ui.mTrans_ImgIcon.gameObject, false)
    self.ui.mText_Title.color = Color(0.9372549019607843, 0.9372549019607843, 0.9372549019607843, 0.26666666666666666)
  else
    local funcOpen = AccountNetCmdHandler:CheckSystemIsUnLock(self.systemID)
    setactive(self.ui.mTrans_ImgLocked.gameObject, not funcOpen)
    setactive(self.ui.mTrans_ImgIcon.gameObject, funcOpen)
    if funcOpen then
      self.ui.mText_Title.color = Color(0.9372549019607843, 0.9372549019607843, 0.9372549019607843, 1)
    else
      self.ui.mText_Title.color = Color(0.9372549019607843, 0.9372549019607843, 0.9372549019607843, 0.26666666666666666)
    end
  end
  self:SetRoot(obj.transform)
  UIUtils.GetButtonListener(self.ui.mBtn_LeftTabItemSelf.gameObject).onClick = function()
    self:OnClickSelfBtn()
  end
end
function UIPVPMainLeftTabItem:GetSystemID()
  local systemID = 0
  if self.leftTab == UIPVPGlobal.LeftTabList.Rank then
    systemID = 14006
  elseif self.leftTab == UIPVPGlobal.LeftTabList.Record then
    systemID = 14005
  elseif self.leftTab == UIPVPGlobal.LeftTabList.Store then
    systemID = 14001
  elseif self.leftTab == UIPVPGlobal.LeftTabList.Robot then
    systemID = 14007
  elseif self.leftTab == UIPVPGlobal.LeftTabList.unOPen then
    systemID = -1
  end
  return systemID
end
function UIPVPMainLeftTabItem:OnClickSelfBtn()
  if self.systemID == -1 then
    PopupMessageManager.PopupString(TableData.GetHintById(120208))
    return
  end
  if self.systemID > 0 and not AccountNetCmdHandler:CheckSystemIsUnLock(self.systemID) then
    local unlockData = TableDataBase.listUnlockDatas:GetDataById(self.systemID, true)
    local str = UIUtils.CheckUnlockPopupStr(unlockData)
    PopupMessageManager.PopupString(str)
    return
  end
  if self.leftTab == UIPVPGlobal.LeftTabList.Rank then
    UIManager.OpenUI(UIDef.UIPVPRankDialog)
  elseif self.leftTab == UIPVPGlobal.LeftTabList.Record then
    UIPVPGlobal.IsOpenPVPChallengeDialog = UIDef.UIPVPChallengeRecordDialog
    UIManager.OpenUI(UIDef.UIPVPChallengeRecordDialog)
  elseif self.leftTab == UIPVPGlobal.LeftTabList.Store then
    UIManager.OpenUIByParam(UIDef.UIPVPStoreExchangePanel, {
      CS.GF2.Data.StoreTagType.Pvp,
      25
    })
  elseif self.leftTab == UIPVPGlobal.LeftTabList.Robot then
    NetCmdPVPData:ReqNrtPvpRobots(function(ret)
      if ret == ErrorCodeSuc then
        UIManager.OpenUI(UIDef.PVPMacineYardPanel)
      end
    end)
  elseif self.leftTab == UIPVPGlobal.LeftTabList.Title then
    UIManager.OpenUI(UIDef.UIPVPRankRewardDialog)
  end
end
function UIPVPMainLeftTabItem:UpdateRedPoint(enable)
  setactive(self.ui.mTrans_LeftTabItemRedPoint.transform.parent.gameObject, enable)
end
function UIPVPMainLeftTabItem:SetRedPoint(Show)
  setactive(self.ui.mTrans_LeftTabItemRedPoint, Show)
end
