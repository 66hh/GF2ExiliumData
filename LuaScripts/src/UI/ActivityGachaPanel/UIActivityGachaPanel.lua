require("UI.UIBasePanel")
require("UI.ActivityGachaPanel.ActivityGachaGlobal")
require("UI.ActivityGachaPanel.UIActivitieGachaTop")
require("UI.ActivityGachaPanel.UIActivityGachaListItem")
require("UI.ActivityGachaPanel.UIActivityGachaGroupItem")
require("UI.ActivityGachaPanel.UIActivitieGachaRaffleItem")
require("UI.ActivityTheme.Daiyan.DaiyanGlobal")
require("UI.SimpleMessageBox.SimpleMessageBoxPanel")
require("UI.MonopolyActivity.ActivityTourGlobal")
UIActivityGachaPanel = class("UIActivityGachaPanel", UIBasePanel)
UIActivityGachaPanel.__index = UIActivityGachaPanel
function UIActivityGachaPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
end
function UIActivityGachaPanel:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.oriColor = self.ui.mText_LeftConsume.color
  self.dropDownListBinding = {}
end
function UIActivityGachaPanel:OnInit(root, data)
  self:AddBtnListener()
  self.actId = data.actId
  self.planId = data.planId
  self.gachaId = data.gachaId
  self.maxRound = NetCmdActivityGachaData:GetMaxRound(self.gachaId)
  self.closeTime = NetCmdActivityGachaData:GetActEndTime(self.actId)
  self.roundItemList = {}
  self.dropDownItemList = {}
  self:UpdateRewardRecord()
  self.raffleCount = self:GetRaffleCount()
  self.initOpen = true
  self.curSelGroup = NetCmdActivityGachaData:GetCurGroupIdx(self.actId)
  self:RefreshContent()
  ActivityTourGlobal.ReplaceAllColor(self.mUIRoot)
end
function UIActivityGachaPanel:OnShowStart()
end
function UIActivityGachaPanel:RefreshContent()
  self:RefreshActivityInfo()
  self:RefreshGroupState()
  self:RefreshTop()
  self:RefreshReward()
  self:RefreshRound()
  self:RefreshBottomButton()
end
function UIActivityGachaPanel:OnShowFinish()
end
function UIActivityGachaPanel:OnBackFrom()
end
function UIActivityGachaPanel:OnClose()
  if not LuaUtils.IsNullOrDestroyed(self.topInfo) then
    self.topInfo:OnRelease(true)
    self.topInfo = nil
  end
  self:ReleaseCtrlTable(self.roundItemList, true)
  self.roundItemList = nil
  if not self.btnOne then
    gfdestroy(self.btnOne)
    self.btnOne = nil
  end
  if not self.btnMany then
    gfdestroy(self.btnMany)
    self.btnMany = nil
  end
  if not self.dropDownList then
    gfdestroy(self.dropDownList)
    self.dropDownList = nil
  end
  for i = 1, #self.dropDownItemList do
    gfdestroy(self.dropDownItemList[i])
  end
  self.dropDownItemList = nil
  MessageSys:RemoveListener(UIEvent.GachaRaffle, self.onRaffleReturn)
  self.onRaffleReturn = nil
  MessageSys:RemoveListener(UIEvent.OpenGachaGroup, self.onOpenGachaGroup)
  self.onOpenGachaGroup = nil
  self.isOpenNewGroup = false
end
function UIActivityGachaPanel:OnHide()
end
function UIActivityGachaPanel:OnHideFinish()
end
function UIActivityGachaPanel:OnRelease()
  if not LuaUtils.IsNullOrDestroyed(self.targetRewardDetail) then
    self.targetRewardDetail:OnRelease()
    self.targetRewardDetail = nil
  end
  if not LuaUtils.IsNullOrDestroyed(self.normalRewardDetail) then
    self.normalRewardDetail:OnRelease()
    self.normalRewardDetail = nil
  end
  self.ui = nil
