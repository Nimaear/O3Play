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

