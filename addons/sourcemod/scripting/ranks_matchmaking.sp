#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#include <clientprefs>
#include <overlays>

#undef REQUIRE_PLUGIN
#include <kento_rankme/rankme>
#include <gameme>
#include <zr_rank>
#include <hlstatsx_api>
#define REQUIRE_PLUGIN

#pragma newdecls required
#pragma semicolon 1

int rank[MAXPLAYERS+1] = {0, ...};
int oldrank[MAXPLAYERS+1] = {0, ...};

// ConVar Variables
ConVar g_CVAR_RanksPoints[18];
ConVar g_CVAR_RankPoints_Type;
ConVar g_CVAR_RankPoints_Flag;
ConVar g_CVAR_RankPoints_Prefix;
ConVar g_CVAR_RankPoints_HudOverlay;
ConVar g_CVAR_RankPoints_OverlayTime;
ConVar g_CVAR_RankPoints_SoundEnable;
ConVar g_CVAR_RankPoints_SoundRankUp;
ConVar g_CVAR_RankPoints_SoundRankDown;

// Variables to store ConVar values;
int g_RankPoints_Type;
int g_RankPoints_Flag;
int g_RankPoints_HudOverlay;
int g_RankPoints_SoundEnable;
float g_RankPoints_OverlayTime;
char g_RankPoints_SoundRankUp[PLATFORM_MAX_PATH];
char g_RankPoints_SoundRankDown[PLATFORM_MAX_PATH];
char g_RankPoints_Prefix[40];
int RankPoints[18];

bool g_zrank;
bool g_kentorankme;
bool g_gameme;
bool g_hlstatsx;

char RankStrings[19][256];
char RankOverlays[18][PLATFORM_MAX_PATH];

