local addon, ns = ...

ns.PowerDisplay = O3.Class:extend({
	width = 181,
	height = 14,
	powerType = 'MANA',
	texture = O3.Media:statusBar('Stone'),
	powers = {},
	secondaryPower = nil,
	runes = false,
	horizontalOffset = -290,
	auraWatchers = {},
	events = {
		UNIT_POWER = true,
		UNIT_POWER_FREQUENT = true,
		UNIT_MAXPOWER = true,
	},
	power = 0,
	powerMax = 0,
	enable = function (self)
		self.frame:Show()
		self:UNIT_MAXPOWER('player', self.powerType)
		if (self.secondaryPower) then
			self:UNIT_MAXPOWER('player', self.secondaryPower.powerString)
		end
		self:registerNormalEvent('UPDATE_SHAPESHIFT_FORM')
		if (self.runes) then
			self:registerNormalEvent('RUNE_TYPE_UPDATE')
			self:registerNormalEvent('RUNE_POWER_UPDATE')
			self.runes:RUNE_POWER_UPDATE()
		end
		self:registerEvents()
	end,
	disable = function (self)
		self.frame:Hide()
		self:unregisterEvents()
	end,
	UNIT_POWER_FREQUENT = function (self, unit, powerType)
		if (powerType == self.powerType) then
			self.power = UnitPower('player', powerType)
			self.bar.frame:SetValue(self.power)
			self.text:SetText(self.power)

			local inactiveRegen, activeRegen = GetPowerRegen()
			local regenedPower = self.power+activeRegen
			if (self.regenBar) then
				self.regenBar.frame:SetValue(regenedPower)
				if (regenedPower > self.powerMax) then
					self.regenBar.frame:SetStatusBarColor(1,0,0,1)
				else
					self.regenBar.frame:SetStatusBarColor(0,1,1,1)
				end
			end
		elseif self.secondaryPower and powerType == self.secondaryPower.powerString then
			self.secondaryPower:UNIT_POWER()
		end
	end,
	UNIT_POWER = function (self, unit, powerType)
		if self.secondaryPower and powerType == self.secondaryPower.powerString then
			self.secondaryPower:UNIT_POWER()
		end
	end,
	UNIT_MAXPOWER = function (self, unit, powerType)
		if (powerType == self.powerType) then
			self.power = UnitPower('player', powerType)
			self.powerMax = UnitPowerMax('player', powerType)
			self.bar.frame:SetMinMaxValues(0, self.powerMax)
			self.bar.frame:SetValue(self.power)
			self.text:SetText(self.power)
			if (self.regenBar) then
				self.regenBar.frame:SetMinMaxValues(0, self.powerMax)
			end
		elseif self.secondaryPower and powerType == self.secondaryPower.powerString then
			self.secondaryPower:UNIT_MAXPOWER()
		end
	end,
	registerEvent = function (self, event, object)
		self.frame:RegisterUnitEvent(event, 'player')
		object = object or self
		self._events[event] = self._events[event] or {}
		self._events[event][object] = true
	end,
	registerNormalEvent = function (self, event)
		self.frame:RegisterEvent(event)
		object = object or self
		self._events[event] = self._events[event] or {}
		self._events[event][object] = true
	end,
	registerUnitAuraWatcher = function (self, watcher)
		if (not self.events.aura) then
			self.events.UNIT_AURA = true
			self:registerEvent('UNIT_AURA')
		end
		table.insert(self.auraWatchers, watcher)
	end,
	UNIT_AURA = function (self)
		for i = 1, #self.auraWatchers do
			self.auraWatchers[i]:UNIT_AURA()
		end
	end,
	reset = function (self)
		self:UNIT_AURA()
		self:UNIT_MAXPOWER('player', self.powerType)
		if (self.secondaryPower) then
			self.secondaryPower:UNIT_MAXPOWER()
		end
	end,
	RUNE_TYPE_UPDATE = function (self)
		self.runes:RUNE_TYPE_UPDATE()
	end,
	RUNE_POWER_UPDATE = function (self)
		self.runes:RUNE_POWER_UPDATE()
	end,
	init = function (self)
		self.panel = O3.UI.Panel:instance({
			width = self.width,
			height = self.height,
			style = function (panel)
				self.bg = panel:createTexture({
					layer = 'BACKGROUND',
					subLayer = -7,
					file = self.texture,
					color = {0.1, 0.1, 0.1, 0.7},
				})			
			end,
		})
		self.frame = self.panel.frame
		self.UPDATE_SHAPESHIFT_FORM = self.reset
		O3.EventHandler:mixin(self)
		self:initEventHandler()
		self:registerNormalEvent('PLAYER_ENTERING_WORLD')
	end,
	postCreate = function(self)
	end,
	PLAYER_ENTERING_WORLD = function (self)
		local _, class = UnitClass('player')
		self.class = class
		self:create()
		self:postCreate()
		self.frame:UnregisterEvent('PLAYER_ENTERING_WORLD')
	end,
	create = function (self)

		if (self.powerType == 'ENERGY') then
			self.regenBar = O3.UI.StatusBar:instance({
				parentFrame = self.frame,
				width = self.width,
				color = {0.1, 0.9, 0.9, 1},
				texture = self.texture,
				textureSubLayer = -6,
				height = 14,
				offset = {0, 0, nil, 0},
			})
		end

		local color = PowerBarColor[self.powerType]
			
		self.bar = O3.UI.StatusBar:instance({
			parentFrame = self.frame,
			width = self.width,
			height = 14,
			offset = {0, 0, nil, 0},
			color = {color.r, color.g, color.b, 1},
			texture = self.texture,
			textureSubLayer = -5,
			createRegions = function (bar)
				bar.text = bar:createFontString({
					offset = {4, 4, 0, 0},
					color = {0.9, 0.9, 0.9, 1},
					--shadowColor = {0.5, 0.5, 0.5, 1},
					shadowOffset = {1, -1},
					justifyH = 'CENTER',
				})
			end,
		})
		self.bg:SetVertexColor(color.r/2, color.g/2, color.b/2)
		self.text = self.bar.text
	end,
})


