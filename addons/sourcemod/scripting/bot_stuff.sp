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

char g_szCrosshairCode[MAXPLAYERS+1][35], g_szPreviousBuy[MAXPLAYERS+1][128];
bool g_bIsBombScenario, g_bIsHostageScenario, g_bFreezetimeEnd, g_bBombPlanted, g_bHalftimeSwitch, g_bIsCompetitive;
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
	version = "1.3.3", 
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
        PrintToServer("Usage: team <TeamName> <t|ct>");
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

	char szMap[64];
    GetCurrentMap(szMap, sizeof(szMap));
    GetMapDisplayName(szMap, szMap, sizeof(szMap));
    ParseMapNades(szMap);

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

		if (BotMimic_IsPlayerMimicing(i))
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
    g_iRoundsPlayed = 0;

    while ((iEnt = FindEntityByClassname(iEnt, "cs_team_manager")) != -1)
    {
        int iTeamNum = GetEntProp(iEnt, Prop_Send, "m_iTeamNum");

        if (iTeamNum == CS_TEAM_CT)
            g_iRoundsPlayed += (g_iCTScore = GetEntProp(iEnt, Prop_Send, "m_scoreTotal"));
        else if (iTeamNum == CS_TEAM_T)
            g_iRoundsPlayed += (g_iTScore = GetEntProp(iEnt, Prop_Send, "m_scoreTotal"));
    }
}

public void OnFreezetimeEnd(Event eEvent, char[] szName, bool bDontBroadcast)
{
	g_bFreezetimeEnd = true;
	g_fFreezeTimeEnd = GetGameTime();
}

public void OnWeaponZoom(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(eEvent.GetInt("userid"));
	if (!IsValidClient(client) || !IsPlayerAlive(client) || !IsFakeClient(client))
		return;

	g_fShootTimestamp[client] = GetGameTime();
}

public void OnWeaponFire(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(eEvent.GetInt("userid"));
	if (!IsValidClient(client) || !IsPlayerAlive(client) || !IsFakeClient(client))
		return;

	char szWeaponName[64];
	eEvent.GetString("weapon", szWeaponName, sizeof(szWeaponName));

	if (IsValidClient(g_iTarget[client]))
	{
		float fTargetLoc[3];
		GetClientAbsOrigin(g_iTarget[client], fTargetLoc);

		float fRangeToEnemy = GetVectorDistance(g_fBotOrigin[client], fTargetLoc);
		if (StrEqual(szWeaponName, "weapon_deagle") && fRangeToEnemy > 100.0)
			SetEntDataFloat(client, g_iFireWeaponOffset, GetEntDataFloat(client, g_iFireWeaponOffset) + Math_GetRandomFloat(0.20, 0.40));
	}

	if ((StrEqual(szWeaponName, "weapon_awp") || StrEqual(szWeaponName, "weapon_ssg08")) && IsItMyChance(50.0))
		RequestFrame(BeginQuickSwitch, GetClientUserId(client));
}

public void OnThinkPost(int iEnt)
{
	SetEntDataArray(iEnt, g_iProfileRankOffset, g_iProfileRank, MAXPLAYERS + 1);
	SetEntDataArray(iEnt, g_iPlayerColorOffset, g_iPlayerColor, MAXPLAYERS + 1);

	Address pEntAddr = GetEntityAddress(iEnt);
	for (int i = 1; i <= MaxClients; i++)
		if (IsValidClient(i) && IsFakeClient(i))
			SetCrosshairCode(pEntAddr, i, g_szCrosshairCode[i]);
}

