#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#include <clientprefs>

#undef REQUIRE_PLUGIN
#include <kento_rankme/rankme>
#include <zr_rank>
#include <hlstatsx_api>
#define REQUIRE_PLUGIN

#pragma newdecls required
#pragma semicolon 1

int rank[MAXPLAYERS+1] = {0, ...};
int oldrank[MAXPLAYERS+1] = {0, ...};

// ConVar Variables
ConVar g_CVAR_RanksPoints[51];
ConVar g_CVAR_RankPoints_Type;
ConVar g_CVAR_RankPoints_Flag;
ConVar g_CVAR_RankPoints_Prefix;

// Variables to store ConVar values;
int g_RankPoints_Type;
int g_RankPoints_Flag;
char g_RankPoints_Prefix[40];
int RankPoints[51];

bool g_zrank;
bool g_kentorankme;
bool g_hlstatsx;

char RankStrings[52][256];

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
	HookEventEx("cs_win_panel_match", cs_win_panel_match);
	HookEvent("player_disconnect", Event_Disconnect, EventHookMode_Pre);
	
	// ConVar to check which rank you want
	g_CVAR_RankPoints_Type = CreateConVar("ranks_matchmaking_typeofrank", "0", "Type of Rank that you want to use for this plugin (0 for Kento Rankme, 1 for GameMe, 2 for ZR Rank, 3 for HLStatsX)", _, true, 0.0, true, 3.0);
	g_CVAR_RankPoints_Prefix = CreateConVar("ranks_matchmaking_prefix", "[{purple}Fake Ranks{default}]", "Chat Prefix");
	g_CVAR_RankPoints_Flag = CreateConVar("ranks_matchmaking_flag", "", "Flag to restrict the ranks to certain players (leave it empty to enable for everyone)");
	
	// Rank Points ConVars;
	g_CVAR_RanksPoints[0] = CreateConVar("ranks_matchmaking_point_rat1", "100", "Number of Points to reach Lab Rat I", _, true, 0.0, false);
	g_CVAR_RanksPoints[1] = CreateConVar("ranks_matchmaking_point_rat2", "250", "Number of Points to reach Lab Rat II", _, true, 0.0, false);
	g_CVAR_RanksPoints[2] = CreateConVar("ranks_matchmaking_point_hare1", "400", "Number of Points to reach Sprinting Hare I", _, true, 0.0, false);
	g_CVAR_RanksPoints[3] = CreateConVar("ranks_matchmaking_point_hare2", "550", "Number of Points to reach Sprinting Hare II", _, true, 0.0, false);
	g_CVAR_RanksPoints[4] = CreateConVar("ranks_matchmaking_point_scout1", "700", "Number of Points to reach Wild Scout I", _, true, 0.0, false);
	g_CVAR_RanksPoints[5] = CreateConVar("ranks_matchmaking_point_scout2", "850", "Number of Points to reach Wild Scout II", _, true, 0.0, false);
	g_CVAR_RanksPoints[6] = CreateConVar("ranks_matchmaking_point_scoute", "1000", "Number of Points to reach Wild Scout Elite", _, true, 0.0, false);
	g_CVAR_RanksPoints[7] = CreateConVar("ranks_matchmaking_point_fox1", "1150", "Number of Points to reach Hunter Fox I", _, true, 0.0, false);
	g_CVAR_RanksPoints[8] = CreateConVar("ranks_matchmaking_point_fox2", "1300", "Number of Points to reach Hunter Fox II", _, true, 0.0, false);
	g_CVAR_RanksPoints[9] = CreateConVar("ranks_matchmaking_point_fox3", "1450", "Number of Points to reach Hunter Fox III", _, true, 0.0, false);
	g_CVAR_RanksPoints[10] = CreateConVar("ranks_matchmaking_point_foxe", "1600", "Number of Points to reach Hunter Fox Elite", _, true, 0.0, false);
	g_CVAR_RanksPoints[11] = CreateConVar("ranks_matchmaking_point_tw", "1750", "Number of Points to reach Timber Wolf", _, true, 0.0, false);
	g_CVAR_RanksPoints[12] = CreateConVar("ranks_matchmaking_point_ew", "1900", "Number of Points to reach Ember Wolf", _, true, 0.0, false);
	g_CVAR_RanksPoints[13] = CreateConVar("ranks_matchmaking_point_ww", "2050", "Number of Points to reach Wildfire Wolf", _, true, 0.0, false);
	g_CVAR_RanksPoints[14] = CreateConVar("ranks_matchmaking_point_tha", "2200", "Number of Points to reach The Howling Alpha", _, true, 0.0, false);
	g_CVAR_RanksPoints[15] = CreateConVar("ranks_matchmaking_point_ws1", "2350", "Number of Points to reach Wingman Silver I", _, true, 0.0, false);
	g_CVAR_RanksPoints[16] = CreateConVar("ranks_matchmaking_point_ws2", "2500", "Number of Points to reach Wingman Silver II", _, true, 0.0, false);
	g_CVAR_RanksPoints[17] = CreateConVar("ranks_matchmaking_point_ws3", "2650", "Number of Points to reach Wingman Silver III", _, true, 0.0, false);
	g_CVAR_RanksPoints[18] = CreateConVar("ranks_matchmaking_point_ws4", "2800", "Number of Points to reach Wingman Silver IV", _, true, 0.0, false);
	g_CVAR_RanksPoints[19] = CreateConVar("ranks_matchmaking_point_wse", "2950", "Number of Points to reach Wingman Silver Elite", _, true, 0.0, false);
	g_CVAR_RanksPoints[20] = CreateConVar("ranks_matchmaking_point_wsem", "3100", "Number of Points to reach Wingman Silver Elite Master", _, true, 0.0, false);
	g_CVAR_RanksPoints[21] = CreateConVar("ranks_matchmaking_point_wg1", "3250", "Number of Points to reach Wingman Gold Nova I", _, true, 0.0, false);
	g_CVAR_RanksPoints[22] = CreateConVar("ranks_matchmaking_point_wg2", "3400", "Number of Points to reach Wingman Gold Nova II", _, true, 0.0, false);
	g_CVAR_RanksPoints[23] = CreateConVar("ranks_matchmaking_point_wg3", "3550", "Number of Points to reach Wingman Gold Nova III", _, true, 0.0, false);
	g_CVAR_RanksPoints[24] = CreateConVar("ranks_matchmaking_point_wg4", "3700", "Number of Points to reach Wingman Gold Nova IV", _, true, 0.0, false);
	g_CVAR_RanksPoints[25] = CreateConVar("ranks_matchmaking_point_wmg1", "3850", "Number of Points to reach Wingman Master Guardian I", _, true, 0.0, false);
	g_CVAR_RanksPoints[26] = CreateConVar("ranks_matchmaking_point_wmg2", "4000", "Number of Points to reach Wingman Master Guardian II", _, true, 0.0, false);
	g_CVAR_RanksPoints[27] = CreateConVar("ranks_matchmaking_point_wmge", "4150", "Number of Points to reach Wingman Master Guardian Elite", _, true, 0.0, false);
	g_CVAR_RanksPoints[28] = CreateConVar("ranks_matchmaking_point_wdmg", "4300", "Number of Points to reach Wingman Distinguished Master Guardian", _, true, 0.0, false);
	g_CVAR_RanksPoints[29] = CreateConVar("ranks_matchmaking_point_wle", "4450", "Number of Points to reach Wingman Legendary Eagle", _, true, 0.0, false);
	g_CVAR_RanksPoints[30] = CreateConVar("ranks_matchmaking_point_wlem", "4600", "Number of Points to reach Wingman Legendary Eagle Master", _, true, 0.0, false);
	g_CVAR_RanksPoints[31] = CreateConVar("ranks_matchmaking_point_wsmfc", "4750", "Number of Points to reach Wingman Supreme Master First Class", _, true, 0.0, false);
	g_CVAR_RanksPoints[32] = CreateConVar("ranks_matchmaking_point_wge", "4900", "Number of Points to reach Wingman Global Elite", _, true, 0.0, false);
	g_CVAR_RanksPoints[33] = CreateConVar("ranks_matchmaking_point_s1", "5050", "Number of Points to reach Silver I", _, true, 0.0, false);
	g_CVAR_RanksPoints[34] = CreateConVar("ranks_matchmaking_point_s2", "5200", "Number of Points to reach Silver II", _, true, 0.0, false);
	g_CVAR_RanksPoints[35] = CreateConVar("ranks_matchmaking_point_s3", "5350", "Number of Points to reach Silver III", _, true, 0.0, false);
	g_CVAR_RanksPoints[36] = CreateConVar("ranks_matchmaking_point_s4", "5500", "Number of Points to reach Silver IV", _, true, 0.0, false);
	g_CVAR_RanksPoints[37] = CreateConVar("ranks_matchmaking_point_se", "5650", "Number of Points to reach Silver Elite", _, true, 0.0, false);
	g_CVAR_RanksPoints[38] = CreateConVar("ranks_matchmaking_point_sem", "5800", "Number of Points to reach Silver Elite Master", _, true, 0.0, false);
	g_CVAR_RanksPoints[39] = CreateConVar("ranks_matchmaking_point_g1", "5950", "Number of Points to reach Gold Nova I", _, true, 0.0, false);
	g_CVAR_RanksPoints[40] = CreateConVar("ranks_matchmaking_point_g2", "6100", "Number of Points to reach Gold Nova II", _, true, 0.0, false);
	g_CVAR_RanksPoints[41] = CreateConVar("ranks_matchmaking_point_g3", "6250", "Number of Points to reach Gold Nova III", _, true, 0.0, false);
	g_CVAR_RanksPoints[42] = CreateConVar("ranks_matchmaking_point_g4", "6400", "Number of Points to reach Gold Nova IV", _, true, 0.0, false);
	g_CVAR_RanksPoints[43] = CreateConVar("ranks_matchmaking_point_mg1", "6550", "Number of Points to reach Master Guardian I", _, true, 0.0, false);
	g_CVAR_RanksPoints[44] = CreateConVar("ranks_matchmaking_point_mg2", "6700", "Number of Points to reach Master Guardian II", _, true, 0.0, false);
	g_CVAR_RanksPoints[45] = CreateConVar("ranks_matchmaking_point_mge", "6850", "Number of Points to reach Master Guardian Elite", _, true, 0.0, false);
	g_CVAR_RanksPoints[46] = CreateConVar("ranks_matchmaking_point_dmg", "7000", "Number of Points to reach Distinguished Master Guardian", _, true, 0.0, false);
	g_CVAR_RanksPoints[47] = CreateConVar("ranks_matchmaking_point_le", "7150", "Number of Points to reach Legendary Eagle", _, true, 0.0, false);
	g_CVAR_RanksPoints[48] = CreateConVar("ranks_matchmaking_point_lem", "7300", "Number of Points to reach Legendary Eagle Master", _, true, 0.0, false);
	g_CVAR_RanksPoints[49] = CreateConVar("ranks_matchmaking_point_smfc", "7450", "Number of Points to reach Supreme Master First Class", _, true, 0.0, false);
	g_CVAR_RanksPoints[50] = CreateConVar("ranks_matchmaking_point_ge", "7600", "Number of Points to reach Global Elite", _, true, 0.0, false);
	
	LoadTranslations("ranks_matchmaking.phrases");
	AutoExecConfig(true, "ranks_matchmaking");
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	MarkNativeAsOptional("ZR_Rank_GetPoints");
	MarkNativeAsOptional("RankMe_OnPlayerLoaded");
	MarkNativeAsOptional("RankMe_GetPoints");
	return APLRes_Success;
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "zr_rank")) {
		g_zrank = true;
	} else if (StrEqual(name, "rankme")) {
		g_kentorankme = true;
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
	} else if (StrEqual(name, "hlstatsx_api")) {
		g_hlstatsx = false;
	}		
}

