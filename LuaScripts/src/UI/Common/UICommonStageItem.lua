require("UI.UIBaseCtrl")
UICommonStageItem = class("UICommonStageItem", UIBaseCtrl)
UICommonStageItem.__index = UICommonStageItem
function UICommonStageItem:ctor(maxNum)
  self.maxNum = maxNum
  self.stageList = {}
end
function UICommonStageItem:__InitCtrl()
  for i = 1, GlobalConfig.MaxStar do
    local stage = {}
    local obj = self:GetRectTransform("GrpStage" .. i)
    stage.obj = obj
    stage.transOn = UIUtils.GetRectTransform(obj, "Trans_On")
    stage.effect = nil
    stage.timer = nil
    stage.timer2 = nil
    setactive(stage.obj, i <= self.maxNum)
    table.insert(self.stageList, stage)
  end
end
function UICommonStageItem:InitCtrl(parent, useScrollListChild)
  local obj
  if useScrollListChild then
    local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
    obj = instantiate(itemPrefab.childItem)
  else
    obj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComStageItemV2.prefab", self))
  end
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, true)
  end
  self:SetRoot(obj.transform)
  self:__InitCtrl()
end
function UICommonStageItem:SetData(stageNum)
  local num = math.min(stageNum, self.maxNum)
  for i, stage in ipairs(self.stageList) do
    setactive(stage.transOn, i <= num)
  end
end
function UICommonStageItem:ResetMaxNum(maxNum)
  self.maxNum = maxNum
  for i, stage in ipairs(self.stageList) do
    setactive(stage.obj, i <= self.maxNum)
  end
end
function UICommonStageItem:SetEffect(num, delay, delay2)
  if num <= self.maxNum then
    local stage = self.stageList[num]
    stage.effect = ResSys:GetUIRes("Character/Res/Effect/UI_ChrOverview_GrpStage_On.prefab", true)
    CS.LuaUIUtils.SetParent(stage.effect.gameObject, stage.obj.gameObject)
    setactive(stage.transOn, false)
    setactive(stage.effect.gameObject, delay == nil)
    if 0 < delay then
      if stage.timer then
        stage.timer:Stop()
        stage.timer = nil
      end
      stage.timer = TimerSys:DelayCall(delay, function()
        setactive(stage.effect, true)
      end)
    else
      setactive(stage.effect, true)
    end
    if 0 < delay2 then
      if stage.timer2 then
        stage.timer2:Stop()
        stage.timer2 = nil
      end
      stage.timer2 = TimerSys:DelayCall(delay2, function()
        setactive(stage.transOn, true)
      end)
    else
      setactive(stage.transOn, true)
    end
  end
end
function UICommonStageItem:SetWeaponEffect(lastBreakTimes, stageNum, delay, delay2)
  lastBreakTimes = math.max(lastBreakTimes, 0)
  stageNum = math.min(stageNum, self.maxNum)
  for i, stage in ipairs(self.stageList) do
    setactive(stage.transOn, i <= lastBreakTimes)
  end
  lastBreakTimes = math.max(lastBreakTimes, 1)
  for i = lastBreakTimes, stageNum do
    self:SetEffect(i, delay, delay2)
  end
end
function UICommonStageItem:OnRelease()
  self.super.OnRelease(self)
  for i, stage in ipairs(self.stageList) do
    if stage.timer then
      stage.timer:Stop()
      stage.timer = nil
    end
    if stage.timer2 then
      stage.timer2:Stop()
      stage.timer2 = nil
    end
    if stage.effect then
      ResourceManager:DestroyInstance(stage.effect)
    end
  end
end