public Action CS_OnBuyCommand(int client, const char[] szWeapon)
{
	if (!IsValidClient(client) || !IsPlayerAlive(client) || !IsFakeClient(client))
		return Plugin_Continue;

	if (BotMimic_IsPlayerMimicing(client))
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
			ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_m4a1_silencer", true);
			return Plugin_Changed;
		}

		if (IsItMyChance(5.0) && iAccount >= CS_GetWeaponPrice(client, CSWeapon_AUG))
		{
			ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_aug", true);
			return Plugin_Changed;
		}
	}

	if (strcmp(szWeapon, "mac10") == 0 && IsItMyChance(40.0) && iAccount >= CS_GetWeaponPrice(client, CSWeapon_GALILAR))
	{
		ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_galilar", true);
		return Plugin_Changed;
	}

	if (strcmp(szWeapon, "mp9") == 0)
	{
		if (IsItMyChance(40.0) && iAccount >= CS_GetWeaponPrice(client, CSWeapon_FAMAS))
		{
			ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_famas", true);
			return Plugin_Changed;
		}

		if (IsItMyChance(15.0) && iAccount >= CS_GetWeaponPrice(client, CSWeapon_UMP45))
		{
			ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_ump45", true);
			return Plugin_Changed;
		}
	}

	if ((strcmp(szWeapon, "tec9") == 0 || strcmp(szWeapon, "fiveseven") == 0) && g_bUseCZ75[client])
	{
		ReplaceWeapon(client, CS_SLOT_SECONDARY, "weapon_cz75a", true);
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

	int iBone = LookupBone(iPlayer, "head_0");
	if (iBone < 0 || iPart != 2)
		return MRES_Ignored;

	float fHeadPos[3], fUnused[3];
	GetBonePosition(iPlayer, iBone, fHeadPos, fUnused);
	fHeadPos[2] += 4.0;

	hReturn.SetVector(fHeadPos);
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
		float fClientEyes[3], fNoisePos[3];
		GetClientEyePosition(client, fClientEyes);

		if (IsItMyChance(40.0) && IsPointVisible(fClientEyes, fNoisePos) && LineGoesThroughSmoke(fClientEyes, fNoisePos) && !bIsWalking)
            DHookSetParam(hParams, 7, true);

		DHookGetParamVector(hParams, 2, fNoisePos);

		if (CanThrowNade(client) && IsItMyChance(4.0) && GetTask(client) != ESCAPE_FROM_BOMB && GetTask(client) != ESCAPE_FROM_FLAMES && GetEntityMoveType(client) != MOVETYPE_LADDER)
		{
			ProcessGrenadeThrow(client, fNoisePos);
			return MRES_Supercede;
		}

		if (BotMimic_IsPlayerMimicing(client))
		{
			if (g_iDoingSmokeNum[client] >= 0 && g_iDoingSmokeNum[client] < g_iMaxNades)
				g_fNadeTimestamp[g_iDoingSmokeNum[client]] = GetGameTime();
			BotMimic_StopPlayerMimic(client);
		}

		if (eItems_GetWeaponSlotByWeapon(g_iActiveWeapon[client]) == CS_SLOT_KNIFE && GetTask(client) != ESCAPE_FROM_BOMB && GetTask(client) != ESCAPE_FROM_FLAMES)
			BotEquipBestWeapon(client, true);

		g_bDontSwitch[client] = true;
		CreateTimer(5.0, Timer_EnableSwitch, GetClientUserId(client));

		fNoisePos[2] += 25.0;
		DHookSetParamVector(hParams, 2, fNoisePos);
		return MRES_ChangedHandled;
	}
	else if (strcmp(szDesc, "Nearby enemy gunfire") == 0)
	{
		float fPos[3], fClientEyes[3];
		GetClientEyePosition(client, fClientEyes);
		DHookGetParamVector(hParams, 2, fPos);

		if (CanThrowNade(client) && IsItMyChance(25.0) && BotBendLineOfSight(client, fClientEyes, fPos, fPos, 135.0) && GetTask(client) != ESCAPE_FROM_BOMB && GetTask(client) != ESCAPE_FROM_FLAMES && GetEntityMoveType(client) != MOVETYPE_LADDER)
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
    if (!g_bIsProBot[client])
        return MRES_Ignored;

    SelectBestTargetPos(client, g_fTargetPos[client]);

    if (!IsValidClient(g_iTarget[client]) || !IsPlayerAlive(g_iTarget[client]) || g_fTargetPos[client][2] == 0.0)
        return MRES_Ignored;

    SetEntDataVector(client, g_iBotTargetSpotOffset, g_fTargetPos[client]);
    return MRES_Ignored;
}

