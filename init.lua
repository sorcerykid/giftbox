--------------------------------------------------------
-- Minetest :: Giftbox Mod v2.2 (giftbox)
--
-- See README.txt for licensing and other information.
-- Copyright (c) 2016-2018, Leslie E. Krause
--
-- ./games/minetest_game/mods/giftbox/init.lua
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

minetest.register_node( "giftbox:present", {
	description = "Gift Box",
	tiles = { "present_top.png", "present_bottom.png", "present_side.png",
		"present_side.png", "present_side.png", "present_side.png" },
	is_ground_content = false,
	groups = { choppy = 2, oddly_breakable_by_hand = 2 },
	sounds = default.node_sound_wood_defaults( ),

	drop = { },

	after_place_node = function ( pos, player )
		minetest.get_meta( pos ):set_string( "infotext", giftbox.present_infotext .. " (placed by " .. player:get_player_name( ) .. ")" )
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
	allow_metadata_inventory_take = function ( pos, listname, index, stack, player )
		-- only allow receiver to take item and remove node
		-- of course, placer can already bypass protection

		if minetest.is_protected( pos, player:get_player_name( ) ) then
			return 0
		end
		return stack:get_count( )
	end,
	allow_metadata_inventory_put = function ( pos, listname, index, stack, player )
		return 0
	end,
	on_metadata_inventory_take = function ( pos, listname, index, stack, player )
		if default.is_empty( pos ) then
			minetest.remove_node( pos )
		end
		minetest.log( "action", string.format( default.STATUS_CONTAINER_GET, player:get_player_name( ), "giftbox", minetest.pos_to_string( pos ) ) )
	end,
	on_open = function ( pos, clicker )
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
		elseif not minetest.is_protected( pos, pname ) and not default.is_empty( pos ) then
			-- only show formspec if placer remembered to select item
			-- otherwise, allow node be dug normally (but no drops)

			local formspec =
				"size[10,6.5]" ..
				"image[0,0;12,6;" .. giftbox.present_greeting .. "]" ..
		        	default.gui_bg ..
        			default.gui_bg_img ..
		        	default.gui_slots ..
				"list[nodemeta:%s;main;7,4;1,1;]" ..
				"list[current_player;main;1,5.5;8,1;]" ..
				default.get_hotbar_bg( 1, 5.5 )
			return string.format( formspec, spos )
		end
	end,
        on_close = function ( pos, player, fields )
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
} )

minetest.register_craftitem( "giftbox:package_unsealed", {
	description = "Package (To seal, point to an object and use)",
	inventory_image = "package_unsealed.png",
	wield_image = "package_unsealed2.png",
	groups = { flammable = 3 },
	on_use = function( cur_stack, player, pointed_thing )
		if pointed_thing.type == "object" and not pointed_thing.ref:is_player( ) then
			local player_name = player:get_player_name( )
			local player_inv = player:get_inventory( )

			-- ignore objects that are not builtin-item (sanity check)
			local entity = pointed_thing.ref:get_luaentity( )
			if entity.name ~= "__builtin:item" then return end

			local item_name = ItemStack( entity.itemstring ):get_name( )
			if item_name == "giftbox:package_unsealed" or item_name == "giftbox:package_sealed" then
				minetest.chat_send_player( player_name, "This item cannot be stored inside a package." )
				return
			end

			cur_stack:take_item( )
			pointed_thing.ref:remove( )

			-- produce a sealed package containing pointed_thing
			local new_stack = ItemStack( "giftbox:package_sealed" )
			local meta = new_stack:get_meta( )

			meta:set_string( "description", giftbox.parcel_public_description ..
				" (from " .. player_name .. " on " .. os.date( "%x" ) .. ")" )
			meta:set_string( "timestamp", os.time( ) )
			meta:set_string( "receiver", default.OWNER_NOBODY )
			meta:set_string( "owner", player_name )
			meta:set_string( "is_anonymous", "false" )
			meta:set_string( "itemstring", entity.itemstring )

			if player_inv:room_for_item( "main", new_stack ) then
				player_inv:add_item( "main", new_stack )
			else
				minetest.add_item( player:getpos( ), new_stack )
			end
		end
		return cur_stack
	end
} )

