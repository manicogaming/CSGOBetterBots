#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#include <eItems>
#include <smlib/arrays>
#include <smlib/math>
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

const float HalfHumanHeight = 36.0;

char g_szCrosshairCode[MAXPLAYERS+1][35], g_szPreviousBuy[MAXPLAYERS+1][128];
bool g_bIsBombScenario, g_bIsHostageScenario, g_bFreezetimeEnd, g_bBombPlanted, g_bHalftimeSwitch, g_bIsCompetitive;
bool g_bForceT, g_bForceCT;
bool g_bUseCZ75[MAXPLAYERS+1], g_bUseUSP[MAXPLAYERS+1], g_bUseM4A1S[MAXPLAYERS+1], g_bDontSwitch[MAXPLAYERS+1], g_bDropWeapon[MAXPLAYERS+1], g_bHasGottenDrop[MAXPLAYERS+1], g_bCheapDrop[MAXPLAYERS+1], g_bBuyingCheapDrop[MAXPLAYERS+1];
bool g_bIsProBot[MAXPLAYERS+1], g_bThrowGrenade[MAXPLAYERS+1], g_bUncrouch[MAXPLAYERS+1];
int g_iProfileRank[MAXPLAYERS+1], g_iPlayerColor[MAXPLAYERS+1], g_iTarget[MAXPLAYERS+1], g_iPrevTarget[MAXPLAYERS+1], g_iDoingSmokeNum[MAXPLAYERS+1], g_iActiveWeapon[MAXPLAYERS+1];
int g_iCurrentRound, g_iRoundsPlayed, g_iCTScore, g_iTScore;
int g_iProfileRankOffset, g_iPlayerColorOffset;
int g_iBotTargetSpotOffset, g_iBotNearbyEnemiesOffset, g_iFireWeaponOffset, g_iEnemyVisibleOffset, g_iBotProfileOffset, g_iBotSafeTimeOffset, g_iBotEnemyOffset, g_iBotLookAtSpotStateOffset, g_iBotMoraleOffset, g_iBotTaskOffset, g_iBotDispositionOffset;
float g_fBotOrigin[MAXPLAYERS+1][3], g_fTargetPos[MAXPLAYERS+1][3], g_fNadeTarget[MAXPLAYERS+1][3], g_fNadeSolveTarget[MAXPLAYERS+1][3];
float g_fOriginalNoisePos[MAXPLAYERS+1][3];
float g_fRoundStart, g_fFreezeTimeEnd;
float g_fLookAngleMaxAccel[MAXPLAYERS+1], g_fReactionTime[MAXPLAYERS+1], g_fAggression[MAXPLAYERS+1], g_fShootTimestamp[MAXPLAYERS+1], g_fThrowNadeTimestamp[MAXPLAYERS+1], g_fCrouchTimestamp[MAXPLAYERS+1];
float g_fBombPos[3];
bool g_bNadeResolved[MAXPLAYERS+1];
int g_iNadeSolveDefIndex[MAXPLAYERS+1];
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
Handle g_hTryToRetreat;
Address g_pTheBots;
int g_iPlayerResourceEntity = -1;
int g_iAliveCountT, g_iAliveCountCT;
int g_iAvgMoneyT, g_iAvgMoneyCT;
float g_fWeaponPickupCooldown[MAXPLAYERS+1];
float g_fNadeLineupCooldown[MAXPLAYERS+1];
float g_fNadeArrivedTimestamp[MAXPLAYERS+1];

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

float g_fBotCurrentGoal[MAXPLAYERS+1][3];
float g_fBotNextRepathTime[MAXPLAYERS+1];
RouteType g_eBotCurrentRoute[MAXPLAYERS+1];

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
	version = "1.4.3", 
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
    HookEventEx("bomb_beginplant", OnBombBeginPlant);
    HookEventEx("player_jump", OnPlayerJump);
    
    LoadSDK();
    LoadDetours();
    
    RegConsoleCmd("team", Command_Team);
    RegConsoleCmd("sm_validate_bots", Command_ValidateBots);

}

public Action Command_Team(int iClient, int iArgs)
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

    KeyValues hKv = new KeyValues("Teams");
    if (!hKv.ImportFromFile(szPath))
    {
        delete hKv;
        PrintToServer("Unable to parse configuration file: %s", szPath);
        return Plugin_Handled;
    }

    if (!hKv.JumpToKey(szTeam))
    {
        delete hKv;
        PrintToServer("Unknown team: %s", szTeam);
        return Plugin_Handled;
    }

    char szPlayers[256], szLogo[64];
    hKv.GetString("players", szPlayers, sizeof(szPlayers));
    hKv.GetString("logo", szLogo, sizeof(szLogo), "");
    delete hKv;

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

public Action Command_ValidateBots(int iClient, int iArgs)
{
    char szPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, szPath, sizeof(szPath), "configs/bot_rosters.txt");
    if (!FileExists(szPath))
    {
        PrintToServer("[Validate] Configuration file not found: %s", szPath);
        return Plugin_Handled;
    }

    KeyValues hKv = new KeyValues("Teams");
    if (!hKv.ImportFromFile(szPath))
    {
        delete hKv;
        PrintToServer("[Validate] Unable to parse configuration file: %s", szPath);
        return Plugin_Handled;
    }

    if (!hKv.GotoFirstSubKey())
    {
        delete hKv;
        PrintToServer("[Validate] No teams found.");
        return Plugin_Handled;
    }

    int iMissing, iTotal;
    do
    {
        char szTeamName[64], szPlayers[256];
        hKv.GetSectionName(szTeamName, sizeof(szTeamName));
        hKv.GetString("players", szPlayers, sizeof(szPlayers));

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
    while (hKv.GotoNextKey());

    delete hKv;
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
    CreateTimer(0.5, Timer_MoveToBomb, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

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

		if (g_bDropWeapon[i])
			continue;

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

void BuyEcoPistolAndGear(int iClient, bool bDefaultPistol, int iTeam, bool bHasDefuser)
{
	if (bDefaultPistol)
	{
		switch (Math_GetRandomInt(1, 5))
		{
			case 1: FakeClientCommand(iClient, "buy p250");
			case 2: FakeClientCommand(iClient, "buy tec9");
			case 3: FakeClientCommand(iClient, "buy deagle");
		}
	}
	else
	{
		switch (Math_GetRandomInt(1, 20))
		{
			case 1: FakeClientCommand(iClient, "buy vest");
			case 10: FakeClientCommand(iClient, "buy %s", (iTeam == CS_TEAM_CT && !bHasDefuser) ? "defuser" : "vest");
		}
	}
}

public Action Timer_MoveToBomb(Handle hTimer, any data)
{
	if (g_bBombPlanted)
	{
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
				SwitchWeapon(i, GetPlayerWeaponSlot(i, CS_SLOT_KNIFE));
				SmartBotMoveTo(i, fC4Pos, FASTEST_ROUTE, 1.2);
			}
		}
	}
	else if (g_bIsBombScenario && g_bFreezetimeEnd)
	{
		int iLooseC4 = FindLooseBomb();
		if (!IsValidEntity(iLooseC4))
			return Plugin_Continue;

		float fC4Pos[3];
		GetEntPropVector(iLooseC4, Prop_Send, "m_vecOrigin", fC4Pos);

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsValidClient(i) || !IsFakeClient(i) || !IsPlayerAlive(i) || GetClientTeam(i) != CS_TEAM_CT)
				continue;

			if (GetEntData(i, g_iBotNearbyEnemiesOffset) != 0)
				continue;

			TaskType eTask = GetTask(i);
			if (eTask == GUARD_LOOSE_BOMB || eTask == DEFUSE_BOMB || eTask == ESCAPE_FROM_BOMB || eTask == ESCAPE_FROM_FLAMES || eTask == GUARD_HOSTAGES || eTask == COLLECT_HOSTAGES || eTask == RESCUE_HOSTAGES)
				continue;

			float fDist = GetVectorDistance(g_fBotOrigin[i], fC4Pos);
			if (fDist < 500.0)
				SetTask(i, GUARD_LOOSE_BOMB);
			else
				SmartBotMoveTo(i, fC4Pos, FASTEST_ROUTE, 1.2);
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

    ArrayList aBotsT = new ArrayList(2);
    ArrayList aBotsCT = new ArrayList(2);

    for (int iClient = 1; iClient <= MaxClients; iClient++)
    {
        if (!IsValidClient(iClient) || !IsFakeClient(iClient) || !IsPlayerAlive(iClient) || g_bDropWeapon[iClient])
            continue;

        int iPrimaryWeapon = GetPlayerWeaponSlot(iClient, CS_SLOT_PRIMARY);
        if (!IsValidEntity(iPrimaryWeapon))
            continue;

        int iDefIndex = GetEntProp(iPrimaryWeapon, Prop_Send, "m_iItemDefinitionIndex");
        CSWeaponID eWeaponID = CS_ItemDefIndexToID(iDefIndex);
        if (eWeaponID == CSWeapon_NONE)
            continue;

        int iMoney = GetEntProp(iClient, Prop_Send, "m_iAccount");
        int iWeaponPrice = CS_GetWeaponPrice(iClient, eWeaponID);
        if (iMoney < iWeaponPrice)
            continue;

        GetEntityClassname(iPrimaryWeapon, g_szPreviousBuy[iClient], sizeof(g_szPreviousBuy[]));
        ReplaceString(g_szPreviousBuy[iClient], sizeof(g_szPreviousBuy[]), "weapon_", "");

        int iEntry[2];
        iEntry[0] = iClient;
        iEntry[1] = iMoney;

        int iTeam = GetClientTeam(iClient);
        if (iTeam == CS_TEAM_T)
            aBotsT.PushArray(iEntry);
        else if (iTeam == CS_TEAM_CT)
            aBotsCT.PushArray(iEntry);
    }

    SortADTArrayCustom(aBotsT, Sort_BotMoneyDesc);
    SortADTArrayCustom(aBotsCT, Sort_BotMoneyDesc);

    bool bNeedDropT, bNeedDropCT;
    AssignDrops(aBotsT, aBotsCT, bNeedDropT, bNeedDropCT);

    if (bNeedDropT)
        CollectCheapDroppers(aBotsT, CS_TEAM_T);

    if (bNeedDropCT)
        CollectCheapDroppers(aBotsCT, CS_TEAM_CT);

    if ((bNeedDropT && aBotsT.Length > 0) || (bNeedDropCT && aBotsCT.Length > 0))
        AssignDrops(aBotsT, aBotsCT, bNeedDropT, bNeedDropCT);

    delete aBotsT;
    delete aBotsCT;

    return Plugin_Continue;
}