public Plugin myinfo = 
{
	name = "[CS:GO] Matchmaking Ranks by Points",
	author = "Hallucinogenic Troll",
	description = "Prints the Matchmaking Ranks on scoreboard, based on points stats by a certain rank.",
	version = "1.6",
	url = "https://PTFun.net/"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_mm", Menu_Points);
	HookEvent("announce_phase_end", Event_AnnouncePhaseEnd);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("player_disconnect", Event_Disconnect, EventHookMode_Pre);
	
	// ConVar to check which rank you want
	g_CVAR_RankPoints_Type = CreateConVar("ranks_matchmaking_typeofrank", "0", "Type of Rank that you want to use for this plugin (0 for Kento Rankme, 1 for GameMe, 2 for ZR Rank, 3 for HLStatsX)", _, true, 0.0, true, 3.0);
	g_CVAR_RankPoints_Prefix = CreateConVar("ranks_matchmaking_prefix", "[{purple}Fake Ranks{default}]", "Chat Prefix");
	g_CVAR_RankPoints_Flag = CreateConVar("ranks_matchmaking_flag", "", "Flag to restrict the ranks to certain players (leave it empty to enable for everyone)");
	g_CVAR_RankPoints_HudOverlay = CreateConVar("ranks_matchmaking_hudoverlay" , "1", "Chooses between a HUD Text Message (0) or an Overlay (1)", _, true, 0.0, true, 1.0);
	g_CVAR_RankPoints_OverlayTime = CreateConVar("ranks_matchmaking_overlaytime", "5.0", "Time between showing and deleting the overlay (need \"ranks_matchmaking_hudoverlay\" set to 1). 0.0 means forever", _, true, 0.0, false);
	g_CVAR_RankPoints_SoundEnable = CreateConVar("ranks_matchmaking_soundenable", "1", "Enable sounds when a player ranks up or deranks", _, true, 0.0, true, 1.0);
	g_CVAR_RankPoints_SoundRankUp = CreateConVar("ranks_matchmaking_soundrankup", "levels_ranks/levelup.mp3", "Path to the sound which will play on Rank Up (needs \"ranks_matchmaking_soundenable\" set to 1)");
	g_CVAR_RankPoints_SoundRankDown = CreateConVar("ranks_matchmaking_soundrankdown", "levels_ranks/leveldown.mp3", "Path to the sound which will play on Derank (needs \"ranks_matchmaking_soundenable\" set to 1)");
	
	// Rank Points ConVars;
	g_CVAR_RanksPoints[0] = CreateConVar("ranks_matchmaking_point_s1", "100", "Number of Points to reach Silver I", _, true, 0.0, false);
	g_CVAR_RanksPoints[1] = CreateConVar("ranks_matchmaking_point_s2", "150", "Number of Points to reach Silver II", _, true, 0.0, false);
	g_CVAR_RanksPoints[2] = CreateConVar("ranks_matchmaking_point_s3", "200", "Number of Points to reach Silver III", _, true, 0.0, false);
	g_CVAR_RanksPoints[3] = CreateConVar("ranks_matchmaking_point_s4", "300", "Number of Points to reach Silver IV", _, true, 0.0, false);
	g_CVAR_RanksPoints[4] = CreateConVar("ranks_matchmaking_point_se", "400", "Number of Points to reach Silver Elite", _, true, 0.0, false);
	g_CVAR_RanksPoints[5] = CreateConVar("ranks_matchmaking_point_sem", "500", "Number of Points to reach Silver Elite Master", _, true, 0.0, false);
	g_CVAR_RanksPoints[6] = CreateConVar("ranks_matchmaking_point_g1", "600", "Number of Points to reach Gold Nova I", _, true, 0.0, false);
	g_CVAR_RanksPoints[7] = CreateConVar("ranks_matchmaking_point_g2", "750", "Number of Points to reach Gold Nova II", _, true, 0.0, false);
	g_CVAR_RanksPoints[8] = CreateConVar("ranks_matchmaking_point_g3", "900", "Number of Points to reach Gold Nova III", _, true, 0.0, false);
	g_CVAR_RanksPoints[9] = CreateConVar("ranks_matchmaking_point_g4", "1050", "Number of Points to reach Gold Nova IV", _, true, 0.0, false);
	g_CVAR_RanksPoints[10] = CreateConVar("ranks_matchmaking_point_mg1", "1200", "Number of Points to reach Master Guardian I", _, true, 0.0, false);
	g_CVAR_RanksPoints[11] = CreateConVar("ranks_matchmaking_point_mg2", "1400", "Number of Points to reach Master Guardian II", _, true, 0.0, false);
	g_CVAR_RanksPoints[12] = CreateConVar("ranks_matchmaking_point_mge", "1600", "Number of Points to reach Master Guardian Elite", _, true, 0.0, false);
	g_CVAR_RanksPoints[13] = CreateConVar("ranks_matchmaking_point_dmg", "1800", "Number of Points to reach Distinguished Master Guardian", _, true, 0.0, false);
	g_CVAR_RanksPoints[14] = CreateConVar("ranks_matchmaking_point_le", "2000", "Number of Points to reach Legendary Eagle", _, true, 0.0, false);
	g_CVAR_RanksPoints[15] = CreateConVar("ranks_matchmaking_point_lem", "2200", "Number of Points to reach Legendary Eagle Master", _, true, 0.0, false);
	g_CVAR_RanksPoints[16] = CreateConVar("ranks_matchmaking_point_smfc", "2400", "Number of Points to reach Supreme Master First Class", _, true, 0.0, false);
	g_CVAR_RanksPoints[17] = CreateConVar("ranks_matchmaking_point_ge", "2700", "Number of Points to reach Global Elite", _, true, 0.0, false);
	
	LoadTranslations("ranks_matchmaking.phrases");
	AutoExecConfig(true, "ranks_matchmaking");
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	MarkNativeAsOptional("ZR_Rank_GetPoints");
	MarkNativeAsOptional("RankMe_OnPlayerLoaded");
	MarkNativeAsOptional("RankMe_GetPoints");
	MarkNativeAsOptional("QueryGameMEStats");
	return APLRes_Success;
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "zr_rank")) {
		g_zrank = true;
	} else if (StrEqual(name, "rankme")) {
		g_kentorankme = true;
	} else if(StrEqual(name, "gameme")) {
		g_gameme = true;
	} else if (StrEqual(name, "hlstatsx_api")) {
		g_hlstatsx = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "zr_rank")) {
		g_zrank = false;
	} else if(StrEqual(name, "rankme")) {
		g_kentorankme = false;
	} else if(StrEqual(name, "gameme")) {
		g_gameme = false;
	} else if (StrEqual(name, "hlstatsx_api")) {
		g_hlstatsx = false;
	}		
}

