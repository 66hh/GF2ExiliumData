require("UI.UIBasePanel")
UIPVPDefenseTeamDialog = class("UIPVPDefenseTeamDialog", UIBasePanel)
UIPVPDefenseTeamDialog.__index = UIPVPDefenseTeamDialog
local self = UIPVPDefenseTeamDialog
UIPVPDefenseTeamDialog.TeamType = {TeamA = 0, TeamB = 1}
UIPVPDefenseTeamDialog.DotItemBgColor = {
  Default = Color(0.6862745098039216, 0.6862745098039216, 0.6862745098039216, 0.2),
  Use = Color(0 / 255, 0.9450980392156862, 0.4588235294117647, 1)
}
function UIPVPDefenseTeamDialog:ctor(obj)
  UIPVPDefenseTeamDialog.super.ctor(self)
  obj.Type = UIBasePanelType.Dialog
end
function UIPVPDefenseTeamDialog:OnInit(root)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.curTeam = UIPVPDefenseTeamDialog.TeamType.TeamA
  self.curUseMapId = 1
  self.curPreviewMapId = 1
  self.curPreviewMapIndex = 0
  self.curMapData = nil
  self.isOnClickUseBtn = false
  self.needRefresh = false
  self.limitNameList = {
    TableData.GetHintById(120199),
    TableData.GetHintById(120200),
    TableData.GetHintById(120201),
    TableData.GetHintById(120202)
  }
  self.ui.defendRed = self.ui.mBtn_Edit.transform:Find("Root/Trans_RedPoint").gameObject
  UIUtils.GetButtonListener(self.ui.mBtn_BtnBack.gameObject).onClick = function()
    UIPVPGlobal.CurPreviewMapIndex = -1
    UIManager.CloseUI(UIDef.UIPVPDefenseTeamDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnHome.gameObject).onClick = function()
    UIPVPGlobal.CurPreviewMapIndex = -1
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnDescription.gameObject).onClick = function()
    self:ShowDesc(true)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Content.gameObject).onClick = function()
    self:ChangePvpMap(-1)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Content1.gameObject).onClick = function()
    self:ChangePvpMap(1)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnTeamA.gameObject).onClick = function()
    self.curTeam = UIPVPDefenseTeamDialog.TeamType.TeamA
    self:ChangeDefenseTeam()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnTeamB.gameObject).onClick = function()
    self.curTeam = UIPVPDefenseTeamDialog.TeamType.TeamB
    self:ChangeDefenseTeam()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Edit.gameObject).onClick = function()
    self:OnClickEditMapBtn()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    self:OnClickConfirmMapBtn()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Buy.gameObject).onClick = function()
    self:OnClickBuyMapBtn()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Preview.gameObject).onClick = function()
    self:OnClickEditMapBtn(true)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_LvUp.gameObject).onClick = function()
    UIManager.JumpUIByParam(UIDef.PVPMapLvUpConfirmDialog, {
      self.curTeam,
      self.curPreviewMapId
    })
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnExitGame.gameObject).onClick = function()
    local data = {
      [1] = TableData.GetHintById(120070),
      [2] = TableData.GetHintById(120064)
    }
    UIManager.OpenUIByParam(UIDef.SimpleMessageBoxPanel, data)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_RankAddition.gameObject).onClick = function()
    local data = {
      [1] = TableData.GetHintById(120154),
      [2] = self.SeasonDesc
    }
    UIManager.OpenUIByParam(UIDef.SimpleMessageBoxPanel, data)
  end
  self.isUpLevel = false
  function self.RefreshPanel()
    self.isUpLevel = true
  end
  MessageSys:AddListener(UIEvent.PvpMapUpLevel, self.RefreshPanel)
  self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_BtnBack)
  self:InitData()
end
function UIPVPDefenseTeamDialog:RefreshMapUpLevel()
  NetCmdPVPData:InitPvpDatas()
  self:ShowMapByIndex(UIPVPGlobal.CurPreviewMapIndex)
  self:UpdatePvpMapData()
