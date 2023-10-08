UIRecentActivityFirstOpenedDialog = class("UIRecentActivityFirstOpenedDialog", UIBasePanel)
function UIRecentActivityFirstOpenedDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
  csPanel.UsePool = false
end
function UIRecentActivityFirstOpenedDialog:OnAwake(root, data)
  self.ui = UIUtils.GetUIBindTable(root)
  self:SetRoot(root)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Close.gameObject, function()
    self:onClickBack()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnGoto.gameObject, function()
    self:onClickGoto()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_GrpClose.gameObject, function()
    self:onClickBack()
  end)
end
function UIRecentActivityFirstOpenedDialog:OnInit(root, data, behaviourId)
  self.activityEntranceData = data.activityEntranceData
  self.activityConfigData = data.activityConfigData
  self.activityModuleData = data.activityModuleData
  NetCmdThemeData:SetThemeAnimState(self.activityEntranceData.id, 1)
  NetCmdThemeData:SetShowAniIndex(NetCmdThemeData:GetShowAniIndex() + 1)
end
function UIRecentActivityFirstOpenedDialog:OnShowStart()
  self:refresh()
end
function UIRecentActivityFirstOpenedDialog:OnBackFrom()
  self:refresh()
end
function UIRecentActivityFirstOpenedDialog:OnSave()
end
function UIRecentActivityFirstOpenedDialog:OnRecover()
  self:refresh()
end
function UIRecentActivityFirstOpenedDialog:OnClose()
  self.activityEntranceData = nil
end
function UIRecentActivityFirstOpenedDialog:OnRelease()
  self.ui = nil
  self.super.OnRelease(self)
end
function UIRecentActivityFirstOpenedDialog:refresh()
  if not self.activityEntranceData then
    return
  end
  NetCmdThemeData:SetThemeMessageBoxState(self.activityEntranceData.id, 1)
  self.ui.mImage_Bg.sprite = IconUtils.GetAtlasSprite("RecentActivitie/" .. self.activityEntranceData.banner_title)
  self.ui.mText_Title.text = self.activityEntranceData.name.str
  self.ui.mText_Desc.text = self.activityEntranceData.banner_information.str
  self.ui.mText_Open.text = self.activityEntranceData.activity_desc.str
end
function UIRecentActivityFirstOpenedDialog:onClickGoto()
  if self.activityConfigData.prologue > 0 and NetCmdThemeData:GetThemeAVGState(self.activityConfigData.id) < 1 then
    NetCmdThemeData:SendThemeActivityInfo(self.activityEntranceData.id, function(ret)
      if ret == ErrorCodeSuc then
        if self.activityModuleData.stage_type == 1 then
          UIManager.OpenUIByParam(UIDef.DaiyanPreheatPanel, {
            activityEntranceData = self.activityEntranceData,
            activityModuleData = self.activityModuleData,
            activityConfigData = self.activityConfigData
          })
        else
          UIManager.OpenUIByParam(UIDef.DaiyanMainPanel, {
            activityEntranceData = self.activityEntranceData,
            activityModuleData = self.activityModuleData,
            activityConfigData = self.activityConfigData
          })
        end
      end
    end)
    CS.AVGController.PlayAvgByPlotId(self.activityConfigData.prologue, function()
      NetCmdThemeData:SetThemeAVGState(self.activityConfigData.id, 1)
    end, true)
  else
    NetCmdThemeData:SendThemeActivityInfo(self.activityEntranceData.id, function(ret)
      if ret == ErrorCodeSuc then
        if self.activityModuleData.stage_type == 1 then
          UIManager.OpenUIByParam(UIDef.DaiyanPreheatPanel, {
            activityEntranceData = self.activityEntranceData,
            activityModuleData = self.activityModuleData,
            activityConfigData = self.activityConfigData
          })
        else
          UIManager.OpenUIByParam(UIDef.DaiyanMainPanel, {
            activityEntranceData = self.activityEntranceData,
            activityModuleData = self.activityModuleData,
            activityConfigData = self.activityConfigData
          })
        end
      end
    end)
  end
end
function UIRecentActivityFirstOpenedDialog:onClickBack()
  UIManager.CloseUI(self.mCSPanel)
end
