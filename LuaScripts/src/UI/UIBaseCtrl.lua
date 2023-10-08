require("Lib.GFLib")
UIBaseCtrl = class("UIBaseCtrl")
UIBaseCtrl.__index = UIBaseCtrl
UIBaseCtrl.mUIRoot = nil
UIBaseCtrl.mUIAssetsList = nil
UIBaseCtrl.mUITimerList = {}
UIBaseCtrl.mIsPop = false
UIBaseCtrl.LuaBindUi = typeof(CS.XLua.LuaUiBind.LuaBindingNew)
function UIBaseCtrl:ctor()
  self.mUIAssetsList = List:New()
  self.isPlayFadeOut = false
end
function UIBaseCtrl:SetRoot(transform)
  if transform == nil then
    print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!设置了空的Root!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
  end
  self.mUIRoot = transform
  ResourceManager:AddLuaToCheck(self, self.ClearAssets, transform)
  if self.mIsPop then
    local sort = UIManager.GetResourceBarSortOrder()
    self:AddCanvas(sort + 1)
  end
end
function UIBaseCtrl:AddCanvas(sort)
  UIUtils.AddCanvas(self.mUIRoot.gameObject, sort)
end
function UIBaseCtrl:InstanceUIPrefab(path, parent, isFullScreen)
  isFullScreen = isFullScreen == true and true or false
  local asset = UIUtils.GetGizmosPrefab(path)
  if asset then
    local obj = instantiate(asset)
    string.gsub(obj.name, "%(Clone%)", "_" .. string.sub(obj.name, -1))
    if parent then
      CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, isFullScreen)
    end
    self:AddAsset(asset)
    return obj
  else
    return nil
  end
end
function UIBaseCtrl:LuaUIBindTable(target, UITable)
  if UITable == nil then
    gfdebug("table表为空")
    return
  end
  local LuaUIBindScript = target.gameObject:GetComponent(self.LuaBindUi)
  if LuaUIBindScript == nil then
    return
  end
  local vars = LuaUIBindScript.BindingNameList
  UITable.mUIRoot = target
  for i = 0, vars.Count - 1 do
    UITable[vars[i]] = LuaUIBindScript:GetBindingComponent(vars[i])
  end
end
function UIBaseCtrl:AddAsset(asset)
  if self.mUIAssetsList == nil then
    self.mUIAssetsList = List:New()
  end
  self.mUIAssetsList:Add(asset)
end
function UIBaseCtrl.ClearAssets(luaScript)
  if luaScript.mUIAssetsList ~= nil then
    for i = 1, #luaScript.mUIAssetsList do
      ResourceManager:UnloadAssetFromLua(luaScript.mUIAssetsList[i])
    end
    luaScript.mUIAssetsList:Clear()
  end
  luaScript.mUIAssetsList = nil
end
function UIBaseCtrl:Instantiate(relativePath, parent)
  local go = ResSys:InstantiateUIRes(relativePath, parent, false)
  if not go then
    gferror("实例化失败!" .. relativePath)
    return nil
  end
  if self.cacheGoTable == nil then
    self.cacheGoTable = {}
  end
  table.insert(self.cacheGoTable, go)
  return go
end
function UIBaseCtrl:CacheLoadedAsset(asset)
  if self.cacheAssetTable == nil then
    self.cacheAssetTable = {}
  end
  table.insert(self.cacheAssetTable, asset)
end
function UIBaseCtrl:ReleaseCtrlTable(ctrlTable, isDestroy)
  if type(ctrlTable) ~= "table" then
    return
  end
  for i = #ctrlTable, 1, -1 do
    ctrlTable[i]:OnRelease(isDestroy)
    table.remove(ctrlTable, i)
  end
  if ctrlTable[0] then
    ctrlTable[0]:OnRelease(isDestroy)
    table.remove(ctrlTable, 0)
  end
end
function UIBaseCtrl:OnRelease(isDestroy)
  if self.cacheGoTable then
    for i = #self.cacheGoTable, 1, -1 do
      ResourceManager:DestroyInstance(self.cacheGoTable[i])
    end
    self.cacheGoTable = nil
  end
  if self.cacheAssetTable then
    for i = #self.cacheAssetTable, 1, -1 do
      ResourceManager:UnloadAssetFromLua(self.cacheAssetTable[i])
    end
    self.cacheAssetTable = nil
  end
  if not LuaUtils.IsNullOrDestroyed(self.mUIRoot) and isDestroy then
    gfdestroy(self.mUIRoot.gameObject)
  end
  self.mUIRoot = nil
end
function UIBaseCtrl:GetRoot()
  return self.mUIRoot
end
function UIBaseCtrl:SetPosZ(zPos)
  local pos = self.mUIRoot.localPosition
  local z = math.min(zPos, pos.z)
  pos.z = z
  self.mUIRoot.localPosition = pos
  UIUtils.AddSubCanvas(self.mUIRoot.gameObject, -1 * zPos, true)
