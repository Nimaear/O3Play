local addon, ns = ...

local _, class = UnitClass('player')
if (class ~= "WARRIOR") then
	return
end

local GetTime = GetTime
local A_MEATCLEAVER = 85739
local A_RAGINGBLOW = 131116
local A_BLOODSURGE = 46916

local ARMS = 1
local FURY = 2
local PROTECTION = 3

ns.Play:registerControl(ns.PowerDisplay:extend({
	specId = FURY,
	powerType = 'RAGE',
	postCreate = function (self)

		local meatCleaver = ns.BuffStackDisplay:instance({
			parentFrame = self.frame,
			spellId = A_MEATCLEAVER,
			color = {0.9, 0.9, 0.1},
			maxAmount = 4,
		})
		meatCleaver:point('BOTTOM', self.frame, 'TOP', 0, -1)
		self:registerUnitAuraWatcher(meatCleaver)

		local ragingBlow = ns.BuffStackDisplay:instance({
			parentFrame = self.frame,
			spellId = A_RAGINGBLOW,
			maxAmount = 2,
		})
		ragingBlow:point('TOP', self.frame, 'BOTTOM', 0, 1)
		self:registerUnitAuraWatcher(ragingBlow)

		local bloodSurge = ns.BuffStackDisplay:instance({
			parentFrame = self.frame,
			spellId = A_BLOODSURGE,
			color = {0.9, 0.1, 0.1},
			maxAmount = 2,
		})
		bloodSurge:point('TOP', ragingBlow.frame, 'BOTTOM', 0, 1)
		self:registerUnitAuraWatcher(bloodSurge)

		self.frame:SetPoint('TOP', UIParent, 'CENTER', 0, self.horizontalOffset)
	end,
}))


-- ns.Play:registerControl(ns.PowerDisplay:extend({
-- 	specId = PROTECTION,
-- 	powerType = 'RAGE',
-- 	postCreate = function (self)

-- 		local thrill = ns.BuffStackDisplay:instance({
-- 			parentFrame = self.frame,
-- 			spellId = A_THRILLOFTHEHUNT,
-- 			color = {0.1, 0.7, 0.9},
-- 			maxAmount = 3,
-- 		})
-- 		thrill:point('TOP', self.frame, 'BOTTOM', 0, 1)
-- 		self:registerUnitAuraWatcher(thrill)
-- 		self.frame:SetPoint('TOP', UIParent, 'CENTER', 0, self.horizontalOffset)
-- 	end,
-- }))

ns.Play:registerControl(ns.PowerDisplay:extend({
	specId = ARMS,
	powerType = 'RAGE',
	postCreate = function (self)

		local thrill = ns.BuffStackDisplay:instance({
			parentFrame = self.frame,
			spellId = A_THRILLOFTHEHUNT,
			color = {0.1, 0.7, 0.9},
			maxAmount = 3,
		})
		thrill:point('TOP', self.frame, 'BOTTOM', 0, 1)
		self:registerUnitAuraWatcher(thrill)
		self.frame:SetPoint('TOP', UIParent, 'CENTER', 0, self.horizontalOffset)
	end,
}))
