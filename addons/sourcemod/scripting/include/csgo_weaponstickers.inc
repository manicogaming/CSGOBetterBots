/*
 * ============================================================================
 *
 *  [CS:GO] Weapon Stickers.
 *  Copyright (C) 2020 - Bruno "quasemago" Ronning <brunoronningfn@gmail.com>
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, per version 3 of the License, or
 *  any later version.	
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * ============================================================================
*/

#if defined _csgo_weaponstickers_included
 #endinput
#endif
#define _csgo_weaponstickers_included

/**
 * Set sticker to weapon.
 *
 * @param client			Client index.
 * @param weapon			Weapon index.
 * @param slot				Slot number (0-5).
 * @param defIndex			Sticker defIndex.
 * @param wear				Sticker wear.
 * @return					True on success, false on failure.
 */
native bool CS_SetWeaponSticker(int client, int weapon, int slot, int defIndex, float wear);

/**
 * Get random sticker index.
 *
 * @return					Sticker index.
 */
native int CS_GetRandomSticker();