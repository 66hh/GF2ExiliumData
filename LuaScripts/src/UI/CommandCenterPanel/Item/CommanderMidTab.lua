require("UI.UIBaseCtrl")
CommanderMidTab = class("CommanderMidTab", UIBaseCtrl)
CommanderMidTab.__index = CommanderMidTab
function CommanderMidTab:ctor()
  self.systemId = 0
end
function CommanderMidTab:__InitCtrl()
end
function CommanderMidTab:InitCtrl(obj)
  self:SetRoot(obj.transform)
  self:__InitCtrl()
  self.grpText = self:GetRectTransform("Root/GrpText")
  self.btn = obj.transform:GetComponent(typeof(CS.UnityEngine.UI.GFButton))
  self.animator = obj.transform:GetComponent(typeof(CS.UnityEngine.Animator))
  self.transRedPoint = self:GetRectTransform("Root/GrpText/GrpText/Trans_RedPoint")
end
function CommanderMidTab:SetData(systemId)
  self.systemId = systemId or 0
  self:UpdateData()
end
function CommanderMidTab:UpdateData()
  local isLock = not AccountNetCmdHandler:CheckSystemIsUnLock(self.systemId)
  if self.systemId ~= 16000 and self.systemId ~= 17000 and AccountNetCmdHandler:CheckSystemIsUnLockThisLogin(self.systemId) and not PlayerPrefs.HasKey(AccountNetCmdHandler:GetUID() .. "_Unlock_" .. self.systemId) then
    self.btn.interactable = false
    self.transRedPoint.localScale = vectorzero
    PlayerPrefs.SetInt(AccountNetCmdHandler:GetUID() .. "_Unlock_" .. self.systemId, 1)
    TimerSys:DelayCall(1.5, function()
      if self.animator then
        self.animator:SetTrigger("UnlockAni")
      end
    end)
    TimerSys:DelayCall(2.5, function()
      if self.transRedPoint then
        self.transRedPoint.localScale = vectorone
      end
      if self.btn then
        self.btn.interactable = true
      end
    end)
  else
    self.btn.interactable = not isLock
  end
end