end
function UIPVPDefenseTeamDialog:ShowBaseMapUpLv()
  if NetCmdPVPData:GetBaseMapUpLv() == 1 then
    NetCmdPVPData:SetBaseMapUpLv(0)
    NetCmdPVPData:SetMapUpLvRed(self.curMapData.map_group, 2)
    local mapData = TableData.listNrtpvpMapDatas:GetDataById(NetCmdPVPData:GetBaseMapUseId())
    if mapData ~= nil then
      UIManager.OpenUIByParam(UIDef.PVPMapLvUpDialog, mapData)
    end
  end
end
function UIPVPDefenseTeamDialog:CleanTime()
  if self.upOrBuyTime then
    self.upOrBuyTime:Stop()
    self.upOrBuyTime = nil
  end
end
function UIPVPDefenseTeamDialog:RefreshUpOrBuyMapTime()
  self:CleanTime()
  setactive(self.ui.mTrans_LimitedBuyTime.gameObject, false)
  setactive(self.ui.mTrans_LimitedUPTime.gameObject, false)
  setactive(self.ui.mTrans_LvUp.gameObject, false)
  local storeData = TableDataBase.listStoreGoodDatas:GetDataById(self.curMapData.map_num)
  if storeData == nil or storeData.show_time == nil or storeData.close_time == nil then
    return
  end
  local nowTime = CGameTime:GetTimestamp()
  local open = false
  if nowTime >= storeData.show_time and nowTime <= storeData.close_time then
    open = true
  end
  local repeatCount = math.ceil(storeData.close_time - nowTime)
  local timeIndex = 1
  if 1 > self.curMapData.map_level or not NetCmdPVPData.UserMapDic[self.curPreviewMapIndex].Value then
    if storeData.feature_code.Count > 0 and storeData.feature_code[0] == 4 then
      timeIndex = 3
      local timeStr = CS.TimeUtils.LeftTimeToShowFormat(storeData.close_time - CGameTime:GetTimestamp())
      self.ui.mText_BuyTime.text = string_format(self.limitNameList[3], timeStr)
      setactive(self.ui.mTrans_LimitedBuyTime.gameObject, open)
    else
      local timeStr = CS.TimeUtils.LeftTimeToShowFormat(storeData.close_time - CGameTime:GetTimestamp())
      self.ui.mText_Time.text = string_format(self.limitNameList[1], timeStr)
      setactive(self.ui.mTrans_LimitedUPTime.gameObject, open)
    end
  elseif self.curMapData.map_level < 3 then
    if storeData.feature_code.Count > 0 and storeData.feature_code[0] == 4 then
      timeIndex = 4
      local timeStr = CS.TimeUtils.LeftTimeToShowFormat(storeData.close_time - CGameTime:GetTimestamp())
      self.ui.mText_BuyTime.text = string_format(self.limitNameList[4], timeStr)
      setactive(self.ui.mTrans_LimitedBuyTime.gameObject, open)
    else
      timeIndex = 2
      local timeStr = CS.TimeUtils.LeftTimeToShowFormat(storeData.close_time - CGameTime:GetTimestamp())
      self.ui.mText_Time.text = string_format(self.limitNameList[2], timeStr)
      setactive(self.ui.mTrans_LimitedUPTime.gameObject, open)
    end
  else
    open = false
  end
  setactive(self.ui.mTrans_LvUp.gameObject, open and 0 < self.curMapData.map_upgrade_id)
  if open then
    self.upOrBuyTime = TimerSys:DelayCall(1, function()
      local timeDesc = CS.TimeUtils.LeftTimeToShowFormat(storeData.close_time - CGameTime:GetTimestamp())
      if timeIndex == 1 or timeIndex == 2 then
        self.ui.mText_Time.text = string_format(self.limitNameList[timeIndex], timeDesc)
      else
        self.ui.mText_BuyTime.text = string_format(self.limitNameList[timeIndex], timeDesc)
      end
    end, nil, repeatCount)
  end
end
function UIPVPDefenseTeamDialog:OnShowFinish()
  UIPVPGlobal.isMyDefend = true
  if not self.needRefresh then
    return
  end
  if UIPVPGlobal.CurPreviewMapIndex < 0 then
    self:ShowFirstMap()
  else
    self:ShowMapByIndex(UIPVPGlobal.CurPreviewMapIndex)
  end
  self.needRefresh = false
  self:ShowBaseMapUpLv()
