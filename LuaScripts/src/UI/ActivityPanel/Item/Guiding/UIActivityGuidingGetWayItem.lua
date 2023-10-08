require("UI.UIBaseCtrl")
UIActivityGuidingGetWayItem = class("UIActivityGuidingGetWayItem", UIBaseCtrl)
UIActivityGuidingGetWayItem.__index = UIActivityGuidingGetWayItem
function UIActivityGuidingGetWayItem:ctor()
  self.super.ctor(self)
end
function UIActivityGuidingGetWayItem:InitCtrl(itemPrefab, parent)
  local instObj = instantiate(itemPrefab, parent)
  self:SetRoot(instObj.transform)
  self.ui = {}
  self:LuaUIBindTable(instObj.transform, self.ui)
  setactive(instObj, true)
end
function UIActivityGuidingGetWayItem:SetData(data)
  setactive(self.ui.mImg_Icon, data.icon ~= "")
  if data.icon ~= "" then
    self.ui.mImg_Icon.sprite = IconUtils.GetGuidingSprite(data.icon)
  end
  self.medium = NetCmdActivityGuidingData:GetActivityMedium(data.id)
  self.ui.mText_Name.text = data.notes.str
  if self.medium ~= nil then
    if NetCmdActivityGuidingData:IsMediumViewed(data.id) then
      setactive(self.ui.mTrans_Goto, false)
      setactive(self.ui.mTrans_Receive, self.medium.State ~= CS.ProtoObject.ActivityMediumState.Getted)
    else
      setactive(self.ui.mTrans_Goto, self.medium.State == CS.ProtoObject.ActivityMediumState.None)
      setactive(self.ui.mTrans_Receive, self.medium.State == CS.ProtoObject.ActivityMediumState.Checked)
    end
    setactive(self.ui.mTrans_Finish, self.medium.State == CS.ProtoObject.ActivityMediumState.Getted)
  else
    gfwarning(tostring(NetCmdActivityGuidingData:IsMediumViewed(data.id)))
    setactive(self.ui.mTrans_Goto, not NetCmdActivityGuidingData:IsMediumViewed(data.id))
    setactive(self.ui.mTrans_Receive, NetCmdActivityGuidingData:IsMediumViewed(data.id))
    setactive(self.ui.mTrans_Finish, false)
  end
  if data.urls == "" then
    UIUtils.GetButtonListener(self.ui.mTrans_Goto.gameObject).onClick = function()
      UIManager.OpenUIByParam(UIDef.UIGuidingActivityExplainDialog, {
        id = data.id
      })
    end
  else
    UIUtils.GetButtonListener(self.ui.mTrans_Goto.gameObject).onClick = function()
      NetCmdActivityGuidingData:ViewMedium(data.id)
      setactive(self.ui.mTrans_Goto, false)
      setactive(self.ui.mTrans_Receive, true)
      if CS.GF2.SDK.PlatformLoginManager.Instance:OpenApplicationURL(data.urls) == false then
        CS.GF2.ExternalTools.Browsers.BrowserHandler.Show(data.urls, CS.GF2.ExternalTools.Browsers.BrowserShowType.OutSourceURL)
      end
    end
  end
  UIUtils.GetButtonListener(self.ui.mTrans_Receive.gameObject).onClick = function()
    NetCmdActivityGuidingData:ReqGetMediumReward(data.id, function(ret)
      if ret == ErrorCodeSuc then
        UIManager.OpenUIByParam(UIDef.UICommonReceivePanel, {
          nil,
          function()
            setactive(self.ui.mTrans_Receive, false)
            setactive(self.ui.mTrans_Finish, true)
          end
        })
      end
    end)
  end
end
