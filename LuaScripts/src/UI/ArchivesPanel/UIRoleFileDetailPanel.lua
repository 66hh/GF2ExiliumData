require("UI.UIBasePanel")
UIRoleFileDetailPanel = class("UIRoleFileDetailPanel", UIBasePanel)
UIRoleFileDetailPanel.__index = UIRoleFileDetailPanel
function UIRoleFileDetailPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
end
function UIRoleFileDetailPanel:OnAwake(root, data)
  self:SetRoot(root)
  self:InitBaseData()
  self.mview:InitCtrl(root, self.ui)
  self:AddBtnListen()
end
function UIRoleFileDetailPanel:OnInit(root, data)
  self.mData = data
  self.IsPanelOpen = false
  self.IsVisual = false
  self.listData = {}
  self.GunCmdData = ArchivesUtils:GetGunData(self.mData.UnitId)
  self.IsInstDuty = false
  self.DataIndex = 0
  self.GunId = 0
  self.LastChrItem = nil
  for i = 0, TableData.listGunCharacterDatas.Count - 1 do
    local data = TableData.listGunCharacterDatas[i]
    local netcmd = ArchivesUtils:GetGunData(data.UnitId)
    local a = data.sort
    if netcmd ~= nil then
      table.insert(self.listData, data)
    end
  end
  table.sort(self.listData, function(a, b)
    if a.sort == nil or b.sort == nil then
      return false
    end
    if a.sort == b.sort then
      return false
    else
      return a.sort < b.sort
    end
  end)
  self:GetIndex()
  if self.DataIndex == 1 then
    setactive(self.ui.mBtn_Left.gameObject, false)
  elseif self.DataIndex == #self.listData then
    setactive(self.ui.mBtn_Right.gameObject, false)
  end
end
function UIRoleFileDetailPanel:OnShowStart()
  if ArchivesUtils.EnterWay == 1 then
    self.ui.mAnim_Root:SetTrigger("FadeIn")
  elseif ArchivesUtils.EnterWay == 2 then
    TimerSys:DelayCall(0.33, function()
      self.ui.mAnim_Root:SetTrigger("FadeIn")
    end)
  end
  self.IsPanelOpen = true
  self:UpdateInfoData()
end
function UIRoleFileDetailPanel:OnBackFrom()
  self:OnShowStart()
end
function UIRoleFileDetailPanel:OnHide()
  self.IsPanelOpen = false
end
function UIRoleFileDetailPanel:OnRelease()
  self.IsPanelOpen = nil
  self.IsVisual = nil
  self.mData = nil
  self.listData = nil
  self.GunCmdData = nil
  self.IsInstDuty = nil
  self.dutyobj = nil
  self.DataIndex = nil
  self.GunId = nil
  self.LastChrItem = nil
  self.ui.mBtn_Home.onClick:RemoveListener(self.onClickHomeCallback)
  self.ui.mBtn_Back.onClick:RemoveListener(self.onClickBackCallback)
  UIUtils.GetButtonListener(self.ui.mBtn_Visual.gameObject).onClick = nil
  UIUtils.GetButtonListener(self.ui.mBtn_Show.gameObject).onClick = nil
  self.ui.mBtn_Left.onClick:RemoveListener(self.onClickLeftCallback)
  self.ui.mBtn_Right.onClick:RemoveListener(self.onClickRightCallback)
  self.ui.mBtn_PlotAudio.onClick:RemoveListener(self.onClickPlotAudioCallback)
  self.ui.mBtn_ChrAudio.onClick:RemoveListener(self.onChrAudioCallback)
  self.mview = nil
  self.ui = nil
end
function UIRoleFileDetailPanel:OnClickClose()
  ArchivesUtils.IsBackFromPlotPanel = false
  self.ui.mAnim_Root:SetTrigger("ComPage_fadeout")
  UIManager.CloseUI(UIDef.UIRoleFileDetailPanel)
end
function UIRoleFileDetailPanel:InitBaseData()
  self.mview = UIRoleFileDetailPanelView.New()
  self.ui = {}
end
function UIRoleFileDetailPanel:GetIndex()
  for i = 1, #self.listData do
    if self.listData[i].Id == self.mData.Id then
      self.DataIndex = i
      return
    end
  end
