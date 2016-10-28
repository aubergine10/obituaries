-- luacheck: globals game script defines

local TICKS   = 1
local SECONDS = 60 * TICKS
local MINUTES = 60 * SECONDS

local delay     = 2 * MINUTES -- delay between obituaries
local threshold = 0

local range = 2 -- entity search range

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

  local __1__ = player.name
  local __2__, __3__ -- depends on cause of death



--[[ KILLED BY ]]--
-- throttled so it's rare; entity-based obituaries are more fun
  if event.force and ( event.tick % 7 == 0 ) then

    __2__ = event.force.name
    __3__ = player.force.name

    local killed_by = ( __2__ == __3__ ) and 'friend' or 'enemy'
    suspect = cause_of_death[ killed_by ]
    return game.print { killed_by .. '-' .. random( 1, suspect ), __1__, __2__, __3__ }


--[[ DROWNED ]]--
  elseif is_water[ surface.get_tile( player.position ).name ] then

    __2__ = { 'tile-name.'..surface.get_tile( player.position ).name }

    suspect = cause_of_death.water
    return game.print { 'water-' .. random( 1, suspect ), __1__, __2__ }


--[[ ENTITY SEARCH ]]--
  else

    local x, y   = player.position.x, player.position.y
    local nearby = surface.find_entities { { x-range, y-range }, { x+range, y+range } }

    for _, entity in pairs( nearby ) do
      suspect = cause_of_death[ entity.type ]

      if suspect then
        __2__ = { 'entity-name.' .. entity.name }
        __3__ = entity.type

        return game.print { entity.type .. '-' .. random( 1, suspect ), __1__, __2__, __3__ }
      end

    end--for


--[[ UNKNOWN ]]--
    suspect = cause_of_death.unknown
    return game.print { 'unknown-' .. random( 1, suspect ), __1__ }

  end

end--on_died

script.on_event( defines.events.on_entity_died, on_died )
