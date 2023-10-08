require("UI.UIBaseCtrl")
require("UI.BattleIndexPanel.Btn_BattleIndexBranchItem")
UIBattleIndexBranchStorySubPanel = class("UIBattleIndexBranchStorySubPanel", UIBaseView)
UIBattleIndexBranchStorySubPanel.__index = UIBattleIndexBranchStorySubPanel
UIBattleIndexBranchStorySubPanel.leftTabUIList = {}
UIBattleIndexBranchStorySubPanel.rightItemUIList = {}
function UIBattleIndexBranchStorySubPanel:ctor(csPanel)
  UIBattleIndexBranchStorySubPanel.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIBattleIndexBranchStorySubPanel:InitCtrl(root, pageIndex, isLock)
  self.ui = {}
  self:SetRoot(root)
  self:LuaUIBindTable(root, self.ui)
  self.currSelectIndex = -1
  self.isBranchLock = isLock
  self.pageIndex = pageIndex
  self:MaualUI(self.pageIndex)
end
function UIBattleIndexBranchStorySubPanel:MaualUI(pageIndex)
  self.pageIDList = NetCmdThemeData:GetPageList(pageIndex, true)
  local stageData = TableData.listStageIndexDatas:GetDataById(pageIndex)
  if stageData then
    self.chapterData = TableDataBase.listChapterDatas:GetDataById(stageData.detail_id[0])
    NetCmdThemeData:UpdateLevelInfo(self.chapterData.stage_group)
  end
  local tabPrefab = self.ui.mTrans_LeftContent:GetComponent(typeof(CS.ScrollListChild))
  for i = 0, self.pageIDList.Count - 1 do
    do
      local index = i + 1
      if self.leftTabUIList[index] == nil then
        self.leftTabUIList[index] = {}
        local instObj = instantiate(tabPrefab.childItem)
        self:LuaUIBindTable(instObj, self.leftTabUIList[index])
        UIUtils.AddListItem(instObj.gameObject, self.ui.mTrans_LeftContent.gameObject)
        if self.pageIDList[i] > 0 then
          local data = TableDataBase.listChapterDatas:GetDataById(self.pageIDList[i])
          self.leftTabUIList[index].mText_Name.text = data.tab_name
          self.leftTabUIList[index].mBtn_Self.enabled = true
          setactive(self.leftTabUIList[index].mTrans_RedPoint.gameObject, 0 > NetCmdThemeData:GetThemeFinishRed())
        else
          self.leftTabUIList[index].mText_Name.text = "接入中..."
          self.leftTabUIList[index].mBtn_Self.enabled = false
          setactive(self.leftTabUIList[index].mTrans_RedPoint.gameObject, false)
        end
        UIUtils.GetButtonListener(self.leftTabUIList[index].mBtn_Self.gameObject).onClick = function()
          self:OnClickTab(i)
        end
      end
    end
  end
  self:OnClickTab(0)
