require("UI.UICommonModifyPanel.CommanderInfoGlobal")
require("UI.Common.UICommonSettingItem")
require("UI.Common.UIComTabBtn1Item")
require("UI.UIBasePanel")
UISettingSubPanel = class("UISettingSubPanel", UIBaseCtrl)
UISettingSubPanel.__index = UISettingSubPanel
UISettingSubPanel.mTopTabViewList = {}
UISettingSubPanel.mSettingList = {}
UISettingSubPanel.mOthersList = {}
UISettingSubPanel.mSoundList = {}
UISettingSubPanel.mVoiceList = {}
UISettingSubPanel.mView = nil
UISettingSubPanel.Tab = {
  Sound = 1,
  Graphic = 2,
  Account = 3,
  Others = 4,
  KeyBoard = 5
}
UISettingSubPanel.SoundSettings = {
  SoundEffect = 11,
  BackGround = 12,
  Voice = 13,
  Movie = 14
}
UISettingSubPanel.GraphicSettings = {
  All = 20,
  Resolution = 21,
  Render = 22,
  RenderScale = 23,
  Shadow = 24,
  PostProcess = 25,
  Effect = 26,
  FPS = 27,
  Bloom = 28,
  AntiAliasing = 29,
  Outline = 30,
  VSync = 31
}
UISettingSubPanel.AccountButtons = {
  Exit = 51,
  Center = 52,
  Service = 53
}
UISettingSubPanel.Others = {
  Gender = 41,
  Avg = 42,
  UAV = 43,
  Language = 44
}
function UISettingSubPanel:ctor()
  UISettingSubPanel.super.ctor(self)
end
function UISettingSubPanel:InitCtrl(root, parent)
  self.parent = parent
  self:SetRoot(root)
  self.curTab = 0
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  function self.SDKNoticeHaveNewMsgFunc(sender)
    self:SDKNoticeHaveNewMsg(sender)
  end
  self:AddEventListener()
  self:InitTabList()
  self:InitSoundList()
  self:InitGraphicList()
  if CS.GameRoot.Instance.AdapterPlatform ~= CS.PlatformSetting.PlatformType.Mobile then
    self:InitKeyBoard()
  end
  self:InitAccount()
  self:InitOthers()
  self:InitVoice()
  self:OnClickTab(UISettingSubPanel.Tab.Sound)
end
function UISettingSubPanel:AddEventListener()
  MessageSys:AddListener(SystemEvent.SDKNoticeHaveNewMsg, self.SDKNoticeHaveNewMsgFunc)
end
function UISettingSubPanel:SDKNoticeHaveNewMsg(sender)
  if sender and sender.Sender then
    PlayerPrefs.SetInt(AccountNetCmdHandler:GetUID() .. CommanderInfoGlobal.ServiceCenterKey, 1)
  end
  local isShow = NetCmdIllustrationData:UpdatePlayerSettingRedPoint() == 1
  setactive(self.ui.mTrans_LookOverRedPoint1, isShow)
  self.parent:UpdateLeftRedPoint()
end
function UISettingSubPanel:UpdateTopRedPoint()
  for i = 1, 4 do
    if i == 4 then
      local isShow = PlayerPrefs.GetInt(AccountNetCmdHandler:GetUID() .. CommanderInfoGlobal.ServiceCenterKey) == 1
      self.mTopTabViewList[i]:SetRedPoint(isShow)
    end
  end
end
function UISettingSubPanel:Show()
  local lastTab = self.curTab
  self.curTab = 0
  self:OnClickTab(lastTab)
end
function UISettingSubPanel:InitTabList()
  local maxTabID = 4
  if CS.GameRoot.Instance.AdapterPlatform ~= CS.PlatformSetting.PlatformType.Mobile then
    maxTabID = 5
  end
  for i = 1, maxTabID do
    if i ~= 3 then
      do
        local topTab
        if self.mTopTabViewList[i] == nil then
          topTab = UIComTabBtn1Item.New()
          topTab:InitCtrl(self.ui.mContent_Top.transform)
          self.mTopTabViewList[i] = topTab
        else
          topTab = self.mTopTabViewList[i]
        end
        local str = TableData.GetHintById(104000 + i)
        if i == 5 then
          str = TableData.GetHintById(104078)
        end
        topTab:SetData({id = 0, name = str})
        UIUtils.GetListener(topTab.mBtn_Item.gameObject).onClick = function()
          self:OnClickTab(i)
        end
      end
    end
  end