local DotIcon = O3.UI.Panel:extend({
	icon = nil,
	width = 32,
	height = 32,
	coords = {.08, .92, .08, .92},
	createRegions = function (self)
		self:createTexture({
			layer = 'BACKGROUND',
			subLayer = 0,
			color = {0, 0, 0, 0.65},
			offset = {0, 0, 0, 0},
			-- height = 1,
		})
		self.icon = self:createTexture({
			layer = 'BORDER',
			subLayer = 2,
			file = self.icon,
			coords = self.coords,
			tile = false,
			-- color = {color.r, color.g, color.b, 0.95},
			-- color = self.color,
			offset = {1,1,1,1},
		})
		self.outline = self:createOutline({
			layer = 'ARTWORK',
			subLayer = 3,
			gradient = 'VERTICAL',
			color = {1, 1, 1, 0.1 },
			colorEnd = {1, 1, 1, 0.2 },
			offset = {1, 1, 1, 1},
		})
		self.highlight = self:createTexture({
			layer = 'ARTWORK',
			gradient = 'VERTICAL',
			color = {0,1,1,0.15},
			colorEnd = {0,1,1,0.20},
			offset = {1,1,1,1},
		})
		self.highlight:Hide()

		self.text = self:createFontString({
			offset = {1, 1, nil, -14},
			color = {0.9, 0.9, 0.9, 1},
			fontSize = 13,
			--shadowColor = {0.5, 0.5, 0.5, 1},
			shadowOffset = {1, -1},
			justifyH = 'CENTER',
		})
		self.strength = self:createFontString({
			offset = {1, 1, -14, nil},
			color = {0.9, 0.9, 0.9, 1},
			fontSize = 13,
			--shadowColor = {0.5, 0.5, 0.5, 1},
			shadowOffset = {1, -1},
			justifyH = 'CENTER',
		})		
		self.icon:SetDesaturated(true)
	end,
	desaturate = function (self, desaturate)
		self.icon:SetDesaturated(desaturate)
		if (desaturate) then
			self.text:SetText('')
			self.strength:SetText('')
			self.cacheKey = nil
		end
	end,
	setTexture = function (self, texture)
		self.icon:SetTexture(texture)
	end,
})

