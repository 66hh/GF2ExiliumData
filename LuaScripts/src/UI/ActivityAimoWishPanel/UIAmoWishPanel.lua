require("UI.UIBasePanel")
require("UI.Common.UICommonItem")
require("UI.ActivityAimoWishPanel.Item.AmoWishListItem")
require("UI.ActivityAimoWishPanel.Item.AmoWishAccessListItem")
UIAmoWishPanel = class("UIAmoWishPanel", UIBasePanel)
UIAmoWishPanel.__index = UIAmoWishPanel
function UIAmoWishPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
end
function UIAmoWishPanel:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:AddBtnListen()
end
function UIAmoWishPanel:OnInit(root, data)
  self.mTabsTable = {}
  self.mRewardTable = {}
  self.mTaskTable = {}
  self.mPlanActivityData = data
  local dataList = TableData.listAmoActivitySubDatas:GetList()
  for i = 0, dataList.Count - 1 do
    local amoWishListItem = AmoWishListItem.New()
    amoWishListItem:InitCtrl(self.ui.mSListChild_Content.transform)
    amoWishListItem:SetData(dataList[i].id, i == dataList.Count - 1, self.mPlanActivityData)
    table.insert(self.mTabsTable, amoWishListItem)
  end
  function self.RefreshAimoWish(msg)
    self:OnRefreshAimoWish(msg)
  end
  MessageSys:AddListener(UIEvent.RefreshAimoWish, self.RefreshAimoWish)
  self:RefreshAimoWishInfo(dataList[0].id)
  function self.mAutoRefresh()
    if self.mAmoActivityData ~= nil then
      self:RefreshAimoWishInfo(self.mAmoActivityData.id, false)
      setactive(self.ui.mTrans_Complished, false)
      TimerSys:DelayCall(0.2, function()
        self.ui.mAni_Root:SetTrigger("InfoChange")
        setactive(self.ui.mTrans_Complished, true)
      end)
      MessageSys:SendMessage(UIEvent.GetAimoWishReward, self)
    end
  end
  MessageSys:AddListener(CS.GF2.Message.UIEvent.OnCloseCommonReceivePanel, self.mAutoRefresh)
  UIUtils.GetButtonListener(self.ui.mBtn_BtnReceive.transform).onClick = function()
    NetCmdActivityAmoData:SendGetAmoQuestReward(self.mRefreshId, function(ret)
      if ret == ErrorCodeSuc then
        UIManager.OpenUI(UIDef.UICommonReceivePanel)
      end
    end)
  end
end
function UIAmoWishPanel:OnShowStart()
  self:RefreshAimoWishInfo(self.mAmoActivityData.id)
end
function UIAmoWishPanel:OnShowFinish()
end
function UIAmoWishPanel:OnTop()
end
function UIAmoWishPanel:OnBackFrom()
  self:RefreshAimoWishInfo(self.mAmoActivityData.id)
end
function UIAmoWishPanel:OnRefreshAimoWish(msg)
  local refreshId = msg.Sender
  self.ui.mAni_Root:SetTrigger("Switch")
  self:RefreshAimoWishInfo(refreshId)
end
function UIAmoWishPanel:RefreshAimoWishInfo(refreshId)
  self.mRefreshId = refreshId
  local amoActivityData = TableData.listAmoActivitySubDatas:GetDataById(refreshId)
  if amoActivityData == nil then
    return
  end
  self.ui.mScrollRect.verticalNormalizedPosition = 1
  self.mAmoActivityData = amoActivityData
  for _, v in pairs(self.mTabsTable) do
    v:SetInteractable(true)
    if v.mData.id == refreshId then
      v:SetInteractable(false)
    end
  end
  self.ui.mTextFit_Info.text = amoActivityData.theme_long_description
  self.ui.mText_Title.text = amoActivityData.theme_short_description
  self.ui.mText_Chr.text = amoActivityData.name
  for i = 0, amoActivityData.theme_quests.Count - 1 do
    local amoWishAccessListItem = self.mTaskTable[i + 1]
    if amoWishAccessListItem == nil then
      amoWishAccessListItem = AmoWishAccessListItem.New()
      amoWishAccessListItem:InitCtrl(self.ui.mSListChild_GrpAccessList.transform)
      table.insert(self.mTaskTable, amoWishAccessListItem)
    end
    amoWishAccessListItem:SetData(amoActivityData.theme_quests[i])
  end
  local rewards = TableData.SpliteStrToItemAndNumList(amoActivityData.reward)
  if rewards ~= nil and 0 < rewards.Count then
    local index = 1
    for k, v in pairs(rewards) do
      local item = self.mRewardTable[index]
      if item == nil then
        item = UICommonItem.New()
        item:InitCtrl(self.ui.mSListChild_Content1)
        table.insert(self.mRewardTable, item)
      end
      local itemData = TableData.GetItemData(v.itemid)
      item:SetItemByStcData(itemData, v.num)
      index = index + 1
    end
  end
  local IsMainQuestUnlock = NetCmdActivityAmoData:GetMainQuestUnlock(refreshId)
  setactive(self.ui.mBtn_BtnReceive.transform.parent, IsMainQuestUnlock)
  setactive(self.ui.mTrans_Complete, not IsMainQuestUnlock)
  self.ui.mImg_Avatar.sprite = IconUtils.GetCharacterWholeSprite(amoActivityData.theme_icon)
  local isMainQuestRewardGet = NetCmdActivityAmoData:HasMainQuestRewardGet(refreshId)
  setactive(self.ui.mTrans_Ongoing, not isMainQuestRewardGet)
  setactive(self.ui.mTrans_Complished, isMainQuestRewardGet)
  self.ui.mTextFit_Info1.text = amoActivityData.theme_reply
  self.ui.mText_Title1.text = amoActivityData.reply_name
  self.ui.mImg_Sign.sprite = IconUtils.GetActivityCharacterSignSprite(amoActivityData.theme_icon)
  self.ui.mText_Name1.text = amoActivityData.name_gun
  local characterData = TableData.GetGunCharacterData(amoActivityData.theme_bg)
  if characterData ~= nil then
    self.ui.mImage_Bg.color = ColorUtils.StringToColor(characterData.color)
    self.ui.mImage_Bg1.color = ColorUtils.StringToColor(characterData.color)
  end
  local ossWithLog = CS.OssWishLog(amoActivityData.theme_bg, 0, 1)
  MessageSys:SendMessage(OssEvent.WishLog, nil, ossWithLog)
end
function UIAmoWishPanel:OnHide()
end
function UIAmoWishPanel:OnClose()
  for _, v in pairs(self.mTabsTable) do
    gfdestroy(v:OnRelease())
  end
  for _, v in pairs(self.mTaskTable) do
    gfdestroy(v:GetRoot())
  end
  for _, v in pairs(self.mRewardTable) do
    gfdestroy(v:GetRoot())
  end
  MessageSys:RemoveListener(UIEvent.RefreshAimoWish, self.RefreshAimoWish)
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.OnCloseCommonReceivePanel, self.mAutoRefresh)
end
function UIAmoWishPanel:OnRelease()
  self.ui = nil
  self.mData = nil
end
function UIAmoWishPanel:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_BtnBack.transform).onClick = function()
    UIManager.CloseUI(UIDef.UIActivityAimoWishPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnHome.transform).onClick = function()
    UIManager.JumpToMainPanel()
  end
end
