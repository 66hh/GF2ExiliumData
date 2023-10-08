require("UI.UIBasePanel")
ArchivesCenterDarkzoneDialogV2 = class("ArchivesCenterDarkzoneDialogV2", UIBasePanel)
ArchivesCenterDarkzoneDialogV2.__index = ArchivesCenterDarkzoneDialogV2
function ArchivesCenterDarkzoneDialogV2:ctor(root)
  self.super.ctor(self, root)
  root.Type = UIBasePanelType.Panel
end
function ArchivesCenterDarkzoneDialogV2:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ArchivesCenterDarkzoneDialogV2)
  end
  setactive(self.ui.mText_SecondDuring.gameObject, false)
  setactive(self.ui.mText_ThridDuring.gameObject, false)
  self.TextUIList = {}
end
function ArchivesCenterDarkzoneDialogV2:OnInit(root, data)
  self.planData = data.planData
  self.seasonData = data.seasonData
  if self.planData and self.seasonData then
    self:UpdateInfo()
  end
end
function ArchivesCenterDarkzoneDialogV2:UpdateInfo()
  self.ui.mText_Name.text = self.seasonData.name.str
  local beforeTime = CS.CGameTime.ConvertLongToDateTime(self.planData.OpenTime):ToString("yyyy.MM.dd")
  local afterTime = CS.CGameTime.ConvertLongToDateTime(self.planData.CloseTime):ToString("yyyy.MM.dd")
  self.ui.mText_Time.text = string.format("%s-%s", beforeTime, afterTime)
  local firstDataA = TableData.listDarkzoneSeasonMothlyDatas:GetDataById(10010101)
  if firstDataA then
    self.ui.mText_FirstName.text = string_format(firstDataA.text.str, AccountNetCmdHandler:GetName())
  end
  local firstDataB = TableData.listDarkzoneSeasonMothlyDatas:GetDataById(10010102)
  if firstDataB and NetCmdArchivesData:IsFinishAllDarkTask() then
    self.ui.mTextFit_FirstDetails.text = string_format(firstDataB.text.str, self.seasonData.name.str)
    setactive(self.ui.mTextFit_FirstDetails.gameObject, true)
  else
    setactive(self.ui.mTextFit_FirstDetails.gameObject, false)
  end
  local isShowTwo, isShowThree = false, false
  if NetCmdArchivesData:IsShowContentByType(self.planData.id, 2) then
    isShowTwo = true
    local secondTitle = TableData.listDarkzoneSeasonMothlyDatas:GetDataById(10010201)
    if secondTitle then
      self.ui.mText_SecondName.text = string_format(secondTitle.text.str, self.seasonData.name.str)
      setactive(self.ui.mTrans_Title.gameObject, true)
    end
    local secondDataA = TableData.listDarkzoneSeasonMothlyDatas:GetDataById(10010202)
    local currTaskCount = NetCmdArchivesData:GetReportById(self.planData.id, secondDataA.id)
    if 0 < currTaskCount then
      local descA = string_format(secondDataA.text.str, currTaskCount)
      local totalTaskCount = NetCmdArchivesData:GetTotalTaskCountBySeasonId(self.seasonData.id)
      if 0 < totalTaskCount then
        local rate = math.floor(currTaskCount / totalTaskCount * 100) .. "%"
        local secondDataB = TableData.listDarkzoneSeasonMothlyDatas:GetDataById(10010203)
        descA = descA .. string_format(secondDataB.text.str, rate)
      end
      if not self.TextUIList[10010202] then
        local go = instantiate(self.ui.mText_SecondDuring.gameObject, self.ui.mTrans_SecDuring)
        self.TextUIList[10010202] = go:GetComponent(typeof(CS.UnityEngine.UI.Text))
        setactive(self.TextUIList[10010202].gameObject, true)
      end
      self.TextUIList[10010202].text = descA
    elseif self.TextUIList[10010202] then
      setactive(self.TextUIList[10010202].gameObject, false)
    end
    local secondDataC = TableData.listDarkzoneSeasonMothlyDatas:GetDataById(10010204)
    local secondValueC = NetCmdArchivesData:GetReportById(self.planData.id, secondDataC.id)
    if 0 < secondValueC then
      local descC = string_format(secondDataC.text.str, secondValueC)
      if not self.TextUIList[10010204] then
        local go = instantiate(self.ui.mText_SecondDuring.gameObject, self.ui.mTrans_SecDuring)
        self.TextUIList[10010204] = go:GetComponent(typeof(CS.UnityEngine.UI.Text))
        setactive(self.TextUIList[10010204].gameObject, true)
      end
      self.TextUIList[10010204].text = descC
    elseif self.TextUIList[10010204] then
      setactive(self.TextUIList[10010204].gameObject, false)
    end
    local secondDataD = TableData.listDarkzoneSeasonMothlyDatas:GetDataById(10010205)
    local secondValueD = NetCmdArchivesData:GetReportById(self.planData.id, secondDataD.id)
    local descD = ""
    if 0 < secondValueD then
      descD = string_format(secondDataD.text.str, secondValueD)
    end
    local secondDataE = TableData.listDarkzoneSeasonMothlyDatas:GetDataById(10010206)
    local secondValueE = NetCmdArchivesData:GetReportById(self.planData.id, secondDataE.id)
    if 0 < secondValueE then
      local levelRewardData = TableData.listDarkzoneSystemEndlessRewardDatas:GetDataById(secondValueE)
      if levelRewardData then
        local levelData = TableData.listDarkzoneSystemEndlessDatas:GetDataById(levelRewardData.group)
        if levelData then
          descD = descD .. string_format(secondDataE.text.str, levelData.quest.str)
        end
      end
    end
    if descD ~= "" then
      if not self.TextUIList[10010205] then
        local go = instantiate(self.ui.mText_SecondDuring.gameObject, self.ui.mTrans_SecDuring)
        self.TextUIList[10010205] = go:GetComponent(typeof(CS.UnityEngine.UI.Text))
      end
      self.TextUIList[10010205].text = descD
      setactive(self.TextUIList[10010205].gameObject, true)
    elseif self.TextUIList[10010205] then
      setactive(self.TextUIList[10010205].gameObject, false)
    end
    setactive(self.ui.mTrans_ContentA.gameObject, true)
  else
    setactive(self.ui.mTrans_Title.gameObject, false)
    setactive(self.ui.mTrans_ContentA.gameObject, false)
  end
  if NetCmdArchivesData:IsShowContentByType(self.planData.id, 3) then
    isShowThree = true
    local thridDataA = TableData.listDarkzoneSeasonMothlyDatas:GetDataById(10010301)
    local dataValueA = NetCmdArchivesData:GetReportById(self.planData.id, thridDataA.id)
    if 0 < dataValueA then
      local tdescA = string_format(thridDataA.text.str, dataValueA)
      local thridDataB = TableData.listDarkzoneSeasonMothlyDatas:GetDataById(10010302)
      local dataValueB = NetCmdArchivesData:GetReportById(self.planData.id, thridDataB.id)
      if 0 < dataValueB then
        tdescA = tdescA .. string_format(thridDataB.text.str, dataValueB)
      end
      if not self.TextUIList[10010301] then
        local go = instantiate(self.ui.mText_ThridDuring.gameObject, self.ui.mTrans_ThrDuring)
        self.TextUIList[10010301] = go:GetComponent(typeof(CS.UnityEngine.UI.Text))
      end
      self.TextUIList[10010301].text = tdescA
      setactive(self.TextUIList[10010301].gameObject, true)
    elseif self.TextUIList[10010301] then
      setactive(self.TextUIList[10010301].gameObject, false)
    end
    local thridDataC = TableData.listDarkzoneSeasonMothlyDatas:GetDataById(10010303)
    local dataValueC = NetCmdArchivesData:GetReportById(self.planData.id, thridDataC.id)
    if 0 < dataValueC then
      local tdescC = string_format(thridDataC.text.str, dataValueC)
      if not self.TextUIList[10010303] then
        local go = instantiate(self.ui.mText_ThridDuring.gameObject, self.ui.mTrans_ThrDuring)
        self.TextUIList[10010303] = go:GetComponent(typeof(CS.UnityEngine.UI.Text))
      end
      self.TextUIList[10010303].text = tdescC
      setactive(self.TextUIList[10010303].gameObject, true)
    elseif self.TextUIList[10010303] then
      setactive(self.TextUIList[10010303].gameObject, false)
    end
    local thridDataD = TableData.listDarkzoneSeasonMothlyDatas:GetDataById(10010304)
    local dataValueD = NetCmdArchivesData:GetReportById(self.planData.id, thridDataD.id)
    if 0 < dataValueD then
      local tdescD = string_format(thridDataD.text.str, dataValueD)
      if not self.TextUIList[10010304] then
        local go = instantiate(self.ui.mText_ThridDuring.gameObject, self.ui.mTrans_ThrDuring)
        self.TextUIList[10010304] = go:GetComponent(typeof(CS.UnityEngine.UI.Text))
      end
      self.TextUIList[10010304].text = tdescD
      setactive(self.TextUIList[10010304].gameObject, true)
    elseif self.TextUIList[10010304] then
      setactive(self.TextUIList[10010304].gameObject, false)
    end
    local thridDataE = TableData.listDarkzoneSeasonMothlyDatas:GetDataById(10010305)
    local dataValueE = NetCmdArchivesData:GetReportById(self.planData.id, thridDataE.id)
    if 0 < dataValueE then
      local tdescE = string_format(thridDataE.text.str, dataValueE)
      local thridDataF = TableData.listDarkzoneSeasonMothlyDatas:GetDataById(10010306)
      if thridDataF then
        tdescE = tdescE .. thridDataF.text.str
      end
      if not self.TextUIList[10010305] then
        local go = instantiate(self.ui.mText_ThridDuring.gameObject, self.ui.mTrans_ThrDuring)
        self.TextUIList[10010305] = go:GetComponent(typeof(CS.UnityEngine.UI.Text))
      end
      self.TextUIList[10010305].text = tdescE
      setactive(self.TextUIList[10010305].gameObject, true)
    elseif self.TextUIList[10010305] then
      setactive(self.TextUIList[10010305].gameObject, false)
    end
    setactive(self.ui.mTrans_ContentB.gameObject, true)
  else
    setactive(self.ui.mTrans_ContentB.gameObject, false)
  end
  setactive(self.ui.mTrans_DuringInfo.gameObject, isShowTwo or isShowThree)
  local desc = NetCmdArchivesData:GetDescByDivide(self.planData.id)
  self.ui.mTextFit_Details.text = desc
  setactive(self.ui.mTextFit_Details.gameObject, desc ~= "")
end
function ArchivesCenterDarkzoneDialogV2:OnShowStart()
end
function ArchivesCenterDarkzoneDialogV2:OnShowFinish()
end
function ArchivesCenterDarkzoneDialogV2:OnBackFrom()
  self:UpdateInfo()
end
function ArchivesCenterDarkzoneDialogV2:OnClose()
end
function ArchivesCenterDarkzoneDialogV2:OnHide()
end
function ArchivesCenterDarkzoneDialogV2:OnHideFinish()
end
function ArchivesCenterDarkzoneDialogV2:OnRelease()
  self.TextUIList = {}
end
