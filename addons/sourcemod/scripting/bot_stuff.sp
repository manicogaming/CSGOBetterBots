#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#include <eItems>
#include <smlib>
#include <navmesh>
#include <dhooks>
#include <botmimic>
#include <PTaH>
#include <ripext>

char g_szMap[128];
char g_szCrosshairCode[MAXPLAYERS+1][35], g_szPreviousBuy[MAXPLAYERS+1][128];
bool g_bIsBombScenario, g_bIsHostageScenario, g_bFreezetimeEnd, g_bBombPlanted, g_bEveryoneDead, g_bHalftimeSwitch, g_bIsCompetitive;
bool g_bUseCZ75[MAXPLAYERS+1], g_bUseUSP[MAXPLAYERS+1], g_bUseM4A1S[MAXPLAYERS+1], g_bDontSwitch[MAXPLAYERS+1], g_bDropWeapon[MAXPLAYERS+1], g_bHasGottenDrop[MAXPLAYERS+1];
bool g_bIsProBot[MAXPLAYERS+1], g_bThrowGrenade[MAXPLAYERS+1], g_bUncrouch[MAXPLAYERS+1];
int g_iProfileRank[MAXPLAYERS+1], g_iPlayerColor[MAXPLAYERS+1], g_iTarget[MAXPLAYERS+1], g_iPrevTarget[MAXPLAYERS+1], g_iDoingSmokeNum[MAXPLAYERS+1], g_iActiveWeapon[MAXPLAYERS+1];
int g_iCurrentRound, g_iRoundsPlayed, g_iCTScore, g_iTScore, g_iMaxNades;
int g_iProfileRankOffset, g_iPlayerColorOffset;
int g_iBotTargetSpotOffset, g_iBotNearbyEnemiesOffset, g_iFireWeaponOffset, g_iEnemyVisibleOffset, g_iBotProfileOffset, g_iBotSafeTimeOffset, g_iBotEnemyOffset, g_iBotLookAtSpotStateOffset, g_iBotMoraleOffset, g_iBotTaskOffset, g_iBotDispositionOffset;
float g_fBotOrigin[MAXPLAYERS+1][3], g_fTargetPos[MAXPLAYERS+1][3], g_fNadeTarget[MAXPLAYERS+1][3];
float g_fRoundStart, g_fFreezeTimeEnd;
float g_fLookAngleMaxAccel[MAXPLAYERS+1], g_fReactionTime[MAXPLAYERS+1], g_fAggression[MAXPLAYERS+1], g_fShootTimestamp[MAXPLAYERS+1], g_fThrowNadeTimestamp[MAXPLAYERS+1], g_fCrouchTimestamp[MAXPLAYERS+1];
ConVar g_cvBotEcoLimit;
Handle g_hBotMoveTo;
Handle g_hLookupBone;
Handle g_hGetBonePosition;
Handle g_hBotIsVisible;
Handle g_hBotIsHiding;
Handle g_hBotEquipBestWeapon;
Handle g_hBotSetLookAt;
Handle g_hSetCrosshairCode;
Handle g_hSwitchWeaponCall;
Handle g_hIsLineBlockedBySmoke;
Handle g_hBotBendLineOfSight;
Handle g_hBotThrowGrenade;
Handle g_hAddMoney;
Address g_pTheBots;
CNavArea g_pCurrArea[MAXPLAYERS+1];

//BOT Nades Variables
float g_fNadePos[128][3], g_fNadeLook[128][3];
int g_iNadeDefIndex[128];
char g_szReplay[128][128];
float g_fNadeTimestamp[128];
int g_iNadeTeam[128];

static const char g_szTopBotNames[][] =
{
    "s1mple", "ZywOo", "NiKo", "sh1ro", "jL", "donk", "m0NESY"
};

static char g_szBoneNames[][] =  {
	"neck_0", 
	"pelvis", 
	"spine_0", 
	"spine_1", 
	"spine_2", 
	"spine_3", 
	"clavicle_l",
	"clavicle_r",
	"arm_upper_L", 
	"arm_lower_L", 
	"hand_L", 
	"arm_upper_R", 
	"arm_lower_R", 
	"hand_R", 
	"leg_upper_L",  
	"leg_lower_L", 
	"ankle_L",
	"leg_upper_R", 
	"leg_lower_R",
	"ankle_R"
};

enum RouteType
{
	DEFAULT_ROUTE = 0, 
	FASTEST_ROUTE, 
	SAFEST_ROUTE, 
	RETREAT_ROUTE
}

enum PriorityType
{
	PRIORITY_LOWEST = -1,
	PRIORITY_LOW, 
	PRIORITY_MEDIUM, 
	PRIORITY_HIGH, 
	PRIORITY_UNINTERRUPTABLE
}

enum LookAtSpotState
{
	NOT_LOOKING_AT_SPOT,			///< not currently looking at a point in space
	LOOK_TOWARDS_SPOT,				///< in the process of aiming at m_lookAtSpot
	LOOK_AT_SPOT,					///< looking at m_lookAtSpot
	NUM_LOOK_AT_SPOT_STATES
}

enum GrenadeTossState
{
	NOT_THROWING,				///< not yet throwing
	START_THROW,				///< lining up throw
	THROW_LINED_UP,				///< pause for a moment when on-line
	FINISH_THROW				///< throwing
}

enum TaskType
{
	SEEK_AND_DESTROY,
	PLANT_BOMB,
	FIND_TICKING_BOMB,
	DEFUSE_BOMB,
	GUARD_TICKING_BOMB,
	GUARD_BOMB_DEFUSER,
	GUARD_LOOSE_BOMB,
	GUARD_BOMB_ZONE,
	GUARD_INITIAL_ENCOUNTER,
	ESCAPE_FROM_BOMB,
	HOLD_POSITION,
	FOLLOW,
	VIP_ESCAPE,
	GUARD_VIP_ESCAPE_ZONE,
	COLLECT_HOSTAGES,
	RESCUE_HOSTAGES,
	GUARD_HOSTAGES,
	GUARD_HOSTAGE_RESCUE_ZONE,
	MOVE_TO_LAST_KNOWN_ENEMY_POSITION,
	MOVE_TO_SNIPER_SPOT,
	SNIPING,
	ESCAPE_FROM_FLAMES,
	NUM_TASKS
}

enum DispositionType
{
	ENGAGE_AND_INVESTIGATE,								///< engage enemies on sight and investigate enemy noises
	OPPORTUNITY_FIRE,									///< engage enemies on sight, but only look towards enemy noises, dont investigate
	SELF_DEFENSE,										///< only engage if fired on, or very close to enemy
	IGNORE_ENEMIES,										///< ignore all enemies - useful for ducking around corners, running away, etc
	NUM_DISPOSITIONS
}

enum GamePhase
{
	GAMEPHASE_WARMUP_ROUND,
	GAMEPHASE_PLAYING_STANDARD,	
	GAMEPHASE_PLAYING_FIRST_HALF,
	GAMEPHASE_PLAYING_SECOND_HALF,
	GAMEPHASE_HALFTIME,
	GAMEPHASE_MATCH_ENDED,    
	GAMEPHASE_MAX
}

public Plugin myinfo = 
{
	name = "BOT Improvement", 
	author = "manico", 
	description = "Improves bots and does other things.", 
	version = "1.2.3", 
	url = "http://steamcommunity.com/id/manico001"
};

public void OnPluginStart()
{
    g_bIsCompetitive = (FindConVar("game_mode").IntValue == 1 && FindConVar("game_type").IntValue == 0);
    g_cvBotEcoLimit = FindConVar("bot_eco_limit");

    HookEventEx("round_prestart", OnRoundPreStart);
    HookEventEx("round_start", OnRoundStart);
    HookEventEx("round_end", OnRoundEnd);
    HookEventEx("round_freeze_end", OnFreezetimeEnd);

    HookEventEx("player_spawn", OnPlayerSpawn);

    HookEventEx("weapon_zoom", OnWeaponZoom);
    HookEventEx("weapon_fire", OnWeaponFire);

    LoadSDK();
    LoadDetours();

    RegConsoleCmd("team", Command_Team);
}

public Action Command_Team(int client, int iArgs)
{
    if (iArgs < 2)
    {
        PrintToChat(client, "Usage: team <TeamName> <t|ct>");
        return Plugin_Handled;
    }

    char szTeam[32], szSide[8], szPath[PLATFORM_MAX_PATH];
    GetCmdArg(1, szTeam, sizeof(szTeam));
    GetCmdArg(2, szSide, sizeof(szSide));

    if (strcmp(szSide, "ct", false) != 0 && strcmp(szSide, "t", false) != 0)
    {
        PrintToServer("Invalid side: %s (use t or ct)", szSide);
        return Plugin_Handled;
    }

    BuildPath(Path_SM, szPath, sizeof(szPath), "configs/bot_rosters.txt");
    if (!FileExists(szPath))
    {
        PrintToServer("Configuration file %s not found.", szPath);
        return Plugin_Handled;
    }

    KeyValues kv = new KeyValues("Teams");
    if (!kv.ImportFromFile(szPath))
    {
        delete kv;
        PrintToServer("Unable to parse KeyValues file %s.", szPath);
        return Plugin_Handled;
    }

    if (!kv.JumpToKey(szTeam))
    {
        delete kv;
        PrintToServer("Unknown team: %s", szTeam);
        return Plugin_Handled;
    }

    char szPlayers[256], szLogo[64];
    kv.GetString("players", szPlayers, sizeof(szPlayers));
    kv.GetString("logo", szLogo, sizeof(szLogo));
    delete kv;

    ServerCommand("bot_kick %s all", szSide);

    char szPlayerNames[5][MAX_NAME_LENGTH];
    int iCount = ExplodeString(szPlayers, ",", szPlayerNames, sizeof(szPlayerNames), sizeof(szPlayerNames[]));

    for (int i = 0; i < iCount; i++)
        ServerCommand("bot_add_%s %s", szSide, szPlayerNames[i]);

    ServerCommand(strcmp(szSide, "ct", false) == 0 ? "mp_teamlogo_1 %s" : "mp_teamlogo_2 %s", szLogo);

    return Plugin_Handled;
}

