require("UI.UIBasePanel")
require("UI.MailPanelV2.UIMailPanelV2View")
require("UI.MailPanelV2.Item.UIMailLeftTabItemV2")
require("UI.Common.UICommonItem")
UIMailPanelV2 = class("UIMailPanelV2", UIBasePanel)
UIMailPanelV2.__index = UIMailPanelV2
UIMailPanelV2.mPath_MailListItem = "Mail/MailLeftTabItemV2.prefab"
UIMailPanelV2.mView = nil
UIMailPanelV2.mCurSelMailItem = nil
UIMailPanelV2.mMailListItems = {}
UIMailPanelV2.mAttachmentIds = {}
UIMailPanelV2.mAttachmentItems = {}
UIMailPanelV2.mCachedMailList = nil
UIBasePanel.mIsSyncOn = false
UIMailPanelV2.tipsItem = nil
function UIMailPanelV2:ctor()
  UIMailPanelV2.super.ctor(self)
end
function UIMailPanelV2:OnInit(root)
  UIMailPanelV2.super.SetRoot(UIMailPanelV2, root)
  self.RedPointType = {
    RedPointConst.Mails
  }
  self.mView = UIMailPanelV2View.New()
  self.ui = {}
  self.mView:InitCtrl(root, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_BackItem.gameObject).onClick = function(gameObj)
    self:OnReturnClick(gameObj)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_HomeItem.gameObject).onClick = function()
    self:OnCommanderCenter()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Delete.gameObject).onClick = function(gameObj)
    self:OnDeleteBtnClicked(gameObj)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Right3Item.gameObject).onClick = function(gameObj)
    self:OnAllReceive(gameObj)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Left3Item.gameObject).onClick = function(gameObj)
    self:OnDeleteAllBtnClicked(gameObj)
  end
  function self.onMailChangedCallBack()
    self:OnMailChangedCallBack()
  end
  function self.redPointUpdate(msg)
    if msg.Sender == "Mails" then
      self.mCachedMailList:Clear()
      self.mCachedMailList = nil
      self.mCurSelMailItem = nil
      self:UpdateMailList()
      self.ui.mScrollbar_Material.value = 1
      self:UpdateRedPoint()
    end
  end
  function self.onMailGetAttachment(msg)
  end
  function self.onMailsGetAttachment(msg)
  end
  MessageSys:AddListener(CS.GF2.Message.MailEvent.OnMailsGetAttachment, self.onMailsGetAttachment)
  MessageSys:AddListener(CS.GF2.Message.MailEvent.OnMailGetAttachment, self.onMailGetAttachment)
  MessageSys:AddListener(CS.GF2.Message.RedPointEvent.RedPointUpdate, self.redPointUpdate)
  MessageSys:AddListener(CS.GF2.Message.MailEvent.MailDelete, self.onMailChangedCallBack)
  function self.ui.mList_Item.itemProvider()
    return self:GetRenderItem()
  end
  function self.ui.mList_Item.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
  self.ui.mText_NumAll.text = "/" .. TableData.GlobalConfigData.MailMaxlimit
  self:InitMailList()
end
function UIMailPanelV2:OnTop()
end
function UIMailPanelV2:OnShowFinish()
  if not self.skipRefresh then
    self:RefreshMailList()
  else
    self.skipRefresh = nil
  end
end
function UIMailPanelV2:OnClose()
  MessageSys:RemoveListener(CS.GF2.Message.MailEvent.OnMailsGetAttachment, self.onMailsGetAttachment)
  MessageSys:RemoveListener(CS.GF2.Message.MailEvent.OnMailGetAttachment, self.onMailGetAttachment)
  MessageSys:RemoveListener(CS.GF2.Message.RedPointEvent.RedPointUpdate, self.redPointUpdate)
  MessageSys:RemoveListener(CS.GF2.Message.MailEvent.MailDelete, self.onMailChangedCallBack)
  for _, item in ipairs(self.mMailListItems) do
    gfdestroy(item:GetRoot())
  end
  self.mCurSelMailItem = nil
  self.mCachedMailList = nil
  self.mMailListItems = {}
  if self.timer ~= nil then
    self.timer:Stop()
    self.timer = nil
  end
end
function UIMailPanelV2:OnRelease()
  self.mCurSelMailItem = nil
  self.mMailListItems = {}
  self.mAttachmentIds = {}
  self.mAttachmentItems = {}
  self.mCachedMailList = nil
  self.mIsSyncOn = false
  self.tipsItem = nil
  self.mMailInitialized = nil
