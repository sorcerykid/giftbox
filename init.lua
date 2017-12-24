--------------------------------------------------------
-- Minetest :: Giftbox Mod v2.0 alpha (giftbox)
--
-- See README.txt for licensing and other information.
-- Copyright (c) 2016-2017, Leslie Ellen Krause
--
-- ./games/just_test_tribute/mods/giftbox/init.lua
--------------------------------------------------------

giftbox = { }

dofile( minetest.get_modpath( "giftbox" ) .. "/config.lua" )

local box_colors = { "black", "blue", "cyan", "green", "magenta", "red", "white", "yellow" }
	-- black = black + grey
	-- blue = blue + magenta
	-- brown => yellow
	-- cyan = cyan + yellow
	-- dark_green => green
	-- dark_grey => cyan
	-- green = green + red
	-- grey => white
	-- magenta = magenta + cyan
	-- orange => red
	-- pink => magenta
	-- red = red + green
	-- violet => blue
	-- white = white + grey
	-- yellow = yellow + green

minetest.register_node( "giftbox:giftbox", {
	description = "Gift Box",
        tiles = { "giftbox_top.png", "giftbox_bottom.png", "giftbox_side.png",
                "giftbox_side.png", "giftbox_side.png", "giftbox_side.png" },
        is_ground_content = false,
        groups = { choppy = 2, oddly_breakable_by_hand = 2 },
        sounds = default.node_sound_wood_defaults( ),

	after_place_node = function( pos, player )
		local owner = player:get_player_name( ) or "singleplayer"
		local meta = minetest.get_meta( pos )
--		meta:set_string( "owner", owner )
		meta:set_string( "infotext", giftbox.present_infotext .. " (placed by " .. owner .. ")" )
	end,
        on_construct = function ( pos )
		local meta = minetest.get_meta( pos )
		meta:get_inventory( ):set_size( "main", 1 )
		meta:set_string( "oldtime", os.time( ) )
		meta:set_string( "newtime", os.time( ) )
	end,
	can_dig = function ( pos, player )
		return not minetest.is_protected( pos, player:get_player_name( ) ) and default.is_empty( pos )
	end,
	allow_metadata_inventory_take = function( pos, listname, index, stack, player )
		if not default.is_owner( pos, player ) then
			return 0
		end
		return stack:get_count( )
	end,
	allow_metadata_inventory_put = function( pos, listname, index, stack, player )
		return 0
	end,
	on_metadata_inventory_take = function( pos, listname, index, stack, player )
		if default.is_empty( pos ) then
			minetest.remove_node( pos )
		end
		minetest.log( "action", string.format( default.STATUS_CONTAINER_GET, player:get_player_name( ), "giftbox", minetest.pos_to_string( pos ) ) )
	end,
	on_open = function( pos, clicker )
		local pname = clicker:get_player_name( )
		local spos = pos.x .. "," .. pos.y .. "," .. pos.z

		if minetest.check_player_privs( pname, { give = true } ) then
			local slot, name
			local formspec =
				"size[8,6]" ..
		        	default.gui_bg ..
        			default.gui_bg_img ..
		        	default.gui_slots ..
				"label[1,0.8;Select an item to place in the gift box.]" ..
				"list[nodemeta:%s;main;6,0.5;1,1;]"

			slot = 0
		        for _, name in ipairs( giftbox.present_items ) do
				formspec = formspec .. "item_image_button[ " .. ( slot % 8 ) .. "," .. ( math.floor ( slot / 8 ) + 2 ) .. ";1,1;" .. name .. ";add " .. name .. ";]"
				slot = slot + 1
	                end
			return string.format( formspec, spos )
		elseif not minetest.is_protected( pos, pname ) then
			local formspec =
				"size[10,6.5]" ..
				"image[0,0;12,6;" .. giftbox.present_greeting .. "]" ..
		        	default.gui_bg ..
        			default.gui_bg_img ..
		        	default.gui_slots ..
				"list[nodemeta:%s;main;7,4;1,1;]" ..
				"list[current_player;main;1,5.5;8,1;]" ..
				default.get_hotbar_bg(1,5.5)
			return string.format( formspec, spos )
		end
	end,
        on_close = function( pos, player, fields )
		local fname, item

		fname = next( fields, nil )	-- use next since we only care about the name of a single button
		if minetest.check_player_privs( player:get_player_name( ), { give = true } ) and fname then
			item = string.match( fname, "add (.+)" )
			if item then
                	        minetest.get_meta( pos ):get_inventory( ):set_stack( "main", 1, item )
				minetest.log( "action", string.format( default.STATUS_CONTAINER_PUT, player:get_player_name( ), "present", minetest.pos_to_string( pos ) ) )
			end
		end
	end,
})