public void OnMapStart()
{
    g_iProfileRankOffset = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicLevel");
    g_iPlayerColorOffset = FindSendPropInfo("CCSPlayerResource", "m_iCompTeammateColor");

    GetCurrentMap(g_szMap, sizeof(g_szMap));
    GetMapDisplayName(g_szMap, g_szMap, sizeof(g_szMap));
    ParseMapNades(g_szMap);

    g_bIsBombScenario = IsValidEntity(FindEntityByClassname(-1, "func_bomb_target"));
    g_bIsHostageScenario = IsValidEntity(FindEntityByClassname(-1, "func_hostage_rescue"));

    CreateTimer(1.0, Timer_CheckPlayer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    CreateTimer(0.1, Timer_MoveToBomb, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    SDKHook(GetPlayerResourceEntity(), SDKHook_ThinkPost, OnThinkPost);

    Array_Fill(g_iPlayerColor, MaxClients + 1, -1);
}

public Action Timer_CheckPlayer(Handle hTimer, any data)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || !IsFakeClient(i) || !IsPlayerAlive(i))
			continue;

		int iAccount = GetEntProp(i, Prop_Send, "m_iAccount");
		int iTeam = GetClientTeam(i);
		int iArmor = GetEntProp(i, Prop_Data, "m_ArmorValue");
		bool bInBuyZone = !!GetEntProp(i, Prop_Send, "m_bInBuyZone");
		bool bHasDefuser = !!GetEntProp(i, Prop_Send, "m_bHasDefuser");
		bool bHasHelmet = !!GetEntProp(i, Prop_Send, "m_bHasHelmet");
		int iPrimary = GetPlayerWeaponSlot(i, CS_SLOT_PRIMARY);

		char szCurrentWeapon[64];
		GetClientWeapon(i, szCurrentWeapon, sizeof(szCurrentWeapon));
		bool bDefaultPistol = IsDefaultPistol(szCurrentWeapon);

		if (IsItMyChance(2.0))
		{
			FakeClientCommand(i, "+lookatweapon");
			FakeClientCommand(i, "-lookatweapon");
		}

		if (!bInBuyZone)
			continue;

		if (IsValidEntity(iPrimary) || (GetFriendsWithPrimary(i) >= 1 && !bDefaultPistol))
		{
			if (iArmor < 50 || !bHasHelmet)
				FakeClientCommand(i, "buy vesthelm");

			if (iTeam == CS_TEAM_CT && !bHasDefuser)
				FakeClientCommand(i, "buy defuser");

			if (GetGameTime() - g_fRoundStart > 6.0 && !g_bFreezetimeEnd)
			{
				int iRndNadeSet = Math_GetRandomInt(1, 3);

				switch (iRndNadeSet)
				{
					case 1:
					{
						FakeClientCommand(i, "buy smokegrenade");
						FakeClientCommand(i, "buy flashbang");
						FakeClientCommand(i, "buy flashbang");
						FakeClientCommand(i, "buy hegrenade");
					}
					case 2:
					{
						FakeClientCommand(i, "buy smokegrenade");
						FakeClientCommand(i, "buy flashbang");
						FakeClientCommand(i, "buy flashbang");
						FakeClientCommand(i, "buy molotov");
					}
					case 3:
					{
						FakeClientCommand(i, "buy smokegrenade");
						FakeClientCommand(i, "buy flashbang");
						FakeClientCommand(i, "buy hegrenade");
						FakeClientCommand(i, "buy molotov");
					}
				}
			}
		}

		if ((iAccount < g_cvBotEcoLimit.IntValue && iAccount > 2000 && !IsValidEntity(iPrimary)) || GetFriendsWithPrimary(i) >= 1)
		{
			if (bDefaultPistol)
			{
				switch (Math_GetRandomInt(1, 5))
				{
					case 1: FakeClientCommand(i, "buy p250");
					case 2: FakeClientCommand(i, "buy tec9");
					case 3: FakeClientCommand(i, "buy deagle");
				}
			}
			else
			{
				switch (Math_GetRandomInt(1, 15))
				{
					case 1: FakeClientCommand(i, "buy vest");
					case 10: FakeClientCommand(i, "buy %s", (iTeam == CS_TEAM_CT && !bHasDefuser) ? "defuser" : "vest");
				}
			}
		}

		if (g_iCurrentRound == 0 || g_iCurrentRound == 12)
		{
			if (IsItMyChance(2.0))
				FakeClientCommand(i, "buy %s", (iTeam == CS_TEAM_CT) ? "elite" : "vest");
			else if (IsItMyChance(30.0))
				FakeClientCommand(i, "buy %s", (iTeam == CS_TEAM_CT) ? "defuser" : "p250");
			else if (IsItMyChance(60.0))
				FakeClientCommand(i, "buy vest");
		}
	}

	return Plugin_Continue;
}

public Action Timer_MoveToBomb(Handle hTimer, any data)
{
	if (!g_bBombPlanted)
		return Plugin_Continue;

	int iPlantedC4 = FindEntityByClassname(-1, "planted_c4");
	if (!IsValidEntity(iPlantedC4))
		return Plugin_Continue;

	float fC4Pos[3];
	GetEntPropVector(iPlantedC4, Prop_Send, "m_vecOrigin", fC4Pos);

	int iCTCount = GetAliveTeamCount(CS_TEAM_CT);
	int iTCount = GetAliveTeamCount(CS_TEAM_T);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || !IsFakeClient(i) || !IsPlayerAlive(i) || GetClientTeam(i) != CS_TEAM_CT)
			continue;

		float fDistanceToBomb = GetVectorDistance(g_fBotOrigin[i], fC4Pos);
		bool bLastMan = (iTCount == 0 && iCTCount == 1 && fDistanceToBomb > 30.0 && GetTask(i) != ESCAPE_FROM_BOMB);

		if ((bLastMan || fDistanceToBomb > 2000.0) && GetEntData(i, g_iBotNearbyEnemiesOffset) == 0 && !g_bDontSwitch[i])
		{
			SDKCall(g_hSwitchWeaponCall, i, GetPlayerWeaponSlot(i, CS_SLOT_KNIFE), 0);
			BotMoveTo(i, fC4Pos, FASTEST_ROUTE);
		}
	}

	return Plugin_Continue;
}

public Action Timer_DropWeapons(Handle hTimer, any data)
{
    if (GetGameTime() - g_fRoundStart <= 3.0)
        return Plugin_Continue;

    if (g_bFreezetimeEnd)
        return Plugin_Stop;

    ArrayList ArrayBotT = new ArrayList(2);
    ArrayList ArrayBotCT = new ArrayList(2);

    for (int j = 1; j <= MaxClients; j++)
    {
        if (!IsValidClient(j) || !IsFakeClient(j) || !IsPlayerAlive(j) || g_bDropWeapon[j])
            continue;

        int iOtherPrimary = GetPlayerWeaponSlot(j, CS_SLOT_PRIMARY);
        if (!IsValidEntity(iOtherPrimary))
            continue;

        int iDefIndex = GetEntProp(iOtherPrimary, Prop_Send, "m_iItemDefinitionIndex");
        CSWeaponID pWeaponID = CS_ItemDefIndexToID(iDefIndex);
        if (pWeaponID == CSWeapon_NONE)
            continue;

        int iMoney = GetEntProp(j, Prop_Send, "m_iAccount");
        if (iMoney < CS_GetWeaponPrice(j, pWeaponID))
            continue;

        GetEntityClassname(iOtherPrimary, g_szPreviousBuy[j], sizeof(g_szPreviousBuy[j]));
        ReplaceString(g_szPreviousBuy[j], sizeof(g_szPreviousBuy[j]), "weapon_", "");

        int iEntry[2];
        iEntry[0] = j;
        iEntry[1] = iMoney;

        if (GetClientTeam(j) == CS_TEAM_T)
            ArrayBotT.PushArray(iEntry);
        else if (GetClientTeam(j) == CS_TEAM_CT)
            ArrayBotCT.PushArray(iEntry);
    }

    SortADTArrayCustom(ArrayBotT, Sort_BotMoneyDesc);
    SortADTArrayCustom(ArrayBotCT, Sort_BotMoneyDesc);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsValidClient(i) || !IsPlayerAlive(i) || g_bHasGottenDrop[i])
            continue;

        if (!GetEntProp(i, Prop_Send, "m_bInBuyZone"))
            continue;

        int iPrimary = GetPlayerWeaponSlot(i, CS_SLOT_PRIMARY);
        int iAccount = GetEntProp(i, Prop_Send, "m_iAccount");

        if (IsValidEntity(iPrimary) || iAccount >= g_cvBotEcoLimit.IntValue)
            continue;

        ArrayList ArrayTeamList = (GetClientTeam(i) == CS_TEAM_T) ? ArrayBotT : ArrayBotCT;
        if (ArrayTeamList.Length == 0)
            continue;

        int iEntry[2];
        ArrayTeamList.GetArray(0, iEntry, sizeof(iEntry));
        int iBestBot = iEntry[0];
        ArrayTeamList.Erase(0);

        float fEyes[3];
        GetClientEyePosition(i, fEyes);

        BotSetLookAt(iBestBot, "Use entity", fEyes, PRIORITY_HIGH, 3.0, false, 5.0, false);
        g_bDropWeapon[iBestBot] = true;
        g_bHasGottenDrop[i] = true;
    }

    delete ArrayBotT;
    delete ArrayBotCT;

    return Plugin_Continue;
}

public void OnMapEnd()
{
	SDKUnhook(GetPlayerResourceEntity(), SDKHook_ThinkPost, OnThinkPost);
}

public void OnClientPostAdminCheck(int client)
{
    g_iProfileRank[client] = Math_GetRandomInt(1, 40);

    if (!IsFakeClient(client))
    {
        char szColor[64];
        GetClientInfo(client, "cl_color", szColor, sizeof(szColor));
        g_iPlayerColor[client] = StringToInt(szColor);
        return;
    }

    char szBotName[MAX_NAME_LENGTH];
    GetClientName(client, szBotName, sizeof(szBotName));
    g_bIsProBot[client] = false;

    if (IsProBot(szBotName, g_szCrosshairCode[client], 35))
    {
        if (IsTopBot(szBotName))
        {
            g_fLookAngleMaxAccel[client] = 20000.0;
            g_fReactionTime[client] = 0.0;
            g_fAggression[client] = 1.0;
        }
        else
        {
            g_fLookAngleMaxAccel[client] = Math_GetRandomFloat(4000.0, 7000.0);
            g_fReactionTime[client] = Math_GetRandomFloat(0.165, 0.325);
            g_fAggression[client] = Math_GetRandomFloat(0.0, 1.0);
        }

        g_bIsProBot[client] = true;
    }

    g_bUseUSP[client] = IsItMyChance(75.0);
    g_bUseM4A1S[client] = IsItMyChance(50.0);
    g_bUseCZ75[client] = IsItMyChance(20.0);
    g_pCurrArea[client] = INVALID_NAV_AREA;
}

