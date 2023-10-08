require("UI.UIManager")
UIUtils = {}
function UIUtils.GetGraphicRaycaster(gameobj)
  return CS.LuaUIUtils.GetGraphicRaycaster(gameobj)
end
function UIUtils.GetListener(gameobj)
  return CS.LuaUIUtils.GetListener(gameobj)
end
function UIUtils.GetButtonListener(gameobj)
  return CS.LuaUIUtils.GetButtonListener(gameobj)
end
function UIUtils.AddBtnClickListener(component, callback)
  if not component or not callback then
    return
  end
  UIUtils.GetButtonListener(component.gameObject).onClick = callback
end
function UIUtils.EnableBtn(btnComponent, enable)
  if not btnComponent then
    return
  end
  btnComponent.interactable = enable and enable or false
end
function UIUtils.GetUIContainer(gameobj)
  return CS.LuaUIUtils.GetUIContainer(gameobj)
end
function UIUtils.GetButtonIntervalListener(gameobj, interval)
  return CS.LuaUIUtils.GetButtonIntervalListener(gameobj, interval)
end
function UIUtils.GetButtonTipsHelper(gameobj)
  return CS.LuaUIUtils.GetButtonTipsHelper(gameobj)
end
function UIUtils.GetSscrollRectDragHelper(gameobj)
  return CS.LuaUIUtils.GetSscrollRectDragHelper(gameobj)
end
function UIUtils.GetDragHelper(gameobj)
  return CS.LuaUIUtils.GetDragHelper(gameobj)
end
function UIUtils.GetUIBlockHelper(gameobj, child, callback, gameobj1)
  return CS.LuaUIUtils.GetUIBlockHelper(gameobj, child, callback, gameobj1)
end
function UIUtils.GetLoopVerticalScrollRect(gameobj)
  return CS.LuaUIUtils.GetLoopVerticalScrollRect(gameobj)
end
function UIUtils.SetUIEnable(gameobj, enable)
  return CS.UIUtils.SetUIEnable(gameobj, enable)
end
function UIUtils.AddListItem(item, list)
  return CS.LuaUIUtils.AddListItem(item, list)
end
function UIUtils.GetVirtualList(gameobj)
  return CS.LuaUIUtils.GetVirtualList(gameobj)
end
function UIUtils.GetVirtualListEx(gameobj)
  return CS.LuaUIUtils.GetVirtualListEx(gameobj)
end
function UIUtils.GetChildCenterScroll(gameObj)
  return CS.LuaUIUtils.GetChildCenterScroll(gameObj)
end
function UIUtils.GetPageScroll(gameObj)
  if gameObj then
    return CS.LuaUIUtils.GetPageScroll(gameObj)
  end
  return nil
end
function UIUtils.GetTempBtn(gameObj)
  if gameObj then
    return CS.LuaUIUtils.GetUIContainerBtn(gameObj)
  end
  return nil
end
function UIUtils.GetLoopScrollView(gameObj)
  if gameObj then
    return CS.LuaUIUtils.GetLoopScrollView(gameObj)
  end
  return nil
end
function UIUtils.GetUIRes(path)
  local sourcePrefab = ResSys:GetUIRes(path, false)
  if sourcePrefab == nil then
    print("没有资源 ：" .. path)
  end
  return sourcePrefab
end
function UIUtils.GetGizmosPrefab(path, owner)
  local sourcePrefab = ResSys:GetUIGizmos(path, false)
  if sourcePrefab == nil then
    print("没有资源 ：" .. path)
  end
  if owner ~= nil then
    owner:AddAsset(sourcePrefab)
  end
  return sourcePrefab
end
function UIUtils.Instantiate(uiBaseCtrl, relativePath, parent)
  if not uiBaseCtrl then
    return
  end
  return uiBaseCtrl:Instantiate(relativePath, parent)
end
function UIUtils.InstantiateByTemplate(template, parent)
  if not template or template:IsNull() then
    return
  end
  return instantiate(template, parent)
end
function UIUtils.GetUIBindTable(component)
  local luaUIBind = component.gameObject:GetComponent(typeof(LuaBindingNew))
  if luaUIBind == nil then
    return
  end
  local res = {}
  local vars = luaUIBind.BindingNameList
  for i = 0, vars.Count - 1 do
    res[vars[i]] = luaUIBind:GetBindingComponent(vars[i])
  end
  return res
