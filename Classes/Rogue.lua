local addon, ns = ...

local _, class = UnitClass('player')
if (class ~= "ROGUE") then
	return
end

local SPELL_POWER_COMBO_POINTS = 4
local A_ANTICIPATION = 115189

local energy = ns.PowerDisplay:instance({
	powerType = 'ENERGY',
	comboPoints = true,
	postCreate = function (self)

		self.secondaryPower = ns.SecondaryPowerDisplay:instance({
			color = {0.9, 0.81, 0.19, 1},
			powerType = SPELL_POWER_COMBO_POINTS,
			parentFrame = self.frame
		})
		self.secondaryPower:point('BOTTOM', self.frame, 'TOP', 0, -1)

		local anticipation = ns.BuffStackDisplay:instance({
			parentFrame = self.frame,
			spellId = A_ANTICIPATION,
			maxAmount = 5,
		})

		anticipation:point('TOP', self.frame, 'BOTTOM', 0, 1)
		self:registerUnitAuraWatcher(anticipation)
		self.frame:SetPoint('TOP', UIParent, 'CENTER', 0, self.horizontalOffset)
	end,
	PLAYER_ENTERING_WORLD = function (self)
		self:create()
		self:postCreate()
		self.frame:UnregisterEvent('PLAYER_ENTERING_WORLD')
		self:enable()
	end,	
})

