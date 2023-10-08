require("UI.UIBaseCtrl")
UIDormChrRecordSelectItem = class("UIDormChrRecordSelectItem", UIBaseCtrl)
UIDormChrRecordSelectItem.__index = UIDormChrRecordSelectItem
function UIDormChrRecordSelectItem:ctor()
end
function UIDormChrRecordSelectItem:InitCtrl(itemPrefab)
  if itemPrefab == nil then
    return
  end
  local instObj = instantiate(itemPrefab.childItem, itemPrefab.transform)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  self.iconList = {}
  UIUtils.AddListItem(instObj.gameObject, itemPrefab.gameObject)
  self:SetRoot(instObj.transform)
  UIUtils.GetButtonListener(self.ui.mBtn_Self.gameObject).onClick = function()
    if self.isUnlock then
      self.clickFunction(self)
    else
      PopupMessageManager.PopupString(self.popupStr)
    end
  end
end
function UIDormChrRecordSelectItem:SetData(id, index)
  self.dailyData = TableData.listCharacterDailyDatas:GetDataById(id)
  self.ui.mText_TitleName.text = self.dailyData.title.str
  self.ui.mText_Num.text = string.format("-", index)
  self:UpdateUnlockType()
  self:SetReadState()
end
function UIDormChrRecordSelectItem:SetClickFunction(func)
  self.clickFunction = func
end
function UIDormChrRecordSelectItem:SetSelectState(isSelect)
  self.isSelect = isSelect
  self.ui.mBtn_Self.interactable = self.isSelect == false
end
function UIDormChrRecordSelectItem:SetReadState()
  self.hasRead = NetCmdLoungeData:CheckLogRewardHasReceive(self.dailyData.id)
  local r = UIUtils.GetKVSortItemTable(self.dailyData.reward)
  local count = #r
  setactive(self.ui.mTrans_GoldConsume, self.hasRead == false and 0 < count)
  setactive(self.ui.mTrans_RedPoint, self.hasRead == false and self.isUnlock == true)
  if self.hasRead == false then
    local index = 1
    if 0 < count then
      local i = r[1].id
      if self.iconList[index] == nil then
        local t = {}
        t.obj = instantiate(self.ui.mTrans_Icon, self.ui.mTrans_GoldConsume)
        t.img = t.obj.transform:Find("Img_Icon"):GetComponent(typeof(CS.UnityEngine.UI.Image))
        self.iconList[index] = t
      end
      local img = self.iconList[index].img
      setactive(self.iconList[index].obj, true)
      img.sprite = IconUtils.GetItemIconSprite(i)
    end
  end
end
function UIDormChrRecordSelectItem:StartPlayBehavior()
  local Data = {}
  Data[2] = self.dailyData
  if self.hasRead == false then
    Data[1] = function()
      self:UpdateUnlockType()
      self:SetReadState()
      if self.dailyData.reward.Key.Count > 0 then
        UIManager.OpenUI(UIDef.UICommonReceivePanel)
      end
    end
    NetCmdLoungeData:SendDormGetCharacterReward(self.dailyData.id, function()
      UIManager.OpenUIByParam(UIDef.UIDormChrRecordDialog, Data)
    end)
  else
    UIManager.OpenUIByParam(UIDef.UIDormChrRecordDialog, Data)
  end
  local gunId = NetCmdLoungeData:GetCurrGunId()
  local info = CS.OssLoungeGunDiary(gunId, self.dailyData.id, not self.hasRead)
  MessageSys:SendMessage(OssEvent.OnPlayGunDiary, nil, info)
end
function UIDormChrRecordSelectItem:UpdateUnlockType()
  self.isUnlock = NetCmdLoungeData:CheckChrDailyHasUnlock(self.dailyData.id)
  if self.isUnlock == false then
    self.unlockData = TableData.listAchievementDetailDatas:GetDataById(self.dailyData.condition, true)
    self.popupStr = "未配置数据(程序写)"
    if self.unlockData then
      self.popupStr = self.unlockData.des.str
    end
  end
  self.ui.mAnimator_Self:SetBool("UnLock", self.isUnlock)
end
function UIDormChrRecordSelectItem:OnRelease()
  for i, v in ipairs(self.iconList) do
    gfdestroy(v.obj)
  end
  self.iconList = nil
  self.super.OnRelease(self, true)
end
