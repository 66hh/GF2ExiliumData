DZStoreUtils = {}
DZStoreUtils.LastTab = nil
DZStoreUtils.LastSellBtn = nil
DZStoreUtils.SellItemDataDic = {}
DZStoreUtils.NpcStoreStateDic = {}
DZStoreUtils.redDotList = {}
DZStoreUtils.selectQuestGroupId = nil
DZStoreUtils.selectQuestTargetId = nil
DZStoreUtils.curNpcId = nil
DZStoreUtils.NpcStateDic = {}
function DZStoreUtils:GetCurFavorLevelAndExp(NpcId, favorNum)
  local StcData = TableData.listDarkzoneNpcParameterDatas
  local favorMax = TableDataBase.GlobalDarkzoneData.DarkzoneNpcMaxFavorLevel
  local tableID = (NpcId - 400) * 1000
  for i = 1, favorMax do
    if i < favorMax then
      local nowdata = StcData:GetDataById(tableID + i)
      local nextdata = StcData:GetDataById(tableID + i + 1)
      if favorNum == nowdata.need_favor_point then
        return i, nowdata.need_favor_point, nextdata.need_favor_point, nowdata.discount
      elseif favorNum < nextdata.need_favor_point then
        return i, favorNum, nextdata.need_favor_point, nowdata.discount
      end
    else
      local data = StcData:GetDataById(tableID + i)
      return i, data.need_favor_point, data.need_favor_point, data.discount
    end
  end
end
function DZStoreUtils:UpdateNpcStateDic(list)
  local result = {}
  for i = 1, #list do
    local Data = list[i]
    local IsUnlock = false
    if Data.unlock == CS.GF2.Data.DarkzoneNpcUnlockType.None then
      IsUnlock = true
    elseif Data.unlock == CS.GF2.Data.DarkzoneNpcUnlockType.Level then
      if AccountNetCmdHandler:GetLevel() < Data.unlock_parameter_1 then
        IsUnlock = false
      else
        IsUnlock = true
      end
    elseif Data.unlock == CS.GF2.Data.DarkzoneNpcUnlockType.NpcFavor then
      local NetData = DarkNetCmdStoreData:GetNpcDataById(Data.unlock_parameter_1)
      if NetData == nil then
        IsUnlock = false
      else
        local favor = NetData.Favor
        local favorLevel = DZStoreUtils:GetCurFavorLevelAndExp(Data.id, favor)
        if favorLevel >= Data.unlock_parameter_2 then
          IsUnlock = true
        end
      end
    end
    result[list[i].id] = IsUnlock
  end
  DZStoreUtils.NpcStateDic = result
  return result
end
function DZStoreUtils:SetIndex(num)
  if 1 <= num and num <= 9 then
    return "0" .. tostring(num)
  else
    return tostring(num)
  end
end