public void OnMapStart()
{
	for (int i = 0; i < 18; i++)
		RankPoints[i] = g_CVAR_RanksPoints[i].IntValue;
		
	g_RankPoints_HudOverlay = g_CVAR_RankPoints_HudOverlay.IntValue;
	g_RankPoints_OverlayTime = g_CVAR_RankPoints_OverlayTime.FloatValue;
	
	g_CVAR_RankPoints_Prefix.GetString(g_RankPoints_Prefix, sizeof(g_RankPoints_Prefix));
	
	g_RankPoints_SoundEnable = g_CVAR_RankPoints_SoundEnable.IntValue;
	
	g_CVAR_RankPoints_SoundRankUp.GetString(g_RankPoints_SoundRankUp, sizeof(g_RankPoints_SoundRankUp));
	g_CVAR_RankPoints_SoundRankDown.GetString(g_RankPoints_SoundRankDown, sizeof(g_RankPoints_SoundRankDown));
	
	char buffer[10];
	g_CVAR_RankPoints_Flag.GetString(buffer, sizeof(buffer));
	
	if(StrEqual(buffer, "0") || strlen(buffer) < 1)
		g_RankPoints_Flag = -1;
	else
		g_RankPoints_Flag = ReadFlagString(buffer);
	
	g_RankPoints_Type = g_CVAR_RankPoints_Type.IntValue;
	
	
	int iIndex = FindEntityByClassname(MaxClients+1, "cs_player_manager");
	if (iIndex == -1)
		SetFailState("Unable to find cs_player_manager entity");
	
	SDKHook(iIndex, SDKHook_ThinkPost, Hook_OnThinkPost);
	
	GetRanksNames();
	
	if(g_RankPoints_HudOverlay)
		GetRanksOverlays();
	
	if(g_RankPoints_SoundEnable)
		GetRanksGradesSounds();
}

public void GetRanksGradesSounds()
{
	char buffer[PLATFORM_MAX_PATH];
	Format(buffer, sizeof(buffer), "sound/%s", g_RankPoints_SoundRankUp);
	AddFileToDownloadsTable(buffer);
	Format(buffer, sizeof(buffer), "*/%s", g_RankPoints_SoundRankUp);
	FakePrecacheSound(buffer);
	Format(buffer, sizeof(buffer), "sound/%s", g_RankPoints_SoundRankDown);
	AddFileToDownloadsTable(buffer);
	Format(buffer, sizeof(buffer), "*/%s", g_RankPoints_SoundRankDown);
	FakePrecacheSound(buffer);
}

public void GetRanksOverlays()
{
	for(int i = 0; i < 18; i++)
	{
		Format(RankOverlays[i], sizeof(RankOverlays[]), "lvl_overlays/overlay_hd_%d", (i+1));
		PrecacheDecalAnyDownload(RankOverlays[i]);
	}
}

public void GetRanksNames()
{
	FormatEx(RankStrings[0], sizeof(RankStrings[]), "%t", "Unranked");
	FormatEx(RankStrings[1], sizeof(RankStrings[]), "%t", "Silver I");
	FormatEx(RankStrings[2], sizeof(RankStrings[]), "%t", "Silver II");
	FormatEx(RankStrings[3], sizeof(RankStrings[]), "%t", "Silver III");
	FormatEx(RankStrings[4], sizeof(RankStrings[]), "%t", "Silver IV");
	FormatEx(RankStrings[5], sizeof(RankStrings[]), "%t", "Silver Elite");
	FormatEx(RankStrings[6], sizeof(RankStrings[]), "%t", "Silver Elite Master");
	FormatEx(RankStrings[7], sizeof(RankStrings[]), "%t", "Gold Nova I");
	FormatEx(RankStrings[8], sizeof(RankStrings[]), "%t", "Gold Nova II");
	FormatEx(RankStrings[9], sizeof(RankStrings[]), "%t", "Gold Nova III");
	FormatEx(RankStrings[10], sizeof(RankStrings[]), "%t", "Gold Nova Master");
	FormatEx(RankStrings[11], sizeof(RankStrings[]), "%t", "Master Guardian I");
	FormatEx(RankStrings[12], sizeof(RankStrings[]), "%t", "Master Guardian II");
	FormatEx(RankStrings[13], sizeof(RankStrings[]), "%t", "Master Guardian Elite");
	FormatEx(RankStrings[14], sizeof(RankStrings[]), "%t", "Distinguished Master Guardian");
	FormatEx(RankStrings[15], sizeof(RankStrings[]), "%t", "Legendary Eagle");
	FormatEx(RankStrings[16], sizeof(RankStrings[]), "%t", "Legendary Eagle Master");
	FormatEx(RankStrings[17], sizeof(RankStrings[]), "%t", "Supreme First Master Class");
	FormatEx(RankStrings[18], sizeof(RankStrings[]), "%t", "Global Elite");
}

public Action RankMe_OnPlayerLoaded(int client)
{
	if(g_kentorankme && g_RankPoints_Type == 0)
	{
		int points = RankMe_GetPoints(client);
		CheckRanks(client, points);
	}
}

