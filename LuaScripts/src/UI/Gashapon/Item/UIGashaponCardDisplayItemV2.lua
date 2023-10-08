require("UI.UIBaseCtrl")
require("UI.Common.UICommonItem")
UIGashaponCardDisplayItemV2 = class("UIGashaponCardDisplayItemV2", UIBaseCtrl)
UIGashaponCardDisplayItemV2.__index = UIGashaponCardDisplayItemV2
UIGashaponCardDisplayItemV2.mImg_Chr = nil
UIGashaponCardDisplayItemV2.mImg_Weapon = nil
UIGashaponCardDisplayItemV2.mImg_QualityFrame = nil
UIGashaponCardDisplayItemV2.mImage_Glow = nil
UIGashaponCardDisplayItemV2.mText_New = nil
UIGashaponCardDisplayItemV2.mTrans_Character = nil
UIGashaponCardDisplayItemV2.mTrans_Weapon = nil
UIGashaponCardDisplayItemV2.mImage_ElementBg = nil
UIGashaponCardDisplayItemV2.mTrans_NewTag = nil
UIGashaponCardDisplayItemV2.mTrans_Again = nil
function UIGashaponCardDisplayItemV2:__InitCtrl()
end
function UIGashaponCardDisplayItemV2:InitCtrl(parent, index)
  self.index = index
  local instObj = instantiate(UIUtils.GetGizmosPrefab("Gashapon/GashaponCardDisplayItem.prefab", self), parent)
  self:SetRoot(instObj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self:__InitCtrl()
  local elementObj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComElementItemV2.prefab", self))
  self.ui.mTrans_IconElement = self:GetRectTransform("Root/Trans_GrpElement/GrpElement")
  CS.LuaUIUtils.SetParent(elementObj, self.ui.mTrans_IconElement.gameObject, true)
  self.ui.mImg_ElementIcon = UIUtils.GetImage(elementObj, "Image_ElementIcon")
  local dutyObj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComDutyItemV2.prefab", self))
  self:GetRectTransform("Root/GrpItem/GrpIcon/Trans_GrpDuty/GrpDuty")
  self.ui.mTrans_IconDuty = self:GetRectTransform("Root/GrpDuty")
  self.ui.mImg_DutyIcon = UIUtils.GetImage(dutyObj, "Img_DutyIcon")
  CS.LuaUIUtils.SetParent(dutyObj, self.ui.mTrans_IconDuty.gameObject, true)
end
function UIGashaponCardDisplayItemV2:InitData(data)
  self.mData = data
  self.mStcData = TableData.GetItemData(data.ItemId)
  if self.mStcData == nil then
    gferror("没有找到id是" .. data.ItemId .. "的道具")
  else
    self:InitItemInfo()
  end
end
function UIGashaponCardDisplayItemV2:InitItemInfo()
  local name = self.mStcData.name
  local icon = self.mStcData.icon
  local rank = TableData.GlobalSystemData.QualityStar[self.mStcData.rank - 1]
  if self.mStcData.type == GlobalConfig.ItemType.GunType then
    local gunData = TableData.GetGunData(tonumber(self.mStcData.args[0]))
    self.ui.mImg_Character.sprite = IconUtils.GetCharacterGachaSprite(gunData.code)
    setactive(self.ui.mTrans_Character, true)
    setactive(self.ui.mTrans_Weapon, false)
  elseif self.mStcData.type == GlobalConfig.ItemType.Weapon then
    self.ui.mImg_Weapon.sprite = IconUtils.GetWeaponNormalSprite(icon)
    setactive(self.ui.mTrans_Character, false)
    setactive(self.ui.mTrans_Weapon, true)
  else
    gfwarning("Invalid type !!!!!!!!!!!!!!!" .. self.mStcData.type)
  end
  local rankColor = TableData.GetGlobalGun_Quality_Color2(rank)
  self.rank = rank
  self.ui.animator:SetInteger("Color", self.mStcData.rank)
  self:ConvertChipAnim()
  if 0 < self.mData.OverflowNum then
    CS.PopupMessageManager.PopupDownLeftTips(self.mStcData.id, 10)
  end
end
function UIGashaponCardDisplayItemV2:SetColor(rank)
  self.ui.animator:SetInteger("Color", rank)
end
function UIGashaponCardDisplayItemV2:ConvertChipAnim()
  if self.mData.ItemNum == 0 then
    setactive(self.ui.mTrans_Again, true)
    setactive(self.ui.mTrans_NewTag, false)
    local sort = self.mData.ExtItems.orderBy
    local transId = 0
    local transNum = 0
    for key, value in pairs(self.mData.TranItems) do
      transId = key
      transNum = value
    end
    for key, value in pairs(self.mData.ExtItems) do
      local consumeItem = UICommonItem.New()
      consumeItem:InitCtrl(self.ui.mTrans_AgainItem)
      consumeItem:SetItemData(key, value, false)
      if transId ~= 0 then
        self.timerPhase1 = TimerSys:DelayCall(2 + 0.15 * (self.index - 1), function()
          if consumeItem ~= nil and self.timerPhase1 ~= nil then
            local ani = consumeItem:GetRoot():GetComponent(typeof(CS.UnityEngine.Animator))
            if ani ~= nil then
              ani:SetTrigger("FadeIn")
            end
            local fxTrans = consumeItem:GetRoot():Find("GashaponCardDisplayItem_Conversion")
            if fxTrans ~= nil then
              setactive(fxTrans, false)
              setactive(fxTrans, true)
            end
          end
        end)
        self.timerPhase2 = TimerSys:DelayCall(3.1 + 0.15 * (self.index - 1), function()
          if consumeItem ~= nil and self.timerPhase2 ~= nil then
            consumeItem:SetItemData(transId, transNum, false)
          end
        end)
      end
    end
    if self.mStcData.type ~= GlobalConfig.ItemType.Weapon then
      local id = self.mStcData.Args[0]
      local gunData = TableData.listGunDatas:GetDataById(id)
      local dutyData = TableData.listGunDutyDatas:GetDataById(gunData.duty)
      setactive(self.ui.mTrans_GrpDuty, true)
      self.ui.mImg_DutyIcon.sprite = IconUtils.GetGunTypeSprite(dutyData.icon)
      setactive(self.ui.mTrans_GrpElement, false)
      local elementData = TableData.listLanguageElementDatas:GetDataById(gunData.attack_type)
      self.ui.mImg_ElementIcon.sprite = IconUtils.GetElementIcon(elementData.icon)
    else
      setactive(self.ui.mTrans_GrpDuty, false)
      setactive(self.ui.mTrans_GrpElement, false)
      setactive(self.ui.mTrans_Again, false)
      setactive(self.ui.mTrans_GrpElement, false)
    end
  else
    setactive(self.ui.mTrans_Again, false)
    setactive(self.ui.mTrans_NewTag, true)
    local id = self.mStcData.Args[0]
    if self.mStcData.type ~= GlobalConfig.ItemType.Weapon then
      local gunData = TableData.listGunDatas:GetDataById(id)
      local dutyData = TableData.listGunDutyDatas:GetDataById(gunData.duty)
      setactive(self.ui.mTrans_GrpDuty, true)
      self.ui.mImg_DutyIcon.sprite = IconUtils.GetGunTypeSprite(dutyData.icon)
      setactive(self.ui.mTrans_GrpElement, false)
      local elementData = TableData.listLanguageElementDatas:GetDataById(gunData.attack_type)
      self.ui.mImg_ElementIcon.sprite = IconUtils.GetElementIcon(elementData.icon)
    else
      local weaponData = TableData.listGunWeaponDatas:GetDataById(id)
      setactive(self.ui.mTrans_NewTag, NetCmdIllustrationData:CheckItemIsFirstTime(self.mStcData.type, weaponData.id, true))
      setactive(self.ui.mTrans_GrpDuty, false)
      setactive(self.ui.mTrans_GrpElement, false)
    end
  end
end
function UIGashaponCardDisplayItemV2:SetIndex(index)
  self.ui.mIndex = index
end
function UIGashaponCardDisplayItemV2:StopTimer()
  if self.timer ~= nil then
    self.timer:Stop()
  end
  self.timer = nil
  if self.delayCall ~= nil then
    self.delayCall:Stop()
  end
  self.delayCall = nil
  if self.timerPhase1 ~= nil then
    self.timerPhase1:Stop()
  end
  self.timerPhase1 = nil
  if self.timerPhase2 ~= nil then
    self.timerPhase2:Stop()
  end
  self.timerPhase2 = nil
end
