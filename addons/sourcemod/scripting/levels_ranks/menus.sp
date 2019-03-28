public Action OnClientSayCommand(int iClient, const char[] command, const char[] sArgs)
{
	if(iClient && g_bInitialized[iClient])
	{
		if(g_iTypeStatistics != 2)
		{
			if(!strcmp(sArgs, "top", false))
			{
				PrintTop(iClient, 0);
			}
			else if(!strcmp(sArgs, "rank", false))
			{
				int iKills, iDeaths;
				char sMessage[PLATFORM_MAX_PATH];

				if(KILLS(iClient) == 0) iKills = 1;
				else iKills = KILLS(iClient);

				if(DEATHS(iClient) == 0) iDeaths = 1;
				else iDeaths = DEATHS(iClient);

				switch(g_bRankMessage)
				{
					case true:
					{
						for(int i = 1; i <= MaxClients; i++)
						{
							if(g_bInitialized[i])
							{
								FormatEx(sMessage, sizeof(sMessage), "%T", "RankPlayer", i, iClient, g_iDBRankPlayer[iClient], g_iDBCountPlayers, EXP(iClient), iKills, iDeaths, float(iKills) / float(iDeaths));
								LR_PrintToChat(i, "%s", sMessage);
							}
						}
					}

					case false:
					{
						FormatEx(sMessage, sizeof(sMessage), "%T", "RankPlayer", iClient, iClient, g_iDBRankPlayer[iClient], g_iDBCountPlayers, EXP(iClient), iKills, iDeaths, float(iKills) / float(iDeaths));
						LR_PrintToChat(iClient, "%s", sMessage);
					}
				}
			}
		}
	}

	return Plugin_Continue;
}

public Action ResetStatsFull(int iClient, int iArgs)
{
	ResetStats();
	return Plugin_Handled;
}

public Action CallMainMenu(int iClient, int iArgs)
{
	MainMenu(iClient);
	return Plugin_Handled;
}

void MainMenu(int iClient)
{
	char sBuffer[96], sBufferExp[32], sText[128];
	Menu hMenu = new Menu(MainMenuHandler);

	switch(IsClientVip(iClient))
	{
		case true:
		{
			FormatEx(sBuffer, sizeof(sBuffer), "%T", "MainMenu_VIP", iClient);
			FormatEx(sBufferExp, sizeof(sBufferExp), "%i", EXP(iClient));
		}

		case false:
		{
			FormatEx(sBuffer, sizeof(sBuffer), "%T", "MainMenu_Rank", iClient, g_sShowRank[RANK(iClient)]);
			switch(RANK(iClient))
			{
				case 0, 18: FormatEx(sBufferExp, sizeof(sBufferExp), "%i", EXP(iClient));
				default: FormatEx(sBufferExp, sizeof(sBufferExp), "%i / %i", EXP(iClient), g_iShowExp[RANK(iClient) + 1]);
			}
		}
	}

	switch(g_iTypeStatistics)
	{
		case 2: hMenu.SetTitle(PLUGIN_NAME ... " " ... PLUGIN_VERSION ... "\n \n%T\n ", "MainMenu_None", iClient, sBuffer, sBufferExp);
		default: hMenu.SetTitle(PLUGIN_NAME ... " " ... PLUGIN_VERSION ... "\n \n%T\n ", "MainMenu_Exp", iClient, sBuffer, sBufferExp, g_iDBRankPlayer[iClient], g_iDBCountPlayers);
	}

	switch(g_bInventory)
	{
		case true:
		{
			FormatEx(sText, sizeof(sText), "%T", "AllRanks", iClient); hMenu.AddItem("0", sText);
			FormatEx(sText, sizeof(sText), "%T\n ", "Capabilities", iClient); hMenu.AddItem("1", sText);
		}

		case false:
		{
			FormatEx(sText, sizeof(sText), "%T\n ", "AllRanks", iClient); hMenu.AddItem("0", sText);
		}
	}

	if(g_iTypeStatistics != 2)
	{
		FormatEx(sText, sizeof(sText), "%T", "TOP", iClient); hMenu.AddItem("2", sText);
		FormatEx(sText, sizeof(sText), "%T", "FullMyStats", iClient); hMenu.AddItem("3", sText);

		if(g_iTypeStatistics == 0)
		{
			int flags = GetUserFlagBits(iClient);
			if(flags & g_iAdminFlag || flags & ADMFLAG_ROOT)
			{
				FormatEx(sText, sizeof(sText), "%T", "MainAdminMenu", iClient); hMenu.AddItem("4", sText);
			}
		}
	}

	hMenu.ExitButton = true;
	hMenu.Display(iClient, MENU_TIME_FOREVER);
}