end
function UISettingSubPanel:OnClickTab(id)
  if self.curTab == id or id == nil or id <= 0 then
    return
  end
  if self.curTab > 0 then
    local lastTab = self.mTopTabViewList[self.curTab]
    lastTab.mBtn_Item.interactable = true
  end
  local curTabItem = self.mTopTabViewList[id]
  curTabItem.mBtn_Item.interactable = false
  self.curTab = id
  setactive(self.ui.mTrans_Sound, id == self.Tab.Sound)
  setactive(self.ui.mTrans_PictureQuality, id == self.Tab.Graphic)
  setactive(self.ui.mTrans_Account, true)
  setactive(self.ui.mTrans_Other, id == self.Tab.Others)
  setactive(self.ui.mTrans_KeyPreview, id == self.Tab.KeyBoard)
  if id == self.Tab.Graphic then
    for id = 20, 31 do
      local setting = self.mSettingList[id]
      if setting ~= nil then
        setting:RefreshScreenPos()
      end
    end
  elseif id == self.Tab.Others then
    for id = 41, 43 do
      local setting = self.mOthersList[id]
      if setting ~= nil then
        setting:RefreshScreenPos()
      end
    end
    CS.GF2.SDK.PlatformLoginManager.Instance:CheckCustomNewMsg()
  end
end
function UISettingSubPanel:InitSoundList()
  local ids = {
    14,
    13,
    11,
    12
  }
  for i = 1, #ids do
    do
      local id = ids[i]
      local item
      if self.mSoundList[i] == nil then
        item = UICommonSettingItem.New()
        item:InitCtrl(self.ui.mContent_Sound, nil, true)
        self.mSoundList[i] = item
      else
        item = self.mSoundList[i]
      end
      local data = {
        id = id,
        name = TableData.GetHintById(103998 + id),
        type = 1,
        listener = function(ptc)
          UISettingSubPanel:OnSoundValueChange(id, item, ptc)
        end
      }
      if id == UISettingSubPanel.SoundSettings.SoundEffect then
        data.value = CS.BattlePerformSetting.VolumeValueForShow
      elseif id == UISettingSubPanel.SoundSettings.BackGround then
        data.value = CS.BattlePerformSetting.BGMVolumeValueForShow
      elseif id == UISettingSubPanel.SoundSettings.Voice then
        data.value = CS.BattlePerformSetting.VoiceValueForShow
      elseif id == UISettingSubPanel.SoundSettings.Movie then
        data.name = TableData.GetHintById(104051)
        data.value = CS.BattlePerformSetting.MovieVolumeValueForShow
      end
      item:SetData(data, self.parent)
    end
  end
end
function UISettingSubPanel:OnSoundValueChange(id, item, value)
  if id == UISettingSubPanel.SoundSettings.SoundEffect then
    CS.BattlePerformSetting.VolumeValue = value
  elseif id == UISettingSubPanel.SoundSettings.BackGround then
    CS.BattlePerformSetting.BGMVolumeValue = value
  elseif id == UISettingSubPanel.SoundSettings.Voice then
    CS.BattlePerformSetting.VoiceValue = value
  elseif id == UISettingSubPanel.SoundSettings.Movie then
    CS.BattlePerformSetting.MovieVolumeValue = value
  end
  item.ui.mText_Num.text = FormatNum(math.floor(value * 100))
