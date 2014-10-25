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

local A_LUNAR_EMPOWERMENT = 164547
local A_SOLAR_EMPOWERMENT = 164545

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
		self.secondaryPower = ns.EclipseDisplay:instance({
			parentFrame = self.frame
		})
		self.secondaryPower:point('BOTTOM', self.frame, 'TOP', 0, -1)		
		self.frame:SetPoint('TOP', UIParent, 'CENTER', 0, self.horizontalOffset)

		local solarEmpowerMent = ns.BuffStackDisplay:instance({
			parentFrame = self.frame,
			color = {0.8, 0.4, 0.2, 1},
			spellId = A_SOLAR_EMPOWERMENT,
			maxAmount = 3,
		})

		solarEmpowerMent:point('TOP', self.frame, 'BOTTOM', 0, 1)
		self:registerUnitAuraWatcher(solarEmpowerMent)

		local lunarEmpowerMent = ns.BuffStackDisplay:instance({
			parentFrame = self.frame,
			color = {0.2, 0.4, 0.8, 1},
			spellId = A_LUNAR_EMPOWERMENT,
			maxAmount = 2,
		})

		lunarEmpowerMent:point('TOP', solarEmpowerMent.frame, 'BOTTOM', 0, 1)
		self:registerUnitAuraWatcher(lunarEmpowerMent)

	end,
}))