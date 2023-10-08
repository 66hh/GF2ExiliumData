require("UI.UIBaseCtrl")
ArchivesCenterAchievementItemV2 = class("ArchivesCenterAchievementItemV2", UIBaseCtrl)
ArchivesCenterAchievementItemV2.__index = ArchivesCenterAchievementItemV2
function ArchivesCenterAchievementItemV2:ctor()
end
function ArchivesCenterAchievementItemV2:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  self.itemUIList = {}
end
function ArchivesCenterAchievementItemV2:SetData(data)
  if data ~= nil then
    setactive(self.ui.mUIRoot, true)
    self.ui.mText_Tittle.text = data.Name
    self.ui.mText_Content.text = data.Desp
    setactive(self.ui.mTrans_NotFinished.gameObject, false)
    setactive(self.ui.mBtn_BtnGoOn.gameObject, false)
    setactive(self.ui.mTrans_RedPoint.gameObject, false)
    setactive(self.ui.mBtn_BtnReceive.gameObject, false)
    setactive(self.ui.mTrans_Finished.gameObject, false)
    for i = 0, data.RewardList.Count - 1 do
      local itemview
      if i < #self.itemUIList then
        self.itemUIList[i + 1]:SetItemData(data.RewardList[i].itemid, data.RewardList[i].num)
      else
        itemview = UICommonItem.New()
        itemview:InitCtrl(self.ui.mTrans_Item)
        itemview:SetItemData(data.RewardList[i].itemid, data.RewardList[i].num)
        itemview.mUIRoot:SetAsLastSibling()
        table.insert(self.itemUIList, itemview)
      end
      local stcData = TableData.GetItemData(data.RewardList[i].itemid)
      TipsManager.Add(self.itemUIList[i + 1].mUIRoot, stcData)
    end
    local isCompleted = data.IsCompleted
    local isReceived = data.IsReceived
    if isCompleted then
      if isReceived then
        self.ui.mImg_ProgressBar.fillAmount = 1
        self.ui.mText_Num.text = "<color=#384B52>" .. data.ConditionNum .. "/" .. data.ConditionNum .. "</color>"
        setactive(self.ui.mTrans_Finished.gameObject, true)
      else
        self.ui.mImg_ProgressBar.fillAmount = 1
        self.ui.mText_Num.text = "<color=#f26c1c>" .. data.ConditionNum .. "/" .. data.ConditionNum .. "</color>"
        setactive(self.ui.mBtn_BtnReceive.gameObject, true)
      end
    else
      self.ui.mImg_ProgressBar.fillAmount = data.Counter / data.ConditionNum
      self.ui.mText_Num.text = "<color=#384B52>" .. math.floor(data.Counter) .. "/" .. data.ConditionNum .. "</color>"
      setactive(self.ui.mTrans_NotFinished.gameObject, data.jumpID == 0)
      setactive(self.ui.mBtn_BtnGoOn.gameObject, 0 < data.jumpID)
    end
  else
    setactive(self.ui.mUIRoot, false)
  end
end