public Action OnPlayerRunCmd(int client, int &iButtons, int &iImpulse, float fVel[3], float fAngles[3], int &iWeapon, int &iSubtype, int &iCmdNum, int &iTickCount, int &iSeed, int iMouse[2])
{
	g_bBombPlanted = !!GameRules_GetProp("m_bBombPlanted");
	
	if (!IsValidClient(client) || !IsPlayerAlive(client) || !IsFakeClient(client))
		return Plugin_Continue;

	if (!g_bFreezetimeEnd && g_bDropWeapon[client] && view_as<LookAtSpotState>(GetEntData(client, g_iBotLookAtSpotStateOffset)) == LOOK_AT_SPOT)
	{
		CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY), true);
		FakeClientCommand(client, "buy %s", g_szPreviousBuy[client]);
		g_bDropWeapon[client] = false;
	}

	GetClientAbsOrigin(client, g_fBotOrigin[client]);
	g_iActiveWeapon[client] = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if (!IsValidEntity(g_iActiveWeapon[client]))
		return Plugin_Continue;

	if (!g_bFreezetimeEnd)
		return Plugin_Continue;

	float fNow = GetGameTime();
	int iDefIndex = GetEntProp(g_iActiveWeapon[client], Prop_Send, "m_iItemDefinitionIndex");

	float fPlayerVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", fPlayerVelocity);
	fPlayerVelocity[2] = 0.0;
	float fSpeed = GetVectorLength(fPlayerVelocity);

	g_pCurrArea[client] = NavMesh_GetNearestArea(g_fBotOrigin[client]);

	if ((GetAliveTeamCount(CS_TEAM_T) == 0 || GetAliveTeamCount(CS_TEAM_CT) == 0) && !g_bDontSwitch[client])
	{
		SDKCall(g_hSwitchWeaponCall, client, GetPlayerWeaponSlot(client, CS_SLOT_KNIFE), 0);
		
		if (BotMimic_IsPlayerMimicing(client))
            BotMimic_StopPlayerMimic(client);
			
		Array_Fill(g_fNadeTimestamp, view_as<int>(0.0), g_iMaxNades);
		g_iDoingSmokeNum[client] = -1;
	}

	if (IsItMyChance(0.2) && g_iDoingSmokeNum[client] == -1 && !BotMimic_IsPlayerMimicing(client))
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

	if (BotMimic_IsPlayerMimicing(client))
	{
    	g_iDoingSmokeNum[client] = -1;
    	return Plugin_Continue;
	}

	if (g_iDoingSmokeNum[client] != -1 && !BotMimic_IsPlayerMimicing(client))
	{
		if (g_iDoingSmokeNum[client] >= 0 && g_iDoingSmokeNum[client] < g_iMaxNades)
		{
			g_fNadeTimestamp[g_iDoingSmokeNum[client]] = fNow;
			float fDisToNade = GetVectorDistance(g_fBotOrigin[client], g_fNadePos[g_iDoingSmokeNum[client]]);
			BotMoveTo(client, g_fNadePos[g_iDoingSmokeNum[client]], FASTEST_ROUTE);
			if (fDisToNade < 25.0)
			{
				BotSetLookAt(client, "Use entity", g_fNadeLook[g_iDoingSmokeNum[client]], PRIORITY_HIGH, 2.0, false, 3.0, false);
				if (view_as<LookAtSpotState>(GetEntData(client, g_iBotLookAtSpotStateOffset)) == LOOK_AT_SPOT && fSpeed == 0.0 && (GetEntityFlags(client) & FL_ONGROUND))
					BotMimic_PlayRecordFromFile(client, g_szReplay[g_iDoingSmokeNum[client]]);
			}
		}
		else
		{
			g_iDoingSmokeNum[client] = -1;
		}
	}

	if (g_bThrowGrenade[client] && eItems_GetWeaponSlotByDefIndex(iDefIndex) == CS_SLOT_GRENADE)
	{
		BotThrowGrenade(client, g_fNadeTarget[client]);
		g_fThrowNadeTimestamp[client] = fNow;
	}

	if (IsSafe(client))
	{
		iButtons &= ~IN_SPEED;
		if(g_bIsProBot[client] && !g_bDontSwitch[client] && !BotIsHiding(client))
			SDKCall(g_hSwitchWeaponCall, client, GetPlayerWeaponSlot(client, CS_SLOT_KNIFE), 0);
	}

	if (g_bIsProBot[client] && !g_bBombPlanted && 
	    !BotMimic_IsPlayerMimicing(client) &&  
	    GetTask(client) != COLLECT_HOSTAGES && 
	    GetTask(client) != RESCUE_HOSTAGES && 
	    GetTask(client) != GUARD_LOOSE_BOMB && 
	    GetTask(client) != PLANT_BOMB && 
	    GetTask(client) != ESCAPE_FROM_FLAMES)
	{
		float fClientEyes[3];
		GetClientEyePosition(client, fClientEyes);

		int iSkipAK[2] = {7, 9};
		TryPickupWeapon(client, "weapon_ak47", iSkipAK, sizeof(iSkipAK), CS_SLOT_PRIMARY, fClientEyes, g_fBotOrigin[client]);

		int iSkipM4[4] = {7, 9, 16, 60};
		TryPickupWeapon(client, "weapon_m4a1", iSkipM4, sizeof(iSkipM4), CS_SLOT_PRIMARY, fClientEyes, g_fBotOrigin[client]);

		int iSkipDeagle[1] = {1};
		TryPickupWeapon(client, "weapon_deagle", iSkipDeagle, sizeof(iSkipDeagle), CS_SLOT_SECONDARY, fClientEyes, g_fBotOrigin[client]);

		int iSkipTec9[5] = {1, 30, 3, 63, 2};
		TryPickupWeapon(client, "weapon_tec9", iSkipTec9, sizeof(iSkipTec9), CS_SLOT_SECONDARY, fClientEyes, g_fBotOrigin[client]);
		TryPickupWeapon(client, "weapon_fiveseven", iSkipTec9, sizeof(iSkipTec9), CS_SLOT_SECONDARY, fClientEyes, g_fBotOrigin[client]);

		int iSkipP250[6] = {1, 30, 3, 63, 36, 2};
		TryPickupWeapon(client, "weapon_p250", iSkipP250, sizeof(iSkipP250), CS_SLOT_SECONDARY, fClientEyes, g_fBotOrigin[client]);

		int iSkipUSP[8] = {1, 30, 3, 63, 36, 32, 61, 2};
		TryPickupWeapon(client, "weapon_hkp2000", iSkipUSP, sizeof(iSkipUSP), CS_SLOT_SECONDARY, fClientEyes, g_fBotOrigin[client]);
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
			g_fShootTimestamp[client] = fNow;

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
			g_fNadeTimestamp[g_iDoingSmokeNum[client]] = fNow;
			BotMimic_StopPlayerMimic(client);
		}

		if ((eItems_GetWeaponSlotByDefIndex(iDefIndex) == CS_SLOT_KNIFE || eItems_GetWeaponSlotByDefIndex(iDefIndex) == CS_SLOT_GRENADE) && GetTask(client) != ESCAPE_FROM_BOMB && GetTask(client) != ESCAPE_FROM_FLAMES)
			BotEquipBestWeapon(client, true);

		if (bIsEnemyVisible && GetEntityMoveType(client) != MOVETYPE_LADDER)
		{
			if (g_iPrevTarget[client] == -1)
				g_fCrouchTimestamp[client] = fNow + Math_GetRandomFloat(0.23, 0.25);
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
				g_fCrouchTimestamp[client] = fNow + Math_GetRandomFloat(0.23, 0.25);

			switch (iDefIndex)
			{
				case 7, 8, 10, 13, 14, 16, 17, 19, 23, 24, 25, 26, 28, 33, 34, 39, 60:
				{
					if (fOnTarget > fAimTolerance && !bIsDucking && fTargetDistance < 2000.0 && iDefIndex != 17 && iDefIndex != 19 && iDefIndex != 23 && iDefIndex != 24 && iDefIndex != 25 && iDefIndex != 26 && iDefIndex != 33 && iDefIndex != 34)
						AutoStop(client, fVel, fAngles);
					else if (fTargetDistance > 2000.0 && GetEntDataFloat(client, g_iFireWeaponOffset) == fNow)
						AutoStop(client, fVel, fAngles);
					if (fOnTarget > fAimTolerance && fTargetDistance < 2000.0)
					{
						iButtons &= ~IN_ATTACK;
						if (!bIsReloading && (fSpeed < 50.0 || bIsDucking || iDefIndex == 17 || iDefIndex == 19 || iDefIndex == 23 || iDefIndex == 24 || iDefIndex == 25 || iDefIndex == 26 || iDefIndex == 33 || iDefIndex == 34))
						{
							iButtons |= IN_ATTACK;
							SetEntDataFloat(client, g_iFireWeaponOffset, fNow);
						}
					}
				}
				case 1:
				{
					if (fNow - GetEntDataFloat(client, g_iFireWeaponOffset) < 0.15 && !bIsDucking && !bIsReloading)
						AutoStop(client, fVel, fAngles);
				}
				case 9, 40:
				{
					if (fTargetDistance < 2750.0 && !bIsReloading && GetEntProp(client, Prop_Send, "m_bIsScoped") && fNow - g_fShootTimestamp[client] > 0.4 && GetClientAimTarget(client, true) == g_iTarget[client])
					{
						iButtons |= IN_ATTACK;
						SetEntDataFloat(client, g_iFireWeaponOffset, fNow);
					}
				}
			}

			float fClientLoc[3];
			Array_Copy(g_fBotOrigin[client], fClientLoc, 3);
			fClientLoc[2] += HalfHumanHeight;
			if (fNow >= g_fCrouchTimestamp[client] && !GetEntProp(g_iActiveWeapon[client], Prop_Data, "m_bInReload") && IsPointVisible(fClientLoc, g_fTargetPos[client]) && fOnTarget > fAimTolerance && fTargetDistance < 2000.0 && (iDefIndex == 7 || iDefIndex == 8 || iDefIndex == 10 || iDefIndex == 13 || iDefIndex == 14 || iDefIndex == 16 || iDefIndex == 39 || iDefIndex == 60 || iDefIndex == 28))
				iButtons |= IN_DUCK;

			g_iPrevTarget[client] = g_iTarget[client];
		}
	}

	return Plugin_Changed;
}

