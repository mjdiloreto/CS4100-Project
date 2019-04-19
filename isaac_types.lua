-- reverse tables for enums
GridEntityEnumReverse = makeReverseTable(GridEntityType)
DoorSlotEnumReverse = makeReverseTable(DoorSlot)
RoomTypeEnumReverse = makeReverseTable(RoomType)

-- returns a string representing the enum type of the grid entity at the given index
-- 1 --> GRID_DECORATION
-- 2 --> GRID_ROCK
-- 3 --> GRID_ROCKB
-- 4 --> GRID_ROCKT
-- 5 --> GRID_ROCK_BOMB
-- 6 --> GRID_ROCK_ALT
-- 7 --> GRID_PIT
-- 8 --> GRID_SPIKES
-- 9 --> GRID_SPIKES_ONOFF
-- 10 --> GRID_SPIDERWEB
-- 11 --> GRID_LOCK
-- 12 --> GRID_TNT
-- 13 --> GRID_FIREPLACE
-- 14 --> GRID_POOP
-- 15 --> GRID_WALL
-- 16 --> GRID_DOOR
-- 17 --> GRID_TRAPDOOR
-- 18 --> GRID_STAIRS
-- 19 --> GRID_GRAVITY
-- 20 --> GRID_PRESSURE_PLATE
-- 21 --> GRID_STATUE
-- 22 --> GRID_ROCK_SS
function getGridType(gridIndex)
  local gridEntity = Game():GetRoom():GetGridEntity(gridIndex)
  if gridEntity ~= nil then
    return GridEntityEnumReverse[gridEntity:GetType()]
  end
  return ""
end

