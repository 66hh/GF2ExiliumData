require("UI.UIBaseCtrl")
DarkzoneGrassWarningTipsItem = class("DarkzoneGrassWarningTipsItem", UIBaseCtrl)
DarkzoneGrassWarningTipsItem.__index = DarkzoneGrassWarningTipsItem
local EnumDarkzoneProperty = require("UI.UIDarkMainPanelInGame.DarkzoneProperty")
function DarkzoneGrassWarningTipsItem:InitCtrl(origin, parent)
  self.obj = instantiate(origin, parent.transform)
  self.parent = parent
  self.ui = {}
  self:LuaUIBindTable(self.obj, self.ui)
  self.trans = self.obj.gameObject:GetComponent(typeof(CS.UnityEngine.RectTransform))
end
function DarkzoneGrassWarningTipsItem:SetHost(host)
  self.mHost = host
  self.hasHost = true
  function self.ui.mHelp_Pos.lateUpdate(deltatime)
    self:UpdatePos()
  end
end
function DarkzoneGrassWarningTipsItem:UpdatePos()
  if self.hasHost then
    if self.mHost == nil then
      self:SetNull()
      return
    end
    local pos = CS.SysMgr.dzGameMapMgr:NameTipPosByHostPos(self.mHost.Data.serverTrans.UnityPos, self.parent)
    self.trans.anchoredPosition = pos
  end
end
function DarkzoneGrassWarningTipsItem:SetNull()
  setactive(self.obj, false)
  self.hasHost = false
  self.mHost = nil
  self.ui.mHelp_Pos.lateUpdate = nil
end
function DarkzoneGrassWarningTipsItem:OnRelease()
  self.ui.mHelp_Pos.lateUpdate = nil
  self.ui = nil
  self.mview = nil
  self.mHost = nil
  self.trans = nil
  self.hasHost = nil
  self.parent = nil
end
function DarkzoneGrassWarningTipsItem:SetVisible(visible)
  self.obj.gameObject:SetActive(visible)
end
