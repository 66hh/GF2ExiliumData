require("UI.UAVPanel.UAVAttributeItem")
require("UI.UAVPanel.UAVPartsItem")
require("UI.UAVPanel.UAVTacticSkillItem")
UIUAVPanel = class("UIUAVPanel", UIBasePanel)
function UIUAVPanel:OnAwake(root, data)
end
function UIUAVPanel:OnInit(root, data)
  self.SaveType = 0
  self.Const = {MaxLevel = 60}
  self.levelUpPanel = nil
  self.UnInstallPos = -1
  self.ReplacePos = -1
  self.IsClickSave = false
  self.uavMaxLevel = 0
  self.uavlimitlevel = 0
  self.realmaxLevel = 0
  self.fuelpanel = nil
  self.contrastdialog = nil
  self.OnlyRefreshOnce = false
  self.fakearmequiplist = List:New()
  self.Const.MaxLevel = TableData.GlobalSystemData.UavMaxLv
  self:SetRoot(root)
  self.mView = UIUtils.GetUIBindTable(root)
  self.mView.mLayoutlist = {}
  table.insert(self.mView.mLayoutlist, getcomponent(self.mView.mTrans_layout1, typeof(CS.GridLayout)))
  table.insert(self.mView.mLayoutlist, getcomponent(self.mView.mTrans_layout2, typeof(CS.GridLayout)))
  table.insert(self.mView.mLayoutlist, getcomponent(self.mView.mTrans_layout3, typeof(CS.GridLayout)))
  self.mView.mBtn_Fuel.enabled = true
  setactive(self.mView.mTrans_GrpDetailsLeft, false)
  self.mView.mUIBlockHelper:InitBlocker(self.mView.mTrans_GrpDetailsLeft, root, function()
    self:OnClickBlocker()
  end)
  self.mView.mAnimator:SetInteger("UAVInfo", 0)
  self.mView.mAnimator:SetInteger("List", 3)
  UAVUtility:InitData()
  local nowGrade = NetCmdUavData:GetUavData().UavGrade
  local fuelLimit = TableData.listUavAdvanceDatas:GetDataById(nowGrade).fuel
  self.mView.mText_NowNum.text = fuelLimit
  self.mView.mImg_Progress1.fillAmount = 1
  self:InitInfo()
  self:AddListener()
  local armequipStateList = NetCmdUavData:GetArmEquipState()
  self:UpdateRightSkillState(armequipStateList)
  self:UpdateBottomSkillState()
  self:UpdateUavMainViewInfo()
  UIUtils.GetButtonListener(self.mView.mBtn_CommandCenter.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_Close.gameObject).onClick = function()
    self:OnClickClose()
  end
  self.mView.mBtn_Fuel.onClick:AddListener(function()
    self:OnClickFuel()
  end)
  self:RegistrationKeyboard(KeyCode.Escape, self.mView.mBtn_Close)
  UAVUtility.IsPlayAnim = false
  self.mAnim_assemble_skin = GameObject.Find("UAVhanger_assemble_skin"):GetComponent("Animator")
  self.mAnim_drone_skin = GameObject.Find("DroneDefault_skin 1"):GetComponent("Animator")
  self.mGo_SceneEffect = GameObject.Find("_SceneEffect")
  local parent = self.mGo_SceneEffect.transform:Find("UAVhangerFX_02")
  local effect
  if self:CheckPlatform(CS.PlatformSetting.PlatformType.Mobile) then
    effect = parent:Find("UAVhangerFX_02_mobile").gameObject
  elseif self:CheckPlatform(CS.PlatformSetting.PlatformType.PC) then
    effect = parent:Find("UAVhangerFX_02_pc").gameObject
  elseif self:CheckPlatform(CS.PlatformSetting.PlatformType.NintendoSwitch) then
    effect = parent:Find("UAVhangerFX_02_mobile").gameObject
  elseif self:CheckPlatform(CS.PlatformSetting.PlatformType.PlayStation) then
    effect = parent:Find("UAVhangerFX_02_pc").gameObject
  end
  setactive(effect, true)
end
function UIUAVPanel:OnShowStart()
end
function UIUAVPanel:OnBackFrom()
  local armequipStateList = NetCmdUavData:GetArmEquipState()
  self:UpdateRightSkillState(armequipStateList)
  self:UpdateUavMainViewInfo()
  self:UpdateBottomSkillState()
end
function UIUAVPanel:OnTop()
  local armequipStateList = NetCmdUavData:GetArmEquipState()
  self:UpdateRightSkillState(armequipStateList)
  self:UpdateUavMainViewInfo()
  self:UpdateBottomSkillState()
  self:UpdateLeftAreaInfo()
end
function UIUAVPanel:OnUpdate(deltaTime)
  if self.uavTacticSkillItemTable then
    for i = 1, #self.uavTacticSkillItemTable do
      self.uavTacticSkillItemTable[i]:OnUpdate(deltaTime)
    end
  end
end
function UIUAVPanel:OnClose()
  if self.uavTacticSkillItemTable then
    for i = 1, #self.uavTacticSkillItemTable do
      self.uavTacticSkillItemTable[i]:OnRelease()
    end
  end
  self.uavTacticSkillItemTable = nil
  UAVUtility.NowArmId = -1
  UAVUtility.NowRealBottomArmId = -2
  UAVUtility.NowFakeBottomArmId = -2
  UAVUtility.IsClickUninstall = false
  UAVUtility.NowBottomPos = -1
  UAVUtility.AniState = -1
  self.mAnim_assemble_skin = nil
  self.mAnim_drone_skin = nil
  self.mGo_SceneEffect = nil
  self.levelUpPanel = nil
  self.FuelGetPanel = nil
  self.BreakPanel = nil
  self.mView.mBtn_Fuel.onClick = nil
  self.mView.mUIContainer_Info.onClick = nil
  self.mView = nil
end
function UIUAVPanel:OnRelease()
end
function UIUAVPanel:Close()
  self:OnClickClose()
end
function UIUAVPanel:OnClickFuel()
  local data = {
    [1] = TableData.GetHintById(105034),
    [2] = TableData.GetHintById(105035)
  }
  UIManager.OpenUIByParam(UIDef.SimpleMessageBoxPanel, data)
