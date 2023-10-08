require("UI.DarkZonePanel.UIDarkZoneNPCSelectPanel.UIDarkZoneNPCSelectPanelView")
require("UI.UIBasePanel")
UIDarkZoneNPCSelectPanel = class("UIDarkZoneNPCSelectPanel", UIBasePanel)
UIDarkZoneNPCSelectPanel.__index = UIDarkZoneNPCSelectPanel
function UIDarkZoneNPCSelectPanel:ctor(csPanel)
  UIDarkZoneNPCSelectPanel.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
end
function UIDarkZoneNPCSelectPanel:OnInit(root, data)
  UIDarkZoneNPCSelectPanel.super.SetRoot(UIDarkZoneNPCSelectPanel, root)
  self:InitBaseData()
  self.redDotList = DZStoreUtils.redDotList
  self.mview:InitCtrl(root, self.ui)
  self:AddBtnListen()
end
function UIDarkZoneNPCSelectPanel:OnShowFinish()
  self.IsPanelOpen = true
  self:UpdateData()
end
function UIDarkZoneNPCSelectPanel:OnHide()
  self.IsPanelOpen = false
end
function UIDarkZoneNPCSelectPanel:OnUpdate(deltatime)
end
function UIDarkZoneNPCSelectPanel:OnClose()
  self.ui = nil
  self.mview = nil
  self.ItemDataList = nil
  self.IsPanelOpen = nil
  self.NpcList = nil
  self.NpcDic = nil
  self.NpcStateDic = nil
  self.EnterTimes = nil
  self.redDotList = nil
  DZStoreUtils.SellItemDataDic = {}
end
function UIDarkZoneNPCSelectPanel:OnRelease()
  self.super.OnRelease(self)
  self.hasCache = false
end
function UIDarkZoneNPCSelectPanel:InitBaseData()
  self.mview = UIDarkZoneNPCSelectPanelView.New()
  self.ui = {}
  self.ItemDataList = {}
  self.IsPanelOpen = false
  self.NpcList = {}
  self.NpcDic = {}
  self.NpcStateDic = {}
  self.EnterTimes = 0
end
function UIDarkZoneNPCSelectPanel:AddBtnListen()
  self:SetBtnByNPCData()
  if self.hasCache ~= true then
    UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
      UIManager.JumpToMainPanel()
    end
    UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
      UIManager.CloseUI(UIDef.UIDarkZoneNPCSelectPanel)
    end
    self.hasCache = true
  end
end
function UIDarkZoneNPCSelectPanel:SetBtnByNPCData()
  local list = {}
  for i = 0, TableData.listDarkzoneNpcDatas.Count - 1 do
    table.insert(list, TableData.listDarkzoneNpcDatas[i])
  end
  table.sort(list, function(a, b)
    if a == nil or b == nil then
      return false
    end
    if a.npc_sort < b.npc_sort then
      return true
    else
      return false
    end
  end)
  self.NpcList = {}
  self.NpcBtnList = {}
  self.NpcBtnDataList = {}
  for i = 1, #list do
    self.NpcDic[list[i].id] = list[i]
    table.insert(self.NpcList, list[i])
    local Data = list[i]
    local trans = self.ui.mTrans_GrpContent:GetChild(i - 1)
    local NpcUi = {}
    local LuaUIBindScript = trans:GetComponent(UIBaseCtrl.LuaBindUi)
    local vars = LuaUIBindScript.BindingNameList
    for i = 0, vars.Count - 1 do
      NpcUi[vars[i]] = LuaUIBindScript:GetBindingComponent(vars[i])
    end
    self.NpcBtnList[i] = NpcUi
    local data = {}
    data.Data = Data
    data.IsNpcUnlock = false
    self.NpcBtnDataList[i] = data
    setactive(NpcUi.mTrans_RedPoint, false)
    NpcUi.mText_Name.text = Data.name.str
    UIUtils.GetButtonListener(NpcUi.mBtn_NPC.gameObject).onClick = function()
      self.redDotList[Data.id] = nil
      UIManager.OpenUIByParam(UIDef.UIDarkZoneStorePanel, self.NpcBtnDataList[i])
    end
  end
end
function UIDarkZoneNPCSelectPanel:UpdateData()
  for i = 1, #self.NpcBtnList do
    local Data = self.NpcBtnDataList[i].Data
    local NpcUi = self.NpcBtnList[i]
    if self.redDotList[Data.id] then
      setactive(NpcUi.mTrans_RedPoint, true)
    end
    self.NpcStateDic = DZStoreUtils:UpdateNpcStateDic(self.NpcList)
    local IsUnlock = self.NpcStateDic[Data.id]
    self.NpcBtnDataList[i].IsNpcUnlock = IsUnlock
    if IsUnlock then
      if self.EnterTimes == 0 then
        setactive(NpcUi.mTrans_GrpLocked, false)
      elseif NpcUi.mTrans_GrpLocked.gameObject.activeSelf == true then
        self:DelayCall(1.2, function()
          NpcUi.mAnim_NPC:SetBool("Unlock", true)
        end)
        self:DelayCall(3.1, function()
          if CS.LuaUtils.IsNullOrDestroyed(NpcUi.mTrans_GrpLocked) == false then
            setactive(NpcUi.mTrans_GrpLocked, false)
          end
        end)
      else
        setactive(NpcUi.mTrans_GrpLocked, false)
      end
      NpcUi.mImg_NPC.color = ColorUtils.StringToColor("FFFFFF")
    else
      NpcUi.mImg_NPC.color = ColorUtils.StringToColor("989898")
      setactive(NpcUi.mTrans_GrpLocked, true)
      if Data.unlock == CS.GF2.Data.DarkzoneNpcUnlockType.Level then
        NpcUi.mText_LockDes.text = string_format(TableData.GetHintById(903139), Data.unlock_parameter_1)
      elseif Data.unlock == CS.GF2.Data.DarkzoneNpcUnlockType.NpcFavor then
        NpcUi.mText_LockDes.text = string_format(TableData.GetHintById(903140), TableData.listDarkzoneNpcDatas:GetDataById(Data.unlock_parameter_1).name.str, Data.unlock_parameter_2)
      end
    end
  end
  self.EnterTimes = self.EnterTimes + 1
end
