require("UI.UIBaseCtrl")
UIBattleIndexTabHardItem = class("UIBattleIndexTabHardItem", UIBaseCtrl)
UIBattleIndexTabHardItem.__index = UIBattleIndexTabHardItem
UIBattleIndexTabHardItem.mText_BattleIndexTabHardItem = nil
UIBattleIndexTabHardItem.mText_1 = nil
UIBattleIndexTabHardItem.mText_2 = nil
UIBattleIndexTabHardItem.mText_Title = nil
UIBattleIndexTabHardItem.mTrans_RedPoint = nil
function UIBattleIndexTabHardItem:__InitCtrl()
end
function UIBattleIndexTabHardItem:InitCtrl(parent)
  local instObj = instantiate(UIUtils.GetGizmosPrefab("BattleIndex/Btn_BattleIndexTabHardItem.prefab", self))
  CS.LuaUIUtils.SetParent(instObj.gameObject, parent.gameObject)
  self:SetRoot(instObj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self:__InitCtrl()
end
function UIBattleIndexTabHardItem:SetData(data)
  if data ~= nil then
    setactive(self.mUIRoot, true)
    self.mData = data
    self.isUnLock = true
    for i = 0, data.unlock.Count - 1 do
      if not NetCmdAchieveData:CheckComplete(data.unlock[i]) then
        self.isUnLock = false
      end
    end
    self.levelUnlocked = AccountNetCmdHandler:GetLevel() >= data.level
    self.isNew = not AccountNetCmdHandler:IsWatchedChapter(data.id)
    self.isNext = self.isUnLock and 0 < NetCmdDungeonData:UpdateChapterRedPoint(data.id)
    self:UpdateChapterItem()
  else
    setactive(self.mUIRoot, false)
  end
end
function UIBattleIndexTabHardItem:UpdateChapterItem()
  local chapterNum = self.mData.id > 100 and self.mData.id % 100 or self.mData.id
  self.ui.mText_1.text = string.format("-", chapterNum)
  self.ui.mText_2.text = string.format("-", chapterNum)
  self.ui.mText_Text.text = self.mData.name.str
  setactive(self.ui.mTrans_Locked, not self.isUnLock or not self.levelUnlocked)
  setactive(self.ui.mTrans_NowProgress, self.isNext)
  setactive(self.ui.mTrans_RedPoint, self.isUnLock and self.levelUnlocked and NetCmdDungeonData:UpdateChatperRewardRedPoint(self.mData.id) > 0)
end