end
function UIUAVPanel:UpdateInfo()
end
function UIUAVPanel:InitInfo()
  self.mView.mText_UAVName.text = TableData.GetHintById(105009)
  self.mView.mText_HasEquipedSkill.text = TableData.GetHintById(105010)
  self.mView.mText_UAVInfo.text = TableData.GetHintById(105039)
  self.mView.mText_FuelName.text = TableData.GetHintById(105008)
  self.mView.mText_RangeName.text = TableData.GetHintById(105013)
  self.mView.mText_OilCost.text = TableData.GetHintById(105011)
  self.attributelist = List:New()
  self.attributelist:Add(TableData.listLanguagePropertyDatas:GetDataById(7).ShowName.str)
  self.attributelist:Add(TableData.listLanguagePropertyDatas:GetDataById(9).ShowName.str)
  self.attributelist:Add(TableData.listLanguagePropertyDatas:GetDataById(32).ShowName.str)
  self.attributelist:Add(TableData.listLanguagePropertyDatas:GetDataById(29).ShowName.str)
  self.attributelist:Add(TableData.listLanguagePropertyDatas:GetDataById(28).ShowName.str)
end
function UIUAVPanel:UpdateRightSkillState(armequiplist)
  if self.uavTacticSkillItemTable then
    for i = 1, #self.uavTacticSkillItemTable do
      self.uavTacticSkillItemTable[i]:OnRelease()
    end
  end
  for i = 0, self.mView.mTrans_RightSkillContent.childCount - 1 do
    gfdestroy(self.mView.mTrans_RightSkillContent:GetChild(i))
  end
  self.uavTacticSkillItemTable = {}
  local unequipnum = 0
  for i = 0, armequiplist.Count - 1 do
    local armid = armequiplist[i]
    if armid == 0 then
      unequipnum = unequipnum + 1
    else
      local instObj = instantiate(UIUtils.GetGizmosPrefab("UAV/UAVTacticSkillItemV2.prefab", self), self.mView.mTrans_RightSkillContent)
      local item = UAVTacticSkillItem.New()
      local nowGrade = NetCmdUavData:GetUavData().UavGrade
      local fuelLimit = TableData.listUavAdvanceDatas:GetDataById(nowGrade).fuel
      item:InitCtrl(instObj.transform)
      item:InitData(armid, fuelLimit, self)
      table.insert(self.uavTacticSkillItemTable, item)
    end
  end
  if unequipnum == 3 then
    setactive(self.mView.mTrans_NoEquip.gameObject, true)
  else
    setactive(self.mView.mTrans_NoEquip.gameObject, false)
  end
end
function UIUAVPanel:UpdateBottomSkillState(IsRefreshWithClickLeftArmList)
  local grade = NetCmdUavData:GetUavGrade()
  local armequiplist = NetCmdUavData:GetArmEquipState()
  for i = 0, self.mView.mTrans_Skill.childCount - 1 do
    gfdestroy(self.mView.mTrans_Skill:GetChild(i))
  end
  local uavarmdic = TableData.GetUavArmsData()
  local num = 0
  local EquipNum = 0
  local advData = TableData.listUavAdvanceDatas:GetDataById(grade)
  EquipNum = advData.equip_num
  if IsRefreshWithClickLeftArmList then
    self.fakearmequiplist:Clear()
    for i = 0, armequiplist.Count - 1 do
      self.fakearmequiplist:Add(armequiplist[i])
    end
    self.fakearmequiplist[UAVUtility.NowBottomPos + 1] = UAVUtility.NowArmId
    UAVUtility.NowFakeBottomArmId = UAVUtility.NowArmId
    for i = 0, 2 do
      num = num + 1
      if EquipNum >= num then
        local instObj = instantiate(UIUtils.GetGizmosPrefab("UAV/UAVPartsItemV2.prefab", self), self.mView.mTrans_Skill)
        local item = UAVPartsItem.New()
        item:InitCtrl(instObj.transform, self.mView)
        item:InitData(self.fakearmequiplist[i + 1], true, i, self:IsShowBottomBtnRedPoint(self.fakearmequiplist[i + 1]), self)
      else
        local instObj = instantiate(UIUtils.GetGizmosPrefab("UAV/UAVPartsItemV2.prefab", self), self.mView.mTrans_Skill)
        local item = UAVPartsItem.New()
        item:InitCtrl(instObj.transform, self.mView)
        item:InitData(num, false, i, nil, self)
      end
    end
    local templist = List:New()
    for i = 1, self.fakearmequiplist:Count() do
      templist:Add(self.fakearmequiplist[i])
    end
    templist:Sort()
    local costnum = 0
    local lastnum = 0
    local nownum = 0
    for i = 1, templist:Count() do
      if templist[i] ~= 0 then
        lastnum = nownum
        nownum = templist[i]
        costnum = costnum + uavarmdic[templist[i]].Cost
        if nownum == lastnum then
          costnum = costnum - uavarmdic[nownum].Cost
        end
      end
    end
    for i = 0, self.mView.mTrans_Cost.childCount - 1 do
      gfdestroy(self.mView.mTrans_Cost:GetChild(i))
    end
    local NowCostLimit = 0
    NowCostLimit = advData.cost
    local IsNeedRed = costnum > NowCostLimit
    for i = 1, NowCostLimit do
      local script = self.mView.mTrans_Cost:GetComponent(typeof(CS.ScrollListChild))
      local itemobj = instantiate(script.childItem.gameObject, self.mView.mTrans_Cost)
      if costnum >= i then
        setactive(itemobj.transform:Find("GrpState/Trans_On"), true)
        setactive(itemobj.transform:Find("GrpState/Trans_Off"), false)
      end
      if IsNeedRed then
        itemobj.transform:Find("GrpState/Trans_On"):GetComponent(typeof(CS.UnityEngine.UI.Image)).color = ColorUtils.RedColor
      end
    end
    return
  end
  for i = 0, 2 do
    num = num + 1
    if EquipNum >= num then
      local instObj = instantiate(UIUtils.GetGizmosPrefab("UAV/UAVPartsItemV2.prefab", self), self.mView.mTrans_Skill)
      local item = UAVPartsItem.New()
      item:InitCtrl(instObj.transform, self.mView)
      item:InitData(armequiplist[i], true, i, self:IsShowBottomBtnRedPoint(armequiplist[i]), self)
    else
      local instObj = instantiate(UIUtils.GetGizmosPrefab("UAV/UAVPartsItemV2.prefab", self), self.mView.mTrans_Skill)
      local item = UAVPartsItem.New()
      item:InitCtrl(instObj.transform, self.mView)
      item:InitData(num, false, i, nil, self)
    end
  end
  local armequiplist = NetCmdUavData:GetArmEquipState()
  local uavarmdic = TableData.GetUavArmsData()
  local costnum = 0
  for i = 0, armequiplist.Count - 1 do
    if armequiplist[i] ~= 0 then
      costnum = costnum + uavarmdic[armequiplist[i]].Cost
    end
  end
  for i = 0, self.mView.mTrans_Cost.childCount - 1 do
    gfdestroy(self.mView.mTrans_Cost:GetChild(i))
  end
  local NowCostLimit = 0
  NowCostLimit = advData.cost
  for i = 1, NowCostLimit do
    local script = self.mView.mTrans_Cost:GetComponent(typeof(CS.ScrollListChild))
    local itemobj = instantiate(script.childItem.gameObject, self.mView.mTrans_Cost)
    if costnum >= i then
      setactive(itemobj.transform:Find("GrpState/Trans_On"), true)
      setactive(itemobj.transform:Find("GrpState/Trans_Off"), false)
    end
  end
