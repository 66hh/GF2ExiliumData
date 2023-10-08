require("UI.Tips.UIComItemDetailsPanelV2View")
require("UI.Tips.TipsPanelHelper")
require("UI.UIBasePanel")
UITipsPanel = class("UITipsPanel", UIBasePanel)
UITipsPanel.__index = UITipsPanel
local self = UITipsPanel
function UITipsPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UITipsPanel.Open(itemData, num, needGetWay, showTime, relateId, closecallback, showWeaponPartTips, showWayCanNotJump, showCreditCount, isBattleGroup, hideCompose, showUse)
  print("执行了吗" .. itemData.name)
  TipsPanelHelper.bShowItem = true
  TipsPanelHelper.itemData = itemData
  TipsPanelHelper.num = num
  TipsPanelHelper.needGetWay = needGetWay
  TipsPanelHelper.showTime = showTime
  TipsPanelHelper.relateId = relateId
  TipsPanelHelper.closecallback = closecallback
  TipsPanelHelper.showWeaponPartTips = showWeaponPartTips
  TipsPanelHelper.showWayCanNotJump = showWayCanNotJump
  TipsPanelHelper.showCreditCount = showCreditCount
  TipsPanelHelper.hideCompose = hideCompose
  TipsPanelHelper.showUse = showUse
  local toppanel = UISystem:GetTopPanelUI()
  local topdialog = UISystem:GetTopDialogUI()
  if topdialog ~= nil and toppanel ~= nil and toppanel.UIDefine.UIType == UIDef.UICommandCenterPanel and topdialog.UIDefine.UIType == UIDef.UICommonReceivePanel then
    needGetWay = false
    self.needGetWay = false
  end
  if isBattleGroup == nil then
    isBattleGroup = false
  end
  local uiGroupType = CS.UISystem.UIGroupType.Default
  if SceneSys:IsBattleScene() == false or not isBattleGroup then
    uiGroupType = CS.UISystem.UIGroupType.Default
  else
    uiGroupType = CS.UISystem.UIGroupType.BattleUI
  end
  if TipsPanelHelper.itemData.type == GlobalConfig.ItemType.GunType then
    CS.RoleInfoCtrlHelper.Instance:InitSysPlayerDataById(TipsPanelHelper.itemData.id)
  else
    UIManager.OpenUIByParam(UIDef.UITipsPanel, nil, uiGroupType)
  end
end
function UITipsPanel.OpenStoreGood(name, icon, des, rank, itemData)
  TipsPanelHelper.bShowItem = false
  TipsPanelHelper.storeGoodName = name
  TipsPanelHelper.storeGoodIcon = icon
  TipsPanelHelper.storeGoodDes = des
  TipsPanelHelper.storeGoodRank = rank
  TipsPanelHelper.itemData = itemData
  UIManager.OpenUI(UIDef.UITipsPanel)
end
function UITipsPanel.OpenCommandDetail(data)
  TipsPanelHelper.commandData = data
  UIManager.OpenUI(UIDef.UITipsPanel)
end
function UITipsPanel:Close()
  UIManager.CloseUI(UIDef.UITipsPanel)
end
function UITipsPanel:OnInit(root, data)
  self.super.SetRoot(self, root)
  self.mData = data
  self.mUIGroupType = self.mCSPanel.UIGroupType
  if data ~= nil then
    TipsPanelHelper.itemData = data.Length >= 1 and data[0] or TipsPanelHelper.itemData
    TipsPanelHelper.num = data.Length >= 2 and data[1] or TipsPanelHelper.num
    if data.Length >= 3 then
      TipsPanelHelper.needGetWay = data[2]
    end
    TipsPanelHelper.showTime = data.Length >= 4 and data[3] or TipsPanelHelper.showTime
    TipsPanelHelper.relateId = data.Length >= 5 and data[4] or 0
    TipsPanelHelper.showWeaponPartTips = data.Length >= 7 and data[6] or false
    TipsPanelHelper.bShowItem = true
  end
  self.closecallback = TipsPanelHelper.closecallback
  self.mView = UIComItemDetailsPanelV2View.New()
  self.mView:InitCtrl(root)
  UIUtils.GetButtonListener(self.mView.ui.mBtn_Close.gameObject).onClick = self.OnCloseClick
  UIUtils.GetButtonListener(self.mView.ui.mBtn_BgClose.gameObject).onClick = self.OnCloseClick
  function self.OnUpdateItemData()
    self:OnUpdateItemDataFun()
  end
  MessageSys:AddListener(9007, self.OnUpdateItemData)
  MessageSys:AddListener(5002, self.OnUpdateItemData)
  self.mUIRoot = root
  self.super.SetPosZ(self)
  self:SetToMaxIndex()
  if UITipsPanel.ShowCommandDetail() then
    return
  end
  if TipsPanelHelper.bShowItem == true then
    self.mView:ShowItemDetail(TipsPanelHelper.itemData, TipsPanelHelper.num, TipsPanelHelper.needGetWay, TipsPanelHelper.showTime, TipsPanelHelper.relateId, TipsPanelHelper.showWeaponPartTips, TipsPanelHelper.showWayCanNotJump, TipsPanelHelper.showCreditCount, TipsPanelHelper.hideCompose, TipsPanelHelper.showUse)
    if self.mData ~= nil and self.mData.Length >= 6 then
      UIUtils.AddSubCanvas(self.mUIRoot.gameObject, self.mData[5], false)
    end
  else
    self.mView:ShowStoreGoodDetail(TipsPanelHelper.storeGoodName, TipsPanelHelper.storeGoodIcon, TipsPanelHelper.storeGoodDes, TipsPanelHelper.storeGoodRank, TipsPanelHelper.itemData)
  end
end
function UITipsPanel.ShowCommandDetail()
  if TipsPanelHelper.commandData == nil then
    return false
  end
  self.mView:ShowCommandDetail(TipsPanelHelper.commandData)
  TipsPanelHelper.commandData = nil
  return true
end
function UITipsPanel.OnCloseClick(gameObject)
  if not self.mUIGroupType then
    UIManager.CloseUI(UIDef.UITipsPanel)
  else
    UIManager.CloseUIByGroup(UIDef.UITipsPanel, self.mUIGroupType)
  end
end
function UITipsPanel:SetToMaxIndex()
  self.mUIRoot.transform:SetSiblingIndex(self.mUIRoot.transform.parent.childCount - 1)
end
function UITipsPanel:OnClose()
  if self.mView.RobotDetalList then
    for i = 1, #self.mView.RobotDetalList do
      if self.mView.RobotDetalList[i] then
        gfdestroy(self.mView.RobotDetalList[i]:GetRoot())
      end
    end
    self.mView.RobotDetalList = nil
  end
  if self.closecallback ~= nil then
    self.closecallback()
  end
  self.mView.updateFlag = false
  self.mView:onRelease()
  self.mData = nil
  self.mView = nil
  self.closecallback = nil
  self.mUIGroupType = nil
  MessageSys:RemoveListener(9007, self.OnUpdateItemData)
  MessageSys:RemoveListener(5002, self.OnUpdateItemData)
end
function UITipsPanel:ShowTips(itemData, num, needGetWay, showTime)
end
function UITipsPanel:OnUpdate()
  if self.mView ~= nil and self.mView.updateFlag then
    self.mView:UpdateStaminaContent()
  end
  if self.mView ~= nil then
    self.mView:OnUpdate()
  end
end
function UITipsPanel:OnUpdateItemDataFun()
  self.mView:UpdateDetailContent()
  if self.mView.HowToGetPanel ~= nil then
    self.mView.HowToGetPanel:UpdatePanel()
  end
end
