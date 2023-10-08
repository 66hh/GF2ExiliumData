require("UI.UIBaseCtrl")
UIComAccessItem = class("UIComAccessItem", UIBaseCtrl)
UIComAccessItem.__index = UIComAccessItem
function UIComAccessItem:__InitCtrl()
  self.mTrans_Goto = self:FindChild("GrpAction")
  self.mTrans_Open = self:FindChild("GrpAction/GrpOpen")
  self.mTrans_Lock = self:FindChild("GrpAction/GrpLocked")
  self.mTrans_Close = self:FindChild("GrpAction/GrpClose")
  self.mText_AccessName = self:GetText("GrpTextName/Text_AccessName")
  UIUtils.GetButtonListener(self.mUIRoot.gameObject).onClick = function(gameObj)
    self:onClickJump()
  end
end
function UIComAccessItem:InitCtrl(root)
  local obj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComAccessListItemV2.prefab", self))
  self:SetRoot(obj.transform)
  obj.transform:SetParent(root, false)
  obj.transform.localScale = vectorone
  self:__InitCtrl()
end
function UIComAccessItem:SetData(data, cannotJumpOut)
  self.mData = data
  self.howToGetData = data.howToGetData
  self.goodId = data.itemData.goodsid
  self.root = data.root.mParent
  self.callback = data.root.callback
  self.parent = data.root
  self.type = data.type
  self.cannotJumpOut = cannotJumpOut == true
  self.mText_AccessName.text = data.title
  local f = function()
    self:SetData(data)
  end
  if self.howToGetData then
    self.canClickJumpBtn = UIUtils.CheckIsUnLock(tonumber(self.howToGetData.jump_code), f)
  end
  if self.type == 99 then
    setactive(self.mTrans_Goto, true)
    setactive(self.mTrans_Close, false)
    setactive(self.mTrans_Lock, false)
    setactive(self.mTrans_Open, true)
  elseif not self.howToGetData or not self.howToGetData.can_jump then
    setactive(self.mTrans_Goto, false)
    setactive(self.mTrans_Open, false)
  else
    setactive(self.mTrans_Goto, true)
    if self.howToGetData.jump_code == nil or self.canClickJumpBtn ~= 0 then
      setactive(self.mTrans_Lock, self.canClickJumpBtn ~= -1)
      setactive(self.mTrans_Open, false)
      setactive(self.mTrans_Close, self.canClickJumpBtn == -1)
    else
      setactive(self.mTrans_Close, false)
      setactive(self.mTrans_Lock, false)
      setactive(self.mTrans_Open, true)
    end
  end
end
function UIComAccessItem:onClickJump()
  if self.type == 99 then
    local data = {}
    data.itemData = self.mData.itemData
    UIManager.OpenUIByParam(UIDef.UIRepositoryComposeDialog, data)
    return
  end
  if not (self.howToGetData and self.howToGetData.can_jump) or self.howToGetData.jump_code == nil then
    return
  end
  if self.cannotJumpOut then
    CS.PopupMessageManager.PopupString(TableData.GetHintById(903334))
    return
  end
  if self.canClickJumpBtn ~= 0 then
    local jumpData = TableData.listJumpListContentnewDatas:GetDataById(tonumber(self.howToGetData.jump_code))
    local str = ""
    if self.canClickJumpBtn == -1 then
      str = string_format(TableData.GetHintById(jumpData.plan_open_hint), TableData.GetHintById(103054))
    elseif self.canClickJumpBtn > 0 then
      local unlockData = TableData.listUnlockDatas:GetDataById(self.canClickJumpBtn)
      str = UIUtils.CheckUnlockPopupStr(unlockData)
    elseif self.canClickJumpBtn == -2 then
      str = TableData.GetHintById(103070)
    end
    CS.PopupMessageManager.PopupString(str)
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