end
function UIMailPanelV2:GetRenderItem()
  return self:ItemProvider()
end
function UIMailPanelV2:ItemProvider()
  local itemView = UICommonItem.New()
  itemView:InitCtrl(self.ui.mContent_Item.transform)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView.mUIRoot.gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIMailPanelV2:ItemRenderer(index, renderData)
  local itemId = self.mAttachmentIds[index + 1]
  local itemData = self.mAttachmentItems[itemId]
  local itemView = renderData.data
  local itemCount = 0
  local typeData = TableData.listItemTypeDescDatas:GetDataById(itemData.type)
  if self.mCurSelMailItem.mData.attachments:ContainsKey(itemData.id) then
    if typeData.pile == 0 then
      itemCount = 1
    else
      itemCount = self.mCurSelMailItem.mData.attachments[itemData.id]
    end
  end
  itemView:SetByItemData(itemData, itemCount, 0 < self.mCurSelMailItem.mData.get_attachment)
end
function UIMailPanelV2:InitMailList()
  local itemPrefab = UIUtils.GetGizmosPrefab(self.mPath_MailListItem, self)
  if self.mCachedMailList == nil then
    self.mCachedMailList = NetCmdMailData:GetSortedMailList()
  end
  local bIsDefaultSet = false
  local prevSelectIndex = -1
  if self.mCurSelMailItem ~= nil then
    printstack(self.mCurSelMailItem.mIndex)
    prevSelectIndex = self.mCurSelMailItem.mIndex
  end
  self:HideItemList()
  self:ClearSelect()
  setactive(self.ui.mTrans_MailList.gameObject, self.mCachedMailList.Count > 0)
  setactive(self.ui.mTrans_None.gameObject, self.mCachedMailList.Count <= 0)
  setactive(self.ui.mTrans_MailList.gameObject, self.mCachedMailList.Count > 0)
  setactive(self.ui.mTrans_None.gameObject, self.mCachedMailList.Count <= 0)
  for i = 0, self.mCachedMailList.Count - 1 do
    local instObj, item
    if #self.mMailListItems >= i + 1 then
      item = self.mMailListItems[i + 1]
      item:SetActive(true)
      instObj = item:GetRoot().gameObject
    else
      instObj = instantiate(itemPrefab, self.ui.mContent_Material.gameObject.transform)
      item = UIMailLeftTabItemV2.New()
    end
    item:InitCtrl(instObj.transform)
    item:InitData(self.mCachedMailList[i])
    item.mIndex = i
    local itemBtn = UIUtils.GetButtonListener(item.mUIRoot.gameObject)
    function itemBtn.onClick(gameObj)
      self:OnMailItemClicked(gameObj)
    end
    itemBtn.param = item
    self.mMailListItems[i + 1] = item
    if self.mCachedMailList[i].IsExpired == false and i >= prevSelectIndex and bIsDefaultSet == false then
      bIsDefaultSet = true
      self:SelectMail(item)
    end
  end
  ResourceManager:UnloadAssetFromLua(itemPrefab)
  self.ui.mText_Num.text = self.mCachedMailList.Count
end
function UIMailPanelV2:RefreshMailList()
  for i = 1, #self.mMailListItems do
    local item = self.mMailListItems[i]
    item:SetRead(self.mMailListItems[i].mIsRead == true)
  end
end
function UIMailPanelV2:OnMailItemClicked(gameObj)
  if self.mIsSyncOn == true then
    return
  end
  local eventTrigger = getcomponent(gameObj, typeof(CS.ButtonEventTriggerListener))
  if eventTrigger ~= nil then
    local item = eventTrigger.param
    self:ClearSelect()
    self:SelectMail(item)
  end
end
function UIMailPanelV2.OnMailChangedCallBack()
  MessageBox.Show(TableData.GetHintById(60051), TableData.GetHintById(60050), MessageBox.ShowFlag.eMidBtn, nil, function()
    self:UpdateMailList()
  end, nil)
end
function UIMailPanelV2:SelectMail(item)
  if item.mData.isReq then
    item:Select()
    self.mCurSelMailItem = item
    self:UpdateMailContent(item)
  else
    local data = NetCmdMailData:GetMailDataById(item.mData.id)
    item:SetData(data)
    item:Select()
    self.mCurSelMailItem = item
    NetCmdMailData:SendMailDetail(item.mData.id, function()
      self:MailReadCallback(item)
      self:UpdateMailContent(item)
    end)
  end
