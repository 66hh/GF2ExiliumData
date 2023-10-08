require("UI.UIBaseCtrl")
UIDarkZoneQuestInfoPanelItem = class("UIDarkZoneQuestInfoPanelItem", UIBaseCtrl)
UIDarkZoneQuestInfoPanelItem.__index = UIDarkZoneQuestInfoPanelItem
function UIDarkZoneQuestInfoPanelItem:ctor()
end
function UIDarkZoneQuestInfoPanelItem:__InitCtrl()
end
function UIDarkZoneQuestInfoPanelItem:InitCtrl(parent, parentPanel)
  local obj = instantiate(UIUtils.GetGizmosPrefab("Darkzone/Btn_DarkzoneQuestItemV3.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, false)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self.isFinish = false
  self.isLock = false
  self.lockType = 0
  self.parentObj = parentPanel
  setactive(self.ui.mTrans_Finish.gameObject, false)
  setactive(self.ui.mTrans_Lock.gameObject, false)
end
function UIDarkZoneQuestInfoPanelItem:SetData(data, questGroupID, questSeriesID)
  self.ui.mText_QuestName.text = data.quest_name.str
  local questType = TableData.listDarkzoneSeriesQuestTypeDatas:GetDataById(data.quest_type)
  self.ui.mImg_QuestBg.sprite = ResSys:GetAtlasSprite("DarkzoneQuest/" .. data.quest_pic)
  local id = data.quest_rewardshow
  local itemData = TableData.GetItemData(id)
  self.ui.mImg_ItemIcon.sprite = IconUtils.GetItemIconSprite(id)
  self.ui.mImg_QualityBg.color = TableData.GetGlobalGun_Quality_Color2(itemData.rank)
  UIUtils.GetButtonListener(self.ui.mBtn_Root.gameObject).onClick = function()
    if self.isFinish == false and self.isLock == false then
      local t = {}
      t[0] = 1
      t[1] = data.id
      UIManager.OpenUIByParam(UIDef.UIDarkZoneQuestPanel, t)
    elseif self.isLock == true then
      if 0 >= self.lockType then
        PopupMessageManager.PopupString(TableData.GetHintById(903418))
      else
        PopupMessageManager.PopupString(string_format(TableData.GetHintById(903472), self.lockType))
      end
    else
      PopupMessageManager.PopupString(TableData.GetHintById(903463))
    end
  end
end
function UIDarkZoneQuestInfoPanelItem:OnFinish()
  self.isFinish = true
  setactive(self.ui.mTrans_Finish.gameObject, true)
end
function UIDarkZoneQuestInfoPanelItem:SetLock(lockType)
  self.isLock = true
  self.lockType = lockType
  setactive(self.ui.mTrans_Lock.gameObject, true)
end
