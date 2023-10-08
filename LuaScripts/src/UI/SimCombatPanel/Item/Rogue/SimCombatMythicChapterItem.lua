require("UI.UIBaseCtrl")
SimCombatMythicChapterItem = class("SimCombatMythicChapterItem", UIBaseCtrl)
local self = SimCombatMythicChapterItem
function SimCombatMythicChapterItem:ctor()
  self.chapterItemState = UISimCombatRogueGlobal.ItemState.Normal
  self.chapterItemMode = UISimCombatRogueGlobal.ItemMode.Normal
  self.chapterItemRogueMode = UISimCombatRogueGlobal.RogueMode.Normal
  self.simRogueStage = nil
  self.chapterItemData = nil
  self.ItemIndex = 0
  self.progressNum = 0
  self.curAllGroupNum = 0
  self.maxProgressNum = 0
  self.maxPhase = 0
  self.progressNumText = 0
  self.isThisItemRendered = false
end
function SimCombatMythicChapterItem:InitCtrl(parent)
  local itemPrefab = parent.gameObject:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  UIUtils.GetButtonListener(self.ui.mBtn_ChapterInfo_L.gameObject).onClick = function()
    self:OnClickItem()
  end
end
function SimCombatMythicChapterItem:SetData(data)
  self.chapterItemData = data
  self.ItemIndex = data.Id
  local curTier = NetCmdSimCombatRogueData.RogueStage.Tier
  local normalMaxTier = NetCmdSimCombatRogueData.NormalMaxTier
  local normalMaxPhase = NetCmdSimCombatRogueData.NormalMaxPhase
  local curRogueType = NetCmdSimCombatRogueData.RogueStage.RogueType
  local normalGroupNum = NetCmdSimCombatRogueData:GetRogueLevelGroupNum(UISimCombatRogueGlobal.RogueMode.Normal, data.Id)
  local challengeGroupNum = NetCmdSimCombatRogueData:GetRogueLevelGroupNum(UISimCombatRogueGlobal.RogueMode.Challenge, data.Id)
  if curTier > data.Id then
    self.chapterItemState = UISimCombatRogueGlobal.ItemState.Finish
  end
  local setChallengeMode = function()
    if NetCmdSimCombatRogueData.NormalMaxPhase > data.Id then
      self.chapterItemState = UISimCombatRogueGlobal.ItemState.Finish
    else
      self.chapterItemState = UISimCombatRogueGlobal.ItemState.Normal
    end
    self.chapterItemMode = UISimCombatRogueGlobal.ItemMode.Normal
    self.chapterItemRogueMode = UISimCombatRogueGlobal.RogueMode.Challenge
    self.progressNumText = "0%"
    if NetCmdSimCombatRogueData.ChallengeMaxPhase ~= nil and NetCmdSimCombatRogueData.ChallengeMaxPhase.Length >= data.Id then
      self.maxPhase = math.ceil(NetCmdSimCombatRogueData.ChallengeMaxPhase[data.Id - 1] / challengeGroupNum * 100)
      self.maxProgressNum = NetCmdSimCombatRogueData.ChallengeMaxPhase[data.Id - 1]
      if challengeGroupNum == self.maxProgressNum then
        self.chapterItemState = UISimCombatRogueGlobal.ItemState.Finish
      end
    else
      self.maxPhase = nil
      self.maxProgressNum = nil
    end
  end
  if curTier < data.Id then
    if normalMaxTier < data.Id then
      self.chapterItemState = UISimCombatRogueGlobal.ItemState.Lock
      self.chapterItemRogueMode = UISimCombatRogueGlobal.RogueMode.Normal
      self.chapterItemMode = UISimCombatRogueGlobal.ItemMode.Normal
      self.progressNum = 0
      self.curAllGroupNum = 1
      self.maxPhase = nil
      self.maxProgressNum = nil
      self.progressNumText = "0%"
      local isNewTier = false
      isNewTier = NetCmdSimCombatRogueData.NormalMaxPhase == NetCmdSimCombatRogueData:GetRogueLevelGroupNum(UISimCombatRogueGlobal.RogueMode.Normal, normalMaxTier)
      if data.Id == normalMaxTier + 1 and isNewTier then
        self.chapterItemState = UISimCombatRogueGlobal.ItemState.Normal
      end
      local tmpAllGroupNum = NetCmdSimCombatRogueData:GetRogueLevelGroupNum(UISimCombatRogueGlobal.RogueMode.Normal, normalMaxTier)
      local tmpAllGroupNum2 = NetCmdSimCombatRogueData:GetRogueLevelGroupNum(UISimCombatRogueGlobal.RogueMode.Challenge, normalMaxTier)
      self.chapterItemRogueMode = UISimCombatRogueGlobal.RogueMode.Normal
      self.maxPhase = math.ceil(normalMaxPhase / tmpAllGroupNum * 100)
      self.maxProgressNum = normalMaxPhase
    else
      setChallengeMode()
    end
  else
    if data.Id == curTier then
      self.chapterItemMode = UISimCombatRogueGlobal.ItemMode.Normal
      self.progressNum = NetCmdSimCombatRogueData.RogueStage.FinishedGroupNum
      if curRogueType == UISimCombatRogueGlobal.RogueMode.Normal then
        self.curAllGroupNum = normalGroupNum
      else
        self.curAllGroupNum = challengeGroupNum
      end
      self.maxPhase = math.ceil(NetCmdSimCombatRogueData.NormalMaxPhase / normalGroupNum * 100)
      self.maxProgressNum = NetCmdSimCombatRogueData.NormalMaxPhase
      if not NetCmdSimCombatRogueData.RogueStage.IsFinished then
        if curRogueType == UISimCombatRogueGlobal.RogueMode.Challenge then
          local tmpProgressNum = self.progressNum
          if tmpProgressNum == 0 then
            tmpProgressNum = 1
          end
          local rogueChapterCofig = NetCmdSimCombatRogueData:GetRogueChapterCofig(UISimCombatRogueGlobal.RogueMode.Challenge, curTier, tmpProgressNum)
          if rogueChapterCofig.ExStagePlan ~= nil and NetCmdSimCombatRogueData.ExNum ~= 0 then
            self.chapterItemMode = UISimCombatRogueGlobal.ItemMode.Ex
          else
            self.chapterItemMode = UISimCombatRogueGlobal.ItemMode.Normal
          end
          if self.progressNum + 1 == challengeGroupNum then
            self.chapterItemMode = UISimCombatRogueGlobal.ItemMode.GrpBoss
          end
        elseif self.progressNum + 1 == normalGroupNum then
          self.chapterItemMode = UISimCombatRogueGlobal.ItemMode.GrpBoss
        end
      else
        if curRogueType == UISimCombatRogueGlobal.RogueMode.Challenge then
          self.chapterItemState = UISimCombatRogueGlobal.ItemState.Finish
        else
          self.chapterItemState = UISimCombatRogueGlobal.ItemState.Finish
        end
        self.chapterItemMode = UISimCombatRogueGlobal.ItemMode.Normal
        self.progressNum = 0
      end
      self.chapterItemRogueMode = curRogueType
      local tmpProgress = math.ceil(self.progressNum / self.curAllGroupNum * 100)
      self.progressNumText = tmpProgress .. "%"
    else
    end
  end
  self:SetMode(self.chapterItemState, self.chapterItemMode, self.chapterItemData.Id)
