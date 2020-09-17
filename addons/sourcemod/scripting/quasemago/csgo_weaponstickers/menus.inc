static int g_menuSite[MAXPLAYERS + 1] = {0, ...};
static int g_tempSlot[MAXPLAYERS + 1] = {-1, ...};
static int g_tempMaxSlots[MAXPLAYERS + 1] = {0, ...};
static int g_tempIndex[MAXPLAYERS + 1] = {-1, ...};
static char g_tempSearch[MAXPLAYERS +1][MAX_LENGTH_CLASSNAME];

#define ALL_SLOTS 99

void MenusClientDisconnect(int client)
{
	g_menuSite[client] = 0;
	g_tempSlot[client] = -1;
	g_tempMaxSlots[client] = 0;
	g_tempIndex[client] = -1;
	g_tempSearch[client][0] = '\0';
}

/**
 * Menus.
 */
void ShowWeaponStickersMenu(int client, const char[] search = "")
{
	if (!IsPlayerAlive(client))
	{
		CPrintToChat(client, "%t", "Need Alive");
		return;
	}

	int weapon = eItems_GetActiveWeapon(client);
	if (!eItems_IsValidWeapon(weapon) || !IsValidDefIndex(eItems_GetWeaponDefIndexByWeapon(weapon)))
	{
		CPrintToChat(client, "%t", "Invalid Stickers Weapon");
		return;
	}

	int slots = GetWeaponSupportedStickerSlots(weapon);
	if (slots <= 0)
	{
		CPrintToChat(client, "%t", "Invalid Stickers Weapon");
		return;
	}

	int index = eItems_GetWeaponNumByWeapon(weapon);
	if (index < 0)
	{
		CPrintToChat(client, "%t", "Validate Error");
		return;
	}

	g_tempIndex[client] = index;
	g_tempMaxSlots[client] = slots;
	strcopy(g_tempSearch[client], MAX_LENGTH_CLASSNAME, search);

	Menu menu = new Menu(MenuHandler_Menu_WeaponStickers);
	menu.SetTitle("%T", "Menu Stickers Title", client);
	
	for (int i = 0; i < slots; i++)
	{
		static char slot[16];
		IntToString(i, slot, sizeof(slot));
		
		if (g_PlayerWeapon[client][index].m_sticker[i] != 0)
		{
			AddMenuItemFormat(menu, slot, _, "Slot %i\n  -> %s.", i, g_Sticker[eItems_GetStickerNumByDefIndex(g_PlayerWeapon[client][index].m_sticker[i])].m_displayName);
		}
		else
		{
			AddMenuItemFormat(menu, slot, _, "Slot %i\n  -> %T.", i, "None Sticker", client);
		}
	}

	menu.AddItem("x", "", ITEMDRAW_SPACER);
	AddMenuItemFormat(menu, "99", _, "%T.", "All Slots", client);

	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}


