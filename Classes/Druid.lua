local addon, ns = ...

local _, class = UnitClass('player')
if (class ~= "DRUID") then
	return
end


local BALANCE = 1
local FERAL = 2
local GUARDIAN = 3
local RESTORATION = 4
local SPELL_POWER_COMBO_POINTS = 4

ns.Play:registerControl(ns.PowerDisplay:extend({
	specId = RESTORATION,
	powerType = 'ENERGY',
	comboPoints = true,
	postCreate = function (self)
		self.secondaryPower = ns.SecondaryPowerDisplay:instance({
			color = {0.9, 0.81, 0.19, 1},
			powerType = SPELL_POWER_COMBO_POINTS,
			parentFrame = self.frame
		})
		self.secondaryPower:point('BOTTOM', self.frame, 'TOP', 0, -1)		self.frame:SetPoint('TOP', UIParent, 'CENTER', 0, self.horizontalOffset)
	end,
}))

ns.Play:registerControl(ns.PowerDisplay:extend({
	specId = FERAL,
	powerType = 'ENERGY',
	comboPoints = true,
	postCreate = function (self)
		self.secondaryPower = ns.SecondaryPowerDisplay:instance({
			color = {0.9, 0.81, 0.19, 1},
			powerType = SPELL_POWER_COMBO_POINTS,
			parentFrame = self.frame
		})
		self.secondaryPower:point('BOTTOM', self.frame, 'TOP', 0, -1)		self.frame:SetPoint('TOP', UIParent, 'CENTER', 0, self.horizontalOffset)
	end,
}))

ns.Play:registerControl(ns.PowerDisplay:extend({
	specId = GUARDIAN,
	powerType = 'ENERGY',
	comboPoints = true,
	postCreate = function (self)
		self.secondaryPower = ns.SecondaryPowerDisplay:instance({
			color = {0.9, 0.81, 0.19, 1},
			powerType = SPELL_POWER_COMBO_POINTS,
			parentFrame = self.frame
		})
		self.secondaryPower:point('BOTTOM', self.frame, 'TOP', 0, -1)		self.frame:SetPoint('TOP', UIParent, 'CENTER', 0, self.horizontalOffset)
	end,
}))

ns.Play:registerControl(ns.PowerDisplay:extend({
	specId = BALANCE,
	powerType = 'ENERGY',
	comboPoints = true,
	postCreate = function (self)
		self.secondaryPower = ns.SecondaryPowerDisplay:instance({
			color = {0.9, 0.81, 0.19, 1},
			powerType = SPELL_POWER_COMBO_POINTS,
			parentFrame = self.frame
		})
		self.secondaryPower:point('BOTTOM', self.frame, 'TOP', 0, -1)		self.frame:SetPoint('TOP', UIParent, 'CENTER', 0, self.horizontalOffset)
	end,
}))