end
function SimCombatMythicChapterItem:SetSelected(boolean)
  self.ui.mAnimator_SimCombatMythicChapterItem:SetInteger("Switch", boolean and 1 or 2)
end
function SimCombatMythicChapterItem:SetTextColor(isNormal)
  self.ui.mAnimator_SimCombatMythicChapterItem:SetInteger("ModeSwitch", isNormal and 0 or 1)
end
function SimCombatMythicChapterItem:OnClickItem()
  if self.chapterItemState == UISimCombatRogueGlobal.ItemState.Finish then
    UIUtils.PopupHintMessage(103024)
  else
    UIManager.OpenUIByParam(UIDef.UISimCombatMythicItemDetailPanel, self.chapterItemData.Id)
  end
end
function SimCombatMythicChapterItem:SetSelect(boolean)
  setactive(self.ui.mTrans_Tittle.gameObject, not boolean)
  setactive(self.ui.mTrans_Arrow.gameObject, boolean)
  self.ui.mBtn_ChapterInfo_L.interactable = not boolean
end
function SimCombatMythicChapterItem:SetMode(itemState, itemMode, picId)
  self.ui.mText_Tittle_S.text = self.chapterItemData.Name
  self.ui.mText_Tittle_L.text = self.chapterItemData.Name
  self.ui.mText_Num_S.text = self.chapterItemData.Chapter
  self.ui.mText_Num_L.text = self.chapterItemData.Chapter
  self.ui.mText_ProgressNum_L.text = self.progressNumText
  self.ui.mText_ProgressNum_S.text = self.progressNumText
  self.chapterItemState = itemState
  self.chapterItemMode = itemMode
  setactive(self.ui.mTrans_During_S, itemState == UISimCombatRogueGlobal.ItemState.During)
  setactive(self.ui.mTrans_Lock_S, itemState == UISimCombatRogueGlobal.ItemState.Lock)
  setactive(self.ui.mTrans_Boss_S, itemMode == UISimCombatRogueGlobal.ItemMode.GrpBoss)
  setactive(self.ui.mTrans_Ex_S, itemMode == UISimCombatRogueGlobal.ItemMode.Ex)
  setactive(self.ui.mTrans_Progress_S, self.ItemIndex == NetCmdSimCombatRogueData.RogueStage.Tier and itemState == UISimCombatRogueGlobal.ItemState.During)
  setactive(self.ui.mTrans_Finished_S, itemState == UISimCombatRogueGlobal.ItemState.Finish)
  setactive(self.ui.mTrans_During_L, itemState == UISimCombatRogueGlobal.ItemState.During)
  setactive(self.ui.mTrans_Lock_L, itemState == UISimCombatRogueGlobal.ItemState.Lock)
  setactive(self.ui.mTrans_Boss_L, itemMode == UISimCombatRogueGlobal.ItemMode.GrpBoss)
  setactive(self.ui.mTrans_Ex_L, itemMode == UISimCombatRogueGlobal.ItemMode.Ex)
  setactive(self.ui.mTrans_Progress_L, self.ItemIndex == NetCmdSimCombatRogueData.RogueStage.Tier and itemState == UISimCombatRogueGlobal.ItemState.During)
  setactive(self.ui.mTrans_Finished_L, itemState == UISimCombatRogueGlobal.ItemState.Finish)
  self.ui.mImg_Chapter_L.sprite = UISimCombatRogueGlobal.GetRogueIcon(UISimCombatRogueGlobal.IconType.Battle, picId .. "_L")
  self.ui.mImg_Chapter_S.sprite = UISimCombatRogueGlobal.GetRogueIcon(UISimCombatRogueGlobal.IconType.Battle, picId .. "_S")
  self.ui.mImg_LockBg_L.sprite = UISimCombatRogueGlobal.GetRogueIcon(UISimCombatRogueGlobal.IconType.Battle, picId .. "_L")
  self.ui.mImg_LockBg_S.sprite = UISimCombatRogueGlobal.GetRogueIcon(UISimCombatRogueGlobal.IconType.Battle, picId .. "_S")
end
function SimCombatMythicChapterItem:SetSelfShow(boolean)
  self.ui.mCanvasGroup_SelfItem.alpha = boolean and 1 or 0
end
function SimCombatMythicChapterItem:OnRelease()
  self:DestroySelf()
end
