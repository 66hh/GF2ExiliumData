require("UI.UIBasePanel")
require("UI.ArchivesPanel.Item.Btn_ArchivesCenterChrPlotItemV2")
ArchivesCenterChrPlotPanelV2 = class("ArchivesCenterChrPlotPanelV2", UIBasePanel)
ArchivesCenterChrPlotPanelV2.__index = ArchivesCenterChrPlotPanelV2
function ArchivesCenterChrPlotPanelV2:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Is3DPanel = true
end
function ArchivesCenterChrPlotPanelV2:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.characterUIList = {}
  self.characterDataList = {}
  self.currSelectIndex = -1
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ArchivesCenterChrPlotPanelV2)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Round.gameObject).onClick = function()
    if self.characterDataList[self.currSelectIndex].type == CS.GF2.Data.RoleType.Gun and NetCmdArchivesData:CharacterIsLock(self.characterDataList[self.currSelectIndex].gun_id) then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(110040))
      return
    end
    local state = NetCmdArchivesData:GetSingleCharacterPlotState(self.characterDataList[self.currSelectIndex].id)
    if state == 0 then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(103050))
    else
      if self.onPlayAvgTime and CGameTime:GetTimestamp() - self.onPlayAvgTime <= 2 then
        return
      end
      self.onPlayAvgTime = CGameTime:GetTimestamp()
      if state == 1 then
        CS.AVGController.PlayAvgByPlotId(self.characterDataList[self.currSelectIndex].id, function(action, isSkip)
          NetCmdArchivesData:SetPlotIndex(NetCmdArchivesData:GetNextChartacterPlot(self.data.unit_id[0], self.characterDataList[self.currSelectIndex].id))
          self:UpdateInfo()
          local characterAvgId = self.characterDataList[self.currSelectIndex].id
          self:SendOssReport(characterAvgId, isSkip)
        end, true)
      elseif state == 2 then
        NetCmdArchivesData:SendCharacterReadMsg(self.characterDataList[self.currSelectIndex].id, function(ret)
          if ret == ErrorCodeSuc then
            CS.AVGController.PlayAvgByPlotId(self.characterDataList[self.currSelectIndex].id, function(action, isSkip)
              NetCmdArchivesData:SetPlotIndex(NetCmdArchivesData:GetNextChartacterPlot(self.data.unit_id[0], self.characterDataList[self.currSelectIndex].id))
              UIManager.OpenUI(UIDef.UICommonReceivePanel)
              self:UpdateInfo()
              local characterAvgId = self.characterDataList[self.currSelectIndex].id
              self:SendOssReport(characterAvgId, isSkip)
            end, true)
          end
        end)
      end
    end
  end
end
function ArchivesCenterChrPlotPanelV2:OnInit(root, data)
  self.data = data.currData
  NetCmdArchivesData:SetPlotIndex(NetCmdArchivesData:GetCharacterMaxPlot(self.data.unit_id[0]))
  self:UpdateInfo()
end
function ArchivesCenterChrPlotPanelV2:UpdateInfo()
  self.ui.mText_Name.text = self.data.name.str
  self.ui.mImg_Bg.sprite = IconUtils.GetArchivesIcon("Img_ArchivesCenter_ChrCD_" .. self.data.en_name)
  self.ui.mImg_Round.color = ColorUtils.StringToColor(self.data.color)
  local characterIDList = NetCmdArchivesData:GettCharacterAvgByGroupId(self.data.unit_id[0])
  local currUI, currData
  for i = 0, characterIDList.Count - 1 do
    local cpData = TableDataBase.listCharacterAvgDatas:GetDataById(characterIDList[i])
    local index = i + 1
    if index > #self.characterUIList then
      local item = Btn_ArchivesCenterChrPlotItemV2.New()
      item:InitCtrl(self.ui.mTrans_Content)
      item:UpdateParentSatte(true)
      item:SetData(cpData, index, self)
      table.insert(self.characterUIList, item)
    else
      self.characterUIList[index]:UpdateParentSatte(true)
      self.characterUIList[index]:SetData(cpData, index)
    end
    self.characterDataList[index] = cpData
    if index == NetCmdArchivesData:GetPlotIndex() then
      currUI = self.characterUIList[NetCmdArchivesData:GetPlotIndex()]
      currData = cpData
    end
  end
  if currUI and currData then
    self.currSelectIndex = -1
    currUI:OnClickPlotIndex(currData, NetCmdArchivesData:GetPlotIndex())
  end
  if #self.characterUIList > characterIDList.Count then
    for i = characterIDList.Count + 1, #self.characterUIList do
      self.characterUIList[i]:UpdateParentSatte(false)
    end
  end
end
function ArchivesCenterChrPlotPanelV2:UpdateBtnState()
  for k, v in ipairs(self.characterUIList) do
    v.ui.mBtn_Item.interactable = k ~= self.currSelectIndex
  end
end
function ArchivesCenterChrPlotPanelV2:OnShowStart()
end
function ArchivesCenterChrPlotPanelV2:OnShowFinish()
  self.mCSPanel.ShouldGrabScreenOnShowStart = false
  self.mCSPanel.ShouldGrabScreenOnBackFrom = false
  self.mCSPanel.ShouldResetGrabScreenBlurOnHide = false
end
function ArchivesCenterChrPlotPanelV2:OnBackFrom()
end
function ArchivesCenterChrPlotPanelV2:OnHide()
  self.onPlayAvgTime = nil
end
function ArchivesCenterChrPlotPanelV2:OnClose()
  self.onPlayAvgTime = nil
  self.currSelectIndex = -1
  self.mCSPanel.ShouldGrabScreenOnShowStart = true
  self.mCSPanel.ShouldGrabScreenOnBackFrom = true
  self.mCSPanel.ShouldResetGrabScreenBlurOnHide = true
end
function ArchivesCenterChrPlotPanelV2:OnHideFinish()
end
function ArchivesCenterChrPlotPanelV2:OnRelease()
  self.onPlayAvgTime = nil
end
function ArchivesCenterChrPlotPanelV2:SendOssReport(plotId, isSkip)
  if self.ossGunPlotInfo == nil then
    self.ossGunPlotInfo = CS.OssGunPlotInfo()
  end
  local gunType = self.data.type.value__
  local gunId = 0
  if 0 < self.data.unit_id.Count then
    gunId = self.data.unit_id[0]
  else
    gferror("[Oss] GunId is null!!!")
  end
  local plotType = 1
  self.ossGunPlotInfo:SetInfo(gunType, gunId, plotType, plotId, isSkip)
  MessageSys:SendMessage(OssEvent.GunPlotLog, nil, self.ossGunPlotInfo)
end
