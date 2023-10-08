require("UI.CommonGetGunPanel.UICommonGetGunPanelView")
require("UI.Common.UICommonDutyItem")
require("UI.UIBasePanel")
UICommonGetGunPanel = class("UICommonGetGunPanel", UIBasePanel)
UICommonGetGunPanel.__index = UICommonGetGunPanel
UICommonGetGunPanel.itemList = {}
UICommonGetGunPanel.gunData = nil
UICommonGetGunPanel.callback = nil
UICommonGetGunPanel.gunType = 1
UICommonGetGunPanel.isLoading = false
UICommonGetGunPanel.needSkip = false
UICommonGetGunPanel.isUnskipable = false
UICommonGetGunPanel.loadGunGetScene = false
UICommonGetGunPanel.GunType = {Item = 1, Gun = 2}
function UICommonGetGunPanel.OpenGetGunPanel(data, callback, type, needSkip, autoClose, skipPanel, unskipableIndex, isGacha)
  UIManager.OpenUIByParam(UIDef.UICommonGetGunPanel, {
    [1] = data,
    [2] = callback,
    [3] = type,
    [4] = needSkip,
    [5] = autoClose,
    [6] = skipPanel,
    [7] = unskipableIndex,
    [8] = isGacha
  })
end
function UICommonGetGunPanel:ctor(csPanel)
  UICommonGetGunPanel.super.ctor(UICommonGetGunPanel, csPanel)
  UICommonGetGunPanel.mUIGroupType = csPanel.UIGroupType
  self.mCSPanel = csPanel
end
function UICommonGetGunPanel:OnFadeInFinish()
  UISystem:SetMainCamera(true)
end
function UICommonGetGunPanel:ShowNextPage()
  if self.isLoading then
    return
  end
  setactive(self.ui.mTrans_WhiteMask2, false)
  setactive(self.ui.mTrans_BlackMask2, true)
  setactive(self.ui.mTrans_Vignetting2, true)
  self.isUnskipable = false
  self.timeLineShow = false
  self.isSkippedWeapon = false
  self.isChrSkipped = false
  self.checkChrState = false
  self.checkChrState2 = false
  self.nowTime = 0
  self.timeLineTimer = nil
  table.remove(self.itemList, 1)
  if 0 < #self.itemList then
    self.ui.mAudio_Chr:Stop()
    self.ui.mAudio_Weapon:Stop()
    CS.CriWareAudioController.StopVoice()
    self:OnShowStart()
  else
    self:OnEnd(self.skipPanel)
  end
end
function UICommonGetGunPanel:ShowUnskipablePage(ignoreGap)
  if ignoreGap == nil and self.canSkip ~= nil and not self.canSkip then
    return
  end
  if self.gapTimer then
    self.gapTimer:Stop()
    self.gapTimer = nil
  end
  self.canSkip = false
  self.gapTimer = TimerSys:DelayCall(0.5, function()
    self.canSkip = true
  end)
  self.unskipableList = self.unskipableList or {}
  if #self.unskipableList == 0 then
    self.tmpBtnSkip = nil
    self:OnEnd(self.skipPanel)
  elseif self.itemCount - #self.itemList + 1 >= self.unskipableList[1] then
    table.remove(self.unskipableList, 1)
    self:ShowUnskipablePage(ignoreGap)
  else
    if self.isLoading then
      return
    end
    self.isUnskipable = true
    self.timeLineShow = false
    self.isSkippedWeapon = false
    self.isChrSkipped = false
    self.checkChrState = false
    self.checkChrState2 = false
    self.nowTime = 0
    self.timeLineTimer = nil
    self.rank = nil
    for i = 1, #self.itemList - (self.itemCount - self.unskipableList[1] + 1) do
      table.remove(self.itemList, 1)
    end
    if 0 < #self.itemList then
      self.ui.mAudio_Chr:Stop()
      self.ui.mAudio_Weapon:Stop()
      CS.CriWareAudioController.StopVoice()
      self:OnShowStart()
    else
      self:OnEnd(self.skipPanel)
    end
  end
end
function UICommonGetGunPanel.Close()
  UISystem:CloseUIForce(UIDef.UICommonGetGunPanel)
end
function UICommonGetGunPanel:OnClose()
  if self.loadGunGetScene then
    SceneSys:UnloadGunGetScene()
    self.loadGunGetScene = false
  end
  self.GetList = nil
  MessageSys:RemoveListener(UIEvent.WeaponTimelineEnd, self.weaponTimelineEndFunc)