end
function UIUtils.OutUIBindTable(go, outTable)
  outTable = outTable or {}
  local luaUIBind = go:GetComponent(typeof(LuaBindingNew))
  if luaUIBind == nil then
    return
  end
  local vars = luaUIBind.BindingNameList
  for i = 0, vars.Count - 1 do
    outTable[vars[i]] = luaUIBind:GetBindingComponent(vars[i])
  end
end
function UIUtils.GetRandomNum2()
  local num1 = math.random(100, 999)
  local num2 = math.random(100, 999)
  return num1 .. "-" .. num2
end
function UIUtils.GetRandomNum3()
  local num1 = math.random(100, 999)
  local num2 = math.random(100, 999)
  local num3 = math.random(100, 999)
  return num1 .. "-" .. num2 .. "-" .. num3
end
function UIUtils.GetDarkPanelTool(path, owner)
  local prefab = ResSys:GetDarkPanel("ChrWeaponEquipInfoItemV2.prefab")
  if prefab == nil then
    print("没有暗区详情面板")
  end
  if owner ~= nil then
    owner:AddAsset(prefab)
  end
  return prefab
end
function UIUtils.GetDarkPanelBoxItem(path, owner)
  local boxitem = ResSys:GetDarkBoxItem("DarkzoneBoxItem.prefab")
  if boxitem == nil then
    print("没有暗区boxitem")
  end
  if owner ~= nil then
    owner:AddAsset(boxitem)
  end
  return boxitem
end
function UIUtils.GetDarkGetItem(path, owner)
  local getitem = ResSys:GetDarkBoxItem("DarkzoneGetItem.prefab")
  if getitem == nil then
    print("没有暗区getitem")
  end
  if owner ~= nil then
    owner:AddAsset(getitem)
  end
  return getitem
end
function UIUtils.GetScrollRectEx(root, path)
  local widgetScroll = UIUtils.GetWidget(root, path, typeof(CS.ScrollRectEx))
  return widgetScroll
end
function UIUtils.GetImage(root, path)
  local widgetImg = UIUtils.GetWidget(root, path, typeof(CS.UnityEngine.UI.Image))
  return widgetImg
end
function UIUtils.GetText(root, path)
  return UIUtils.GetWidget(root, path, typeof(CS.UnityEngine.UI.Text))
end
function UIUtils.GetRectTransform(root, path)
  return UIUtils.GetWidget(root, path, typeof(CS.UnityEngine.RectTransform))
end
function UIUtils.GetToggle(root, path)
  return UIUtils.GetWidget(root, path, typeof(CS.UnityEngine.UI.Toggle))
end
function UIUtils.GetButton(root, path)
  return UIUtils.GetWidget(root, path, typeof(CS.UnityEngine.UI.Button))
end
function UIUtils.GetTransform(root, path)
  return UIUtils.GetWidget(root, path, typeof(CS.UnityEngine.Transform))
end
function UIUtils.GetLayoutElemnt(root, path)
  return UIUtils.GetWidget(root, path, typeof(CS.UnityEngine.UI.LayoutElement))
end
function UIUtils.GetLayoutGroup(root, path)
  return UIUtils.GetWidget(root, path, typeof(CS.UnityEngine.UI.HorizontalOrVerticalLayoutGroup))
end
function UIUtils.GetAnimator(root, path)
  return UIUtils.GetWidget(root, path, typeof(CS.UnityEngine.Animator))
end
function UIUtils.GetAnimatorTime(root, path)
  return UIUtils.GetWidget(root, path, typeof(CS.AniTime))
end
function UIUtils.GetGFButton(root, path)
  return UIUtils.GetWidget(root, path, typeof(CS.UnityEngine.UI.GFButton))
end
function UIUtils.GetObject(root, path)
  if root == nil then
    return
  end
  if not path or path == "" then
    return root
  end
  local result = UIUtils.FindChild(root.transform, path)
  return result
end
function UIUtils.GetIconSprite(pack, path)
  local sourceSprite = CS.IconUtils.GetIconV2(pack, path)
  if sourceSprite == nil then
    print("没有资源 ：" .. path)
  end
  return sourceSprite
end
function UIUtils.GetIconTexture(pack, path)
  local tex = ResSys:GetIconTexture(pack, path)
  if tex == nil then
    print("没有资源 ：" .. path)
  end
  return tex
end
function UIUtils.GetGunMessageSprite(spritename)
  return CS.LuaUIUtils.GetGunMessageSprite(spritename)
end
function UIUtils.OpenNoticeUIPanel(msg)
  CS.LuaUIUtils.OpenNoticePanel(msg)
end
function UIUtils.StringFormat(param, ...)
  return CS.LuaUIUtils.StringFormat(param, ...)
