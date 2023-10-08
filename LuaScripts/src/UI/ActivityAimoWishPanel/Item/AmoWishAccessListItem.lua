require("UI.UIBaseCtrl")
AmoWishAccessListItem = class("AmoWishAccessListItem", UIBaseCtrl)
AmoWishAccessListItem.__index = AmoWishAccessListItem
function AmoWishAccessListItem:__InitCtrl()
end
function AmoWishAccessListItem:InitCtrl(parent)
  self.obj = instantiate(UIUtils.GetGizmosPrefab("Activity/AmoWish/Btn_AmoWishAccessListItem.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(self.obj.gameObject, parent.gameObject, false)
  end
  self.ui = {}
  self:LuaUIBindTable(self.obj, self.ui)
  self:SetRoot(self.obj.transform)
  self:__InitCtrl()
  UIUtils.GetButtonListener(self.ui.mBtn_Root.transform).onClick = function()
    local compeletState = NetCmdActivityAmoData:GetRewardIsCompeletStateByID(self.mTaskId)
    if compeletState == 0 then
      SceneSwitch:SwitchByID(tonumber(self.mAmoActivityData.link))
    end
  end
end
function AmoWishAccessListItem:SetData(taskId)
  self.mTaskId = taskId
  self.mAmoActivityData = TableData.listAmoActivityDatas:GetDataById(taskId)
  if self.mAmoActivityData == nil then
    return
  end
  self.ui.mText_Name.text = self.mAmoActivityData.des
  local compeletState = NetCmdActivityAmoData:GetRewardIsCompeletStateByID(taskId)
  self.ui.mAni_Root:SetBool("Complete", compeletState ~= 0)
  local amoActivityDatas = TableData.listAmoActivityDatas:GetDataById(taskId)
  if amoActivityDatas ~= nil then
    local taskCount = NetCmdActivityAmoData:GetCounter(taskId)
    taskCount = math.floor(math.min(NetCmdActivityAmoData:GetCounter(taskId), amoActivityDatas.condition_num))
    self.ui.mText_Num.text = taskCount .. "/" .. amoActivityDatas.condition_num
  end
end
function AmoWishAccessListItem:SetInteractable(interactable)
end
function AmoWishAccessListItem:OnRelease()
  self.super.OnRelease(self, true)
end
function AmoWishAccessListItem:UpdateRedPoint(show)
end
