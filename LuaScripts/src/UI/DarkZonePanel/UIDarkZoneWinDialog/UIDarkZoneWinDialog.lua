require("UI.UIBasePanel")
require("UI.Common.UICommonItem")
require("UI.DarkZonePanel.UIDarkZoneExplorePanel.DarkZoneExploreGlobal")
require("UI.DarkZonePanel.UIDarkZoneModePanel.DarkZoneGlobal")
UIDarkZoneWinDialog = class("UIDarkZoneWinDialog", UIBasePanel)
UIDarkZoneWinDialog.__index = UIDarkZoneWinDialog
function UIDarkZoneWinDialog:ctor(csPanel)
  UIDarkZoneWinDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneWinDialog:OnInit(root, data)
  UIDarkZoneWinDialog.super.SetRoot(UIDarkZoneWinDialog, root)
  self.mItemTable = {}
  self:InitBaseData()
  self.questRewardData = data
  self.BagMgr = CS.SysMgr.dzPlayerMgr.MainPlayer.DarkPlayerBag
  self:LuaUIBindTable(root, self.ui)
  self:AddBtnListen()
  MessageSys:SendMessage(CS.GF2.Message.DarkMsg.DarkZoneHideMainPanel, nil)
end
function UIDarkZoneWinDialog:CloseFunction()
  CS.SysMgr.dzUIControlMgr:DarkEnd()
end
function UIDarkZoneWinDialog:OnShowStart()
  self:UpdateData()
end
function UIDarkZoneWinDialog:OnClose()
  self.ui = nil
  self.mview = nil
  self.ItemDataList = nil
  self.IsPanelOpen = nil
  self.GunInfoDialog = nil
  self.BagMgr = nil
  self.clickTime = nil
  self.hasCache = false
  self.canClose = false
  if self.mComWinShowExpItem ~= nil then
    self.mComWinShowExpItem:OnRelease()
  end
  if self.mGunTab ~= nil then
    for _, item in pairs(self.mGunTab) do
      ResourceManager:DestroyInstance(item.mGameObject)
    end
  end
  for _, item in pairs(self.mItemTable) do
    gfdestroy(item:GetRoot())
  end
end
function UIDarkZoneWinDialog:OnRelease()
  self.super.OnRelease(self)
  self.hasCache = false
end
function UIDarkZoneWinDialog:InitBaseData()
  self.ui = {}
  self.ItemDataList = {}
  self.IsPanelOpen = false
  self.clickTime = 0
  self.hasCache = false
  self.canClose = false
  self.timeDelayfloat = 6
  TimerSys:DelayCall(1, function()
    self.canClose = true
  end)
end
function UIDarkZoneWinDialog:AddBtnListen()
  if self.hasCache ~= true then
    UIUtils.GetButtonListener(self.ui.mBtn_BtnConfirm.gameObject).onClick = function()
      if self.canClose then
        self:CloseFunction()
      end
    end
    self.hasCache = true
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    local darkZoneType = CS.SysMgr.dzMatchGameMgr.darkZoneType
    if darkZoneType == CS.ProtoObject.DarkZoneType.DzQuest or darkZoneType == CS.ProtoObject.DarkZoneType.DzInfinity then
      if not self.mComWinShowExpItem.IsCanClickNext then
        return
      end
      MessageSys:SendMessage(GuideEvent.OnDarkWin2Panel, CS.SysMgr.dzMatchGameMgr.darkZoneType)
      self.mComWinShowExpItem.mAni_Root:SetTrigger("FadeOut")
      TimerSys:DelayCall(0.3, function()
        setactive(self.ui.mTrans_ExpRoot, false)
        setactive(self.ui.mTrans_Settlement2, true)
        self.ui.mAni_Root:SetTrigger("FadeIn_1")
      end)
      self.ui.mBtn_Close.onClick:RemoveAllListeners()
    end
  end
