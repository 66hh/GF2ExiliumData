require("UI.UIBaseCtrl")
ArchivesCenterPlotLevelItemV2 = class("ArchivesCenterPlotLevelItemV2", UIBaseCtrl)
ArchivesCenterPlotLevelItemV2.__index = ArchivesCenterPlotLevelItemV2
function ArchivesCenterPlotLevelItemV2:__InitCtrl()
end
function ArchivesCenterPlotLevelItemV2:InitCtrl(root)
  local com = root:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
end
function ArchivesCenterPlotLevelItemV2:SetData(data)
  UIUtils.GetButtonListener(self.ui.mBtn_ArchivesCenterPlotLevelItemV2.gameObject).onClick = function()
    self:OnClickSelf(data)
  end
  setactive(self.ui.mText_Num.gameObject, false)
  setactive(self.ui.mTrans_ImgLock, false)
  setactive(self.ui.mText_Title.gameObject, false)
  local avgData = TableData.listAvgDatas:GetDataById(data.avgId)
  if not avgData then
    return
  end
  if avgData.condition == 0 or NetCmdArchivesData:MainStoryIsUnLock(avgData.condition) then
    self.isUnLockAvg = true
    if avgData.name.str ~= "" then
      self.ui.mText_Num.text = avgData.name.str .. avgData.number
    else
      self.ui.mText_Num.text = avgData.number
    end
    if avgData.condition == 0 then
      self.ui.mText_Title.text = ""
    else
      local stageData = TableData.listStageDatas:GetDataById(avgData.condition)
      if stageData then
        self.ui.mText_Title.text = stageData.code.str
      end
    end
    setactive(self.ui.mText_Title.gameObject, true)
    setactive(self.ui.mText_Num.gameObject, true)
  else
    setactive(self.ui.mTrans_ImgLock, true)
    self.isUnLockAvg = false
  end
end
function ArchivesCenterPlotLevelItemV2:OnClickSelf(data)
  if self.isUnLockAvg then
    if self.onPlayAvgTime and CGameTime:GetTimestamp() - self.onPlayAvgTime <= 2 then
      return
    end
    self.onPlayAvgTime = CGameTime:GetTimestamp()
    CS.AVGController.PlayAvgByPlotId(data.avgId, function(action, isSkip)
      if self.ossStagePlotInfo == nil then
        self.ossStagePlotInfo = CS.OssStagePlotInfo()
      end
      local avgData = TableDataBase.listAvgDatas:GetDataById(data.avgId)
      local stageId = avgData.collect_id
      local plotId = data.avgId
      self.ossStagePlotInfo:SetInfo(stageId, plotId, isSkip)
      MessageSys:SendMessage(OssEvent.StagePlotLog, nil, self.ossStagePlotInfo)
    end, true, true, false)
  else
    UIUtils.PopupHintMessage(110016)
  end
end
function ArchivesCenterPlotLevelItemV2:UpdateAniState()
  if self.isUnLockAvg then
    self.ui.mAnimator_ArchivesCenterPlotLevelItemV2:SetBool("Unlock", true)
  else
    self.ui.mAnimator_ArchivesCenterPlotLevelItemV2:SetBool("Unlock", false)
  end
  self.ui.mAnimator_ArchivesCenterPlotLevelItemV2.keepAnimatorControllerStateOnDisable = true
end