end
function UIUtils.StringFormatWithHintId(hintID, ...)
  return UIUtils.StringFormat(TableData.GetHintById(hintID), ...)
end
function UIUtils.GetHintStr(hintID)
  return TableData.GetHintById(hintID)
end
function UIUtils.FindTransform(path)
  local trans = CS.UnityEngine.GameObject.Find(path)
  if trans ~= nil then
    return trans.transform
  end
  return nil
end
function UIUtils.FindGameObject(path)
  local trans = CS.UnityEngine.GameObject.Find(path)
  if trans ~= nil then
    return trans
  end
  return nil
end
function UIUtils.GetModel(type, tableId, getModelUIType, weaponID)
  return CS.UI3DModelManager.Instance:GetModel(type, tableId, getModelUIType, weaponID)
end
function UIUtils.GetModelNoWeapon(type, tableId, getModelUIType)
  return CS.UI3DModelManager.Instance:GetModel(type, tableId, getModelUIType)
end
function UIUtils.LoadBarrackEffect(tableId, gunModel)
  return CS.UI3DModelManager.Instance:LoadBarrackEffect(tableId, gunModel)
end
function UIUtils.GetUIModelAsyn(type, tableId, callback)
  CS.UIModelManager.Instance:GetModel(type, tableId, true, callback)
end
function UIUtils.GetRobotModel(robotId)
  CS.RobotModelManager.Instance:CreateRobot(robotId)
end
function UIUtils.GetBarrackUIModelAsyn(gunId, weaponId, weaponData, callback)
  CS.UIBarrackModelManager.Instance:GetBarrckModel(gunId, weaponId, weaponData, true, callback)
end
function UIUtils.ReleaseBarrackUIModel(gunId, weaponId, callback)
  CS.UIBarrackModelManager.Instance:Release()
end
function UIUtils.GetDarkZoneTeamUIModelAsyn(gunId, weaponId, index, callback)
  CS.UIDarkZoneTeamModelManager.Instance:GetDarkZoneTeamModel(gunId, weaponId, index, true, callback)
end
function UIUtils.ReleaseDarkZoneTeamUIModel(gunId, weaponId, callback)
  CS.UIDarkZoneTeamModelManager.Instance:Release()
end
function UIUtils.FindChild(transform, path)
  return transform:Find(path)
end
function UIUtils.ForceUpdateCanvases()
  print("force update !!!!!!!")
  CS.UnityEngine.Canvas.ForceUpdateCanvases()
end
function UIUtils.AddSubCanvas(gameObject, order, autoIncrease)
  CS.LuaUIUtils.AddSubCanvas(gameObject, order, autoIncrease)
end
function UIUtils.SetColor(ctrl, color)
  CS.LuaUIUtils.SetColor(ctrl, color)
end
function UIUtils.SetAlpha(ctrl, alpha)
  CS.LuaUIUtils.SetAlpha(ctrl, alpha)
end
function UIUtils.SetTextAlpha(ctrl, alpha)
  CS.LuaUIUtils.SetTxtAlpha(ctrl, alpha)
end
function UIUtils.SetCanvasGroupValue(obj, alpha)
  CS.LuaUIUtils.SetCanvasGroupValue(obj, alpha)
end
function UIUtils.SetInteractive(trans, activity)
  CS.LuaUIUtils.SetInteractive(trans, activity)
end
function UIUtils.ForceRebuildLayout(rectTrans)
  CS.LuaUIUtils.ForceRebuildLayout(rectTrans)
end
function UIUtils.ForceRebuildCanvas()
  CS.LuaUIUtils.ForceRebuildCanvas()
end
function UIUtils.SetChildrenScale(trans, scale, includeSelf)
  CS.LuaUIUtils.SetChildrenScale(trans, scale, includeSelf)
end
function UIUtils.SetGachaEffectMaterailColor(trans, color)
  CS.LuaUIUtils.SetGachaEffectMaterailColor(trans, color)
end
function UIUtils.GetPanelTopZPos(panel)
  return CS.LuaUIUtils.GetPanelTopZPos(panel)
end
function UIUtils.GetPointerClickHelper(go, callback, selfArea)
  return CS.LuaUIUtils.GetPointerClickHelper(go, callback, selfArea)
end
function UIUtils.SetParticleRenderOrder(gameObject, order)
  CS.LuaUIUtils.SetParticleRenderOrder(gameObject, order)
end
function UIUtils.SetMeshRenderSortOrder(gameObject, order)
  CS.LuaUIUtils.SetMeshRenderSortOrder(gameObject, order)