public void OnPlayerSpawn(Event eEvent, const char[] szName, bool bDontBroadcast)
{
    int client = GetClientOfUserId(eEvent.GetInt("userid"));
    if (!IsValidClient(client))
        return;

    SetPlayerTeammateColor(client);

    if (!IsFakeClient(client))
        return;

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
        char szWeapon[32];
        GetClientWeapon(client, szWeapon, sizeof(szWeapon));

        if (strcmp(szWeapon, "weapon_hkp2000") == 0)
            ReplaceWeapon(client, CS_SLOT_SECONDARY, "weapon_usp_silencer");
    }
}

public void BotMimic_OnPlayerStopsMimicing(int client, char[] szName, char[] szCategory, char[] szPath)
{
    g_iDoingSmokeNum[client] = -1;
}

public void OnClientDisconnect(int client)
{
	if (IsFakeClient(client))
		g_iProfileRank[client] = 0;
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
		kv.GetString("replay", g_szReplay[i], sizeof(g_szReplay[]));
		g_fNadeTimestamp[i] = kv.GetFloat("timestamp");
		
		g_iNadeTeam[i] = CS_TEAM_NONE;
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

bool IsProBot(const char[] szName, char[] szCrosshairCode, const int iSize)
{
    char szPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, szPath, sizeof(szPath), "data/bot_info.json");

    if (!FileExists(szPath))
    {
        PrintToServer("Configuration file %s not found.", szPath);
        return false;
    }

    JSONObject jObjData = JSONObject.FromFile(szPath);
    if (jObjData == null)
    {
        PrintToServer("Failed to parse JSON file: %s", szPath);
        return false;
    }

    if (!jObjData.HasKey(szName))
    {
        delete jObjData;
        return false;
    }

    JSONObject jObjInfo = view_as<JSONObject>(jObjData.Get(szName));
    if (jObjInfo != null)
    {
        jObjInfo.GetString("crosshair_code", szCrosshairCode, iSize);
        delete jObjInfo;
    }

    delete jObjData;
    return true;
}

