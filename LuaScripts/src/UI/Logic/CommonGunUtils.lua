CommonGunUtils = {}
local this = CommonGunUtils
CommonGunUtils.sortKeyState = 0
CommonGunUtils.sortAscOrder = 0
function CommonGunUtils.SortGunByKeyState(isSortAD, keyState, gunList)
  CommonGunUtils.sortAscOrder = isSortAD
  CommonGunUtils.sortKeyState = keyState
  table.sort(gunList, CommonGunUtils.SortSubFunction)
end
function CommonGunUtils.SortSubFunction(gunAItem, gunBItem)
  local gunATableData = TableData.GetGunData(gunAItem.stc_gun_id)
  local gunBTableData = TableData.GetGunData(gunBItem.stc_gun_id)
  if CommonGunUtils.sortKeyState == 1 then
    if gunAItem.level == gunBItem.Level then
      return false
    elseif CommonGunUtils.sortAscOrder then
      return gunAItem.level > gunBItem.level
    else
      return gunAItem.level < gunBItem.level
    end
  end
  if CommonGunUtils.sortKeyState == 2 then
  end
  if CommonGunUtils.sortKeyState == 3 then
  end
  if CommonGunUtils.sortKeyState == 4 then
    if gunATableData.rank == gunBTableData.rank then
      return false
    elseif CommonGunUtils.sortAscOrder then
      return gunATableData.rank > gunBTableData.rank
    else
      return gunATableData.rank < gunBTableData.rank
    end
  end
  if CommonGunUtils.sortKeyState == 5 then
    if gunAItem.hp == gunBItem.hp then
      return false
    elseif CommonGunUtils.sortAscOrder then
      return gunAItem.hp > gunBItem.hp
    else
      return gunAItem.hp < gunBItem.hp
    end
  end
  if CommonGunUtils.sortKeyState == 6 then
    if gunAItem.team_id == gunBItem.team_id then
      return false
    elseif CommonGunUtils.sortAscOrder then
      return gunAItem.team_id > gunBItem.team_id
    else
      return gunAItem.team_id < gunBItem.team_id
    end
  end
  if CommonGunUtils.sortKeyState == 7 then
    if gunAItem.wear == gunBItem.wear then
      return false
    elseif CommonGunUtils.sortAscOrder then
      return gunAItem.wear < gunBItem.wear
    else
      return gunAItem.wear > gunBItem.wear
    end
  end
  return false
end
