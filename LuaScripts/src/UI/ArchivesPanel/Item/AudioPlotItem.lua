require("UI.UIBaseCtrl")
AudioPlotItem = class("AudioPlotItem", UIBaseCtrl)
AudioPlotItem.__index = AudioPlotItem
function AudioPlotItem:__InitCtrl()
end
function AudioPlotItem:InitCtrl(root)
  local com = root:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
end
function AudioPlotItem:SetData(Data, Type, index, uiAudioPlotPanel, uiRoleFileDetailPanel)
  self.uiAudioPlotPanel = uiAudioPlotPanel
  self.uiRoleFileDetailPanel = uiRoleFileDetailPanel
  self.Id = Data.Id
  setactive(self.ui.mTrans_Sound, false)
  setactive(self.ui.mTrans_Video, false)
  setactive(self.ui.mTrans_GrpLock, false)
  if Type == 1 then
    local condition1 = NetCmdTeamData:GetGunByID(self.uiAudioPlotPanel.GunId).mGun.GunClass >= Data.Level
    local condition2 = Data.LastWatch
    self.ui.mText_Name.text = TableData.listAvgPlotDatas:GetDataById(Data.Id).name.str
    if condition1 and condition2 then
      self.ui.mAnim_Self:SetBool("Selected", true)
      setactive(self.ui.mText_LockText.gameObject, false)
      UIUtils.GetButtonListener(self.ui.mBtn_Self.gameObject).onClick = function()
        CS.AVGController.PlayAvgByPlotId(Data.Id, function()
          local name = self.uiRoleFileDetailPanel.mData.en_name
          self.uiAudioPlotPanel:UpdateItemList()
        end)
      end
      self:UpdateRedPoint(Type, Data.Id, index, true)
    else
      self.ui.mAnim_Self:SetBool("Selected", false)
      setactive(self.ui.mTrans_GrpLock, true)
      setactive(self.ui.mText_LockText.gameObject, true)
      self.ui.mText_LockText.text = string_format(TableData.GetHintById(110019), Data.Level)
      if condition1 and condition2 == false then
        self.ui.mText_LockText.text = TableData.GetHintById(110020)
      end
      UIUtils.GetButtonListener(self.ui.mBtn_Self.gameObject).onClick = function()
        local str = string_format(TableData.GetHintById(110019), Data.Level)
        if condition1 and condition2 == false then
          str = TableData.GetHintById(110020)
        end
        CS.PopupMessageManager.PopupString(str)
      end
      self:UpdateRedPoint(Type, Data.Id, index, false)
    end
    setactive(self.ui.mTrans_Video, true)
  elseif Type == 2 then
    setactive(self.ui.mTrans_Sound, true)
    setactive(self.ui.mText_LockText.gameObject, false)
    if Data.Belong == 1 then
      local audiodata = TableData.listAudioDatas:GetDataById(Data.Id)
      self.ui.mText_Name.text = audiodata.show_title.str
      UIUtils.GetButtonListener(self.ui.mBtn_Self.gameObject).onClick = function()
        if ArchivesUtils.CurAudioItem ~= nil then
          if ArchivesUtils.CurAudioItem.Id == self.Id then
            CS.CriWareAudioController.StopVoice()
            ArchivesUtils.CurAudioItem.ui.mAnim_Self:SetLayerWeight(2, 0)
            ArchivesUtils.CurAudioItem.ui.mAnim_Self:SetTrigger("Normal")
            ArchivesUtils.CurAudioItem = nil
            return
          end
          ArchivesUtils.CurAudioItem.ui.mAnim_Self:SetLayerWeight(2, 0)
          ArchivesUtils.CurAudioItem.ui.mAnim_Self:SetTrigger("Normal")
        end
        self.ui.mAnim_Self:SetLayerWeight(2, 1)
        ArchivesUtils.CurAudioItem = self
        ArchivesUtils.AnimState = 1
        local strarr = string.split(audiodata.audio_name, "/")
        local sheet = strarr[1]
        local audio = strarr[2]
        self.uiAudioPlotPanel.IsPlaying = false
        self:PlayAudioText(sheet, audio, Data.Id)
        self.uiAudioPlotPanel.ui.mText_Details.text = audiodata.show_name.str
        self.uiAudioPlotPanel.ui.mText_Tittle.text = audiodata.show_title.str
        setactive(self.uiAudioPlotPanel.ui.mTrans_GrpLine, true)
        self:UpdateRedPoint(Type, Data.Id, index, true)
      end
      self:UpdateRedPoint(Type, Data.Id, index, true)
    elseif Data.Belong == 2 then
      local adjdata = TableData.listAdjutantConversationDatas:GetDataById(Data.Id)
      local audiodata = TableData.listAudioDatas:GetDataById(adjdata.voice)
      self.ui.mText_Name.text = audiodata.show_title.str
      UIUtils.GetButtonListener(self.ui.mBtn_Self.gameObject).onClick = function()
        if ArchivesUtils.CurAudioItem ~= nil then
          if ArchivesUtils.CurAudioItem.Id == self.Id then
            CS.CriWareAudioController.StopVoice()
            ArchivesUtils.CurAudioItem.ui.mAnim_Self:SetLayerWeight(2, 0)
            ArchivesUtils.CurAudioItem.ui.mAnim_Self:SetTrigger("Normal")
            ArchivesUtils.CurAudioItem = nil
            return
          end
          ArchivesUtils.CurAudioItem.ui.mAnim_Self:SetLayerWeight(2, 0)
          ArchivesUtils.CurAudioItem.ui.mAnim_Self:SetTrigger("Normal")
        end
        self.ui.mAnim_Self:SetLayerWeight(2, 1)
        ArchivesUtils.CurAudioItem = self
        ArchivesUtils.AnimState = 1
        local strarr = string.split(TableData.listAudioDatas:GetDataById(adjdata.voice).audio_name, "/")
        local sheet = strarr[1]
        local audio = strarr[2]
        self.uiAudioPlotPanel.IsPlaying = false
        self:PlayAudioText(sheet, audio, adjdata.voice)
        self.uiAudioPlotPanel.ui.mText_Details.text = audiodata.show_name.str
        self.uiAudioPlotPanel.ui.mText_Tittle.text = audiodata.show_title.str
        setactive(self.uiAudioPlotPanel.ui.mTrans_GrpLine, true)
        self:UpdateRedPoint(Type, adjdata.voice, index, true)
      end
      self:UpdateRedPoint(Type, adjdata.voice, index, true)
    end
  end
