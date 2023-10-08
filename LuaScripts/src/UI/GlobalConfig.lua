GlobalConfig = {}
GlobalConfig.StaminaId = 101
GlobalConfig.PVPTicketId = 102
GlobalConfig.DiamondId = 1
GlobalConfig.CoinId = 2
GlobalConfig.MaxStaminaId = 6
GlobalConfig.TrainingTicket = 9
GlobalConfig.GunExpItem = 25
GlobalConfig.DZCoinId = 18
GlobalConfig.WeaponCoin = 26
GlobalConfig.WeaponEvolutionItem = 8300
GlobalConfig.LotteryMachine = 170001
GlobalConfig.MaxChallenge = 3
GlobalConfig.MaxStar = 6
GlobalConfig.GunMaxStar = 5
GlobalConfig.MaxEquipCount = 3
GlobalConfig.UavBreakMatNum = 1
GlobalConfig.ContentPrefabOrder = 5
GlobalConfig.IsOpenStagePanelByJumpUI = false
GlobalConfig.ItemType = {
  Resource = CS.GF2.Data.ItemType.Resource:GetHashCode(),
  Packages = CS.GF2.Data.ItemType.DropPackage:GetHashCode(),
  StaminaType = CS.GF2.Data.ItemType.Stamina:GetHashCode(),
  GunType = CS.GF2.Data.ItemType.Gun:GetHashCode(),
  GunCore = CS.GF2.Data.ItemType.GunCore:GetHashCode(),
  Weapon = CS.GF2.Data.ItemType.GunWeapon:GetHashCode(),
  GiftPick = CS.GF2.Data.ItemType.Giftpick:GetHashCode(),
  WeaponPart = CS.GF2.Data.ItemType.WeaponPart:GetHashCode(),
  EquipmentType = 0,
  DarkzoneCure = CS.GF2.Data.ItemType.DarkzoneCure:GetHashCode(),
  DarkzoneResource = CS.GF2.Data.ItemType.DarkzoneResource:GetHashCode(),
  RogueBuff = CS.GF2.Data.ItemType.RogueBuff:GetHashCode(),
  Talent = CS.GF2.Data.ItemType.Talent:GetHashCode(),
  ItemPackage = CS.GF2.Data.ItemType.ItemPackage:GetHashCode(),
  PlayerAvatar = CS.GF2.Data.ItemType.PlayerAvatar:GetHashCode(),
  Title = CS.GF2.Data.ItemType.Title:GetHashCode(),
  Medal = CS.GF2.Data.ItemType.Medal:GetHashCode(),
  PlayerAvatarFrame = CS.GF2.Data.ItemType.PlayerFrame:GetHashCode(),
  Robot = CS.GF2.Data.ItemType.Robot:GetHashCode(),
  RobotPackage = CS.GF2.Data.ItemType.RobotPackage:GetHashCode(),
  Wishcreate = CS.GF2.Data.ItemType.Wishcreate:GetHashCode(),
  WishMaterial = CS.GF2.Data.ItemType.WishMaterial:GetHashCode(),
  Costume = CS.GF2.Data.ItemType.Costume:GetHashCode(),
  Random = CS.GF2.Data.ItemType.Random:GetHashCode()
}
GlobalConfig.ResourceType = {
  Diamond = CS.GF2.Data.ResourceType.Diamond:GetHashCode(),
  CreditPay = CS.GF2.Data.ResourceType.CreditPay:GetHashCode(),
  CreditFree = CS.GF2.Data.ResourceType.CreditFree:GetHashCode()
}
GlobalConfig.CanUseItemType = {
  [CS.GF2.Data.ItemType.Usable:GetHashCode()] = 1,
  [CS.GF2.Data.ItemType.MonthlyCard:GetHashCode()] = 1,
  [CS.GF2.Data.ItemType.Pass:GetHashCode()] = 1
}
GlobalConfig.RecordFlag = {NotFirstGacha = 0, NameModified = 1}
GlobalConfig.StoryType = {
  Normal = 1,
  Story = 2,
  Hide = 3,
  Hard = 4,
  StoryBattle = 5,
  Branch = 11
}
GlobalConfig.SortType = {
  Level = 1,
  Rank = 2,
  Time = 3,
  Prop = 4,
  Quality = 5
}
GlobalConfig.TeamCount = 5
function GlobalConfig.GetCostHintStr(costNum)
  if costNum then
    return string_format(TableData.GetHintById(804), costNum)
  end
end
function GlobalConfig.GetCostNotEnoughStr(itemId)
  if itemId then
    local itemData = TableData.listItemDatas:GetDataById(itemId)
    if itemData then
      local hint = string_format(TableData.GetHintById(225), itemData.name.str)
      return hint
    end
  end
  return ""
end
function GlobalConfig.SetLvText(level)
  local strLv = TableData.GetHintById(80057)
  return string_format(strLv, level)
end
function GlobalConfig.SetLvTextWithMax(level, maxLevel)
  local strLv = TableData.GetHintById(80057)
  return string_format(strLv, level) .. "/" .. maxLevel
end
function GlobalConfig.ParseItemStr(str)
  local itemList = {}
  local s1 = string.split(str, ",")
  for i, v in ipairs(s1) do
    local s2 = string.split(v, ":")
    table.insert(itemList, s2)
  end
  return itemList
end