MenuLR(MainMenuHandler)
{	
	switch(mAction)
	{
		case MenuAction_End: delete hMenu;
		case MenuAction_Select:
		{
			char sInfo[2];
			hMenu.GetItem(iSlot, sInfo, sizeof(sInfo));

			switch(StringToInt(sInfo))
			{
				case 0: AllRankMenu(iClient);
				case 1: InventoryMenu(iClient);
				case 2: PrintTop(iClient, 0);
				case 3: FullMyStats(iClient);
				case 4: MainAdminMenu(iClient);
			}
		}
	}
}

void AllRankMenu(int iClient)
{
	char sText[192];
	Menu hMenu = new Menu(AllRankMenuHandler);
	hMenu.SetTitle(PLUGIN_NAME ... " | %T\n ", "AllRanks", iClient);

	for(int i = 1; i <= 18; i++)
	{
		if(i > 1)
		{
			FormatEx(sText, sizeof(sText), "[%i] %s", g_iShowExp[i], g_sShowRank[i]);
			hMenu.AddItem("", sText, ITEMDRAW_DISABLED);
		}
		else
		{
			FormatEx(sText, sizeof(sText), "%s", g_sShowRank[i]);
			hMenu.AddItem("", sText, ITEMDRAW_DISABLED);
		}
	}

	hMenu.ExitBackButton = true;
	hMenu.ExitButton = true;
	hMenu.Display(iClient, MENU_TIME_FOREVER);
}

MenuLR(AllRankMenuHandler)
{
	switch(mAction)
	{
		case MenuAction_End: delete hMenu;
		case MenuAction_Cancel: if(iSlot == MenuCancel_ExitBack) {MainMenu(iClient);}
	}
}

void PrintTop(int iClient, int iValue)
{
	if(g_bInitialized[iClient])
	{
		char sQuery[512];
		DataPack hDataPack = new DataPack();
		hDataPack.WriteCell(iClient);

		if(iValue > 0)
		{
			hDataPack.WriteCell(iValue - 1);
		}
		else
		{
			hDataPack.WriteCell(0);
			iValue = 1;
		}

		FormatEx(sQuery, sizeof(sQuery), g_sSQL_CallTOP, iValue - 1);
		g_hDatabase.Query(SQL_PrintTop, sQuery, hDataPack);
	}
}

public void SQL_PrintTop(Database db, DBResultSet dbRs, const char[] sError, any data)
{
	if(dbRs == null)
	{
		LogLR("SQL_PrintTop - error in retrieving data (%s)", sError);
		return;
	}

	DataPack hDataPack = view_as<DataPack>(data);
	hDataPack.Reset();
	int iClient = hDataPack.ReadCell();
	int iValue = hDataPack.ReadCell();
	delete hDataPack;

	if(g_bInitialized[iClient])
	{
		int i;
		char sName[64], sTemp[512], sTemp1[20], sBuffer[256];

		if(!dbRs.HasResults || dbRs.RowCount == 0)
		{
			PrintTop(iClient, g_iDBCountPlayers - 9);
			return;
		}

		Menu hMenu = CreateMenuEx(GetMenuStyleHandle(view_as<MenuStyle>(MenuStyle_Radio)), PrintTopMenuHandler);
		hMenu.SetTitle("");

		FormatEx(sTemp, sizeof(sTemp), "%T\n \n", "TOPCount", iClient, iValue + 1, iValue + 10, g_iDBCountPlayers);
		while(dbRs.HasResults && dbRs.FetchRow())
		{
			i++;
			dbRs.FetchString(0, sName, sizeof(sName));
			int iStats = dbRs.FetchInt(1);
			FormatEx(sBuffer, sizeof(sBuffer), "%d - [ %i ] - %s\n", i + iValue, iStats, sName);

			if(strlen(sTemp) + strlen(sBuffer) < 512)
			{
				Format(sTemp, sizeof(sTemp), "%s%s", sTemp, sBuffer);
				sBuffer = "\0";
			}
		}

		Format(sTemp, sizeof(sTemp), "%s\n ", sTemp);
		hMenu.AddItem(sTemp, sTemp);

		IntToString(iValue + i, sTemp, sizeof(sTemp));
		FormatEx(sTemp1, sizeof(sTemp1), "%T", "Next", iClient);
		if(i > 9)
		{
			hMenu.AddItem(sTemp, sTemp1);
		}

		IntToString(iValue - i, sTemp, sizeof(sTemp));
		FormatEx(sTemp1, sizeof(sTemp1), "%T", "Back", iClient);
		if(iValue + i - 1 > 9)
		{
			hMenu.AddItem(sTemp, sTemp1);
		}

		hMenu.ExitButton = true;
		hMenu.DisplayAt(iClient, iValue, MENU_TIME_FOREVER);
	}
}