end
function UICommonGetGunPanel:OnRelease()
  self.itemList = {}
  self.effectList = {}
  self.curEffect = nil
  self.mGunGetShow = nil
  self.timeLineShow = nil
  self.chrStateInfo = nil
  self.checkChrState = nil
  self.checkChrState2 = nil
  self.timeLineTimer = nil
  self.tmpBtnSkip = nil
  self.rank = nil
  self.mView = nil
  self.loadTimeLine = nil
  self.loadGunGetSSRScene = nil
  self.isUnskipable = false
end
function UICommonGetGunPanel:OnInit(root, data)
  UICommonGetGunPanel.super.SetRoot(UICommonGetGunPanel, root)
  self.mView = UICommonGetGunPanelView.New()
  self.ui = {}
  self.mView:LuaUIBindTable(self.mUIRoot, self.ui)
  self.mView:LuaUIBindTable(self.ui.mTrans_GunContent, self.ui)
  self.mView:LuaUIBindTable(self.ui.mTrans_WeaponContent, self.ui)
  self.mView:InitCtrl(root, self.ui)
  self.mView:LuaUIBindTable(self.ui.mTrans_ExtraGet, self.ui)
  self.itemList = {}
  self.mHideFlag = true
  self.callback = data[2]
  self.gunType = data[3] == nil and UICommonGetGunPanel.GunType.Item or data[3]
  self.needSkip = data[4] or false
  if data[5] == nil then
    self.autoClose = true
  else
    self.autoClose = data[5]
  end
  self.nowTime = 0
  self.isNewList = false
  self.skipPanel = data[6]
  if data[8] == nil then
    self.isGacha = false
  else
    self.isGacha = data[8]
  end
  setactive(self.ui.mTrans_WhiteMask, not self.isGacha)
  self.unskipableList = {}
  local unskipableIndex = {}
  local dataList = data[1]
  if dataList.Length ~= nil then
    for i = 0, dataList.Length - 1 do
      local item = dataList[i]
      local itemID
      if type(item) == "number" then
        itemID = item
        item = {ItemId = itemID, ItemNum = 1}
      else
        itemID = item.ItemId
      end
      local itemData = TableData.listItemDatas:GetDataById(itemID)
      local mStcData = TableData.GetItemData(itemID)
      if item.ItemNum ~= nil and item.ItemNum ~= 0 then
        if mStcData.type ~= GlobalConfig.ItemType.Weapon then
          table.insert(self.unskipableList, i + 1)
        elseif NetCmdIllustrationData:CheckItemIsFirstTime(mStcData.type, itemID, false) and unskipableIndex[itemID] == nil then
          table.insert(self.unskipableList, i + 1)
          unskipableIndex[itemID] = true
        end
      end
      if itemData.type == GlobalConfig.ItemType.GunType then
        local gunData = TableData.listGunDatas:GetDataById(itemData.args[0])
        if gunData.gacha_get_timeline ~= "" then
          self.loadGunGetSSRScene = true
        end
      end
      table.insert(self.itemList, item)
    end
    self.itemCount = #self.itemList
  else
    self.isNewList = true
    self.itemList = dataList
    for i = 1, #dataList do
      local item = dataList[i]
      local itemData = TableData.listItemDatas:GetDataById(item.ItemId or item)
      if itemData.type == GlobalConfig.ItemType.GunType then
        local gunData = TableData.listGunDatas:GetDataById(itemData.args[0])
        if gunData.gacha_get_timeline ~= "" then
          self.loadGunGetSSRScene = true
        end
      end
    end
  end
  self.dutyItem = UICommonDutyItem.New()
  self.dutyItem:InitCtrl(self.ui.mTrans_ChrDuty)
  if CS.GameRoot.Instance and CS.GameRoot.Instance.AdapterPlatform == CS.PlatformSetting.PlatformType.PC then
    UISystem.UICanvas.transform:GetComponent("CanvasScaler").matchWidthOrHeight = 1
    local targetWidth = 1600
    local targetHeight = 900
    local currentHeight = 720
    self.ui.mTrans_BtnSkip.anchorMin = vector2zero
    self.ui.mTrans_BtnSkip.anchorMax = vector2zero
    self.ui.mTrans_BtnSkip.sizeDelta = Vector2(targetWidth, targetHeight)
    self.ui.mTrans_BtnSkip.localScale = vectorone * currentHeight / targetHeight
  end
  SceneSys:OpenGunGetScene(function(obj)
    UICommonGetGunPanel.loadGunGetScene = true
    setactive(self.ui.mTrans_WhiteMask2, true)
    setactive(self.ui.mTrans_BlackMask2, false)
    setactive(self.ui.mTrans_Vignetting2, false)
    local type = SceneSys.currentScene:GetSceneType()
    self.mGunGetShow = obj
    if type == CS.EnumSceneType.Gacha or type == CS.EnumSceneType.CommandCenter then
      CS.UnityEngine.SceneManagement.SceneManager.SetActiveScene(obj.scene)
    end
    self:UpdatePanel()
    if self.loadTimeLine then
      self.loadTimeLine()
      self.loadTimeLine = nil
    end
  end)
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UICommonGetGunPanel)
  end
  if data[7] ~= nil and 1 < data[7] then
    self:ShowUnskipablePage()
  end
  function self.weaponTimelineEndFunc(msg)
    setactive(self.mUIRoot.gameObject, true)
    self.isInGunScene = false
    if self.skipPanel ~= nil then
      setactive(self.skipPanel.mUIRoot, true)
    end
    self:UpdateItemPanel(self.item)
  end
  MessageSys:AddListener(UIEvent.WeaponTimelineEnd, self.weaponTimelineEndFunc)