void AssignDrops(ArrayList aBotsT, ArrayList aBotsCT, bool &bNeedDropT, bool &bNeedDropCT)
{
    bNeedDropT = false;
    bNeedDropCT = false;

    for (int iClient = 1; iClient <= MaxClients; iClient++)
    {
        if (!IsValidClient(iClient) || !IsPlayerAlive(iClient) || g_bHasGottenDrop[iClient])
            continue;

        if (!GetEntProp(iClient, Prop_Send, "m_bInBuyZone"))
            continue;

        int iPrimaryWeapon = GetPlayerWeaponSlot(iClient, CS_SLOT_PRIMARY);
        int iMoney = GetEntProp(iClient, Prop_Send, "m_iAccount");
        int iTeam = GetClientTeam(iClient);

        if (IsValidEntity(iPrimaryWeapon) || iMoney >= 3000)
            continue;

        ArrayList aTeamBots = (iTeam == CS_TEAM_T) ? aBotsT : aBotsCT;
        
        if (aTeamBots.Length == 0)
        {
            if (iTeam == CS_TEAM_T)
                bNeedDropT = true;
            else
                bNeedDropCT = true;

            continue;
        }

        int iEntry[2];
        aTeamBots.GetArray(0, iEntry, 2);
        int iDropBot = iEntry[0];
        aTeamBots.Erase(0);

        float fEyePos[3];
        GetClientEyePosition(iClient, fEyePos);
        BotSetLookAt(iDropBot, "Use entity", fEyePos, PRIORITY_HIGH, 3.0, false, 5.0, false);
        
        g_bDropWeapon[iDropBot] = true;
        g_bHasGottenDrop[iClient] = true;
    }
}

void CollectCheapDroppers(ArrayList aTeamBots, int iTeam)
{
    aTeamBots.Clear();

    CSWeaponID eRifle = (iTeam == CS_TEAM_T) ? CSWeapon_GALILAR : CSWeapon_FAMAS;
    CSWeaponID eSMG = (iTeam == CS_TEAM_T) ? CSWeapon_MAC10 : CSWeapon_MP9;

    for (int iClient = 1; iClient <= MaxClients; iClient++)
    {
        if (!IsValidClient(iClient) || !IsFakeClient(iClient) || !IsPlayerAlive(iClient) || g_bDropWeapon[iClient])
            continue;

        if (GetClientTeam(iClient) != iTeam)
            continue;

        int iPrimaryWeapon = GetPlayerWeaponSlot(iClient, CS_SLOT_PRIMARY);
        if (!IsValidEntity(iPrimaryWeapon))
            continue;

        int iMoney = GetEntProp(iClient, Prop_Send, "m_iAccount");

        if (iMoney >= CS_GetWeaponPrice(iClient, eRifle))
            strcopy(g_szPreviousBuy[iClient], sizeof(g_szPreviousBuy[]), (iTeam == CS_TEAM_T) ? "galilar" : "famas");
        else if (iMoney >= CS_GetWeaponPrice(iClient, eSMG))
            strcopy(g_szPreviousBuy[iClient], sizeof(g_szPreviousBuy[]), (iTeam == CS_TEAM_T) ? "mac10" : "mp9");
        else
            continue;

        g_bCheapDrop[iClient] = true;

        int iEntry[2];
        iEntry[0] = iClient;
        iEntry[1] = iMoney;
        aTeamBots.PushArray(iEntry);
    }

    SortADTArrayCustom(aTeamBots, Sort_BotMoneyDesc);
}

public void OnMapEnd()
{
	if (g_iPlayerResourceEntity != -1 && IsValidEntity(g_iPlayerResourceEntity))
		SDKUnhook(g_iPlayerResourceEntity, SDKHook_ThinkPost, OnThinkPost);

	g_iPlayerResourceEntity = -1;
}

public void OnClientPostAdminCheck(int iClient)
{
    g_iProfileRank[iClient] = Math_GetRandomInt(1, 40);

    if (!IsFakeClient(iClient))
    {
        char szColor[64];
        GetClientInfo(iClient, "cl_color", szColor, sizeof(szColor));
        g_iPlayerColor[iClient] = StringToInt(szColor);
        return;
    }

    g_bIsProBot[iClient] = IsBotInDatabase(iClient);

    if (g_bIsProBot[iClient])
    {
        GetBotCrosshairCode(iClient, g_szCrosshairCode[iClient], sizeof(g_szCrosshairCode[]));

        char szBotName[MAX_NAME_LENGTH];
        GetClientName(iClient, szBotName, sizeof(szBotName));

        if (IsTopBot(szBotName))
        {
            g_fLookAngleMaxAccel[iClient] = 100000.0;
            g_fReactionTime[iClient] = 0.0;
            g_fAggression[iClient] = 1.0;
        }
        else
        {
            g_fLookAngleMaxAccel[iClient] = Math_GetRandomFloat(4000.0, 7000.0);
            g_fReactionTime[iClient] = Math_GetRandomFloat(0.165, 0.325);
            g_fAggression[iClient] = Math_GetRandomFloat(0.0, 1.0);
        }
    }

    g_bUseUSP[iClient] = IsItMyChance(75.0);
    g_bUseM4A1S[iClient] = IsItMyChance(50.0);
    g_bUseCZ75[iClient] = IsItMyChance(20.0);
    g_fBotCurrentGoal[iClient][0] = 0.0;
    g_fBotCurrentGoal[iClient][1] = 0.0;
    g_fBotCurrentGoal[iClient][2] = 0.0;
    g_fBotNextRepathTime[iClient] = 0.0;
    g_eBotCurrentRoute[iClient] = DEFAULT_ROUTE;
}

public void OnRoundPreStart(Event eEvent, const char[] szName, bool bDontBroadcast)
{
    g_iCurrentRound = GameRules_GetProp("m_totalRoundsPlayed");

    g_bForceT = false;
    g_bForceCT = false;

    int iOvertimePlaying = GameRules_GetProp("m_nOvertimePlaying");
    GamePhase eGamePhase = view_as<GamePhase>(GameRules_GetProp("m_gamePhase"));

    if (g_cvHalftime.BoolValue && eGamePhase == GAMEPHASE_PLAYING_FIRST_HALF)
    {
        int iRoundsBeforeHalftime = iOvertimePlaying ? g_cvMaxRounds.IntValue + ((2 * iOvertimePlaying - 1) * (g_cvOTMaxRounds.IntValue / 2)) : (g_cvMaxRounds.IntValue / 2);
        if (iRoundsBeforeHalftime > 0 && g_iRoundsPlayed == iRoundsBeforeHalftime - 1)
        {
            g_bHalftimeSwitch = true;
            g_bForceT = true;
            g_bForceCT = true;
        }
    }

    if (eGamePhase != GAMEPHASE_PLAYING_FIRST_HALF)
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
		g_bCheapDrop[i] = false;
		g_bThrowGrenade[i] = false;
		g_bNadeResolved[i] = false;

		g_iTarget[i] = -1;
		g_iPrevTarget[i] = -1;
		g_iDoingSmokeNum[i] = -1;
		g_fNadeArrivedTimestamp[i] = 0.0;

		g_fShootTimestamp[i] = 0.0;
		g_fThrowNadeTimestamp[i] = 0.0;
		g_fCrouchTimestamp[i] = 0.0;

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
		CreateTimer(0.5, Timer_DropWeapons, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
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

public void OnPlayerJump(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	int iClient = GetClientOfUserId(eEvent.GetInt("userid"));
	if (!IsValidClient(iClient) || !IsPlayerAlive(iClient))
		return;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (i == iClient || !IsValidClient(i) || !IsPlayerAlive(i) || !IsFakeClient(i) || GetClientTeam(i) == GetClientTeam(iClient))
			continue;

		BotOnAudibleEvent(i, eEvent, iClient, 1100.0, PRIORITY_LOW, false);
	}
}

public void OnBombBeginPlant(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	int iPlanter = GetClientOfUserId(eEvent.GetInt("userid"));
	if (!IsValidClient(iPlanter) || !IsPlayerAlive(iPlanter))
		return;

	float fPlanterPos[3];
	GetClientAbsOrigin(iPlanter, fPlanterPos);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (i == iPlanter || !IsValidClient(i) || !IsPlayerAlive(i) || !IsFakeClient(i) || GetClientTeam(i) == GetClientTeam(iPlanter))
			continue;

		BotOnAudibleEvent(i, eEvent, iPlanter, 1100.0, PRIORITY_HIGH, true, false, fPlanterPos);

		if (!g_bIsProBot[i] || !CanThrowNade(i) || g_bThrowGrenade[i])
			continue;

		if (GetTask(i) == ESCAPE_FROM_BOMB || GetTask(i) == ESCAPE_FROM_FLAMES || GetEntityMoveType(i) == MOVETYPE_LADDER)
			continue;

		float fEyePos[3];
		GetClientEyePosition(i, fEyePos);

		if (GetVectorDistance(fPlanterPos, fEyePos) > 1500.0)
			continue;

		if (IsPointVisible(fEyePos, fPlanterPos))
			continue;

		if (!IsItMyChance(30.0))
			continue;

		int iNades[] = {DEFIDX_MOLOTOV, DEFIDX_INCENDIARY, DEFIDX_HE};
		int iNade = FindNadeByDefIndex(i, iNades, sizeof(iNades));
		if (iNade != -1)
			ProcessGrenadeThrow(i, fPlanterPos, iNade);
	}
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
	int iClient = GetClientOfUserId(eEvent.GetInt("userid"));
	
	if (!IsValidClient(iClient) || !IsPlayerAlive(iClient) || !IsFakeClient(iClient))
		return;
	
	g_fShootTimestamp[iClient] = GetGameTime();
}

