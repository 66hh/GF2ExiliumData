AdjutantChrChangeItemData = class("AdjutantChrChangeItemData")
local self = AdjutantChrChangeItemData
function AdjutantChrChangeItemData:ctor()
  self.adjutantIds = nil
  self.adjutantData = nil
  self.pos = -1
  self.gunData = nil
  self.isOnClick = false
  self.isLock = false
end
function AdjutantChrChangeItemData:InitCtrl()
end
function AdjutantChrChangeItemData:SetAdjutantListData(data, pos)
  self.characterId = data.characterId
  self.adjutantId = NetCmdCommandCenterAdjutantData.AllAdjutantDic[self.characterId][0]
  local tmpAdjutant = TableData.listAdjutantDatas:GetDataById(self.adjutantId)
  self.adjutantIds = data.adjutantIds
  self.isLock = tmpAdjutant.unlock == 2 and not NetCmdCommandCenterAdjutantData.AllAdjutantDic[self.characterId]:Contains(tmpAdjutant.Id)
  self.adjutantData = nil
  self.gunData = nil
  local checkPos = function(index)
    local tmpAdjutant = NetCmdCommandCenterAdjutantData.AdjutantDatas[index]
    if tmpAdjutant ~= nil then
      if self.characterId == TableData.listGunDatas:GetDataById(tmpAdjutant.DetailId).CharacterId and not self.isLock then
        self.adjutantData = tmpAdjutant
        self.gunData = TableData.listGunDatas:GetDataById(tmpAdjutant.DetailId)
        self.pos = index
        self.isOnClick = true
        return true
      else
        self.pos = -1
      end
    end
    return false
  end
  if pos ~= nil then
    if checkPos(pos) then
    end
  elseif checkPos(0) and self.pos == 0 then
  else
    for i = 1, NetCmdCommandCenterAdjutantData.AdjutantDatas.Count - 1 do
      if checkPos(i) then
        break
      end
    end
  end
  if self.adjutantData == nil then
    local tmpAdjutant = TableData.listAdjutantDatas:GetDataById(self.adjutantIds[0])
    self.gunData = TableData.listGunDatas:GetDataById(tmpAdjutant.DetailId)
    for i = 0, self.adjutantIds.Count - 1 do
      local adjutantId = self.adjutantIds[i]
      local campAdjutant = TableData.listAdjutantDatas:GetDataById(adjutantId)
      local campGun = TableData.listGunDatas:GetDataById(campAdjutant.DetailId)
      if campGun.Rank > self.gunData.Rank then
        tmpAdjutant = campAdjutant
        self.gunData = campGun
      end
    end
    self.adjutantData = tmpAdjutant
  end
  self.characterData = TableData.listGunCharacterDatas:GetDataById(self.gunData.CharacterId)
end
function AdjutantChrChangeItemData:OnRelease()
end
