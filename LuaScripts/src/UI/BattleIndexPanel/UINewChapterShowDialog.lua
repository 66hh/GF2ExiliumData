require("UI.UIBasePanel")
UINewChapterShowDialog = class("UINewChapterShowDialog", UIBasePanel)
UINewChapterShowDialog.__index = UINewChapterShowDialog
function UINewChapterShowDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
  self.mCSPanel = csPanel
end
function UINewChapterShowDialog:OnInit(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.chapterID = data.NewChapterID
  self.chapterData = TableData.listChapterDatas:GetDataById(self.chapterID)
  self:InitShow()
end
function UINewChapterShowDialog:InitShow()
  gfdebug("UINewChapterShowDialog 调用了吗")
  self.ui.mText_Tittle.text = string.format(string_format(TableData.GetHintById(611), "-"), self.chapterData.Id)
  self.ui.mText_InfoB.text = self.chapterData.name.str
  self.ui.mText_InfoR.text = self.chapterData.name.str
  self.ui.mText_Info.text = self.chapterData.name.str
  self.ui.mText_Line.text = string.format(string_format(TableData.GetHintById(614), "-"), self.chapterID)
  TimerSys:DelayCall(4, function()
    NetCmdDungeonData.HasNewChapterUnlocked = false
    UIManager.CloseUI(UIDef.UINewChapterShowDialog)
    MessageSys:SendMessage(UIEvent.UINewChapterShowFinish, nil)
  end)
end
function UINewChapterShowDialog:OnHide()
end
function UINewChapterShowDialog:OnClose()
end