end
function UIPVPDefenseTeamDialog:OnHide()
  self.isHide = true
end
function UIPVPDefenseTeamDialog:InitData()
  NetCmdPVPData:InitPvpDatas()
  self.curUseMapId = NetCmdPVPData.CurMapId
  self.curPreviewMapId = self.curUseMapId
  self.curMapData = TableData.listNrtpvpMapDatas:GetDataById(self.curUseMapId)
  self.needRefresh = true
  setactive(self.ui.mTrans_ViewSwitch.gameObject, NetCmdPVPData.UserMapDic.Count > 1)
end
function UIPVPDefenseTeamDialog:UpdatePvpMapData()
  self:SetPreviewMapData()
  self:UpdatePvpMapDotData()
  self:ChangeDefenseTeam()
  self:UpdateBtn()
  self:RefreshUpOrBuyMapTime()
  self:RefreshBtnState()
end
function UIPVPDefenseTeamDialog:RefreshBtnState()
  self.SeasonDesc = TableData.GetHintById(120155)
  local ShowBtn = false
  local seasonId
  for i = 1, self.curMapData.season_buff_time.Count do
    if NetCmdPVPData.seasonData.id == self.curMapData.season_buff_time[i - 1] then
      seasonId = self.curMapData.season_buff_time[i - 1]
      break
    end
  end
  if seasonId then
    local pvpSeasonCycleData = TableDataBase.listPlanDatas:GetDataById(seasonId)
    if CGameTime:GetTimestamp() >= pvpSeasonCycleData.OpenTime and CGameTime:GetTimestamp() <= pvpSeasonCycleData.CloseTime then
      local dataA, dataB = math.floor(self.curMapData.season_buff_effect[0] * 0.1), math.floor(self.curMapData.season_buff_effect[1] * 0.1)
      if 0 < dataA then
        if 0 < dataB then
          self.SeasonDesc = string_format(TableData.GetHintById(120155), dataA .. "%", dataB .. "%")
        else
          self.SeasonDesc = string_format(TableData.GetHintById(120162), dataA .. "%")
        end
      else
        self.SeasonDesc = string_format(TableData.GetHintById(120163), dataB .. "%")
      end
      ShowBtn = true
    end
  end
  setactive(self.ui.mBtn_RankAddition.gameObject, ShowBtn)
  if 0 < NetCmdPVPData:GetMapMessageBox(self.curMapData.Id) then
    NetCmdPVPData:SetMapMessageBox(self.curMapData.Id, 0)
    local content = string_format(TableData.GetHintById(120198), self.curMapData.MapName)
    CS.PopupMessageManager.PopupStateChangeString(content)
  end
end
function UIPVPDefenseTeamDialog:UpdatePvpMapDotData()
  local tmpDotItem = self.ui.mTrans_DotItem
  local tmpDot = self.ui.mTrans_Dot
  setactive(tmpDotItem.gameObject, false)
  for i = 0, NetCmdPVPData.UserMapDic.Count - 1 do
    local tmpObj
    if tmpDot.childCount > i + 1 then
      tmpObj = tmpDot.transform:GetChild(i + 1).gameObject
    else
      tmpObj = instantiate(tmpDotItem)
      UIUtils.AddListItem(tmpObj, tmpDot.gameObject)
    end
    setactive(tmpObj, true)
    local tmpImg = tmpObj.transform:Find("ImgBg"):GetComponent("Image")
    tmpImg.color = UIPVPDefenseTeamDialog.DotItemBgColor.Default
    local tmpOutline = tmpObj.transform:Find("Outline").gameObject
    local tmpUserMap = NetCmdPVPData.UserMapDic[i]
    setactive(tmpOutline, tmpUserMap.Key == self.curPreviewMapId)
    if tmpUserMap.Key == self.curUseMapId then
      tmpImg.color = UIPVPDefenseTeamDialog.DotItemBgColor.Use
    else
      tmpImg.color = UIPVPDefenseTeamDialog.DotItemBgColor.Default
    end
  end