public void LoadSDK()
{
	GameData hConf = new GameData("botstuff.games");
	if (hConf == null)
		SetFailState("Failed to find botstuff.games game config.");

	g_pTheBots = SetupAddress(hConf, "TheBots");
	g_iBotTargetSpotOffset = SetupOffset(hConf, "CCSBot::m_targetSpot");
	g_iBotNearbyEnemiesOffset = SetupOffset(hConf, "CCSBot::m_nearbyEnemyCount");
	g_iFireWeaponOffset = SetupOffset(hConf, "CCSBot::m_fireWeaponTimestamp");
	g_iEnemyVisibleOffset = SetupOffset(hConf, "CCSBot::m_isEnemyVisible");
	g_iBotProfileOffset = SetupOffset(hConf, "CCSBot::m_pLocalProfile");
	g_iBotSafeTimeOffset = SetupOffset(hConf, "CCSBot::m_safeTime");
	g_iBotEnemyOffset = SetupOffset(hConf, "CCSBot::m_enemy");
	g_iBotLookAtSpotStateOffset = SetupOffset(hConf, "CCSBot::m_lookAtSpotState");
	g_iBotMoraleOffset = SetupOffset(hConf, "CCSBot::m_morale");
	g_iBotTaskOffset = SetupOffset(hConf, "CCSBot::m_task");
	g_iBotDispositionOffset = SetupOffset(hConf, "CCSBot::m_disposition");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CCSBot::MoveTo");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	if ((g_hBotMoveTo = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall: CCSBot::MoveTo");

	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBaseAnimating::LookupBone");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if ((g_hLookupBone = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall: CBaseAnimating::LookupBone");

	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBaseAnimating::GetBonePosition");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	PrepSDKCall_AddParameter(SDKType_QAngle, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	if ((g_hGetBonePosition = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall: CBaseAnimating::GetBonePosition");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CCSBot::IsVisible");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer, VDECODE_FLAG_ALLOWNULL);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hBotIsVisible = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall: CCSBot::IsVisible");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CCSBot::IsAtHidingSpot");
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hBotIsHiding = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall: CCSBot::IsAtHidingSpot");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CCSBot::EquipBestWeapon");
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	if ((g_hBotEquipBestWeapon = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall: CCSBot::EquipBestWeapon");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CCSBot::SetLookAt");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	if ((g_hBotSetLookAt = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall: CCSBot::SetLookAt");

	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "SetCrosshairCode");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	if ((g_hSetCrosshairCode = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall: SetCrosshairCode");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "Weapon_Switch");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer, VDECODE_FLAG_ALLOWNULL);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	if ((g_hSwitchWeaponCall = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall: Weapon_Switch");

	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBotManager::IsLineBlockedBySmoke");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hIsLineBlockedBySmoke = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall: CBotManager::IsLineBlockedBySmoke");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CCSBot::BendLineOfSight");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hBotBendLineOfSight = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall: CCSBot::BendLineOfSight");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CCSBot::ThrowGrenade");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	if ((g_hBotThrowGrenade = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall: CCSBot::ThrowGrenade");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CCSPlayer::AddAccount");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	if ((g_hAddMoney = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall: CCSPlayer::AddAccount");

	delete hConf;
}