public void OnRoundPreStart(Event eEvent, char[] szName, bool bDontBroadcast)
{
    g_iCurrentRound = GameRules_GetProp("m_totalRoundsPlayed");
    g_cvBotEcoLimit.IntValue = ShouldForce() ? 0 : 3000;
}

public void OnRoundStart(Event eEvent, char[] szName, bool bDontBroadcast)
{
	g_bFreezetimeEnd = false;
	g_bEveryoneDead = false;
	g_fRoundStart = GetGameTime();
	g_bHalftimeSwitch = false;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || !IsFakeClient(i) || !IsPlayerAlive(i))
			continue;

		g_bUncrouch[i] = IsItMyChance(50.0);
		g_bDontSwitch[i] = false;
		g_bDropWeapon[i] = false;
		g_bHasGottenDrop[i] = false;
		g_bThrowGrenade[i] = false;

		g_iTarget[i] = -1;
		g_iPrevTarget[i] = -1;
		g_iDoingSmokeNum[i] = -1;

		g_fShootTimestamp[i] = 0.0;
		g_fThrowNadeTimestamp[i] = 0.0;
		g_fCrouchTimestamp[i] = 0.0;

		if (g_bIsBombScenario || g_bIsHostageScenario)
		{
			int iTeam = g_bIsBombScenario ? CS_TEAM_CT : CS_TEAM_T;
			int iOppositeTeam = g_bIsBombScenario ? CS_TEAM_T : CS_TEAM_CT;
			int iClientTeam = GetClientTeam(i);

			if (iClientTeam == iTeam)
				SetEntData(i, g_iBotMoraleOffset, -3);

			if (g_bHalftimeSwitch && iClientTeam == iOppositeTeam)
				SetEntData(i, g_iBotMoraleOffset, 1);
		}
	}

	if (g_bIsCompetitive)
		CreateTimer(0.2, Timer_DropWeapons, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public void OnRoundEnd(Event eEvent, char[] szName, bool bDontBroadcast)
{
	int iEnt = -1;
	while ((iEnt = FindEntityByClassname(iEnt, "cs_team_manager")) != -1)
	{
		int iTeamNum = GetEntProp(iEnt, Prop_Send, "m_iTeamNum");

		if (iTeamNum == CS_TEAM_CT)
			g_iCTScore = GetEntProp(iEnt, Prop_Send, "m_scoreTotal");
		else if (iTeamNum == CS_TEAM_T)
			g_iTScore = GetEntProp(iEnt, Prop_Send, "m_scoreTotal");
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsFakeClient(i) && BotMimic_IsPlayerMimicing(i))
			BotMimic_StopPlayerMimic(i);
	}

	g_iRoundsPlayed = g_iCTScore + g_iTScore;

	for (int i = 0; i < g_iMaxNades; i++)
		g_fNadeTimestamp[i] = 0.0;
}

public void OnFreezetimeEnd(Event eEvent, char[] szName, bool bDontBroadcast)
{
	g_bFreezetimeEnd = true;
	g_fFreezeTimeEnd = GetGameTime();
}

public void OnWeaponZoom(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(eEvent.GetInt("userid"));
	if (!IsValidClient(client) || !IsFakeClient(client) || !IsPlayerAlive(client))
		return;

	g_fShootTimestamp[client] = GetGameTime();
}

public void OnWeaponFire(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(eEvent.GetInt("userid"));
	if (!IsValidClient(client) || !IsFakeClient(client) || !IsPlayerAlive(client))
		return;

	char szWeaponName[64];
	eEvent.GetString("weapon", szWeaponName, sizeof(szWeaponName));

	if (IsValidClient(g_iTarget[client]))
	{
		float fTargetLoc[3];
		GetClientAbsOrigin(g_iTarget[client], fTargetLoc);

		float fRangeToEnemy = GetVectorDistance(g_fBotOrigin[client], fTargetLoc);
		if (strcmp(szWeaponName, "weapon_deagle") == 0 && fRangeToEnemy > 100.0)
		{
			float currentOffset = GetEntDataFloat(client, g_iFireWeaponOffset);
			SetEntDataFloat(client, g_iFireWeaponOffset, currentOffset + Math_GetRandomFloat(0.20, 0.40));
		}
	}

	if ((strcmp(szWeaponName, "weapon_awp") == 0 || strcmp(szWeaponName, "weapon_ssg08") == 0) && IsItMyChance(50.0))
		RequestFrame(BeginQuickSwitch, GetClientUserId(client));
}

public void OnThinkPost(int iEnt)
{
	SetEntDataArray(iEnt, g_iProfileRankOffset, g_iProfileRank, MAXPLAYERS + 1);
	SetEntDataArray(iEnt, g_iPlayerColorOffset, g_iPlayerColor, MAXPLAYERS + 1);

	for (int i = 1; i <= MaxClients; i++)
		if (IsValidClient(i) && IsFakeClient(i))
			SetCrosshairCode(GetEntityAddress(iEnt), i, g_szCrosshairCode[i]);
}