end
function UIDarkZoneWinDialog:UpdateData()
  setactive(self.ui.mTrans_ExploreInfo, false)
  setactive(self.ui.mTrans_ExploreEmptyIcon, false)
  setactive(self.ui.mTrans_Settlement2, false)
  self.ui.mText_Name.text = TableData.GetHintById(80067)
  if CS.SysMgr.dzMatchGameMgr.darkZoneType == CS.ProtoObject.DarkZoneType.DzExplore then
    MessageSys:SendMessage(GuideEvent.OnDarkWin2Panel, CS.SysMgr.dzMatchGameMgr.darkZoneType)
    setactive(self.ui.mTrans_Settlement2, true)
    setactive(self.ui.mTrans_ExpRoot, false)
    TimerSys:DelayCall(1, function()
      self.ui.mAni_Root:SetTrigger("FadeIn_1")
    end)
    self.ui.mText_Name.text = TableData.GetHintById(240062)
    setactive(self.ui.mTrans_ExploreEmptyIcon, true)
    if DarkZoneExploreGlobal.CheckExploreLevelOpen(CS.SysMgr.dzMatchGameMgr.ExploreMapMaxIndex + 1) and CS.SysMgr.dzMatchGameMgr.UnlockBeacon then
      setactive(self.ui.mTrans_ExploreInfo, true)
      setactive(self.ui.mTrans_ExploreEmptyIcon, false)
      local beforePcr = CS.SysMgr.dzPlayerMgr.MainPlayerData.InitBeaconNum / CS.SysMgr.dzUIControlMgr.beaconNumMax
      local afterPcr = CS.SysMgr.dzPlayerMgr.MainPlayerData.BeaconNum / CS.SysMgr.dzUIControlMgr.beaconNumMax
      self.ui.mImg_Now.fillAmount = beforePcr
      self.ui.mImg_Add.fillAmount = beforePcr
      LuaDOTweenUtils.DoImageFillAmount(self.ui.mImg_Add, beforePcr, afterPcr, 1)
      self.ui.mText_ExpAll.text = CS.SysMgr.dzPlayerMgr.MainPlayerData.BeaconNum .. "/" .. CS.SysMgr.dzUIControlMgr.beaconNumMax
    end
  else
    MessageSys:SendMessage(GuideEvent.OnDarkWin1Panel, CS.SysMgr.dzMatchGameMgr.darkZoneType)
    setactive(self.ui.mTrans_ExpRoot, true)
    self.mComWinShowExpItem = CS.ComWinShowExpItem(self.ui.mTrans_ExpRoot)
    self.mComWinShowExpItem:SetData()
    self.mGunTab = {}
    for i = 0, CS.SysMgr.dzPlayerMgr.MainPlayerData.GunsId.Length - 1 do
      local curGunId = CS.SysMgr.dzPlayerMgr.MainPlayerData.GunsId[i]
      local gunCmdData = NetCmdTeamData:GetGunByID(curGunId)
      if gunCmdData ~= nil then
        local combatWinShowChrItem = CS.CombatWinChrShowItem(self.mComWinShowExpItem.TransListContent)
        combatWinShowChrItem:SetData(gunCmdData)
        table.insert(self.mGunTab, combatWinShowChrItem)
      end
    end
  end
  setactive(self.ui.mText_Tittle, false)
  local questID = DarkNetCmdStoreData.currentTaskID
  if questID == 0 then
    questID = 10101
    gfdebug("未收到任务模式ID,临时测试使用10101")
  else
    local dzQuestData = TableData.listDarkzoneSystemQuestDatas:GetDataById(DarkNetCmdStoreData.currentTaskID)
    if dzQuestData ~= nil then
      self.ui.mText_Tittle.text = dzQuestData.quest_name.str
      setactive(self.ui.mText_Tittle, true)
    end
  end
  if CS.SysMgr.dzMatchGameMgr.darkZoneType == CS.ProtoObject.DarkZoneType.DzQuest then
    PlayerPrefs.SetInt(AccountNetCmdHandler:GetUID() .. DarkZoneGlobal.QuestCacheIDKey, DarkNetCmdStoreData.currentTaskID)
  end
  local dropReward = {}
  for i = 0, self.questRewardData.Count - 1 do
    table.insert(dropReward, self.questRewardData[i])
  end
  if CS.SysMgr.dzMatchGameMgr.darkZoneType == CS.ProtoObject.DarkZoneType.DzInfinity then
    table.sort(dropReward, function(a, b)
      if DarkNetCmdLeaveData:IsContainDropUp(a.ItemId) ~= DarkNetCmdLeaveData:IsContainDropUp(b.ItemId) then
        if DarkNetCmdLeaveData:IsContainDropUp(a.ItemId) == true then
          return true
        elseif DarkNetCmdLeaveData:IsContainDropUp(a.ItemId) == true then
          return false
        end
      else
        local data1 = TableData.GetItemData(a.ItemId)
        local data2 = TableData.GetItemData(b.ItemId)
        if data1.rank ~= data2.rank then
          return data1.rank > data2.rank
        else
          return a.ItemId > b.ItemId
        end
      end
    end)
  else
    table.sort(dropReward, function(a, b)
      local data1 = TableData.GetItemData(a.ItemId)
      local data2 = TableData.GetItemData(b.ItemId)
      if data1.rank == data2.rank then
        return a.ItemId > b.ItemId
      else
        return data1.rank > data2.rank
      end
    end)
  end
  for i = 1, #dropReward do
    if dropReward[i].ItemId ~= 200 then
      local item = UICommonItem.New()
      item:InitCtrl(self.ui.mSListChild_Content.transform)
      if 1 < dropReward[i].ItemNum then
        item:SetItemData(dropReward[i].ItemId, dropReward[i].ItemNum, false, false, nil, dropReward[i].relate)
      else
        item:SetItemData(dropReward[i].ItemId, 0, false, false, nil, dropReward[i].relate)
      end
      if CS.SysMgr.dzMatchGameMgr.darkZoneType == CS.ProtoObject.DarkZoneType.DzInfinity then
        local isContainDropUp = DarkNetCmdLeaveData:IsContainDropUp(dropReward[i].ItemId)
        if isContainDropUp == true then
          item:SetUpIconVisible(true)
        end
      end
      table.insert(self.mItemTable, item)
    end
  end
  local allBagGoods = {}
  local allBagGoodsDict = CS.SysMgr.dzPlayerMgr.MainPlayer.DarkPlayerBag:GetAllGoods()
  for i = 0, allBagGoodsDict.Count - 1 do
    table.insert(allBagGoods, allBagGoodsDict[i])
  end
  table.sort(allBagGoods, function(a, b)
    local data1 = TableData.GetItemData(a.itemID)
    local data2 = TableData.GetItemData(b.itemID)
    if data1.rank == data2.rank then
      return a.itemID > b.itemID
    else
      return data1.rank > data2.rank
    end
  end)
  for i = 1, #allBagGoods do
    local itemShow = allBagGoods[i]:ShowInSettle()
    if itemShow then
      local item = UICommonItem.New()
      item:InitCtrl(self.ui.mSListChild_Content2.transform)
      if 1 >= allBagGoods[i].num then
        item:SetItemData(allBagGoods[i].itemID, 0, false, false, nil, allBagGoods[i].onlyID)
      else
        item:SetItemData(allBagGoods[i].itemID, allBagGoods[i].num, false, false, nil, allBagGoods[i].onlyID)
      end
      table.insert(self.mItemTable, item)
    end
  end
  setactive(self.ui.mTrans_Explore, self.ui.mSListChild_Content2.transform.childCount ~= 0)
  setactive(self.ui.mTrans_Quest, self.ui.mSListChild_Content.transform.childCount ~= 0)
  setactive(self.ui.mTrans_ItemRoot, self.ui.mSListChild_Content1.transform.childCount ~= 0)
  setactive(self.ui.mTrans_GrpEmpty, self.ui.mSListChild_Content2.transform.childCount == 0 and self.ui.mSListChild_Content.transform.childCount == 0 and self.ui.mSListChild_Content.transform.childCount == 0)
end
function UIDarkZoneWinDialog:CloseInfo()
  if self.GunInfoDialog ~= nil then
    TransformUtils.PlayAniWithCallback(self.GunInfoDialog.transform, function()
      setactive(self.GunInfoDialog.gameObject, false)
    end)
  end
end
