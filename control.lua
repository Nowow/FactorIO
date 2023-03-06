require "config"
require "prototypes.combinators"
require "functions"

local function updateFiringRangeVar()
	if not global.firing_radius then
		global.firing_radius = 224
	end
	local artillery_range_research = game.forces.player.technologies["artillery-shell-range-1"]
	local research_level = artillery_range_research.level - 1
	game.print("Research level is " .. research_level)

	local research_range_modifier = 0
	for _, effect in pairs(artillery_range_research.effects) do
		if effect.type == "artillery-range" then
			research_range_modifier = effect.modifier
			break
		end
	end
	game.print("Research range modifier is " .. research_range_modifier)

	global.firing_radius = 224 + math.floor(224 * research_range_modifier*research_level) - 20
	game.print("Set var firing_radius as " .. global.firing_radius)


end

function initGlobal()
	if not global.signals then
		global.signals = {}
	end
	if not global.firing_radius then
		updateFiringRangeVar()
	end
	local signals = global.signals
	if not signals.combinators then
		signals.combinators = {}
	end
	
	for _,entry in pairs(signals.combinators) do
		if not entry.data then entry.data = {} end
	end
end

script.on_configuration_changed(function(data)
	initGlobal(true)
end)

script.on_init(function()
	initGlobal(true)
end)

function shouldTick(entry)
	--game.print("Checking " .. entry.id .. " @ " .. entry.tick_rate .. " + " .. entry.tick_offset .. " #" .. (game.tick%entry.tick_rate))
	return entry and game.tick%entry.tick_rate == entry.tick_offset
end

script.on_event(defines.events.on_tick, function(event)
	if event.tick%maximumTickRate == 0 then
		local signals = global.signals
		for unit,entry in pairs(signals.combinators) do
			if shouldTick(entry) then
				if not tickCombinator(entry, event.tick) then
					signals.combinators[unit] = nil
				end
			end
		end		
	end
end)

local function onEntityRemoved(entity)
	if entity.unit_number then
		global.signals.combinators[entity.unit_number] = nil
	end
end

local function onEntityAdded(entity)
	if entity.type == "constant-combinator" then
		local id = string.sub(entity.name, 12)
		if typeExists(id) then
			local rate = getTickRate(id)
			local ramp = getRampRate(id)
			local offset = maximumTickRate*math.random(0, math.floor(rate/maximumTickRate)-1)
			local entry = {entity = entity, id = id, tick_rate = rate, tick_offset = offset}
			if ramp then
				entry.base_tick_rate = rate
				entry.ramp_rate = ramp
				entry.tick_rate = ramp
			end
			global.signals.combinators[entity.unit_number] = entry
			
			game.print("Added combinator of type " .. global.signals.combinators[entity.unit_number].id .. ", tick rate of " .. rate .. " with offset of " .. global.signals.combinators[entity.unit_number].tick_offset)
			if ramp then
				game.print("Ramping from " .. entry.base_tick_rate .. " to " .. entry.ramp_rate)
			end
			
		end
	end
end

script.on_event(defines.events.on_entity_died, function(event)
	onEntityRemoved(event.entity)	
end)

script.on_event(defines.events.on_pre_player_mined_item, function(event)
	onEntityRemoved(event.entity)
end)

script.on_event(defines.events.on_robot_pre_mined, function(event)
	onEntityRemoved(event.entity)
end)

script.on_event(defines.events.on_built_entity, function(event)
	onEntityAdded(event.created_entity)
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
	onEntityAdded(event.created_entity)
end)

script.on_event(defines.events.on_research_finished, function(event)

	if event.research.name == "artillery-shell-range-1" then
		game.print("Research happened, research is art range!")
		updateFiringRangeVar()
	end
end)