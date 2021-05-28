/**
 * Bot Mimic - Record your movments and have bots playing it back.
 * Admin menu integration and menu interface.
 * by Peace-Maker
 * visit http://wcfan.de
 * 
 * Changelog:
 * 1.0   - 22.07.2013: Released rewrite
 * 1.1   - 02.10.2014: Added sm_savebookmark and bookmark integration and pausing/resuming while recording.
 */

#pragma semicolon 1
#include <sourcemod>
#include <cstrike>
#include <botmimic>

#undef REQUIRE_PLUGIN
#include <adminmenu>

#define PLUGIN_VERSION "1.1"

// This player just stopped recording. Show him the details edit menu when the record was saved.
new bool:g_bPlayerRecordingFromMenu[MAXPLAYERS+1];
new bool:g_bPlayerStoppedRecording[MAXPLAYERS+1];

new String:g_sPlayerSelectedCategory[MAXPLAYERS+1][PLATFORM_MAX_PATH];
new String:g_sPlayerSelectedRecord[MAXPLAYERS+1][PLATFORM_MAX_PATH];
new String:g_sPlayerSelectedBookmark[MAXPLAYERS+1][MAX_BOOKMARK_NAME_LENGTH];
new String:g_sNextBotMimicsThis[PLATFORM_MAX_PATH];
new String:g_sSupposedToMimic[MAXPLAYERS+1][PLATFORM_MAX_PATH];
new bool:g_bRenameRecord[MAXPLAYERS+1];
new bool:g_bEnterCategoryName[MAXPLAYERS+1];

// Admin Menu
new Handle:g_hAdminMenu;

public Plugin:myinfo = 
{
	name = "Bot Mimic Menu",
	author = "Jannik \"Peace-Maker\" Hartung",
	description = "Handle records and record own movements",
	version = PLUGIN_VERSION,
	url = "http://www.wcfan.de/"
}

public OnPluginStart()
{
	RegAdminCmd("sm_mimic", Cmd_Record, ADMFLAG_CONFIG, "Opens the bot mimic menu", "botmimic");
	RegAdminCmd("sm_stoprecord", Cmd_StopRecord, ADMFLAG_CONFIG, "Stops your current record", "botmimic");
	RegAdminCmd("sm_savebookmark", Cmd_SaveBookmark, ADMFLAG_CONFIG, "Saves a bookmark with the given name in the record the target records. sm_savebookmark <name|steamid|#userid> <bookmark name>", "botmimic");
	
	AddCommandListener(CmdLstnr_Say, "say");
	AddCommandListener(CmdLstnr_Say, "say_team");
	
	LoadTranslations("common.phrases");
	
	if(LibraryExists("adminmenu"))
	{
		new Handle:hTopMenu = GetAdminTopMenu();
		if(hTopMenu != INVALID_HANDLE)
			OnAdminMenuReady(hTopMenu);
	}
}

public OnLibraryRemoved(const String:name[])
{
	if(StrEqual(name, "adminmenu"))
		g_hAdminMenu = INVALID_HANDLE;
}

/**
 * Public forwards
 */
public bool:OnClientConnect(client, String:rejectmsg[], maxlen)
{
	if(IsFakeClient(client) && g_sNextBotMimicsThis[0] != '\0')
	{
		strcopy(g_sSupposedToMimic[client], sizeof(g_sSupposedToMimic[]), g_sNextBotMimicsThis);
		g_sNextBotMimicsThis[0] = '\0';
	}
	
	return true;
}

public OnClientPutInServer(client)
{
	if(g_sSupposedToMimic[client][0] != '\0')
	{
		BotMimic_PlayRecordFromFile(client, g_sSupposedToMimic[client]);
	}
}

public OnClientDisconnect(client)
{
	g_sPlayerSelectedCategory[client][0] = '\0';
	g_sPlayerSelectedRecord[client][0] = '\0';
	g_sPlayerSelectedBookmark[client][0] = '\0';
	g_sSupposedToMimic[client][0] = '\0';
	g_bRenameRecord[client] = false;
	g_bEnterCategoryName[client] = false;
	g_bPlayerStoppedRecording[client] = false;
	g_bPlayerRecordingFromMenu[client] = false;
}

/**
 * Command callbacks
 */
public Action:Cmd_Record(client, args)
{
	if(!client)
		return Plugin_Handled;
	
	if(BotMimic_IsPlayerRecording(client))
	{
		PrintToChat(client, "[BotMimic] You're currently recording! Stop the current take first.");
		DisplayRecordInProgressMenu(client);
		return Plugin_Handled;
	}
	
	DisplayCategoryMenu(client);
	return Plugin_Handled;
}

public Action:Cmd_StopRecord(client, args)
{
	if(!client)
		return Plugin_Handled;
	
	if(!BotMimic_IsPlayerRecording(client))
	{
		PrintToChat(client, "[BotMimic] You aren't recording.");
		DisplayCategoryMenu(client);
		return Plugin_Handled;
	}
	
	BotMimic_StopRecording(client, true);
	
	return Plugin_Handled;
}

