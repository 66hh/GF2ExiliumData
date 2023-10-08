require("UI.UIBaseView")
AttackBenefitInfoItemView = class("AttackBenefitInfoItemView", UIBaseView)
AttackBenefitInfoItemView.__index = AttackBenefitInfoItemView
function AttackBenefitInfoItemView:__InitCtrl()
end
function AttackBenefitInfoItemView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