-- returns a string representing the enum type of the given game entity
function getEntityType(entity)

  local entityType = entity.Type
  local entityVariant = entity.Variant

  -- weird misc type that the game uses for random entities
  if entityType == 1000 then return "ENTITY_MISC" end

  -- filter bogus input
  if entityType < 0 or entityType > 225 then return nil end

  -- match type
  if entityType == 0   then return "ENTITY_NULL" end
  if entityType == 1   then return "ENTITY_PLAYER" end
  if entityType == 2   then return "ENTITY_TEAR" end
  if entityType == 3   then return "ENTITY_FAMILIAR" end
  if entityType == 4   then return "ENTITY_BOMBDROP" end

  -- there's a lot of different pickups lol
  if entityType == 5 then
    local pickupString = "ENTITY_PICKUP"
    local variantString = ""

    -- define variants
    if entityVariant == 20 then
      variantString = "COIN"
    elseif entityVariant == 40 then
      variantString = "BOMB"
    elseif entityVariant == 60 then
      variantString = "CHEST"
    elseif entityVariant == 69 then
      variantString = "BAG"
    elseif entityVariant == 30 then
      variantString = "KEY"
    elseif entityVariant == 100 then
      variantString = "PEDESTAL_ITEM"
    elseif entityVariant == 10 then
      variantString = "HEART"
    elseif entityVariant == 10 then
      variantString = "BUM"
    elseif entityVariant == 10 then
      variantString = "LOTTERY"
    elseif entityVariant == 340 then
      variantString = "TROPHY"
    end

    -- return string
    if variantString == "" then
      return pickupString
    else
      return pickupString .. "_" .. variantString
    end
  end

  if entityType == 6   then return "ENTITY_SLOT" end
  if entityType == 7   then return "ENTITY_LASER" end
  if entityType == 8   then return "ENTITY_KNIFE" end
  if entityType == 9   then return "ENTITY_PROJECTILE" end
  if entityType == 10  then return "ENTITY_GAPER" end
  if entityType == 11  then return "ENTITY_GUSHER" end
  if entityType == 12  then return "ENTITY_HORF" end
  if entityType == 13  then return "ENTITY_FLY" end
  if entityType == 14  then return "ENTITY_POOTER" end
  if entityType == 15  then return "ENTITY_CLOTTY" end
  if entityType == 16  then return "ENTITY_MULLIGAN" end
  if entityType == 17  then return "ENTITY_SHOPKEEPER" end
  if entityType == 18  then return "ENTITY_ATTACKFLY" end
  if entityType == 19  then return "ENTITY_LARRYJR" end
  if entityType == 20  then return "ENTITY_MONSTRO" end
  if entityType == 21  then return "ENTITY_MAGGOT" end
  if entityType == 22  then return "ENTITY_HIVE" end
  if entityType == 23  then return "ENTITY_CHARGER" end
  if entityType == 24  then return "ENTITY_GLOBIN" end
  if entityType == 25  then return "ENTITY_BOOMFLY" end
  if entityType == 26  then return "ENTITY_MAW" end
  if entityType == 27  then return "ENTITY_HOST" end
  if entityType == 28  then return "ENTITY_CHUB" end
  if entityType == 29  then return "ENTITY_HOPPER" end
  if entityType == 30  then return "ENTITY_BOIL" end
  if entityType == 31  then return "ENTITY_SPITY" end
  if entityType == 32  then return "ENTITY_BRAIN" end
  if entityType == 33  then return "ENTITY_FIREPLACE" end
  if entityType == 34  then return "ENTITY_LEAPER" end
  if entityType == 35  then return "ENTITY_MRMAW" end
  if entityType == 36  then return "ENTITY_GURDY" end
  if entityType == 37  then return "ENTITY_BABY" end
  if entityType == 38  then return "ENTITY_VIS" end
  if entityType == 39  then return "ENTITY_GUTS" end
  if entityType == 40  then return "ENTITY_KNIGHT" end
  if entityType == 41  then return "ENTITY_STONEHEAD" end
  if entityType == 42  then return "ENTITY_MONSTRO2" end
  if entityType == 43  then return "ENTITY_POKY" end
  if entityType == 44  then return "ENTITY_MOM" end
  if entityType == 45  then return "ENTITY_SLOTH" end
  if entityType == 46  then return "ENTITY_LUST" end
  if entityType == 47  then return "ENTITY_WRATH" end
  if entityType == 48  then return "ENTITY_GLUTTONY" end
  if entityType == 49  then return "ENTITY_GREED" end
  if entityType == 50  then return "ENTITY_ENVY" end
  if entityType == 51  then return "ENTITY_PRIDE" end
  if entityType == 52  then return "ENTITY_DOPLE" end
  if entityType == 53  then return "ENTITY_FLAMINGHOPPER" end
  if entityType == 54  then return "ENTITY_LEECH" end
  if entityType == 55  then return "ENTITY_LUMP" end
  if entityType == 56  then return "ENTITY_MEMBRAIN" end
  if entityType == 57  then return "ENTITY_PARA_BITE" end
  if entityType == 58  then return "ENTITY_FRED" end
  if entityType == 59  then return "ENTITY_EYE" end
  if entityType == 60  then return "ENTITY_SUCKER" end
  if entityType == 61  then return "ENTITY_PIN" end
  if entityType == 62  then return "ENTITY_FAMINE" end
  if entityType == 63  then return "ENTITY_PESTILENCE" end
  if entityType == 64  then return "ENTITY_WAR" end
  if entityType == 65  then return "ENTITY_DEATH" end
  if entityType == 66  then return "ENTITY_DUKE" end
  if entityType == 67  then return "ENTITY_PEEP" end
  if entityType == 68  then return "ENTITY_LOKI" end
  if entityType == 69  then return "ENTITY_FISTULA_BIG" end
  if entityType == 70  then return "ENTITY_FISTULA_MEDIUM" end
  if entityType == 71  then return "ENTITY_FISTULA_SMALL" end
  if entityType == 72  then return "ENTITY_BLASTOCYST_BIG" end
  if entityType == 73  then return "ENTITY_BLASTOCYST_MEDIUM" end
  if entityType == 74  then return "ENTITY_BLASTOCYST_SMALL" end
  if entityType == 75  then return "ENTITY_EMBRYO" end
  if entityType == 76  then return "ENTITY_MOMS_HEART" end
  if entityType == 77  then return "ENTITY_GEMINI" end
  if entityType == 78  then return "ENTITY_MOTER" end
  if entityType == 79  then return "ENTITY_FALLEN" end
  if entityType == 80  then return "ENTITY_HEADLESS_HORSEMAN" end
  if entityType == 81  then return "ENTITY_HORSEMAN_HEAD" end
  if entityType == 82  then return "ENTITY_SATAN" end
  if entityType == 83  then return "ENTITY_SPIDER" end
  if entityType == 84  then return "ENTITY_KEEPER" end
  if entityType == 85  then return "ENTITY_GURGLE" end
  if entityType == 86  then return "ENTITY_WALKINGBOIL" end
  if entityType == 87  then return "ENTITY_BUTTLICKER" end
  if entityType == 88  then return "ENTITY_HANGER" end
  if entityType == 89  then return "ENTITY_SWARMER" end
  if entityType == 90  then return "ENTITY_HEART" end
  if entityType == 91  then return "ENTITY_MASK" end
  if entityType == 92  then return "ENTITY_BIGSPIDER" end
  if entityType == 93  then return "ENTITY_ETERNALFLY" end
  if entityType == 94  then return "ENTITY_MASK_OF_INFAMY" end
  if entityType == 95  then return "ENTITY_HEART_OF_INFAMY" end
  if entityType == 96  then return "ENTITY_GURDY_JR" end
  if entityType == 97  then return "ENTITY_WIDOW" end
  if entityType == 98  then return "ENTITY_DADDYLONGLEGS" end
  if entityType == 99  then return "ENTITY_ISAAC" end
  if entityType == 100 then return "ENTITY_STONE_EYE" end
  if entityType == 101 then return "ENTITY_CONSTANT_STONE_SHOOTER" end
  if entityType == 102 then return "ENTITY_BRIMSTONE_HEAD" end
  if entityType == 103 then return "ENTITY_MOBILE_HOST" end
  if entityType == 104 then return "ENTITY_NEST" end
  if entityType == 105 then return "ENTITY_BABY_LONG_LEGS" end
  if entityType == 106 then return "ENTITY_CRAZY_LONG_LEGS" end
  if entityType == 107 then return "ENTITY_FATTY" end
  if entityType == 108 then return "ENTITY_FAT_SACK" end
  if entityType == 109 then return "ENTITY_BLUBBER" end
  if entityType == 110 then return "ENTITY_HALF_SACK" end
  if entityType == 111 then return "ENTITY_DEATHS_HEAD" end
  if entityType == 112 then return "ENTITY_MOMS_HAND" end
  if entityType == 113 then return "ENTITY_FLY_L2" end
  if entityType == 114 then return "ENTITY_SPIDER_L2" end
  if entityType == 115 then return "ENTITY_SWINGER" end
  if entityType == 116 then return "ENTITY_DIP" end
  if entityType == 117 then return "ENTITY_WALL_HUGGER" end
  if entityType == 118 then return "ENTITY_WIZOOB" end
  if entityType == 119 then return "ENTITY_SQUIRT" end
  if entityType == 120 then return "ENTITY_COD_WORM" end
  if entityType == 121 then return "ENTITY_RING_OF_FLIES" end
  if entityType == 122 then return "ENTITY_DINGA" end
  if entityType == 123 then return "ENTITY_OOB" end
  if entityType == 124 then return "ENTITY_BLACK_MAW" end
  if entityType == 125 then return "ENTITY_SKINNY" end
  if entityType == 126 then return "ENTITY_BONY" end
  if entityType == 127 then return "ENTITY_HOMUNCULUS" end
  if entityType == 128 then return "ENTITY_TUMOR" end
  if entityType == 129 then return "ENTITY_CAMILLO_JR" end
  if entityType == 130 then return "ENTITY_NERVE_ENDING" end
  if entityType == 131 then return "ENTITY_SKINBALL" end
  if entityType == 132 then return "ENTITY_MOM_HEAD" end
  if entityType == 133 then return "ENTITY_ONE_TOOTH" end
  if entityType == 134 then return "ENTITY_GAPING_MAW" end
  if entityType == 135 then return "ENTITY_BROKEN_GAPING_MAW" end
  if entityType == 136 then return "ENTITY_GURGLING" end
  if entityType == 137 then return "ENTITY_SPLASHER" end
  if entityType == 138 then return "ENTITY_GRUB" end
  if entityType == 139 then return "ENTITY_WALL_CREEP" end
  if entityType == 140 then return "ENTITY_RAGE_CREEP" end
  if entityType == 141 then return "ENTITY_BLIND_CREEP" end
  if entityType == 142 then return "ENTITY_CONJOINED_SPITTY" end
  if entityType == 143 then return "ENTITY_ROUND_WORM" end
  if entityType == 144 then return "ENTITY_POOP" end
  if entityType == 145 then return "ENTITY_RAGLING" end
  if entityType == 146 then return "ENTITY_FLESH_MOBILE_HOST" end
  if entityType == 147 then return "ENTITY_PSY_HORF" end
  if entityType == 148 then return "ENTITY_FULL_FLY" end
  if entityType == 149 then return "ENTITY_TICKING_SPIDER" end
  if entityType == 150 then return "ENTITY_BEGOTTEN" end
  if entityType == 151 then return "ENTITY_NULLS" end
  if entityType == 152 then return "ENTITY_PSY_TUMOR" end
  if entityType == 153 then return "ENTITY_FLOATING_KNIGHT" end
  if entityType == 154 then return "ENTITY_NIGHT_CRAWLER" end
  if entityType == 155 then return "ENTITY_DART_FLY" end
  if entityType == 156 then return "ENTITY_CONJOINED_FATTY" end
  if entityType == 157 then return "ENTITY_FAT_BAT" end
  if entityType == 158 then return "ENTITY_IMP" end
  if entityType == 159 then return "ENTITY_THE_HAUNT" end
  if entityType == 160 then return "ENTITY_DINGLE" end
  if entityType == 161 then return "ENTITY_MEGA_MAW" end
  if entityType == 162 then return "ENTITY_GATE" end
  if entityType == 163 then return "ENTITY_MEGA_FATTY" end
  if entityType == 164 then return "ENTITY_CAGE" end
  if entityType == 165 then return "ENTITY_MAMA_GURDY" end
  if entityType == 166 then return "ENTITY_DARK_ONE" end
  if entityType == 167 then return "ENTITY_ADVERSARY" end
  if entityType == 168 then return "ENTITY_POLYCEPHALUS" end
  if entityType == 169 then return "ENTITY_MR_FRED" end
  if entityType == 170 then return "ENTITY_URIEL" end
  if entityType == 171 then return "ENTITY_GABRIEL" end
  if entityType == 172 then return "ENTITY_THE_LAMB" end
  if entityType == 173 then return "ENTITY_MEGA_SATAN" end
  if entityType == 174 then return "ENTITY_MEGA_SATAN_2" end
  if entityType == 175 then return "ENTITY_ROUNDY" end
  if entityType == 176 then return "ENTITY_BLACK_BONY" end
  if entityType == 177 then return "ENTITY_BLACK_GLOBIN" end
  if entityType == 178 then return "ENTITY_BLACK_GLOBIN_HEAD" end
  if entityType == 179 then return "ENTITY_BLACK_GLOBIN_BODY" end
  if entityType == 180 then return "ENTITY_SWARM" end
  if entityType == 181 then return "ENTITY_MEGA_CLOTTY" end
  if entityType == 182 then return "ENTITY_BONE_KNIGHT" end
  if entityType == 183 then return "ENTITY_CYCLOPIA" end
  if entityType == 184 then return "ENTITY_RED_GHOST" end
  if entityType == 185 then return "ENTITY_FLESH_DEATHS_HEAD" end
  if entityType == 186 then return "ENTITY_MOMS_DEAD_HAND" end
  if entityType == 187 then return "ENTITY_DUKIE" end
  if entityType == 188 then return "ENTITY_ULCER" end
  if entityType == 189 then return "ENTITY_MEATBALL" end
  if entityType == 190 then return "ENTITY_PITFALL" end
  if entityType == 191 then return "ENTITY_MOVABLE_TNT" end
  if entityType == 192 then return "ENTITY_ULTRA_COIN" end
  if entityType == 193 then return "ENTITY_ULTRA_DOOR" end
  if entityType == 194 then return "ENTITY_CORN_MINE" end
  if entityType == 195 then return "ENTITY_HUSH_FLY" end
  if entityType == 196 then return "ENTITY_HUSH_GAPER" end
  if entityType == 197 then return "ENTITY_HUSH_BOIL" end
  if entityType == 198 then return "ENTITY_GREED_GAPER" end
  if entityType == 199 then return "ENTITY_MUSHROOM" end
  if entityType == 200 then return "ENTITY_POISON_MIND" end
  if entityType == 201 then return "ENTITY_STONEY" end
  if entityType == 202 then return "ENTITY_BLISTER" end
  if entityType == 203 then return "ENTITY_THE_THING" end
  if entityType == 204 then return "ENTITY_MINISTRO" end
  if entityType == 205 then return "ENTITY_PORTAL" end
  if entityType == 206 then return "ENTITY_TARBOY" end
  if entityType == 207 then return "ENTITY_FISTULOID" end
  if entityType == 208 then return "ENTITY_GUSH" end
  if entityType == 209 then return "ENTITY_LEPER" end
  if entityType == 210 then return "ENTITY_STAIN" end
  if entityType == 211 then return "ENTITY_BROWNIE" end
  if entityType == 212 then return "ENTITY_FORSAKEN" end
  if entityType == 213 then return "ENTITY_LITTLE_HORN" end
  if entityType == 214 then return "ENTITY_RAG_MAN" end
  if entityType == 215 then return "ENTITY_ULTRA_GREED" end
  if entityType == 216 then return "ENTITY_HUSH" end
  if entityType == 217 then return "ENTITY_HUSH_SKINLESS" end
  if entityType == 218 then return "ENTITY_RAG_MEGA" end
  if entityType == 219 then return "ENTITY_SISTERS_VIS" end
  if entityType == 220 then return "ENTITY_BIG_HORN" end
  if entityType == 221 then return "ENTITY_DELIRIUM" end
  if entityType == 222 then return "ENTITY_MATRIARCH" end
  if entityType == 223 then return "ENTITY_EFFECT" end
  if entityType == 224 then return "ENTITY_TEXT" end
  return nil -- returns nil if it doesn't match a type
end
