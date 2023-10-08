UIActivityItemConfig = {}
UIActivityItemConfig[LuaUtils.EnumToInt(CS.OperationActivityType.SignIn)] = {
  itemClass = UIActivitySignInItem,
  prefabPath = "Activity/SignIn/ActivitySignInItem.prefab"
}
UIActivityItemConfig[LuaUtils.EnumToInt(CS.OperationActivityType.AmoWish)] = {
  itemClass = UIActivityAmoWishItem,
  prefabPath = "Activity/AmoWish/AmoWishActivityItem.prefab"
}
UIActivityItemConfig[LuaUtils.EnumToInt(CS.OperationActivityType.SevenQuest)] = {
  itemClass = UIActivitySevenQuestItem,
  prefabPath = "Activity/SevenQuest/SevenQuestItem.prefab"
}
UIActivityItemConfig[LuaUtils.EnumToInt(CS.OperationActivityType.Guiding)] = {
  itemClass = UIActivityGuidingItem,
  prefabPath = "Activity/Guiding/GuidingActivityItem.prefab"
}
