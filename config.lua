-- giftbox mod configuration file

giftbox.present_infotext = "Christmas Present"
giftbox.present_greeting = "present_greeting.png"

giftbox.present_items = {
	"default:torch 60",
	"default:apple 40",
	"farming:bread 20",
	"mt_seasons:pumpkin_slice 10",

	"default:junglesapling 5",
	"default:pine_sapling 5",
	"default:aspen_sapling 5",
	"default:acacia_sapling 5",

	"default:pick_diamond",
	"default:sword_diamond",
	"default:pick_bronze",
	"default:sword_bronze",

	"3d_armor:helmet_diamond",
	"3d_armor:leggings_diamond",
	"3d_armor:chestplate_diamond",
	"3d_armor:boots_diamond",

	"default:coalblock 20",
	"tnt:tnt 15",
	"default:obsidian 10",
	"default:snowblock 5",

	"mobs:cursed_stone",
	"jt_mods:griefer_soul_block",
	"default:meselamp_white 10",
	"default:meselamp 10",
}

giftbox.giftbox_public_infotext1 = "Gift Box"
giftbox.giftbox_public_infotext2 = "'%s'"
giftbox.giftbox_private_infotext1 = "Gift Box for %s"
giftbox.giftbox_private_infotext2 = "Dear %s: '%s'"

giftbox.giftbox_drops = {
	-- digging gift box allows for a single drop of items with a given a rarity
	{ items = { "default:sword_diamond" }, rarity = 50 },
	{ items = { "default:sword_bronze" }, rarity = 25 },

	{ items = { "default:pick_diamond" }, rarity = 50 },
	{ items = { "default:pick_bronze" }, rarity = 25 },

	-- default drop must be placed last and have rarity of 0 to avoid empty drops
	{ items = { "default:gold_lump 5", "default:coal_lump 10" }, rarity = 0 },
}
