require("UI.UIBaseCtrl")
UICombatLauncherChallengeItem = class("UICombatLauncherChallengeItem", UIBaseCtrl)
UICombatLauncherChallengeItem.__index = UICombatLauncherChallengeItem
function UICombatLauncherChallengeItem:__InitCtrl()
end
function UICombatLauncherChallengeItem:InitCtrl(parent)
  if parent == nil then
    return
  end
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(itemPrefab.childItem, parent)
  self.ui = UIUtils.GetUIBindTable(obj)
  self:SetRoot(obj.transform)
  self:__InitCtrl()
end
function UICombatLauncherChallengeItem:InitRoot(root)
  self.ui = UIUtils.GetUIBindTable(root)
  self:SetRoot(root.transform)
  self:__InitCtrl()
end
function UICombatLauncherChallengeItem:SetData(id, archived)
  if id ~= nil then
    setactive(self.mUIRoot, true)
    local challengeData = TableData.GetStageChallengeData(id)
    self.ui.mText_Description.text = challengeData.description.str
    self.ui.mAnimator_Root:SetBool("Finish", archived)
  else
    setactive(self.mUIRoot, false)
  end
end
