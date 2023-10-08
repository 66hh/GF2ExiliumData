require("UI.UIBaseCtrl")
ActivityTourAvatarStepItem = class("ActivityTourAvatarStepItem", UIBaseCtrl)
ActivityTourAvatarStepItem.__index = ActivityTourAvatarStepItem
function ActivityTourAvatarStepItem:ctor()
  self.super.ctor(self)
end
function ActivityTourAvatarStepItem:InitCtrl(itemPrefab, parent)
  local instObj = instantiate(itemPrefab, parent)
  self:SetRoot(instObj.transform)
  self.mUIRootRectTrans = UIUtils.GetRectTransform(instObj)
  self.ui = {}
  self:LuaUIBindTable(instObj.transform, self.ui)
  self.ui.mAnimator_Root.keepAnimatorControllerStateOnDisable = true
end
function ActivityTourAvatarStepItem:FadeInOut(isFadeIn)
  UIUtils.AnimatorFadeInOut(self.ui.mAnimator_Root, isFadeIn)
end
function ActivityTourAvatarStepItem:SetGunData(gunID)
  local gunCmdData = NetCmdTeamData:GetGunByID(gunID)
  self.ui.mImage_Avatar.sprite = IconUtils.GetCharacterHeadSprite(gunCmdData.gunData.Code)
  self:SetShowType(0)
  self:FadeInOut(true)
end
function ActivityTourAvatarStepItem:SetMonsterData(monsterID)
  local enemyData = TableData.listMonopolyEnemyDatas:GetDataById(monsterID)
  if enemyData then
    self.ui.mImage_Avatar.sprite = IconUtils.GetPlayerAvatar(enemyData.chess_icon)
  end
  self:SetShowType(1)
  self:FadeInOut(true)
end
function ActivityTourAvatarStepItem:SetShowType(showType)
  self.ui.mAnimator_Root:SetInteger("Switch", showType)
end
function ActivityTourAvatarStepItem:SetPositionX(X)
  local newPos = self:GetPosition()
  newPos.x = X
  self.mUIRootRectTrans.anchoredPosition = newPos
end
function ActivityTourAvatarStepItem:GetPosition()
  return self.mUIRootRectTrans.anchoredPosition
end
function ActivityTourAvatarStepItem:Show(isShow)
  setactive(self.mUIRoot.gameObject, isShow)
end
