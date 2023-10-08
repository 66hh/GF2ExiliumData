UIStageLineItem = class("UIStageLineItem", UIBaseCtrl)
UIStageLineItem.__index = UIStageLineItem
function UIStageLineItem:__InitCtrl()
end
function UIStageLineItem:InitCtrl(parent, bezierCurvePrefabPath)
  bezierCurvePrefabPath = bezierCurvePrefabPath and bezierCurvePrefabPath or "story/BezierCurve.prefab"
  local instObj = instantiate(UIUtils.GetGizmosPrefab(bezierCurvePrefabPath, self))
  CS.LuaUIUtils.SetParent(instObj.gameObject, parent.gameObject)
  self:SetRoot(instObj.transform)
  self.mUIRoot.transform:SetSiblingIndex(0)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self:__InitCtrl()
end
function UIStageLineItem:SetParent(parent)
  self.parent = parent
  CS.LuaUIUtils.SetParent(self.mUIRoot.gameObject, parent.gameObject, false)
  self.mUIRoot.transform:SetSiblingIndex(0)
end
function UIStageLineItem:SetCurveValue(num)
  self.ui.mImage_Line.material:SetFloat("_Curve", num)
end
function UIStageLineItem:EnableLine(enable)
  setactivewithcheck(self.ui.mUIRoot.gameObject, true)
  if self.ui.mCanvasGroup then
    if enable then
      self.ui.mCanvasGroup.alpha = 1
    else
      self.ui.mCanvasGroup.alpha = 0
    end
  end
end
function UIStageLineItem:SetLinePos(startPos, endPos, isComplete)
  local temEnd = Vector3(startPos.x, endPos.y, startPos.z)
  if math.abs(endPos.y - startPos.y) > 4 then
    self.ui.mTrans_Line.sizeDelta = Vector2(math.abs(endPos.x - startPos.x), math.abs(endPos.y - startPos.y))
    self.ui.mTrans_Line.anchoredPosition = Vector2(endPos.x - startPos.x >= 0 and 0 or endPos.x - startPos.x, (endPos.y - startPos.y) / 2)
    if endPos.y - startPos.y > 0 and endPos.x - startPos.x > 0 then
      self.ui.mImage_Line.material:EnableKeyword("FLIP")
      self.ui.mImage_Line.material:EnableKeyword("BEZIERCURVE")
    else
      self.ui.mImage_Line.material:DisableKeyword("FLIP")
      self.ui.mImage_Line.material:EnableKeyword("BEZIERCURVE")
    end
  elseif math.abs(endPos.y - startPos.y) < 0.1 then
    self.ui.mTrans_Line.sizeDelta = Vector2(math.abs(endPos.x - startPos.x), 0.01)
    self.ui.mTrans_Line.anchoredPosition = Vector2(0, 0)
    self.ui.mImage_Line.material:DisableKeyword("BEZIERCURVE")
  end
end
function UIStageLineItem:SetNoBezierCurveLinePos(startNode, endNode, lineRoot, lineWidth)
  local startPos = lineRoot:InverseTransformPoint(startNode.transform.position)
  startPos.z = 0
  local endPos = lineRoot:InverseTransformPoint(endNode.transform.position)
  endPos.z = 0
  self.ui.mTrans_Line.sizeDelta = Vector2(Vector3.Distance(startPos, endPos), 3)
  self.ui.mTrans_Line.localPosition = startPos
  if math.abs(startPos.y - endPos.y) > 4 then
    local angel = CS.MathClient.PointToAngle(Vector2(startPos.x, startPos.y), Vector2(endPos.x, endPos.y))
    self.ui.mTrans_Line.localRotation = CS.UnityEngine.Quaternion.Euler(0, 0, angel)
  else
    self.ui.mTrans_Line.localRotation = CS.UnityEngine.Quaternion.identity
  end
  self.ui.mImage_Line.material:DisableKeyword("BEZIERCURVE")
  lineWidth = lineWidth and lineWidth or 3
  self.ui.mImage_Line.material:SetFloat("_Width", lineWidth)
end
function UIStageLineItem:SetBranchLine(startPos, endPos, isComplete)
  if math.abs(endPos.y - startPos.y) > 4 then
    self.ui.mTrans_Line.sizeDelta = Vector2(math.abs(endPos.x - startPos.x), math.abs(endPos.y - startPos.y))
    self.ui.mTrans_Line.anchoredPosition = Vector2(endPos.x - startPos.x >= 0 and 0 or endPos.x - startPos.x, (endPos.y - startPos.y) / 2)
    if endPos.y - startPos.y > 0 and endPos.x - startPos.x > 0 then
      self.ui.mImage_Line.material:EnableKeyword("FLIP")
      self.ui.mImage_Line.material:EnableKeyword("BEZIERCURVE")
    else
      self.ui.mImage_Line.material:DisableKeyword("FLIP")
      self.ui.mImage_Line.material:EnableKeyword("BEZIERCURVE")
    end
  end
end
function UIStageLineItem:UpdateLineColor(isComplete)
  self.ui.mImage_Line.material:SetColor("_Color", isComplete and ColorUtils.LineColor or ColorUtils.LockedLineColor)
  self.ui.mImage_Line.material:SetColor("_ShadowColor", isComplete and ColorUtils.LineShadowColor or ColorUtils.LockedLineShadowColor)
end
function UIStageLineItem:UpdateHardLineColor(isComplete, isHard)
  self.ui.mImage_Line.material:SetColor("_Color", isComplete and ColorUtils.LineColor or ColorUtils.LockedLineColor)
  self.ui.mImage_Line.material:SetColor("_ShadowColor", isComplete and ColorUtils.LineShadowColor or ColorUtils.LockedLineShadowColor)
end
function UIStageLineItem:OnRelease()
  self.supportLine = nil
  self.parent = nil
  self.super.OnRelease(self, true)
end
