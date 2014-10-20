local addon, ns = ...

local _, class = UnitClass('player')
if (class ~= "MONK") then
	return
end

local A_ENERGIZINGBREW = 115288
local A_TIGEREYEBREW = 125195
local A_ELUSIVEBREW = 128939
local A_TIGEREYEBREWING = 116740

local WINDWALKER = 3
local BREWMASTER = 1

ns.Play:registerControl(ns.PowerDisplay:extend({
	specId = WINDWALKER,
	powerType = 'ENERGY',
	calculateWidth = function (self, maxPower)
		return self.width
	end,	
	postCreate = function (self)
		self.secondaryPower = ns.SecondaryPowerDisplay:instance({
			color = {0.9, 0.9, 0.9, 1},
			powerType = SPELL_POWER_CHI,
			parentFrame = self.frame
		})
		self.secondaryPower:point('BOTTOM', self.frame, 'TOP', 0, -1)
		self.frame:SetPoint('TOP', UIParent, 'CENTER', 0, self.horizontalOffset)

		local brew = ns.BuffStackDisplay:instance({
			parentFrame = self.frame,
			spellId = A_TIGEREYEBREW,
			maxAmount = 20,
		})
		brew:point('TOP', self.frame, 'BOTTOM', 0, 1)
		self:registerUnitAuraWatcher(brew)
	end,
}))

ns.Play:registerControl(ns.PowerDisplay:extend({
	specId = BREWMASTER,
	powerType = 'ENERGY',
	calculateWidth = function (self, maxPower)
		return self.width
	end,	
	postCreate = function (self)
		self.secondaryPower = ns.SecondaryPowerDisplay:instance({
			color = {0.9, 0.9, 0.9, 1},
			powerType = SPELL_POWER_CHI,
			parentFrame = self.frame
		})
		self.secondaryPower:point('BOTTOM', self.frame, 'TOP', 0, -1)
		self.frame:SetPoint('TOP', UIParent, 'CENTER', 0, self.horizontalOffset)

		local brew = ns.BuffStackDisplay:instance({
			parentFrame = self.frame,
			spellId = A_ELUSIVEBREW,
			maxAmount = 15,
		})
		brew:point('TOP', self.frame, 'BOTTOM', 0, 1)
		self:registerUnitAuraWatcher(brew)
	end,
}))
