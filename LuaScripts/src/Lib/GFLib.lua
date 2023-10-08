require("Lib.class")
require("Lib.List")
require("Lib.Dictionary")
require("UI.UIUtils")
require("UI.UIManager")
vectorone = CS.UnityEngine.Vector3.one
vectorzero = CS.UnityEngine.Vector3.zero
vector2one = CS.UnityEngine.Vector2.one
vector2zero = CS.UnityEngine.Vector2.zero
VirtualListRendererChangeData = CS.VirtualListRendererChangeData
GlobalTab = CS.GlobalTab
Time = CS.UnityEngine.Time
GFUtils = CS.GFUtils
GFMath = CS.GFMath
CmdConst = CS.CmdConst
GCFGConst = CS.GF2.Data.GCFGConst
CarrierPropNo = CS.GF2.Data.CarrierPropNo
TableData = CS.GF2.Data.TableData
TableDataBase = CS.GF2.Data.TableDataBase
GlobalData = CS.GF2.Data.GlobalData
SystemList = CS.GF2.Data.SystemList
AVGController = CS.AVGController
ResSys = CS.ResSys.Instance
GameObject = CS.UnityEngine.GameObject
Transform = CS.UnityEngine.Transform
RectTransform = CS.UnityEngine.RectTransform
InputSys = CS.InputSys.Instance
MessageBox = CS.MessageBox
PopupMessageManager = CS.PopupMessageManager
UISystem = CS.UISystem.Instance
UI3DModelManager = CS.UISystem.Instance
SceneSys = CS.SceneSys.Instance
CharacterPicUtils = CS.CharacterPicUtils
IconUtils = CS.IconUtils
Tween = CS.DG.Tweening
DOTween = CS.LuaDOTweenUtils
NetCmdItemsData = CS.NetCmdItemData.Instance
UITweenManager = CS.UITweenManager
Color = CS.UnityEngine.Color
CSUIUtils = CS.UIUtils
Vector3 = CS.UnityEngine.Vector3
Vector2 = CS.UnityEngine.Vector2
System = CS.System
DateTime = CS.System.DateTime
TimeSpan = CS.System.TimeSpan
ScrollAlign = CS.ScrollAlign
NetCmdTrainGunData = CS.NetCmdTrainGunData.Instance
MessageSys = CS.GF2.Message.MessageSys.Instance
TimerSys = CS.GF2.Timer.TimerSys.Instance
PropertyUtils = CS.PropertyUtils
DevelopProperty = CS.GF2.Data.DevelopProperty
NetCmdTeamData = CS.NetCmdTeamData.Instance
NetCmdPVPData = CS.NetCmdPVPData.Instance
NetCmdQuestData = CS.NetCmdQuestData.Instance
NetCmdPVPQuestData = CS.NetCmdPVPQuestData.Instance
NetCmdCommonQuestData = CS.NetCmdCommonQuestData.Instance
NetCmdChatData = CS.NetCmdChatData.Instance
ResourceManager = CS.Framework.ResSys.ResourceManager.ResourceManager.Instance
NetCmdUavData = CS.NetCmdUavData.Instance
NetCmdItemData = CS.NetCmdItemData.Instance
NetTeamHandle = CS.NetCmdTeamData.Instance
CampaignPool = CS.CampaignPool.Instance
TableDataMgr = CS.TableDataManager.Instance
CarrierTrainNetCmdHandler = CS.CarrierNetCmdHandler.Instance
CarrierNetCmdHandler = CS.CarrierNetCmdHandler.Instance
GashaponNetCmdHandler = CS.GashaponNetCmdHandler.Instance
NetCmdSimulateBattleData = CS.NetCmdSimulateBattleData.Instance
NetCmdCoreData = CS.NetCmdCoreData.Instance
NetCmdFacilityData = CS.NetCmdFacilityData.Instance
NetCmdEquipData = CS.NetCmdEquipData.Instance
NetCmdGunEquipData = CS.NetCmdGunEquipData.Instance
NetCmdStageRatingData = CS.NetCmdStageRatingData.Instance
NetCmdStoreData = CS.NetCmdStoreData.Instance
NetCmdNpcData = CS.NetCmdNpcData.Instance
NetCmdDormData = CS.NetCmdDormData.Instance
AccountNetCmdHandler = CS.AccountNetCmdHandler.Instance
NetCmdMailData = CS.NetCmdMailData.Instance
NetCmdCommanderData = CS.NetCmdCommanderData.Instance
NetCmdDungeonData = CS.NetCmdDungeonData.Instance
NetCmdIllustrationData = CS.NetCmdIllustrationData.Instance
PlayerNetCmdHandler = CS.PlayerNetCmdHandler.Instance
BattleNetCmdHandler = CS.BattleNetCmdHandler.Instance
CGameTime = CS.CGameTime.Instance
NetCmdStageRecordData = CS.NetCmdStageRecordData.Instance
PostInfoConfig = CS.PostInfoConfig
NetCmdChipData = CS.NetCmdChipData.Instance
NetCmdGunSkillData = CS.NetCmdGunSkillData.Instance
NetCmdExpeditionData = CS.NetCmdExpeditionData.Instance
NetCmdGuildData = CS.NetCmdGuildData.Instance
NetCmdFriendData = CS.NetCmdFriendData.Instance
NetCmdRaidData = CS.NetCmdRaidData.Instance
NetCmdBannerData = CS.NetCmdBannerData.Instance
NetCmdAchieveData = CS.NetCmdAchieveData.Instance
NetCmdRecentActivityData = CS.NetCmdRecentActivityData.Instance
NetCmdArchivesData = CS.NetCmdArchivesData.Instance
NetCmdCheckInData = CS.NetCmdCheckInData.Instance
NetCmdWeaponData = CS.NetCmdWeaponData.Instance
NetCmdWeaponPartsData = CS.NetCmdWeaponPartsData.Instance
NetCmdRankData = CS.NetCmdRankData.Instance
NetCmdRedPointData = CS.NetCmdRedPointData.Instance
NetCmdDormLetterData = CS.NetCmdDormLetterData.Instance
NetCmdSimCombatRogueData = CS.NetCmdSimCombatRogueData.Instance
NetCmdGunClothesData = CS.NetCmdGunClothesData.Instance
NetCmdCommandCenterAdjutantData = CS.NetCmdCommandCenterAdjutantData.Instance
NetCmdCommandCenterData = CS.NetCmdCommandCenterData.Instance
NetCmdSimCombatMythicData = CS.NetCmdSimCombatMythicData.Instance
NetCmdOperationActivityData = CS.NetCmdOperationActivityData.Instance
NetCmdOperationActivity_SignInData = CS.NetCmdOperationActivity_SignInData.Instance
TextData = CS.TextData.Instance
NetCmdDormDataV2 = CS.NetCmdDormDataV2.Instance
GameSettingConfig = CS.GameSettingConfig
SaveUtility = CS.SaveUtility
JumpSystem = CS.JumpSystem.Instance
DarkNetCmdTeamData = CS.DarkNetCmdTeamData.Instance
NetCmdBattlePassData = CS.NetCmdBattlePassData.Instance
GunListFilter = CS.GunListFilter
RoleInfoCtrl = CS.RoleInfoCtrl
ComPropsDetailsHelper = CS.ComPropsDetailsHelper.Instance
ComScreenItemHelper = CS.ComScreenItemHelper.Instance
TransformUtils = CS.TransformUtils
DarkZoneTeamData = CS.DarkZoneTeamData
UIDarkZoneTeamModelManager = CS.UIDarkZoneTeamModelManager.Instance
SceneObjManager = CS.SceneObjManager.Instance
SceneSwitch = CS.SceneSwitch.Instance
VirtualList = CS.VirtualList
TutorialSystem = CS.GF2.Tutorial.TutorialSystem.Instance
UnlockByTutorialSystem = CS.UnlockByTutorialSystem.Instance
DarkRoleData = CS.DarkRoleData.Instance
TimeMgrDark = CS.TimeMgr.Instance
AFKBattleManager = CS.AFKBattleManager.Instance
DarkNetCmdData = CS.DarkNetCmdData.Instance
PropertyHelper = CS.PropertyHelper
KeyCode = CS.UnityEngine.KeyCode
StageType = CS.GF2.Data.StageType
AudioUtils = CS.GF2.Audio.AudioUtils
DarkNetCmdCraftData = CS.DarkNetCmdCraftData.Instance
DarkNetCmdMatchData = CS.DarkNetCmdMatchData.Instance
DarkNetCmdStoreData = CS.DarkNetCmdStoreData.Instance
DarkZoneNetRepoCmdData = CS.DarkZoneNetRepoCmdData.Instance
DarkNetCmdLeaveData = CS.DarkNetCmdLeaveData.Instance
PlayerPrefs = CS.UnityEngine.PlayerPrefs
PropertyWrapper = CS.GF2.Battle.Property.Wrapper.PropertyWrapper
DormCameraUtils = CS.DormCameraUtils.Instance
SupplyHelper = CS.SupplyHelper.Instance
NetCmdTalentData = CS.NetCmdTalentData.Instance
LuaBindingNew = CS.XLua.LuaUiBind.LuaBindingNew
ItemType = CS.GF2.Data.ItemType
CMDRetSuc = CS.CMDRet.eSuccess
PlanType = CS.GF2.Data.PlanType
PlanActivityType = CS.GF2.Data.PlanActivityType
RenderDataItem = CS.RenderDataItem
UITweenManager = CS.UITweenManager
ScrollListChild = CS.ScrollListChild
RectOffset = CS.UnityEngine.RectOffset
DropType = CS.ProtoCsmsg.StageDrop.Types.DropType
UIEvent = CS.GF2.Message.UIEvent
MonopolyEvent = CS.GF2.Message.MonopolyEvent
SystemEvent = CS.GF2.Message.SystemEvent
BarrackCameraStand = CS.BarrackCameraStand
LuaDOTweenUtils = CS.LuaDOTweenUtils
SceneSys = CS.SceneSys.Instance
EnumSceneType = CS.EnumSceneType
GuideEvent = CS.GF2.Message.GuideEvent
UIBarrackModelManager = CS.UIBarrackModelManager.Instance
UIBarrackWeaponModelManager = CS.UIBarrackWeaponModelManager.Instance
LayoutRebuilder = CS.UnityEngine.UI.LayoutRebuilder
BarrackHelper = CS.BarrackHelper
BarrackCameraOperate = CS.BarrackCameraOperate
NetCmdTutorialDataV2 = CS.NetCmdTutorialDataV2.Instance
InputKeySys = CS.InputKeySys.Instance
NetCmdDarkZoneSeasonData = CS.NetCmdDarkZoneSeasonData.Instance
LuaUtils = CS.LuaUtils
Ease = CS.DG.Tweening.Ease
UIGroupType = CS.UISystem.UIGroupType
ErrorCodeSuc = LuaUtils.EnumToInt(CS.ProtoCsmsg.ErrorCode.Success)
RedPointSystem = require("UI.RedPoint.RadPointSystem")
RedPointManager = CS.RedPointManager.Instance
UIRedPointWatcher = CS.UIRedPointWatcher
NewRedPointConst = CS.RedPointConst
DarkZoneNetRepositoryData = CS.DarkZoneNetRepositoryData.Instance
DarkNetCmdMakeTableData = CS.DarkNetCmdMakeTableData.Instance
NetCmdThemeData = CS.NetCmdThemeData.Instance
NetCmdActivityGachaData = CS.NetCmdActivityGachaData.Instance
NetCmdActivitySevenQuestData = CS.NetCmdActivitySevenQuestData.Instance
NetCmdActivityGuidingData = CS.NetCmdActivityGuidingData.Instance
OssEvent = CS.GF2.Message.OssEvent
NetCmdActivityAmoData = CS.NetCmdActivityAmoData.Instance
NetCmdMonopolyData = CS.NetCmdMonopolyData.Instance
DeepLinkManager = CS.Framework.DeepLink.DeepLinkManager.Instance
LoungeHelper = CS.LoungeHelper
NetCmdLoungeData = CS.NetCmdLoungeData.Instance
GunTypeStr = {
  "HG",
  "SMG",
  "RF",
  "AR",
  "MG",
  "SG"
}
RankFrame = {
  "NewCommonResource_Common_Frame_1",
  "NewCommonResource_Common_Frame_2",
  "NewCommonResource_Common_Frame_3",
  "NewCommonResource_Common_Frame_4",
  "NewCommonResource_Common_Frame_5",
  "NewCommonResource_Common_Frame_6"
}
LeaderBoardType = {
  AllLeaderBoardType = 0,
  WeeklySimCombatLeaderBoardType = 1,
  NrtPvpLeaderBoardType = 2
}
function gfenum(tbl, index)
  local enumtbl = {}
  local enumindex = index or 0
  for i, v in ipairs(tbl) do
    enumtbl[v] = enumindex + i
  end
  return enumtbl
