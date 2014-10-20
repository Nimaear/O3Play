local addon, ns = ...

local _, class = UnitClass('player')
if (class ~= "PALADIN") then
	return
end

local RETRIBUTION = 3

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
		self.frame:SetPoint('TOP', UIParent, 'CENTER', 0, self.horizontalOffset)
	end,
}))

