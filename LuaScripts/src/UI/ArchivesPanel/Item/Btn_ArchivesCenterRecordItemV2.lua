require("UI.UIBaseCtrl")
require("UI.Common.UICommonItem")
Btn_ArchivesCenterRecordItemV2 = class("Btn_ArchivesCenterRecordItemV2", UIBaseCtrl)
Btn_ArchivesCenterRecordItemV2.__index = Btn_ArchivesCenterRecordItemV2
function Btn_ArchivesCenterRecordItemV2:ctor(root)
end
function Btn_ArchivesCenterRecordItemV2:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self.ui.itemUIList = {}
  self:SetRoot(instObj.transform)
end
function Btn_ArchivesCenterRecordItemV2:SetData(data, type, index)
  self.ui.mText_Title.text = data.type_name
  self.ui.mText_StoryName.text = "0" .. data.sort
  self.ui.mText_StoryDesc.text = data.title.str
  self.type = type
  local iconName = string_format("ArchivesCenter/Icon_ArchivesCenter_Record_{0}", data.type)
  self.ui.mImg_StoryIcon.sprite = ResSys:GetAtlasSprite(iconName)
  self.lockState = 0
  if type == 1 then
    local currPlotCount = NetCmdArchivesData:GetPlotCurrCount(data.group_id)
    if index < currPlotCount then
      self.lockState = 1
      setactive(self.ui.mTrans_Lock.gameObject, false)
      setactive(self.ui.mTrans_CanLock.gameObject, false)
    elseif index == currPlotCount then
      self.lockState = 2
      self.ui.mText_StoryName.text = ""
      self.ui.mText_StoryDesc.text = ""
      for k, v in pairs(data.unlock_item) do
        local itemData = TableData.GetItemData(k)
        if itemData then
          self.ui.mImg_Icon.sprite = IconUtils.GetItemIconSprite(itemData.id)
          self.ui.mText_Num.text = v
          break
        end
      end
      local sortedItemList = LuaUtils.SortItemByDict(data.reward)
      for i = 0, sortedItemList.Count - 1 do
        local index = i + 1
        local kvPair = sortedItemList[i]
        if self.ui.itemUIList[index] then
          self.ui.itemUIList[index]:SetItemData(kvPair.Key, kvPair.Value)
        else
          do
            local item = UICommonItem.New()
            item:InitCtrl(self.ui.mTrans_Item)
            item:SetItemData(kvPair.Key, kvPair.Value, nil, nil, nil, nil, nil, function()
              UITipsPanel.Open(TableData.GetItemData(kvPair.Key))
            end)
            table.insert(self.ui.itemUIList, item)
          end
        end
      end
      setactive(self.ui.mTrans_Lock.gameObject, false)
      setactive(self.ui.mTrans_CanLock.gameObject, true)
    else
      self.ui.mText_StoryName.text = ""
      self.ui.mText_StoryDesc.text = ""
      self.ui.mText_Lock.text = TableData.GetHintById(110052)
      setactive(self.ui.mTrans_Lock.gameObject, true)
      setactive(self.ui.mTrans_CanLock.gameObject, false)
    end
  else
    setactive(self.ui.mTrans_CanLock.gameObject, false)
    if NetCmdSimulateBattleData:StageIsUnLock(data.stage_id, false) then
      setactive(self.ui.mTrans_Lock.gameObject, false)
      self.lockState = 1
    else
      self.ui.mText_StoryName.text = ""
      self.ui.mText_StoryDesc.text = ""
      local stageData = TableDataBase.listStageDatas:GetDataById(data.stage_id)
      if stageData then
        self.ui.mText_Lock.text = string_format(TableData.GetHintById(110053), stageData.code)
      end
      setactive(self.ui.mTrans_Lock.gameObject, true)
    end
  end
  TimerSys:DelayCall(0.3, function()
    if self.lockState == 1 then
      self.ui.mImg_Dot.color = Color(0.10196078431372549, 0.17254901960784313, 0.2, 0.6980392156862745)
      self.ui.mAnimator_ArchivesCenterRecordItemV2:SetBool("Bool", false)
    else
      self.ui.mImg_Dot.color = Color(0.10196078431372549, 0.17254901960784313, 0.2, 0.2980392156862745)
      self.ui.mAnimator_ArchivesCenterRecordItemV2:SetBool("Bool", true)
    end
  end)
  UIUtils.GetButtonListener(self.ui.mBtn_ArchivesCenterRecordItemV2.gameObject).onClick = function()
    self:OnBtnClick(data)
  end
