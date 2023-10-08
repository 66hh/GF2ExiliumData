UIWeaponGlobal = {}
UIWeaponGlobal.WeaponLvRichText = "<size=56>{0}</size>/{1}"
UIWeaponGlobal.WeaponEnhanceLvRichText = "<color=#ed6015><size=84>{0}</size></color>/{1}"
UIWeaponGlobal.MaxStar = 5
UIWeaponGlobal.MaxMaterialCount = 20
UIWeaponGlobal.WeaponMaxSlot = 4
UIWeaponGlobal.MaxBreakCount = 1
UIWeaponGlobal.SRRank = 4
UIWeaponGlobal.DicLevelExp = nil
UIWeaponGlobal.weaponModel = nil
UIWeaponGlobal.ReplaceSortType = {
  Level = 1,
  Rank = 2,
  Time = 3,
  Element = 4
}
UIWeaponGlobal.MaterialSortType = {Rank = 1}
UIWeaponGlobal.ReplaceSortCfg = {
  {
    "level",
    "rank",
    "element",
    "stcId",
    "id"
  },
  {
    "rank",
    "level",
    "element",
    "stcId",
    "id"
  },
  {"id"}
}
UIWeaponGlobal.WeaponPartsSortCfg = {
  {"level"},
  {"rank"},
  {"powerNum"},
  {"id"}
}
UIWeaponGlobal.MaterialSortCfg = {
  {
    "rank",
    "weaponType",
    "breakTimes",
    "level",
    "stcId",
    "id"
  }
}
UIWeaponGlobal.PartMaterialSortCfg = {
  "type",
  "rank",
  "equipGun",
  "weaponId",
  "isLock",
  "fatherType",
  "partType",
  "suitId",
  "id"
}
UIWeaponGlobal.MaterialFiltrateCfg = {
  2,
  3,
  4,
  5
}
UIWeaponGlobal.PartMaterialFiltrateCfg = {
  3,
  4,
  5
}
UIWeaponGlobal.SkillType = {NormalSkill = 1, BuffSkill = 2}
UIWeaponGlobal.ContentType = {
  Info = 1,
  Replace = 2,
  Enhance = 3,
  WeaponPart = 4
}
UIWeaponGlobal.MaterialType = {Item = 1, Weapon = 2}
UIWeaponGlobal.WeaponPanelTab = {
  Info = 1,
  Enhance = 2,
  Break = 3,
  Evolution = 4,
  WeaponPart = 5
}
UIWeaponGlobal.WeaponPartPanelTab = {Info = 1, Enhance = 2}
UIWeaponGlobal.SystemIdList = {
  0,
  0,
  0,
  0,
  SystemList.GundetailWeaponpart
}
UIWeaponGlobal.WeaponContentTypeV4 = {Weapon = 1, WeaponPart = 2}
UIWeaponGlobal.WeaponPowerUpContentTypeV4 = {
  LevelUp = 2,
  Break = 1,
  Polarity = 3
}
UIWeaponGlobal.WeaponTabHint = {
  102016,
  102006,
  40031,
  40044,
  40026
}
UIWeaponGlobal.WeaponPartTabHint = {102225, 102226}
UIWeaponGlobal.WeaponBreakColor = {
  WhiteColor = ColorUtils.StringToColor("efefef"),
  YellowColor = ColorUtils.StringToColor("f0af14")
}
UIWeaponGlobal.ModEffectType = {
  Alert = 1,
  Armor = 2,
  Cover = 3,
  Ambush = 4
}
UIWeaponGlobal.WeaponModQuality = {
  Flaw = 1,
  Normal = 2,
  Perfect = 3
}
function UIWeaponGlobal:GetWeaponSimpleData(data)
  if data then
    local weapon = {}
    weapon.id = data.id
    weapon.stcId = data.stc_id
    weapon.level = data.Level
    weapon.icon = data.ResCode
    weapon.rank = data.Rank
    weapon.maxLevel = data.MaxLevel
    weapon.element = data.Element
    weapon.isLock = data.IsLocked
    weapon.slotList = data.slotList
    weapon.partList = data.partList
    weapon.gunId = data.gun_id
    weapon.breakTimes = data.BreakTimes
    weapon.isSelect = false
    weapon.stcData = data.StcData
    return weapon
  end
  return nil