public void OnClientPostAdminCheck(int client)
{
	if (IsValidClient(client)) {

		if (g_gameme && g_RankPoints_Type == 1) {

			QueryGameMEStats("playerinfo", client, QuerygameMEStatsCallback, 0);

		} else if (g_zrank && g_RankPoints_Type == 2) {

			int points = ZR_Rank_GetPoints(client);
			CheckRanks(client, points);

		} else if (g_hlstatsx && g_RankPoints_Type == 3) {

			HLStatsX_Api_GetStats("playerinfo", client, _HLStatsX_API_Response, 0);
		}
	}
}

public int QuerygameMEStatsCallback(int command, int payload, int client, Handle &datapack)
{
	if ((client > 0) && (command == RAW_MESSAGE_CALLBACK_PLAYER))
	{
		Handle data2 = CloneHandle(datapack);
		ResetPack(data2);		
		int points;
		
		points = ReadPackCell(data2);
		points = ReadPackCell(data2);
		points = ReadPackCell(data2);

		CloseHandle(data2);
		
		CheckRanks(client, points);	
	}
}

public void _HLStatsX_API_Response(int command, int payload, int client, DataPack &datapack)
{
	if (!IsValidClient(client) || command != HLX_CALLBACK_TYPE_PLAYER_INFO) {
		return;
	}

	DataPack pack = view_as<DataPack>(CloneHandle(datapack));
	int points;
	
	points = pack.ReadCell();
	points = pack.ReadCell();

	delete datapack;
	delete pack;

	CheckRanks(client, points);
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int victim = GetClientOfUserId(event.GetInt("userid"));
	
	if(IsValidClient(victim))
		CheckPoints(victim);
	
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	
	if(IsValidClient(attacker))
		CheckPoints(attacker);
	
	int assister = GetClientOfUserId(event.GetInt("assister"));
	
	if(IsValidClient(assister))
		CheckPoints(assister);
}

public Action Event_Disconnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(client)
		rank[client] = 0;
}

public void CheckPoints(int client)
{
	if (g_kentorankme && g_RankPoints_Type == 0) {

		int points = RankMe_GetPoints(client);
		CheckRanks(client, points);

	} else if (g_gameme && g_RankPoints_Type == 1) {
		
		QueryGameMEStats("playerinfo", client, QuerygameMEStatsCallback, 0);

	} else if (g_zrank && g_RankPoints_Type == 2) {

		int points = ZR_Rank_GetPoints(client);
		CheckRanks(client, points);

	} else if (g_hlstatsx && g_RankPoints_Type == 3) {

		HLStatsX_Api_GetStats("playerinfo", client, _HLStatsX_API_Response, 0);
	}
}

public void CheckRanks(int client, int points)
{	
	if(g_RankPoints_Flag != -1)
	{
		if(!CheckCommandAccess(client, "", g_RankPoints_Flag, true))
		{
			rank[client] = 0;
			return;
		}		
	}
	
	// Unranked
	if(points < RankPoints[0])
		rank[client] = 0;
	else if(points >= RankPoints[0] && points < RankPoints[1]) // Silver I
		rank[client] = 1;
	else if(points >= RankPoints[1] && points < RankPoints[2]) // Silver II
		rank[client] = 2;
	else if(points >= RankPoints[2] && points < RankPoints[3]) // Silver III
		rank[client] = 3;
	else if(points >= RankPoints[3] && points < RankPoints[4]) // Silver IV
		rank[client] = 4;
	else if(points >= RankPoints[4] && points < RankPoints[5]) // Silver Elite
		rank[client] = 5;
	else if(points >= RankPoints[5] && points < RankPoints[6]) // Silver Elite Master
		rank[client] = 6;
	else if(points >= RankPoints[6] && points < RankPoints[7]) // Gold Nova I
		rank[client] = 7;
	else if(points >= RankPoints[7] && points < RankPoints[8]) // Gold Nova II
		rank[client] = 8;
	else if(points >= RankPoints[8] && points < RankPoints[9]) // Gold Nova III
		rank[client] = 9;
	else if(points >= RankPoints[9] && points < RankPoints[10]) // Gold Nova Master
		rank[client] = 10;
	else if(points >= RankPoints[10] && points < RankPoints[11]) // Master Guardian I
		rank[client] = 11;
	else if(points >= RankPoints[11] && points < RankPoints[12]) // Master Guardian II
		rank[client] = 12;
	else if(points >= RankPoints[12] && points < RankPoints[13]) // Master Guardian Elite
		rank[client] = 13;
	else if(points >= RankPoints[13] && points < RankPoints[14]) // Distinguished Master Guardian
		rank[client] = 14;
	else if(points >= RankPoints[14] && points < RankPoints[15]) // Legendary Eagle
		rank[client] = 15;
	else if(points >= RankPoints[15] && points < RankPoints[16]) // Legendary Eagle Master
		rank[client] = 16;
	else if(points >= RankPoints[16] && points < RankPoints[17]) // Supreme Master First Class
		rank[client] = 17;
	else if(points >= RankPoints[17]) // Global Elite
		rank[client] = 18;
	
	if(rank[client] > oldrank[client] && rank[client] > 0)
	{
		switch(g_RankPoints_HudOverlay)
		{
			case 0:
			{
				SetHudTextParams(-1.0, 0.125, 5.0, 255, 255, 255, 255, 0, 0.25, 1.5, 0.5);
				ShowHudText(client, 5, "%t", "Rank Up", RankStrings[rank[client]]);
			}
			case 1:
			{
				ShowOverlay(client, RankOverlays[rank[client] - 1], g_RankPoints_OverlayTime);
			}
		}
		
		if(g_RankPoints_SoundEnable)
		{
			ClientCommand(client, "playgamesound Music.StopAllMusic");
			EmitSoundToClient(client, g_RankPoints_SoundRankUp, SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 0.75);
		}
	}
	
	if(rank[client] < oldrank[client] && rank[client] > 0)
	{
		switch(g_RankPoints_HudOverlay)
		{
			case 0:
			{
				SetHudTextParams(-1.0, 0.125, 5.0, 255, 255, 255, 255, 0, 0.25, 1.5, 0.5);
				ShowHudText(client, 5, "%t", "Rank Down", RankStrings[rank[client]]);
			}
			case 1:
			{
				ShowOverlay(client, RankOverlays[rank[client] - 1], g_RankPoints_OverlayTime);
			}
		}
		
		if(g_RankPoints_SoundEnable)
		{
			ClientCommand(client, "playgamesound Music.StopAllMusic");
			EmitSoundToClient(client, g_RankPoints_SoundRankDown, SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 0.75);
		}
	}
	
	oldrank[client] = rank[client];
	
}