end
function UIBattleIndexBranchStorySubPanel:OnClickTab(index)
  if 0 < index then
    CS.PopupMessageManager.PopupString(TableData.GetHintById(270016))
    return
  end
  if self.currSelectIndex == index then
    return
  end
  self.currSelectIndex = index
  self.leftTabUIList[index + 1].mBtn_Self.interactable = false
  local chapterData = TableDataBase.listChapterDatas:GetDataById(self.pageIDList[index])
  self.chapterIDList = NetCmdThemeData:GetChapterIDList(chapterData.tab)
  local Prefab = self.ui.mTrans_Content:GetComponent(typeof(CS.ScrollListChild))
  self:RefreshRed(chapterData)
  for i = 1, 4 do
    if self.rightItemUIList[i] == nil then
      self.rightItemUIList[i] = {}
      local instObj = instantiate(Prefab.childItem)
      self:LuaUIBindTable(instObj, self.rightItemUIList[i])
      UIUtils.AddListItem(instObj.gameObject, self.ui.mTrans_Content.gameObject)
    end
    self.rightItemUIList[i].mText_Text.text = "0" .. i
    if i <= self.chapterIDList.Count then
      local data = TableDataBase.listChapterDatas:GetDataById(self.chapterIDList[i - 1])
      if data then
        self.rightItemUIList[i].mText_TitleName.text = data.name.str
        setactive(self.rightItemUIList[i].mTrans_NotAccess.gameObject, false)
        setactive(self.rightItemUIList[i].mTrans_Title.gameObject, true)
        setactive(self.rightItemUIList[i].mTrans_GrpLocked.gameObject, self.isBranchLock or self:IsLock(data.unlock))
        if self.isBranchLock then
          self.rightItemUIList[i].mText_Process.text = ""
          setactive(self.rightItemUIList[i].mTrans_RedPoint.gameObject, false)
        elseif 0 < data.chapter_reward_value.Count then
          local stars = NetCmdDungeonData:GetCurStarsByChapterID(data.id)
          local totalCount = data.chapter_reward_value[data.chapter_reward_value.Count - 1]
          local levelPassStage = NetCmdThemeData:GetLevelPassStage(chapterData.id)
          if stars == 0 or totalCount == 0 then
            self.rightItemUIList[i].mText_Process.text = "0%"
            setactive(self.rightItemUIList[i].mTrans_RedPoint.gameObject, 0 > NetCmdThemeData:GetThemeFinishRed())
          else
            if levelPassStage == 1 then
              self.rightItemUIList[i].mText_Process.text = "<color=#f26c1c>完成度" .. math.ceil(stars / totalCount * 100) .. "%</color>"
            else
              self.rightItemUIList[i].mText_Process.text = "完成度" .. math.ceil(stars / totalCount * 100) .. "%"
            end
            setactive(self.rightItemUIList[i].mTrans_RedPoint.gameObject, 0 < NetCmdDungeonData:UpdateChatperRewardRedPoint(chapterData.id) or 0 > NetCmdThemeData:GetThemeFinishRed())
          end
        else
          local chapterInfo = TableData.GetStorysByChapterID(chapterData.id)
          local compCount = NetCmdDungeonData:GetChapterCompteCount(chapterData.id)
          if chapterInfo then
            self.rightItemUIList[i].mText_Process.text = math.ceil(compCount / chapterInfo.Count * 100) .. "%"
          else
            self.rightItemUIList[i].mText_Process.text = "0%"
          end
          setactive(self.rightItemUIList[i].mTrans_RedPoint.gameObject, false)
        end
        setactive(self.rightItemUIList[i].mImg_Pic.gameObject, true)
      end
      if self.chapterData then
        setactive(self.rightItemUIList[i].mTrans_Icon.gameObject, not self.isBranchLock and NetCmdThemeData:ChapterPassInThemeOpen(self.chapterData.plan_id, self.chapterData.id))
      else
        setactive(self.rightItemUIList[i].mTrans_Icon.gameObject, false)
      end
    else
      setactive(self.rightItemUIList[i].mImg_Pic.gameObject, false)
      setactive(self.rightItemUIList[i].mTrans_GrpLocked.gameObject, false)
      setactive(self.rightItemUIList[i].mTrans_NotAccess.gameObject, true)
      setactive(self.rightItemUIList[i].mTrans_Title.gameObject, false)
      setactive(self.rightItemUIList[i].mTrans_Icon.gameObject, false)
      setactive(self.rightItemUIList[i].mTrans_RedPoint.gameObject, false)
    end
    UIUtils.GetButtonListener(self.rightItemUIList[i].mBtn_BattleIndexBranchItem.gameObject).onClick = function()
      if self.chapterIDList.Count >= i then
        if self.isBranchLock then
          CS.PopupMessageManager.PopupString(TableData.GetHintById(103050))
          return
        end
        NetCmdThemeData:SetThemeFinishRed(1)
        self:RefreshRed(chapterData)
        self:OnClickChapter(self.chapterIDList[i - 1])
      else
        CS.PopupMessageManager.PopupString("暂未接入战役")
      end
    end
  end
end
function UIBattleIndexBranchStorySubPanel:RefreshRed(chapterData)
  for _, obj in pairs(self.leftTabUIList) do
    if self.pageIDList[_ - 1] > 0 then
      setactive(obj.mTrans_RedPoint.gameObject, NetCmdThemeData:ThemeBattleRed())
    end
  end
end
function UIBattleIndexBranchStorySubPanel:OnClickChapter(chapterId)
  local chapterData = TableData.listChapterDatas:GetDataById(chapterId)
  UIManager.OpenUIByParam(UIDef.DaiyanChapterPanel, {chapterData = chapterData})
end
function UIBattleIndexBranchStorySubPanel:IsLock(list)
  if list.Count == 0 then
    return false
  end
  for i = 0, list.Count do
    if AccountNetCmdHandler:CheckSystemIsUnLock(list[i]) then
      return false
    end
  end
  return true
end
function UIBattleIndexBranchStorySubPanel:OnBackFrom()
  if self.pageIndex == nil then
    self.isBranchLock = true
    self.pageIndex = 5
    local indexData = TableData.listStageIndexDatas:GetDataById(5)
    if indexData and indexData.detail_id.Count > 0 then
      for i = 0, indexData.detail_id.Count - 1 do
        local chapterData = TableData.listChapterDatas:GetDataById(indexData.detail_id[i])
        if chapterData then
          local planActivity = TableData.listPlanDatas:GetDataById(chapterData.plan_id)
          if planActivity and CGameTime:GetTimestamp() >= planActivity.open_time and CGameTime:GetTimestamp() < planActivity.close_time then
            self.isBranchLock = false
            break
          end
        end
      end
    end
  end
  self:MaualUI(self.pageIndex)
end
function UIBattleIndexBranchStorySubPanel:OnRelease()
  for _, obj in pairs(UIBattleIndexBranchStorySubPanel.leftTabUIList) do
    gfdestroy(obj.mTrans_Parent)
  end
  UIBattleIndexBranchStorySubPanel.leftTabUIList = {}
  for _, obj in pairs(UIBattleIndexBranchStorySubPanel.rightItemUIList) do
    gfdestroy(obj.mTrans_Parent)
  end
  self.currSelectIndex = -1
  UIBattleIndexBranchStorySubPanel.rightItemUIList = {}
end
function UIBattleIndexBranchStorySubPanel:OnClose()
end
