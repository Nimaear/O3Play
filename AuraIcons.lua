local addon, ns = ...

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
			layer = 'BACKGROUND',
			subLayer = 1,
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

		self.cooldown = CreateFrame("Cooldown", nil, self.frame, "CooldownFrameTemplate")
		self.cooldown:SetDrawEdge(false)
		self.cooldown:SetDrawSwipe(true)
		self.cooldown:ClearAllPoints()
		self.cooldown:SetFrameLevel(self.frame:GetFrameLevel()+1)

		self.cooldown:SetAllPoints(self.icon)

	end,
	desaturate = function (self, desaturate)
		self.icon:SetDesaturated(desaturate)
		if (desaturate) then
--			self.cooldown:Hide()
			self.text:SetText('')
			self.strength:SetText('')
			self.cacheKey = nil
			self.cooldown:SetCooldown(GetTime()-1,1)
		else
--			self.cooldown:Show()
			--self.cooldown:SetCooldown(GetTime()-1,1)
		end
	end,
	setTexture = function (self, texture)
		self.icon:SetTexture(texture)
	end,
	setCooldown = function (self, duration, expires)
		self.cooldown:SetCooldown(expires-duration, duration)
	end,
})

ns.DotWatcher = O3.UI.Panel:extend({
	enabled = true,
	width = 36,
	height = 36,
	strength = 1,

	auras = {
		player = {
			['PLAYER|HARMFUL'] = {
				[5171] = {false, false},
			}
		}
	},
	auras = {
		-- {5171, 'player', 'PLAYER|HELPFUL', false, false},
		-- {91021, 'target', 'PLAYER|HARMFUL', false, false},
		-- {1943, 'target', 'PLAYER|HARMFUL', true, true},
		-- {16511, 'target', 'PLAYER|HARMFUL', true, true},	
	},
	icons = {},
	cache = {},
	events = {
		PLAYER_TARGET_CHANGED = true,
		UNIT_AURA = true,
		PLAYER_REGEN_DISABLED = true,
		UNIT_ATTACK_POWER = true,
		UPDATE_STEALTH = true,
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

		self.panel = O3.UI.Panel:instance({
			width = self.width,
			height = self.height,
			parentFrame = self.parentFrame,
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
		local aurasCount = 0
		for unitId, unitInfo in pairs(self.auras) do
			for filter, auras in pairs(unitInfo) do
				for spellId, auraInfo in pairs(auras) do
					O3.AuraWatcher:register(spellId, self)
					local icon = DotIcon:instance({
						parentFrame = self.frame,
						guid = nil,
						spellId = spellId,
						unitId = unitId,
						calculateDamage = auraInfo[1] or false,
						calculateStrength = auraInfo[2] or false,
						filter = filter,
						pattern = auraInfo[3] or "Suffering (%d+) .*",
						offset = {-1+aurasCount*33, nil, nil, nil},
					})
					local name, rank, texture = GetSpellInfo(spellId)
					icon:setTexture(texture)
					icon:desaturate(true)
					self.icons[unitId..'-'..spellId] = icon
					aurasCount = aurasCount + 1
				end
			end
		end

		self:setWidth(aurasCount*33-1)
		self:postCreate()
	end,
	apply = function (self, spellId, foundUnitId, destGUID, destName, casterIsPlayer)
		self.cache[destGUID..spellId] = self.strength
		if (not foundUnitId) then
			return
		end

		local iconKey = foundUnitId..'-'..spellId
		if (not self.icons[iconKey]) then
			return
		end
		self:updateStrength(self.icons[iconKey])
	end,	
	refresh = function (self, spellId, foundUnitId, destGUID, destName, casterIsPlayer)
		self.cache[destGUID..spellId] = self.strength
		if (not foundUnitId) then
			return
		end

		local iconKey = foundUnitId..'-'..spellId
		if (not self.icons[iconKey]) then
			return
		end
		self:updateStrength(self.icons[iconKey])
	end,
	remove = function (self, spellId, foundUnitId, destGUID, destName, casterIsPlayer)

		if (not foundUnitId) then
			return
		end
		if (foundUnitId) then
			local iconKey = foundUnitId..'-'..spellId
			if (not self.icons[iconKey]) then
				return
			end
			self.icons[iconKey]:desaturate(true)
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

	UPDATE_STEALTH = function (self)
		self.hasStealth = IsStealthed()
	end,
	PLAYER_ENTERING_WORLD = function (self)
		table.wipe(self.cache)
		self:PLAYER_TARGET_CHANGED()
	end,
	UNIT_ATTACK_POWER = function (self, unitId)
		if unitId == 'player' then
			self:calculateStrength()
			self:refreshStrength()
		end
	end,
	refreshStrength = function (self)
		for iconKey, icon in pairs(self.icons) do
			local spellId = icon.spellId
			if (icon.calculateStrength and icon.cacheKey and self.cache[icon.cacheKey]) then
				local strength = (self.cache[icon.cacheKey]*100)/self.strength
				if (strength <= 100) then
					icon.strength:SetTextColor(0.1, 0.9, 0.1, 1)
				else
					icon.strength:SetTextColor(0.9, 0.1, 0.1, 1)
				end
				icon.strength:SetText(string.format('%d',strength))
			else
				icon.strength:SetText('')
			end
		end	
	end,
	PLAYER_TARGET_CHANGED = function (self)
		if (UnitExists('target')) then
			for iconKey, icon in pairs(self.icons) do
				if (icon.unitId == 'target') then
					self:UNIT_AURA('target')		
				end
			end
			self:refreshStrength()
		else
			for iconKey, icon in pairs(self.icons) do
				if (icon.unitId == 'target') then
					icon:desaturate(true)
				end
			end
		end
	end,
	updateStrength = function (self, icon)
		if (icon.calculateStrength and icon.cacheKey) then
			icon.strength:SetText(string.format('%.2f',self.cache[icon.cacheKey]))
		else
			icon.strength:SetText('')
		end
	end,	
	PLAYER_REGEN_DISABLED = function (self)
		--table.wipe(self.cache)
	end,
	UNIT_AURA = function (self, unitId)
		if (self.auras[unitId]) then
			self.rakeStrength = 1
			local guid = UnitGUID(unitId)
			for filter, auras in pairs(self.auras[unitId]) do
				for spellId, spellInfo in pairs(auras) do
					local icon = self.icons[unitId..'-'..spellId]
					icon:desaturate(true)
				end
				for i = 1, 40 do
					local name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellId, canApplyAura, isBossDebuff, value1, value2, value3 = UnitAura(unitId, i, filter)
					if not name then
						break
					end
					local iconKey = unitId..'-'..spellId
					if (self.icons[iconKey]) then
						local cacheKey = guid..spellId
						local icon = self.icons[iconKey]
						if (not icon) then
							break
						end
						icon.cacheKey = cacheKey
						if (icon.calculateDamage) then
							self.scanTooltip:ClearLines()
							self.scanTooltip:SetUnitAura(unitId, i, filter)

							-- Get the global name of the tooltip object:
							local name = self.scanTooltip:GetName()

							-- Loop over each line in the tooltip:
							for i = 1, self.scanTooltip:NumLines() do
								-- Get a reference to the left-aligned text on this line:
								local left = _G[name .. "TextLeft" .. i]:GetText()
								local damage = string.match(left, icon.pattern)
								if (damage) then
									icon:setCooldown(duration, expires)
									icon:desaturate(false)
									icon.text:SetText(self:smartValue(tonumber(damage)))
								end
							end
						else
							icon:setCooldown(duration, expires)
							icon:desaturate(false)				
						end
						self:updateStrength(icon)
					end
				end
			end
		end
		if unitId == 'player' then
			self:calculateStrength()
		end
	end,
	calculateStrength = function (self)
		self.strength = UnitAttackPower('player')
	end,

})
