require("UI.UIBasePanel")
ComBtnInputKeyPC = class("ComBtnInputKeyPC", UIBaseCtrl)
ComBtnInputKeyPC.__index = ComBtnInputKeyPC
function ComBtnInputKeyPC:ctor()
end
function ComBtnInputKeyPC:InitCtrl(obj, needHideObjList, panel, Key, KeyStr)
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self.PCKeyUI = {}
  self:LuaUIBindTable(CS.LuaUIUtils.GetUIPCKeyObj(self.ui.mPCKey.transform), self.PCKeyUI)
  self.panel = panel
  self.needHideObjList = {}
  self.needHideObjList = needHideObjList
  self.isShow = true
  self.PCKeyUI.mText_InputKey.text = KeyStr
  self.key = Key
  self.KeyStr = KeyStr
  self.clickBtn = nil
  self.ui.mText_Show.text = TableData.GetHintById(280018)
  self:Content()
end
function ComBtnInputKeyPC:Content()
  self:AddKeyListener()
end
function ComBtnInputKeyPC:AddKeyListener()
  function self.showFunc()
    if self.isShow then
      self.isShow = false
      for i = 1, #self.needHideObjList do
        local obj = self.needHideObjList[i]
        setactivewithcheck(obj, false)
      end
      self.ui.mText_Show.text = TableData.GetHintById(280017)
    else
      self.isShow = true
      for i = 1, #self.needHideObjList do
        local obj = self.needHideObjList[i]
        setactivewithcheck(obj, true)
      end
      self.ui.mText_Show.text = TableData.GetHintById(280018)
    end
  end
  UIUtils.GetButtonListener(self.PCKeyUI.mBtn_KeyPC.gameObject).onClick = function()
    self.showFunc()
  end
  if self.key == KeyCode.Mouse2 then
    self.clickBtn = self.panel.ui.mBtn_Reset
    self.ui.mText_Show.text = TableData.GetHintById(230019)
  elseif self.key == KeyCode.H then
    self.clickBtn = self.PCKeyUI.mBtn_KeyPC
  end
  setactivewithcheck(self.ui.mTrans_Icon, self.key == KeyCode.Mouse2)
  setactivewithcheck(self.ui.mPCKey, self.key ~= KeyCode.Mouse2)
  self.panel:RegistrationKeyboard(self.key, self.clickBtn)
end
function ComBtnInputKeyPC:OnRelease()
  gfdestroy(self:GetRoot())
end
