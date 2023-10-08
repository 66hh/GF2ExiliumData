require("UI.ArchivesPanel.ArchivesUtils")
require("UI.UIBasePanel")
UIAudioPlotPanel = class("UIAudioPlotPanel", UIBasePanel)
UIAudioPlotPanel.__index = UIAudioPlotPanel
function UIAudioPlotPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
end
function UIAudioPlotPanel:OnInit(root, data)
  self:SetRoot(root)
  self.mData = data
  self.IdList = data.IdList
  self.GunId = data.GunId
  self.Type = data.Type
  self.chat_list = data.chat_list
  self.uiRoleFileDetailPanel = data.UIRoleFileDetailPanel
  ArchivesUtils.IsBackFromPlotPanel = false
  self:InitBaseData()
  self.mview:InitCtrl(root, self.ui)
  self:AddBtnListen()
  function self.ui.mVirtualListEx.itemProvider()
    return self:ItemProvider()
  end
  function self.ui.mVirtualListEx.itemRenderer(...)
    self:ItemRenderer(...)
  end
  if ArchivesUtils.IsPlayed == false then
    setactive(self.ui.mText_Details.gameObject, false)
    setactive(self.ui.mText_Tittle.gameObject, false)
    setactive(self.ui.mTrans_GrpLine, false)
  end
  ArchivesUtils.CurAudioItem = nil
  ArchivesUtils.AnimState = -1
end
function UIAudioPlotPanel:OnShowStart()
  self.IsPanelOpen = true
  self:UpdateInfoData()
  self:UpdateItemList()
end
function UIAudioPlotPanel:OnHide()
  self.IsPanelOpen = false
end
function UIAudioPlotPanel:OnUpdate(deltatime)
  self:CheckAudioOver()
end
function UIAudioPlotPanel:OnClickClose()
  ArchivesUtils.EnterWay = 2
  ArchivesUtils.IsPlayed = false
  ArchivesUtils.IsBackFromPlotPanel = true
  UIManager.CloseUI(UIDef.UIAudioPlotPanel)
end
function UIAudioPlotPanel:OnRelease()
  self.ui = nil
  self.mview = nil
  self.ItemDataList = nil
  self.IsPanelOpen = nil
  self.IdList = nil
  self.GunId = nil
  self.avgdic = nil
  self.IsInstDuty = nil
end
function UIAudioPlotPanel:CheckAudioOver()
  if ArchivesUtils.CurAudioItem ~= nil and CS.CriWareAudioController.IsVoicePlaying() == false and self.IsPlaying == true then
    ArchivesUtils.CurAudioItem.ui.mAnim_Self:SetLayerWeight(2, 0)
    ArchivesUtils.CurAudioItem.ui.mAnim_Self:ResetTrigger("PlayVoice")
    ArchivesUtils.CurAudioItem.ui.mAnim_Self:SetTrigger("Normal")
    ArchivesUtils.CurAudioItem = nil
    self.IsPlaying = false
  elseif ArchivesUtils.CurAudioItem ~= nil and CS.CriWareAudioController.IsVoicePlaying() then
    ArchivesUtils.CurAudioItem.ui.mAnim_Self:ResetTrigger("PlayVoice")
    ArchivesUtils.CurAudioItem.ui.mAnim_Self:SetTrigger("PlayVoice")
    self.IsPlaying = true
  end
end
function UIAudioPlotPanel:InitBaseData()
  self.mview = UIAudioPlotPanelView.New()
  self.ui = {}
  self.ItemDataList = {}
  self.IsPanelOpen = false
  self.avgdic = {}
  self.IsInstDuty = false
  if self.Type == 1 then
    local avglist = string.split(self.IdList, ",")
    for i = 1, #avglist do
      if i == #avglist then
        local arr = string.split(avglist[i], ":")
        local temp = string.split(arr[2], ";")
        self.avgdic[tonumber(arr[1])] = tonumber(temp[1])
      else
        local arr = string.split(avglist[i], ":")
        self.avgdic[tonumber(arr[1])] = tonumber(arr[2])
      end
    end
  end
  self.IsPlaying = false
end
function UIAudioPlotPanel:UpdateInfoData()
  self:InstDuty(self.ui.mTrans_Duty)
end
function UIAudioPlotPanel:InstDuty(root)
  local data = TableData.listGunDatas:GetDataById(self.GunId)
  local dutydata = TableData.listGunDutyDatas:GetDataById(data.duty)
  local guncmd = NetCmdTeamData:GetGunByID(self.GunId)
  local str = dutydata.icon
  self.ui.mText_Name.text = data.name.str
  self.ui.mText_Level.text = guncmd.mGun.GunClass
  self.ui.mImg_Avator.sprite = UIUtils.GetIconSprite("Icon/Avatar", "Avatar_Whole_" .. data.code)
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
  self.ui.mText_Duty.text = dutydata.Name.str
end
function UIAudioPlotPanel:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    ArchivesUtils.IsBackFromPlotPanel = false
    ArchivesUtils.IsPlayed = false
    self.ui.mAnim_Root:SetTrigger("_FadeOut")
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    self:OnClickClose()
  end
end
function UIAudioPlotPanel:UpdateItemList()
  self.ItemDataList = {}
  if self.Type == 1 then
    for k, v in pairs(self.avgdic) do
      local data = {}
      data.Id = k
      data.Level = v
      table.insert(self.ItemDataList, data)
    end
    table.sort(self.ItemDataList, function(a, b)
      return a.Id <= b.Id
    end)
    for i = 1, #self.ItemDataList do
      if i == 1 then
        local guncmd = ArchivesUtils:GetGunData(self.uiRoleFileDetailPanel.mData.unit_id)
        if guncmd ~= nil and guncmd.mGun.GunClass >= self.ItemDataList[i].Level then
          self.ItemDataList[i].LastWatch = true
        else
          self.ItemDataList[i].LastWatch = false
        end
      else
        self.ItemDataList[i].LastWatch = AccountNetCmdHandler:IsWatchedChapter(self.ItemDataList[i - 1].Id)
      end
    end
  elseif self.Type == 2 then
    for i = 0, self.IdList.Count - 1 do
      local data = {}
      data.Id = self.IdList[i]
      data.Belong = 1
      table.insert(self.ItemDataList, data)
    end
    for i = 0, self.chat_list.Count - 1 do
      local data = {}
      data.Id = self.chat_list[i]
      data.Belong = 2
      table.insert(self.ItemDataList, data)
    end
  end
  self.ui.mVirtualListEx:Refresh()
  self.ui.mVirtualListEx.numItems = #self.ItemDataList
end
function UIAudioPlotPanel:ItemProvider()
  local itemView = AudioPlotItem.New()
  itemView:InitCtrl(self.ui.mTrans_Content)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIAudioPlotPanel:ItemRenderer(index, renderData)
  local data = self.ItemDataList[index + 1]
  local item = renderData.data
  item:SetData(data, self.Type, index, self, self.uiRoleFileDetailPanel)
end
