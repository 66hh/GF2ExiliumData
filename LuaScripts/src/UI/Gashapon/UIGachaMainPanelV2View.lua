require("UI.UIBaseView")
UIGachaMainPanelV2View = class("UIGachaMainPanelV2View", UIBaseView)
UIGachaMainPanelV2View.__index = UIGachaMainPanelV2View
function UIGachaMainPanelV2View:__InitCtrl()
  if CS.GameRoot.Instance then
  end
end
function UIGachaMainPanelV2View:InitCtrl(root, ui)
  self:SetRoot(root)
  self:__InitCtrl()
  local dutyObj1 = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComDutyItemV2.prefab", self), ui.mTrans_IconDuty1)
  ui.mImg_DutyIcon1 = UIUtils.GetImage(dutyObj1, "Img_DutyIcon")
  local dutyObj2 = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComDutyItemV2.prefab", self), ui.mTrans_IconDuty2)
  ui.mImg_DutyIcon2 = UIUtils.GetImage(dutyObj2, "Img_DutyIcon")
  local elementObj1 = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComElementItemV2.prefab", self), ui.mTrans_IconElement1)
  ui.mImg_ElementIcon1 = UIUtils.GetImage(elementObj1, "Image_ElementIcon")
  local elementObj2 = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComElementItemV2.prefab", self), ui.mTrans_IconElement2)
  ui.mImg_ElementIcon2 = UIUtils.GetImage(elementObj2, "Image_ElementIcon")
end
