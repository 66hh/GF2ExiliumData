require("UI.UIBaseCtrl")
require("UI.Common.UICommonGetWayItem")
UICommonGetWayTitleItem = class("UICommonGetWayTitleItem", UIBaseCtrl)
UICommonGetWayTitleItem.__index = UICommonGetWayTitleItem
UICommonGetWayTitleItem.mText_HowToGetTypeText = nil
UICommonGetWayTitleItem.getWayUpperLimit = nil
function UICommonGetWayTitleItem:__InitCtrl()
  self.mText_HowToGetTypeText = self:GetText("HowToGetType/Text_Titlename")
  self.mTrans_HowToGetList = self:GetRectTransform("HowToGetList")
end
function UICommonGetWayTitleItem:ctor()
  UICommonGetWayTitleItem.super.ctor(self)
  self.getWayUpperLimit = TableData.GlobalSystemData.GetwayStoryUpperlimit
  self.infoList = {}
end
function UICommonGetWayTitleItem:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/UICommonGetWayTitleItem.prefab", self))
  setparent(parent, obj.transform)
  obj.transform.localScale = vectorone
  obj.transform.localPosition = vectorone
  self:SetRoot(obj.transform)
  self:__InitCtrl()
end
function UICommonGetWayTitleItem:SetData(data)
  if data then
    self.mText_HowToGetTypeText.text = data.title
    if data.getList then
      local getList = data.getList
      if data.type == 9 or data.type == 14 or data.type == 16 then
        getList = self:FilterChapterItem(data.getList, data.type)
      end
      for _, item in ipairs(self.infoList) do
        item:SetData(nil)
      end
      for i, howToGet in ipairs(getList) do
        local item
        if i <= #self.infoList then
          item = self.infoList[i]
        else
          item = UICommonGetWayItem.New()
          item:InitCtrl(self.mTrans_HowToGetList)
          table.insert(self.infoList, item)
        end
        data.howToGetData = howToGet
        item:SetData(data)
      end
    end
    setactive(self.mUIRoot.gameObject, true)
  else
    setactive(self.mUIRoot.gameObject, false)
  end
end
function UICommonGetWayTitleItem:FilterChapterItem(list, type)
  local showList = {}
  for i, itemData in ipairs(list) do
    local item = {}
    if type == 9 or type == 14 then
      item.isUnLock = self:CheckIsUnLock(itemData.jump_code)
    elseif type == 16 then
      item.isUnLock = self:CheckSimulateBattleIsUnLock(itemData.jump_code)
    end
    item.data = itemData
    if i <= self.getWayUpperLimit then
      table.insert(showList, item)
    elseif item.isUnLock then
      table.remove(showList, 1)
      table.insert(showList, item)
    else
      break
    end
  end
  table.sort(showList, function(a, b)
    local tValueA, tValueB
    tValueA, tValueB = a.isUnLock == true or false, b.isUnLock == true or false
    if tValueA ~= tValueB then
      if tValueA then
        return true
      else
        return false
      end
    elseif tValueA then
      return a.data.id > b.data.id
    else
      return a.data.id < b.data.id
    end
  end)
  local list = {}
  for _, v in ipairs(showList) do
    table.insert(list, v.data)
  end
  return list
end
function UICommonGetWayTitleItem:CheckIsUnLock(jump_code)
  local jumpDataID = tonumber(jump_code)
  local data = TableData.listStoryDatas:GetDataById(jumpDataID)
  local args = data.args
  local argList
  if string.len(args) > 0 then
    argList = string.split(args, ":")
    for i = 1, #argList do
      argList[i] = tonumber(argList[i])
    end
  end
  if argList then
    if argList[1] and 0 < argList[1] then
      return NetCmdDungeonData:IsUnLockChapter(argList[1])
    elseif argList[2] and 0 < argList[2] then
      local chapterId = TableData.listStoryDatas:GetDataById(argList[2]).chapter
      if NetCmdDungeonData:IsUnLockChapter(chapterId) then
        return NetCmdDungeonData:IsUnLockStory(argList[2])
      end
      return false
    end
    return true
  end
  return true
end
function UICommonGetWayTitleItem:CheckSimulateBattleIsUnLock(jump_code)
  local jumpDataID = tonumber(jump_code)
  local data = TableData.listStoryDatas:GetDataById(jumpDataID)
  local args = data.args
  local argList
  if string.len(args) > 0 then
    argList = string.split(args, ":")
    for i = 1, #argList do
      argList[i] = tonumber(argList[i])
    end
  end
  if argList then
    if argList[1] and 0 < argList[1] then
      return NetCmdSimulateBattleData:CheckStageIsUnLock(argList[1])
    end
    return true
  end
  return true
end