end
function UIUtils.GetCanvasSortOrder(gameObject)
  CS.LuaUIUtils.GetCanvasSortOrder(gameObject)
end
function UIUtils.NumberToRomeString(szNum)
  local rmNum = {
    "Ⅰ",
    "Ⅱ",
    "Ⅲ",
    "Ⅳ",
    "Ⅴ",
    "Ⅵ",
    "Ⅶ",
    "Ⅷ",
    "Ⅸ",
    "Ⅹ"
  }
  return rmNum[szNum]
end
function UIUtils.GetWidget(root, path, widgetType)
  if root == nil then
    return
  end
  if type(widgetType) ~= "userdata" then
    print_error("只能使用typeof获取组件")
    return
  end
  local tObj
  if path == nil or path == "" then
    tObj = root
  else
    tObj = UIUtils.FindChild(root.transform, path)
  end
  if tObj == nil then
    return nil
  end
  local com = tObj:GetComponent(widgetType)
  return com
end
function UIUtils.SplitStrToVector(str, char)
  if str == nil or str == "" then
    return
  end
  char = char == nil and "," or char
  local strArr = string.split(str, char)
  if #strArr < 2 then
    return vectorzero
  end
  if #strArr == 2 then
    return Vector2(tonumber(strArr[1]), tonumber(strArr[2]))
  elseif #strArr == 3 then
    return Vector3(tonumber(strArr[1]), tonumber(strArr[2]), tonumber(strArr[3]))
  end
end
function UIUtils.TransformPoint(rect1, rect2)
  return CS.LuaUIUtils.TransformPoint(rect1, rect2)
end
function UIUtils.CreateGameObj(pos, parent)
  return CS.LuaUIUtils.CreateGameObj(pos, parent)
end
function UIUtils.AddCanvas(obj, sort)
  CS.LuaUIUtils.AddCanvas(obj, sort)
end
function UIUtils.AddHyperTextListener(obj, func)
  CS.LuaUIUtils.AddHyperTextListener(obj, func)
end
function UIUtils.PopupHintMessage(hintId)
  local hint = TableData.GetHintById(hintId)
  if hint == nil then
    hint = ""
  end
  CS.PopupMessageManager.PopupString(hint)
end
function UIUtils.PopupErrorWithHint(hintId)
  UIUtils.PopupHintMessage(hintId)
end
function UIUtils.PopupPositiveHintMessage(hintId)
  local hint = TableData.GetHintById(hintId)
  if hint == nil then
    hint = ""
  end
  CS.PopupMessageManager.PopupPositiveString(hint)
end
function UIUtils.GetStringWordNum(str)
  local lenInByte = #str
  local count = 0
  local i = 1
  while true do
    local curByte = string.byte(str, i)
    if lenInByte < i then
      break
    end
    local byteCount = 1
    if 0 < curByte and curByte < 128 then
      byteCount = 1
    elseif 128 <= curByte and curByte < 224 then
      byteCount = 2
    elseif 224 <= curByte and curByte < 240 then
      byteCount = 3
    elseif 240 <= curByte and curByte <= 247 then
      byteCount = 4
    else
      break
    end
    i = i + byteCount
    count = count + 1
  end
  return count
end
function UIUtils.GetEffectMaxDuration(gameObj)
  local duration = 0
  local particleComponents = getparticlesinchildren(gameObj)
  for i = 0, particleComponents.Length - 1 do
    if duration < particleComponents[i].main.duration then
      duration = particleComponents[i].main.duration
    end
  end
  return duration
end
function UIUtils.CallWithAniDelay(obj, callback, aniName)
  local root = UIUtils.GetRectTransform(obj, "Root")
  if root then
    local aniTime = root.gameObject:GetComponent("AniTime")
    local animtor = root.gameObject:GetComponent(typeof(CS.UnityEngine.Animator))
    if aniTime and animtor then
      if aniName == nil then
        animtor:SetTrigger("FadeOut")
      else
        animtor:SetTrigger(aniName)
      end
      TimerSys:DelayCall(aniTime.m_FadeOutTime, function()
        if callback then
          callback()
        end
      end)
    elseif callback then
      callback()
    end
  elseif callback then
    callback()
  end
