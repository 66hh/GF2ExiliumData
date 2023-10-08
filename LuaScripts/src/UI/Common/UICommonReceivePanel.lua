require("UI.Common.UICommonItem")
require("UI.CommonGetGunPanel.UICommonGetGunPanel")
require("UI.CommonLevelUpPanel.UICommonLevelUpPanel")
UICommonReceivePanel = class("UICommonReceivePanel", UIBasePanel)
function UICommonReceivePanel.OpenWithCheckPopupDownLeftTips(onCloseCallback, userParam)
  if UICommonReceivePanel.CheckCanPopup() then
    local param
    if userParam ~= nil then
      param = userParam
    else
      param = {nil, onCloseCallback}
    end
    UIManager.OpenUIByParam(UIDef.UICommonReceivePanel, param)
  end
end
function UICommonReceivePanel.CheckCanPopup()
  local userDropCacheList = NetCmdItemData:GetUserDropCache()
  if userDropCacheList == nil then
    return false
  end
  for i = userDropCacheList.Count - 1, 0, -1 do
    local userDropCache = userDropCacheList[i]
    if userDropCache.ItemNum == 0 then
    end
  end
  return userDropCacheList.Count > 0
end
function UICommonReceivePanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
  csPanel.UsePool = false
end
function UICommonReceivePanel:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self.maxLevel = TableData.GlobalSystemData.CommanderLevel
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self.textColor = self.ui.mText_Lv.color
  self.imageColor = self.ui.mImage_ExpAfter.color
  self.notShowItemList = TableData.GlobalSystemData.ItemGetCommonWindowNoshow
end
function UICommonReceivePanel:OnInit(root, data)
  self.mView = nil
  self.itemList = {}
  self.gunList = nil
  self.itemViewList = {}
  self.hasGun = false
  self.callback = nil
  self.mergeItem = false
  self.expDelta = 0
  self.dicTranItem = {}
  gfdebug("onSlotReceived 2")
  if self.textColor then
    self.ui.mText_Lv.color = self.textColor
  end
  if self.imageColor then
    self.ui.mImage_ExpAfter.color = self.imageColor
  end
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self.ui.mFadeManager:onItemFadeInEnd("+", self.onItemFadeInEnd)
  self.mCSPanel:Block()
  self.cachePanelType = self.mCSPanel.Type
  if data then
    if data[4] == nil then
      self.mergeItem = false
    else
      self.mergeItem = true
    end
    self.itemlist = data[1] == nil and self:InitItemList(NetCmdItemData:GetUserDropCache()) or data[1]
    gfdebug("onSlotReceived 3")
    self.callback = data[2]
    if data[3] ~= nil and next(data[3]) == nil then
      self.gunList = nil
    else
      self.gunList = data[3] == nil and NetCmdItemData:GetUserDropGunChache()
    end
    local panelType = data[6]
    if panelType then
      self.mCSPanel.Type = panelType
    end
    self.onClickConfirmCallback = data[7]
  else
    self.itemlist = self:InitItemList(NetCmdItemData:GetUserDropCache())
    self.gunList = NetCmdItemData:GetUserDropGunChache()
    self.callback = nil
    self.mergeItem = false
  end
  self.ui.mBtn_Confirm.interactable = false
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    if self.onClickConfirmCallback then
      self.onClickConfirmCallback()
    end
    self.onClickConfirmCallback = nil
    NetCmdItemData:ClearUserDropCache()
    gfdebug("[Tutorial] UICommonReceivePanel ClearUserDropCache")
    UIManager.CloseUI(UIDef.UICommonReceivePanel)
  end
  gfdebug("onSlotReceived 4")
  self.onShowStarted = false
end
function UICommonReceivePanel:OnShowStart()
  if #self.itemlist == 0 and self.expDelta == 0 then
    self:SetVisible(false)
    UIManager.CloseUI(UIDef.UICommonReceivePanel)
    return
  end
  if self.onShowStarted then
    return
  end
  self:UpdatePanel()
  self.onShowStarted = true
  self.ui.mBtn_Confirm.interactable = false
  self.mCSPanel:SetUIInteractable(false)
  if self.timer then
    self.timer:Stop()
    self.timer = nil
  end
  if 0 >= self.expDelta then
    self.timer = TimerSys:DelayCall(1.5, function()
      self.ui.mBtn_Confirm.interactable = true
      self.mCSPanel:SetUIInteractable(true)
    end)
  end
  local canvasGroup = self.mUIRoot:Find("Root"):GetComponent(typeof(CS.UnityEngine.CanvasGroup))
  if canvasGroup ~= nil and not canvasGroup:Equals(nil) then
    canvasGroup.blocksRaycasts = true
  end
  self.ui.mFadeManager:InitFade()