MenuLR(PrintTopMenuHandler)
{
	switch(mAction)
	{
		case MenuAction_End: delete hMenu;
		case MenuAction_Cancel: if(iSlot == MenuCancel_Exit) {MainMenu(iClient);}
		case MenuAction_Select:
		{
			char sTemp[512];
			hMenu.GetItem(iSlot, sTemp, sizeof(sTemp));

			if(StringToInt(sTemp) >= 0)
			{
				PrintTop(iClient, StringToInt(sTemp) + 1);
			}
			else PrintTop(iClient, 0);
		}
	}
}

void InventoryMenu(int iClient)
{
	Menu hMenu = new Menu(MenuHandler_Category);
	hMenu.SetTitle(PLUGIN_NAME ... " | %T\n ", "Capabilities", iClient);
	hMenu.ExitBackButton = true;
	hMenu.ExitButton = true;

	for(int iRank = 0; iRank <= 18; iRank++)
	{
		Call_StartForward(g_hForward_OnMenuCreated);
		Call_PushCell(iClient);
		Call_PushCell(iRank);
		Call_PushCellRef(hMenu);
		Call_Finish();
	}

	if(hMenu.ItemCount == 0)
	{
		hMenu.AddItem("", "-----");
	}

	hMenu.Display(iClient, MENU_TIME_FOREVER);
}

MenuLR(MenuHandler_Category)
{
	switch(mAction)
	{
		case MenuAction_End: delete hMenu;
		case MenuAction_Cancel: if(iSlot == MenuCancel_ExitBack) {MainMenu(iClient);}
		case MenuAction_Select:
		{
			char sInfo[64];
			hMenu.GetItem(iSlot, sInfo, sizeof(sInfo));

			for(int iRank = 0; iRank <= 18; iRank++)
			{
				Call_StartForward(g_hForward_OnMenuItemSelected);
				Call_PushCell(iClient);
				Call_PushCell(iRank);
				Call_PushString(sInfo);
				Call_Finish();
			}
		}
	}

	return 0;
}

void FullMyStats(int iClient)
{
	int iKills, iDeaths, iHeadShots, iShoots, iHits;

	char sText[512];
	Menu hMenu = new Menu(FullStats_Callback);

	if(KILLS(iClient) == 0) iKills = 1;
	else iKills = KILLS(iClient);

	if(DEATHS(iClient) == 0) iDeaths = 1;
	else iDeaths = DEATHS(iClient);

	if(SHOOTS(iClient) == 0) iShoots = 1;
	else iShoots = SHOOTS(iClient);

	if(HITS(iClient) == 0) iHits = 1;
	else iHits = HITS(iClient);

	if(HEADSHOTS(iClient) == 0) iHeadShots = 1;
	else iHeadShots = HEADSHOTS(iClient);

	hMenu.SetTitle(PLUGIN_NAME ... " | %T\n ", "FullStats", iClient, KILLS(iClient), DEATHS(iClient), ASSISTS(iClient), HEADSHOTS(iClient), RoundToCeil((100.00 / float(iKills)) * float(iHeadShots)), float(iKills) / float(iDeaths), SHOOTS(iClient), HITS(iClient), RoundToCeil((100.00 / float(iShoots)) * float(iHits)));

	FormatEx(sText, sizeof(sText), "%T", "Back", iClient);
	hMenu.AddItem("", sText);

	hMenu.ExitButton = true;
	hMenu.Display(iClient, MENU_TIME_FOREVER);
}

MenuLR(FullStats_Callback)
{
	switch(mAction)
	{
		case MenuAction_End: delete hMenu;
		case MenuAction_Select: MainMenu(iClient);
	}
}

