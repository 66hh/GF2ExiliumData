require("UI.Tips.TipsManager")
require("UI.UIBaseCtrl")
ResourcesCommonItem = class("ResourcesCommonItem", UIBaseCtrl)
ResourcesCommonItem.__index = ResourcesCommonItem
function ResourcesCommonItem:ctor()
  self.itemID = 0
  self.switchID = 0
end
function ResourcesCommonItem:__InitCtrl()
end
function ResourcesCommonItem:InitCtrl(parent, isCommandCenter, resObj)
  local obj
  if resObj ~= nil then
    obj = resObj
  elseif isCommandCenter then
    obj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComBtnCurrencyItem_B.prefab", self))
  else
    obj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComBtnCurrencyItem_W.prefab", self))
  end
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self:__InitCtrl()
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, false)
  end
end
function ResourcesCommonItem:InitCtrlWithObj(obj)
  if obj == nil then
    return
  end
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self:__InitCtrl()
end
function ResourcesCommonItem:OnShow(isCommandCenter)
  if self.ui.mAnimator ~= nil and isCommandCenter ~= nil and isCommandCenter == true then
    self.ui.mAnimator:SetBool("CommandCenterW", false)
  elseif self.ui.mAnimator ~= nil then
    self.ui.mAnimator:SetBool("CommandCenterW", true)
  end
  self:UpdateData(self.paramData)
end
function ResourcesCommonItem:OnRelease()
  self:DestroySelf()
end
function ResourcesCommonItem:OnUpdate()
  self:UpdateStaminaData()
end
function ResourcesCommonItem:UpdateDarkIcon(num)
  local id = GlobalConfig.DZCoinId
  self.ui.mImage_ResourceIcon.sprite = IconUtils.GetItemIconSprite(id)
  setactive(self.ui.mTrans_Right.gameObject, false)
  local itemData = TableData.GetItemData(id)
  self.ui.mText_Num.text = num
  TipsManager.Add(self.ui.mBtn_SelfButton.gameObject, itemData, count, false, itemData.type == 6, nil, nil, nil, nil, true)
end
function ResourcesCommonItem:SetData(itemData, paramData)
  self.itemID = itemData.id
  self.switchID = itemData.jumpID
  self.jumpParam = itemData.param
  self.ui.mImage_ResourceIcon.sprite = IconUtils.GetItemIconSprite(self.itemID)
  setactivewithcheck(self.ui.mTrans_Right.gameObject, self.switchID ~= nil)
  if self.switchID then
    local jumpData = TableData.listJumpListContentnewDatas:GetDataById(self.switchID)
    local contentUnlockNum = jumpData.unlock_id
    local contentIsLock = false
    if 0 < contentUnlockNum then
      contentIsLock = not AccountNetCmdHandler:CheckSystemIsUnLock(contentUnlockNum)
    end
    setactive(self.ui.mBtn_Plus, not contentIsLock)
    UIUtils.GetButtonListener(self.ui.mBtn_Plus.gameObject).onClick = function()
      self:OnAddResBtnClicked()
    end
  end
  self.paramData = paramData
  self:UpdateData(paramData)
end
function ResourcesCommonItem:UpdateData(paramData)
  local itemData = TableData.GetItemData(self.itemID)
  local count = 0
  if itemData then
    count = NetCmdItemData:GetItemCountById(self.itemID)
  end
  if self.itemID == 9 then
    self.ui.mText_Num.text = count .. "/" .. TableData.GlobalConfigData.SimtrainingTimes
  elseif itemData.type == GlobalConfig.ItemType.StaminaType then
    self.ui.mText_Num.text = count .. "/" .. GlobalData.GetStaminaResourceMaxNum(self.itemID)
    if self.switchID ~= nil and self.switchID ~= 0 then
      local jumpData = TableData.listJumpListContentnewDatas:GetDataById(self.switchID)
      local behaviorData = TableData.listJumpBehaviorDatas:GetDataById(jumpData.behavior)
      if behaviorData ~= nil then
        local unlockId = behaviorData.unlock_id
        if unlockId ~= nil and unlockId ~= 0 and not AccountNetCmdHandler:CheckSystemIsUnLock(unlockId) then
          setactive(self.ui.mTrans_Right, false)
        end
      end
    end
  elseif self.itemID == NetCmdSimulateBattleData:GetWeeklyBCostItemId() then
    local maxLimit = TableData.listItemLimitDatas:GetDataById(self.itemID)
    local maxCount = 1
    if maxLimit then
      maxCount = maxLimit.init_num
    end
    self.ui.mText_Num.text = count .. "/" .. maxCount
  else
    local strCount = self.ChangeNumDigit(tonumber(count))
    self.ui.mText_Num.text = strCount
  end
  local needShowGetWay = self.itemID == GlobalConfig.StaminaId or self.itemID == GlobalConfig.LotteryMachine
  if paramData ~= nil then
    TipsManager.Add(self.ui.mBtn_SelfButton.gameObject, itemData, count, needShowGetWay, itemData.type == 6, nil, paramData[1], paramData[2], nil, true)
  else
    TipsManager.Add(self.ui.mBtn_SelfButton.gameObject, itemData, count, needShowGetWay, itemData.type == 6, nil, nil, nil, nil, true)
  end
end
function ResourcesCommonItem:UpdateStaminaData()
  local itemData = TableData.GetItemData(self.itemID)
  if itemData.type == GlobalConfig.ItemType.StaminaType then
    local count = GlobalData.GetStaminaResourceItemCount(self.itemID)
    self.ui.mText_Num.text = count .. "/" .. GlobalData.GetStaminaResourceMaxNum(self.itemID)
  end
end
function ResourcesCommonItem:OnAddResBtnClicked()
  if self.itemID == GlobalConfig.StaminaId then
    UIManager.OpenUIByParam(UIDef.UICommonGetPanel)
  else
    SceneSwitch:SwitchByID(self.switchID)
  end
end
function ResourcesCommonItem:UpdateNum(num)
  self.ui.mText_Num.text = num
end
function ResourcesCommonItem.ChangeNumDigit(num)
  if type(num) ~= "number" then
    gfdebug("类型传输错误，返回默认值，请检查道具" .. self.itemID)
    return "0"
  end
  local hint
  if num < 1000000.0 then
    return num
  elseif 1000000.0 <= num and num < 1.0E7 then
    hint = TableData.GetHintById(901062)
    return string_format(hint, math.modf(num / 1000.0))
  elseif 1.0E7 <= num and num < 1.0E10 then
    hint = TableData.GetHintById(901063)
    return string_format(hint, math.modf(num / 1000000.0))
  elseif 1.0E10 <= num and num < 1.0E13 then
    hint = TableData.GetHintById(901064)
    return string_format(hint, math.modf(num / 1.0E9))
  else
    return num
  end
end
