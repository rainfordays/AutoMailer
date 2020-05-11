local _, A = ...

-- INTERFACE OPTIONS PANEL
function A:CreateOptionsMenu()
  local optionsPanel = CreateFrame("Frame", "AutoMailerOptions", UIParent)
  optionsPanel.name = "AutoMailer"
  InterfaceOptions_AddCategory(optionsPanel)

  local text = optionsPanel:CreateFontString(nil, "OVERLAY")
  text:SetFontObject("GameFontNormalHuge")
  text:SetText("AutoMailer Options")
  text:SetPoint("TOPLEFT", optionsPanel, "TOPLEFT", 20, -10)

  local recipientHeader = optionsPanel:CreateFontString(nil, "OVERLAY")
  recipientHeader:SetFontObject("GameFontNormal")
  recipientHeader:SetText("Recipient (current: "..AutoMailer.recipient..")")
  recipientHeader:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 0, -15)


  local recipientBox = CreateFrame("EditBox", "recipientBox", optionsPanel, "InputBoxTemplate")
  recipientBox:SetPoint("TOPLEFT", recipientHeader, "BOTTOMLEFT", 0, -5)
  recipientBox:SetSize(200, 30)
  recipientBox:SetFontObject("ChatFontNormal")
  recipientBox:SetMultiLine(false)
  recipientBox:SetAutoFocus(false)
  recipientBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
  recipientBox:SetScript("OnKeyUp", function(self)
    AutoMailer.recipient = self:GetText()
    recipientHeader:SetText("Recipient (current: "..AutoMailer.recipient..")")
  end)
  recipientBox:SetScript("OnEnterPressed", function(self)
    AutoMailer.recipient = self:GetText()
    recipientHeader:SetText("Recipient (current: "..AutoMailer.recipient..")")
    self:ClearFocus()
  end)
  
  optionsPanel.recipientBox = recipientBox

  local itemsHeader = optionsPanel:CreateFontString(nil, "OVERLAY")
  itemsHeader:SetPoint("TOPLEFT", recipientBox, "BOTTOMLEFT", 0, -15)
  itemsHeader:SetFontObject("GameFontNormal")
  itemsHeader:SetText("Items to AutoMail")

  optionsPanel.itemsHeader = itemsHeader


  local backdrop = {
    bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    tile = true,
    tileSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
  }
  
  local itemsFrame = CreateFrame("ScrollFrame", nil, optionsPanel, "UIPanelScrollFrameTemplate")
  itemsFrame:SetPoint("TOPLEFT", itemsHeader, "BOTTOMLEFT", 0, -5)
  itemsFrame:SetSize(275, 300)

  optionsPanel.itemsFrame = itemsFrame

  local itemsBG = CreateFrame("Frame", nil, optionsPanel)
  itemsBG:SetPoint("CENTER", itemsFrame, "CENTER")
  itemsBG:SetSize(285, 310)
  itemsBG:SetBackdrop(backdrop)


  local items = CreateFrame("EditBox", nil, itemsFrame)
  --items:SetBackdrop(backdrop)
  items:SetFrameStrata("DIALOG")
  items:SetPoint("TOP", itemsFrame, "TOP", 0, -10)
  items:SetFont(GameFontNormal:GetFont(), 12)
  items:SetWidth(265)
  items:SetHeight(300)
  items:SetText(AutoMailer.items)
  items:SetAutoFocus(false)
  items:SetMultiLine(true)
  items:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
  items:SetScript("OnKeyUp", function(self)
    AutoMailer.items = self:GetText()
  end)

  itemsFrame:SetScrollChild(items)
  optionsPanel.items = items



  A.optionsPanel = optionsPanel
end