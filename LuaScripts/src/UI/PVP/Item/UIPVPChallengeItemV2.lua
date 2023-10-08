require("UI.UIBaseCtrl")
UIPVPChallengeItemV2 = class("UIPVPChallengeItemV2", UIBaseCtrl)
UIPVPChallengeItemV2.__index = UIPVPChallengeItemV2
function UIPVPChallengeItemV2:ctor()
end
function UIPVPChallengeItemV2:InitCtrl(parent, obj)
  local itemPrefab, instObj
  if obj == nil then
    itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
    instObj = instantiate(itemPrefab.childItem)
  else
    instObj = obj
  end
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  UIUtils.GetButtonListener(self.ui.mBtn_Root.gameObject).onClick = function()
    self:OnClickSelf()
  end
  self.detailType = UIPVPGlobal.ButtonType.Challenge
  self.pvpHistoryInfo = nil
  self.pvpOpponentInfo = nil
  self.isNPC = false
  self.index = 1
end
function UIPVPChallengeItemV2:SetData(data, detailType, index)
  self.detailType = detailType
  self.index = index or 0
  local coverData
  if self.detailType == UIPVPGlobal.ButtonType.Challenge then
    self.pvpOpponentInfo = data
    self.ui.mText_EffectNum.text = self.pvpOpponentInfo:GetEffectNum()
  elseif self.detailType == UIPVPGlobal.ButtonType.History then
    self.pvpHistoryInfo = data
    self.pvpOpponentInfo = self.pvpHistoryInfo.opponent
    coverData = NetCmdPVPData:GetHistoryCapacity(data.battleId)
    self.ui.mText_EffectNum.text = coverData.capacity
  end
  self.pvpOpponentInfo = self.pvpOpponentInfo
  self.ui.mText_ScoreNum.text = self.pvpOpponentInfo.points
  if not (mapData and mapData.map_type > 1) or 0 < self.pvpOpponentInfo.uid then
  else
    local pvpDummyData = TableData.listPvpDummyDatas:GetDataById(self.pvpOpponentInfo.DummyId)
    self.ui.mText_RobotScoreNum.text = NetCmdPVPData:GetConfigRobotFight(self.pvpOpponentInfo:GetRobotIDByTeam(self.curTeam), pvpDummyData.level)
  end
  self.ui.mText_Rank.text = UIPVPGlobal.GetLevel(self.pvpOpponentInfo.level)
  UIPVPGlobal.GetRankImage(self.pvpOpponentInfo.level, self.ui.mImg_Icon, self.ui.mImg_IconBg)
  UIPVPGlobal.GetRankNumImage(self.pvpOpponentInfo.level, self.ui.mImg_StarNum)
  setactive(self.ui.mTrans_AiName.gameObject, self.isNPC)
  setactive(self.ui.mTrans_PlayerName.gameObject, not self.isNPC)
  if self.isNPC then
    self.ui.mText_AiName.text = self.pvpOpponentInfo.user.Name
  else
    self.ui.mText_PlayerName.text = self.pvpOpponentInfo.user.Name
  end
  local tmpFullGunCmdData = self.pvpOpponentInfo:GetLineUpDetailByTeam(0)[0]
  if tmpFullGunCmdData and tmpFullGunCmdData.gunData then
    local currGunData = TableData.listGunDatas:GetDataById(tmpFullGunCmdData.gunData.Id)
    if currGunData then
      if self.isNPC then
        self.ui.mImg_Figure.sprite = IconUtils.GetCharacterGachaSprite(currGunData.code)
      elseif coverData then
        self.ui.mImg_Figure.sprite = IconUtils.GetCharacterTypeSpriteWithClothByGunId(IconUtils.cCharacterAvatarType_Avatar, IconUtils.cCharacterAvatarGacha, tmpFullGunCmdData.gunData.Id, coverData.costume)
      else
        local clothId = self.pvpOpponentInfo:getClothIdByIndex(0)
        if 0 < clothId then
          self.ui.mImg_Figure.sprite = IconUtils.GetCharacterTypeSpriteWithClothByGunId(IconUtils.cCharacterAvatarType_Avatar, IconUtils.cCharacterAvatarGacha, tmpFullGunCmdData.gunData.Id, clothId)
        else
          self.ui.mImg_Figure.sprite = IconUtils.GetCharacterTypeSpriteWithClothByGunId(IconUtils.cCharacterAvatarType_Avatar, IconUtils.cCharacterAvatarGacha, tmpFullGunCmdData.gunData.Id)
        end
      end
    else
      self.ui.mImg_Figure.sprite = IconUtils.GetCharacterGachaSprite("NemesisSR")
    end
  else
    local iconName = "NemesisSR"
    if self.pvpHistoryInfo and self.pvpHistoryInfo.NrtPvpHistory.Opponent and self.pvpHistoryInfo.NrtPvpHistory.Opponent.DefendGuns then
      local defendData = self.pvpHistoryInfo.NrtPvpHistory.Opponent.DefendGuns[0].DefendGuns
      if defendData and defendData.Avatars then
        local id = 0
        for i = 0, defendData.Avatars.Count - 1 do
          if 0 < defendData.Avatars[i].Id then
            id = defendData.Avatars[i].Id
            break
          end
        end
        if self.pvpOpponentInfo.uid == 0 and 100000 < id then
          id = defendData.Avatars[0].Id // 100
        end
        local gunData = TableData.listGunDatas:GetDataById(id, true)
        if gunData then
          if coverData then
            self.ui.mImg_Figure.sprite = IconUtils.GetCharacterTypeSpriteWithClothByGunId(IconUtils.cCharacterAvatarType_Avatar, IconUtils.cCharacterAvatarGacha, id, coverData.costume)
          else
            iconName = gunData.en_name.str
            self.ui.mImg_Figure.sprite = IconUtils.GetCharacterGachaSprite(iconName)
          end
        end
      end
    end
  end
  self:SetItemState()