end
function UICommonGetGunPanel:OnUpdate(deltatime)
  if self.checkChrState and self.chrStateInfo:IsName("FadeIn") then
    if self.chrStateInfo.length < self.nowTime then
      self.checkChrState = false
      if self.itemData and self.itemData.type == GlobalConfig.ItemType.GunType and self.gunData.gacha_get_timeline ~= "" or self.gunType == UICommonGetGunPanel.GunType.Gun and self.gunData.gacha_get_timeline ~= "" then
        self:ShowSSRTimeline()
      else
        self:PlayFade2()
      end
    else
      self.nowTime = self.nowTime + deltatime
    end
  end
  if self.checkChrState2 then
    if self.nowTime > 3 then
      self.checkChrState2 = false
    else
      self.nowTime = self.nowTime + deltatime
    end
  end
end
function UICommonGetGunPanel:PlayFade2()
  if self.timeLineTimer ~= nil then
    self.timeLineTimer:Stop()
  end
  if not CS.LuaUtils.IsNullOrDestroyed(self.mUIRoot) then
    setactive(self.mUIRoot, true)
  end
  if self.rank ~= nil then
    TimerSys:DelayCall(0.01, function()
      self.ui.chrAnimator:SetInteger("Color", self.rank)
    end)
  end
  self.nowTime = 0
  self.isChrSkipped = true
  self.ui.animator.enabled = true
  self.ui.animator:SetInteger("BGFadeIn", 0)
  if self.skipPanel ~= nil then
    setactive(self.skipPanel.ui.mBtn_BgSkip.gameObject, true)
    setactive(self.skipPanel.ui.mBtn_IconSkip.gameObject, true)
  end
  setactive(self.ui.chrAnimator.gameObject, true)
  self.ui.chrAnimator:ResetTrigger("FadeOut")
  self.ui.chrAnimator:Play("FadeIn_2")
  self.checkChrState2 = true
  self.chrStateInfo = self.ui.chrAnimator:GetCurrentAnimatorStateInfo(0)
  if (self.gunType == UICommonGetGunPanel.GunType.Gun or self.itemData and self.itemData.type == GlobalConfig.ItemType.GunType) and not self.isFirst then
    setactive(self.ui.mTrans_ExtraGet.gameObject, true)
    self.ui.extraGetAnimator:ResetTrigger("FadeOut")
    self.ui.extraGetAnimator:SetTrigger("FadeIn")
  else
    setactive(self.ui.mTrans_ExtraGet.gameObject, false)
  end