end
function formatnum(num)
  if num <= 0 then
    return 0
  else
    local t1, t2 = math.modf(num)
    if 0 < t2 then
      return num
    else
      return t1
    end
  end
end
function ResourceDestroy(gameobj)
  ResourceManager:DestroyInstance(gameobj)
end
function gfdestroy(gameobj)
  CS.LuaUtils.Destroy(gameobj)
end
function gf_delay_destroy(gameobj, delay)
  CS.LuaUtils.Destroy(gameobj, delay)
end
function printstack(originalInfo)
  local traceback = CS.LoggerHelperExtension.ConvertLuaTraceback(debug.traceback())
  print("<color=#EECF1EFF>" .. originalInfo .. "\n" .. traceback .. "</color>")
end
function print_cyan(...)
  gferror("<color=cyan>" .. "[Cyan] " .. (...) .. "</color> \n" .. debug.traceback())
end
function print_error(...)
  gferror((...) .. "\n" .. debug.traceback())
end
function print_debug(msg)
  gfdebug(msg)
end
function new_array(item_type, item_count)
  return CS.LuaUtils.CreateArrayInstance(item_type, item_count)
end
function new_list(item_type)
  return CS.LuaUtils.CreateListInstance(item_type)
end
local new_dictionary = function(key_type, value_type)
  return CS.LuaUtils.CreateDictionaryInstance(key_type, value_type)
