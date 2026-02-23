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
#include <bot_steamids>

enum
{
	DEFIDX_DEAGLE = 1,
	DEFIDX_DUALIES = 2,
	DEFIDX_FIVESEVEN = 3,
	DEFIDX_GLOCK = 4,
	DEFIDX_AK47 = 7,
	DEFIDX_AUG = 8,
	DEFIDX_AWP = 9,
	DEFIDX_FAMAS = 10,
	DEFIDX_G3SG1 = 11,
	DEFIDX_GALIL = 13,
	DEFIDX_M249 = 14,
	DEFIDX_M4A4 = 16,
	DEFIDX_MAC10 = 17,
	DEFIDX_P90 = 19,
	DEFIDX_MP5SD = 23,
	DEFIDX_UMP45 = 24,
	DEFIDX_XM1014 = 25,
	DEFIDX_BIZON = 26,
	DEFIDX_MAG7 = 27,
	DEFIDX_NEGEV = 28,
	DEFIDX_SAWEDOFF = 29,
	DEFIDX_TEC9 = 30,
	DEFIDX_P2000 = 32,
	DEFIDX_MP7 = 33,
	DEFIDX_MP9 = 34,
	DEFIDX_NOVA = 35,
	DEFIDX_P250 = 36,
	DEFIDX_SCAR20 = 38,
	DEFIDX_SG556 = 39,
	DEFIDX_SSG08 = 40,
	DEFIDX_M4A1S = 60,
	DEFIDX_USPS = 61,
	DEFIDX_CZ75 = 63,
	DEFIDX_REVOLVER = 64,
	DEFIDX_FLASH = 43,
	DEFIDX_HE = 44,
	DEFIDX_SMOKE = 45,
	DEFIDX_MOLOTOV = 46,
	DEFIDX_DECOY = 47,
	DEFIDX_INCENDIARY = 48
};

char g_szCrosshairCode[MAXPLAYERS+1][35], g_szPreviousBuy[MAXPLAYERS+1][128];
bool g_bIsBombScenario, g_bIsHostageScenario, g_bFreezetimeEnd, g_bBombPlanted, g_bHalftimeSwitch, g_bIsCompetitive;
bool g_bForceT, g_bForceCT;
bool g_bUseCZ75[MAXPLAYERS+1], g_bUseUSP[MAXPLAYERS+1], g_bUseM4A1S[MAXPLAYERS+1], g_bDontSwitch[MAXPLAYERS+1], g_bDropWeapon[MAXPLAYERS+1], g_bHasGottenDrop[MAXPLAYERS+1];
bool g_bIsProBot[MAXPLAYERS+1], g_bThrowGrenade[MAXPLAYERS+1], g_bUncrouch[MAXPLAYERS+1];
int g_iProfileRank[MAXPLAYERS+1], g_iPlayerColor[MAXPLAYERS+1], g_iTarget[MAXPLAYERS+1], g_iPrevTarget[MAXPLAYERS+1], g_iDoingSmokeNum[MAXPLAYERS+1], g_iActiveWeapon[MAXPLAYERS+1];
int g_iCurrentRound, g_iRoundsPlayed, g_iCTScore, g_iTScore;
int g_iProfileRankOffset, g_iPlayerColorOffset;
int g_iBotTargetSpotOffset, g_iBotNearbyEnemiesOffset, g_iFireWeaponOffset, g_iEnemyVisibleOffset, g_iBotProfileOffset, g_iBotSafeTimeOffset, g_iBotEnemyOffset, g_iBotLookAtSpotStateOffset, g_iBotMoraleOffset, g_iBotTaskOffset, g_iBotDispositionOffset, g_iBotInitialEncounterAreaOffset;
float g_fBotOrigin[MAXPLAYERS+1][3], g_fTargetPos[MAXPLAYERS+1][3], g_fNadeTarget[MAXPLAYERS+1][3];
float g_fOriginalNoisePos[MAXPLAYERS+1][3];
float g_fRoundStart, g_fFreezeTimeEnd;
float g_fLookAngleMaxAccel[MAXPLAYERS+1], g_fReactionTime[MAXPLAYERS+1], g_fAggression[MAXPLAYERS+1], g_fShootTimestamp[MAXPLAYERS+1], g_fThrowNadeTimestamp[MAXPLAYERS+1], g_fCrouchTimestamp[MAXPLAYERS+1];
float g_fEnemyLostTime[MAXPLAYERS+1];
float g_fBombPos[3];
bool g_bWasEnemyVisible[MAXPLAYERS+1];
ConVar g_cvGameMode;
ConVar g_cvGameType;
ConVar g_cvRecoilScale;
ConVar g_cvMaxRounds;
ConVar g_cvOTMaxRounds;
ConVar g_cvHalftime;
ConVar g_cvCanClinch;
ConVar g_cvFreezeTime;
ConVar g_cvGravity;
ConVar g_cvMolotovDetonateTime;
ConVar g_cvMolotovMaxSlope;
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
Handle g_hOnAudibleEvent;
Address g_pTheBots;
CNavArea g_pCurrArea[MAXPLAYERS+1];
int g_iPlayerResourceEntity = -1;
int g_iAliveCountT, g_iAliveCountCT;
int g_iAvgMoneyT, g_iAvgMoneyCT;
float g_fLastNavUpdate[MAXPLAYERS+1][3];
float g_fWeaponPickupCooldown[MAXPLAYERS+1];
float g_fNadeLineupCooldown[MAXPLAYERS+1];

enum struct NadeLineup
{
	float fPos[3];
	float fLook[3];
	int iDefIndex;
	char szReplay[128];
	float fTimestamp;
	int iTeam;
}

ArrayList g_aNades;

static const char g_szTopBotNames[][] =
{
    "sh1ro", "ZywOo", "ropz", "donk", "m0NESY"
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
	version = "1.3.9", 
	url = "http://steamcommunity.com/id/manico001"
};

public void OnPluginStart()
{
    g_cvGameMode = FindConVar("game_mode");
    g_cvGameType = FindConVar("game_type");
    g_cvRecoilScale = FindConVar("weapon_recoil_scale");
    g_cvMaxRounds = FindConVar("mp_maxrounds");
    g_cvOTMaxRounds = FindConVar("mp_overtime_maxrounds");
    g_cvHalftime = FindConVar("mp_halftime");
    g_cvCanClinch = FindConVar("mp_match_can_clinch");
    g_cvFreezeTime = FindConVar("mp_freezetime");
    g_cvGravity = FindConVar("sv_gravity");
    g_cvMolotovDetonateTime = FindConVar("molotov_throw_detonate_time");
    g_cvMolotovMaxSlope = FindConVar("weapon_molotov_maxdetonateslope");
    
    g_bIsCompetitive = (g_cvGameMode.IntValue == 1 && g_cvGameType.IntValue == 0);
    
    HookEventEx("round_prestart", OnRoundPreStart);
    HookEventEx("round_start", OnRoundStart);
    HookEventEx("round_end", OnRoundEnd);
    HookEventEx("round_freeze_end", OnFreezetimeEnd);
    
    HookEventEx("player_spawn", OnPlayerSpawn);
    HookEventEx("player_death", OnPlayerDeath);
    
    HookEventEx("weapon_zoom", OnWeaponZoom);
    HookEventEx("weapon_fire", OnWeaponFire);

    HookEventEx("bomb_planted", OnBombPlanted);
    HookEventEx("bomb_defused", OnBombDefused);
    HookEventEx("player_jump", OnPlayerJump);
    HookEventEx("bomb_beginplant", OnBombBeginPlant);
    
    LoadSDK();
    LoadDetours();
    
    RegConsoleCmd("team", Command_Team);
    RegConsoleCmd("sm_validate_bots", Command_ValidateBots);
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
        PrintToServer("Configuration file not found: %s", szPath);
        return Plugin_Handled;
    }

    KeyValues kv = new KeyValues("Teams");
    if (!kv.ImportFromFile(szPath))
    {
        delete kv;
        PrintToServer("Unable to parse configuration file: %s", szPath);
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
    kv.GetString("logo", szLogo, sizeof(szLogo), "");
    delete kv;

    ServerCommand("bot_kick %s all", szSide);

    char szPlayerNames[5][MAX_NAME_LENGTH];
    int iCount = ExplodeString(szPlayers, ",", szPlayerNames, sizeof(szPlayerNames), sizeof(szPlayerNames[]));

    for (int i = 0; i < iCount; i++)
    {
        TrimString(szPlayerNames[i]);
        if (szPlayerNames[i][0] != '\0')
        {
            ServerCommand("bot_add_%s %s", szSide, szPlayerNames[i]);
        }
    }

    if (szLogo[0] != '\0')
    {
        int iLogoSlot = strcmp(szSide, "ct", false) == 0 ? 1 : 2;
        ServerCommand("mp_teamlogo_%d %s", iLogoSlot, szLogo);
    }

    return Plugin_Handled;
}