end
function UICommonReceivePanel:OnBackFrom()
  self.mCSPanel:PlayFadeIn()
  self.ui.mBtn_Confirm.interactable = false
  self.mCSPanel:SetUIInteractable(false)
  if self.timer then
    self.timer:Stop()
    self.timer = nil
  end
  self.timer = TimerSys:DelayCall(1.5, function()
    self.ui.mBtn_Confirm.interactable = true
    self.mCSPanel:SetUIInteractable(true)
  end)
  self.ui.mFadeManager:InitFade()
  self.mCSPanel:DoPlayBGM()
end
function UICommonReceivePanel:OnHide()
  if self.timer ~= nil then
    self.timer:Stop()
    self.timer = nil
  end
end
function UICommonReceivePanel:OnClose()
  if self.callback ~= nil then
    self.callback()
    self.callback = nil
  end
  if self.timer then
    self.timer:Stop()
    self.timer = nil
  end
  self:ReleaseTimers()
  self.mCSPanel.Type = self.cachePanelType
  self.cachePanelType = nil
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = nil
  self.onShowStarted = nil
  self:ReleaseCtrlTable(self.itemViewList, true)
  self.itemViewList = nil
  setactive(self.ui.mTrans_RaidPanel, false)
  self.dicTranItem = nil
  self.ui.mFadeManager:onItemFadeInEnd("-", self.onItemFadeInEnd)
  MessageSys:SendMessage(UIEvent.OnCloseCommonReceivePanel, nil)
  MessageSys:SendMessage(CS.GF2.Message.CommonEvent.ItemUpdate, nil)
end
function UICommonReceivePanel:OnRelease()
  self.ui = nil
  self.itemList = nil
  self.gunList = nil
  self.itemViewList = nil
  self.maxLevel = nil
  self.textColor = nil
  self.imageColor = nil
end
function UICommonReceivePanel:UpdatePanel()
  if self.itemlist ~= nil then
    for _, item in ipairs(self.itemlist) do
      local itemData = TableData.GetItemData(item.ItemId)
      local typeData = TableData.listItemTypeDescDatas:GetDataById(itemData.type)
      if typeData.pile == 0 then
        for i = 1, item.ItemNum do
          self:GetAppropriateItem(item.ItemId, item.ItemNum, item.Relate, item.DropUp)
        end
      else
        self:GetAppropriateItem(item.ItemId, item.ItemNum, item.Relate, item.DropUp)
      end
    end
  end
  self:CheckHasGun()
  if 0 < self.expDelta then
    self:DelayCall(0.3, function()
      self:UpdateExpData()
    end)
  end
end
function UICommonReceivePanel:GetAppropriateItem(itemId, itemNum, relateId, isUpItem)
  local itemData = TableData.GetItemData(itemId)
  if itemData == nil then
    return nil
  end
  if itemId == 200 then
    return nil
  end
  local itemView
  if itemData.type == GlobalConfig.ItemType.Weapon then
    local weaponInfoItem = UICommonItem.New()
    weaponInfoItem:InitCtrl(self.ui.mTrans_ItemList)
    weaponInfoItem:SetData(itemData.args[0], 1, nil, true, itemData)
    itemView = weaponInfoItem
  elseif itemData.type == GlobalConfig.ItemType.WeaponPart then
    local weaponPartItem = UICommonItem.New()
    local partData = NetCmdWeaponPartsData:GetWeaponModById(relateId)
    weaponPartItem:InitCtrl(self.ui.mTrans_ItemList)
    weaponPartItem:SetPartData(partData, nil, false)
    weaponPartItem:SetQualityLine(true)
    TipsManager.Add(weaponPartItem.ui.mBtn_Select.gameObject, itemData, 1, false, nil, relateId, nil, nil, true)
    itemView = weaponPartItem
  else
    itemView = UICommonItem.New()
    itemView:InitCtrl(self.ui.mTrans_ItemList)
    if itemData.type == 23 then
      itemView:SetEquipData(itemData.args[0], 0, nil, itemId, relateId)
    else
      itemView:SetItemData(itemId, itemNum)
    end
  end
  itemView:SetUpIconVisible(isUpItem == true)
  local d = self.dicTranItem[itemId]
  if d then
    itemView.ui.mBtn_Select.interactable = false
    itemView:SetItemOverflowDisplay(d.ItemId, d.ItemNum)
  end
  table.insert(self.itemViewList, itemView)