end
function UIUtils.NumberToString(szNum)
  local szChMoney = ""
  local iLen = 0
  local iNum = 0
  local iAddZero = 0
  local hzUnit = {"", "十"}
  local hzNum = {
    "零",
    "一",
    "二",
    "三",
    "四",
    "五",
    "六",
    "七",
    "八",
    "九"
  }
  if nil == tonumber(szNum) then
    return tostring(szNum)
  end
  iLen = string.len(szNum)
  if 3 < iLen or iLen == 0 or 0 > tonumber(szNum) then
    return tostring(szNum)
  end
  for i = 1, iLen do
    iNum = string.sub(szNum, i, i)
    if iNum == 0 and i ~= iLen then
      iAddZero = iAddZero + 1
    else
      if 0 < iAddZero then
        szChMoney = szChMoney .. hzNum[1]
      end
      szChMoney = szChMoney .. hzNum[iNum + 1]
      iAddZero = 0
    end
    if iAddZero < 4 and (0 == (iLen - i) % 4 or 0 ~= tonumber(iNum)) then
      szChMoney = szChMoney .. hzUnit[iLen - i + 1]
    end
  end
  local removeZero = function(num)
    num = tostring(num)
    local szLen = string.len(num)
    local zero_num = 0
    for i = szLen, 1, -3 do
      szNum = string.sub(num, i - 2, i)
      if szNum == hzNum[1] then
        zero_num = zero_num + 1
      else
        break
      end
    end
    num = string.sub(num, 1, szLen - zero_num * 3)
    szNum = string.sub(num, 1, 6)
    if szNum == hzNum[2] .. hzUnit[2] then
      num = string.sub(num, 4, string.len(num))
    end
    return num
  end
  return removeZero(szChMoney)
end
function UIUtils.CheckInputIsLegal(input)
  return CS.LuaUIUtils.CheckInputIsLegal(input)
end
function UIUtils.ScrollRectGotoSelect(selected, scrollRect, viewport)
  CS.LuaUIUtils.ScrollRectGotoSelect(selected, scrollRect, viewport)
end
function UIUtils.BreviaryText(message, textComp, maxLength)
  return CS.LuaUIUtils.BreviaryText(message, textComp, maxLength)
end
function UIUtils.GetFontWidth(message, textComp)
  return CS.LuaUIUtils.GetFontWidth(message, textComp)
end
function UIUtils.InitUITimeCountDown(go, time, template)
  CS.LuaUIUtils.InitUITimerCountDown(go, time, template)
end
function UIUtils.InitUITextGroupUp(go, formValue, toValue)
  CS.LuaUIUtils.InitUITextGroupUp(go, formValue, toValue)
end
function UIUtils.StopUITextGroupUp(go)
  CS.LuaUIUtils.StopUITextGroupUp(go)
end
function UIUtils.PlayLayoutElementHeightAni(go, fromValue, toValue, duartion, callback)
  CS.LuaUIUtils.PlayLayoutElementHeightAni(go, fromValue, toValue, duartion, callback)
end
function UIUtils.PlayUITypeWrite(go, content, tempStr)
  CS.LuaUIUtils.PlayUITypeWrite(go, content, tempStr)
end
function UIUtils.StopUITypeWrite(go)
  CS.LuaUIUtils.StopUITypeWrite(go)
end
function UIUtils.GetItemHaveAndCostText(haveCount, cost)
  if haveCount < cost then
    return "<color=#FF5E41>" .. haveCount .. "</color>/" .. cost
  else
    return haveCount .. "/" .. cost
  end