end
function UICommonGetGunPanel:ShowSSRTimeline()
  if self.mGunGetShow ~= nil then
    MessageSys:SendMessage(UIEvent.GashaAirportPlayable, nil)
    if not CS.LuaUtils.IsNullOrDestroyed(self.ssrTimelineParent) then
      setactive(self.ssrTimelineParent, true)
    end
    if SceneSys.currentScene:GetSceneType() == CS.EnumSceneType.Battle then
      SceneSys.currentScene:EnableSceneObjs(false)
    end
    if SceneSys.currentScene:GetSceneType() == CS.EnumSceneType.CommandCenter then
      SceneSys.currentScene:EnableGunGetSceneObjs(true)
    end
    if SceneSys.currentScene:GetSceneType() == CS.EnumSceneType.Gacha then
      SceneSys.currentScene:EnableVirtualCamera(true)
    end
  end
  self.timeLineShow = true
end
function UICommonGetGunPanel:OnShowStart()
  setactive(self.mUIRoot.gameObject, false)
  self:UpdatePanel()
  function self.OnSkip()
    if self.canSkip ~= nil and not self.canSkip then
      return
    end
    if self.isInGunScene ~= nil and self.isInGunScene == true then
      return
    end
    self.canSkip = false
    TimerSys:DelayCall(0.5, function()
      self.canSkip = true
    end)
    if self.gunType == UICommonGetGunPanel.GunType.Gun or self.itemData and self.itemData.type ~= GlobalConfig.ItemType.Weapon then
      if self.isChrSkipped then
        self.tmpBtnSkip = nil
        self:ShowNextPage()
      elseif not self.isFirst then
        if self.itemData and self.itemData.rank < 5 or self.timeLineShow then
          self:PlayFade2()
        elseif not self.timeLineShow and not self.loadGunGetSSRScene then
          self.checkChrState = false
          self:ShowSSRTimeline()
        end
      end
    elseif self.isSkippedWeapon then
      self:ShowNextPage()
    else
      self.isSkippedWeapon = true
      local resultBg = self.ui.bgJump:JumpTo()
      local resultWeapon = self.ui.weaponJump:JumpTo()
      if not resultBg and not resultWeapon then
        self:ShowNextPage()
      end
    end
  end
  if self.needSkip then
    local bgFunc = self.OnSkip
    local btnFunc = function()
      if self.isInGunScene ~= nil and self.isInGunScene == true then
        SceneSys:GetGunGetScene():SkipTimeline()
      else
        local topUI = UISystem:GetTopUI(UIGroupType.Default)
        if topUI.UIDefine.UIType == UIDef.UIGachaDialogPanel then
          MessageSys:SendMessage(UIEvent.GashaSpeakEnd, nil)
        else
          self:ShowUnskipablePage(true)
        end
      end
    end
    if (self.isUnskipable or self.isFirst) and self.gunType == UICommonGetGunPanel.GunType.Gun then
      bgFunc = nil
      btnFunc = nil
    end
    local param = {
      onInitFinished = function(skipPanel)
        self.skipPanel = skipPanel
        setactive(skipPanel.ui.mBtn_BgSkip.gameObject, not self.isGacha)
        setactive(skipPanel.ui.mBtn_IconSkip.gameObject, not self.isUnskipable and not self.isFirst)
      end,
      isDialog = true,
      bgSkip = bgFunc,
      btnSkip = btnFunc
    }
    if self.skipPanel == nil then
      UIManager.OpenUIByParam(UIDef.UIGashaponSkipPanel, param, CS.UISystem.UIGroupType.BattleUI)
    else
      self.skipPanel:RefreshView(param)
    end
  end
end
function UICommonGetGunPanel:OnEnd(skipPanel)
  if self.tmpBtnSkip ~= nil then
    self.tmpBtnSkip()
    self.tmpBtnSkip = nil
    return
  end
  if self.timeLineTimer ~= nil then
    self.timeLineTimer:Stop()
  end
  if self.timeLineShow ~= nil and not CS.LuaUtils.IsNullOrDestroyed(self.mGunGetShow) then
    local loader = self.mGunGetShow:GetComponent("GunShowTimelineLoader")
    if loader ~= nil then
      loader:DestroyTimelineObj()
    end
  end
  if SceneSys.currentScene:GetSceneType() == CS.EnumSceneType.Gacha then
    SceneSys.currentScene:SetActiveScene()
  end
  if self.autoClose then
    self.Close()
  end
  if self.callback ~= nil then
    self.callback(self, skipPanel)
    self.callback = nil
  end
  if self.skipPanel ~= nil then
    self.skipPanel.Close()
    self.skipPanel = nil
  end
