local addon, ns = ...

local _, class = UnitClass('player')
if (class ~= "SHAMAN") then
	return
end

local GetTime = GetTime
local A_TIDALWAVES = 53390
local A_LIGHTNINGSHIELD = 324
local A_MAELSTROMWEAPON = 53817

local RESTORATION = 3
local ENHANCEMENT = 2
local ELEMENTAL = 1

ns.Play:registerControl(ns.PowerDisplay:extend({
	specId = RESTORATION,
	powerType = 'MANA',
	postCreate = function (self)

		local tidalWaves = ns.BuffStackDisplay:instance({
			parentFrame = self.frame,
			spellId = A_TIDALWAVES,
			maxAmount = 2,
		})
		tidalWaves:point('TOP', self.frame, 'BOTTOM', 0, 1)
		self:registerUnitAuraWatcher(tidalWaves)
		self.frame:SetPoint('TOP', UIParent, 'CENTER', 0, self.horizontalOffset)
	end,
}))

ns.Play:registerControl(ns.PowerDisplay:extend({
	specId = ELEMENTAL,
	powerType = 'MANA',
	postCreate = function (self)

		local lightningShield = ns.BuffStackDisplay:instance({
			parentFrame = self.frame,
			color = {0.1, 0.8, 0.8},
			spellId = A_LIGHTNINGSHIELD,
			maxAmount = 15,
		})
		lightningShield:point('TOP', self.frame, 'BOTTOM', 0, 1)
		self:registerUnitAuraWatcher(lightningShield)
		self.frame:SetPoint('TOP', UIParent, 'CENTER', 0, self.horizontalOffset)
	end,
}))

ns.Play:registerControl(ns.PowerDisplay:extend({
	specId = ENHANCEMENT,
	powerType = 'MANA',
	postCreate = function (self)

		local maelstrom = ns.BuffStackDisplay:instance({
			parentFrame = self.frame,
			color = {0.1, 0.8, 0.8},
			spellId = A_MAELSTROMWEAPON,
			maxAmount = 5,
		})
		maelstrom:point('TOP', self.frame, 'BOTTOM', 0, 1)
		self:registerUnitAuraWatcher(maelstrom)
		self.frame:SetPoint('TOP', UIParent, 'CENTER', 0, self.horizontalOffset)
	end,
}))