ns.DotWatcher = O3.UI.Panel:extend({
	enabled = true,
	width = 36,
	height = 36,
	dots = {
		55095, 55078
	},
	icons = {},
	cache = {},
	events = {
		PLAYER_TARGET_CHANGED = true,
		UNIT_AURA = true,
		PLAYER_REGEN_DISABLED = true,
		UNIT_ATTACK_POWER = true,
	},
	enable = function (self)
		self.frame:Show()
		self:registerEvents()
	end,
	disable = function (self)
		self.frame:Hide()
		self:unregisterEvents()
	end,
	reset = function (self)
	end,
	init = function (self)
		for i=1,#self.dots do
			O3.AuraWatcher:register(self.dots[i], self)
		end
		self.panel = O3.UI.Panel:instance({
			width = self.width,
			height = self.height,
		})
		self.frame = self.panel.frame
		O3.EventHandler:mixin(self)
		self:initEventHandler()
		local _, class = UnitClass('player')
		self.class = class
		self:create()
		self:postCreate()
		self:registerEvent('PLAYER_ENTERING_WORLD')

		self.scanTooltip = CreateFrame( "GameTooltip", "MyScanningTooltip", UIParent, "GameTooltipTemplate" )
		self.scanTooltip:SetOwner( UIParent, "ANCHOR_NONE" )
	end,
	postCreate = function(self)
		self:PLAYER_TARGET_CHANGED()
	end,
	create = function (self)
		local dotCount = #self.dots
		self:setWidth(dotCount*36+dotCount*3)
		for i = 1, dotCount do
			local icon = DotIcon:instance({
				parentFrame = self.frame,
				guid = nil,
				offset = {3 + (i-1)*32, nil, nil, nil},
			})
			local name, rank, texture = GetSpellInfo(self.dots[i])
			icon:setTexture(texture)
			self.icons[self.dots[i]] = icon
		end
	end,
	refresh = function (self, appliedSpellId, foundUnitId, destGUID, destName, casterIsPlayer)
		self.cache[destGUID..appliedSpellId] = self.ap
		if (foundUnitId ~= 'target' or not casterIsPlayer) then
			return
		end
		self:searchForAura(appliedSpellId, foundUnitId, destGUID)
		self:UNIT_AURA('player')		
	end,
	remove = function (self, spellId, foundUnitId, destGUID, destName, casterIsPlayer)
		self.cache[destGUID..spellId] = nil
		if (foundUnitId ~= 'target' or not casterIsPlayer) then
			return
		end
		if (self.icons[spellId]) then
			self.icons[spellId]:desaturate(true)
		end
	end,
	smartValue = function(self, val)
		if (val >= 1e6) then
			return ("%.fm"):format(val / 1e6)
		elseif (val >= 1e3) then
			return ("%.fk"):format(val / 1e3)
		else
			return ("%d"):format(val)
		end
	end,	
	apply = function (self, appliedSpellId, foundUnitId, destGUID, destName, casterIsPlayer)
		self.cache[destGUID..appliedSpellId] = self.ap
		if (foundUnitId ~= 'target' or not casterIsPlayer) then
			return
		end
		self:searchForAura(appliedSpellId, foundUnitId, destGUID)
		self:UNIT_AURA('player')
	end,
	periodicDamage = function (self, appliedSpellId, foundUnitId, destGUID, destName, casterIsPlayer)
		if (foundUnitId ~= 'target' or not casterIsPlayer) then
			return
		end
		self:searchForAura(appliedSpellId, foundUnitId, destGUID)
		self:UNIT_AURA('player')
	end,
	PLAYER_ENTERING_WORLD = function (self)
		table.wipe(self.cache)
		self:PLAYER_TARGET_CHANGED()
	end,
	UNIT_ATTACK_POWER = function (self, unitId)
		if unitId == 'player' then
			self.ap = UnitAttackPower('player')
			self:refreshStrength()
		end
	end,
	refreshStrength = function (self)
		for i = 1, #self.dots do
			local spellId = self.dots[i]
			local icon = self.icons[spellId]
			if (icon.cacheKey and self.cache[icon.cacheKey]) then
				local strength = (self.cache[icon.cacheKey]*100)/self.ap
				if (strength <= 100) then
					icon.strength:SetTextColor(0.1, 0.9, 0.1, 1)
				else
					icon.strength:SetTextColor(0.9, 0.1, 0.1, 1)
				end
				icon.strength:SetText(string.format('%d',strength))
			else
				icon.strength:SetText('?')
			end
		end	
	end,
	PLAYER_TARGET_CHANGED = function (self)
		if (UnitExists('target')) then
			for i = 1, #self.dots do
				self:searchForAura(self.dots[i], 'target', UnitGUID('target'))
			end
			self:refreshStrength()
		else
			for i = 1, #self.dots do
				self.icons[self.dots[i]]:desaturate(true)
			end
		end
	end,
	PLAYER_REGEN_DISABLED = function (self)
		-- table.wipe(self.cache)
	end,
	UNIT_AURA = function (self, unitId)
		if unitId == 'player' then
			self.ap = UnitAttackPower('player')
			self:refreshStrength()
		end
	end,
	searchForAura = function (self, appliedSpellId, foundUnitId, destGUID)
		if (not self.icons[appliedSpellId]) then
			return
		end
		self.icons[appliedSpellId].cacheKey = destGUID..appliedSpellId
		local filter = "PLAYER|HARMFUL"
		local foundIndex = nil
		for i = 1, 40 do
			local name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellId, canApplyAura, isBossDebuff, value1, value2, value3 = UnitAura(foundUnitId, i, filter)
			if not name then
				break
			end
			if spellId == appliedSpellId then
				foundIndex = i
				break
			end
		end
		if foundIndex then
			self.scanTooltip:ClearLines()
			self.scanTooltip:SetUnitAura(foundUnitId, foundIndex, filter)

			-- Get the global name of the tooltip object:
			local name = self.scanTooltip:GetName()

			-- Loop over each line in the tooltip:
			for i = 1, self.scanTooltip:NumLines() do
			    -- Get a reference to the left-aligned text on this line:
			    local left = _G[name .. "TextLeft" .. i]:GetText()
			    local damage = string.match(left, "Suffering (%d+) .*")
			    if (damage and self.icons[appliedSpellId]) then
			    	self.icons[appliedSpellId]:desaturate(false)
			    	self.icons[appliedSpellId].text:SetText(self:smartValue(tonumber(damage)))
			    end
			end
		else
			self.icons[appliedSpellId]:desaturate(true)
		end
		self:refreshStrength()
	end,
	-- periodicDamage = function (self, spellId, foundUnitId, destGUID, destName, casterIsPlayer, amount)
	-- 	print(foundUnitId, spellId, amount)
	-- end
})