end
function UISettingSubPanel:InitGraphicList()
  for id = 20, 20 do
    do
      local item
      if self.mSettingList[id] == nil then
        item = UICommonSettingItem.New()
        item:InitCtrl(self.ui.mTrans_GlobalSetting, function()
          self:OnClickDropDown(item)
        end)
        self.mSettingList[id] = item
      else
        item = self.mSettingList[id]
      end
      local data = {id = id, type = 2}
      if id == self.GraphicSettings.All then
        data.name = TableData.GetHintById(104015)
        data.list = {
          TableData.GetHintById(104024),
          TableData.GetHintById(104025),
          TableData.GetHintById(104026),
          TableData.GetHintById(104027),
          TableData.GetHintById(104028)
        }
        data.value = CS.BattlePerformSetting.AllQualityVale + 1
        function data.listener(ptc)
          self:OnDropDownAllQualityValueChange(ptc)
        end
      end
      item:SetData(data, self.parent)
      self.mSettingList[id] = item
    end
  end
  local settingItems = {
    22,
    24,
    25,
    26,
    27,
    28,
    29,
    30
  }
  local start = 22
  if CS.GameRoot.Instance.AdapterPlatform == CS.PlatformSetting.PlatformType.PC then
    settingItems = {
      21,
      22,
      23,
      24,
      25,
      26,
      27,
      28,
      29,
      30,
      31
    }
  end
  for k, id in pairs(settingItems) do
    local item
    if self.mSettingList[id] == nil then
      item = UICommonSettingItem.New()
      item:InitCtrl(self.ui.mTrans_OtherSettings, function()
        self:OnClickDropDown(item)
      end)
      self.mSettingList[id] = item
    else
      item = self.mSettingList[id]
    end
    local data = {}
    if id == UISettingSubPanel.GraphicSettings.VSync then
      data = {
        id = id,
        name = "垂直同步",
        type = 2,
        listener = function(ptc)
          self:OnGraphicValueChange(id, ptc)
        end
      }
    else
      data = {
        id = id,
        name = TableData.GetHintById(103994 + id),
        type = 2,
        listener = function(ptc)
          self:OnGraphicValueChange(id, ptc)
        end
      }
    end
    if id == UISettingSubPanel.GraphicSettings.Resolution then
      data.name = TableData.GetHintById(104046)
      data.list = {}
      local resolutions = CS.GraphicsSettingsManager.Instance.Resolutions
      for i = 0, resolutions.Count do
        if i == 0 then
          table.insert(data.list, TableData.GetHintById(104047))
        elseif i == 1 then
          table.insert(data.list, TableData.GetHintById(104061))
        else
          local resolution = resolutions[i - 1]
          table.insert(data.list, resolution.width .. " * " .. resolution.height)
        end
      end
      if CS.GameRoot.Instance.AdapterPlatform == CS.PlatformSetting.PlatformType.PC then
        local resolution = CS.BattlePerformSetting.Resolution
        if resolution == 0 then
          data.value = 0
        elseif resolution == -1 then
          data.value = 1
        else
          data.value = resolution
        end
      else
        data.value = 0
      end
    elseif id == UISettingSubPanel.GraphicSettings.Render then
      data.value = CS.BattlePerformSetting.RenderQualityValue
      data.name = TableData.GetHintById(104016)
      data.list = {
        TableData.GetHintById(104025),
        TableData.GetHintById(104026),
        TableData.GetHintById(104042),
        TableData.GetHintById(104027),
        TableData.GetHintById(104028)
      }
    elseif id == UISettingSubPanel.GraphicSettings.RenderScale then
      data.value = CS.BattlePerformSetting.RenderScaleValue
      data.name = TableData.GetHintById(104077)
      data.list = {
        "0.85",
        "1.00",
        "1.15",
        "1.30"
      }
    elseif id == UISettingSubPanel.GraphicSettings.Shadow then
      data.value = CS.BattlePerformSetting.ShadowValue
      data.name = TableData.GetHintById(104017)
      data.list = {
        TableData.GetHintById(104031),
        TableData.GetHintById(104032),
        TableData.GetHintById(104033),
        TableData.GetHintById(104034)
      }
    elseif id == UISettingSubPanel.GraphicSettings.PostProcess then
      data.value = CS.BattlePerformSetting.PostprocessingValue
      data.name = TableData.GetHintById(104018)
      data.list = {
        TableData.GetHintById(104030),
        TableData.GetHintById(104031),
        TableData.GetHintById(104032),
        TableData.GetHintById(104033)
      }
    elseif id == UISettingSubPanel.GraphicSettings.Effect then
      data.value = CS.BattlePerformSetting.EffectValue
      data.name = TableData.GetHintById(104019)
      data.list = {
        TableData.GetHintById(104031),
        TableData.GetHintById(104032),
        TableData.GetHintById(104033),
        TableData.GetHintById(104034)
      }
    elseif id == UISettingSubPanel.GraphicSettings.FPS then
      data.CSharpArr = CS.BattlePerformSetting.FPSValues
      data.name = TableData.GetHintById(104020)
      local Length = data.CSharpArr.Length
      data.list = {}
      data.value = 0
      for i = 0, Length - 1 do
        table.insert(data.list, CS.GFFPSUtils.GetValueByFPSModeIndex(data.CSharpArr[i]))
      end
      data.value = CS.BattlePerformSetting.FPSValue
      data.CSharpArr = nil
    elseif id == UISettingSubPanel.GraphicSettings.Bloom then
      data.value = CS.BattlePerformSetting.BloomValue
      data.name = TableData.GetHintById(104021)
      data.list = {
        TableData.GetHintById(104030),
        TableData.GetHintById(104029)
      }
    elseif id == UISettingSubPanel.GraphicSettings.AntiAliasing then
      data.value = CS.BattlePerformSetting.AntiAliasingValue
      data.name = TableData.GetHintById(104022)
      data.list = {
        TableData.GetHintById(104030),
        TableData.GetHintById(104031),
        TableData.GetHintById(104032),
        TableData.GetHintById(104033)
      }
    elseif id == UISettingSubPanel.GraphicSettings.Outline then
      data.value = CS.BattlePerformSetting.OutlineValue
      data.name = TableData.GetHintById(104023)
      data.list = {
        TableData.GetHintById(104031),
        TableData.GetHintById(104032),
        TableData.GetHintById(104033),
        TableData.GetHintById(104034)
      }
    elseif id == UISettingSubPanel.GraphicSettings.VSync then
      data.value = CS.BattlePerformSetting.VSyncValue
      data.list = {
        TableData.GetHintById(104030),
        TableData.GetHintById(104029)
      }
    end
    item:SetData(data, self.parent)
  end