void MainAdminMenu(int iClient)
{
	char sText[192];
	Menu hMenu = new Menu(MainAdminMenu_Callback);
	hMenu.SetTitle(PLUGIN_NAME ... " | %T\n ", "MainAdminMenu", iClient);

	FormatEx(sText, sizeof(sText), "%T", "GiveTakeMenuExp", iClient);
	hMenu.AddItem("", sText);

	hMenu.ExitButton = true;
	hMenu.Display(iClient, MENU_TIME_FOREVER);
}

MenuLR(MainAdminMenu_Callback)
{
	switch(mAction)
	{
		case MenuAction_End: delete hMenu;
		case MenuAction_Cancel: if(iSlot == MenuCancel_Exit) {MainMenu(iClient);}
		case MenuAction_Select: GiveTakeValue(iClient);
	}
}

void GiveTakeValue(int iClient)
{
	char sID[16], sNickName[32];
	Menu hMenu = new Menu(ChangeExpPlayers_CallBack);
	hMenu.SetTitle(PLUGIN_NAME ... " | %T\n ", "GiveTakeMenuExp", iClient);

	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientConnected(i) && IsClientInGame(i) && g_bInitialized[i])
		{
			IntToString(GetClientUserId(i), sID, 16);
			sNickName[0] = '\0';
			GetClientName(i, sNickName, 32);
			hMenu.AddItem(sID, sNickName);
		}
	}
	
	hMenu.ExitBackButton = true;
	hMenu.Display(iClient, MENU_TIME_FOREVER);
}

MenuLR(ChangeExpPlayers_CallBack)
{	
	switch(mAction)
	{
		case MenuAction_End: delete hMenu;
		case MenuAction_Cancel: if(iSlot == MenuCancel_ExitBack) {MainAdminMenu(iClient);}
		case MenuAction_Select:
		{
			char sID[16];
			hMenu.GetItem(iSlot, sID, 16);

			int iRecipient = GetClientOfUserId(StringToInt(sID));
			if(g_bInitialized[iRecipient])
			{
				GiveTakeValueEND(iClient, sID);
			}
			else GiveTakeValue(iClient);
		}
	}
}

public void GiveTakeValueEND(int iClient, char[] sID) 
{
	Menu hMenu = new Menu(ChangeExpPlayersENDHandler);
	hMenu.SetTitle(PLUGIN_NAME ... " | %T\n ", "GiveTakeMenuExp", iClient);
	hMenu.AddItem(sID, "100");
	hMenu.AddItem(sID, "1000");
	hMenu.AddItem(sID, "10000");
	hMenu.AddItem(sID, "-10000");
	hMenu.AddItem(sID, "-1000");
	hMenu.AddItem(sID, "-100");
	hMenu.ExitBackButton = true;
	hMenu.ExitButton = true;
	hMenu.Display(iClient, MENU_TIME_FOREVER);
}

MenuLR(ChangeExpPlayersENDHandler)
{	
	switch(mAction)
	{
		case MenuAction_End: delete hMenu;
		case MenuAction_Cancel: if(iSlot == MenuCancel_ExitBack) {GiveTakeValue(iClient);}
		case MenuAction_Select:
		{
			char info[32], s_buffer[32], sMessage[PLATFORM_MAX_PATH];
			hMenu.GetItem(iSlot, info, sizeof(info), _, s_buffer, sizeof(s_buffer));
			int iRecipient = GetClientOfUserId(StringToInt(info));
			int iBuffer = StringToInt(s_buffer);

			if(IsClientInGame(iRecipient))
			{
				GiveTakeValueEND(iClient, info);
				SetExpEvent(iRecipient, iBuffer);

				if(iBuffer > 0)
				{
					FormatEx(sMessage, sizeof(sMessage), "%T", "AdminGive", iRecipient, EXP(iRecipient), iBuffer);
					LR_PrintToChat(iRecipient, "%s", sMessage);
					LR_PrintToChat(iClient, "%N - {GRAY}%i (+%i)", iRecipient, EXP(iRecipient), iBuffer);
				}
				else
				{
					FormatEx(sMessage, sizeof(sMessage), "%T", "AdminTake", iRecipient, EXP(iRecipient), iBuffer);
					LR_PrintToChat(iRecipient, "%s", sMessage);
					LR_PrintToChat(iClient, "%N - {GRAY}%i (%i)", iRecipient, EXP(iRecipient), iBuffer);
				}
			}
		}
	}
}