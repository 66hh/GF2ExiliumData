require("UI.UIBaseCtrl")
UIAchievementItemV2 = class("UIAchievementItemV2", UIBaseCtrl)
UIAchievementItemV2.__index = UIAchievementItemV2
UIAchievementItemV2.mImg_ProgressBar = nil
UIAchievementItemV2.mText_Tittle = nil
UIAchievementItemV2.mText_Content = nil
UIAchievementItemV2.mText_Percent = nil
UIAchievementItemV2.mText_Name = nil
UIAchievementItemV2.mText_Completed = nil
UIAchievementItemV2.mContent_Item = nil
function UIAchievementItemV2:__InitCtrl()
end
function UIAchievementItemV2:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("CommanderInfo/AchievementItemV2.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, false)
  end
  self.ui = {}
  self:SetRoot(obj.transform)
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self:__InitCtrl()
  self.ui.mText_GotoQuest.text = TableData.GetHintById(20)
  self.ui.mText_CompleteQuest.text = TableData.GetHintById(901001)
  self.mItemViewList = List:New()
end
function UIAchievementItemV2:SetData(data)
  if data ~= nil then
    setactive(self.ui.mUIRoot, true)
    self.ui.mText_Tittle.text = data.Name
    self.ui.mText_Content.text = data.Desp
    self.ui.mImg_ProgressBar.fillAmount = data.Progress
    self.ui.mText_Percent.text = data.ProgressStr
    for _, item in ipairs(self.mItemViewList) do
      gfdestroy(item:GetRoot())
    end
    for i = 0, data.RewardList.Count - 1 do
      local itemview = UICommonItem.New()
      itemview:InitCtrl(self.ui.mContent_Item)
      itemview:SetItemData(data.RewardList[i].itemid, data.RewardList[i].num)
      self.mItemViewList:Add(itemview)
      itemview.mUIRoot:SetAsFirstSibling()
      local stcData = TableData.GetItemData(data.RewardList[i].itemid)
      TipsManager.Add(itemview.mUIRoot, stcData)
    end
    local isCompleted = data.IsCompleted
    local canJump = data.CanJump
    local isReceived = data.IsReceived
    local isUnlock = true
    if canJump then
      local f = function()
        self:SetData(data)
      end
      isUnlock = UIUtils.CheckIsUnLock(data.jumpID, f)
    end
    setactive(self.ui.mTrans_Receive, isCompleted and not isReceived)
    setactive(self.ui.mTrans_Goto, not isCompleted and canJump and isUnlock == 0)
    if isCompleted then
      self.ui.mText_Name.text = TableData.GetHintById(901003)
    else
      self.ui.mText_Name.text = TableData.GetHintById(901002)
    end
    setactive(self.ui.mTrans_Completed, isCompleted and isReceived or not isCompleted and not canJump)
    setactive(self.ui.mTrans_BtnUnlock, isUnlock ~= 0 and canJump == true)
    if isUnlock ~= 0 then
      local str = ""
      local btnStr = ""
      if 0 < isUnlock then
        local unlockData = TableData.listUnlockDatas:GetDataById(isUnlock)
        str = UIUtils.CheckUnlockPopupStr(unlockData)
        btnStr = TableData.GetHintById(103050)
      elseif isUnlock == -2 then
        str = TableData.GetHintById(103070)
        btnStr = TableData.GetHintById(900009)
      elseif isUnlock == -1 then
        local jumpData = TableData.listJumpListContentnewDatas:GetDataById(tonumber(data.jumpID))
        str = string_format(TableData.GetHintById(jumpData.plan_open_hint), TableData.GetHintById(103054))
        btnStr = TableData.GetHintById(103051)
      end
      self.ui.mText_BtnUnlock.text = btnStr
      self.ui.mBtn_BtnUnlock.onClick:AddListener(function()
        PopupMessageManager.PopupString(str)
      end)
    end
  else
    setactive(self.ui.mUIRoot, false)
  end
end