public void LoadDetours()
{
	GameData hConf = new GameData("botstuff.games");
	if (hConf == null)
	{
		SetFailState("Failed to load botstuff.games gamedata.");
		return;
	}

	SetupDetour(hConf, "CCSBot::SetLookAt", Hook_Pre, CCSBot_SetLookAt);
	SetupDetour(hConf, "CCSBot::PickNewAimSpot", Hook_Post, CCSBot_PickNewAimSpot);
	SetupDetour(hConf, "BotCOS", Hook_Pre, BotCOSandSIN);
	SetupDetour(hConf, "BotSIN", Hook_Pre, BotCOSandSIN);
	SetupDetour(hConf, "CCSBot::GetPartPosition", Hook_Pre, CCSBot_GetPartPosition);

	delete hConf;
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

bool CanThrowNade(int client)
{
	return (GetGameTime() - g_fThrowNadeTimestamp[client] > 5.0 && IsValidEntity(GetPlayerWeaponSlot(client, CS_SLOT_GRENADE)));
}

void TryPickupWeapon(int client, char[] szClassname, const int[] iSkipList, int iSkipSize, int iSlot, float fClientEyes[3], float fOrigin[3])
{
    int iWeaponEnt = GetNearestEntity(client, szClassname);
    if (!IsValidEntity(iWeaponEnt))
        return;

    int iCurrent = GetPlayerWeaponSlot(client, iSlot);
    int iCurrentDef = IsValidEntity(iCurrent) ? GetEntProp(iCurrent, Prop_Send, "m_iItemDefinitionIndex") : 0;

    bool bSkip = false;
    if (iCurrent != -1)
    {
        for (int i = 0; i < iSkipSize; i++)
        {
            if (iCurrentDef == iSkipList[i])
            {
                bSkip = true;
                break;
            }
        }
    }

    if (iCurrent == -1 || (iCurrent != -1 && !bSkip))
    {
        float fLoc[3];
        GetEntPropVector(iWeaponEnt, Prop_Send, "m_vecOrigin", fLoc);

        if (GetVectorLength(fLoc) != 0.0 && IsPointVisible(fClientEyes, fLoc))
        {
            BotMoveTo(client, fLoc, FASTEST_ROUTE);

            if (GetVectorDistance(fOrigin, fLoc) < 50.0 && iCurrent != -1)
                CS_DropWeapon(client, iCurrent, false);
        }
    }
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
	int iCount = 0;
	int iTeam = GetClientTeam(client);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (i == client || !IsValidClient(i))
			continue;

		if (GetClientTeam(i) != iTeam)
			continue;

		if (IsValidEntity(GetPlayerWeaponSlot(i, CS_SLOT_PRIMARY)))
			iCount++;
	}

	return iCount;
}

public int GetNearestGrenade(int client)
{
	if (g_bBombPlanted)
		return -1;

	int iClosestNade = -1;
	float fOrigin[3], fDist, fClosestDist = -1.0;

	GetClientAbsOrigin(client, fOrigin);

	for (int i = 0; i < g_iMaxNades; i++)
	{
		if ((GetGameTime() - g_fNadeTimestamp[i]) < 25.0)
			continue;

		if (GetClientTeam(client) != g_iNadeTeam[i])
			continue;

		int iEntity = eItems_FindWeaponByDefIndex(client, g_iNadeDefIndex[i]);
		if (!IsValidEntity(iEntity))
			continue;

		if (i < 0 || i >= sizeof(g_fNadePos))
			continue;

		fDist = GetVectorDistance(fOrigin, g_fNadePos[i]);
		if (fDist > 250.0)
			continue;

		if (fDist < fClosestDist || fClosestDist == -1.0)
		{
			iClosestNade = i;
			fClosestDist = fDist;
		}
	}

	return iClosestNade;
}

stock int GetNearestEntity(int client, char[] szClassname)
{
	int iNearestEntity = -1, iEntity = -1;
	float fClientOrigin[3], fEntityOrigin[3], fDistance, fNearestDistance = -1.0;
	
	GetClientAbsOrigin(client, fClientOrigin);
	
	while ((iEntity = FindEntityByClassname(iEntity, szClassname)) != -1)
	{
		GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", fEntityOrigin);
		fDistance = GetVectorDistance(fClientOrigin, fEntityOrigin);
		
		if (fDistance < fNearestDistance || fNearestDistance == -1.0)
		{
			iNearestEntity = iEntity;
			fNearestDistance = fDistance;
		}
	}
	
	return iNearestEntity;
}

stock int ReplaceWeapon(int client, int iSlot, const char[] szClass, bool bHandleMoney = false)
{
	if (bHandleMoney)
	{
		CSWeaponID iWeaponID = CS_AliasToWeaponID(szClass);
		if (iWeaponID != CSWeapon_NONE)
		{
			int iPrice = CS_GetWeaponPrice(client, iWeaponID);
			AddMoney(client, -iPrice, true, true, szClass);
		}
	}

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

	if (GetEntProp(g_iActiveWeapon[client], Prop_Data, "m_bInReload"))
		return true;

	if (GetEntProp(g_iActiveWeapon[client], Prop_Data, "m_iClip1") == 0)
		return true;

	if (GetEntPropFloat(g_iActiveWeapon[client], Prop_Send, "m_flNextPrimaryAttack") > GetGameTime())
		return true;

	return false;
}

public void BeginQuickSwitch(int iUserId)
{
    int client = GetClientOfUserId(iUserId);
    if (!IsValidClient(client))
        return;

    SDKCall(g_hSwitchWeaponCall, client, GetPlayerWeaponSlot(client, CS_SLOT_KNIFE), 0);
    RequestFrame(FinishQuickSwitch, iUserId);
}

public void FinishQuickSwitch(int iUserId)
{
	int client = GetClientOfUserId(iUserId);
	
	if (!IsValidClient(client))
		return;
	
	SDKCall(g_hSwitchWeaponCall, client, GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY), 0);
}

public Action Timer_EnableSwitch(Handle hTimer, any iUserId)
{
	int client = GetClientOfUserId(iUserId);
	
	if (IsValidClient(client))
		g_bDontSwitch[client] = false;
	
	return Plugin_Stop;
}

public Action Timer_DontForceThrow(Handle hTimer, any iUserId)
{
	int client = GetClientOfUserId(iUserId);
	
	if (IsValidClient(client))
	{
		g_bThrowGrenade[client] = false;
		BotEquipBestWeapon(client, true);
	}
	
	return Plugin_Stop;
}