end
function UIUtils.CheckIsUnLock(jumpID, callback)
  local jumpData = TableData.listJumpListContentnewDatas:GetDataById(jumpID)
  local jumpType = jumpData.Behavior
  local unlockNum = TableData.listJumpBehaviorDatas:GetDataById(jumpType).UnlockId
  local contentUnlockNum = jumpData.unlock_id
  local jumpParam = string.split(jumpData.Args, ":")
  if 0 < unlockNum then
    local isLock = not AccountNetCmdHandler:CheckSystemIsUnLock(unlockNum)
    if isLock then
      return unlockNum
    end
  end
  if 0 < contentUnlockNum then
    local contentIsLock = not AccountNetCmdHandler:CheckSystemIsUnLock(contentUnlockNum)
    if contentIsLock then
      return contentUnlockNum
    end
  end
  if jumpType == 1000 and tonumber(jumpParam[2]) ~= 2 then
    return NetCmdDungeonData:IsUnLockChapter(tonumber(jumpParam[2])) == true and 0 or -2
  elseif jumpType == 1001 or jumpType == 1002 then
    if jumpParam[3] and 0 < tonumber(jumpParam[3]) then
      local stageID = tonumber(jumpParam[3])
      local storyData = TableData.listStoryDatas:GetDataById(stageID)
      if storyData == nil then
        return -2
      end
      local chapterId = storyData.chapter
      if NetCmdDungeonData:IsUnLockChapter(chapterId) then
        return NetCmdDungeonData:IsUnLockStory(stageID) == true and 0 or -2
      end
      return -2
    else
      local chapterID = tonumber(jumpParam[2])
      if 0 < chapterID then
        return NetCmdDungeonData:IsUnLockChapter(chapterID) == true and 0 or -2
      else
        return 0
      end
    end
  else
    if 0 < jumpData.plan_open then
      local simCombatID = jumpData.plan_open_args
      local simType = jumpData.plan_open_function
      local isInOpenTime = true
      if 0 < simType and 0 < simCombatID then
        local curPlan = NetCmdSimulateBattleData:GetPlanByType(simType)
        if curPlan == nil then
          NetCmdSimulateBattleData:ReqPlanData(simType, function()
            callback()
          end)
          return
        else
          isInOpenTime = UIUtils.CheckWeeklyIsOpen(curPlan, simCombatID)
        end
      end
      if isInOpenTime == false then
        return -1
      end
    end
    local simCombatStageID
    local unlockStageID = 0
    local unlockLevel = 0
    local SimCombatDailyData
    simCombatStageID = tonumber(jumpParam[1]) or 0
    if jumpType == 1003 then
      simCombatStageID = tonumber(jumpParam[2]) or 0
    end
    if simCombatStageID == 0 then
      return 0
    end
    SimCombatDailyData = TableData.listSimCombatResourceDatas:GetDataById(simCombatStageID, true)
    if SimCombatDailyData then
      unlockStageID = SimCombatDailyData.unlock_detail
    end
    if SimCombatDailyData == nil then
      return 0
    end
    unlockLevel = SimCombatDailyData.unlock_level
    local isReachNeedLevel = unlockLevel <= AccountNetCmdHandler:GetLevel()
    if unlockStageID == 0 then
      return 0
    end
    local preStageRecord = NetCmdStageRecordData:GetStageRecordById(unlockStageID, false)
    if preStageRecord ~= nil and 0 < preStageRecord.first_pass_time and isReachNeedLevel then
      return 0
    end
    return -2
  end
  return 0
end
function UIUtils.CheckWeeklyIsOpen(plan, simType)
  if plan == nil then
    gfwarning("Invalid plan !!!!!!!!!!!!!")
    return false
  end
  local args = plan.Args
  if CGameTime:GetTimestamp() > plan.CloseTime then
    return false
  else
    for i = 0, args.Count - 1 do
      if simType == args[i] then
        return true
      end
    end
    return false
  end
end
function UIUtils.DigitNum(num)
  if math.floor(num) ~= num or num < 0 then
    return -1
  elseif 0 == num then
    return 1
  else
    local digit = 0
    while 0 < num do
      num = math.floor(num / 10)
      digit = digit + 1
    end
    return digit
  end
end
function UIUtils.AddZeroFrontNum(destDigit, num)
  local curDigit = UIUtils.DigitNum(num)
  if -1 == curDigit then
    return -1
  elseif destDigit <= curDigit then
    return tostring(num)
  else
    local str_e = ""
    for var = 1, destDigit - curDigit do
      str_e = str_e .. "0"
    end
    return str_e .. tostring(num)
  end
end
function UIUtils.CheckIsTimeOut(time)
  local nowTime = CGameTime:GetTimestamp()
  local result = time < nowTime
  return result
end
function UIUtils.SetStringLocal(key, value)
  local saveKey = string.format("%d_%s", AccountNetCmdHandler.Uid, key)
  PlayerPrefs.SetString(saveKey, value)
end
function UIUtils.GetStringLocal(key)
  local getKey = string.format("%d_%s", AccountNetCmdHandler.Uid, key)
  return PlayerPrefs.GetString(getKey)
end
function UIUtils.SetIntLocal(key, value)
  local saveKey = string.format("%d_%s", AccountNetCmdHandler.Uid, key)
  PlayerPrefs.SetInt(saveKey, value)
end
function UIUtils.GetIntLocal(key)
  local getKey = string.format("%d_%s", AccountNetCmdHandler.Uid, key)
  return PlayerPrefs.GetInt(getKey)