end
function UICommonReceivePanel:UpdateExpData()
  setactive(self.ui.mTrans_RaidPanel, true)
  local levelUp = AccountNetCmdHandler.mLevelDelta
  local curLevel = AccountNetCmdHandler:GetLevel()
  local beforeLv = curLevel - levelUp
  self.ui.mText_ExpAdd.text = "+" .. self.expDelta
  self.ui.mText_Lv.text = "Lv." .. beforeLv
  local notNeedShowExp = beforeLv >= self.maxLevel
  setactive(self.ui.mTrans_GrpAdd, not notNeedShowExp)
  setactive(self.ui.mImage_ExpBefore, not (curLevel >= self.maxLevel))
  if notNeedShowExp then
    self.ui.mText_Lv.text = TableData.GetHintById(160012)
    self.ui.mText_Lv.color = ColorUtils.OrangeColor2
    self.ui.mImage_ExpAfter.color = ColorUtils.OrangeColor2
    self.ui.mImage_ExpAfter.fillAmount = 1
    self:DelayCall(0.5, function()
      self.ui.mBtn_Confirm.interactable = true
    end)
    return
  end
  local oldExp = AccountNetCmdHandler:GetOldExpPct()
  self.ui.mImage_ExpAfter.fillAmount = oldExp
  local last_level = oldExp
  local cur_level = AccountNetCmdHandler:GetExpPct()
  local mSequence = CS.LuaDOTweenUtils.SetComRoleLevelUp(self.ui.mImage_ExpBefore, self.ui.mImage_ExpAfter, 0 < levelUp, last_level, cur_level, function()
    if 0 < levelUp then
      UICommonLevelUpPanel.Open(UICommonLevelUpPanel.ShowType.CommanderLevelUp)
    end
    if curLevel >= self.maxLevel then
      self.ui.mText_Lv.text = TableData.GetHintById(160012)
      self.ui.mText_Lv.color = ColorUtils.OrangeColor2
      self.ui.mImage_ExpAfter.color = ColorUtils.OrangeColor2
      self.ui.mImage_ExpAfter.fillAmount = 1
    end
    self:DelayCall(0.5, function()
      self.ui.mBtn_Confirm.interactable = true
    end)
  end, function()
    self.ui.mText_Lv.text = "Lv." .. curLevel
  end)
  UITweenManager.TweenPlay(mSequence)
end
function UICommonReceivePanel:CheckHasGun()
  if self.gunList ~= nil and self.gunList.Length > 0 then
    local gunList = {}
    for i = 0, self.gunList.Length - 1 do
      table.insert(gunList, self.gunList[i])
    end
    UICommonGetGunPanel.OpenGetGunPanel(gunList, function()
      if SceneSys.currentScene:GetSceneType() == CS.EnumSceneType.CommandCenter then
        SceneSys:SwitchVisible(CS.EnumSceneType.CommandCenter)
      end
      if self.callback ~= nil then
        self.callback()
        self.callback = nil
      end
      setactivewithcheck(self.ui.mTrans_Receive, true)
    end, nil, true)
    setactivewithcheck(self.ui.mTrans_Receive, false)
  end
end
function UICommonReceivePanel:InitItemList(data)
  gfdebug("onSlotReceived InitItemList")
  local itemList = {}
  local dicExItem = {}
  for i = 0, data.Count - 1 do
    if data[i].OverflowNum ~= 0 then
      PopupMessageManager.PopupDownLeftTips(data[i].ItemId)
    end
    local itemId = data[i].ItemId
    if itemId == 200 then
      self.expDelta = self.expDelta + data[i].ItemNum
    else
      local itemData = TableData.GetItemData(itemId)
      local typeData = TableData.listItemTypeDescDatas:GetDataById(itemData.type)
      local typeID = itemData.type
      if self.notShowItemList:Contains(typeID) == false then
        if itemData.type == GlobalConfig.ItemType.GunType and 0 >= data[i].ItemNum then
          local tID
          for id, num in pairs(data[i].ExtItems) do
            if dicExItem[id] then
              dicExItem[id] = dicExItem[id] + num
            else
              dicExItem[id] = num
            end
            tID = id
          end
          if 0 < data[i].TranItems.Count then
            local t = {}
            for id, num in pairs(data[i].TranItems) do
              t.ItemId = id
              t.ItemNum = num
              t.Relate = 0
            end
            self.dicTranItem[tID] = t
          end
        elseif self.mergeItem and 0 < typeData.pile then
          if dicExItem[itemId] then
            dicExItem[itemId] = dicExItem[itemId] + data[i].ItemNum
          else
            dicExItem[itemId] = data[i].ItemNum
          end
        else
          table.insert(itemList, data[i])
        end
      end
    end
  end
  for id, num in pairs(dicExItem) do
    local item = {}
    item.ItemId = id
    item.ItemNum = num
    item.Relate = 0
    table.insert(itemList, item)
  end
  UIUtils.SortItemTable(itemList)
  return itemList
end
function UICommonReceivePanel.onItemFadeInEnd(go)
  local animator = go:GetComponentInChildren(typeof(CS.UnityEngine.Animator))
  if not animator then
    return
  end
  animator:SetTrigger("FadeIn")
end