end
function UIActivityGachaPanel:OnRecover()
end
function UIActivityGachaPanel:OnSave()
end
function UIActivityGachaPanel:AddBtnListener()
  UIUtils.GetButtonListener(self.ui.mBtn_BtnBack.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIActivityGachaPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Screen.gameObject).onClick = function()
    if self.dropDownList then
      setactive(self.ui.mScrollListChild_GrpScreenList.gameObject, true)
    end
  end
  function self.onRaffleReturn(msg)
    self:ShowRaffleReward(msg)
  end
  function self.onOpenGachaGroup(msg)
    self:OnOpenGroup(msg)
  end
  MessageSys:AddListener(UIEvent.GachaRaffle, self.onRaffleReturn)
  MessageSys:AddListener(UIEvent.OpenGachaGroup, self.onOpenGachaGroup)
end
function UIActivityGachaPanel:UpdateRewardRecord()
  self.mData = {}
  self.mData.id = self.gachaId
  self.mData.data = {}
  for groupIdx = 1, self.maxRound do
    local groupData = NetCmdActivityGachaData:GetGroupConfig(self.gachaId, groupIdx)
    if not self.mData.data[groupIdx] then
      self.mData.data[groupIdx] = {}
    end
    local record = NetCmdActivityGachaData:GetRewardRecordById(self.actId, groupData.id)
    local lstId = TableDataBase.listActivityGachaRewardByGachaGroupDatas:GetDataById(groupData.gacha_group).Id
    for i = 0, lstId.Count - 1 do
      local rewardData = TableData.listActivityGachaRewardDatas:GetDataById(lstId[i])
      if not self.mData.data[groupIdx][rewardData.type] then
        self.mData.data[groupIdx][rewardData.type] = {}
      end
      local num = 0
      if record then
        for p, q in pairs(record.Rewards) do
          if p == rewardData.id then
            num = q
            break
          end
        end
      end
      table.insert(self.mData.data[groupIdx][rewardData.type], {
        id = rewardData.id,
        curNum = math.max(0, rewardData.stock - num),
        totalNum = rewardData.stock
      })
    end
  end
end
function UIActivityGachaPanel:RefreshActivityInfo()
  local data = TableData.listActivityGachaConfigDatas:GetDataById(self.mData.id)
  if not data then
    return
  end
  self.ui.mText_Name.text = data.activity_name.str
  self.ui.mText_Content.text = data.gacha_desc.str
  local planId = data.plan_id > 0 and data.plan_id or self.planId
  local planData = TableData.listPlanDatas:GetDataById(planId)
  if planData then
    local openTime = CS.CGameTime.ConvertLongToDateTime(planData.open_time):ToString("MM/dd HH:mm")
    local closeTime = CS.CGameTime.ConvertLongToDateTime(planData.close_time):ToString("MM/dd HH:mm")
    self.ui.mText_Time.text = string_format(TableData.GetHintById(270132), openTime, closeTime)
  else
    self.ui.mText_Time.text = ""
  end
  self.ui.mImg_Bg.sprite = IconUtils.GetAtlasV2(ActivityGachaGlobal.DaiyanIconRootPath, data.gacha_bg)
end
function UIActivityGachaPanel:RefreshGroupState()
  if not self.mData or not self.mData.data then
    return
  end
  local group = NetCmdActivityGachaData:GetCurGroupIdx(self.actId)
  for i = 1, self.maxRound do
    local record = NetCmdActivityGachaData:GetRewardRecord(self.actId, i)
    local data = self.mData.data[i]
    if data then
      if record and record.State == ActivityGachaGlobal.ActivityGroupState.Start then
        if i == group then
          data.state = ActivityGachaGlobal.GroupState_Doing
        else
          data.state = ActivityGachaGlobal.GroupState_Open
        end
      elseif record and record.State == ActivityGachaGlobal.ActivityGroupState.End then
        data.state = ActivityGachaGlobal.GroupState_Close
      else
        data.state = ActivityGachaGlobal.GroupState_NotOpen
      end
    end
  end