end
function UIWeaponGlobal:GetWeaponModSimpleData(data, type)
  if data then
    local item = {}
    item.type = type
    if item.type == UIWeaponGlobal.MaterialType.Item then
      local count = NetCmdItemData:GetItemCount(data)
      if count <= 0 then
        return nil
      end
      local itemData = TableData.listItemDatas:GetDataById(data)
      item.id = data
      item.stcId = data
      item.rank = itemData.rank
      item.level = itemData.rank
      item.weaponType = 0
      item.offerExp = itemData.args[0]
      item.count = count
      item.isLock = false
      item.isSelect = false
    else
      item.id = data.id
      item.stcId = data.stcId
      item.name = data.name
      item.icon = data.icon
      item.rank = data.rank
      item.partType = data.type
      item.fatherType = data.fatherType
      item.level = data.level
      item.exp = data.exp
      item.suitId = data.suitId
      item.equipGun = data.equipGun
      item.weaponId = data.equipWeapon
      item.powerNum = data.powerNum
      item.isLock = data.IsLocked
      item.isMaxLv = not data.isCanLevelUp
      item.isSelect = false
      item.count = 1
      item.offerExp = data:GetWeaponOfferExp()
    end
    item.selectCount = 0
    return item
  end
  return nil
end
function UIWeaponGlobal:GetMaterialSimpleData(data, type)
  if data then
    local item = {}
    item.type = type
    if item.type == UIWeaponGlobal.MaterialType.Item then
      local count = NetCmdItemData:GetItemCount(data)
      if count <= 0 then
        return nil
      end
      local itemData = TableData.listItemDatas:GetDataById(data)
      item.id = data
      item.stcId = data
      item.rank = itemData.rank
      item.level = itemData.rank
      item.weaponType = 0
      item.offerExp = itemData.args[0]
      item.costCoin = itemData.args[1]
      item.count = count
      item.breakTimes = 0
      item.partCount = 0
      item.isLock = false
      item.IsLocked = false
      item.isBreakItem = false
      item.isSelect = false
      item.timeStamp = 0
    elseif item.type == UIWeaponGlobal.MaterialType.Weapon then
      item.id = data.id
      item.stcId = data.stc_id
      item.level = data.Level
      item.icon = data.ResCode
      item.rank = data.Rank
      item.weaponType = data.Type
      item.isLock = data.IsLocked
      item.IsLocked = data.IsLocked
      item.breakTimes = data.BreakTimes
      item.partCount = data.PartsCount
      item.offerExp = data:GetWeaponOfferExp()
      item.costCoin = data:GetChipCash()
      item.count = 1
      item.isSelect = false
      item.timeStamp = data.Timestamp
    end
    item.selectCount = 0
    return item
  end
  return nil
end
function UIWeaponGlobal:GetWeaponLevelExpDic()
  if self.DicLevelExp == nil then
    self.DicLevelExp = {}
    for i = 0, TableData.listGunWeaponExpDatas.Count - 1 do
      local data = TableData.listGunWeaponExpDatas[i]
      self.DicLevelExp[data.level] = data.weapon_exp_total
    end
  end
  return self.DicLevelExp
end
function UIWeaponGlobal:GetWeaponTotalExpByLevel(level, expRate)
  local dic = UIWeaponGlobal:GetWeaponLevelExpDic()
  return math.ceil(dic[level] * expRate)
end
function UIWeaponGlobal:GetWeaponLevelByExp(exp, expRate)
  local dic = UIWeaponGlobal:GetWeaponLevelExpDic()
  for i = 1, TableData.listGunWeaponExpDatas.Count - 1 do
    local data = TableData.listGunWeaponExpDatas[i]
    local needExp = dic[data.level] * (expRate / 1000)
    local lastExp = dic[data.level - 1] * (expRate / 1000)
    if exp >= lastExp and exp < needExp then
      return data.level - 1
    end
  end
  return TableData.listGunWeaponExpDatas[TableData.listGunWeaponExpDatas.Count - 1].level
