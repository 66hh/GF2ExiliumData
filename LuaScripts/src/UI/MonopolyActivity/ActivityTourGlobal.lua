require("UI.UIBasePanel")
ActivityTourGlobal = class("ActivityTourGlobal", UIBasePanel)
ActivityTourGlobal.__index = ActivityTourGlobal
ActivityTourGlobal = {}
ActivityTourGlobal.Camp = CS.GF2.Monopoly.Camp.Player
ActivityTourGlobal.MonsterCamp_Int = CS.LuaUtils.EnumToInt(CS.GF2.Monopoly.Camp.Monster)
ActivityTourGlobal.PlayerCamp_Int = CS.LuaUtils.EnumToInt(CS.GF2.Monopoly.Camp.Player)
ActivityTourGlobal.MonopolyFunctionType = CS.GF2.Monopoly.MonopolyFunctionType
ActivityTourGlobal.ActorType = CS.GF2.Monopoly.MonopolyActorDefine.ActorType
ActivityTourGlobal.SelectObjType_None = CS.LuaUtils.EnumToInt(CS.GF2.Monopoly.SelectObjType.None)
ActivityTourGlobal.SelectObjType_Actor = CS.LuaUtils.EnumToInt(CS.GF2.Monopoly.SelectObjType.Actor)
ActivityTourGlobal.SelectObjType_Grid = CS.LuaUtils.EnumToInt(CS.GF2.Monopoly.SelectObjType.Grid)
ActivityTourGlobal.OccupyCampPlayer = CS.LuaUtils.EnumToInt(CS.GF2.Monopoly.Camp.Player)
ActivityTourGlobal.MapGridRowCount = CS.MonoPolyMananger.GridNum
ActivityTourGlobal.EventSelectDialog_UIType = CS.GF2.Monopoly.EventSelectDialog_UIType
ActivityTourGlobal.TreatmentSelectDialog_UIType = CS.GF2.Monopoly.TreatmentSelectDialog_UIType
ActivityTourGlobal.MaxCommandNum = 5
function ActivityTourGlobal.SetGlobalValue()
  MpGridManager = CS.GF2.Monopoly.MpGridManager.Instance
  MonopolyWorld = CS.GF2.Monopoly.MonopolyWorld.Instance
  MonopolySelectManager = CS.GF2.Monopoly.MonopolySelectManager.Instance
end
ActivityTourGlobal.NumberTip = 1
ActivityTourGlobal.InspirationTip = 2
ActivityTourGlobal.PointPath = "Icon_ActivityTourMove_Point_"
ActivityTourGlobal.EventPointBuffIconPath = "Item_Icon_Activity_Buff"
ActivityTourGlobal.EventPointBuffRare = 2
ActivityTourGlobal.EncounterBgDir = "ActivityTourMap"
ActivityTourGlobal.StoreTabType_Buy = 1
ActivityTourGlobal.StoreTabType_Compose = 2
ActivityTourGlobal.ColorSkinType = {
  Color1 = "color1",
  Color2 = "color2",
  Color3 = "color3"
}
ActivityTourGlobal.DeleteCommandType = {Bag = 0, Get = 1}
ActivityTourGlobal.CommandType = CS.GF2.Data.OrderType
ActivityTourGlobal.CommandType_RandomMovePoint = CS.LuaUtils.EnumToInt(CS.GF2.Data.OrderType.Random)
ActivityTourGlobal.CommandType_ManualMovePoint = CS.LuaUtils.EnumToInt(CS.GF2.Data.OrderType.Selected)
ActivityTourGlobal.FinishType = CS.ProtoObject.MonopolyRoom.Types.FinishType
ActivityTourGlobal.FinishType_Win = CS.LuaUtils.EnumToInt(CS.ProtoObject.MonopolyRoom.Types.FinishType.Win)
ActivityTourGlobal.FinishType_Lose = CS.LuaUtils.EnumToInt(CS.ProtoObject.MonopolyRoom.Types.FinishType.Lose)
ActivityTourGlobal.RandomRewardType = CS.ProtoObject.MonopolyPlayer.Types.RewardType
ActivityTourGlobal.MonopolyDefine = CS.GF2.Monopoly.MonopolyDefine
ActivityTourGlobal.MaxHp = CS.GF2.Monopoly.MonopolyDefine.MaxHp
ActivityTourGlobal.PointsId = CS.GF2.Monopoly.MonopolyDefine.PointsId
ActivityTourGlobal.OrderSelectType_SelfActor = CS.LuaUtils.EnumToInt(CS.GF2.Monopoly.OrderSelectType.SelfActor)
ActivityTourGlobal.ShowPointType = CS.GF2.Monopoly.MonopolyDefine.ShowPointType
ActivityTourGlobal.ShowDetailType = CS.GF2.Monopoly.ShowDetailType
ActivityTourGlobal.PointChangeReason = CS.ProtoObject.PointChangeReason
ActivityTourGlobal.ErrorCodeActivityNotOpenOrClosed = LuaUtils.EnumToInt(CS.ProtoCsmsg.ErrorCode.ActivityNotOpenOrClosed)
function ActivityTourGlobal.GetActivityTourSprite(spriteName)
  return IconUtils.GetAtlasV2("ActivityTour", spriteName)
end
function ActivityTourGlobal.GetCommandItemQualityColor(rank)
  return TableData.GetActivityTourCommand_Quality_Color(rank)
end
function ActivityTourGlobal.ReplaceAllColor(uiRoot)
  ActivityTourGlobal.ReplaceColor(uiRoot, ActivityTourGlobal.ColorSkinType.Color1)
  ActivityTourGlobal.ReplaceColor(uiRoot, ActivityTourGlobal.ColorSkinType.Color2)
  ActivityTourGlobal.ReplaceColor(uiRoot, ActivityTourGlobal.ColorSkinType.Color3)
end
function ActivityTourGlobal.ReplaceColor(uiRoot, colorSkinType)
  local monopolyConfig = NetCmdThemeData:GetCurrMonopolyCfg()
  if not monopolyConfig then
    return
  end
  local colorStr = monopolyConfig.theme_color
  if colorSkinType == ActivityTourGlobal.ColorSkinType.Color2 then
    colorStr = monopolyConfig.sup_color
  elseif colorSkinType == ActivityTourGlobal.ColorSkinType.Color3 then
    colorStr = monopolyConfig.logo_color
  end
  CS.UIReplaceSkin.ReplaceColor(uiRoot, colorSkinType, ColorUtils.StringToColor(colorStr))
end
function ActivityTourGlobal.ReplaceImageDir(uiRoot)
  local monopolyConfig = NetCmdThemeData:GetCurrMonopolyCfg()
  if not monopolyConfig then
    return
  end
  CS.UIReplaceSkin.ReplaceImageDir(uiRoot, "image", monopolyConfig.pic_resoures)
end
function ActivityTourGlobal.GetMaxWillValue(gunID)
  local gun = NetCmdTeamData:GetGunByID(gunID)
  if gun == nil then
    return 0
  end
  return gun:GetGunPropertyValueByType(CS.GF2.Data.DevelopProperty.MaxWillValue)
end
