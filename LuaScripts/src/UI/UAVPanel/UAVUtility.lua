UAVUtility = {}
UAVUtility.NowArmId = -1
UAVUtility.NowRealBottomArmId = -2
UAVUtility.NowBottomPos = -1
UAVUtility.NowFakeBottomArmId = -2
UAVUtility.IsClickUninstall = false
UAVUtility.OnlyRefreshOnce = false
UAVUtility.AniState = -1
UAVUtility.BreakLevelDic = nil
UAVUtility.uavmaxlevelDic = nil
UAVUtility.IsPlayAnim = false
function UAVUtility:InitData()
end
function UAVUtility:GetUavGrade(uavlevel)
end
function UAVUtility:GetUavLevelMax(uavgrade)
end
function UAVUtility:GetUavRealMaxLevel()
end
function UAVUtility.GetUavArmMaxLevel(uavArmLevelCostId)
  local curLevelCostTable = {}
  local dataList = TableData.listUavArmLevelCostDatas:GetList()
  for i = 0, dataList.Count - 1 do
    if dataList[i].uav_arm_level_cost == uavArmLevelCostId then
      table.insert(curLevelCostTable, dataList[i])
    end
  end
  table.sort(curLevelCostTable, function(a, b)
    return a.id < b.id
  end)
  return curLevelCostTable[#curLevelCostTable].id
end
function UAVUtility:GetLevelUpCost(uavArmLevelCostId, curLevel)
  local dataList = TableData.listUavArmLevelCostDatas:GetList()
  for i = 0, dataList.Count - 1 do
    local dataRow = dataList[i]
    if dataRow.Id == curLevel + 1 and dataRow.UavArmLevelCost == uavArmLevelCostId then
      return dataRow.Cost
    end
  end
  return 0
end
