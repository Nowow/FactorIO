local callbacks = {}

---AVOID FUNCTION NAME CONFLICTS, WHICH WILL CONFUSE THE DECLARATIONS IN COMBINATORS
---ALSO IF ANY CALLS OR THEIR NAMES CHANGE, GAME NEEDS RESTART THEN COMBINATORS NEED TO BE BROKEN AND REPLACED

local function getBox(entity)
	return moveBox(entity.prototype.collision_box, entity.position.x, entity.position.y)	
end


function getNearEnemies(entity) --stagger calls to this one
	local forces = {game.forces.enemy}
	if game.forces.wisp_attack then
		table.insert(forces, game.forces.wisp_attack)
	end
	if game.forces["biter_faction_1"] then
		for i = 1,5 do
			table.insert(forces, game.forces["biter_faction_" .. i])
		end
	end
	return #entity.surface.find_entities_filtered({type = "unit", area = {{entity.position.x-24, entity.position.y-24}, {entity.position.x+24, entity.position.y+24}}, force = forces})
end

function getNearEnemyStructures(entity)
	local forces = {game.forces.enemy}
	if game.forces.wisp_attack then
		table.insert(forces, game.forces.wisp_attack)
	end
	if game.forces["biter_faction_1"] then
		for i = 1,5 do
			table.insert(forces, game.forces["biter_faction_" .. i])
		end
	end
	local position_x = entity.position.x
	local position_y = entity.position.y
	local radius = global.firing_radius
	return #entity.surface.find_entities_filtered({type = "unit-spawner", position={position_x, position_y}, radius=radius, force = forces})
end

function runCallback(id, entity, data, connection)
	local func = callbacks[id]
	if func then
		--game.print("Running callback for combinator " .. id)
		return func(entity, data, connection)
	else
		game.print("Could not find callback for entity " .. entity.name .. ", ID = " .. id .. "!")
		return 0
	end
end

function registerCall(id, callback)
	callbacks[id] = callback
end

function typeExists(id)
	return callbacks[id] ~= nil
end