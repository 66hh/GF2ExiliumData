require("UI.UIBasePanel")
UISimCombatMythicBuffSelDialog = class("UISimCombatMythicBuffSelDialog", UIBasePanel)
UISimCombatMythicBuffSelDialog.__index = UISimCombatMythicBuffSelDialog
local self = UISimCombatMythicBuffSelDialog
function UISimCombatMythicBuffSelDialog:ctor(obj)
  UISimCombatMythicBuffSelDialog.super.ctor(self)
  obj.Type = UIBasePanelType.Dialog
end
function UISimCombatMythicBuffSelDialog:OnInit(root, data)
  self.super.SetRoot(UISimCombatMythicBuffSelDialog, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.curSelBuff = nil
  self.curSelBuffItem = nil
  self.chapterItemRogueMode = data.chapterItemRogueMode
  self.finishedGroupNum = data.finishedGroupNum
  self.selBuffCallback = data.callback
  UIUtils.GetButtonListener(self.ui.mBtn_Select.gameObject).onClick = function()
    NetCmdSimCombatRogueData:GetCS_SimCombatRogueSelectBuff(self.chapterItemRogueMode, self.curSelBuff.Id, function(ret)
      if ret == ErrorCodeSuc then
        self.curSelBuffItem:GetRogueBuff()
        UIManager.CloseUI(UIDef.UISimCombatMythicBuffSelDialog)
      end
    end)
  end
  self:SetBuffList()
  if self.finishedGroupNum == 0 then
    self.ui.mText_Tittle.text = TableData.GetHintById(111027)
  else
    self.ui.mText_Tittle.text = TableData.GetHintById(111026)
  end
end
function UISimCombatMythicBuffSelDialog:OnHide()
  self.isHide = true
end
function UISimCombatMythicBuffSelDialog:OnClose()
  NetCmdSimCombatRogueData.RogueStage:ClearSelectedBuffs()
  if self.selBuffCallback then
    self.selBuffCallback()
  end
end
function UISimCombatMythicBuffSelDialog:SetBuffList()
  setactive(self.ui.mBtn_Select.gameObject, false)
  local curBuffs = NetCmdSimCombatRogueData.RogueStage.SelectedBuffs
  for i = 0, curBuffs.Count - 1 do
    local item = SimCombatMythicBuffSelItem.New()
    item:InitCtrl(self.ui.mScrollListChild_Content)
    item:SetData(curBuffs[i])
    UIUtils.GetButtonListener(item.ui.mBtn_Self.gameObject).onClick = function()
      self:OnClickBuffItem(curBuffs[i], item)
    end
  end
end
function UISimCombatMythicBuffSelDialog:OnClickBuffItem(buff, item)
  setactive(self.ui.mBtn_Select.gameObject, true)
  if self.curSelBuffItem ~= nil then
    self.curSelBuffItem:SetSelect(false)
  end
  item:SetSelect(true)
  self.curSelBuff = buff
  self.curSelBuffItem = item
end
