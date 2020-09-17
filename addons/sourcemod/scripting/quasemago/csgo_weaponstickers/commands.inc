void LoadCommands()
{
	RegConsoleCmd("sm_sticker", Command_Stickers);
	RegConsoleCmd("sm_stickers", Command_Stickers);
}

public Action Command_Stickers(int client, int args)
{
	if (!g_cvarEnabled.BoolValue)
	{
		CPrintToChat(client, "%t", "Disabled Feature");
		return Plugin_Handled;
	}

	if (strlen(g_requiredFlag) > 0 && !ClientHasFlag(client, g_requiredFlag))
	{
		CPrintToChat(client, "%t", "Need Access");
		return Plugin_Handled;
	}

	if (args != 0)
	{
		char arg[MAX_LENGTH_CLASSNAME];
		GetCmdArgString(arg, sizeof(arg));

		if (strlen(arg) < 2)
		{
			CPrintToChat(client, "%t", "Min Length Search");
			return Plugin_Handled;
		}

		ShowWeaponStickersMenu(client, arg);
	}
	else
	{
		ShowWeaponStickersMenu(client);
	}
	return Plugin_Handled;
}