end
function UIActivityGachaPanel:IsAllTargetRewardGet(round, rewardType)
  if not self.mData or not self.mData.data then
    return false
  end
  local data = self.mData.data[round]
  if not data then
    return false
  end
  rewardType = rewardType and rewardType or ActivityGachaGlobal.TargteType
  local rewardData = data[rewardType]
  if not rewardData then
    return true
  end
  for i = 1, #rewardData do
    if rewardData[i].curNum > 0 then
      return false
    end
  end
  return true
end
function UIActivityGachaPanel:RefreshTop()
  if not self.mData or not self.mData.data then
    return
  end
  local data = self.mData.data[self.curSelGroup]
  if not data then
    return
  end
  if LuaUtils.IsNullOrDestroyed(self.topInfo) then
    self.topInfo = UIActivitieGachaTop.New()
    self.topInfo:InitCtrl(self.ui.mScrollListChild_GrpTop.transform)
  end
  self.topInfo:Refresh(self.curSelGroup)
end
function UIActivityGachaPanel:RefreshReward()
  if LuaUtils.IsNullOrDestroyed(self.targetRewardDetail) then
    self.targetRewardDetail = UIActivityGachaListItem.New()
    self.targetRewardDetail:InitCtrl(self.ui.mScrollListChild_Content.transform)
  end
  if LuaUtils.IsNullOrDestroyed(self.normalRewardDetail) then
    self.normalRewardDetail = UIActivityGachaListItem.New()
    self.normalRewardDetail:InitCtrl(self.ui.mScrollListChild_Content.transform)
  end
  local data = self.mData.data[self.curSelGroup]
  self.targetRewardDetail:SetData(ActivityGachaGlobal.TargteType, data and data[ActivityGachaGlobal.TargteType] or nil)
  self.normalRewardDetail:SetData(ActivityGachaGlobal.NormalType, data and data[ActivityGachaGlobal.NormalType] or nil)
end
function UIActivityGachaPanel:RefreshRound()
  if not self.mData or not self.mData.data then
    return
  end
  for i = 1, self.maxRound do
    local data = self.mData.data[i]
    local item = self.roundItemList[i]
    if not item then
      item = UIActivityGachaGroupItem.New()
      item:InitCtrl(self.ui.mScrollListChild_GrpCenter, true)
      self.roundItemList[i] = item
    end
    item:SetData(self.mData.id, i, data, function(group)
      self:SelectGroup(group)
    end)
    item:SetSelect(self.curSelGroup)
  end
end
function UIActivityGachaPanel:SelectGroup(group)
  self.curSelGroup = group
  self:RefreshTop()
  self:RefreshReward()
  self:RefreshBottomButton()
  for i = 1, self.maxRound do
    local item = self.roundItemList[i]
    if item then
      item:SetSelect(group)
    end
  end
end
function UIActivityGachaPanel:RefreshAfterOpenGroup()
  self:RefreshGroupState()
  self:RefreshTop()
  self:RefreshReward()
  self:RefreshRound()
  self:RefreshBottomButton()
end
function UIActivityGachaPanel:RefreshAfterRaffle()
  self:RefreshGroupState()
  self:RefreshReward()
  self:RefreshRound()
  self:RefreshBottomButton()