public void OnWeaponFire(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	int iClient = GetClientOfUserId(eEvent.GetInt("userid"));
	if (!IsValidClient(iClient) || !IsPlayerAlive(iClient) || !IsFakeClient(iClient))
		return;

	char szWeaponName[32];
	eEvent.GetString("weapon", szWeaponName, sizeof(szWeaponName));

	if (IsValidClient(g_iTarget[iClient]) && StrEqual(szWeaponName, "weapon_deagle"))
	{
		float fTargetLoc[3];
		GetClientAbsOrigin(g_iTarget[iClient], fTargetLoc);
		
		float fRangeToEnemy = GetVectorDistance(g_fBotOrigin[iClient], fTargetLoc);
		if (fRangeToEnemy > 100.0)
			SetEntDataFloat(iClient, g_iFireWeaponOffset, GetEntDataFloat(iClient, g_iFireWeaponOffset) + Math_GetRandomFloat(0.20, 0.40));
	}

	if ((StrEqual(szWeaponName, "weapon_awp") || StrEqual(szWeaponName, "weapon_ssg08")) && IsItMyChance(50.0))
		RequestFrame(BeginQuickSwitch, GetClientUserId(iClient));

	if (StrEqual(szWeaponName, "weapon_awp") || StrEqual(szWeaponName, "weapon_ssg08"))
		RequestFrame(CheckSniperRetreat, GetClientUserId(iClient));
}

public void OnThinkPost(int iEnt)
{
	static float fLastThinkUpdate = 0.0;
	float fNow = GetGameTime();
	if (fNow - fLastThinkUpdate < 2.0)
		return;
	fLastThinkUpdate = fNow;

	SetEntDataArray(iEnt, g_iProfileRankOffset, g_iProfileRank, MAXPLAYERS + 1);
	SetEntDataArray(iEnt, g_iPlayerColorOffset, g_iPlayerColor, MAXPLAYERS + 1);

	Address pEntAddr = GetEntityAddress(iEnt);
	for (int i = 1; i <= MaxClients; i++)
		if (IsValidClient(i) && IsFakeClient(i))
			SetCrosshairCode(pEntAddr, i, g_szCrosshairCode[i]);
}

public Action CS_OnBuyCommand(int iClient, const char[] szWeapon)
{
	if (!IsValidClient(iClient) || !IsPlayerAlive(iClient) || !IsFakeClient(iClient))
		return Plugin_Continue;

	int iTeam = GetClientTeam(iClient);
	int iAccount = GetEntProp(iClient, Prop_Send, "m_iAccount");
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

	if (bIsEco && !g_bBuyingCheapDrop[iClient])
		return Plugin_Handled;

	if (!g_bBuyingCheapDrop[iClient] && GetPlayerWeaponSlot(iClient, CS_SLOT_PRIMARY) != -1 &&
	    (strcmp(szWeapon, "galilar") == 0 || strcmp(szWeapon, "famas") == 0 || strcmp(szWeapon, "ak47") == 0 ||
	     strcmp(szWeapon, "m4a1") == 0 || strcmp(szWeapon, "ssg08") == 0 || strcmp(szWeapon, "aug") == 0 ||
	     strcmp(szWeapon, "sg556") == 0 || strcmp(szWeapon, "awp") == 0 || strcmp(szWeapon, "scar20") == 0 ||
	     strcmp(szWeapon, "g3sg1") == 0 || strcmp(szWeapon, "nova") == 0 || strcmp(szWeapon, "xm1014") == 0 ||
	     strcmp(szWeapon, "mag7") == 0 || strcmp(szWeapon, "m249") == 0 || strcmp(szWeapon, "negev") == 0 ||
	     strcmp(szWeapon, "mac10") == 0 || strcmp(szWeapon, "mp9") == 0 || strcmp(szWeapon, "mp7") == 0 ||
	     strcmp(szWeapon, "ump45") == 0 || strcmp(szWeapon, "p90") == 0 || strcmp(szWeapon, "bizon") == 0))
		return Plugin_Handled;

	int iEnemyAvgMoney = (iTeam == CS_TEAM_CT) ? g_iAvgMoneyT : g_iAvgMoneyCT;

	if ((strcmp(szWeapon, "ak47") == 0 || strcmp(szWeapon, "m4a1") == 0) && !g_bForceT && !g_bForceCT && !IsValidEntity(GetPlayerWeaponSlot(iClient, CS_SLOT_PRIMARY)) && IsItMyChance(40.0) && iEnemyAvgMoney < 2500)
	{
		if (iTeam == CS_TEAM_T && iAccount >= CS_GetWeaponPrice(iClient, CSWeapon_MAC10))
		{
			ReplaceWeapon(iClient, CS_SLOT_PRIMARY, "weapon_mac10", true);
			return Plugin_Changed;
		}
		else if (iTeam == CS_TEAM_CT && iAccount >= CS_GetWeaponPrice(iClient, CSWeapon_MP9))
		{
			ReplaceWeapon(iClient, CS_SLOT_PRIMARY, "weapon_mp9", true);
			return Plugin_Changed;
		}
	}

	if (strcmp(szWeapon, "m4a1") == 0)
	{
		if (g_bUseM4A1S[iClient] && iAccount >= CS_GetWeaponPrice(iClient, CSWeapon_M4A1_SILENCER))
		{
			ReplaceWeapon(iClient, CS_SLOT_PRIMARY, "weapon_m4a1_silencer", true);
			return Plugin_Changed;
		}

		if (IsItMyChance(5.0) && iAccount >= CS_GetWeaponPrice(iClient, CSWeapon_AUG))
		{
			ReplaceWeapon(iClient, CS_SLOT_PRIMARY, "weapon_aug", true);
			return Plugin_Changed;
		}
	}

	if (strcmp(szWeapon, "mac10") == 0 && IsItMyChance(40.0) && iAccount >= CS_GetWeaponPrice(iClient, CSWeapon_GALILAR))
	{
		ReplaceWeapon(iClient, CS_SLOT_PRIMARY, "weapon_galilar", true);
		return Plugin_Changed;
	}

	if (strcmp(szWeapon, "mp9") == 0)
	{
		if (IsItMyChance(40.0) && iAccount >= CS_GetWeaponPrice(iClient, CSWeapon_FAMAS))
		{
			ReplaceWeapon(iClient, CS_SLOT_PRIMARY, "weapon_famas", true);
			return Plugin_Changed;
		}

		if (IsItMyChance(15.0) && iAccount >= CS_GetWeaponPrice(iClient, CSWeapon_UMP45))
		{
			ReplaceWeapon(iClient, CS_SLOT_PRIMARY, "weapon_ump45", true);
			return Plugin_Changed;
		}
	}

	if ((strcmp(szWeapon, "tec9") == 0 || strcmp(szWeapon, "fiveseven") == 0) && g_bUseCZ75[iClient])
	{
		ReplaceWeapon(iClient, CS_SLOT_SECONDARY, "weapon_cz75a", true);
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
	if (hParams == null || hParams.IsNull(2))
		return MRES_Ignored;

	int iClient = hParams.Get(2);
	if (!IsValidClient(iClient) || GetClientTeam(iBot) == GetClientTeam(iClient))
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
		GetClientAbsOrigin(iClient, g_fOriginalNoisePos[iBot]);
	}

	return MRES_Ignored;
}