end
function UISettingSubPanel:OnClickDropDown(item)
  for id = 20, 31 do
    local setting = self.mSettingList[id]
    if setting ~= nil then
      if item ~= setting or setting.isSortDropDownActive then
        setting:ShowDropDown(false)
      else
        setting:OnDropDown()
      end
    end
  end
end
function UISettingSubPanel:OnDropDownAllQualityValueChange(value)
  if value == 0 then
    return
  end
  value = value - 1
  CS.BattlePerformSetting.SetAllQualityValue(value)
  self.mSettingList[self.GraphicSettings.Render]:SetDropDownValue(CS.BattlePerformSetting.RenderQualityValue)
  if CS.GameRoot.Instance.AdapterPlatform == CS.PlatformSetting.PlatformType.PC then
    self.mSettingList[self.GraphicSettings.RenderScale]:SetDropDownValue(CS.BattlePerformSetting.RenderScaleValue)
  end
  self.mSettingList[self.GraphicSettings.Shadow]:SetDropDownValue(CS.BattlePerformSetting.ShadowValue)
  self.mSettingList[self.GraphicSettings.PostProcess]:SetDropDownValue(CS.BattlePerformSetting.PostprocessingValue)
  self.mSettingList[self.GraphicSettings.Effect]:SetDropDownValue(CS.BattlePerformSetting.EffectValue)
  self.mSettingList[self.GraphicSettings.Bloom]:SetDropDownValue(CS.BattlePerformSetting.BloomValue)
  self.mSettingList[self.GraphicSettings.AntiAliasing]:SetDropDownValue(CS.BattlePerformSetting.AntiAliasingValue)
  self.mSettingList[self.GraphicSettings.Outline]:SetDropDownValue(CS.BattlePerformSetting.OutlineValue)
  if CS.GameRoot.Instance.AdapterPlatform == CS.PlatformSetting.PlatformType.PC then
    self.mSettingList[self.GraphicSettings.VSync]:SetDropDownValue(CS.BattlePerformSetting.VSyncValue)
  end
  CS.BattlePerformSetting.AllQualityVale = value
end
function UISettingSubPanel:OnGraphicValueChange(id, value)
  if id == UISettingSubPanel.GraphicSettings.All then
    CS.BattlePerformSetting.AllQualityVale = value
  elseif id == UISettingSubPanel.GraphicSettings.Resolution then
    local curValue = value
    if value == 1 then
      curValue = -1
    end
    CS.BattlePerformSetting.Resolution = curValue
  elseif id == UISettingSubPanel.GraphicSettings.Render then
    CS.BattlePerformSetting.RenderQualityValue = value
  elseif id == UISettingSubPanel.GraphicSettings.RenderScale then
    CS.BattlePerformSetting.RenderScaleValue = value
  elseif id == UISettingSubPanel.GraphicSettings.Shadow then
    CS.BattlePerformSetting.ShadowValue = value
  elseif id == UISettingSubPanel.GraphicSettings.PostProcess then
    CS.BattlePerformSetting.PostprocessingValue = value
  elseif id == UISettingSubPanel.GraphicSettings.Effect then
    CS.BattlePerformSetting.EffectValue = value
  elseif id == UISettingSubPanel.GraphicSettings.FPS then
    CS.BattlePerformSetting.FPSValue = value
  elseif id == UISettingSubPanel.GraphicSettings.Bloom then
    CS.BattlePerformSetting.BloomValue = value
  elseif id == UISettingSubPanel.GraphicSettings.AntiAliasing then
    CS.BattlePerformSetting.AntiAliasingValue = value
  elseif id == UISettingSubPanel.GraphicSettings.Outline then
    CS.BattlePerformSetting.OutlineValue = value
  elseif id == UISettingSubPanel.GraphicSettings.VSync then
    CS.BattlePerformSetting.VSyncValue = value
  end
  self.mSettingList[20]:SetDropDownValue(0)
  CS.BattlePerformSetting.AllQualityVale = -1
