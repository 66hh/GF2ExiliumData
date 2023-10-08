require("UI.SimCombatPanel.Tutorial.Item.UISimCombatNoteSelItem")
require("UI.UIBaseCtrl")
UISimCombatNoteItem = class("UISimCombatNoteItem", UIBaseCtrl)
UISimCombatNoteItem.__index = UISimCombatNoteItem
function UISimCombatNoteItem:__InitCtrl()
end
function UISimCombatNoteItem:ctor()
  self.itemList = {}
end
function UISimCombatNoteItem:InitCtrl(parent)
  self.parent = parent
  local obj = instantiate(UIUtils.GetGizmosPrefab("SimCombatTutoria/SimCombatNoteItem.prefab", self))
  self:SetRoot(obj.transform)
  obj.transform:SetParent(parent, false)
  obj.transform.localScale = vectorone
  self:__InitCtrl()
  self.ui = {}
  self:LuaUIBindTable(obj.transform, self.ui)
  self.noteList = {}
end
function UISimCombatNoteItem:SetData(data)
  self.mData = data
  self.ui.mText_Title.text = data.StcData.chapter_name.str
  self.ui.mImg_Icon.sprite = IconUtils.GetAtlasV2("SimCombatTeaching", data.StcData.chapter_icon)
  self.tutorialLevelsList = data:GetLevelsWithTutorials()
  self.completedDataList = data:GetCompletedTutorials()
  self.readLevels = UISimCombatNoteItem.GetReadLevels()
  local index = 0
  local notReadLevels = {}
  for i = 0, self.tutorialLevelsList.Count - 1 do
    do
      local levelData = self.tutorialLevelsList[i]
      local tutorialData = levelData.TutorialList
      local notRead = true
      for k = 1, #self.readLevels do
        if self.readLevels[k] == levelData.StcData.id then
          notRead = false
        end
      end
      if notRead and levelData.IsCompleted then
        table.insert(notReadLevels, levelData.StcData.id)
      end
      for j = 0, tutorialData.Count - 1 do
        do
          local pptData = tutorialData[j]
          local item
          local key = index + 1
          if self.noteList[key] == nil then
            item = UISimCombatNoteSelItem.New()
            item:InitCtrl(self.ui.mTrans_Content)
            table.insert(self.noteList, item)
            UIUtils.GetButtonListener(item.ui.mBtn_Self.gameObject).onClick = function()
              if not self.completedDataList:Contains(pptData) then
                PopupMessageManager.PopupString(TableData.GetHintReplaceById(103044, levelData.StageData.name.str))
                return
              end
              if 0 < #notReadLevels then
                for l = 1, #notReadLevels do
                  table.insert(self.readLevels, notReadLevels[l])
                end
                self:SaveLevels()
                notReadLevels = {}
              end
              self:ShowGuide(self.completedDataList, key - 1)
            end
          else
            item = self.noteList[key]
          end
          item:SetData(pptData)
          item:SetRedPoint(self.completedDataList:Contains(pptData) and 0 < #notReadLevels)
          item:SetLock(not self.completedDataList:Contains(pptData))
          index = index + 1
        end
      end
    end
  end
end
function UISimCombatNoteItem:SaveLevels()
  local readNotes = ""
  for i = 1, #self.readLevels do
    if i == 1 then
      readNotes = readNotes .. self.readLevels[i]
    else
      readNotes = readNotes .. "," .. self.readLevels[i]
    end
  end
  gfdebug(readNotes)
  PlayerPrefs.SetString(AccountNetCmdHandler:GetUID() .. "_SimCombatNoteRead", readNotes)
end
function UISimCombatNoteItem:ShowGuide(tutorialData, index)
  UIManager.OpenUIByParam(UIDef.UISysGuideWindow, {tutorialData, index})
end
function UISimCombatNoteItem.GetReadLevels()
  local readNote = PlayerPrefs.GetString(AccountNetCmdHandler:GetUID() .. "_SimCombatNoteRead")
  local readNotes = string.split(readNote, ",")
  local readLevels = {}
  local finished = 0
  for i = 1, #readNotes do
    local levelId = tonumber(readNotes[i])
    if levelId ~= nil and 0 < levelId then
      local levelData = TableData.listSimCombatTutorialLevelsDatas:GetDataById(levelId)
      table.insert(readLevels, levelId)
      finished = finished + levelData.tutorials_mark
    end
  end
  return readLevels, finished
end