public MRESReturn CCSBot_SetLookAt(int iClient, DHookParam hParams)
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
		g_bDontSwitch[iClient] = true;
		CreateTimer(5.0, Timer_EnableSwitch, GetClientUserId(iClient));
		return MRES_Ignored;
	}
	else if (strcmp(szDesc, "Last Enemy Position") == 0)
	{
		if (IsValidClient(g_iTarget[iClient]) && IsPlayerAlive(g_iTarget[iClient]) && CanThrowNade(iClient) && IsItMyChance(1.0) && GetTask(iClient) != ESCAPE_FROM_BOMB && GetTask(iClient) != ESCAPE_FROM_FLAMES && GetEntityMoveType(iClient) != MOVETYPE_LADDER)
		{
			float fPos[3];
			DHookGetParamVector(hParams, 2, fPos);

			int iNades[] = {DEFIDX_HE, DEFIDX_MOLOTOV, DEFIDX_INCENDIARY, DEFIDX_FLASH, DEFIDX_SMOKE};
			int iNade = FindNadeByDefIndex(iClient, iNades, sizeof(iNades));
			if (iNade != -1 && ProcessGrenadeThrow(iClient, fPos, iNade))
				return MRES_Supercede;
		}

		return MRES_Ignored;
	}
	else if (strcmp(szDesc, "GrenadeThrowBend") == 0)
	{
		if (g_bThrowGrenade[iClient])
			hParams.SetVector(2, g_fNadeTarget[iClient]);

		hParams.Set(4, 8.0);
		hParams.Set(6, 1.5);
		return MRES_ChangedHandled;
	}
	else if (strcmp(szDesc, "Noise") == 0)
	{
		bool bIsWalking = !!GetEntProp(iClient, Prop_Send, "m_bIsWalking");
		float fClientEyes[3], fNoisePos[3];
		GetClientEyePosition(iClient, fClientEyes);
		DHookGetParamVector(hParams, 2, fNoisePos);

		if (IsItMyChance(15.0) && IsPointVisible(fClientEyes, fNoisePos) && LineGoesThroughSmoke(fClientEyes, fNoisePos) && !bIsWalking)
			DHookSetParam(hParams, 7, true);

		if (CanThrowNade(iClient) && IsItMyChance(3.0) && GetTask(iClient) != ESCAPE_FROM_BOMB && GetTask(iClient) != ESCAPE_FROM_FLAMES && GetEntityMoveType(iClient) != MOVETYPE_LADDER)
		{
			int iNades[] = {DEFIDX_HE, DEFIDX_MOLOTOV, DEFIDX_INCENDIARY, DEFIDX_FLASH};
			int iNade = FindNadeByDefIndex(iClient, iNades, sizeof(iNades));
			if (iNade != -1 && (ProcessGrenadeThrow(iClient, g_fOriginalNoisePos[iClient], iNade) || ProcessGrenadeThrow(iClient, fNoisePos, iNade)))
				return MRES_Supercede;
		}

		if (BotMimic_IsPlayerMimicing(iClient))
		{
			if (g_iDoingSmokeNum[iClient] != -1)
				SetNadeTimestamp(g_iDoingSmokeNum[iClient], GetGameTime());

			BotMimic_StopPlayerMimic(iClient);
		}

		if (eItems_GetWeaponSlotByWeapon(g_iActiveWeapon[iClient]) == CS_SLOT_KNIFE && GetTask(iClient) != ESCAPE_FROM_BOMB && GetTask(iClient) != ESCAPE_FROM_FLAMES)
			BotEquipBestWeapon(iClient, true);

		g_bDontSwitch[iClient] = true;
		CreateTimer(5.0, Timer_EnableSwitch, GetClientUserId(iClient));

		fNoisePos[2] += 25.0;
		DHookSetParamVector(hParams, 2, fNoisePos);
		return MRES_ChangedHandled;
	}
	else if (strcmp(szDesc, "Nearby enemy gunfire") == 0)
	{
		float fPos[3];
		DHookGetParamVector(hParams, 2, fPos);

		if (CanThrowNade(iClient) && IsItMyChance(25.0) && GetTask(iClient) != ESCAPE_FROM_BOMB && GetTask(iClient) != ESCAPE_FROM_FLAMES && GetEntityMoveType(iClient) != MOVETYPE_LADDER)
		{
			int iNades[] = {DEFIDX_HE, DEFIDX_MOLOTOV, DEFIDX_INCENDIARY, DEFIDX_FLASH, DEFIDX_SMOKE};
			int iNade = FindNadeByDefIndex(iClient, iNades, sizeof(iNades));
			if (iNade != -1 && (ProcessGrenadeThrow(iClient, g_fOriginalNoisePos[iClient], iNade) || ProcessGrenadeThrow(iClient, fPos, iNade)))
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

public MRESReturn CCSBot_PickNewAimSpot(int iClient, DHookParam hParams)
{
    if (!g_bIsProBot[iClient])
        return MRES_Ignored;

    SelectBestTargetPos(iClient, g_fTargetPos[iClient]);

    if (!IsValidClient(g_iTarget[iClient]) || !IsPlayerAlive(g_iTarget[iClient]) || g_fTargetPos[iClient][2] == 0.0)
        return MRES_Ignored;

    SetEntDataVector(iClient, g_iBotTargetSpotOffset, g_fTargetPos[iClient]);
    return MRES_Ignored;
}

public Action OnPlayerRunCmd(int iClient, int &iButtons, int &iImpulse, float fVel[3], float fAngles[3], int &iWeapon, int &iSubtype, int &iCmdNum, int &iTickCount, int &iSeed, int iMouse[2])
{
	if (!IsValidClient(iClient) || !IsPlayerAlive(iClient) || !IsFakeClient(iClient))
		return Plugin_Continue;

	if (!g_bFreezetimeEnd && g_bDropWeapon[iClient] && view_as<LookAtSpotState>(GetEntData(iClient, g_iBotLookAtSpotStateOffset)) == LOOK_AT_SPOT)
	{
		if (g_bCheapDrop[iClient])
		{
			g_bBuyingCheapDrop[iClient] = true;
			FakeClientCommand(iClient, "buy %s", g_szPreviousBuy[iClient]);
			g_bBuyingCheapDrop[iClient] = false;
			RequestFrame(TossCheapDrop, GetClientUserId(iClient));
			g_bCheapDrop[iClient] = false;
		}
		else
		{
			CS_DropWeapon(iClient, GetPlayerWeaponSlot(iClient, CS_SLOT_PRIMARY), true);
			FakeClientCommand(iClient, "buy %s", g_szPreviousBuy[iClient]);
		}
		g_bDropWeapon[iClient] = false;
	}

	GetClientAbsOrigin(iClient, g_fBotOrigin[iClient]);
	g_iActiveWeapon[iClient] = GetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon");
	if (!IsValidEntity(g_iActiveWeapon[iClient]))
		return Plugin_Continue;

	if (!g_bFreezetimeEnd)
		return Plugin_Continue;

	float fNow = GetGameTime();
	int iDefIndex = GetEntProp(g_iActiveWeapon[iClient], Prop_Send, "m_iItemDefinitionIndex");

	float fPlayerVelocity[3];
	GetEntPropVector(iClient, Prop_Data, "m_vecAbsVelocity", fPlayerVelocity);
	fPlayerVelocity[2] = 0.0;
	float fSpeed = GetVectorLength(fPlayerVelocity);

	if ((g_iAliveCountT == 0 || g_iAliveCountCT == 0) && !g_bDontSwitch[iClient])
	{
		SwitchWeapon(iClient, GetPlayerWeaponSlot(iClient, CS_SLOT_KNIFE));
		
		if (BotMimic_IsPlayerMimicing(iClient))
            BotMimic_StopPlayerMimic(iClient);
			
		ResetNadeTimestamps();
		g_iDoingSmokeNum[iClient] = -1;
	}

	if (g_iDoingSmokeNum[iClient] == -1 && fNow >= g_fNadeLineupCooldown[iClient])
	{
		g_iDoingSmokeNum[iClient] = GetNearestGrenade(iClient);
		g_fNadeLineupCooldown[iClient] = fNow + 1.0;
	}

	if (GetDisposition(iClient) == SELF_DEFENSE)
		SetDisposition(iClient, ENGAGE_AND_INVESTIGATE);

	if (g_iDoingSmokeNum[iClient] != -1 && !BotMimic_IsPlayerMimicing(iClient))
	{
		NadeLineup sNade;
		g_aNades.GetArray(g_iDoingSmokeNum[iClient], sNade);
		float fDisToNade = GetVectorDistance(g_fBotOrigin[iClient], sNade.fPos);
		if (fDisToNade > 600.0 || GetEntData(iClient, g_iBotNearbyEnemiesOffset) > 0)
		{
			g_iDoingSmokeNum[iClient] = -1;
			BotEquipBestWeapon(iClient, true);
		}
		else
		{
			SetNadeTimestamp(g_iDoingSmokeNum[iClient], fNow);
			if (fDisToNade >= 25.0)
			{
				g_fNadeArrivedTimestamp[iClient] = 0.0;
				SmartBotMoveTo(iClient, sNade.fPos, FASTEST_ROUTE, 0.8);
			}
			else
			{
				// 已进入定点25码范围内：彻底停下步伐，绝不继续调用 SmartBotMoveTo 造成与 LookAt 视角冲突引发原地死循环打转！
				AutoStop(iClient, fVel, fAngles);
				BotSetLookAt(iClient, "Use entity", sNade.fLook, PRIORITY_HIGH, 2.0, false, 3.0, false);

				if (g_fNadeArrivedTimestamp[iClient] == 0.0)
					g_fNadeArrivedTimestamp[iClient] = fNow;

				// 速度降至10以下且在地面，或已对准目标角度，立即开始回放投掷
				if ((view_as<LookAtSpotState>(GetEntData(iClient, g_iBotLookAtSpotStateOffset)) == LOOK_AT_SPOT || fDisToNade < 15.0) && fSpeed < 10.0 && (GetEntityFlags(iClient) & FL_ONGROUND))
				{
					BotMimic_PlayRecordFromFile(iClient, sNade.szReplay);
					g_fNadeArrivedTimestamp[iClient] = 0.0;
				}
				// 超过2.5秒仍未成功触发回放（如录像缺失或被障碍卡住），主动超时放弃，切回主武器，杜绝原地罚站打转！
				else if (fNow - g_fNadeArrivedTimestamp[iClient] > 2.5)
				{
					g_iDoingSmokeNum[iClient] = -1;
					g_fNadeArrivedTimestamp[iClient] = 0.0;
					BotEquipBestWeapon(iClient, true);
				}
			}
		}
	}

	if (g_bThrowGrenade[iClient] && eItems_GetWeaponSlotByDefIndex(iDefIndex) == CS_SLOT_GRENADE)
	{
		if (!g_bNadeResolved[iClient] && fSpeed < 5.0)
		{
			float fLookAt[3];
			if (SolveGrenadeToss(iClient, g_fNadeSolveTarget[iClient], fLookAt, g_iNadeSolveDefIndex[iClient]))
				Array_Copy(fLookAt, g_fNadeTarget[iClient], 3);

			g_bNadeResolved[iClient] = true;
		}

		BotThrowGrenade(iClient, g_fNadeTarget[iClient]);
		g_fThrowNadeTimestamp[iClient] = fNow;
		g_bThrowGrenade[iClient] = false; // 关键修复：投掷指令只下发一次，切勿每帧(128Hz)狂轰滥炸重置导致Bot卡死捏雷！
	}

	if (IsSafe(iClient))
	{
		iButtons &= ~IN_SPEED;
		// 严防在准备下包/正在下包/拆包期间被切刀强制打断！
		if(g_bIsProBot[iClient] && !g_bDontSwitch[iClient] && !BotIsHiding(iClient) && GetTask(iClient) != PLANT_BOMB && GetTask(iClient) != DEFUSE_BOMB && iDefIndex != 49)
			SwitchWeapon(iClient, GetPlayerWeaponSlot(iClient, CS_SLOT_KNIFE));
	}

	if (g_bIsProBot[iClient] && !g_bBombPlanted && GetTask(iClient) != COLLECT_HOSTAGES && GetTask(iClient) != RESCUE_HOSTAGES && GetTask(iClient) != GUARD_LOOSE_BOMB && GetTask(iClient) != PLANT_BOMB && GetTask(iClient) != ESCAPE_FROM_FLAMES)
	{
		if (fNow >= g_fWeaponPickupCooldown[iClient])
		{
			int iPrim = GetPlayerWeaponSlot(iClient, CS_SLOT_PRIMARY);
			if (!IsValidEntity(iPrim))
			{
				ProcessWeaponPickup(iClient);
			}
			g_fWeaponPickupCooldown[iClient] = fNow + 2.0;
		}
	}

	if (g_bIsProBot[iClient] && GetDisposition(iClient) != IGNORE_ENEMIES)
		ProcessCombat(iClient, iButtons, fVel, fAngles, iDefIndex, fSpeed, fNow);

	if (g_bIsProBot[iClient] && CanThrowNade(iClient) && !g_bThrowGrenade[iClient] && !BotMimic_IsPlayerMimicing(iClient) && GetEntityMoveType(iClient) != MOVETYPE_LADDER && GetTask(iClient) != ESCAPE_FROM_BOMB && GetTask(iClient) != ESCAPE_FROM_FLAMES)
	{
		bool bIsEnemyVisible = !!GetEntData(iClient, g_iEnemyVisibleOffset);

		if (g_bBombPlanted && !bIsEnemyVisible && GetClientTeam(iClient) == CS_TEAM_T && IsEnemyNearBomb() && IsItMyChance(0.5))
		{
			float fClientEyes[3];
			GetClientEyePosition(iClient, fClientEyes);

			if (!IsPointVisible(fClientEyes, g_fBombPos))
			{
				int iDenialNades[] = {DEFIDX_MOLOTOV, DEFIDX_INCENDIARY, DEFIDX_HE};
				int iNade = FindNadeByDefIndex(iClient, iDenialNades, sizeof(iDenialNades));
				if (iNade != -1)
					ProcessGrenadeThrow(iClient, g_fBombPos, iNade);
			}
		}
	}

	return Plugin_Changed;
}

void ProcessWeaponPickup(int iClient)
{
	float fClientEyes[3];
	GetClientEyePosition(iClient, fClientEyes);

	int iSkipAK[2] = {DEFIDX_AK47, DEFIDX_AWP};
	TryPickupWeapon(iClient, "weapon_ak47", iSkipAK, sizeof(iSkipAK), CS_SLOT_PRIMARY, fClientEyes, g_fBotOrigin[iClient]);

	int iSkipM4[4] = {DEFIDX_AK47, DEFIDX_AWP, DEFIDX_M4A4, DEFIDX_M4A1S};
	TryPickupWeapon(iClient, "weapon_m4a1", iSkipM4, sizeof(iSkipM4), CS_SLOT_PRIMARY, fClientEyes, g_fBotOrigin[iClient]);

	int iSkipDeagle[1] = {DEFIDX_DEAGLE};
	TryPickupWeapon(iClient, "weapon_deagle", iSkipDeagle, sizeof(iSkipDeagle), CS_SLOT_SECONDARY, fClientEyes, g_fBotOrigin[iClient]);

	int iSkipTec9[5] = {DEFIDX_DEAGLE, DEFIDX_TEC9, DEFIDX_FIVESEVEN, DEFIDX_CZ75, DEFIDX_DUALIES};
	TryPickupWeapon(iClient, "weapon_tec9", iSkipTec9, sizeof(iSkipTec9), CS_SLOT_SECONDARY, fClientEyes, g_fBotOrigin[iClient]);
	TryPickupWeapon(iClient, "weapon_fiveseven", iSkipTec9, sizeof(iSkipTec9), CS_SLOT_SECONDARY, fClientEyes, g_fBotOrigin[iClient]);

	int iSkipP250[6] = {DEFIDX_DEAGLE, DEFIDX_TEC9, DEFIDX_FIVESEVEN, DEFIDX_CZ75, DEFIDX_P250, DEFIDX_DUALIES};
	TryPickupWeapon(iClient, "weapon_p250", iSkipP250, sizeof(iSkipP250), CS_SLOT_SECONDARY, fClientEyes, g_fBotOrigin[iClient]);

	int iSkipUSP[8] = {DEFIDX_DEAGLE, DEFIDX_TEC9, DEFIDX_FIVESEVEN, DEFIDX_CZ75, DEFIDX_P250, DEFIDX_P2000, DEFIDX_USPS, DEFIDX_DUALIES};
	TryPickupWeapon(iClient, "weapon_hkp2000", iSkipUSP, sizeof(iSkipUSP), CS_SLOT_SECONDARY, fClientEyes, g_fBotOrigin[iClient]);
}

void ProcessCombat(int iClient, int &iButtons, float fVel[3], float fAngles[3], int iDefIndex, float fSpeed, float fNow)
{
	g_iTarget[iClient] = BotGetEnemy(iClient);

	float fTargetDistance;
	int iZoomLevel;
	bool bIsEnemyVisible = !!GetEntData(iClient, g_iEnemyVisibleOffset);
	bool bIsHiding = BotIsHiding(iClient);
	bool bIsDucking = !!(GetEntityFlags(iClient) & FL_DUCKING);
	bool bIsReloading = IsPlayerReloading(iClient);
	bool bResumeZoom = !!GetEntProp(iClient, Prop_Send, "m_bResumeZoom");

	if (bResumeZoom)
		g_fShootTimestamp[iClient] = fNow;

	if (HasEntProp(g_iActiveWeapon[iClient], Prop_Send, "m_zoomLevel"))
		iZoomLevel = GetEntProp(g_iActiveWeapon[iClient], Prop_Send, "m_zoomLevel");

	if (bIsHiding && (iDefIndex == DEFIDX_AUG || iDefIndex == DEFIDX_SG556) && iZoomLevel == 0)
		iButtons |= IN_ATTACK2;
	else if (!bIsHiding && (iDefIndex == DEFIDX_AUG || iDefIndex == DEFIDX_SG556) && iZoomLevel == 1)
		iButtons |= IN_ATTACK2;

	if (bIsHiding && g_bUncrouch[iClient])
		iButtons &= ~IN_DUCK;

	if (!IsValidClient(g_iTarget[iClient]) || !IsPlayerAlive(g_iTarget[iClient]) || g_fTargetPos[iClient][2] == 0.0)
	{
		g_iPrevTarget[iClient] = g_iTarget[iClient];
		return;
	}

	if (BotMimic_IsPlayerMimicing(iClient))
	{
		if (g_iDoingSmokeNum[iClient] != -1)
			SetNadeTimestamp(g_iDoingSmokeNum[iClient], fNow);

		BotMimic_StopPlayerMimic(iClient);
	}

	if ((eItems_GetWeaponSlotByDefIndex(iDefIndex) == CS_SLOT_KNIFE || eItems_GetWeaponSlotByDefIndex(iDefIndex) == CS_SLOT_GRENADE) && GetTask(iClient) != ESCAPE_FROM_BOMB && GetTask(iClient) != ESCAPE_FROM_FLAMES)
		BotEquipBestWeapon(iClient, true);

	if (bIsEnemyVisible && GetEntityMoveType(iClient) != MOVETYPE_LADDER)
	{
		if (g_iPrevTarget[iClient] == -1)
			g_fCrouchTimestamp[iClient] = fNow + Math_GetRandomFloat(0.23, 0.25);
		fTargetDistance = GetVectorDistance(g_fBotOrigin[iClient], g_fTargetPos[iClient]);

		float fClientEyes[3], fClientAngles[3], fAimPunchAngle[3], fToAimSpot[3], fAimDir[3];
		GetClientEyePosition(iClient, fClientEyes);
		SubtractVectors(g_fTargetPos[iClient], fClientEyes, fToAimSpot);
		GetClientEyeAngles(iClient, fClientAngles);
		GetEntPropVector(iClient, Prop_Send, "m_aimPunchAngle", fAimPunchAngle);
		ScaleVector(fAimPunchAngle, g_cvRecoilScale.FloatValue);
		AddVectors(fClientAngles, fAimPunchAngle, fClientAngles);
		GetViewVector(fClientAngles, fAimDir);

		float fRangeToEnemy = NormalizeVector(fToAimSpot, fToAimSpot);
		float fOnTarget = GetVectorDotProduct(fToAimSpot, fAimDir);
		float fAimTolerance = Cosine(ArcTangent(32.0 / fRangeToEnemy));

		if (g_iPrevTarget[iClient] == -1 && fOnTarget > fAimTolerance)
			g_fCrouchTimestamp[iClient] = fNow + Math_GetRandomFloat(0.23, 0.25);

		if (IsRifleOrHeavy(iDefIndex) || IsSprayWeapon(iDefIndex))
		{
			bool bIsSpray = IsSprayWeapon(iDefIndex);

			if (fOnTarget > fAimTolerance && !bIsDucking && fTargetDistance < 2000.0 && !bIsSpray)
				AutoStop(iClient, fVel, fAngles);
			else if (fTargetDistance > 2000.0 && GetEntDataFloat(iClient, g_iFireWeaponOffset) == fNow)
				AutoStop(iClient, fVel, fAngles);
			if (fOnTarget > fAimTolerance && fTargetDistance < 2000.0)
			{
				iButtons &= ~IN_ATTACK;
				if (!bIsReloading && (fSpeed < 50.0 || bIsDucking || bIsSpray))
				{
					iButtons |= IN_ATTACK;
					SetEntDataFloat(iClient, g_iFireWeaponOffset, fNow);
				}
			}
		}
		else if (iDefIndex == DEFIDX_DEAGLE)
		{
			if (fNow - GetEntDataFloat(iClient, g_iFireWeaponOffset) < 0.15 && !bIsDucking && !bIsReloading)
				AutoStop(iClient, fVel, fAngles);
		}
		else if (iDefIndex == DEFIDX_AWP || iDefIndex == DEFIDX_SSG08)
		{
			if (fTargetDistance < 2750.0 && !bIsReloading && GetEntProp(iClient, Prop_Send, "m_bIsScoped") && fNow - g_fShootTimestamp[iClient] > 0.4 && GetClientAimTarget(iClient, true) == g_iTarget[iClient])
			{
				iButtons |= IN_ATTACK;
				SetEntDataFloat(iClient, g_iFireWeaponOffset, fNow);
			}
		}

		float fClientLoc[3];
		Array_Copy(g_fBotOrigin[iClient], fClientLoc, 3);
		fClientLoc[2] += HalfHumanHeight;
		if (fNow >= g_fCrouchTimestamp[iClient] && !GetEntProp(g_iActiveWeapon[iClient], Prop_Data, "m_bInReload") && IsPointVisible(fClientLoc, g_fTargetPos[iClient]) && fOnTarget > fAimTolerance && fTargetDistance < 2000.0 && IsRifleOrHeavy(iDefIndex))
			iButtons |= IN_DUCK;

		g_iPrevTarget[iClient] = g_iTarget[iClient];
	}
	else
	{
		g_iPrevTarget[iClient] = g_iTarget[iClient];
	}
}

public void OnPlayerSpawn(Event eEvent, const char[] szName, bool bDontBroadcast)
{
    int iClient = GetClientOfUserId(eEvent.GetInt("userid"));
    if (!IsValidClient(iClient))
        return;

    SetPlayerTeammateColor(iClient);

    if (!IsFakeClient(iClient))
        return;

    if (g_bIsProBot[iClient])
    {
        Address pLocalProfile = view_as<Address>(GetEntData(iClient, g_iBotProfileOffset));
        //All these offsets are inside BotProfileManager::Init which has strings for every botprofile parameter
        StoreToAddress(pLocalProfile + view_as<Address>(104), view_as<int>(g_fLookAngleMaxAccel[iClient]), NumberType_Int32);
        StoreToAddress(pLocalProfile + view_as<Address>(116), view_as<int>(g_fLookAngleMaxAccel[iClient]), NumberType_Int32);
        StoreToAddress(pLocalProfile + view_as<Address>(84), view_as<int>(g_fReactionTime[iClient]), NumberType_Int32);
        StoreToAddress(pLocalProfile + view_as<Address>(4), view_as<int>(g_fAggression[iClient]), NumberType_Int32);
    }

    if (g_bUseUSP[iClient] && GetClientTeam(iClient) == CS_TEAM_CT)
    {
        char szWeapon[32];
        GetClientWeapon(iClient, szWeapon, sizeof(szWeapon));

        if (strcmp(szWeapon, "weapon_hkp2000") == 0)
            ReplaceWeapon(iClient, CS_SLOT_SECONDARY, "weapon_usp_silencer");
    }
}

public void BotMimic_OnPlayerStopsMimicing(int iClient, char[] szName, char[] szCategory, char[] szPath)
{
    g_iDoingSmokeNum[iClient] = -1;
    if (IsValidClient(iClient) && IsPlayerAlive(iClient))
    {
        BotEquipBestWeapon(iClient, true);
    }
}

public void OnClientDisconnect(int iClient)
{
	g_iProfileRank[iClient] = 0;
	g_iPlayerColor[iClient] = -1;
	g_bIsProBot[iClient] = false;
	g_bUseCZ75[iClient] = false;
	g_bUseUSP[iClient] = false;
	g_bUseM4A1S[iClient] = false;
	g_bDontSwitch[iClient] = false;
	g_bDropWeapon[iClient] = false;
	g_bHasGottenDrop[iClient] = false;
	g_bCheapDrop[iClient] = false;
	g_bThrowGrenade[iClient] = false;
	g_bUncrouch[iClient] = false;
	g_iTarget[iClient] = -1;
	g_iPrevTarget[iClient] = -1;
	g_iDoingSmokeNum[iClient] = -1;
	g_fNadeArrivedTimestamp[iClient] = 0.0;
	g_iActiveWeapon[iClient] = -1;
	g_fLookAngleMaxAccel[iClient] = 0.0;
	g_fReactionTime[iClient] = 0.0;
	g_fAggression[iClient] = 0.0;
	g_fShootTimestamp[iClient] = 0.0;
	g_fThrowNadeTimestamp[iClient] = 0.0;
	g_fCrouchTimestamp[iClient] = 0.0;
	g_fWeaponPickupCooldown[iClient] = 0.0;
	g_fNadeLineupCooldown[iClient] = 0.0;
	g_fBotCurrentGoal[iClient][0] = 0.0;
	g_fBotCurrentGoal[iClient][1] = 0.0;
	g_fBotCurrentGoal[iClient][2] = 0.0;
	g_fBotNextRepathTime[iClient] = 0.0;
	g_eBotCurrentRoute[iClient] = DEFAULT_ROUTE;
	g_szCrosshairCode[iClient][0] = '\0';
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
	
	KeyValues hKv = new KeyValues("Nades");
	if (!hKv.ImportFromFile(szPath))
	{
		delete hKv;
		PrintToServer("Unable to parse Key Values file %s.", szPath);
		return;
	}
	
	if (!hKv.JumpToKey(szMap))
	{
		delete hKv;
		PrintToServer("No nades found for %s.", szMap);
		return;
	}
	
	if (!hKv.GotoFirstSubKey())
	{
		delete hKv;
		PrintToServer("Nades are not configured right for %s.", szMap);
		return;
	}
	
	do
	{
		NadeLineup sNade;
		char szTeam[4];

		hKv.GetVector("position", sNade.fPos);
		hKv.GetVector("lookat", sNade.fLook);
		sNade.iDefIndex = hKv.GetNum("nadedefindex");
		hKv.GetString("replay", sNade.szReplay, sizeof(sNade.szReplay));
		sNade.fTimestamp = hKv.GetFloat("timestamp");

		sNade.iTeam = CS_TEAM_NONE;
		hKv.GetString("team", szTeam, sizeof(szTeam));
		if (strcmp(szTeam, "CT", false) == 0)
			sNade.iTeam = CS_TEAM_CT;
		else if (strcmp(szTeam, "T", false) == 0)
			sNade.iTeam = CS_TEAM_T;

		g_aNades.PushArray(sNade);
	}
	while (hKv.GotoNextKey());
	
	delete hKv;
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

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CCSBot::TryToRetreat");
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hTryToRetreat = EndPrepSDKCall()) == null)
		SetFailState("Failed to create SDKCall: CCSBot::TryToRetreat");

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

public void BotMoveTo(int iClient, float fOrigin[3], RouteType eRouteType)
{
	SDKCall(g_hBotMoveTo, iClient, fOrigin, eRouteType);
}

void SmartBotMoveTo(int iClient, float fNewGoal[3], RouteType eRouteType, float fMinInterval = 1.0)
{
	if (!IsValidClient(iClient))
		return;

	float fNow = GetGameTime();
	float fDistToOldGoal = GetVectorDistance(g_fBotCurrentGoal[iClient], fNewGoal);

	if (fDistToOldGoal > 64.0 || fNow >= g_fBotNextRepathTime[iClient] || g_eBotCurrentRoute[iClient] != eRouteType)
	{
		Array_Copy(fNewGoal, g_fBotCurrentGoal[iClient], 3);
		g_eBotCurrentRoute[iClient] = eRouteType;
		g_fBotNextRepathTime[iClient] = fNow + fMinInterval;
		SDKCall(g_hBotMoveTo, iClient, g_fBotCurrentGoal[iClient], eRouteType);
	}
}

bool BotIsVisible(int iClient, float fPos[3], bool bTestFOV, int iIgnore = -1)
{
	return SDKCall(g_hBotIsVisible, iClient, fPos, bTestFOV, iIgnore);
}

public bool BotIsHiding(int iClient)
{
	return SDKCall(g_hBotIsHiding, iClient);
}

public void BotEquipBestWeapon(int iClient, bool bMustEquip)
{
	SDKCall(g_hBotEquipBestWeapon, iClient, bMustEquip);
}

public void BotSetLookAt(int iClient, const char[] szDesc, const float fPos[3], PriorityType ePri, float fDuration, bool bClearIfClose, float fAngleTolerance, bool bAttack)
{
	SDKCall(g_hBotSetLookAt, iClient, szDesc, fPos, ePri, fDuration, bClearIfClose, fAngleTolerance, bAttack);
}

public bool BotBendLineOfSight(int iClient, const float fEye[3], const float fTarget[3], float fBend[3], float fAngleLimit)
{
	return SDKCall(g_hBotBendLineOfSight, iClient, fEye, fTarget, fBend, fAngleLimit);
}

public void BotThrowGrenade(int iClient, const float fTarget[3])
{
	SDKCall(g_hBotThrowGrenade, iClient, fTarget);
}

void BotOnAudibleEvent(int iBot, Event eEvent, int iPlayer, float fRange, PriorityType ePriority, bool bIsHostile, bool bIsFootstep = false, const float fActualOrigin[3] = NULL_VECTOR)
{
	SDKCall(g_hOnAudibleEvent, iBot, eEvent, iPlayer, fRange, ePriority, bIsHostile, bIsFootstep, fActualOrigin);
}

public int BotGetEnemy(int iClient)
{
	return GetEntDataEnt2(iClient, g_iBotEnemyOffset);
}

public void SetCrosshairCode(Address pCCSPlayerResource, int iClient, const char[] szCode)
{
	SDKCall(g_hSetCrosshairCode, pCCSPlayerResource, iClient, szCode);
}

public void AddMoney(int iClient, int iAmount, bool bTrackChange, bool bItemBought, const char[] szItemName)
{
	SDKCall(g_hAddMoney, iClient, iAmount, bTrackChange, bItemBought, szItemName);
}

void SwitchWeapon(int iClient, int iWeapon)
{
	SDKCall(g_hSwitchWeaponCall, iClient, iWeapon, 0);
}

bool BotTryToRetreat(int iClient, float fMaxRange = 400.0, float fDuration = -1.0)
{
	return SDKCall(g_hTryToRetreat, iClient, fMaxRange, fDuration);
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

bool CanThrowNade(int iClient)
{
	return (GetGameTime() - g_fThrowNadeTimestamp[iClient] > 5.0 && IsValidEntity(GetPlayerWeaponSlot(iClient, CS_SLOT_GRENADE)));
}

int FindLooseBomb()
{
	int iEnt = -1;
	while ((iEnt = FindEntityByClassname(iEnt, "weapon_c4")) != -1)
	{
		int iOwner = GetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity");
		if (!IsValidClient(iOwner))
			return iEnt;
	}
	return -1;
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

int FindNadeByDefIndex(int iClient, const int[] iDefIndices, int iCount)
{
	for (int i = 0; i < iCount; i++)
	{
		int iWeapon = eItems_FindWeaponByDefIndex(iClient, iDefIndices[i]);
		if (IsValidEntity(iWeapon))
			return iWeapon;
	}
	return -1;
}

void TryPickupWeapon(int iClient, char[] szClassname, const int[] iSkipList, int iSkipSize, int iSlot, float fClientEyes[3], float fOrigin[3])
{
    int iWeaponEnt = GetNearestEntity(iClient, szClassname);
    if (!IsValidEntity(iWeaponEnt))
        return;

    int iCurrent = GetPlayerWeaponSlot(iClient, iSlot);
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
            SmartBotMoveTo(iClient, fLoc, FASTEST_ROUTE, 1.2);

            if (GetVectorDistance(fOrigin, fLoc) < 50.0 && iCurrent != -1)
                CS_DropWeapon(iClient, iCurrent, false);
        }
    }
}

stock void SetupDetour(GameData hGameData, const char[] szConf, HookMode eMode, DHookCallback hCallback)
{
	DynamicDetour hDetour = DynamicDetour.FromConf(hGameData, szConf);
	if (!hDetour.Enable(eMode, hCallback))
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

int GetFriendsWithPrimary(int iClient)
{
	int iCount = 0;
	int iTeam = GetClientTeam(iClient);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (i == iClient || !IsValidClient(i))
			continue;

		if (GetClientTeam(i) != iTeam)
			continue;

		if (IsValidEntity(GetPlayerWeaponSlot(i, CS_SLOT_PRIMARY)))
			iCount++;
	}

	return iCount;
}

public int GetNearestGrenade(int iClient)
{
	if (g_bBombPlanted)
		return -1;

	int iClosestNade = -1;
	float fOrigin[3], fDist, fClosestDist = -1.0;

	GetClientAbsOrigin(iClient, fOrigin);

	for (int i = 0; i < g_aNades.Length; i++)
	{
		NadeLineup sNade;
		g_aNades.GetArray(i, sNade);

		if ((GetGameTime() - sNade.fTimestamp) < 25.0)
			continue;

		if (GetClientTeam(iClient) != sNade.iTeam)
			continue;

		int iEntity = eItems_FindWeaponByDefIndex(iClient, sNade.iDefIndex);
		if (!IsValidEntity(iEntity))
			continue;

		fDist = GetVectorDistance(fOrigin, sNade.fPos);
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

stock int GetNearestEntity(int iClient, char[] szClassname)
{
	int iNearestEntity = -1, iEntity = -1;
	float fClientOrigin[3], fEntityOrigin[3], fDistance, fNearestDistance = -1.0;
	
	GetClientAbsOrigin(iClient, fClientOrigin);
	
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

stock int ReplaceWeapon(int iClient, int iSlot, const char[] szClass, bool bHandleMoney = false)
{
	if (bHandleMoney)
	{
		char szAlias[64];
		strcopy(szAlias, sizeof(szAlias), szClass);
		ReplaceString(szAlias, sizeof(szAlias), "weapon_", "");
		CSWeaponID eWeaponID = CS_AliasToWeaponID(szAlias);
		if (eWeaponID != CSWeapon_NONE)
		{
			int iPrice = CS_GetWeaponPrice(iClient, eWeaponID);
			AddMoney(iClient, -iPrice, true, true, szClass);
		}
	}

	int iWeapon = GetPlayerWeaponSlot(iClient, iSlot);
	
	if (IsValidEntity(iWeapon))
	{
		if (GetEntPropEnt(iWeapon, Prop_Send, "m_hOwnerEntity") != iClient)
			SetEntPropEnt(iWeapon, Prop_Send, "m_hOwnerEntity", iClient);
		
		CS_DropWeapon(iClient, iWeapon, false, true);
		AcceptEntityInput(iWeapon, "Kill");
	}
	
	iWeapon = GivePlayerItem(iClient, szClass);
	
	if (IsValidEntity(iWeapon))
		EquipPlayerWeapon(iClient, iWeapon);
	
	return iWeapon;
}

bool IsPlayerReloading(int iClient)
{
	if (!IsValidEntity(g_iActiveWeapon[iClient]))
		return false;

	if (GetEntProp(g_iActiveWeapon[iClient], Prop_Data, "m_bInReload"))
		return true;

	if (GetEntProp(g_iActiveWeapon[iClient], Prop_Data, "m_iClip1") == 0)
		return true;

	if (GetEntPropFloat(g_iActiveWeapon[iClient], Prop_Send, "m_flNextPrimaryAttack") > GetGameTime())
		return true;

	return false;
}

public void CheckSniperRetreat(int iUserId)
{
	int iClient = GetClientOfUserId(iUserId);
	if (!IsValidClient(iClient) || !IsPlayerAlive(iClient) || !IsFakeClient(iClient))
		return;

	bool bTargetAlive = IsValidClient(g_iTarget[iClient]) && IsPlayerAlive(g_iTarget[iClient]);
	int iNearbyEnemies = GetEntData(iClient, g_iBotNearbyEnemiesOffset);

	if (bTargetAlive || iNearbyEnemies > 1)
		BotTryToRetreat(iClient, 400.0, 1.5);
}

public void TossCheapDrop(int iUserId)
{
	int iClient = GetClientOfUserId(iUserId);
	if (!IsValidClient(iClient) || !IsPlayerAlive(iClient))
		return;

	int iPrimary = GetPlayerWeaponSlot(iClient, CS_SLOT_PRIMARY);
	if (IsValidEntity(iPrimary))
		CS_DropWeapon(iClient, iPrimary, true);
}

public void BeginQuickSwitch(int iUserId)
{
    int iClient = GetClientOfUserId(iUserId);
    if (!IsValidClient(iClient))
        return;

    SwitchWeapon(iClient, GetPlayerWeaponSlot(iClient, CS_SLOT_KNIFE));
    RequestFrame(FinishQuickSwitch, iUserId);
}

public void FinishQuickSwitch(int iUserId)
{
	int iClient = GetClientOfUserId(iUserId);
	
	if (!IsValidClient(iClient))
		return;
	
	SwitchWeapon(iClient, GetPlayerWeaponSlot(iClient, CS_SLOT_PRIMARY));
}

public Action Timer_EnableSwitch(Handle hTimer, any iUserId)
{
	int iClient = GetClientOfUserId(iUserId);
	
	if (IsValidClient(iClient))
		g_bDontSwitch[iClient] = false;
	
	return Plugin_Stop;
}

public Action Timer_DontForceThrow(Handle hTimer, any iUserId)
{
	int iClient = GetClientOfUserId(iUserId);
	
	if (IsValidClient(iClient))
	{
		g_bThrowGrenade[iClient] = false;
		BotEquipBestWeapon(iClient, true);
	}
	
	return Plugin_Stop;
}

public void DelayThrow(int iUserId)
{
    int iClient = GetClientOfUserId(iUserId);
    
    if (IsValidClient(iClient))
    {
        g_bThrowGrenade[iClient] = true;
        CreateTimer(3.0, Timer_DontForceThrow, iUserId);
    }
}

public void SelectBestTargetPos(int iClient, float fTargetPos[3])
{
	if (!IsValidClient(g_iTarget[iClient]) || !IsPlayerAlive(g_iTarget[iClient]))
		return;

	int iHeadBone = LookupBone(g_iTarget[iClient], "head_0");
	int iSpineBone = LookupBone(g_iTarget[iClient], "spine_3");
	if (iHeadBone < 0 || iSpineBone < 0)
		return;

	bool bShootSpine;
	float fHead[3], fBody[3], fBad[3];
	GetBonePosition(g_iTarget[iClient], iHeadBone, fHead, fBad);
	GetBonePosition(g_iTarget[iClient], iSpineBone, fBody, fBad);

	fHead[2] += 4.0;

	bool bHeadVisible = BotIsVisible(iClient, fHead, false, -1);
	bool bBodyVisible = bHeadVisible && BotIsVisible(iClient, fBody, false, -1);

	if (bHeadVisible)
	{
		if (bBodyVisible)
		{
			if (!IsValidEntity(g_iActiveWeapon[iClient])) 
				return;

			int iDefIndex = GetEntProp(g_iActiveWeapon[iClient], Prop_Send, "m_iItemDefinitionIndex");

			switch (iDefIndex)
			{
				case DEFIDX_AK47, DEFIDX_AUG, DEFIDX_FAMAS, DEFIDX_GALIL, DEFIDX_M249, DEFIDX_M4A4, DEFIDX_MAC10, DEFIDX_P90, DEFIDX_MP5SD, DEFIDX_UMP45, DEFIDX_XM1014, DEFIDX_BIZON, DEFIDX_MAG7, DEFIDX_NEGEV, DEFIDX_SAWEDOFF, DEFIDX_MP7, DEFIDX_MP9, DEFIDX_NOVA, DEFIDX_SG556, DEFIDX_M4A1S:
				{
					float fTargetDistance = GetVectorDistance(g_fBotOrigin[iClient], fHead);
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
			int iBone = LookupBone(g_iTarget[iClient], g_szBoneNames[b]);
			if (iBone < 0)
				continue;

			GetBonePosition(g_iTarget[iClient], iBone, fHead, fBad);

			if (BotIsVisible(iClient, fHead, false, -1))
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

public bool TraceFilter_Ground(int iEntity, int iContentsMask)
{
	return (iEntity == 0 || iEntity > MaxClients);
}

bool GetGroundHeightNative(const float fPos[3], float &fHeight)
{
	float fStart[3], fEnd[3], fHitPos[3];
	fStart[0] = fPos[0];
	fStart[1] = fPos[1];
	fStart[2] = fPos[2] + 64.0;

	fEnd[0] = fPos[0];
	fEnd[1] = fPos[1];
	fEnd[2] = fPos[2] - 1024.0;

	TR_TraceRayFilter(fStart, fEnd, MASK_SOLID, RayType_EndPoint, TraceFilter_Ground);
	if (TR_DidHit())
	{
		TR_GetEndPosition(fHitPos);
		fHeight = fHitPos[2];
		return true;
	}

	fHeight = fPos[2];
	return false;
}

stock bool ProcessGrenadeThrow(int iClient, float fTarget[3], int iGrenadeEnt = -1)
{
	int iGrenadeSlot = iGrenadeEnt != -1 ? iGrenadeEnt : GetPlayerWeaponSlot(iClient, CS_SLOT_GRENADE);
	if (!IsValidEntity(iGrenadeSlot))
		return false;

	int iNadeDefIndex = GetEntProp(iGrenadeSlot, Prop_Send, "m_iItemDefinitionIndex");

	float fGroundTarget[3];
	fGroundTarget[0] = fTarget[0];
	fGroundTarget[1] = fTarget[1];
	fGroundTarget[2] = fTarget[2];

	float fHeight;
	if (GetGroundHeightNative(fTarget, fHeight))
		fGroundTarget[2] = fHeight;

	float fLookAt[3];
	if (!SolveGrenadeToss(iClient, fGroundTarget, fLookAt, iNadeDefIndex))
		return false;

	Array_Copy(fLookAt, g_fNadeTarget[iClient], 3);
	Array_Copy(fGroundTarget, g_fNadeSolveTarget[iClient], 3);
	g_iNadeSolveDefIndex[iClient] = iNadeDefIndex;
	g_bNadeResolved[iClient] = false;
	SwitchWeapon(iClient, iGrenadeSlot);
	RequestFrame(DelayThrow, GetClientUserId(iClient));
	return true;
}

bool SolveGrenadeToss(int iClient, const float fTarget[3], float fLookAt[3], int iNadeDefIndex)
{
	float fEyePos[3];
	GetClientEyePosition(iClient, fEyePos);

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

	// 粗测：角度步长优化为 8.0 度（原3.0，51次循环骤降至18次）
	for (float fPitch = -70.0; fPitch <= 70.0; fPitch += 8.0)
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

	// 精测：细化搜索（步长 1.5 度）
	for (float fPitch = fBestPitch - 4.0; fPitch <= fBestPitch + 4.0; fPitch += 1.5)
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

	float fFinalLandPos[3];
	float fFinalLaunchPitch = -10.0 + fBestPitch + FloatAbs(fBestPitch) * 10.0 / 90.0;
	SimulateGrenade(fEyePos, fYaw, fFinalLaunchPitch, fThrowSpeed, fGrav, iNadeDefIndex, fFinalLandPos);

	fFinalLandPos[2] += 10.0;
	float fTargetRaised[3];
	fTargetRaised[0] = fTarget[0];
	fTargetRaised[1] = fTarget[1];
	fTargetRaised[2] = fTarget[2] + 10.0;

	if (!IsPointVisible(fFinalLandPos, fTargetRaised))
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

	float fDt = 0.04; // 25Hz 离散采样步长，大幅降低微观逐Tick碰撞开销
	int iBounces;
	float fDetonateTime = GetNadeDetonateTime(iNadeDefIndex);
	float fThinkInterval = (iNadeDefIndex == DEFIDX_MOLOTOV || iNadeDefIndex == DEFIDX_INCENDIARY) ? 0.1 : 0.2;
	float fNextThink = fThinkInterval;
	float fMolotovMaxSlopeZ = Cosine(DegToRad(g_cvMolotovMaxSlope.FloatValue));

	for (float t = 0.0; t <= 4.0; t += fDt) // 手雷最大飞行时间上限截断为 4.0s（杜绝 60.0s 极端死循环，计算量暴降 93%）
	{
		float fNewVelZ = fVel[2] - fGravity * fDt;
		float fAvgVelZ = (fVel[2] + fNewVelZ) * 0.5;

		float fMove[3];
		fMove[0] = fVel[0] * fDt;
		fMove[1] = fVel[1] * fDt;
		fMove[2] = fAvgVelZ * fDt;
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
					float fDotClamp = GetVectorDotProduct(fVelNorm, fNormal);
					if (fDotClamp > 0.5)
						ScaleVector(fVel, 1.0 - fDotClamp + 0.5);
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
			float fRemaining = (1.0 - fFraction) * fDt;
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

stock bool IsSafe(int iClient)
{
	return IsFakeClient(iClient) && (GetGameTime() - g_fFreezeTimeEnd) < GetEntDataFloat(iClient, g_iBotSafeTimeOffset);
}

stock TaskType GetTask(int iClient)
{
    return IsFakeClient(iClient) ? view_as<TaskType>(GetEntData(iClient, g_iBotTaskOffset)) : view_as<TaskType>(-1);
}

stock void SetTask(int iClient, TaskType eTask)
{
	if (!IsFakeClient(iClient))
		return;

	SetEntData(iClient, g_iBotTaskOffset, eTask);
}

stock DispositionType GetDisposition(int iClient)
{
    return IsFakeClient(iClient) ? view_as<DispositionType>(GetEntData(iClient, g_iBotDispositionOffset)) : view_as<DispositionType>(-1);
}

stock void SetDisposition(int iClient, DispositionType eDisposition)
{
	if(!IsFakeClient(iClient))
		return;
		
	SetEntData(iClient, g_iBotDispositionOffset, eDisposition);
}

stock void SetPlayerTeammateColor(int iClient)
{
	if (GetClientTeam(iClient) <= CS_TEAM_SPECTATOR)
		return;

	if (g_iPlayerColor[iClient] > -1)
		return;

	for (int iColor = 0; iColor < 5; iColor++)
	{
		bool bColorTaken = false;

		for (int iOther = 1; iOther <= MaxClients; iOther++)
		{
			if (!IsValidClient(iOther))
				continue;

			if (GetClientTeam(iOther) != GetClientTeam(iClient))
				continue;

			if (g_iPlayerColor[iOther] == iColor && iOther != iClient)
			{
				bColorTaken = true;
				break;
			}
		}

		if (!bColorTaken)
		{
			g_iPlayerColor[iClient] = iColor;
			return;
		}
	}

	g_iPlayerColor[iClient] = -1;
}

public void AutoStop(int iClient, float fVel[3], float fAngles[3])
{
    float fPlayerVelocity[3], fVelAngle[3];
    GetEntPropVector(iClient, Prop_Data, "m_vecAbsVelocity", fPlayerVelocity);

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

stock bool IsValidClient(int iClient)
{
	return (iClient > 0 && iClient <= MaxClients && IsClientConnected(iClient) && IsClientInGame(iClient) && !IsClientSourceTV(iClient));
}

void SetNadeTimestamp(int iIndex, float fTime)
{
	NadeLineup sNade;
	g_aNades.GetArray(iIndex, sNade);
	sNade.fTimestamp = fTime;
	g_aNades.SetArray(iIndex, sNade);
}

void ResetNadeTimestamps()
{
	for (int i = 0; i < g_aNades.Length; i++)
	{
		NadeLineup sNade;
		g_aNades.GetArray(i, sNade);
		sNade.fTimestamp = 0.0;
		g_aNades.SetArray(i, sNade);
	}
}