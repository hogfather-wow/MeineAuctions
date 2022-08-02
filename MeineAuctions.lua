MeineAuctions = LibStub("AceAddon-3.0"):NewAddon("MeineAuctions", "AceEvent-3.0")

function MeineAuctions:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("MeineAuctionsDB")
	MeineAuctions:RegisterEvent("AUCTION_HOUSE_SHOW")
	MeineAuctions:RegisterEvent("CHAT_MSG_SYSTEM")
	MeineAuctions:RegisterEvent("BAG_UPDATE")
end

function MeineAuctions:OnEnable() end

function MeineAuctions:OnDisable() end

-- AUCTIONS
function MeineAuctions:AUCTION_HOUSE_SHOW()
	MeineAuctions:RegisterEvent("AUCTION_OWNED_LIST_UPDATE")
	MeineAuctions:RegisterEvent("AUCTION_HOUSE_CLOSED")
end

function MeineAuctions:AUCTION_OWNED_LIST_UPDATE()
	self.db.char.Auctions = {}
	for i = 1, GetNumAuctionItems("owner") do
		local _, _, itemCount, _, _, _, _, startPrice, _, buyoutPrice, _, _, _, _, _, saleStatus, itemID = GetAuctionItemInfo("owner", i)
		
		if saleStatus and saleStatus == 1 then
			saleStatus = true
		else
			saleStatus = false
		end
		
		if  itemID and not saleStatus then
			table.insert(self.db.char.Auctions, format("%s|%s|%s|%s", itemID, itemCount, startPrice, buyoutPrice))
		end
	end
end

function MeineAuctions:BAG_UPDATE()
	self.db.char.Inventory = {}
	for bagID = 0, 4 do
		for slot = 1, GetContainerNumSlots(bagID) do
			local itemCount = select(2, GetContainerItemInfo(bagID, slot))
			local itemID = GetContainerItemID(bagID, slot)
			if itemID and itemCount then
				table.insert(self.db.char.Inventory, format("%s|%s", itemID, itemCount))
			end
		end
	end
end

function MeineAuctions:AUCTION_HOUSE_CLOSED()
	MeineAuctions:UnregisterEvent("AUCTION_HOUSE_CLOSED")
	MeineAuctions:UnregisterEvent("AUCTION_OWNED_LIST_UPDATE")
end

function MeineAuctions:GetItemAuctionCount(searchID)
	local itemAuctionCount = 0
	for charName, variables in pairs(self.db.sv.char) do
		if	variables.Auctions then
			for _, auctions in ipairs(variables.Auctions) do
				local itemID, count, startPrice, buyoutPrice = strsplit("|", auctions)
				if tonumber(itemID) == tonumber(searchID) then
					itemAuctionCount = itemAuctionCount + tonumber(count)
				end
			end
		end
	end
	return itemAuctionCount
end

function MeineAuctions:GetItemInventoryCount(searchID)
	local itemInventoryCount = 0
	for charName, variables in pairs(self.db.sv.char) do
		if variables.Inventory then
			for _, inventory in ipairs(variables.Inventory) do
				local itemID, count = strsplit("|", inventory)
				if tonumber(itemID) == tonumber(searchID) then
					itemInventoryCount = itemInventoryCount + tonumber(count)
				end
			end
		end
	end
	return itemInventoryCount
end

function MeineAuctions:GetItemCount(searchID)
	return MeineAuctions:GetItemAuctionCount(searchID) + MeineAuctions:GetItemInventoryCount(searchID)
end

function MeineAuctions:CHAT_MSG_SYSTEM(type, msg)
	-- ERR_AUCTION_SOLD_S
	if string.match(msg, "Es wurde ein Käufer für Eure Auktion gefunden:") then
		PlaySound(SOUNDKIT.AUCTION_WINDOW_OPEN)
	end
end
