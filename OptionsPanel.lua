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
  recipientHeader:SetText("Recipient")
  recipientHeader:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 0, -15)



  local recipientBox = CreateFrame("EditBox", "recipientBox", optionsPanel, "InputBoxTemplate")
  recipientBox:SetPoint("TOPLEFT", recipientHeader, "BOTTOMLEFT", 5, 0)
  recipientBox:SetSize(200, 30)
  recipientBox:SetFontObject("ChatFontNormal")
  recipientBox:SetMultiLine(false)
  recipientBox:SetText(AutoMailer.recipient)
  recipientBox:SetCursorPosition(0)
  recipientBox:SetAutoFocus(false)
  recipientBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
  recipientBox:SetScript("OnKeyUp", function(self)
    AutoMailer.recipient = self:GetText()
  end)
  recipientBox:SetScript("OnEnterPressed", function(self)
    AutoMailer.recipient = self:GetText()
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
  itemsFrame:SetScript("OnMouseUp", function(self)
    A.optionsPanel.items:SetFocus()
  end)

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


  local BOECB = CreateFrame("CheckButton", "AMBOECB", optionsPanel, "ChatConfigCheckButtonTemplate")
  BOECB:SetChecked(AutoMailer.SendBOE or false)
  BOECB:SetPoint("TOPLEFT", itemsBG, "TOPRIGHT", 30, 0)
  BOECB:SetScript("OnClick", function(self)
    AutoMailer.SendBOE = self:GetChecked()
  end)
  AutoMailer.SendBOE = BOECB:GetChecked() -- INIT OPTION TO SAVED VARIABLES

  local BOETEXT = BOECB:CreateFontString(nil, "OVERLAY")
  BOETEXT:SetPoint("LEFT", BOECB, "RIGHT", 5, 0)
  BOETEXT:SetFontObject("GameFontNormal")
  BOETEXT:SetText("Automatically send BoEs")

  local BOELEVELLIMIT = CreateFrame("CheckButton", "AMBOELVLLIMITCB", optionsPanel, "ChatConfigCheckButtonTemplate")
  BOELEVELLIMIT:SetChecked(AutoMailer.LimitBoeLevel or false)
  BOELEVELLIMIT:SetPoint("TOPLEFT", BOECB, "BOTTOMLEFT", 5, 0)
  BOELEVELLIMIT:SetScript("OnClick", function(self)
    AutoMailer.LimitBoeLevel = self:GetChecked()
  end)
  AutoMailer.LimitBoeLevel = BOELEVELLIMIT:GetChecked() -- INIT OPTION TO SAVED VARIABLES

  local BOELIMITTEXT = BOELEVELLIMIT:CreateFontString(nil, "OVERLAY")
  BOELIMITTEXT:SetPoint("LEFT", BOELEVELLIMIT, "RIGHT", 5, 0)
  BOELIMITTEXT:SetFontObject("GameFontNormal")
  BOELIMITTEXT:SetText("Only BoEs with required level lower than yours")


  local boeRecipientHeader = optionsPanel:CreateFontString(nil, "OVERLAY")
  boeRecipientHeader:SetFontObject("GameFontNormal")
  boeRecipientHeader:SetText("BoE Recipient")
  boeRecipientHeader:SetPoint("TOPLEFT", BOELIMITTEXT, "BOTTOMLEFT", -30, -15)



  local boeRecipientBox = CreateFrame("EditBox", "boeRecipientBox", optionsPanel, "InputBoxTemplate")
  boeRecipientBox:SetPoint("TOPLEFT", boeRecipientHeader, "BOTTOMLEFT", 5, 0)
  boeRecipientBox:SetSize(200, 30)
  boeRecipientBox:SetFontObject("ChatFontNormal")
  boeRecipientBox:SetMultiLine(false)
  boeRecipientBox:SetText(AutoMailer.boeRecipient)
  boeRecipientBox:SetCursorPosition(0)
  boeRecipientBox:SetAutoFocus(false)
  boeRecipientBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
  boeRecipientBox:SetScript("OnKeyUp", function(self)
    AutoMailer.boeRecipient = self:GetText()
  end)
  boeRecipientBox:SetScript("OnEnterPressed", function(self)
    AutoMailer.boeRecipient = self:GetText()
    self:ClearFocus()
  end)




  local BOELIMITRARITYCB = CreateFrame("CheckButton", "AMBOELIMITRARITYCB", optionsPanel, "ChatConfigCheckButtonTemplate")
  BOELIMITRARITYCB:SetChecked(AutoMailer.limitBoeRarity or false)
  BOELIMITRARITYCB:SetPoint("TOPLEFT", boeRecipientBox, "BOTTOMLEFT", 0, 0)
  BOELIMITRARITYCB:SetScript("OnClick", function(self)
    AutoMailer.limitBoeRarity = self:GetChecked()
  end)
  AutoMailer.limitBoeRarity = BOELIMITRARITYCB:GetChecked() -- INIT OPTION TO SAVED VARIABLES

  local BOELIMITRARITYTEXT = BOELIMITRARITYCB:CreateFontString(nil, "OVERLAY")
  BOELIMITRARITYTEXT:SetPoint("LEFT", BOELIMITRARITYCB, "RIGHT", 5, 0)
  BOELIMITRARITYTEXT:SetFontObject("GameFontNormal")
  BOELIMITRARITYTEXT:SetText("Limit rarity")


  
  local rarities = {"Poor", "Common", "Uncommon", "Rare", "Epic"}
  local RARITYLIMIT = CreateFrame("Frame", "AUTOMAILERRARITYLIMIT", optionsPanel, "UIDropDownMenuTemplate")
  RARITYLIMIT:SetPoint("TOPLEFT", BOELIMITRARITYCB, "BOTTOMLEFT", -24, -5)
  RARITYLIMIT.displayMode = "MENU"
  RARITYLIMIT.info = {}
  RARITYLIMIT.initialize = function(self, level)
    if not level then return end

    for i, rarity in pairs({"Uncommon", "Rare", "Epic"}) do
      local info = UIDropDownMenu_CreateInfo()

      info.text = rarity
      info.arg1 = rarity
      info.func = A.SetRarityLimit
      info.checked = rarity == rarities[AutoMailer.boeRarityLimit+1]

      UIDropDownMenu_AddButton(info, 1)
    end
  end
  optionsPanel.rarityLimit = RARITYLIMIT
  UIDropDownMenu_SetText(optionsPanel.rarityLimit, rarities[AutoMailer.boeRarityLimit])





  
  local loginMessage = CreateFrame("CheckButton", nil, optionsPanel, "UICheckButtonTemplate")
  loginMessage:SetSize(25,25)
  loginMessage:SetPoint("BOTTOMLEFT", optionsPanel, "BOTTOMLEFT", 10, 3)
  loginMessage:SetScript("OnClick", function(self, button)
    AutoMailer.loginMessage = self:GetChecked()
  end)
  loginMessage:SetChecked(AutoMailer.loginMessage)
  optionsPanel.loginMessage = loginMessage

  local loginMessageText = loginMessage:CreateFontString(nil, "OVERLAY")
  loginMessageText:SetFontObject("GameFontNormal")
  loginMessageText:SetPoint("LEFT", loginMessage, "RIGHT", 3, 0)
  loginMessageText:SetText("Display login message")
  optionsPanel.loginMessageText = loginMessageText

  A.optionsPanel = optionsPanel
end


function A.SetRarityLimit(self, arg1, arg2, checked)
  local quals = {
    ["Uncommon"] = LE_ITEM_QUALITY_UNCOMMON,
    ["Rare"] = LE_ITEM_QUALITY_RARE,
    ["Epic"] = LE_ITEM_QUALITY_EPIC
  }

  AutoMailer.boeRarityLimit = quals[arg1]
  UIDropDownMenu_SetText(A.optionsPanel.rarityLimit, arg1)
end