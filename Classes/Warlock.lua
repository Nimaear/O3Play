local addon, ns = ...

local _, class = UnitClass('player')
if (class ~= "WARLOCK") then
	return
end

local AFFLICTION = 1
local DEMONOLOGY = 2
local DESTRUCTION = 3

local A_MOLTENCORE = 122355
local A_BACKDRAFT = 117828

ns.Play:registerControl(ns.PowerDisplay:extend({
	specId = DEMONOLOGY,
	powerType = 'MANA',
	calculateWidth = function (self, maxPower)
		return self.width
	end,	
	postCreate = function (self)
		self.frame:SetPoint('TOP', UIParent, 'CENTER', 0, self.horizontalOffset)
		self.secondaryPower = ns.DemonicFuryDisplay:instance({
			parentFrame = self.frame
		})
		self.secondaryPower:point('BOTTOM', self.frame, 'TOP', 0, -1)

		local moltenCore = ns.BuffStackDisplay:instance({
			parentFrame = self.frame,
			spellId = A_MOLTENCORE,
			maxAmount = 5,
		})
		moltenCore:point('TOP', self.frame, 'BOTTOM', 0, 1)
		self:registerUnitAuraWatcher(moltenCore)
	end,
}))

ns.Play:registerControl(ns.PowerDisplay:extend({
	specId = DESTRUCTION,
	powerType = 'MANA',
	calculateWidth = function (self, maxPower)
		return self.width
	end,	
	postCreate = function (self)
		self.secondaryPower = ns.EmberDisplay:instance({
			parentFrame = self.frame
		})
		self.secondaryPower:point('BOTTOM', self.frame, 'TOP', 0, -1)

		local backdraft = ns.BuffStackDisplay:instance({
			parentFrame = self.frame,
			spellId = A_BACKDRAFT,
			color = {0.9, 0.1, 0.1},
			maxAmount = 6,
		})
		backdraft:point('TOP', self.frame, 'BOTTOM', 0, 1)
		self:registerUnitAuraWatcher(backdraft)

		self.frame:SetPoint('TOP', UIParent, 'CENTER', 0, self.horizontalOffset)
	end,
}))

ns.Play:registerControl(ns.PowerDisplay:extend({
	specId = AFFLICTION,
	powerType = 'MANA',
	calculateWidth = function (self, maxPower)
		return self.width
	end,	
	postCreate = function (self)
		self.secondaryPower = ns.SecondaryPowerDisplay:instance({
			color = {0.58, 0.51, 0.79, 1},
			powerType = SPELL_POWER_SOUL_SHARDS,
			parentFrame = self.frame
		})
		self.secondaryPower:point('BOTTOM', self.frame, 'TOP', 0, -1)
		self.frame:SetPoint('TOP', UIParent, 'CENTER', 0, self.horizontalOffset)
	end,
}))