end
function UIMailPanelV2:MailReadCallback(item)
  item:SetRead(true)
  item:ClearAttachment()
  self:UpdateRedPoint()
end
function UIMailPanelV2:ClearSelect()
  for i = 1, #self.mMailListItems do
    self.mMailListItems[i]:UnSelect()
  end
  self.mCurSelMailItem = nil
end
function UIMailPanelV2:HideItemList()
  for i = 1, #self.mMailListItems do
    self.mMailListItems[i]:SetActive(false)
  end
end
function UIMailPanelV2:UpdateMailList()
  self:InitMailList()
end
function UIMailPanelV2.CheckScroll(pos)
  if pos.y > 0 then
    setactive(UIMailPanelV2.ui.mScrollbar_Material.gameObject, true)
  else
    setactive(UIMailPanelV2.ui.mScrollbar_Material.gameObject, false)
  end
end
function UIMailPanelV2:UpdateMailContent(item, skipAnim)
  if self.mCurSelMailItem ~= item then
    return
  end
  self:ClearAttachmentItem()
  local data = self.mCurSelMailItem.mData
  self.ui.mText_Title.text = data.title
  self.ui.mText_Description.text = data.content
  self.ui.mText_Time.text = data.mail_date
  self.ui.mText_CountDown.text = data.remain_time
  self.ui.mText_MailName.text = data.addresser
  self.ui.mTextEvent_DescriptionEvent:SetNeedToken(data.need_token)
  self:UpdateTimer()
  local layoutElement = self.ui.mTrans_Reward:GetComponent(typeof(CS.UnityEngine.UI.LayoutElement))
  layoutElement.ignoreLayout = true
  setactive(self.ui.mTrans_Reward, false)
  local attachments = {}
  for k, v in pairs(data.attachments) do
    attachments[k] = v
    layoutElement.ignoreLayout = false
    setactive(self.ui.mTrans_Reward, true)
  end
  local canReceive = false
  local i = 1
  for k, v in pairs(attachments) do
    local itemData = TableData.GetItemData(k)
    local typeData = TableData.listItemTypeDescDatas:GetDataById(itemData.type)
    local count = 1
    if typeData.pile == 0 then
      count = v
    end
    for index = 1, count do
      self.mAttachmentIds[i] = k
      i = i + 1
    end
    self.mAttachmentItems[k] = itemData
    local itemTime = itemData.time_limit
    if itemTime == 0 or 0 < itemTime and UIUtils.CheckIsTimeOut(itemTime) == false then
      canReceive = true
    end
  end
  self.ui.mList_Item.numItems = #self.mAttachmentIds
  self.ui.mList_Item:Refresh()
  if not skipAnim then
    self.ui.mAnimator:SetTrigger("Switch")
  end
  if data.hasLink == true then
    setactive(self.ui.mBtn_PowerUp.gameObject, false)
    setactive(self.ui.mTrans_UnLocked.gameObject, false)
  elseif canReceive == false then
    setactive(self.ui.mTrans_Delete.gameObject, true)
    setactive(self.ui.mTrans_CanReceive.gameObject, false)
  else
    setactive(self.ui.mTrans_UnLocked.gameObject, data.hasAttachment and data.get_attachment == 1)
    if data.get_attachment == 0 and data.hasAttachment then
      setactive(self.ui.mTrans_CanReceive.gameObject, true)
      setactive(self.ui.mTrans_Delete.gameObject, false)
      UIUtils.GetButtonListener(self.ui.mBtn_PowerUp.gameObject).onClick = function(gameObj)
        self:OnReceiveBtnClicked(gameObj)
      end
    else
      setactive(self.ui.mTrans_Delete.gameObject, true)
      setactive(self.ui.mTrans_CanReceive.gameObject, false)
    end
  end
end
function UIMailPanelV2:UpdateTimer()
  if self.timer ~= nil then
    self.timer:Stop()
    self.timer = nil
  end
  self.timer = TimerSys:DelayCall(1, function()
    if self.mCurSelMailItem == nil then
      self.timer:Stop()
      self.timer = nil
    else
      self.ui.mText_CountDown.text = self.mCurSelMailItem.mData.remain_time
    end
  end, nil, -1)