public Action Command_ValidateBots(int client, int iArgs)
{
    char szPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, szPath, sizeof(szPath), "configs/bot_rosters.txt");
    if (!FileExists(szPath))
    {
        PrintToServer("[Validate] Configuration file not found: %s", szPath);
        return Plugin_Handled;
    }

    KeyValues kv = new KeyValues("Teams");
    if (!kv.ImportFromFile(szPath))
    {
        delete kv;
        PrintToServer("[Validate] Unable to parse configuration file: %s", szPath);
        return Plugin_Handled;
    }

    if (!kv.GotoFirstSubKey())
    {
        delete kv;
        PrintToServer("[Validate] No teams found.");
        return Plugin_Handled;
    }

    int iMissing, iTotal;
    do
    {
        char szTeamName[64], szPlayers[256];
        kv.GetSectionName(szTeamName, sizeof(szTeamName));
        kv.GetString("players", szPlayers, sizeof(szPlayers));

        char szPlayerNames[5][MAX_NAME_LENGTH];
        int iCount = ExplodeString(szPlayers, ",", szPlayerNames, sizeof(szPlayerNames), sizeof(szPlayerNames[]));

        for (int i = 0; i < iCount; i++)
        {
            TrimString(szPlayerNames[i]);
            if (szPlayerNames[i][0] == '\0')
                continue;

            iTotal++;
            if (!IsNameInBotDatabase(szPlayerNames[i]))
            {
                PrintToServer("[Validate] MISSING: \"%s\" (team: %s) not found in bot_info.json", szPlayerNames[i], szTeamName);
                iMissing++;
            }
        }
    }
    while (kv.GotoNextKey());

    delete kv;
    PrintToServer("[Validate] Done. %d/%d players checked, %d missing from bot_info.json.", iTotal, iTotal, iMissing);
    return Plugin_Handled;
}

public void OnMapStart()
{
    g_iProfileRankOffset = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicLevel");
    if (g_iProfileRankOffset == -1)
    {
        LogError("Failed to find m_nPersonaDataPublicLevel offset");
    }
    
    g_iPlayerColorOffset = FindSendPropInfo("CCSPlayerResource", "m_iCompTeammateColor");
    if (g_iPlayerColorOffset == -1)
    {
        LogError("Failed to find m_iCompTeammateColor offset");
    }

    char szMap[PLATFORM_MAX_PATH];
    GetCurrentMap(szMap, sizeof(szMap));
    GetMapDisplayName(szMap, szMap, sizeof(szMap));
    ParseMapNades(szMap);

    g_bIsBombScenario = (FindEntityByClassname(-1, "func_bomb_target") != -1);
    g_bIsHostageScenario = (FindEntityByClassname(-1, "func_hostage_rescue") != -1);

    CreateTimer(1.0, Timer_CheckPlayer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    CreateTimer(0.1, Timer_MoveToBomb, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    g_iPlayerResourceEntity = GetPlayerResourceEntity();
    if (g_iPlayerResourceEntity != -1)
    {
        SDKHook(g_iPlayerResourceEntity, SDKHook_ThinkPost, OnThinkPost);
    }
    else
    {
        LogError("Failed to find player resource entity");
    }

    Array_Fill(g_iPlayerColor, MaxClients + 1, -1);
}

public Action Timer_CheckPlayer(Handle hTimer, any data)
{
	int iHalfRound = g_cvMaxRounds.IntValue / 2;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || !IsFakeClient(i) || !IsPlayerAlive(i))
			continue;

		if (IsItMyChance(2.0))
			FakeClientCommand(i, "+lookatweapon;-lookatweapon");

		bool bInBuyZone = view_as<bool>(GetEntProp(i, Prop_Send, "m_bInBuyZone"));
		if (!bInBuyZone)
			continue;

		int iAccount = GetEntProp(i, Prop_Send, "m_iAccount");
		int iTeam = GetClientTeam(i);
		int iArmor = GetEntProp(i, Prop_Data, "m_ArmorValue");
		bool bHasDefuser = view_as<bool>(GetEntProp(i, Prop_Send, "m_bHasDefuser"));
		bool bHasHelmet = view_as<bool>(GetEntProp(i, Prop_Send, "m_bHasHelmet"));
		int iPrimary = GetPlayerWeaponSlot(i, CS_SLOT_PRIMARY);

		char szCurrentWeapon[64];
		GetClientWeapon(i, szCurrentWeapon, sizeof(szCurrentWeapon));
		bool bDefaultPistol = IsDefaultPistol(szCurrentWeapon);
		
		bool bHasPrimary = IsValidEntity(iPrimary);
		int iFriendsWithPrimary = GetFriendsWithPrimary(i);

		if (g_iCurrentRound == 0 || g_iCurrentRound == iHalfRound)
		{
			int iRand = Math_GetRandomInt(1, 100);
			
			if (iRand <= 2)
				FakeClientCommand(i, "buy %s", (iTeam == CS_TEAM_CT) ? "elite" : "vest");
			else if (iRand <= 32)
				FakeClientCommand(i, "buy %s", (iTeam == CS_TEAM_CT) ? "defuser" : "p250");
			else if (iRand <= 92)
				FakeClientCommand(i, "buy vest");
			
			continue;
		}

		if (bHasPrimary || (iFriendsWithPrimary >= 1 && !bDefaultPistol))
		{
			if (iArmor < 50 || !bHasHelmet)
				FakeClientCommand(i, "buy vesthelm");

			if (iTeam == CS_TEAM_CT && !bHasDefuser)
				FakeClientCommand(i, "buy defuser");

			float fFreezeWindow = g_cvFreezeTime.FloatValue - 2.0;
			if (fFreezeWindow < 0.0)
				fFreezeWindow = 0.0;

			if (GetGameTime() - g_fRoundStart > fFreezeWindow && !g_bFreezetimeEnd)
			{
				FakeClientCommand(i, "buy smokegrenade");
				FakeClientCommand(i, "buy flashbang");
				FakeClientCommand(i, "buy flashbang");
				
				switch (Math_GetRandomInt(1, 3))
				{
					case 1: FakeClientCommand(i, "buy hegrenade");
					case 2: FakeClientCommand(i, "buy molotov");
					case 3:
					{
						FakeClientCommand(i, "buy hegrenade");
						FakeClientCommand(i, "buy molotov");
					}
				}
			}
		}
		else if ((!IsTeamForcing(iTeam) && ((iTeam == CS_TEAM_T) ? g_iAvgMoneyT : g_iAvgMoneyCT) < 3000 && iAccount > 2000 && !bHasPrimary) || iFriendsWithPrimary >= 1)
		{
			BuyEcoPistolAndGear(i, bDefaultPistol, iTeam, bHasDefuser);
		}
	}

	return Plugin_Continue;
}