end
function UICommonGetGunPanel:UpdatePanel()
  if self.gunType == UICommonGetGunPanel.GunType.Item then
    if SceneSys:GetGunGetScene() == nil then
      return
    end
    self.item = self.itemList[1]
    local itemData = TableData.listItemDatas:GetDataById(self.item.ItemId)
    if itemData.type == GlobalConfig.ItemType.Weapon and itemData.rank >= 5 then
      self.isFirst = NetCmdIllustrationData:CheckItemIsFirstTime(GlobalConfig.ItemType.Weapon, self.item.ItemId, not self.isGacha)
      SceneSys:SwitchVisible(CS.EnumSceneType.GunGetShowSSR)
      SceneSys:GetGunGetScene():LoadWeaponTimeline(self.item.ItemId)
      self.isInGunScene = true
      if self.skipPanel ~= nil then
        setactive(self.skipPanel.mUIRoot, not self.isFirst)
      end
    else
      setactive(self.mUIRoot.gameObject, true)
      self:UpdateItemPanel(self.item)
    end
  else
    setactive(self.mUIRoot.gameObject, true)
    self:UpdateGunContent(self.gunData)
    setactive(self.ui.mTrans_GunContent.gameObject, true)
    setactive(self.ui.mTrans_WeaponContent.gameObject, false)
  end
end
function UICommonGetGunPanel:UpdateItemPanel(data)
  if data == nil then
    return
  end
  if type(data) == "number" then
    self.itemData = TableData.GetItemData(data)
  else
    self.itemData = TableData.GetItemData(data.ItemId)
  end
  setactive(self.ui.mTrans_GunContent.gameObject, false)
  setactive(self.ui.mTrans_WeaponContent.gameObject, false)
  if self.itemData.type == GlobalConfig.ItemType.Weapon then
    setactive(self.ui.mTrans_WeaponContent.gameObject, true)
    local weaponData = TableData.listGunWeaponDatas:GetDataById(self.itemData.args[0])
    self:UpdateWeaponContent(weaponData)
    self.GetList = self.GetList or {}
    self.isFirst = NetCmdIllustrationData:CheckItemIsFirstTime(self.itemData.type, weaponData.id, not self.isGacha) and self.GetList[weaponData.id] == nil
    self.GetList[self.item.ItemId] = 1
    setactive(self.ui.mTrans_WeaponNew, self.isFirst or self.isUnskipable)
    setactive(self.ui.mTrans_ExtraGet.gameObject, false)
  elseif self.itemData.type == GlobalConfig.ItemType.GunType then
    setactive(self.ui.mTrans_GunContent.gameObject, true)
    local gunData = TableData.listGunDatas:GetDataById(self.itemData.args[0])
    if not self.isFirst then
      self.isFirst = NetCmdIllustrationData:CheckItemIsFirstTime(self.itemData.type, gunData.id, true)
    end
    self:UpdateGunContent(gunData)
    if not self.isFirst then
      self:UpdateItemList(gunData.sold_get1)
    end
    setactive(self.ui.mTrans_ChrNew, self.isFirst)
    setactive(self.ui.mTrans_ExtraGet.gameObject, false)
  end
