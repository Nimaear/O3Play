local addon, ns = ...

local SPELL_POWER_COMBO_POINTS = 4

ns.SecondaryPowerDisplay = O3.UI.Panel:extend({
	maxAmount = 5,
	width = 181,
	height = 14,
	color = {1,0.5,0,1},
	highColor = {1, 0.1, 0, 1},
	enabled = true,
	powerMax = 1,
	powers = {},
	powerType = nil,
	multiplier = 1,
	detailed = false,
	_lookup = {
		[SPELL_POWER_COMBO_POINTS] = 'COMBO_POINTS',
		[SPELL_POWER_CHI] = 'CHI',
		[SPELL_POWER_HOLY_POWER] = 'HOLY_POWER',
		[SPELL_POWER_DEMONIC_FURY] = 'DEMONIC_FURY',
		[SPELL_POWER_BURNING_EMBERS] = 'BURNING_EMBERS',
		[SPELL_POWER_SOUL_SHARDS] = 'SOUL_SHARDS',
		[SPELL_POWER_ECLIPSE] = 'ECLIPSE',
	},
	powerString = nil,
	powerColor = {1, 1, 1, 1},
	calculateWidth = function (self, stacks)
		return ((self.width-1)/stacks)+1
	end,
	preInit = function (self)
		self.power = 0
		self.powerString = self._lookup[self.powerType]
	end,
	getColor = function (self, stackNo)
		if (stackNo > 10) then
			return self.highColor
		else
			return self.color
		end
	end,
	UNIT_POWER = function (self)
		local powerType = self.powerType
		self.power = UnitPower('player', powerType, self.detailed)
		for i = 1, self.powerMax/self.multiplier do
			local bar = self.powers[i].frame
			bar:SetValue(self.power)
		end
	end,
	UNIT_MAXPOWER = function (self)
		local powerType = self.powerType
		self.power = UnitPower('player', powerType, self.detailed)
		self.powerMax = UnitPowerMax('player', powerType, self.detailed)
		local width = self:calculateWidth(self.powerMax/self.multiplier)
		for i = 1, self.maxAmount do
			local bar = self.powers[i].frame
			if i <= self.powerMax/self.multiplier then
				bar:Show()
				bar:SetWidth(width)
			else
				bar:Hide()
			end
		end
		for i = 1, self.powerMax/self.multiplier do
			local bar = self.powers[i].frame
			bar:SetValue(self.power)
		end
	end,	
	style = function (self)
		self:createTexture({
			layer = 'BACKGROUND',
			subLayer = -7,
			color = {0.1, 0.1, 0.1, 0.7},
		})
	end,
	createRegions = function (self)
		local width = self:calculateWidth(self.maxAmount)
		for i = 1, self.maxAmount do
			local power = O3.UI.StatusBar:instance({
				parentFrame = self.frame,
				texture = O3.Media:statusBar('Stone'),
				color = self:getColor(i),
				width = width,
				height = self.height,
				min = (i-1)*self.multiplier,
				max = i*self.multiplier,
			})
			if i == 1 then
				power:point('TOPLEFT', self.frame, 'TOPLEFT', 0, 0)
			else
				power:point('LEFT', self.powers[i-1].frame, 'RIGHT', -1, 0)
			end
			self.powers[i] = power
		end
	end,
})

ns.DemonicFuryDisplay = ns.SecondaryPowerDisplay:extend({
	color = {0.58, 0.51, 0.79, 1},
	powerType = SPELL_POWER_DEMONIC_FURY,
	UNIT_POWER = function (self)
		self.bar.frame:SetValue(UnitPower('player', self.powerType))
	end,
	UNIT_MAXPOWER = function (self)
		local powerType = self.powerType
		self.bar.frame:SetMinMaxValues(0, UnitPowerMax('player', self.powerType))
		self.bar.frame:SetValue(UnitPower('player', self.powerType))
	end,	
	createRegions = function (self)
		self.bar = O3.UI.StatusBar:instance({
			offset = {0,0,0,0},
			parentFrame = self.frame,
			color = self.color,
			width = self.width,
			height = self.height,
			min = 0,
			max = 1000,
		})
	end,
})

ns.EmberDisplay = ns.SecondaryPowerDisplay:extend({
	maxAmount = 4,
	multiplier = 10,
	color = {0.9, 0.45, 0.1, 1},
	powerType = SPELL_POWER_BURNING_EMBERS,
	detailed = true,
})

local mathAbs = math.abs
local mathFloor = math.floor

ns.EclipseDisplay = ns.SecondaryPowerDisplay:extend({
	moonColor = {0.2, 0.2, 0.8, 1},
	sunColor = {0.8, 0.4, 0.2, 1},
	powerType = SPELL_POWER_ECLIPSE,
	UNIT_POWER = function (self)
		local eclipse = UnitPower('player', self.powerType)
		local moonWidth = mathFloor(((100+eclipse)/200)*self.width)+1
		if (moonWidth == 0) then
			self.moon:hide()
			self.sun.frame:SetWidth(self.width)
		elseif moonWidth >= self.width then
			self.moon.frame:SetWidth(self.width)
			self.sun:hide()
		else
			self.moon:show()
			self.sun:show()
			self.moon.frame:SetWidth(moonWidth)
			self.sun.frame:SetWidth(self.width-moonWidth+1)
		end
		self.text:SetText(math.abs(eclipse))
	end,
	UNIT_MAXPOWER = function (self)
		self:UNIT_POWER()
	end,
	style = function (self)
	end,	
	createRegions = function (self)
		self.moon = O3.UI.StatusBar:instance({
			offset = {0,nil,0,0},
			parentFrame = self.frame,
			color = self.moonColor,
			texture = O3.Media:statusBar('Stone'),
			width = self.width,
			height = self.height,
			min = 0,
			max = 100,
		})
		self.moon.frame:SetValue(100)
		self.moon.frame:SetFrameLevel(1)
		self.sun = O3.UI.StatusBar:instance({
			offset = {nil,0,0,0},
			parentFrame = self.frame,
			color = self.sunColor,
			texture = O3.Media:statusBar('Stone'),
			width = self.width,
			height = self.height,
			min = 0,
			max = 100,
		})
		self.sun.frame:SetValue(100)
		self.sun.frame:SetFrameLevel(1)
		self.frame:SetFrameLevel(2)
		--self.moon:point('RIGHT', self.sun.frame, 'LEFT', 1, 0)
		self.text = self:createFontString({
			offset = {4, 4, 0, 0},
			color = {0.9, 0.9, 0.9, 1},
			layer = 'BORDER',
			subLayer = 7,
			--shadowColor = {0.5, 0.5, 0.5, 1},
			shadowOffset = {1, -1},
			justifyH = 'CENTER',
		})
	end,
})