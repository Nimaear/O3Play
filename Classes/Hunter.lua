local addon, ns = ...

local _, class = UnitClass('player')
if (class ~= "HUNTER") then
	return
end

local GetTime = GetTime
local A_FRENZY = 19615
local A_THRILLOFTHEHUNT = 34720

local BEAST_MASTERY = 1
local MARKSMAN = 2
local SURVIVAL = 3

ns.Play:registerControl(ns.PowerDisplay:extend({
	specId = BEAST_MASTERY,
	powerType = 'FOCUS',
	postCreate = function (self)

		local frenzy = ns.BuffStackDisplay:instance({
			parentFrame = self.frame,
			spellId = A_FRENZY,
			color = {0.9, 0.9, 0.1},
			maxAmount = 5,
		})
		frenzy:point('BOTTOM', self.frame, 'TOP', 0, -1)
		self:registerUnitAuraWatcher(frenzy)

		local thrill = ns.BuffStackDisplay:instance({
			parentFrame = self.frame,
			spellId = A_THRILLOFTHEHUNT,
			maxAmount = 3,
		})
		thrill:point('TOP', self.frame, 'BOTTOM', 0, 1)
		self:registerUnitAuraWatcher(thrill)

		self.frame:SetPoint('TOP', UIParent, 'CENTER', 0, self.horizontalOffset)
	end,
}))


ns.Play:registerControl(ns.PowerDisplay:extend({
	specId = SURVIVAL,
	powerType = 'FOCUS',
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

ns.Play:registerControl(ns.PowerDisplay:extend({
	specId = MARKSMAN,
	powerType = 'FOCUS',
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
