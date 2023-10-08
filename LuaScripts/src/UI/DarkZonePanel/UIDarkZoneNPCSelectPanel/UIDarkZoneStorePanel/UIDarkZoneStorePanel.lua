require("UI.DarkZonePanel.UIDarkZoneNPCSelectPanel.UIDarkZoneStorePanel.Item.DZBuyItem")
require("UI.DarkZonePanel.UIDarkZoneNPCSelectPanel.UIDarkZoneStorePanel.Item.DZComTabItem")
require("UI.DarkZonePanel.UIDarkZoneTaskPanel.Item.DarkZoneLeftTaskRootItem")
require("UI.DarkZonePanel.UIDarkZoneNPCSelectPanel.UIDarkZoneStorePanel.UIDarkZoneStorePanelView")
require("UI.UIBasePanel")
UIDarkZoneStorePanel = class("UIDarkZoneStorePanel", UIBasePanel)
UIDarkZoneStorePanel.__index = UIDarkZoneStorePanel
function UIDarkZoneStorePanel:ctor(csPanel)
  UIDarkZoneStorePanel.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
end
function UIDarkZoneStorePanel:OnInit(root, data)
  UIDarkZoneStorePanel.super.SetRoot(UIDarkZoneStorePanel, root)
  self:InitBaseData()
  self.IsNpcUnlock = true
  self.Npc = 401
  self.mData = TableData.listDarkzoneNpcDatas:GetDataById(401)
  DZStoreUtils.curNpcId = self.Npc
  self.mview:InitCtrl(root, self.ui)
  self:GetAllUnLockNpc()
  self.ui.mText_TagetTitle.text = TableData.GetHintById(80070)
  for i = 1, 3 do
    local obj
    obj = instantiate(self.ui.mTrans_leftListTaskItem.gameObject)
    setactive(obj, true)
    local itemView = DarkZoneLeftTaskRootItem.New()
    itemView:InitCtrl(self.ui.mTrans_TaskRootContent, obj)
    local num = 903241 + i
    itemView:SetData(num)
    self.leftTaskRoot[i] = itemView
  end
  setactive(self.ui.mTrans_leftListTaskItem.gameObject, false)
  for i = 1, #self.allNPCList do
    if self.allNPCList[i] == self.Npc then
      self.listIndex = i
    end
  end
  local com = self.ui.mTrans_BtnScreen:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem)
  CS.LuaUIUtils.SetParent(obj.gameObject, self.ui.mTrans_BtnScreen.gameObject, true)
  self.ScreenItem = {}
  self.ScreenItem.mUIRoot = obj.transform
  local LuaUIBindScript = obj:GetComponent(UIBaseCtrl.LuaBindUi)
  local vars = LuaUIBindScript.BindingNameList
  for i = 0, vars.Count - 1 do
    self.ScreenItem[vars[i]] = LuaUIBindScript:GetBindingComponent(vars[i])
  end
  setactive(self.ScreenItem.mBtn_TypeScreen, false)
  function self.msgFunction(msg)
    self:FreshTaskData(msg)
  end
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.FreshDarkZoneTask, self.msgFunction)
  self.pointer = UIUtils.GetPointerClickHelper(self.ui.mTrans_GrpDetailsLeft.gameObject, function()
    setactive(self.ui.mTrans_GrpDetailsLeft, false)
  end, self.ui.mTrans_GrpDetailsLeft.gameObject)
  self:AddBtnListen()
  function self.ui.mBuyVirtualList.itemProvider()
    return self:BuyItemProvider()
  end
  function self.ui.mBuyVirtualList.itemRenderer(index, renderDataItem)
    self:BuyItemRenderer(index, renderDataItem)
  end
  function self.ui.mSellVirtualList.itemProvider()
    return self:SellItemProvider()
  end
  function self.ui.mSellVirtualList.itemRenderer(index, renderDataItem)
    self:SellItemRenderer(index, renderDataItem)
  end
  function self.ui.mVirtualList.itemProvider()
    local item = self:ItemProvider()
    return item
  end
  function self.ui.mVirtualList.itemRenderer(index, renderDataItem)
    self:ItemRenderer(index, renderDataItem)
  end
  self:InitData()
end
function UIDarkZoneStorePanel:OnShowFinish()
  self.ui.mText_CoinNum.text = NetCmdItemData:GetResItemCount(18)
  self.TabList[self.CurTab].callBack()
  if self.IsPanelOpen == false then
    self.ui.mAnim_Root:ResetTrigger("Previous")
    self.ui.mAnim_Root:SetTrigger("Previous")
  end
  local NpcNetData = DarkNetCmdStoreData:GetNpcDataById(self.mData.id)
  self.NpcFavor = 0
  if NpcNetData then
    self.NpcFavor = NpcNetData.Favor
  end
  self.FavorLevel, self.FavorExp, self.NextFavor = DZStoreUtils:GetCurFavorLevelAndExp(self.mData.id, NpcNetData.Favor)
  if self.IsNpcUnlock then
    setactive(self.ui.mBtn_Quest.gameObject, true)
    self.ui.mImg_Chr.color = ColorUtils.WhiteColor
  else
    setactive(self.ui.mBtn_Quest.gameObject, false)
    self.FavorLevel = 0
    self.ui.mImg_Chr.color = ColorUtils.GrayColor
  end
  self.ui.mText_Level.text = self.FavorLevel
  self.ui.mText_ExpNum.text = self.FavorExp .. "/" .. self.NextFavor
  self.ui.mSlider.FillAmount = self.FavorExp / self.NextFavor
  self.IsPanelOpen = true
end
function UIDarkZoneStorePanel:OnHideFinish()
  self.IsPanelOpen = false
end
function UIDarkZoneStorePanel:OnUpdate(deltatime)
  for k, v in ipairs(self.SellItemScriptList) do
    v:OnUpdate(deltatime)
  end
  for k, v in pairs(self.BuyItemScriptList) do
    v:UpdateTime(deltatime)
  end
  for k, v in pairs(self.LongAddList) do
    if v ~= nil then
      if self.ClickMultiSell == false then
        v.enabled = false
      elseif self.ClickMultiSell == true then
        v.enabled = true
      end
    end
  end
end
function UIDarkZoneStorePanel:CloseFunction()
  if self.isAtQuestPage == false then
    if self.ClickMultiSell then
      self:CancleSell()
    end
    UIManager.CloseUI(UIDef.UIDarkZoneStorePanel)
  else
    self:EnterStore()
  end
