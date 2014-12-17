local addon, ns = ...

local _, class = UnitClass('player')
if (class ~= "DEATHKNIGHT") then
	return
end

local floor = math.floor
local tableWipe = table.wipe

local UNHOLY, FROST, BLOOD = 3, 2, 1

local runeColor = {
    [1] = { 187/255, 43/255, 50/255 }, -- blood
    [2] = { 108/255, 187/255, 43/255 }, -- unholy
    [3] = { 55/255, 100/255, 161/255 }, -- frost
    [4] = { 142/255, 52/255, 155/255 }, -- death
}

local GetTime = GetTime
local A_BLOODTAP = 114851

local RuneDisplay = O3.UI.Panel:extend({
	height = 17,
	runes = {},
	width = 181,
	timeSinceLastUpdate = 0,
	calculateWidth = function (self)
		return ((self.width-1)/3)+1
	end,
	style = function (self)
		self:createTexture({
			layer = 'BACKGROUND',
			subLayer = -7,
			color = {0.1, 0.1, 0.1, 0.7},
		})
	end,	
	createRegions = function (self)
		width = self:calculateWidth()
		for i = 1, 6 do
			local bar = O3.UI.StatusBar:instance({
				height = 9,
				width = width,
				parentFrame = self.frame,
			})

			if (i == 1) then
				bar:point('BOTTOMLEFT', self.frame, 'BOTTOMLEFT', 0, 0)
			elseif (i % 2 == 0) then
				bar:point('BOTTOMLEFT', self.runes[i-1], 'TOPLEFT', 0, -1)
			else
				bar:point('BOTTOMLEFT', self.runes[i-2], 'BOTTOMRIGHT', -1, 0)
			end
			bar.frame.type = GetRuneType(i)
			bar.frame:SetStatusBarColor(unpack(runeColor[bar.frame.type or 1]))
			self.runes[i] = bar.frame
		end	
	end,
	RUNE_TYPE_UPDATE = function (self)	
		for index=1,6 do
			local type = GetRuneType(index)
			local rune = self.runes[index]
			if type ~= rune.type then
				rune.type = type
				rune:SetStatusBarColor(unpack(runeColor[type]))
			end
		end
	end,
	RUNE_POWER_UPDATE = function (self, runeIndex, isEnergize)
		local runes = self.runes
		if (self.frame:GetScript('OnUpdate') == nil) then
			self.frame:SetScript('OnUpdate', function (frame, elapsed)
				local now = GetTime()
				self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed
				local allRunes = 0
		  		if (self.timeSinceLastUpdate > 0.08) then
					for index = 0,2 do
						local first = index*2+1
						local second = first+1
						local start1, duration1, runeReady1 = GetRuneCooldown(first)
						local start2, duration2, runeReady2 = GetRuneCooldown(second)
						local totalRunes = (runeReady1 and 1 or 0) + (runeReady2 and 1 or 0)
						if (totalRunes == 2) then
							runes[first]:SetValue(1)
							runes[second]:SetValue(1)
							runes[first]:SetStatusBarColor(unpack(runeColor[runes[first].type]))
							runes[second]:SetStatusBarColor(unpack(runeColor[runes[second].type]))
						elseif (totalRunes == 1) then
							if (start1 < start2) then
								runes[first]:SetValue(1)
								runes[second]:SetValue((now-start2)/duration2)
								runes[first]:SetStatusBarColor(unpack(runeColor[runes[first].type]))
								runes[second]:SetStatusBarColor(unpack(runeColor[runes[second].type]))
							else 
								runes[first]:SetValue(1)
								runes[second]:SetValue((now-start1)/duration1)
								runes[second]:SetStatusBarColor(unpack(runeColor[runes[first].type]))
								runes[first]:SetStatusBarColor(unpack(runeColor[runes[second].type]))
							end
						else
							if (start1 < start2) then
								runes[first]:SetValue(0)
								runes[second]:SetValue((now-start1)/duration1)
								runes[second]:SetStatusBarColor(unpack(runeColor[runes[first].type]))
							else
								runes[first]:SetValue(0)
								runes[second]:SetValue((now-start2)/duration2)
							end
						end
						allRunes = allRunes + totalRunes

					end

		  			self.timeSinceLastUpdate = 0
				end
				if (allRunes == 6) then
					self.frame:SetScript('OnUpdate', nil)
				end
			end)
		end
	end,	
})


local energy = ns.PowerDisplay:instance({
	powerType = 'RUNIC_POWER',
	runes = true,
	postCreate = function (self)

		local bloodTaps = ns.BuffStackDisplay:instance({
			parentFrame = self.frame,
			spellId = A_BLOODTAP,
			maxAmount = 12,
		})
		self.runes = RuneDisplay:instance({
			parentFrame = self.frame,
		})
		self.runes:point('BOTTOM', self.frame, 'TOP', 0, -1)
		bloodTaps:point('TOP', self.frame, 'BOTTOM', 0, 1)
		self:registerUnitAuraWatcher(bloodTaps)
		self.frame:SetPoint('TOP', UIParent, 'CENTER', 0, self.horizontalOffset)

		local dotWatcher = ns.DotWatcher:instance({
			parentFrame = self.frame,
		auras = {
			{55095, 'target', 'PLAYER|HARMFUL', true, true},
			{55078, 'target', 'PLAYER|HARMFUL', true, true},
		},

		})
		dotWatcher:point('BOTTOM', self.runes.frame, 'TOP', 0, 20)

	end,
	PLAYER_ENTERING_WORLD = function (self)
		self:create()
		self:postCreate()
		self.frame:UnregisterEvent('PLAYER_ENTERING_WORLD')
		self:enable()
	end,	
})