void BuyEcoPistolAndGear(int client, bool bDefaultPistol, int iTeam, bool bHasDefuser)
{
	if (bDefaultPistol)
	{
		switch (Math_GetRandomInt(1, 5))
		{
			case 1: FakeClientCommand(client, "buy p250");
			case 2: FakeClientCommand(client, "buy tec9");
			case 3: FakeClientCommand(client, "buy deagle");
		}
	}
	else
	{
		switch (Math_GetRandomInt(1, 20))
		{
			case 1: FakeClientCommand(client, "buy vest");
			case 10: FakeClientCommand(client, "buy %s", (iTeam == CS_TEAM_CT && !bHasDefuser) ? "defuser" : "vest");
		}
	}
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

	bool bLastManStanding = (g_iAliveCountT == 0 && g_iAliveCountCT == 1);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || !IsFakeClient(i) || !IsPlayerAlive(i) || GetClientTeam(i) != CS_TEAM_CT)
			continue;

		if (!bLastManStanding && (g_bDontSwitch[i] || GetEntData(i, g_iBotNearbyEnemiesOffset) != 0))
			continue;

		float fDistanceToBomb = GetVectorDistance(g_fBotOrigin[i], fC4Pos);

		if (GetTask(i) == ESCAPE_FROM_BOMB || GetTask(i) == ESCAPE_FROM_FLAMES)
			continue;

		bool bShouldMoveToBomb = (bLastManStanding && fDistanceToBomb > 30.0) || fDistanceToBomb > 2000.0;

		if (bShouldMoveToBomb)
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

    ArrayList ArrayBotsT = new ArrayList(2);
    ArrayList ArrayBotsCT = new ArrayList(2);

    for (int iClient = 1; iClient <= MaxClients; iClient++)
    {
        if (!IsValidClient(iClient) || !IsFakeClient(iClient) || !IsPlayerAlive(iClient) || g_bDropWeapon[iClient])
            continue;

        int iPrimaryWeapon = GetPlayerWeaponSlot(iClient, CS_SLOT_PRIMARY);
        if (!IsValidEntity(iPrimaryWeapon))
            continue;

        int iDefIndex = GetEntProp(iPrimaryWeapon, Prop_Send, "m_iItemDefinitionIndex");
        CSWeaponID pWeaponID = CS_ItemDefIndexToID(iDefIndex);
        if (pWeaponID == CSWeapon_NONE)
            continue;

        int iMoney = GetEntProp(iClient, Prop_Send, "m_iAccount");
        int iWeaponPrice = CS_GetWeaponPrice(iClient, pWeaponID);
        if (iMoney < iWeaponPrice)
            continue;

        GetEntityClassname(iPrimaryWeapon, g_szPreviousBuy[iClient], sizeof(g_szPreviousBuy[]));
        ReplaceString(g_szPreviousBuy[iClient], sizeof(g_szPreviousBuy[]), "weapon_", "");

        int iEntry[2];
        iEntry[0] = iClient;
        iEntry[1] = iMoney;

        int iTeam = GetClientTeam(iClient);
        if (iTeam == CS_TEAM_T)
            ArrayBotsT.PushArray(iEntry);
        else if (iTeam == CS_TEAM_CT)
            ArrayBotsCT.PushArray(iEntry);
    }

    SortADTArrayCustom(ArrayBotsT, Sort_BotMoneyDesc);
    SortADTArrayCustom(ArrayBotsCT, Sort_BotMoneyDesc);

    for (int iClient = 1; iClient <= MaxClients; iClient++)
    {
        if (!IsValidClient(iClient) || !IsPlayerAlive(iClient) || g_bHasGottenDrop[iClient])
            continue;

        if (!GetEntProp(iClient, Prop_Send, "m_bInBuyZone"))
            continue;

        int iPrimaryWeapon = GetPlayerWeaponSlot(iClient, CS_SLOT_PRIMARY);
        int iMoney = GetEntProp(iClient, Prop_Send, "m_iAccount");
        int iTeam = GetClientTeam(iClient);

        if (IsValidEntity(iPrimaryWeapon) || IsTeamForcing(iTeam) || iMoney >= 3000)
            continue;

        ArrayList ArrayTeamBots = (iTeam == CS_TEAM_T) ? ArrayBotsT : ArrayBotsCT;
        
        if (ArrayTeamBots.Length == 0)
            continue;

        int iEntry[2];
        ArrayTeamBots.GetArray(0, iEntry, 2);
        int iDropBot = iEntry[0];
        ArrayTeamBots.Erase(0);

        float fEyePos[3];
        GetClientEyePosition(iClient, fEyePos);
        BotSetLookAt(iDropBot, "Use entity", fEyePos, PRIORITY_HIGH, 3.0, false, 5.0, false);
        
        g_bDropWeapon[iDropBot] = true;
        g_bHasGottenDrop[iClient] = true;
    }

    delete ArrayBotsT;
    delete ArrayBotsCT;

    return Plugin_Continue;
}

public void OnMapEnd()
{
	if (g_iPlayerResourceEntity != -1 && IsValidEntity(g_iPlayerResourceEntity))
		SDKUnhook(g_iPlayerResourceEntity, SDKHook_ThinkPost, OnThinkPost);

	g_iPlayerResourceEntity = -1;
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

    g_bIsProBot[client] = IsBotInDatabase(client);

    if (g_bIsProBot[client])
    {
        GetBotCrosshairCode(client, g_szCrosshairCode[client], sizeof(g_szCrosshairCode[]));

        char szBotName[MAX_NAME_LENGTH];
        GetClientName(client, szBotName, sizeof(szBotName));

        if (IsTopBot(szBotName))
        {
            g_fLookAngleMaxAccel[client] = 100000.0;
            g_fReactionTime[client] = 0.0;
            g_fAggression[client] = 1.0;
        }
        else
        {
            g_fLookAngleMaxAccel[client] = Math_GetRandomFloat(4000.0, 7000.0);
            g_fReactionTime[client] = Math_GetRandomFloat(0.165, 0.325);
            g_fAggression[client] = Math_GetRandomFloat(0.0, 1.0);
        }
    }

    g_bUseUSP[client] = IsItMyChance(75.0);
    g_bUseM4A1S[client] = IsItMyChance(50.0);
    g_bUseCZ75[client] = IsItMyChance(20.0);
    g_pCurrArea[client] = INVALID_NAV_AREA;
}

public void OnRoundPreStart(Event eEvent, const char[] szName, bool bDontBroadcast)
{
    g_iCurrentRound = GameRules_GetProp("m_totalRoundsPlayed");

    g_bForceT = false;
    g_bForceCT = false;

    int iOvertimePlaying = GameRules_GetProp("m_nOvertimePlaying");
    GamePhase pGamePhase = view_as<GamePhase>(GameRules_GetProp("m_gamePhase"));

    if (g_cvHalftime.BoolValue && pGamePhase == GAMEPHASE_PLAYING_FIRST_HALF)
    {
        int iRoundsBeforeHalftime = iOvertimePlaying ? g_cvMaxRounds.IntValue + ((2 * iOvertimePlaying - 1) * (g_cvOTMaxRounds.IntValue / 2)) : (g_cvMaxRounds.IntValue / 2);
        if (iRoundsBeforeHalftime > 0 && g_iRoundsPlayed == iRoundsBeforeHalftime - 1)
        {
            g_bHalftimeSwitch = true;
            g_bForceT = true;
            g_bForceCT = true;
        }
    }

    if (pGamePhase != GAMEPHASE_PLAYING_FIRST_HALF)
    {
        int iNumWinsToClinch = GetNumWinsToClinch();
        if (g_iCTScore == iNumWinsToClinch - 1)
            g_bForceT = true;
        if (g_iTScore == iNumWinsToClinch - 1)
            g_bForceCT = true;
    }

    if (g_cvMaxRounds.IntValue > 0)
    {
        int iLastRound = (g_cvMaxRounds.IntValue - 1) + (iOvertimePlaying * g_cvOTMaxRounds.IntValue);
        if (g_iCurrentRound == iLastRound)
        {
            g_bForceT = true;
            g_bForceCT = true;
        }
    }
}

public void OnRoundStart(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	g_bFreezetimeEnd = false;
	g_bBombPlanted = false;
	g_fRoundStart = GetGameTime();
	g_bHalftimeSwitch = false;

	bool bIsScenario = g_bIsBombScenario || g_bIsHostageScenario;
	int iTeam = g_bIsBombScenario ? CS_TEAM_CT : CS_TEAM_T;
	int iOppositeTeam = g_bIsBombScenario ? CS_TEAM_T : CS_TEAM_CT;

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
		g_fEnemyLostTime[i] = 0.0;
		g_bWasEnemyVisible[i] = false;

		if (bIsScenario)
		{
			int iClientTeam = GetClientTeam(i);

			if (iClientTeam == iTeam)
				SetEntData(i, g_iBotMoraleOffset, -3);
			else if (g_bHalftimeSwitch && iClientTeam == iOppositeTeam)
				SetEntData(i, g_iBotMoraleOffset, 1);
		}
	}

	g_iAvgMoneyT = GetTeamAverageMoney(CS_TEAM_T);
	g_iAvgMoneyCT = GetTeamAverageMoney(CS_TEAM_CT);

	if (g_bIsCompetitive)
		CreateTimer(0.2, Timer_DropWeapons, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public void OnRoundEnd(Event eEvent, const char[] szName, bool bDontBroadcast)
{
    int iEnt = -1;
    
    while ((iEnt = FindEntityByClassname(iEnt, "cs_team_manager")) != -1)
    {
        int iTeamNum = GetEntProp(iEnt, Prop_Send, "m_iTeamNum");
        int iScore = GetEntProp(iEnt, Prop_Send, "m_scoreTotal");

        if (iTeamNum == CS_TEAM_CT)
            g_iCTScore = iScore;
        else if (iTeamNum == CS_TEAM_T)
            g_iTScore = iScore;
    }
    
    g_iRoundsPlayed = GameRules_GetProp("m_totalRoundsPlayed");
}

public void OnFreezetimeEnd(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	g_bFreezetimeEnd = true;
	g_fFreezeTimeEnd = GetGameTime();
	UpdateAliveTeamCounts();
}

public void OnBombPlanted(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	g_bBombPlanted = true;

	int iPlantedC4 = FindEntityByClassname(-1, "planted_c4");
	if (IsValidEntity(iPlantedC4))
		GetEntPropVector(iPlantedC4, Prop_Send, "m_vecOrigin", g_fBombPos);
}

public void OnBombDefused(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	g_bBombPlanted = false;
}

public void OnPlayerDeath(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	UpdateAliveTeamCounts();
}

void UpdateAliveTeamCounts()
{
	g_iAliveCountT = 0;
	g_iAliveCountCT = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || !IsPlayerAlive(i))
			continue;

		int iTeam = GetClientTeam(i);
		if (iTeam == CS_TEAM_T)
			g_iAliveCountT++;
		else if (iTeam == CS_TEAM_CT)
			g_iAliveCountCT++;
	}
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

	char szWeaponName[32];
	eEvent.GetString("weapon", szWeaponName, sizeof(szWeaponName));

	if (IsValidClient(g_iTarget[client]) && StrEqual(szWeaponName, "weapon_deagle"))
	{
		float fTargetLoc[3];
		GetClientAbsOrigin(g_iTarget[client], fTargetLoc);
		
		float fRangeToEnemy = GetVectorDistance(g_fBotOrigin[client], fTargetLoc);
		if (fRangeToEnemy > 100.0)
			SetEntDataFloat(client, g_iFireWeaponOffset, GetEntDataFloat(client, g_iFireWeaponOffset) + Math_GetRandomFloat(0.20, 0.40));
	}

	if ((StrEqual(szWeaponName, "weapon_awp") || StrEqual(szWeaponName, "weapon_ssg08")) && IsItMyChance(50.0))
		RequestFrame(BeginQuickSwitch, GetClientUserId(client));
}