minetest.register_craftitem( "giftbox:package_sealed", {
	inventory_image = "package_sealed.png",
	wield_image = "package_sealed2.png",
	groups = { flammable = 3, not_in_creative_inventory = 1 },
        on_use = function( itemstack, player, pointed_thing )
		local player_name = player:get_player_name( )
		local meta = itemstack:get_meta( )
		local receiver = meta:get_string( "receiver" )
		local owner = meta:get_string( "owner" )

		if owner == player_name or minetest.check_player_privs( player_name, { give = true } ) then
			local formspec =
				"size[8,3.5]" ..
				default.gui_bg ..
				default.gui_bg_img ..
				"checkbox[4.8,1.8;is_anonymous;Anonymous Sender;" .. meta:get_string( "is_anonymous" ) .. "]" ..
				"label[0.1,2.0;Recipient:]" ..
				"field[1.8,2.4;3.0,0.25;receiver;;" .. receiver .. "]" ..
				"label[2.9,0.0;Package Contents:]" ..
				"image[3.5,0.6;1,1;gui_furnace_arrow_bg.png^[transformR270]" ..
				"item_image_button[2.5,0.6;1,1;giftbox:package_sealed;restore;]" ..
				"item_image_button[4.5,0.6;1,1;" .. ItemStack( meta:get_string( "itemstring" ) ):get_name( ) .. ";revert;]" ..
				"label[0.1,2.9;Stored on " .. os.date( "%x %X", tonumber( meta:get_string( "timestamp" ) ) ) .. "]" ..
				"button_exit[6.0,3.0;2,0.3;save;Save]"

			minetest.create_form( nil, player_name, formspec, function ( _, player, fields )

				if fields.is_anonymous then
					meta:set_string( "is_anonymous", fields.is_anonymous )

				elseif fields.revert then
					local itemstring = meta:get_string( "itemstring" )
					player:set_wielded_item( ItemStack( itemstring ) )
					minetest.destroy_form( player_name )

				elseif fields.restore then
					player:set_wielded_item( "giftbox:package_unsealed" )
					minetest.destroy_form( player_name )

				elseif fields.save and fields.receiver then
					if fields.receiver == owner then
						minetest.chat_send_player( owner, "You cannot send a parcel to yourself." )
						return
					elseif fields.receiver ~= default.OWNER_NOBODY and not string.find( fields.receiver, "^[-_A-Za-z0-9]+$" ) then
						minetest.chat_send_player( owner, "The specified recipient is invalid." )
						return
					end

					-- public vs. private letters and parcels
					local description = fields.receiver == default.OWNER_NOBODY and
						giftbox.parcel_public_description or
						string.format( giftbox.parcel_private_description, fields.receiver )

					if meta:get_string( "is_anonymous" ) == "false" then
						description = description .. " (from " .. owner .. " on " .. os.date( "%x", tonumber( meta:get_string( "timestamp" ) ) ) .. ")"
					end

					meta:set_string( "description", description )
					meta:set_string( "receiver", fields.receiver )

					player:set_wielded_item( itemstack )
				end
			end )

		elseif receiver == player_name or receiver == default.OWNER_NOBODY then
			local formspec =
				"size[9,7]" ..
		        	default.gui_bg ..
        			default.gui_bg_img ..
				"background[0,0;9,6;" .. giftbox.package_viewer .. "]" ..
        			"label[0.5,0.5;" .. minetest.colorize( "#000000", os.date( "%x %X", tonumber( meta:get_string( "timestamp" ) ) ) ) .. "]" ..
        			"button_exit[3.0,6.5;3.0,0.3;open;Open Package]"

        		if meta:get_string( "is_anonymous" ) == "false" then
				formspec = formspec .. "label[3.5,2.5;" .. minetest.colorize( "#000000", owner ) .. "]"
        		end
        		if receiver ~= default.OWNER_NOBODY then
				formspec = formspec .. "label[3.5,3.0;" .. minetest.colorize( "#000000", receiver ) .. "]"
        		end

			minetest.create_form( nil, player_name, formspec, function ( _, player, fields )
				if fields.open then
					local itemstring = meta:get_string( "itemstring" )
					player:set_wielded_item( ItemStack( itemstring ) )
					-- TODO: record deliveries of letters and parcels in debug log
				end
			end )
		else
			minetest.chat_send_player( player_name, "Access denied. This parcel does not belong to you." )
		end

		return itemstack
	end
} )