end
local new_dictionary = function(key_type, value_type)
  return CS.LuaUtils.CreateDictionaryInstance(key_type, value_type)
end
function getcomponent(target, ctype)
  return CS.LuaUtils.GetComponent(target, ctype)
end
function getcomponentinchildren(target, ctype)
  return CS.LuaUtils.GetComponentInChildren(target, ctype)
end
function getComponentsInChildren(target, ctype)
  return CS.LuaUtils.GetComponentsInChildren(target, ctype)
end
function addcomponent(target, ctype)
  return CS.LuaUtils.AddComponent(target, ctype)
end
function getchildcomponent(target, child, ctype)
  return CS.LuaUtils.GetChildComponent(target, child, ctype)
end
function getparticlesinchildren(target)
  return CS.LuaUtils.GetParticlesInChildren(target)
end
function instantiate(prefab, parent, instantiateInWorldSpace)
  return CS.UnityEngine.GameObject.Instantiate(prefab, parent, instantiateInWorldSpace or false)
end
function setparent(parent, child)
  return CS.LuaUtils.SetParent(parent, child)
end
function setposition(obj, pos)
  return CS.LuaUtils.SetPosition(obj, pos)
end
function setscale(parent, child)
  return CS.LuaUtils.SetScale(parent, child)
end
function setangles(parent, child)
  return CS.LuaUtils.SetEulerAngles(parent, child)