public int MenuHandler_Menu_WeaponStickers(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		if (g_tempIndex[client] < 0)
		{
			ShowWeaponStickersMenu(client);
			return;
		}
		
		char buffer[16];
		menu.GetItem(param, buffer, sizeof(buffer));

		g_tempSlot[client] = StringToInt(buffer);

		if (strlen(g_tempSearch[client]) > 2)
		{
			ShowWeaponStickersSetMenu(client, g_tempSlot[client], -1, g_tempSearch[client]);
		}
		else
		{
			ShowWeaponStickerSlotMenu(client, g_tempSlot[client]);
		}
	}
	else if (action == MenuAction_Cancel)
	{
		ResetClientTempVars(client);
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

static void ShowWeaponStickerSlotMenu(int client, int slot)
{
	if (!IsPlayerAlive(client))
	{
		CPrintToChat(client, "%t", "Need Alive");
		return;
	}

	int weapon = eItems_GetActiveWeapon(client);
	if (!eItems_IsValidWeapon(weapon))
	{
		CPrintToChat(client, "%t", "Invalid Stickers Weapon");
		return;
	}

	int weaponIndex = eItems_GetWeaponNumByWeapon(weapon);
	if (weaponIndex < 0 || weaponIndex != g_tempIndex[client])
	{
		CPrintToChat(client, "%t", "Validate Error");
		return;
	}

	char weaponName[MAX_LENGTH_DISPLAY];
	if (!eItems_GetWeaponDisplayNameByWeaponNum(weaponIndex, weaponName, sizeof(weaponName)))
	{
		CPrintToChat(client, "%t", "Validate Error");
		return;
	}

	Menu menu = new Menu(MenuHandler_Menu_StickerSlot);
	if (slot != ALL_SLOTS && g_PlayerWeapon[client][weaponIndex].m_sticker[slot] != 0)
	{
		char stickerName[MAX_LENGTH_DISPLAY];
		eItems_GetStickerDisplayNameByDefIndex(g_PlayerWeapon[client][weaponIndex].m_sticker[slot], stickerName, sizeof(stickerName));
		menu.SetTitle("%T", "Menu Stickers Slot Already Title", client, weaponName, slot, stickerName);
	}
	else
	{
		menu.SetTitle("%T", slot == ALL_SLOTS ? "Menu Stickers Slot Title AllSlots" : "Menu Stickers Slot Title", client, weaponName, slot);
	}

	AddMenuItemFormat(menu, "-1", _, "%T", "Menu Stickers Slot Remove", client);

	for (int i = g_stickerSetsCount - 1; i >= 0; i--)
	{
		static char index[16];
		IntToString(i, index, sizeof(index));
		menu.AddItem(index, g_StickerSet[i].m_displayName);
	}

	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.DisplayAt(client, g_menuSite[client], MENU_TIME_FOREVER);
}

public int MenuHandler_Menu_StickerSlot(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		if (g_tempIndex[client] < 0)
		{
			ShowWeaponStickersMenu(client);
			return;
		}

		char buffer[32];
		menu.GetItem(param, buffer, sizeof(buffer));

		int index = StringToInt(buffer);
		if (index == -1)
		{
			if (g_tempSlot[client] == ALL_SLOTS)
			{
				for (int i = 0; i < g_tempMaxSlots[client]; i++)
				{
					g_PlayerWeapon[client][g_tempIndex[client]].m_sticker[i] = 0;
					UpdateClientData(client, g_tempIndex[client], i);
				}
			}
			else
			{
				g_PlayerWeapon[client][g_tempIndex[client]].m_sticker[g_tempSlot[client]] = 0;
				UpdateClientData(client, g_tempIndex[client], g_tempSlot[client]);
			}

			g_isStickerRefresh[client] = true;
			RefreshClientWeapon(client, g_tempIndex[client]);

			// Announce.
			char weaponName[MAX_LENGTH_DISPLAY];
			eItems_GetWeaponDisplayNameByWeaponNum(g_tempIndex[client], weaponName, sizeof(weaponName));

			if (g_tempSlot[client] == ALL_SLOTS)
			{
				CPrintToChat(client, "%t", "Remove Sticker AllSlots", weaponName);
			}
			else
			{
				CPrintToChat(client, "%t", "Remove Sticker", weaponName, g_tempSlot[client]);
			}

			// Reopen menu.
			g_menuSite[client] = GetMenuSelectionPosition();
			ShowWeaponStickerSlotMenu(client, g_tempSlot[client]);
		}
		else
		{
			ShowWeaponStickersSetMenu(client, g_tempSlot[client], index);
		}
	}
	else if (action == MenuAction_Cancel)
	{
		ResetClientTempVars(client);

		if (param == MenuCancel_ExitBack)
		{
			ShowWeaponStickersMenu(client);
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

static void ShowWeaponStickersSetMenu(int client, int slot, int stickerSet, const char[] search = "")
{
	if (!IsPlayerAlive(client))
	{
		CPrintToChat(client, "%t", "Need Alive");
		return;
	}

	int weapon = eItems_GetActiveWeapon(client);
	if (!IsValidEntity(weapon))
	{
		CPrintToChat(client, "%t", "Invalid Stickers Weapon");
		return;
	}
	
	int weaponIndex = eItems_GetWeaponNumByWeapon(weapon);
	if (weaponIndex < 0 || weaponIndex != g_tempIndex[client])
	{
		CPrintToChat(client, "%t", "Validate Error");
		return;
	}

	if (strlen(search) < 2 && stickerSet < 0)
	{
		CPrintToChat(client, "%t", "Validate Error");
		return;
	}

	char weaponName[MAX_LENGTH_DISPLAY];
	if (!eItems_GetWeaponDisplayNameByWeaponNum(weaponIndex, weaponName, sizeof(weaponName)))
	{
		CPrintToChat(client, "%t", "Validate Error");
		return;
	}

	Menu menu = new Menu(MenuHandler_Menu_StickerSet);
	int count;

	// Add stickers to menu.
	if (strlen(search) > 2)
	{
		if (slot != ALL_SLOTS && g_PlayerWeapon[client][weaponIndex].m_sticker[slot] != 0)
		{
			char stickerName[MAX_LENGTH_DISPLAY];
			eItems_GetStickerDisplayNameByDefIndex(g_PlayerWeapon[client][weaponIndex].m_sticker[slot], stickerName, sizeof(stickerName));
			menu.SetTitle("%T", "Menu Stickers Set Search Already Title", client, weaponName, slot, stickerName, search);
		}
		else
		{
			menu.SetTitle("%T", slot == ALL_SLOTS ? "Menu Stickers Set Search Title AllSlots" : "Menu Stickers Set Search Title", client, weaponName, slot, search);
		}

		for (int i = 0; i < g_stickerCount; i++)
		{
			if (StrContains(g_Sticker[i].m_displayName, search, false) == -1)
			{
				continue;
			}

			count++;

			static char index[16];
			IntToString(i, index, sizeof(index));
			menu.AddItem(index, g_Sticker[i].m_displayName);
		}
	}
	else
	{
		if (slot != ALL_SLOTS && g_PlayerWeapon[client][weaponIndex].m_sticker[slot] != 0)
		{
			char stickerName[MAX_LENGTH_DISPLAY];
			eItems_GetStickerDisplayNameByDefIndex(g_PlayerWeapon[client][weaponIndex].m_sticker[slot], stickerName, sizeof(stickerName));
			menu.SetTitle("%T", "Menu Stickers Set Already Title", client, weaponName, slot, stickerName, g_StickerSet[stickerSet].m_displayName);
		}
		else
		{
			menu.SetTitle("%T", slot == ALL_SLOTS ? "Menu Stickers Set Title AllSlots" : "Menu Stickers Set Title", client, weaponName, slot, g_StickerSet[stickerSet].m_displayName);
		}

		int length = g_StickerSet[stickerSet].m_Stickers.Length;
		for (int i = 0; i < length; i++)
		{
			int sticker = g_StickerSet[stickerSet].m_Stickers.Get(i);
			if (sticker < 0)
			{
				continue;
			}

			static char index[16];
			IntToString(sticker, index, sizeof(index));
			menu.AddItem(index, g_Sticker[sticker].m_displayName);
		}
	}

	if (!count && strlen(search) > 2)
	{
		AddMenuItemFormat(menu, "-1", ITEMDRAW_DISABLED, "%T", "Menu Stickers Slot Search None", client);
	}

	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.DisplayAt(client, g_menuSite[client], MENU_TIME_FOREVER);
}

public int MenuHandler_Menu_StickerSet(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		if (g_tempIndex[client] < 0)
		{
			ShowWeaponStickersMenu(client);
			return;
		}

		char buffer[32];
		menu.GetItem(param, buffer, sizeof(buffer));

		int stickerIndex = StringToInt(buffer);
		if (stickerIndex < 0)
		{
			ShowWeaponStickersMenu(client);
			return;
		}

		int stickerSet = eItems_GetStickerSetNumByStickerSetId(g_Sticker[stickerIndex].m_setId);
		if (stickerSet < 0)
		{
			ShowWeaponStickersMenu(client);
			return;
		}

		int time = GetTime();
		if (g_playerReuseTime[client] > time)
		{
			CPrintToChat(client, "%t", "Delay Sticker", g_playerReuseTime[client] - time);

			// Reopen menu.
			g_menuSite[client] = GetMenuSelectionPosition();
			ShowWeaponStickersSetMenu(client, g_tempSlot[client], stickerSet, g_tempSearch[client]);
			return;
		}

		if (g_tempSlot[client] == ALL_SLOTS)
		{
			for (int i = 0; i < g_tempMaxSlots[client]; i++)
			{
				g_PlayerWeapon[client][g_tempIndex[client]].m_sticker[i] = g_Sticker[stickerIndex].m_defIndex;
				UpdateClientData(client, g_tempIndex[client], i);
			}
		}
		else
		{
			g_PlayerWeapon[client][g_tempIndex[client]].m_sticker[g_tempSlot[client]] = g_Sticker[stickerIndex].m_defIndex;
			UpdateClientData(client, g_tempIndex[client], g_tempSlot[client]);
		}

		g_isStickerRefresh[client] = true;
		RefreshClientWeapon(client, g_tempIndex[client]);

		// Announce.
		char weaponName[MAX_LENGTH_DISPLAY];
		eItems_GetWeaponDisplayNameByWeaponNum(g_tempIndex[client], weaponName, sizeof(weaponName));

		if (g_tempSlot[client] == ALL_SLOTS)
		{
			CPrintToChat(client, "%t", "Change Sticker AllSlots", g_Sticker[stickerIndex].m_displayName, weaponName);
		}
		else
		{
			CPrintToChat(client, "%t", "Change Sticker", g_Sticker[stickerIndex].m_displayName, weaponName, g_tempSlot[client]);
		}

		// Reopen menu.
		g_menuSite[client] = GetMenuSelectionPosition();
		ShowWeaponStickersSetMenu(client, g_tempSlot[client], stickerSet, g_tempSearch[client]);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_ExitBack)
		{
			if (strlen(g_tempSearch[client]) > 2)
			{
				ResetClientTempVars(client);
				ShowWeaponStickersMenu(client);
			}
			else
			{
				ShowWeaponStickerSlotMenu(client, g_tempSlot[client]);
			}
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

static void ResetClientTempVars(int client)
{
	g_menuSite[client] = 0;
	g_tempSlot[client] = -1;
	g_tempMaxSlots[client] = 0;
	g_tempIndex[client] = -1;
	g_tempSearch[client][0] = '\0';
}