public Action CS_OnBuyCommand(int client, const char[] szWeapon)
{
	if (!IsValidClient(client) || !IsFakeClient(client) || !IsPlayerAlive(client))
		return Plugin_Continue;

	if (strcmp(szWeapon, "molotov") == 0 || strcmp(szWeapon, "incgrenade") == 0 || strcmp(szWeapon, "decoy") == 0 ||
	    strcmp(szWeapon, "flashbang") == 0 || strcmp(szWeapon, "hegrenade") == 0 || strcmp(szWeapon, "smokegrenade") == 0 ||
	    strcmp(szWeapon, "vest") == 0 || strcmp(szWeapon, "vesthelm") == 0 || strcmp(szWeapon, "defuser") == 0)
		return Plugin_Continue;

	if (GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) != -1 &&
	    (strcmp(szWeapon, "galilar") == 0 || strcmp(szWeapon, "famas") == 0 || strcmp(szWeapon, "ak47") == 0 ||
	     strcmp(szWeapon, "m4a1") == 0 || strcmp(szWeapon, "ssg08") == 0 || strcmp(szWeapon, "aug") == 0 ||
	     strcmp(szWeapon, "sg556") == 0 || strcmp(szWeapon, "awp") == 0 || strcmp(szWeapon, "scar20") == 0 ||
	     strcmp(szWeapon, "g3sg1") == 0 || strcmp(szWeapon, "nova") == 0 || strcmp(szWeapon, "xm1014") == 0 ||
	     strcmp(szWeapon, "mag7") == 0 || strcmp(szWeapon, "m249") == 0 || strcmp(szWeapon, "negev") == 0 ||
	     strcmp(szWeapon, "mac10") == 0 || strcmp(szWeapon, "mp9") == 0 || strcmp(szWeapon, "mp7") == 0 ||
	     strcmp(szWeapon, "ump45") == 0 || strcmp(szWeapon, "p90") == 0 || strcmp(szWeapon, "bizon") == 0))
		return Plugin_Handled;

	int iAccount = GetEntProp(client, Prop_Send, "m_iAccount");

	if (strcmp(szWeapon, "m4a1") == 0)
	{
		if (g_bUseM4A1S[client] && iAccount >= CS_GetWeaponPrice(client, CSWeapon_M4A1_SILENCER))
		{
			AddMoney(client, -CS_GetWeaponPrice(client, CSWeapon_M4A1_SILENCER), true, true, "weapon_m4a1_silencer");
			CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_m4a1_silencer");
			return Plugin_Changed;
		}
		if (IsItMyChance(5.0) && iAccount >= CS_GetWeaponPrice(client, CSWeapon_AUG))
		{
			AddMoney(client, -CS_GetWeaponPrice(client, CSWeapon_AUG), true, true, "weapon_aug");
			CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_aug");
			return Plugin_Changed;
		}
	}

	if (strcmp(szWeapon, "mac10") == 0 && IsItMyChance(40.0) && iAccount >= CS_GetWeaponPrice(client, CSWeapon_GALILAR))
	{
		AddMoney(client, -CS_GetWeaponPrice(client, CSWeapon_GALILAR), true, true, "weapon_galilar");
		CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_galilar");
		return Plugin_Changed;
	}

	if (strcmp(szWeapon, "mp9") == 0)
	{
		if (IsItMyChance(40.0) && iAccount >= CS_GetWeaponPrice(client, CSWeapon_FAMAS))
		{
			AddMoney(client, -CS_GetWeaponPrice(client, CSWeapon_FAMAS), true, true, "weapon_famas");
			CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_famas");
			return Plugin_Changed;
		}
		if (IsItMyChance(15.0) && iAccount >= CS_GetWeaponPrice(client, CSWeapon_UMP45))
		{
			AddMoney(client, -CS_GetWeaponPrice(client, CSWeapon_UMP45), true, true, "weapon_ump45");
			CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_ump45");
			return Plugin_Changed;
		}
	}

	if ((strcmp(szWeapon, "tec9") == 0 || strcmp(szWeapon, "fiveseven") == 0) && g_bUseCZ75[client])
	{
		AddMoney(client, -CS_GetWeaponPrice(client, CSWeapon_CZ75A), true, true, "weapon_cz75a");
		CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_cz75a");
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

public MRESReturn BotCOSandSIN(DHookReturn hReturn)
{
	hReturn.Value = 0;
	return MRES_Supercede;
}

public MRESReturn CCSBot_GetPartPosition(DHookReturn hReturn, DHookParam hParams)
{
	int iPlayer = hParams.Get(1);
	int iPart = hParams.Get(2);

	if (iPart != 2)
		return MRES_Ignored;

	int iBone = LookupBone(iPlayer, "head_0");
	if (iBone < 0)
		return MRES_Ignored;

	float fHead[3], fBad[3];
	GetBonePosition(iPlayer, iBone, fHead, fBad);
	fHead[2] += 4.0;

	hReturn.SetVector(fHead);
	return MRES_Override;
}

public MRESReturn CCSBot_SetLookAt(int client, DHookParam hParams)
{
	char szDesc[64];
	DHookGetParamString(hParams, 1, szDesc, sizeof(szDesc));

	if (strcmp(szDesc, "Defuse bomb") == 0 || strcmp(szDesc, "Use entity") == 0 || strcmp(szDesc, "Open door") == 0 || strcmp(szDesc, "Hostage") == 0)
		return MRES_Ignored;
	else if (strcmp(szDesc, "Avoid Flashbang") == 0)
	{
		DHookSetParam(hParams, 3, PRIORITY_HIGH);
		return MRES_ChangedHandled;
	}
	else if (strcmp(szDesc, "Blind") == 0 || strcmp(szDesc, "Face outward") == 0)
		return MRES_Supercede;
	else if (strcmp(szDesc, "Breakable") == 0 || strcmp(szDesc, "Plant bomb on floor") == 0)
	{
		g_bDontSwitch[client] = true;
		CreateTimer(5.0, Timer_EnableSwitch, GetClientUserId(client));
		return strcmp(szDesc, "Plant bomb on floor") == 0 ? MRES_Supercede : MRES_Ignored;
	}
	else if (strcmp(szDesc, "GrenadeThrowBend") == 0)
	{
		float fEyePos[3];
		GetClientEyePosition(client, fEyePos);
		hParams.GetVector(2, g_fNadeTarget[client]);
		BotBendLineOfSight(client, fEyePos, g_fNadeTarget[client], g_fNadeTarget[client], 135.0);
		hParams.SetVector(2, g_fNadeTarget[client]);
		hParams.Set(4, 8.0);
		hParams.Set(6, 1.5);
		return MRES_ChangedHandled;
	}
	else if (strcmp(szDesc, "Noise") == 0)
	{
		bool bIsWalking = !!GetEntProp(client, Prop_Send, "m_bIsWalking");
		float fClientEyes[3], fNoisePosition[3];
		GetClientEyePosition(client, fClientEyes);

		if (IsItMyChance(35.0) && IsPointVisible(fClientEyes, fNoisePosition) && LineGoesThroughSmoke(fClientEyes, fNoisePosition) && !bIsWalking)
			DHookSetParam(hParams, 7, true);

		DHookGetParamVector(hParams, 2, fNoisePosition);

		if (GetGameTime() - g_fThrowNadeTimestamp[client] > 5.0 && IsValidEntity(GetPlayerWeaponSlot(client, CS_SLOT_GRENADE)) && IsItMyChance(1.0)
			&& GetTask(client) != ESCAPE_FROM_BOMB && GetTask(client) != ESCAPE_FROM_FLAMES && GetEntityMoveType(client) != MOVETYPE_LADDER)
		{
			ProcessGrenadeThrow(client, fNoisePosition);
			return MRES_Supercede;
		}

		if (BotMimic_IsPlayerMimicing(client))
		{
			g_fNadeTimestamp[g_iDoingSmokeNum[client]] = GetGameTime();
			BotMimic_StopPlayerMimic(client);
		}

		if (eItems_GetWeaponSlotByWeapon(g_iActiveWeapon[client]) == CS_SLOT_KNIFE && GetTask(client) != ESCAPE_FROM_BOMB && GetTask(client) != ESCAPE_FROM_FLAMES)
			BotEquipBestWeapon(client, true);

		g_bDontSwitch[client] = true;
		CreateTimer(5.0, Timer_EnableSwitch, GetClientUserId(client));

		fNoisePosition[2] += 25.0;
		DHookSetParamVector(hParams, 2, fNoisePosition);
		return MRES_ChangedHandled;
	}
	else if (strcmp(szDesc, "Nearby enemy gunfire") == 0)
	{
		float fPos[3], fClientEyes[3];
		GetClientEyePosition(client, fClientEyes);
		DHookGetParamVector(hParams, 2, fPos);

		if (GetGameTime() - g_fThrowNadeTimestamp[client] > 5.0 && IsValidEntity(GetPlayerWeaponSlot(client, CS_SLOT_GRENADE)) && IsItMyChance(20.0)
			&& BotBendLineOfSight(client, fClientEyes, fPos, fPos, 135.0) && GetTask(client) != ESCAPE_FROM_BOMB && GetTask(client) != ESCAPE_FROM_FLAMES
			&& GetEntityMoveType(client) != MOVETYPE_LADDER)
		{
			ProcessGrenadeThrow(client, fPos);
			return MRES_Supercede;
		}

		fPos[2] += 25.0;
		DHookSetParamVector(hParams, 2, fPos);
		return MRES_ChangedHandled;
	}
	else
	{
		float fPos[3];
		DHookGetParamVector(hParams, 2, fPos);
		fPos[2] += 25.0;
		DHookSetParamVector(hParams, 2, fPos);
		return MRES_ChangedHandled;
	}
}

public MRESReturn CCSBot_PickNewAimSpot(int client, DHookParam hParams)
{
	if (g_bIsProBot[client])
	{
		SelectBestTargetPos(client, g_fTargetPos[client]);

		if (!IsValidClient(g_iTarget[client]) || !IsPlayerAlive(g_iTarget[client]) || g_fTargetPos[client][2] == 0)
			return MRES_Ignored;

		SetEntDataVector(client, g_iBotTargetSpotOffset, g_fTargetPos[client]);
	}
	return MRES_Ignored;
}

public Action OnPlayerRunCmd(int client, int &iButtons, int &iImpulse, float fVel[3], float fAngles[3], int &iWeapon, int &iSubtype, int &iCmdNum, int &iTickCount, int &iSeed, int iMouse[2])
{
	g_bBombPlanted = !!GameRules_GetProp("m_bBombPlanted");

	if (IsValidClient(client) && IsPlayerAlive(client) && IsFakeClient(client))
	{
		if (!g_bFreezetimeEnd && g_bDropWeapon[client] && view_as<LookAtSpotState>(GetEntData(client, g_iBotLookAtSpotStateOffset)) == LOOK_AT_SPOT)
		{
			CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY), true);
			FakeClientCommand(client, "buy %s", g_szPreviousBuy[client]);
			g_bDropWeapon[client] = false;
		}

		GetClientAbsOrigin(client, g_fBotOrigin[client]);
		g_iActiveWeapon[client] = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if (!IsValidEntity(g_iActiveWeapon[client])) return Plugin_Continue;

		if (g_bFreezetimeEnd)
		{
			int iDefIndex = GetEntProp(g_iActiveWeapon[client], Prop_Send, "m_iItemDefinitionIndex");
			float fPlayerVelocity[3], fSpeed;
			GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", fPlayerVelocity);
			fPlayerVelocity[2] = 0.0;
			fSpeed = GetVectorLength(fPlayerVelocity);

			g_pCurrArea[client] = NavMesh_GetNearestArea(g_fBotOrigin[client]);

			if ((GetAliveTeamCount(CS_TEAM_T) == 0 || GetAliveTeamCount(CS_TEAM_CT) == 0) && !g_bDontSwitch[client])
			{
				SDKCall(g_hSwitchWeaponCall, client, GetPlayerWeaponSlot(client, CS_SLOT_KNIFE), 0);
				g_bEveryoneDead = true;
			}

			if (IsItMyChance(0.2) && g_iDoingSmokeNum[client] == -1)
				g_iDoingSmokeNum[client] = GetNearestGrenade(client);

			if (GetDisposition(client) == SELF_DEFENSE)
				SetDisposition(client, ENGAGE_AND_INVESTIGATE);

			if (g_pCurrArea[client] != INVALID_NAV_AREA)
			{
				if (g_pCurrArea[client].Attributes & NAV_MESH_WALK)
					iButtons |= IN_SPEED;
				if (g_pCurrArea[client].Attributes & NAV_MESH_RUN)
					iButtons &= ~IN_SPEED;
			}

			if (g_iDoingSmokeNum[client] != -1 && !BotMimic_IsPlayerMimicing(client))
			{
				g_fNadeTimestamp[g_iDoingSmokeNum[client]] = GetGameTime();
				float fDisToNade = GetVectorDistance(g_fBotOrigin[client], g_fNadePos[g_iDoingSmokeNum[client]]);
				BotMoveTo(client, g_fNadePos[g_iDoingSmokeNum[client]], FASTEST_ROUTE);
				if (fDisToNade < 25.0)
				{
					BotSetLookAt(client, "Use entity", g_fNadeLook[g_iDoingSmokeNum[client]], PRIORITY_HIGH, 2.0, false, 3.0, false);
					if (view_as<LookAtSpotState>(GetEntData(client, g_iBotLookAtSpotStateOffset)) == LOOK_AT_SPOT && fSpeed == 0.0 && (GetEntityFlags(client) & FL_ONGROUND))
						BotMimic_PlayRecordFromFile(client, g_szReplay[g_iDoingSmokeNum[client]]);
				}
			}

			if (g_bThrowGrenade[client] && eItems_GetWeaponSlotByDefIndex(iDefIndex) == CS_SLOT_GRENADE)
			{
				BotThrowGrenade(client, g_fNadeTarget[client]);
				g_fThrowNadeTimestamp[client] = GetGameTime();
			}

			if (IsSafe(client) || g_bEveryoneDead)
				iButtons &= ~IN_SPEED;

			int iDroppedC4 = FindEntityByClassname(-1, "weapon_c4");
			if(IsValidEntity(iDroppedC4) && GetClientTeam(client) == CS_TEAM_CT)
				SetTask(client, GUARD_LOOSE_BOMB);
			
			if (g_bIsProBot[client] && !g_bBombPlanted && GetTask(client) != COLLECT_HOSTAGES && GetTask(client) != RESCUE_HOSTAGES && GetTask(client) != GUARD_LOOSE_BOMB && GetTask(client) != PLANT_BOMB && GetTask(client) != ESCAPE_FROM_FLAMES)
			{
				float fClientEyes[3];
				GetClientEyePosition(client, fClientEyes);

				int iAK47 = GetNearestEntity(client, "weapon_ak47");
				int iM4A1 = GetNearestEntity(client, "weapon_m4a1");
				int iPrimary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
				int iPrimaryDefIndex;

				if (IsValidEntity(iAK47))
				{
					iPrimaryDefIndex = IsValidEntity(iPrimary) ? GetEntProp(iPrimary, Prop_Send, "m_iItemDefinitionIndex") : 0;
					float fAK47Location[3];
					if ((iPrimaryDefIndex != 7 && iPrimaryDefIndex != 9) || iPrimary == -1)
					{
						GetEntPropVector(iAK47, Prop_Send, "m_vecOrigin", fAK47Location);
						if (GetVectorLength(fAK47Location) != 0.0 && IsPointVisible(fClientEyes, fAK47Location))
							BotMoveTo(client, fAK47Location, FASTEST_ROUTE);
					}
				}
				else if (IsValidEntity(iM4A1))
				{
					iPrimaryDefIndex = IsValidEntity(iPrimary) ? GetEntProp(iPrimary, Prop_Send, "m_iItemDefinitionIndex") : 0;
					float fM4A1Location[3];
					if (iPrimaryDefIndex != 7 && iPrimaryDefIndex != 9 && iPrimaryDefIndex != 16 && iPrimaryDefIndex != 60)
					{
						GetEntPropVector(iM4A1, Prop_Send, "m_vecOrigin", fM4A1Location);
						if (GetVectorLength(fM4A1Location) != 0.0 && IsPointVisible(fClientEyes, fM4A1Location))
						{
							BotMoveTo(client, fM4A1Location, FASTEST_ROUTE);
							if (GetVectorDistance(g_fBotOrigin[client], fM4A1Location) < 50.0 && GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) != -1)
								CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY), false);
						}
					}
					else if (iPrimary == -1)
					{
						GetEntPropVector(iM4A1, Prop_Send, "m_vecOrigin", fM4A1Location);
						if (IsPointVisible(fClientEyes, fM4A1Location))
							BotMoveTo(client, fM4A1Location, FASTEST_ROUTE);
					}
				}

				int iUSP = GetNearestEntity(client, "weapon_hkp2000");
				int iP250 = GetNearestEntity(client, "weapon_p250");
				int iFiveSeven = GetNearestEntity(client, "weapon_fiveseven");
				int iTec9 = GetNearestEntity(client, "weapon_tec9");
				int iDeagle = GetNearestEntity(client, "weapon_deagle");
				int iSecondary = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
				int iSecondaryDefIndex;

				if (IsValidEntity(iDeagle))
				{
					iSecondaryDefIndex = IsValidEntity(iSecondary) ? GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex") : 0;
					float fDeagleLocation[3];
					if (iSecondaryDefIndex == 4 || iSecondaryDefIndex == 32 || iSecondaryDefIndex == 61 || iSecondaryDefIndex == 36 || iSecondaryDefIndex == 30 || iSecondaryDefIndex == 3 || iSecondaryDefIndex == 63)
					{
						GetEntPropVector(iDeagle, Prop_Send, "m_vecOrigin", fDeagleLocation);
						if (GetVectorLength(fDeagleLocation) != 0.0 && IsPointVisible(fClientEyes, fDeagleLocation))
						{
							BotMoveTo(client, fDeagleLocation, FASTEST_ROUTE);
							if (GetVectorDistance(g_fBotOrigin[client], fDeagleLocation) < 50.0 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
								CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false);
						}
					}
				}
				else if (IsValidEntity(iTec9))
				{
					iSecondaryDefIndex = IsValidEntity(iSecondary) ? GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex") : 0;
					float fTec9Location[3];
					if (iSecondaryDefIndex == 4 || iSecondaryDefIndex == 32 || iSecondaryDefIndex == 61 || iSecondaryDefIndex == 36)
					{
						GetEntPropVector(iTec9, Prop_Send, "m_vecOrigin", fTec9Location);
						if (GetVectorLength(fTec9Location) != 0.0 && IsPointVisible(fClientEyes, fTec9Location))
						{
							BotMoveTo(client, fTec9Location, FASTEST_ROUTE);
							if (GetVectorDistance(g_fBotOrigin[client], fTec9Location) < 50.0 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
								CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false);
						}
					}
				}
				else if (IsValidEntity(iFiveSeven))
				{
					iSecondaryDefIndex = IsValidEntity(iSecondary) ? GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex") : 0;
					float fFiveSevenLocation[3];
					if (iSecondaryDefIndex == 4 || iSecondaryDefIndex == 32 || iSecondaryDefIndex == 61 || iSecondaryDefIndex == 36)
					{
						GetEntPropVector(iFiveSeven, Prop_Send, "m_vecOrigin", fFiveSevenLocation);
						if (GetVectorLength(fFiveSevenLocation) != 0.0 && IsPointVisible(fClientEyes, fFiveSevenLocation))
						{
							BotMoveTo(client, fFiveSevenLocation, FASTEST_ROUTE);
							if (GetVectorDistance(g_fBotOrigin[client], fFiveSevenLocation) < 50.0 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
								CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false);
						}
					}
				}
				else if (IsValidEntity(iP250))
				{
					iSecondaryDefIndex = IsValidEntity(iSecondary) ? GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex") : 0;
					float fP250Location[3];
					if (iSecondaryDefIndex == 4 || iSecondaryDefIndex == 32 || iSecondaryDefIndex == 61)
					{
						GetEntPropVector(iP250, Prop_Send, "m_vecOrigin", fP250Location);
						if (GetVectorLength(fP250Location) != 0.0 && IsPointVisible(fClientEyes, fP250Location))
						{
							BotMoveTo(client, fP250Location, FASTEST_ROUTE);
							if (GetVectorDistance(g_fBotOrigin[client], fP250Location) < 50.0 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
								CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false);
						}
					}
				}
				else if (IsValidEntity(iUSP))
				{
					iSecondaryDefIndex = IsValidEntity(iSecondary) ? GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex") : 0;
					float fUSPLocation[3];
					if (iSecondaryDefIndex == 4)
					{
						GetEntPropVector(iUSP, Prop_Send, "m_vecOrigin", fUSPLocation);
						if (GetVectorLength(fUSPLocation) != 0.0 && IsPointVisible(fClientEyes, fUSPLocation))
						{
							BotMoveTo(client, fUSPLocation, FASTEST_ROUTE);
							if (GetVectorDistance(g_fBotOrigin[client], fUSPLocation) < 50.0 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
								CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false);
						}
					}
				}
			}

			if (g_bIsProBot[client] && GetDisposition(client) != IGNORE_ENEMIES)
			{
				g_iTarget[client] = BotGetEnemy(client);

				float fTargetDistance;
				int iZoomLevel;
				bool bIsEnemyVisible = !!GetEntData(client, g_iEnemyVisibleOffset);
				bool bIsHiding = BotIsHiding(client);
				bool bIsDucking = !!(GetEntityFlags(client) & FL_DUCKING);
				bool bIsReloading = IsPlayerReloading(client);
				bool bResumeZoom = !!GetEntProp(client, Prop_Send, "m_bResumeZoom");

				if (bResumeZoom)
					g_fShootTimestamp[client] = GetGameTime();

				if (HasEntProp(g_iActiveWeapon[client], Prop_Send, "m_zoomLevel"))
					iZoomLevel = GetEntProp(g_iActiveWeapon[client], Prop_Send, "m_zoomLevel");

				if (bIsHiding && (iDefIndex == 8 || iDefIndex == 39) && iZoomLevel == 0)
					iButtons |= IN_ATTACK2;
				else if (!bIsHiding && (iDefIndex == 8 || iDefIndex == 39) && iZoomLevel == 1)
					iButtons |= IN_ATTACK2;

				if (bIsHiding && g_bUncrouch[client])
					iButtons &= ~IN_DUCK;

				if (!IsValidClient(g_iTarget[client]) || !IsPlayerAlive(g_iTarget[client]) || g_fTargetPos[client][2] == 0)
				{
					g_iPrevTarget[client] = g_iTarget[client];
					return Plugin_Continue;
				}

				if (BotMimic_IsPlayerMimicing(client))
				{
					g_fNadeTimestamp[g_iDoingSmokeNum[client]] = GetGameTime();
					BotMimic_StopPlayerMimic(client);
				}

				if ((eItems_GetWeaponSlotByDefIndex(iDefIndex) == CS_SLOT_KNIFE || eItems_GetWeaponSlotByDefIndex(iDefIndex) == CS_SLOT_GRENADE) && GetTask(client) != ESCAPE_FROM_BOMB && GetTask(client) != ESCAPE_FROM_FLAMES)
					BotEquipBestWeapon(client, true);

				if (bIsEnemyVisible && GetEntityMoveType(client) != MOVETYPE_LADDER)
				{
					if (g_iPrevTarget[client] == -1)
						g_fCrouchTimestamp[client] = GetGameTime() + Math_GetRandomFloat(0.23, 0.25);
					fTargetDistance = GetVectorDistance(g_fBotOrigin[client], g_fTargetPos[client]);

					float fClientEyes[3], fClientAngles[3], fAimPunchAngle[3], fToAimSpot[3], fAimDir[3];
					GetClientEyePosition(client, fClientEyes);
					SubtractVectors(g_fTargetPos[client], fClientEyes, fToAimSpot);
					GetClientEyeAngles(client, fClientAngles);
					GetEntPropVector(client, Prop_Send, "m_aimPunchAngle", fAimPunchAngle);
					ScaleVector(fAimPunchAngle, (FindConVar("weapon_recoil_scale").FloatValue));
					AddVectors(fClientAngles, fAimPunchAngle, fClientAngles);
					GetViewVector(fClientAngles, fAimDir);

					float fRangeToEnemy = NormalizeVector(fToAimSpot, fToAimSpot);
					float fOnTarget = GetVectorDotProduct(fToAimSpot, fAimDir);
					float fAimTolerance = Cosine(ArcTangent(32.0 / fRangeToEnemy));

					if (g_iPrevTarget[client] == -1 && fOnTarget > fAimTolerance)
						g_fCrouchTimestamp[client] = GetGameTime() + Math_GetRandomFloat(0.23, 0.25);

					switch (iDefIndex)
					{
						case 7, 8, 10, 13, 14, 16, 17, 19, 23, 24, 25, 26, 28, 33, 34, 39, 60:
						{
							if (fOnTarget > fAimTolerance && !bIsDucking && fTargetDistance < 2000.0 && iDefIndex != 17 && iDefIndex != 19 && iDefIndex != 23 && iDefIndex != 24 && iDefIndex != 25 && iDefIndex != 26 && iDefIndex != 33 && iDefIndex != 34)
								AutoStop(client, fVel, fAngles);
							else if (fTargetDistance > 2000.0 && GetEntDataFloat(client, g_iFireWeaponOffset) == GetGameTime())
								AutoStop(client, fVel, fAngles);
							if (fOnTarget > fAimTolerance && fTargetDistance < 2000.0)
							{
								iButtons &= ~IN_ATTACK;
								if (!bIsReloading && (fSpeed < 50.0 || bIsDucking || iDefIndex == 17 || iDefIndex == 19 || iDefIndex == 23 || iDefIndex == 24 || iDefIndex == 25 || iDefIndex == 26 || iDefIndex == 33 || iDefIndex == 34))
								{
									iButtons |= IN_ATTACK;
									SetEntDataFloat(client, g_iFireWeaponOffset, GetGameTime());
								}
							}
						}
						case 1:
						{
							if (GetGameTime() - GetEntDataFloat(client, g_iFireWeaponOffset) < 0.15 && !bIsDucking && !bIsReloading)
								AutoStop(client, fVel, fAngles);
						}
						case 9, 40:
						{
							if (fTargetDistance < 2750.0 && !bIsReloading && GetEntProp(client, Prop_Send, "m_bIsScoped") && GetGameTime() - g_fShootTimestamp[client] > 0.4 && GetClientAimTarget(client, true) == g_iTarget[client])
							{
								iButtons |= IN_ATTACK;
								SetEntDataFloat(client, g_iFireWeaponOffset, GetGameTime());
							}
						}
					}

					float fClientLoc[3];
					Array_Copy(g_fBotOrigin[client], fClientLoc, 3);
					fClientLoc[2] += HalfHumanHeight;
					if (GetGameTime() >= g_fCrouchTimestamp[client] && !GetEntProp(g_iActiveWeapon[client], Prop_Data, "m_bInReload") && IsPointVisible(fClientLoc, g_fTargetPos[client]) && fOnTarget > fAimTolerance && fTargetDistance < 2000.0 && (iDefIndex == 7 || iDefIndex == 8 || iDefIndex == 10 || iDefIndex == 13 || iDefIndex == 14 || iDefIndex == 16 || iDefIndex == 39 || iDefIndex == 60 || iDefIndex == 28))
						iButtons |= IN_DUCK;

					g_iPrevTarget[client] = g_iTarget[client];
				}
			}
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}