public void DelayThrow(int iUserId)
{
    int client = GetClientOfUserId(iUserId);
    
    if (IsValidClient(client))
    {
        g_bThrowGrenade[client] = true;
        CreateTimer(3.0, Timer_DontForceThrow, iUserId);
    }
}

public void SelectBestTargetPos(int client, float fTargetPos[3])
{
	if (!IsValidClient(g_iTarget[client]) || !IsPlayerAlive(g_iTarget[client]))
		return;

	int iHeadBone = LookupBone(g_iTarget[client], "head_0");
	int iSpineBone = LookupBone(g_iTarget[client], "spine_3");
	if (iHeadBone < 0 || iSpineBone < 0)
		return;

	bool bShootSpine;
	float fHead[3], fBody[3], fBad[3];
	GetBonePosition(g_iTarget[client], iHeadBone, fHead, fBad);
	GetBonePosition(g_iTarget[client], iSpineBone, fBody, fBad);

	fHead[2] += 4.0;

	bool bHeadVisible = BotIsVisible(client, fHead, false, -1);
	bool bBodyVisible = bHeadVisible && BotIsVisible(client, fBody, false, -1);

	if (bHeadVisible)
	{
		if (bBodyVisible)
		{
			if (!IsValidEntity(g_iActiveWeapon[client])) 
				return;

			int iDefIndex = GetEntProp(g_iActiveWeapon[client], Prop_Send, "m_iItemDefinitionIndex");

			switch (iDefIndex)
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
		// Head wasn't visible, check other bones.
		for (int b = 0; b < sizeof(g_szBoneNames); b++)
		{
			int iBone = LookupBone(g_iTarget[client], g_szBoneNames[b]);
			if (iBone < 0)
				continue;

			GetBonePosition(g_iTarget[client], iBone, fHead, fBad);

			if (BotIsVisible(client, fHead, false, -1))
				break;
			else
				fHead[2] = 0.0;
		}
	}

	if (bShootSpine)
		Array_Copy(fBody, fTargetPos, 3);
	else
		Array_Copy(fHead, fTargetPos, 3);
}

stock void GetViewVector(const float fVecAngle[3], float fOutPut[3])
{
    fOutPut[0] = Cosine(fVecAngle[1] * FLOAT_PI / 180.0);
    fOutPut[1] = Sine(fVecAngle[1] * FLOAT_PI / 180.0);
    fOutPut[2] = -Sine(fVecAngle[0] * FLOAT_PI / 180.0);
}

stock float AngleNormalize(float fAngle)
{
    fAngle -= RoundToFloor(fAngle / 360.0) * 360.0;

    if (fAngle > 180.0)
        fAngle -= 360.0;
    else if (fAngle < -180.0)
        fAngle += 360.0;

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
	if (!GetGrenadeToss(client, fTarget))
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

    if (fRange < 1.0)
        return false;

    const float fSlope = 0.2;
    float fTossHeight = fSlope * fRange;

    float fHeightInc = fTossHeight / 10.0;
    float fTarget[3];
    float fSafeSpace = fTossHeight / 2.0;

    float fMins[3] = { -16.0, -16.0, 0.0 };
    float fMaxs[3] = {  16.0,  16.0, 0.0 };
    fMaxs[2] = fHeightInc;

    float fLow = 0.0, fHigh = fTossHeight + fSafeSpace, fLastH = 0.0;
    bool bGotLow = false;

    fTarget[0] = fTossTarget[0];
    fTarget[1] = fTossTarget[1];

    for (float fH = 0.0; fH < 3.0 * fTossHeight; fH += fHeightInc)
    {
        fTarget[2] = fTossTarget[2] + fH;

        Handle hTraceResult = TR_TraceHullFilterEx(fEyePosition, fTarget, fMins, fMaxs, MASK_VISIBLE_AND_NPCS | CONTENTS_GRATE, TraceEntityFilterStuff);

        if (TR_GetFraction(hTraceResult) == 1.0)
        {
            if (!bGotLow)
            {
                fLow = fH;
                bGotLow = true;
            }
        }
        else if (bGotLow)
        {
            fHigh = fLastH;
            delete hTraceResult;
            break;
        }

        fLastH = fH;
        delete hTraceResult;
    }

    if (!bGotLow)
        return false;

    if (fTossHeight < fLow)
        fTossHeight = (fLow + fSafeSpace > fHigh) ? (fHigh + fLow) / 2.0 : fLow + fSafeSpace;
    else if (fTossHeight > fHigh - fSafeSpace)
        fTossHeight = (fHigh - fSafeSpace < fLow) ? (fHigh + fLow) / 2.0 : fHigh - fSafeSpace;

    fTossTarget[2] += fTossHeight;
    return true;
}

stock bool LineGoesThroughSmoke(const float fFrom[3], const float fTo[3])
{	
    return SDKCall(g_hIsLineBlockedBySmoke, g_pTheBots, fFrom, fTo);
}

stock int GetAliveTeamCount(int iTeam)
{
    int iNumber = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsValidClient(i))
            continue;

        if (!IsPlayerAlive(i))
            continue;

        if (GetClientTeam(i) != iTeam)
            continue;

        iNumber++;
    }
    return iNumber;
}