end
function UIUAVPanel:UpdateUavMainViewInfo()
  local nowgrade = NetCmdUavData:GetUavData().UavGrade
  local fuelLimit = TableData.listUavAdvanceDatas:GetDataById(nowgrade).fuel
  self.mView.mText_NowNum.text = fuelLimit
  self.mView.mImg_Progress1.fillAmount = 1
  local uavadvancedata = TableData.listUavAdvanceDatas:GetDataById(nowgrade)
  local itemscript = self.mView.mTrans_AttributeList:GetComponent(typeof(CS.ScrollListChild))
  local properid = uavadvancedata.PropertyId
  local PropertyData = TableData.listPropertyDatas:GetDataById(properid)
  for i = 0, self.mView.mTrans_AttributeList.childCount - 1 do
    gfdestroy(self.mView.mTrans_AttributeList:GetChild(i))
  end
  self.mView.mUIContainer_Info.onClick:AddListener(function()
    self:OnClickUAVInfoIcon()
  end)
  self.mView.mText_UAVLevel.text = "LV." .. nowgrade .. "/" .. TableData.GlobalSystemData.UavMaxLv
  local instObj = instantiate(itemscript.childItem, self.mView.mTrans_AttributeList)
  local item = UAVAttributeItem.New()
  item:InitCtrl(instObj.transform)
  item:InitData(self.attributelist[1], PropertyData.Pow)
  local instObj = instantiate(itemscript.childItem, self.mView.mTrans_AttributeList)
  local item = UAVAttributeItem.New()
  item:InitCtrl(instObj.transform)
  item:InitData(self.attributelist[2], PropertyData.MaxHp)
  local instObj = instantiate(itemscript.childItem, self.mView.mTrans_AttributeList)
  local item = UAVAttributeItem.New()
  item:InitCtrl(instObj.transform)
  item:InitData(self.attributelist[3], PropertyData.shield_armor)
  local instObj = instantiate(itemscript.childItem, self.mView.mTrans_AttributeList)
  local item = UAVAttributeItem.New()
  item:InitCtrl(instObj.transform)
  item:InitData(self.attributelist[4], PropertyData.SuppressValue)
  local instObj = instantiate(itemscript.childItem, self.mView.mTrans_AttributeList)
  local item = UAVAttributeItem.New()
  item:InitCtrl(instObj.transform)
  item:InitData(self.attributelist[5], PropertyData.MaxWillValue)
  setactive(self.mView.mTrans_LevelUp.gameObject, false)
  setactive(self.mView.mTrans_Break.gameObject, false)
  setactive(self.mView.mTrans_MaxLevel.gameObject, false)
  setactive(self.redtrans1, false)
  setactive(self.redtrans2, false)
  if nowgrade == self.Const.MaxLevel then
    setactive(self.mView.mTrans_LevelUp.gameObject, false)
    setactive(self.mView.mTrans_Break.gameObject, false)
    setactive(self.mView.mTrans_MaxLevel.gameObject, true)
  elseif nowgrade < self.Const.MaxLevel then
    setactive(self.mView.mTrans_LevelUp.gameObject, false)
    setactive(self.mView.mTrans_Break.gameObject, true)
    if self:IsShowBreakRedPoint() then
      setactive(self.redtrans2, true)
    end
    setactive(self.mView.mTrans_MaxLevel.gameObject, false)
  else
    setactive(self.mView.mTrans_LevelUp.gameObject, true)
    setactive(self.mView.mTrans_Break.gameObject, false)
    setactive(self.mView.mTrans_MaxLevel.gameObject, false)
  end
end
function UIUAVPanel:getMaxGrade()
  local dataList = TableData.listUavAdvanceDatas:GetList()
  dataList:Sort()