end
function UIMailPanelV2:GetAppropriateItem(itemData, itemNum)
  if itemData == nil then
    return nil
  end
  if itemData.type == 8 then
    local weaponInfoItem = UICommonItem.New()
    weaponInfoItem:InitCtrl(self.ui.mContent_Item.gameObject.transform)
    weaponInfoItem:SetData(itemData.args[0], 1)
    if 0 < self.mCurSelMailItem.mData.get_attachment then
      weaponInfoItem:SetReceived(true)
    end
    return weaponInfoItem
  else
    local itemView = UICommonItem.New()
    itemView:InitCtrl(self.ui.mContent_Item.gameObject.transform)
    if itemData.type == 5 then
      local equipData = TableData.listGunEquipDatas:GetDataById(tonumber(itemData.args[0]))
      itemView:SetEquipData(itemData.args[0], 0, nil, equipData.id)
    else
      itemView:SetItemData(itemData.id, itemNum)
    end
    if 0 < self.mCurSelMailItem.mData.get_attachment then
      itemView:SetReceived(true)
    end
    return itemView
  end
end
function UIMailPanelV2:ClearAttachmentItem()
  self.mAttachmentIds = {}
end
function UIMailPanelV2:OnReceiveBtnClicked(gameObj)
  local canReceive = false
  if self.mCurSelMailItem.mData then
    local attachments = self.mCurSelMailItem.mData.attachments
    local equipTable = {}
    local weaponTable = {}
    local otherTable = {}
    for itemId, num in pairs(attachments) do
      local itemData = TableData.GetItemData(itemId)
      local itemTime = itemData.time_limit
      if itemTime == 0 or 0 < itemTime and UIUtils.CheckIsTimeOut(itemTime) == false then
        canReceive = true
      end
      if otherTable[itemId] ~= nil then
        otherTable[itemId] = otherTable[itemId] + num
      else
        otherTable[itemId] = num
      end
    end
    if canReceive == false then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(60052))
      self:UpdateMailContent(self.mCurSelMailItem, true)
      return
    end
    if TipsManager.CheckItemIsOverflowAndStopByList(otherTable) then
      return
    end
  end
  local id = self.mCurSelMailItem.mData.id
  NetCmdMailData:SendReqRoleMailGetAttachmentCmd(id, function(ret)
    self:OnReceiveAttachmentCallback(ret)
  end)
end
function UIMailPanelV2:OnDeleteBtnClicked(gameObj)
  local id = self.mCurSelMailItem.mData.id
  local ids = {}
  ids[1] = id
  NetCmdMailData:SendReqRoleMailDelCmd(ids, function(ret)
    self:OnMailDeleteCallback(ret)
  end)
  self.mIsSyncOn = true
end
function UIMailPanelV2:OnDeleteAllBtnClicked(gameObj)
  if self:HasCanDelMail() then
    MessageBox.Show(TableData.GetHintById(60003), TableData.GetHintById(60004), MessageBox.ShowFlag.eNone, nil, function(param)
      self:ConfirmMailTips(param)
    end, nil)
  else
    CS.PopupMessageManager.PopupString(TableData.GetHintById(60057))
  end
end
function UIMailPanelV2:OnLinkBtnClicked(gameObj)
  if self.mCurSelMailItem.mData.IsExpired == true then
    MessageBox.Show(TableData.GetHintById(60051), TableData.GetHintById(60052), MessageBox.ShowFlag.eMidBtn, nil, nil, nil)
    return
  end
end
function UIMailPanelV2:OnAllReceive(gameObj)
  NetCmdMailData:SendReqRoleMailGetAttachmentsCmd(function(ret)
    self:GetRewardCallBack(ret)
  end)
end
function UIMailPanelV2:OnReceiveAttachmentCallback(ret)
  if ret == ErrorCodeSuc then
    self.skipRefresh = true
    UIManager.OpenUIByParam(UIDef.UICommonReceivePanel, {
      nil,
      function()
        self:UpdateRedPoint()
        self:UpdateMailList()
      end
    })
  else
    gfdebug("领取失败")
    self.mCachedMailList:Remove(self.mCurSelMailItem.mData)
    if self.mCurSelMailItem.mIndex + 1 > self.mCachedMailList.Count then
      self.mCurSelMailItem = nil
      self.ui.mTrans_MailList.offsetMax = Vector2(self.ui.mTrans_MailList.offsetMax.x, 0)
    end
    self:UpdateMailList()
  end