end
function UIDarkZoneStorePanel:OnClose()
  self.ui.mBuyVirtualList.numItems = 0
  self.ui.mSellVirtualList.numItems = 0
  self.ui = nil
  self.mview = nil
  self.ItemDataList = nil
  self.IsPanelOpen = nil
  self.CurTab = nil
  self.NpcStoreItemDic = nil
  self:ReleaseCtrlTable(self.TabList, true)
  self.TabList = nil
  self.BuyItemList = nil
  self.SellItemList = nil
  self.Npc = nil
  self.ClickMultiSell = nil
  self.SortWay = nil
  DZStoreUtils.LastTab = nil
  self.BlockHelper = nil
  self.DZSellInfo = nil
  self.NpcFavor = nil
  self.IsAscend = nil
  self.IsSetBack = nil
  self.SellCanGetNum = nil
  self.FavorLevel = nil
  self.FavorExp = nil
  self.NextFavor = nil
  self.NpcIndex = nil
  self.IsSwitchLockByArrow = nil
  self.NotSell = nil
  self.SellItemScriptList = nil
  self.MultiSellList = nil
  self.BuyItemScriptList = nil
  self.LongAddList = nil
  self.dropListCount = nil
  self.canFreshTime = nil
  self.maxFreshTime = nil
  self.finishDailyTaskNum = nil
  self.maxCanFinishDailyTaskNum = nil
  self.nowHasTask = nil
  self.canAcceptTask = nil
  self.currentTaskData = nil
  self.currentStep = nil
  self.stepStr = nil
  self.npcData = nil
  self:ReleaseCtrlTable(self.leftTaskRoot, true)
  self.leftTaskRoot = nil
  self:ReleaseCtrlTable(self.dailyTargetItemList, true)
  self.dailyTargetItemList = nil
  self:ReleaseCtrlTable(self.capitalTargetItemList, true)
  self.capitalTargetItemList = nil
  self:ReleaseCtrlTable(self.completeTargetItemList, true)
  self.completeTargetItemList = nil
  self.rewardDataList = nil
  self:ReleaseCtrlTable(self.favorChangeList, true)
  self.favorChangeList = nil
  self:ReleaseCtrlTable(self.targetList, true)
  self.targetList = nil
  self.currentTaskItem = nil
  self.NpcList = nil
  self.NpcStateDic = nil
  self.allNPCList = nil
  self.listIndex = nil
  self.isAtQuestPage = nil
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.FreshDarkZoneTask, self.msgFunction)
  self.msgFunction = nil
  if self.ScreenItem then
    gfdestroy(self.ScreenItem.mUIRoot)
  end
  self.ScreenItem = nil
  for i = 1, #self.droplist do
    gfdestroy(self.droplist[i].obj)
    gfdestroy(self.droplist[i].obj.transform.parent.parent.gameObject)
  end
  self.droplist = nil
  self.isSell = nil
end
function UIDarkZoneStorePanel:OnRelease()
  self.super.OnRelease(self)
  self.hasCache = false
end
function UIDarkZoneStorePanel:EnterMisson()
  self.isAtQuestPage = true
  self.ui.mAnim_Root:SetInteger("Switch", 1)
  setactive(self.ui.mTrans_Store, false)
  setactive(self.ui.mTrans_Quest, true)
  self:GetUnLockNpc(0)
end
function UIDarkZoneStorePanel:EnterStore()
  self.isAtQuestPage = false
  self.ui.mAnim_Root:SetInteger("Switch", 0)
  setactive(self.ui.mTrans_Store, true)
  setactive(self.ui.mTrans_Quest, false)
  self.NpcIndex = 1
  for i = 1, #self.NpcList do
    local NpcData = self.NpcList[i]
    if self.Npc == NpcData.id then
      self.NpcIndex = i
      break
    end
  end
  self:UpdateNpc(0)
end
function UIDarkZoneStorePanel:InitBaseData()
  self.mview = UIDarkZoneStorePanelView.New()
  self.ui = {}
  self.ItemDataList = {}
  self.IsPanelOpen = false
  self.CurTab = 1
  self.NpcStoreItemDic = {}
  self.TabList = {}
  self.BuyItemList = {}
  self.SellItemList = {}
  self.Npc = 0
  self.ClickMultiSell = false
  self.SortWay = 1
  self.DZSellInfo = nil
  self.NpcFavor = 0
  self.IsAscend = false
  self.SellCanGetNum = 0
  self.FavorLevel = 1
  self.FavorExp = 0
  self.NextFavor = 0
  self.NpcIndex = 0
  self.IsSwitchLockByArrow = false
  self.NotSell = false
  self.SellItemScriptList = {}
  self.MultiSellList = {}
  self.BuyItemScriptList = {}
  self.LongAddList = {}
  self.dropListCount = 0
  self.canFreshTime = NetCmdItemData:GetItemCountById(CS.GF2.Data.TicketItemType.DarkzoneDailyRefresh.value__)
  self.maxFreshTime = TableData.GetPlayerMaxLimitById(CS.GF2.Data.TicketItemType.DarkzoneDailyRefresh.value__)
  self.finishDailyTaskNum = NetCmdItemData:GetItemCountById(CS.GF2.Data.TicketItemType.DarkzoneDailyFinish.value__)
  self.maxCanFinishDailyTaskNum = TableData.GetPlayerMaxLimitById(CS.GF2.Data.TicketItemType.DarkzoneDailyFinish.value__)
  self.nowHasTask = {0, 0}
  self.canAcceptTask = TableDataBase.GlobalDarkzoneData.QuestAcceptLimit
  self.leftTaskRoot = {}
  self.currentStep = 0
  self.stepStr = TableData.GetHintById(903232)
  self.dailyTargetItemList = {}
  self.capitalTargetItemList = {}
  self.completeTargetItemList = {}
  self.rewardDataList = {}
  self.favorChangeList = {}
  self.targetList = {}
  self.allNPCList = {}
  self.listIndex = 1
  self.isAtQuestPage = false
  self.currentTaskItem = nil
  self.NpcList = {}
  self.NpcStateDic = {}
  local list = {}
  for i = 0, TableData.listDarkzoneNpcDatas.Count - 1 do
    table.insert(list, TableData.listDarkzoneNpcDatas[i])
  end
  table.sort(list, function(a, b)
    if a == nil or b == nil then
      return false
    end
    if a.npc_sort < b.npc_sort then
      return true
    else
      return false
    end
  end)
  for i = 1, #list do
    table.insert(self.NpcList, list[i])
  end
  self.NpcStateDic = DZStoreUtils:UpdateNpcStateDic(list)
