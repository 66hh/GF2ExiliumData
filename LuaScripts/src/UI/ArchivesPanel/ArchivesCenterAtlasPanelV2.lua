ArchivesCenterAtlasPanelV2 = class("ArchivesCenterAtlasPanelV2", UIBasePanel)
ArchivesCenterAtlasPanelV2.__index = ArchivesCenterAtlasPanelV2
function ArchivesCenterAtlasPanelV2:ctor(csPanel)
  self.super.ctor(self, csPanel)
end
function ArchivesCenterAtlasPanelV2:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:InitBtnUI()
  self:OnBtnClick()
end
function ArchivesCenterAtlasPanelV2:InitBtnUI()
  self.BtnUIList = {}
  table.insert(self.BtnUIList, self:GetComponent(self.ui.mBtn_Story, 1))
  table.insert(self.BtnUIList, self:GetComponent(self.ui.mBtn_Hard, 2))
  table.insert(self.BtnUIList, self:GetComponent(self.ui.mBtn_Plot, 3))
end
function ArchivesCenterAtlasPanelV2:GetComponent(root, index)
  local cell = {}
  cell.btn = root.gameObject
  cell.name = root.transform:Find("Root/TextName"):GetComponent(typeof(CS.UnityEngine.UI.Text))
  cell.red = root.transform:Find("Root/TextName/Trans_RedPoint").gameObject
  cell.animat = root.gameObject:GetComponent(typeof(CS.UnityEngine.Animator))
  cell.data = TableDataBase.listStoryRoomDatas:GetDataById(index)
  cell.name.text = cell.data.name.str
  UIUtils.GetButtonListener(cell.btn).onClick = function()
    self:OnBtnClickIndex(cell.data)
  end
  return cell
end
function ArchivesCenterAtlasPanelV2:OnBtnClickIndex(data)
  if not AccountNetCmdHandler:CheckSystemIsUnLock(data.unlock) then
    local unlockData = TableDataBase.listUnlockDatas:GetDataById(data.unlock)
    if unlockData then
      local str = UIUtils.CheckUnlockPopupStr(unlockData)
      PopupMessageManager.PopupString(str)
      return
    end
  end
  if data.sort == 1 then
    UIManager.OpenUIByParam(UIDef.ArchivesCenterRecordEnterPanelV2, 1)
  elseif data.sort == 2 then
    UIManager.OpenUIByParam(UIDef.ArchivesCenterRecordEnterPanelV2, 2)
  elseif data.sort == 3 then
    UIManager.OpenUI(UIDef.ArchivesCenterPanelV2)
  end
end
function ArchivesCenterAtlasPanelV2:OnInit()
end
function ArchivesCenterAtlasPanelV2:OnShowFinish()
  self:RefreshInfo()
end
function ArchivesCenterAtlasPanelV2:RefreshInfo()
  for k, v in ipairs(self.BtnUIList) do
    if v.data.sort == 1 then
      setactive(v.red, NetCmdArchivesData:PlotBranchIsHaveRed())
    end
    v.animat:SetBool("Bool", not AccountNetCmdHandler:CheckSystemIsUnLock(v.data.unlock))
  end
end
function ArchivesCenterAtlasPanelV2:OnBtnClick()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ArchivesCenterAtlasPanelV2)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
end
function ArchivesCenterAtlasPanelV2:OnBackFrom()
  self:RefreshInfo()
end
function ArchivesCenterAtlasPanelV2:OnClose()
end