minetest.register_craft( {
	output = "giftbox:package_unsealed",
	recipe = {
		{ "default:paper", "default:paper", "default:paper" },
		{ "default:paper", "", "default:paper" },
		{ "default:paper", "default:paper", "default:paper" },
	}
} )

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

		on_dig = function ( pos, node, player )
			local digger = player:get_player_name( )
			local receiver = minetest.get_meta( pos ):get_string( "receiver" )
		--	local is_protected = minetest.get_meta( pos ):get_string( "is_protected" ) == "true"

			if not minetest.is_protected( pos, digger ) then
				-- always allow owner to dig node, but still obey protection
				minetest.handle_node_drops( pos, { node.name }, player )
				minetest.remove_node( pos )

			elseif receiver == digger or receiver == default.OWNER_NOBODY then
				-- otherwise drop random items directly for receiver (if any)
				-- this is necessary to bypass protection checks
				local drops = minetest.get_node_drops( node.name, player:get_wielded_item( ):get_name( ) )

				minetest.handle_node_drops( pos, drops, player )
				minetest.remove_node( pos )
			end
		end,
		after_place_node = function ( pos, player )
			local placer = player:get_player_name( ) or "singleplayer"
			local meta = minetest.get_meta( pos )

			default.set_owner( pos, placer )
			meta:set_string( "receiver", default.OWNER_NOBODY )
			meta:set_string( "is_anonymous", "false" )

			-- initial item string: Gift Box (placed by sorcerykid)
			meta:set_string( "infotext", giftbox.giftbox_public_infotext1 .. " (from " .. placer .. ")" )
		end,
		on_open = function ( pos, player, fields )
			local meta = minetest.get_meta( pos )
			local formspec =
				"size[8,3]" ..
				default.gui_bg ..
				default.gui_bg_img ..
				"button_exit[6,2.5;2,0.3;save;Save]" ..
				"checkbox[4.5,1.3;is_anonymous;Anonymous Sender;" .. meta:get_string( "is_anonymous" ) .. "]" ..
				"label[0.1,0;Personalize your holiday greeting (or leave blank for the default):]" ..
				"field[0.4,1;7.8,0.25;message;;" .. minetest.formspec_escape( meta:get_string( "message" ) ) .. "]" ..
				"label[0.1,1.5;Recipient:]" ..
				"field[1.8,1.9;2.5,0.25;receiver;;" .. meta:get_string( "receiver" ) .. "]"

			-- only placer of gift box should edit properties, not the receiver
			if default.is_owner( pos, player ) then
				return formspec
        		end        
		end,
	        on_close = function ( pos, player, fields )
			local owner = player:get_player_name( )
			local meta = minetest.get_meta( pos )

			-- only placer of gift box should edit properties, not the receiver
			if not default.is_owner( pos, player ) then return end

			if fields.is_anonymous then
				-- in next version of active formspecs, we should save checkbox state
				-- in form meta first rather than directly to node meta
				meta:set_string( "is_anonymous", fields.is_anonymous )

			elseif fields.save and fields.message and fields.receiver then
				local infotext

				if fields.message ~= "" and string.len( fields.message ) < 5 then
					minetest.chat_send_player( owner, "The specified message is too short." )
					return
				elseif string.len( fields.message ) > 250 then
					minetest.chat_send_player( owner, "The specified message is too long." )
					return
				elseif fields.receiver == owner then
					minetest.chat_send_player( owner, "You cannot give a gift to yourself." )
					return
				elseif fields.receiver ~= default.OWNER_NOBODY and not string.find( fields.receiver, "^[-_A-Za-z0-9]+$" ) then
					minetest.chat_send_player( owner, "The specified recipient is invalid." )
					return
				end

				-- item string with message: Dear sorcerykid: "Happy holidays!" (placed by sorcerykid)
				-- item string without message: Gift Box for maikerumine (placed by sorcerykid)
				
				if fields.receiver == default.OWNER_NOBODY then
					-- public gift box
					infotext = fields.message == "" and
						giftbox.giftbox_public_infotext1 or
						string.format( giftbox.giftbox_public_infotext2, fields.message )
				else
					-- private gift box
					infotext = fields.message == "" and
						string.format( giftbox.giftbox_private_infotext1, fields.receiver ) or
						string.format( giftbox.giftbox_private_infotext2, fields.receiver, fields.message )
				end

				if meta:get_string( "is_anonymous" ) == "false" then
					infotext = infotext .. " (from " .. owner .. ")"
				end

				minetest.log( "action", string.format( default.STATUS_SIGNATURE_SET, player:get_player_name( ), fields.message, "giftbox", minetest.pos_to_string( pos ) ) )

				meta:set_string( "receiver", fields.receiver )
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

minetest.register_alias( "giftbox:giftbox", "giftbox:present" )
