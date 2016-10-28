-- luacheck: globals game script defines

local TICKS   = 1
local SECONDS = 60 * TICKS
local MINUTES = 60 * SECONDS

local delay     = 2 * MINUTES -- delay between obituaries
local threshold = 0

local is_water = {
  [ 'water'           ] = true;
  [ 'water-green'     ] = true;
  [ 'deepwater'       ] = true;
  [ 'deepwater-green' ] = true;
}

local cause_of_death = {
--.cfg file    # locale keys
  friend     = 2;
  enemy      = 5;
  locomotive = 30;
  unit       = 13;
  fire       = 9;
  water      = 8;
  fish       = 2;
  unknown    = 30;
}

local random = math.random 

local function on_died( event )
  if event.tick < threshold or event.entity.type ~= 'player' then return end

  threshold = event.tick + delay -- prevent obituary spam in large MP games

  local player  = event.entity
  local surface = player.surface
  local suspect

  -- guess how they died

  if event.force and event.tick % 3 == 0 then -- killed by...?

    local killed_by = event.force == player.force and 'friend' or 'enemy'

    suspect = cause_of_death[ killed_by ]

    return game.print { killed_by .. '-' .. random( 1, suspect ), player.name, event.force }


  elseif is_water[ surface.get_tile( player.position ).name ] then -- drowned

    suspect = cause_of_death.water

    local water_name = { 'tile-name.'..surface.get_tile( player.position ).name }

    return game.print { 'water-' .. random( 1, suspect ), player.name, water_name }


  else -- search for other suspects

    local x, y   = player.position.x, player.position.y
    local nearby = surface.find_entities { { x-1, y-1 }, { x+1, y+1 } }
    local type

    for _, entity in pairs( nearby ) do

      type = entity.type

      suspect = cause_of_death[ type ]

      if suspect then
        return game.print { type .. '-' .. random( 1, suspect ), player.name, {'entity-name.'..entity.name} }
      end

    end--for


    -- cause unknown
    suspect = cause_of_death.unknown

    return game.print { 'unknown-' .. random( 1, suspect ), player.name }

  end

end--on_died

script.on_event( defines.events.on_entity_died, on_died )
