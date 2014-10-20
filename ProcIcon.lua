local addon, ns = ...

local GetTime = GetTime

local itemData = {
	[102643] = {'ICDProc', 126707, 20, 60},
	[102659] = {'ICDProc', 126690, 20, 60},
	-- [105472] = {'ICDProc', 146308, 20, 115}, -- Assurance
}

local enchantData = {
	[4430] = {'ICDProc', 96228, 10, 60}, -- Synapse springs
	[4894] = {'ICDProc', 125489, 15, 60}, -- Swordguard broidery
	[4892] = {'ICDProc', 125487, 15, 60}, -- Lightweave broidery
}


local ICDProc = O3.Class:extend({
	config = {
		font = O3.Media:font('Normal'),
		fontSize = 10,
		fontFlags = '',
		fontColor = {r = 0.4, g = 0.4, b = 0.4},
	},
	duration = 0,
	startTime = 0,
	internalCD = 0,
	createIcon = function (self, texture)
		self.iconTexture = self.frame:CreateTexture()
		self.iconTexture:SetTexture(texture)
		self.iconTexture:SetAllPoints()
		self.iconTexture:SetTexCoord(0.08,0.92,0.08,0.92)

		self.cooldown = CreateFrame('Cooldown', nil, self.frame)
		self.cooldown:SetAllPoints(self.frame)
		self.cooldown:SetScript('OnHide', function (cooldownFrame)
			self.iconTexture:SetDesaturated(true)
			if (self.startTime > 0) and (GetTime() < self.startTime+self.internalCD) then
				cooldownFrame:SetCooldown(self.startTime, self.internalCD)
			end
		end)
		self.iconTexture:SetDesaturated(true)
	end,
	init = function (self, size, parent)
		self.frame = CreateFrame('Frame', nil, parent)
		self.frame:SetFrameStrata('BACKGROUND')
		-- self.frame:SetFrameLevel(2)
		self.frame:SetSize(size, size)
		O3.UI:shadow(self.frame)

		local _, _, texture = GetSpellInfo(self.spellId)

		self:createIcon(texture)
	end,
	texture = function (self, spellId)
		local _, _, texture = GetSpellInfo(self.spellId)
		self.iconTexture:SetTexture(texture)
		self.iconTexture:SetDesaturated(true)
	end,
	point = function (self, ...)
		self.frame:SetPoint(...)
	end,
	size = function (self, size)
		self.frame:SetSize(size, size)
	end,
	show = function (self)
		self.frame:Show()
	end,
	hide = function (self)
		self.frame:Hide()
	end,
	start = function (self, duration)
		self.duration = duration
		local now = GetTime()
		self.startTime = now
		self.cooldown:SetCooldown(now, duration)
		self.iconTexture:SetDesaturated(false)
	end,
	restart = function (self)
		local now = GetTime()
		self.startTime = now
		self.cooldown:SetCooldown(now, self.duration)
		self.iconTexture:SetDesaturated(false)
	end,
	onStop = function (self)
	end,
	stop = function (self)
		self:onStop()
	end,
})

local Proccer = {
	ICDProc = ICDProc
}