end
function UIUAVPanel:UpdateRightAreaInfo(IsShowSkillInfo)
  if IsShowSkillInfo ~= nil then
    setactive(self.mView.mTrans_RightSKiillInfo.gameObject, true)
    self.mView.mAnimator:SetInteger("UAVInfo", 3)
    return
  end
  setactive(self.mView.mTrans_ParsEmpty.gameObject, UAVUtility.NowArmId == 0)
  if UAVUtility.NowArmId == 0 then
    return
  end
  local nowarmid = UAVUtility.NowArmId
  local armtabledata = TableData.GetUavArmsData()
  local armequiped = NetCmdUavData:GetArmEquipState()
  local uavarmdic = NetCmdUavData:GetUavArmData()
  local subid = string.sub(armtabledata[nowarmid].SkillSet, 1, 3)
  local battleskilldata
  if uavarmdic:ContainsKey(nowarmid) == false then
    battleskilldata = TableData.GetUarArmRevelantData(subid .. 1)
  else
    battleskilldata = TableData.GetUarArmRevelantData(subid .. uavarmdic[nowarmid].Level)
  end
  self.IsClickSave = false
  self.mView.mText_SkllName.text = armtabledata[nowarmid].Name.str
  local maxLevel = UAVUtility.GetUavArmMaxLevel(armtabledata[nowarmid].uav_arm_level_cost)
  if uavarmdic:ContainsKey(nowarmid) then
    self.mView.mText_SkillLevel.text = "LV." .. uavarmdic[nowarmid].Level .. "/" .. tostring(maxLevel)
    setactive(self.mView.mTrans_ArmLock, false)
  else
    self.mView.mText_SkillLevel.text = "LV.1/" .. tostring(maxLevel)
    setactive(self.mView.mTrans_ArmLock, true)
  end
  self.mView.mText_RangeName.text = TableData.GetHintById(105013)
  local attackTypeId = armtabledata[nowarmid].AttackType
  local attackDataRow = TableData.listLanguageElementDatas:GetDataById(attackTypeId)
  if attackDataRow then
    local attackTypeIcon = attackDataRow.Icon
    local attackTypeName = attackDataRow.Name.str
    local attackTypeColor = attackDataRow.Color
    self.mView.mImage_AttackType.sprite = UIUtils.GetIconSprite("Icon/Element", attackTypeIcon)
    self.mView.mText_AttackType.text = attackTypeName
  else
    gferror("LanguageElement表没有找Id: " .. attackTypeId)
  end
  local shieldTypeId = armtabledata[nowarmid].ShieldType
  local shieldDataRow = TableData.listLanguageShieldDatas:GetDataById(shieldTypeId)
  if shieldDataRow then
    local shieldTypeIcon = shieldDataRow.Icon
    local shieldTypeName = shieldDataRow.Name.str
    local shieldTypeColor = shieldDataRow.Color
    self.mView.mImage_DefenseType.sprite = UIUtils.GetIconSprite("Icon/Attribute", shieldTypeIcon)
    self.mView.mText_DefenseType.text = shieldTypeName
  else
    gferror("LanguageShield表没有找Id: " .. shieldTypeId)
  end
  self.mView.mText_OilCost.text = TableData.GetHintById(105011)
  self.mView.mText_OilCostNum.text = battleskilldata.TeCost
  self.mView.mText_UseTimesNum.text = battleskilldata.Stock
  self.mView.mText_SkillDes.text = battleskilldata.Detail.str
  self.mView.mImage_RightLeftUpIcon.sprite = UIUtils.GetIconSprite("Icon/Skill", battleskilldata.Icon)
  self.mView.mImage_RightSkillIcon.sprite = UIUtils.GetIconSprite("Icon/UAV3DModelIcon", "Icon_UAV3DModelIcon_" .. armtabledata[nowarmid].ResCode)
  self.mView.mText_RightCostNum.text = armtabledata[nowarmid].Cost
  self:UpdateRightBtnState()
end
function UIUAVPanel:IsShowLeftListRedPoint(armid, type)
  local uavarmdic = NetCmdUavData:GetUavArmData()
  local armdata = TableData.GetUavArmsData()
  local levelupunlockmatNum = NetCmdItemData:GetNetItemCount(armdata[armid].ItemId)
  if type == 1 then
    if 1 <= levelupunlockmatNum and uavarmdic:ContainsKey(armid) == false then
      return true
    end
  elseif type == 2 then
    local armtabledata = TableData.GetUavArmsData()
    local maxArmLevel = UAVUtility.GetUavArmMaxLevel(armtabledata[armid].uav_arm_level_cost)
    if uavarmdic[armid].Level == maxArmLevel then
      return false
    end
    local upgradecost = armdata[armid].UpgradeCost[uavarmdic[armid].Level - 1]
    local uavarmdic = NetCmdUavData:GetUavArmData()
    local armDataRow = TableData.listUavArmsDatas:GetDataById(armid)
    local uavArmLevelCostId = armDataRow.uav_arm_level_cost
    local costArr = UAVUtility:GetLevelUpCost(uavArmLevelCostId, uavarmdic[armid].Level)
    if costArr == 0 then
      return false
    end
    local levelUpCostItemId = costArr[0]
    local levelupNum = NetCmdItemData:GetNetItemCount(levelUpCostItemId)
    if upgradecost <= levelupNum then
      return true
    end
  end
  return false
end
function UIUAVPanel:IsShowBottomBtnRedPoint(armId)
  if not armId or armId == 0 then
    return false
  end
  local netArmData = NetCmdUavData:GetUavArmDataByArmId(armId)
  if not netArmData then
    return false
  end
  local armtabledata = TableData.GetUavArmsData()
  local maxArmLevel = UAVUtility.GetUavArmMaxLevel(armtabledata[armId].uav_arm_level_cost)
  if netArmData.Level == maxArmLevel then
    return false
  end
  local armDataRow = TableData.listUavArmsDatas:GetDataById(armId)
  local uavArmLevelCostId = armDataRow.uav_arm_level_cost
  local costArr = UAVUtility:GetLevelUpCost(uavArmLevelCostId, netArmData.Level)
  if costArr == 0 then
    return false
  end
  local levelUpCostItemId = costArr[0]
  local upGradeCost = costArr[1]
  local hasCount = NetCmdItemData:GetNetItemCount(levelUpCostItemId)
  if upGradeCost >= hasCount then
    return false
  end
  return true
end
function UIUAVPanel:IsShowBreakRedPoint()
  local nowgrade = NetCmdUavData:GetUavData().UavGrade
  local uavadvancedata = TableData.listUavAdvanceDatas:GetDataById(nowgrade + 1)
  local cashItem = NetCmdItemData:GetResItemCount(2)
  local breakItem = NetCmdItemData:GetNetItemCount(uavadvancedata.uav_material[0])
  if nowgrade < self.Const.MaxLevel and cashItem >= uavadvancedata.uav_cash and 1 <= breakItem then
    return true
  end
  return false
end
function UIUAVPanel:SetAnim()
  setactive(self.mView.mTrans_RightSKiillInfo.gameObject, true)
  self.mView.mAnimator:SetInteger("UAVInfo", 2)
end
function UIUAVPanel:IsShowRedPointOnBtn(armid, type)
  local uavarmdic = NetCmdUavData:GetUavArmData()
  local armdata = TableData.GetUavArmsData()
  local levelupunlockmatNum = NetCmdItemData:GetNetItemCount(armdata[armid].ItemId)
  if type == 1 then
    if 1 <= levelupunlockmatNum then
      return true
    end
  elseif type == 2 then
    local armtabledata = TableData.GetUavArmsData()
    local maxArmLevel = UAVUtility.GetUavArmMaxLevel(armtabledata[armid].uav_arm_level_cost)
    if uavarmdic[armid].Level == maxArmLevel then
      return false
    end
    local upgradecost = armdata[armid].UpgradeCost[uavarmdic[armid].Level - 1]
    local uavarmdic = NetCmdUavData:GetUavArmData()
    local armDataRow = TableData.listUavArmsDatas:GetDataById(armid)
    local uavArmLevelCostId = armDataRow.uav_arm_level_cost
    local costArr = UAVUtility:GetLevelUpCost(uavArmLevelCostId, uavarmdic[armid].Level)
    if costArr == 0 then
      return false
    end
    local levelUpCostItemId = costArr[0]
    local levelupNum = NetCmdItemData:GetNetItemCount(levelUpCostItemId)
    if upgradecost <= levelupNum then
      return true
    end
  end
  return false
