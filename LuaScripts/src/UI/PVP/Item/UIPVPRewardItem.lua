require("UI.UIBaseCtrl")
UIPVPRewardItem = class("UIPVPRewardItem", UIBaseCtrl)
UIPVPRewardItem.__index = UIPVPRewardItem
function UIPVPRewardItem:ctor()
end
function UIPVPRewardItem:InitCtrl(parent, data)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  local tmpReward = UIUtils.GetKVSortItemTable(data.reward_list)
  for i = 1, #tmpReward do
    local itemview = UICommonItem.New()
    itemview:InitCtrl(self.ui.transItemList)
    itemview:SetItemData(tmpReward[i].id, tmpReward[i].num)
  end
  self.ui.txtNum.text = data.value
  setactive(self.ui.transReceive, UIPVPGlobal.CurRewardState[data.id] == UIPVPGlobal.RewardType.Receive)
  setactive(self.ui.transFinish, UIPVPGlobal.CurRewardState[data.id] == UIPVPGlobal.RewardType.Finish)
  setactive(self.ui.transUnFinish, UIPVPGlobal.CurRewardState[data.id] == UIPVPGlobal.RewardType.UnFinish)
end
function UIPVPRewardItem:OnRelease()
  gfdestroy(self.mUIRoot)
end