local IconContainer = O3.Class:extend({
	config = {
		spacing = 3,
		size = 32,
	},
	events = {
		UNIT_INVENTORY_CHANGED = true,
	},
	enabled = true,
	spellId = nil,
	unitId = nil,
	duration = 0,
	internalCD = 0,
	free = {},
	busy = {},
	watchedSpells = {},
	init = function (self)
		self.frame = CreateFrame('Frame', nil, UIParent)
		self.frame:SetSize(self.config.size, self.config.size)
		-- O3.UI:shadow(self.frame)
		self:findItems()
		self:initEventHandler()
	end,
	watchedSpells = {},
	point = function (self, ...)
		self.frame:SetPoint(...)
	end,
	UNIT_INVENTORY_CHANGED = function (self, unitId)
		if (unitId == 'player') then
			for i = 1, #self.busy do
				local icon = table.remove(self.busy, 1)
				table.insert(self.free, icon)
				icon:hide()
			end
			self:findItems()
		end
	end,
	findItems = function (self)
		for i = 1, 19 do
			local itemId = GetInventoryItemID("player", i)
			if itemId then
				local itemLink = GetInventoryItemLink("player", i)
				local a, b, color, ltype, c, enchantId, gem1, gem2, gem3, gem4, suffix, unique, linkLvl, name, d, e, f =   string.find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
				-- print(a, b, color, ltype, c, enchantId, name, e, e, f)
				local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(itemId)
				if (itemData[itemId]) then
					local creator, spellId, duration, internalCD = unpack(itemData[itemId])
					self:register(spellId, 'player', duration, internalCD)
				end
				enchantId = tonumber(enchantId)
				if (enchantData[enchantId]) then
					local creator, spellId, duration, internalCD = unpack(enchantData[enchantId])
					self:register(spellId, 'player', duration, internalCD)
				end
			end
		end
	end,
	freeUp = function (self, bar)
		for i = 1, #self.busy do
			if (self.busy[i] == bar) then
				local icon = table.remove(self.busy, i)
			end
		end
	end,
	register = function (self, spellId, unitId, duration, internalCD)
		self.watchedSpells[unitId] = self.watchedSpells[unitId] or {} 
		self.watchedSpells[unitId][spellId] = {duration, internalCD}
		O3.AuraWatcher:register(spellId, self)
		return self:create(spellId, unitId, duration, internalCD)
	end,
	create = function (self, spellId, unitId, internalCD)
		if #self.free == 0 then
			local new = ICDProc:instance({
				duration = duration,
				spellId = spellId,
				unitId = unitId,
				internalCD = internalCD,
			}, self.config.size, self.frame)
			new:show()
			table.insert(self.busy, new)
			self:reposition()
			return new
		else
			local free = table.remove(self.free, #self.free)
			free.spellId = spellId
			free.unitId = unitId
			free.duration = duration
			free.internalCD = internalCD
			free:texture(spellId)
			free:show()
			table.insert(self.busy, free)
			self:reposition()

			return free
		end
	end, 
	reposition = function (self)
		local amount = #self.busy
		for i = 1, amount do
			self.busy[i].frame:ClearAllPoints()
			if i == 1 then
				self.busy[i]:point('LEFT', self.frame, 'LEFT')
			else
				self.busy[i]:point('LEFT', self.busy[i-1].frame, 'RIGHT', self.config.spacing, 0)
			end
		end
		self.frame:SetWidth(amount*self.config.size+(amount-1)*self.config.spacing)
	end,
	apply = function (self, spellId, unitId, destGUID, destName, playerIsCaster)
		if (self.watchedSpells[unitId] and self.watchedSpells[unitId][spellId]) then
			for i = 1, #self.busy do
				local icon = self.busy[i]
				if icon.spellId == spellId and icon.unitId == unitId then
					local spellInfo = self.watchedSpells[unitId][spellId]
					icon.internalCD = spellInfo[2]
					icon:start(spellInfo[1])
					break
				end
			end

		end
	end,
	remove = function (self, spellId, unitId, destGUID, destName, playerIsCaster)
		-- print(spellId, unitId)
		for i = 1, #self.busy do
			local icon = self.busy[i]
			if icon.spellId == spellId and icon.unitId == unitId then
				icon:stop()
				break
			end
		end
	end,
	refresh = function (self, spellId, unitId, destGUID, destName, playerIsCaster)
		local found = false
		for i = 1, #self.busy do
			local icon = self.busy[i]
			if icon.spellId == spellId and icon.unitId == unitId then
				icon:restart()
				found = true
				break
			end
		end
		if (not found) then
			self:apply(spellId, unitId, destGUID, destName, playerIsCaster)
		end
	end,		
	reset = function (self)
	end,
	dose = function (self, spellId, unitId, destGUID, destName, playerIsCaster, amount)
	end,
})
O3.EventHandler:mixin(IconContainer)

ns.IconContainer = IconContainer