public void OnPlayerSpawn(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(eEvent.GetInt("userid"));
	SetPlayerTeammateColor(client);

	if (IsValidClient(client) && IsFakeClient(client))
	{
		if (g_bIsProBot[client])
		{
			Address pLocalProfile = view_as<Address>(GetEntData(client, g_iBotProfileOffset));
			//All these offsets are inside BotProfileManager::Init which has strings for every botprofile parameter
			StoreToAddress(pLocalProfile + view_as<Address>(104), view_as<int>(g_fLookAngleMaxAccel[client]), NumberType_Int32);
			StoreToAddress(pLocalProfile + view_as<Address>(116), view_as<int>(g_fLookAngleMaxAccel[client]), NumberType_Int32);
			StoreToAddress(pLocalProfile + view_as<Address>(84), view_as<int>(g_fReactionTime[client]), NumberType_Int32);
			StoreToAddress(pLocalProfile + view_as<Address>(4), view_as<int>(g_fAggression[client]), NumberType_Int32);
		}

		if (g_bUseUSP[client] && GetClientTeam(client) == CS_TEAM_CT)
		{
			char szUSP[32];
			GetClientWeapon(client, szUSP, sizeof(szUSP));
			if (strcmp(szUSP, "weapon_hkp2000") == 0)
				CSGO_ReplaceWeapon(client, CS_SLOT_SECONDARY, "weapon_usp_silencer");
		}
	}
}