end
function Btn_ArchivesCenterRecordItemV2:OnBtnClick(data)
  local Data = {}
  Data[1] = data
  Data[2] = function()
    if self.type == 1 then
      if NetCmdArchivesData.RecordRoomDetail:ContainsKey(data.group_id) then
        if NetCmdArchivesData.RecordRoomDetail[data.group_id].State then
        else
          NetCmdArchivesData:SendGetRewardMsg(data.group_id, function(ret)
            if ret == ErrorCodeSuc then
              NetCmdArchivesData:SetShowRewardSate(true)
            end
          end)
        end
      else
        NetCmdArchivesData:SendGetRewardMsg(data.group_id, function(ret)
          if ret == ErrorCodeSuc then
            NetCmdArchivesData:SetShowRewardSate(true)
          end
        end)
      end
    else
      NetCmdArchivesData:SetDiffcultStoryReadState(data.id, 1)
    end
  end
  local action = function()
    if data.Type == ArchivesUtils.Type.Audio then
      UIManager.OpenUIByParam(UIDef.UIRecordAudioDialog, Data)
    elseif data.Type == ArchivesUtils.Type.Paper then
      UIManager.OpenUIByParam(UIDef.UIRecordPaperDialog, Data)
    elseif data.Type == ArchivesUtils.Type.Video then
      UIManager.OpenUIByParam(UIDef.UIRecordVideoDialog, Data)
    elseif data.Type == ArchivesUtils.Type.Electron then
      UIManager.OpenUIByParam(UIDef.UIRecordElectronDialog, Data)
    end
    local groupId = Data[1].group_id
    local informationId = Data[1].id
    local isFirstTimeWatch = not NetCmdArchivesData:ArchivesStoryIsRead(Data[1].id)
    local informationData = TableDataBase.listInformationCsDatas:GetDataById(groupId)
    if informationData.type == 1 then
      if self.ossSecretPlotInfo == nil then
        self.ossSecretPlotInfo = CS.OssSecretPlotInfo()
      end
      self.ossSecretPlotInfo:SetInfo(groupId, informationId, isFirstTimeWatch)
      MessageSys:SendMessage(OssEvent.SecretPlotLog, nil, self.ossSecretPlotInfo)
    elseif informationData.type == 2 then
      if self.ossEchoPlotInfo == nil then
        self.ossEchoPlotInfo = CS.OssEchoPlotInfo()
      end
      self.ossEchoPlotInfo:SetInfo(groupId, informationId, isFirstTimeWatch)
      MessageSys:SendMessage(OssEvent.EchoPlotLog, nil, self.ossEchoPlotInfo)
    else
      gferror("Oss 存在未定义的类型")
    end
  end
  if self.lockState == 0 then
    if self.type == 1 then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(110052))
    elseif 0 < data.jump_id then
      local stageData = TableDataBase.listStageDatas:GetDataById(data.stage_id)
      local desc = string_format(TableData.GetHintById(110054), stageData.code)
      local content = MessageContent.New(desc, MessageContent.MessageType.DoubleBtn, function()
        SceneSwitch:SwitchByID(data.jump_id)
      end)
      MessageBoxPanel.Show(content)
    end
    return
  elseif self.lockState == 2 then
    local itemId, itemCount
    for k, v in pairs(data.unlock_item) do
      itemId = k
      itemCount = v
      break
    end
    local str = TableData.GetHintById(110017)
    local itemData = TableData.listItemDatas:GetDataById(itemId)
    local content = string_format(str, itemCount, itemData.Name.str)
    if NetCmdArchivesData:IsEnougnToUnLock(data.unlock_item) then
      local content = MessageContent.New(content, MessageContent.MessageType.DoubleBtn, function()
        NetCmdArchivesData:SendUnlockMsg(data.id, function(ret)
          if ret == ErrorCodeSuc then
            action()
          end
        end)
      end)
      MessageBoxPanel.Show(content)
    else
      CS.PopupMessageManager.PopupString(string_format(TableData.GetHintById(225), itemData.Name.str))
    end
    return
  end
  action()
end