end
function UIActivityGachaPanel:RefreshDropDownMenu()
  if not self.dropDownList then
    local com = self.ui.mScrollListChild_GrpScreenList:GetComponent(typeof(CS.ScrollListChild))
    self.dropDownList = instantiate(com.childItem)
    CS.LuaUIUtils.SetParent(self.dropDownList.gameObject, self.ui.mScrollListChild_GrpScreenList.gameObject, true)
    self:LuaUIBindTable(self.dropDownList, self.dropDownListBinding)
    UIUtils.GetUIBlockHelper(self.ui.mScrollListChild_GrpScreenList.transform, self.ui.mScrollListChild_GrpScreenList.transform, function()
      setactive(self.ui.mScrollListChild_GrpScreenList.gameObject, false)
    end, self.mUIRoot.transform)
  end
  local data = NetCmdActivityGachaData:GetGroupConfig(self.mData.id, self.curSelGroup)
  for i = 0, data.continuity.Count - 1 do
    local item
    if not self.dropDownItemList[i + 1] then
      local com = self.dropDownListBinding.mTrans_Content:GetComponent(typeof(CS.ScrollListChild))
      item = instantiate(com.childItem)
      CS.LuaUIUtils.SetParent(item.gameObject, com.gameObject, true)
      self.dropDownItemList[i + 1] = item
    else
      item = self.dropDownItemList[i + 1]
    end
    local itemBinding = {}
    self:LuaUIBindTable(item, itemBinding)
    itemBinding.mText_SuitName.text = string_format(TableData.GetHintById(270122), data.continuity[i])
    local isSelect = data.continuity[i] == self.raffleCount
    itemBinding.mText_SuitName.color = isSelect and itemBinding.textColor.AfterSelected or itemBinding.textColor.BeforeSelected
    setactive(itemBinding.mTrans_GrpSel, isSelect)
    UIUtils.GetButtonListener(itemBinding.mBtn_Select.gameObject).onClick = function()
      setactive(self.ui.mScrollListChild_GrpScreenList.gameObject, false)
      self:SetRaffleCount(data.continuity[i])
      self:RefreshBottomButton()
    end
  end
  for i = data.continuity.Count + 1, #self.dropDownItemList do
    setactive(self.dropDownItemList[i], false)
  end
  setactive(self.ui.mScrollListChild_GrpScreenList.gameObject, false)
end
function UIActivityGachaPanel:RefreshBottomButton()
  if not self.mData or not self.mData.data then
    return
  end
  local data = self.mData.data[self.curSelGroup]
  if not data then
    return
  end
  if data.state == ActivityGachaGlobal.GroupState_Doing or data.state == ActivityGachaGlobal.GroupState_Open then
    self:RefreshStateDoingButton()
  elseif data.state == ActivityGachaGlobal.GroupState_Close then
    self:RefreshStateCloseButton()
  elseif data.state == ActivityGachaGlobal.GroupState_NotOpen then
    self:RefreshStateNotOpenButton()
  end
