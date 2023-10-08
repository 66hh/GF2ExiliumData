UISimCombatRogueGlobal = {}
UISimCombatRogueGlobal.CurItemTier = 0
UISimCombatRogueGlobal.CurItem = nil
UISimCombatRogueGlobal.CurTier = 0
UISimCombatRogueGlobal.ChapterItemWidth = 400
UISimCombatRogueGlobal.ChapterNumWidth = 67
UISimCombatRogueGlobal.BattleDetailWidth = 420
UISimCombatRogueGlobal.PriceType = CS.GF2.Data.ResourceType.RogueCoin
UISimCombatRogueGlobal.RoguePreGunCount = 4
UISimCombatRogueGlobal.ChapterItemMoveDuration = 0.3
UISimCombatRogueGlobal.RogueMode = {
  Normal = CS.ProtoObject.RogueType.Ordinary,
  Challenge = CS.ProtoObject.RogueType.Challenge
}
UISimCombatRogueGlobal.ItemState = {
  During = 1,
  Lock = 2,
  Normal = 3,
  Finish = 4
}
UISimCombatRogueGlobal.ItemMode = {
  Normal = 1,
  GrpBoss = 2,
  Ex = 3
}
UISimCombatRogueGlobal.IconType = {
  Battle = 1,
  BattleDetailBg = 2,
  ModeSel = 3
}
UISimCombatRogueGlobal.RogueStoreTabBtnTypes = {Buy = 1, Sell = 2}
UISimCombatRogueGlobal.RogueStoreTypes = {Gun = 1, Buff = 2}
UISimCombatRogueGlobal.StoreTypes = {
  Gun = CS.GF2.Data.GoodsType.RogueGunPreset,
  Buff = CS.GF2.Data.GoodsType.RogueShopBuff
}
UISimCombatRogueGlobal.ItemTypes = {Gun = 27, Buff = 28}
UISimCombatRogueGlobal.RogueStoreTabBtns = {
  {
    BtnType = UISimCombatRogueGlobal.RogueStoreTabBtnTypes.Buy,
    HintId = 111021
  },
  {
    BtnType = UISimCombatRogueGlobal.RogueStoreTabBtnTypes.Sell,
    HintId = 111022
  }
}
UISimCombatRogueGlobal.RogueTargetState = {
  Finished = CS.RogueTargetState.Finished,
  Unfinish = CS.RogueTargetState.Unfinish,
  Receive = CS.RogueTargetState.Receive
}
UISimCombatRogueGlobal.SettlementTextColor = {
  Normal = "<color=#84a8ae>{0}</color>",
  Challenge = "<color=#ce4848>{0}</color>"
}
UISimCombatRogueGlobal.challengeFuncList = {}
function UISimCombatRogueGlobal.GetRogueIcon(type, iconname)
  local prefix = "Img_SimCombatMythic_"
  if type == UISimCombatRogueGlobal.IconType.Battle then
    iconname = prefix .. "Battle_" .. iconname
  elseif type == UISimCombatRogueGlobal.IconType.BattleDetailBg then
    iconname = prefix .. "BattleDetailBg" .. iconname
  elseif type == UISimCombatRogueGlobal.IconType.ModeSel then
    iconname = prefix .. "ModeSel_" .. iconname
  end
  return IconUtils.GetRogueIcon(iconname)
end
function UISimCombatRogueGlobal.GetBuffCost(storeGoodData, rogueBuffCofigData)
  local key = string_format("{0}#{1}", storeGoodData.Tag, storeGoodData.Id)
  local storeHistory = NetCmdStoreData:GetGoodsHistoryById(key)
  local count = 0
  if storeHistory ~= nil then
    count = storeHistory.Count
  end
  local rogueBuffCostlist = {}
  for i = 0, storeGoodData.PriceArgs.Count - 1 do
    local pricearr = string.split(storeGoodData.PriceArgs[i], ":")
    table.insert(rogueBuffCostlist, {
      Level = tonumber(pricearr[2]),
      Price = tonumber(pricearr[1])
    })
  end
  table.sort(rogueBuffCostlist, function(a, b)
    return a.Level < b.Level
  end)
  for i, v in ipairs(rogueBuffCostlist) do
    if count < v.Level then
      return v.Price
    end
  end
end
function UISimCombatRogueGlobal.GetBuyLeastBuffNum(curLevel, maxLevel)
  return math.ceil(maxLevel / curLevel)
end
function UISimCombatRogueGlobal.InitChallengeFuncList()
  UISimCombatRogueGlobal.challengeFuncList = {}
end
function UISimCombatRogueGlobal.AddChallengeFuncList(funcName, func, param)
  table.insert(UISimCombatRogueGlobal.challengeFuncList, {
    funcName = funcName,
    func = func,
    param = param
  })
end
function UISimCombatRogueGlobal.ExcuteChallengeFuncList()
  if #UISimCombatRogueGlobal.challengeFuncList ~= 0 then
    local func = UISimCombatRogueGlobal.challengeFuncList[1].func
    local param = UISimCombatRogueGlobal.challengeFuncList[1].param
    table.remove(UISimCombatRogueGlobal.challengeFuncList, 1)
    func(param)
  end
end
function UISimCombatRogueGlobal.NextChallengeFuncList()
  UISimCombatRogueGlobal.ExcuteChallengeFuncList()
end
function UISimCombatRogueGlobal.InitRogueTarget()
end
function UISimCombatRogueGlobal.GetTargetState(id)
  local allTask = NetCmdQuestData:GetSimCombatRogueReward()
  for i, v in pairs(allTask) do
    if id == i then
      if v then
        return UISimCombatRogueGlobal.RogueTargetState.Finished
      else
        return UISimCombatRogueGlobal.RogueTargetState.Receive
      end
    end
  end
  return UISimCombatRogueGlobal.RogueTargetState.Unfinish
end
function UISimCombatRogueGlobal.HasCanReceiveTarget()
  return NetCmdSimCombatRogueData:HasCanReceiveTarget()
end
