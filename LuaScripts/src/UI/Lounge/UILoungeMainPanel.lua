UILoungeMainPanel = class("UILoungeMainPanel", UIBasePanel)
UILoungeMainPanel.__index = UILoungeMainPanel
local AnimType = {
  1001,
  1002,
  1003,
  1004,
  1005,
  1006
}
function UILoungeMainPanel:ctor(csPanel)
  UILoungeMainPanel.super:ctor(csPanel)
  csPanel.Is3DPanel = true
end
function UILoungeMainPanel:OnAwake(root, data)
  self:SetRoot(root)
  self.mUIRoot = root
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
end
function UILoungeMainPanel:OnInit(root, data)
  self:AddListener()
end
function UILoungeMainPanel:OnShowStart()
  setactive(self.mUIRoot.gameObject, true)
  math.randomseed(os.time())
  local randNum = math.random(#AnimType)
  LoungeHelper.AnimCtrl:PlayAnim(AnimType[randNum])
end
function UILoungeMainPanel:OnShowFinish()
  SceneSys:SwitchVisible(EnumSceneType.Lounge)
end
function UILoungeMainPanel:OnHide()
  setactive(self.mUIRoot.gameObject, false)
end
function UILoungeMainPanel:OnClose()
  setactive(self.mUIRoot.gameObject, false)
end
function UILoungeMainPanel:OnRelease()
  self.super.OnRelease(self)
end
function UILoungeMainPanel:AddListener()
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnBack.gameObject, function()
    UIManager.JumpToMainPanel()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnHome.gameObject, function()
    UIManager.JumpToMainPanel()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Book.gameObject, function()
    LoungeHelper.AnimCtrl:PlayAnim(AnimType[1])
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Book1.gameObject, function()
    LoungeHelper.AnimCtrl:PlayAnim(AnimType[2])
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Game.gameObject, function()
    LoungeHelper.AnimCtrl:PlayAnim(AnimType[3])
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Look.gameObject, function()
    LoungeHelper.AnimCtrl:PlayAnim(AnimType[4])
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Rest.gameObject, function()
    LoungeHelper.AnimCtrl:PlayAnim(AnimType[5])
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Sleep.gameObject, function()
    LoungeHelper.AnimCtrl:PlayAnim(AnimType[6])
  end)
end
function UILoungeMainPanel:HideUI()
  setactive(self.ui.mRect_Root.gameObject, false)
end
function UILoungeMainPanel:ShowUI()
  setactive(self.ui.mRect_Root.gameObject, true)
end