end
function UIPVPDefenseTeamDialog:ChangeDefenseTeam()
  if self.curTeam == UIPVPDefenseTeamDialog.TeamType.TeamA then
    self.ui.mBtn_BtnTeamA.interactable = false
    self.ui.mBtn_BtnTeamB.interactable = true
  elseif self.curTeam == UIPVPDefenseTeamDialog.TeamType.TeamB then
    self.ui.mBtn_BtnTeamA.interactable = true
    self.ui.mBtn_BtnTeamB.interactable = false
  end
  setactive(self.ui.mTrans_Machine.gameObject, false)
  setactive(self.ui.mTrans_TeamContent.gameObject, false)
  local gunCmdDatas = NetCmdPVPData:GetGunCmdDatasByPvpMapIdWithType(self.curPreviewMapId, self.curTeam)
  if gunCmdDatas == nil then
    return
  end
  UIPVPGlobal.SetPvpGunCmdDatas(self.ui.mTrans_TeamContent, gunCmdDatas, nil, UIPVPGlobal.LineUpType.MeDefend)
  setactive(self.ui.mTrans_TeamContent.gameObject, true)
end
function UIPVPDefenseTeamDialog:ChangePvpMap(changeIndex)
  local index = self.curPreviewMapIndex + changeIndex
  if index < 0 then
    index = NetCmdPVPData.UserMapDic.Count - 1
  end
  if index > NetCmdPVPData.UserMapDic.Count - 1 then
    index = 0
  end
  UIPVPGlobal.CurPreviewMapIndex = index
  local AnimTriggerName = 0 < changeIndex and "Next" or "Previous"
  self.ui.mAnimator_Root:SetTrigger(AnimTriggerName)
  self.curPreviewMapIndex = index
  self.curTeam = UIPVPDefenseTeamDialog.TeamType.TeamA
  self.curPreviewMapId = NetCmdPVPData.UserMapDic[self.curPreviewMapIndex].Key
  self.curMapData = TableData.listNrtpvpMapDatas:GetDataById(self.curPreviewMapId)
  self:UpdatePvpMapData()
end
function UIPVPDefenseTeamDialog:SetPreviewMapData()
  local tmpUserMap = NetCmdPVPData.UserMapDic[self.curPreviewMapIndex]
  setactive(self.ui.mTrans_Open.gameObject, tmpUserMap.Value)
  setactive(self.ui.mTrans_Lock.gameObject, not tmpUserMap.Value)
  if tmpUserMap.Value then
    if self.isOnClickUseBtn then
      self.ui.mAnimator_Root:SetInteger("Action", 1)
      self.isOnClickUseBtn = false
    elseif tmpUserMap.Key ~= self.curUseMapId then
      self.ui.mAnimator_Root:SetInteger("Action", 0)
    else
      self.ui.mAnimator_Root:SetInteger("Action", 2)
    end
  else
    self.ui.mAnimator_Root:SetInteger("Action", 0)
    NetCmdPVPData:SetMapUpLvRed(self.curMapData.map_group, 2)
  end
  setactive(self.ui.mTrans_NotUsedBg.gameObject, tmpUserMap.Key ~= self.curUseMapId)
  setactive(self.ui.mTrans_UesdBg.gameObject, tmpUserMap.Key == self.curUseMapId)
  self.ui.mText_PvpMapTittle.text = self.curMapData.MapName
  self.ui.mText_Num.text = NetCmdPVPData:GetEffectNumByPvpMapIdWithType(self.curPreviewMapId, self.curTeam)
  setactive(self.ui.mTrans_TeamSwitch.gameObject, 1 < self.curMapData.BarrierId.Count)
  setactive(self.ui.mTrans_TeamSwitchText.gameObject, 1 < self.curMapData.BarrierId.Count)
  self.ui.mImg_BgR.sprite = IconUtils.GetAtlasSprite("PVPPic/" .. self.curMapData.NameResources)
  local storeData = TableDataBase.listStoreGoodDatas:GetDataById(self.curMapData.map_num)
  if storeData then
    self.ui.mImg_Icon.sprite = IconUtils.GetItemIconSprite(storeData.price_type)
  end
  if self.curMapData.map_type == 1 then
    self.ui.mText_NormalType.text = TableData.GetHintById(120126 + self.curMapData.map_level)
    self.ui.mText_UPType.text = ""
  else
    self.ui.mText_UPType.text = TableData.GetHintById(120130 + self.curMapData.map_level)
    self.ui.mText_NormalType.text = ""
  end