public Action:Cmd_SaveBookmark(client, args)
{
	if(args < 2)
	{
		ReplyToCommand(client, "[BotMimic] Saves a bookmark with the given name in the record the target records. sm_savebookmark <name|steamid|#userid> <bookmark name>");
		return Plugin_Handled;
	}
	
	decl String:sTarget[64];
	GetCmdArg(1, sTarget, sizeof(sTarget));
	new iTarget = FindTarget(client, sTarget, false, false);
	if(iTarget == -1)
		return Plugin_Handled;
	
	if(!BotMimic_IsPlayerRecording(iTarget))
	{
		ReplyToCommand(client, "[BotMimic] Target %N is not recording.", iTarget);
		return Plugin_Handled;
	}
	
	new String:sBookmarkName[MAX_BOOKMARK_NAME_LENGTH];
	GetCmdArg(2, sBookmarkName, sizeof(sBookmarkName));
	TrimString(sBookmarkName);
	StripQuotes(sBookmarkName);
	
	if(strlen(sBookmarkName) == 0)
	{
		ReplyToCommand(client, "[BotMimic] You have to give a name for the bookmark.");
		return Plugin_Handled;
	}
	
	BotMimic_SaveBookmark(iTarget, sBookmarkName);
	
	ReplyToCommand(client, "[BotMimic] Saved bookmark \"%s\" in %N's record.", sBookmarkName, iTarget);
	
	return Plugin_Handled;
}