end
function UIUAVPanel:UpdateLeftAreaInfo(IsNeedSort)
  for i = 0, self.mView.mTrans_LeftSkillListContent.childCount - 1 do
    gfdestroy(self.mView.mTrans_LeftSkillListContent:GetChild(i))
  end
  setactive(self.mView.mTrans_LeftSkillList.gameObject, true)
  local armtabledata = TableData.GetUavArmsData()
  local uavarmdic = NetCmdUavData:GetUavArmData()
  local equipstate = NetCmdUavData:GetArmEquipState()
  if IsNeedSort then
    self.sortlist = List:New()
    for k, v in pairs(armtabledata) do
      local data = {}
      data.armid = k
      if equipstate:Contains(k) and k == UAVUtility.NowFakeBottomArmId then
        data.sort = 0
      end
      if equipstate:Contains(k) and k ~= UAVUtility.NowFakeBottomArmId then
        data.sort = 1
      end
      if uavarmdic:ContainsKey(k) and equipstate:Contains(k) == false then
        data.sort = 2
      end
      if uavarmdic:ContainsKey(k) == false then
        data.sort = 3
      end
      table.insert(self.sortlist, data)
    end
    table.sort(self.sortlist, function(a, b)
      if a.sort == b.sort then
        return a.armid < b.armid
      end
      return a.sort < b.sort
    end)
    for i = 1, self.sortlist:Count() do
      local instObj = instantiate(UIUtils.GetGizmosPrefab("UAV/UAVPartsListItemV2.prefab", self), self.mView.mTrans_LeftSkillListContent)
      local item = UAVPartsListItem.New()
      item:InitCtrl(instObj.transform)
      if 3 > self.sortlist[i].sort then
        item:InitData(self.sortlist[i].armid, UAVUtility.NowArmId, self:IsShowLeftListRedPoint(self.sortlist[i].armid, 2), self)
      else
        item:InitData(self.sortlist[i].armid, UAVUtility.NowArmId, self:IsShowLeftListRedPoint(self.sortlist[i].armid, 1), self)
      end
    end
  else
    if not self.sortlist then
      return
    end
    for i = 1, self.sortlist:Count() do
      local instObj = instantiate(UIUtils.GetGizmosPrefab("UAV/UAVPartsListItemV2.prefab", self), self.mView.mTrans_LeftSkillListContent)
      local item = UAVPartsListItem.New()
      item:InitCtrl(instObj.transform)
      if 3 > self.sortlist[i].sort then
        item:InitData(self.sortlist[i].armid, UAVUtility.NowArmId, self:IsShowLeftListRedPoint(self.sortlist[i].armid, 2), self)
      else
        item:InitData(self.sortlist[i].armid, UAVUtility.NowArmId, self:IsShowLeftListRedPoint(self.sortlist[i].armid, 1), self)
      end
    end
  end
  if UAVUtility.NowArmId == 0 then
    self.mView.mAnimator:SetInteger("UAVInfo", 3)
  end
  if UAVUtility.OnlyRefreshOnce then
    local fadeManager = self.mView.mTrans_LeftSkillListContent:GetComponent(typeof(CS.MonoScrollerFadeManager))
    fadeManager:InitFade()
    UAVUtility.OnlyRefreshOnce = false
  end
end
function UIUAVPanel:AddListener()
  self.mView.mToggle_Contrast.onValueChanged:AddListener(function(isOn)
    self:OnClickContrast(isOn)
  end)
  self.mView.mToggle_Range.onValueChanged:AddListener(function(ison)
    if ison then
      setactive(self.mView.mTrans_SkillRange, true)
      local nowarmid = UAVUtility.NowArmId
      local armtabledata = TableData.GetUavArmsData()
      local armequiped = NetCmdUavData:GetArmEquipState()
      local uavarmdic = NetCmdUavData:GetUavArmData()
      local subid = string.sub(armtabledata[nowarmid].SkillSet, 1, 3)
      local battleskilldata
      if uavarmdic:ContainsKey(nowarmid) then
        battleskilldata = TableData.GetUarArmRevelantData(subid .. uavarmdic[nowarmid].Level)
      else
        battleskilldata = TableData.GetUarArmRevelantData(subid .. 1)
      end
      local skillrangedata = TableData.GetSkillData(battleskilldata.SkillList[0])
      CS.SkillRangeUIHelper.SetSkillRange(self.mView.mLayoutlist, 1, skillrangedata)
    else
      setactive(self.mView.mTrans_SkillRange, false)
    end
  end)
  local BtnReplace = UIUtils.GetTempBtn(self.mView.mTrans_BtnReplace)
  local BtnUninstall = UIUtils.GetTempBtn(self.mView.mTrans_BtnUnistall)
  local BtnEquip = UIUtils.GetTempBtn(self.mView.mTrans_BtnEquip)
  local BtnPowerUp = UIUtils.GetTempBtn(self.mView.mTrans_BtnPowerUp)
  local BtnUnlock = UIUtils.GetTempBtn(self.mView.mTrans_BtnUnLock)
  UIUtils.GetButtonListener(self.mView.mBtn_CloseRange.gameObject).onClick = function()
    self.mView.mToggle_Range.isOn = false
  end
  UIUtils.GetButtonListener(BtnReplace.gameObject).onClick = function()
    self:OnClickReplace(UAVUtility.NowFakeBottomArmId, UAVUtility.NowBottomPos)
  end
  UIUtils.GetButtonListener(BtnUninstall.gameObject).onClick = function()
    self:OnClickUninstall(UAVUtility.NowArmId)
  end
  UIUtils.GetButtonListener(BtnEquip.gameObject).onClick = function()
    self:OnClickEquip(UAVUtility.NowArmId, UAVUtility.NowBottomPos)
  end
  UIUtils.GetButtonListener(BtnPowerUp.gameObject).onClick = function()
    self:OnClickPowerUp()
  end
  UIUtils.GetButtonListener(BtnUnlock.gameObject).onClick = function()
    self:OnClickUnlock(UAVUtility.NowArmId)
  end
  local btnlevelup = UIUtils.GetTempBtn(self.mView.mTrans_LevelUp)
  local btnbreak = UIUtils.GetTempBtn(self.mView.mTrans_Break)
  self.btnlevelup = btnlevelup
  self.btnbreak = btnbreak
  self.btnpowerup = BtnPowerUp
  self.btnunlock = BtnUnlock
  self.redtrans1 = self.btnlevelup.transform:Find("Root/Trans_RedPoint")
  local script1 = self.redtrans1:GetComponent(typeof(CS.ScrollListChild))
  instantiate(script1.childItem.gameObject, self.redtrans1)
  self.redtrans2 = self.btnbreak.transform:Find("Root/Trans_RedPoint")
  local script2 = self.redtrans2:GetComponent(typeof(CS.ScrollListChild))
  instantiate(script2.childItem.gameObject, self.redtrans2)
  self.redtrans3 = self.btnpowerup.transform:Find("Root/Trans_RedPoint")
  local script3 = self.redtrans3:GetComponent(typeof(CS.UICommonContainer))
  local obj = script3:InstantiateObj()
  setparent(self.redtrans3, obj)
  self.redtrans4 = self.btnunlock.transform:Find("Root/Trans_RedPoint")
  local script4 = self.redtrans4:GetComponent(typeof(CS.ScrollListChild))
  instantiate(script4.childItem.gameObject, self.redtrans4)
  UIUtils.GetButtonListener(btnlevelup.gameObject).onClick = function()
    self:OnClickBtnLevelUp()
  end
  UIUtils.GetButtonListener(btnbreak.gameObject).onClick = function()
    self:OnClickBtnBreak()
  end