public void Hook_OnThinkPost(int iEnt)
{
	static int iRankOffset = -1;
	if (iRankOffset == -1)
		iRankOffset = FindSendPropInfo("CCSPlayerResource", "m_iCompetitiveRanking");
	
	int iRank[MAXPLAYERS+1];
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i))
		{
			iRank[i] = rank[i];
			SetEntDataArray(iEnt, iRankOffset, iRank, MaxClients+1);
		}
	}
}

public Action Menu_Points(int client, int args)
{
	Menu menu = new Menu(Panel_Handler);
	
	char buffer[256];
	
	Format(buffer, sizeof(buffer), "%t", "Rank Menu Title");
	menu.SetTitle(buffer);
	
	Format(buffer, sizeof(buffer), "%t", "Less Than X Points", RankStrings[0], (RankPoints[0] - 1));
	menu.AddItem("1", buffer);
	
	char S_i[2];
	for(int i = 1; i < 17; i++)
	{
		IntToString(i, S_i, sizeof(S_i));
		Format(buffer, sizeof(buffer), "%t", "Between X and Y", RankStrings[i], RankPoints[i - 1], (RankPoints[i + 1] - 1));
		menu.AddItem(S_i, buffer);
	}
	Format(buffer, sizeof(buffer), "%t", "More Than X Points", RankStrings[18], (RankPoints[17] - 1));
	menu.AddItem("17", buffer);
	
	menu.ExitButton = true;
	menu.Display(client, 20);
}

public int Panel_Handler(Menu menu, MenuAction action, int client, int choice)
{
	if(action == MenuAction_Select)
	{
		
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (buttons & IN_SCORE && !(GetEntProp(client, Prop_Data, "m_nOldButtons") & IN_SCORE))
	{
		Handle hBuffer = StartMessageOne("ServerRankRevealAll", client);
		if (hBuffer == INVALID_HANDLE)
			PrintToChat(client, "INVALID_HANDLE");
		else
			EndMessage();
	}
	
	return Plugin_Continue;
}

public Action Event_AnnouncePhaseEnd(Handle event, const char[] name, bool dontBroadcast)
{
	Handle hBuffer = StartMessageAll("ServerRankRevealAll");
	if (hBuffer == INVALID_HANDLE)
		PrintToServer("ServerRankRevealAll = INVALID_HANDLE");
	else
		EndMessage();
		
	return Plugin_Continue;
}

stock bool IsValidClient(int client)
{
	if(client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsFakeClient(client))
		return true;
	
	return false;
}

// https://wiki.alliedmods.net/Csgo_quirks
stock void FakePrecacheSound(const char[] szPath)
{
	AddToStringTable(FindStringTable("soundprecache"), szPath);
}
