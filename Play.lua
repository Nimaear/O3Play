local addon, ns = ...

ns.Play = O3:module({
	name = 'Play',
	initialized = false,
	specControls = {
		
	},
	specHandlers = {

	},
	specId = nil,
	controls = function (self)
	end,
	config = {
		enabled = true
	},
	events = {
		PLAYER_ENTERING_WORLD = true,
		PLAYER_SPECIALIZATION_CHANGED = true,
		ACTIVE_TALENT_GROUP_CHANGED = true,
	},
	PLAYER_ENTERING_WORLD = function (self)
		self:PLAYER_SPECIALIZATION_CHANGED()
		--self:unregisterEvent('PLAYER_ENTERING_WORLD')
	end,
	preInit = function (self)
		self.ACTIVE_TALENT_GROUP_CHANGED = self.PLAYER_SPECIALIZATION_CHANGED
	end,
	PLAYER_SPECIALIZATION_CHANGED = function (self)
		local control
		if (self.specId) then
			control = self:getSpecControl(self.specId)
			if (control) then
				control:disable()
			end
		end
		self.specId = GetSpecialization()
		if (self.specId) then
			control = self:getSpecControl(self.specId)
			if (control) then
				control:enable()
			end
		end
	end,
	createSpecControl = function (self, specId)
		if (not self.specHandlers[specId]) then
			return nil
		end
		local control = self.specHandlers[specId]:instance({})
		control:PLAYER_ENTERING_WORLD()
		return control
	end,
	getSpecControl = function (self, specId)
		self.specControls[specId] = self.specControls[specId] or self:createSpecControl(specId)
		return self.specControls[specId]
	end,
	registerControl = function (self, control)
		self.specHandlers[control.specId] = control
	end,
})

