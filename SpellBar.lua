local addon, ns = ...

local GetTime = GetTime

local StatusBar = O3.Class:extend({
	config = {
		statusBar = O3.Media:statusBar('Default'),
		font = O3.Media:font('Normal'),
		fontSize = 10,
		fontFlags = '',
		fontColor = {r = 0.4, g = 0.4, b = 0.4},
		color = {0.8, 0.2, 0.2},
		min = 0,
		max = 30,
	},
	duration = 0,
	timeSinceLastUpdate = 0,
	expireTime = 0,
	createIcon = function (self, texture, height)
		self.icon = CreateFrame('Frame', nil, self.frame)
		O3.UI:shadow(self.icon)
		self.icon:SetSize(height, height)
		self.iconTexture = self.icon:CreateTexture()
		self.iconTexture:SetTexture(texture)
		self.iconTexture:SetAllPoints()
		self.icon:SetPoint('TOPLEFT')
		self.iconTexture:SetTexCoord(0.08,0.92,0.08,0.92)
	end,
	createBar = function (self)
		self.bar = CreateFrame('StatusBar', nil, self.frame)
		self.bar:SetStatusBarTexture(self.config.statusBar)
		self.bar:SetStatusBarColor(unpack(self.config.color))
		self.bar:SetPoint('TOPLEFT', self.icon, 'TOPRIGHT', 3, 0)
		self.bar:SetPoint('BOTTOMRIGHT')
		self.bar:SetMinMaxValues(self.config.min, self.config.max)
		O3.UI:shadow(self.bar)

		self.bar:SetScript('OnUpdate', function (frame, elapsed)
			self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed
			if self.timeSinceLastUpdate > 0.05 then
				local value = (self.expireTime-GetTime())
				if (value <= 0) then
					self:stop()
				else
					self.bar:SetValue(value)
				end
				self.timeSinceLastUpdate = 0
			end
		end)		
	end,
	init = function (self, height, texture, parent)
		self.frame = CreateFrame('Frame', nil, parent)
		self.frame:SetHeight(height)

		self:createIcon(texture, height)
		self:createBar()
	end,
	minMax = function (self, min, max)
		self.bar:SetMinMaxValues(min, max)
	end,
	value = function (self, value)
		self.bar:SetValue(value)
	end,
	texture = function (self, texture)
		self.iconTexture:SetTexture(texture)
	end,
	color = function (self, color)
		self.bar:SetStatusBarColor(unpack(color))
	end,
	width = function (self, width)
		self.frame:SetWidth(width)
	end,
	point = function (self, ...)
		self.frame:SetPoint(...)
	end,
	height = function (self, height)
		self.frame:SetHeight(height)
		self.icon:SetSize(height, height)
	end,
	expire = function (self, expireTime)
		self.expireTime = expireTime
	end,
	show = function (self)
		self.frame:Show()
	end,
	hide = function (self)
		self.frame:Hide()
	end,
	start = function (self, duration, max)
		self.bar:SetMinMaxValues(0, max or duration)
		self.expireTime = GetTime() + duration
		self.frame:Show()
	end,
	restart = function (self)
		self.expireTime = GetTime() + self.duration
		self.frame:Show()
	end,
	onStop = function (self)
	end,
	stop = function (self)
		self:onStop()
		self.frame:Hide()
	end,
})


local SpellBar = StatusBar:extend({
	init = function (self, height, spellId, parent)
		self.frame = CreateFrame('Frame', nil, parent)
		self.frame:SetHeight(height)

		local _, _, texture = GetSpellInfo(spellId)
		self:createIcon(texture, height)
		self:createBar()
	end,
	texture = function (self, spellId)
		local _, _, texture = GetSpellInfo(spellId)
		self.iconTexture:SetTexture(texture)
	end,	
})

local BarContainer = O3.Class:extend({
	enabled = true,
	config = {
		spacing = -3,
		height = 12,
		width = 250,
		max = 20,
	},
	free = {},
	busy = {},
	watchedSpells = {},
	init = function (self)
		self.frame = CreateFrame('Frame', nil, UIParent)
		self.frame:SetWidth(self.config.width)
		self.frame:SetHeight(12)
		-- O3.UI:shadow(self.frame)
	end,
	register = function (self, spellId, unitId, duration, color)
		self.watchedSpells[unitId] = self.watchedSpells[unitId] or {} 
		self.watchedSpells[unitId][spellId] = {duration, color}
		O3.AuraWatcher:register(spellId, self)
	end,
	point = function (self, ...)
		self.frame:SetPoint(...)
	end,
	freeUp = function (self, bar)
		for i = 1, #self.busy do
			if (self.busy[i] == bar) then
				table.remove(self.busy, i)
			end
		end
	end,
	create = function (self, spellId, unitId, height, color)
		if #self.free == 0 then
			local new = SpellBar:new(height, spellId, self.frame)
			new.spellId = spellId
			new.unitId = unitId
			new:point('LEFT', self.frame, 'LEFT')
			new:point('RIGHT', self.frame, 'RIGHT')
			new:color(color)
			new.onStop = function(bar)
				self:freeUp(bar)
				table.insert(self.free, new)
			end
			table.insert(self.busy, new)
			self:reposition()
			return new
		else
			local free = table.remove(self.free, #self.free)
			free.spellId = spellId
			free.unitId = unitId
			free:height(height)
			free:texture(spellId)
			free:color(color)
			table.insert(self.busy, free)
			self:reposition()
			return free
		end

	end, 
	reposition = function (self)
		for i = 1, #self.busy do
			if i == 1 then
				self.busy[i]:point('TOP', self.frame, 'TOP')
			else
				self.busy[i]:point('TOP', self.busy[i-1].frame, 'BOTTOM', 0, self.config.spacing)
			end
		end
	end,
	apply = function (self, spellId, unitId, destGUID, destName, playerIsCaster)
		if (self.watchedSpells[unitId] and self.watchedSpells[unitId][spellId]) then
			local spellInfo = self.watchedSpells[unitId][spellId]
			local bar = self:create(spellId, unitId, self.config.height, spellInfo[2])
			bar:start(spellInfo[1], self.config.max)
		end
	end,
	remove = function (self, spellId, unitId, destGUID, destName, playerIsCaster)
		-- print(spellId, unitId)
		for i = 1, #self.busy do
			local bar = self.busy[i]
			if bar.spellId == spellId and bar.unitId == unitId then
				bar:stop()
				break
			end
		end
	end,
	reset = function (self)
	end,
	refresh = function (self, spellId, unitId, destGUID, destName, playerIsCaster)
		local found = false
		for i = 1, #self.busy do
			local bar = self.busy[i]
			if bar.spellId == spellId and bar.unitId == unitId then
				bar:restart()
				found = true
				break
			end
		end
		if (not found) then
			self:apply(spellId, unitId, destGUID, destName, playerIsCaster)
		end
	end,
	dose = function (self, spellId, unitId, destGUID, destName, playerIsCaster, amount)
	end,	
})


ns.BarContainer = BarContainer
ns.StatusBar = StatusBar
ns.SpellBar = SpellBar