end
function UIWeaponGlobal:GetWeaponTypeList()
  local list = {}
  local typeList = TableData.listGunWeaponTypeDatas
  for i = 0, typeList.Count - 1 do
    table.insert(list, typeList[i])
  end
  return list
end
function UIWeaponGlobal:GetWeaponPartTypeList()
  local list = {}
  local typeList = TableData.listWeaponModTypeDatas
  for i = 0, typeList.Count - 1 do
    if typeList[i].type == 1 then
      table.insert(list, typeList[i])
    end
  end
  return list
end
function UIWeaponGlobal:GetWeaponPartSuitList()
  local list = {}
  local typeList = TableData.listModPowerDatas
  for i = 0, typeList.Count - 1 do
    table.insert(list, typeList[i])
  end
  return list
end
function UIWeaponGlobal:ExpToBook(exp)
  local list = {}
  local itemList = TableData.GlobalSystemData.WeaponLevelUpItem
  exp = math.ceil(exp * (TableData.GlobalSystemData.WeaponExpReturn / 1000))
  for i, v in ipairs(itemList) do
    local item = {}
    local itemData = TableData.listItemDatas:GetDataById(v)
    local offerExp = tonumber(itemData.args[0])
    local num = math.floor(exp / offerExp)
    if 0 < num then
      item.id = v
      item.num = num
      table.insert(list, item)
      exp = exp - num * offerExp
    end
  end
  return list
end
function UIWeaponGlobal:BreakWeaponReturn(weapon)
  local item = {}
  local waeponData = TableData.listGunWeaponDatas:GetDataById(weapon.stc_id)
  for id, num in pairs(waeponData.sold_get) do
    local num = math.ceil(num * weapon.BreakTimes * (TableData.GlobalSystemData.WeaponExpReturn / 1000))
    if id == GlobalConfig.WeaponCoin then
      item.id = id
      item.num = num
    end
  end
  return item
end
function UIWeaponGlobal:EnableWeaponModel(enable)
  if not CS.LuaUtils.IsNullOrDestroyed(UIWeaponGlobal.weaponModel) then
    setactive(UIWeaponGlobal.weaponModel.gameObject, enable)
  end
end
function UIWeaponGlobal:UpdateWeaponModel(weaponId, gunId)
  local weaponData = TableData.listGunWeaponDatas:GetDataById(weaponId)
  UIWeaponGlobal:ReleaseWeaponModel()
  UIWeaponGlobal.weaponModel = UIModelToucher.CreateWeapon(weaponData, gunId)
  UIModelToucher.SetWeaponTransformValue(weaponData)
end
function UIWeaponGlobal:UpdateWeaponModelByConfig(weaponCmdData, enableTranslate, enableToucher)
  local weaponId = weaponCmdData.stc_id
  local gunId = weaponCmdData.gun_id
  local weaponConfig = weaponCmdData.WeaponConfig
  UIWeaponGlobal:ReleaseWeaponModel()
  local weaponData = TableData.listGunWeaponDatas:GetDataById(weaponId)
  UIWeaponGlobal.weaponModel = UIModelToucher.CreateWeapon(weaponData, gunId)
  local weaponRoot = UIWeaponGlobal:GetWeaponObjRoot()
  if weaponRoot == nil then
  else
    local obj = SceneObjManager:GetWeaponModelInstance(weaponConfig)
    obj.transform:SetParent(weaponRoot, false)
  end
  if enableToucher == nil then
    enableToucher = FacilityBarrackGlobal.GetCurCameraStand() == FacilityBarrackGlobal.CameraType.WeaponToucher
  end
  UIModelToucher.SetWeaponTransformValue(weaponData, enableTranslate, enableToucher)
