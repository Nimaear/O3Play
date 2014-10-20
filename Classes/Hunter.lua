local addon, ns = ...

local _, class = UnitClass('player')
if (class ~= "HUNTER") then
	return
end

local GetTime = GetTime
local A_FRENZY = 19615

local BEAST_MASTERY = 1

ns.Play:registerControl(ns.PowerDisplay:extend({
	specId = BEAST_MASTERY,
	powerType = 'FOCUS',
	postCreate = function (self)

		local frenzy = ns.BuffStackDisplay:instance({
			parentFrame = self.frame,
			spellId = A_FRENZY,
			maxAmount = 5,
		})
		frenzy:point('TOP', self.frame, 'BOTTOM', 0, 1)
		self:registerUnitAuraWatcher(frenzy)
		self.frame:SetPoint('TOP', UIParent, 'CENTER', 0, self.horizontalOffset)
	end,
}))
