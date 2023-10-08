require("UI.Tips.UIComAccessItem")
require("UI.UIBaseView")
require("UI.Common.UICommonPropertyItem")
require("UI.WeaponPanel.UIWeaponGlobal")
require("UI.FacilityBarrackPanel.FacilityBarrackGlobal")
UIComItemDetailsPanelV2View = class("UIComItemDetailsPanelV2View", UIBaseView)
UIComItemDetailsPanelV2View.__index = UIComItemDetailsPanelV2View
UIComItemDetailsPanelV2View.mBtn_Close = nil
UIComItemDetailsPanelV2View.mBtn_Close1 = nil
UIComItemDetailsPanelV2View.mImg_EquipIcon = nil
UIComItemDetailsPanelV2View.mImg_EquipIcon = nil
UIComItemDetailsPanelV2View.mImg_EquipLine = nil
UIComItemDetailsPanelV2View.mImg_IconIcon = nil
UIComItemDetailsPanelV2View.mImg_WeaponIcon = nil
UIComItemDetailsPanelV2View.mImg_WeaponLine = nil
UIComItemDetailsPanelV2View.mImg_WeaponPartsIcon = nil
UIComItemDetailsPanelV2View.mImg_WeaponPartsLine = nil
UIComItemDetailsPanelV2View.mImg_ItemIcon = nil
UIComItemDetailsPanelV2View.mImg_ItemLine = nil
UIComItemDetailsPanelV2View.mText_ = nil
UIComItemDetailsPanelV2View.mText_Name = nil
UIComItemDetailsPanelV2View.mText_EquipName = nil
UIComItemDetailsPanelV2View.mText_Name = nil
UIComItemDetailsPanelV2View.mText__Num = nil
UIComItemDetailsPanelV2View.mText_NumNow = nil
UIComItemDetailsPanelV2View.mText_NumAfter = nil
UIComItemDetailsPanelV2View.mText_WeaponName = nil
UIComItemDetailsPanelV2View.mText_WeaponName1 = nil
UIComItemDetailsPanelV2View.mText_WeaponPartsName = nil
UIComItemDetailsPanelV2View.mText_WeaponPartsName1 = nil
UIComItemDetailsPanelV2View.mText_WeaponPartsName2 = nil
UIComItemDetailsPanelV2View.mText__Description = nil
UIComItemDetailsPanelV2View.mText_ItemName = nil
UIComItemDetailsPanelV2View.mText_Description = nil
UIComItemDetailsPanelV2View.mText_ = nil
UIComItemDetailsPanelV2View.mText_NextTimeNum = nil
UIComItemDetailsPanelV2View.mText_NextTime_Time = nil
UIComItemDetailsPanelV2View.mText_AllTime_Num = nil
UIComItemDetailsPanelV2View.mText_AllTimeTime = nil
UIComItemDetailsPanelV2View.mText_Max = nil
UIComItemDetailsPanelV2View.mText_Name = nil
UIComItemDetailsPanelV2View.mText_NumNum = nil
UIComItemDetailsPanelV2View.mContent_Attribute = nil
UIComItemDetailsPanelV2View.mContent_AttributeAttribute = nil
UIComItemDetailsPanelV2View.mContent_AttributeAttributeAttribute = nil
UIComItemDetailsPanelV2View.mContent_ = nil
UIComItemDetailsPanelV2View.mContent_ = nil
UIComItemDetailsPanelV2View.mScrollbar_Attribute = nil
UIComItemDetailsPanelV2View.mScrollbar_AttributeAttribute = nil
UIComItemDetailsPanelV2View.mScrollbar_AttributeAttributeAttribute = nil
UIComItemDetailsPanelV2View.mScrollbar_ = nil
UIComItemDetailsPanelV2View.mScrollbar_ = nil
UIComItemDetailsPanelV2View.mList_EquipAttribute = nil
UIComItemDetailsPanelV2View.mList_WeaponAttribute = nil
UIComItemDetailsPanelV2View.mList_Attribute = nil
UIComItemDetailsPanelV2View.mList_WeaponParts = nil
UIComItemDetailsPanelV2View.mList_Item = nil
UIComItemDetailsPanelV2View.mTrans_Equip = nil
UIComItemDetailsPanelV2View.mTrans_Bg = nil
UIComItemDetailsPanelV2View.mTrans_Icon = nil
UIComItemDetailsPanelV2View.mTrans_NumRight = nil
UIComItemDetailsPanelV2View.mTrans_Line = nil
UIComItemDetailsPanelV2View.mTrans_Weapon = nil
UIComItemDetailsPanelV2View.mTrans_WeaponParts = nil
UIComItemDetailsPanelV2View.mTrans_Item = nil
UIComItemDetailsPanelV2View.mTrans_Time = nil
UIComItemDetailsPanelV2View.mTrans_NextTime = nil
UIComItemDetailsPanelV2View.mTrans_AllTime = nil
UIComItemDetailsPanelV2View.mTrans_Max = nil
UIComItemDetailsPanelV2View.mTrans_Num = nil
UIComItemDetailsPanelV2View.staminaRegainAmount = nil
UIComItemDetailsPanelV2View.staminaRegainInterval = nil
UIComItemDetailsPanelV2View.HowToGetPanel = nil
UIComItemDetailsPanelV2View.subProp = {}
UIComItemDetailsPanelV2View.getWayList = {}
UIComItemDetailsPanelV2View.attributeList = {}
UIComItemDetailsPanelV2View.propertyItemList = {}
UIComItemDetailsPanelV2View.modSuitItemList = {}
UIComItemDetailsPanelV2View.equipSetList = {}
UIComItemDetailsPanelV2View.attributeItemTable = {}
UIComItemDetailsPanelV2View.StaminaType = GlobalConfig.ItemType.StaminaType
UIComItemDetailsPanelV2View.GunType = GlobalConfig.ItemType.GunType
UIComItemDetailsPanelV2View.EquipmentType = GlobalConfig.ItemType.EquipmentType
UIComItemDetailsPanelV2View.WeaponType = GlobalConfig.ItemType.Weapon
UIComItemDetailsPanelV2View.WeaponPartType = GlobalConfig.ItemType.WeaponPart
UIComItemDetailsPanelV2View.Packages = GlobalConfig.ItemType.Packages
UIComItemDetailsPanelV2View.GiftPick = GlobalConfig.ItemType.GiftPick
UIComItemDetailsPanelV2View.RobotPackage = GlobalConfig.ItemType.RobotPackage
UIComItemDetailsPanelV2View.Robot = GlobalConfig.ItemType.Robot
UIComItemDetailsPanelV2View.ItemShowType = {
  NormalItemType = 1,
  StaminaType = 2,
  GunType = 3,
  EquipmentType = 4,
  WeaponType = 5,
  WeaponPart = 6,
  Packages = 7,
  TalentType = 8,
  GiftPick = 9,
  Robot = 10,
  RobotPackage = 11
}
function UIComItemDetailsPanelV2View:__InitCtrl()
  self.StarList = {}
end
function UIComItemDetailsPanelV2View:InitEquipSetList()
  for i = 1, 2 do
    local item = self:InitEquipSet(self.ui.mTrans_EquipSkill)
    table.insert(self.equipSetList, item)
  end
end
function UIComItemDetailsPanelV2View:InitEquipSet(parent)
  local equipSet = UIEquipSetItem.New()
  equipSet:InitCtrl(parent)
  return equipSet
end
function UIComItemDetailsPanelV2View:InitCtrl(root)
  self.mTrans_AccessTitle = nil
  self.mTrans_AccessList = nil
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:LuaUIBindTable(self.ui.mTrans_Chr, self.ui)
  self.weaponUI = {}
  self.WeaponPartUI = {}
  self:LuaUIBindTable(self.ui.mTrans_Weapon, self.weaponUI)
  self:LuaUIBindTable(self.ui.mTrans_WeaponParts, self.WeaponPartUI)
  self:__InitCtrl()
  self.RobotDetalList = {}
  self.hintFormatStr = TableData.GetHintById(808)
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = self.OnCloseClick
  UIUtils.GetButtonListener(self.ui.mBtn_BgClose.gameObject).onClick = self.OnCloseClick
  UIUtils.GetButtonListener(self.ui.mBtn_UseItem.gameObject).onClick = function()
    self:UseItemFunction()
  end
  function self.onItemComposeCallback(msg)
    self:onItemCompose(msg)
  end
  MessageSys:AddListener(UIEvent.ItemCompose, self.onItemComposeCallback)