end
function setrotation(parent, child)
  return CS.LuaUtils.SetRotation(parent, child)
end
function clearallchild(parent)
  return CS.LuaUtils.ClearAllChild(parent)
end
function setactive(objtranscomp, active)
  if objtranscomp == nil then
    print("设置了空的对象！！！！！")
  end
  return CS.LuaUtils.SetActive(objtranscomp, active)
end
function setchildactive(objtranscomp, index, active)
  if objtranscomp == nil then
    print("设置了空的对象！！！！！")
  end
  return CS.LuaUtils.SetChildActive(objtranscomp, index, active)
end
function setactivewithcheck(component, active)
  if component == nil then
    return
  end
  return LuaUtils.SetActiveWithCheck(component, active)
end
function array_iter(cs_array, index)
  if index < cs_array.Length then
    return index + 1, cs_array[index]
  end
end
function array_ipairs(cs_array)
  return array_iter, cs_array, 0
end
function list_iter(cs_ilist, index)
  if index < cs_ilist.Count then
    return index + 1, cs_ilist[index]
  end
end
function list_ipairs(cs_ilist)
  return list_iter, cs_ilist, 0
end
function dictionary_iter(cs_enumerator)
  if cs_enumerator:MoveNext() then
    local current = cs_enumerator.Current
    return current.Key, current.Value
  end
end
function dictionary_ipairs(cs_idictionary)
  local cs_enumerator = cs_idictionary:GetEnumerator()
  return dictionary_iter, cs_enumerator
end
function gfdebug(msg)
  CS.LuaUtils.Debug(msg)
end
function gferror(msg)
  CS.LuaUtils.Error(msg)
end
function gfwarning(msg)
  CS.LuaUtils.Warning(msg)