end
function UIUtils:CloneGo(pref, parent, count, func, startCount)
  if parent == nil or pref == nil then
    return
  end
  startCount = startCount or 0
  count = count or 1
  pref = pref.gameObject
  parent = parent.transform
  for i = 1, count do
    local go
    if i > parent.childCount - startCount then
      go = instantiate(pref, parent)
      go.transform:SetAsLastSibling()
    else
      go = parent:GetChild(i - 1 + startCount).gameObject
    end
    setactive(go, true)
    if func ~= nil then
      func(go, i)
    end
  end
  for i = count + startCount, parent.childCount - 1 do
    setactive(parent:GetChild(i).gameObject, false)
  end
end
function UIUtils.ScrollMoveToMidWithSidebar(toPosX, totalWidth, sidebarWidth, scrollRectTransform, needScroll, scrollTime, forceToX)
  forceToX = forceToX and forceToX or false
  local toX = (totalWidth - sidebarWidth) / 2 - toPosX
  if forceToX then
    toX = toPosX
  end
  local toPos = Vector3(toX, scrollRectTransform.localPosition.y, 0)
  scrollTime = scrollTime and scrollTime or 0.3
  if needScroll then
    CS.UITweenManager.PlayLocalPositionTween(scrollRectTransform, scrollRectTransform.localPosition, toPos, scrollTime)
  else
    scrollRectTransform.localPosition = toPos
  end
end
function UIUtils.EnableGraphicRaycaster(gameobj, enable)
  enable = enable and enable or false
  local raycaster = UIUtils.GetGraphicRaycaster(gameobj)
  if not raycaster then
    return
  end
  raycaster.enabled = enable
end
function UIUtils.AnimatorFadeInOut(animator, isFadeIn)
  if not animator then
    return
  end
  if isFadeIn then
    UIUtils.AnimatorFadeIn(animator)
  else
    UIUtils.AnimatorFadeOut(animator)
  end
end
function UIUtils.AnimatorFadeIn(animator)
  if not animator then
    return
  end
  animator:ResetTrigger("FadeOut")
  animator:SetTrigger("FadeIn")
end
function UIUtils.AnimatorFadeOut(animator)
  if not animator then
    return
  end
  animator:ResetTrigger("FadeIn")
  animator:SetTrigger("FadeOut")
end
function UIUtils.IsNullOrDestroyed(unityObj)
  return CS.LuaUtils.IsNullOrDestroyed(unityObj)
end
function UIUtils.GetItemName(itemId)
  if not itemId then
    print_error("Item ID Can Not Is NUll")
    return ""
  end
  local itemData = TableData.listItemDatas:GetDataById(itemId)
  local itemName = itemData.name
  if not itemName then
    print_error("Item Name Is Null :" .. tostring(itemId))
    return ""
  end
  return itemData.name.str
end
function UIUtils.GetItemIcon(itemId)
  if not itemId then
    print_error("Item ID Can Not Is NUll")
    return ""
  end
  return IconUtils.GetItemIconSprite(itemId)
end
function UIUtils.DoScrollFade(component)
  if UIUtils.IsNullOrDestroyed(component) then
    print_error("component Can Not Is NUll")
    return
  end
  local gameObject = component.gameObject
  if UIUtils.IsNullOrDestroyed(gameObject) then
    print_error("gameObject Can Not Is NUll")
    return
  end
  local scrollFade = gameObject:GetComponent(typeof(CS.ScrollFade))
  if not scrollFade then
    print_error("gameObject Not ScrollFade Component")
    return
  end
  return scrollFade:DoScrollFade()
end
function UIUtils.ChangeNumDigit(num)
  if type(num) ~= "number" then
    gfdebug("类型传输错误，返回默认值，请检查道具" .. self.itemID)
    return 0
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
function UIUtils.ChangeNumByDigit(num, digit)
  if type(num) ~= "number" then
    gfdebug("类型传输错误，返回默认值，请检查")
    return 0
  end
  digit = digit == nil and 3 or digit
  local hint
  if digit == 3 then
    hint = TableData.GetHintById(901062)
  elseif digit == 6 then
    hint = TableData.GetHintById(901063)
  elseif digit == 9 then
    hint = TableData.GetHintById(901064)
  end
  if num < 10 ^ digit then
    return num
  else
    hint = TableData.GetHintById(901062)
    local result = num / 10 ^ digit
    local result1, result2 = math.modf(result)
    if result1 < 10 and 0.1 <= result2 then
      local decimal = math.modf(result2 * 10) * 0.1
      return string_format(hint, result1 + decimal)
    else
      return string_format(hint, result1)
    end
  end