end
function UIBaseCtrl:DelayCall(duration, callback, userData, repeatCount)
  if repeatCount == nil then
    repeatCount = 1
  end
  local timer = TimerSys:DelayCall(duration, function()
    if callback then
      callback()
    end
  end, userData, repeatCount)
  table.insert(self.mUITimerList, timer)
  return timer
end
function UIBaseCtrl:ReleaseTimers()
  for _, timer in ipairs(self.mUITimerList) do
    if timer then
      timer:Stop()
    end
  end
  self.mUITimerList = {}
end
function UIBaseCtrl:DestroySelf()
  if self.mUIRoot ~= nil then
    gfdestroy(self.mUIRoot)
    self.mUIRoot = nil
  end
end
function UIBaseCtrl:ReleaseSelf()
  if self.mUIRoot ~= nil then
    ResourceManager:DestroyInstance(self.mUIRoot.gameObject)
    self.mUIRoot = nil
  end
end
function UIBaseCtrl:SetActive(enable)
  if self.mUIRoot ~= nil then
    setactivewithcheck(self.mUIRoot, enable)
  end
end
function UIBaseCtrl:SetVisible(visible)
  self:SetActive(visible)
end
function UIBaseCtrl:FindChild(path)
  if path == "" then
    return
  end
  return self.mUIRoot:Find(path)
end
function UIBaseCtrl:GetComponent(ctype)
  return CS.LuaUtils:GetComponent(self.mUIRoot, ctype.GetClassType())
end
function UIBaseCtrl:GetComponent(path, ctype)
  local child = self:FindChild(path)
  if child == nil then
    return
  end
  return CS.LuaUtils.GetComponent(child, ctype)
end
function UIBaseCtrl:GetSelfButton()
  return CS.LuaUIUtils.GetButton(self.mUIRoot)
end
function UIBaseCtrl:GetButton(path)
  local child = self:FindChild(path)
  if child == nil then
    return
  end
  return CS.LuaUIUtils.GetButton(child)
end
function UIBaseCtrl:GetSelfImage()
  return CS.LuaUIUtils.GetImage(self.mUIRoot)
end
function UIBaseCtrl:GetImage(path)
  local child = self:FindChild(path)
  if child == nil then
    return
  end
  return CS.LuaUIUtils.GetImage(child)
end
function UIBaseCtrl:GetSelfRawImage()
  return CS.LuaUIUtils.GetRawImage(self.mUIRoot)
end
function UIBaseCtrl:GetRawImage(path)
  local child = self:FindChild(path)
  if child == nil then
    return
  end
  return CS.LuaUIUtils.GetRawImage(child)
end
function UIBaseCtrl:GetSelfText()
  return CS.LuaUIUtils.GetText(self.mUIRoot)
end
function UIBaseCtrl:GetText(path)
  local child = self:FindChild(path)
  if child == nil then
    return
  end
  return CS.LuaUIUtils.GetText(child)
end
function UIBaseCtrl:GetSelfRectTransform()
  return CS.LuaUIUtils.GetRectTransform(self.mUIRoot)
end
function UIBaseCtrl:GetRectTransform(path)
  local child = self:FindChild(path)
  if child == nil then
    return
  end
  return CS.LuaUIUtils.GetRectTransform(child)
end
function UIBaseCtrl:GetSelfGridLayoutGroup()
  return CS.LuaUIUtils:GetGridLayoutGroup(self.mUIRoot)
end
function UIBaseCtrl:GetGridLayoutGroup(path)
  local child = self:FindChild(path)
  if child == nil then
    return
  end
  return CS.LuaUIUtils.GetGridLayoutGroup(child)
end
function UIBaseCtrl:GetVerticalLayoutGroup()
  return CS.LuaUIUtils.GetVerticalLayoutGroup(self.mUIRoot)
end
function UIBaseCtrl:GetVerticalLayoutGroup(path)
  local child = self:FindChild(path)
  if child == nil then
    return
  end
  return CS.LuaUIUtils.GetVerticalLayoutGroup(child)
end
function UIBaseCtrl:GetHorizontalLayoutGroup()
  return CS.LuaUIUtils:GetHorizontalLayoutGroup(self.mUIRoot)
end
function UIBaseCtrl:GetHorizontalLayoutGroup(path)
  local child = self:FindChild(path)
  if child == nil then
    return
  end
  return CS.LuaUIUtils.GetHorizontalLayoutGroup(child)
end
function UIBaseCtrl:GetCanvasGroup()
  return CS.LuaUIUtils:GetCanvasGroup(self.mUIRoot)
end
function UIBaseCtrl:GetCanvasGroup(path)
  local child = self:FindChild(path)
  if child == nil then
    return
  end
  return CS.LuaUIUtils.GetCanvasGroup(child)
end
function UIBaseCtrl:GetSelfCanvas()
  return CS.LuaUIUtils.GetCanvas(self.mUIRoot)
end
function UIBaseCtrl:GetToggle()
  return CS.LuaUIUtils:GetToggle(self.mUIRoot)