end
function string_format(fmt, ...)
  assert(fmt ~= nil, "Format error:Invalid Format String")
  local parms = {
    ...
  }
  local search = function(k)
    k = k + 1
    assert(k <= #parms and 0 <= k, "Format error:IndexOutOfRange")
    return tostring(parms[k])
  end
  return (string.gsub(fmt, "{(%d)}", search))
end
function setlayer(gameobj, layer, include_child)
  CS.LuaUtils.SetLayer(gameobj, layer, include_child)
end
function string.split(str, separator)
  local nFindStartIndex = 1
  local nSplitIndex = 1
  local nSplitArray = {}
  while true do
    local nFindLastIndex = string.find(str, separator, nFindStartIndex, true)
    if not nFindLastIndex then
      nSplitArray[nSplitIndex] = string.sub(str, nFindStartIndex, string.len(str))
      break
    end
    nSplitArray[nSplitIndex] = string.sub(str, nFindStartIndex, nFindLastIndex - 1)
    nFindStartIndex = nFindLastIndex + string.len(separator)
    nSplitIndex = nSplitIndex + 1
  end
  return nSplitArray
end
function math.pow(x, y)
  return x ^ y
end
function FormatNum(num)
  if num <= 0 then
    return 0
  else
    local t1, t2 = math.modf(num)
    if 0 < t2 then
      return num
    else
      return t1
    end
  end
end
function math.bit(value, bit_idx)
  if bit_idx <= 0 or value <= 0 then
    return 0
  end
  local a = 2 ^ bit_idx
  return math.floor(value % a * 2 / a)
end
function setRectTransformHeight(rt, height)
  local sizeDelta = rt.sizeDelta
  sizeDelta.y = height
  rt.sizeDelta = sizeDelta
end
function setRectTransformWidth(rt, width)
  local sizeDelta = rt.sizeDelta
  sizeDelta.x = width
  rt.sizeDelta = sizeDelta
end
function trim(str)
  return (string.gsub(str, "^%s*(.-)%s*$", "%1"))
end
function handler(obj, method)
  return function(...)
    return method(obj, ...)
  end
end
local rawpairs = pairs
function pairsBySort(tbl, func)
  if func == nil then
    return rawpairs(tbl)
  end
  local ary = {}
  local lastUsed = 0
  for key in rawpairs(tbl) do
    if lastUsed == 0 then
      ary[1] = key
    else
      local done = false
      for j = 1, lastUsed do
        if func(key, ary[j]) == true then
          done = true
          break
        end
      end
      if done == false then
        ary[lastUsed + 1] = key
      end
    end
    lastUsed = lastUsed + 1
  end
  local i = 0
  local iter = function()
    i = i + 1
    if ary[i] == nil then
      return nil
    else
      return ary[i], tbl[ary[i]]
    end
  end
  return iter
end
function deep_copy(object)
  local lookup_table = {}
  local function _copy(object)
    if type(object) ~= "table" then
      return object
    elseif lookup_table[object] then
      return lookup_table[object]
    end
    local new_table = {}
    lookup_table[object] = new_table
    for key, value in pairs(object) do
      new_table[_copy(key)] = _copy(value)
    end
    return setmetatable(new_table, getmetatable(object))
  end
  return _copy(object)
end
function tableIsContain(table, match)
  if type(table) == "table" then
    for i, item in ipairs(table) do
      if match(item) then
        return i, item
      end
    end
  end
  return -1, nil
end
function luaRoundNum(num)
  local n = math.modf(num)
  return n
end
function CSDictionary2LuaTable(dic)
  local table = {}
  if dic then
    for key, value in pairs(dic) do
      table[key] = value
    end
  end
  return table
end
function CSList2LuaTable(list, handler)
  local array = {}
  if list then
    for i = 0, list.Count - 1 do
      if handler then
        local value = handler(list[i])
        table.insert(array, value)
      else
        table.insert(array, list[i])
      end
    end
  end
  return array
end
function DightNum(num)
  if math.floor(num) ~= num or num < 0 then
    return -1
  elseif 0 == num then
    return 1
  else
    local tmp_dight = 0
    while 0 < num do
      num = math.floor(num / 10)
      tmp_dight = tmp_dight + 1
    end
    return tmp_dight
  end
end
function AddZeroFrontNum(dest_dight, num)
  local num_dight = DightNum(num)
  if -1 == num_dight then
    return -1
  elseif dest_dight <= num_dight then
    return tostring(num)
  else
    local str_e = ""
    for var = 1, dest_dight - num_dight do
      str_e = str_e .. "0"
    end
    return str_e .. tostring(num)
  end
end
function GetOrAddComponent(go, componentType)
  if go == nil then
    gferror("go is null")
    return
  end
  local component = go:GetComponent(typeof(componentType))
  if component == nil then
    component = go:AddComponent(typeof(componentType))
  end
  return component
end
