local addon, ns = ...

local _, class = UnitClass('player')
if (class ~= "PALADIN") then
	return
end

local RETRIBUTION = 3
local A_SELFLESSHEALER = 114250

ns.Play:registerControl(ns.PowerDisplay:extend({
	specId = RETRIBUTION,
	powerType = 'MANA',
	postCreate = function (self)
		self.secondaryPower = ns.SecondaryPowerDisplay:instance({
			color = {0.9, 0.81, 0.19, 1},
			powerType = SPELL_POWER_HOLY_POWER,
			parentFrame = self.frame
		})
		self.secondaryPower:point('BOTTOM', self.frame, 'TOP', 0, -1)

		local selflessHealer = ns.BuffStackDisplay:instance({
			parentFrame = self.frame,
			spellId = A_SELFLESSHEALER,
			color = {0.1, 0.9, 0.1},
			maxAmount = 3,
		})
		selflessHealer:point('TOP', self.frame, 'BOTTOM', 0, 1)
		self:registerUnitAuraWatcher(selflessHealer)

		self.frame:SetPoint('TOP', UIParent, 'CENTER', 0, self.horizontalOffset)
	end,
}))