end
function UIWeaponGlobal:GetWeaponObjRoot()
  local name = UIWeaponGlobal.weaponModel.transform.name
  local transName = string.sub(name, 1, #name - 7)
  local tmpRoot = UIWeaponGlobal.weaponModel.transform:Find(transName)
  return tmpRoot
end
function UIWeaponGlobal:ReleaseWeaponModel()
  UISystem.BarrackCharacterCameraCtrl:ShowBarrack3DCanvas(false)
  BarrackHelper.CameraMgr:ReleaseWeaponRT()
  UIBarrackWeaponModelManager:Release()
  if not CS.LuaUtils.IsNullOrDestroyed(UIWeaponGlobal.weaponModel) then
    CS.UITweenManager.KillTween(UIWeaponGlobal.weaponModel.transform)
    local tmpRoot = UIWeaponGlobal:GetWeaponObjRoot()
    if tmpRoot ~= nil and tmpRoot.childCount > 0 then
      ResourceManager:DestroyInstance(tmpRoot:GetChild(0).gameObject)
    end
    ResourceManager:DestroyInstance(UIWeaponGlobal.weaponModel)
    UIWeaponGlobal.weaponModel = nil
  end
end
function UIWeaponGlobal:GetWeaponModelShow(weaponData, gunId)
  if weaponData.character_id ~= 0 then
    return weaponData.model_show_new .. "_" .. weaponData.character_id
  elseif gunId ~= nil and gunId ~= 0 then
    local gunData = TableData.listGunDatas:GetDataById(gunId)
    return weaponData.model_show_new .. "_" .. gunData.character_id
  else
    return weaponData.model_default
  end
end
function UIWeaponGlobal:SetWeaponEffectShow(boolean)
  local trans = UIWeaponGlobal.weaponModel.transform
  for i = 0, trans.childCount - 1 do
    local effect = trans:GetChild(i).gameObject:GetComponent(typeof(CS.FXDistortionPrefab))
    if effect ~= nil then
      setactive(effect.gameObject, boolean)
      return
    end
  end
end
function UIWeaponGlobal.SetTextColorByPropName(name)
  local expandList = TableData.GetPropertyExpandList()
  for i = 0, expandList.Count - 1 do
    local lanData = expandList[i]
    if lanData.sys_name == name then
      return lanData.statue == 2 and ColorUtils.OrangeColor or ColorUtils.BlackColor
    end
  end
  return ColorUtils.BlackColor
end
UIWeaponGlobal.Location = {
  Dev = 1,
  Observation = 2,
  Desktop = 3
}
function UIWeaponGlobal:GetWeaponLocation()
  return UIWeaponGlobal.location
end
function UIWeaponGlobal:PutUpWeaponForDev(weaponStcData)
  if not weaponStcData then
    return
  end
  local targetPos = UIUtils.SplitStrToVector(weaponStcData.position_dev)
  local targetEuler = UIUtils.SplitStrToVector(weaponStcData.rotation_dev)
  local targetScale = UIUtils.SplitStrToVector(weaponStcData.scale_dev)
  UIWeaponGlobal:setWeaponTrans(targetPos, targetEuler, targetScale)
  UIModelToucher.SetStartEuler(targetEuler)
  UIWeaponGlobal.location = UIWeaponGlobal.Location.Dev
end
function UIWeaponGlobal:PutUpWeaponForObservation(weaponStcData, slotId)
  if not weaponStcData then
    return
  end
  local targetPos, targetEuler, targetScale
  if slotId ~= nil then
    targetPos = UIUtils.SplitStrToVector(string.split(weaponStcData.mod_show_position, ";")[slotId])
    targetEuler = UIUtils.SplitStrToVector(string.split(weaponStcData.mod_show_rotate, ";")[slotId])
    targetScale = UIUtils.SplitStrToVector(string.split(weaponStcData.mod_show_scale, ";")[slotId])
  else
    targetPos = UIUtils.SplitStrToVector(weaponStcData.position_putup)
    targetEuler = UIUtils.SplitStrToVector(weaponStcData.rotation_putup)
    targetScale = UIUtils.SplitStrToVector(weaponStcData.scale_putup)
  end
  UIWeaponGlobal:setWeaponTrans(targetPos, targetEuler, targetScale)
  UIModelToucher.SetStartEuler(targetEuler)
  UIWeaponGlobal.location = UIWeaponGlobal.Location.Observation
end
function UIWeaponGlobal:PutDownWeapon(weaponStcData)
  if not weaponStcData then
    return
  end
  local targetPos = UIUtils.SplitStrToVector(weaponStcData.position)
  local targetEuler = UIUtils.SplitStrToVector(weaponStcData.rotation)
  local targetScale = UIUtils.SplitStrToVector(weaponStcData.scale)
  UIWeaponGlobal:setWeaponTrans(targetPos, targetEuler, targetScale)
  UIModelToucher.ResetStartEuler()
  UIWeaponGlobal.location = UIWeaponGlobal.Location.Desktop
end
function UIWeaponGlobal:setWeaponTrans(targetPos, targetEuler, targetScale)
  local weaponModel = UIWeaponGlobal.weaponModel
  if CS.LuaUtils.IsNullOrDestroyed(weaponModel) then
    return
  end
  local weaponTrans = weaponModel.transform
  weaponTrans.position = targetPos
  weaponTrans.rotation = CS.UnityEngine.Quaternion.Euler(targetEuler)
  weaponTrans.localScale = targetScale
end
function UIWeaponGlobal.SetWeaponPartAttr(gunWeaponModData, subPropList, parentTrans)
  parentTrans = parentTrans.transform
  for i = 1, #subPropList do
    subPropList[i]:SetData(nil)
    subPropList[i]:OnRelease(true)
  end
  subPropList = {}
  local mainObj
  local mainPropitem = ChrWeaponAttributeListItemV3.New()
  mainPropitem:InitCtrl(parentTrans, mainObj)
  table.insert(subPropList, mainPropitem)
  local mainPropData = TableData.GetPropertyDataByName(gunWeaponModData.mainProp)
  mainPropitem:SetData(mainPropData, gunWeaponModData.mainPropValue, true, false, false)
  local dataList = gunWeaponModData.subPropList
  for i = 0, dataList.Count - 1 do
    local data = dataList[i]
    local obj
    local item = ChrWeaponAttributeListItemV3.New()
    item:InitCtrl(parentTrans, obj)
    table.insert(subPropList, item)
    local rankList = UIWeaponGlobal.GetSubPropRankList(data)
    item:SetData(data.propData, data.value, true, false, false, true)
    item:SetPropQuality(rankList)
  end
  return subPropList
end
function UIWeaponGlobal.GetSubPropRankList(weaponModAffix)
  local rankList = {}
  local affixData = TableData.listModAffixDatas:GetDataById(weaponModAffix.affixId)
  table.insert(rankList, affixData.rank)
  for i = 0, weaponModAffix.levelData.Count - 1 do
    local lvUpData = TableData.listPropertyLevelUpGroupDatas:GetDataById(weaponModAffix.levelData[i])
    table.insert(rankList, lvUpData.rank)
  end
  return rankList
end
function UIWeaponGlobal.GetSubPropRankWithValueList(weaponModAffix)
  local rankList = {}
  local propValue = weaponModAffix.PropValue
  local isPercent = false
  if weaponModAffix.LanguagePropertyData.show_type == 2 then
    isPercent = true
    propValue = UIWeaponGlobal.PercentValue(propValue)
  end
  table.insert(rankList, {
    rank = weaponModAffix.ModAffixData.rank,
    value = propValue
  })
  for i = 0, weaponModAffix.levelData.Count - 1 do
    local lvUpData = TableData.listPropertyLevelUpGroupDatas:GetDataById(weaponModAffix.levelData[i])
    local lvUpValue = lvUpData.Value
    if isPercent then
      lvUpValue = UIWeaponGlobal.PercentValue(lvUpValue)
    end
    table.insert(rankList, {
      rank = lvUpData.rank,
      value = lvUpValue
    })
  end
  return rankList
end
function UIWeaponGlobal.PercentValue(value)
  value = value / 10
  value = math.floor(value * 10 + 0.5) / 10
  return value .. "%"
end
UIWeaponGlobal.needReleaseWeaponRT = false
function UIWeaponGlobal.SetNeedReleaseWeaponRT(boolean)
  UIWeaponGlobal.needReleaseWeaponRT = boolean
end
function UIWeaponGlobal.GetNeedReleaseWeaponRT()
  return UIWeaponGlobal.needReleaseWeaponRT
end
UIWeaponGlobal.needToCommandCenter = false
function UIWeaponGlobal.SetNeedToCommandCenter(boolean)
  UIWeaponGlobal.needToCommandCenter = boolean
end
function UIWeaponGlobal.GetNeedToCommandCenter()
  return UIWeaponGlobal.needToCommandCenter
end
function UIWeaponGlobal.GetWeaponModel()
  return UIBarrackWeaponModelManager.CurWeaponModel
end
UIWeaponGlobal.needCloseBarrack3DCanvas = false
function UIWeaponGlobal.SetNeedCloseBarrack3DCanvas(boolean)
  UIWeaponGlobal.needCloseBarrack3DCanvas = boolean
end
function UIWeaponGlobal.GetNeedCloseBarrack3DCanvas()
  return UIWeaponGlobal.needCloseBarrack3DCanvas
end
UIWeaponGlobal.beginCallback = nil
UIWeaponGlobal.endCallback = nil
function UIWeaponGlobal:SetWeaponToucherBeginCallback(callback)
  UIWeaponGlobal.beginCallback = callback
end
function UIWeaponGlobal:SetWeaponToucherEndCallback(callback)
  UIWeaponGlobal.endCallback = callback
end
function UIWeaponGlobal:InitWeaponToucherEvent(CanvasGroup)
  UIBarrackWeaponModelManager:SetWeaponToucherEventBeginCallback(function()
    if UIWeaponGlobal.beginCallback ~= nil then
      UIWeaponGlobal.beginCallback()
    end
  end)
  UIBarrackWeaponModelManager:SetWeaponToucherEventEndCallback(function()
    if UIWeaponGlobal.endCallback ~= nil then
      UIWeaponGlobal.endCallback()
    end
  end)
end
function UIWeaponGlobal:ReleaseWeaponToucherEvent()
  UIBarrackWeaponModelManager:ReleaseWeaponToucherEventBeginCallback()
  UIBarrackWeaponModelManager:ReleaseWeaponToucherEventEndCallback()
  UIWeaponGlobal.beginCallback = nil
  UIWeaponGlobal.endCallback = nil
end
function UIWeaponGlobal.SetBreakTimesImg(img, num, maxNum, isSmall)
  local suffix = ""
  if isSmall == nil then
    isSmall = true
  end
  if isSmall then
    suffix = "_S"
  end
  if num == 0 then
    num = 1
  end
  if num ~= 0 then
    img.sprite = IconUtils.GetUIWeaponBreakNum("Img_BreakNum" .. num .. suffix)
  end
  if maxNum <= num then
    img.color = UIWeaponGlobal.WeaponBreakColor.YellowColor
    UIUtils.SetAlpha(img, 1)
  else
    img.color = UIWeaponGlobal.WeaponBreakColor.WhiteColor
    UIUtils.SetAlpha(img, 0.66)
  end
end
UIWeaponGlobal.PolarityIndex = 0
function UIWeaponGlobal.GetPolarityIndex()
  return UIWeaponGlobal.PolarityIndex
end
function UIWeaponGlobal.SetPolarityIndex(value)
  UIWeaponGlobal.PolarityIndex = value
end
UIWeaponGlobal.isReadyToStartTutorial = true
function UIWeaponGlobal.SetIsReadyToStartTutorial(boolean)
  gfdebug("[Tutorial] UIWeaponGlobal.isReadyToStartTutorial" .. tostring(boolean))
  UIWeaponGlobal.isReadyToStartTutorial = boolean
end
function UIWeaponGlobal.GetIsReadyToStartTutorial()
  return UIWeaponGlobal.isReadyToStartTutorial
end