public void OnPlayerJump(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(eEvent.GetInt("userid"));
	if (!IsValidClient(client) || !IsPlayerAlive(client))
		return;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (i == client || !IsValidClient(i) || !IsPlayerAlive(i) || !IsFakeClient(i) || GetClientTeam(i) == GetClientTeam(client))
			continue;

		BotOnAudibleEvent(i, eEvent, client, 1100.0, PRIORITY_LOW, false);
	}
}

public void OnBombBeginPlant(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	int iPlanter = GetClientOfUserId(eEvent.GetInt("userid"));
	if (!IsValidClient(iPlanter) || !IsPlayerAlive(iPlanter))
		return;
		
	float fPlanterOrigin[3];
	GetClientAbsOrigin(iPlanter, fPlanterOrigin);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (i == iPlanter || !IsValidClient(i) || !IsPlayerAlive(i) || !IsFakeClient(i) || GetClientTeam(i) == GetClientTeam(iPlanter))
			continue;

		BotOnAudibleEvent(i, eEvent, iPlanter, 1100.0, PRIORITY_HIGH, true, false, fPlanterOrigin);
	}
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

	int iTeam = GetClientTeam(client);
	int iAccount = GetEntProp(client, Prop_Send, "m_iAccount");
	int iOwnAvgMoney = (iTeam == CS_TEAM_T) ? g_iAvgMoneyT : g_iAvgMoneyCT;
	bool bIsResetRound = IsResetRound();
	bool bIsEco = !bIsResetRound && !IsTeamForcing(iTeam) && iOwnAvgMoney < 3000;
	bool bIsFullSave = bIsEco && iAccount < 2000;

	if (strcmp(szWeapon, "vest") == 0 || strcmp(szWeapon, "vesthelm") == 0 || strcmp(szWeapon, "defuser") == 0)
		return bIsFullSave ? Plugin_Handled : Plugin_Continue;

	if (strcmp(szWeapon, "molotov") == 0 || strcmp(szWeapon, "incgrenade") == 0 || strcmp(szWeapon, "decoy") == 0 ||
	    strcmp(szWeapon, "flashbang") == 0 || strcmp(szWeapon, "hegrenade") == 0 || strcmp(szWeapon, "smokegrenade") == 0)
		return bIsEco ? Plugin_Handled : Plugin_Continue;

	if (strcmp(szWeapon, "p250") == 0 || strcmp(szWeapon, "tec9") == 0 || strcmp(szWeapon, "fiveseven") == 0 ||
	    strcmp(szWeapon, "deagle") == 0 || strcmp(szWeapon, "elite") == 0 || strcmp(szWeapon, "cz75a") == 0 ||
	    strcmp(szWeapon, "hkp2000") == 0 || strcmp(szWeapon, "usp_silencer") == 0 || strcmp(szWeapon, "glock") == 0 ||
	    strcmp(szWeapon, "revolver") == 0)
		return bIsFullSave ? Plugin_Handled : Plugin_Continue;

	if (bIsEco)
		return Plugin_Handled;

	if (GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) != -1 &&
	    (strcmp(szWeapon, "galilar") == 0 || strcmp(szWeapon, "famas") == 0 || strcmp(szWeapon, "ak47") == 0 ||
	     strcmp(szWeapon, "m4a1") == 0 || strcmp(szWeapon, "ssg08") == 0 || strcmp(szWeapon, "aug") == 0 ||
	     strcmp(szWeapon, "sg556") == 0 || strcmp(szWeapon, "awp") == 0 || strcmp(szWeapon, "scar20") == 0 ||
	     strcmp(szWeapon, "g3sg1") == 0 || strcmp(szWeapon, "nova") == 0 || strcmp(szWeapon, "xm1014") == 0 ||
	     strcmp(szWeapon, "mag7") == 0 || strcmp(szWeapon, "m249") == 0 || strcmp(szWeapon, "negev") == 0 ||
	     strcmp(szWeapon, "mac10") == 0 || strcmp(szWeapon, "mp9") == 0 || strcmp(szWeapon, "mp7") == 0 ||
	     strcmp(szWeapon, "ump45") == 0 || strcmp(szWeapon, "p90") == 0 || strcmp(szWeapon, "bizon") == 0))
		return Plugin_Handled;

	int iEnemyAvgMoney = (iTeam == CS_TEAM_CT) ? g_iAvgMoneyT : g_iAvgMoneyCT;

	if ((strcmp(szWeapon, "ak47") == 0 || strcmp(szWeapon, "m4a1") == 0) && !g_bForceT && !g_bForceCT && !IsValidEntity(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY)) && IsItMyChance(40.0) && iEnemyAvgMoney < 2500)
	{
		if (iTeam == CS_TEAM_T && iAccount >= CS_GetWeaponPrice(client, CSWeapon_MAC10))
		{
			ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_mac10", true);
			return Plugin_Changed;
		}
		else if (iTeam == CS_TEAM_CT && iAccount >= CS_GetWeaponPrice(client, CSWeapon_MP9))
		{
			ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_mp9", true);
			return Plugin_Changed;
		}
	}

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