end
function UIMailPanelV2:OnMailDeleteCallback(ret)
  self.mIsSyncOn = false
  if ret == ErrorCodeSuc then
    gfdebug("删除邮件成功")
  else
    gfdebug("删除邮件失败")
    MessageBox.Show(TableData.GetHintById(60053), TableData.GetHintById(60054), MessageBox.ShowFlag.eMidBtn, nil, nil, nil)
  end
end
function UIMailPanelV2:OnAllMailDeleteCallback(ret)
  self.mIsSyncOn = false
  if ret == ErrorCodeSuc then
    gfdebug("删除邮件成功")
  else
    gfdebug("删除邮件失败")
    MessageBox.Show(TableData.GetHintById(60053), TableData.GetHintById(60054), MessageBox.ShowFlag.eMidBtn, nil, nil, nil)
  end
end
function UIMailPanelV2:OnReturnClick(gameObj)
  UIManager.CloseUI(UIDef.UIMailPanelV2)
end
function UIMailPanelV2.OnCommanderCenter()
  UIManager.JumpToMainPanel()
end
function UIMailPanelV2:GetRewardCallBack(ret)
  if ret == ErrorCodeSuc then
    local idList = NetCmdMailData:GetAllReadId()
    if idList.Count == 0 then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(60056))
    else
      UIManager.OpenUIByParam(UIDef.UICommonReceivePanel, {
        nil,
        function()
          self.mCachedMailList:Clear()
          self.mCachedMailList = nil
          self.mCurSelMailItem = nil
          self:UpdateMailList()
          self:UpdateRedPoint()
        end
      })
    end
  else
    printstack("一键领取邮件失败")
  end
end
function UIMailPanelV2:FiltrateMail()
  local mailList = {}
  for _, item in pairs(self.mCachedMailList) do
    if item.read == 1 then
      if item.hasAttachment then
        if item.get_attachment == 1 then
          table.insert(mailList, item.id)
        end
      else
        table.insert(mailList, item.id)
      end
    end
  end
  return mailList
end
function UIMailPanelV2:HasNotGetAttachment()
  for _, item in pairs(self.mCachedMailList) do
    if item.hasAttachment and item.get_attachment == 0 then
      return true
    end
  end
  return false
end
function UIMailPanelV2:CheckAllReceiveItem()
  local otherTable = {}
  local canReceive = false
  for _, item in pairs(self.mCachedMailList) do
    if item.hasAttachment and item.get_attachment == 0 then
      local attachments = item.attachments
      for itemId, num in pairs(attachments) do
        if otherTable[itemId] ~= nil then
          otherTable[itemId] = otherTable[itemId] + num
        else
          otherTable[itemId] = num
        end
        local itemData = TableData.GetItemData(itemId)
        local itemTime = itemData.time_limit
        if itemTime == 0 or 0 < itemTime and UIUtils.CheckIsTimeOut(itemTime) == false then
          canReceive = true
        end
      end
    end
  end
  if canReceive == false then
    CS.PopupMessageManager.PopupString(TableData.GetHintById(60052))
    self:UpdateMailContent(self.mCurSelMailItem, true)
  end
  if TipsManager.CheckItemIsOverflowAndStopByList(otherTable) then
    return true
  end
  return false
end
function UIMailPanelV2:HasCanDelMail()
  for _, item in pairs(self.mCachedMailList) do
    if item.read == 1 then
      if item.hasAttachment then
        if item.get_attachment == 1 then
          return true
        end
      else
        return true
      end
    end
  end
  return false
end
function UIMailPanelV2:ConfirmMailTips(param)
  if self.tipsItem then
    self.tipsItem:CloseTips()
  end
  local ids = self:FiltrateMail()
  NetCmdMailData:SendReqRoleMailDelCmd(ids, function(ret)
    self:OnAllMailDeleteCallback(ret)
  end)
end
function UIMailPanelV2:CollectItem(itemList)
  local dicItem = {}
  for id, num in pairs(itemList) do
    local itemData = TableData.GetItemData(id)
    if itemData then
      local maxCount = 0
      local type = itemData.type
      local typeData = TableData.listItemTypeDescDatas:GetDataById(type)
      if typeData.related_item and 0 < typeData.related_item then
        if dicItem[typeData.related_item] == nil then
          dicItem[typeData.related_item] = 0
        end
        dicItem[typeData.related_item] = dicItem[typeData.related_item] + num
      else
        dicItem[id] = num
      end
    end
  end
  return dicItem
end
