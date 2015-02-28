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

local A_TIGERSFURY = 5217
local A_SAVAGEROAR2 = 174544
local A_SAVAGEROAR = 52610
local A_KINGOFTHEJUNGLE = 102543
local A_BLOODTALONS = 145152
local A_RIP = 1079
local A_RAKE = 155722

local FeralAuraWatcher = ns.DotWatcher:extend({
	rakeStrength = 2,
	hasRoar = false,
	hasStealth = false,
	hasFury = false,
	hasKingOfTheJungle = false,
	hasBloodtalons = false,	
	listeners = {
		[A_TIGERSFURY] = 'tigersFury',
		[A_SAVAGEROAR] = 'savageRoar',
		[A_SAVAGEROAR2] = 'savageRoar',
		[A_KINGOFTHEJUNGLE] = 'kingOfTheJungle',
		[A_BLOODTALONS] = 'bloodTalons',
		[A_RIP] = 'rip',
		[A_RAKE] = 'rake',
	},
	auras = {
		player = {
			['PLAYER|HELPFUL'] = {
				[5217] = {false, false},
				[52610] = {false, false},
			}
		},
		target = {
			['PLAYER|HARMFUL'] = {
				[155722] = {true, true, "Bleeding for (%d+) .*"},
				[1079] = {true, true, "Bleeding for (%d+) .*"},
			}
		}
	},
	postCreate = function(self)
		self:PLAYER_TARGET_CHANGED()
		O3.AuraWatcher:register(A_TIGERSFURY, self)
		O3.AuraWatcher:register(A_BLOODTALONS, self)
		O3.AuraWatcher:register(A_SAVAGEROAR, self)
		O3.AuraWatcher:register(A_SAVAGEROAR2, self)
		O3.AuraWatcher:register(A_KINGOFTHEJUNGLE, self)
		self.icons['player-'..A_SAVAGEROAR2] = self.icons['player-'..A_SAVAGEROAR]
	end,	
	tigersFury = function (self, action, spellId, foundUnitId, destGUID, destName, casterIsPlayer)
		if (action == 'apply' or action == 'refresh') then
			self.hasFury = true
		else
			self.hasFury = false
		end
	end,
	savageRoar = function (self, action, spellId, foundUnitId, destGUID, destName, casterIsPlayer)
		if (action == 'apply' or action == 'refresh') then
			self.hasRoar = true
		else
			self.hasRoar = false
		end
	end,
	kingOfTheJungle = function (self, action, spellId, foundUnitId, destGUID, destName, casterIsPlayer)
		if (action == 'apply' or action == 'refresh') then
			self.hasKingOfTheJungle = true
		else
			self.hasKingOfTheJungle = false
		end
	end,
	bloodTalons = function (self, action, spellId, foundUnitId, destGUID, destName, casterIsPlayer)
		if (action == 'apply' or action == 'refresh') then
			self.hasBloodtalons = true
		else
			self.hasBloodtalons = false
		end
	end,
	rip = function (self, action, spellId, foundUnitId, destGUID, destName, casterIsPlayer)
		if (action == 'apply' or action == 'refresh') then
			self:calculateStrength()
			
			self.cache[destGUID..spellId] = self.strength
			if (not foundUnitId) then
				return
			end

			local iconKey = foundUnitId..'-'..spellId
			if (not self.icons[iconKey]) then
				return
			end
			self:updateStrength(self.icons[iconKey])
		else
			if (not foundUnitId) then
				return
			end
			if (foundUnitId) then
				local iconKey = foundUnitId..'-'..spellId
				if (not self.icons[iconKey]) then
					return
				end
				self.icons[iconKey]:desaturate(true)
			end
		end
	end,
	rake = function (self, action, spellId, foundUnitId, destGUID, destName, casterIsPlayer)
		if (action == 'apply' or action == 'refresh') then
			self:calculateStrength()
			
			self.cache[destGUID..spellId] = self.rakeStrength
			if (not foundUnitId) then
				return
			end

			local iconKey = foundUnitId..'-'..spellId
			if (not self.icons[iconKey]) then
				return
			end
			self:updateStrength(self.icons[iconKey])
		else
			if (not foundUnitId) then
				return
			end
			if (foundUnitId) then
				local iconKey = foundUnitId..'-'..spellId
				if (not self.icons[iconKey]) then
					return
				end
				self.icons[iconKey]:desaturate(true)
			end
		end	
	end,
	calculateStrength = function (self)
		local multiplier = 1
		if (self.hasRoar) then
			multiplier = multiplier * 1.4
		end
		if (self.hasFury) then
			multiplier = multiplier * 1.15
		end
		if (self.hasBloodtalons) then
			multiplier = multiplier * 1.3
		end
		self.strength = multiplier
		if (self.hasKingOfTheJungle or IsStealthed()) then
			multiplier = multiplier * 2
		end
		self.rakeStrength = multiplier
	end,	
})

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
		self.secondaryPower:point('BOTTOM', self.frame, 'TOP', 0, -1)		
		self.frame:SetPoint('TOP', UIParent, 'CENTER', 0, self.horizontalOffset)

		local dotWatcher = FeralAuraWatcher:instance({
			parentFrame = self.frame,
		})
		dotWatcher:point('BOTTOM', self.secondaryPower.frame, 'TOP', 0, 20)			
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