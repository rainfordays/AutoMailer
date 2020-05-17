local _, A = ...

function A:Print(...)
  DEFAULT_CHAT_FRAME:AddMessage(A.addonName .. "- " .. tostringall(...))
end


A.slashPrefix = "|cff8d63ff/automailer|r "
A.addonName = "|cff8d63ffAutoMailer|r "


--[[
    ---- EVENT FRAME ----
]]
local E = CreateFrame("Frame")
E:RegisterEvent("ADDON_LOADED")
E:RegisterEvent("MAIL_SHOW")
E:RegisterEvent("PLAYER_ENTERING_WORLD")
E:SetScript("OnEvent", function(self, event, ...)
  return self[event] and self[event](self, ...)
end)


--[[
    -- ADDON LOADED --
]]
function E:ADDON_LOADED(name)
  if name ~= "AutoMailer" then return end
  if not AutoMailer then AutoMailer = {} end
  if not AutoMailer.items then AutoMailer.items = "" end
  if not AutoMailer.recipient then AutoMailer.recipient = "" end


  SLASH_AUTOMAILER1= "/automailer"
  SlashCmdList.AUTOMAILER = function(msg)
    A:SlashCommand(msg)
  end
  
  A:CreateOptionsMenu()
end



--[[
    -- PLAYER ENTERING WORLD --
]]
function E:PLAYER_ENTERING_WORLD(login, reloadUI)
  if login or reloadUI then
    print(A.addonName .. "loaded. "..A.slashPrefix.."for settings.")
  end
end



--[[
    -- BAG UPDATE --
]]
function E:MAIL_SHOW()
  if not IsShiftKeyDown() then return end
  if AutoMailer.recipient ~= "" and AutoMailer.items ~= "" then

    local itemsInMail = 0
    local recipient = AutoMailer.recipient
    local sentMail = false

    for bag = 0, NUM_BAG_SLOTS do
      for slot = 1, GetContainerNumSlots(bag) do
        local _, _, _, _, _, _, itemLink, _, _, itemID = GetContainerItemInfo(bag, slot)
        if itemID then
          if not C_Item.IsBound(ItemLocation:CreateFromBagAndSlot(bag, slot)) then
            local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType  = GetItemInfo(itemID)
  
            if string.find(AutoMailer.items:lower(), itemName:lower()) -- item is in text list
            or (AutoMailer.SendBOE and (AutoMailer.LimitBoeLevel and itemMinLevel < UnitLevel("PLAYER")) and bindType == 2) -- item is BoE, BoE is checked AND limit the level of boes
            or (AutoMailer.SendBOE and not AutoMailer.LimitBoeLevel and bindType == 2) then -- item is BoE and limit BoE is not checked
              SetSendMailShowing(true)
              UseContainerItem(bag, slot)
              itemsInMail = itemsInMail + 1
  
              if itemsInMail == ATTACHMENTS_MAX_SEND then
                local subject = A:GetMailSubject()
                SendMail(recipient, subject, "")
                sentMail = true
                itemsInMail = 0
              end
            end
          end
        end -- ITEMLINK
      end -- SLOTS
    end -- BAGS
    if GetSendMailItem(1) then
      local subject = A:GetMailSubject()
      SendMail(recipient, subject, "")
      sentMail = true
    end
    if sentMail then
      A:Print("Successfully sent mail to "..recipient)
    end
  end
end

function A:GetMailSubject()
  local name, _, _, count = GetSendMailItem(1)
  return name.." ("..count..")"
end

--[[
    ---- SLASH COMMANDS ----
]]

A.commands = {
  ["recipient"] = {
    ["description"] = "Set AutoMailer recipient.",
    action = function(recipient)
      if recipient then
        AutoMailer.recipient = recipient
        A:Print("Recipient set to '"..recipient.."'")
      else
        A:Print("Current recipient: ".. recipient)
      end
    end
  },
  ["add"] = {
    ["description"] = "Add item to AutoMailer list (only name, no itemlinks).",
    action = function(itemName)
      AutoMailer.items = AutoMailer.items .. itemName .. "\n"
      A:Print("Added "..itemName)
    end
  },
  ["remove"] = {
    ["description"] = "Remove item from AutoMailer list.",
    action = function(itemName)
      if itemName then
        AutoMailer.items = string.gsub(AutoMailer.items, itemName.."\n", "")
        A:Print("Removed "..itemName)
      end
    end
  },
  ["reset"] = {
    ["description"] = "Reset all settings.",
    action = function()
      wipe(AutoMailer)
      AutoMailer.items = ""
      AutoMailer.recipient = ""
      A:Print("All settings reset.")
    end
  },
  ["list"] = {
    ["description"] = "List items in AutoMailer.",
    action = function()
      if AutoMailer.items ~= "" and AutoMailer.items then
        A:Print("Item list")
        print(AutoMailer.items)
      else
        A:Print("No items in AutoMailer list.")
      end
    end
  }
}

function A:SlashCommand(args)
  InterfaceOptionsFrame_OpenToCategory(A.optionsPanel)
  InterfaceOptionsFrame_OpenToCategory(A.optionsPanel)

  --[[

    local command, rest = strsplit(" ", args, 2) -- Split args
    command = command:lower() -- command to lowercase for easier detection
  
    if A.commands[command] then
      A.commands[command].action(rest)
  
    else
      print("AutoMailer commands")
      for command, t in pairs(A.commands) do
        print(A.slashPrefix .. command .. " - " .. t.description)
      end
    end
  ]]
end


function A:Count(T)
  local i = 0
  for _,_ in pairs(T) do
    i = i+1
  end
  return i
end