end
function UIUtils.GetIfNotEnoughText(itemId, cost)
  local haveCount = NetCmdItemData:GetNetItemCount(itemId)
  local haveDigit = UIUtils.ChangeNumDigit(haveCount)
  local costDigit = UIUtils.ChangeNumDigit(cost)
  if cost > haveCount then
    return "<color=#FF5E41>" .. haveDigit .. "</color>/" .. costDigit
  else
    return haveDigit .. "/" .. costDigit
  end
end
function UIUtils.GetIfNotEnoughTextWithDigit(itemId, cost, digit)
  if digit == nil then
    digit = 5
  end
  local haveCount = NetCmdItemData:GetNetItemCount(itemId)
  local haveDigit = CS.LuaUIUtils.GetNumberText(haveCount, digit)
  local costDigit = UIUtils.ChangeNumDigit(cost)
  if cost > haveCount then
    return "<color=#FF5E41>" .. haveDigit .. "</color>/" .. costDigit
  else
    return haveDigit .. "/" .. costDigit
  end
end
function UIUtils.SetParent(obj, parent, worldPositionStays)
  worldPositionStays = worldPositionStays and worldPositionStays or false
  CS.LuaUIUtils.SetParentNew(obj.gameObject, parent.gameObject, worldPositionStays)
end
function UIUtils.CheckUnlockPopupStr(unlockData)
  return CS.LuaUIUtils.CheckUnlockPopupStr(unlockData)
end
function UIUtils.SortItemTable(itemTable)
  table.sort(itemTable, function(a, b)
    local id1 = a.itemId or a.ItemId
    local id2 = b.itemId or b.ItemId
    local data1 = TableData.GetItemData(id1)
    local data2 = TableData.GetItemData(id2)
    local typeData1 = TableData.listItemTypeDescDatas:GetDataById(data1.type)
    local typeData2 = TableData.listItemTypeDescDatas:GetDataById(data2.type)
    if typeData1.rank ~= typeData2.rank then
      return typeData2.rank > typeData1.rank
    end
    if data1.type ~= data2.type then
      return data2.type > data1.type
    end
    if data1.rank ~= data2.rank then
      return data2.rank < data1.rank
    end
    return data1.Id > data2.Id
  end)
end
function UIUtils.AddDrop(dropCaches, drop)
  local dropIsCredit = UIUtils.IfNeedSpecialMerge(drop.itemId)
  for _, dropCache in pairs(dropCaches) do
    local isCredit = UIUtils.IsCreditItem(dropCache.itemId)
    local isNeedMerge = isCredit and dropIsCredit
    if dropCache.itemId == drop.itemId or isNeedMerge then
      dropCache.itemNum = dropCache.itemNum + drop.itemNum
      return
    end
  end
  table.insert(dropCaches, drop)
end
function UIUtils.GetKVSortItemTable(kvSortList)
  local dataList = {}
  local count = kvSortList.Key.Count
  for i = 0, count - 1 do
    local t = {}
    t.id = kvSortList.Key[i]
    t.num = kvSortList.Value[i]
    table.insert(dataList, t)
  end
  return dataList
end
function UIUtils.IfNeedSpecialMerge(itemId)
  return UIUtils.IsCreditItem(itemId) and TableDataBase.SystemVersionOpenData.FreePayCredit == 0
end
function UIUtils.IsCreditItem(itemId)
  return itemId == GlobalConfig.ResourceType.CreditPay or itemId == GlobalConfig.ResourceType.CreditFree
end
function UIUtils.GetItemTypeOrder(type)
  if type then
    local list = TableData.GlobalSystemData.LauncherItemType
    for i = 0, list.Length - 1 do
      if list[i] == type then
        return i
      end
    end
  end
  return -1
end
function UIUtils.SortStageNormalDrop(normalDropList)
  local itemIdList = {}
  if normalDropList then
    for key, v in pairs(normalDropList) do
      table.insert(itemIdList, key)
    end
    table.sort(itemIdList, function(a, b)
      local data1 = TableData.listItemDatas:GetDataById(a)
      local data2 = TableData.listItemDatas:GetDataById(b)
      local typeOrder1 = UIUtils.GetItemTypeOrder(data1.type)
      local typeOrder2 = UIUtils.GetItemTypeOrder(data2.type)
      if typeOrder1 == typeOrder2 then
        if data1.rank == data2.rank then
          return data1.id > data2.id
        end
        return data1.rank > data2.rank
      end
      return typeOrder1 < typeOrder2
    end)
  end
  return itemIdList
end
function UIUtils.DormChrChange(gunId, callback)
  CS.LoungeModelManager.Instance:SwitchGunModel(gunId, callback)
  LoungeHelper.CameraCtrl.CameraPreObj:ExitLookAt()
end
