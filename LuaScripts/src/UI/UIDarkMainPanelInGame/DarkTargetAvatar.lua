require("UI.UIBaseCtrl")
DarkTargetAvatar = class("DarkTargetAvatar", UIBaseCtrl)
DarkTargetAvatar.__index = DarkTargetAvatar
function DarkTargetAvatar:InitCtrl(root, parent)
  local com = root:GetComponent(typeof(CS.ScrollListChild))
  self.obj = instantiate(com.childItem)
  if root then
    CS.LuaUIUtils.SetParent(self.obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(self.obj, self.ui)
  self:SetRoot(self.obj.transform)
  self.ui.mBtn_Root.onClick:AddListener(function()
    CS.SysMgr.dzPlayerMgr.MainPlayer:ChangeAttackTarget(self.mData)
  end)
end
function DarkTargetAvatar:SetData(Data, isTarget)
  self.mData = Data
  setactive(self.obj.gameObject, true)
  self:SetTarget(isTarget)
  self.ui.mImg_Avatar.sprite = IconUtils.GetEnemyCharacterHeadSprite(self.mData.EnemyData.character_pic)
end
function DarkTargetAvatar:Close()
  self.mData = nil
  self.ui.mBtn_Root.interactable = false
  setactive(self.obj.gameObject, false)
end
function DarkTargetAvatar:SetTarget(isTarget)
  if isTarget then
    self.ui.mBtn_Root.interactable = false
  else
    self.ui.mBtn_Root.interactable = true
  end
end
function DarkTargetAvatar:OnRelease()
  self.ui = nil
  self.mview = nil
  self.mData = nil
end