end
function UIPVPDefenseTeamDialog:ResetDialog()
  setactive(self.ui.mBtn_Edit.transform.parent.gameObject, false)
  setactive(self.ui.mBtn_Confirm.transform.parent.gameObject, false)
  setactive(self.ui.mBtn_Preview.transform.parent.gameObject, false)
  setactive(self.ui.mText_Buy.gameObject, false)
  setactive(self.ui.mBtn_Buy.transform.parent.gameObject, false)
  setactive(self.ui.mTrans_Consume.gameObject, false)
  setactive(self.ui.mBtn_LvUp.gameObject, false)
end
function UIPVPDefenseTeamDialog:UpdateBtn()
  self:ResetDialog()
  local tmpUserMap = NetCmdPVPData.UserMapDic[self.curPreviewMapIndex]
  local tmpNrtpvpMapData = TableData.listNrtpvpMapDatas:GetDataById(tmpUserMap.Key)
  if tmpNrtpvpMapData.MapType == 2 then
    if tmpUserMap.Value then
      setactive(self.ui.mBtn_Edit.transform.parent.gameObject, true)
      setactive(self.ui.mBtn_Confirm.transform.parent.gameObject, tmpUserMap.Key ~= self.curUseMapId)
    else
      setactive(self.ui.mBtn_Preview.transform.parent.gameObject, true)
      local tmpStoreGood = TableData.listStoreGoodDatas:GetDataById(self.curMapData.MapNum)
      local nowTime = CGameTime:GetTimestamp()
      local canBuy = nowTime > tmpStoreGood.ShowTime and nowTime < tmpStoreGood.CloseTime
      local canUnlockMap = NetCmdPVPData.PvpInfo.level >= self.curMapData.MapOpenLevel
      local needRedPoint = NetCmdPVPData:CheckPvpMapRedPoint(self.curMapData.Id)
      if not needRedPoint then
        if canUnlockMap then
          self.ui.mAnimator_Root:SetInteger("Lock", 2)
        else
          self.ui.mAnimator_Root:SetInteger("Lock", 0)
        end
      elseif canUnlockMap then
        self.ui.mAnimator_Root:SetInteger("Lock", 1)
        NetCmdPVPData:SetPvpRedPointTrue(self.curMapData.Id)
      end
      setactive(self.ui.mBtn_Buy.transform.parent.gameObject, canBuy and canUnlockMap)
      setactive(self.ui.mTrans_Consume.gameObject, canUnlockMap)
      setactive(self.ui.mText_Buy.gameObject, canBuy and (not canUnlockMap or needRedPoint))
      local targetLevel = NetCmdPVPData.seasonData.Type * 100 + self.curMapData.MapOpenLevel
      local pvpLevelData = TableData.listNrtpvpLevelDatas:GetDataById(targetLevel)
      self.ui.mText_Buy.text = string_format(TableData.GetHintById(120040), pvpLevelData.Name.str)
      self.ui.mText_TextNum.text = math.ceil(tmpStoreGood.Price)
      local resNum = NetCmdItemData:GetItemCountById(tmpStoreGood.price_type)
      self.ui.mText_TextNum.color = ColorUtils.WhiteColor
      if resNum < tmpStoreGood.Price then
        self.ui.mText_TextNum.color = ColorUtils.RedColor
      else
        UIUtils.GetButtonListener(self.ui.mBtn_Buy.gameObject).onClick = function()
          self:OnClickBuyMapBtn()
        end
      end
    end
  else
    setactive(self.ui.mBtn_Edit.transform.parent.gameObject, true)
    setactive(self.ui.mBtn_Confirm.transform.parent.gameObject, tmpUserMap.Key ~= self.curUseMapId)
    local needRedPoint = NetCmdPVPData:CheckPvpMapRedPoint(self.curMapData.Id)
    if needRedPoint then
      self.ui.mAnimator_Root:SetInteger("Lock", 1)
      NetCmdPVPData:SetPvpRedPointTrue(self.curMapData.Id)
    end
  end
  setactive(self.ui.mBtn_LvUp.gameObject, self.curMapData.map_upgrade_id ~= 0 and NetCmdPVPData.UserMapDic[self.curPreviewMapIndex].Value)