end
function UIRoleFileDetailPanel:UpdateInfoData()
  if ArchivesUtils.IsBackFromPlotPanel == false then
    self.ui.mText_Detail.text = self.mData.CharInfo.str
    self.ui.mText_Level.text = self.GunCmdData.mGun.GunClass
    local rank = ArchivesUtils:GetUnlockBestRank(self.mData.UnitId)
    for i = 0, self.ui.mTrans_GrpChr.childCount - 1 do
      gfdestroy(self.ui.mTrans_GrpChr:GetChild(i))
    end
    local gunlist = {}
    for i = 0, self.mData.UnitId.Count - 1 do
      local data = TableData.listGunDatas:GetDataById(self.mData.UnitId[i])
      table.insert(gunlist, data)
    end
    table.sort(gunlist, function(a, b)
      return a.rank <= b.rank
    end)
    for i = 1, #gunlist do
      local gundata = gunlist[i]
      local item = ChrItem.New()
      item:InitCtrl(self.ui.mTrans_GrpChr)
      item:SetData(gundata, self)
      if rank == gundata.rank then
        item.ui.mBtn_Self.onClick:Invoke()
      end
    end
    self:InstDuty(self.ui.mTrans_GrpDuty)
    self.ui.mText_JPName.text = self.mData.CvJp.str
    self.ui.mText_CNName.text = self.mData.CvCn.str
    self.ui.mText_Suti.text = self.mData.BodyId.str
    self.ui.mText_Laoyin.text = self.mData.Brand.str
    self.ui.mText_GuiShu.text = self.mData.Belong.str
    self.ui.mText_Kou.text = self.mData.PetPhrase.str
  end
  self:UpdateRedPoint(self.mData)
end
function UIRoleFileDetailPanel:UpdateRedPoint(Data)
  local plotredpoint = self.ui.mBtn_PlotAudio.gameObject.transform:Find("Root/Trans_RedPoint")
  local chrredpoint = self.ui.mBtn_ChrAudio.gameObject.transform:Find("Root/Trans_RedPoint")
  setactive(plotredpoint, false)
  setactive(chrredpoint, false)
  local charlist = Data.chat_list
  local audiolist = Data.audio_list
  local avgdic = {}
  local avlist = {}
  local uid = AccountNetCmdHandler.Uid
  local latestAvgId = NetCmdArchivesData:GetInt(uid .. Data.en_name .. "LastAvgId")
  local latestAudioId = NetCmdArchivesData:GetInt(uid .. Data.en_name .. "LastAudioId")
  local guncmd = ArchivesUtils:GetGunData(Data.unit_id)
  local templist = string.split(Data.avg_list, ",")
  for i = 1, #templist do
    if i == #templist then
      local arr = string.split(templist[i], ":")
      local temp = string.split(arr[2], ";")
      avgdic[tonumber(arr[1])] = tonumber(temp[1])
    else
      local arr = string.split(templist[i], ":")
      avgdic[tonumber(arr[1])] = tonumber(arr[2])
    end
  end
  for k, v in pairs(avgdic) do
    local data = {}
    data.Id = k
    data.Level = v
    table.insert(avlist, data)
  end
  table.sort(avlist, function(a, b)
    return a.Id <= b.Id
  end)
  local audioplot = "audioplot"
  for i = 0, Data.audio_list.Count - 1 do
    if NetCmdArchivesData:GetInt(uid .. Data.audio_list[i] .. audioplot) == 0 then
      setactive(chrredpoint, true)
      break
    end
  end
  for i = 0, Data.chat_list.Count - 1 do
    local adjData = TableData.listAdjutantConversationDatas:GetDataById(Data.chat_list[i])
    if NetCmdArchivesData:GetInt(uid .. adjData.voice .. audioplot) == 0 then
      setactive(chrredpoint, true)
      break
    end
  end
end
function UIRoleFileDetailPanel:InstDuty(root)
  local data = TableData.listGunDatas:GetDataById(self.mData.UnitId[0])
  local dutydata = TableData.listGunDutyDatas:GetDataById(data.duty)
  local str = dutydata.icon
  if self.IsInstDuty == false then
    local com = root:GetComponent(typeof(CS.ScrollListChild))
    self.dutyobj = instantiate(com.childItem)
    if root then
      CS.LuaUIUtils.SetParent(self.dutyobj.gameObject, root.gameObject, true)
    end
    self.IsInstDuty = true
  end
  local str2 = string.gsub(str, "Burst", "ALL")
  self.dutyobj.transform:Find("Img_DutyIcon"):GetComponent("Image").sprite = IconUtils.GetGunTypeIcon(str2)
  self.ui.mText_DutyName.text = dutydata.Name.str
