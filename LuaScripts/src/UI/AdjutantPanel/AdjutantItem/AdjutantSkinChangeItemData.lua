AdjutantSkinChangeItemData = class("AdjutantSkinChangeItemData")
local self = AdjutantSkinChangeItemData
function AdjutantSkinChangeItemData:ctor()
  self.adjutantId = 0
  self.adjutantData = nil
  self.gunData = nil
  self.isLock = false
  self.isOnClick = false
end
function AdjutantSkinChangeItemData:InitCtrl()
end
function AdjutantSkinChangeItemData:SetAdjutantSkinListData(characterId, adjutantId)
  self.adjutantId = adjutantId
  self.adjutantData = TableData.listAdjutantDatas:GetDataById(adjutantId)
  self.isLock = self.adjutantData.unlock == 2 and not NetCmdCommandCenterAdjutantData.AllAdjutantDic[characterId]:Contains(adjutantId)
  self.gunData = TableData.listGunDatas:GetDataById(self.adjutantData.DetailId)
end