end
function UIDarkZoneStorePanel:AddBtnListen()
  UIUtils.GetButtonListener(self.ScreenItem.mBtn_Sort.gameObject).onClick = function()
    setactive(self.ui.mTrans_GrpScreenList, true)
    setactive(self.BlockHelper.gameObject, true)
  end
  UIUtils.GetButtonListener(self.ScreenItem.mBtn_Ascend.gameObject).onClick = function()
    self.IsAscend = not self.IsAscend
    self:UpdateSellData()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    self:CloseFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Quest.gameObject).onClick = function()
    self:EnterMisson()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Left.gameObject).onClick = function()
    if self.isAtQuestPage == false then
      self:UpdateNpc(-1)
    else
      self:GetUnLockNpc(-1)
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Right.gameObject).onClick = function()
    if self.isAtQuestPage == false then
      self:UpdateNpc(1)
    else
      self:GetUnLockNpc(1)
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Info.gameObject).onClick = function()
    UIManager.OpenUIByParam(UIDef.UIDarkzoneReliabilityDetailDialog, {
      [1] = self.NpcList,
      [2] = self.FavorLevel
    })
  end
  if self.hasCache ~= true then
    self.ui.mTrans_BtnFresh.onClick:AddListener(function()
      self:OnClickFreshBtn()
    end)
    self.ui.mTrans_BtnAccept.onClick:AddListener(function()
      self:AcceptQuestGroup()
    end)
    self.ui.mTrans_BtnAbandon.onClick:AddListener(function()
      DarkNetCmdStoreData:SendCS_DarkZoneGiveUpQuestGroup(self.currentTaskItem.mData.GroupId, function()
        CS.PopupMessageManager.PopupPositiveString(TableData.GetHintById(903324))
      end)
    end)
    self.ui.mTrans_BtnReceive.onClick:AddListener(function()
      DarkNetCmdStoreData:SendCS_DarkZoneTakeQuestReward(self.currentTaskItem.mData.GroupId)
    end)
    self.hasCache = true
  end
end
function UIDarkZoneStorePanel:UpdateNpc(nextIndex)
  nextIndex = nextIndex or 0
  self.NotSell = false
  self.NpcIndex = self.NpcIndex + nextIndex
  if self.NpcIndex < 1 then
    self.NpcIndex = 1
  elseif self.NpcIndex > #self.NpcList then
    self.NpcIndex = #self.NpcList
  end
  local NpcData = self.NpcList[self.NpcIndex]
  self.mData = NpcData
  self.Npc = NpcData.id
  DZStoreUtils.curNpcId = self.Npc
  self.IsNpcUnlock = self.NpcStateDic[self.Npc]
  self.ClickMultiSell = false
  if self.DZSellInfo ~= nil then
    ComPropsDetailsHelper:Close()
  end
  setactive(self.ui.mTrans_GrpBulkSale, false)
  self.ui.mImg_Chr.sprite = ResSys:GetAtlasSprite("DarkzoneAvatarPic/" .. self.mData.npc_img)
  self.ui.mText_Name.text = self.mData.name.str
  if self.IsNpcUnlock then
    setactive(self.TabList[1].ui.mTrans_Locked, false)
    setactive(self.TabList[2].ui.mTrans_Locked, false)
    self.TabList[1].ui.mBtn_ComTab1ItemV2.enabled = true
    self.TabList[2].ui.mBtn_ComTab1ItemV2.enabled = true
    self.IsSwitchLockByArrow = false
    setactive(self.ui.mBtn_Quest.gameObject, true)
    local NpcNetData = DarkNetCmdStoreData:GetNpcDataById(self.Npc)
    if NpcNetData == nil then
      self.FavorLevel, self.FavorExp, self.NextFavor = DZStoreUtils:GetCurFavorLevelAndExp(self.mData.id, 0)
      self.NpcFavor = 0
      self.ui.mText_Level.text = self.FavorLevel
      self.ui.mText_ExpNum.text = self.FavorExp .. "/" .. self.NextFavor
      self.ui.mSlider.FillAmount = self.FavorExp / self.NextFavor
      self.ui.mImg_Chr.color = ColorUtils.WhiteColor
    else
      self.FavorLevel, self.FavorExp, self.NextFavor = DZStoreUtils:GetCurFavorLevelAndExp(self.mData.id, NpcNetData.Favor)
      self.NpcFavor = NpcNetData.Favor
      self.ui.mText_Level.text = self.FavorLevel
      self.ui.mText_ExpNum.text = self.FavorExp .. "/" .. self.NextFavor
      self.ui.mSlider.FillAmount = self.FavorExp / self.NextFavor
      self.ui.mImg_Chr.color = ColorUtils.WhiteColor
    end
    self.ui.mBtn_MultiSell.interactable = true
  else
    setactive(self.TabList[1].ui.mTrans_Locked, true)
    setactive(self.TabList[2].ui.mTrans_Locked, false)
    self.TabList[1].ui.mBtn_ComTab1ItemV2.enabled = false
    self.TabList[2].ui.mBtn_ComTab1ItemV2.enabled = true
    self.IsSwitchLockByArrow = true
    self.CurTab = 2
    setactive(self.ui.mBtn_Quest.gameObject, false)
    local NpcNetData = DarkNetCmdStoreData:GetNpcDataById(self.mData.id)
    if NpcNetData == nil then
      self.FavorLevel, self.FavorExp, self.NextFavor = DZStoreUtils:GetCurFavorLevelAndExp(self.mData.id, 0)
      self.NpcFavor = 0
    else
      self.FavorLevel, self.FavorExp, self.NextFavor = DZStoreUtils:GetCurFavorLevelAndExp(self.mData.id, NpcNetData.Favor)
      self.NpcFavor = NpcNetData.Favor
    end
    self.ui.mText_Level.text = self.FavorLevel - 1
    self.ui.mText_ExpNum.text = self.FavorExp .. "/" .. self.NextFavor
    self.ui.mSlider.FillAmount = self.FavorExp / self.NextFavor
    self.ui.mImg_Chr.color = ColorUtils.GrayColor
    self.ui.mBtn_MultiSell.interactable = false
  end
  self.TabList[self.CurTab].callBack()
  setactive(self.ui.mBtn_Right.gameObject, self.NpcIndex < #self.NpcList)
  setactive(self.ui.mBtn_Left.gameObject, self.NpcIndex > 1)
  if 0 < nextIndex then
    self.ui.mAnim_Root:ResetTrigger("Next")
    self.ui.mAnim_Root:SetTrigger("Next")
  elseif nextIndex < 0 then
    self.ui.mAnim_Root:ResetTrigger("Previous")
    self.ui.mAnim_Root:SetTrigger("Previous")
  end
end
function UIDarkZoneStorePanel:InitData()
  for i = 1, 2 do
    local item = DZComTabItem.New()
    item:InitCtrl(self.ui.mTrans_GrpTabBtn)
    item:SetTable(self)
    if i == 2 then
      item:SetData(TableData.GetHintById(903154), 2)
      if self.IsNpcUnlock == false then
        self.CurTab = 1
        setactive(item.ui.mTrans_Locked, true)
        item.ui.mBtn_ComTab1ItemV2.enabled = false
      end
    elseif i == 1 then
      item:SetData(TableData.GetHintById(21), 1)
    end
    table.insert(self.TabList, item)
  end
  self.NpcStoreItemDic = {}
  local NPCId = 401
  local list = NetCmdStoreData:GetStoreGoodListByTag(NPCId)
  for i = 0, list.Count - 1 do
    if list[i]:GetStoreGoodData().goods_type ~= CS.GF2.Data.GoodsType.Darkzonelost then
      local data = {}
      data.id = list[i].id
      data.storeData = list[i]
      if self.NpcStoreItemDic[NPCId] == nil then
        self.NpcStoreItemDic[NPCId] = {}
      end
      table.insert(self.NpcStoreItemDic[NPCId], data)
    end
  end
  self.droplist = {}
  local obj = self:InstanceUIPrefab("UICommonFramework/ComScreenDropdownListItemV2.prefab", self.ui.mTrans_GrpScreenList)
  for i = 1, 1 do
    if obj then
      do
        local childparent = obj.transform:Find("Content")
        local childobj = self:InstanceUIPrefab("Character/ChrEquipSuitDropdownItemV2.prefab", childparent)
        local sort = {}
        sort.index = i
        sort.obj = childobj
        sort.btnself = UIUtils.GetButton(childobj)
        sort.txtName = UIUtils.GetText(childobj, "GrpText/Text_SuitName")
        sort.hintID = 903168 + i
        sort.txtName.text = TableData.GetHintById(sort.hintID)
        sort.grpset = childobj.transform:Find("GrpSel")
        UIUtils.GetButtonListener(sort.btnself.gameObject).onClick = function()
          self:OnClickDrop(i - 1)
        end
        self.textcolor = childobj.transform:GetComponent("TextImgColor")
        self.beforecolor = self.textcolor.BeforeSelected
        self.aftercolor = self.textcolor.AfterSelected
        if sort.index ~= self.SortWay then
          sort.txtName.color = self.textcolor.BeforeSelected
          setactive(sort.grpset, false)
        else
          sort.txtName.color = self.textcolor.AfterSelected
          setactive(sort.grpset, true)
        end
        table.insert(self.droplist, sort)
      end
    end
  end
  self.BlockHelper = UIUtils.GetUIBlockHelper(self.mview.mUIRoot, self.ui.mTrans_GrpScreenList, function()
    setactive(self.ui.mTrans_GrpScreenList, false)
  end)
  self.ui.mText_Name.text = self.mData.name.str
  self.ui.mImg_Chr.sprite = ResSys:GetAtlasSprite("DarkzoneAvatarPic/" .. self.mData.npc_img)
  self.ui.mImg_RightUpIcon.sprite = ResSys:GetAtlasSprite("Icon/Item/" .. TableData.listItemDatas:GetDataById(18).Icon)
  self.ui.mImg_BulkSaleIcon.sprite = ResSys:GetAtlasSprite("Icon/Item/" .. TableData.listItemDatas:GetDataById(18).Icon)
  UIUtils.GetButtonListener(self.ui.mBtn_MultiSell.gameObject).onClick = function()
    self:ActiveMultiSell()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_TodayPrice.gameObject).onClick = function()
    UIManager.OpenUI(UIDef.UIDarkZoneStoreQuoteDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Cancel.gameObject).onClick = function()
    for k, v in pairs(self.SellItemScriptList) do
      v:Release()
    end
    self:CancleSell()
    self:SetStateBack()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Sell.gameObject).onClick = function()
    self:OpenMultiSell()
  end
  self.MulitSellRedPoint = self.ui.mBtn_MultiSell.gameObject.transform:Find("Root/Trans_RedPoint")
  self.SellBt21RedPoint = self.ui.mBtn_TodayPrice.gameObject.transform:Find("Root/Trans_RedPoint")
  self.ScreenItem.mText_SortName.text = TableData.GetHintById(903169)
  for i = 1, #self.NpcList do
    if self.NpcList[i].id == self.Npc then
      self.NpcIndex = i
      break
    end
  end
  if self.NpcIndex == 1 then
    setactive(self.ui.mBtn_Left.gameObject, false)
  elseif self.NpcIndex == #self.NpcList then
    setactive(self.ui.mBtn_Right.gameObject, false)
  end
  local NpcData = self.NpcList[self.NpcIndex]
  self.mData = NpcData
  self.Npc = NpcData.id
  DZStoreUtils.curNpcId = self.Npc