for i, color in ipairs( box_colors ) do
	minetest.register_node( "giftbox:giftbox_" .. color, {
		description = ( color:gsub( "^%l", string.upper ) ) .. " Gift Box",
		drawtype = "mesh",
		mesh = "giftbox.obj",
		tiles = { "giftbox_" .. color .. ".png" },
		paramtype = "light",
		visual_scale = 0.45,
		wield_scale = { x = 1, y = 1, z = 1 },	-- apparently no way to set wield scale of mesh?
		sunlight_propagates = true,
		is_ground_content = false,
		groups = { choppy = 2, oddly_breakable_by_hand = 2, flammable = 1 },
		sounds = default.node_sound_dirt_defaults(),
		paramtype2 = "facedir",

	        selection_box = {
			type = "fixed",
			fixed = {
				{ -0.45, -0.5, -0.45,  0.45,  0.45, 0.45 },
			}
		},

		drop = { max_items = 1,	items = giftbox.giftbox_drops },
	
		after_place_node = function( pos, player )
			-- initial item string: Gift Box (placed by sorcerykid)

			local placer = player:get_player_name( ) or "singleplayer"
			local meta = minetest.get_meta( pos )
			meta:set_string( "owner", default.OWNER_NOBODY )
			meta:set_string( "placer", placer )
			meta:set_string( "is_anonymous", "false" )
			meta:set_string( "infotext", "Public Gift Box (from " .. placer .. ")" )
		end,
		on_open = function( pos, player, fields )
			local meta = minetest.get_meta( pos )
			local formspec =
				"size[8,3]" ..
				default.gui_bg ..
				default.gui_bg_img ..
				"button_exit[6,2.5;2,0.3;save;Save]" ..
				"checkbox[6,1.6;is_anonymous;Anonymous Sender;" .. meta:get_string( "is_anonymous" ) .. "]" ..
				"label[0.1,0;Personalize your holiday greeting (or leave blank for the default):]" ..
				"field[0.4,1;7.5,0.25;message;;" .. meta:get_string( "message" ) .. "]" ..
				"label[0.1,1.5;Recipient:]" ..
				"field[1.8,1.9;3.5,0.25;owner;;" .. meta:get_string( "owner" ) .. "]"

			-- only placer of gift box should edit properties, not the receiver
			if meta:get_string( "placer" ) ~= placer then
				return formspec
        		end        
		end,
	        on_close = function( pos, player, fields )
			local placer = player:get_player_name( )
			local meta = minetest.get_meta( pos )

			-- only placer of gift box should edit properties, not the receiver
			if meta:get_string( "placer" ) ~= placer then return end

			if fields.is_anonymous then
				-- in next version of active formspecs, we should save checkbox state
				-- in form meta first rather than directly to node meta
				meta:set_string( "is_anonymous", fields.is_anonymous )

			elseif fields.save and fields.message and fields.owner then
				local infotext

				if string.len( fields.message ) > 50 then
					minetest.chat_send_player( placer, "The specified message is too long." )
					return
				elseif fields.owner == placer then
					minetest.chat_send_player( placer, "You cannot send a gift to yourself." )
					return
				elseif not "" and not string.find( fields.owner, "^[_A-Za-z0-9]+$" ) then
					minetest.chat_send_player( placer, "The specified recipient is invalid." )
					return
				end

				-- item string with message: Dear sorcerykid: "Happy holidays!" (placed by sorcerykid)
				-- item string without message: Gift Box for maikerumine (placed by sorcerykid)
				
				if fields.owner == default.OWNER_NOBODY then
					-- public gift box
					infotext = fields.message == "" and "Gift Box" or "\"" .. fields.message .. "\""
				else
					-- private gift box
					infotext = fields.message == "" and "Gift Box for " .. fields.owner or "Dear " .. fields.owner .. ": \"" .. fields.message .. "\""
				end

				if meta:get_string( "is_anonymous" ) == "false" then
					infotext = infotext .. " (from " .. placer .. ")"
				end

				minetest.log( "action", string.format( default.STATUS_SIGNATURE_SET, player:get_player_name( ), fields.message, "giftbox", minetest.pos_to_string( pos ) ) )

				meta:set_string( "owner", fields.owner )
				meta:set_string( "message", fields.message )
				meta:set_string( "infotext", infotext )
			end
		end,
	} )

	minetest.register_craft( {
		output = "giftbox:giftbox_" .. color,
		recipe = {
			{ "wool:" .. color, "farming:cotton", "wool:" .. color },
			{ "default:paper", "default:mese_crystal", "default:paper" },
			{ "wool:" .. color, "default:paper", "wool:" .. color },
		}
	} )
end

minetest.register_alias( "mt_seasons:gift_box_brown", "giftbox:giftbox_yellow" )
minetest.register_alias( "mt_seasons:gift_box_dark_green", "giftbox:giftbox_green" )
minetest.register_alias( "mt_seasons:gift_box_dark_grey", "giftbox:giftbox_cyan" )
minetest.register_alias( "mt_seasons:gift_box_grey", "giftbox:giftbox_white" )
minetest.register_alias( "mt_seasons:gift_box_orange", "giftbox:giftbox_red" )
minetest.register_alias( "mt_seasons:gift_box_pink", "giftbox:giftbox_magenta" )
minetest.register_alias( "mt_seasons:gift_box_violet", "giftbox:giftbox_blue" )

minetest.register_alias( "mt_seasons:gift_box_red", "giftbox:giftbox_red" )
minetest.register_alias( "mt_seasons:gift_box_green", "giftbox:giftbox_green" )
minetest.register_alias( "mt_seasons:gift_box_blue", "giftbox:giftbox_blue" )
minetest.register_alias( "mt_seasons:gift_box_cyan", "giftbox:giftbox_cyan" )
minetest.register_alias( "mt_seasons:gift_box_magenta", "giftbox:giftbox_magenta" )
minetest.register_alias( "mt_seasons:gift_box_yellow", "giftbox:giftbox_yellow" )
minetest.register_alias( "mt_seasons:gift_box_white", "giftbox:giftbox_white" )
minetest.register_alias( "mt_seasons:gift_box_black", "giftbox:giftbox_black" )
