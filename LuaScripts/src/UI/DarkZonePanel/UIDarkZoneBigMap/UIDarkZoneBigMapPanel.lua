require("UI.UIBaseCtrl")
require("UI.DarkZonePanel.UIDarkZoneBigMap.UIDarkZoneMapIconItem")
require("UI.DarkZonePanel.UIDarkZoneExplorePanel.DarkZoneExploreGlobal")
UIDarkZoneBigMapPanel = class("UIDarkZoneBigMapPanel", UIBaseCtrl)
UIDarkZoneBigMapPanel.__index = UIDarkZoneBigMapPanel
function UIDarkZoneBigMapPanel:InitCtrl(root)
  local obj = self:Instantiate("Darkzone/DarkzoneMapItem.prefab", root)
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self:InitBaseData()
  self:AddBtnListen()
  setactive(self.ui.mTrans_MarkIcon, false)
  self:InitIconList()
  self:OnMapShow()
  self.ui.mSlider_MapSlider.value = self.currentScale
  self:OnSliderValueChange(self.currentScale)
  self:RefreshExpore()
end
function UIDarkZoneBigMapPanel:OnClose()
  if self.ui.mTrans_MarkList.gameObject.activeSelf == false then
    self:CloseSelf()
  else
    setactive(self.ui.mTrans_MarkList, false)
  end
end
function UIDarkZoneBigMapPanel:CloseSelf()
  if self.callback then
    self.callback()
    self.callback = nil
  end
end
function UIDarkZoneBigMapPanel:CloseFunction()
  self.mapManage:CloseBigMap()
  self:OnRelease()
end
function UIDarkZoneBigMapPanel:OnRelease()
  self.ui = nil
  self.currentScale = nil
  self.mapManage = nil
  self:ReleaseCtrlTable(self.iconMaskList, true)
  self.iconMaskList = nil
  self.canSetPoint = nil
  self.super.OnRelease(self)
end
function UIDarkZoneBigMapPanel:InitBaseData()
  self.currentScale = tonumber(TableData.GlobalDarkzoneData.DarkzoneMapZoomDefault) or 1
  self.mapManage = CS.SysMgr.dzMiniMapDataMgr
  self.tbData = {}
  local list = TableData.listDarkzoneMinimapIconDatas:GetList()
  for i = 0, list.Count - 1 do
    if list[i].icon_visible == true then
      local d = {}
      d.iconName = list[i].icon_name.str
      d.icon = list[i].icon
      table.insert(self.tbData, d)
    end
  end
  self.iconMaskList = {}
  local areaID = CS.SysMgr.dzMatchGameMgr.selectSceneId
  local darkzoneMapV2Data = TableData.listDarkzoneMapV2Datas:GetDataById(areaID)
  local areaData = TableData.listDarkzoneMinimapV2Datas:GetDataById(darkzoneMapV2Data.minimap_id)
  self.maxSliderValue = areaData.DarkzoneMapZoomBenchmarkMax
  self.minSliderValue = areaData.DarkzoneMapZoomBenchmarkMin
  local maxScaleValue = areaData.DarkzoneMapZoomLimit[1]
  local minScaleValue = areaData.DarkzoneMapZoomLimit[0]
  self.offsetKValue = (maxScaleValue - minScaleValue) / (self.maxSliderValue - self.minSliderValue)
  self.offsetBValue = minScaleValue - self.minSliderValue * self.offsetKValue
  self.ui.mSlider_MapSlider.maxValue = self.maxSliderValue
  self.ui.mSlider_MapSlider.minValue = self.minSliderValue
end
function UIDarkZoneBigMapPanel:AddBtnListen()
  self.ui.mBtn_Close.onClick:AddListener(function()
    self:OnClose()
  end)
  self.ui.mBtn_Increase.onClick:AddListener(function()
    self:OnSliderBtnClick(0.1)
  end)
  self.ui.mBtn_Reduce.onClick:AddListener(function()
    self:OnSliderBtnClick(-0.1)
  end)
  self.ui.mSlider_MapSlider.onValueChanged:AddListener(function(ptc)
    self:OnSliderValueChange(ptc)
  end)
  self.ui.mBtn_Info.onClick:AddListener(function()
    setactive(self.ui.mTrans_MarkList, true)
  end)
  self.ui.mBtn_CloseMask.onClick:AddListener(function()
    setactive(self.ui.mTrans_MarkList, false)
  end)
end
function UIDarkZoneBigMapPanel:OnSliderValueChange(ptc)
  if ptc <= self.minSliderValue then
    ptc = self.minSliderValue
  elseif ptc >= self.maxSliderValue then
    ptc = self.maxSliderValue
  end
  self.ui.mBtn_Increase.interactable = ptc < self.maxSliderValue
  self.ui.mBtn_Reduce.interactable = ptc > self.minSliderValue
  self.ui.mText_Num.text = string.format("%.1f X", ptc)
  self.currentScale = ptc
  local num = ptc * self.offsetKValue + self.offsetBValue
  self.mapManage:ShowLod(ptc, num)
end
function UIDarkZoneBigMapPanel:OnSliderBtnClick(changeValue)
  self.currentScale = self.currentScale + changeValue
  self.ui.mSlider_MapSlider.value = self.currentScale
end
function UIDarkZoneBigMapPanel:OnMapShow()
  self.mapManage:OpenBigMap(self.mUIRoot)
end
function UIDarkZoneBigMapPanel:SetMapCloseBtnActive(enable)
  setactive(self.ui.mBtn_Close.transform.parent, enable)
end
function UIDarkZoneBigMapPanel:InitIconList()
  for k, v in ipairs(self.tbData) do
    local item = UIDarkZoneMapIconItem.New()
    local obj
    obj = instantiate(self.ui.mTrans_MarkIcon.gameObject)
    item:InitCtrl(self.ui.mTrans_Content, obj)
    item:SetData(v)
    item:SetActive(true)
    table.insert(self.iconMaskList, item)
  end
end
function UIDarkZoneBigMapPanel:SetData(callback)
  self.callback = callback
end
function UIDarkZoneBigMapPanel:RefreshExpore()
  for i = 1, 3 do
    self.ui["mAni_GrpNum" .. i].keepAnimatorControllerStateOnDisable = true
  end
  setactive(self.ui.mTrans_GrpExplore.gameObject, false)
  if CS.SysMgr.dzMatchGameMgr.darkZoneType ~= CS.ProtoObject.DarkZoneType.DzExplore then
    return
  end
  if not DarkZoneExploreGlobal.CheckExploreLevelOpen(CS.SysMgr.dzMatchGameMgr.ExploreMapMaxIndex + 1) then
    return
  end
  setactive(self.ui.mTrans_GrpExplore.gameObject, true)
  local curBeaconNum = CS.SysMgr.dzPlayerMgr.MainPlayerData.BeaconAllCount
  local beaconNumMax = CS.SysMgr.dzUIControlMgr.BeaconAllMapCount
  self.ui.mText_Explore.text = string_format(TableData.GetHintById(240092), curBeaconNum, beaconNumMax)
end
function UIDarkZoneBigMapPanel:OnShowStart()
  local index = CS.SysMgr.dzMatchGameMgr.exploreMapIndex + 1
  for i = 1, 3 do
    self.ui["mAni_GrpNum" .. i]:SetBool("Bool", index == i)
  end
end