end
function UIDarkZoneStorePanel:OnClickDrop(index)
  if index == 0 then
    self.SortWay = 1
    for i = 1, #self.droplist do
      if self.droplist[i].index ~= self.SortWay then
        self.droplist[i].txtName.color = self.textcolor.BeforeSelected
        setactive(self.droplist[i].grpset, false)
      else
        self.droplist[i].txtName.color = self.textcolor.AfterSelected
        setactive(self.droplist[i].grpset, true)
      end
    end
    setactive(self.ui.mTrans_GrpScreenList, false)
    setactive(self.ScreenItem.mBtn_Ascend.gameObject, false)
    self.ScreenItem.mText_SortName.text = TableData.GetHintById(903169)
    self:UpdateSellData()
  elseif index == 1 then
    self.SortWay = 2
    for i = 1, #self.droplist do
      if self.droplist[i].index ~= self.SortWay then
        self.droplist[i].txtName.color = self.textcolor.BeforeSelected
        setactive(self.droplist[i].grpset, false)
      else
        self.droplist[i].txtName.color = self.textcolor.AfterSelected
        setactive(self.droplist[i].grpset, true)
      end
    end
    setactive(self.ui.mTrans_GrpScreenList, false)
    setactive(self.ScreenItem.mBtn_Ascend.gameObject, false)
    self.ScreenItem.mText_SortName.text = TableData.GetHintById(903170)
    self:UpdateSellData()
  end