end
function UIActivityGachaPanel:RefreshStateDoingButton()
  setactive(self.ui.mTrans_TextTip.gameObject, false)
  setactive(self.ui.mTrans_GrpConsume.gameObject, true)
  setactive(self.ui.mScrollListChild_One.gameObject, true)
  setactive(self.ui.mScrollListChild_Many.gameObject, true)
  setactive(self.ui.mTrans_GrpBtn.gameObject, true)
  setactive(self.ui.mTrans_ScreenRoot.gameObject, true)
  local config = TableData.listActivityGachaConfigDatas:GetDataById(self.mData.id)
  if not config then
    return
  end
  local groupData = NetCmdActivityGachaData:GetGroupConfig(self.mData.id, self.curSelGroup)
  if not groupData then
    return
  end
  self:SetRaffleCount(-1 == self.raffleCount and groupData.continuity[0] or self.raffleCount)
  self.ui.mImg_LeftConsume.sprite = IconUtils.GetItemIconSprite(config.gacha_item)
  local curNum = NetCmdItemData:GetItemCount(config.gacha_item)
  self.ui.mText_LeftConsume.color = curNum < config.gacha_cost and ColorUtils.RedColor or self.oriColor
  self.ui.mText_LeftConsume.text = string_format(TableData.GetHintById(270176), config.gacha_cost)
  self.ui.mImg_RightConsume.sprite = IconUtils.GetItemIconSprite(config.gacha_item)
  local costNum = self.raffleCount * config.gacha_cost
  self.ui.mText_RightConsume.color = curNum < costNum and ColorUtils.RedColor or self.oriColor
  self.ui.mText_RightConsume.text = string_format(TableData.GetHintById(270176), costNum)
  if LuaUtils.IsNullOrDestroyed(self.btnOne) then
    self.btnOne = UIActivitieGachaRaffleItem.New()
    self.btnOne:InitCtrl(self.ui.mScrollListChild_One.transform)
  end
  self.btnOne:SetData(1, function()
    if curNum < config.gacha_cost then
      CS.PopupMessageManager.PopupString(string_format(TableData.GetHintById(270131), UIUtils.GetItemName(config.gacha_item)))
      return
    end
    self:DoRaffle(1)
  end)
  self:CreateBtnMany()
  self.btnMany:SetData(self.raffleCount, function()
    if curNum < costNum then
      CS.PopupMessageManager.PopupString(string_format(TableData.GetHintById(270131), UIUtils.GetItemName(config.gacha_item)))
      return
    end
    self:DoRaffle(self.raffleCount)
  end)
  self:RefreshDropDownMenu()
  if self:IsAllTargetRewardGet(self.curSelGroup, ActivityGachaGlobal.TargteType) and self:IsAllTargetRewardGet(self.curSelGroup, ActivityGachaGlobal.NormalType) then
    setactive(self.ui.mTrans_GrpConsume.gameObject, false)
    setactive(self.ui.mTrans_TextTip.gameObject, true)
    setactive(self.ui.mTrans_GrpBtn.gameObject, false)
    self.ui.mText_Tip.text = TableData.GetHintById(270114)
  end
end
function UIActivityGachaPanel:RefreshStateCloseButton()
  setactive(self.ui.mTrans_TextTip.gameObject, true)
  setactive(self.ui.mTrans_GrpConsume.gameObject, false)
  setactive(self.ui.mTrans_GrpBtn.gameObject, false)
  self.ui.mText_Tip.text = TableData.GetHintById(270115)
end
function UIActivityGachaPanel:RefreshStateNotOpenButton()
  setactive(self.ui.mTrans_TextTip.gameObject, true)
  setactive(self.ui.mTrans_GrpConsume.gameObject, false)
  setactive(self.ui.mTrans_GrpBtn.gameObject, false)
  self.ui.mText_Tip.text = TableData.GetHintById(270116)
end
function UIActivityGachaPanel:CreateBtnMany()
  if LuaUtils.IsNullOrDestroyed(self.btnMany) then
    self.btnMany = UIActivitieGachaRaffleItem.New()
    self.btnMany:InitCtrl(self.ui.mScrollListChild_Many.transform)
  end
end
function UIActivityGachaPanel:DoRaffle(count)
  if self:CheckActivityClose() then
    return
  end
  if self:IsAllTargetRewardGet(self.curSelGroup, ActivityGachaGlobal.TargteType) and self.curSelGroup < self.maxRound then
    if NetCmdActivityGachaData.ShowRaffleTip then
      local todayTipsParam = {}
      todayTipsParam[1] = string_format(TableData.GetHintById(270124), TableData.GetHintById(270014))
      todayTipsParam[2] = function()
        self:SendRaffle(count)
      end
      todayTipsParam[3] = ""
      todayTipsParam[4] = nil
      todayTipsParam[5] = false
      todayTipsParam[6] = function()
        NetCmdActivityGachaData.ShowRaffleTip = false
      end
      UIManager.OpenUIByParam(UIDef.UIComTodayTipsDialog, todayTipsParam)
    else
      self:SendRaffle(count)
    end
  else
    self:SendRaffle(count)
  end
end
function UIActivityGachaPanel:SendRaffle(count)
  NetCmdActivityGachaData:SendCS_ActivityGacha(self.actId, self.curSelGroup, count, function(ret)
    if ret == ErrorCodeSuc then
    end
  end)