end
function UIUAVPanel:UpdateRightBtnState()
  local armtabledata = TableData.GetUavArmsData()
  local armequiped = NetCmdUavData:GetArmEquipState()
  local uavarmdic = NetCmdUavData:GetUavArmData()
  setactive(self.mView.mTrans_BtnReplace.gameObject, false)
  setactive(self.mView.mTrans_BtnUnistall.gameObject, false)
  setactive(self.mView.mTrans_BtnEquip.gameObject, false)
  setactive(self.mView.mTrans_BtnPowerUp.gameObject, false)
  setactive(self.mView.mTrans_BtnUnLock.gameObject, false)
  setactive(self.mView.mTrans_ArmMaxLevel.gameObject, false)
  for i = 0, self.mView.mTrans_UnlockItem.childCount - 1 do
    gfdestroy(self.mView.mTrans_UnlockItem:GetChild(i))
  end
  setactive(self.redtrans3, false)
  setactive(self.redtrans4, false)
  setactive(self.mView.mToggle_Contrast, false)
  if uavarmdic:ContainsKey(UAVUtility.NowArmId) and UAVUtility.NowRealBottomArmId ~= UAVUtility.NowArmId and UAVUtility.NowRealBottomArmId ~= 0 then
    setactive(self.mView.mTrans_BtnReplace.gameObject, true)
    setactive(self.mView.mToggle_Contrast, true)
  end
  if uavarmdic:ContainsKey(UAVUtility.NowArmId) and UAVUtility.NowArmId == UAVUtility.NowRealBottomArmId then
    setactive(self.mView.mTrans_BtnUnistall.gameObject, true)
  end
  if uavarmdic:ContainsKey(UAVUtility.NowArmId) and UAVUtility.NowRealBottomArmId == 0 then
    setactive(self.mView.mTrans_BtnEquip.gameObject, true)
  end
  local maxArmLevel = UAVUtility.GetUavArmMaxLevel(armtabledata[UAVUtility.NowArmId].uav_arm_level_cost)
  if uavarmdic:ContainsKey(UAVUtility.NowArmId) and maxArmLevel > uavarmdic[UAVUtility.NowArmId].Level then
    setactive(self.mView.mTrans_BtnPowerUp.gameObject, true)
    if self:IsShowRedPointOnBtn(UAVUtility.NowArmId, 2) then
      setactive(self.redtrans3, true)
    end
  end
  if not uavarmdic:ContainsKey(UAVUtility.NowArmId) then
    setactive(self.mView.mTrans_BtnUnLock.gameObject, true)
    if self:IsShowRedPointOnBtn(UAVUtility.NowArmId, 1) then
      setactive(self.redtrans4, true)
    end
    local script = self.mView.mTrans_UnlockItem:GetComponent(typeof(CS.ScrollListChild))
    local itemobj = instantiate(script.childItem.gameObject, self.mView.mTrans_UnlockItem)
    local itembtn = itemobj.transform:GetComponent(typeof(CS.UnityEngine.UI.Button))
    local itemtext = itemobj.transform:Find("Trans_GrpNum/ImgBg/Text_Num"):GetComponent(typeof(CS.UnityEngine.UI.Text))
    local itemimg = UIUtils.GetImage(itemobj, "GrpItem/Img_Item")
    local itemrankimg = UIUtils.GetImage(itemobj, "GrpBg/Img_Bg")
    local itemData
    local NowPartsNum = NetCmdItemData:GetNetItemCount(armtabledata[UAVUtility.NowArmId].ItemId)
    local num = armtabledata[UAVUtility.NowArmId].ItemId
    itemData = TableData.GetItemData(armtabledata[UAVUtility.NowArmId].ItemId)
    TipsManager.Add(itemobj.gameObject, itemData, nil, true)
    itemimg.sprite = UIUtils.GetIconSprite("Icon/" .. itemData.icon_path, itemData.icon)
    itemrankimg.sprite = IconUtils.GetQuiltyByRank(itemData.rank)
    local NowUnLockCost = armtabledata[UAVUtility.NowArmId].UnlockNum
    if NowPartsNum < NowUnLockCost then
      itemtext.text = string.format("<color=#FF5E41>%d</color>/<color=#FFFFFF>%d</color>", NowPartsNum, NowUnLockCost)
    else
      itemtext.text = NowPartsNum .. "/" .. NowUnLockCost
    end
  end
  local maxLevel = UAVUtility.GetUavArmMaxLevel(armtabledata[UAVUtility.NowArmId].uav_arm_level_cost)
  if uavarmdic:ContainsKey(UAVUtility.NowArmId) and uavarmdic[UAVUtility.NowArmId].Level == maxLevel then
    setactive(self.mView.mTrans_ArmMaxLevel.gameObject, true)
  end
