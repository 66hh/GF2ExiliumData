require("UI.UIBaseCtrl")
UICommonEnemyItem = class("UICommonEnemyItem", UIBaseCtrl)
UICommonEnemyItem.__index = UICommonEnemyItem
function UICommonEnemyItem:ctor()
  self.rankList = {}
  self.unKnowEnemySprite = {
    [1] = "Avatar_Head_Unknown",
    [2] = "Avatar_Head_Unknown",
    [3] = "Avatar_Head_Unknown"
  }
end
function UICommonEnemyItem:__InitCtrl()
  self.mBtn_OpenDetail = self:GetSelfButton()
  self.mImage_Icon = self:GetImage("GrpEnemyIcon/ImgBg/Img_EnemyIcon")
  self.mText_Level = self:GetText("GrpLevel/Text_Level")
  self.mTrans_Level = self:GetRectTransform("GrpLevel")
  self.mTrans_Lv = self:GetRectTransform("GrpLevel/TextLv")
  setactive(self.mTrans_Lv, false)
  for i = 1, 3 do
    local obj = self:GetRectTransform("GrpEnemyRank/Trans_rank" .. i)
    table.insert(self.rankList, obj)
  end
end
function UICommonEnemyItem:InitCtrl(parent, useNewSetParent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComEnemyInfoItemV2.prefab", self))
  useNewSetParent = useNewSetParent and useNewSetParent or false
  if parent then
    if useNewSetParent then
      UIUtils.SetParent(obj.gameObject, parent.gameObject)
    else
      CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, false)
    end
  end
  self:SetRoot(obj.transform)
  self:__InitCtrl()
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self.obj = obj
end
function UICommonEnemyItem:InitRoot(root)
  self:SetRoot(root.transform)
  self:__InitCtrl()
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
end
function UICommonEnemyItem:SetData(code, stageLevel, IsDarkZone, DzLevel)
  if code then
    self.mImage_Icon.sprite = IconUtils.GetEnemyCharacterHeadSprite(code.character_pic)
    local showLevel = code.add_level + (stageLevel == nil and 0 or stageLevel)
    self.mText_Level.text = TableData.GetHintById(80057, tostring(showLevel))
    if IsDarkZone then
      if DzLevel[1] == DzLevel[2] then
        self.mText_Level.text = DzLevel[2]
      else
        setactive(self.mTrans_Lv, false)
        self.mText_Level.text = string_format(TableData.GetHintById(80057), DzLevel[1]) .. "-" .. DzLevel[2]
      end
    end
    for i, obj in ipairs(self.rankList) do
      setactive(obj, i == code.rank)
    end
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
function UICommonEnemyItem:SetDarkzoneTargetIcon(isShow)
  setactive(self.ui.mTrans_TargetIcon, isShow)
  self.ui.mImg_Icon.sprite = IconUtils.GetDarkZoneModelIcon("Img_DarkzoneMode_Type_1")
end
function UICommonEnemyItem:HideDarkzoneRankIcon()
  for i = 1, 3 do
    setactive(self.rankList[i], false)
  end
end
function UICommonEnemyItem:SetUnKnowEnemyData(code)
  setactive(self.mTrans_Lv, false)
  self.mText_Level.text = string_format(TableData.GetHintById(80057), "??")
  for i, obj in ipairs(self.rankList) do
    setactive(obj, i == code.rank)
  end
  self.mImage_Icon.sprite = IconUtils.GetCharacterHeadFullName(self.unKnowEnemySprite[code.rank])
end
function UICommonEnemyItem:EnableLv(enable)
  setactive(self.mTrans_Level, enable)
end
function UICommonEnemyItem:OnRelease()
  self:DestroySelf()
end