end
function UIComItemDetailsPanelV2View.OnCloseClick(gameObject)
  setactive(self.ui.mUIRoot.gameObject, false)
end
function UIComItemDetailsPanelV2View:GetTableData(tableId)
  return TableData.GetItemData(tableId)
end
function UIComItemDetailsPanelV2View:CheckItemType(itemData)
  if itemData.type == UIComItemDetailsPanelV2View.GunType then
    return UIComItemDetailsPanelV2View.ItemShowType.GunType
  elseif itemData.type == UIComItemDetailsPanelV2View.EquipmentType then
    return UIComItemDetailsPanelV2View.ItemShowType.EquipmentType
  elseif itemData.type == UIComItemDetailsPanelV2View.WeaponType then
    return UIComItemDetailsPanelV2View.ItemShowType.WeaponType
  elseif itemData.type == UIComItemDetailsPanelV2View.StaminaType then
    return UIComItemDetailsPanelV2View.ItemShowType.NormalItemType
  elseif itemData.type == UIComItemDetailsPanelV2View.WeaponPartType then
    return UIComItemDetailsPanelV2View.ItemShowType.WeaponPart
  elseif itemData.type == UIComItemDetailsPanelV2View.Packages then
    return UIComItemDetailsPanelV2View.ItemShowType.Packages
  elseif itemData.type == GlobalConfig.ItemType.Talent then
    return UIComItemDetailsPanelV2View.ItemShowType.TalentType
  elseif itemData.type == UIComItemDetailsPanelV2View.GiftPick then
    return UIComItemDetailsPanelV2View.ItemShowType.GiftPick
  elseif itemData.type == UIComItemDetailsPanelV2View.Robot then
    return UIComItemDetailsPanelV2View.ItemShowType.Robot
  else
    return UIComItemDetailsPanelV2View.ItemShowType.NormalItemType
  end
end
function UIComItemDetailsPanelV2View:ShowItemDetail(itemData, num, needGetWay, showTime, relateId, showWeaponPartTips, showWayCanNotJump, showCreditCount, hideCompose, showUseItemBtn)
  self.mData = itemData
  local type = self:CheckItemType(itemData)
  self:GetAccessTrans(type)
  self.ui.mCount = num
  self.ui.mNeedGetWay = needGetWay
  if showTime == nil then
  end
  self.ui.mShowTime = showTime
  self.ui.mRelateId = relateId or 0
  self.ui.mHideCompose = hideCompose
  setactive(self.ui.mUIRoot.gameObject, true)
  local showUse = showUseItemBtn == true and GlobalConfig.CanUseItemType[self.mData.type] ~= nil
  setactive(self.ui.mBtn_UseItem.transform.parent.parent, showUse == true)
  local isShowGet = self.mData.HasApproach and self.ui.mNeedGetWay and showUse == false
  isShowGet = isShowGet ~= nil and isShowGet or false
  if needGetWay then
    self:ShowAccessTitle(true)
    self:ShowAccessList(true)
    self:ShowGet(nil, showWayCanNotJump)
  else
    self:ShowAccessTitle(false)
    self:ShowAccessList(false)
  end
  setactive(self.ui.mTrans_Japan, (showCreditCount ~= nil and showCreditCount or false) and (itemData.id == GlobalConfig.ResourceType.CreditFree or itemData.id == GlobalConfig.ResourceType.CreditPay) and 0 < TableData.SystemVersionOpenData.FreePayCredit)
  if showCreditCount and (itemData.id == GlobalConfig.ResourceType.CreditFree or itemData.id == GlobalConfig.ResourceType.CreditPay) and 0 < TableData.SystemVersionOpenData.FreePayCredit then
    self.ui.mText_CreditFreeNum.text = GlobalData.credit_free
    self.ui.mText_CreditPaidNum.text = GlobalData.credit_pay
  end
  setactive(self.ui.mTrans_ItemDetailView.gameObject, type == UIComItemDetailsPanelV2View.ItemShowType.NormalItemType)
  setactive(self.ui.mTrans_Equip.gameObject, type == UIComItemDetailsPanelV2View.ItemShowType.EquipmentType)
  setactive(self.ui.mTrans_Weapon.gameObject, type == UIComItemDetailsPanelV2View.ItemShowType.WeaponType)
  setactive(self.ui.mTrans_WeaponParts.gameObject, type == UIComItemDetailsPanelV2View.ItemShowType.WeaponPart)
  setactive(self.ui.mTrans_Chr.gameObject, type == UIComItemDetailsPanelV2View.ItemShowType.Packages)
  setactive(self.ui.mTrans_ChrTalent, type == UIComItemDetailsPanelV2View.ItemShowType.TalentType)
  setactive(self.ui.mTrans_Box, type == UIComItemDetailsPanelV2View.ItemShowType.GiftPick)
  setactive(self.ui.mTrans_Robot, type == UIComItemDetailsPanelV2View.ItemShowType.RobotPackage or type == UIComItemDetailsPanelV2View.ItemShowType.Robot)
  setactive(self.ui.mImage_WeaponIcon, false)
  setactive(self.ui.mImage_IconImage, true)
  setactive(self.ui.mTrans_Command, false)
  setactive(self.ui.mTrans_Avatar, false)
  if type == UIComItemDetailsPanelV2View.ItemShowType.NormalItemType then
    self.ui.mText_TopTitle.text = TableData.GetHintById(101)
    self:ShowItem()
  elseif type == UIComItemDetailsPanelV2View.ItemShowType.EquipmentType then
    self.ui.mText_TopTitle.text = TableData.GetHintById(102)
    self:ShowEquipment()
  elseif type == UIComItemDetailsPanelV2View.ItemShowType.GunType then
    self:ShowGun()
  elseif type == UIComItemDetailsPanelV2View.ItemShowType.WeaponType then
    self.ui.mText_TopTitle.text = TableData.GetHintById(103)
    self:ShowWeapon()
  elseif type == UIComItemDetailsPanelV2View.ItemShowType.WeaponPart then
    self.ui.mText_TopTitle.text = TableData.GetHintById(101)
    self:ShowWeaponPart(showWeaponPartTips, relateId)
  elseif type == UIComItemDetailsPanelV2View.ItemShowType.Packages then
    self.ui.mText_TopTitle.text = TableData.GetHintById(101)
    self:ShowPackage()
  elseif type == UIComItemDetailsPanelV2View.ItemShowType.TalentType then
    self.ui.mText_TopTitle.text = TableData.GetHintById(101)
    self:ShowTalent()
  elseif type == UIComItemDetailsPanelV2View.ItemShowType.GiftPick then
    self.ui.mText_TopTitle.text = TableData.GetHintById(101)
    self:ShowGiftPick()
  elseif type == UIComItemDetailsPanelV2View.ItemShowType.RobotPackage then
    self.ui.mText_TopTitle.text = TableData.GetHintById(101)
    self:ShowRobot(type)
  elseif type == UIComItemDetailsPanelV2View.ItemShowType.Robot then
    self.ui.mText_TopTitle.text = TableData.GetHintById(101)
    self:ShowRobot(type)
  end
  self.ui.mItemShowType = type