end
function UIUAVPanel:OnClickSave()
  if self.SaveType == 1 then
    self.IsClickSave = true
    NetCmdUavData:SendUavArmInstallData(self.UnInstallPos, 0, function(ret)
      if ret == ErrorCodeSuc then
        UAVUtility.NowArmId = 0
        UAVUtility.NowRealBottomArmId = 0
        UAVUtility.NowFakeBottomArmId = 0
        self:UpdateBottomSkillState()
        self:UpdateRightAreaInfo(true)
        self:UpdateLeftAreaInfo()
      end
    end)
  end
end
function UIUAVPanel:OnClickReplace(desarmid, ReplacePos)
  local armequiplist = NetCmdUavData:GetArmEquipState()
  local tempequiplist = List:New()
  for i = 0, armequiplist.Count - 1 do
    tempequiplist:Add(armequiplist[i])
  end
  tempequiplist[ReplacePos + 1] = desarmid
  local uavarmlist = TableData.GetUavArmsData()
  local costnum = 0
  local NetUavGrade = NetCmdUavData:GetUavTotalData().Uav.UavGrade
  local uavadvancedata = TableData.listUavAdvanceDatas:GetDataById(NetUavGrade)
  local NowCostLimit = uavadvancedata.cost
  local templist = List:New()
  for i = 1, tempequiplist:Count() do
    templist:Add(tempequiplist[i])
  end
  templist:Sort()
  local lastnum = 0
  local nownum = 0
  for i = 1, templist:Count() do
    if templist[i] ~= 0 then
      lastnum = nownum
      nownum = templist[i]
      costnum = costnum + uavarmlist[templist[i]].Cost
      if nownum == lastnum then
        costnum = costnum - uavarmlist[nownum].Cost
      end
    end
  end
  if NowCostLimit < costnum then
    local hint = TableData.GetHintById(105023)
    CS.PopupMessageManager.PopupString(hint)
    return
  end
  self:PlaySkinAnim()
  NetCmdUavData:SendUavArmInstallData(ReplacePos, desarmid, function(ret)
    if ret == ErrorCodeSuc then
      UAVUtility.NowRealBottomArmId = desarmid
      UAVUtility.NowFakeBottomArmId = desarmid
      self:UpdateBottomSkillState()
      self:UpdateLeftAreaInfo()
      self:UpdateRightBtnState()
      PopupMessageManager.PopupPositiveString(TableData.GetHintById(105041))
    end
  end)
end
function UIUAVPanel:OnClickUninstall(uninstallarmid)
  local restarmnum = 0
  local armequiplist = NetCmdUavData:GetArmEquipState()
  local tempequiplist = List:New()
  for i = 0, armequiplist.Count - 1 do
    tempequiplist:Add(armequiplist[i])
  end
  for i = 0, armequiplist.Count - 1 do
    if armequiplist[i] ~= 0 then
      restarmnum = restarmnum + 1
    end
  end
  if restarmnum == 1 then
    CS.PopupMessageManager.PopupString(TableData.GetHintById(105005))
    return
  end
  self:PlaySkinAnim()
  UAVUtility.IsClickUninstall = true
  for i = 0, armequiplist.Count - 1 do
    if armequiplist[i] == uninstallarmid then
      setactive(self.mView.mTrans_Skill:GetChild(i):Find("Trans_GrpItem"), false)
      setactive(self.mView.mTrans_Skill:GetChild(i):Find("Trans_GrpAdd"), true)
      self.UnInstallPos = i
      self.SaveType = 1
      tempequiplist[i + 1] = 0
      break
    end
  end
  for i = 0, self.mView.mTrans_Cost.childCount - 1 do
    gfdestroy(self.mView.mTrans_Cost:GetChild(i))
  end
  local uavarmdic = TableData.GetUavArmsData()
  local costnum = 0
  for i = 1, tempequiplist:Count() do
    if tempequiplist[i] ~= 0 then
      costnum = costnum + uavarmdic[tempequiplist[i]].Cost
    end
  end
  local NetUavGrade = NetCmdUavData:GetUavTotalData().Uav.UavGrade
  local uavadvancedata = TableData.listUavAdvanceDatas:GetDataById(NetUavGrade)
  local NowCostLimit = uavadvancedata.Cost
  for i = 1, NowCostLimit do
    local script = self.mView.mTrans_Cost:GetComponent(typeof(CS.ScrollListChild))
    local itemobj = instantiate(script.childItem.gameObject, self.mView.mTrans_Cost)
    if i <= costnum then
      setactive(itemobj.transform:Find("GrpState/Trans_On"), true)
    end
  end
  NetCmdUavData:SendUavArmInstallData(self.UnInstallPos, 0, function(ret)
    if ret == ErrorCodeSuc then
      UAVUtility.NowArmId = 0
      UAVUtility.NowRealBottomArmId = 0
      UAVUtility.NowFakeBottomArmId = 0
      self:UpdateBottomSkillState()
      self:UpdateRightAreaInfo(true)
      self:UpdateLeftAreaInfo()
      PopupMessageManager.PopupPositiveString(TableData.GetHintById(105042))
    end
  end)
