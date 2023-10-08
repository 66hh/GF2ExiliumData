UIPVPRankItem = class("UIPVPRankItem", UIBaseCtrl)
function UIPVPRankItem:ctor()
end
function UIPVPRankItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  self.avatarTable = {}
end
function UIPVPRankItem:SetData(data)
  if not data then
    return
  end
  local user = data.User
  local levelDataRow = UIPVPGlobal.GetCurSeasonLevelDataRow(data.Points, data.Rank)
  if not levelDataRow then
    return
  end
  setactive(self.ui.mImage_SelfLine.gameObject, user.Uid == AccountNetCmdHandler:GetUID())
  self.ui.mText_Rank.text = levelDataRow.Name.str
  self.ui.mText_PlayerName.text = user.Name
  self.ui.mText_Num.text = data.Points
  self.ui.mText_Level.text = TableData.GetHintReplaceById(80057, user.Level)
  if data.Rank < 10 then
    self.ui.mText_Ranking.text = "0" .. data.Rank
  else
    self.ui.mText_Ranking.text = data.Rank
  end
  if not self.playerAvatarItem then
    self.playerAvatarItem = UICommonPlayerAvatarItem.New()
    self.playerAvatarItem:InitCtrlByScrollChild(self.ui.mScrollListChild.childItem, self.ui.mScrollListChild.transform)
    self.playerAvatarItem:EnableBtn(false)
    self.playerAvatarItem:AddBtnListener(function()
      self:OnClickUserAvatar()
    end)
  end
  self.playerAvatarItem:SetData(TableData.GetPlayerAvatarIconById(user.Portrait, user.Sex.value__))
  self.ui.mImg_RankBg.sprite = IconUtils.GetAtlasSprite("PVPPic/Img_PVPRank_Chess_" .. levelDataRow.Section .. "_Bg")
  self.ui.mImg_RankIcon.sprite = IconUtils.GetAtlasSprite("PVPPic/Img_PVPRank_Chess_" .. levelDataRow.Section)
  self.ui.mImg_RankNum.sprite = IconUtils.GetAtlasSprite("PVPPic/Img_PVPRank_Num_" .. levelDataRow.Icon)
  self:InitAvatarGrpList(data)
end
function UIPVPRankItem:InitAvatarGrpList(data)
  if not self.avatarTable or #self.avatarTable == 0 then
    self.avatarTable = {}
    local gunLimit = 4
    for i = 0, gunLimit - 1 do
      local rankAvatarItem = UIPVPRankGunAvatarItem.New()
      rankAvatarItem:InitCtrl(self.ui.mGrp_ChrList)
      table.insert(self.avatarTable, rankAvatarItem)
    end
  end
  local gunAvatarTable = {
    nil,
    nil,
    nil,
    nil
  }
  if data and data.GunDetails then
    local gunAvatarList = data.GunDetails[0]
    for i = 0, gunAvatarList.Count - 1 do
      if gunAvatarList[i].Id ~= 0 then
        table.insert(gunAvatarTable, gunAvatarList[i])
      end
    end
  end
  for i = 1, #self.avatarTable do
    self.avatarTable[i]:SetData(gunAvatarTable[i], data.User)
  end
end
function UIPVPRankItem:OnClickUserAvatar()
end
function UIPVPRankItem:OnRelease()
  for i = #self.avatarTable, 1, -1 do
    self.avatarTable[i]:OnRelease()
  end
  if self.playerAvatarItem then
    self.playerAvatarItem:OnRelease()
  end
  self.playerAvatarItem = nil
  self.avatarTable = nil
end