end
function UISettingSubPanel:InitAccount()
  UIUtils.GetListener(self.ui.mBtn_Exit.gameObject).onClick = function()
    self:OnClickLogOut()
  end
  self.ui.mBtn_AccountCancel.transform.parent.gameObject:SetActive(CS.GameRoot.Instance:IsAndroidBiliSdkLogin())
  UIUtils.GetButtonListener(self.ui.mBtn_AccountCancel.gameObject).onClick = function()
    CS.GF2.SDK.PlatformLoginManager.Instance:BiliCloseAccount()
  end
  self.ui.mBtn_Center.transform.parent.gameObject:SetActive(CS.GameRoot.Instance:IsBiliSdkLogin() == false)
  UIUtils.GetListener(self.ui.mBtn_Center.gameObject).onClick = function()
    self:OnClickUserCenter()
  end
  self.ui.mBtn_Service.transform.parent.gameObject:SetActive(CS.GameRoot.Instance:IsBiliSdkLogin() == false)
  UIUtils.GetListener(self.ui.mBtn_Service.gameObject).onClick = function()
    self:OnClickCustomerCenter()
  end
  self.ui.mBtnUploadLog.transform.parent.gameObject:SetActive(CS.LogReporterSystem.Instance.IsServerAllowReportLog)
  UIUtils.GetListener(self.ui.mBtnUploadLog.gameObject).onClick = function()
    CS.LogReporterSystem.Instance:ReportNormalLogWithMessageBox()
  end
end
function UISettingSubPanel:OnRefresh()
  self.ui.mBtnUploadLog.transform.parent.gameObject:SetActive(CS.LogReporterSystem.Instance.IsServerAllowReportLog)
end
function UISettingSubPanel:InitKeyBoard()
  local InputData = {}
  local allTypeList = TableData.listShortcutKeyTypeDatas:GetList()
  local allListCount = allTypeList.Count
  for i = 0, allListCount - 1 do
    local id = allTypeList[i].id
    local ids = TableData.listShortcutKeyByTypeDatas:GetDataById(id).Id
    local idsListCount = ids.Count
    for j = 0, idsListCount - 1 do
      local tbID = ids[j]
      local d = TableData.listShortcutKeyDatas:GetDataById(tbID)
      table.insert(InputData, d)
    end
  end
  local curTypeID
  self.mKeyBoardList = {}
  self.mKeyBoardTypeList = {}
  local data = {}
  for i, v in ipairs(InputData) do
    if curTypeID == nil or curTypeID ~= v.type then
      curTypeID = v.type
      local typeData = TableData.listShortcutKeyTypeDatas:GetDataById(curTypeID)
      local obj = instantiate(self.ui.mTrans_KeyBoardTittleName.gameObject, self.ui.mTrans_KeyBoard)
      local t = obj.transform:Find("GrpName/Text_Name"):GetComponent(typeof(CS.UnityEngine.UI.Text))
      t.text = typeData.name.str
      setactive(obj, true)
      table.insert(self.mKeyBoardTypeList, obj)
    end
    local item
    if self.mKeyBoardList[i] == nil then
      item = UICommonSettingItem.New()
      item:InitCtrl(self.ui.mTrans_KeyBoard)
      self.mKeyBoardList[i] = item
    else
      item = self.mKeyBoardList[i]
    end
    data.type = 4
    data.value = v
    data.name = v.name.str
    item:SetData(data, self.parent)
  end
end
function UISettingSubPanel:OnClickLogOut()
  MessageBox.Show(TableData.GetHintById(64), TableData.GetHintById(108), nil, function()
    AccountNetCmdHandler:LogoutAndSdkLogOut()
  end, function()
  end)
end
function UISettingSubPanel:OnClickUserCenter()
  CS.GF2.SDK.PlatformLoginManager.Instance:UserCenter()
end
function UISettingSubPanel:OnClickCustomerCenter()
  PlayerPrefs.SetInt(AccountNetCmdHandler:GetUID() .. CommanderInfoGlobal.ServiceCenterKey, 0)
  self:SDKNoticeHaveNewMsg()
  CS.GF2.SDK.PlatformLoginManager.Instance:CustomerCenter()
