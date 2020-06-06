local _, A = ...


function A:Print(...)
  DEFAULT_CHAT_FRAME:AddMessage(A.addonName .. "- " .. tostringall(...))
end


A.slashPrefix = "|cff8d63ff/automailer|r "
A.addonName = "|cff8d63ffAutoMailer|r "
A.sentMail = false

--[[
    ---- EVENT FRAME ----
]]
local E = CreateFrame("Frame")
E:RegisterEvent("ADDON_LOADED")
E:RegisterEvent("MAIL_SHOW")
E:RegisterEvent("MAIL_CLOSED")
E:RegisterEvent("BAG_UPDATE_DELAYED")
E:RegisterEvent("PLAYER_ENTERING_WORLD")
E:SetScript("OnEvent", function(self, event, ...)
  return self[event] and self[event](self, ...)
end)


--[[
    -- ADDON LOADED --
]]
function E:ADDON_LOADED(name)
  if name ~= "AutoMailer" then return end
  AutoMailer = AutoMailer or {}
  AutoMailer.items = AutoMailer.items or ""
  AutoMailer.recipient = AutoMailer.recipient or ""
  AutoMailer.boeRecipient = AutoMailer.boeRecipient or ""
  AutoMailer.boeRarityLimit = AutoMailer.boeRarityLimit or 4

  if AutoMailer.loginMessage == nil then AutoMailer.loginMessage = true end

  
  A.itemsSent = {}
  A.itemsSent[AutoMailer.recipient] = {}
  A.itemsSent[AutoMailer.boeRecipient] = {}

  SLASH_AUTOMAILER1= "/automailer"
  SLASH_AUTOMAILER2= "/am"
  SlashCmdList.AUTOMAILER = function(msg)
    A:SlashCommand(msg)
  end
  
  A:CreateOptionsMenu()
  A.loaded = true
end



--[[
    -- PLAYER ENTERING WORLD --
]]
function E:PLAYER_ENTERING_WORLD(login, reloadUI)
  if (login or reloadUI) and AutoMailer.loginMessage and A.loaded then
    print(A.addonName .. "loaded")
  end
end



