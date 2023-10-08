require("UI.UIBasePanel")
require("UI.Lounge.Item.UIDormChrRecordSelectItem")
UIDormChrRecordSelectPanel = class("UIDormChrRecordSelectPanel", UIBasePanel)
UIDormChrRecordSelectPanel.__index = UIDormChrRecordSelectPanel
function UIDormChrRecordSelectPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
  csPanel.Is3DPanel = true
end
function UIDormChrRecordSelectPanel:OnAwake(root, data)
  self:SetRoot(root)
end
function UIDormChrRecordSelectPanel:OnInit(root, data)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:SetBaseData()
  self:AddBtnLister()
end
function UIDormChrRecordSelectPanel:OnShowStart()
  local listCount = self.allDataList.Count
  for i = 0, listCount - 1 do
    local index = 1 + i
    local id = self.allDataList[i]
    if self.rightBtnList[index] == nil then
      self.rightBtnList[index] = UIDormChrRecordSelectItem.New()
      self.rightBtnList[index]:InitCtrl(self.ui.mScrollListChild_Content)
      self.rightBtnList[index]:SetClickFunction(function(item)
        self:RightBtnClickFunction(item)
      end)
    end
    local item = self.rightBtnList[index]
    item:SetData(id, index)
  end
end
function UIDormChrRecordSelectPanel:OnShowFinish()
  LoungeHelper.CameraCtrl.isDebug = false
end
function UIDormChrRecordSelectPanel:OnTop()
end
function UIDormChrRecordSelectPanel:OnBackFrom()
end
function UIDormChrRecordSelectPanel:OnClose()
  self.isShowUI = true
  self:ReleaseCtrlTable(self.rightBtnList, true)
  self.rightBtnList = nil
  self.allDataList = nil
  self.gunData = nil
  self.ui = nil
end
function UIDormChrRecordSelectPanel:OnHide()
end
function UIDormChrRecordSelectPanel:OnHideFinish()
end
function UIDormChrRecordSelectPanel:OnRelease()
end
function UIDormChrRecordSelectPanel:SetBaseData()
  self.rightBtnList = {}
  local gunCmdData = NetCmdLoungeData:GetCurrGunCmdData()
  local gunID = gunCmdData.gunData.character_id
  self.gunData = TableData.listGunCharacterDatas:GetDataById(gunID)
  local gunModelID = self.gunData.unit_id[0]
  self.allDataList = TableData.listCharacterDailyByGunIdDatas:GetDataById(gunModelID).Id
  self.closeTime = 0.01
end
function UIDormChrRecordSelectPanel:AddBtnLister()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    self:OnClickClose()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    self.closeTime = 0
    UIManager.JumpToMainPanel()
    SceneSys:UnloadLoungeScene()
  end
end
function UIDormChrRecordSelectPanel:RightBtnClickFunction(item)
  item:StartPlayBehavior()
end
function UIDormChrRecordSelectPanel:OnClickClose()
  UIManager.CloseUI(UIDef.UIDormChrRecordSelectPanel)
end
function UIDormChrRecordSelectPanel:OnCameraStart()
  return self.closeTime or 0.01
end
function UIDormChrRecordSelectPanel:OnCameraBack()
  return self.closeTime
end
