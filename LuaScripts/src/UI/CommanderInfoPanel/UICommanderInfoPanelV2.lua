require("UI.UICommonModifyPanel.UICommanderInfoCardItemV2")
require("UI.CommanderInfoPanel.UICommanderInfoPanelV2View")
require("UI.Common.UICommonLeftTabItemV2")
require("UI.UIBasePanel")
UICommanderInfoPanelV2 = class("UICommanderInfoPanelV2", UIBasePanel)
UICommanderInfoPanelV2.__index = UICommanderInfoPanelV2
UICommanderInfoPanelV2.mView = nil
UICommanderInfoPanelV2.mData = nil
UICommanderInfoPanelV2.curTab = 0
UICommanderInfoPanelV2.curPanel = 0
UICommanderInfoPanelV2.tabList = {}
UICommanderInfoPanelV2.tabGoList = {}
UICommanderInfoPanelV2.playerInfoItem = nil
UICommanderInfoPanelV2.TAB = {
  PlayerInfo = 1,
  Achievement = 2,
  Settings = 3
}
function UICommanderInfoPanelV2:ctor()
  UICommanderInfoPanelV2.super.ctor(self)
end
function UICommanderInfoPanelV2:CloseUICommanderInfoPanelV2()
  self.curTab = 0
  UIManager.CloseUI(UIDef.UICommanderInfoPanel)
end
function UICommanderInfoPanelV2:OnInit(root, data)
  UICommanderInfoPanelV2.super.SetRoot(UICommanderInfoPanelV2, root)
  self.mData = data
  self.mView = UICommanderInfoPanelV2View.New()
  self.ui = {}
  self.mView:InitCtrl(self.mUIRoot, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    if self.playerInfoItem and self.playerInfoItem.supportList and self.ui.mTrans_SupChrReplace.gameObject.activeSelf then
      self.playerInfoItem.supportList:CloseSupportGunList()
    else
      self:CloseUICommanderInfoPanelV2()
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    CS.BattlePerformSetting.RefreshGraphicSetting()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_ExitGame.gameObject).onClick = function()
    CS.LuaUtils.ExitGame()
  end
  self:InitTabButton()
  self:OnClickTab(UICommanderInfoPanelV2.TAB.PlayerInfo)
end
function UICommanderInfoPanelV2:OnShowStart()
  local lastTab = self.curTab
  self.curTab = 0
  self:OnClickTab(lastTab)
end
function UICommanderInfoPanelV2:OnHide()
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.RefreshSgin, function()
    UICommanderInfoPanelV2:RefreshPanel()
  end)
end
function UICommanderInfoPanelV2:OnSave()
  self:OnRelease()
end
function UICommanderInfoPanelV2:OnRecover()
  self:OnShowStart()
end
function UICommanderInfoPanelV2:OnRelease()
  self.mData = nil
end
function UICommanderInfoPanelV2:OnClose()
  for _, v in pairs(self.tabList) do
    v:OnRelease()
  end
  self.tabList = {}
  for _, v in pairs(self.tabGoList) do
    gfdestroy(v)
  end
  self.tabGoList = {}
  CS.BattlePerformSetting.RefreshGraphicSetting()
  if self.achievementPanel ~= nil then
    self.achievementPanel:Release()
  end
  self.achievementPanel = nil
  if self.settingPanel ~= nil then
    self.settingPanel:Release()
  end
  self.settingPanel = nil
  if self.playerInfoItem then
    self.playerInfoItem:OnRelease()
  end
  if self.playerInfoItem.supportList then
    gfdestroy(self.playerInfoItem.supportList:GetRoot())
  end
  self.playerInfoItem = nil
end
function UICommanderInfoPanelV2:InitTabButton()
  local leftTabPrefab = UIUtils.GetGizmosPrefab("UICommonFramework/ComLeftTab1ItemV2.prefab", self)
  for id = 1, 3 do
    do
      local item = UICommonLeftTabItemV2.New()
      local obj = instantiate(leftTabPrefab, self.ui.mContent_Tab.transform)
      item:InitCtrl(obj.transform)
      if id == self.TAB.Achievement then
        setactive(obj, false)
      end
      item.tagId = id
      item.mText_Name.text = TableData.GetHintById(900015 + id)
      item.mText_Num.text = UICommonLeftTabItemV2.GetRandomNum()
      UIUtils.GetButtonListener(item.mBtn.gameObject).onClick = function()
        self:OnClickTab(item.tagId)
      end
      table.insert(self.tabGoList, obj)
      self.tabList[id] = item
    end
  end
  self:UpdateLeftRedPoint()
  ResourceManager:UnloadAssetFromLua(leftTabPrefab)
end
function UICommanderInfoPanelV2:OnClickTab(id)
  if id == 2 and TipsManager.NeedLockTips(CS.GF2.Data.SystemList.Achievement) then
    return
  end
  if self.curTab == id or id == nil or id <= 0 then
    return
  end
  if self.curTab > 0 then
    local lastTab = self.tabList[self.curTab]
    lastTab:SetItemState(false)
  end
  local curTabItem = self.tabList[id]
  curTabItem:SetItemState(true)
  self.curTab = id
  setactive(self.ui.mTrans_0, self.curTab == self.TAB.PlayerInfo)
  setactive(self.ui.mTrans_1, false)
  setactive(self.ui.mTrans_2, self.curTab == self.TAB.Settings)
  self.ui.animator:SetInteger("SwitchTab", self.curTab - 1)
  self:UpdatePanelByType(id)
  self:UpdateLeftRedPoint()
end
function UICommanderInfoPanelV2:UpdatePanelByType()
  if self.curTab == self.TAB.Achievement then
    if self.achievementPanel == nil then
      self.achievementPanel = UIAchievementSubPanel.New()
      self.achievementPanel:InitCtrl(self.ui.mTrans_1)
    else
      self.achievementPanel:Show()
    end
  elseif self.curTab == self.TAB.PlayerInfo then
    if self.playerInfoItem == nil then
      self.playerInfoItem = UICommanderInfoCardItemV2.New(self)
      self.playerInfoItem:InitCtrlNew(self.ui.mPlayerInfo, self.ui.mTrans_0)
    end
    self.playerInfoItem:SetData(AccountNetCmdHandler:GetRoleInfoData(), self.mData.isSelf or false)
  elseif self.curTab == self.TAB.Settings then
    if self.settingPanel == nil then
      self.settingPanel = UISettingSubPanel.New()
      self.settingPanel:InitCtrl(self.ui.mTrans_2, self)
    else
      self.settingPanel:Show()
    end
  end
end
function UICommanderInfoPanelV2:OnRefresh()
  if self.curTab == self.TAB.Settings and self.settingPanel ~= nil then
    self.settingPanel:OnRefresh()
  end
end
function UICommanderInfoPanelV2:UpdateLeftRedPoint()
  for id = 1, 3 do
    if id == self.TAB.PlayerInfo then
      setactive(self.tabList[id].mTrans_RedPoint, NetCmdIllustrationData:UpdatePlayerCardRedPoint() > 0)
    elseif id == self.TAB.Settings then
      setactive(self.tabList[id].mTrans_RedPoint, 0 < NetCmdIllustrationData:UpdatePlayerSettingRedPoint())
    end
  end
end
function UICommanderInfoPanelV2:OnBackFrom()
  self:OnShowStart()
end
function UICommanderInfoPanelV2:OnTop()
  self:OnShowStart()
end