end
function UIRoleFileDetailPanel:AddBtnListen()
  function self.onClickHomeCallback()
    ArchivesUtils.IsBackFromPlotPanel = false
    self.ui.mAnim_Root:SetTrigger("ComPage_fadeout")
    UIManager.JumpToMainPanel()
  end
  function self.onClickBackCallback()
    self:OnClickClose()
  end
  function self.onClickVisualCallback()
    if self.IsVisual == false then
      self:Visual()
    end
  end
  function self.onClickShowCallback()
    if self.IsVisual then
      self.ui.mAnim_Root:SetTrigger("Visual_fadein")
      self.ui.mBtn_Visual.interactable = false
      self.IsVisual = false
      TimerSys:DelayCall(0.2, function()
        self.ui.mBtn_Visual.interactable = true
      end)
    end
  end
  function self.onClickLeftCallback()
    self:LeftArrow()
  end
  function self.onClickRightCallback()
    self:RightArrow()
  end
  function self.onClickPlotAudioCallback()
    self:PlotAudio()
  end
  function self.onChrAudioCallback()
    self:ChrAudio()
  end
  self.ui.mBtn_Home.onClick:AddListener(self.onClickHomeCallback)
  self.ui.mBtn_Back.onClick:AddListener(self.onClickBackCallback)
  UIUtils.GetButtonListener(self.ui.mBtn_Visual.gameObject).onClick = self.onClickVisualCallback
  UIUtils.GetButtonListener(self.ui.mBtn_Show.gameObject).onClick = self.onClickShowCallback
  self.ui.mBtn_Left.onClick:AddListener(self.onClickLeftCallback)
  self.ui.mBtn_Right.onClick:AddListener(self.onClickRightCallback)
  self.ui.mBtn_PlotAudio.onClick:AddListener(self.onClickPlotAudioCallback)
  self.ui.mBtn_ChrAudio.onClick:AddListener(self.onChrAudioCallback)
end
function UIRoleFileDetailPanel:Visual()
  self.ui.mAnim_Root:SetTrigger("Visual_fadeout")
  self.ui.mBtn_Show.interactable = false
  self.IsVisual = true
  TimerSys:DelayCall(0.2, function()
    self.ui.mBtn_Show.interactable = true
  end)
end
function UIRoleFileDetailPanel:LeftArrow()
  ArchivesUtils.IsBackFromPlotPanel = false
  if self.ui.mBtn_Right.gameObject.activeSelf == false then
    setactive(self.ui.mBtn_Right.gameObject, true)
  end
  self.DataIndex = self.DataIndex - 1
  self.mData = self.listData[self.DataIndex]
  self.ui.mAnim_Root:SetTrigger("Previous")
  self:UpdateInfoData()
  if self.DataIndex == 1 then
    setactive(self.ui.mBtn_Left.gameObject, false)
  end
end
function UIRoleFileDetailPanel:RightArrow()
  ArchivesUtils.IsBackFromPlotPanel = false
  if self.ui.mBtn_Left.gameObject.activeSelf == false then
    setactive(self.ui.mBtn_Left.gameObject, true)
  end
  self.DataIndex = self.DataIndex + 1
  self.mData = self.listData[self.DataIndex]
  self.ui.mAnim_Root:SetTrigger("Next")
  self:UpdateInfoData()
  if self.DataIndex == #self.listData then
    setactive(self.ui.mBtn_Right.gameObject, false)
  end
end
function UIRoleFileDetailPanel:PlotAudio()
  local data = {}
  data.IdList = self.mData.avg_list
  data.GunId = self.GunId
  data.Type = 1
  data.UIRoleFileDetailPanel = self
  UIManager.OpenUIByParam(UIDef.UIAudioPlotPanel, data)
end
function UIRoleFileDetailPanel:ChrAudio()
  local data = {}
  data.IdList = self.mData.audio_list
  data.chat_list = self.mData.chat_list
  data.GunId = self.GunId
  data.Type = 2
  data.UIRoleFileDetailPanel = self
  UIManager.OpenUIByParam(UIDef.UIAudioPlotPanel, data)
end