end
function UIPVPChallengeItemV2:SetItemState()
  local hint1 = TableData.GetHintById(120005)
  local hint2 = TableData.GetHintById(120016)
  local hint3 = TableData.GetHintById(120042)
  local hint4 = TableData.GetHintById(120043)
  local resultText
  setactive(self.ui.mTrans_State.gameObject, true)
  setactive(self.ui.mTrans_AddScore.gameObject, false)
  local desc = string.format("id = %d 类型 = %d 结果 = %d", self.pvpOpponentInfo.uid, self.detailType, self.pvpOpponentInfo.result)
  print(desc)
  if self.detailType == UIPVPGlobal.ButtonType.Challenge then
    if self.pvpOpponentInfo.result == 0 then
      setactive(self.ui.mTrans_State.gameObject, false)
      self.ui.mBtn_Root.interactable = true
      setactive(self.ui.mTrans_AddScore.gameObject, true)
    elseif self.pvpOpponentInfo.result == 1 then
      self.ui.mBtn_Root.interactable = false
      resultText = hint1
      setactive(self.ui.mTrans_Success.gameObject, true)
      self.ui.mText_Success.text = resultText
      setactive(self.ui.mTrans_Fail.gameObject, false)
      self.ui.mText_Fail.text = resultText
    elseif self.pvpOpponentInfo.result == 2 then
      self.ui.mBtn_Root.interactable = false
      resultText = hint2
      setactive(self.ui.mTrans_Success.gameObject, false)
      self.ui.mText_Success.text = resultText
      setactive(self.ui.mTrans_Fail.gameObject, true)
      self.ui.mText_Fail.text = resultText
    end
    setactive(self.ui.mTrans_Time.gameObject, false)
    setactive(self.ui.mTrans_Score.gameObject, false)
  else
    setactive(self.ui.mTrans_State.gameObject, true)
    if self.pvpHistoryInfo.positive then
      if self.pvpHistoryInfo.result then
        resultText = hint1
        setactive(self.ui.mTrans_Success.gameObject, true)
        self.ui.mText_Success.text = resultText
        setactive(self.ui.mTrans_Fail.gameObject, false)
        self.ui.mText_Fail.text = resultText
      else
        resultText = hint2
        setactive(self.ui.mTrans_Success.gameObject, false)
        self.ui.mText_Success.text = resultText
        setactive(self.ui.mTrans_Fail.gameObject, true)
        self.ui.mText_Fail.text = resultText
      end
    elseif self.pvpHistoryInfo.result then
      resultText = hint3
      setactive(self.ui.mTrans_Success.gameObject, true)
      self.ui.mText_Success.text = resultText
      setactive(self.ui.mTrans_Fail.gameObject, false)
      self.ui.mText_Fail.text = resultText
    else
      resultText = hint4
      setactive(self.ui.mTrans_Success.gameObject, false)
      self.ui.mText_Success.text = resultText
      setactive(self.ui.mTrans_Fail.gameObject, true)
      self.ui.mText_Fail.text = resultText
    end
    setactive(self.ui.mTrans_Time.gameObject, true)
    setactive(self.ui.mTrans_Score.gameObject, true)
    UIPVPGlobal.GetResult(self.pvpHistoryInfo, self.ui.mText_Time, self.ui.mText_Score)
  end
end
function UIPVPChallengeItemV2:SetAddPointText(addPointText)
  self.ui.mText_AddScore.text = TableData.GetHintById(120088) .. "+" .. addPointText
end
function UIPVPChallengeItemV2:OnClickSelf()
  if self.detailType == UIPVPGlobal.ButtonType.Challenge and self.pvpOpponentInfo.result ~= 0 then
    return
  end
  if self.detailType == UIPVPGlobal.ButtonType.Challenge then
    local tmpData = self.pvpOpponentInfo
    UIManager.OpenUIByParam(UIDef.UIPVPEmbattleDetailDialog, {
      tmpData = tmpData,
      detailType = self.detailType,
      index = self.index
    })
  elseif self.detailType == UIPVPGlobal.ButtonType.History then
    NetCmdPVPData:ReqPvpHistory(CS.ProtoCsmsg.CS_NrtPvpHistory.Types.PvpHistoryInfoType.SingleFull, self.pvpHistoryInfo.battleId, function(ret)
      if ret == ErrorCodeSuc then
        local tmpData = NetCmdPVPData:GetHistoryByBattleId(self.pvpHistoryInfo.battleId) or self.pvpHistoryInfo
        UIManager.OpenUIByParam(UIDef.UIPVPEmbattleDetailDialog, {
          tmpData = tmpData,
          detailType = self.detailType,
          index = self.index
        })
      end
    end)
  end
end