public Action:CmdLstnr_Say(client, const String:command[], argc)
{
	decl String:sText[256];
	GetCmdArgString(sText, sizeof(sText));
	StripQuotes(sText);

	if(g_bRenameRecord[client])
	{
		g_bRenameRecord[client] = false;
		
		if(StrEqual(sText, "!stop", false))
		{
			PrintToChat(client, "[BotMimic] Renaming aborted.");
			DisplayRecordDetailMenu(client);
			return Plugin_Handled;
		}
		
		if(g_sPlayerSelectedRecord[client][0] == '\0')
		{
			if(g_sPlayerSelectedCategory[client][0] == '\0')
				DisplayCategoryMenu(client);
			else
				DisplayRecordMenu(client);
			PrintToChat(client, "[BotMimic] You didn't target a record to rename.");
			return Plugin_Handled;
		}
		
		new BMError:error= BotMimic_ChangeRecordName(g_sPlayerSelectedRecord[client], sText);
		if(error != BM_NoError)
		{
			decl String:sError[64];
			BotMimic_GetErrorString(error, sError, sizeof(sError));
			PrintToChat(client, "[BotMimic] There was an error changing the name: %s", sError);
			return Plugin_Handled;
		}
		
		DisplayRecordDetailMenu(client);
		
		PrintToChat(client, "[BotMimic] Record was renamed to \"%s\".", sText);
		return Plugin_Handled;
	}
	else if(g_bEnterCategoryName[client])
	{
		g_bEnterCategoryName[client] = false;
		
		if(StrEqual(sText, "!stop", false))
		{
			PrintToChat(client, "[BotMimic] Creation of category aborted.");
			DisplayCategoryMenu(client);
			return Plugin_Handled;
		}
		
		new Handle:hCategoryList = BotMimic_GetLoadedRecordCategoryList();
		PushArrayString(hCategoryList, sText);
		
		//TODO: SortRecordList();
		strcopy(g_sPlayerSelectedCategory[client], sizeof(g_sPlayerSelectedCategory[]), sText);
		DisplayRecordMenu(client);
		PrintToChat(client, "[BotMimic] A new category was created named \"%s\".", sText);
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

/**
 * Bot Mimic Callbacks
 */
public BotMimic_OnRecordSaved(client, String:name[], String:category[], String:subdir[], String:file[])
{
	if(g_bPlayerStoppedRecording[client])
	{
		g_bPlayerStoppedRecording[client] = false;
		strcopy(g_sPlayerSelectedRecord[client], PLATFORM_MAX_PATH, file);
		strcopy(g_sPlayerSelectedCategory[client], sizeof(g_sPlayerSelectedCategory[]), category);
		DisplayRecordDetailMenu(client);
	}
}

public BotMimic_OnRecordDeleted(String:name[], String:category[], String:path[])
{
	for(new i=1;i<=MaxClients;i++)
	{
		if(StrEqual(g_sPlayerSelectedRecord[i], path))
		{
			g_sPlayerSelectedRecord[i][0] = '\0';
			DisplayRecordMenu(i);
		}
	}
	
	if(StrEqual(g_sNextBotMimicsThis, path))
		g_sNextBotMimicsThis[0] = '\0';
}

public Action:BotMimic_OnStopRecording(client, String:name[], String:category[], String:subdir[], String:path[], &bool:save)
{
	// That's nothing we started.
	if(!g_bPlayerRecordingFromMenu[client])
		return Plugin_Continue;
	
	g_bPlayerRecordingFromMenu[client] = false;
	PrintHintText(client, "Stopped recording");
	return Plugin_Continue;
}

/**
 * Menu creation and handling
 */

DisplayCategoryMenu(client)
{
	g_bRenameRecord[client] = false;
	g_bEnterCategoryName[client] = false;
	g_sPlayerSelectedCategory[client][0] = '\0';
	g_sPlayerSelectedRecord[client][0] = '\0';
	
	new Handle:hMenu = CreateMenu(Menu_SelectCategory);
	SetMenuTitle(hMenu, "Manage Movement Recording Categories");
	if(g_hAdminMenu)
		SetMenuExitBackButton(hMenu, true);
	else
		SetMenuExitButton(hMenu, true);
	
	AddMenuItem(hMenu, "record", "Record new movement");
	AddMenuItem(hMenu, "createcategory", "Create new category");
	AddMenuItem(hMenu, "", "", ITEMDRAW_SPACER);
	
	new Handle:hCategoryList = BotMimic_GetLoadedRecordCategoryList();
	new iSize = GetArraySize(hCategoryList);
	decl String:sCategory[64];
	for(new i=0;i<iSize;i++)
	{
		GetArrayString(hCategoryList, i, sCategory, sizeof(sCategory));
		
		AddMenuItem(hMenu, sCategory, sCategory);
	}
	
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public Menu_SelectCategory(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		new String:info[PLATFORM_MAX_PATH];
		GetMenuItem(menu, param2, info, sizeof(info));
		
		// He want's to start a new record
		if(StrEqual(info, "record"))
		{
			if(BotMimic_IsPlayerRecording(param1))
			{
				PrintToChat(param1, "[BotMimic] You're currently recording! Stop the current take first.");
				DisplayRecordInProgressMenu(param1);
				return;
			}
			
			if(!IsPlayerAlive(param1) || GetClientTeam(param1) < CS_TEAM_T)
			{
				PrintToChat(param1, "[BotMimic] You have to be alive to record your movements.");
				DisplayCategoryMenu(param1);
				return;
			}
			
			if(BotMimic_IsPlayerMimicing(param1))
			{
				PrintToChat(param1, "[BotMimic] You're currently mimicing another record. Stop that first before recording.");
				RedisplayAdminMenu(g_hAdminMenu, param1);
				return;
			}
			
			decl String:sTempName[MAX_RECORD_NAME_LENGTH];
			Format(sTempName, sizeof(sTempName), "%d_%d", GetTime(), param1);
			g_bPlayerRecordingFromMenu[param1] = true;
			BotMimic_StartRecording(param1, sTempName, DEFAULT_CATEGORY);
			DisplayRecordInProgressMenu(param1);
		}
		else if(StrEqual(info, "createcategory"))
		{
			g_bEnterCategoryName[param1] = true;
			PrintToChat(param1, "[BotMimic] Type the name of the category in chat or \"!stop\" to abort. Remember that this is used as a folder name too!");
		}
		else
		{
			strcopy(g_sPlayerSelectedCategory[param1], sizeof(g_sPlayerSelectedCategory[]), info);
			DisplayRecordMenu(param1);
		}
	}
	else if (action == MenuAction_Cancel)
	{
		if(param2 == MenuCancel_ExitBack)
			RedisplayAdminMenu(g_hAdminMenu, param1);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

DisplayRecordMenu(client)
{
	g_sPlayerSelectedRecord[client][0] = '\0';
	
	// We don't have a category selected? Show the correct menu!
	// This is to go back to the correct menu when discarding a record in the progress menu.
	if(g_sPlayerSelectedCategory[client][0] == '\0')
	{
		DisplayCategoryMenu(client);
		return;
	}
	
	new Handle:hMenu = CreateMenu(Menu_SelectRecord);
	decl String:sTitle[64];
	Format(sTitle, sizeof(sTitle), "Manage Recordings in %s", g_sPlayerSelectedCategory[client]);
	SetMenuTitle(hMenu, sTitle);
	SetMenuExitBackButton(hMenu, true);
	
	AddMenuItem(hMenu, "record", "Record new movement");
	AddMenuItem(hMenu, "", "", ITEMDRAW_SPACER);
	
	new Handle:hRecordList = BotMimic_GetLoadedRecordList();
	
	new iSize = GetArraySize(hRecordList);
	decl String:sPath[PLATFORM_MAX_PATH], String:sBuffer[MAX_RECORD_NAME_LENGTH+24], String:sCategory[64];
	new iFileHeader[BMFileHeader], iPlaying;
	for(new i=0;i<iSize;i++)
	{
		GetArrayString(hRecordList, i, sPath, sizeof(sPath));
		
		// Only show records from the selected category
		BotMimic_GetFileCategory(sPath, sCategory, sizeof(sCategory));
		if(!StrEqual(g_sPlayerSelectedCategory[client], sCategory))
			continue;
		
		BotMimic_GetFileHeaders(sPath, iFileHeader);
		
		// How many bots are currently playing this record?
		iPlaying = 0;
		decl String:sPlayerPath[PLATFORM_MAX_PATH];
		for(new c=1;c<=MaxClients;c++)
		{
			if(IsClientInGame(c) && BotMimic_IsPlayerMimicing(c))
			{
				BotMimic_GetRecordPlayerMimics(c, sPlayerPath, sizeof(sPlayerPath));
				if(StrEqual(sPath, sPlayerPath))
					iPlaying++;
			}
		}
		
		if(iPlaying > 0)
			Format(sBuffer, sizeof(sBuffer), "%s (Playing %dx)", iFileHeader[BMFH_recordName], iPlaying);
		else
			Format(sBuffer, sizeof(sBuffer), "%s", iFileHeader[BMFH_recordName]);
		
		AddMenuItem(hMenu, sPath, sBuffer);
	}
	
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public Menu_SelectRecord(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		new String:info[PLATFORM_MAX_PATH];
		GetMenuItem(menu, param2, info, sizeof(info));
		
		// He want's to start a new record
		if(StrEqual(info, "record"))
		{
			if(BotMimic_IsPlayerRecording(param1))
			{
				PrintToChat(param1, "[BotMimic] You're currently recording! Stop the current take first.");
				DisplayRecordInProgressMenu(param1);
				return;
			}
			
			if(!IsPlayerAlive(param1) || GetClientTeam(param1) < CS_TEAM_T)
			{
				PrintToChat(param1, "[BotMimic] You have to be alive to record your movements.");
				DisplayRecordMenu(param1);
				return;
			}
			
			if(BotMimic_IsPlayerMimicing(param1))
			{
				PrintToChat(param1, "[BotMimic] You're currently mimicing another record. Stop that first before recording.");
				RedisplayAdminMenu(g_hAdminMenu, param1);
				return;
			}
			
			decl String:sTempName[MAX_RECORD_NAME_LENGTH];
			Format(sTempName, sizeof(sTempName), "%d_%d", GetTime(), param1);
			g_bPlayerRecordingFromMenu[param1] = true;
			BotMimic_StartRecording(param1, sTempName, g_sPlayerSelectedCategory[param1]);
			DisplayRecordInProgressMenu(param1);
		}
		else
		{
			strcopy(g_sPlayerSelectedRecord[param1], PLATFORM_MAX_PATH, info);
			DisplayRecordDetailMenu(param1);
		}
	}
	else if (action == MenuAction_Cancel)
	{
		g_sPlayerSelectedCategory[param1][0] = '\0';
		if(param2 == MenuCancel_ExitBack)
			DisplayCategoryMenu(param1);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

DisplayRecordDetailMenu(client)
{
	if(g_sPlayerSelectedRecord[client][0] == '\0' || !FileExists(g_sPlayerSelectedRecord[client]))
	{
		g_sPlayerSelectedRecord[client][0] = '\0';
		DisplayRecordMenu(client);
		return;
	}
	
	new iFileHeader[BMFileHeader];
	if(BotMimic_GetFileHeaders(g_sPlayerSelectedRecord[client], iFileHeader) != BM_NoError)
	{
		g_sPlayerSelectedRecord[client][0] = '\0';
		DisplayRecordMenu(client);
		return;
	}
	
	new Handle:hMenu = CreateMenu(Menu_HandleRecordDetails);
	SetMenuTitle(hMenu, "Record \"%s\": Details", iFileHeader[BMFH_recordName]);
	SetMenuExitBackButton(hMenu, true);
	
	AddMenuItem(hMenu, "playselect", "Select a bot to mimic");
	AddMenuItem(hMenu, "playadd", "Add a bot to mimic");
	AddMenuItem(hMenu, "stop", "Stop any bots mimicing this record");
	AddMenuItem(hMenu, "bookmarks", "Display bookmarks", iFileHeader[BMFH_bookmarkCount]>0?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
	AddMenuItem(hMenu, "rename", "Rename this record");
	AddMenuItem(hMenu, "delete", "Delete");
	
	decl String:sBuffer[64];
	Format(sBuffer, sizeof(sBuffer), "Length: %d ticks", iFileHeader[BMFH_tickCount]);
	AddMenuItem(hMenu, "", sBuffer, ITEMDRAW_DISABLED);
	FormatTime(sBuffer, sizeof(sBuffer), "Recorded: %c", iFileHeader[BMFH_recordEndTime]);
	AddMenuItem(hMenu, "", sBuffer, ITEMDRAW_DISABLED);
	
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public Menu_HandleRecordDetails(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		if(g_sPlayerSelectedRecord[param1][0] == '\0' || !FileExists(g_sPlayerSelectedRecord[param1]))
		{
			g_sPlayerSelectedRecord[param1][0] = '\0';
			DisplayRecordMenu(param1);
			return;
		}
		
		new iFileHeader[BMFileHeader];
		if(BotMimic_GetFileHeaders(g_sPlayerSelectedRecord[param1], iFileHeader) != BM_NoError)
		{
			g_sPlayerSelectedRecord[param1][0] = '\0';
			DisplayRecordMenu(param1);
			return;
		}
		
		new String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		
		// Select a present bot
		if(StrEqual(info, "playselect"))
		{
			// Build up a menu with bots
			new Handle:hMenu = CreateMenu(Menu_SelectBotToMimic);
			SetMenuTitle(hMenu, "Which bot should mimic this record?");
			SetMenuExitBackButton(hMenu, true);
			
			decl String:sUserId[6], String:sBuffer[MAX_NAME_LENGTH*2];
			decl String:sPath[PLATFORM_MAX_PATH];
			for(new i=1;i<=MaxClients;i++)
			{
				if(IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i) >= CS_TEAM_T && !IsClientSourceTV(i) && !IsClientReplay(i))
				{
					IntToString(GetClientUserId(i), sUserId, sizeof(sUserId));
					Format(sBuffer, sizeof(sBuffer), "%N", i);
					
					if(GetClientTeam(i) == CS_TEAM_T)
						Format(sBuffer, sizeof(sBuffer), "%s [T]", sBuffer);
					else
						Format(sBuffer, sizeof(sBuffer), "%s [CT]", sBuffer);
					
					if(BotMimic_IsPlayerMimicing(i))
					{
						BotMimic_GetRecordPlayerMimics(i, sPath, sizeof(sPath));
						BotMimic_GetFileHeaders(sPath, iFileHeader);
						Format(sBuffer, sizeof(sBuffer), "%s (Plays %s)", sBuffer, iFileHeader[BMFH_recordName]);
					}
					AddMenuItem(hMenu, sUserId, sBuffer);
				}
			}
			
			// Only show the player list, if there is a bot on the server
			if(GetMenuItemCount(hMenu) > 0)
				DisplayMenu(hMenu, param1, MENU_TIME_FOREVER);
			else
				DisplayRecordDetailMenu(param1);
		}
		// Add a new bot just for this purpose.
		else if(StrEqual(info, "playadd"))
		{
			new Handle:hMenu = CreateMenu(Menu_SelectBotTeam);
			SetMenuTitle(hMenu, "Select the team for the new bot");
			SetMenuExitBackButton(hMenu, true);
			
			AddMenuItem(hMenu, "t", "Terrorist");
			AddMenuItem(hMenu, "ct", "Counter-Terrorist");
			
			DisplayMenu(hMenu, param1, MENU_TIME_FOREVER);
		}
		// Stop all bots playing this record
		else if(StrEqual(info, "stop"))
		{
			new iCount, String:sPath[PLATFORM_MAX_PATH];
			for(new i=1;i<=MaxClients;i++)
			{
				if(IsClientInGame(i) && BotMimic_IsPlayerMimicing(i))
				{
					BotMimic_GetRecordPlayerMimics(i, sPath, sizeof(sPath));
					if(StrEqual(sPath, g_sPlayerSelectedRecord[param1]))
					{
						BotMimic_StopPlayerMimic(i);
						iCount++;
					}
				}
			}
			
			PrintToChat(param1, "[BotMimic] Stopped %d bots from mimicing record \"%s\".", iCount, iFileHeader[BMFH_recordName]);
			DisplayRecordDetailMenu(param1);
		}
		else if(StrEqual(info, "bookmarks"))
		{
			DisplayBookmarkListMenu(param1);
		}
		else if(StrEqual(info, "rename"))
		{
			g_bRenameRecord[param1] = true;
			PrintToChat(param1, "[BotMimic] Type the new name for record \"%s\" or type \"!stop\" to cancel.", iFileHeader[BMFH_recordName]);
		}
		else if(StrEqual(info, "delete"))
		{
			new iCount = BotMimic_DeleteRecord(g_sPlayerSelectedRecord[param1]);
			
			PrintToChat(param1, "[BotMimic] Stopped %d bots and deleted record \"%s\".", iCount, iFileHeader[BMFH_recordName]);
			
			g_sPlayerSelectedRecord[param1][0] = '\0';
			DisplayRecordMenu(param1);
		}
	}
	else if (action == MenuAction_Cancel)
	{
		g_sPlayerSelectedRecord[param1][0] = '\0';
		if(param2 == MenuCancel_ExitBack)
			DisplayRecordMenu(param1);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Menu_SelectBotToMimic(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		if(g_sPlayerSelectedRecord[param1][0] == '\0' || !FileExists(g_sPlayerSelectedRecord[param1]))
		{
			g_sPlayerSelectedRecord[param1][0] = '\0';
			DisplayRecordMenu(param1);
			return;
		}
		
		new iFileHeader[BMFileHeader];
		if(BotMimic_GetFileHeaders(g_sPlayerSelectedRecord[param1], iFileHeader) != BM_NoError)
		{
			g_sPlayerSelectedRecord[param1][0] = '\0';
			DisplayRecordMenu(param1);
			return;
		}
		
		new String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		
		new userid = StringToInt(info);
		new iBot = GetClientOfUserId(userid);
		
		if(!iBot || !IsClientInGame(iBot) || GetClientTeam(iBot) < CS_TEAM_T)
		{
			PrintToChat(param1, "[BotMimic] The bot you selected can't be found anymore.");
			DisplayRecordDetailMenu(param1);
			return;
		}
		
		decl String:sPath[PLATFORM_MAX_PATH];
		if(BotMimic_IsPlayerMimicing(iBot))
		{
			BotMimic_GetRecordPlayerMimics(iBot, sPath, sizeof(sPath));
			// That bot already plays this record. stop that.
			if(StrEqual(sPath, g_sPlayerSelectedRecord[param1]))
			{
				BotMimic_StopPlayerMimic(iBot);
				PrintToChat(param1, "[BotMimic] %N stopped mimicing record \"%s\".", iBot, iFileHeader[BMFH_recordName]);
			}
			// He's been playing a different record, switch to the selected.
			else
			{
				BotMimic_StopPlayerMimic(iBot);
				BotMimic_PlayRecordFromFile(iBot, g_sPlayerSelectedRecord[param1]);
				PrintToChat(param1, "[BotMimic] %N started mimicing record \"%s\".", iBot, iFileHeader[BMFH_recordName]);
			}
		}
		else
		{
			BotMimic_PlayRecordFromFile(iBot, g_sPlayerSelectedRecord[param1]);
			PrintToChat(param1, "[BotMimic] %N started mimicing record \"%s\".", iBot, iFileHeader[BMFH_recordName]);
		}
		
		DisplayRecordDetailMenu(param1);
	}
	else if (action == MenuAction_Cancel)
	{
		if(param2 == MenuCancel_ExitBack)
			DisplayRecordDetailMenu(param1);
		else
			g_sPlayerSelectedRecord[param1][0] = '\0';
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Menu_SelectBotTeam(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		if(g_sPlayerSelectedRecord[param1][0] == '\0' || !FileExists(g_sPlayerSelectedRecord[param1]))
		{
			g_sPlayerSelectedRecord[param1][0] = '\0';
			DisplayRecordMenu(param1);
			return;
		}
		
		new iFileHeader[BMFileHeader];
		if(BotMimic_GetFileHeaders(g_sPlayerSelectedRecord[param1], iFileHeader) != BM_NoError)
		{
			g_sPlayerSelectedRecord[param1][0] = '\0';
			DisplayRecordMenu(param1);
			return;
		}
		
		new String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		
		strcopy(g_sNextBotMimicsThis, sizeof(g_sNextBotMimicsThis), g_sPlayerSelectedRecord[param1]);
		
		if(StrEqual(info, "t"))
		{
			ServerCommand("bot_add_t");
		}
		else
		{
			ServerCommand("bot_add_ct");
		}
		
		PrintToChat(param1, "[BotMimic] Added new bot who mimics record \"%s\".", iFileHeader[BMFH_recordName]);
		
		DisplayRecordDetailMenu(param1);
	}
	else if (action == MenuAction_Cancel)
	{
		if(param2 == MenuCancel_ExitBack)
			DisplayRecordDetailMenu(param1);
		else
			g_sPlayerSelectedRecord[param1][0] = '\0';
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

DisplayBookmarkListMenu(client)
{
	g_sPlayerSelectedBookmark[client][0]= '\0';
	
	new iFileHeader[BMFileHeader];
	if(BotMimic_GetFileHeaders(g_sPlayerSelectedRecord[client], iFileHeader) != BM_NoError)
	{
		g_sPlayerSelectedRecord[client][0] = '\0';
		DisplayRecordMenu(client);
		return;
	}
	
	new Handle:hMenu = CreateMenu(Menu_HandleBookmarkList);
	SetMenuTitle(hMenu, "Bookmarks for record \"%s\"", iFileHeader[BMFH_recordName]);
	SetMenuExitBackButton(hMenu, true);
	
	new Handle:hBookmarks;
	if(BotMimic_GetRecordBookmarks(g_sPlayerSelectedRecord[client], hBookmarks) != BM_NoError)
	{
		g_sPlayerSelectedRecord[client][0] = '\0';
		DisplayRecordMenu(client);
		return;
	}
	
	new iSize = GetArraySize(hBookmarks);
	decl String:sBuffer[MAX_BOOKMARK_NAME_LENGTH];
	for(new i=0;i<iSize;i++)
	{
		GetArrayString(hBookmarks, i, sBuffer, sizeof(sBuffer));
		AddMenuItem(hMenu, sBuffer, sBuffer);
	}
	CloseHandle(hBookmarks);
	
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public Menu_HandleBookmarkList(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		if(g_sPlayerSelectedRecord[param1][0] == '\0' || !FileExists(g_sPlayerSelectedRecord[param1]))
		{
			g_sPlayerSelectedRecord[param1][0] = '\0';
			DisplayRecordMenu(param1);
			return;
		}
		
		new iFileHeader[BMFileHeader];
		if(BotMimic_GetFileHeaders(g_sPlayerSelectedRecord[param1], iFileHeader) != BM_NoError)
		{
			g_sPlayerSelectedRecord[param1][0] = '\0';
			DisplayRecordMenu(param1);
			return;
		}
		
		new String:info[MAX_BOOKMARK_NAME_LENGTH];
		GetMenuItem(menu, param2, info, sizeof(info));
		strcopy(g_sPlayerSelectedBookmark[param1], MAX_BOOKMARK_NAME_LENGTH, info);
		
		DisplayBookmarkMimicingPlayers(param1);
	}
	else if (action == MenuAction_Cancel)
	{
		if(param2 == MenuCancel_ExitBack)
			DisplayRecordDetailMenu(param1);
		else
			g_sPlayerSelectedRecord[param1][0] = '\0';
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

DisplayBookmarkMimicingPlayers(client)
{
	new Handle:hMenu = CreateMenu(Menu_HandleBookmarkMimicingPlayer);
	SetMenuTitle(hMenu, "Select which player who currently plays the record should jump to bookmark \"%s\":", g_sPlayerSelectedBookmark[client]);
	SetMenuExitBackButton(hMenu, true);
	
	new String:sBuffer[PLATFORM_MAX_PATH], String:sUserId[16];
	for(new i=1;i<=MaxClients;i++)
	{
		if(!IsClientInGame(i) || !BotMimic_IsPlayerMimicing(i))
			continue;
		
		BotMimic_GetRecordPlayerMimics(i, sBuffer, sizeof(sBuffer));
		if(!StrEqual(sBuffer, g_sPlayerSelectedRecord[client], false))
			continue;
		
		Format(sBuffer, sizeof(sBuffer), "%N (#%d)", i, GetClientUserId(i));
		IntToString(GetClientUserId(i), sUserId, sizeof(sUserId));
		AddMenuItem(hMenu, sUserId, sBuffer);
	}
	
	if(GetMenuItemCount(hMenu) == 0)
		AddMenuItem(hMenu, "", "No players currently mimicing this record.", ITEMDRAW_DISABLED);
	
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public Menu_HandleBookmarkMimicingPlayer(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		if(g_sPlayerSelectedRecord[param1][0] == '\0' || !FileExists(g_sPlayerSelectedRecord[param1]))
		{
			g_sPlayerSelectedRecord[param1][0] = '\0';
			g_sPlayerSelectedBookmark[param1][0] = '\0';
			DisplayRecordMenu(param1);
			return;
		}
		
		if(g_sPlayerSelectedBookmark[param1][0] == '\0')
		{
			DisplayBookmarkListMenu(param1);
			return;
		}
		
		new iFileHeader[BMFileHeader];
		if(BotMimic_GetFileHeaders(g_sPlayerSelectedRecord[param1], iFileHeader) != BM_NoError)
		{
			g_sPlayerSelectedRecord[param1][0] = '\0';
			g_sPlayerSelectedBookmark[param1][0] = '\0';
			DisplayRecordMenu(param1);
			return;
		}
		
		new String:info[MAX_BOOKMARK_NAME_LENGTH];
		GetMenuItem(menu, param2, info, sizeof(info));
		
		new userid = StringToInt(info);
		new iTarget = GetClientOfUserId(userid);
		
		if(!iTarget || !IsClientInGame(iTarget) || GetClientTeam(iTarget) < CS_TEAM_T)
		{
			PrintToChat(param1, "[BotMimic] The bot you selected can't be found anymore.");
			DisplayBookmarkMimicingPlayers(param1);
			return;
		}
		
		if(!BotMimic_IsPlayerMimicing(iTarget))
		{
			PrintToChat(param1, "[BotMimic] %N isn't mimicing anything anymore.", iTarget);
			DisplayBookmarkMimicingPlayers(param1);
			return;
		}
		else
		{
			decl String:sRecordPath[PLATFORM_MAX_PATH];
			BotMimic_GetRecordPlayerMimics(iTarget, sRecordPath, sizeof(sRecordPath));
			if(!StrEqual(sRecordPath, g_sPlayerSelectedRecord[param1], false))
			{
				PrintToChat(param1, "[BotMimic] %N isn't mimicing the selected record anymore.", iTarget);
				DisplayBookmarkMimicingPlayers(param1);
				return;
			}
		}
		
		BotMimic_GoToBookmark(iTarget, g_sPlayerSelectedBookmark[param1]);
		DisplayBookmarkMimicingPlayers(param1);
	}
	else if (action == MenuAction_Cancel)
	{
		if(param2 == MenuCancel_ExitBack)
			DisplayBookmarkListMenu(param1);
		else
		{
			g_sPlayerSelectedRecord[param1][0] = '\0';
			g_sPlayerSelectedBookmark[param1][0] = '\0';
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

DisplayRecordInProgressMenu(client)
{
	if(!BotMimic_IsPlayerRecording(client))
	{
		DisplayRecordMenu(client);
		return;
	}
	
	new Handle:hMenu = CreateMenu(Menu_HandleRecordProgress);
	SetMenuTitle(hMenu, "Recording...");
	SetMenuExitButton(hMenu, false);
	
	if(BotMimic_IsRecordingPaused(client))
		AddMenuItem(hMenu, "resume", "Resume recording");
	else
		AddMenuItem(hMenu, "pause", "Pause recording");
	AddMenuItem(hMenu, "save", "Save recording");
	AddMenuItem(hMenu, "discard", "Discard recording");
	
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public Menu_HandleRecordProgress(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		// He isn't recording anymore
		if(!BotMimic_IsPlayerRecording(param1))
		{
			DisplayRecordMenu(param1);
			return;
		}
		
		new String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		
		g_bPlayerRecordingFromMenu[param1] = false;
		if(StrEqual(info, "pause"))
		{
			if(!BotMimic_IsRecordingPaused(param1))
			{
				BotMimic_PauseRecording(param1);
				PrintToChat(param1, "[BotMimic] Paused recording.");
			}
			
			DisplayRecordInProgressMenu(param1);
		}
		else if(StrEqual(info, "resume"))
		{
			if(BotMimic_IsRecordingPaused(param1))
			{
				BotMimic_ResumeRecording(param1);
				PrintToChat(param1, "[BotMimic] Resumed recording.");
			}
			
			DisplayRecordInProgressMenu(param1);
		}
		else if(StrEqual(info, "save"))
		{
			g_bPlayerStoppedRecording[param1] = true;
			BotMimic_StopRecording(param1, true);
		}
		else if(StrEqual(info, "discard"))
		{
			BotMimic_StopRecording(param1, false);
			DisplayRecordMenu(param1);
		}
	}
	else if (action == MenuAction_Cancel)
	{
		PrintHintText(param1, "Recording...");
		PrintToChat(param1, "[BotMimic] Type !stoprecord to stop recording.");
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

/**
 * Admin Menu Integration
 */
public OnAdminMenuReady(Handle:topmenu)
{
	// Don't add the category twice!
	if(g_hAdminMenu == topmenu)
		return;
	
	g_hAdminMenu = topmenu;
	
	new TopMenuObject:iBotMimicCategory;
	if((iBotMimicCategory = FindTopMenuCategory(topmenu, "Bot Mimic")) == INVALID_TOPMENUOBJECT)
		iBotMimicCategory = AddToTopMenu(topmenu, "Bot Mimic", TopMenuObject_Category, TopMenu_SelectCategory, INVALID_TOPMENUOBJECT, "sm_mimic", ADMFLAG_CONFIG);
	
	if(iBotMimicCategory == INVALID_TOPMENUOBJECT)
		return;
	
	AddToTopMenu(topmenu, "Record new movement", TopMenuObject_Item, TopMenu_NewRecord, iBotMimicCategory, "sm_mimic", ADMFLAG_CONFIG);
	AddToTopMenu(topmenu, "List categories", TopMenuObject_Item, TopMenu_ListCategories, iBotMimicCategory, "sm_mimic", ADMFLAG_CONFIG);
}

public TopMenu_SelectCategory(Handle:topmenu, TopMenuAction:action, TopMenuObject:object_id, param, String:buffer[], maxlength)
{
	if(action == TopMenuAction_DisplayTitle)
	{
		Format(buffer, maxlength, "Bot Mimic");
	}
	else if(action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Bot Mimic");
	}
}

public TopMenu_NewRecord(Handle:topmenu, TopMenuAction:action, TopMenuObject:object_id, param, String:buffer[], maxlength)
{
	if(action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Record new movement");
	}
	else if(action == TopMenuAction_SelectOption)
	{
		if(!IsPlayerAlive(param) || GetClientTeam(param) < CS_TEAM_T)
		{
			PrintToChat(param, "[BotMimic] You have to be alive to record your movements.");
			RedisplayAdminMenu(topmenu, param);
			return;
		}
		
		if(BotMimic_IsPlayerRecording(param))
		{
			PrintToChat(param, "[BotMimic] You're already recording!");
			RedisplayAdminMenu(topmenu, param);
			return;
		}
		
		if(BotMimic_IsPlayerMimicing(param))
		{
			PrintToChat(param, "[BotMimic] You're currently mimicing another record. Stop that first before recording.");
			RedisplayAdminMenu(topmenu, param);
			return;
		}
		
		decl String:sTempName[MAX_RECORD_NAME_LENGTH];
		Format(sTempName, sizeof(sTempName), "%d_%d", GetTime(), param);
		g_bPlayerRecordingFromMenu[param] = true;
		BotMimic_StartRecording(param, sTempName, DEFAULT_CATEGORY);
		DisplayRecordInProgressMenu(param);
	}
}

public TopMenu_ListCategories(Handle:topmenu, TopMenuAction:action, TopMenuObject:object_id, param, String:buffer[], maxlength)
{
	if(action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "List categories");
	}
	else if(action == TopMenuAction_SelectOption)
	{
		DisplayCategoryMenu(param);
	}
}