end
function UIUAVPanel:OnClickEquip(equiparmid, bottompos)
  local armequiplist = NetCmdUavData:GetArmEquipState()
  local uavarmlist = TableData.GetUavArmsData()
  local uavdata = NetCmdUavData:GetUavData()
  local costnum = 0
  local NetUavGrade = NetCmdUavData:GetUavTotalData().Uav.UavGrade
  local uavadvancedata = TableData.listUavAdvanceDatas:GetDataById(NetUavGrade)
  local NowCostLimit = uavadvancedata.Cost
  local templist = List:New()
  for i = 1, self.fakearmequiplist:Count() do
    templist:Add(self.fakearmequiplist[i])
  end
  templist:Sort()
  local lastnum = 0
  local nownum = 0
  for i = 1, templist:Count() do
    if templist[i] ~= 0 then
      lastnum = nownum
      nownum = templist[i]
      costnum = costnum + uavarmlist[templist[i]].Cost
      if nownum == lastnum then
        costnum = costnum - uavarmlist[nownum].Cost
      end
    end
  end
  if NowCostLimit < costnum then
    local hint = TableData.GetHintById(105023)
    CS.PopupMessageManager.PopupString(hint)
    return
  end
  self:PlaySkinAnim()
  NetCmdUavData:SendUavArmInstallData(bottompos, equiparmid, function(ret)
    if ret == ErrorCodeSuc then
      UAVUtility.NowRealBottomArmId = UAVUtility.NowArmId
      UAVUtility.NowFakeBottomArmId = UAVUtility.NowArmId
      self:UpdateBottomSkillState()
      self:UpdateRightAreaInfo()
      self:UpdateLeftAreaInfo()
      self:UpdateRightBtnState()
      PopupMessageManager.PopupPositiveString(TableData.GetHintById(105040))
    end
  end)
end
function UIUAVPanel:OnClickPowerUp()
  UIManager.OpenUI(UIDef.UIUAVPartsSkillUpDialogPanel, self)
end
function UIUAVPanel:OnClickUnlock(unlockarmid)
  local armtabledata = TableData.GetUavArmsData()
  local uavrevelantdata = NetCmdUavData:GetUavData()
  local uavarmdic = NetCmdUavData:GetUavArmData()
  local armequiplist = NetCmdUavData:GetArmEquipState()
  local partsnum = NetCmdItemData:GetNetItemCount(armtabledata[unlockarmid].ItemId)
  if partsnum < armtabledata[unlockarmid].UnlockNum then
    local uavarmdata = TableData.GetUavArmsData()
    local hint = TableData.GetHintById(225)
    local str = string_format(hint, TableData.GetItemData(uavarmdata[unlockarmid].ItemId).Name.str)
    CS.PopupMessageManager.PopupString(str)
    return
  else
    self:OnUnlockCallBack(unlockarmid)
  end
end
function UIUAVPanel:OnClickBtnLevelUp()
  local uavdata = NetCmdUavData:GetUavData()
  UIManager.OpenUIByParam(UIDef.UIUAVLevelUpPanel, uavdata)
end
function UIUAVPanel:OnClickBtnBreak()
  UIManager.OpenUIByParam(UIDef.UAVBreakDialogPanel, self)
end
function UIUAVPanel:OnUnlockCallBack(unlockarmid)
  NetCmdUavData:SendUnlockUavArmData(unlockarmid, function(ret)
    if ret == ErrorCodeSuc then
      self:UpdateBottomSkillState(true)
      self:UpdateLeftAreaInfo()
      self:UpdateRightBtnState()
      self:UpdateRightAreaInfo()
      local hint = TableData.GetHintById(105030)
      local data = {}
      data.type = "yanfa"
      data.str = hint
      UIManager.OpenUIByParam(UIDef.UIUAVUnlockPartsDialog, data)
    end
  end)
end
function UIUAVPanel:FreshCallBack(ret)
  if ret == ErrorCodeSuc then
    self:UpdateBottomSkillState()
    if self.IsClickSave then
      self:UpdateRightAreaInfo(self.IsClickSave)
    end
    self:UpdateLeftAreaInfo()
    self:UpdateRightBtnState()
  end
end
function UIUAVPanel:UpOrDown(IsUp)
end
function UIUAVPanel:PlaySkinAnim()
  if UAVUtility.IsPlayAnim == false then
    UAVUtility.IsPlayAnim = true
    self.mAnim_assemble_skin:SetTrigger("StartAssemble")
    self.mAnim_drone_skin:SetTrigger("StartAssemble")
    local effect = self.mGo_SceneEffect.transform:Find("UAVhangerFX_01")
    setactive(effect, true)
    TimerSys:DelayCall(6, function()
      UAVUtility.IsPlayAnim = false
      if CS.LuaUtils.IsNullOrDestroyed(effect) == false then
        setactive(effect, false)
      end
    end)
  end
end
function UIUAVPanel:CheckPlatform(PlatformType)
  return PlatformType == CS.GameRoot.Instance.AdapterPlatform
end
function UIUAVPanel:OnClickClose()
  if self.mView.mTrans_UAVInfo.gameObject.activeSelf == true then
    if CS.SceneSys.Instance.IsLoading then
      return
    end
    UISystem:ClearUIStacks()
    SceneSys:ReturnMain()
    return
  end
  if self.mView.mTrans_UAVPartsInfo.gameObject.activeSelf == true then
    if self.mView.mTrans_GrpPartsInfo.gameObject.activeSelf and self.mView.mCanvasgroup.alpha == 1 then
      self.mView.mAnimator:SetInteger("UAVInfo", 3)
    end
    self.mView.mAnimator:SetInteger("List", 5)
    TimerSys:DelayCall(0.3, function()
      setactive(self.mView.mTrans_UAVPartsInfo.gameObject, false)
      self.mView.mAnimator:SetInteger("UAVInfo", 0)
      setactive(self.mView.mTrans_UAVInfo.gameObject, true)
      setactive(self.mView.mTrans_SkillRange, false)
    end)
    self.mView.mToggle_Range.isOn = false
    self.mView.mToggle_Contrast.isOn = false
    local pos = self.mView.mTrans_ScrollContent.localPosition
    self.mView.mTrans_ScrollContent.localPosition = Vector3(pos.x, 0, pos.z)
    UAVUtility.NowRealBottomArmId = -1
    UAVUtility.NowFakeBottomArmId = -1
    UAVUtility.IsClickUninstall = false
    self:UpdateBottomSkillState()
    self:UpdateUavMainViewInfo()
    local listequip = NetCmdUavData:GetArmEquipState()
    self:UpdateRightSkillState(listequip)
  end
end
function UIUAVPanel:OnClickBlocker()
  self.mView.mToggle_Contrast.isOn = false
end
function UIUAVPanel:OnClickContrast(isOn)
  if isOn then
    ComPropsDetailsHelper:InitUAVData(self.mView.mTrans_DetailsLeft, UAVUtility.NowRealBottomArmId)
  else
    ComPropsDetailsHelper:Close()
  end
  setactive(self.mView.mTrans_GrpDetailsLeft, isOn)
end
function UIUAVPanel:OnClickUAVInfoIcon()
  UIManager.OpenUI(UIDef.UIUAVPropPanel)
end