end
function UIComItemDetailsPanelV2View:ShowGet(cmdCallBack, showWayCanNotJump)
  if NetCmdDungeonData.hasResChapterData == false then
    NetCmdDungeonData:SendReqDungeonChapter(function()
      self:ShowGet()
    end)
    return
  end
  local t = {
    StageType.CashStage,
    StageType.ExpStage,
    StageType.DailyStage,
    StageType.TowerStage,
    StageType.WeeklyStage,
    StageType.MythicStage,
    StageType.TutorialStage
  }
  for i = 1, #t do
    local tableID = t[i]
    if NetCmdStageRecordData:GetStageRecordsByType(tableID:GetHashCode()) == nil and cmdCallBack == nil then
      NetCmdStageRecordData:RequestStageRecordByType(tableID, function()
        self:ShowGet(true, showWayCanNotJump)
      end)
      return
    end
  end
  local curPlan = NetCmdSimulateBattleData:GetPlanByType(CS.GF2.Data.PlanType.PlanFunctionSimDailyopen:GetHashCode())
  if curPlan == nil then
    NetCmdSimulateBattleData:ReqPlanData(CS.GF2.Data.PlanType.PlanFunctionSimDailyopen:GetHashCode(), function()
      self:ShowGet(nil, showWayCanNotJump)
    end)
    return
  end
  local data = self.mData
  if data.get_list == "" and data.compose.Count == 0 then
    self:ShowAccessTitle(false)
    self:ShowAccessList(false)
    return
  end
  local getList = string.split(data.get_list, ",")
  self.accessItemList = {}
  if (self.ui.mHideCompose == nil or not self.ui.mHideCompose) and data.compose.Count > 0 and self.mTrans_AccessList ~= nil then
    local dataParam = {
      title = TableData.GetHintById(1075),
      type = 99,
      getList = nil,
      itemData = data,
      howToGetData = nil,
      root = self
    }
    local uiItem = UIComAccessItem.New()
    uiItem:InitCtrl(self.mTrans_AccessList)
    uiItem:SetData(dataParam, true)
    table.insert(self.accessItemList, uiItem)
  end
  if self.mTrans_AccessList ~= nil then
    for _, item in ipairs(getList) do
      if item ~= "" then
        local getListData = TableData.listItemGetListDatas:GetDataById(tonumber(item))
        if getListData then
          local dataParam = {
            title = getListData.title.str,
            type = getListData.type,
            getList = getListData,
            itemData = data,
            howToGetData = getListData,
            root = self
          }
          local uiItem = UIComAccessItem.New()
          uiItem:InitCtrl(self.mTrans_AccessList)
          uiItem:SetData(dataParam, showWayCanNotJump)
          table.insert(self.accessItemList, uiItem)
        end
      end
    end
  end
  self:ShowAccessTitle(0 < #self.accessItemList)
end
function UIComItemDetailsPanelV2View:ShowItem()
  local itemTypeData = TableData.listItemTypeDescDatas:GetDataById(self.mData.type)
  setactive(self.ui.mText_Count, itemTypeData.stock_show)
  if itemTypeData.stock_show == true then
    local itemNum = NetCmdItemData:GetItemCount(self.mData.id)
    if self.mData.id == GlobalConfig.ResourceType.CreditPay or self.mData.id == GlobalConfig.ResourceType.CreditFree then
      itemNum = GlobalData.credit_all
    end
    setactive(self.ui.mText_Count, itemNum ~= nil and 0 < itemNum)
    if itemNum and 0 < itemNum then
      self.ui.mText_Count.text = string_format(self.hintFormatStr, itemNum)
    else
      self.ui.mText_Count.text = ""
    end
  end
  self.ui.mText_ItemName.text = self.mData.name.str
  self.ui.mText_Description.text = self.mData.introduction.str
  self.ui.mImage_IconImage.sprite = UIUtils.GetIconSprite("Icon/" .. self.mData.icon_path, self.mData.icon)
  self.ui.mImage_ItemRate.color = TableData.GetGlobalGun_Quality_Color2(self.mData.rank)
  setactive(self.ui.mTrans_TimeLeft, self.mData.type == UIComItemDetailsPanelV2View.StaminaType)
  self.needCheckTime = false
  local toppanel = UISystem:GetTopPanelUI()
  if toppanel ~= nil and (toppanel.UIDefine.UIType == UIDef.UIMailPanelV2 or toppanel.UIDefine.UIType == UIDef.UICommonReceivePanel or toppanel.UIDefine.UIType == UIDef.UIRepositoryPanelV2) then
    self.needCheckTime = self.mData.time_limit ~= 0
  end
  setactive(self.ui.mTrans_TimeLimit, self.needCheckTime)
  if self.mData.type == UIComItemDetailsPanelV2View.StaminaType then
    self:ShowStamina()
  elseif self.mData.type == 2 then
  elseif self.mData.type == GlobalConfig.ItemType.Weapon then
  elseif self.mData.type == GlobalConfig.ItemType.RogueBuff then
    setactive(self.ui.mImage_IconImage, false)
    setactive(self.ui.mImg_Buff, true)
    self.ui.mImg_Buff.sprite = self.ui.mImage_IconImage.sprite
  elseif self.mData.type == GlobalConfig.ItemType.PlayerAvatar then
    local frameID = AccountNetCmdHandler:GetAvatarFrame()
    self.ui.mImg_Avatar.sprite = UIUtils.GetIconSprite("Icon/" .. self.mData.icon_path, self.mData.icon)
    setactive(self.ui.mImage_IconImage, false)
    setactive(self.ui.mTrans_Avatar, true)
  end
end
function UIComItemDetailsPanelV2View:ShowGun()
  self.ui.mText_ItemName.text = self.mData.name.str
  self.ui.mText_Description.text = self.mData.introduction.str
  self.ui.mImage_ItemRate.color = TableData.GetGlobalGun_Quality_Color1(self.mData.rank)
end
function UIComItemDetailsPanelV2View:ShowRobot(type)
  setactive(self.ui.mTrans_ItemDetailView, false)
  setactive(self.ui.mTrans_Robot, true)
  self.ui.mText_RobotName.text = self.mData.name.str
  self.ui.mText_RobotTypeName.text = TableData.listRobotEnemyDatas:GetDataById(self.mData.args[0]).robot_type
  self.ui.mImg_RobotRank.color = TableData.GetGlobalGun_Quality_Color2(self.mData.rank)
  self.ui.mImg_RobotIcon.sprite = IconUtils.GetItemIcon(self.mData.Icon)
  local tempSkillData = {}
  if type == UIComItemDetailsPanelV2View.ItemShowType.Robot then
    if 0 < self.mData.args.Count then
      local robot = TableData.listRobotEnemyDatas:GetDataById(self.mData.args[0])
      local skillList = {}
      local SkillAdd = function(skillId)
        if skillId ~= 0 and skillId then
          local skilldisplay = TableData.listBattleSkillDisplayDatas:GetDataById(skillId)
          if skilldisplay and skilldisplay.skill_in_panel then
            table.insert(skillList, skillId)
          end
        end
      end
      SkillAdd(robot.SkillNormalAttack)
      SkillAdd(robot.SkillActive)
      if robot.SkillActiveExtra ~= "" then
        SkillAdd(tonumber(robot.SkillActiveExtra))
      end
      SkillAdd(robot.SkillSuper)
      SkillAdd(robot.SkillTalent)
      if robot.SkillTalentExtra then
        SkillAdd(tonumber(robot.SkillTalentExtra))
      end
      SkillAdd(robot.SkillFaction)
      SkillAdd(robot.SkillFaction2)
      for i = 1, #skillList do
        table.insert(tempSkillData, TableData.listBattleSkillDisplayDatas:GetDataById(skillList[i]))
      end
    end
  elseif type == UIComItemDetailsPanelV2View.ItemShowType.RobotPackage then
    for i = 0, self.mData.SkillShow.Count - 1 do
      table.insert(tempSkillData, TableData.listBattleSkillDatas:GetDataById(self.mData.SkillShow[i]))
    end
  end
  for i = 1, #tempSkillData do
    local robotAttItem = self.RobotDetalList[i]
    if not robotAttItem then
      robotAttItem = UIStoreRobotAttItem.New()
      robotAttItem:InitCtrl(self.ui.mRobotDetailItem, self.ui.mTrans_RobotContent)
      table.insert(self.RobotDetalList, robotAttItem)
    end
    robotAttItem:SetData(tempSkillData[i])
  end
end
function UIComItemDetailsPanelV2View:ShowWeapon()
  local ui = self.weaponUI
  local weaponCmdData = NetCmdWeaponData:GetWeaponById(self.ui.mRelateId)
  if weaponCmdData == nil then
    weaponCmdData = CS.WeaponCmdData(self.mData.id)
  end
  ui.mText_WeaponName.text = self.mData.name.str
  ui.mTextFit_Introduction.text = weaponCmdData.ItemData.introduction.str
  ui.mImg_QualityLine.color = TableData.GetGlobalGun_Quality_Color2(weaponCmdData.Rank, ui.mImg_QualityLine.color.a)
  ui.mImg_WeaponIcon.sprite = IconUtils.GetWeaponNormalSprite(weaponCmdData.StcData.res_code)
  ui.mText_WeaponType.text = weaponCmdData.WeaponTypeData.name.str
  ui.mText_LvNow.text = GlobalConfig.SetLvText(weaponCmdData.Level)
  ui.mText_LvMax.text = "/" .. weaponCmdData.DefaultMaxLevel
  local capacity = weaponCmdData.Capacity
  setactive(ui.mTrans_PartsVolume.gameObject, false)
  UIWeaponGlobal.SetBreakTimesImg(ui.mImg_Num, weaponCmdData.BreakTimes, weaponCmdData.MaxBreakTime)
  self:WeaponUpdateSlot(ui, weaponCmdData)
  self:InitWeaponTab(ui)
  self:WeaponSkill(ui, weaponCmdData)
  self:WeaponPrivateSkill(ui, weaponCmdData)
  self:WeaponUpdateWeaponGroupSkill(ui, weaponCmdData)
  self:WeaponAttribute(ui, weaponCmdData)
end
function UIComItemDetailsPanelV2View:WeaponAttribute(ui, weaponCmdData)
  local setData = function(item, propData, value, showBg)
    item.mText_Name.text = propData.show_name.str
    setactive(item.mTrans_ImgBg.gameObject, showBg)
    local strValue
    if propData.show_type == 2 then
      strValue = FacilityBarrackGlobal.PercentValue(value)
    else
      strValue = value
    end
    item.mText_Num.text = value
  end
  local tmpAttrParent = ui.mTrans_Attribute
  local tmpItem = tmpAttrParent.transform:GetChild(0)
  local attrList = {}
  local expandList = TableData.GetPropertyExpandList()
  for i = 0, expandList.Count - 1 do
    local lanData = expandList[i]
    local value = weaponCmdData:GetPropertyByLevelAndSysNameWithPercent(lanData.sys_name, weaponCmdData.Level, weaponCmdData.BreakTimes)
    if 0 < value then
      local attr = {}
      attr.propData = lanData
      attr.value = value
      table.insert(attrList, attr)
    end
  end
  table.sort(attrList, function(a, b)
    return a.propData.order < b.propData.order
  end)
  setactive(tmpAttrParent.gameObject, false)
  setactive(tmpAttrParent.gameObject, true)
  for i = 0, tmpAttrParent.childCount - 1 do
    setactive(tmpAttrParent:GetChild(i).gameObject, false)
  end
  self.lvUpAttributeItems = {}
  for i = 1, #attrList do
    local item = {}
    local tmpItemObj
    if i <= tmpAttrParent.childCount then
      tmpItemObj = tmpAttrParent:GetChild(i - 1)
    else
      tmpItemObj = instantiate(tmpItem, tmpAttrParent, false).transform
    end
    setactive(tmpItemObj.gameObject, true)
    self:LuaUIBindTable(tmpItemObj, item)
    setData(item, attrList[i].propData, attrList[i].value, i % 2 == 0)
  end
end
function UIComItemDetailsPanelV2View:WeaponUpdateSlot(ui, weaponCmdData)
  local slotTrans = ui.mTrans_WeaponPartsEquipe
  local slotList = weaponCmdData.slotList
  for i = 0, slotTrans.childCount - 1 do
    setactive(slotTrans:GetChild(i).gameObject, i < slotList.Count)
  end
  for i = 0, slotList.Count - 1 do
    local item = slotTrans:GetChild(i):Find("Img_QualityColor"):GetComponent(typeof(CS.UnityEngine.UI.Image))
    local data = weaponCmdData:GetWeaponPartByType(i)
    if data then
      setactive(item.gameObject, true)
      item.color = TableData.GetGlobalGun_Quality_Color2(data.rank, item.color.a)
    else
      setactive(item.gameObject, false)
      item.color = Color(0.47843137254901963, 0.48627450980392156, 0.4980392156862745, item.color.a)
    end
  end
end
function UIComItemDetailsPanelV2View:InitWeaponTab(ui)
  local tmpTabParent = ui.mScrollListChild_GrpTabBar.transform
  local tmpScrollListChild = ui.mScrollListChild_GrpTabBar
  local tabItemList = {}
  local showAttributeOrEffect = function(index)
    for i, v in ipairs(tabItemList) do
      local isShow = v.index == index
      v.mBtn_ComChrUAVSkillInfoItem.interactable = not isShow
      setactive(v.contentTrans, isShow)
    end
  end
  local initTab = function(index, hint, contentTrans)
    local obj
    if index < tmpTabParent.childCount then
      obj = tmpTabParent:GetChild(index)
    else
      obj = instantiate(tmpScrollListChild.childItem, tmpTabParent, false)
    end
    local tabItem = {}
    tabItem.index = index
    tabItem.contentTrans = contentTrans
    self:LuaUIBindTable(obj, tabItem)
    tabItem.mText_UAVSkillItemName.text = hint
    UIUtils.GetButtonListener(tabItem.mBtn_ComChrUAVSkillInfoItem.gameObject).onClick = function()
      showAttributeOrEffect(index)
    end
    table.insert(tabItemList, tabItem)
  end
  initTab(1, TableData.GetHintById(220004), ui.mTrans_Attribute.parent.gameObject)
  initTab(2, TableData.GetHintById(220002), ui.mTrans_Effect.gameObject)
  showAttributeOrEffect(1)
end
function UIComItemDetailsPanelV2View:WeaponSkill(ui, weaponCmdData)
  local data = weaponCmdData.Skill
  ui.mText_SkillName.text = data.name.str
  ui.mTextFit_Describe.text = data.description.str
end
function UIComItemDetailsPanelV2View:WeaponPrivateSkill(ui, weaponCmdData)
  if weaponCmdData.PrivateSkillDisplayData == nil then
    setactive(ui.mTrans_ExclusiveEffect.gameObject, false)
    return
  end
  setactive(ui.mTrans_ExclusiveEffect.gameObject, true)
  ui.mText_Name1.text = weaponCmdData.PrivateSkillDisplayData.name.str
  ui.mTextFit_Describe1.text = weaponCmdData.PrivateSkillDisplayData.description.str
  local active = weaponCmdData:IsPrivateWeapon()
  setactive(ui.mTrans_Activated.gameObject, active)
  setactive(ui.mTrans_NotActivated.gameObject, not active)
end
function UIComItemDetailsPanelV2View:WeaponUpdateWeaponGroupSkill(ui, weaponCmdData)
  local hasGroup = self:WeaponGetWeaponPartGroupSkill(ui, weaponCmdData)
  local hasProficiency = self:WeaponGetWeaponPartProficiencySkill(ui, weaponCmdData) > 0
  setactive(ui.mTrans_PartsSkill.gameObject, hasGroup or hasProficiency)
end
function UIComItemDetailsPanelV2View:WeaponGetWeaponPartGroupSkill(ui, weaponCmdData)
  local hasGroup = false
  local gunWeaponModDatas = weaponCmdData:GetWeaponPartGroupSkill()
  local groupSkillData
  if gunWeaponModDatas == nil or gunWeaponModDatas.Count == 0 then
    groupSkillData = nil
    setactive(ui.mTrans_GroupSkill.gameObject, false)
  else
    hasGroup = true
    local gunWeaponModData = gunWeaponModDatas[0]
    local modPowerData = gunWeaponModData.ModPowerData
    local powerSkillData = gunWeaponModData.PowerSkillCsData
    groupSkillData = gunWeaponModData.GroupSkillData
    setactive(ui.mTrans_GroupSkill.gameObject, true)
    CS.WeaponCmdData.SetModPowerDataNameWithLevel(ui.mText_Skill, modPowerData, weaponCmdData)
    ui.mImg_SuitIcon.sprite = IconUtils.GetWeaponPartIconSprite(modPowerData.image, false)
    local showText = gunWeaponModData:GetModGroupSkillShowText()
    ui.mTextFit_GroupDescribe.text = showText
  end
  return hasGroup
end
function UIComItemDetailsPanelV2View:WeaponGetWeaponPartProficiencySkill(ui, weaponCmdData)
  local tmpParent = ui.mTrans_OtherPartsSkillDescribe1
  local count = CS.WeaponCmdData.SetWeaponPartProficiencySkill(weaponCmdData, tmpParent)
  return count
end
function UIComItemDetailsPanelV2View:ShowWeaponPart(showWeaponPartTips, relateId)
  if showWeaponPartTips == nil then
    showWeaponPartTips = false
  end
  local tmpHavePart = self.ui.mRelateId ~= nil and self.ui.mRelateId ~= 0
  local gunWeaponModData = NetCmdWeaponPartsData:GetWeaponModById(self.ui.mRelateId)
  local havePart = tmpHavePart and gunWeaponModData ~= nil
  local weaponPartData = TableData.listItemDatas:GetDataById(tonumber(self.mData.args[0]))
  local stcData = TableData.listWeaponModDatas:GetDataById(weaponPartData.id)
  local modAspectData = TableData.listModAspectDatas:GetDataById(stcData.aspect_id)
  local weaponModTypeData = TableData.listWeaponModTypeDatas:GetDataById(modAspectData.type)
  local modEffectTypeData = TableData.listModEffectTypeDatas:GetDataById(stcData.effect_id)
  self.WeaponPartUI.mText_Name.text = weaponPartData.name.str
  self.WeaponPartUI.mText_Type.text = weaponModTypeData.name.str
  self.WeaponPartUI.mText_Quality.text = ""
  self.WeaponPartUI.mImg_TypeIcon.sprite = ResSys:GetWeaponPartEffectSprite(modEffectTypeData.icon)
  self.WeaponPartUI.mText_Num.text = stcData.mod_capacity
  self.WeaponPartUI.mImg_Icon.sprite = IconUtils.GetWeaponPartIcon(weaponPartData.icon)
  self.WeaponPartUI.mImg_QualityLine.color = TableData.GetGlobalGun_Quality_Color2(stcData.rank, self.WeaponPartUI.mImg_QualityLine.color.a)
  self.WeaponPartUI.mText_Fit.text = weaponModTypeData.weapon_mod_des.str
  self.WeaponPartUI.mTextFit_PartsDescribe.text = weaponPartData.introduction.str
  setactive(self.WeaponPartUI.mTrans_Awarded.gameObject, havePart)
  setactive(self.WeaponPartUI.mTrans_PartsSkill.gameObject, havePart)
  self.WeaponPartUI.mTextFit_None.text = modEffectTypeData.description.str
  setactive(self.WeaponPartUI.mText_Lv.gameObject, havePart)
  setactive(self.WeaponPartUI.mTextFit_PartsDescribe.gameObject, not havePart)
  if havePart then
    if gunWeaponModData.PolarityTagData ~= nil then
      self.WeaponPartUI.mImg_PolarityIcon.sprite = IconUtils.GetElementIcon(gunWeaponModData.PolarityTagData.icon .. "_S")
    else
    end
    setactive(self.WeaponPartUI.mTrans_Icon.gameObject, gunWeaponModData.stcDataCanPolarity)
    self:SetModLevel(gunWeaponModData)
    self:UpdateWeaponPartAttribute(gunWeaponModData)
    self:UpdateWeaponPartsSkill(gunWeaponModData)
  else
    local basic_affix_id = 0
    if basic_affix_id ~= 0 then
      setactive(self.WeaponPartUI.mTrans_Item.gameObject, true)
      local tmpGunWeaponMod = CS.GunWeaponModData(stcData.id)
      self:UpdateWeaponPartAttribute(tmpGunWeaponMod)
    else
      setactive(self.WeaponPartUI.mTrans_Item.gameObject, false)
      setactive(self.WeaponPartUI.mTrans_MainAttribute.gameObject, false)
    end
  end
end
function UIComItemDetailsPanelV2View:SetModLevel(tmpGunWeaponModData)
  CS.GunWeaponModData.SetModLevelText(self.WeaponPartUI.mText_Lv, tmpGunWeaponModData, nil, true, self.WeaponPartUI.mCanvasGroup_Lv, 0.4)
  CS.GunWeaponModData.SetModPolarityText(self.WeaponPartUI.mText_State, self.WeaponPartUI.mImg_PolarityIcon, tmpGunWeaponModData, self.WeaponPartUI.mCanvasGroup_State, 0.4)
end
function UIComItemDetailsPanelV2View:UpdateWeaponPartAttribute(gunWeaponModData)
  self.subPropList = CS.GunWeaponModData.SetWeaponPartAttr(gunWeaponModData, self.WeaponPartUI.mTrans_Item.transform, self.WeaponPartUI.mTrans_MainAttribute.transform, 0, false, 0, false)
end
function UIComItemDetailsPanelV2View:UpdateWeaponPartsSkill(gunWeaponModData)
  local hasGroupSkill = self:UpdateWeaponPartsGroupSkill(gunWeaponModData)
  local hasProficiencySkill = self:UpdateWeaponPartsProficiencySkill(gunWeaponModData) > 0
  setactive(self.WeaponPartUI.mTrans_PartsSkill.gameObject, hasGroupSkill or hasProficiencySkill)
end
function UIComItemDetailsPanelV2View:UpdateWeaponPartsGroupSkill(gunWeaponModData)
  if self.WeaponPartUI.mText_Num3 ~= nil then
    setactive(self.WeaponPartUI.mText_Num3.gameObject, false)
  end
  local hasGroupSkill = false
  local modPowerData = gunWeaponModData.ModPowerData
  local groupSkillData = gunWeaponModData.GroupSkillData
  local PowerSkillCsData = gunWeaponModData.PowerSkillCsData
  if nil == groupSkillData then
    setactive(self.WeaponPartUI.mTrans_GroupSkill.gameObject, false)
  else
    hasGroupSkill = true
    setactive(self.WeaponPartUI.mTrans_GroupSkill.gameObject, true)
    CS.GunWeaponModData.SetModPowerDataNameWithLevel(self.WeaponPartUI.mText_Skill, modPowerData, gunWeaponModData)
    local showText = gunWeaponModData:GetModGroupSkillShowText()
    self.WeaponPartUI.mTextFit_GroupDescribe.text = showText
    self.WeaponPartUI.mImg_SuitIcon.sprite = IconUtils.GetWeaponPartIconSprite(gunWeaponModData.ModPowerData.image, false)
  end
  return hasGroupSkill
end
function UIComItemDetailsPanelV2View:UpdateWeaponPartsProficiencySkill(gunWeaponModData)
  local tmpParent = self.WeaponPartUI.mTrans_OtherPartsSkillDescribe1
  local count = CS.GunWeaponModData.SetWeaponPartProficiencySkill(gunWeaponModData, tmpParent)
  return count
end
function UIComItemDetailsPanelV2View:UpdateWeaponAttribute(data, stcData)
  local attrList = {}
  local curLv = 0
  if data then
    curLv = data.Level
  else
    data = CS.WeaponCmdData(stcData.id)
  end
  local expandList = TableData.GetPropertyExpandList()
  for i = 0, expandList.Count - 1 do
    local lanData = expandList[i]
    if lanData.type == 1 then
      local value = 0
      if data then
        value = data:GetPropertyByLevelAndSysName(lanData.sys_name, curLv, data.BreakTimes)
      else
        value = stcData
      end
      if 0 < value then
        local attr = {}
        attr.propData = lanData
        attr.value = value
        table.insert(attrList, attr)
      end
    end
  end
  table.sort(attrList, function(a, b)
    return a.propData.order < b.propData.order
  end)
  for _, item in ipairs(self.attributeList) do
    item:SetData(nil)
  end
  clearallchild(self.ui.mTrans_WeaponSub)
  for i = 1, #attrList do
    local item
    if i <= #self.attributeList then
      item = self.attributeList[i]
    else
      item = UICommonPropertyItem.New()
      item:InitCtrl(self.ui.mTrans_WeaponSub)
      table.insert(self.attributeList, item)
    end
    item:SetData(attrList[i].propData, attrList[i].value, false, false, i % 2 == 0)
  end
end
function UIComItemDetailsPanelV2View:ShowEquipment()
  self.ui.mText_EquipName.text = self.mData.name.str
  self.ui.mText_Description.text = self.mData.introduction.str
  self.ui.mImage_ItemRate.color = TableData.GetGlobalGun_Quality_Color1(self.mData.rank)
  local equipData = TableData.listGunEquipDatas:GetDataById(tonumber(self.mData.args[0]))
  local rankColor = TableData.GetGlobalGun_Quality_Color2(equipData.rank)
  self.ui.mImage_EquipIcon.sprite = IconUtils.GetEquipSprite(equipData.res_code)
  self.ui.mImage_EquipBase.color = rankColor
  local cmdData = NetCmdEquipData:GetEquipById(self.ui.mRelateId)
  self:UpdateEquipMainAttribute(cmdData)
  self:UpdateEquipSubAttribute(cmdData)
  local setData = TableData.listEquipSetDatas:GetDataById(equipData.SetIdCs)
  for i, item in ipairs(self.equipSetList) do
    item:SetData(equipData.SetIdCs, setData["set" .. i .. "_num"])
  end
  setactive(self.ui.mTrans_Count.gameObject, false)
end
function UIComItemDetailsPanelV2View:UpdateEquipMainAttribute(data)
  if data ~= nil and data.main_prop ~= nil then
    local tableData = TableData.listCalibrationDatas:GetDataById(data.main_prop.Id)
    if tableData then
      local propData = TableData.GetPropertyDataByName(tableData.property, tableData.type)
      self.ui.mText_MainAttributeName.text = propData.show_name.str
      if propData.show_type == 2 then
        self.ui.mText_MainAttributeNum.text = math.ceil(data.main_prop.Value / 10) .. "%"
      else
        self.ui.mText_MainAttributeNum.text = data.main_prop.Value
      end
    end
  else
    self.ui.mText_MainAttributeName.text = TableData.GetHintById(20010)
    self.ui.mText_MainAttributeNum.text = ""
  end
end
function UIComItemDetailsPanelV2View:UpdateEquipSubAttribute(data)
  if data == nil or data.sub_props == nil then
    local item = PropertyItemS.New()
    item:InitCtrl(self.ui.mTrans_EquipSub)
    item.mText_Name.text = TableData.GetHintById(20011)
    item.mText_Num.text = ""
    return
  end
  if data.sub_props then
    local item
    for _, item in ipairs(self.subProp) do
      item:SetData(nil)
    end
    for i = 0, data.sub_props.Length - 1 do
      local prop = data.sub_props[i]
      local tableData = TableData.listCalibrationDatas:GetDataById(prop.Id)
      local propData = TableData.GetPropertyDataByName(tableData.property, tableData.type)
      if i + 1 <= #self.subProp then
        item = self.subProp[i + 1]
      else
        item = PropertyItemS.New()
        item:InitCtrl(self.ui.mTrans_EquipSub)
        table.insert(self.subProp, item)
      end
      item:SetData(propData, prop.Value, false, ColorUtils.BlackColor, false)
      item:SetNameColor(ColorUtils.BlackColor)
      item:SetTextSize(24)
    end
  end
end
function UIComItemDetailsPanelV2View:ShowStamina()
  self.staminaRegainInterval = self.mData.args[0]
  if not self.ui.mNeedGetWay and not self.ui.mShowTime then
    setactive(self.ui.mText_AllAdd.transform.parent, false)
    setactive(self.ui.mText_NextAdd.transform.parent, false)
    setactive(self.ui.mText_Full.gameObject, false)
    self.updateFlag = false
  else
    local maxStamina = GlobalData.GetStaminaResourceMaxNum(self.mData.id)
    setactive(self.ui.mText_AllAdd.transform.parent, maxStamina > self.ui.mCount)
    setactive(self.ui.mText_NextAdd.transform.parent, maxStamina > self.ui.mCount)
    setactive(self.ui.mText_Full.gameObject, maxStamina <= self.ui.mCount)
    self.updateFlag = maxStamina > self.ui.mCount
  end
end
function UIComItemDetailsPanelV2View:UpdateStaminaContent()
  local staminaInfo = GlobalData.GetStaminaTypeResById(self.mData.id)
  if staminaInfo then
    local maxStaminaInScene = GlobalData.GetStaminaResourceMaxNum(self.mData.id)
    local lastTime = 0
    if maxStaminaInScene > self.ui.mCount then
      local staminaTime = staminaInfo.RefreshTime
      local passedTime = (CGameTime:GetTimestamp() - staminaTime) % self.staminaRegainInterval
      if passedTime <= 0 then
        passedTime = self.staminaRegainInterval
      end
      lastTime = self.staminaRegainInterval - passedTime
      if lastTime <= 0 then
        MessageSys:SendMessage(CS.GF2.Message.ModelDataEvent.StaminaUpdate, nil)
        lastTime = 0
      end
      local timeMax = self.staminaRegainInterval * (maxStaminaInScene - self.ui.mCount) - passedTime
      local timeMaxString = CS.LuaUIUtils.GetTimeStringBySecond(timeMax)
      local timeString = CS.LuaUIUtils.GetTimeStringBySecond(lastTime)
      self.ui.mText_NextAdd.text = timeString
      self.ui.mText_AllAdd.text = timeMaxString
    else
      setactive(self.ui.mText_AllAdd.transform.parent, false)
      setactive(self.ui.mText_NextAdd.transform.parent, false)
      setactive(self.ui.mText_Full.gameObject, true)
      self.updateFlag = false
    end
  end
end
function UIComItemDetailsPanelV2View:UpdateDetailContent()
  if self.ui.mItemShowType == UIComItemDetailsPanelV2View.ItemShowType.NormalItemType then
    local itemNum = NetCmdItemData:GetItemCount(self.mData.id)
    self.ui.mCount = itemNum
    if self.ui.mCount and tonumber(self.ui.mCount) > 0 then
      self.ui.mText_Count.text = string_format(self.hintFormatStr, itemNum)
    else
      self.ui.mText_Count.text = ""
    end
  end
end
function UIComItemDetailsPanelV2View:ShowCommandDetail(commandData)
  self.ui.mText_TopTitle.text = TableData.GetHintById(101)
  setactive(self.ui.mTrans_Chr, false)
  setactive(self.ui.mTrans_ItemDetailView.gameObject, false)
  setactive(self.ui.mTrans_Equip.gameObject, false)
  setactive(self.ui.mTrans_Weapon.gameObject, false)
  setactive(self.ui.mTrans_WeaponParts.gameObject, false)
  setactive(self.ui.mTrans_ChrTalent.gameObject, false)
  setactive(self.ui.mTrans_TimeLeft, false)
  setactive(self.ui.mTrans_AccessTitle, false)
  setactive(self.ui.mTrans_Box, false)
  setactive(self.ui.mTrans_Robot, false)
  setactive(self.ui.mTrans_Command, true)
  self.ui.mImg_CommandIcon.sprite = IconUtils.GetActivityTourIcon(commandData.order_icon)
  self.ui.mImg_CommandName.text = commandData.name.str
  self.ui.mImg_CommandQuality.color = TableData.GetActivityTourCommand_Quality_Color(commandData.level)
  self.ui.mText_CommandStep.text = TableData.GetActivityTourStepContent(commandData)
  self.ui.mText_CommandDes.text = commandData.order_desc.str
  self.ui.mText_CommandIntr.text = commandData.order_desc2.str
end
function UIComItemDetailsPanelV2View:ShowStoreGoodDetail(name, icon, des, rank, itemData)
  self.mData = itemData
  self.ui.mText_TopTitle.text = TableData.GetHintById(101)
  setactive(self.ui.mTrans_Chr, false)
  setactive(self.ui.mTrans_ItemDetailView.gameObject, true)
  setactive(self.ui.mTrans_Equip.gameObject, false)
  setactive(self.ui.mTrans_Weapon.gameObject, false)
  setactive(self.ui.mTrans_WeaponParts.gameObject, false)
  setactive(self.ui.mTrans_ChrTalent.gameObject, false)
  setactive(self.ui.mTrans_TimeLeft, false)
  setactive(self.ui.mTrans_AccessTitle, false)
  setactive(self.ui.mTrans_Box, false)
  setactive(self.ui.mTrans_Robot, false)
  setactive(self.ui.mImage_WeaponIcon, false)
  setactive(self.ui.mTrans_Command, false)
  setactive(self.ui.mImage_IconImage, true)
  self.ui.mImage_IconImage.sprite = IconUtils.GetItemIcon(icon)
  self.ui.mText_ItemName.text = name
  self.ui.mText_Description.text = des
  self.ui.mImage_ItemRate.color = TableData.GetGlobalGun_Quality_Color2(rank)
  if not itemData then
    return
  end
  local type = self:CheckItemType(itemData)
  if type == UIComItemDetailsPanelV2View.ItemShowType.Robot then
    setactive(self.ui.mTrans_ItemDetailView.gameObject, false)
    setactive(self.ui.mTrans_Robot, type == UIComItemDetailsPanelV2View.ItemShowType.Robot)
    self.ui.mText_TopTitle.text = TableData.GetHintById(101)
    self:ShowRobot(type)
  end
  if type == UIComItemDetailsPanelV2View.ItemShowType.WeaponType then
    setactive(self.ui.mImage_IconImage, false)
    setactive(self.ui.mImage_WeaponIcon, true)
    self.ui.mImage_WeaponIcon.sprite = IconUtils.GetWeaponNormalSprite(icon)
  end
end
function UIComItemDetailsPanelV2View:ShowPackage(name, icon, des, rank)
  self.ui.mText_TopTitle.text = TableData.GetHintById(101)
  setactive(self.ui.mTrans_ItemDetailView.gameObject, false)
  setactive(self.ui.mTrans_Equip.gameObject, false)
  setactive(self.ui.mTrans_Weapon.gameObject, false)
  setactive(self.ui.mTrans_WeaponParts.gameObject, false)
  setactive(self.ui.mTrans_TimeLeft, false)
  setactive(self.ui.mTrans_Chr, true)
  self.ui.mImg_ChrIcon.sprite = IconUtils.GetItemIcon(self.mData.icon)
  self.ui.mText_ChrName.text = self.mData.name.str
  self.ui.mText_ChrDetail.text = self.mData.Introduction.str
  self.ui.mImg_ChrLine.color = TableData.GetGlobalGun_Quality_Color1(self.mData.rank)
  local total
  if self.mData.args.Length > 0 then
    for i = 0, self.mData.drop_weight.Length - 1 do
      local arg = self.mData.drop_weight[i]
      local args = string.split(arg, ":")
      local itemData = TableData.GetItemData(tonumber(args[1]))
      local chrPro = UICommonChrProbabilityItem.New()
      chrPro:InitCtrl(self.ui.mTrans_ChrAttribute)
      chrPro:SetData(itemData.name.str, args[2] .. "%")
    end
  end
end
function UIComItemDetailsPanelV2View:ShowRandom()
  self.ui.mText_TopTitle.text = TableData.GetHintById(101)
  setactive(self.ui.mTrans_ItemDetailView.gameObject, false)
  setactive(self.ui.mTrans_Equip.gameObject, false)
  setactive(self.ui.mTrans_Weapon.gameObject, false)
  setactive(self.ui.mTrans_WeaponParts.gameObject, false)
  setactive(self.ui.mTrans_TimeLeft, false)
  setactive(self.ui.mTrans_Chr, true)
  self.ui.mImg_ChrIcon.sprite = IconUtils.GetItemIcon(self.mData.icon)
  self.ui.mText_ChrName.text = self.mData.name.str
  self.ui.mText_ChrDetail.text = self.mData.Introduction.str
  self.ui.mImg_ChrLine.color = TableData.GetGlobalGun_Quality_Color1(self.mData.rank)
  local total
  local dropID = tonumber(self.mData.ArgsStr)
  local itemDataTable = {}
  local itemTableList = {}
  local dropTableData = TableData.listDropPackageDatas:GetDataById(dropID, true)
  if dropTableData then
    local count = dropTableData.args.Count
    for i = 0, count - 1 do
      local args = dropTableData.args[i]
      local splitArgs = string.split(args, ":")
      if #splitArgs == 3 then
        local itemId = tonumber(splitArgs[1])
        local num = tonumber(splitArgs[2])
        if itemDataTable[itemId] then
          itemDataTable[itemId] = itemDataTable[itemId] + num
        else
          itemDataTable[itemId] = num
        end
      end
    end
  end
  for i, v in pairs(itemDataTable) do
    local t = {i, v}
    table.insert(itemTableList, t)
  end
  if 0 < self.mData.args.Length then
    for i = 0, self.mData.drop_weight.Length - 1 do
      local arg = self.mData.drop_weight[i]
      local args = string.split(arg, ":")
      local itemData = TableData.GetItemData(tonumber(args[1]))
      local chrPro = UICommonChrProbabilityItem.New()
      chrPro:InitCtrl(self.ui.mTrans_ChrAttribute)
      chrPro:SetData(itemData.name.str, args[2] .. "%")
    end
  end
end
function UIComItemDetailsPanelV2View:ShowTalent()
  self.ui.mText_TalentName.text = self.mData.name.str
  self.ui.mText_TalentItemDesc.text = self.mData.introduction.str
  local talentKeyData = TableData.listTalentKeyDatas:GetDataById(self.mData.id)
  local skillDisplayData = TableData.listBattleSkillDisplayDatas:GetDataById(talentKeyData.battle_skill_id, true)
  local rankColor = TableData.GetGlobalGun_Quality_Color2(self.mData.Rank)
  self.ui.mImg_TalentIcon.sprite = IconUtils.GetItemIconSprite(self.mData.id)
  self.ui.mImg_TalentLine.color = rankColor
  setactivewithcheck(self.ui.mTextFit_TalentSkillDesc, false)
  if skillDisplayData then
    self.ui.mTextFit_TalentSkillDesc.text = skillDisplayData.description.str
    setactivewithcheck(self.ui.mTextFit_TalentSkillDesc, true)
  end
  setactive(self.ui.mTrans_TitleName, talentKeyData.talent_key_type == 2)
  local str = ""
  local jobStr = ""
  if talentKeyData.talent_key_type == 2 then
    if talentKeyData.require_job == 0 then
      str = TableData.GetHintById(180018)
      jobStr = string_format(TableData.GetHintById(180033), TableData.GetHintById(180035))
    else
      local gunDutyData = TableData.listGunDutyDatas:GetDataById(talentKeyData.require_job)
      str = gunDutyData.name.str
      jobStr = string_format(TableData.GetHintById(180033), str)
    end
  elseif talentKeyData.talent_key_type == 1 then
    str = TableData.GetHintById(180031)
    jobStr = TableData.GetHintById(180034)
  end
  self.ui.mText_TalentTypeDesc.text = str
  self.ui.mText_TalentTypeName.text = jobStr
  local propertyId = talentKeyData.PropertyId
  self:ShowPropertyNow(propertyId)
end
function UIComItemDetailsPanelV2View:ShowGiftPick()
  self.ui.mText_BoxInfo.text = self.mData.name.str
  self.ui.mText_BoxDes.text = self.mData.introduction.str
  self.ui.mImg_BoxIcon.sprite = UIUtils.GetIconSprite("Icon/" .. self.mData.icon_path, self.mData.icon)
  self.ui.mImg_BoxLine.color = TableData.GetGlobalGun_Quality_Color2(self.mData.rank)
  self.itemGiftPickList = {}
  local splitData = string.split(self.mData.ArgsStr, ";")
  self.totalNum = tonumber(splitData[1])
  self.itemTableList = string.split(splitData[2], ",")
  for i = 1, #self.itemTableList do
    local splitItem = string.split(self.itemTableList[i], ":")
    local itemId = tonumber(splitItem[1])
    local itemNum = tonumber(splitItem[2])
    local item = UICommonItem.New()
    item:InitCtrl(self.ui.mTrans_BoxContent)
    local itemTableData = TableData.GetItemData(itemId)
    if itemTableData.type == GlobalConfig.ItemType.Weapon then
      item:SetWeaponDataNoLock(NetCmdWeaponData:GetWeaponByStcId(itemId), nil)
    else
      item:SetItemData(itemId, itemNum)
    end
    table.insert(self.itemGiftPickList, item)
  end
end
function UIComItemDetailsPanelV2View:SetStars(count)
  for i, star in ipairs(self.StarList) do
    setactive(star, i <= count)
  end
end
function UIComItemDetailsPanelV2View:OnUpdate()
  if self.mData == nil or self.mData.time_limit == nil then
    return
  end
  if self.needCheckTime then
    local isNotOverTime = self.mData.time_limit > CGameTime:GetTimestamp()
    if isNotOverTime then
      self.ui.mText_TimeLimit.text = string_format(TableData.GetHintById(190000), CS.TimeUtils.GetLeftTime(self.mData.time_limit))
    else
      self.ui.mText_TimeLimit.text = TableData.GetHintById(190005)
      setactive(self.ui.mTrans_TimeLimitIcon, isNotOverTime)
      self.needCheckTime = false
    end
    if self.needCheckTime ~= self.iconHasChange then
      self.iconHasChange = self.needCheckTime
      setactive(self.ui.mTrans_TimeLimitIcon, isNotOverTime)
    end
  end
end
function UIComItemDetailsPanelV2View:onItemCompose(msg)
  local itemID = tonumber(msg.Sender)
  local count = tonumber(msg.Content)
  if itemID == self.mData.id then
    if count and 0 < count then
      self.ui.mText_Count.text = string_format(TableData.GetHintById(808), count)
    else
      self.ui.mText_Count.text = ""
    end
  end
end
function UIComItemDetailsPanelV2View:ShowPropertyNow(propertyId)
  for i, attributeScript in ipairs(self.attributeItemTable) do
    attributeScript:SetVisible(false)
  end
  local usedIndex = 1
  for j = DevelopProperty.None.value__ + 1, DevelopProperty.AllEnd.value__ - 1 do
    local propertyType = DevelopProperty.__CastFrom(j)
    if propertyType then
      local propertyValue = PropertyHelper.GetPropertyValueByEnum(propertyId, propertyType)
      if 0 < propertyValue then
        local propertyData = TableData.GetPropertyDataByName(propertyType:ToString())
        if propertyData then
          local name = propertyData.ShowName.str
          local nowValue = propertyValue
          if propertyData.ShowType == 2 then
            nowValue = nowValue / 10
            nowValue = math.floor(nowValue * 10 + 0.5) / 10
            nowValue = nowValue .. "%"
          end
          if usedIndex > #self.attributeItemTable then
            local template = self.ui.mTrans_TalentAttribute
            local go = UIUtils.InstantiateByTemplate(template, self.ui.mTrans_TalentAttribute.parent)
            local attrBar = self:NewAttrBar(go)
            table.insert(self.attributeItemTable, attrBar)
          end
          local attributeScript = self.attributeItemTable[usedIndex]
          attributeScript:Show(name, nowValue)
          attributeScript:SetVisible(true)
          usedIndex = usedIndex + 1
        end
      end
    end
  end
  self:setLastAttrLineInvisible()
end
function UIComItemDetailsPanelV2View:setLastAttrLineInvisible()
  local count = #self.attributeItemTable
  for i, attributeScript in ipairs(self.attributeItemTable) do
    attributeScript:SetLineVisible(i ~= count)
  end
end
function UIComItemDetailsPanelV2View:NewAttrBar(go)
  local attrBar = {}
  function attrBar:BindGo(root)
    self.root = root
    self.ui = UIUtils.GetUIBindTable(root)
  end
  function attrBar:Show(name, value)
    self.ui.mText_Num.text = value
    self.ui.mText_Name.text = name
  end
  function attrBar:SetLineVisible(visible)
    setactive(self.ui.mTrans_Line, visible)
  end
  function attrBar:SetVisible(visible)
    setactive(self.root, visible)
  end
  function attrBar:OnRelease(isDestroy)
    if isDestroy then
      gfdestroy(self.root)
    end
  end
  attrBar:BindGo(go)
  return attrBar
end
function UIComItemDetailsPanelV2View:GetAccessTrans(type)
  self.mTrans_AccessTitle = nil
  self.mTrans_AccessList = nil
  if type == UIComItemDetailsPanelV2View.ItemShowType.NormalItemType then
    self.mTrans_AccessTitle = self.ui.mTrans_AccessTitle
    self.mTrans_AccessList = self.ui.mTrans_AccessList
    return
  elseif type == UIComItemDetailsPanelV2View.ItemShowType.EquipmentType then
  elseif type == UIComItemDetailsPanelV2View.ItemShowType.GunType then
  elseif type == UIComItemDetailsPanelV2View.ItemShowType.WeaponType then
    self.mTrans_AccessTitle = self.weaponUI.mTrans_Text.transform
    self.mTrans_AccessList = self.weaponUI.mScrollListChild_AccessList.transform
    return
  elseif type == UIComItemDetailsPanelV2View.ItemShowType.WeaponPart then
    self.mTrans_AccessTitle = self.WeaponPartUI.mTrans_TextAccess.transform
    self.mTrans_AccessList = self.WeaponPartUI.mScrollListChild_AccessList.transform
    return
  elseif type == UIComItemDetailsPanelV2View.ItemShowType.Packages then
  elseif type == UIComItemDetailsPanelV2View.ItemShowType.TalentType then
  elseif type == UIComItemDetailsPanelV2View.ItemShowType.GiftPick then
  elseif type == UIComItemDetailsPanelV2View.ItemShowType.RobotPackage then
  elseif type == UIComItemDetailsPanelV2View.ItemShowType.Robot then
  end
  self.mTrans_AccessTitle = self.ui.mTrans_AccessTitle
  self.mTrans_AccessList = self.ui.mTrans_AccessList
end
function UIComItemDetailsPanelV2View:ShowAccessTitle(boolean)
  if self.mTrans_AccessTitle ~= nil then
    setactive(self.mTrans_AccessTitle, boolean)
  end
end
function UIComItemDetailsPanelV2View:ShowAccessList(boolean)
  if self.mTrans_AccessList ~= nil then
    setactive(self.mTrans_AccessList, boolean)
  end
end
function UIComItemDetailsPanelV2View:UseItemFunction()
  if self.mData == nil then
    return
  end
  local canUse = NetCmdItemData:CheckItemCanUse(self.mData.id)
  local hint = ""
  local needOpenReceiveDialog = false
  if self.mData.type == CS.GF2.Data.ItemType.MonthlyCard:GetHashCode() then
    if canUse == false then
      hint = TableData.GetHintById(260051)
    else
      hint = TableData.GetHintById(260052)
    end
    needOpenReceiveDialog = true
  elseif self.mData.id == 110010 or self.mData.id == 110011 then
    if canUse == false then
      local state = NetCmdBattlePassData.BattlePassStatus
      if state == CS.ProtoObject.BattlepassType.AdvanceTwo then
        hint = TableData.GetHintById(260055)
      elseif state == CS.ProtoObject.BattlepassType.AdvanceOne then
        hint = TableData.GetHintById(260053)
      elseif state == CS.ProtoObject.BattlepassType.None then
        hint = TableData.GetHintById(260058)
      end
    elseif self.mData.id == 110010 then
      hint = TableData.GetHintById(260054)
    else
      hint = TableData.GetHintById(260057)
    end
  elseif self.mData.id == 110012 then
    if canUse == false then
      local state = NetCmdBattlePassData.BattlePassStatus
      if state == CS.ProtoObject.BattlepassType.AdvanceTwo then
        hint = TableData.GetHintById(260055)
      elseif state == CS.ProtoObject.BattlepassType.Base then
        hint = TableData.GetHintById(260056)
      elseif state == CS.ProtoObject.BattlepassType.None then
        hint = TableData.GetHintById(260058)
      end
    else
      hint = TableData.GetHintById(260057)
    end
    needOpenReceiveDialog = true
  end
  if canUse == false then
    CS.PopupMessageManager.PopupString(hint)
  else
    NetCmdItemData:SendItemUse(self.mData.id, 1, function()
      CS.PopupMessageManager.PopupPositiveString(hint)
      UIManager.CloseUI(UIDef.UITipsPanel)
      if needOpenReceiveDialog == true then
        UIManager.OpenUI(UIDef.UICommonReceivePanel)
      end
    end)
  end
end
function UIComItemDetailsPanelV2View:onRelease(isDestroy)
  for _, item in pairs(self.getWayList) do
    gfdestroy(item:GetRoot())
  end
  for _, item in pairs(self.attributeList) do
    gfdestroy(item:GetRoot())
  end
  for _, item in pairs(self.propertyItemList) do
    gfdestroy(item:GetRoot())
  end
  for _, item in pairs(self.modSuitItemList) do
    gfdestroy(item:GetRoot())
  end
  for _, item in pairs(self.subProp) do
    gfdestroy(item:GetRoot())
  end
  for _, item in pairs(self.equipSetList) do
    gfdestroy(item:GetRoot())
  end
  if self.itemGiftPickList then
    for i = 1, #self.itemGiftPickList do
      gfdestroy(self.itemGiftPickList[i]:GetRoot())
    end
    self.itemGiftPickList = nil
  end
  if self.elementSkillItem then
    gfdestroy(self.elementSkillItem)
  end
  if self.normalSkillItem then
    gfdestroy(self.normalSkillItem:GetRoot())
  end
  if self.accessItemList then
    for i, v in pairs(self.accessItemList) do
      v:OnRelease(true)
    end
    self.accessItemList = {}
  end
  UIComItemDetailsPanelV2View.subProp = {}
  UIComItemDetailsPanelV2View.getWayList = {}
  UIComItemDetailsPanelV2View.attributeList = {}
  UIComItemDetailsPanelV2View.propertyItemList = {}
  UIComItemDetailsPanelV2View.modSuitItemList = {}
  UIComItemDetailsPanelV2View.equipSetList = {}
  self:ReleaseCtrlTable(self.attributeItemTable, true)
  self.attributeItemTable = nil
  self.HowToGetPanel = nil
  self.StarList = {}
  self.ui.mainProp = nil
  self.detailBrief = nil
  self.ui.mWeaponPartsAttr = nil
  self.hintFormatStr = nil
  self.needCheckTime = nil
  self.iconHasChange = nil
  setactive(self.ui.mText_Count, false)
  MessageSys:RemoveListener(UIEvent.ItemCompose, self.onItemComposeCallback)
end
