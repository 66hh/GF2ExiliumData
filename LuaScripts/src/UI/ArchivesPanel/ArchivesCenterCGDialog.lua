require("UI.UIBasePanel")
ArchivesCenterCGDialog = class("ArchivesCenterCGDialog", UIBasePanel)
function ArchivesCenterCGDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function ArchivesCenterCGDialog:OnAwake(root, data)
  self.Index = 0
  self.CGList = {}
  self.CGCount = 0
end
function ArchivesCenterCGDialog:OnInit(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:AddBtnListen()
  self.mData = data
  self:InitInfoData()
end
function ArchivesCenterCGDialog:OnShowStart()
end
function ArchivesCenterCGDialog:OnHide()
end
function ArchivesCenterCGDialog:OnUpdate(deltatime)
end
function ArchivesCenterCGDialog:OnClose()
end
function ArchivesCenterCGDialog:OnRelease()
end
function ArchivesCenterCGDialog:InitInfoData()
  self.ui.mImg_CG.sprite = ResSys:GetCGSprte(self.mData.img)
  self.ui.mText_Tittle.text = self.mData.name.str
  local index = 0
  self.CGList = {}
  for i = 0, TableData.listChapterCgCsDatas.Count - 1 do
    local data = TableData.listChapterCgCsDatas:GetDataById(i + 1)
    local avgData = TableData.listAvgDatas:GetDataById(data.stageId)
    if NetCmdArchivesData:MainStoryIsUnLock(avgData.condition) then
      index = index + 1
      if self.mData.Id == data.Id then
        self.Index = index
      end
      table.insert(self.CGList, data)
    end
  end
  self.CGCount = #self.CGList
  setactive(self.ui.mBtn_Left.gameObject, 1 < self.Index)
  setactive(self.ui.mBtn_Right.gameObject, self.Index < self.CGCount)
end
function ArchivesCenterCGDialog:AddBtnListen()
  UIUtils.AddBtnClickListener(self.ui.mBtn_Close, function()
    self:OnClickClose()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BgClose, function()
    self:OnClickClose()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Left, function()
    self:LastPic()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Right, function()
    self:NextPic()
  end)
end
function ArchivesCenterCGDialog:LastPic()
  self.ui.mAnim_Root:SetTrigger("Previous")
  setactive(self.ui.mBtn_Left.gameObject, true)
  setactive(self.ui.mBtn_Right.gameObject, true)
  self.Index = self.Index - 1
  if self.Index <= 0 then
    setactive(self.ui.mBtn_Left.gameObject, false)
  end
  self.ui.mImg_CG.sprite = ResSys:GetCGSprte(self.CGList[self.Index].img)
  self.ui.mText_Tittle.text = self.CGList[self.Index].name.str
  if self.CGList[self.Index + 1] == nil then
    setactive(self.ui.mBtn_Right.gameObject, false)
  end
  if self.CGList[self.Index - 1] == nil then
    setactive(self.ui.mBtn_Left.gameObject, false)
  end
end
function ArchivesCenterCGDialog:NextPic()
  self.ui.mAnim_Root:SetTrigger("Next")
  setactive(self.ui.mBtn_Left.gameObject, true)
  setactive(self.ui.mBtn_Right.gameObject, true)
  self.Index = self.Index + 1
  if self.Index >= self.CGCount then
    setactive(self.ui.mBtn_Right.gameObject, false)
  end
  self.ui.mImg_CG.sprite = ResSys:GetCGSprte(self.CGList[self.Index].img)
  self.ui.mText_Tittle.text = self.CGList[self.Index].name.str
  if self.CGList[self.Index + 1] == nil then
    setactive(self.ui.mBtn_Right.gameObject, false)
  end
  if self.CGList[self.Index - 1] == nil then
    setactive(self.ui.mBtn_Left.gameObject, false)
  end
end
function ArchivesCenterCGDialog:OnClickClose()
  UIManager.CloseUI(UIDef.ArchivesCenterCGDialog)
end
