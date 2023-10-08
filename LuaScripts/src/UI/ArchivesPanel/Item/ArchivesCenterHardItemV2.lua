require("UI.UIBaseCtrl")
ArchivesCenterHardItemV2 = class("ArchivesCenterHardItemV2", UIBaseCtrl)
ArchivesCenterHardItemV2.__index = ArchivesCenterHardItemV2
function ArchivesCenterHardItemV2:ctor()
end
function ArchivesCenterHardItemV2:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  UIUtils.GetButtonListener(self.ui.mBtn_Root.gameObject).onClick = function()
    UIManager.OpenUIByParam(UIDef.ArchivesCenterRecordPanelV2, {
      2,
      self.data
    })
  end
  function self.PointEnterFun()
    self.ui.mAnimator_Root:SetBool("CD_Rotation", true)
    self.inCDTime = CGameTime:GetXTTimeSpan()
  end
  self.ui.mBtn_Root.PointEnterEvent:AddListener(self.PointEnterFun)
  function self.PointExitFun()
    local cdTimeCount = CGameTime:GetXTTimeSpan() - self.inCDTime
    local timeCount = 2000 - cdTimeCount % 2000
    self.mTimer = TimerSys:DelayCall(timeCount / 1000, function()
      self.ui.mAnimator_Root:SetBool("CD_Rotation_Stop", true)
    end)
  end
  self.ui.mBtn_Root.PointExitEvent:AddListener(self.PointExitFun)
end
function ArchivesCenterHardItemV2:SetData(data, index)
  self.data = data
  self.inCDTime = CGameTime:GetXTTimeSpan()
  self.ui.mText_TopNum.text = data.code.str
  self.ui.mText_MidNum.text = data.code.str
  self.ui.mText_Name.text = data.name.str
  self.ui.mImg_Bg.sprite = IconUtils.GetArchivesIcon(data.icon)
  setactive(self.ui.mTrans_RedPoint, false)
  local currPlotCount = NetCmdArchivesData:GetPlotCurrCount(data.id)
  local maxPlotCount = NetCmdArchivesData:GetPlotGroupCount(data.id)
  self.ui.mText_Num.text = "<color=#f0af14>" .. currPlotCount .. "</color>/" .. maxPlotCount
  if currPlotCount >= maxPlotCount then
    setactive(self.ui.mTrans_Lock, false)
    setactive(self.ui.mTrans_Center, true)
  else
    setactive(self.ui.mTrans_Lock, true)
    setactive(self.ui.mTrans_Center, false)
  end
  local itemData = TableDataBase.listItemDatas:GetDataById(data.item_id)
  if itemData then
    self.ui.mImg_Icon.sprite = IconUtils.GetItemIconSprite(itemData.id)
  end
end
function ArchivesCenterHardItemV2:OnRelease()
  self.ui.mBtn_Root.PointEnterEvent:RemoveListener(self.PointEnterFun)
  self.ui.mBtn_Root.PointExitEvent:RemoveListener(self.PointExitFun)
  if self.mTimer ~= nil then
    self.mTimer:Stop()
    self.mTimer = nil
  end
end
