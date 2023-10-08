require("UI.UIBasePanel")
require("UI.Lounge.Btn_DormMainFunctionItem")
require("UI.Lounge.DormGlobal")
DormMainPanel = class("DormMainPanel", UIBasePanel)
DormMainPanel.__index = DormMainPanel
function DormMainPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
  csPanel.Is3DPanel = true
end
function DormMainPanel:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self.formatString = TableData.GetHintById(280019)
  self:LuaUIBindTable(root, self.ui)
  self:ManualUI()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.DormMainPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    self.jumptomainpanel = true
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Visual.gameObject).onClick = function()
    self.isShowUI = not self.isShowUI
    self:UpdateUIState()
    UIManager.OpenUI(UIDef.UIDormVisualHPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Feel.gameObject).onClick = function()
    self:onClickLove()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnChrChange.gameObject).onClick = function()
    UIManager.OpenUIByParam(UIDef.UIDormChrChangePanel, self.mGunCmdData)
  end
  self.ossDeltaTime = 0
end
function DormMainPanel:UpdateUIState()
  setactive(self.ui.mTrans_NormalFeel, self.mGunCmdData.Id ~= NetCmdLoungeData.loveCharacterID)
  setactive(self.ui.mTrans_FavorFeel, self.mGunCmdData.Id == NetCmdLoungeData.loveCharacterID)
  self:UpdateRedPoint()
  self:SetPlayerPrefs()
end
function DormMainPanel:ManualUI()
  self.isShowUI = true
end
function DormMainPanel:OnInit(root, data)
  self:SetBaseData()
  self:UpdateName()
  self:InitFunctionItem()
  self:UpdateUIState()
end
function DormMainPanel:UpdateName()
  self.mGunCmdData = NetCmdLoungeData:GetCurrGunCmdData()
  self.gunData = TableData.listGunCharacterDatas:GetDataById(self.mGunCmdData.gunData.character_id)
  self.ui.mText_Title.text = string_format(self.formatString, self.gunData.name.str)
  NetCmdLoungeData:SendEnterDorm(self.mGunCmdData.gunData.id, function(ret)
    if ret == ErrorCodeSuc then
    end
  end)
end
function DormMainPanel:OnShowStart()
  self.jumptomainpanel = false
  SceneSys:SwitchVisible(EnumSceneType.Lounge)
  LoungeHelper.CameraCtrl.CameraPreObj:ExitLookAt()
end
function DormMainPanel:CleanCameraTime()
  if self.cameraTime then
    self.cameraTime:Stop()
    self.cameraTime = nil
  end
end
function DormMainPanel:OnShowFinish()
  self:CleanCameraTime()
  if LoungeHelper.CameraCtrl then
    LoungeHelper.CameraCtrl.isDebug = false
  else
    self.cameraTime = TimerSys:DelayCall(0.5, function()
      self:CleanCameraTime()
      if LoungeHelper.CameraCtrl then
        LoungeHelper.CameraCtrl.isDebug = false
      end
    end)
  end
  UISystem.UIRootCanvasAdapter:CanvasResolutionChange()
end
function DormMainPanel:OnTop()
  self:UpdateName()
  self:UpdateUIState()
end
function DormMainPanel:OnBackFrom()
  self:UpdateName()
  self:UpdateUIState()
  if self.curPlayAnimID then
    LoungeHelper.AnimCtrl:PlayAnim(self.curPlayAnimID)
  end
  self.curPlayAnimID = nil
end
function DormMainPanel:OnUpdate()
  self.ossDeltaTime = self.ossDeltaTime + Time.deltaTime
end
function DormMainPanel:OnClose()
  local animIdList = LoungeHelper.AnimCtrl:GetVisitedAnimIdList()
  local gunId = NetCmdLoungeData:GetCurrGunId()
  local info = CS.OssLoungeLog(2, gunId, self.ossDeltaTime, animIdList)
  MessageSys:SendMessage(OssEvent.OnLoungeLog, nil, info)
  LoungeHelper.AnimCtrl:ClearVisitedAnimIdList()
  self.isShowUI = true
  self:ReleaseCtrlTable(self.rightBtnList, true)
  self.rightBtnList = nil
  self:CleanCameraTime()
  if self.jumptomainpanel then
    SceneSys:SwitchVisible(EnumSceneType.CommandCenter)
  else
    SceneSys:SwitchVisible(NetCmdLoungeData:GetEnterSceneType())
  end
  LoungeHelper.CameraCtrl:SetCanSendMessage(false)
  SceneSys:UnloadLoungeScene()