stock bool IsSafe(int client)
{
	return IsFakeClient(client) && (GetGameTime() - g_fFreezeTimeEnd) < GetEntDataFloat(client, g_iBotSafeTimeOffset);
}

stock TaskType GetTask(int client)
{
    return IsFakeClient(client) ? view_as<TaskType>(GetEntData(client, g_iBotTaskOffset)) : view_as<TaskType>(-1);
}

stock DispositionType GetDisposition(int client)
{
    return IsFakeClient(client) ? view_as<DispositionType>(GetEntData(client, g_iBotDispositionOffset)) : view_as<DispositionType>(-1);
}

stock void SetDisposition(int client, DispositionType iDisposition)
{
	if(!IsFakeClient(client))
		return;
		
	SetEntData(client, g_iBotDispositionOffset, iDisposition);
}

stock void SetPlayerTeammateColor(int client)
{
	if (GetClientTeam(client) <= CS_TEAM_SPECTATOR)
		return;

	if (g_iPlayerColor[client] > -1)
		return;

	for (int iColor = 0; iColor < 5; iColor++)
	{
		bool bColorTaken = false;

		for (int iClient = 1; iClient <= MaxClients; iClient++)
		{
			if (!IsValidClient(iClient))
				continue;

			if (GetClientTeam(iClient) != GetClientTeam(client))
				continue;

			if (g_iPlayerColor[iClient] == iColor && iClient != client)
			{
				bColorTaken = true;
				break;
			}
		}

		if (!bColorTaken)
		{
			g_iPlayerColor[client] = iColor;
			return;
		}
	}

	g_iPlayerColor[client] = -1;
}

public void AutoStop(int client, float fVel[3], float fAngles[3])
{
    float fPlayerVelocity[3], fVelAngle[3];
    GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", fPlayerVelocity);

    float fSpeed = GetVectorLength(fPlayerVelocity);
    if (fSpeed < 1.0)
        return;

    GetVectorAngles(fPlayerVelocity, fVelAngle);
    fVelAngle[1] = fAngles[1] - fVelAngle[1];

    float fDirForward[3];
    GetAngleVectors(fVelAngle, fDirForward, NULL_VECTOR, NULL_VECTOR);

    fVel[0] = -fDirForward[0] * fSpeed;
    fVel[1] = -fDirForward[1] * fSpeed;
}

stock bool ShouldForce()
{
    int iOvertimePlaying = GameRules_GetProp("m_nOvertimePlaying");
    GamePhase pGamePhase = view_as<GamePhase>(GameRules_GetProp("m_gamePhase"));

    ConVar cvMaxRounds = FindConVar("mp_maxrounds");
    ConVar cvOTMaxRounds = FindConVar("mp_overtime_maxrounds");
    ConVar cvHalftime = FindConVar("mp_halftime");

    if (cvHalftime.BoolValue && pGamePhase == GAMEPHASE_PLAYING_FIRST_HALF)
    {
        int iRoundsBeforeHalftime = iOvertimePlaying ? cvMaxRounds.IntValue + ((2 * iOvertimePlaying - 1) * (cvOTMaxRounds.IntValue / 2)) : (cvMaxRounds.IntValue / 2);

        if ((iRoundsBeforeHalftime > 0) && (g_iRoundsPlayed == iRoundsBeforeHalftime - 1))
        {
            g_bHalftimeSwitch = true;
            return true;
        }
    }

    if (pGamePhase != GAMEPHASE_PLAYING_FIRST_HALF)
    {
        int iNumWinsToClinch = GetNumWinsToClinch();
        if (g_iCTScore == iNumWinsToClinch - 1 || g_iTScore == iNumWinsToClinch - 1)
            return true;
    }

    if (cvMaxRounds.IntValue > 0)
    {
        int iLastRound = (cvMaxRounds.IntValue - 1) + (iOvertimePlaying * cvOTMaxRounds.IntValue);
        if (g_iCurrentRound == iLastRound)
            return true;
    }

    return false;
}

stock int GetNumWinsToClinch()
{
	int iOvertimePlaying = GameRules_GetProp("m_nOvertimePlaying");
	int iMaxRounds = FindConVar("mp_maxrounds").IntValue;
	bool bCanClinch = FindConVar("mp_match_can_clinch").BoolValue;
	int iOvertimeMaxRounds = FindConVar("mp_overtime_maxrounds").IntValue;
	
	return (iMaxRounds > 0 && bCanClinch) ? (iMaxRounds / 2) + 1 + iOvertimePlaying * (iOvertimeMaxRounds / 2) : -1;
}

stock bool IsItMyChance(float fChance)
{
    return (fChance > 0.0) && (Math_GetRandomFloat(0.0, 100.0) <= fChance);
}

stock bool IsValidClient(int client)
{
	return (client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client));
}