public MRESReturn CCSBot_OnAudibleEvent(int iBot, DHookParam hParams)
{
	int client = hParams.Get(2);
	if (!IsValidClient(client) || GetClientTeam(iBot) == GetClientTeam(client))
		return MRES_Ignored;

	Address pActualOrigin = view_as<Address>(hParams.Get(7));
	if (pActualOrigin != Address_Null)
	{
		// Sound origin override (decoys, etc.)
		g_fOriginalNoisePos[iBot][0] = view_as<float>(LoadFromAddress(pActualOrigin, NumberType_Int32));
		g_fOriginalNoisePos[iBot][1] = view_as<float>(LoadFromAddress(pActualOrigin + view_as<Address>(4), NumberType_Int32));
		g_fOriginalNoisePos[iBot][2] = view_as<float>(LoadFromAddress(pActualOrigin + view_as<Address>(8), NumberType_Int32));
	}
	else
	{
		// Player's origin (ground level)
		GetClientAbsOrigin(client, g_fOriginalNoisePos[iBot]);
	}

	return MRES_Ignored;
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
	else if (strcmp(szDesc, "Last Enemy Position") == 0)
	{
		g_fEnemyLostTime[client] = GetGameTime();
		g_bWasEnemyVisible[client] = true;

		if (IsValidClient(g_iTarget[client]) && IsPlayerAlive(g_iTarget[client]) && CanThrowNade(client) && IsItMyChance(1.0) && GetTask(client) != ESCAPE_FROM_BOMB && GetTask(client) != ESCAPE_FROM_FLAMES && GetEntityMoveType(client) != MOVETYPE_LADDER)
		{
			float fPos[3];
			DHookGetParamVector(hParams, 2, fPos);

			int iNades[] = {DEFIDX_HE, DEFIDX_MOLOTOV, DEFIDX_INCENDIARY, DEFIDX_FLASH, DEFIDX_SMOKE};
			int iNade = FindNadeByDefIndex(client, iNades, sizeof(iNades));
			if (iNade != -1 && ProcessGrenadeThrow(client, fPos, iNade))
				return MRES_Supercede;
		}

		return MRES_Ignored;
	}
	else if (strcmp(szDesc, "GrenadeThrowBend") == 0)
	{
		if (g_bThrowGrenade[client])
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
		DHookGetParamVector(hParams, 2, fNoisePos);

		if (IsItMyChance(15.0) && IsPointVisible(fClientEyes, fNoisePos) && LineGoesThroughSmoke(fClientEyes, fNoisePos) && !bIsWalking)
			DHookSetParam(hParams, 7, true);

		if (CanThrowNade(client) && IsItMyChance(3.0) && GetTask(client) != ESCAPE_FROM_BOMB && GetTask(client) != ESCAPE_FROM_FLAMES && GetEntityMoveType(client) != MOVETYPE_LADDER)
		{
			int iNades[] = {DEFIDX_HE, DEFIDX_MOLOTOV, DEFIDX_INCENDIARY, DEFIDX_FLASH};
			int iNade = FindNadeByDefIndex(client, iNades, sizeof(iNades));
			if (iNade != -1 && (ProcessGrenadeThrow(client, g_fOriginalNoisePos[client], iNade) || ProcessGrenadeThrow(client, fNoisePos, iNade)))
				return MRES_Supercede;
		}

		if (BotMimic_IsPlayerMimicing(client))
		{
			if (g_iDoingSmokeNum[client] != -1)
				SetNadeTimestamp(g_iDoingSmokeNum[client], GetGameTime());

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
		float fPos[3];
		DHookGetParamVector(hParams, 2, fPos);

		if (CanThrowNade(client) && IsItMyChance(25.0) && GetTask(client) != ESCAPE_FROM_BOMB && GetTask(client) != ESCAPE_FROM_FLAMES && GetEntityMoveType(client) != MOVETYPE_LADDER)
		{
			int iNades[] = {DEFIDX_HE, DEFIDX_MOLOTOV, DEFIDX_INCENDIARY, DEFIDX_FLASH, DEFIDX_SMOKE};
			int iNade = FindNadeByDefIndex(client, iNades, sizeof(iNades));
			if (iNade != -1 && (ProcessGrenadeThrow(client, g_fOriginalNoisePos[client], iNade) || ProcessGrenadeThrow(client, fPos, iNade)))
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

	float fMoveDelta = GetVectorDistance(g_fBotOrigin[client], g_fLastNavUpdate[client]);
	if (fMoveDelta > 32.0 || g_pCurrArea[client] == INVALID_NAV_AREA)
	{
		g_pCurrArea[client] = NavMesh_GetNearestArea(g_fBotOrigin[client]);
		Array_Copy(g_fBotOrigin[client], g_fLastNavUpdate[client], 3);
	}

	if ((g_iAliveCountT == 0 || g_iAliveCountCT == 0) && !g_bDontSwitch[client])
	{
		SDKCall(g_hSwitchWeaponCall, client, GetPlayerWeaponSlot(client, CS_SLOT_KNIFE), 0);
		
		if (BotMimic_IsPlayerMimicing(client))
            BotMimic_StopPlayerMimic(client);
			
		ResetNadeTimestamps();
		g_iDoingSmokeNum[client] = -1;
	}

	if (g_iDoingSmokeNum[client] == -1 && fNow >= g_fNadeLineupCooldown[client])
	{
		g_iDoingSmokeNum[client] = GetNearestGrenade(client);
		g_fNadeLineupCooldown[client] = fNow + 1.0;
	}

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
		NadeLineup nade;
		g_aNades.GetArray(g_iDoingSmokeNum[client], nade);
		SetNadeTimestamp(g_iDoingSmokeNum[client], fNow);
		float fDisToNade = GetVectorDistance(g_fBotOrigin[client], nade.fPos);
		BotMoveTo(client, nade.fPos, FASTEST_ROUTE);
		if (fDisToNade < 25.0)
		{
			BotSetLookAt(client, "Use entity", nade.fLook, PRIORITY_HIGH, 2.0, false, 3.0, false);
			if (view_as<LookAtSpotState>(GetEntData(client, g_iBotLookAtSpotStateOffset)) == LOOK_AT_SPOT && fSpeed == 0.0 && (GetEntityFlags(client) & FL_ONGROUND))
				BotMimic_PlayRecordFromFile(client, nade.szReplay);
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

	if (g_bIsProBot[client] && !g_bBombPlanted && GetTask(client) != COLLECT_HOSTAGES && GetTask(client) != RESCUE_HOSTAGES && GetTask(client) != GUARD_LOOSE_BOMB && GetTask(client) != PLANT_BOMB && GetTask(client) != ESCAPE_FROM_FLAMES)
	{
		if (fNow >= g_fWeaponPickupCooldown[client])
		{
			ProcessWeaponPickup(client);
			g_fWeaponPickupCooldown[client] = fNow + 0.5;
		}
	}

	if (g_bIsProBot[client] && GetDisposition(client) != IGNORE_ENEMIES)
		ProcessCombat(client, iButtons, fVel, fAngles, iDefIndex, fSpeed, fNow);

	if (g_bIsProBot[client] && CanThrowNade(client) && !g_bThrowGrenade[client] && !BotMimic_IsPlayerMimicing(client) && GetEntityMoveType(client) != MOVETYPE_LADDER && GetTask(client) != ESCAPE_FROM_BOMB && GetTask(client) != ESCAPE_FROM_FLAMES)
	{
		bool bIsEnemyVisible = !!GetEntData(client, g_iEnemyVisibleOffset);

		if (!bIsEnemyVisible && !g_bWasEnemyVisible[client] && g_fEnemyLostTime[client] == 0.0)
		{
			Address pBot = GetEntityAddress(client);
			Address pEncounterArea = view_as<Address>(LoadFromAddress(pBot + view_as<Address>(g_iBotInitialEncounterAreaOffset), NumberType_Int32));

			if (pEncounterArea != Address_Null)
			{
				int iEnemyTeam = (GetClientTeam(client) == CS_TEAM_T) ? CS_TEAM_CT : CS_TEAM_T;
				float fEnemyOccupy = view_as<float>(LoadFromAddress(pEncounterArea + view_as<Address>(184 + (iEnemyTeam % 2) * 4), NumberType_Int32));
				float fElapsed = fNow - g_fFreezeTimeEnd;
				float fDelta = fEnemyOccupy - fElapsed;

				if (fDelta <= 5.0 && fDelta > -3.0 && IsItMyChance(5.0))
				{
					int iAreaID = LoadFromAddress(pEncounterArea + view_as<Address>(132), NumberType_Int32);
					CNavArea encounterArea = NavMesh_FindAreaByID(iAreaID);

					if (encounterArea != INVALID_NAV_AREA)
					{
						float fTarget[3];
						encounterArea.GetCenter(fTarget);

						int iNades[] = {DEFIDX_MOLOTOV, DEFIDX_INCENDIARY, DEFIDX_HE, DEFIDX_FLASH, DEFIDX_SMOKE};
						int iNade = FindNadeByDefIndex(client, iNades, sizeof(iNades));
						if (iNade != -1)
							ProcessGrenadeThrow(client, fTarget, iNade);
					}

					StoreToAddress(pBot + view_as<Address>(g_iBotInitialEncounterAreaOffset), 0, NumberType_Int32);
				}
				else if (fDelta <= -3.0)
				{
					StoreToAddress(pBot + view_as<Address>(g_iBotInitialEncounterAreaOffset), 0, NumberType_Int32);
				}
			}
		}

		if (g_bBombPlanted && !bIsEnemyVisible && GetClientTeam(client) == CS_TEAM_T && IsEnemyNearBomb() && IsItMyChance(0.5))
		{
			float fClientEyes[3];
			GetClientEyePosition(client, fClientEyes);

			if (!IsPointVisible(fClientEyes, g_fBombPos))
			{
				int iDenialNades[] = {DEFIDX_MOLOTOV, DEFIDX_INCENDIARY, DEFIDX_HE};
				int iNade = FindNadeByDefIndex(client, iDenialNades, sizeof(iDenialNades));
				if (iNade != -1)
					ProcessGrenadeThrow(client, g_fBombPos, iNade);
			}
		}
	}

	return Plugin_Changed;
}

void ProcessWeaponPickup(int client)
{
	float fClientEyes[3];
	GetClientEyePosition(client, fClientEyes);

	int iSkipAK[2] = {DEFIDX_AK47, DEFIDX_AWP};
	TryPickupWeapon(client, "weapon_ak47", iSkipAK, sizeof(iSkipAK), CS_SLOT_PRIMARY, fClientEyes, g_fBotOrigin[client]);

	int iSkipM4[4] = {DEFIDX_AK47, DEFIDX_AWP, DEFIDX_M4A4, DEFIDX_M4A1S};
	TryPickupWeapon(client, "weapon_m4a1", iSkipM4, sizeof(iSkipM4), CS_SLOT_PRIMARY, fClientEyes, g_fBotOrigin[client]);

	int iSkipDeagle[1] = {DEFIDX_DEAGLE};
	TryPickupWeapon(client, "weapon_deagle", iSkipDeagle, sizeof(iSkipDeagle), CS_SLOT_SECONDARY, fClientEyes, g_fBotOrigin[client]);

	int iSkipTec9[5] = {DEFIDX_DEAGLE, DEFIDX_TEC9, DEFIDX_FIVESEVEN, DEFIDX_CZ75, DEFIDX_DUALIES};
	TryPickupWeapon(client, "weapon_tec9", iSkipTec9, sizeof(iSkipTec9), CS_SLOT_SECONDARY, fClientEyes, g_fBotOrigin[client]);
	TryPickupWeapon(client, "weapon_fiveseven", iSkipTec9, sizeof(iSkipTec9), CS_SLOT_SECONDARY, fClientEyes, g_fBotOrigin[client]);

	int iSkipP250[6] = {DEFIDX_DEAGLE, DEFIDX_TEC9, DEFIDX_FIVESEVEN, DEFIDX_CZ75, DEFIDX_P250, DEFIDX_DUALIES};
	TryPickupWeapon(client, "weapon_p250", iSkipP250, sizeof(iSkipP250), CS_SLOT_SECONDARY, fClientEyes, g_fBotOrigin[client]);

	int iSkipUSP[8] = {DEFIDX_DEAGLE, DEFIDX_TEC9, DEFIDX_FIVESEVEN, DEFIDX_CZ75, DEFIDX_P250, DEFIDX_P2000, DEFIDX_USPS, DEFIDX_DUALIES};
	TryPickupWeapon(client, "weapon_hkp2000", iSkipUSP, sizeof(iSkipUSP), CS_SLOT_SECONDARY, fClientEyes, g_fBotOrigin[client]);
}

void ProcessCombat(int client, int &iButtons, float fVel[3], float fAngles[3], int iDefIndex, float fSpeed, float fNow)
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

	if (bIsHiding && (iDefIndex == DEFIDX_AUG || iDefIndex == DEFIDX_SG556) && iZoomLevel == 0)
		iButtons |= IN_ATTACK2;
	else if (!bIsHiding && (iDefIndex == DEFIDX_AUG || iDefIndex == DEFIDX_SG556) && iZoomLevel == 1)
		iButtons |= IN_ATTACK2;

	if (bIsHiding && g_bUncrouch[client])
		iButtons &= ~IN_DUCK;

	if (!IsValidClient(g_iTarget[client]) || !IsPlayerAlive(g_iTarget[client]) || g_fTargetPos[client][2] == 0.0)
	{
		g_bWasEnemyVisible[client] = false;
		g_fEnemyLostTime[client] = 0.0;
		g_iPrevTarget[client] = g_iTarget[client];
		return;
	}

	if (BotMimic_IsPlayerMimicing(client))
	{
		if (g_iDoingSmokeNum[client] != -1)
			SetNadeTimestamp(g_iDoingSmokeNum[client], fNow);

		BotMimic_StopPlayerMimic(client);
	}

	if ((eItems_GetWeaponSlotByDefIndex(iDefIndex) == CS_SLOT_KNIFE || eItems_GetWeaponSlotByDefIndex(iDefIndex) == CS_SLOT_GRENADE) && GetTask(client) != ESCAPE_FROM_BOMB && GetTask(client) != ESCAPE_FROM_FLAMES)
		BotEquipBestWeapon(client, true);

	if (bIsEnemyVisible && GetEntityMoveType(client) != MOVETYPE_LADDER)
	{
		g_bWasEnemyVisible[client] = true;

		if (g_iPrevTarget[client] == -1)
			g_fCrouchTimestamp[client] = fNow + Math_GetRandomFloat(0.23, 0.25);
		fTargetDistance = GetVectorDistance(g_fBotOrigin[client], g_fTargetPos[client]);

		float fClientEyes[3], fClientAngles[3], fAimPunchAngle[3], fToAimSpot[3], fAimDir[3];
		GetClientEyePosition(client, fClientEyes);
		SubtractVectors(g_fTargetPos[client], fClientEyes, fToAimSpot);
		GetClientEyeAngles(client, fClientAngles);
		GetEntPropVector(client, Prop_Send, "m_aimPunchAngle", fAimPunchAngle);
		ScaleVector(fAimPunchAngle, g_cvRecoilScale.FloatValue);
		AddVectors(fClientAngles, fAimPunchAngle, fClientAngles);
		GetViewVector(fClientAngles, fAimDir);

		float fRangeToEnemy = NormalizeVector(fToAimSpot, fToAimSpot);
		float fOnTarget = GetVectorDotProduct(fToAimSpot, fAimDir);
		float fAimTolerance = Cosine(ArcTangent(32.0 / fRangeToEnemy));

		if (g_iPrevTarget[client] == -1 && fOnTarget > fAimTolerance)
			g_fCrouchTimestamp[client] = fNow + Math_GetRandomFloat(0.23, 0.25);

		if (IsRifleOrHeavy(iDefIndex) || IsSprayWeapon(iDefIndex))
		{
			bool bIsSpray = IsSprayWeapon(iDefIndex);

			if (fOnTarget > fAimTolerance && !bIsDucking && fTargetDistance < 2000.0 && !bIsSpray)
				AutoStop(client, fVel, fAngles);
			else if (fTargetDistance > 2000.0 && GetEntDataFloat(client, g_iFireWeaponOffset) == fNow)
				AutoStop(client, fVel, fAngles);
			if (fOnTarget > fAimTolerance && fTargetDistance < 2000.0)
			{
				iButtons &= ~IN_ATTACK;
				if (!bIsReloading && (fSpeed < 50.0 || bIsDucking || bIsSpray))
				{
					iButtons |= IN_ATTACK;
					SetEntDataFloat(client, g_iFireWeaponOffset, fNow);
				}
			}
		}
		else if (iDefIndex == DEFIDX_DEAGLE)
		{
			if (fNow - GetEntDataFloat(client, g_iFireWeaponOffset) < 0.15 && !bIsDucking && !bIsReloading)
				AutoStop(client, fVel, fAngles);
		}
		else if (iDefIndex == DEFIDX_AWP || iDefIndex == DEFIDX_SSG08)
		{
			if (fTargetDistance < 2750.0 && !bIsReloading && GetEntProp(client, Prop_Send, "m_bIsScoped") && fNow - g_fShootTimestamp[client] > 0.4 && GetClientAimTarget(client, true) == g_iTarget[client])
			{
				iButtons |= IN_ATTACK;
				SetEntDataFloat(client, g_iFireWeaponOffset, fNow);
			}
		}

		float fClientLoc[3];
		Array_Copy(g_fBotOrigin[client], fClientLoc, 3);
		fClientLoc[2] += HalfHumanHeight;
		if (fNow >= g_fCrouchTimestamp[client] && !GetEntProp(g_iActiveWeapon[client], Prop_Data, "m_bInReload") && IsPointVisible(fClientLoc, g_fTargetPos[client]) && fOnTarget > fAimTolerance && fTargetDistance < 2000.0 && IsRifleOrHeavy(iDefIndex))
			iButtons |= IN_DUCK;

		g_iPrevTarget[client] = g_iTarget[client];
	}
	else
	{
		g_iPrevTarget[client] = g_iTarget[client];
	}
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
	g_iProfileRank[client] = 0;
	g_iPlayerColor[client] = -1;
	g_bIsProBot[client] = false;
	g_bUseCZ75[client] = false;
	g_bUseUSP[client] = false;
	g_bUseM4A1S[client] = false;
	g_bDontSwitch[client] = false;
	g_bDropWeapon[client] = false;
	g_bHasGottenDrop[client] = false;
	g_bThrowGrenade[client] = false;
	g_bUncrouch[client] = false;
	g_iTarget[client] = -1;
	g_iPrevTarget[client] = -1;
	g_iDoingSmokeNum[client] = -1;
	g_iActiveWeapon[client] = -1;
	g_fLookAngleMaxAccel[client] = 0.0;
	g_fReactionTime[client] = 0.0;
	g_fAggression[client] = 0.0;
	g_fShootTimestamp[client] = 0.0;
	g_fThrowNadeTimestamp[client] = 0.0;
	g_fCrouchTimestamp[client] = 0.0;
	g_fWeaponPickupCooldown[client] = 0.0;
	g_fNadeLineupCooldown[client] = 0.0;
	g_fEnemyLostTime[client] = 0.0;
	g_bWasEnemyVisible[client] = false;
	g_pCurrArea[client] = INVALID_NAV_AREA;
	g_szCrosshairCode[client][0] = '\0';
}

void ParseMapNades(const char[] szMap)
{
	delete g_aNades;
	g_aNades = new ArrayList(sizeof(NadeLineup));

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
	
	do
	{
		NadeLineup nade;
		char szTeam[4];

		kv.GetVector("position", nade.fPos);
		kv.GetVector("lookat", nade.fLook);
		nade.iDefIndex = kv.GetNum("nadedefindex");
		kv.GetString("replay", nade.szReplay, sizeof(nade.szReplay));
		nade.fTimestamp = kv.GetFloat("timestamp");

		nade.iTeam = CS_TEAM_NONE;
		kv.GetString("team", szTeam, sizeof(szTeam));
		if (strcmp(szTeam, "CT", false) == 0)
			nade.iTeam = CS_TEAM_CT;
		else if (strcmp(szTeam, "T", false) == 0)
			nade.iTeam = CS_TEAM_T;

		g_aNades.PushArray(nade);
	}
	while (kv.GotoNextKey());
	
	delete kv;
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
	g_iBotInitialEncounterAreaOffset = SetupOffset(hConf, "CCSBot::m_initialEncounterArea");

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

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CCSBot::OnAudibleEvent");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer, VDECODE_FLAG_ALLOWNULL);
	if ((g_hOnAudibleEvent = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall: CCSBot::OnAudibleEvent");

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
	SetupDetour(hConf, "CCSBot::OnAudibleEvent", Hook_Pre, CCSBot_OnAudibleEvent);

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

void BotOnAudibleEvent(int iBot, Event eEvent, int iPlayer, float fRange, PriorityType iPriority, bool bIsHostile, bool bIsFootstep = false, const float fActualOrigin[3] = NULL_VECTOR)
{
	SDKCall(g_hOnAudibleEvent, iBot, eEvent, iPlayer, fRange, iPriority, bIsHostile, bIsFootstep, fActualOrigin);
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

bool IsEnemyNearBomb()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || !IsPlayerAlive(i) || GetClientTeam(i) != CS_TEAM_CT)
			continue;

		float fPos[3];
		GetClientAbsOrigin(i, fPos);
		if (GetVectorDistance(fPos, g_fBombPos) < 500.0)
			return true;
	}
	return false;
}

int FindNadeByDefIndex(int client, const int[] iDefIndices, int iCount)
{
	for (int i = 0; i < iCount; i++)
	{
		int iWeapon = eItems_FindWeaponByDefIndex(client, iDefIndices[i]);
		if (IsValidEntity(iWeapon))
			return iWeapon;
	}
	return -1;
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

    if (iCurrent == -1 || !bSkip)
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
	delete hDetour;
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

	for (int i = 0; i < g_aNades.Length; i++)
	{
		NadeLineup nade;
		g_aNades.GetArray(i, nade);

		if ((GetGameTime() - nade.fTimestamp) < 25.0)
			continue;

		if (GetClientTeam(client) != nade.iTeam)
			continue;

		int iEntity = eItems_FindWeaponByDefIndex(client, nade.iDefIndex);
		if (!IsValidEntity(iEntity))
			continue;

		fDist = GetVectorDistance(fOrigin, nade.fPos);
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
		char szAlias[64];
		strcopy(szAlias, sizeof(szAlias), szClass);
		ReplaceString(szAlias, sizeof(szAlias), "weapon_", "");
		CSWeaponID iWeaponID = CS_AliasToWeaponID(szAlias);
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
				case DEFIDX_AK47, DEFIDX_AUG, DEFIDX_FAMAS, DEFIDX_GALIL, DEFIDX_M249, DEFIDX_M4A4, DEFIDX_MAC10, DEFIDX_P90, DEFIDX_MP5SD, DEFIDX_UMP45, DEFIDX_XM1014, DEFIDX_BIZON, DEFIDX_MAG7, DEFIDX_NEGEV, DEFIDX_SAWEDOFF, DEFIDX_MP7, DEFIDX_MP9, DEFIDX_NOVA, DEFIDX_SG556, DEFIDX_M4A1S:
				{
					float fTargetDistance = GetVectorDistance(g_fBotOrigin[client], fHead);
					if (IsItMyChance(70.0) && fTargetDistance < 2000.0)
						bShootSpine = true;
				}
				case DEFIDX_AWP, DEFIDX_G3SG1, DEFIDX_SCAR20:
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

stock bool ProcessGrenadeThrow(int client, float fTarget[3], int iGrenadeEnt = -1)
{
	int iGrenadeSlot = iGrenadeEnt != -1 ? iGrenadeEnt : GetPlayerWeaponSlot(client, CS_SLOT_GRENADE);
	if (!IsValidEntity(iGrenadeSlot))
		return false;

	int iNadeDefIndex = GetEntProp(iGrenadeSlot, Prop_Send, "m_iItemDefinitionIndex");

	float fGroundTarget[3];
	fGroundTarget[0] = fTarget[0];
	fGroundTarget[1] = fTarget[1];
	fGroundTarget[2] = fTarget[2];

	float fHeight;
	if (NavMesh_GetGroundHeight(fTarget, fHeight))
		fGroundTarget[2] = fHeight;

	float fLookAt[3];
	if (!SolveGrenadeToss(client, fGroundTarget, fLookAt, iNadeDefIndex))
		return false;

	Array_Copy(fLookAt, g_fNadeTarget[client], 3);
	SDKCall(g_hSwitchWeaponCall, client, iGrenadeSlot, 0);
	RequestFrame(DelayThrow, GetClientUserId(client));
	return true;
}

bool SolveGrenadeToss(int client, const float fTarget[3], float fLookAt[3], int iNadeDefIndex)
{
	float fEyePos[3];
	GetClientEyePosition(client, fEyePos);

	float fDelta[3];
	SubtractVectors(fTarget, fEyePos, fDelta);

	float fTargetDist = GetVectorLength(fDelta);
	if (fTargetDist < 250.0)
		return false;

	float fYaw = ArcTangent2(fDelta[1], fDelta[0]) * 180.0 / FLOAT_PI;
	float fGrav = g_cvGravity.FloatValue * 0.4;
	float fThrowSpeed = 750.0 * 0.9;

	float fBestDist = 999999.0;
	float fBestPitch = 0.0;

	for (float fPitch = -75.0; fPitch <= 75.0; fPitch += 2.0)
	{
		float fLaunchPitch = -10.0 + fPitch + FloatAbs(fPitch) * 10.0 / 90.0;

		float fLandPos[3];
		SimulateGrenade(fEyePos, fYaw, fLaunchPitch, fThrowSpeed, fGrav, iNadeDefIndex, fLandPos);

		float fDist = GetVectorDistance(fLandPos, fTarget);
		if (fDist < fBestDist)
		{
			fBestDist = fDist;
			fBestPitch = fPitch;
		}
	}

	if (fBestDist > 500.0)
		return false;

	for (float fPitch = fBestPitch - 3.0; fPitch <= fBestPitch + 3.0; fPitch += 0.5)
	{
		float fLaunchPitch = -10.0 + fPitch + FloatAbs(fPitch) * 10.0 / 90.0;

		float fLandPos[3];
		SimulateGrenade(fEyePos, fYaw, fLaunchPitch, fThrowSpeed, fGrav, iNadeDefIndex, fLandPos);

		float fDist = GetVectorDistance(fLandPos, fTarget);
		if (fDist < fBestDist)
		{
			fBestDist = fDist;
			fBestPitch = fPitch;
		}
	}

	if (fBestDist > 200.0)
		return false;

	float fDir[3], fAngles[3];
	fAngles[0] = fBestPitch;
	fAngles[1] = fYaw;
	fAngles[2] = 0.0;
	GetAngleVectors(fAngles, fDir, NULL_VECTOR, NULL_VECTOR);

	fLookAt[0] = fEyePos[0] + fDir[0] * 1000.0;
	fLookAt[1] = fEyePos[1] + fDir[1] * 1000.0;
	fLookAt[2] = fEyePos[2] + fDir[2] * 1000.0;

	return true;
}

void SimulateGrenade(const float fEyePos[3], float fYaw, float fLaunchPitch, float fSpeed, float fGravity, int iNadeDefIndex, float fEndPos[3])
{
	float fAngles[3], fDir[3];
	fAngles[0] = fLaunchPitch;
	fAngles[1] = fYaw;
	fAngles[2] = 0.0;

	GetAngleVectors(fAngles, fDir, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(fDir, fDir);

	float fVel[3], fPos[3], fNext[3];
	fVel[0] = fDir[0] * fSpeed;
	fVel[1] = fDir[1] * fSpeed;
	fVel[2] = fDir[2] * fSpeed;

	// Trace 22 units forward from eye, back up 6 units
	float fSpawn[3];
	fSpawn[0] = fEyePos[0] + fDir[0] * 22.0;
	fSpawn[1] = fEyePos[1] + fDir[1] * 22.0;
	fSpawn[2] = fEyePos[2] + fDir[2] * 22.0;

	float fMins[3] = {-2.0, -2.0, -2.0};
	float fMaxs[3] = {2.0, 2.0, 2.0};

	TR_TraceHullFilter(fEyePos, fSpawn, fMins, fMaxs, MASK_SOLID, TraceEntityFilterStuff);
	float fFrac = TR_GetFraction();
	TR_GetEndPosition(fPos);

	// Only back up if we have enough room (don't push behind eyes)
	if (fFrac * 22.0 > 6.0)
	{
		fPos[0] -= fDir[0] * 6.0;
		fPos[1] -= fDir[1] * 6.0;
		fPos[2] -= fDir[2] * 6.0;
	}

	float dt = GetTickInterval();
	int iBounces;
	float fDetonateTime = GetNadeDetonateTime(iNadeDefIndex);
	float fThinkInterval = (iNadeDefIndex == DEFIDX_MOLOTOV || iNadeDefIndex == DEFIDX_INCENDIARY) ? 0.1 : 0.2;
	float fNextThink = fThinkInterval;
	float fMolotovMaxSlopeZ = Cosine(DegToRad(g_cvMolotovMaxSlope.FloatValue));

	for (float t = 0.0; t <= 60.0; t += dt)
	{
		float fNewVelZ = fVel[2] - fGravity * dt;
		float fAvgVelZ = (fVel[2] + fNewVelZ) * 0.5;

		float fMove[3];
		fMove[0] = fVel[0] * dt;
		fMove[1] = fVel[1] * dt;
		fMove[2] = fAvgVelZ * dt;
		fVel[2] = fNewVelZ;

		fNext[0] = fPos[0] + fMove[0];
		fNext[1] = fPos[1] + fMove[1];
		fNext[2] = fPos[2] + fMove[2];

		TR_TraceHullFilter(fPos, fNext, fMins, fMaxs, MASK_SHOT_HULL, TraceEntityFilterStuff);

		if (TR_GetFraction() != 1.0)
		{
			float fFraction = TR_GetFraction();
			TR_GetEndPosition(fNext);

			float fNormal[3];
			TR_GetPlaneNormal(INVALID_HANDLE, fNormal);
			int iHitEnt = TR_GetEntityIndex();

			// Molotov/incendiary ground detonation
			if ((iNadeDefIndex == DEFIDX_MOLOTOV || iNadeDefIndex == DEFIDX_INCENDIARY) && fNormal[2] >= fMolotovMaxSlopeZ)
			{
				if (iHitEnt == 0 || !IsValidClient(iHitEnt))
				{
					Array_Copy(fNext, fEndPos, 3);
					return;
				}
			}

			// Reflect velocity (PhysicsClipVelocity with overbounce 2.0)
			float fDot = GetVectorDotProduct(fVel, fNormal);
			fVel[0] -= 2.0 * fDot * fNormal[0];
			fVel[1] -= 2.0 * fDot * fNormal[1];
			fVel[2] -= 2.0 * fDot * fNormal[2];

			// STOP_EPSILON - zero out tiny velocity components
			for (int i = 0; i < 3; i++)
			{
				if (fVel[i] > -0.1 && fVel[i] < 0.1)
					fVel[i] = 0.0;
			}

			// Apply elasticity
			float fElasticity = 0.45;
			if (iHitEnt > 0)
			{
				if (IsValidClient(iHitEnt))
					fElasticity *= 0.3;
				else if (HasEntProp(iHitEnt, Prop_Send, "m_flElasticity"))
					fElasticity *= GetEntPropFloat(iHitEnt, Prop_Send, "m_flElasticity");
			}

			if (fElasticity > 0.9)
				fElasticity = 0.9;

			ScaleVector(fVel, fElasticity);

			// Speed dampening on floor hits at high speed
			if (fNormal[2] > 0.7)
			{
				float fSpeedSq = GetVectorDotProduct(fVel, fVel);
				if (fSpeedSq > 96000.0)
				{
					float fVelNorm[3];
					NormalizeVector(fVel, fVelNorm);
					float l = GetVectorDotProduct(fVelNorm, fNormal);
					if (l > 0.5)
						ScaleVector(fVel, 1.0 - l + 0.5);
				}

				if (fSpeedSq < 400.0) // 20^2
				{
					fVel[0] = 0.0;
					fVel[1] = 0.0;
					fVel[2] = 0.0;
					Array_Copy(fNext, fEndPos, 3);
					return;
				}
			}

			// Continue for remainder of tick (traced re-push)
			float fRemaining = (1.0 - fFraction) * dt;
			if (fRemaining > 0.0)
			{
				float fPush[3];
				fPush[0] = fNext[0] + fVel[0] * fRemaining;
				fPush[1] = fNext[1] + fVel[1] * fRemaining;
				fPush[2] = fNext[2] + fVel[2] * fRemaining;

				TR_TraceHullFilter(fNext, fPush, fMins, fMaxs, MASK_SHOT_HULL, TraceEntityFilterStuff);
				TR_GetEndPosition(fNext);
			}

			iBounces++;
			if (iBounces > 20)
			{
				Array_Copy(fNext, fEndPos, 3);
				return;
			}
		}

		Array_Copy(fNext, fPos, 3);

		// Think-based detonation
		if (t >= fNextThink)
		{
			switch (iNadeDefIndex)
			{
				case DEFIDX_HE, DEFIDX_FLASH:
				{
					if (t >= fDetonateTime)
					{
						Array_Copy(fPos, fEndPos, 3);
						return;
					}
				}
				case DEFIDX_SMOKE:
				{
					if (GetVectorDotProduct(fVel, fVel) <= 0.01) // 0.1^2
					{
						Array_Copy(fPos, fEndPos, 3);
						return;
					}
				}
				case DEFIDX_DECOY:
				{
					if (GetVectorDotProduct(fVel, fVel) < 0.04) // 0.2^2
					{
						Array_Copy(fPos, fEndPos, 3);
						return;
					}
				}
				case DEFIDX_MOLOTOV, DEFIDX_INCENDIARY:
				{
					if (t >= fDetonateTime)
					{
						Array_Copy(fPos, fEndPos, 3);
						return;
					}
				}
			}
			fNextThink = t + fThinkInterval;
		}
	}

	Array_Copy(fPos, fEndPos, 3);
}

float GetNadeDetonateTime(int iNadeDefIndex)
{
	switch (iNadeDefIndex)
	{
		case DEFIDX_HE, DEFIDX_FLASH:
			return 1.5;
		case DEFIDX_MOLOTOV, DEFIDX_INCENDIARY:
			return g_cvMolotovDetonateTime.FloatValue;
	}
	return 60.0; // smoke/decoy detonate by velocity, not time
}

stock bool LineGoesThroughSmoke(const float fFrom[3], const float fTo[3])
{	
    return SDKCall(g_hIsLineBlockedBySmoke, g_pTheBots, fFrom, fTo);
}

stock bool IsRifleOrHeavy(int iDefIndex)
{
	switch (iDefIndex)
	{
		case DEFIDX_AK47, DEFIDX_AUG, DEFIDX_FAMAS, DEFIDX_GALIL, DEFIDX_M249, DEFIDX_M4A4, DEFIDX_NEGEV, DEFIDX_SG556, DEFIDX_M4A1S:
			return true;
	}
	return false;
}

stock bool IsSprayWeapon(int iDefIndex)
{
	switch (iDefIndex)
	{
		case DEFIDX_MAC10, DEFIDX_P90, DEFIDX_MP5SD, DEFIDX_UMP45, DEFIDX_XM1014, DEFIDX_BIZON, DEFIDX_MP7, DEFIDX_MP9:
			return true;
	}
	return false;
}

int GetTeamAverageMoney(int iTeam)
{
	int iTotal, iCount;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || !IsPlayerAlive(i) || GetClientTeam(i) != iTeam)
			continue;

		iTotal += GetEntProp(i, Prop_Send, "m_iAccount");
		iCount++;
	}
	return iCount > 0 ? iTotal / iCount : 0;
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

stock int GetNumWinsToClinch()
{
	int iOvertimePlaying = GameRules_GetProp("m_nOvertimePlaying");
	int iMaxRounds = g_cvMaxRounds.IntValue;
	bool bCanClinch = g_cvCanClinch.BoolValue;
	int iOvertimeMaxRounds = g_cvOTMaxRounds.IntValue;
	
	return (iMaxRounds > 0 && bCanClinch) ? (iMaxRounds / 2) + 1 + iOvertimePlaying * (iOvertimeMaxRounds / 2) : -1;
}

stock bool IsTeamForcing(int iTeam)
{
	return (iTeam == CS_TEAM_T) ? g_bForceT : g_bForceCT;
}

stock bool IsResetRound()
{
	int iMaxRounds = g_cvMaxRounds.IntValue;
	if (g_iCurrentRound == 0 || g_iCurrentRound == iMaxRounds / 2)
		return true;

	int iOTHalf = g_cvOTMaxRounds.IntValue / 2;
	if (iOTHalf > 0 && g_iCurrentRound >= iMaxRounds && (g_iCurrentRound - iMaxRounds) % iOTHalf == 0)
		return true;

	return false;
}

stock bool IsItMyChance(float fChance)
{
    return (fChance > 0.0) && (Math_GetRandomFloat(0.0, 100.0) <= fChance);
}

stock bool IsValidClient(int client)
{
	return (client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client));
}

void SetNadeTimestamp(int iIndex, float fTime)
{
	NadeLineup nade;
	g_aNades.GetArray(iIndex, nade);
	nade.fTimestamp = fTime;
	g_aNades.SetArray(iIndex, nade);
}

void ResetNadeTimestamps()
{
	for (int i = 0; i < g_aNades.Length; i++)
	{
		NadeLineup nade;
		g_aNades.GetArray(i, nade);
		nade.fTimestamp = 0.0;
		g_aNades.SetArray(i, nade);
	}
}