end
function DormMainPanel:OnHide()
end
function DormMainPanel:OnHideFinish()
  if DormGlobal.IsSkinOpen then
    DormGlobal.IsSkinOpen = false
    LoungeHelper.CameraCtrl.CameraPreObj:EnterLookAt()
  end
end
function DormMainPanel:OnRelease()
  self:CleanCameraTime()
end
function DormMainPanel:SetBaseData()
  self.rightBtnList = {}
  LoungeHelper.CameraCtrl:SetCanSendMessage(true)
end
function DormMainPanel:InitFunctionItem()
  for i = 1, 4 do
    if self.rightBtnList[i] == nil then
      self.rightBtnList[i] = Btn_DormMainFunctionItem.New()
      self.rightBtnList[i]:InitCtrl(self.ui.mScrollListChild_TabFunctionList)
    end
  end
  self.rightBtnList[1]:SetBtnName(TableData.GetHintById(280020))
  self.rightBtnList[1]:SetClickFunction(function()
    UIManager.OpenUI(UIDef.UIDormChrBehaviourPanel)
  end)
  self.rightBtnList[1]:SetIcon("Icon_DormFunction_Behaviour")
  self.rightBtnList[2]:SetBtnName(TableData.GetHintById(280021))
  self.rightBtnList[2]:SetClickFunction(function()
    DormGlobal.IsSkinOpen = true
    UIManager.OpenUIByParam(UIDef.UIDormSkinChangePanel, self.mGunCmdData.id)
    self.curPlayAnimID = LoungeHelper.AnimCtrl:GetCurrPlayAnimId()
  end)
  self.rightBtnList[2]:SetRedPoint(NetCmdGunClothesData:IsAnyClothesDormNeedRedPoint(self.mGunCmdData.id))
  self.rightBtnList[2]:SetIcon("Icon_DormFunction_Skin")
  self.rightBtnList[3]:SetBtnName(TableData.GetHintById(280022))
  self.rightBtnList[3]:SetClickFunction(function()
    UIManager.OpenUI(UIDef.UIDormChrRecordSelectPanel)
  end)
  self.rightBtnList[3]:SetRedPoint(NetCmdLoungeData:DormChrDailyRedPointByGunID(self.mGunCmdData.id) > 0)
  self.rightBtnList[3]:SetIcon("Icon_DormFunction_Record")
  self.rightBtnList[4]:SetBtnName(TableData.GetHintById(280023))
  self.rightBtnList[4]:SetClickFunction(function()
    UIManager.OpenUIByParam(UIDef.UIDormPlayStoryDialog, {
      currData = self.gunData
    })
  end)
  self.rightBtnList[4]:SetRedPoint(0 < NetCmdLoungeData:DormChrStoryRedPointByGunID(self.mGunCmdData.id))
  self.rightBtnList[4]:SetIcon("Icon_DormFunction_Plot")
  self.rightBtnList[4]:SetLineVisible(false)
end
function DormMainPanel:onClickLove()
  local loveId = self.mGunCmdData.Id
  if loveId == NetCmdLoungeData.loveCharacterID then
    loveId = 0
  end
  NetCmdLoungeData:SendCS_DormSetLove(loveId, function()
    self:UpdateUIState()
    if loveId ~= 0 then
      CS.PopupMessageManager.PopupPositiveString(TableData.GetHintById(280025))
      self.ui.mAnimator_Feel:SetBool("Light", true)
    end
  end)
end
function DormMainPanel:UpdateRedPoint()
  self.rightBtnList[2]:SetRedPoint(NetCmdGunClothesData:IsAnyClothesDormNeedRedPoint(self.mGunCmdData.id))
  self.rightBtnList[3]:SetRedPoint(NetCmdLoungeData:DormChrDailyRedPointByGunID(self.mGunCmdData.id) > 0)
  self.rightBtnList[4]:SetRedPoint(0 < NetCmdLoungeData:DormChrStoryRedPointByGunID(self.mGunCmdData.id))
  setactive(self.ui.mTransChr_RedPoint, 0 < NetCmdLoungeData:GetDormRedPoint())
end
function DormMainPanel:SetPlayerPrefs()
  local key = AccountNetCmdHandler:GetUID() .. "DormUnlock" .. self.mGunCmdData.Id
  PlayerPrefs.SetInt(key, 1)
end