end
function AudioPlotItem:UpdateRedPoint(Type, Id, index, bool)
  setactive(self.ui.mTrans_RedPoint, false)
  local uid = AccountNetCmdHandler.Uid
  local key = uid .. Id .. "audioplot"
  local value = NetCmdArchivesData:GetInt(key)
  if value == 0 then
    if Type == 1 then
      if index == 0 then
        local guncmd = ArchivesUtils:GetGunData(self.uiRoleFileDetailPanel.mData.unit_id)
        if guncmd ~= nil and guncmd.mGun.GunClass >= ArchivesUtils.AvgDic[self.uiRoleFileDetailPanel.mData.id].Level then
          setactive(self.ui.mTrans_RedPoint, true)
        end
      else
        setactive(self.ui.mTrans_RedPoint, bool)
      end
    elseif Type == 2 then
      setactive(self.ui.mTrans_RedPoint, bool)
    end
  end
end
function AudioPlotItem:PlayAudioText(sheet, audio, audioId)
  ArchivesUtils.IsPlayed = true
  setactive(self.uiAudioPlotPanel.ui.mText_Details.gameObject, true)
  setactive(self.uiAudioPlotPanel.ui.mText_Tittle.gameObject, true)
  CS.CriWareAudioController.StopVoice()
  CS.CriWareAudioController.PlayVoice(sheet, audio)
  local name = self.uiRoleFileDetailPanel.mData.en_name
  NetCmdArchivesData:SetInt(AccountNetCmdHandler.Uid .. name .. "LastAudioId", audioId)
end
function AudioPlotItem:SaveStr(Id)
  local uid = AccountNetCmdHandler.Uid
  local key = uid .. Id .. "audioplot"
  NetCmdArchivesData:SetInt(key, 1)
end
