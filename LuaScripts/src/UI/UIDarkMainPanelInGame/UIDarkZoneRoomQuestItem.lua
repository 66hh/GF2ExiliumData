require("UI.UIBaseCtrl")
UIDarkZoneRoomQuestItem = class("UIDarkZoneRoomQuestItem", UIBaseCtrl)
function UIDarkZoneRoomQuestItem:ctor(go, template)
  self.ui = {}
  self:SetRoot(go)
  self:LuaUIBindTable(go, self.ui)
  self.targetList = {}
  setactive(self.ui.mTrans_Dot, false)
  self.ui.mAnimator_Extra.keepAnimatorControllerStateOnDisable = true
  function self.ui.mUIAutoChangeLayout_Layout.startAction()
    self:SetShow()
  end
  function self.ui.mUIAutoChangeLayout_Layout.finishAction()
    self:SetHide()
  end
  self.ui.mCanvasGroup_Layout.alpha = 0
  self.ui.mCanvasGroup_Layout.blocksRaycasts = false
  self.isFadeOut = false
end
function UIDarkZoneRoomQuestItem:SetData(roomID)
  self.showTarget = nil
  local mapList = DarkNetCmdStoreData:GetRoomQuestListByAreaID(roomID)
  self.mapList = mapList
  local showItem
  for i = 0, mapList.Count - 1 do
    local id = mapList[i]
    local isNotFinish = self:CheckQuestIsNotFinish(id)
    if isNotFinish and showItem == nil then
      showItem = id
    end
  end
  local f
  if 0 >= mapList.Count or showItem == nil then
    self:OnCloseSelf()
  else
    if self.needFadeOut ~= false or self.isFadeOut ~= false then
      if self.closeTimer then
        self.closeTimer:Stop()
        self.closeTimer = nil
      end
      function f()
        self.ui.mUIAutoChangeLayout_Layout:StartLayoutShow()
      end
    end
    if self.needClose == true then
      if self.timer then
        self.timer:Stop()
        self.timer = nil
      end
      self.needClose = false
      if self.lastRoomID ~= roomID then
        self.lastRoomID = roomID
        self:PlayFadeInAnim(2)
      end
    else
      function f()
        self.ui.mUIAutoChangeLayout_Layout:StartLayoutRefresh()
      end
      self:PlayFadeInAnim(2)
    end
  end
  if f then
    self:RefreshLayoutValue(f)
  end
  self.roomID = roomID
end
function UIDarkZoneRoomQuestItem:RefreshRoomItemShowData(mapList)
  self.showTarget = nil
  local listCount = mapList.Count
  if 0 < listCount then
    for i, v in ipairs(self.targetList) do
      v.mQuestID = nil
      setactive(v.mUIObj, false)
    end
    for i = 0, listCount - 1 do
      local id = mapList[i]
      local index = i + 1
      if not self.targetList[index] then
        self.targetList[index] = {}
        local item = self.targetList[index]
        item.ui = {}
        local obj = instantiate(self.ui.mTrans_Dot, self.ui.mTrans_DotIfo)
        item.mUIObj = obj
        UIUtils.OutUIBindTable(obj.transform, item.ui)
      end
      setactive(self.targetList[index].mUIObj, true)
      self.targetList[index].mQuestID = id
      local isNotFinish = self:CheckQuestIsNotFinish(id)
      setactive(self.targetList[index].ui.mTrans_Normal, isNotFinish == true)
      setactive(self.targetList[index].ui.mTrans_Finish, isNotFinish == false)
      if isNotFinish and self.showTarget == nil then
        local d = TableData.listDarkzoneRoomNoticeDatas:GetDataById(id, true)
        if d ~= nil then
          self.ui.mText_Target.text = d.text.str
        end
        self.showTarget = self.targetList[index]
      end
    end
  end
  if self.showTarget == nil then
    self:CloseFunction()
  else
    self.ui.mAnimator_Extra:SetInteger("Switch", 2)
  end
end
function UIDarkZoneRoomQuestItem:PlayFadeInAnim(animState)
  if self.playAnimTimer then
    self.playAnimTimer:Stop()
    self.playAnimTimer = nil
  end
  self.ui.mAnimator_Extra:SetInteger("Switch", 1)
  self.playAnimTimer = TimerSys:DelayFrameCall(3, function()
    self.ui.mAnimator_Extra:SetInteger("Switch", animState)
    if animState == 4 then
      self:DelayCall(1.6, function()
        self:RefreshRoomItemShowData(self.mapList)
      end)
    else
      self:RefreshRoomItemShowData(self.mapList)
    end
  end)