end
function UIActivityGachaPanel:CheckActivityClose()
  if self.closeTime <= CGameTime:GetTimestamp() then
    local config = TableData.listActivityGachaConfigDatas:GetDataById(self.mData.id)
    if config then
      local unused_item_id = config.unused_item_id
      if unused_item_id.Count > 0 then
        for k, v in pairs(unused_item_id) do
          if 0 < k then
            MessageBox.ShowMidBtn(TableData.GetHintById(64), string_format(TableData.GetHintById(270123), "未配置物品"), nil, nil, function()
              UIManager.CloseUI(UIDef.UIActivityGachaPanel)
              UIManager.CloseUI(UIDef.DaiyanMainPanel)
            end)
            break
          end
        end
      end
    end
    return true
  end
  return false
end
function UIActivityGachaPanel:DealAfterCloseRewardDialog()
  self:UpdateRewardRecord()
  if self.isOpenNewGroup then
    if self:IsAllTargetRewardGet(self.curSelGroup, ActivityGachaGlobal.NormalType) and self:IsAllTargetRewardGet(self.curSelGroup, ActivityGachaGlobal.TargteType) then
      if self.curSelGroup < self.maxRound then
        self.curSelGroup = self.curSelGroup + 1
      end
      CS.PopupMessageManager.PopupStateChangeString(TableData.GetHintById(270114))
    else
      if self.curSelGroup < self.maxRound then
        self.curSelGroup = self.curSelGroup + 1
      end
      local tip = string_format(TableData.GetHintById(270125), TableData.GetHintById(270014))
      CS.PopupMessageManager.PopupStateChangeString(tip)
    end
    self.isOpenNewGroup = false
    self:RefreshAfterOpenGroup()
  else
    if self:IsAllTargetRewardGet(self.curSelGroup, ActivityGachaGlobal.NormalType) and self:IsAllTargetRewardGet(self.curSelGroup, ActivityGachaGlobal.TargteType) then
      local oriGroup = self.curSelGroup
      if self.curSelGroup < self.maxRound then
        for i = self.curSelGroup + 1, self.maxRound do
          local record = NetCmdActivityGachaData:GetRewardRecord(self.actId, i)
          if record and record.State == ActivityGachaGlobal.ActivityGroupState.Start then
            self.curSelGroup = i
            break
          end
        end
        if self.curSelGroup == oriGroup then
          self.curSelGroup = self.curSelGroup + 1
        end
      end
      UIUtils.PopupPositiveHintMessage(270114)
    end
    self:RefreshAfterRaffle()
  end
end
function UIActivityGachaPanel:ShowRaffleReward(msg)
  UIManager.OpenUIByParam(UIDef.UIActivityGachaReceiveDialog, {
    msg.Sender,
    self.mData.id,
    self:IsAllTargetRewardGet(self.curSelGroup, ActivityGachaGlobal.TargteType),
    function()
      self:DealAfterCloseRewardDialog()
    end,
    self.curSelGroup == self.maxRound,
    self.curSelGroup
  })
end
function UIActivityGachaPanel:OnOpenGroup(msg)
  self.isOpenNewGroup = true
end
function UIActivityGachaPanel:GetRaffleCount()
  if self.mData then
    local count = PlayerPrefs.GetInt(AccountNetCmdHandler:GetUID() .. ActivityGachaGlobal.GachaRaffleCountStr .. self.mData.id)
    return 0 < count and count or -1
  end
  return -1
end
function UIActivityGachaPanel:SetRaffleCount(count)
  if not count or count <= 0 or not self.mData then
    return
  end
  PlayerPrefs.SetInt(AccountNetCmdHandler:GetUID() .. ActivityGachaGlobal.GachaRaffleCountStr .. self.mData.id, count)
  self.raffleCount = count
end
