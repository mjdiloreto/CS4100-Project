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
-- 21 --> `
-- 22 --> GRID_ROCK_SS
function getGridType(gridIndex)
  local gridEntity = Game():GetRoom():GetGridEntity(gridIndex)
  if gridEntity ~= nil then
    return GridEntityEnumReverse[gridEntity:GetType()]
  end
  return ""
end

function addEntitySubType(t, v, s, entry)
  local et = EntityTypeEnum[t]
  if et then
    local ev = et[v]
    if ev then
      EntityTypeEnum[t][v][s] = entry
    else
      EntityTypeEnum[t][v] = {}
      EntityTypeEnum[t][v][s] = entry
    end
  else
    EntityTypeEnum[t] = {}
    EntityTypeEnum[t][v] = {}
    EntityTypeEnum[t][v][s] = entry
  end
end

function addEntityVariant(t, v, entry)
  local et = EntityTypeEnum[t]
  if et then
    local ev = et[v]
    if ev then
      EntityTypeEnum[t][v][-1] = entry
    else
      EntityTypeEnum[t][v] = {}
      EntityTypeEnum[t][v][-1] = entry
    end
  else
    EntityTypeEnum[t] = {}
    EntityTypeEnum[t][v] = {}
    EntityTypeEnum[t][v][-1] = entry
  end
end

function addEntityType(t, entry)
  local et = EntityTypeEnum[t]
  if et then
    local ev = et[-1]
    if not ev then
      EntityTypeEnum[t][-1] = entry
    end
  else
    EntityTypeEnum[t] = {}
    EntityTypeEnum[t][-1] = entry
  end
end

function fetchEntitySubType(t, v, s)
  local et = EntityTypeEnum[t]
  if et then
    local ev = et[v]
    if ev then
      local es = ev[s]
      if es then
        return es
      else
        if ev[-1] then
          return ev[-1]
        else
          return EntityTypeEnum[-1]
        end
      end
    else
      if et[-1] then
          return et[-1]
        else
          return EntityTypeEnum[-1]
        end
    end
  else
    return EntityTypeEnum[-1]
  end
end

function fetchEntityVariant(t, v)
  local et = EntityTypeEnum[t]
  if et then
    local ev = et[v]
    if ev then
      if ev[-1] then
        return ev[-1]
      else
        return EntityTypeEnum[-1]
      end
    else
      if et[-1] then
          return et[-1]
        else
          return EntityTypeEnum[-1]
        end
    end
  else
    return EntityTypeEnum[-1]
  end
end

function fetchEntityType(t)
  local et = EntityTypeEnum[t]
  if et and et[-1] then
    return et[-1]
  else
    return EntityTypeEnum[-1]
  end
end

function getEntityType(entity)
  return fetchEntitySubType(entity.Type, entity.Variant, entity.SubType)
end




-- DEFINE TYPES HERE --
EntityTypeEnum = {}
EntityTypeEnum[-1] = "UNKNOWN"

-- decorations
addEntityType(1000, "")

-- misc
addEntityType(0, "NULL")
addEntityType(1, "PLAYER")
addEntityType(2, "TEAR")
addEntityType(3, "FAMILIAR")

-- BOMBS, DANGEROUS!!!
addEntityType(4, "ACTIVE_BOMB")

-- PICKUPS
addEntityType(5, "PICKUP")

---- coins
addEntityVariant(5, 20, "COIN")
addEntitySubType(5, 20, 1, "PENNY")
addEntitySubType(5, 20, 2, "NICKEL")
addEntitySubType(5, 20, 3, "DIME")
addEntitySubType(5, 20, 4, "DOUBLE_PENNY")
addEntitySubType(5, 20, 5, "LUCKY_PENNY")
addEntitySubType(5, 20, 6, "STICKY_NICKEL")

---- bomb drops
addEntityVariant(5, 40, "BOMB")
addEntitySubType(5, 40, 1, "BOMB")
addEntitySubType(5, 40, 2, "DOUBLE_BOMB")
addEntitySubType(5, 40, 3, "TROLLBOMB")
addEntitySubType(5, 40, 4, "GOLDEN_BOMB")
addEntitySubType(5, 40, 5, "MEGATROLLBOMB")

---- hearts
addEntityVariant(5, 10, "HEART")
addEntitySubType(5, 10, 1, "HEART")
addEntitySubType(5, 10, 2, "HALF_HEART")
addEntitySubType(5, 10, 3, "SOUL_HEART")
addEntitySubType(5, 10, 4, "ANGEL_HEART")
addEntitySubType(5, 10, 5, "DOUBLE_HEART")
addEntitySubType(5, 10, 6, "BLACK_HEART")
addEntitySubType(5, 10, 7, "GOLD_HEART")
addEntitySubType(5, 10, 8, "HALF_SOUL_HEART")
addEntitySubType(5, 10, 9, "SCARED_HEART")
addEntitySubType(5, 10, 10, "BLENDED_HEART")
addEntitySubType(5, 10, 11, "BONE_HEART")

-- pedestal items
addEntityVariant(5, 100, "PEDESTAL_ITEM")
addEntitySubType(5, 100, 0, "PEDESTAL_EMPTY")

-- active items
addEntitySubType(5, 100, 130, "A Pony")
addEntitySubType(5, 100, 65, "Anarchist Cookbook")
addEntitySubType(5, 100, 136, "Best Friend")
addEntitySubType(5, 100, 286, "Blank Card")
addEntitySubType(5, 100, 186, "Blood Rights")
addEntitySubType(5, 100, 42, "Bob's Rotten Head")
addEntitySubType(5, 100, 78, "Book of Revelations")
addEntitySubType(5, 100, 287, "Book of Secrets")
addEntitySubType(5, 100, 58, "Book of Shadows")
addEntitySubType(5, 100, 288, "Box of Spiders")
addEntitySubType(5, 100, 326, "Breath of Life")
addEntitySubType(5, 100, 294, "Butter Bean")
addEntitySubType(5, 100, 296, "Converter")
addEntitySubType(5, 100, 160, "Crack the Sky")
addEntitySubType(5, 100, 158, "Crystal Ball")
addEntitySubType(5, 100, 285, "D10")
addEntitySubType(5, 100, 283, "D100")
addEntitySubType(5, 100, 166, "D20")
addEntitySubType(5, 100, 284, "D4")
addEntitySubType(5, 100, 175, "Dad's Key")
addEntitySubType(5, 100, 124, "Dead Sea Scrolls")
addEntitySubType(5, 100, 85, "Deck of Cards")
addEntitySubType(5, 100, 47, "Doctor's Remote")
addEntitySubType(5, 100, 291, "Flush!")
addEntitySubType(5, 100, 127, "Forget Me Now")
addEntitySubType(5, 100, 145, "Guppy's Head")
addEntitySubType(5, 100, 133, "Guppy's Paw")
addEntitySubType(5, 100, 293, "Head of Krampus")
addEntitySubType(5, 100, 282, "How to Jump")
addEntitySubType(5, 100, 323, "Isaac's Tears")
addEntitySubType(5, 100, 135, "IV Bag")
addEntitySubType(5, 100, 40, "Kamikaze!")
addEntitySubType(5, 100, 56, "Lemon Mishap")
addEntitySubType(5, 100, 295, "Magic Fingers")
addEntitySubType(5, 100, 102, "Mom's Bottle of Pills")
addEntitySubType(5, 100, 39, "Mom's Bra")
addEntitySubType(5, 100, 41, "Mom's Pad")
addEntitySubType(5, 100, 123, "Monster Manual")
addEntitySubType(5, 100, 86, "Monstro's Tooth")
addEntitySubType(5, 100, 37, "Mr. Boom")
addEntitySubType(5, 100, 77, "My Little Unicorn")
addEntitySubType(5, 100, 147, "Notched Axe")
addEntitySubType(5, 100, 297, "Pandora's Box")
addEntitySubType(5, 100, 177, "Portable Slot")
addEntitySubType(5, 100, 146, "Prayer Card")
addEntitySubType(5, 100, 126, "Razor Blade")
addEntitySubType(5, 100, 289, "Red Candle")
addEntitySubType(5, 100, 137, "Remote Detonator")
addEntitySubType(5, 100, 292, "Satanic Bible")
addEntitySubType(5, 100, 325, "Scissors")
addEntitySubType(5, 100, 49, "Shoop Da Whoop!")
addEntitySubType(5, 100, 171, "Spider Butt")
addEntitySubType(5, 100, 38, "Tammy's Head")
addEntitySubType(5, 100, 192, "Telepathy for Dummies")
addEntitySubType(5, 100, 44, "Teleport")
addEntitySubType(5, 100, 111, "The Bean")
addEntitySubType(5, 100, 33, "The Bible")
addEntitySubType(5, 100, 34, "The Book of Belial")
addEntitySubType(5, 100, 97, "The Book of Sin")
addEntitySubType(5, 100, 338, "The Boomerang")
addEntitySubType(5, 100, 164, "The Candle")
addEntitySubType(5, 100, 105, "The D6")
addEntitySubType(5, 100, 93, "The Gamekid")
addEntitySubType(5, 100, 66, "The Hourglass")
addEntitySubType(5, 100, 290, "The Jar")
addEntitySubType(5, 100, 83, "The Nail")
addEntitySubType(5, 100, 35, "The Necronomicon")
addEntitySubType(5, 100, 107, "The Pinking Shears")
addEntitySubType(5, 100, 36, "The Poop")
addEntitySubType(5, 100, 324, "Undefined")
addEntitySubType(5, 100, 298, "Unicorn Stump")
addEntitySubType(5, 100, 84, "We Need to Go Deeper!")
addEntitySubType(5, 100, 181, "White Pony")
addEntitySubType(5, 100, 45, "Yum Heart")
addEntitySubType(5, 100, 357, "Box of Friends")
addEntitySubType(5, 100, 386, "D12")
addEntitySubType(5, 100, 437, "D7")
addEntitySubType(5, 100, 406, "D8")
addEntitySubType(5, 100, 347, "Diplopia")
addEntitySubType(5, 100, 382, "Friendly Ball")
addEntitySubType(5, 100, 352, "Glass Cannon")
addEntitySubType(5, 100, 422, "Glowing Hour Glass")
addEntitySubType(5, 100, 434, "Jar of Flies")
addEntitySubType(5, 100, 421, "Kidney Bean")
addEntitySubType(5, 100, 351, "Mega Bean")
addEntitySubType(5, 100, 441, "Mega Blast")
addEntitySubType(5, 100, 427, "Mine Crafter")
addEntitySubType(5, 100, 439, "Mom's Box")
addEntitySubType(5, 100, 348, "Placebo")
addEntitySubType(5, 100, 383, "Tear Detonator")
addEntitySubType(5, 100, 419, "Teleport 2.0")
addEntitySubType(5, 100, 396, "Ventricle Razor")
addEntitySubType(5, 100, 349, "Wooden Nickel")
addEntitySubType(5, 100, 512, "Black Hole")
addEntitySubType(5, 100, 545, "Book of the Dead")
addEntitySubType(5, 100, 550, "Broken Shovel")
addEntitySubType(5, 100, 504, "Brown Nugget")
addEntitySubType(5, 100, 482, "Clicker")
addEntitySubType(5, 100, 480, "Compost")
addEntitySubType(5, 100, 521, "Coupon")
addEntitySubType(5, 100, 485, "Crooked Penny")
addEntitySubType(5, 100, 489, "D Infinity")
addEntitySubType(5, 100, 476, "D1")
addEntitySubType(5, 100, 481, "Dataminer")
addEntitySubType(5, 100, 510, "Delirious")
addEntitySubType(5, 100, 486, "Dull Razor")
addEntitySubType(5, 100, 490, "Eden's Soul")
addEntitySubType(5, 100, 483, "Mama Mega!")
addEntitySubType(5, 100, 488, "Metronome")
addEntitySubType(5, 100, 552, "Mom's Shovel")
addEntitySubType(5, 100, 523, "Moving Box")
addEntitySubType(5, 100, 527, "Mr. ME!")
addEntitySubType(5, 100, 515, "Mystery Gift")
addEntitySubType(5, 100, 478, "Pause")
addEntitySubType(5, 100, 475, "Plan C")
addEntitySubType(5, 100, 487, "Potato Peeler")
addEntitySubType(5, 100, 536, "Sacrificial Altar")
addEntitySubType(5, 100, 507, "Sharp Straw")
addEntitySubType(5, 100, 479, "Smelter")
addEntitySubType(5, 100, 516, "Sprinkler")
addEntitySubType(5, 100, 522, "Telekinesis")
addEntitySubType(5, 100, 477, "Void")
addEntitySubType(5, 100, 484, "Wait What?")

-- passive items
addEntitySubType(5, 100, 320, "???'s Only Friend")
addEntitySubType(5, 100, 11, "1up!")
addEntitySubType(5, 100, 245, "20/20")
addEntitySubType(5, 100, 191, "3 Dollar Bill")
addEntitySubType(5, 100, 116, "9 Volt")
addEntitySubType(5, 100, 18, "A Dollar")
addEntitySubType(5, 100, 132, "A Lump of Coal")
addEntitySubType(5, 100, 74, "A Quarter")
addEntitySubType(5, 100, 346, "A Snack")
addEntitySubType(5, 100, 230, "Abaddon")
addEntitySubType(5, 100, 188, "Abel")
addEntitySubType(5, 100, 214, "Anemic")
addEntitySubType(5, 100, 161, "Ankh")
addEntitySubType(5, 100, 222, "Anti-Gravity")
addEntitySubType(5, 100, 308, "Aquarius")
addEntitySubType(5, 100, 300, "Aries")
addEntitySubType(5, 100, 207, "Ball of Bandages")
addEntitySubType(5, 100, 231, "Ball of Tar")
addEntitySubType(5, 100, 272, "BBF")
addEntitySubType(5, 100, 274, "Best Bud")
addEntitySubType(5, 100, 247, "BFFS!")
addEntitySubType(5, 100, 279, "Big Fan")
addEntitySubType(5, 100, 260, "Black Candle")
addEntitySubType(5, 100, 226, "Black Lotus")
addEntitySubType(5, 100, 119, "Blood Bag")
addEntitySubType(5, 100, 254, "Blood Clot")
addEntitySubType(5, 100, 7, "Blood of the Martyr")
addEntitySubType(5, 100, 157, "Bloody Lust")
addEntitySubType(5, 100, 342, "Blue Cap")
addEntitySubType(5, 100, 246, "Blue Map")
addEntitySubType(5, 100, 273, "Bob's Brain")
addEntitySubType(5, 100, 140, "Bob's Curse")
addEntitySubType(5, 100, 125, "Bobby-Bomb")
addEntitySubType(5, 100, 250, "Bogo Bombs")
addEntitySubType(5, 100, 131, "Bomb Bag")
addEntitySubType(5, 100, 19, "Boom!")
addEntitySubType(5, 100, 198, "Box")
addEntitySubType(5, 100, 25, "Breakfast")
addEntitySubType(5, 100, 118, "Brimstone")
addEntitySubType(5, 100, 337, "Broken Watch")
addEntitySubType(5, 100, 8, "Brother Bobby")
addEntitySubType(5, 100, 129, "Bucket of Lard")
addEntitySubType(5, 100, 144, "Bum Friend")
addEntitySubType(5, 100, 209, "Butt Bombs")
addEntitySubType(5, 100, 340, "Caffeine Pill")
addEntitySubType(5, 100, 319, "Cain's Other Eye")
addEntitySubType(5, 100, 301, "Cancer")
addEntitySubType(5, 100, 307, "Capricorn")
addEntitySubType(5, 100, 165, "Cat-O-Nine-Tails")
addEntitySubType(5, 100, 162, "Celtic Cross")
addEntitySubType(5, 100, 216, "Ceremonial Robes")
addEntitySubType(5, 100, 208, "Champion Belt")
addEntitySubType(5, 100, 62, "Charm of the Vampire")
addEntitySubType(5, 100, 154, "Chemical Peel")
addEntitySubType(5, 100, 69, "Chocolate Milk")
addEntitySubType(5, 100, 241, "Contract From Below")
addEntitySubType(5, 100, 224, "Cricket's Body")
addEntitySubType(5, 100, 4, "Cricket's Head")
addEntitySubType(5, 100, 73, "Cube of Meat")
addEntitySubType(5, 100, 48, "Cupid's Arrow")
addEntitySubType(5, 100, 316, "Cursed Eye")
addEntitySubType(5, 100, 170, "Daddy Longlegs")
addEntitySubType(5, 100, 278, "Dark Bum")
addEntitySubType(5, 100, 259, "Dark Matter")
addEntitySubType(5, 100, 117, "Dead Bird")
addEntitySubType(5, 100, 81, "Dead Cat")
addEntitySubType(5, 100, 185, "Dead Dove")
addEntitySubType(5, 100, 336, "Dead Onion")
addEntitySubType(5, 100, 237, "Death's Touch")
addEntitySubType(5, 100, 113, "Demon Baby")
addEntitySubType(5, 100, 24, "Dessert")
addEntitySubType(5, 100, 23, "Dinner")
addEntitySubType(5, 100, 57, "Distant Admiration")
addEntitySubType(5, 100, 52, "Dr. Fetus")
addEntitySubType(5, 100, 265, "Dry Baby")
addEntitySubType(5, 100, 236, "E Coli")
addEntitySubType(5, 100, 168, "Epic Fetus")
addEntitySubType(5, 100, 310, "Eve's Mascara")
addEntitySubType(5, 100, 240, "Experimental Treatment")
addEntitySubType(5, 100, 204, "Fanny Pack")
addEntitySubType(5, 100, 179, "Fate")
addEntitySubType(5, 100, 257, "Fire Mind")
addEntitySubType(5, 100, 128, "Forever Alone")
addEntitySubType(5, 100, 318, "Gemini")
addEntitySubType(5, 100, 163, "Ghost Baby")
addEntitySubType(5, 100, 225, "Gimpy")
addEntitySubType(5, 100, 210, "Gnawed Leaf")
addEntitySubType(5, 100, 215, "Goat Head")
addEntitySubType(5, 100, 331, "Godhead")
addEntitySubType(5, 100, 70, "Growth Hormones")
addEntitySubType(5, 100, 112, "Guardian Angel")
addEntitySubType(5, 100, 206, "Guillotine")
addEntitySubType(5, 100, 212, "Guppy's Collar")
addEntitySubType(5, 100, 187, "Guppy's Hair Ball")
addEntitySubType(5, 100, 134, "Guppy's Tail")
addEntitySubType(5, 100, 156, "Habit")
addEntitySubType(5, 100, 10, "Halo of Flies")
addEntitySubType(5, 100, 167, "Harlequin Baby")
addEntitySubType(5, 100, 269, "Headless Baby")
addEntitySubType(5, 100, 248, "Hive Mind")
addEntitySubType(5, 100, 184, "Holy Grail")
addEntitySubType(5, 100, 313, "Holy Mantle")
addEntitySubType(5, 100, 178, "Holy Water")
addEntitySubType(5, 100, 256, "Hot Bombs")
addEntitySubType(5, 100, 203, "Humbling Bundle")
addEntitySubType(5, 100, 242, "Infamy")
addEntitySubType(5, 100, 148, "Infestation")
addEntitySubType(5, 100, 234, "Infestation 2")
addEntitySubType(5, 100, 149, "Ipecac")
addEntitySubType(5, 100, 201, "Iron Bar")
addEntitySubType(5, 100, 276, "Isaac's Heart")
addEntitySubType(5, 100, 197, "Jesus Juice")
addEntitySubType(5, 100, 311, "Judas' Shadow")
addEntitySubType(5, 100, 266, "Juicy Sack")
addEntitySubType(5, 100, 238, "Key Piece 1")
addEntitySubType(5, 100, 239, "Key Piece 2")
addEntitySubType(5, 100, 343, "Latch Key")
addEntitySubType(5, 100, 332, "Lazarus' Rags")
addEntitySubType(5, 100, 270, "Leech")
addEntitySubType(5, 100, 302, "Leo")
addEntitySubType(5, 100, 15, "<3")
addEntitySubType(5, 100, 304, "Libra")
addEntitySubType(5, 100, 275, "Lil Brimstone")
addEntitySubType(5, 100, 277, "Lil Haunt")
addEntitySubType(5, 100, 252, "Little Baggy")
addEntitySubType(5, 100, 96, "Little C.H.A.D.")
addEntitySubType(5, 100, 88, "Little Chubby")
addEntitySubType(5, 100, 99, "Little Gish")
addEntitySubType(5, 100, 100, "Little Steven")
addEntitySubType(5, 100, 87, "Loki's Horns")
addEntitySubType(5, 100, 82, "Lord of the Pit")
addEntitySubType(5, 100, 213, "Lost Contact")
addEntitySubType(5, 100, 46, "Lucky Foot")
addEntitySubType(5, 100, 22, "Lunch")
addEntitySubType(5, 100, 312, "Maggy's Bow")
addEntitySubType(5, 100, 194, "Magic 8 Ball")
addEntitySubType(5, 100, 12, "Magic Mushroom")
addEntitySubType(5, 100, 253, "Magic Scab")
addEntitySubType(5, 100, 53, "Magneto")
addEntitySubType(5, 100, 344, "Match Book")
addEntitySubType(5, 100, 193, "MEAT!")
addEntitySubType(5, 100, 202, "Midas' Touch")
addEntitySubType(5, 100, 71, "Mini Mush")
addEntitySubType(5, 100, 258, "Missing No.")
addEntitySubType(5, 100, 262, "Missing Page 2")
addEntitySubType(5, 100, 173, "Mitre")
addEntitySubType(5, 100, 195, "Mom's Coin Purse")
addEntitySubType(5, 100, 110, "Mom's Contacts")
addEntitySubType(5, 100, 55, "Mom's Eye")
addEntitySubType(5, 100, 200, "Mom's Eyeshadow")
addEntitySubType(5, 100, 30, "Mom's Heels")
addEntitySubType(5, 100, 199, "Mom's Key")
addEntitySubType(5, 100, 114, "Mom's Knife")
addEntitySubType(5, 100, 31, "Mom's Lipstick")
addEntitySubType(5, 100, 228, "Mom's Perfume")
addEntitySubType(5, 100, 139, "Mom's Purse")
addEntitySubType(5, 100, 29, "Mom's Underwear")
addEntitySubType(5, 100, 217, "Mom's Wig")
addEntitySubType(5, 100, 109, "Money = Power")
addEntitySubType(5, 100, 322, "Mongo Baby")
addEntitySubType(5, 100, 229, "Monstro's Lung")
addEntitySubType(5, 100, 106, "Mr. Mega")
addEntitySubType(5, 100, 153, "Mutant Spider")
addEntitySubType(5, 100, 5, "My Reflection")
addEntitySubType(5, 100, 317, "Mysterious Liquid")
addEntitySubType(5, 100, 271, "Mystery Sack")
addEntitySubType(5, 100, 6, "Number One")
addEntitySubType(5, 100, 121, "Odd Mushroom")
addEntitySubType(5, 100, 120, "Odd Mushroom")
addEntitySubType(5, 100, 219, "Old Bandage")
addEntitySubType(5, 100, 115, "Ouija Board")
addEntitySubType(5, 100, 141, "Pageant Boy")
addEntitySubType(5, 100, 51, "Pentagram")
addEntitySubType(5, 100, 75, "PHD")
addEntitySubType(5, 100, 227, "Piggy Bank")
addEntitySubType(5, 100, 309, "Pisces")
addEntitySubType(5, 100, 218, "Placenta")
addEntitySubType(5, 100, 169, "Polyphemus")
addEntitySubType(5, 100, 261, "Proptosis")
addEntitySubType(5, 100, 281, "Punching Bag")
addEntitySubType(5, 100, 190, "Pyro")
addEntitySubType(5, 100, 223, "Pyromaniac")
addEntitySubType(5, 100, 174, "Rainbow Baby")
addEntitySubType(5, 100, 16, "Raw Liver")
addEntitySubType(5, 100, 95, "Robo-Baby")
addEntitySubType(5, 100, 267, "Robo-Baby 2.0")
addEntitySubType(5, 100, 14, "Roid Rage")
addEntitySubType(5, 100, 72, "Rosary")
addEntitySubType(5, 100, 268, "Rotten Baby")
addEntitySubType(5, 100, 26, "Rotten Meat")
addEntitySubType(5, 100, 221, "Rubber Cement")
addEntitySubType(5, 100, 94, "Sack of Pennies")
addEntitySubType(5, 100, 182, "Sacred Heart")
addEntitySubType(5, 100, 172, "Sacrificial Dagger")
addEntitySubType(5, 100, 220, "Sad Bombs")
addEntitySubType(5, 100, 339, "Safety Pin")
addEntitySubType(5, 100, 306, "Sagittarius")
addEntitySubType(5, 100, 321, "Samson's Chains")
addEntitySubType(5, 100, 142, "Scapular")
addEntitySubType(5, 100, 305, "Scorpio")
addEntitySubType(5, 100, 255, "Screw")
addEntitySubType(5, 100, 205, "Sharp Plug")
addEntitySubType(5, 100, 280, "Sissy Longlegs")
addEntitySubType(5, 100, 67, "Sister Maggy")
addEntitySubType(5, 100, 9, "Skatole")
addEntitySubType(5, 100, 17, "Skeleton Key")
addEntitySubType(5, 100, 264, "Smart Fly")
addEntitySubType(5, 100, 189, "SMB Super Fan")
addEntitySubType(5, 100, 330, "Soy Milk")
addEntitySubType(5, 100, 143, "Speed Ball")
addEntitySubType(5, 100, 91, "Spelunker Hat")
addEntitySubType(5, 100, 211, "Spider Baby")
addEntitySubType(5, 100, 89, "Spider Bite")
addEntitySubType(5, 100, 159, "Spirit of the Night")
addEntitySubType(5, 100, 3, "Spoon Bender")
addEntitySubType(5, 100, 196, "Squeezy")
addEntitySubType(5, 100, 251, "Starter Deck")
addEntitySubType(5, 100, 64, "Steam Sale")
addEntitySubType(5, 100, 176, "Stem Cells")
addEntitySubType(5, 100, 50, "Steven")
addEntitySubType(5, 100, 138, "Stigmata")
addEntitySubType(5, 100, 232, "Stop Watch")
addEntitySubType(5, 100, 315, "Strange Attractor")
addEntitySubType(5, 100, 92, "Super Bandage")
addEntitySubType(5, 100, 345, "Synthoil")
addEntitySubType(5, 100, 299, "Taurus")
addEntitySubType(5, 100, 244, "Tech.5")
addEntitySubType(5, 100, 68, "Technology")
addEntitySubType(5, 100, 152, "Technology 2")
addEntitySubType(5, 100, 63, "The Battery")
addEntitySubType(5, 100, 28, "The Belt")
addEntitySubType(5, 100, 180, "The Black Bean")
addEntitySubType(5, 100, 334, "The Body")
addEntitySubType(5, 100, 103, "The Common Cold")
addEntitySubType(5, 100, 21, "The Compass")
addEntitySubType(5, 100, 101, "The Halo")
addEntitySubType(5, 100, 2, "The Inner Eye")
addEntitySubType(5, 100, 60, "The Ladder")
addEntitySubType(5, 100, 329, "The Ludovico Technique")
addEntitySubType(5, 100, 79, "The Mark")
addEntitySubType(5, 100, 333, "The Mind")
addEntitySubType(5, 100, 151, "The Mulligan")
addEntitySubType(5, 100, 328, "The Negative")
addEntitySubType(5, 100, 80, "The Pact")
addEntitySubType(5, 100, 104, "The Parasite")
addEntitySubType(5, 100, 155, "The Peeper")
addEntitySubType(5, 100, 327, "The Polaroid")
addEntitySubType(5, 100, 98, "The Relic")
addEntitySubType(5, 100, 1, "The Sad Onion")
addEntitySubType(5, 100, 90, "The Small Rock")
addEntitySubType(5, 100, 335, "The Soul")
addEntitySubType(5, 100, 13, "The Virus")
addEntitySubType(5, 100, 108, "The Wafer")
addEntitySubType(5, 100, 249, "There's Options")
addEntitySubType(5, 100, 314, "Thunder Thighs")
addEntitySubType(5, 100, 233, "Tiny Planet")
addEntitySubType(5, 100, 183, "Toothpicks")
addEntitySubType(5, 100, 341, "Torn Photo")
addEntitySubType(5, 100, 150, "Tough Love")
addEntitySubType(5, 100, 20, "Transcendence")
addEntitySubType(5, 100, 54, "Treasure Map")
addEntitySubType(5, 100, 243, "Trinity Shield")
addEntitySubType(5, 100, 303, "Virgo")
addEntitySubType(5, 100, 122, "Whore of Babylon")
addEntitySubType(5, 100, 32, "Wire Coat Hanger")
addEntitySubType(5, 100, 27, "Wooden Spoon")
addEntitySubType(5, 100, 76, "X-Ray Vision")
addEntitySubType(5, 100, 359, "8 Inch Nails")
addEntitySubType(5, 100, 408, "Athame")
addEntitySubType(5, 100, 391, "Betrayal")
addEntitySubType(5, 100, 438, "Binky")
addEntitySubType(5, 100, 420, "Black Powder")
addEntitySubType(5, 100, 353, "Bomber Boy")
addEntitySubType(5, 100, 385, "Bumbo")
addEntitySubType(5, 100, 377, "Bursting Sack")
addEntitySubType(5, 100, 412, "Cambion Conception")
addEntitySubType(5, 100, 356, "Car Battery")
addEntitySubType(5, 100, 387, "Censer")
addEntitySubType(5, 100, 402, "Chaos")
addEntitySubType(5, 100, 372, "Charged Baby")
addEntitySubType(5, 100, 423, "Circle of Protection")
addEntitySubType(5, 100, 369, "Continuum")
addEntitySubType(5, 100, 354, "Crack Jacks")
addEntitySubType(5, 100, 415, "Crown of Light")
addEntitySubType(5, 100, 371, "Curse of the Tower")
addEntitySubType(5, 100, 373, "Dead Eye")
addEntitySubType(5, 100, 416, "Deep Pockets")
addEntitySubType(5, 100, 381, "Eden's Blessing")
addEntitySubType(5, 100, 409, "Empty Vessel")
addEntitySubType(5, 100, 368, "Epiphora")
addEntitySubType(5, 100, 410, "Evil Eye")
addEntitySubType(5, 100, 401, "Explosivo")
addEntitySubType(5, 100, 404, "Farting Baby")
addEntitySubType(5, 100, 361, "Fate's Reward")
addEntitySubType(5, 100, 364, "Friend Zone")
addEntitySubType(5, 100, 418, "Fruit Cake")
addEntitySubType(5, 100, 405, "GB Bug")
addEntitySubType(5, 100, 432, "Glitter Bombs")
addEntitySubType(5, 100, 398, "God's Flesh")
addEntitySubType(5, 100, 429, "Head of the Keeper")
addEntitySubType(5, 100, 374, "Holy Light")
addEntitySubType(5, 100, 375, "Host Hat")
addEntitySubType(5, 100, 413, "Immaculate Conception")
addEntitySubType(5, 100, 360, "Incubus")
addEntitySubType(5, 100, 388, "Key Bum")
addEntitySubType(5, 100, 440, "Kidney Stone")
addEntitySubType(5, 100, 362, "Lil Chest")
addEntitySubType(5, 100, 384, "Lil Gurdy")
addEntitySubType(5, 100, 435, "Lil' Loki")
addEntitySubType(5, 100, 365, "Lost Fly")
addEntitySubType(5, 100, 411, "Lusty Blood")
addEntitySubType(5, 100, 394, "Marked")
addEntitySubType(5, 100, 399, "Maw of the Void")
addEntitySubType(5, 100, 436, "Milk!")
addEntitySubType(5, 100, 355, "Mom's Pearls")
addEntitySubType(5, 100, 414, "More Options")
addEntitySubType(5, 100, 370, "Mr. Dolly")
addEntitySubType(5, 100, 431, "Multidimensional Baby")
addEntitySubType(5, 100, 433, "My Shadow")
addEntitySubType(5, 100, 425, "Night Light")
addEntitySubType(5, 100, 378, "No. 2")
addEntitySubType(5, 100, 426, "Obsessed Fan")
addEntitySubType(5, 100, 430, "Papa Fly")
addEntitySubType(5, 100, 380, "Pay to Play")
addEntitySubType(5, 100, 428, "PJs")
addEntitySubType(5, 100, 379, "Pupula Duplex")
addEntitySubType(5, 100, 407, "Purity")
addEntitySubType(5, 100, 376, "Restock")
addEntitySubType(5, 100, 389, "Rune Bag")
addEntitySubType(5, 100, 424, "Sack Head")
addEntitySubType(5, 100, 366, "Scatter Bombs")
addEntitySubType(5, 100, 390, "Seraphim")
addEntitySubType(5, 100, 393, "Serpent's Kiss")
addEntitySubType(5, 100, 400, "Spear of Destiny")
addEntitySubType(5, 100, 403, "Spider Mod")
addEntitySubType(5, 100, 367, "Sticky Bombs")
addEntitySubType(5, 100, 417, "Succubus")
addEntitySubType(5, 100, 363, "Sworn Protector")
addEntitySubType(5, 100, 395, "Tech X")
addEntitySubType(5, 100, 358, "The Wiz")
addEntitySubType(5, 100, 350, "Toxic Shock")
addEntitySubType(5, 100, 397, "Tractor Beam")
addEntitySubType(5, 100, 392, "Zodiac")
addEntitySubType(5, 100, 526, "7 Seals")
addEntitySubType(5, 100, 491, "Acid Baby")
addEntitySubType(5, 100, 493, "Adrenaline")
addEntitySubType(5, 100, 465, "Analog Stick")
addEntitySubType(5, 100, 528, "Angelic Prism")
addEntitySubType(5, 100, 511, "Angry Fly")
addEntitySubType(5, 100, 443, "Apple!")
addEntitySubType(5, 100, 506, "Backstabber")
addEntitySubType(5, 100, 458, "Belly Button")
addEntitySubType(5, 100, 473, "Big Chubby")
addEntitySubType(5, 100, 535, "Blanket")
addEntitySubType(5, 100, 509, "Bloodshot Eye")
addEntitySubType(5, 100, 513, "Bozo")
addEntitySubType(5, 100, 549, "Brittle Bones")
addEntitySubType(5, 100, 514, "Broken Modem")
addEntitySubType(5, 100, 551, "Broken Shovel")
addEntitySubType(5, 100, 518, "Buddy in a Box")
addEntitySubType(5, 100, 497, "Camo Undies")
addEntitySubType(5, 100, 453, "Compound Fracture")
addEntitySubType(5, 100, 457, "Cone Head")
addEntitySubType(5, 100, 466, "Contagion")
addEntitySubType(5, 100, 455, "Dad's Lost Coin")
addEntitySubType(5, 100, 546, "Dad's Ring")
addEntitySubType(5, 100, 442, "Dark Prince's Crown")
addEntitySubType(5, 100, 446, "Dead Tooth")
addEntitySubType(5, 100, 530, "Death's List")
addEntitySubType(5, 100, 469, "Depression")
addEntitySubType(5, 100, 547, "Divorce Papers")
addEntitySubType(5, 100, 445, "Dog Tooth")
addEntitySubType(5, 100, 498, "Duality")
addEntitySubType(5, 100, 499, "Eucharist")
addEntitySubType(5, 100, 496, "Euthanasia")
addEntitySubType(5, 100, 462, "Eye of Belial")
addEntitySubType(5, 100, 450, "Eye of Greed")
addEntitySubType(5, 100, 517, "Fast Bombs")
addEntitySubType(5, 100, 467, "Finger!")
addEntitySubType(5, 100, 540, "Flat Stone")
addEntitySubType(5, 100, 495, "Ghost Pepper")
addEntitySubType(5, 100, 460, "Glaucoma")
addEntitySubType(5, 100, 464, "Glyph of Balance")
addEntitySubType(5, 100, 501, "Greed's Gullet")
addEntitySubType(5, 100, 531, "Haemolacria")
addEntitySubType(5, 100, 543, "Hallowed Ground")
addEntitySubType(5, 100, 470, "Hushy")
addEntitySubType(5, 100, 494, "Jacob's Ladder")
addEntitySubType(5, 100, 548, "Jaw Bone")
addEntitySubType(5, 100, 520, "Jumper Cables")
addEntitySubType(5, 100, 472, "King Baby")
addEntitySubType(5, 100, 532, "Lachryphagy")
addEntitySubType(5, 100, 502, "Large Zit")
addEntitySubType(5, 100, 444, "Lead Pencil")
addEntitySubType(5, 100, 525, "Leprosy")
addEntitySubType(5, 100, 519, "Lil Delirium")
addEntitySubType(5, 100, 471, "Lil Monstro")
addEntitySubType(5, 100, 537, "Lil Spewer")
addEntitySubType(5, 100, 447, "Linger Bean")
addEntitySubType(5, 100, 503, "Little Horn")
addEntitySubType(5, 100, 538, "Marbles")
addEntitySubType(5, 100, 541, "Marrow")
addEntitySubType(5, 100, 449, "Metal Plate")
addEntitySubType(5, 100, 456, "Moldy Bread")
addEntitySubType(5, 100, 508, "Mom's Razor")
addEntitySubType(5, 100, 539, "Mystery Egg")
addEntitySubType(5, 100, 461, "Parasitoid")
addEntitySubType(5, 100, 544, "Pointy Rib")
addEntitySubType(5, 100, 505, "Poke Go")
addEntitySubType(5, 100, 454, "Polydactyly")
addEntitySubType(5, 100, 529, "Pop!")
addEntitySubType(5, 100, 500, "Sack of Sacks")
addEntitySubType(5, 100, 534, "Schoolbag")
addEntitySubType(5, 100, 468, "Shade")
addEntitySubType(5, 100, 448, "Shard of Glass")
addEntitySubType(5, 100, 459, "Sinus Infection")
addEntitySubType(5, 100, 542, "Slipped Rib")
addEntitySubType(5, 100, 463, "Sulfuric Acid")
addEntitySubType(5, 100, 451, "Tarot Cloth")
addEntitySubType(5, 100, 524, "Technology Zero")
addEntitySubType(5, 100, 474, "Tonsil")
addEntitySubType(5, 100, 533, "Trisagion")
addEntitySubType(5, 100, 452, "Varicose Veins")
addEntitySubType(5, 100, 492, "YO LISTEN!")

-- chests
addEntityVariant(5, 50, "CHEST")
addEntityVariant(5, 51, "BOMB_CHEST")
addEntityVariant(5, 52, "SPIKED_CHEST")
addEntityVariant(5, 53, "ETERNAL_CHEST")
addEntityVariant(5, 54, "MIMIC_CHEST")
addEntityVariant(5, 60, "LOCKED_CHEST")
addEntityVariant(5, 360, "RED_CHEST")

-- other
addEntityVariant(5, 69, "BAG")
addEntityVariant(5, 30, "KEY") -- TODO SubTypes
addEntityVariant(5, 70, "PILL")
addEntityVariant(5, 90, "BATTERY")
addEntityVariant(5, 350, "TRINKET") -- TODO SubTypes
addEntityVariant(5, 340, "BIG_CHEST")
addEntityVariant(5, 370, "TROPHY")

-- other types
addEntityType(6, "SLOT")
addEntityType(7, "LASER")
addEntityType(8, "KNIFE")
addEntityType(9, "PROJECTILE")
addEntityType(10, "GAPER")
addEntityType(11, "GUSHER")
addEntityType(12, "HORF")
addEntityType(13, "FLY")
addEntityType(14, "POOTER")
addEntityType(15, "CLOTTY")
addEntityType(16, "MULLIGAN")
addEntityType(17, "SHOPKEEPER")
addEntityType(18, "ATTACKFLY")
addEntityType(19, "LARRYJR")
addEntityType(20, "MONSTRO")
addEntityType(21, "MAGGOT")
addEntityType(22, "HIVE")
addEntityType(23, "CHARGER")
addEntityType(24, "GLOBIN")
addEntityType(25, "BOOMFLY")
addEntityType(26, "MAW")
addEntityType(27, "HOST")
addEntityType(28, "CHUB")
addEntityType(29, "HOPPER")
addEntityType(30, "BOIL")
addEntityType(31, "SPITY")
addEntityType(32, "BRAIN")
addEntityType(33, "FIREPLACE")
addEntityType(34, "LEAPER")
addEntityType(35, "MRMAW")
addEntityType(36, "GURDY")
addEntityType(37, "BABY")
addEntityType(38, "VIS")
addEntityType(39, "GUTS")
addEntityType(40, "KNIGHT")
addEntityType(41, "STONEHEAD")
addEntityType(42, "MONSTRO2")
addEntityType(43, "POKY")
addEntityType(44, "MOM")
addEntityType(45, "SLOTH")
addEntityType(46, "LUST")
addEntityType(47, "WRATH")
addEntityType(48, "GLUTTONY")
addEntityType(49, "GREED")
addEntityType(50, "ENVY")
addEntityType(51, "PRIDE")
addEntityType(52, "DOPLE")
addEntityType(53, "FLAMINGHOPPER")
addEntityType(54, "LEECH")
addEntityType(55, "LUMP")
addEntityType(56, "MEMBRAIN")
addEntityType(57, "PARA_BITE")
addEntityType(58, "FRED")
addEntityType(59, "EYE")
addEntityType(60, "SUCKER")
addEntityType(61, "PIN")
addEntityType(62, "FAMINE")
addEntityType(63, "PESTILENCE")
addEntityType(64, "WAR")
addEntityType(65, "DEATH")
addEntityType(66, "DUKE")
addEntityType(67, "PEEP")
addEntityType(68, "LOKI")
addEntityType(69, "FISTULA_BIG")
addEntityType(70, "FISTULA_MEDIUM")
addEntityType(71, "FISTULA_SMALL")
addEntityType(72, "BLASTOCYST_BIG")
addEntityType(73, "BLASTOCYST_MEDIUM")
addEntityType(74, "BLASTOCYST_SMALL")
addEntityType(75, "EMBRYO")
addEntityType(76, "MOMS_HEART")
addEntityType(77, "GEMINI")
addEntityType(78, "MOTER") -- mom's heart fetus versions
addEntityType(79, "FALLEN")
addEntityType(80, "HEADLESS_HORSEMAN")
addEntityType(81, "HORSEMAN_HEAD")
addEntityType(82, "SATAN")
addEntityType(83, "SPIDER")
addEntityType(84, "KEEPER")
addEntityType(85, "GURGLE")
addEntityType(86, "WALKINGBOIL")
addEntityType(87, "BUTTLICKER")
addEntityType(88, "HANGER")
addEntityType(89, "SWARMER")
addEntityType(90, "HEART")
addEntityType(91, "MASK")
addEntityType(92, "BIGSPIDER")
addEntityType(93, "ETERNALFLY")
addEntityType(94, "MASK_OF_INFAMY")
addEntityType(95, "HEART_OF_INFAMY")
addEntityType(96, "GURDY_JR")
addEntityType(97, "WIDOW")
addEntityType(98, "DADDYLONGLEGS")
addEntityType(99, "ISAAC")
addEntityType(100, "STONE_EYE")
addEntityType(101, "CONSTANT_STONE_SHOOTER")
addEntityType(102, "BRIMSTONE_HEAD")
addEntityType(103, "MOBILE_HOST")
addEntityType(104, "NEST")
addEntityType(105, "BABY_LONG_LEGS")
addEntityType(106, "CRAZY_LONG_LEGS")
addEntityType(107, "FATTY")
addEntityType(108, "FAT_SACK")
addEntityType(109, "BLUBBER")
addEntityType(110, "HALF_SACK")
addEntityType(111, "DEATHS_HEAD")
addEntityType(112, "MOMS_HAND")
addEntityType(113, "FLY_L2")
addEntityType(114, "SPIDER_L2")
addEntityType(115, "SWINGER")
addEntityType(116, "DIP")
addEntityType(117, "WALL_HUGGER")
addEntityType(118, "WIZOOB")
addEntityType(119, "SQUIRT")
addEntityType(120, "COD_WORM")
addEntityType(121, "RING_OF_FLIES")
addEntityType(122, "DINGA")
addEntityType(123, "OOB")
addEntityType(124, "BLACK_MAW")
addEntityType(125, "SKINNY")
addEntityType(126, "BONY")
addEntityType(127, "HOMUNCULUS")
addEntityType(128, "TUMOR")
addEntityType(129, "CAMILLO_JR")
addEntityType(130, "NERVE_ENDING")
addEntityType(131, "SKINBALL")
addEntityType(132, "MOM_HEAD")
addEntityType(133, "ONE_TOOTH")
addEntityType(134, "GAPING_MAW")
addEntityType(135, "BROKEN_GAPING_MAW")
addEntityType(136, "GURGLING")
addEntityType(137, "SPLASHER")
addEntityType(138, "GRUB")
addEntityType(139, "WALL_CREEP")
addEntityType(140, "RAGE_CREEP")
addEntityType(141, "BLIND_CREEP")
addEntityType(142, "CONJOINED_SPITTY")
addEntityType(143, "ROUND_WORM")
addEntityType(144, "POOP")
addEntityType(145, "RAGLING")
addEntityType(146, "FLESH_MOBILE_HOST")
addEntityType(147, "PSY_HORF")
addEntityType(148, "FULL_FLY")
addEntityType(149, "TICKING_SPIDER")
addEntityType(150, "BEGOTTEN")
addEntityType(151, "NULLS")
addEntityType(152, "PSY_TUMOR")
addEntityType(153, "FLOATING_KNIGHT")
addEntityType(154, "NIGHT_CRAWLER")
addEntityType(155, "DART_FLY")
addEntityType(156, "CONJOINED_FATTY")
addEntityType(157, "FAT_BAT")
addEntityType(158, "IMP")
addEntityType(159, "THE_HAUNT")
addEntityType(160, "DINGLE")
addEntityType(161, "MEGA_MAW")
addEntityType(162, "GATE")
addEntityType(163, "MEGA_FATTY")
addEntityType(164, "CAGE")
addEntityType(165, "MAMA_GURDY")
addEntityType(166, "DARK_ONE")
addEntityType(167, "ADVERSARY")
addEntityType(168, "POLYCEPHALUS")
addEntityType(169, "MR_FRED")
addEntityType(170, "URIEL")
addEntityType(171, "GABRIEL")
addEntityType(172, "THE_LAMB")
addEntityType(173, "MEGA_SATAN")
addEntityType(174, "MEGA_SATAN_2")
addEntityType(175, "ROUNDY")
addEntityType(176, "BLACK_BONY")
addEntityType(177, "BLACK_GLOBIN")
addEntityType(178, "BLACK_GLOBIN_HEAD")
addEntityType(179, "BLACK_GLOBIN_BODY")
addEntityType(180, "SWARM")
addEntityType(181, "MEGA_CLOTTY")
addEntityType(182, "BONE_KNIGHT")
addEntityType(183, "CYCLOPIA")
addEntityType(184, "RED_GHOST")
addEntityType(185, "FLESH_DEATHS_HEAD")
addEntityType(186, "MOMS_DEAD_HAND")
addEntityType(187, "DUKIE")
addEntityType(188, "ULCER")
addEntityType(189, "MEATBALL")
addEntityType(190, "PITFALL")
addEntityType(191, "MOVABLE_TNT")
addEntityType(192, "ULTRA_COIN")
addEntityType(193, "ULTRA_DOOR")
addEntityType(194, "CORN_MINE")
addEntityType(195, "HUSH_FLY")
addEntityType(196, "HUSH_GAPER")
addEntityType(197, "HUSH_BOIL")
addEntityType(198, "GREED_GAPER")
addEntityType(199, "MUSHROOM")
addEntityType(200, "POISON_MIND")
addEntityType(201, "STONEY")
addEntityType(202, "BLISTER")
addEntityType(203, "THE_THING")
addEntityType(204, "MINISTRO")
addEntityType(205, "PORTAL")
addEntityType(206, "TARBOY")
addEntityType(207, "FISTULOID")
addEntityType(208, "GUSH")
addEntityType(209, "LEPER")
addEntityType(210, "STAIN")
addEntityType(211, "BROWNIE")
addEntityType(212, "FORSAKEN")
addEntityType(213, "LITTLE_HORN")
addEntityType(214, "RAG_MAN")
addEntityType(215, "ULTRA_GREED")
addEntityType(216, "HUSH")
addEntityType(217, "HUSH_SKINLESS")
addEntityType(218, "RAG_MEGA")
addEntityType(219, "SISTERS_VIS")
addEntityType(220, "BIG_HORN")
addEntityType(221, "DELIRIUM")
addEntityType(222, "MATRIARCH")
addEntityType(223, "EFFECT")
addEntityType(224, "TEXT")