public void BotMimic_OnPlayerStopsMimicing(int client, char[] szName, char[] szCategory, char[] szPath)
{
	g_iDoingSmokeNum[client] = -1;
}

public void OnClientDisconnect(int client)
{
	if (IsValidClient(client) && IsFakeClient(client))
		g_iProfileRank[client] = 0;
}

public void eItems_OnItemsSynced()
{
	ServerCommand("changelevel %s", g_szMap);
}

void ParseMapNades(const char[] szMap)
{
	char szPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, szPath, sizeof(szPath), "configs/bot_nades.txt");
	
	if (!FileExists(szPath))
	{
		PrintToServer("Configuration file %s is not found.", szPath);
		return;
	}
	
	KeyValues kv = new KeyValues("Nades");
	
	if (!kv.ImportFromFile(szPath))
	{
		delete kv;
		PrintToServer("Unable to parse Key Values file %s.", szPath);
		return;
	}
	
	if (!kv.JumpToKey(szMap))
	{
		delete kv;
		PrintToServer("No nades found for %s.", szMap);
		return;
	}
	
	if (!kv.GotoFirstSubKey())
	{
		delete kv;
		PrintToServer("Nades are not configured right for %s.", szMap);
		return;
	}
	
	int i = 0;
	do
	{
		char szTeam[4];
		
		kv.GetVector("position", g_fNadePos[i]);
		kv.GetVector("lookat", g_fNadeLook[i]);
		g_iNadeDefIndex[i] = kv.GetNum("nadedefindex");
		kv.GetString("replay", g_szReplay[i], 128);
		g_fNadeTimestamp[i] = kv.GetFloat("timestamp");
		kv.GetString("team", szTeam, sizeof(szTeam));
		
		if (strcmp(szTeam, "CT", false) == 0)
			g_iNadeTeam[i] = CS_TEAM_CT;
		else if (strcmp(szTeam, "T", false) == 0)
			g_iNadeTeam[i] = CS_TEAM_T;
	
		i++;
	}
	while (kv.GotoNextKey());
	
	delete kv;
	g_iMaxNades = i;
}

bool IsProBot(const char[] szName, char[] szCrosshairCode, int iSize)
{
	char szPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, szPath, sizeof(szPath), "data/bot_info.json");
	
	if (!FileExists(szPath))
	{
		PrintToServer("Configuration file %s is not found.", szPath);
		return false;
	}
	
	JSONObject jData = JSONObject.FromFile(szPath);
	if (jData.HasKey(szName))
	{
		JSONObject jInfoObj = view_as<JSONObject>(jData.Get(szName));
		jInfoObj.GetString("crosshair_code", szCrosshairCode, iSize);
		
		delete jInfoObj;
		delete jData;
		return true;
	}
	
	delete jData;
	return false;
}

public void LoadSDK()
{
	GameData hGameConfig = new GameData("botstuff.games");
	if (hGameConfig == null)
		SetFailState("Failed to find botstuff.games game config.");

	g_pTheBots = SetupAddress(hGameConfig, "TheBots");
	g_iBotTargetSpotOffset = SetupOffset(hGameConfig, "CCSBot::m_targetSpot");
	g_iBotNearbyEnemiesOffset = SetupOffset(hGameConfig, "CCSBot::m_nearbyEnemyCount");
	g_iFireWeaponOffset = SetupOffset(hGameConfig, "CCSBot::m_fireWeaponTimestamp");
	g_iEnemyVisibleOffset = SetupOffset(hGameConfig, "CCSBot::m_isEnemyVisible");
	g_iBotProfileOffset = SetupOffset(hGameConfig, "CCSBot::m_pLocalProfile");
	g_iBotSafeTimeOffset = SetupOffset(hGameConfig, "CCSBot::m_safeTime");
	g_iBotEnemyOffset = SetupOffset(hGameConfig, "CCSBot::m_enemy");
	g_iBotLookAtSpotStateOffset = SetupOffset(hGameConfig, "CCSBot::m_lookAtSpotState");
	g_iBotMoraleOffset = SetupOffset(hGameConfig, "CCSBot::m_morale");
	g_iBotTaskOffset = SetupOffset(hGameConfig, "CCSBot::m_task");
	g_iBotDispositionOffset = SetupOffset(hGameConfig, "CCSBot::m_disposition");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::MoveTo");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	if ((g_hBotMoveTo = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for CCSBot::MoveTo signature!");

	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CBaseAnimating::LookupBone");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if ((g_hLookupBone = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for CBaseAnimating::LookupBone signature!");

	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CBaseAnimating::GetBonePosition");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	PrepSDKCall_AddParameter(SDKType_QAngle, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	if ((g_hGetBonePosition = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for CBaseAnimating::GetBonePosition signature!");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::IsVisible");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer, VDECODE_FLAG_ALLOWNULL);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hBotIsVisible = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for CCSBot::IsVisible signature!");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::IsAtHidingSpot");
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hBotIsHiding = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for CCSBot::IsAtHidingSpot signature!");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::EquipBestWeapon");
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	if ((g_hBotEquipBestWeapon = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for CCSBot::EquipBestWeapon signature!");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::SetLookAt");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	if ((g_hBotSetLookAt = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for CCSBot::SetLookAt signature!");

	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "SetCrosshairCode");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	if ((g_hSetCrosshairCode = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for SetCrosshairCode signature!");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Virtual, "Weapon_Switch");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer, VDECODE_FLAG_ALLOWNULL);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	if ((g_hSwitchWeaponCall = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for Weapon_Switch offset!");

	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CBotManager::IsLineBlockedBySmoke");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hIsLineBlockedBySmoke = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for CBotManager::IsLineBlockedBySmoke offset!");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::BendLineOfSight");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hBotBendLineOfSight = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for CCSBot::BendLineOfSight signature!");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::ThrowGrenade");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	if ((g_hBotThrowGrenade = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for CCSBot::ThrowGrenade signature!");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSPlayer::AddAccount");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	if ((g_hAddMoney = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall for CCSPlayer::AddAccount signature!");

	delete hGameConfig;
}

public void LoadDetours()
{
	GameData hGameData = new GameData("botstuff.games");
	if (hGameData == null)
	{
		SetFailState("Failed to load botstuff gamedata.");
		return;
	}

	SetupDetour(hGameData, "CCSBot::SetLookAt", Hook_Pre, CCSBot_SetLookAt);
	SetupDetour(hGameData, "CCSBot::PickNewAimSpot", Hook_Post, CCSBot_PickNewAimSpot);
	SetupDetour(hGameData, "BotCOS", Hook_Pre, BotCOSandSIN);
	SetupDetour(hGameData, "BotSIN", Hook_Pre, BotCOSandSIN);
	SetupDetour(hGameData, "CCSBot::GetPartPosition", Hook_Pre, CCSBot_GetPartPosition);

	delete hGameData;
}

public int LookupBone(int iEntity, const char[] szName)
{
	return SDKCall(g_hLookupBone, iEntity, szName);
}

