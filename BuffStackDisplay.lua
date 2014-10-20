local addon, ns = ...

ns.BuffStackDisplay = O3.UI.Panel:extend({
	spellId = nil,
	maxAmount = 0,
	width = 181,
	height = 10,
	texture = O3.Media:statusBar('Stone'),
	color = {1,0.5,0,1},
	highColor = {1, 0.1, 0, 1},
	enabled = true,
	calculateWidth = function (self, stacks)
		return ((self.width-1)/stacks)+1
	end,
	UNIT_AURA = function (self)	
		self.amount = 0
		local name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellId, canApplyAura, isBossDebuff, value1, value2, value3
		for i = 1, 40 do
			name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellId, canApplyAura, isBossDebuff, value1, value2, value3 = UnitAura('player', i, 'HELPFUL')
			if (name and spellId == self.spellId) then
				self.amount = count
				break
			elseif not name then
				break
			end
		end
		self:update()
	end,
	getColor = function (self, stackNo)
		if (stackNo > 10) then
			return self.highColor
		else
			return self.color
		end
	end,
	update = function (self)
		for i = 1, self.maxAmount do
			self.stacks[i].frame:SetValue(self.amount)
		end
	end,
	preInit = function (self)
		self.amount = 0
	end,
	style = function (self)
		self:createTexture({
			layer = 'BACKGROUND',
			subLayer = -7,
			color = {0.1, 0.1, 0.1, 0.7},
		})
	end,
	createRegions = function (self)
		self.stacks = {}
		if (self.maxAmount > 0) then
			self.stacks = {}
			local cols = self.maxAmount
			local reminder = 0
			if (self.maxAmount > 10) then
				cols = 10
				reminder = self.maxAmount - 10
			end
			local width = self:calculateWidth(cols)
			for i = 1, cols do
				local color = self:getColor(i)
				local stack = O3.UI.StatusBar:instance({
					texture = self.texture,
					parentFrame = self.frame,
					color = self:getColor(i),
					width = width,
					height = 10,
					min = i-1,
					max = i,
				})
				if i == 1 then
					stack:point('TOPLEFT', self.frame, 'TOPLEFT', 0, 0)
				else
					stack:point('LEFT', self.stacks[i-1].frame, 'RIGHT', -1, 0)
				end
				self.stacks[i] = stack
			end
			if (reminder > 0) then
				self.height = 19
				local width = self:calculateWidth(reminder)
				for i = 11, self.maxAmount do
					local color = self:getColor(i)
					local stack = O3.UI.StatusBar:instance({
						texture = self.texture,
						parentFrame = self.frame,
						color = self:getColor(i),
						width = width,
						height = 10,
						min = i-1,
						max = i,
					})
					if i == 11 then
						stack:point('TOPLEFT', self.stacks[1].frame, 'BOTTOMLEFT', 0, 1)
					else
						stack:point('LEFT', self.stacks[i-1].frame, 'RIGHT', -1, 0)
					end
					self.stacks[i] = stack					
				end
			end
		end
	end,
	reset = function (self)
		self:UNIT_AURA()
	end,
})