local function AutoMailerSendMail()
  if not A.sendingMail then return end

  if #AutoMailer.recipient ~= 0 and #AutoMailer.items ~= 0 then
    A.sentMail = false
    local itemsInMail = 0

    for bag = 0, NUM_BAG_SLOTS do
      for slot = 1, GetContainerNumSlots(bag) do
        local _, itemCount, locked, _, _, _, itemLink = GetContainerItemInfo(bag, slot)
        if itemLink and not locked then
          if not A:ContainerItemIsSoulbound(bag, slot) then -- Item is not soulbound
            local itemName, _, _, _, itemMinLevel, _, _, _, _, _, _, _, _, bindType = GetItemInfo(itemLink)
            local sendItem = false

            if A:ItemInAutomailList(itemName) then -- item is in text list
              sendItem = true
            elseif A:AutomailBoe(bindType) and #AutoMailer.boeRecipient == 0 then -- Mail BoEs and item is BoE
              if AutoMailer.LimitBoeLevel then -- Limit BoE required level to be below player level
                if itemMinLevel < UnitLevel("PLAYER") then -- Check required level
                  sendItem = true
                end
              else -- Not limiting BoE levels so send all BoEs
                sendItem = true
              end
            end

            if sendItem then -- we should send this item
              SetSendMailShowing(true)
              UseContainerItem(bag, slot)
              if A.itemsSent[AutoMailer.recipient][itemName] then
                A.itemsSent[AutoMailer.recipient][itemName] = A.itemsSent[AutoMailer.recipient][itemName]+itemCount
              else
                A.itemsSent[AutoMailer.recipient][itemName] = itemCount
              end
              itemsInMail = itemsInMail + 1

              if itemsInMail == 12 then -- If there are max attached items then send the mail before proceeding
                SetSendMailShowing(true)
                SendMail(AutoMailer.recipient, A.GetMailSubject(), "")
                A.sentMail = true
                return
                --coroutine.yield()
              end -- 12 ITEMS IN MAIL
            end -- IF SENDITEM
          end -- NOT SOULBOUND
        end -- ITEMLINK
      end -- SLOTS
    end -- BAGS
    if GetSendMailItem(1) then
      SetSendMailShowing(true)
      SendMail(AutoMailer.recipient, A.GetMailSubject(), "")
      A.sentMail = true
    end
  end -- Send regular


  -- BOES TO SEPARATE CHARACTER
  if #AutoMailer.boeRecipient ~= 0 then
    A.sentBoes = false
    local itemsInMail = 0

    for bag = 0, NUM_BAG_SLOTS do
      for slot = 1, GetContainerNumSlots(bag) do
        local locked = select(3, GetContainerItemInfo(bag, slot))
        local itemLink = select(7, GetContainerItemInfo(bag, slot))
        if itemLink and not locked then
          if not A:ContainerItemIsSoulbound(bag, slot) then -- Item is not soulbound
            local itemName, _, rarity, _, itemMinLevel, _, _, _, _, _, _, _, _, bindType = GetItemInfo(itemLink)
            local sendItem = false

            if A:AutomailBoe(bindType) and rarity <= AutoMailer.boeRarityLimit then -- Mail BoEs and item is BoE
              if AutoMailer.LimitBoeLevel then -- Limit BoE required level to be below player level
                if itemMinLevel < UnitLevel("PLAYER") then -- Check required level
                  sendItem = true
                end
              else -- Not limiting BoE levels so send all BoEs
                sendItem = true
              end
            end

            if sendItem then -- we should send this item
              SetSendMailShowing(true)
              UseContainerItem(bag, slot)
              if A.itemsSent[AutoMailer.boeRecipient][itemName] then
                A.itemsSent[AutoMailer.boeRecipient][itemName] = A.itemsSent[AutoMailer.boeRecipient][itemName]+1
              else
                A.itemsSent[AutoMailer.boeRecipient][itemName] = 1
              end
              itemsInMail = itemsInMail + 1

              if itemsInMail == 12 then -- If there are max attached items then send the mail before proceeding
                SetSendMailShowing(true)
                SendMail(AutoMailer.boeRecipient, A.GetMailSubject(), "")
                A.sentBoes = true
                return
                --coroutine.yield()
              end -- 12 ITEMS IN MAIL
            end -- IF SENDITEM
          end -- NOT SOULBOUND
        end -- ITEMLINK
      end -- SLOTS
    end -- BAGS
    if GetSendMailItem(1) then
      SetSendMailShowing(true)
      SendMail(AutoMailer.boeRecipient, A.GetMailSubject(), "")
      A.sentBoes = true
    end
  end
  
  if A.sentMail then
    A:Print("Successfully sent mail to "..AutoMailer.recipient)
    A.sentMail = false
    return
  end
  if A.sentBoes then
    A:Print("Successfully sent BoEs to "..AutoMailer.boeRecipient)
    A.sentBoes = false
  end

  A.sendingMail = false
end


--[[
    -- MAILING EVENTS --
]]
function E:MAIL_SHOW()
  if IsShiftKeyDown() then
    A.sendingMail = true
    AutoMailerSendMail()
  end
end

function E:MAIL_CLOSED()
  A.sendingMail = false
end


function E:BAG_UPDATE_DELAYED()
  if A.sendingMail then
    AutoMailerSendMail()
  end
end


function A:GetMailSubject()
  local name, _, _, count = GetSendMailItem(1)
  return name.." ("..count..")"
end

function A:ItemInAutomailList(itemName)
  return string.find(AutoMailer.items:lower(), itemName:lower())
end

function A:AutomailBoe(bindType)
  return AutoMailer.SendBOE and bindType == 2
end

function A:ContainerItemIsSoulbound(bag, slot)
  return C_Item.IsBound(ItemLocation:CreateFromBagAndSlot(bag, slot))
end

function A:SlashCommand(args)
  local command = strsplit(" ", args, 1)
  command = command:lower()

  if command == "list" then
    local sentMessage = false
    for recipient, items in pairs(A.itemsSent) do
      local string = ""
      for itemName, count in pairs(items) do
        if #string > 0 then
          string = string .. ", "..itemName.."x"..count
        else
          string = itemName.."x"..count
        end
      end

      if #string > 0 then
        A:Print("Items sent to ".. recipient)
        print(string)
        sentMessage = true
      end
    end
    if not sentMessage then
      A:Print("Nothing sent this session.")
    end
  else
    InterfaceOptionsFrame_OpenToCategory(A.optionsPanel)
    InterfaceOptionsFrame_OpenToCategory(A.optionsPanel)
  end
end



function A:Count(T)
  local i = 0
  for _,_ in pairs(T) do
    i = i+1
  end
  return i
end