end
function UICommonGetGunPanel:UpdateGunContent(gunData)
  if gunData then
    self.gunData = gunData
    local characterData = TableData.listGunCharacterDatas:GetDataById(gunData.character_id)
    local dutyData = TableData.listGunDutyDatas:GetDataById(gunData.duty)
    self.soundData = TableData.listAudioDatas:GetDataById(gunData.get_audio)
    self.ui.mText_ChrName.text = gunData.name.str
    self.ui.mImg_ChrAvatar.sprite = IconUtils.GetCharacterWholeSprite(gunData.code)
    if characterData.body_id.str ~= "" then
      self.ui.mImg_Pic.sprite = IconUtils.GetAtlasSprite("GashaponPic/Img_GashaponSignature_" .. characterData.body_id.str)
    end
    self.ui.mText_ChrContent.text = gunData.dialogue.str
    self.ui.mText_ChrType.text = "/" .. dutyData.name.str
    self.dutyItem:SetData(dutyData)
    self.ui.chrAnimator:SetInteger("Color", gunData.rank)
    setactive(self.ui.mTrans_ExtraGet.gameObject, false)
    setactive(self.ui.mTrans_ChrDialogBox.gameObject, false)
    if self.soundData ~= nil then
    end
    self.ui.chrAnimator:ResetTrigger("FadeIn_2")
    setactive(self.ui.chrAnimator.gameObject, false)
    self.chrStateInfo = self.ui.chrAnimator:GetCurrentAnimatorStateInfo(0)
    self.checkChrState = true
    self.rank = gunData.rank
    self.ui.animator.enabled = false
    function self.loadTimeLine()
      if gunData.gacha_get_timeline ~= "" then
        if SceneSys.currentScene:GetSceneType() == CS.EnumSceneType.Gacha then
          SceneSys.currentScene:HideDefaultObjs()
        end
        if not CS.LuaUtils.IsNullOrDestroyed(self.mGunGetShow) then
          if self.skipPanel ~= nil then
            setactive(self.skipPanel.ui.mBtn_BgSkip.gameObject, false)
            setactive(self.skipPanel.ui.mBtn_IconSkip.gameObject, not self.isUnskipable and not self.isFirst)
          end
          if SceneSys.CurSceneType == CS.EnumSceneType.GunGetShowSSR then
            SceneSys:GetGunGetScene():SetIsSpeaking(true)
          end
          function self.tmpBtnSkip()
            MessageSys:SendMessage(UIEvent.GashaSpeakEnd, true)
          end
          UIManager.OpenUIByParam(UIDef.UIGachaDialogPanel, {
            gunData,
            function()
              if self.skipPanel ~= nil then
                setactive(self.skipPanel.ui.mBtn_BgSkip.gameObject, true)
              end
              if SceneSys.CurSceneType == CS.EnumSceneType.GunGetShowSSR then
                SceneSys:GetGunGetScene():SetIsSpeaking(false)
              end
              CS.CriWareVideoController.StartPlay(gunData.gacha_get_timeline .. ".usm", CS.CriWareVideoType.eVideoPath, function()
                self:PlayFade2()
                self.loadGunGetSSRScene = false
                self.canSkip = false
                TimerSys:DelayCall(1, function()
                  self.canSkip = true
                end)
              end, not self.isUnskipable and not self.isFirst, 1, false, -1, 0, {
                gunData.gacha_get_audio,
                gunData.gacha_get_voice
              })
            end,
            function()
              if self.skipPanel ~= nil then
                setactive(self.skipPanel.ui.mBtn_BgSkip.gameObject, true)
              end
              if SceneSys.CurSceneType == CS.EnumSceneType.GunGetShowSSR then
                SceneSys:GetGunGetScene():SetIsSpeaking(false)
              end
              self:PlayFade2()
              self.loadGunGetSSRScene = false
            end,
            self.isUnskipable or self.isFirst,
            self.skipPanel
          })
        else
          gfwarning("GunGetShow为空或已被销毁！")
        end
      end
    end
    if self.mGunGetShow then
      self.loadTimeLine()
      self.loadTimeLine = nil
    end
  end
end
function UICommonGetGunPanel:UpdateWeaponContent(weaponData)
  local weaponTypeData = TableData.listGunWeaponTypeDatas:GetDataById(weaponData.type)
  local elementData = TableData.listLanguageElementDatas:GetDataById(weaponData.element)
  self.ui.mText_WeaponName.text = weaponData.name.str
  self.ui.mImg_WeaponIcon.sprite = IconUtils.GetWeaponSpriteL(weaponData.res_code)
  self.ui.mImg_WeaponType.sprite = IconUtils.GetGunGashaponPic(weaponTypeData.icon)
  self.ui.mText_WeaponType.text = "/" .. weaponTypeData.name.str
  self.ui.mAnimator_Weapon:SetInteger("Color", weaponData.rank)
  self.ui.animator:SetInteger("BGFadeIn", 1)
  self.ui.animator:Play("Weapon_FadeIn", 1, 0)
  self.ui.mAnimator_Weapon:Play("FadeIn", 0, 0)
end
function UICommonGetGunPanel:UpdateItemList(itemDataList)
  local item = {}
  for itemId, num in pairs(itemDataList) do
    item.id = itemId
    item.num = num
  end
  local itemData = TableData.listItemDatas:GetDataById(item.id)
  self.ui.mImg_ExtraIcon.sprite = IconUtils.GetItemIconSprite(item.id)
  self.ui.mText_ExtraNum.text = "+" .. item.num
end
