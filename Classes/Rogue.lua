local addon, ns = ...

local _, class = UnitClass('player')
if (class ~= "ROGUE") then
	return
end

local SPELL_POWER_COMBO_POINTS = 4
local A_ANTICIPATION = 115189
local COMBAT = 2
local SUBTLETY = 3

ns.Play:registerControl(ns.PowerDisplay:extend({
	specId = SUBTLETY,
	powerType = 'ENERGY',
	calculateWidth = function (self, maxPower)
		return self.width
	end,	
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

		local dotWatcher = ns.DotWatcher:instance({
			parentFrame = self.frame,
			auras = {
				player = {
					['PLAYER|HELPFUL'] = {
						[5171] = {false, false},
					}
				},
				target = {
					['PLAYER|HARMFUL'] = {
						[91021] = {false, false},
						[16511] = {true, false, 'Suffering (%d+) .*'},
						[1943] = {true, false, 'Suffering (%d+) .*'},
					}
				}
			},
		})
		dotWatcher:point('BOTTOM', self.secondaryPower.frame, 'TOP', 0, 20)		
	end,
	-- PLAYER_ENTERING_WORLD = function (self)
	-- 	self:create()
	-- 	self:postCreate()
	-- 	self.frame:UnregisterEvent('PLAYER_ENTERING_WORLD')
	-- 	self:enable()
	-- end,	
}))

ns.Play:registerControl(ns.PowerDisplay:extend({
	specId = COMBAT,
	calculateWidth = function (self, maxPower)
		return self.width
	end,	
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

		local dotWatcher = ns.DotWatcher:instance({
			parentFrame = self.frame,
			auras = {
				player = {
					['PLAYER|HELPFUL'] = {
						[5171] = {false, false},
					}
				},
				target = {
					['PLAYER|HARMFUL'] = {
						[84617] = {false, false},
					}
				}
			},

		})
		dotWatcher:point('BOTTOM', self.secondaryPower.frame, 'TOP', 0, 20)		
	end,
	-- PLAYER_ENTERING_WORLD = function (self)
	-- 	self:create()
	-- 	self:postCreate()
	-- 	self.frame:UnregisterEvent('PLAYER_ENTERING_WORLD')
	-- 	self:enable()
	-- end,	
}))