end
function UIDarkZoneStorePanel:UpdateBuyData()
  setactive(self.ui.mTrans_Sale, false)
  setactive(self.ui.mTrans_Buy, true)
  local list = self.NpcStoreItemDic[self.Npc]
  self.BuyItemList = {}
  for i, v in ipairs(list) do
    self.BuyItemList[i] = v
  end
  if DarkNetCmdStoreData.dropGood.Count > 0 then
    local dropList = DarkNetCmdStoreData.dropGood
    for i = 0, dropList.Count - 1 do
      local itemData = TableData.GetItemData(dropList[i].StcId)
      local goodData = NetCmdStoreData:GetStoreGoodById(itemData.goodsid)
      if goodData ~= nil then
        local data = {}
        data.id = dropList[i]
        data.storeData = goodData
        data.equipData = dropList[i]
        table.insert(self.BuyItemList, data)
      end
    end
    self.dropListCount = DarkNetCmdStoreData.dropGood.Count
  end
  if 0 < #list then
    table.sort(self.BuyItemList, function(a, b)
      if a == nil or b == nil then
        return false
      end
      if a == b then
        return false
      end
      if a.storeData:GetStoreGoodData().Sort == b.storeData:GetStoreGoodData().Sort then
        if a.storeData.id == b.storeData.id then
          return false
        end
        return a.storeData.id < b.storeData.id
      end
      return a.storeData:GetStoreGoodData().Sort < b.storeData:GetStoreGoodData().Sort
    end)
  end
  if self.ui.mBuyVirtualList.numItems ~= #self.BuyItemList then
    self.ui.mBuyVirtualList.numItems = #self.BuyItemList
  else
    self.ui.mBuyVirtualList:Refresh()
  end
  setactive(self.ui.mTrans_BuyEmpty, #self.BuyItemList == 0)
end
function UIDarkZoneStorePanel:UpdateSellData()
  if self.NotSell == true then
    return
  else
    setactive(self.ui.mTrans_Sale, true)
    setactive(self.ui.mTrans_Buy, false)
    local Revise = DarkNetCmdStoreData.Revise
    self.SellItemList = DarkNetCmdStoreData:ConstructList()
    local DZResourceslist = DarkNetCmdStoreData:StoreGetSortStorageList(2, 1, false)
    local DZCureList = DarkNetCmdStoreData:StoreGetSortStorageList(3, 1, false)
    local DZEquipList = DarkNetCmdStoreData:StoreGetSortStorageList(1, 1, false)
    for i = 0, DZResourceslist.Count - 1 do
      if DZResourceslist[i].ItemCount ~= 0 then
        local Kind = DZResourceslist[i].DarkZoneItemData.item_kind
        local BaseSellPrice = DZResourceslist[i].DarkZoneItemData.darkzone_price
        if Revise:ContainsKey(Kind) then
          local ration = Revise[Kind] / 1000
          if ration == 0 then
            ration = 1
          end
          DZResourceslist[i].SellPrice = math.floor(BaseSellPrice * ration)
        else
          DZResourceslist[i].SellPrice = BaseSellPrice
        end
        local favorAdd = DZResourceslist[i].DarkZoneItemData.darkzone_impression
        local NpcData = self.mData
        for k, v in pairs(NpcData.favor_item) do
          if k == Kind then
            favorAdd = favorAdd + v
            break
          end
        end
        DZResourceslist[i].NpcAddFavor = favorAdd
      end
    end
    for i = 0, DZCureList.Count - 1 do
      if DZCureList[i].ItemCount ~= 0 then
        local Kind = DZCureList[i].DarkZoneItemData.item_kind
        local BaseSellPrice = DZCureList[i].DarkZoneItemData.darkzone_price
        if Revise:ContainsKey(Kind) then
          local ration = Revise[Kind] / 1000
          if ration == 0 then
            ration = 1
          end
          DZCureList[i].SellPrice = math.floor(BaseSellPrice * ration)
        else
          DZCureList[i].SellPrice = BaseSellPrice
        end
        local favorAdd = DZCureList[i].DarkZoneItemData.darkzone_impression
        local NpcData = self.mData
        for k, v in pairs(NpcData.favor_item) do
          if k == Kind then
            favorAdd = favorAdd + v
            break
          end
        end
        DZCureList[i].NpcAddFavor = favorAdd
      end
    end
    for i = 0, DZEquipList.Count - 1 do
      if DZEquipList[i].ItemCount ~= 0 then
        local Kind = DZEquipList[i].DarkZoneItemData.item_kind
        local BaseSellPrice = DZEquipList[i].DarkZoneItemData.darkzone_price
        if Revise:ContainsKey(Kind) then
          local ration = Revise[Kind] / 1000
          if ration == 0 then
            ration = 1
          end
          DZEquipList[i].SellPrice = math.floor(BaseSellPrice * ration)
        else
          DZEquipList[i].SellPrice = BaseSellPrice
        end
        local favorAdd = DZEquipList[i].DarkZoneItemData.darkzone_impression
        local NpcData = self.mData
        for k, v in pairs(NpcData.favor_item) do
          if k == Kind then
            favorAdd = favorAdd + v
            break
          end
        end
        DZEquipList[i].NpcAddFavor = favorAdd
      end
    end
    DarkNetCmdStoreData:GetSortList(DZResourceslist, self.SortWay, self.IsAscend)
    DarkNetCmdStoreData:GetSortList(DZCureList, self.SortWay, self.IsAscend)
    DarkNetCmdStoreData:GetSortList(DZEquipList, self.SortWay, self.IsAscend)
    for i = 0, DZResourceslist.Count - 1 do
      self.SellItemList:Add(DZResourceslist[i])
    end
    for i = 0, DZCureList.Count - 1 do
      self.SellItemList:Add(DZCureList[i])
    end
    for i = 0, DZEquipList.Count - 1 do
      self.SellItemList:Add(DZEquipList[i])
    end
    DZStoreUtils.SellItemDataDic = {}
    for i = 0, self.SellItemList.Count - 1 do
      local data = {}
      data.ClickNum = 0
      DZStoreUtils.SellItemDataDic[i] = data
    end
    if DZEquipList.Count == 0 and DZCureList.Count == 0 and DZResourceslist.Count == 0 then
      setactive(self.ui.mTrans_SellEmpty, true)
      self.ui.mSellVirtualList:Refresh()
      self.ui.mSellVirtualList.numItems = self.SellItemList.Count
      setactive(self.ui.mBtn_MultiSell, self.SellItemList.Count ~= 0)
      return
    end
    self.SellItemScriptList = {}
    self.ui.mSellVirtualList.numItems = self.SellItemList.Count
    self.ui.mSellVirtualList:Refresh()
    setactive(self.ui.mBtn_MultiSell, self.SellItemList.Count ~= 0)
  end
end
function UIDarkZoneStorePanel:BuyItemProvider()
  local itemView = DZBuyItem.New()
  itemView:InitCtrl(self.ui.mTrans_BuyContent)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIDarkZoneStorePanel:BuyItemRenderer(index, renderData)
  local data = self.BuyItemList[index + 1]
  local item = renderData.data
  self.BuyItemScriptList[index] = item
  local panelData = {}
  panelData.Npc = self.Npc
  panelData.IsNpcUnlock = self.IsNpcUnlock
  item:SetData(data, panelData)
end
function UIDarkZoneStorePanel:SellItemProvider()
  local itemView = DZSellItem.New()
  itemView:InitCtrl(self.ui.mTrans_SellContent)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIDarkZoneStorePanel:SellItemRenderer(index, renderData)
  local data = self.SellItemList[index]
  local item = renderData.data
  self.SellItemScriptList[index + 1] = item
  item:SetTable(self)
  item:SetData(data, index)
end
function UIDarkZoneStorePanel:ActiveMultiSell()
  self.ui.mText_BulkSaleNum.text = 0
  setactive(self.ui.mTrans_GrpBulkSale, true)
  self.ClickMultiSell = true
  self.ui.mBtn_Sell.interactable = false
end
function UIDarkZoneStorePanel:ShowTodayPrice()
  UIManager.OpenUI(UIDef.UIDarkZoneStoreQuoteDialog)
end
function UIDarkZoneStorePanel:OpenMultiSell()
  UIManager.OpenUIByParam(UIDef.UIDarkZoneStoreMultiSellDialog, {
    [1] = self.MultiSellList,
    [2] = self
  })
end
function UIDarkZoneStorePanel:CancleSell()
  self.IsSetBack = true
  self.ClickMultiSell = false
  self.MultiSellList = {}
  setactive(self.ui.mTrans_GrpBulkSale, false)
  setactive(self.ui.mTrans_GrpDetailsLeft, false)
  self:UpdateSellData()
end
function UIDarkZoneStorePanel:FreshSellTotalPieceData()
  local TotalPrice = 0
  for k, v in pairs(self.MultiSellList) do
    local ItemNum = v.ItemNum
    local SellPrice = v.SellPrice
    TotalPrice = TotalPrice + ItemNum * SellPrice
  end
  self.ui.mText_BulkSaleNum.text = TotalPrice
  self.ui.mBtn_Sell.interactable = 0 < TotalPrice
end
function UIDarkZoneStorePanel:SetStateBack()
  for i = 0, self.ui.mTrans_SellContent.childCount - 1 do
    local child = self.ui.mTrans_SellContent:GetChild(i)
    local grpreduce = child:Find("Trans_GrpReduce")
    local grpchose = child:Find("Trans_GrpChoose")
    if grpreduce ~= nil then
      setactive(grpreduce, false)
    end
    if grpchose ~= nil then
      setactive(grpchose, false)
    end
    if DZStoreUtils.SellItemDataDic[i] ~= nil and DZStoreUtils.SellItemDataDic[i].ClickNum ~= nil then
      DZStoreUtils.SellItemDataDic[i].ClickNum = 0
    end
  end
end
function UIDarkZoneStorePanel:UpdateBuyItemList()
end
function UIDarkZoneStorePanel:SetItemListClick(canClick)
  if self.isSell == true then
    self.mCSPanel:Block()
    self.isSell = nil
  end
end
function UIDarkZoneStorePanel:InitNPCData(id)
  self.Npc = id
  DZStoreUtils.curNpcId = self.Npc
  self.npcData = TableData.listDarkzoneNpcDatas:GetDataById(id)
  self.ui.mImg_Chr.sprite = ResSys:GetAtlasSprite("DarkzoneAvatarPic/" .. self.npcData.npc_img)
end
function UIDarkZoneStorePanel:FreshNPCFavor()
  self.FavorLevel, self.FavorExp, self.NextFavor = DZStoreUtils:GetCurFavorLevelAndExp(self.mData.id, self.mNpcQuestData.Favor)
  self.ui.mText_Level.text = self.FavorLevel
  self.ui.mText_ExpNum.text = self.FavorExp .. "/" .. self.NextFavor
  self.ui.mSlider.FillAmount = self.FavorExp / self.NextFavor
end
function UIDarkZoneStorePanel:FreshTaskFreshTime()
  self.canFreshTime = NetCmdItemData:GetItemCountById(CS.GF2.Data.TicketItemType.DarkzoneDailyRefresh.value__)
  self.ui.mText_FreshNum.text = self.canFreshTime .. "/" .. self.maxFreshTime
end
function UIDarkZoneStorePanel:UpdateTaskList()
  if self.mNpcQuestData.QuestGroups then
    self:CloseListItem(self.dailyTargetItemList)
    self:CloseListItem(self.capitalTargetItemList)
    self:CloseListItem(self.completeTargetItemList)
    local taskDataList = {}
    taskDataList[0] = {}
    taskDataList[1] = {}
    taskDataList[2] = {}
    local allTaskList = TableData.listDarkzoneQuestGroupDatas:GetList()
    local serverTaskList
    if 1 < self.mNpcQuestData.QuestGroups.Count then
      serverTaskList = self.mNpcQuestData.QuestGroups[0].Groups
    else
      serverTaskList = nil
    end
    for i = 0, allTaskList.Count - 1 do
      local item = allTaskList[i]
      if item.NpcId == self.Npc and item.GroupType.value__ == 1 and serverTaskList ~= nil and not serverTaskList:ContainsKey(item.GroupId) then
        local isUnlock = self:CheckTaskIsUnLock(item)
        if isUnlock then
          local data = {}
          data.taskType = item.GroupType.value__ - 1
          data.isFinish = false
          data.taskData = TableData.listDarkzoneQuestStepDatas:GetDataById(item.FirstStep)
          data.GroupId = item.GroupId
          table.insert(taskDataList[data.taskType], data)
        end
      end
    end
    if 2 < self.mNpcQuestData.QuestGroups.Count then
      serverTaskList = self.mNpcQuestData.QuestGroups[1].Groups
    else
      serverTaskList = nil
    end
    if self.mNpcQuestData.TodayQuest and 0 < self.mNpcQuestData.TodayQuest and (serverTaskList == nil or not serverTaskList:ContainsKey(self.mNpcQuestData.TodayQuest)) then
      local tableData = TableData.listDarkzoneQuestGroupDatas:GetDataById(self.mNpcQuestData.TodayQuest)
      local data = {}
      data.taskType = tableData.GroupType.value__ - 1
      data.isFinish = false
      data.taskData = TableData.listDarkzoneQuestStepDatas:GetDataById(tableData.FirstStep)
      data.GroupId = tableData.GroupId
      table.insert(taskDataList[data.taskType], data)
    end
    for i = 0, self.mNpcQuestData.QuestGroups.Count - 1 do
      local list = self.mNpcQuestData.QuestGroups[i].Groups
      local itemList, itemRoot
      for m, n in pairs(list) do
        local stepList = n.Accepted
        local data
        for i = 0, stepList.Count - 1 do
          data = {}
          data.taskType = 2
          data.isFinish = true
          data.serverData = n
          local stepID = stepList[i]
          data.taskData = TableData.listDarkzoneQuestStepDatas:GetDataById(stepID)
          data.GroupId = m
          table.insert(taskDataList[data.taskType], data)
        end
        if n.Status.value__ ~= 2 then
          data = {}
          data.taskType = i
          data.isFinish = false
          data.serverData = n
          data.taskData = TableData.listDarkzoneQuestStepDatas:GetDataById(n.StepId)
          data.GroupId = m
          table.insert(taskDataList[data.taskType], data)
        end
      end
    end
    local itemList, itemRoot
    for i = 0, 2 do
      local taskItems = taskDataList[i]
      for j = 1, #taskItems do
        local taskItem = taskItems[j]
        if taskItem.taskType == 1 then
          itemList = self.dailyTargetItemList
          itemRoot = self.leftTaskRoot[1].ui.mTrans_Content
        elseif taskItem.taskType == 0 then
          itemList = self.capitalTargetItemList
          itemRoot = self.leftTaskRoot[2].ui.mTrans_Content
        elseif taskItem.taskType == 2 then
          itemList = self.completeTargetItemList
          itemRoot = self.leftTaskRoot[3].ui.mTrans_Content
        end
        if not itemList[j] then
          itemList[j] = self:CreateLeftTabItem(itemRoot)
        end
        local item = itemList[j]
        item:SetData(taskItem, function()
          self:FreshTaskDetail(item)
        end)
        if not self.currentTaskItem then
          self.currentTaskItem = item
        end
      end
    end
    self.leftTaskRoot[1]:OnClickBtn(#self.dailyTargetItemList > 0)
    self.leftTaskRoot[2]:OnClickBtn(#self.capitalTargetItemList > 0)
    self.leftTaskRoot[3]:OnClickBtn(false)
  end
end
function UIDarkZoneStorePanel:CloseListItem(list)
  if list then
    for i = 1, #list do
      list[i]:SetActive(false)
    end
  end
end
function UIDarkZoneStorePanel:CreateLeftTabItem(root)
  local item = DarkZoneTaskItem.New()
  item:InitCtrl(root)
  return item
end
function UIDarkZoneStorePanel:OnClickFreshBtn()
  if self.canFreshTime <= 0 then
    return
  end
  local f = function()
    CS.PopupMessageManager.PopupString(TableData.GetHintById(903241))
    self.canFreshTime = self.canFreshTime - 1
    self.ui.mText_FreshNum.text = self.canFreshTime .. "/" .. self.maxFreshTime
  end
  if self.currentTaskItem.mData.serverData and self.currentTaskItem.mData.serverData.Status.value__ == 1 then
    local msg = TableData.GetHintById(903238)
    MessageBoxPanel.ShowDoubleType(msg, function()
      DarkNetCmdStoreData:SendCS_DarkZoneRefreshDailyQuest(self.Npc, f)
    end)
  else
    DarkNetCmdStoreData:SendCS_DarkZoneRefreshDailyQuest(self.Npc, f)
  end
end
function UIDarkZoneStorePanel:FreshTaskDetail(item)
  if item and item.mData then
    if self.currentTaskItem then
      self.currentTaskItem.ui.mBtn_Self.interactable = true
    end
    local isFinish = item.mData.isFinish
    local data = item.mData.taskData
    local serverData = item.mData.serverData
    self.ui.mText_TaskStep.text = string_format(self.stepStr, item.stepNum)
    self.ui.mText_TaskName.text = TableData.listDarkzoneQuestGroupDatas:GetDataById(item.mData.GroupId).GroupName.str
    if self.targetList then
      for i = 1, #self.targetList do
        self.targetList[i]:CloseFunction()
      end
      local dataList
      if data.AndTaget.Count > 0 then
        dataList = data.AndTaget
      else
        dataList = data.OrTarget
      end
      for i = 0, dataList.Count - 1 do
        if not self.targetList[i + 1] then
          self.targetList[i + 1] = DarkZoneTargetItem.New()
          local obj
          obj = instantiate(self.ui.mTrans_GrpTargetItem.gameObject)
          setactive(obj, true)
          self.targetList[i + 1]:InitCtrl(self.ui.mTrans_GrpTargetContent, obj)
        end
        self.targetList[i + 1]:SetData(dataList[i], serverData, isFinish, i + 1)
      end
      setactive(self.ui.mTrans_GrpTargetItem.gameObject, false)
    end
    if self.favorChangeList then
      local reward = data.FavorChange
      for i = 1, #self.favorChangeList do
        self.favorChangeList[i]:SetActive(false)
      end
      local index = 1
      for itemId, num in pairs(reward) do
        if self.Npc == itemId then
          self.ui.mImg_NPCIcon.sprite = ResSys:GetAtlasSprite("DarkzoneAvatarPic/" .. self.npcData.npc_head_img .. "_G")
          self.ui.mText_NPCName.text = self.npcData.name.str
          local str
          if 0 < num then
            str = "+" .. tostring(num)
            self.ui.mText_NPCTrustNum.color = ColorUtils.BlueColor2
          else
            str = tostring(num)
            self.ui.mText_NPCTrustNum.color = ColorUtils.RedColor
          end
          self.ui.mText_NPCTrustNum.text = str
        else
          if not self.favorChangeList[index] then
            self.favorChangeList[index] = DarkZoneFavorItem.New()
            local obj
            obj = instantiate(self.ui.mTrans_GrpTrustItem.gameObject)
            setactive(obj, true)
            self.favorChangeList[index]:InitCtrl(self.ui.mTrans_GrpTrustContent, obj)
          end
          local itemView = self.favorChangeList[index]
          itemView:SetData(itemId, num, index)
          index = index + 1
        end
        setactive(self.ui.mTrans_GrpTrustItem.gameObject, false)
      end
    end
    self.rewardDataList = {}
    local reward = data.StepReward
    for itemId, num in pairs(reward) do
      local rewardData = {}
      rewardData.itemId = itemId
      rewardData.num = num
      table.insert(self.rewardDataList, rewardData)
    end
    self.ui.mText_Description.text = data.step_desc.str
    self:UpdateRewardList()
    item.ui.mBtn_Self.interactable = false
    self.currentTaskItem = item
    self:FreshTaskState()
    setactive(self.ui.mTrans_RefreshNumRoot, item.mData.taskType == 1)
    setactive(self.ui.mTrans_BtnFresh, item.mData.taskType == 1)
  end
end
function UIDarkZoneStorePanel:FreshTaskData(msg)
  if self.isAtQuestPage == false then
    return
  end
  local type = msg.Sender
  local serverData = DarkNetCmdStoreData:GetQuestDataByNPCIdAndGroupID(self.Npc, self.currentTaskItem.mData.GroupId)
  if serverData then
    self.currentTaskItem.mData.serverData = serverData
    self.currentTaskItem:FreshServeData()
  end
  if type == 3 then
    CS.PopupMessageManager.PopupString(TableData.GetHintById(903249))
    if self.mNpcQuestData.TodayQuest and self.mNpcQuestData.TodayQuest > 0 then
      local serverTaskList = self.mNpcQuestData.QuestGroups[0].Groups
      local data = {}
      local tableData = TableData.listDarkzoneQuestGroupDatas:GetDataById(self.mNpcQuestData.TodayQuest)
      data.taskType = tableData.GroupType.value__ - 1
      data.isFinish = false
      data.taskData = TableData.listDarkzoneQuestStepDatas:GetDataById(tableData.FirstStep)
      data.GroupId = tableData.GroupId
      if serverTaskList:ContainsKey(self.mNpcQuestData.TodayQuest) then
        data.serverData = serverTaskList[self.mNpcQuestData.TodayQuest]
      end
      self.currentTaskItem:SetData(data)
    end
    self:FreshTask()
  elseif type == 4 then
    local n = self.currentTaskItem.mData.serverData
    local t = self.currentTaskItem.mData.taskType + 1
    self.nowHasTask[t] = self.nowHasTask[t] - 1
    if t == 2 then
      self.finishDailyTaskNum = self.finishDailyTaskNum - 1
    end
    self:GetUnLockNpc(0)
  elseif type == 5 then
    self:FreshTask()
  else
    local n = self.currentTaskItem.mData.serverData
    local t = self.currentTaskItem.mData.taskType + 1
    if n.Status.value__ == 1 then
      self.nowHasTask[t] = self.nowHasTask[t] + 1
    elseif n.Status.value__ == 0 then
      self.nowHasTask[t] = self.nowHasTask[t] - 1
    end
    self:FreshTaskState()
  end
end
function UIDarkZoneStorePanel:FreshTask()
  self:FreshTaskDetail(self.currentTaskItem)
end
function UIDarkZoneStorePanel:FreshTaskState()
  if self.currentTaskItem then
    local data = self.currentTaskItem.mData
    local hasAccept = data.serverData ~= nil and data.serverData.Status.value__ == 1
    setactive(self.ui.mTrans_BtnAccept.transform.parent, not hasAccept and data.isFinish == false)
    setactive(self.ui.mTrans_BtnAbandon.transform.parent.parent, hasAccept and data.isFinish == false and data.canReceive ~= true)
    setactive(self.ui.mTrans_BtnReceive.transform.parent, data.canReceive == true and data.isFinish == false)
    setactive(self.ui.mTrans_Receive, data.isFinish == true)
  end
end
function UIDarkZoneStorePanel:AcceptQuestGroup()
  if self.currentTaskItem then
    local t = self.currentTaskItem.mData.taskType + 1
    if self.nowHasTask[t] >= self.canAcceptTask[t] then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(903246))
      return
    end
    if self.currentTaskItem.mData.taskType == 1 and self.finishDailyTaskNum <= 0 then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(903325))
      return
    end
    DarkNetCmdStoreData:SendCS_DarkZoneAcceptQuestGroup(self.currentTaskItem.mData.GroupId, function()
      CS.PopupMessageManager.PopupPositiveString(TableData.GetHintById(903323))
    end)
  end
end
function UIDarkZoneStorePanel:EnterNpcSelect(NPCId)
  if self.isAtQuestPage == false then
    return
  end
  if self.currentTaskItem then
    self.currentTaskItem.ui.mBtn_Self.interactable = true
  end
  self.currentTaskItem = nil
  self.mNpcQuestData = DarkNetCmdStoreData:GetNpcDataById(NPCId, true)
  self:InitNPCData(self.mNpcQuestData.Id)
  self:UpdateTaskList()
  self:FreshTask()
  self:FreshNPCFavor()
  self:FreshTaskFreshTime()
end
function UIDarkZoneStorePanel:GetAllUnLockNpc()
  for i = 1, #self.NpcList do
    local data = self.NpcList[i]
    local IsNpcUnlock = self.NpcStateDic[data.id]
    if IsNpcUnlock then
      table.insert(self.allNPCList, data.id)
    end
  end
end
function UIDarkZoneStorePanel:GetUnLockNpc(changeIndex)
  self.nowHasTask = {0, 0}
  for i = 1, #self.allNPCList do
    local data = DarkNetCmdStoreData:GetNpcDataById(self.allNPCList[i], true)
    for i = 0, data.QuestGroups.Count - 1 do
      local list = data.QuestGroups[i].Groups
      for m, n in pairs(list) do
        if n.Status.value__ == 1 then
          local t = i + 1
          self.nowHasTask[t] = self.nowHasTask[t] + 1
        end
      end
    end
  end
  self.listIndex = self.listIndex + changeIndex
  if 1 > self.listIndex then
    self.listIndex = 1
  elseif self.listIndex > #self.allNPCList then
    self.listIndex = #self.allNPCList
  end
  setactive(self.ui.mBtn_Left, self.listIndex ~= 1)
  setactive(self.ui.mBtn_Right, self.listIndex ~= #self.allNPCList)
  local id = self.allNPCList[self.listIndex]
  self:EnterNpcSelect(id)
  if 0 < changeIndex then
    self.ui.mAnim_Root:ResetTrigger("Next")
    self.ui.mAnim_Root:SetTrigger("Next")
  elseif changeIndex < 0 then
    self.ui.mAnim_Root:ResetTrigger("Previous")
    self.ui.mAnim_Root:SetTrigger("Previous")
  end
end
function UIDarkZoneStorePanel:ItemProvider()
  local itemView = UICommonItem.New()
  itemView:InitCtrl()
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView.mUIRoot.gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIDarkZoneStorePanel:ItemRenderer(index, renderDataItem)
  local itemData = self.rewardDataList[index + 1]
  local item = renderDataItem.data
  item:SetItemData(itemData.itemId, itemData.num)
end
function UIDarkZoneStorePanel:UpdateRewardList()
  self.ui.mVirtualList.numItems = #self.rewardDataList
  self.ui.mVirtualList:Refresh()
end
function UIDarkZoneStorePanel:CheckTaskIsUnLock(task)
  local args = task.UnlockArgs
  if task.UnlockType.value__ == 1 then
    local taskList
    if self.mNpcQuestData.QuestGroups.Count >= task.GroupType.value__ then
      taskList = self.mNpcQuestData.QuestGroups[task.GroupType.value__ - 1].Groups
    end
    for i = 0, args.Count - 1 do
      local taskID = args[i]
      if taskList ~= nil and taskList:ContainsKey(taskID) and taskList[taskID].Status.value__ == 2 then
        return true
      end
    end
    return false
  elseif task.UnlockType.value__ == 2 then
    for i = 0, args.Count - 1, 2 do
      local npcID = args[i]
      local limitNum = args[i + 1]
      local npcData = DarkNetCmdStoreData:GetNpcDataById(npcID, true)
      if limitNum > npcData.Favor then
        return false
      end
    end
    return true
  elseif task.UnlockType.value__ == 3 then
    return true
  else
    return true
  end
end
