require("UI.UIBaseCtrl")
require("UI.QuicklyBuyPanelItem.UIQuicklyBuyPanelItemView")
UICommonGetWayItem = class("UICommonGetWayItem", UIBaseCtrl)
UICommonGetWayItem.__index = UICommonGetWayItem
UICommonGetWayItem.mBtn_Jump = nil
UICommonGetWayItem.mText_Title = nil
UICommonGetWayItem.mText_Way = nil
UICommonGetWayItem.mTrans_Disable = nil
function UICommonGetWayItem:__InitCtrl()
  self.mBtn_Jump = self:GetButton("Btn_Jump")
  self.mText_Title = self:GetText("GetWayname/Text_Title")
  self.mText_Way = self:GetText("GetWayname/Text_Way")
  self.mTrans_Disable = self:GetRectTransform("Trans_Disable")
  UIUtils.GetButtonListener(self.mBtn_Jump.gameObject).onClick = function(gameObj)
    self:onClickJump()
  end
end
UICommonGetWayItem.mData = nil
UICommonGetWayItem.howToGetData = nil
UICommonGetWayItem.goodId = 0
UICommonGetWayItem.root = nil
function UICommonGetWayItem:InitCtrlNoPara()
  local itemPrefab = UIUtils.GetGizmosPrefab("UICommonFramework/UICommonGetWayItem.prefab", self)
  local instObj = instantiate(itemPrefab)
  self:SetRoot(instObj.transform)
  self:__InitCtrl()
end
function UICommonGetWayItem:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/UICommonGetWayItem.prefab", self))
  setparent(parent, obj.transform)
  obj.transform.localScale = vectorone
  obj.transform.localPosition = vectorone
  self:SetRoot(obj.transform)
  self:__InitCtrl()
end
function UICommonGetWayItem:SetData(data)
  if data then
    self.mData = data
    self.howToGetData = data.howToGetData
    self.goodId = data.itemData.goodsid
    self.root = data.root.mParent
    self.callback = data.root.callback
    self.parent = data.root
    self.mText_Title.text = data.title
    self.mText_Way.text = data.getList.title.str
    setactive(self.mBtn_Jump.gameObject, self:CheckIsUnLock())
    setactive(self.mTrans_Disable, not self:CheckIsUnLock())
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
function UICommonGetWayItem:CheckIsUnLock()
  local jumpData = string.split(self.howToGetData.jump_code, ":")
  if tonumber(jumpData[1]) == 1 then
    return NetCmdDungeonData:IsUnLockChapter(jumpData[2])
  elseif tonumber(jumpData[1]) == 14 then
    local chapterId = TableData.listStoryDatas:GetDataById(tonumber(jumpData[2])).chapter
    if NetCmdDungeonData:IsUnLockChapter(chapterId) then
      return NetCmdDungeonData:IsUnLockStory(jumpData[2])
    end
    return false
  end
  return true
end
function UICommonGetWayItem:onClickJump()
  if not (self.howToGetData and self.howToGetData.can_jump) or self.howToGetData.jump_code == nil then
    return
  end
  local jump = string.split(self.howToGetData.jump_code, ":")
  if (tonumber(jump[1]) == 5 or tonumber(jump[1]) == 19) and self.howToGetData.quickly_buy == 1 then
    local good = NetCmdStoreData:GetStoreGoodById(self.goodId)
    if good then
      UIQuicklyBuyPanelItemView.OpenConfirmPanel(good, self.root.transform, 1, self.mData.itemData.id, function()
        MessageSys:SendMessage(5002, nil)
        if self.callback then
          self.callback()
        end
        if self.parent then
          self.parent:UpdatePanel()
        end
      end, function()
        SceneSwitch:SwitchByID(tonumber(jump[1]))
        UITipsPanel.OnCloseClick()
      end)
      return
    end
  end
  MessageSys:SendMessage(CS.GF2.Message.UIEvent.MergeEquipJump, nil)
  SceneSwitch:SwitchByID(tonumber(jump[1]))
  UITipsPanel.OnCloseClick()
end
