require("UI.UIBaseCtrl")
UIRepositoryLeftTab2ItemV3 = class("UIRepositoryLeftTab2ItemV3", UIBaseCtrl)
UIRepositoryLeftTab2ItemV3.__index = UIRepositoryLeftTab2ItemV3
function UIRepositoryLeftTab2ItemV3:__InitCtrl()
end
function UIRepositoryLeftTab2ItemV3:InitCtrl(parent)
  local prefab = UIUtils.GetGizmosPrefab("UICommonFramework/ComTabBtn1ItemV2_B.prefab", self)
  self.obj = instantiate(prefab, parent)
  CS.LuaUIUtils.SetParent(self.obj.gameObject, parent.gameObject)
  self:SetRoot(self.obj.transform)
  self:__InitCtrl()
  self.ui = {}
  self:LuaUIBindTable(self.obj, self.ui)
  self.mIsLock = false
  UIUtils.GetButtonListener(self.ui.mBtn_ComTab1ItemV2.gameObject).onClick = function()
    if self.mCallBack ~= nil then
      self.mCallBack(self)
    end
  end
end
function UIRepositoryLeftTab2ItemV3:SetCallBack(callBack)
  self.mCallBack = callBack
end
function UIRepositoryLeftTab2ItemV3:SetName(id, name)
  self.tagId = id
  self.ui.mText_Name.text = name
end
function UIRepositoryLeftTab2ItemV3:SetLock(isLock)
  setactive(self.ui.mTrans_Lock, isLock)
end
function UIRepositoryLeftTab2ItemV3:SetItemState(isChoose)
  UIUtils.SetInteractive(self.ui.mBtn_ComTab1ItemV2.transform, not isChoose)
end
function UIRepositoryLeftTab2ItemV3:GetGlobalTab()
  return self.globalTab
end
function UIRepositoryLeftTab2ItemV3:SetGlobalTabId(globalTabId)
  self.globalTab = GetOrAddComponent(self:GetRoot().gameObject, (typeof(GlobalTab)))
  self.globalTab:SetGlobalTabId(globalTabId)
end