public void OnMapStart()
{
	for (int i = 0; i < 51; i++)
		RankPoints[i] = g_CVAR_RanksPoints[i].IntValue;
	
	g_CVAR_RankPoints_Prefix.GetString(g_RankPoints_Prefix, sizeof(g_RankPoints_Prefix));
	
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
}

public void GetRanksNames()
{
	FormatEx(RankStrings[0], sizeof(RankStrings[]), "%t", "Unranked");
	FormatEx(RankStrings[1], sizeof(RankStrings[]), "%t", "Lab Rat I");
	FormatEx(RankStrings[2], sizeof(RankStrings[]), "%t", "Lab Rat II");
	FormatEx(RankStrings[3], sizeof(RankStrings[]), "%t", "Sprinting Hare I");
	FormatEx(RankStrings[4], sizeof(RankStrings[]), "%t", "Sprinting Hare II");
	FormatEx(RankStrings[5], sizeof(RankStrings[]), "%t", "Wild Scout I");
	FormatEx(RankStrings[6], sizeof(RankStrings[]), "%t", "Wild Scout II");
	FormatEx(RankStrings[7], sizeof(RankStrings[]), "%t", "Wild Scout Elite");
	FormatEx(RankStrings[8], sizeof(RankStrings[]), "%t", "Hunter Fox I");
	FormatEx(RankStrings[9], sizeof(RankStrings[]), "%t", "Hunter Fox II");
	FormatEx(RankStrings[10], sizeof(RankStrings[]), "%t", "Hunter Fox III");
	FormatEx(RankStrings[11], sizeof(RankStrings[]), "%t", "Hunter Fox Elite");
	FormatEx(RankStrings[12], sizeof(RankStrings[]), "%t", "Timber Wolf");
	FormatEx(RankStrings[13], sizeof(RankStrings[]), "%t", "Ember Wolf");
	FormatEx(RankStrings[14], sizeof(RankStrings[]), "%t", "Wildfire Wolf");
	FormatEx(RankStrings[15], sizeof(RankStrings[]), "%t", "The Howling Alpha");
	FormatEx(RankStrings[16], sizeof(RankStrings[]), "%t", "Wingman Silver I");
	FormatEx(RankStrings[17], sizeof(RankStrings[]), "%t", "Wingman Silver II");
	FormatEx(RankStrings[18], sizeof(RankStrings[]), "%t", "Wingman Silver III");
	FormatEx(RankStrings[19], sizeof(RankStrings[]), "%t", "Wingman Silver IV");
	FormatEx(RankStrings[20], sizeof(RankStrings[]), "%t", "Wingman Silver Elite");
	FormatEx(RankStrings[21], sizeof(RankStrings[]), "%t", "Wingman Silver Elite Master");
	FormatEx(RankStrings[22], sizeof(RankStrings[]), "%t", "Wingman Gold Nova I");
	FormatEx(RankStrings[23], sizeof(RankStrings[]), "%t", "Wingman Gold Nova II");
	FormatEx(RankStrings[24], sizeof(RankStrings[]), "%t", "Wingman Gold Nova III");
	FormatEx(RankStrings[25], sizeof(RankStrings[]), "%t", "Wingman Gold Nova Master");
	FormatEx(RankStrings[26], sizeof(RankStrings[]), "%t", "Wingman Master Guardian I");
	FormatEx(RankStrings[27], sizeof(RankStrings[]), "%t", "Wingman Master Guardian II");
	FormatEx(RankStrings[28], sizeof(RankStrings[]), "%t", "Wingman Master Guardian Elite");
	FormatEx(RankStrings[29], sizeof(RankStrings[]), "%t", "Wingman Distinguished Master Guardian");
	FormatEx(RankStrings[30], sizeof(RankStrings[]), "%t", "Wingman Legendary Eagle");
	FormatEx(RankStrings[31], sizeof(RankStrings[]), "%t", "Wingman Legendary Eagle Master");
	FormatEx(RankStrings[32], sizeof(RankStrings[]), "%t", "Wingman Supreme First Master Class");
	FormatEx(RankStrings[33], sizeof(RankStrings[]), "%t", "Wingman Global Elite");
	FormatEx(RankStrings[34], sizeof(RankStrings[]), "%t", "Silver I");
	FormatEx(RankStrings[35], sizeof(RankStrings[]), "%t", "Silver II");
	FormatEx(RankStrings[36], sizeof(RankStrings[]), "%t", "Silver III");
	FormatEx(RankStrings[37], sizeof(RankStrings[]), "%t", "Silver IV");
	FormatEx(RankStrings[38], sizeof(RankStrings[]), "%t", "Silver Elite");
	FormatEx(RankStrings[39], sizeof(RankStrings[]), "%t", "Silver Elite Master");
	FormatEx(RankStrings[40], sizeof(RankStrings[]), "%t", "Gold Nova I");
	FormatEx(RankStrings[41], sizeof(RankStrings[]), "%t", "Gold Nova II");
	FormatEx(RankStrings[42], sizeof(RankStrings[]), "%t", "Gold Nova III");
	FormatEx(RankStrings[43], sizeof(RankStrings[]), "%t", "Gold Nova Master");
	FormatEx(RankStrings[44], sizeof(RankStrings[]), "%t", "Master Guardian I");
	FormatEx(RankStrings[45], sizeof(RankStrings[]), "%t", "Master Guardian II");
	FormatEx(RankStrings[46], sizeof(RankStrings[]), "%t", "Master Guardian Elite");
	FormatEx(RankStrings[47], sizeof(RankStrings[]), "%t", "Distinguished Master Guardian");
	FormatEx(RankStrings[48], sizeof(RankStrings[]), "%t", "Legendary Eagle");
	FormatEx(RankStrings[49], sizeof(RankStrings[]), "%t", "Legendary Eagle Master");
	FormatEx(RankStrings[50], sizeof(RankStrings[]), "%t", "Supreme First Master Class");
	FormatEx(RankStrings[51], sizeof(RankStrings[]), "%t", "Global Elite");
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

		if (g_zrank && g_RankPoints_Type == 2) {
			int points = ZR_Rank_GetPoints(client);
			CheckRanks(client, points);

		} else if (g_hlstatsx && g_RankPoints_Type == 3) {

			HLStatsX_Api_GetStats("playerinfo", client, _HLStatsX_API_Response, 0);
		}
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
	else if(points >= RankPoints[0] && points < RankPoints[1]) // Lab Rat I
		rank[client] = 37;
	else if(points >= RankPoints[1] && points < RankPoints[2]) // Lab Rat II
		rank[client] = 38;
	else if(points >= RankPoints[2] && points < RankPoints[3]) // Sprinting Hare I
		rank[client] = 39;
	else if(points >= RankPoints[3] && points < RankPoints[4]) // Sprinting Hare II
		rank[client] = 40;
	else if(points >= RankPoints[4] && points < RankPoints[5]) // Wild Scout I
		rank[client] = 41;
	else if(points >= RankPoints[5] && points < RankPoints[6]) // Wild Scout II
		rank[client] = 42;
	else if(points >= RankPoints[6] && points < RankPoints[7]) // Wild Scout Elite
		rank[client] = 43;
	else if(points >= RankPoints[7] && points < RankPoints[8]) // Hunter Fox I
		rank[client] = 44;
	else if(points >= RankPoints[8] && points < RankPoints[9]) // Hunter Fox II
		rank[client] = 45;
	else if(points >= RankPoints[9] && points < RankPoints[10]) // Hunter Fox III
		rank[client] = 46;
	else if(points >= RankPoints[10] && points < RankPoints[11]) // Hunter Fox Elite
		rank[client] = 47;
	else if(points >= RankPoints[11] && points < RankPoints[12]) // Timber Wolf
		rank[client] = 48;
	else if(points >= RankPoints[12] && points < RankPoints[13]) // Ember Wolf
		rank[client] = 49;
	else if(points >= RankPoints[13] && points < RankPoints[14]) // Wildfire Wolf
		rank[client] = 50;
	else if(points >= RankPoints[14] && points < RankPoints[15]) // The Howling Alpha
		rank[client] = 51;
	else if(points >= RankPoints[15] && points < RankPoints[16]) // Wingman Silver I
		rank[client] = 19;
	else if(points >= RankPoints[16] && points < RankPoints[17]) // Wingman Silver II
		rank[client] = 20;
	else if(points >= RankPoints[17] && points < RankPoints[18]) // Wingman Silver III
		rank[client] = 21;
	else if(points >= RankPoints[18] && points < RankPoints[19]) // Wingman Silver IV
		rank[client] = 22;
	else if(points >= RankPoints[19] && points < RankPoints[20]) // Wingman Silver Elite
		rank[client] = 23;
	else if(points >= RankPoints[20] && points < RankPoints[21]) // Wingman Silver Elite Master
		rank[client] = 24;
	else if(points >= RankPoints[21] && points < RankPoints[22]) // Wingman Gold Nova I
		rank[client] = 25;
	else if(points >= RankPoints[22] && points < RankPoints[23]) // Wingman Gold Nova II
		rank[client] = 26;
	else if(points >= RankPoints[23] && points < RankPoints[24]) // Wingman Gold Nova III
		rank[client] = 27;
	else if(points >= RankPoints[24] && points < RankPoints[25]) // Wingman Gold Nova Master
		rank[client] = 28;
	else if(points >= RankPoints[25] && points < RankPoints[26]) // Wingman Master Guardian I
		rank[client] = 29;
	else if(points >= RankPoints[26] && points < RankPoints[27]) // Wingman Master Guardian II
		rank[client] = 30;
	else if(points >= RankPoints[27] && points < RankPoints[28]) // Wingman Master Guardian Elite
		rank[client] = 31;
	else if(points >= RankPoints[28] && points < RankPoints[29]) // Wingman Distinguished Master Guardian
		rank[client] = 32;
	else if(points >= RankPoints[29] && points < RankPoints[30]) // Wingman Legendary Eagle
		rank[client] = 33;
	else if(points >= RankPoints[30] && points < RankPoints[31]) // Wingman Legendary Eagle Master
		rank[client] = 34;
	else if(points >= RankPoints[31] && points < RankPoints[32]) // Wingman Supreme Master First Class
		rank[client] = 35;
	else if(points >= RankPoints[32] && points < RankPoints[33]) // Wingman Global Elite
		rank[client] = 36;
	else if(points >= RankPoints[33] && points < RankPoints[34]) // Silver I
		rank[client] = 1;
	else if(points >= RankPoints[34] && points < RankPoints[35]) // Silver II
		rank[client] = 2;
	else if(points >= RankPoints[35] && points < RankPoints[36]) // Silver III
		rank[client] = 3;
	else if(points >= RankPoints[36] && points < RankPoints[37]) // Silver IV
		rank[client] = 4;
	else if(points >= RankPoints[37] && points < RankPoints[38]) // Silver Elite
		rank[client] = 5;
	else if(points >= RankPoints[38] && points < RankPoints[39]) // Silver Elite Master
		rank[client] = 6;
	else if(points >= RankPoints[39] && points < RankPoints[40]) // Gold Nova I
		rank[client] = 7;
	else if(points >= RankPoints[40] && points < RankPoints[41]) // Gold Nova II
		rank[client] = 8;
	else if(points >= RankPoints[41] && points < RankPoints[42]) // Gold Nova III
		rank[client] = 9;
	else if(points >= RankPoints[42] && points < RankPoints[43]) // Gold Nova Master
		rank[client] = 10;
	else if(points >= RankPoints[43] && points < RankPoints[44]) // Master Guardian I
		rank[client] = 11;
	else if(points >= RankPoints[44] && points < RankPoints[45]) // Master Guardian II
		rank[client] = 12;
	else if(points >= RankPoints[45] && points < RankPoints[46]) // Master Guardian Elite
		rank[client] = 13;
	else if(points >= RankPoints[46] && points < RankPoints[47]) // Distinguished Master Guardian
		rank[client] = 14;
	else if(points >= RankPoints[47] && points < RankPoints[48]) // Legendary Eagle
		rank[client] = 15;
	else if(points >= RankPoints[48] && points < RankPoints[49]) // Legendary Eagle Master
		rank[client] = 16;
	else if(points >= RankPoints[49] && points < RankPoints[50]) // Supreme Master First Class
		rank[client] = 17;
	else if(points >= RankPoints[50]) // Global Elite
		rank[client] = 18;
	
	if(rank[client] > oldrank[client] && rank[client] > 0)
	{	
		RankUpdate(client, oldrank[client], rank[client]);
	}
	
	oldrank[client] = rank[client];
	
}

public void RankUpdate(int client, int old_rank, int new_rank)
{
	Protobuf pb = view_as<Protobuf>(StartMessageAll("ServerRankUpdate", USERMSG_RELIABLE));

	// Можно добавлять сразу несколько оружий в одно сообщение
	Protobuf rank_update = pb.AddMessage("rank_update");
	
	int stats_return[35];
	
	RankMe_GetStats(client, stats_return);
	
	rank_update.SetInt("account_id", GetSteamAccountID(client)); // Defindex оружия
	rank_update.SetInt("rank_old", old_rank); // Skin ID оружия (344 - Dragon Lore)
	rank_update.SetInt("rank_new", new_rank); // Редкость оружия. Влияет на задержку выпадения.
	rank_update.SetInt("num_wins", stats_return[23]); // Редкость оружия. Влияет на задержку выпадения.
	
	EndMessage();
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

public void cs_win_panel_match(Handle event, const char[] eventname, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i))
		{
			CheckPoints(i);
		}
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
	if(client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client))
		return true;
	
	return false;
}

// https://wiki.alliedmods.net/Csgo_quirks
stock void FakePrecacheSound(const char[] szPath)
{
	AddToStringTable(FindStringTable("soundprecache"), szPath);
}