public void GetBonePosition(int iEntity, int iBone, float fOrigin[3], float fAngles[3])
{
	SDKCall(g_hGetBonePosition, iEntity, iBone, fOrigin, fAngles);
}

public void BotMoveTo(int client, float fOrigin[3], RouteType routeType)
{
	SDKCall(g_hBotMoveTo, client, fOrigin, routeType);
}

bool BotIsVisible(int client, float fPos[3], bool bTestFOV, int iIgnore = -1)
{
	return SDKCall(g_hBotIsVisible, client, fPos, bTestFOV, iIgnore);
}

public bool BotIsHiding(int client)
{
	return SDKCall(g_hBotIsHiding, client);
}

public void BotEquipBestWeapon(int client, bool bMustEquip)
{
	SDKCall(g_hBotEquipBestWeapon, client, bMustEquip);
}

public void BotSetLookAt(int client, const char[] szDesc, const float fPos[3], PriorityType pri, float fDuration, bool bClearIfClose, float fAngleTolerance, bool bAttack)
{
	SDKCall(g_hBotSetLookAt, client, szDesc, fPos, pri, fDuration, bClearIfClose, fAngleTolerance, bAttack);
}

public bool BotBendLineOfSight(int client, const float fEye[3], const float fTarget[3], float fBend[3], float fAngleLimit)
{
	return SDKCall(g_hBotBendLineOfSight, client, fEye, fTarget, fBend, fAngleLimit);
}

public void BotThrowGrenade(int client, const float fTarget[3])
{
	SDKCall(g_hBotThrowGrenade, client, fTarget);
}

public int BotGetEnemy(int client)
{
	return GetEntDataEnt2(client, g_iBotEnemyOffset);
}

public void SetCrosshairCode(Address pCCSPlayerResource, int client, const char[] szCode)
{
	SDKCall(g_hSetCrosshairCode, pCCSPlayerResource, client, szCode);
}

public void AddMoney(int client, int iAmount, bool bTrackChange, bool bItemBought, const char[] szItemName)
{
	SDKCall(g_hAddMoney, client, iAmount, bTrackChange, bItemBought, szItemName);
}

bool IsDefaultPistol(const char[] szWeapon)
{
	return strcmp(szWeapon, "weapon_hkp2000") == 0 || strcmp(szWeapon, "weapon_usp_silencer") == 0 || strcmp(szWeapon, "weapon_glock") == 0;
}

public int Sort_BotMoneyDesc(int iIndex1, int iIndex2, Handle hArray, Handle hHndl)
{
    int iEntry1[2], iEntry2[2];
    GetArrayArray(hArray, iIndex1, iEntry1, sizeof(iEntry1));
    GetArrayArray(hArray, iIndex2, iEntry2, sizeof(iEntry2));

    if (iEntry1[1] > iEntry2[1]) return -1;
    if (iEntry1[1] < iEntry2[1]) return 1;
    return 0;
}

bool IsTopBot(const char[] szName)
{
    for (int i = 0; i < sizeof(g_szTopBotNames); i++)
    {
        if (strcmp(szName, g_szTopBotNames[i]) == 0)
            return true;
    }
    return false;
}

stock void SetupDetour(GameData hGameData, const char[] szConf, HookMode hMode, DHookCallback hCallback)
{
	DynamicDetour hDetour = DynamicDetour.FromConf(hGameData, szConf);
	if (!hDetour.Enable(hMode, hCallback))
		SetFailState("Failed to setup detour for %s", szConf);
}

stock int SetupOffset(GameData hGameConfig, const char[] szName)
{
	int iOffset = hGameConfig.GetOffset(szName);
	if (iOffset == -1)
		SetFailState("Failed to get %s offset.", szName);
	return iOffset;
}

stock Address SetupAddress(GameData hGameConfig, const char[] szName)
{
	Address pAddr = hGameConfig.GetAddress(szName);
	if (!pAddr)
		SetFailState("Failed to get %s address.", szName);
	return pAddr;
}

int GetFriendsWithPrimary(int client)
{
	int iCount = 0, iPrimary;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i))
			continue;
		
		if (client == i)
			continue;
		
		if (GetClientTeam(i) != GetClientTeam(client))
			continue;
		
		iPrimary = GetPlayerWeaponSlot(i, CS_SLOT_PRIMARY);
		if (IsValidEntity(iPrimary))
			iCount++;
	}
	
	return iCount;
}

public int GetNearestGrenade(int client)
{
	if (g_bBombPlanted)
		return -1;

	int iNearestEntity = -1;
	float fVecOrigin[3], fDistance, fNearestDistance = -1.0;
	
	GetClientAbsOrigin(client, fVecOrigin);
	
	for (int i = 0; i < g_iMaxNades; i++)
	{
		if ((GetGameTime() - g_fNadeTimestamp[i]) < 25.0)
			continue;
		
		if (!IsValidEntity(eItems_FindWeaponByDefIndex(client, g_iNadeDefIndex[i])))
			continue;
		
		if (GetClientTeam(client) != g_iNadeTeam[i])
			continue;
		
		fDistance = GetVectorDistance(fVecOrigin, g_fNadePos[i]);
		
		if (fDistance > 250.0)
			continue;
		
		if (fDistance < fNearestDistance || fNearestDistance == -1.0)
		{
			iNearestEntity = i;
			fNearestDistance = fDistance;
		}
	}
	
	return iNearestEntity;
}

stock int GetNearestEntity(int client, char[] szClassname)
{
	int iNearestEntity = -1, iEntity = -1;
	float fClientOrigin[3], fEntityOrigin[3], fDistance, fNearestDistance = -1.0;
	
	GetClientAbsOrigin(client, fClientOrigin);
	
	while ((iEntity = FindEntityByClassname(iEntity, szClassname)) != -1)
	{
		GetEntPropVector(iEntity, Prop_Data, "m_vecOrigin", fEntityOrigin);
		fDistance = GetVectorDistance(fClientOrigin, fEntityOrigin);
		
		if (fDistance < fNearestDistance || fNearestDistance == -1.0)
		{
			iNearestEntity = iEntity;
			fNearestDistance = fDistance;
		}
	}
	
	return iNearestEntity;
}

stock int CSGO_ReplaceWeapon(int client, int iSlot, const char[] szClass)
{
	int iWeapon = GetPlayerWeaponSlot(client, iSlot);
	
	if (IsValidEntity(iWeapon))
	{
		if (GetEntPropEnt(iWeapon, Prop_Send, "m_hOwnerEntity") != client)
			SetEntPropEnt(iWeapon, Prop_Send, "m_hOwnerEntity", client);
		
		CS_DropWeapon(client, iWeapon, false, true);
		AcceptEntityInput(iWeapon, "Kill");
	}
	
	iWeapon = GivePlayerItem(client, szClass);
	
	if (IsValidEntity(iWeapon))
		EquipPlayerWeapon(client, iWeapon);
	
	return iWeapon;
}

bool IsPlayerReloading(int client)
{
	if (!IsValidEntity(g_iActiveWeapon[client]))
		return false;
	
	if (GetEntProp(g_iActiveWeapon[client], Prop_Data, "m_iClip1") == 0)
		return true;
	
	if (GetEntProp(g_iActiveWeapon[client], Prop_Data, "m_bInReload"))
		return true;
	
	if (GetEntPropFloat(g_iActiveWeapon[client], Prop_Send, "m_flNextPrimaryAttack") <= GetGameTime())
		return false;
	
	return true;
}

public void BeginQuickSwitch(int client)
{
	client = GetClientOfUserId(client);
	
	if(client != 0 && IsClientInGame(client))
	{
		SDKCall(g_hSwitchWeaponCall, client, GetPlayerWeaponSlot(client, CS_SLOT_KNIFE), 0);
		RequestFrame(FinishQuickSwitch, GetClientUserId(client));
	}
}

public void FinishQuickSwitch(int client)
{
	client = GetClientOfUserId(client);
	
	if(client != 0 && IsClientInGame(client))
		SDKCall(g_hSwitchWeaponCall, client, GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY), 0);
}

public Action Timer_EnableSwitch(Handle hTimer, any client)
{
	client = GetClientOfUserId(client);
	
	if(client != 0 && IsClientInGame(client))
		g_bDontSwitch[client] = false;	
	
	return Plugin_Stop;
}

public Action Timer_DontForceThrow(Handle hTimer, any client)
{
	client = GetClientOfUserId(client);
	
	if(client != 0 && IsClientInGame(client))
	{
		g_bThrowGrenade[client] = false;
		BotEquipBestWeapon(client, true);
	}
	
	return Plugin_Stop;
}

public void DelayThrow(any client)
{
	client = GetClientOfUserId(client);
	
	if(client != 0 && IsClientInGame(client))
	{
		g_bThrowGrenade[client] = true;
		CreateTimer(3.0, Timer_DontForceThrow, GetClientUserId(client));
	}
}

public void SelectBestTargetPos(int client, float fTargetPos[3])
{
	if(IsValidClient(g_iTarget[client]) && IsPlayerAlive(g_iTarget[client]))
	{
		int iBone = LookupBone(g_iTarget[client], "head_0");
		int iSpineBone = LookupBone(g_iTarget[client], "spine_3");
		if (iBone < 0 || iSpineBone < 0)
			return;
		
		bool bShootSpine;
		float fHead[3], fBody[3], fBad[3];
		GetBonePosition(g_iTarget[client], iBone, fHead, fBad);
		GetBonePosition(g_iTarget[client], iSpineBone, fBody, fBad);
		
		fHead[2] += 4.0;
		
		if (BotIsVisible(client, fHead, false, -1))
		{
			if (BotIsVisible(client, fBody, false, -1))
			{
				if (!IsValidEntity(g_iActiveWeapon[client])) return;
				
				int iDefIndex = GetEntProp(g_iActiveWeapon[client], Prop_Send, "m_iItemDefinitionIndex");
				
				switch(iDefIndex)
				{
					case 7, 8, 10, 13, 14, 16, 17, 19, 23, 24, 25, 26, 27, 28, 29, 33, 34, 35, 39, 60:
					{
						float fTargetDistance = GetVectorDistance(g_fBotOrigin[client], fHead);
						if (IsItMyChance(70.0) && fTargetDistance < 2000.0)
							bShootSpine = true;
					}
					case 9, 11, 38:
					{
						bShootSpine = true;
					}
				}
			}
		}
		else
		{
			//Head wasn't visible, check other bones.
			for (int b = 0; b <= sizeof(g_szBoneNames) - 1; b++)
			{
				iBone = LookupBone(g_iTarget[client], g_szBoneNames[b]);
				if (iBone < 0)
					return;
				
				GetBonePosition(g_iTarget[client], iBone, fHead, fBad);
				
				if (BotIsVisible(client, fHead, false, -1))
					break;
				else
					fHead[2] = 0.0;
			}
		}
		
		if(bShootSpine)
			fTargetPos = fBody;
		else
			fTargetPos = fHead;
	}
}