end
function UISettingSubPanel:InitOthers()
  local listOther = {42}
  for i, id in ipairs(listOther) do
    local item
    if self.mOthersList[id] == nil then
      item = UICommonSettingItem.New()
      item:InitCtrl(self.ui.mContent_Other, function()
        self:OnClickOthersDropDown(item)
      end)
      self.mOthersList[id] = item
    else
      item = self.mOthersList[id]
    end
    local data = {
      id = id,
      type = 2,
      listener = function(ptc)
        self:OnOthersValueChange(id, ptc)
      end
    }
    if id == self.Others.Gender then
      data.value = AccountNetCmdHandler.Gender
      data.name = TableData.GetHintById(104012)
      data.list = {
        TableData.GetHintById(104013),
        TableData.GetHintById(104014)
      }
    elseif id == self.Others.Avg then
      data.value = AccountNetCmdHandler.AvgRepetion
      data.name = TableData.GetHintById(104035)
      data.list = {
        TableData.GetHintById(104036),
        TableData.GetHintById(104037)
      }
    elseif id == self.Others.UAV then
      data.value = AccountNetCmdHandler.UAVHint
      data.name = TableData.GetHintById(104043)
      data.list = {
        TableData.GetHintById(104044),
        TableData.GetHintById(104045)
      }
    end
    item:SetData(data, self.parent)
  end
end
function UISettingSubPanel:InitVoice()
  for id = 0, 1 do
    do
      local item
      if self.mVoiceList[id] == nil then
        item = UICommonSettingItem.New()
        item:InitCtrl(self.ui.mContent_Sound, function()
          self:OnClickOthersDropDown(item)
        end)
        self.mVoiceList[id] = item
      else
        item = self.mVoiceList[id]
      end
      local data = {
        id = id,
        type = 3,
        listener = function(ptc)
          self:OnVoiceValueChange(ptc)
        end
      }
      data.value = AccountNetCmdHandler.AvgVoice
      data.type = 3
      data.name = TableData.GetHintById(104039 + id)
      item:SetData(data, self.parent)
    end
  end
end
function UISettingSubPanel:OnVoiceValueChange(value)
  AccountNetCmdHandler.AvgVoice = value
  for id = 0, 1 do
    self.mVoiceList[id]:RefreshVoice()
  end
end
function UISettingSubPanel:OnClickOthersDropDown(item)
  for id = 41, 42 do
    local other = self.mOthersList[id]
    if other ~= nil then
      if item ~= other or other.isSortDropDownActive then
        other:ShowDropDown(false)
      else
        other:OnDropDown()
      end
    end
  end
end
function UISettingSubPanel:OnOthersValueChange(id, value)
  if id == UISettingSubPanel.Others.Gender then
    AccountNetCmdHandler.Gender = value
  elseif id == UISettingSubPanel.Others.Avg then
    AccountNetCmdHandler.AvgRepetion = value
  elseif id == UISettingSubPanel.Others.UAV then
    AccountNetCmdHandler.UAVHint = value
  end
end
function UISettingSubPanel:Release()
  for i, view in pairs(UISettingSubPanel.mTopTabViewList) do
    gfdestroy(view:GetRoot())
  end
  for i, view in pairs(UISettingSubPanel.mSettingList) do
    gfdestroy(view:GetRoot())
  end
  for i, view in pairs(UISettingSubPanel.mOthersList) do
    gfdestroy(view:GetRoot())
  end
  for i, view in pairs(UISettingSubPanel.mVoiceList) do
    gfdestroy(view:GetRoot())
  end
  for i, view in pairs(UISettingSubPanel.mSoundList) do
    gfdestroy(view:GetRoot())
  end
  MessageSys:RemoveListener(SystemEvent.SDKNoticeHaveNewMsg, self.SDKNoticeHaveNewMsgFunc)
  UISettingSubPanel.mTopTabViewList = {}
  UISettingSubPanel.mSettingList = {}
  UISettingSubPanel.mOthersList = {}
  UISettingSubPanel.mVoiceList = {}
  UISettingSubPanel.mSoundList = {}
  self:ReleaseCtrlTable(self.mKeyBoardList, true)
  self.mKeyBoardList = nil
  if self.mKeyBoardTypeList then
    for _, view in ipairs(self.mKeyBoardTypeList) do
      gfdestroy(view)
    end
    self.mKeyBoardTypeList = nil
  end
end