end
function UIBaseCtrl:GetGFToggle(path)
  local child = self:FindChild(path)
  if child == nil then
    return
  end
  return CS.LuaUIUtils.GetGFToggle(child)
end
function UIBaseCtrl:GetToggle(path)
  local child = self:FindChild(path)
  if child == nil then
    return
  end
  return CS.LuaUIUtils.GetToggle(child)
end
function UIBaseCtrl:GetScrollCircle()
  return CS.LuaUIUtils:GetScrollCircle(self.mUIRoot)
end
function UIBaseCtrl:GetScrollCircle(path)
  local child = self:FindChild(path)
  if child == nil then
    return
  end
  return CS.LuaUIUtils.GetScrollCircle(child)
end
function UIBaseCtrl:GetSlider()
  return CS.LuaUIUtils:GetSlider(self.mUIRoot)
end
function UIBaseCtrl:GetSlider(path)
  local child = self:FindChild(path)
  if child == nil then
    return
  end
  return CS.LuaUIUtils.GetSlider(child)
end
function UIBaseCtrl:GetScrollbar()
  return CS.LuaUIUtils:GetScrollbar(self.mUIRoot)
end
function UIBaseCtrl:GetScrollbar(path)
  local child = self:FindChild(path)
  if child == nil then
    return
  end
  return CS.LuaUIUtils.GetScrollbar(child)
end
function UIBaseCtrl:GetInputField()
  return CS.LuaUIUtils:GetInputField(self.mUIRoot)
end
function UIBaseCtrl:GetInputField(path)
  local child = self:FindChild(path)
  if child == nil then
    return
  end
  return CS.LuaUIUtils.GetInputField(child)
end
function UIBaseCtrl:GetScrollRect()
  return CS.LuaUIUtils:GetScrollRect(self.mUIRoot)
end
function UIBaseCtrl:GetScrollRect(path)
  local child = self:FindChild(path)
  if child == nil then
    return
  end
  return CS.LuaUIUtils.GetScrollRect(child)
end
function UIBaseCtrl:GetUniWebView()
  return CS.LuaUIUtils:UniWebView(self.mUIRoot)
end
function UIBaseCtrl:GetUniWebView(path)
  local child = self:FindChild(path)
  if child == nil then
    return
  end
  return CS.LuaUIUtils.GetUniWebView(child)
end
function UIBaseCtrl:GetCamera()
  return CS.LuaUIUtils:GetCamera(self.mUIRoot)
end
function UIBaseCtrl:GetCamera(path)
  local child = self:FindChild(path)
  if child == nil then
    return
  end
  return CS.LuaUIUtils.GetCamera(child)
end
function UIBaseCtrl:GetSelfAnimator()
  return CS.LuaUIUtils.GetAnimator(self.mUIRoot)
end
function UIBaseCtrl:GetRootAnimator()
  return self:GetAnimator("Root")
end
function UIBaseCtrl:GetAnimator(path)
  local child = self:FindChild(path)
  if child == nil then
    return
  end
  return CS.LuaUIUtils.GetAnimator(child)
end
function UIBaseCtrl:GetContentSizeFitter()
  return CS.LuaUIUtils:GetContentSizeFitter(self.mUIRoot)
end
function UIBaseCtrl:GetContentSizeFitter(path)
  local child = self:FindChild(path)
  if child == nil then
    return
  end
  return CS.LuaUIUtils.GetContentSizeFitter(child)
end
function UIBaseCtrl:GetDropDown()
  return CS.LuaUIUtils:GetDropdown(self.mUIRoot)
end
function UIBaseCtrl:GetDropDown(path)
  local child = self:FindChild(path)
  if child == nil then
    return
  end
  return CS.LuaUIUtils.GetDropdown(child)
end
function UIBaseCtrl:GetVirtualListEx(path)
  local child = self:FindChild(path)
  if child == nil then
    return
  end
  return CS.LuaUIUtils.GetVirtualListEx(child)
end
function UIBaseCtrl:PlayAniWithCallback(callback)
  if self.isPlayFadeOut then
    return
  end
  local root = self:GetRectTransform("Root")
  if root then
    local animator = getcomponent(root, typeof(CS.UnityEngine.Animator))
    local timeData = getcomponent(root, typeof(CS.AniTime))
    if animator then
      if timeData == nil then
        if callback then
          callback()
        end
      else
        if timeData.m_FadeOutTime > 0 then
          TimerSys:DelayCall(timeData.m_FadeOutTime, function()
            self.isPlayFadeOut = false
            if callback then
              callback()
            end
          end)
        elseif callback then
          callback()
        end
        local param = animator.parameters
        for i = 0, param.Length - 1 do
          local aniName = string.lower(param[i].name)
          if aniName ~= nil and string.match(aniName, "fadeout") ~= nil then
            animator:SetTrigger(param[i].name)
            self.isPlayFadeOut = true
          end
        end
      end
    elseif callback then
      callback()
    end
  end
end
