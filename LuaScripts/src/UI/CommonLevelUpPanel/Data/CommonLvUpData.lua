CommonLvUpData = class("CommonLvUpData")
CommonLvUpData.__index = CommonLvUpData
function CommonLvUpData:ctor(fromLv, toLv, titleHint)
  self.fromLv = fromLv
  self.toLv = toLv
  self.isMaxLv = false
  self.breakLevel = nil
  self.breakTime = nil
  self.skillList = {}
  self.attrList = {}
  self.subPropList = {}
  self.titleHint = titleHint == nil and 102102 or titleHint
end
function CommonLvUpData:SetGunLvUpData(attrList)
  if attrList then
    for _, attr in ipairs(attrList) do
      if attr.mData and attr.upValue > 0 and attr.upValue ~= attr.value then
        local attrData = {}
        attrData.data = attr.mData
        attrData.value = attr.value
        attrData.upValue = attr.upValue
        attrData.isNew = false
        table.insert(self.attrList, attrData)
      end
    end
  end
end
function CommonLvUpData:SetWeaponLvUpData(attrList, breakLevel)
  if attrList then
    for _, attr in ipairs(attrList) do
      if attr.mData and attr.upValue > 0 and attr.upValue ~= attr.value then
        local attrData = {}
        attrData.data = attr.mData
        attrData.value = attr.value
        attrData.upValue = attr.upValue
        attrData.isNew = false
        table.insert(self.attrList, attrData)
      end
    end
  end
end
function CommonLvUpData:SetWeaponBreakData(attrList, breakLevel, lastBreakTimes, breakTime, skill)
  self.breakLevel = breakLevel
  self.breakTime = breakTime
  self.lastBreakTimes = lastBreakTimes
  if attrList then
    for _, attr in ipairs(attrList) do
      if attr.mData and attr.upValue > 0 and attr.upValue ~= attr.value then
        local attrData = {}
        attrData.data = attr.mData
        attrData.value = attr.value
        attrData.upValue = attr.upValue
        attrData.isNew = false
        table.insert(self.attrList, attrData)
      end
    end
  end
  if skill then
    table.insert(self.skillList, skill)
  end
end
function CommonLvUpData:SetEquipLvUpData(mainAttr, beforeAttrList, afterAttrList)
  if mainAttr then
    local attrData = {}
    attrData.data = mainAttr.mData
    attrData.value = mainAttr.value
    attrData.upValue = mainAttr.upValue
    attrData.isNew = false
    table.insert(self.attrList, attrData)
  end
  for i, prop in ipairs(afterAttrList) do
    if prop.mData then
      local beforeData = self:GetAttrById(prop.mData.id, beforeAttrList)
      if beforeData == nil then
        local attrData = {}
        attrData.data = prop.mData
        attrData.value = prop.value
        attrData.upValue = 0
        attrData.isNew = true
        table.insert(self.attrList, attrData)
      else
        local attrData = {}
        attrData.data = prop.mData
        attrData.value = beforeData.value
        attrData.upValue = prop.value
        attrData.isNew = false
        table.insert(self.attrList, attrData)
      end
    end
  end
end
function CommonLvUpData:SetWeaponPartLvUpData(mainAttr, beforeAttrList, afterAttrList, subPropList)
  self.subPropList = subPropList
  if mainAttr then
    local attrData = {}
    attrData.data = mainAttr.mData
    attrData.value = mainAttr.value
    attrData.upValue = mainAttr.upValue
    attrData.isNew = false
    table.insert(self.attrList, attrData)
  end
  for i, prop in ipairs(afterAttrList) do
    if prop.mData then
      local beforeData = self:GetAttrById(prop.mData.id, beforeAttrList)
      if beforeData == nil then
        local attrData = {}
        attrData.data = prop.mData
        attrData.value = prop.value
        attrData.upValue = 0
        attrData.isNew = true
        table.insert(self.attrList, attrData)
      else
        local attrData = {}
        attrData.data = prop.mData
        attrData.value = beforeData.value
        attrData.upValue = prop.value
        attrData.isNew = false
        table.insert(self.attrList, attrData)
      end
    end
  end
end
function CommonLvUpData:SetMaxLv(boolean)
  self.isMaxLv = boolean
end
function CommonLvUpData:GetAttrById(id, attrList)
  for i, prop in ipairs(attrList) do
    if prop.mData and prop.mData.id == id then
      return prop
    end
  end
  return nil
end