end
function UIPVPDefenseTeamDialog:OnClickEditMapBtn(isPreview)
  if isPreview == nil then
    isPreview = false
  end
  local pvpStageParam = CS.PvpStageParam()
  pvpStageParam.PvpPreview = isPreview
  pvpStageParam.PvpDefendMapId = self.curPreviewMapId
  NetCmdPVPData:OpenBattleSceneForPVP(pvpStageParam)
end
function UIPVPDefenseTeamDialog:OnClickBuyMapBtn()
  local tmpStoreGood = TableData.listStoreGoodDatas:GetDataById(self.curMapData.MapNum)
  local resNum = NetCmdItemData:GetResItemCount(tmpStoreGood.price_type)
  local pvpCoinItem = TableData.listItemDatas:GetDataById(tmpStoreGood.price_type)
  if resNum < tmpStoreGood.Price then
    PopupMessageManager.PopupString(string_format(TableData.GetHintById(120079), pvpCoinItem.name.str))
    return
  else
    local hint = string_format(TableData.GetHintById(120068), math.ceil(tmpStoreGood.Price), pvpCoinItem.name.str, tmpStoreGood.Name.str)
    local content = MessageContent.New(hint, MessageContent.MessageType.DoubleBtn, function()
      NetCmdPVPData:SendStoreBuyPvpMap(tmpStoreGood.Id, tmpStoreGood.Price, function(ret)
        if ret == ErrorCodeSuc then
          NetCmdPVPData:InitPvpDatas()
          self:UpdatePvpMapData()
          CS.PopupMessageManager.PopupStateChangeString(TableData.GetHintById(120067))
        end
      end)
    end)
    MessageBoxPanel.Show(content)
  end
end
function UIPVPDefenseTeamDialog:OnClickConfirmMapBtn()
  if NetCmdPVPData:CheckMapCanUse(self.curPreviewMapId) then
    NetCmdPVPData:ReqNrtPvpUseCurrMap(self.curPreviewMapId, function(ret)
      if ret == ErrorCodeSuc then
        self.isOnClickUseBtn = true
        self.curUseMapId = NetCmdPVPData.CurMapId
        self:SetPreviewMapData()
        self:UpdatePvpMapDotData()
        self:UpdateBtn()
      end
    end)
  else
    local hint = 120041
    if TableData.listNrtpvpMapDatas:GetDataById(self.curPreviewMapId).BarrierId.Count <= 1 then
      hint = 120078
    end
    CS.PopupMessageManager.PopupString(TableData.GetHintById(hint))
  end
end
function UIPVPDefenseTeamDialog:OnClickUpdateMapBtn()
end
function UIPVPDefenseTeamDialog:ShowDesc(enable)
end
function UIPVPDefenseTeamDialog:ShowFirstMap()
  local curFocusMapId = NetCmdPVPData:GetFirstPvpMapId()
  local index = 0
  for i = 0, NetCmdPVPData.UserMapDic.Count - 1 do
    local tmpUserMap = NetCmdPVPData.UserMapDic[i]
    if tmpUserMap.Key == curFocusMapId then
      index = i
      break
    end
  end
  self:ShowMapByIndex(index)
end
function UIPVPDefenseTeamDialog:ShowMapByIndex(index)
  self.curPreviewMapIndex = index
  if self.curPreviewMapIndex < 0 then
    self.curPreviewMapIndex = 0
  end
  self.curTeam = UIPVPDefenseTeamDialog.TeamType.TeamA
  self.curPreviewMapId = NetCmdPVPData.UserMapDic[self.curPreviewMapIndex].Key
  self.curMapData = TableData.listNrtpvpMapDatas:GetDataById(self.curPreviewMapId)
  self:UpdatePvpMapData()
end
function UIPVPDefenseTeamDialog:OnRelease()
  self:CleanTime()
end
function UIPVPDefenseTeamDialog:OnClose()
  self:CleanTime()
  UIPVPGlobal.isMyDefend = false
  MessageSys:RemoveListener(UIEvent.PvpMapUpLevel, self.RefreshPanel)
end
function UIPVPDefenseTeamDialog:OnTop()
  if self.isUpLevel then
    self.isUpLevel = false
    self:RefreshMapUpLevel()
  end
end