end
function UIDarkZoneRoomQuestItem:RefreshAnimState()
  for i, v in ipairs(self.targetList) do
    if v.mQuestID then
      local isNotFinish = self:CheckQuestIsNotFinish(v.mQuestID)
      setactive(v.ui.mTrans_Normal, isNotFinish == true)
      setactive(v.ui.mTrans_Finish, isNotFinish == false)
    end
  end
end
function UIDarkZoneRoomQuestItem:RefreshLayoutValue(callback)
  if self.frameTimer then
    self.frameTimer:Stop()
    self.frameTimer = nil
  end
  self.ui.mCanvasGroup_Layout.alpha = 0
  setactive(self.ui.mTrans_UIRoot, true)
  self:RefreshShowItem()
  setactive(self.ui.mTrans_DotIfo, self.mapList.Count > 1)
  self.frameTimer = TimerSys:DelayFrameCall(6, function()
    local h = self.ui.mTrans_UIRoot.rect.height
    self.ui.mUIAutoChangeLayout_Layout.mVerticalMaxValue = h
    self.ui.mCanvasGroup_Layout.alpha = 1
    if callback then
      callback()
    end
  end)
end
function UIDarkZoneRoomQuestItem:Refresh(questID)
  for i, v in ipairs(self.targetList) do
    if v.mQuestID and v.mQuestID == questID then
      local isNotFinish = self:CheckQuestIsNotFinish(v.mQuestID)
      setactive(v.ui.mTrans_Normal, isNotFinish == true)
      setactive(v.ui.mTrans_Finish, isNotFinish == false)
      if isNotFinish == false and self.showTarget == v then
        self:PlayFadeInAnim(4)
      end
    end
  end
end
function UIDarkZoneRoomQuestItem:RefreshShowItem()
  local showTarget
  local count = self.mapList.Count
  for i = 0, count - 1 do
    local v = self.mapList[i]
    local isNotFinish = self:CheckQuestIsNotFinish(v)
    if isNotFinish and showTarget == nil then
      local d = TableData.listDarkzoneRoomNoticeDatas:GetDataById(v, true)
      if d ~= nil then
        self.ui.mText_Target.text = d.text.str
      end
      showTarget = v
      break
    end
  end
end
function UIDarkZoneRoomQuestItem:CheckQuestIsNotFinish(questID)
  local curNum = 0
  local needNum = 1
  local countData = DarkNetCmdStoreData:GetCountByID(2, 0, questID)
  if countData and 0 < countData.Count then
    local d = countData[0]
    curNum = d.Num or 0
    needNum = d.NeedNum or 1
  end
  local isNotFinish = curNum < needNum
  return isNotFinish
end
function UIDarkZoneRoomQuestItem:OnCloseSelf()
  self.needClose = true
  self.lastRoomID = self.roomID
  self.timer = TimerSys:DelayCall(1, function()
    self:CloseFunction()
  end)
end
function UIDarkZoneRoomQuestItem:CloseFunction()
  if self.closeTimer then
    self.closeTimer:Stop()
    self.closeTimer = nil
  end
  self.ui.mAnimator_Extra:SetInteger("Switch", 1)
  self.needClose = false
  self.lastRoomID = nil
  self.needFadeOut = true
  self.closeTimer = TimerSys:DelayCall(0.4, function()
    self.ui.mUIAutoChangeLayout_Layout:StartLayoutHide()
  end)
end
function UIDarkZoneRoomQuestItem:SetShow()
  setactive(self.ui.mTrans_UIRoot, true)
  self.needFadeOut = false
  self.isFadeOut = false
end
function UIDarkZoneRoomQuestItem:SetHide()
  setactive(self.ui.mTrans_UIRoot, false)
  self.isFadeOut = true
  self.needFadeOut = false
end
function UIDarkZoneRoomQuestItem:OnRelease()
  for i, v in ipairs(self.targetList) do
    gfdestroy(v.mUIObj)
  end
  self.targetList = nil
  self.name = nil
  self.avatarSprite = nil
  self.lastRoomID = nil
  self.roomID = nil
  self.isFadeOut = nil
  self.needClose = nil
  self.closeTimer = nil
  self.timer = nil
  self.frameTimer = nil
  self:ReleaseTimers()
  self.super.OnRelease(self)
end