stock void GetViewVector(float fVecAngle[3], float fOutPut[3])
{
	fOutPut[0] = Cosine(fVecAngle[1] / (180 / FLOAT_PI));
	fOutPut[1] = Sine(fVecAngle[1] / (180 / FLOAT_PI));
	fOutPut[2] = -Sine(fVecAngle[0] / (180 / FLOAT_PI));
}

stock float AngleNormalize(float fAngle)
{
	fAngle -= RoundToFloor(fAngle / 360.0) * 360.0;
	
	if (fAngle > 180)
		fAngle -= 360;
	
	if (fAngle < -180)
		fAngle += 360;

	return fAngle;
}

stock bool IsPointVisible(float fStart[3], float fEnd[3])
{
	TR_TraceRayFilter(fStart, fEnd, MASK_VISIBLE_AND_NPCS, RayType_EndPoint, TraceEntityFilterStuff);
	return TR_GetFraction() >= 0.9;
}

public bool TraceEntityFilterStuff(int iEntity, int iMask)
{
	return iEntity > MaxClients;
} 

public void ProcessGrenadeThrow(int client, float fTarget[3])
{
	NavMesh_GetGroundHeight(fTarget, fTarget[2]);
	if(!GetGrenadeToss(client, fTarget))
		return;
	
	Array_Copy(fTarget, g_fNadeTarget[client], 3);
	SDKCall(g_hSwitchWeaponCall, client, GetPlayerWeaponSlot(client, CS_SLOT_GRENADE), 0);
	RequestFrame(DelayThrow, GetClientUserId(client));
}

stock bool GetGrenadeToss(int client, float fTossTarget[3])
{
	float fEyePosition[3], fTo[3];
	GetClientEyePosition(client, fEyePosition);
	SubtractVectors(fTossTarget, fEyePosition, fTo);
	float fRange = GetVectorLength(fTo);

	const float fSlope = 0.2; // 0.25f;
	float fTossHeight = fSlope * fRange;

	float fHeightInc = fTossHeight / 10.0;
	float fTarget[3];
	float fSafeSpace = fTossHeight / 2.0;

	// Build a box to sweep along the ray when looking for obstacles
	float fMins[3] = { -16.0, -16.0, 0.0 };
	float fMaxs[3] = { 16.0, 16.0, 72.0 };
	fMins[2] = 0.0;
	fMaxs[2] = fHeightInc;


	// find low and high bounds of toss window
	float fLow = 0.0;
	float fHigh = fTossHeight + fSafeSpace;
	bool bGotLow = false;
	float fLastH = 0.0;
	for(float h = 0.0; h < 3.0 * fTossHeight; h += fHeightInc)
	{
		fTarget[0] = fTossTarget[0];
		fTarget[1] = fTossTarget[1];
		fTarget[2] = fTossTarget[2] + h;

		// make sure toss line is clear
		Handle hTraceResult = TR_TraceHullFilterEx(fEyePosition, fTarget, fMins, fMins, MASK_VISIBLE_AND_NPCS | CONTENTS_GRATE, TraceEntityFilterStuff);
		
		if (TR_GetFraction(hTraceResult) == 1.0)
		{
			// line is clear
			if (!bGotLow)
			{
				fLow = h;
				bGotLow = true;
			}
		}
		else
		{
			// line is blocked
			if (bGotLow)
			{
				fHigh = fLastH;
				break;
			}
		}

		fLastH = h;
		
		delete hTraceResult;
	}

	if (bGotLow)
	{
		// throw grenade into toss window
		if (fTossHeight < fLow)
		{
			if (fLow + fSafeSpace > fHigh)
				// narrow window
				fTossHeight = (fHigh + fLow)/2.0;
			else
				fTossHeight = fLow + fSafeSpace;
		}
		else if (fTossHeight > fHigh - fSafeSpace)
		{
			if (fHigh - fSafeSpace < fLow)
				// narrow window
				fTossHeight = (fHigh + fLow)/2.0;
			else
				fTossHeight = fHigh - fSafeSpace;
		}
		
		fTossTarget[2] += fTossHeight;
		return true;
	}
	
	return false;
}

stock bool LineGoesThroughSmoke(float fFrom[3], float fTo[3])
{	
	return SDKCall(g_hIsLineBlockedBySmoke, g_pTheBots, fFrom, fTo);
} 

stock int GetAliveTeamCount(int iTeam)
{
	int iNumber = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == iTeam)
			iNumber++;
	}
	return iNumber;
}

stock bool IsSafe(int client)
{
	if(!IsFakeClient(client))
		return false;
	
	if((GetGameTime() - g_fFreezeTimeEnd) < GetEntDataFloat(client, g_iBotSafeTimeOffset))
		return true;
	
	return false;
}

stock TaskType GetTask(int client)
{
	if(!IsFakeClient(client))
		return view_as<TaskType>(-1);
		
	return view_as<TaskType>(GetEntData(client, g_iBotTaskOffset));
}

stock void SetTask(int client, TaskType iTask)
{
	if(!IsFakeClient(client))
		return;
		
	SetEntData(client, g_iBotTaskOffset, iTask);
}

stock DispositionType GetDisposition(int client)
{
	if(!IsFakeClient(client))
		return view_as<DispositionType>(-1);
		
	return view_as<DispositionType>(GetEntData(client, g_iBotDispositionOffset));
}

stock void SetDisposition(int client, DispositionType iDisposition)
{
	if(!IsFakeClient(client))
		return;
		
	SetEntData(client, g_iBotDispositionOffset, iDisposition);
}

stock void SetPlayerTeammateColor(int client)
{
	if(GetClientTeam(client) > CS_TEAM_SPECTATOR)
	{
		if(g_iPlayerColor[client] > -1)
			return;
		
		int nAssignedColor;
		bool bColorInUse = false;
		for (int ii = 0; ii < 5; ii++ )
		{
			nAssignedColor = nAssignedColor % 5;

			bColorInUse = false;
			for ( int j = 1; j <= MaxClients; j++ )
			{
				if (IsValidClient(j) && GetClientTeam(j) == GetClientTeam(client))
				{
					if (nAssignedColor == g_iPlayerColor[j] && j != client)
					{
						bColorInUse = true;
						nAssignedColor++;
						break;
					}
				}
			}

			if (bColorInUse == false )
				break;
		}
		nAssignedColor = bColorInUse == false ? nAssignedColor : -1;
		g_iPlayerColor[client] = nAssignedColor;
	}
}

public void AutoStop(int client, float fVel[3], float fAngles[3])
{
	float fPlayerVelocity[3], fVelAngle[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", fPlayerVelocity);
	GetVectorAngles(fPlayerVelocity, fVelAngle);
	float fSpeed = GetVectorLength(fPlayerVelocity);
	
	if(fSpeed < 1.0)
		return;
	
	fVelAngle[1] = fAngles[1] - fVelAngle[1];
	
	float fNegatedDirection[3], fForwardDirection[3];
	GetAngleVectors(fVelAngle, fForwardDirection, NULL_VECTOR, NULL_VECTOR);
	
	fNegatedDirection[0] = fForwardDirection[0] * (-fSpeed);
	fNegatedDirection[1] = fForwardDirection[1] * (-fSpeed);
	fNegatedDirection[2] = fForwardDirection[2] * (-fSpeed);
	
	fVel[0] = fNegatedDirection[0];
	fVel[1] = fNegatedDirection[1];
}

stock bool ShouldForce()
{
	int iOvertimePlaying = GameRules_GetProp("m_nOvertimePlaying");
	GamePhase pGamePhase = view_as<GamePhase>(GameRules_GetProp("m_gamePhase"));

	if (FindConVar("mp_halftime").BoolValue)
	{
		int iRoundsBeforeHalftime = -1;
		if (pGamePhase == GAMEPHASE_PLAYING_FIRST_HALF)
			iRoundsBeforeHalftime = iOvertimePlaying ? ( FindConVar("mp_maxrounds").IntValue + ( 2 * iOvertimePlaying - 1 ) * ( FindConVar("mp_overtime_maxrounds").IntValue / 2 ) ) : ( FindConVar("mp_maxrounds").IntValue / 2 );

		if ((iRoundsBeforeHalftime > 0) && (g_iRoundsPlayed == (iRoundsBeforeHalftime-1)))
		{
			g_bHalftimeSwitch = true;
			return true;
		}
	}
	
	int iNumWinsToClinch = GetNumWinsToClinch();
	bool bMatchPoint = false;
	if (pGamePhase != GAMEPHASE_PLAYING_FIRST_HALF)
		bMatchPoint = (g_iCTScore == iNumWinsToClinch-1 || g_iTScore == iNumWinsToClinch-1);
	if(bMatchPoint)
		return true;
	
	bool bLastRound = FindConVar("mp_maxrounds").IntValue > 0 ? (g_iCurrentRound == (FindConVar("mp_maxrounds").IntValue-1 + iOvertimePlaying * FindConVar("mp_overtime_maxrounds").IntValue)) : false;
	if(bLastRound)
		return true;
		
	return false;
}

stock int GetNumWinsToClinch()
{
	int iOvertimePlaying = GameRules_GetProp("m_nOvertimePlaying");
	int iNumWinsToClinch = (FindConVar("mp_maxrounds").IntValue > 0 && FindConVar("mp_match_can_clinch").BoolValue) ? (FindConVar("mp_maxrounds").IntValue / 2 ) + 1 + iOvertimePlaying * (FindConVar("mp_overtime_maxrounds").IntValue / 2) : -1;
	return iNumWinsToClinch;
}

stock bool IsItMyChance(float fChance = 0.0)
{
	float flRand = Math_GetRandomFloat(0.0, 100.0);
	if( fChance <= 0.0 )
		return false;
	return flRand <= fChance;
}

stock bool IsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client);
}