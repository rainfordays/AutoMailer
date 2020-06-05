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
        local locked = select(3, GetContainerItemInfo(bag, slot))
        local itemID = select(10, GetContainerItemInfo(bag, slot))
        if itemID and not locked then
          if not A:ContainerItemIsSoulbound(bag, slot) then -- Item is not soulbound
            local itemName = select(1, GetItemInfo(itemID))
            local bindType = select(14, GetItemInfo(itemID))
            local itemMinLevel = select(5, GetItemInfo(itemID))
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

    if A.sentMail then
      A:Print("Successfully sent mail to "..AutoMailer.recipient)
      A.sentMail = false
      return
    end
  end -- Send regular


  -- BOES TO SEPARATE CHARACTER
  if #AutoMailer.boeRecipient ~= 0 then
    A.sentBoes = false
    local itemsInMail = 0

    for bag = 0, NUM_BAG_SLOTS do
      for slot = 1, GetContainerNumSlots(bag) do
        local locked = select(3, GetContainerItemInfo(bag, slot))
        local itemID = select(10, GetContainerItemInfo(bag, slot))
        if itemID and not locked then
          if not A:ContainerItemIsSoulbound(bag, slot) then -- Item is not soulbound
            local bindType = select(14, GetItemInfo(itemID))
            local itemMinLevel = select(5, GetItemInfo(itemID))
            local rarity = select(3, GetItemInfo(itemID))
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

    if A.sentBoes then
      A:Print("Successfully sent BoEs to "..AutoMailer.boeRecipient)
      A.sentBoes = false
    end
  end
  A.sendingMail = false
end
local sendMailCoroutine = coroutine.create(AutoMailerSendMail)


--[[
    -- MAILING EVENTS --
]]
function E:MAIL_SHOW()
  if IsShiftKeyDown() then
    A.sendingMail = true
    AutoMailerSendMail()
    --[[
      sendMailCoroutine = coroutine.create(AutoMailerSendMail)
      coroutine.resume(sendMailCoroutine)

    ]]
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
  InterfaceOptionsFrame_OpenToCategory(A.optionsPanel)
  InterfaceOptionsFrame_OpenToCategory(A.optionsPanel)
end


function A:SomethingLocked()
  for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
    for slot = 1, GetContainerNumSlots(bag) do
      local locked = select(3, GetContainerItemInfo(bag, slot))
      if locked then
        return true
      end
    end
  end
  return false
end


function A:Count(T)
  local i = 0
  for _,_ in pairs(T) do
    i = i+1
  end
  return i
end