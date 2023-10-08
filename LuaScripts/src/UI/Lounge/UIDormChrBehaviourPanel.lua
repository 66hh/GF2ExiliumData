require("UI.UIBasePanel")
require("UI.Lounge.Item.UIDormChrPlayBehaviourItem")
UIDormChrBehaviourPanel = class("UIDormChrBehaviourPanel", UIBasePanel)
UIDormChrBehaviourPanel.__index = UIDormChrBehaviourPanel
function UIDormChrBehaviourPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
  csPanel.Is3DPanel = true
end
function UIDormChrBehaviourPanel:OnAwake(root, data)
  self:SetRoot(root)
end
function UIDormChrBehaviourPanel:OnInit(root, data)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:SetBaseData()
  self:AddBtnLister()
end
function UIDormChrBehaviourPanel:OnShowStart()
  local listCount = #self.allDataList
  local currRandomPlip = LoungeHelper.AnimCtrl:GetCurPlayAnimStr()
  for i = 1, listCount do
    local index = i
    local id = self.allDataList[i]
    if self.rightBtnList[index] == nil then
      self.rightBtnList[index] = UIDormChrPlayBehaviourItem.New()
      self.rightBtnList[index]:InitCtrl(self.ui.mScrollListChild_Content)
      self.rightBtnList[index]:SetClickFunction(function(item)
        self:RightBtnClickFunction(item)
      end)
    end
    local item = self.rightBtnList[index]
    item:SetData(id, self.gunData.unit_id[0])
    local behaviourData = TableData.listDormFormationDatas:GetDataById(id)
    if currRandomPlip == behaviourData.clip then
      self.curSelectBtn = item
      self.curSelectBtn.canChange = true
      self.curSelectBtn:SetSelectState(true)
    end
  end
end
function UIDormChrBehaviourPanel:OnShowFinish()
  LoungeHelper.CameraCtrl.isDebug = false
end
function UIDormChrBehaviourPanel:OnTop()
end
function UIDormChrBehaviourPanel:OnBackFrom()
end
function UIDormChrBehaviourPanel:OnClose()
  self.isShowUI = true
  if self.curSelectBtn ~= nil then
    self.curSelectBtn:SetSelectState(false)
  end
  self.curSelectBtn = nil
  self:ReleaseCtrlTable(self.rightBtnList, true)
  self.rightBtnList = nil
  self.allDataList = nil
  self.gunData = nil
  self.ui = nil
  self.isChangeAction = nil
end
function UIDormChrBehaviourPanel:OnHide()
end
function UIDormChrBehaviourPanel:OnHideFinish()
end
function UIDormChrBehaviourPanel:OnRelease()
end
function UIDormChrBehaviourPanel:SetBaseData()
  self.rightBtnList = {}
  local gunCmdData = NetCmdLoungeData:GetCurrGunCmdData()
  local gunID = gunCmdData.gunData.character_id
  self.gunData = TableData.listGunCharacterDatas:GetDataById(gunID)
  local gunModelID = 0
  local idList = {}
  local ids = TableData.listDormFormationByModleIdDatas:GetDataById(gunModelID)
  if ids ~= nil then
    local d = ids.Id
    local count = d.Count
    for i = 0, count - 1 do
      table.insert(idList, d[i])
    end
  end
  gunModelID = self.gunData.unit_id[0]
  ids = TableData.listDormFormationByModleIdDatas:GetDataById(gunModelID, true)
  if ids ~= nil then
    local d = ids.Id
    local count = d.Count
    for i = 0, count - 1 do
      table.insert(idList, d[i])
    end
  end
  table.sort(idList, function(a, b)
    local aIsUnlock = self:CheckIsUnlock(a)
    local bIsUnlock = self:CheckIsUnlock(b)
    if aIsUnlock == false and bIsUnlock == true then
      return false
    elseif aIsUnlock == true and bIsUnlock == false then
      return true
    else
      return a < b
    end
  end)
  self.allDataList = idList
  self.closeTime = 0.01
end
function UIDormChrBehaviourPanel:CheckIsUnlock(id)
  local isUnlock = true
  local behaviourData = TableData.listDormFormationDatas:GetDataById(id)
  if behaviourData.unlock == 1 and behaviourData.unlock_type > 0 then
    isUnlock = NetCmdAchieveData:CheckComplete(behaviourData.unlock_type)
  elseif behaviourData.unlock == 2 then
    isUnlock = NetCmdLoungeData:CheckFormationHasUnlock(behaviourData.id)
  end
  return isUnlock
end
function UIDormChrBehaviourPanel:AddBtnLister()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    self:OnClickClose()
  end
  setactivewithcheck(self.ui.mBtn_Visual, false)
  UIUtils.GetButtonListener(self.ui.mBtn_Visual.gameObject).onClick = function()
    self:OnClickVisual()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    self.closeTime = 0
    UIManager.JumpToMainPanel()
    SceneSys:UnloadLoungeScene()
  end
end
function UIDormChrBehaviourPanel:RightBtnClickFunction(item)
  if self.isChangeAction == true then
    return
  end
  if self.curSelectBtn ~= nil then
    if self.curSelectBtn.canChange == false then
      return
    end
    self.curSelectBtn:SetSelectState(false)
  end
  self.isChangeAction = true
  UISystem.UISystemBlackCanvas:PlayFadeOutEnhanceBlack(0.4, function()
    TimerSys:DelayCall(0.4, function()
      if item.behaviourData.IsBack then
        LoungeHelper.CameraCtrl.CameraPreObj:ExitLookAt()
      end
      LoungeHelper.AnimCtrl:PlayAnim(item.behaviourData.id)
      item:StartPlayBehavior()
      self.curSelectBtn = item
      self.curSelectBtn:SetSelectState(true)
      UISystem.UISystemBlackCanvas:PlayFadeInEnhanceBlack(0.4, function()
        self.isChangeAction = false
      end)
    end)
  end)
end
function UIDormChrBehaviourPanel:OnClickClose()
  UIManager.CloseUI(UIDef.UIDormChrBehaviourPanel)
end
function UIDormChrBehaviourPanel:OnClickVisual()
  UIManager.OpenUI(UIDef.UIDormVisualHPanel)
end
function UIDormChrBehaviourPanel:OnCameraStart()
  return self.closeTime or 0.01
end
function UIDormChrBehaviourPanel:OnCameraBack()
  return self.closeTime
end
