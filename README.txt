Giftbox Mod v2.2
By Leslie E. Krause

https://forum.minetest.net/viewtopic.php?f=9&t=19133

Repository
----------------------

Browse source code:
  https://bitbucket.org/sorcerykid/giftbox

Download archive:
  https://bitbucket.org/sorcerykid/giftbox/get/master.zip
  https://bitbucket.org/sorcerykid/giftbox/get/master.tar.gz

Revision History
----------------------

Version 1.0b (12-Jan-2018)
  - initial version within doors mod

Version 2.0 (31-Aug-2018)
  - separated common routines into standalone mod
  - included support files for public release

Version 1.0a (Build 01)
  - initial build

Version 1.1a (Build 02)
  - moved configuration settings into separate file
  - made infotext of admin giftbox configurable
  - made background of admin giftbox configurable
  - changed debug log messages into tokenized strings

Version 2.0 (Build 03)
  - merged colored giftboxes from mt_seasons mod
  - added aliases for original colored giftboxes
  - improved end-user customizations of giftbox

Version 2.0 (Build 04)
  - renamed admin giftbox to "present" for distinction
  - created textures for newly registered nodes
  - renamed associated texture files of present
  - replaced owner meta for present with sender instead
  - added protection check to inventory take of present
  - disabled formspec for recipient of empty present
  - added sender/receiver checks when digging giftbox
  - made default infotext of giftbox configurable
  - changed owner of giftbox to placer for simplicity
  - set default receiver of giftbox during placement
  - switched all prior references of owner to receiver
  - registered alias for original admin giftbox

Version 2.1 (Build 05)
  - escaped giftbox message in formspec string
  - improved validation of giftbox message input

Version 2.2 (Build 06)
  - added dependency for formspecs and ownership mods
  - introduced packages with specialized behavior
  - created textures for newly registered items
  - fixed regex during validation of recipient names
  - fixed erroneous checks against unowned nodes
  - general code refactoring and reformatting

Version 2.2 (Build 07)
  - fixed typo in craft recipe of unsealed package

Dependencies
----------------------

Default Mod (required)
  https://github.com/minetest/minetest_game/default

ActiveFormspecs Mod (required)
  https://bitbucket.org/sorcerykid/formspecs

Basic Ownership Mod (required)
  https://bitbucket.org/sorcerykid/ownership

Compatability
----------------------

Minetest 0.4.15+ required

Installation
----------------------

  1) Unzip the archive into the mods directory of your game
  2) Rename the giftbox-master directory to "giftbox"

Source Code License
----------------------------------------------------------

GNU Lesser General Public License v3 (LGPL-3.0)

Copyright (c) 2016-2018, Leslie E. Krause

Original source code by maikerumine:
https://github.com/maikerumine/just_test_tribute/blob/master/mods/mt_seasons/nodes.lua

This program is free software; you can redistribute it and/or modify it under the terms of
the GNU Lesser General Public License as published by the Free Software Foundation; either
version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

http://www.gnu.org/licenses/lgpl-2.1.html

Multimedia License (textures, sounds, and models)
----------------------------------------------------------

Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)

	/models/giftbox.obj
	by Toby109tt

	/textures/present_bottom.png
	by lag01
	modified by maikerumine
	modified by sorcerykid

	/textures/present_side.png
	by lag01
	modified by maikerumine
	modified by sorcerykid

	/textures/present_top.png
	by lag01
	modified by maikerumine
	modified by sorcerykid

	/textures/giftbox_red.png
	by Toby109tt
	modified by sorcerykid

	/textures/giftbox_green.png
	by Toby109tt
	modified by sorcerykid

	/textures/giftbox_blue.png
	by Toby109tt
	modified by sorcerykid

	/textures/giftbox_cyan.png
	by Toby109tt
	modified by sorcerykid

	/textures/giftbox_magenta.png
	by Toby109tt
	modified by sorcerykid

	/textures/giftbox_yellow.png
	by Toby109tt
	modified by sorcerykid

	/textures/giftbox_black.png
	by Toby109tt
	modified by sorcerykid

	/textures/giftbox_white.png
	by Toby109tt
	modified by sorcerykid

You are free to:
Share — copy and redistribute the material in any medium or format.
Adapt — remix, transform, and build upon the material for any purpose, even commercially.
The licensor cannot revoke these freedoms as long as you follow the license terms.

Under the following terms:

Attribution — You must give appropriate credit, provide a link to the license, and
indicate if changes were made. You may do so in any reasonable manner, but not in any way
that suggests the licensor endorses you or your use.

No additional restrictions — You may not apply legal terms or technological measures that
legally restrict others from doing anything the license permits.

Notices:

You do not have to comply with the license for elements of the material in the public
domain or where your use is permitted by an applicable exception or limitation.
No warranties are given. The license may not give you all of the permissions necessary
for your intended use. For example, other rights such as publicity, privacy, or moral
rights may limit how you use the material.

For more details:
http://creativecommons.org/licenses/by-sa/3.0/
