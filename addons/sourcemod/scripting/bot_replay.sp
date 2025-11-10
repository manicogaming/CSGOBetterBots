#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#include <botmimic>
#include <ripext>
#include <bot_pause>

#pragma newdecls required
#pragma semicolon 1

// ============================================================================
// Plugin Information
// ============================================================================
public Plugin myinfo = 
{
	name = "Bot Round Start REC Player", 
	author = "Tasty cup", 
	description = "Play recordings for bots at round start", 
	version = "1.0.0", 
	url = ""
};

// Plugin inspiration comes from chunchun's replay plugin
// This plugin was independently implemented by me with functional optimizations
// Thanks to chunchun for inspiration and understanding

// ============================================================================
// Global Variables
// ============================================================================

// Bot state enumeration
enum BotState
{
    BotState_Normal = 0,     // Normal state
    BotState_PlayingREC,     // Playing REC
    BotState_Busy            // Busy state
}

// Round selection mode (default)
enum RoundSelectionMode
{
    Round_FullMatch = 0,    // Global round mode (play by current round)
    Round_Economy          // Economy round mode (select based on economy)
}

// Economy selection mode
enum EconomySelectionMode
{
    Economy_SingleTeam = 0,     // Single team economy mode (default)
    Economy_BothTeams = 1      // Both teams economy mode
}

// Hybrid algorithm core data structure
// Bot economy information
enum struct BotEconomyInfo
{
    int client;              // Bot client index
    int money;               // Current money
    int teamIndex;           // Index in team (0-4)
    int assignedRecIndex;    // Assigned REC index
    int assignedCost;        // Assigned REC cost
    int assignedValue;       // Assigned REC value
    char assignedRecName[PLATFORM_MAX_PATH];  // Assigned REC name
}

// REC equipment information
enum struct RecEquipmentInfo
{
    char recName[PLATFORM_MAX_PATH];  // REC file name
    int totalCost;           // Total cost
    int totalValue;          // Total value
    int tacticalValue;       // Tactical value (weighted)
    bool hasPrimary;         // Has primary weapon
    bool hasSniper;          // Has sniper rifle
    bool hasRifle;           // Has rifle
    int utilityCount;        // Utility count
    char primaryWeapon[64];  // Primary weapon name
}

// Knapsack DP result
enum struct KnapsackResult
{
    int totalValue;          // Total equipment value
    int totalCost;           // Total cost
    bool isValid;            // Is valid
    int assignment[MAXPLAYERS+1];  // REC index assigned to each bot (-1 means not assigned)
}

// Bot state
bool g_bPlayingRoundStartRec[MAXPLAYERS+1];           // Is playing REC
char g_szRoundStartRecPath[MAXPLAYERS+1][PLATFORM_MAX_PATH];  // REC path
char g_szCurrentRecName[MAXPLAYERS+1][PLATFORM_MAX_PATH];     // Current REC file name
char g_szAssignedRecName[MAXPLAYERS+1][PLATFORM_MAX_PATH];    // Assigned REC name in economy mode
int g_iAssignedRecIndex[MAXPLAYERS+1];                // Assigned REC index
int g_iRecStartMoney[MAXPLAYERS+1];                   // Money at REC start
bool g_bRecMoneySet[MAXPLAYERS+1];                    // Whether money has been set
float g_fRecStartTime[MAXPLAYERS+1];                  // REC start time
BotState g_BotShared_State[MAXPLAYERS+1];             // Each bot's state

// Folder selection
char g_szCurrentRecFolder[PLATFORM_MAX_PATH];         // Currently selected REC folder
char g_szBotRecFolder[MAXPLAYERS+1][PLATFORM_MAX_PATH];  // Demo folder used by each bot
bool g_bRecFolderSelected = false;                    // Whether folder has been selected

// Round information
int g_iCurrentRound = 0;                              // Current round number
bool g_bBombPlanted = false;                          // Whether bomb has been planted
bool g_bBombPlantedThisRound = false;                 // Whether bomb planted this round

// Mode settings
RoundSelectionMode g_iRoundMode = Round_Economy;     // Round selection mode
EconomySelectionMode g_iEconomyMode = Economy_SingleTeam;  // Economy selection mode
int g_iSelectedRoundForTeam[4] = {-1, ...};           // Selected round number for each faction
bool g_bEconomyBasedSelection = false;                // Flag whether using economy mode selection
char g_szSelectedDemoForTeam[4][PLATFORM_MAX_PATH];   // Selected demo folder for each faction
ArrayList g_hAssignedRecsForTeam[4];                  // Assigned REC list for each faction

// Freeze time validation
float g_fValidRoundFreezeTimes[31];                   // Store valid freeze time for each round (for economy system)
bool g_bRoundFreezeTimeValid[31];                     // Mark whether freeze time for this round is valid (for economy system)
float g_fAllRoundFreezeTimes[31];                     // Store all round freeze times (for pause system)
bool g_bAllRoundFreezeTimeValid[31];                  // Mark all round freeze times (for pause system)
float g_fStandardFreezeTime = 20.0;                   // Standard freeze time

// SDK offsets
int g_BotShared_EnemyVisibleOffset = -1;    // Enemy visible offset
int g_BotShared_EnemyOffset = -1;           // Enemy offset

// Enemy cache
int g_BotShared_CachedEnemy[MAXPLAYERS+1] = {-1, ...};        // Cached enemy
float g_BotShared_EnemyCacheTime[MAXPLAYERS+1] = {0.0, ...};  // Cache time

// ConVars
ConVar g_cvEconomyMode;
ConVar g_cvRoundMode;
ConVar g_cvEnableDrops;

// Weapon data tables
StringMap g_hWeaponPrices;
StringMap g_hWeaponConversion_T;
StringMap g_hWeaponConversion_CT;
StringMap g_hWeaponTypes;

// Pause system (for global mode)
bool g_bPausePluginLoaded = false;                // Use bot_pause plugin

// Purchase data (for economy mode)
JSONObject g_jPurchaseData = null;
// C4 holder data
JSONArray g_jC4HolderData = null;

// Purchase system
ArrayList g_hPurchaseActions[MAXPLAYERS+1];       // Purchase queue for each bot
int g_iPurchaseActionIndex[MAXPLAYERS+1];         // Current purchase action index
Handle g_hPurchaseTimer[MAXPLAYERS+1];            // Purchase timer for each bot
ArrayList g_hFinalInventory[MAXPLAYERS+1];        // Final equipment each bot should have
bool g_bInventoryVerified[MAXPLAYERS+1];          // Whether equipment has been verified
Handle g_hVerifyTimer[MAXPLAYERS+1];              // Equipment verification timer
bool g_bAllowPurchase[MAXPLAYERS+1];              // Mark whether purchase is allowed (to distinguish system purchase from manual purchase)
ArrayList g_hDropActions[MAXPLAYERS+1];           // Drop queue for each bot
int g_iDropActionIndex[MAXPLAYERS+1];             // Current drop action index
Handle g_hDropTimer[MAXPLAYERS+1];                // Drop timer for each bot

// Bomb carrier detection
Handle g_hBombCarrierCheckTimer = null;              // Bomb carrier detection timer

// Damage detection
int g_iLastAttacker[MAXPLAYERS+1];                // Last attacker
int g_iLastDamageType[MAXPLAYERS+1];              // Last damage type

// ============================================================================
// Plugin Lifecycle
// ============================================================================

public void OnPluginStart()
{
    // Initialize weapon data  
    InitWeaponData();    

    // Initialize shared library
    if (!BotShared_Init())
    {
        SetFailState("[Bot REC] Failed to initialize Bot Shared library");
    }

    // Check if bot_pause plugin is loaded
    g_bPausePluginLoaded = LibraryExists("bot_pause");

    // Create ConVars
    g_cvEconomyMode = CreateConVar("sm_botrec_economy_mode", "0", 
        "Economy selection mode: 0=Single Team (default), 1=Both Teams", 
        FCVAR_NOTIFY, true, 0.0, true, 1.0);  // Range 0-1
    
    g_cvRoundMode = CreateConVar("sm_botrec_round_mode", "0", 
        "Round selection mode: 0=Full Match (default), 1=Economy Based", 
        FCVAR_NOTIFY, true, 0.0, true, 1.0);

    g_cvEnableDrops = CreateConVar("sm_botrec_enable_drops", "1",
        "Enable/disable weapon drop system: 0=Disabled, 1=Enabled",
        FCVAR_NOTIFY, true, 0.0, true, 1.0);    
    
    // Register admin commands
    RegAdminCmd("sm_botrec_economy", Command_SetEconomyMode, ADMFLAG_GENERIC, 
        "Set economy mode: 0=Off, 1=Single Team, 2=Both Teams");
    
    RegAdminCmd("sm_botrec_round", Command_SetRoundMode, ADMFLAG_GENERIC, 
        "Set round mode: 0=Full Match, 1=Economy Based");
    
    RegAdminCmd("sm_botrec_status", Command_ShowStatus, ADMFLAG_GENERIC, 
        "Show current bot REC status");

    RegAdminCmd("sm_botrec_debug", Command_DebugInfo, ADMFLAG_GENERIC, 
        "Show detailed debug information");      

    RegAdminCmd("sm_botrec_select", Command_SelectDemo, ADMFLAG_GENERIC,
        "Select specific demo folder");          

    // Hook game events
    HookEvent("round_prestart", Event_RoundPreStart);
    HookEvent("round_start", Event_RoundStart);
    HookEvent("player_spawn", Event_PlayerSpawn);
    
    // Initialize all client data
    for (int i = 1; i <= MaxClients; i++)
    {
        ResetClientData(i);
        
        // Initialize purchase data
        g_hPurchaseTimer[i] = null;
        g_hPurchaseActions[i] = null;
        g_iPurchaseActionIndex[i] = 0;
        g_hFinalInventory[i] = null;
        g_bInventoryVerified[i] = false;
        g_hVerifyTimer[i] = null;
        g_bAllowPurchase[i] = false;
        g_hDropTimer[i] = null;
        g_hDropActions[i] = null;
        g_iDropActionIndex[i] = 0;        
    }
    
    // Reset faction round selection
    for (int i = 0; i < sizeof(g_iSelectedRoundForTeam); i++)
    {
        g_iSelectedRoundForTeam[i] = -1;
        g_szSelectedDemoForTeam[i][0] = '\0';  
        g_hAssignedRecsForTeam[i] = null;
    }     
    
    PrintToServer("[Bot REC] Plugin loaded");
}

public void OnMapStart()
{
    // Reset rec folder selection
    g_szCurrentRecFolder[0] = '\0';
    g_bRecFolderSelected = false;
    
    // Reset faction round selection
    for (int i = 0; i < sizeof(g_iSelectedRoundForTeam); i++)
    {
        g_iSelectedRoundForTeam[i] = -1;
        g_szSelectedDemoForTeam[i][0] = '\0';    

        // Clean assigned REC list
        if (g_hAssignedRecsForTeam[i] != null)
        {
            delete g_hAssignedRecsForTeam[i];
            g_hAssignedRecsForTeam[i] = null;
        }
    }
    
    // Initialize pause system freeze time array
    for (int i = 0; i < 31; i++)
    {
        g_bAllRoundFreezeTimeValid[i] = false;
        g_fAllRoundFreezeTimes[i] = 0.0;
    }
    
    // Initialize all client data
    for (int i = 1; i <= MaxClients; i++)
    {
        ResetClientData(i);
    }
    
    // Clean purchase data
    if (g_jPurchaseData != null)
    {
        delete g_jPurchaseData;
        g_jPurchaseData = null;
    }

    // Clean C4 holder data
    if (g_jC4HolderData != null)
    {
        delete g_jC4HolderData;
        g_jC4HolderData = null;
    }
    
    // Get map name
    char szMap[64];
    GetCurrentMap(szMap, sizeof(szMap));
    GetMapDisplayName(szMap, szMap, sizeof(szMap));
    
    PrintToServer("[Bot REC] Map started: %s", szMap);
}

public void OnMapEnd()
{
    // Clean purchase data
    if (g_jPurchaseData != null)
    {
        delete g_jPurchaseData;
        g_jPurchaseData = null;
    }
    
    // Clean bomb carrier detection timer
    if (g_hBombCarrierCheckTimer != null)
    {
        KillTimer(g_hBombCarrierCheckTimer);
        g_hBombCarrierCheckTimer = null;
    }
}

public void OnClientPostAdminCheck(int client)
{
    if (!IsValidClient(client))
        return;
    
    ResetClientData(client);
}

public void OnClientDisconnect(int client)
{
    ResetClientData(client);
    
    // Clean purchase related data
    if (g_hPurchaseTimer[client] != null)
    {
        KillTimer(g_hPurchaseTimer[client]);
        g_hPurchaseTimer[client] = null;
    }
    
    if (g_hPurchaseActions[client] != null)
    {
        delete g_hPurchaseActions[client];
        g_hPurchaseActions[client] = null;
    }
    
    if (g_hVerifyTimer[client] != null)
    {
        KillTimer(g_hVerifyTimer[client]);
        g_hVerifyTimer[client] = null;
    }
    
    if (g_hFinalInventory[client] != null)
    {
        delete g_hFinalInventory[client];
        g_hFinalInventory[client] = null;
    }
    
    g_bAllowPurchase[client] = false;
    
    // Clean drop data
    if (g_hDropTimer[client] != null)
    {
        KillTimer(g_hDropTimer[client]);
        g_hDropTimer[client] = null;
    }
    
    if (g_hDropActions[client] != null)
    {
        delete g_hDropActions[client];
        g_hDropActions[client] = null;
    }
}

// ============================================================================
// Game Event Handling
// ============================================================================

public void Event_RoundPreStart(Event event, const char[] name, bool dontBroadcast)
{
    g_iCurrentRound = GameRules_GetProp("m_totalRoundsPlayed");
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    BotShared_ResetBombState();
    
    // Read current mode from ConVar
    g_iEconomyMode = view_as<EconomySelectionMode>(g_cvEconomyMode.IntValue);
    g_iRoundMode = view_as<RoundSelectionMode>(g_cvRoundMode.IntValue);
    
    PrintToServer("[Bot REC] Round %d | Mode: %s | Economy: %s", 
        g_iCurrentRound,
        g_iRoundMode == Round_Economy ? "ECONOMY" : "FULL",
        g_iEconomyMode == Economy_SingleTeam ? "SINGLE" : "BOTH");
    
    char szMap[64];
    GetCurrentMap(szMap, sizeof(szMap));
    GetMapDisplayName(szMap, szMap, sizeof(szMap));
    
    // First round or after halftime select new rec folder
    if (g_iCurrentRound == 0 || g_iCurrentRound == 15)
    {
        if (SelectRandomRecFolder(szMap))
        {
            PrintToServer("[Bot REC] Selected folder: %s", g_szCurrentRecFolder);
            LoadFreezeTimes(szMap, g_szCurrentRecFolder);
            LoadPurchaseDataFile(g_szCurrentRecFolder);
        }
        else
        {
            g_szCurrentRecFolder[0] = '\0';
            g_bRecFolderSelected = false;
        }
    }
    else if (g_bRecFolderSelected && !g_bRoundFreezeTimeValid[g_iCurrentRound])
    {
        PrintToServer("[Bot REC] Freeze time not loaded for round %d, reloading...", g_iCurrentRound);
        LoadFreezeTimes(szMap, g_szCurrentRecFolder);
    }
    
    // If in economy round mode
    if (g_iRoundMode == Round_Economy && g_bRecFolderSelected)
    {
        g_bEconomyBasedSelection = true;
        
        // Reset faction round selection
        g_iSelectedRoundForTeam[CS_TEAM_T] = -1;
        g_iSelectedRoundForTeam[CS_TEAM_CT] = -1;
        g_szSelectedDemoForTeam[CS_TEAM_T][0] = '\0';  
        g_szSelectedDemoForTeam[CS_TEAM_CT][0] = '\0';  
        
        // Clean assigned REC list
        if (g_hAssignedRecsForTeam[CS_TEAM_T] != null)
            delete g_hAssignedRecsForTeam[CS_TEAM_T];
        if (g_hAssignedRecsForTeam[CS_TEAM_CT] != null)
            delete g_hAssignedRecsForTeam[CS_TEAM_CT];
        
        g_hAssignedRecsForTeam[CS_TEAM_T] = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
        g_hAssignedRecsForTeam[CS_TEAM_CT] = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
        
        // Select based on economy mode
        if (g_iEconomyMode == Economy_SingleTeam)
        {
            SelectRoundByEconomy(CS_TEAM_T);
            SelectRoundByEconomy(CS_TEAM_CT);
        }
        else if (g_iEconomyMode == Economy_BothTeams)
        {
            int iSelectedRound = SelectRoundByBothTeamsEconomy();
            g_iSelectedRoundForTeam[CS_TEAM_T] = iSelectedRound;
            g_iSelectedRoundForTeam[CS_TEAM_CT] = iSelectedRound;
        }
    }
    else if (g_iRoundMode == Round_FullMatch)
    {
        g_bEconomyBasedSelection = false;
    }
    
    // Dynamic pause system in global mode
    PrintToServer("[Pause Debug] Checking pause conditions:");
    PrintToServer("[Pause Debug]   - Round mode: %s", g_iRoundMode == Round_FullMatch ? "FULL" : "ECONOMY");
    PrintToServer("[Pause Debug]   - Folder selected: %s", g_bRecFolderSelected ? "YES" : "NO");
    PrintToServer("[Pause Debug]   - Current round: %d", g_iCurrentRound);
    
    if (g_iRoundMode == Round_FullMatch && g_bRecFolderSelected)
    {
        PrintToServer("[Pause Debug] Calling ScheduleDynamicPause for round %d", g_iCurrentRound);
        ScheduleDynamicPause(g_iCurrentRound);
    }
    else
    {
        PrintToServer("[Pause Debug] Skipping pause (conditions not met)");
    }
    
    // Assign and play REC for all bots
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsValidClient(i) || !IsFakeClient(i) || !IsPlayerAlive(i))
            continue;
        
        AssignAndPlayRec(i);
    }

    // Assign C4 immediately at freeze time start
    if (g_bRecFolderSelected)
    {
        // Execute after 0.1 seconds, ensure all bot RECs are assigned
        CreateTimer(0.1, Timer_AssignC4AtFreezeStart, _, TIMER_FLAG_NO_MAPCHANGE);
    }
    
    // Clean old timer
    if (g_hBombCarrierCheckTimer != null)
    {
        CloseHandle(g_hBombCarrierCheckTimer);
        g_hBombCarrierCheckTimer = null;
    }
    
    // Get freeze time
    ConVar cvFreezeTime = FindConVar("mp_freezetime");
    float fFreezeTime = (cvFreezeTime != null) ? cvFreezeTime.FloatValue : 15.0;
    
    // Check bomb carrying T 90 seconds after freeze ends
    float fBombCheckDelay = fFreezeTime + 90.0;
    g_hBombCarrierCheckTimer = CreateTimer(fBombCheckDelay, Timer_CheckBombCarrier, _, TIMER_FLAG_NO_MAPCHANGE);
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    
    if (!IsValidClient(client) || !IsFakeClient(client))
        return;
    
    g_iAssignedRecIndex[client] = -1;
    g_bRecMoneySet[client] = false;
    g_bInventoryVerified[client] = false;  
}

// ============================================================================
// OnPlayerRunCmd - Detect bomb planting and enemies
// ============================================================================

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
    if (client < 1 || client > MaxClients)
        return Plugin_Continue;
    
    // Detect bomb planting
    g_bBombPlanted = !!GameRules_GetProp("m_bBombPlanted");
    
    if (g_bBombPlanted && !g_bBombPlantedThisRound)
    {
        g_bBombPlantedThisRound = true;
        
        // Decide whether to stop REC based on mode
        if (g_iRoundMode == Round_Economy && g_iEconomyMode == Economy_SingleTeam)
        {
            StopCTBotsRec_EconomyMode();
        }
        else if (g_iRoundMode == Round_FullMatch || 
                (g_iRoundMode == Round_Economy && g_iEconomyMode == Economy_BothTeams))
        {
            StopBotsRec_FullMatchMode();
        }
    }
    
    if (!IsValidClient(client) || !IsPlayerAlive(client) || !IsFakeClient(client))
        return Plugin_Continue;
    
    if (g_bPlayingRoundStartRec[client] && BotMimic_IsPlayerMimicing(client))
    {
        static int iCheckCounter[MAXPLAYERS+1];
        static int iLastHealth[MAXPLAYERS+1];
    
        iCheckCounter[client]++;
    
        if (iCheckCounter[client] >= 10)
        {
            iCheckCounter[client] = 0;
        
            // Get fresh every time
            int iEnemy = BotShared_GetEnemy(client);  
            bool bSeeEnemy = false;
        
            // First validate enemy
            if (iEnemy != -1 && BotShared_IsValidClient(iEnemy) && IsPlayerAlive(iEnemy))
            {
                int iClientTeam = GetClientTeam(client);
                int iEnemyTeam = GetClientTeam(iEnemy);
        
                // Ensure it's a real enemy
                if (iClientTeam != iEnemyTeam)
                {
                    if (g_iRoundMode == Round_FullMatch || 
                        (g_iRoundMode == Round_Economy && g_iEconomyMode == Economy_BothTeams))
                    {
                        // Add extra validation
                        // Enemy must be "playing and still playing"
                        if (g_bPlayingRoundStartRec[iEnemy] && BotMimic_IsPlayerMimicing(iEnemy))
                        {
                            bSeeEnemy = false;  // Enemy is indeed playing, don't stop
                            
                            // Add debug log
                            #if defined DEBUG_MODE
                            PrintToServer("[Debug] %d sees %d (both playing REC) - NOT stopping", 
                                client, iEnemy);
                            #endif
                        }
                        else
                        {
                            bSeeEnemy = BotShared_CanSeeEnemy(client);
                            
                            #if defined DEBUG_MODE
                            if (bSeeEnemy)
                                PrintToServer("[Debug] %d sees %d (enemy NOT playing) - stopping", 
                                    client, iEnemy);
                            #endif
                        }
                    }
                    else
                    {
                        bSeeEnemy = BotShared_CanSeeEnemy(client);
                    }
                }
            }
        
            // Damage detection with time window validation
            int iCurrentHealth = GetClientHealth(client);
            int iDamage = iLastHealth[client] - iCurrentHealth;
            bool bShouldStopFromDamage = false;
        
            if (iDamage > 0 && iLastHealth[client] > 0)
            {
                if (g_iRoundMode == Round_FullMatch || 
                    (g_iRoundMode == Round_Economy && g_iEconomyMode == Economy_BothTeams))
                {
                    int iAttacker = g_iLastAttacker[client];
                
                    // Check both play state and Mimic state
                    if (BotShared_IsValidClient(iAttacker) && 
                        IsFakeClient(iAttacker) && 
                        IsPlayerAlive(iAttacker) &&  // Attacker must be alive
                        g_bPlayingRoundStartRec[iAttacker] && 
                        BotMimic_IsPlayerMimicing(iAttacker))  // Must actually be playing
                    {
                        bShouldStopFromDamage = false;
                        
                        #if defined DEBUG_MODE
                        PrintToServer("[Debug] %d damaged by %d (attacker playing REC) - NOT stopping", 
                            client, iAttacker);
                        #endif
                    }
                    else
                    {
                        bShouldStopFromDamage = ShouldStopFromDamage(iDamage, g_iLastDamageType[client]);
                        
                        #if defined DEBUG_MODE
                        if (bShouldStopFromDamage)
                            PrintToServer("[Debug] %d damaged (attacker NOT playing) - stopping", 
                                client);
                        #endif
                    }
                }
                else
                {
                    bShouldStopFromDamage = ShouldStopFromDamage(iDamage, g_iLastDamageType[client]);
                }
            }
        
            iLastHealth[client] = iCurrentHealth;
        
            if (bSeeEnemy || bShouldStopFromDamage)
            {
                BotMimic_StopPlayerMimic(client);
                g_bPlayingRoundStartRec[client] = false;
            
                char szName[MAX_NAME_LENGTH];
                GetClientName(client, szName, sizeof(szName));
            
                char szReason[64];
                if (bSeeEnemy) 
                    strcopy(szReason, sizeof(szReason), "saw enemy");
                else if (bShouldStopFromDamage) 
                    Format(szReason, sizeof(szReason), "took %d damage (type: %d)", 
                        iDamage, g_iLastDamageType[client]);
            
                PrintToServer("[Bot REC] Client %d (%s) stopped rec: %s", 
                    client, szName, szReason);
            }
        }
    }
    
    return Plugin_Continue;
}

// ============================================================================
// BotMimic Callbacks
// ============================================================================

public void BotMimic_OnPlayerStopsMimicing(int client, char[] name, char[] category, char[] path)
{
    if (g_bPlayingRoundStartRec[client])
    {
        // Reset Bot state to normal
        BotShared_ResetBotState(client);

        g_bPlayingRoundStartRec[client] = false;
        PrintToServer("[Bot REC] Client %d finished round start rec", client);
        
        // Safely stop purchase timer
        if (g_hPurchaseTimer[client] != null)
        {
            KillTimer(g_hPurchaseTimer[client]);
            g_hPurchaseTimer[client] = null;  
        }
        
        // Clean purchase action data
        if (g_hPurchaseActions[client] != null)
        {
            delete g_hPurchaseActions[client];
            g_hPurchaseActions[client] = null;
        }
        g_iPurchaseActionIndex[client] = 0;
        
        // Safely stop verification timer
        if (g_hVerifyTimer[client] != null)
        {
            KillTimer(g_hVerifyTimer[client]);
            g_hVerifyTimer[client] = null; 
        }

        // Safely stop drop timer
        if (g_hDropTimer[client] != null)
        {
            KillTimer(g_hDropTimer[client]);
            g_hDropTimer[client] = null;  
        }
        
        // Clean drop actions
        if (g_hDropActions[client] != null)
        {
            delete g_hDropActions[client];
            g_hDropActions[client] = null;
        }
        g_iDropActionIndex[client] = 0;
        
        // Unhook damage
        SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
    }
}

// ============================================================================
// Damage Hook - Prevent fall damage while playing REC, record damage info
// ============================================================================

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    // Record damage info for later judgment
    g_iLastAttacker[victim] = attacker;
    g_iLastDamageType[victim] = damagetype;
    
    // If playing REC
    if (g_bPlayingRoundStartRec[victim])
    {
        // Fall damage - completely prevent
        if (damagetype & DMG_FALL)
        {
            return Plugin_Handled;
        }
    }
    
    return Plugin_Continue;
}

// ============================================================================
// REC Assignment and Playback
// ============================================================================

void AssignAndPlayRec(int client)
{
    char szBotName[MAX_NAME_LENGTH];
    GetClientName(client, szBotName, sizeof(szBotName));
    
    PrintToServer("[Bot REC] Processing bot %d (%s)", client, szBotName);
    
    char szRecPath[PLATFORM_MAX_PATH];
    bool bFoundRec = false;
    int iRoundToUse = g_iCurrentRound;
    
    // Select rec based on mode
    if (g_bEconomyBasedSelection)
    {
        int iTeam = GetClientTeam(client);
        int iSelectedRound = g_iSelectedRoundForTeam[iTeam];
        
        if (iSelectedRound != -1)
        {
            iRoundToUse = iSelectedRound;
            bFoundRec = GetRoundStartRecForRound(client, iSelectedRound, szRecPath, sizeof(szRecPath));
            PrintToServer("[Bot REC] [Economy Mode] Bot %d using selected round %d", client, iSelectedRound);
        }
        else
        {
            PrintToServer("[Bot REC] [Economy Mode] Bot %d: No round selected for team %d", client, iTeam);
        }
    }
    else
    {
        bFoundRec = GetRoundStartRec(client, g_iCurrentRound, szRecPath, sizeof(szRecPath));
        PrintToServer("[Bot REC] [Full Match Mode] Bot %d using current round %d", client, g_iCurrentRound);
    }
    
    if (bFoundRec)
    {
        strcopy(g_szRoundStartRecPath[client], sizeof(g_szRoundStartRecPath[]), szRecPath);
        
        PrintToServer("[Bot REC] Bot %d assigned rec: %s, rec_index: %d, round: %d", 
            client, szRecPath, g_iAssignedRecIndex[client], iRoundToUse);
        
        // Set money only in global mode
        if (g_iRoundMode == Round_FullMatch && !g_bRecMoneySet[client] && g_iRecStartMoney[client] > 0)
        {
            SetEntProp(client, Prop_Send, "m_iAccount", g_iRecStartMoney[client]);
            g_bRecMoneySet[client] = true;
            PrintToServer("[Bot REC] [Full Match] Bot %d money set to: %d", client, g_iRecStartMoney[client]);
        }
        else if (g_iRoundMode == Round_Economy)
        {
            int iCurrentMoney = GetEntProp(client, Prop_Send, "m_iAccount");
            PrintToServer("[Bot REC] [Economy] Bot %d keeping current money: $%d", client, iCurrentMoney);
        }
        
        // Load purchase data
        bool bPurchaseLoaded = LoadPurchaseActionsForBot(client, iRoundToUse);
        PrintToServer("[Bot REC] Bot %d purchase data loaded: %s", 
            client, bPurchaseLoaded ? "YES" : "NO");
        
        if (bPurchaseLoaded)
        {
            // Clean old purchase timer
            if (g_hPurchaseTimer[client] != null)
            {
                KillTimer(g_hPurchaseTimer[client]);
                g_hPurchaseTimer[client] = null;
            }
            
            // Create purchase execution timer
            DataPack pack = new DataPack();
            pack.WriteCell(GetClientUserId(client));
            g_hPurchaseTimer[client] = CreateTimer(0.1, Timer_ExecutePurchaseAction, pack, 
                TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
            
            PrintToServer("[Bot REC] Bot %d purchase timer started", client);
        }
        
        // Start playing REC
        g_bPlayingRoundStartRec[client] = true;
        float fGameTime = GetGameTime();
        g_fRecStartTime[client] = fGameTime;
        
        PrintToServer("[Bot REC] Bot %d REC start time set to: %.2f", client, fGameTime);
        
        BotMimic_PlayRecordFromFile(client, szRecPath);
        
        // Hook damage
        SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

        // Set Bot state to playing REC
        BotShared_SetBotState(client, BotState_PlayingREC);
        
        PrintToServer("[Bot REC] Bot %d playing rec, start_time: %.1f", 
            client, g_fRecStartTime[client]);
    }
    else
    {
        PrintToServer("[Bot REC] Bot %d: No rec found for round %d", client, iRoundToUse);
    }
}

// ============================================================================
// REC File Selection
// ============================================================================

bool SelectRandomRecFolder(const char[] szMap)
{
    char szMapBasePath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, szMapBasePath, sizeof(szMapBasePath), "data/botmimic/all/%s", szMap);
    
    if (!DirExists(szMapBasePath))
        return false;
    
    ArrayList hFolders = new ArrayList(PLATFORM_MAX_PATH);
    DirectoryListing hMapDir = OpenDirectory(szMapBasePath);
    if (hMapDir == null)
        return false;
    
    char szFolderName[PLATFORM_MAX_PATH];
    FileType iFileType;
    
    while (hMapDir.GetNext(szFolderName, sizeof(szFolderName), iFileType))
    {
        if (iFileType == FileType_Directory && strcmp(szFolderName, ".") != 0 && strcmp(szFolderName, "..") != 0)
        {
            hFolders.PushString(szFolderName);
        }
    }
    
    delete hMapDir;
    
    if (hFolders.Length == 0)
    {
        delete hFolders;
        return false;
    }
    
    // Randomly select a folder
    int iRandomFolder = GetRandomInt(0, hFolders.Length - 1);
    hFolders.GetString(iRandomFolder, g_szCurrentRecFolder, sizeof(g_szCurrentRecFolder));
    delete hFolders;
    
    g_bRecFolderSelected = true;

    // Load C4 holder data
    LoadC4HolderDataFile(g_szCurrentRecFolder);   

    return true;
}

bool GetRoundStartRec(int client, int iRound, char[] szPath, int iMaxLen)
{
    char szMap[64];
    GetCurrentMap(szMap, sizeof(szMap));
    GetMapDisplayName(szMap, szMap, sizeof(szMap));
    
    int iTeam = GetClientTeam(client);
    char szTeamName[4];
    
    if (iTeam == CS_TEAM_T)
        strcopy(szTeamName, sizeof(szTeamName), "T");
    else if (iTeam == CS_TEAM_CT)
        strcopy(szTeamName, sizeof(szTeamName), "CT");
    else
        return false;
    
    // Use bot-specific demo folder
    char szUseDemoFolder[PLATFORM_MAX_PATH];
    
    if (g_szBotRecFolder[client][0] != '\0')
    {
        strcopy(szUseDemoFolder, sizeof(szUseDemoFolder), g_szBotRecFolder[client]);
    }
    else if (g_bRecFolderSelected && g_szCurrentRecFolder[0] != '\0')
    {
        strcopy(szUseDemoFolder, sizeof(szUseDemoFolder), g_szCurrentRecFolder);
    }
    else
    {
        return false;
    }
    
    char szRoundPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, szRoundPath, sizeof(szRoundPath), "data/botmimic/all/%s/%s/round%d/%s", 
        szMap, szUseDemoFolder, iRound + 1, szTeamName);
    
    if (!DirExists(szRoundPath))
        return false;
    
    DirectoryListing hDir = OpenDirectory(szRoundPath);
    if (hDir == null)
        return false;
    
    ArrayList hRecFiles = new ArrayList(PLATFORM_MAX_PATH);
    char szFileName[PLATFORM_MAX_PATH];
    FileType iFileType;
    
    while (hDir.GetNext(szFileName, sizeof(szFileName), iFileType))
    {
        if (iFileType == FileType_File && StrContains(szFileName, ".rec") != -1)
        {
            char szFullPath[PLATFORM_MAX_PATH];
            Format(szFullPath, sizeof(szFullPath), "%s/%s", szRoundPath, szFileName);
            hRecFiles.PushString(szFullPath);
        }
    }
    
    delete hDir;
    
    if (hRecFiles.Length == 0)
    {
        delete hRecFiles;
        return false;
    }
    
    // In economy mode, get REC according to assigned order
    if (g_bEconomyBasedSelection && g_szAssignedRecName[client][0] != '\0')
    {
        char szAssignedRecName[PLATFORM_MAX_PATH];
        strcopy(szAssignedRecName, sizeof(szAssignedRecName), g_szAssignedRecName[client]);
        
        // Find matching REC file
        for (int r = 0; r < hRecFiles.Length; r++)
        {
            char szRecPath[PLATFORM_MAX_PATH];
            hRecFiles.GetString(r, szRecPath, sizeof(szRecPath));
            
            if (StrContains(szRecPath, szAssignedRecName) != -1)
            {
                strcopy(szPath, iMaxLen, szRecPath);
                
                // Extract and save rec file name
                char szRecFileName[PLATFORM_MAX_PATH];
                int iLastSlash = FindCharInString(szPath, '/', true);
                if (iLastSlash != -1)
                    strcopy(szRecFileName, sizeof(szRecFileName), szPath[iLastSlash + 1]);
                else
                    strcopy(szRecFileName, sizeof(szRecFileName), szPath);
                
                ReplaceString(szRecFileName, sizeof(szRecFileName), ".rec", "");
                strcopy(g_szCurrentRecName[client], sizeof(g_szCurrentRecName[]), szRecFileName);
                
                // Save assigned index to avoid fallback logic duplicate assignment
                g_iAssignedRecIndex[client] = r;
                
                GetRoundStartMoney(client, iRound);
                
                delete hRecFiles;
                return true;
            }
        }
        
        // If matching REC file not found, print warning and return false
        PrintToServer("[Bot REC] WARNING: Assigned REC '%s' not found for client %d", 
            szAssignedRecName, client);
        delete hRecFiles;
        return false;
    }
    else if (g_bEconomyBasedSelection)
    {
        // In economy mode, if no assignment list found, return false
        PrintToServer("[Bot REC] WARNING: No assigned REC name for client %d in economy mode", client);
        delete hRecFiles;
        return false;
    }
    
    // Original loop assignment logic (only for non-economy mode)
    if (g_iAssignedRecIndex[client] == -1)
    {
        int iAssignedCount = 0;
        for (int i = 1; i <= MaxClients; i++)
        {
            if (i == client || !IsValidClient(i) || !IsFakeClient(i))
                continue;
            if (GetClientTeam(i) == iTeam && g_iAssignedRecIndex[i] != -1)
                iAssignedCount++;
        }
        g_iAssignedRecIndex[client] = iAssignedCount % hRecFiles.Length;
    }
    
    int iIndex = g_iAssignedRecIndex[client] % hRecFiles.Length;
    hRecFiles.GetString(iIndex, szPath, iMaxLen);
    
    // Extract rec file name
    char szRecFileName[PLATFORM_MAX_PATH];
    int iLastSlash = FindCharInString(szPath, '/', true);
    if (iLastSlash != -1)
        strcopy(szRecFileName, sizeof(szRecFileName), szPath[iLastSlash + 1]);
    else
        strcopy(szRecFileName, sizeof(szRecFileName), szPath);
    
    ReplaceString(szRecFileName, sizeof(szRecFileName), ".rec", "");
    strcopy(g_szCurrentRecName[client], sizeof(g_szCurrentRecName[]), szRecFileName);
    
    GetRoundStartMoney(client, iRound);
    
    delete hRecFiles;
    return true;
}

bool GetRoundStartRecForRound(int client, int iRound, char[] szPath, int iMaxLen)
{
    // Similar to GetRoundStartRec, but uses specified round
    return GetRoundStartRec(client, iRound, szPath, iMaxLen);
}

bool GetRoundStartMoney(int client, int iRound)
{
    char szMap[64];
    GetCurrentMap(szMap, sizeof(szMap));
    GetMapDisplayName(szMap, szMap, sizeof(szMap));
    
    int iTeam = GetClientTeam(client);
    char szTeamName[4];
    
    if (iTeam == CS_TEAM_T)
        strcopy(szTeamName, sizeof(szTeamName), "T");
    else if (iTeam == CS_TEAM_CT)
        strcopy(szTeamName, sizeof(szTeamName), "CT");
    else
        return false;
    
    // Use demo-specific money configuration
    char szUseDemoFolder[PLATFORM_MAX_PATH];
    
    if (g_szBotRecFolder[client][0] != '\0')
    {
        strcopy(szUseDemoFolder, sizeof(szUseDemoFolder), g_szBotRecFolder[client]);
    }
    else if (g_bRecFolderSelected && g_szCurrentRecFolder[0] != '\0')
    {
        strcopy(szUseDemoFolder, sizeof(szUseDemoFolder), g_szCurrentRecFolder);
    }
    else
    {
        g_iRecStartMoney[client] = g_bEconomyBasedSelection ? GetEntProp(client, Prop_Send, "m_iAccount") : 16000;
        return true;
    }
    
    char szJsonPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, szJsonPath, sizeof(szJsonPath), 
        "data/botmimic/all/%s/%s/money.json", szMap, szUseDemoFolder);
    
    if (!FileExists(szJsonPath))
    {
        PrintToServer("[Bot Money] File not found: %s", szJsonPath);
        g_iRecStartMoney[client] = g_bEconomyBasedSelection ? GetEntProp(client, Prop_Send, "m_iAccount") : 16000;
        return true;
    }
    
    JSONObject jRoot = JSONObject.FromFile(szJsonPath);
    if (jRoot == null)
    {
        PrintToServer("[Bot Money] Failed to parse JSON");
        g_iRecStartMoney[client] = g_bEconomyBasedSelection ? GetEntProp(client, Prop_Send, "m_iAccount") : 16000;
        return false;
    }
    
    char szRoundKey[32];
    Format(szRoundKey, sizeof(szRoundKey), "round%d", iRound + 1);
    
    if (!jRoot.HasKey(szRoundKey))
    {
        PrintToServer("[Bot Money] No data for %s", szRoundKey);
        delete jRoot;
        g_iRecStartMoney[client] = g_bEconomyBasedSelection ? GetEntProp(client, Prop_Send, "m_iAccount") : 16000;
        return true;
    }
    
    JSONObject jRound = view_as<JSONObject>(jRoot.Get(szRoundKey));
    if (!jRound.HasKey(szTeamName))
    {
        PrintToServer("[Bot Money] Round %s has no data for team %s", szRoundKey, szTeamName);
        delete jRound;
        delete jRoot;
        g_iRecStartMoney[client] = g_bEconomyBasedSelection ? GetEntProp(client, Prop_Send, "m_iAccount") : 16000;
        return true;
    }
    
    JSONObject jTeam = view_as<JSONObject>(jRound.Get(szTeamName));
    
    // Use REC name to get money (new format)
    if (g_szCurrentRecName[client][0] != '\0' && jTeam.HasKey(g_szCurrentRecName[client]))
    {
        g_iRecStartMoney[client] = jTeam.GetInt(g_szCurrentRecName[client]);
        
        char szBotName[MAX_NAME_LENGTH];
        GetClientName(client, szBotName, sizeof(szBotName));
        PrintToServer("[Bot Money] Client %d (%s) using REC name '%s': $%d", 
            client, szBotName, g_szCurrentRecName[client], g_iRecStartMoney[client]);
        
        delete jTeam;
        delete jRound;
        delete jRoot;
        return true;
    }
    
    // Fallback to default value
    PrintToServer("[Bot Money] WARNING: No money data found for client %d (rec: '%s'), using default", 
        client, g_szCurrentRecName[client]);
    
    delete jTeam;
    delete jRound;
    delete jRoot;
    
    g_iRecStartMoney[client] = g_bEconomyBasedSelection ? GetEntProp(client, Prop_Send, "m_iAccount") : 16000;
    return true;
}

// ============================================================================
// Economy Mode - Round Selection
// ============================================================================

void SelectRoundByEconomy(int iTeam)
{
    char szTeamName[4];
    if (iTeam == CS_TEAM_T)
        strcopy(szTeamName, sizeof(szTeamName), "T");
    else if (iTeam == CS_TEAM_CT)
        strcopy(szTeamName, sizeof(szTeamName), "CT");
    else
        return;
    
    // Collect all bots in this team and sort by economy
    ArrayList hTeamBots = new ArrayList();
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i) && IsFakeClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == iTeam)
            hTeamBots.Push(i);
    }
    
    int iBotCount = hTeamBots.Length;
    if (iBotCount == 0)
    {
        delete hTeamBots;
        PrintToServer("[Economy Hybrid] No bots in team %s", szTeamName);
        return;
    }
    
    // Sort by economy from low to high
    SortADTArrayCustom(hTeamBots, Sort_BotsByMoney);
    
    // Calculate team total economy
    int iTotalMoney = 0;
    for (int i = 0; i < iBotCount; i++)
    {
        int client = hTeamBots.Get(i);
        iTotalMoney += GetEntProp(client, Prop_Send, "m_iAccount");
    }
    
    PrintToServer("[Economy Hybrid] Team %s - Bot count: %d, Total money: $%d", 
        szTeamName, iBotCount, iTotalMoney);
    
    // Check if all bots have economy less than 3000
    bool bAllUnder3000 = true;
    for (int i = 0; i < iBotCount; i++)
    {
        int client = hTeamBots.Get(i);
        if (GetEntProp(client, Prop_Send, "m_iAccount") >= 3000)
        {
            bAllUnder3000 = false;
            break;
        }
    }
    
    // Check if current is pistol round
    bool bCurrentIsPistol = IsCurrentRoundPistol();
    
    PrintToServer("[Economy Hybrid] Team %s - All under $3000: %s, Current is pistol: %s",
        szTeamName, bAllUnder3000 ? "YES" : "NO", bCurrentIsPistol ? "YES" : "NO");
    
    // Get map and all demo folders
    char szMap[64];
    GetCurrentMap(szMap, sizeof(szMap));
    GetMapDisplayName(szMap, szMap, sizeof(szMap));
    
    char szMapBasePath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, szMapBasePath, sizeof(szMapBasePath), "data/botmimic/all/%s", szMap);
    
    if (!DirExists(szMapBasePath))
    {
        PrintToServer("[Economy Hybrid] ERROR: Map path does not exist: %s", szMapBasePath);
        delete hTeamBots;
        return;
    }
    
    ArrayList hDemoFolders = new ArrayList(PLATFORM_MAX_PATH);
    DirectoryListing hMapDir = OpenDirectory(szMapBasePath);
    if (hMapDir != null)
    {
        char szFolderName[PLATFORM_MAX_PATH];
        FileType iFileType;
        
        while (hMapDir.GetNext(szFolderName, sizeof(szFolderName), iFileType))
        {
            if (iFileType == FileType_Directory && strcmp(szFolderName, ".") != 0 && strcmp(szFolderName, "..") != 0)
            {
                hDemoFolders.PushString(szFolderName);
            }
        }
        delete hMapDir;
    }
    
    PrintToServer("[Economy Hybrid] Found %d demo folders", hDemoFolders.Length);
    
    int iBestRound = -1;
    char szBestDemo[PLATFORM_MAX_PATH];
    int iBestValue = bAllUnder3000 ? 999999 : 0;
    KnapsackResult bestResult;
    bestResult.isValid = false;
    
    int iValidRoundsChecked = 0;
    int iRoundsWithData = 0;
    
    for (int d = 0; d < hDemoFolders.Length; d++)
    {
        char szDemoFolder[PLATFORM_MAX_PATH];
        hDemoFolders.GetString(d, szDemoFolder, sizeof(szDemoFolder));
        
        PrintToServer("[Economy Hybrid] Checking demo folder: %s", szDemoFolder);
        
        // Load this demo's freeze times
        float fDemoFreezeTimes[31];
        bool bDemoFreezeValid[31];
        if (!LoadFreezeTimesForDemo(szMap, szDemoFolder, fDemoFreezeTimes, bDemoFreezeValid))
        {
            PrintToServer("[Economy Hybrid]   - No valid freeze times, skipping");
            continue;
        }
        
        // Load this demo's purchase data
        JSONObject jDemoPurchaseData = LoadPurchaseDataForDemo(szMap, szDemoFolder);
        if (jDemoPurchaseData == null)
        {
            PrintToServer("[Economy Hybrid]   - No purchase data, skipping");
            continue;
        }
        
        // Scan all rounds of this demo
        for (int iRound = 0; iRound <= 30; iRound++)
        {
            if (!bDemoFreezeValid[iRound])
                continue;
            
            iValidRoundsChecked++;
            
            // Pistol round match check
            bool bRoundIsPistol = IsPistolRound(iRound);
            if (bCurrentIsPistol != bRoundIsPistol)
                continue;
            
            char szRoundKey[32];
            Format(szRoundKey, sizeof(szRoundKey), "round%d", iRound + 1);
            
            if (!jDemoPurchaseData.HasKey(szRoundKey))
                continue;
            
            JSONObject jRound = view_as<JSONObject>(jDemoPurchaseData.Get(szRoundKey));
            if (!jRound.HasKey(szTeamName))
            {
                delete jRound;
                continue;
            }
            
            iRoundsWithData++;
            
            JSONObject jTeam = view_as<JSONObject>(jRound.Get(szTeamName));
            
            // Get REC file list for this round
            ArrayList hRecFiles = GetRecFilesForRound(szMap, szDemoFolder, iRound, szTeamName);
            if (hRecFiles.Length == 0)
            {
                PrintToServer("[Economy Hybrid]   - Round %d: No REC files found", iRound + 1);
                delete hRecFiles;
                delete jTeam;
                delete jRound;
                continue;
            }
            
            PrintToServer("[Economy Hybrid]   - Round %d: Found %d REC files", 
                iRound + 1, hRecFiles.Length);
            
            // Build REC equipment info cache
            ArrayList hRecInfoList = BuildRecEquipmentCache(hRecFiles, jTeam, iTeam);
            
            if (hRecInfoList.Length == 0)
            {
                PrintToServer("[Economy Hybrid]   - Round %d: No valid REC info", iRound + 1);
                delete hRecInfoList;
                delete hRecFiles;
                delete jTeam;
                delete jRound;
                continue;
            }
            
            // Run knapsack DP algorithm 
            KnapsackResult dpResult;
            dpResult = SolveKnapsackDP(hTeamBots, hRecInfoList, iTotalMoney);
            
            if (dpResult.isValid)
            {
                bool bIsBetter = false;
                
                if (bAllUnder3000)
                {
                    // Low economy: select smallest total value
                    if (dpResult.totalValue < iBestValue)
                        bIsBetter = true;
                }
                else
                {
                    // High economy: select largest total value
                    if (dpResult.totalValue > iBestValue)
                        bIsBetter = true;
                }
                
                if (bIsBetter)
                {
                    PrintToServer("[Economy Hybrid]   - Round %d: NEW BEST (value=%d, cost=$%d)",
                        iRound + 1, dpResult.totalValue, dpResult.totalCost);
                    
                    iBestRound = iRound;
                    strcopy(szBestDemo, sizeof(szBestDemo), szDemoFolder);
                    iBestValue = dpResult.totalValue;
                    bestResult = dpResult;
                }
            }
            else
            {
                PrintToServer("[Economy Hybrid]   - Round %d: DP result invalid", iRound + 1);
            }
            
            delete hRecInfoList;
            delete hRecFiles;
            delete jTeam;
            delete jRound;
        }
        
        delete jDemoPurchaseData;
    }
    
    PrintToServer("[Economy Hybrid] Team %s - Checked %d valid rounds, %d with data",
        szTeamName, iValidRoundsChecked, iRoundsWithData);
    
    if (iBestRound == -1)
    {
        PrintToServer("[Economy Hybrid] Team %s: NO affordable round found! (Checked %d demos)",
            szTeamName, hDemoFolders.Length);
        delete hDemoFolders;
        delete hTeamBots;
        return;
    }
    
    PrintToServer("[Economy Hybrid] Team %s: BEST ROUND = %d from demo '%s' (value=%d)",
        szTeamName, iBestRound + 1, szBestDemo, iBestValue);
    
    // Reload best round data and print details
    ArrayList hBestRecFiles = GetRecFilesForRound(szMap, szBestDemo, iBestRound, szTeamName);
    
    // Phase 2: Local search optimization
    JSONObject jBestPurchaseData = LoadPurchaseDataForDemo(szMap, szBestDemo);
    char szRoundKey[32];
    Format(szRoundKey, sizeof(szRoundKey), "round%d", iBestRound + 1);
    JSONObject jBestRound = view_as<JSONObject>(jBestPurchaseData.Get(szRoundKey));
    JSONObject jBestTeam = view_as<JSONObject>(jBestRound.Get(szTeamName));
    
    hBestRecFiles = GetRecFilesForRound(szMap, szBestDemo, iBestRound, szTeamName);
    ArrayList hBestRecInfoList = BuildRecEquipmentCache(hBestRecFiles, jBestTeam, iTeam);
    
    // Run local search optimization
    KnapsackResult optimizedResult;
    optimizedResult = LocalSearchOptimize(bestResult, hTeamBots, hBestRecInfoList, iTotalMoney);
    
    // Virtual weapon distribution simulation and final assignment
    // Save selected round and demo
    g_iSelectedRoundForTeam[iTeam] = iBestRound;
    strcopy(g_szSelectedDemoForTeam[iTeam], PLATFORM_MAX_PATH, szBestDemo);
    
    // Clean old assignment list
    if (g_hAssignedRecsForTeam[iTeam] != null)
        delete g_hAssignedRecsForTeam[iTeam];
    g_hAssignedRecsForTeam[iTeam] = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
    
    // Apply final assignment and simulate weapon distribution
    int iTotalCost = 0;
    for (int b = 0; b < iBotCount; b++)
    {
        int client = hTeamBots.Get(b);
        int recIndex = optimizedResult.assignment[b];
        
        if (recIndex >= 0 && recIndex < hBestRecInfoList.Length)
        {
            RecEquipmentInfo recInfo;
            hBestRecInfoList.GetArray(recIndex, recInfo, sizeof(RecEquipmentInfo));
            
            g_hAssignedRecsForTeam[iTeam].PushString(recInfo.recName);
            
            // Directly save to bot-specific variables
            strcopy(g_szAssignedRecName[client], PLATFORM_MAX_PATH, recInfo.recName);
            strcopy(g_szBotRecFolder[client], PLATFORM_MAX_PATH, szBestDemo);
            
            iTotalCost += recInfo.totalCost;
            
            char szBotName[MAX_NAME_LENGTH];
            GetClientName(client, szBotName, sizeof(szBotName));
            
            PrintToServer("[Economy Hybrid]   - Bot %d (%s): assigned '%s' (cost=$%d)",
                client, szBotName, recInfo.recName, recInfo.totalCost);
        }
    }
    
    PrintToServer("[Economy Hybrid] Team %s: Final total cost = $%d / $%d",
        szTeamName, iTotalCost, iTotalMoney);
    
    // Virtual drop system simulation
    SimulateDropSystem(hTeamBots, optimizedResult, hBestRecInfoList);
    
    // Clean resources
    delete hBestRecInfoList;
    delete hBestRecFiles;
    delete jBestTeam;
    delete jBestRound;
    delete jBestPurchaseData;
    delete hDemoFolders;
    delete hTeamBots;
}

int SelectRoundByBothTeamsEconomy()
{
    PrintToServer("[Economy Both] ===== Starting Both Teams Economy Selection =====");
    
    char szMap[64];
    GetCurrentMap(szMap, sizeof(szMap));
    GetMapDisplayName(szMap, szMap, sizeof(szMap));
    
    PrintToServer("[Economy Both] Current map: %s", szMap);
    
    // Collect all bots from both factions
    ArrayList hTBots = new ArrayList();
    ArrayList hCTBots = new ArrayList();
    
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsValidClient(i) || !IsFakeClient(i) || !IsPlayerAlive(i))
            continue;
        
        int iTeam = GetClientTeam(i);
        if (iTeam == CS_TEAM_T)
            hTBots.Push(i);
        else if (iTeam == CS_TEAM_CT)
            hCTBots.Push(i);
    }
    
    // Sort by economy
    SortADTArrayCustom(hTBots, Sort_BotsByMoney);
    SortADTArrayCustom(hCTBots, Sort_BotsByMoney);
    
    int iTBotCount = hTBots.Length;
    int iCTBotCount = hCTBots.Length;
    
    if (iTBotCount == 0 && iCTBotCount == 0)
    {
        PrintToServer("[Economy Both] ERROR: No bots found in either team!");
        delete hTBots;
        delete hCTBots;
        return g_iCurrentRound;
    }
    
    PrintToServer("[Economy Both] T bots: %d, CT bots: %d", iTBotCount, iCTBotCount);

    // Calculate team total economy
    int iTTotalMoney = 0;
    int iCTTotalMoney = 0;
    
    for (int i = 0; i < iTBotCount; i++)
    {
        int client = hTBots.Get(i);
        iTTotalMoney += GetEntProp(client, Prop_Send, "m_iAccount");
    }
    
    for (int i = 0; i < iCTBotCount; i++)
    {
        int client = hCTBots.Get(i);
        iCTTotalMoney += GetEntProp(client, Prop_Send, "m_iAccount");
    }
    
    // Check if all bots have economy less than 3000
    bool bAllUnder3000 = true;
    
    for (int i = 0; i < iTBotCount; i++)
    {
        int client = hTBots.Get(i);
        if (GetEntProp(client, Prop_Send, "m_iAccount") >= 3000)
        {
            bAllUnder3000 = false;
            break;
        }
    }
    
    if (bAllUnder3000)
    {
        for (int i = 0; i < iCTBotCount; i++)
        {
            int client = hCTBots.Get(i);
            if (GetEntProp(client, Prop_Send, "m_iAccount") >= 3000)
            {
                bAllUnder3000 = false;
                break;
            }
        }
    }
    
    // Check if current is pistol round
    bool bCurrentIsPistol = IsCurrentRoundPistol();
    
    // Get all demo folders
    char szMapBasePath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, szMapBasePath, sizeof(szMapBasePath), "data/botmimic/all/%s", szMap);
    
    ArrayList hDemoFolders = new ArrayList(PLATFORM_MAX_PATH);
    DirectoryListing hMapDir = OpenDirectory(szMapBasePath);
    if (hMapDir != null)
    {
        char szFolderName[PLATFORM_MAX_PATH];
        FileType iFileType;
        
        while (hMapDir.GetNext(szFolderName, sizeof(szFolderName), iFileType))
        {
            if (iFileType == FileType_Directory && strcmp(szFolderName, ".") != 0 && strcmp(szFolderName, "..") != 0)
            {
                hDemoFolders.PushString(szFolderName);
            }
        }
        delete hMapDir;
    }
    
    // Scan all rounds, use knapsack DP to find optimal round
    int iBestRound = -1;
    char szBestDemo[PLATFORM_MAX_PATH];
    int iBestTotalValue = bAllUnder3000 ? 999999 : 0;
    KnapsackResult bestTResult;
    KnapsackResult bestCTResult;
    bestTResult.isValid = false;
    bestCTResult.isValid = false;
    
    for (int d = 0; d < hDemoFolders.Length; d++)
    {
        char szDemoFolder[PLATFORM_MAX_PATH];
        hDemoFolders.GetString(d, szDemoFolder, sizeof(szDemoFolder));
        
        // Load this demo's freeze times
        float fDemoFreezeTimes[31];
        bool bDemoFreezeValid[31];
        LoadFreezeTimesForDemo(szMap, szDemoFolder, fDemoFreezeTimes, bDemoFreezeValid);
        
        // Load this demo's purchase data
        JSONObject jDemoPurchaseData = LoadPurchaseDataForDemo(szMap, szDemoFolder);
        if (jDemoPurchaseData == null)
            continue;
        
        // Scan all rounds of this demo
        for (int iRound = 0; iRound <= 30; iRound++)
        {
            if (!bDemoFreezeValid[iRound])
                continue;
            
            // Pistol round match check
            bool bRoundIsPistol = IsPistolRound(iRound);
            if (bCurrentIsPistol != bRoundIsPistol)
                continue;
            
            char szRoundKey[32];
            Format(szRoundKey, sizeof(szRoundKey), "round%d", iRound + 1);
            
            if (!jDemoPurchaseData.HasKey(szRoundKey))
                continue;
            
            JSONObject jRound = view_as<JSONObject>(jDemoPurchaseData.Get(szRoundKey));
            
            // Run knapsack DP for T team
            KnapsackResult tResult;
            tResult.isValid = false;
            
            if (iTBotCount > 0 && jRound.HasKey("T"))
            {
                JSONObject jTeamT = view_as<JSONObject>(jRound.Get("T"));
                
                ArrayList hTRecFiles = GetRecFilesForRound(szMap, szDemoFolder, iRound, "T");
                
                if (hTRecFiles.Length > 0)
                {
                    ArrayList hTRecInfoList = BuildRecEquipmentCache(hTRecFiles, jTeamT, CS_TEAM_T);
                    tResult = SolveKnapsackDP(hTBots, hTRecInfoList, iTTotalMoney);
                    delete hTRecInfoList;
                }
                
                delete hTRecFiles;
                delete jTeamT;
            }
            else if (iTBotCount > 0)
            {
                // T team has no data, treat as invalid
                tResult.isValid = false;
            }
            else
            {
                // No T bots, auto pass
                tResult.isValid = true;
                tResult.totalValue = 0;
            }
            
            // Run knapsack DP for CT team 
            KnapsackResult ctResult;
            ctResult.isValid = false;
            
            if (iCTBotCount > 0 && jRound.HasKey("CT"))
            {
                JSONObject jTeamCT = view_as<JSONObject>(jRound.Get("CT"));
                
                ArrayList hCTRecFiles = GetRecFilesForRound(szMap, szDemoFolder, iRound, "CT");
                
                if (hCTRecFiles.Length > 0)
                {
                    ArrayList hCTRecInfoList = BuildRecEquipmentCache(hCTRecFiles, jTeamCT, CS_TEAM_CT);
                    ctResult = SolveKnapsackDP(hCTBots, hCTRecInfoList, iCTTotalMoney);
                    delete hCTRecInfoList;
                }
                
                delete hCTRecFiles;
                delete jTeamCT;
            }
            else if (iCTBotCount > 0)
            {
                // CT team has no data, treat as invalid
                ctResult.isValid = false;
            }
            else
            {
                // No CT bots, auto pass
                ctResult.isValid = true;
                ctResult.totalValue = 0;
            }
            
            delete jRound;
            
            // If both have valid solutions
            if (tResult.isValid && ctResult.isValid)
            {
                int iTotalValue = tResult.totalValue + ctResult.totalValue;
                bool bIsBetter = false;
                
                if (bAllUnder3000)
                {
                    // Low economy: select smallest total value
                    if (iTotalValue < iBestTotalValue)
                        bIsBetter = true;
                }
                else
                {
                    // High economy: select largest total value
                    if (iTotalValue > iBestTotalValue)
                        bIsBetter = true;
                }
                
                if (bIsBetter)
                {
                    iBestRound = iRound;
                    strcopy(szBestDemo, sizeof(szBestDemo), szDemoFolder);
                    iBestTotalValue = iTotalValue;
                    bestTResult = tResult;
                    bestCTResult = ctResult;
                }
            }
        }
        
        delete jDemoPurchaseData;
    }
    
    delete hDemoFolders;
    
    if (iBestRound == -1)
    {
        PrintToServer("[Economy Both] No affordable round found!");
        delete hTBots;
        delete hCTBots;
        return g_iCurrentRound;
    }
    
    // Phase 2: Local search optimization 
    // Reload best round data
    JSONObject jBestPurchaseData = LoadPurchaseDataForDemo(szMap, szBestDemo);
    char szRoundKey[32];
    Format(szRoundKey, sizeof(szRoundKey), "round%d", iBestRound + 1);
    JSONObject jBestRound = view_as<JSONObject>(jBestPurchaseData.Get(szRoundKey));
    
    // Copy T team result
    KnapsackResult optimizedTResult;
    optimizedTResult.isValid = bestTResult.isValid;
    optimizedTResult.totalValue = bestTResult.totalValue;
    optimizedTResult.totalCost = bestTResult.totalCost;
    for (int i = 0; i <= MAXPLAYERS; i++)
        optimizedTResult.assignment[i] = bestTResult.assignment[i];

    // Copy CT team result
    KnapsackResult optimizedCTResult;
    optimizedCTResult.isValid = bestCTResult.isValid;
    optimizedCTResult.totalValue = bestCTResult.totalValue;
    optimizedCTResult.totalCost = bestCTResult.totalCost;
    for (int i = 0; i <= MAXPLAYERS; i++)
        optimizedCTResult.assignment[i] = bestCTResult.assignment[i];
    
    // Optimize for T team
    if (iTBotCount > 0 && jBestRound.HasKey("T"))
    {
        JSONObject jTeamT = view_as<JSONObject>(jBestRound.Get("T"));
        ArrayList hTRecFiles = GetRecFilesForRound(szMap, szBestDemo, iBestRound, "T");
        ArrayList hTRecInfoList = BuildRecEquipmentCache(hTRecFiles, jTeamT, CS_TEAM_T);
        
        optimizedTResult = LocalSearchOptimize(bestTResult, hTBots, hTRecInfoList, iTTotalMoney);
        
        delete hTRecInfoList;
        delete hTRecFiles;
        delete jTeamT;
    }
    
    // Optimize for CT team
    if (iCTBotCount > 0 && jBestRound.HasKey("CT"))
    {
        JSONObject jTeamCT = view_as<JSONObject>(jBestRound.Get("CT"));
        ArrayList hCTRecFiles = GetRecFilesForRound(szMap, szBestDemo, iBestRound, "CT");
        ArrayList hCTRecInfoList = BuildRecEquipmentCache(hCTRecFiles, jTeamCT, CS_TEAM_CT);
        
        optimizedCTResult = LocalSearchOptimize(bestCTResult, hCTBots, hCTRecInfoList, iCTTotalMoney);
        
        delete hCTRecInfoList;
        delete hCTRecFiles;
        delete jTeamCT;
    }
    
    // Phase 3: Apply final assignment 
    // Save selected demo and round
    strcopy(g_szCurrentRecFolder, sizeof(g_szCurrentRecFolder), szBestDemo);
    g_iSelectedRoundForTeam[CS_TEAM_T] = iBestRound;
    g_iSelectedRoundForTeam[CS_TEAM_CT] = iBestRound;
    strcopy(g_szSelectedDemoForTeam[CS_TEAM_T], PLATFORM_MAX_PATH, szBestDemo);
    strcopy(g_szSelectedDemoForTeam[CS_TEAM_CT], PLATFORM_MAX_PATH, szBestDemo);
    
    // Clean old assignment lists
    if (g_hAssignedRecsForTeam[CS_TEAM_T] != null)
        delete g_hAssignedRecsForTeam[CS_TEAM_T];
    if (g_hAssignedRecsForTeam[CS_TEAM_CT] != null)
        delete g_hAssignedRecsForTeam[CS_TEAM_CT];
    
    g_hAssignedRecsForTeam[CS_TEAM_T] = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
    g_hAssignedRecsForTeam[CS_TEAM_CT] = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
    
    // Apply assignment for T team
    if (iTBotCount > 0 && jBestRound.HasKey("T"))
    {
        JSONObject jTeamT = view_as<JSONObject>(jBestRound.Get("T"));
        ArrayList hTRecFiles = GetRecFilesForRound(szMap, szBestDemo, iBestRound, "T");
        ArrayList hTRecInfoList = BuildRecEquipmentCache(hTRecFiles, jTeamT, CS_TEAM_T);
        
        for (int b = 0; b < iTBotCount; b++)
        {
            int client = hTBots.Get(b);
            int recIndex = optimizedTResult.assignment[b];
            
            if (recIndex >= 0 && recIndex < hTRecInfoList.Length)
            {
                RecEquipmentInfo recInfo;
                hTRecInfoList.GetArray(recIndex, recInfo, sizeof(RecEquipmentInfo));
                
                g_hAssignedRecsForTeam[CS_TEAM_T].PushString(recInfo.recName);
                
                // Directly save to bot-specific variables
                strcopy(g_szAssignedRecName[client], PLATFORM_MAX_PATH, recInfo.recName);
                strcopy(g_szBotRecFolder[client], PLATFORM_MAX_PATH, szBestDemo);
                
                char szBotName[MAX_NAME_LENGTH];
                GetClientName(client, szBotName, sizeof(szBotName));
            }
        }
        
        // Virtual weapon distribution simulation
        SimulateDropSystem(hTBots, optimizedTResult, hTRecInfoList);
        
        delete hTRecInfoList;
        delete hTRecFiles;
        delete jTeamT;
    }
    
    // Apply assignment for CT team
    if (iCTBotCount > 0 && jBestRound.HasKey("CT"))
    {
        JSONObject jTeamCT = view_as<JSONObject>(jBestRound.Get("CT"));
        ArrayList hCTRecFiles = GetRecFilesForRound(szMap, szBestDemo, iBestRound, "CT");
        ArrayList hCTRecInfoList = BuildRecEquipmentCache(hCTRecFiles, jTeamCT, CS_TEAM_CT);
        
        for (int b = 0; b < iCTBotCount; b++)
        {
            int client = hCTBots.Get(b);
            int recIndex = optimizedCTResult.assignment[b];
            
            if (recIndex >= 0 && recIndex < hCTRecInfoList.Length)
            {
                RecEquipmentInfo recInfo;
                hCTRecInfoList.GetArray(recIndex, recInfo, sizeof(RecEquipmentInfo));
                
                g_hAssignedRecsForTeam[CS_TEAM_CT].PushString(recInfo.recName);
                
                // Directly save to bot-specific variables
                strcopy(g_szAssignedRecName[client], PLATFORM_MAX_PATH, recInfo.recName);
                strcopy(g_szBotRecFolder[client], PLATFORM_MAX_PATH, szBestDemo);
                
                char szBotName[MAX_NAME_LENGTH];
                GetClientName(client, szBotName, sizeof(szBotName));
            }
        }
        
        // Virtual weapon distribution simulation
        SimulateDropSystem(hCTBots, optimizedCTResult, hCTRecInfoList);
        
        delete hCTRecInfoList;
        delete hCTRecFiles;
        delete jTeamCT;
    }
    
    delete jBestRound;
    delete jBestPurchaseData;
    
    delete hTBots;
    delete hCTBots;
    
    return iBestRound;
}

// ============================================================================
// Stop REC Playback
// ============================================================================

void StopCTBotsRec_EconomyMode()
{
    int iStoppedCount = 0;
    
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsValidClient(i) || !IsFakeClient(i) || !IsPlayerAlive(i))
            continue;
        
        if (GetClientTeam(i) != CS_TEAM_CT)
            continue;
        
        if (g_bPlayingRoundStartRec[i] && BotMimic_IsPlayerMimicing(i))
        {
            BotMimic_StopPlayerMimic(i);
            g_bPlayingRoundStartRec[i] = false;
            iStoppedCount++;
            
            PrintToServer("[Bot REC] CT bot %d stopped REC after bomb plant", i);
        }
    }
    
    if (iStoppedCount > 0)
    {
        PrintToServer("[Bot REC] Stopped %d CT bots after bomb plant", iStoppedCount);
    }
}

void StopBotsRec_FullMatchMode()
{
    int iTCount = GetAliveTeamCount(CS_TEAM_T);
    int iCTCount = GetAliveTeamCount(CS_TEAM_CT);
    int iDifference = iTCount - iCTCount;
    
    PrintToServer("[Bot REC] Full Match Mode: T=%d, CT=%d, Diff=%d", 
        iTCount, iCTCount, iDifference);
    
    // If T has 2 or more players than CT, don't stop
    if (iDifference >= 2)
    {
        PrintToServer("[Bot REC] T has 2+ more players, keeping REC");
        return;
    }
    
    // Otherwise stop all CT bot RECs
    int iStoppedCount = 0;
    
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsValidClient(i) || !IsFakeClient(i) || !IsPlayerAlive(i))
            continue;
        
        if (GetClientTeam(i) != CS_TEAM_CT)
            continue;
        
        if (g_bPlayingRoundStartRec[i] && BotMimic_IsPlayerMimicing(i))
        {
            BotMimic_StopPlayerMimic(i);
            g_bPlayingRoundStartRec[i] = false;
            iStoppedCount++;
        }
    }
    
    if (iStoppedCount > 0)
    {
        PrintToServer("[Bot REC] Stopped %d CT bots", iStoppedCount);
    }
}

// ============================================================================
// Data Loading
// ============================================================================

bool LoadPurchaseDataFile(const char[] szRecFolder)
{
    char szMap[64];
    GetCurrentMap(szMap, sizeof(szMap));
    GetMapDisplayName(szMap, szMap, sizeof(szMap));
    
    char szPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, szPath, sizeof(szPath), 
        "data/botmimic/all/%s/%s/purchases.json", szMap, szRecFolder);
    
    if (!FileExists(szPath))
    {
        PrintToServer("[Bot REC] Purchase data file not found: %s", szPath);
        return false;
    }
    
    // Clean old data
    if (g_jPurchaseData != null)
        delete g_jPurchaseData;
    
    // Load JSON
    g_jPurchaseData = JSONObject.FromFile(szPath);
    if (g_jPurchaseData == null)
    {
        PrintToServer("[Bot REC] Failed to parse purchase data JSON");
        return false;
    }
    
    PrintToServer("[Bot REC] Loaded purchase data from: %s", szPath);
    return true;
}

bool LoadFreezeTimes(const char[] szMap, const char[] szRecFolder)
{
    char szFreezePath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, szFreezePath, sizeof(szFreezePath), 
        "data/botmimic/all/%s/%s/freeze.txt", szMap, szRecFolder);
    
    PrintToServer("[Freeze Loader] ===== LoadFreezeTimes CALLED =====");
    PrintToServer("[Freeze Loader] Map: %s", szMap);
    PrintToServer("[Freeze Loader] Folder: %s", szRecFolder);
    PrintToServer("[Freeze Loader] Path: %s", szFreezePath);
    
    // Initialize all rounds as invalid
    for (int i = 0; i < sizeof(g_bRoundFreezeTimeValid); i++)
    {
        // For economy system (with tolerance check)
        g_bRoundFreezeTimeValid[i] = false;
        g_fValidRoundFreezeTimes[i] = 0.0;
        
        // For pause system (no check)
        g_bAllRoundFreezeTimeValid[i] = false;
        g_fAllRoundFreezeTimes[i] = 0.0;
    }
    
    g_fStandardFreezeTime = 20.0;
    
    if (!FileExists(szFreezePath))
    {
        PrintToServer("[Freeze Loader] ✗ File not found: %s", szFreezePath);
        return false;
    }
    
    File hFile = OpenFile(szFreezePath, "r");
    if (hFile == null)
    {
        PrintToServer("[Freeze Loader] ✗ Failed to open file");
        return false;
    }
    
    char szLine[128];
    int iValidRoundsForEconomy = 0;
    int iValidRoundsForPause = 0;
    const float TOLERANCE = 2.0;
    int iLineNumber = 0;
    
    PrintToServer("[Freeze Loader] Parsing file...");
    
    // First scan to find standard freeze time
    while (hFile.ReadLine(szLine, sizeof(szLine)))
    {
        TrimString(szLine);
        
        if (StrContains(szLine, "Freeze time", false) != -1 || 
            StrContains(szLine, "standard", false) != -1 ||
            StrContains(szLine, "freeze", false) != -1)
        {
            char szParts[2][64];
            int iParts = ExplodeString(szLine, ":", szParts, sizeof(szParts), sizeof(szParts[]));
            
            if (iParts >= 2)
            {
                TrimString(szParts[1]);
                ReplaceString(szParts[1], sizeof(szParts[]), "seconds", "");
                ReplaceString(szParts[1], sizeof(szParts[]), "s", "", false);
                g_fStandardFreezeTime = StringToFloat(szParts[1]);
                
                PrintToServer("[Freeze Loader] Found standard freeze time = %.2f", g_fStandardFreezeTime);
            }
            break;
        }
    }
    
    // Reset file pointer to beginning
    delete hFile;
    hFile = OpenFile(szFreezePath, "r");
    if (hFile == null)
    {
        PrintToServer("[Freeze Loader] ✗ Failed to reopen file");
        return false;
    }
    
    // Second scan: parse round data
    iLineNumber = 0;
    while (hFile.ReadLine(szLine, sizeof(szLine)))
    {
        iLineNumber++;
        TrimString(szLine);
        
        // Skip empty lines and comments
        if (strlen(szLine) == 0 || szLine[0] == '/' || szLine[0] == '#')
        {
            PrintToServer("[Freeze Loader] Line %d: Skipped (empty/comment)", iLineNumber);
            continue;
        }
        
        // Skip standard time definition line
        if (StrContains(szLine, "Freeze time", false) != -1 || 
            StrContains(szLine, "standard", false) != -1 ||
            StrContains(szLine, "freeze", false) != -1)
        {
            PrintToServer("[Freeze Loader] Line %d: Skipped (standard time definition)", iLineNumber);
            continue;
        }
        
        // Parse round time: "round1: 20.5" or "1: 20.5"
        char szParts[2][64];
        int iParts = ExplodeString(szLine, ":", szParts, sizeof(szParts), sizeof(szParts[]));
        
        if (iParts < 2)
        {
            PrintToServer("[Freeze Loader] Line %d: Invalid format (no colon): %s", 
                iLineNumber, szLine);
            continue;
        }
        
        TrimString(szParts[0]);
        int iRoundNum = -1;
        
        // Parse round number
        if (StrContains(szParts[0], "round", false) != -1)
        {
            ReplaceString(szParts[0], sizeof(szParts[]), "round", "", false);
            ReplaceString(szParts[0], sizeof(szParts[]), "Round", "", false);
            ReplaceString(szParts[0], sizeof(szParts[]), "ROUND", "", false);
            TrimString(szParts[0]);
            iRoundNum = StringToInt(szParts[0]);
        }
        else
        {
            iRoundNum = StringToInt(szParts[0]);
        }
        
        if (iRoundNum < 1 || iRoundNum > 30)
        {
            PrintToServer("[Freeze Loader] Line %d: Invalid round number: %d (must be 1-30)", 
                iLineNumber, iRoundNum);
            continue;
        }
        
        // Parse freeze time
        TrimString(szParts[1]);
        ReplaceString(szParts[1], sizeof(szParts[]), "seconds", "");
        ReplaceString(szParts[1], sizeof(szParts[]), "s", "", false);
        float fFreezeTime = StringToFloat(szParts[1]);
        
        if (fFreezeTime <= 0.0)
        {
            PrintToServer("[Freeze Loader] Line %d: Invalid freeze time: %.2f", 
                iLineNumber, fFreezeTime);
            continue;
        }
        
        // Array index = round number - 1
        int iArrayIndex = iRoundNum - 1;
        
        // Handle both systems separately 
        
        // 1. Pause system: unconditionally load all times
        g_bAllRoundFreezeTimeValid[iArrayIndex] = true;
        g_fAllRoundFreezeTimes[iArrayIndex] = fFreezeTime;
        iValidRoundsForPause++;
        
        PrintToServer("[Freeze Loader] Line %d: [PAUSE] Round %d (index %d) = %.2f seconds", 
            iLineNumber, iRoundNum, iArrayIndex, fFreezeTime);
        
        // 2. Economy system: only load times within tolerance
        float fDifference = FloatAbs(fFreezeTime - g_fStandardFreezeTime);
        
        if (fDifference <= TOLERANCE)
        {
            g_bRoundFreezeTimeValid[iArrayIndex] = true;
            g_fValidRoundFreezeTimes[iArrayIndex] = fFreezeTime;
            iValidRoundsForEconomy++;
            
            PrintToServer("[Freeze Loader] Line %d: [ECONOMY] ✓ Round %d (index %d) = %.2f seconds (diff: %.2f)", 
                iLineNumber, iRoundNum, iArrayIndex, fFreezeTime, fDifference);
        }
        else
        {
            PrintToServer("[Freeze Loader] Line %d: [ECONOMY] ✗ Round %d rejected (freeze: %.2f, standard: %.2f, diff: %.2f > tolerance: %.2f)", 
                iLineNumber, iRoundNum, fFreezeTime, g_fStandardFreezeTime, fDifference, TOLERANCE);
        }
    }
    
    delete hFile;
    
    PrintToServer("[Freeze Loader] ===== PARSING COMPLETE =====");
    PrintToServer("[Freeze Loader] Total lines: %d", iLineNumber);
    PrintToServer("[Freeze Loader] Valid rounds for PAUSE system: %d", iValidRoundsForPause);
    PrintToServer("[Freeze Loader] Valid rounds for ECONOMY system: %d", iValidRoundsForEconomy);
    PrintToServer("[Freeze Loader] Standard freeze time: %.2f seconds", g_fStandardFreezeTime);
    
    // Print pause system summary
    if (iValidRoundsForPause > 0)
    {
        PrintToServer("[Freeze Loader] Pause system rounds:");
        for (int i = 0; i < 31; i++)
        {
            if (g_bAllRoundFreezeTimeValid[i])
            {
                PrintToServer("[Freeze Loader]   - Index %d (round%d): %.2f seconds", 
                    i, i + 1, g_fAllRoundFreezeTimes[i]);
            }
        }
    }
    
    // Print economy system summary
    if (iValidRoundsForEconomy > 0)
    {
        PrintToServer("[Freeze Loader] Economy system rounds:");
        for (int i = 0; i < 31; i++)
        {
            if (g_bRoundFreezeTimeValid[i])
            {
                PrintToServer("[Freeze Loader]   - Index %d (round%d): %.2f seconds", 
                    i, i + 1, g_fValidRoundFreezeTimes[i]);
            }
        }
    }
    
    return (iValidRoundsForPause > 0 || iValidRoundsForEconomy > 0);
}

// ============================================================================
// Purchase System
// ============================================================================

// Intercept bot purchase commands
public Action CS_OnBuyCommand(int client, const char[] szWeapon)
{
    if (!IsValidClient(client) || !IsFakeClient(client))
        return Plugin_Continue;
    
    // 1. If plugin-initiated purchase (via DelayedBuy), allow through
    if (g_bAllowPurchase[client])
    {
        g_bAllowPurchase[client] = false;
        return Plugin_Continue;
    }
    
    // 2. If playing rec, intercept all purchases
    if (g_bPlayingRoundStartRec[client])
    {
        return Plugin_Handled;
    }
    
    // 3. Other cases allow through (let bot_stuff handle)
    return Plugin_Continue;
}

// Load purchase actions
bool LoadPurchaseActionsForBot(int client, int iRound)
{
    // Load bot-specific demo purchase data
    char szMap[64];
    GetCurrentMap(szMap, sizeof(szMap));
    GetMapDisplayName(szMap, szMap, sizeof(szMap));
    
    JSONObject jUsePurchaseData = null;
    
    // If bot has specific demo, load specific demo purchase data
    if (g_szBotRecFolder[client][0] != '\0')
    {
        jUsePurchaseData = LoadPurchaseDataForDemo(szMap, g_szBotRecFolder[client]);
        if (jUsePurchaseData == null)
        {
            PrintToServer("[Bot Purchase] Failed to load purchase data for bot %d demo: %s", 
                client, g_szBotRecFolder[client]);
        }
    }
    
    // If no specific data, use global data
    if (jUsePurchaseData == null)
    {
        jUsePurchaseData = g_jPurchaseData;
    }
    
    if (jUsePurchaseData == null)
    {
        PrintToServer("[Bot Purchase] ERROR: No purchase data for client %d", client);
        return false;
    }
    
    // Get team information
    int iTeam = GetClientTeam(client);
    char szTeamName[4];
    
    if (iTeam == CS_TEAM_T)
        strcopy(szTeamName, sizeof(szTeamName), "T");
    else if (iTeam == CS_TEAM_CT)
        strcopy(szTeamName, sizeof(szTeamName), "CT");
    else
        return false;
    
    // Get bot name
    char szBotName[MAX_NAME_LENGTH];
    GetClientName(client, szBotName, sizeof(szBotName));
    
    // Build round key
    char szRoundKey[32];
    Format(szRoundKey, sizeof(szRoundKey), "round%d", iRound + 1);
    
    // Use correct data source
    if (!jUsePurchaseData.HasKey(szRoundKey))
    {
        PrintToServer("[Bot Purchase] ERROR: No purchase data for %s", szRoundKey);
        
        // Clean temporary data
        if (jUsePurchaseData != g_jPurchaseData && jUsePurchaseData != null)
            delete jUsePurchaseData;
        
        return false;
    }
    
    JSONObject jRound = view_as<JSONObject>(jUsePurchaseData.Get(szRoundKey));
    if (!jRound.HasKey(szTeamName))
    {
        PrintToServer("[Bot Purchase] ERROR: Round %s has no data for team %s", 
            szRoundKey, szTeamName);
        delete jRound;
        
        // Clean temporary data
        if (jUsePurchaseData != g_jPurchaseData && jUsePurchaseData != null)
            delete jUsePurchaseData;
        
        return false;
    }
    
    JSONObject jTeam = view_as<JSONObject>(jRound.Get(szTeamName));
    
    // Use rec file name instead of index
    if (g_szCurrentRecName[client][0] == '\0')
    {
        PrintToServer("[Bot Purchase] ERROR: Client %d has no rec name assigned", client);
        delete jTeam;
        delete jRound;
        
        // Clean temporary data
        if (jUsePurchaseData != g_jPurchaseData && jUsePurchaseData != null)
            delete jUsePurchaseData;
        
        return false;
    }
    
    if (!jTeam.HasKey(g_szCurrentRecName[client]))
    {
        PrintToServer("[Bot Purchase] ERROR: Team %s has no data for rec name '%s'", 
            szTeamName, g_szCurrentRecName[client]);
        delete jTeam;
        delete jRound;
        
        // Clean temporary data
        if (jUsePurchaseData != g_jPurchaseData && jUsePurchaseData != null)
            delete jUsePurchaseData;
        
        return false;
    }
    
    JSONObject jBotData = view_as<JSONObject>(jTeam.Get(g_szCurrentRecName[client]));
    
    // Clean old data
    if (g_hPurchaseActions[client] != null)
        delete g_hPurchaseActions[client];
    if (g_hFinalInventory[client] != null)
        delete g_hFinalInventory[client];
    
    g_hPurchaseActions[client] = new ArrayList(ByteCountToCells(128));
    g_hFinalInventory[client] = new ArrayList(ByteCountToCells(64));
    g_iPurchaseActionIndex[client] = 0;

    // Initialize drop data
    if (g_hDropActions[client] != null)
        delete g_hDropActions[client];
    g_hDropActions[client] = new ArrayList(ByteCountToCells(128));
    g_iDropActionIndex[client] = 0;
    
    int iPurchaseCount = 0;
    int iDropCount = 0;
    
    // Load purchase actions and drop actions
    if (jBotData.HasKey("purchases"))
    {
        JSONArray jPurchases = view_as<JSONArray>(jBotData.Get("purchases"));
        
        PrintToServer("[Bot Purchase] Found %d purchase actions for client %d", 
            jPurchases.Length, client);
        
        for (int i = 0; i < jPurchases.Length; i++)
        {
            JSONObject jAction = view_as<JSONObject>(jPurchases.Get(i));
    
            // Get action type
            char szAction[32];
            jAction.GetString("action", szAction, sizeof(szAction));
            
            // Handle purchase action
            if (StrEqual(szAction, "purchased", false))
            {
                float fTime = jAction.GetFloat("time");
                char szItem[64], szSlot[32];
                jAction.GetString("item", szItem, sizeof(szItem));
                jAction.GetString("slot", szSlot, sizeof(szSlot));
                
                char szActionStr[128];
                Format(szActionStr, sizeof(szActionStr), "%.1f|%s|%s", fTime, szItem, szSlot);
                g_hPurchaseActions[client].PushString(szActionStr);
                
                iPurchaseCount++;
            }
            // Handle drop action
            else if (StrEqual(szAction, "dropped", false))
            {
                float fTime = jAction.GetFloat("time");
                char szItem[64], szSlot[32];
                jAction.GetString("item", szItem, sizeof(szItem));
                jAction.GetString("slot", szSlot, sizeof(szSlot));
                
                char szDropStr[128];
                Format(szDropStr, sizeof(szDropStr), "%.1f|%s|%s", fTime, szItem, szSlot);
                g_hDropActions[client].PushString(szDropStr);
                
                iDropCount++;
            }
    
            delete jAction;
        }
        
        delete jPurchases;
    }
    
    // Load final equipment inventory
    int iInventoryCount = 0;
    if (jBotData.HasKey("final_inventory"))
    {
        JSONArray jInventory = view_as<JSONArray>(jBotData.Get("final_inventory"));
        
        for (int i = 0; i < jInventory.Length; i++)
        {
            char szItem[64];
            jInventory.GetString(i, szItem, sizeof(szItem));
            g_hFinalInventory[client].PushString(szItem);
            
            PrintToServer("[Bot Purchase]   Inventory %d: %s", i, szItem);
            iInventoryCount++;
        }
        
        delete jInventory;
    }
    
    delete jBotData;
    delete jTeam;
    delete jRound;
    
    // Set equipment verification timer
    ConVar cvFreezeTime = FindConVar("mp_freezetime");
    if (cvFreezeTime != null)
    {
        float fFreezeTime = cvFreezeTime.FloatValue;
        
        if (fFreezeTime > 3.0 && g_hFinalInventory[client].Length > 0)
        {
            float fVerifyDelay = fFreezeTime - GetRandomFloat(2.5, 3.0);
            DataPack pack = new DataPack();
            pack.WriteCell(GetClientUserId(client));
            g_hVerifyTimer[client] = CreateTimer(fVerifyDelay, Timer_VerifyInventory, pack);
        }
        else
        {
            PrintToServer("[Bot Purchase] ✗ NOT setting verify timer: freezetime=%.1f, inventory_count=%d", 
                fFreezeTime, g_hFinalInventory[client] != null ? g_hFinalInventory[client].Length : 0);
        }
    }
    else
    {
        PrintToServer("[Bot Purchase] ✗ ERROR: mp_freezetime cvar not found!");
    }
    
    // If using temporarily loaded data, need to delete
    if (jUsePurchaseData != g_jPurchaseData && jUsePurchaseData != null)
    {
        delete jUsePurchaseData;
    }
    
    // If has drop actions and feature enabled, start drop timer
    if (iDropCount > 0 && g_cvEnableDrops.BoolValue) 
    {
        DataPack pack = new DataPack();
        pack.WriteCell(GetClientUserId(client));
        g_hDropTimer[client] = CreateTimer(0.1, Timer_ExecuteDropAction, pack, 
            TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    
        PrintToServer("[Bot Drop] Bot %d drop timer started with %d actions", client, iDropCount);
    }
    
    return (iPurchaseCount > 0 || iDropCount > 0 || iInventoryCount > 0);
}

// Purchase action execution timer
public Action Timer_ExecutePurchaseAction(Handle hTimer, DataPack pack)
{
    pack.Reset();
    int iUserId = pack.ReadCell();
    
    int client = GetClientOfUserId(iUserId);
    if (!IsValidClient(client))
    {
        g_hPurchaseTimer[client] = null;  
        delete pack;
        return Plugin_Stop;
    }
    
    if (!g_bPlayingRoundStartRec[client])
    {
        g_hPurchaseTimer[client] = null;  
        delete pack;
        return Plugin_Stop;
    }
    
    if (g_hPurchaseActions[client] == null)
    {
        g_hPurchaseTimer[client] = null;  
        delete pack;
        return Plugin_Stop;
    }
    
    bool bInBuyZone = !!GetEntProp(client, Prop_Send, "m_bInBuyZone");
    float fCurrentTime = GetGameTime() - g_fRecStartTime[client];
    int iTeam = GetClientTeam(client);
    
    // Debug log
    static int iDebugCount[MAXPLAYERS+1];
    iDebugCount[client]++;
    if (iDebugCount[client] <= 3)  // Only print first 3 times
    {
        PrintToServer("[Bot Purchase DEBUG] Client %d: InBuyZone=%d, CurrentTime=%.2f, RecStartTime=%.2f, ActionsCount=%d, CurrentIndex=%d", 
            client, bInBuyZone, fCurrentTime, g_fRecStartTime[client], 
            g_hPurchaseActions[client].Length, g_iPurchaseActionIndex[client]);
    }
    
    if (!bInBuyZone)
        return Plugin_Continue;
    
    while (g_iPurchaseActionIndex[client] < g_hPurchaseActions[client].Length)
    {
        char szAction[128];
        g_hPurchaseActions[client].GetString(g_iPurchaseActionIndex[client], szAction, sizeof(szAction));
        
        char szParts[3][64];
        int iParts = ExplodeString(szAction, "|", szParts, sizeof(szParts), sizeof(szParts[]));
        
        if (iParts < 3)
        {
            g_iPurchaseActionIndex[client]++;
            continue;
        }
        
        float fActionTime = StringToFloat(szParts[0]);
        
        if (fCurrentTime < fActionTime)
            break;
        
        char szOriginalItem[64], szSlot[32];
        strcopy(szOriginalItem, sizeof(szOriginalItem), szParts[1]);
        strcopy(szSlot, sizeof(szSlot), szParts[2]);
        
        // Check if should skip this purchase
        if (ShouldSkipPurchase(client, szOriginalItem))
        {
            PrintToServer("[Bot Purchase] Client %d skipping purchase: %s", client, szOriginalItem);
            g_iPurchaseActionIndex[client]++;
            continue;
        }
        
        // Convert opposite faction weapons
        char szBuyItem[64];
        bool bNeedConvert = GetTeamSpecificWeapon(szOriginalItem, iTeam, szBuyItem, sizeof(szBuyItem));
        
        if (bNeedConvert)
        {
            PrintToServer("[Bot Purchase] Client %d converting '%s' to '%s'", 
                client, szOriginalItem, szBuyItem);
        }
        else
        {
            strcopy(szBuyItem, sizeof(szBuyItem), szOriginalItem);
        }
        
        // Execute purchase
        g_bAllowPurchase[client] = true;
        
        PrintToServer("[Bot Purchase] Client %d buying: %s (converted from: %s) at time %.2f", 
            client, szBuyItem, szOriginalItem, fCurrentTime);
        
        FakeClientCommand(client, "buy %s", szBuyItem);
        
        CreateTimer(0.05, Timer_ResetPurchaseFlag, GetClientUserId(client));
        
        g_iPurchaseActionIndex[client]++;
        
        // Only execute one purchase action per timer trigger, then wait for next trigger
        break;
    }
    
    if (g_iPurchaseActionIndex[client] >= g_hPurchaseActions[client].Length)
    {
        g_hPurchaseTimer[client] = null; 
        delete pack;
        return Plugin_Stop;
    }
    
    return Plugin_Continue;
}

public Action Timer_ResetPurchaseFlag(Handle hTimer, any iUserId)
{
    int client = GetClientOfUserId(iUserId);
    if (IsValidClient(client))
        g_bAllowPurchase[client] = false;
    
    return Plugin_Stop;
}

// Drop action execution timer
public Action Timer_ExecuteDropAction(Handle hTimer, DataPack pack)
{
    pack.Reset();
    int iUserId = pack.ReadCell();
    
    int client = GetClientOfUserId(iUserId);
    if (!IsValidClient(client))
    {
        g_hDropTimer[client] = null;  
        delete pack;
        return Plugin_Stop;
    }
    
    if (!g_bPlayingRoundStartRec[client])
    {
        g_hDropTimer[client] = null;  
        delete pack;
        return Plugin_Stop;
    }
    
    if (g_hDropActions[client] == null)
    {
        g_hDropTimer[client] = null;  
        delete pack;
        return Plugin_Stop;
    }
    
    if (!IsPlayerAlive(client))
        return Plugin_Continue;
    
    float fCurrentTime = GetGameTime() - g_fRecStartTime[client];
    
    while (g_iDropActionIndex[client] < g_hDropActions[client].Length)
    {
        char szAction[128];
        g_hDropActions[client].GetString(g_iDropActionIndex[client], szAction, sizeof(szAction));
        
        char szParts[3][64];
        int iParts = ExplodeString(szAction, "|", szParts, sizeof(szParts), sizeof(szParts[]));
        
        if (iParts < 3)
        {
            g_iDropActionIndex[client]++;
            continue;
        }
        
        float fActionTime = StringToFloat(szParts[0]);
        
        if (fCurrentTime < fActionTime)
            break;
        
        char szItem[64];
        strcopy(szItem, sizeof(szItem), szParts[1]);
        
        // Find and drop item
        ExecuteDropAction(client, szItem);
        
        g_iDropActionIndex[client]++;
    }
    
    if (g_iDropActionIndex[client] >= g_hDropActions[client].Length)
    {
        g_hDropTimer[client] = null;  
        delete pack;
        return Plugin_Stop;
    }
    
    return Plugin_Continue;
}

// ============================================================================
// Bomb Carrier Detection and Weapon Pickup System
// ============================================================================

// Check if bomb carrying T is playing REC
public Action Timer_CheckBombCarrier(Handle hTimer)
{
    g_hBombCarrierCheckTimer = null;
    
    // Find bomb carrying T
    int iBombCarrier = -1;
    
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsValidClient(i) || !IsPlayerAlive(i))
            continue;
        
        if (GetClientTeam(i) != CS_TEAM_T)
            continue;
        
        // Check if carrying C4
        int iC4 = GetPlayerWeaponSlot(i, CS_SLOT_C4);
        if (IsValidEntity(iC4))
        {
            char szClass[64];
            GetEntityClassname(iC4, szClass, sizeof(szClass));
            
            if (StrEqual(szClass, "weapon_c4", false))
            {
                iBombCarrier = i;
                break;
            }
        }
    }
    
    if (iBombCarrier == -1)
    {
        PrintToServer("[Bot REC] No bomb carrier found at 90s check");
        return Plugin_Stop;
    }
    
    // If bomb carrying T is playing REC, stop it
    if (g_bPlayingRoundStartRec[iBombCarrier] && BotMimic_IsPlayerMimicing(iBombCarrier))
    {
        char szName[MAX_NAME_LENGTH];
        GetClientName(iBombCarrier, szName, sizeof(szName));
        
        BotMimic_StopPlayerMimic(iBombCarrier);
        g_bPlayingRoundStartRec[iBombCarrier] = false;
        
        PrintToServer("[Bot REC] Stopped bomb carrier (client %d: %s) REC at 90 seconds", 
            iBombCarrier, szName);
    }
    else
    {
        PrintToServer("[Bot REC] Bomb carrier (client %d) is not playing REC", iBombCarrier);
    }
    
    return Plugin_Stop;
}

// Execute drop operation
void ExecuteDropAction(int client, const char[] szItem)
{
    // Find item slot
    int iWeaponEntity = -1;
    char szWeaponClass[64];
    Format(szWeaponClass, sizeof(szWeaponClass), "weapon_%s", szItem);
    
    // Check all slots
    for (int slot = 0; slot <= 4; slot++)
    {
        int iWeapon = GetPlayerWeaponSlot(client, slot);
        if (IsValidEntity(iWeapon))
        {
            char szClass[64];
            GetEntityClassname(iWeapon, szClass, sizeof(szClass));
            
            if (StrEqual(szClass, szWeaponClass, false))
            {
                iWeaponEntity = iWeapon;
                break;
            }
        }
    }
    
    if (iWeaponEntity == -1)
    {
        return;
    }
    
    // Execute drop
    SDKHooks_DropWeapon(client, iWeaponEntity);
}

// Verify equipment integrity
public Action Timer_VerifyInventory(Handle hTimer, DataPack pack)
{
    pack.Reset();
    int iUserId = pack.ReadCell();
    delete pack;
    
    int client = GetClientOfUserId(iUserId);
    
    // First clear timer handle to avoid duplicate Kill
    g_hVerifyTimer[client] = null;
    
    if (!IsValidClient(client))
    {
        return Plugin_Stop;
    }
    
    if (g_bInventoryVerified[client])
    {
        return Plugin_Stop;
    }
    
    if (g_hFinalInventory[client] == null)
    {
        return Plugin_Stop;
    }
    
    int iTeam = GetClientTeam(client);
    
    // Collect current equipment
    ArrayList hCurrentInventory = new ArrayList(ByteCountToCells(64));
    CollectCurrentInventory(client, hCurrentInventory);
    
    // Verify other equipment
    int iMissingCount = 0;
    for (int i = 0; i < g_hFinalInventory[client].Length; i++)
    {
        char szRequiredItem[64];
        g_hFinalInventory[client].GetString(i, szRequiredItem, sizeof(szRequiredItem));
        
        // Ignore default pistols
        if (IsDefaultPistol(szRequiredItem))
            continue;
        
        // Check if should skip
        if (ShouldSkipPurchase(client, szRequiredItem))
            continue;
        
        bool bHasItem = IsItemInInventory(hCurrentInventory, szRequiredItem);
        
        if (!bHasItem)
        {
            // Convert opposite faction weapons
            char szBuyItem[64];
            GetTeamSpecificWeapon(szRequiredItem, iTeam, szBuyItem, sizeof(szBuyItem));
            
            // Try to purchase, if fail then downgrade
            BuyItemWithFallback(client, szBuyItem, 0.1 + (iMissingCount * 0.2));
            iMissingCount++;
        }
    }
    
    delete hCurrentInventory;
    
    g_bInventoryVerified[client] = true;
    
    return Plugin_Stop;
}

// Purchase function with fallback mechanism
void BuyItemWithFallback(int client, const char[] szItem, float fDelay)
{
    if (IsDefaultPistol(szItem))
        return;
    
    DataPack pack = new DataPack();
    pack.WriteCell(GetClientUserId(client));
    pack.WriteString(szItem);
    
    CreateTimer(fDelay, Timer_BuyItemWithFallback, pack);
}

public Action Timer_BuyItemWithFallback(Handle hTimer, DataPack pack)
{
    pack.Reset();
    int iUserId = pack.ReadCell();
    
    char szItem[64];
    pack.ReadString(szItem, sizeof(szItem));
    delete pack;
    
    int client = GetClientOfUserId(iUserId);
    
    if (!IsValidClient(client) || !IsPlayerAlive(client))
        return Plugin_Stop;
    
    bool bInBuyZone = !!GetEntProp(client, Prop_Send, "m_bInBuyZone");
    
    if (!bInBuyZone)
        return Plugin_Stop;
    
    int iMoney = GetEntProp(client, Prop_Send, "m_iAccount");
    int iPrice = GetItemPrice(szItem);
    
    // If can afford, buy directly
    if (iMoney >= iPrice)
    {
        g_bAllowPurchase[client] = true;
        FakeClientCommand(client, "buy %s", szItem);
        CreateTimer(0.05, Timer_ResetPurchaseFlag, GetClientUserId(client));
        
        return Plugin_Stop;
    }
    
    // Can't afford, try downgrade
    char szFallback[64];
    if (GetFallbackWeapon(szItem, iMoney, szFallback, sizeof(szFallback)))
    {
        g_bAllowPurchase[client] = true;
        FakeClientCommand(client, "buy %s", szFallback);
        CreateTimer(0.05, Timer_ResetPurchaseFlag, GetClientUserId(client));
        
        PrintToServer("[Bot Purchase] Client %d downgraded: %s -> %s ($%d)", 
            client, szItem, szFallback, GetItemPrice(szFallback));
    }
    else
    {
        PrintToServer("[Bot Purchase] Client %d cannot afford %s ($%d) and no fallback available", 
            client, szItem, iPrice);
    }
    
    return Plugin_Stop;
}

// Get downgrade weapon
bool GetFallbackWeapon(const char[] szItem, int iMoney, char[] szFallback, int iMaxLen)
{
    // Sniper downgrade chain: AWP -> SSG08
    if (StrEqual(szItem, "awp", false))
    {
        if (iMoney >= 1700) { strcopy(szFallback, iMaxLen, "ssg08"); return true; }
    }
    else if (StrEqual(szItem, "scar20", false))
    {
        if (iMoney >= 4750) { strcopy(szFallback, iMaxLen, "awp"); return true; }
        if (iMoney >= 1700) { strcopy(szFallback, iMaxLen, "ssg08"); return true; }
    }
    else if (StrEqual(szItem, "g3sg1", false))
    {
        if (iMoney >= 4750) { strcopy(szFallback, iMaxLen, "awp"); return true; }
        if (iMoney >= 1700) { strcopy(szFallback, iMaxLen, "ssg08"); return true; }
    }
    
    // Rifle downgrade chain: AK47/M4 -> FAMAS/Galil -> SMG
    if (StrEqual(szItem, "ak47", false))
    {
        if (iMoney >= 2000) { strcopy(szFallback, iMaxLen, "galilar"); return true; }
        if (iMoney >= 1200) { strcopy(szFallback, iMaxLen, "ump45"); return true; }
        if (iMoney >= 1050) { strcopy(szFallback, iMaxLen, "mac10"); return true; }
    }
    else if (StrEqual(szItem, "m4a1", false) || StrEqual(szItem, "m4a1_silencer", false))
    {
        if (iMoney >= 2250) { strcopy(szFallback, iMaxLen, "famas"); return true; }
        if (iMoney >= 1200) { strcopy(szFallback, iMaxLen, "ump45"); return true; }
        if (iMoney >= 1250) { strcopy(szFallback, iMaxLen, "mp9"); return true; }
    }
    else if (StrEqual(szItem, "aug", false))
    {
        if (iMoney >= 3100) { strcopy(szFallback, iMaxLen, "m4a1"); return true; }
        if (iMoney >= 2250) { strcopy(szFallback, iMaxLen, "famas"); return true; }
        if (iMoney >= 1200) { strcopy(szFallback, iMaxLen, "ump45"); return true; }
    }
    else if (StrEqual(szItem, "sg556", false))
    {
        if (iMoney >= 2700) { strcopy(szFallback, iMaxLen, "ak47"); return true; }
        if (iMoney >= 2000) { strcopy(szFallback, iMaxLen, "galilar"); return true; }
        if (iMoney >= 1200) { strcopy(szFallback, iMaxLen, "ump45"); return true; }
    }
    else if (StrEqual(szItem, "famas", false))
    {
        if (iMoney >= 1200) { strcopy(szFallback, iMaxLen, "ump45"); return true; }
        if (iMoney >= 1250) { strcopy(szFallback, iMaxLen, "mp9"); return true; }
    }
    else if (StrEqual(szItem, "galilar", false))
    {
        if (iMoney >= 1200) { strcopy(szFallback, iMaxLen, "ump45"); return true; }
        if (iMoney >= 1050) { strcopy(szFallback, iMaxLen, "mac10"); return true; }
    }
    
    // SMG downgrade chain
    if (StrEqual(szItem, "p90", false))
    {
        if (iMoney >= 1500) { strcopy(szFallback, iMaxLen, "mp7"); return true; }
        if (iMoney >= 1200) { strcopy(szFallback, iMaxLen, "ump45"); return true; }
    }
    else if (StrEqual(szItem, "mp7", false))
    {
        if (iMoney >= 1200) { strcopy(szFallback, iMaxLen, "ump45"); return true; }
    }
    
    // Armor downgrade: vesthelm -> vest
    if (StrEqual(szItem, "vesthelm", false))
    {
        if (iMoney >= 650) { strcopy(szFallback, iMaxLen, "vest"); return true; }
    }
    
    return false;
}

public Action Timer_BuyMissingItem(Handle hTimer, DataPack pack)
{
    pack.Reset();
    int iUserId = pack.ReadCell();
    
    char szItem[64];
    pack.ReadString(szItem, sizeof(szItem));
    delete pack;
    
    int client = GetClientOfUserId(iUserId);
    
    bool bInBuyZone = !!GetEntProp(client, Prop_Send, "m_bInBuyZone");
    
    if (!bInBuyZone)
        return Plugin_Stop;
    
    g_bAllowPurchase[client] = true;
    FakeClientCommand(client, "buy %s", szItem);
    CreateTimer(0.05, Timer_ResetPurchaseFlag, GetClientUserId(client));
    
    return Plugin_Stop;
}

// Collect current equipment
void CollectCurrentInventory(int client, ArrayList hInventory)
{
    // Primary weapon
    int iPrimary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
    if (IsValidEntity(iPrimary))
    {
        char szClass[64];
        GetEntityClassname(iPrimary, szClass, sizeof(szClass));
        ReplaceString(szClass, sizeof(szClass), "weapon_", "");
        hInventory.PushString(szClass);
    }
    
    // Secondary weapon
    int iSecondary = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
    if (IsValidEntity(iSecondary))
    {
        char szClass[64];
        GetEntityClassname(iSecondary, szClass, sizeof(szClass));
        ReplaceString(szClass, sizeof(szClass), "weapon_", "");
        hInventory.PushString(szClass);
    }
    
    // Check all grenades
    for (int slot = CS_SLOT_GRENADE; slot <= CS_SLOT_C4; slot++)
    {
        int iWeapon = GetPlayerWeaponSlot(client, slot);
        if (IsValidEntity(iWeapon))
        {
            char szClass[64];
            GetEntityClassname(iWeapon, szClass, sizeof(szClass));
            ReplaceString(szClass, sizeof(szClass), "weapon_", "");
            hInventory.PushString(szClass);
        }
    }
    
    // Armor
    int iArmor = GetEntProp(client, Prop_Send, "m_ArmorValue");
    bool bHasHelmet = !!GetEntProp(client, Prop_Send, "m_bHasHelmet");
    
    if (iArmor > 0)
    {
        if (bHasHelmet)
            hInventory.PushString("vesthelm");
        else
            hInventory.PushString("vest");
    }
    
    // Defuser
    if (GetClientTeam(client) == CS_TEAM_CT)
    {
        bool bHasDefuser = !!GetEntProp(client, Prop_Send, "m_bHasDefuser");
        if (bHasDefuser)
            hInventory.PushString("defuser");
    }
}

bool IsItemInInventory(ArrayList hInventory, const char[] szItem)
{
    char szNormalizedItem[64], szCheckItem[64];
    NormalizeItemName(szItem, szNormalizedItem, sizeof(szNormalizedItem));
    
    for (int i = 0; i < hInventory.Length; i++)
    {
        hInventory.GetString(i, szCheckItem, sizeof(szCheckItem));
        NormalizeItemName(szCheckItem, szCheckItem, sizeof(szCheckItem));
        
        if (StrEqual(szNormalizedItem, szCheckItem, false))
            return true;
    }
    
    return false;
}

void NormalizeItemName(const char[] szItem, char[] szOutput, int iMaxLen)
{
    strcopy(szOutput, iMaxLen, szItem);
    
    if (StrEqual(szItem, "m4a1_silencer", false))
        strcopy(szOutput, iMaxLen, "m4a1_silencer");
    else if (StrEqual(szItem, "usp_silencer", false))
        strcopy(szOutput, iMaxLen, "usp_silencer");
    else if (StrEqual(szItem, "cz75a", false))
        strcopy(szOutput, iMaxLen, "cz75a");
    else if (StrEqual(szItem, "incgrenade", false) || StrEqual(szItem, "molotov", false))
        strcopy(szOutput, iMaxLen, "molotov");
}

bool ShouldSkipPurchase(int client, const char[] szItem)
{
    int iSlot = GetWeaponSlotFromItem(szItem);
    
    if (iSlot == -1)
        return false;
    
    int iExistingWeapon = GetPlayerWeaponSlot(client, iSlot);
    if (!IsValidEntity(iExistingWeapon))
        return false;
    
    char szExistingClass[64];
    GetEntityClassname(iExistingWeapon, szExistingClass, sizeof(szExistingClass));
    ReplaceString(szExistingClass, sizeof(szExistingClass), "weapon_", "");
    
    // Never skip secondary weapon purchases
    if (iSlot == CS_SLOT_SECONDARY)
        return false;
    
    // Primary: if purchasing sniper rifle
    if (iSlot == CS_SLOT_PRIMARY && IsSniperWeapon(szItem))
    {
        if (IsSniperWeapon(szExistingClass))
            return true;
        return false;
    }
    
    // Primary: if currently holding sniper rifle, purchasing non-sniper
    if (iSlot == CS_SLOT_PRIMARY && IsSniperWeapon(szExistingClass) && !IsSniperWeapon(szItem))
    {
        return true;
    }
    
    // Primary: if already has non-default weapon, skip
    if (iSlot == CS_SLOT_PRIMARY)
        return true;
    
    return false;
}

// ============================================================================
// Command Handling
// ============================================================================

public Action Command_SetEconomyMode(int client, int args)
{
    if (args < 1)
    {
        ReplyToCommand(client, "[Bot REC] Usage: sm_botrec_economy <mode>");
        ReplyToCommand(client, "  0 = Single Team (default)");  
        ReplyToCommand(client, "  1 = Both Teams");  
        return Plugin_Handled;
    }
    
    char szArg[8];
    GetCmdArg(1, szArg, sizeof(szArg));
    int iMode = StringToInt(szArg);
    
    if (iMode < 0 || iMode > 1)
    {
        ReplyToCommand(client, "[Bot REC] Invalid mode! Use 0-1");
        return Plugin_Handled;
    }
    
    g_cvEconomyMode.IntValue = iMode;
    g_iEconomyMode = view_as<EconomySelectionMode>(iMode);
    
    char szModeName[64];
    switch (g_iEconomyMode)
    {
        case Economy_SingleTeam: strcopy(szModeName, sizeof(szModeName), "Single Team");
        case Economy_BothTeams: strcopy(szModeName, sizeof(szModeName), "Both Teams");
    }
    
    ReplyToCommand(client, "[Bot REC] Economy mode set to: %s", szModeName);
    return Plugin_Handled;
}

public Action Command_SetRoundMode(int client, int args)
{
    if (args < 1)
    {
        ReplyToCommand(client, "[Bot REC] Usage: sm_botrec_round <mode>");
        ReplyToCommand(client, "  0 = Full Match");
        ReplyToCommand(client, "  1 = Economy Based (default)");
        return Plugin_Handled;
    }
    
    char szArg[8];
    GetCmdArg(1, szArg, sizeof(szArg));
    int iMode = StringToInt(szArg);
    
    if (iMode < 0 || iMode > 1)
    {
        ReplyToCommand(client, "[Bot REC] Invalid mode! Use 0 or 1");
        return Plugin_Handled;
    }
    
    g_cvRoundMode.IntValue = iMode;
    g_iRoundMode = view_as<RoundSelectionMode>(iMode);
    
    char szModeName[64];
    switch (g_iRoundMode)
    {
        case Round_FullMatch: strcopy(szModeName, sizeof(szModeName), "Full Match");
        case Round_Economy: strcopy(szModeName, sizeof(szModeName), "Economy Based");
    }
    
    ReplyToCommand(client, "[Bot REC] Round mode set to: %s", szModeName);
    return Plugin_Handled;
}

public Action Command_ShowStatus(int client, int args)
{
    char szEconomyMode[64], szRoundMode[64];
    
    switch (g_iEconomyMode)
    {
        case Economy_SingleTeam: strcopy(szEconomyMode, sizeof(szEconomyMode), "Single Team");
        case Economy_BothTeams: strcopy(szEconomyMode, sizeof(szEconomyMode), "Both Teams");
    }
    
    switch (g_iRoundMode)
    {
        case Round_FullMatch: strcopy(szRoundMode, sizeof(szRoundMode), "Full Match");
        case Round_Economy: strcopy(szRoundMode, sizeof(szRoundMode), "Economy Based");
    }
    
    ReplyToCommand(client, "[Bot REC] ===== Status =====");
    ReplyToCommand(client, "  Round Mode: %s", szRoundMode);
    ReplyToCommand(client, "  Economy Mode: %s", szEconomyMode);
    ReplyToCommand(client, "  Current Round: %d", g_iCurrentRound);
    ReplyToCommand(client, "  Rec Folder: %s", g_bRecFolderSelected ? g_szCurrentRecFolder : "None");
    
    int iPlayingCount = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i) && g_bPlayingRoundStartRec[i])
            iPlayingCount++;
    }
    ReplyToCommand(client, "  Bots Playing REC: %d", iPlayingCount);
    
    return Plugin_Handled;
}

// ============================================================================
// Determine Whether to Stop REC Due to Damage
// ============================================================================

bool ShouldStopFromDamage(int iDamage, int iDamageType)
{
    // Damage too small, ignore (below 5 points)
    if (iDamage < 5)
    {
        return false;
    }
    
    // Fall damage - don't stop (already prevented in OnTakeDamage)
    if (iDamageType & DMG_FALL)
    {
        return false;
    }
    
    // Grenade damage - don't stop
    if (iDamageType & DMG_BLAST)
    {
        return false;
    }
    
    // Fire damage (molotov/incendiary) - stop only if above 5 points
    if (iDamageType & DMG_BURN)
    {
        if (iDamage < 5)
        {
            return false;
        }
        return true;
    }
    
    // Bullet damage (direct attack) - must stop
    if (iDamageType & DMG_BULLET)
    {
        return true;
    }
    
    // Other direct damage - must stop
    return true;
}

// ============================================================================
// Determine if Pistol Round
// ============================================================================

bool IsPistolRound(int iRound)
{
    // round1 (iRound=0) and round16 (iRound=15) are pistol rounds
    return (iRound == 0 || iRound == 15);
}

bool IsCurrentRoundPistol()
{
    return IsPistolRound(g_iCurrentRound);
}

// ============================================================================
// Helper Functions
// ============================================================================

void ResetClientData(int client)
{
    g_bPlayingRoundStartRec[client] = false;
    g_szRoundStartRecPath[client][0] = '\0';
    g_szCurrentRecName[client][0] = '\0';
    g_szAssignedRecName[client][0] = '\0';
    g_iAssignedRecIndex[client] = -1;
    g_bRecMoneySet[client] = false;
    g_iRecStartMoney[client] = 0;
    g_fRecStartTime[client] = 0.0;

    BotShared_ResetBotState(client);    
}

bool IsValidClient(int client)
{
    return BotShared_IsValidClient(client);
}

int GetAliveTeamCount(int iTeam)
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

/**
 * Get weapon slot
 * 
 * @param szItem    Item name (without weapon_ prefix)
 * @return          Slot index (CS_SLOT_PRIMARY/SECONDARY), -1 means not a weapon
 */
int GetWeaponSlotFromItem(const char[] szItem)
{
    // Primary weapons
    if (StrEqual(szItem, "ak47", false) || StrEqual(szItem, "m4a1", false) ||
        StrEqual(szItem, "m4a1_silencer", false) || StrEqual(szItem, "awp", false) ||
        StrEqual(szItem, "famas", false) || StrEqual(szItem, "galilar", false) ||
        StrEqual(szItem, "ssg08", false) || StrEqual(szItem, "aug", false) ||
        StrEqual(szItem, "sg556", false) || StrEqual(szItem, "mp9", false) ||
        StrEqual(szItem, "mac10", false) || StrEqual(szItem, "ump45", false) ||
        StrEqual(szItem, "p90", false) || StrEqual(szItem, "bizon", false) ||
        StrEqual(szItem, "mp7", false) || StrEqual(szItem, "scar20", false) ||
        StrEqual(szItem, "g3sg1", false) || StrEqual(szItem, "nova", false) ||
        StrEqual(szItem, "xm1014", false) || StrEqual(szItem, "mag7", false) ||
        StrEqual(szItem, "sawedoff", false) || StrEqual(szItem, "m249", false) ||
        StrEqual(szItem, "negev", false))
        return CS_SLOT_PRIMARY;
    
    // Secondary weapons
    if (StrEqual(szItem, "deagle", false) || StrEqual(szItem, "usp_silencer", false) ||
        StrEqual(szItem, "glock", false) || StrEqual(szItem, "hkp2000", false) ||
        StrEqual(szItem, "p250", false) || StrEqual(szItem, "tec9", false) ||
        StrEqual(szItem, "fiveseven", false) || StrEqual(szItem, "cz75a", false) ||
        StrEqual(szItem, "elite", false) || StrEqual(szItem, "revolver", false))
        return CS_SLOT_SECONDARY;
    
    return -1;
}

// Sort bots by money (low to high)
public int Sort_BotsByMoney(int index1, int index2, Handle array, Handle hndl)
{
    ArrayList list = view_as<ArrayList>(array);   
    int client1 = list.Get(index1);
    int client2 = list.Get(index2);

    int iMoney1 = GetEntProp(client1, Prop_Send, "m_iAccount");
    int iMoney2 = GetEntProp(client2, Prop_Send, "m_iAccount");

    if (iMoney1 < iMoney2) return -1;
    if (iMoney1 > iMoney2) return 1;
    return 0;
}

// Load freeze times for specified demo
bool LoadFreezeTimesForDemo(const char[] szMap, const char[] szDemoFolder, float fFreezeTimes[31], bool bValid[31])
{
    char szFreezePath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, szFreezePath, sizeof(szFreezePath), 
        "data/botmimic/all/%s/%s/freeze.txt", szMap, szDemoFolder);
    
    // Initialize as invalid
    for (int i = 0; i < 31; i++)
    {
        bValid[i] = false;
        fFreezeTimes[i] = 0.0;
    }
    
    if (!FileExists(szFreezePath))
        return false;
    
    File hFile = OpenFile(szFreezePath, "r");
    if (hFile == null)
        return false;
    
    char szLine[128];
    float fStandard = 20.0;
    const float TOLERANCE = 2.0;
    int iValidCount = 0;
    
    while (hFile.ReadLine(szLine, sizeof(szLine)))
    {
        TrimString(szLine);
        
        if (strlen(szLine) == 0 || szLine[0] == '/' || szLine[0] == '#')
            continue;
        
        // Check standard time
        if (StrContains(szLine, "Freeze time", false) != -1 || 
            StrContains(szLine, "standard", false) != -1 ||
            StrContains(szLine, "freeze", false) != -1)
        {
            char szParts[2][64];
            int iParts = ExplodeString(szLine, ":", szParts, sizeof(szParts), sizeof(szParts[]));
            if (iParts >= 2)
            {
                TrimString(szParts[1]);
                ReplaceString(szParts[1], sizeof(szParts[]), "seconds", "");
                ReplaceString(szParts[1], sizeof(szParts[]), "s", "", false);
                fStandard = StringToFloat(szParts[1]);
            }
            continue;
        }
        
        // Parse round time
        char szParts[2][64];
        int iParts = ExplodeString(szLine, ":", szParts, sizeof(szParts), sizeof(szParts[]));
        if (iParts < 2)
            continue;
        
        TrimString(szParts[0]);
        int iRoundNum = -1;
        
        if (StrContains(szParts[0], "round", false) != -1)
        {
            ReplaceString(szParts[0], sizeof(szParts[]), "round", "", false);
            ReplaceString(szParts[0], sizeof(szParts[]), "Round", "", false);
            TrimString(szParts[0]);
            iRoundNum = StringToInt(szParts[0]);
        }
        else
        {
            iRoundNum = StringToInt(szParts[0]);
        }
        
        if (iRoundNum < 1 || iRoundNum > 30)
            continue;
        
        TrimString(szParts[1]);
        ReplaceString(szParts[1], sizeof(szParts[]), "seconds", "");
        ReplaceString(szParts[1], sizeof(szParts[]), "s", "", false);
        float fFreezeTime = StringToFloat(szParts[1]);
        
        // Array index = round number - 1
        int iArrayIndex = iRoundNum - 1;
        
        // For economy system, needs tolerance check
        float fDifference = FloatAbs(fFreezeTime - fStandard);
        if (fDifference <= TOLERANCE)
        {
            bValid[iArrayIndex] = true;
            fFreezeTimes[iArrayIndex] = fFreezeTime;
            iValidCount++;
        }
    }
    
    delete hFile;
    return (iValidCount > 0);
}

// Load purchase data for specified demo
JSONObject LoadPurchaseDataForDemo(const char[] szMap, const char[] szDemoFolder)
{
    char szPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, szPath, sizeof(szPath), 
        "data/botmimic/all/%s/%s/purchases.json", szMap, szDemoFolder);
    
    if (!FileExists(szPath))
        return null;
    
    return JSONObject.FromFile(szPath);
}

public Action Command_SelectDemo(int client, int args)
{
    if (args < 1)
    {
        char szMap[64];
        GetCurrentMap(szMap, sizeof(szMap));
        GetMapDisplayName(szMap, szMap, sizeof(szMap));
        
        char szMapBasePath[PLATFORM_MAX_PATH];
        BuildPath(Path_SM, szMapBasePath, sizeof(szMapBasePath), "data/botmimic/all/%s", szMap);
        
        ReplyToCommand(client, "[Bot REC] Usage: sm_botrec_select <folder_name>");
        ReplyToCommand(client, "[Bot REC] Available demos:");
        
        if (DirExists(szMapBasePath))
        {
            DirectoryListing hDir = OpenDirectory(szMapBasePath);
            if (hDir != null)
            {
                char szFolderName[PLATFORM_MAX_PATH];
                FileType iFileType;
                int iCount = 0;
                
                while (hDir.GetNext(szFolderName, sizeof(szFolderName), iFileType))
                {
                    if (iFileType == FileType_Directory && strcmp(szFolderName, ".") != 0 && strcmp(szFolderName, "..") != 0)
                    {
                        ReplyToCommand(client, "  - %s", szFolderName);
                        iCount++;
                    }
                }
                
                delete hDir;
                
                if (iCount == 0)
                    ReplyToCommand(client, "[Bot REC] No demo folders found!");
            }
        }
        else
        {
            ReplyToCommand(client, "[Bot REC] Demo path not found: %s", szMapBasePath);
        }
        
        return Plugin_Handled;
    }
    
    char szDemoFolder[PLATFORM_MAX_PATH];
    GetCmdArg(1, szDemoFolder, sizeof(szDemoFolder));
    
    char szMap[64];
    GetCurrentMap(szMap, sizeof(szMap));
    GetMapDisplayName(szMap, szMap, sizeof(szMap));
    
    char szDemoPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, szDemoPath, sizeof(szDemoPath), "data/botmimic/all/%s/%s", szMap, szDemoFolder);
    
    if (!DirExists(szDemoPath))
    {
        ReplyToCommand(client, "[Bot REC] Demo folder '%s' not found!", szDemoFolder);
        return Plugin_Handled;
    }
    
    // Set demo
    strcopy(g_szCurrentRecFolder, sizeof(g_szCurrentRecFolder), szDemoFolder);
    g_bRecFolderSelected = true;
    
    // Load freeze times
    if (LoadFreezeTimes(szMap, g_szCurrentRecFolder))
    {
        ReplyToCommand(client, "[Bot REC] ✓ Loaded freeze times for '%s'", szDemoFolder);
    }
    
    // Load purchase data
    if (LoadPurchaseDataFile(g_szCurrentRecFolder))
    {
        ReplyToCommand(client, "[Bot REC] ✓ Loaded purchase data for '%s'", szDemoFolder);
    }
    
    ReplyToCommand(client, "[Bot REC] ✓ Demo folder set to: %s", szDemoFolder);
    ReplyToCommand(client, "[Bot REC] Use 'mp_restartgame 1' to apply changes");
    
    return Plugin_Handled;
}

// ============================================================================
// REC Assignment Simulation/Execution Functions
// ============================================================================
KnapsackResult SolveKnapsackDP(ArrayList hBots, ArrayList hRecInfoList, int iTotalBudget)
{
    KnapsackResult result;
    result.isValid = false;
    result.totalValue = 0;
    result.totalCost = 0;
    
    for (int i = 0; i <= MAXPLAYERS; i++)
        result.assignment[i] = -1;
    
    int iBotCount = hBots.Length;
    int iRecCount = hRecInfoList.Length;
    
    if (iBotCount == 0 || iRecCount == 0)
        return result;
    
    int iMaxBudget = iTotalBudget;
    if (iMaxBudget > 80000)
        iMaxBudget = 80000;
    
    int iBudgetStep = 100;
    int iBudgetSize = (iMaxBudget / iBudgetStep) + 1;
    
    // Use ArrayList instead of multidimensional arrays
    ArrayList dpTable = new ArrayList(iBudgetSize);
    ArrayList choiceTable = new ArrayList(iBudgetSize);
    ArrayList usedRecsTable = new ArrayList(iBudgetSize);
    
    // Initialize tables all states set to 0 
    for (int i = 0; i <= iBotCount; i++)
    {
        ArrayList dpRow = new ArrayList();
        ArrayList choiceRow = new ArrayList();
        ArrayList usedRecsRow = new ArrayList(iBudgetSize);
        
        for (int b = 0; b < iBudgetSize; b++)
        {
            dpRow.Push(0);  // All initialized to 0
            choiceRow.Push(-1);
            
            ArrayList usedRecs = new ArrayList();
            usedRecsRow.Push(usedRecs);
        }
        
        dpTable.Push(dpRow);
        choiceTable.Push(choiceRow);
        usedRecsTable.Push(usedRecsRow);
    }
    
    // DP table filling logic 
    for (int i = 1; i <= iBotCount; i++)
    {       
        ArrayList currentDp = view_as<ArrayList>(dpTable.Get(i));
        ArrayList currentChoice = view_as<ArrayList>(choiceTable.Get(i));
        ArrayList currentUsedRecs = view_as<ArrayList>(usedRecsTable.Get(i));
        ArrayList prevDp = view_as<ArrayList>(dpTable.Get(i - 1));
        ArrayList prevUsedRecs = view_as<ArrayList>(usedRecsTable.Get(i - 1));
        
        for (int b = 0; b < iBudgetSize; b++)
        {
            int budget = b * iBudgetStep;
            
            // First inherit previous row value 
            int inheritValue = prevDp.Get(b);
            currentDp.Set(b, inheritValue);
            
            // Copy previous row used REC list
            ArrayList inheritUsedList = view_as<ArrayList>(prevUsedRecs.Get(b));
            ArrayList currentUsedList = view_as<ArrayList>(currentUsedRecs.Get(b));
            delete currentUsedList;
            
            currentUsedList = new ArrayList();
            for (int u = 0; u < inheritUsedList.Length; u++)
            {
                currentUsedList.Push(inheritUsedList.Get(u));
            }
            currentUsedRecs.Set(b, currentUsedList);
            
            // Try to assign each REC to current bot
            for (int r = 0; r < iRecCount; r++)
            {
                RecEquipmentInfo recInfo;
                hRecInfoList.GetArray(r, recInfo, sizeof(RecEquipmentInfo));
                
                int cost = recInfo.totalCost;
                int value = recInfo.tacticalValue;
                
                int prevBudgetIndex = (budget - cost) / iBudgetStep;
                
                if (budget >= cost && prevBudgetIndex >= 0 && prevBudgetIndex < iBudgetSize)
                {
                    int prevValue = prevDp.Get(prevBudgetIndex);
                    
                    // Check if this REC has been used
                    ArrayList prevUsedList = view_as<ArrayList>(prevUsedRecs.Get(prevBudgetIndex));
                    bool bRecAlreadyUsed = (prevUsedList.FindValue(r) != -1);
                    
                    // Remove prevValue >= 0 check 
                    if (!bRecAlreadyUsed)
                    {
                        int newValue = prevValue + value;
                        int currentValue = currentDp.Get(b);
                        
                        if (newValue > currentValue)
                        {
                            currentDp.Set(b, newValue);
                            currentChoice.Set(b, r);
                            
                            // Update used REC list
                            ArrayList newUsedList = view_as<ArrayList>(currentUsedRecs.Get(b));
                            delete newUsedList;
                            
                            newUsedList = new ArrayList();
                            // Copy previous state used list
                            for (int u = 0; u < prevUsedList.Length; u++)
                            {
                                newUsedList.Push(prevUsedList.Get(u));
                            }
                            // Add current REC
                            newUsedList.Push(r);
                            
                            currentUsedRecs.Set(b, newUsedList);
                        }
                    }
                }
            }
        }
    }
    
    // Find optimal solution
    int bestBudgetIndex = -1;
    int bestValue = 0;  
    ArrayList lastDp = view_as<ArrayList>(dpTable.Get(iBotCount));
    
    for (int b = 0; b < iBudgetSize; b++)
    {
        int budget = b * iBudgetStep;
        int value = lastDp.Get(b);
        
        if (budget <= iTotalBudget && value > bestValue)
        {
            bestValue = value;
            bestBudgetIndex = b;
        }
    }
    
    // As long as has value it's considered valid 
    if (bestBudgetIndex == -1 || bestValue <= 0)
    {    
        // Cleanup
        for (int i = 0; i <= iBotCount; i++)
        {
            delete view_as<ArrayList>(dpTable.Get(i));
            delete view_as<ArrayList>(choiceTable.Get(i));
            
            ArrayList usedRecsRow = view_as<ArrayList>(usedRecsTable.Get(i));
            for (int b = 0; b < iBudgetSize; b++)
            {
                delete view_as<ArrayList>(usedRecsRow.Get(b));
            }
            delete usedRecsRow;
        }
        delete dpTable;
        delete choiceTable;
        delete usedRecsTable;
        
        return result;
    }
    
    // Backtrack solution
    int currentBudgetIndex = bestBudgetIndex;
    int totalCost = 0;
    ArrayList usedRecIndices = new ArrayList();
    
    for (int i = iBotCount; i >= 1; i--)
    {
        ArrayList currentChoice = view_as<ArrayList>(choiceTable.Get(i));
        int recIndex = currentChoice.Get(currentBudgetIndex);
        result.assignment[i - 1] = recIndex;
        
        if (recIndex >= 0)
        {
            if (usedRecIndices.FindValue(recIndex) != -1)
            {
                // Detected duplicate, but continue (will handle later)
            }
            usedRecIndices.Push(recIndex);
            
            RecEquipmentInfo recInfo;
            hRecInfoList.GetArray(recIndex, recInfo, sizeof(RecEquipmentInfo));
            
            int cost = recInfo.totalCost;
            totalCost += cost;
            
            int prevBudget = (currentBudgetIndex * iBudgetStep) - cost;
            currentBudgetIndex = prevBudget / iBudgetStep;
        }
    }
    
    delete usedRecIndices;
    
    // Mark as valid and set result
    result.isValid = true;
    result.totalValue = bestValue;
    result.totalCost = totalCost;
    
    // Cleanup
    for (int i = 0; i <= iBotCount; i++)
    {
        delete view_as<ArrayList>(dpTable.Get(i));
        delete view_as<ArrayList>(choiceTable.Get(i));
        
        ArrayList usedRecsRow = view_as<ArrayList>(usedRecsTable.Get(i));
        for (int b = 0; b < iBudgetSize; b++)
        {
            delete view_as<ArrayList>(usedRecsRow.Get(b));
        }
        delete usedRecsRow;
    }
    delete dpTable;
    delete choiceTable;
    delete usedRecsTable;
    
    return result;
}

// ============================================================================
// Local Search Optimization
// ============================================================================

KnapsackResult LocalSearchOptimize(KnapsackResult initial, ArrayList hBots, 
                                   ArrayList hRecInfoList, int iTotalBudget)
{
    KnapsackResult current;
    // Copy initial to current
    current.isValid = initial.isValid;
    current.totalValue = initial.totalValue;
    current.totalCost = initial.totalCost;
    for (int i = 0; i <= MAXPLAYERS; i++)
        current.assignment[i] = initial.assignment[i];
    
    int currentQuality = EvaluateAssignmentQuality(current, hBots, hRecInfoList);
    
    bool improved = true;
    int iteration = 0;
    const int MAX_ITERATIONS = 50;
    
    while (improved && iteration < MAX_ITERATIONS)
    {
        improved = false;
        iteration++;
        
        int iBotCount = hBots.Length;
        int iRecCount = hRecInfoList.Length;
        
        // Strategy 1: Try swapping REC assignments between two bots
        for (int i = 0; i < iBotCount - 1; i++)
        {
            for (int j = i + 1; j < iBotCount; j++)
            {
                KnapsackResult candidate;
                // Copy current to candidate
                candidate.isValid = current.isValid;
                candidate.totalValue = current.totalValue;
                candidate.totalCost = current.totalCost;
                for (int k = 0; k <= MAXPLAYERS; k++)
                    candidate.assignment[k] = current.assignment[k];
                
                // Swap Bot i and Bot j assignments
                int temp = candidate.assignment[i];
                candidate.assignment[i] = candidate.assignment[j];
                candidate.assignment[j] = temp;
                
                RecalculateResult(candidate, hBots, hRecInfoList);
                
                if (candidate.totalCost > iTotalBudget)
                    continue;
                
                if (!CanTeamAfford(candidate, hBots, hRecInfoList))
                    continue;
                
                int candidateQuality = EvaluateAssignmentQuality(candidate, hBots, hRecInfoList);
                
                if (candidateQuality > currentQuality)
                {
                    // Verify uniqueness
                    if (!ValidateAssignmentUniqueness(candidate, iBotCount))
                    {
                        continue;
                    }
                    // Copy candidate to current
                    current.isValid = candidate.isValid;
                    current.totalValue = candidate.totalValue;
                    current.totalCost = candidate.totalCost;
                    for (int k = 0; k <= MAXPLAYERS; k++)
                        current.assignment[k] = candidate.assignment[k];
                    
                    currentQuality = candidateQuality;
                    improved = true;
                }
            }
        }
        
        // Strategy 2: Try single bot REC replacement
        for (int i = 0; i < iBotCount; i++)
        {
            int originalRec = current.assignment[i];
            
            for (int r = 0; r < iRecCount; r++)
            {
                if (r == originalRec)
                    continue;
                
                // Check if this REC is already used by other bot
                bool bRecInUse = false;
                for (int b = 0; b < iBotCount; b++)
                {
                    if (b != i && current.assignment[b] == r)
                    {
                        bRecInUse = true;
                        break;
                    }
                }
                
                if (bRecInUse)
                    continue;  // Skip used REC
                
                KnapsackResult candidate;
                candidate.isValid = current.isValid;
                candidate.totalValue = current.totalValue;
                candidate.totalCost = current.totalCost;
                for (int k = 0; k <= MAXPLAYERS; k++)
                    candidate.assignment[k] = current.assignment[k];
                
                candidate.assignment[i] = r;
                
                RecalculateResult(candidate, hBots, hRecInfoList);
                
                if (candidate.totalCost > iTotalBudget)
                    continue;
                
                if (!CanTeamAfford(candidate, hBots, hRecInfoList))
                    continue;
                
                int candidateQuality = EvaluateAssignmentQuality(candidate, hBots, hRecInfoList);
                
                if (candidateQuality > currentQuality)
                {
                    // Double verify uniqueness
                    if (!ValidateAssignmentUniqueness(candidate, iBotCount))
                    {
                        continue;
                    }
                    
                    current.isValid = candidate.isValid;
                    current.totalValue = candidate.totalValue;
                    current.totalCost = candidate.totalCost;
                    for (int k = 0; k <= MAXPLAYERS; k++)
                        current.assignment[k] = candidate.assignment[k];
                    
                    currentQuality = candidateQuality;
                    improved = true;
                }
            }
        }
    }
    
    return current;
}

// ============================================================================
// Quality Evaluation Function (Core Soft Constraints)
// ============================================================================

int EvaluateAssignmentQuality(KnapsackResult result, ArrayList hBots, 
                              ArrayList hRecInfoList)
{
    int quality = result.totalValue;  // Base score: equipment total value
    
    int iBotCount = hBots.Length;
    
    // Soft constraint 1: Penalize uneven equipment value distribution 
    ArrayList values = new ArrayList();
    int totalValue = 0;
    
    for (int i = 0; i < iBotCount; i++)
    {
        int recIndex = result.assignment[i];
        if (recIndex >= 0)
        {
            RecEquipmentInfo recInfo;
            hRecInfoList.GetArray(recIndex, recInfo, sizeof(RecEquipmentInfo));
            values.Push(recInfo.totalValue);
            totalValue += recInfo.totalValue;
        }
        else
        {
            values.Push(0);
        }
    }
    
    // Calculate variance
    float avgValue = float(totalValue) / float(iBotCount);
    float variance = 0.0;
    
    for (int i = 0; i < iBotCount; i++)
    {
        float diff = float(values.Get(i)) - avgValue;
        variance += diff * diff;
    }
    variance /= float(iBotCount);
    
    // Higher variance deducts more points
    int variancePenalty = RoundFloat(variance / 100.0);
    quality -= variancePenalty;
    
    // Soft constraint 2: Reward weapon diversity 
    int primaryCount[10];  // Count various primary weapon types
    for (int i = 0; i < 10; i++)
        primaryCount[i] = 0;
    
    for (int i = 0; i < iBotCount; i++)
    {
        int recIndex = result.assignment[i];
        if (recIndex >= 0)
        {
            RecEquipmentInfo recInfo;
            hRecInfoList.GetArray(recIndex, recInfo, sizeof(RecEquipmentInfo));
            
            if (recInfo.hasSniper)
                primaryCount[0]++;
            else if (recInfo.hasRifle)
                primaryCount[1]++;
            else if (recInfo.hasPrimary)
                primaryCount[2]++;
        }
    }
    
    // Ideal configuration: 1 sniper + 4 rifles, or 5 rifles
    int diversityBonus = 0;
    if (primaryCount[0] == 1 && primaryCount[1] >= 3)
        diversityBonus = 200;  // 1 AWP + rifles
    else if (primaryCount[1] == 5)
        diversityBonus = 150;  // All rifles
    else if (primaryCount[0] == 0 && primaryCount[1] >= 4)
        diversityBonus = 100;  // 4+ rifles
    
    quality += diversityBonus;
    
    // Soft constraint 3: Reward utility configuration
    int totalUtility = 0;
    for (int i = 0; i < iBotCount; i++)
    {
        int recIndex = result.assignment[i];
        if (recIndex >= 0)
        {
            RecEquipmentInfo recInfo;
            hRecInfoList.GetArray(recIndex, recInfo, sizeof(RecEquipmentInfo));
            totalUtility += recInfo.utilityCount;
        }
    }
    
    // Ideal utility count: 8-12 (average about 2 per person)
    int utilityBonus = 0;
    if (totalUtility >= 8 && totalUtility <= 12)
        utilityBonus = 100;
    else if (totalUtility >= 6)
        utilityBonus = 50;
    
    quality += utilityBonus;
    
    // Soft constraint 4: Penalize excessive "weapon distribution" requirement
    int totalDeficit = 0;
    for (int i = 0; i < iBotCount; i++)
    {
        int client = hBots.Get(i);
        int clientMoney = GetEntProp(client, Prop_Send, "m_iAccount");
        
        int recIndex = result.assignment[i];
        if (recIndex >= 0)
        {
            RecEquipmentInfo recInfo;
            hRecInfoList.GetArray(recIndex, recInfo, sizeof(RecEquipmentInfo));
            
            int deficit = recInfo.totalCost - clientMoney;
            if (deficit > 0)
                totalDeficit += deficit;
        }
    }
    
    // Higher weapon distribution requirement deducts more points
    int dropPenalty = totalDeficit / 10;
    quality -= dropPenalty;
    
    delete values;
    
    return quality;
}

// ============================================================================
// Helper Functions
// ============================================================================

// Get REC file list for a round
ArrayList GetRecFilesForRound(const char[] szMap, const char[] szDemoFolder, 
                              int iRound, const char[] szTeamName)
{
    ArrayList hRecFiles = new ArrayList(PLATFORM_MAX_PATH);
    
    char szRoundPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, szRoundPath, sizeof(szRoundPath), 
        "data/botmimic/all/%s/%s/round%d/%s", 
        szMap, szDemoFolder, iRound + 1, szTeamName);
    
    if (!DirExists(szRoundPath))
        return hRecFiles;
    
    DirectoryListing hDir = OpenDirectory(szRoundPath);
    if (hDir != null)
    {
        char szFileName[PLATFORM_MAX_PATH];
        FileType iFileType;
        
        while (hDir.GetNext(szFileName, sizeof(szFileName), iFileType))
        {
            if (iFileType == FileType_File && StrContains(szFileName, ".rec") != -1)
            {
                ReplaceString(szFileName, sizeof(szFileName), ".rec", "");
                hRecFiles.PushString(szFileName);
            }
        }
        delete hDir;
    }
    
    return hRecFiles;
}

// Build REC equipment info cache
ArrayList BuildRecEquipmentCache(ArrayList hRecFiles, JSONObject jTeam, int iTeam)
{
    ArrayList hRecInfoList = new ArrayList(sizeof(RecEquipmentInfo));
    
    for (int r = 0; r < hRecFiles.Length; r++)
    {
        char szRecName[PLATFORM_MAX_PATH];
        hRecFiles.GetString(r, szRecName, sizeof(szRecName));
        
        if (!jTeam.HasKey(szRecName))
        {
            continue;
        }
        
        JSONObject jBotData = view_as<JSONObject>(jTeam.Get(szRecName));
        
        RecEquipmentInfo recInfo;
        strcopy(recInfo.recName, PLATFORM_MAX_PATH, szRecName);
        
        recInfo.totalCost = 0;
        recInfo.totalValue = 0;
        recInfo.tacticalValue = 0;
        recInfo.hasPrimary = false;
        recInfo.hasSniper = false;
        recInfo.hasRifle = false;
        recInfo.utilityCount = 0;
        recInfo.primaryWeapon[0] = '\0';
        
        // Step 1: Calculate cost from purchase records
        ArrayList purchasedItems = new ArrayList(ByteCountToCells(64));
        bool hasSlotItem[5] = {false, ...};  // Track whether each slot has equipment
        
        if (jBotData.HasKey("purchases"))
        {
            JSONArray jPurchases = view_as<JSONArray>(jBotData.Get("purchases"));
            
            for (int i = 0; i < jPurchases.Length; i++)
            {
                JSONObject jAction = view_as<JSONObject>(jPurchases.Get(i));
                
                char szAction[32];
                jAction.GetString("action", szAction, sizeof(szAction));
                
                char szItem[64];
                jAction.GetString("item", szItem, sizeof(szItem));
                
                // Convert opposite faction weapons
                char szConvertedItem[64];
                GetTeamSpecificWeapon(szItem, iTeam, szConvertedItem, sizeof(szConvertedItem));
                
                int iSlot = GetWeaponSlotFromItem(szConvertedItem);
                
                if (StrEqual(szAction, "purchased", false))
                {
                    // Purchase action: add price, mark slot has equipment
                    int iPrice = GetItemPrice(szConvertedItem);
                    recInfo.totalCost += iPrice;
                    purchasedItems.PushString(szConvertedItem);
                    
                    if (iSlot >= 0 && iSlot < 5)
                        hasSlotItem[iSlot] = true;
                }
                else if (StrEqual(szAction, "dropped", false))
                {
                    // Drop action: check if slot had equipment before drop
                    if (iSlot >= 0 && iSlot < 5)
                    {
                        if (!hasSlotItem[iSlot])
                        {
                            // Safety measure: slot was empty before drop, need to add dropped weapon price
                            int iPrice = GetItemPrice(szConvertedItem);
                            recInfo.totalCost += iPrice;
                        }
                        
                        // Slot becomes empty after drop
                        hasSlotItem[iSlot] = false;
                    }
                }
                else if (StrEqual(szAction, "picked_up", false))
                {
                    // Pickup action: mark slot has equipment, but don't add price
                    if (iSlot >= 0 && iSlot < 5)
                        hasSlotItem[iSlot] = true;
                }
                
                delete jAction;
            }
            
            delete jPurchases;
        }
        
        // Step 2: Check items in final_inventory but not in purchases
        if (jBotData.HasKey("final_inventory"))
        {
            JSONArray jInventory = view_as<JSONArray>(jBotData.Get("final_inventory"));
            
            for (int i = 0; i < jInventory.Length; i++)
            {
                char szItem[64];
                jInventory.GetString(i, szItem, sizeof(szItem));
                
                // Convert opposite faction weapons
                char szConvertedItem[64];
                GetTeamSpecificWeapon(szItem, iTeam, szConvertedItem, sizeof(szConvertedItem));
                
                // Check if in purchased list
                bool bWasPurchased = false;
                for (int p = 0; p < purchasedItems.Length; p++)
                {
                    char szPurchased[64];
                    purchasedItems.GetString(p, szPurchased, sizeof(szPurchased));
                    
                    if (StrEqual(szConvertedItem, szPurchased, false))
                    {
                        bWasPurchased = true;
                        break;
                    }
                }
                
                // Get price (needed for totalValue regardless of purchased)
                int iPrice = GetItemPrice(szConvertedItem);
                
                // If not in purchased list, need to add to totalCost
                if (!bWasPurchased)
                {
                    recInfo.totalCost += iPrice;
                }
                
                // Calculate tactical value and total value
                int iTacticalValue = GetTacticalValue(szConvertedItem);
                recInfo.tacticalValue += iTacticalValue;
                recInfo.totalValue += iPrice;
                
                // Analyze equipment type
                int iSlot = GetWeaponSlotFromItem(szConvertedItem);
                
                if (iSlot == CS_SLOT_PRIMARY)
                {
                    recInfo.hasPrimary = true;
                    strcopy(recInfo.primaryWeapon, sizeof(recInfo.primaryWeapon), szConvertedItem);
                    
                    if (IsSniperWeapon(szConvertedItem))
                        recInfo.hasSniper = true;
                    else if (IsRifleWeapon(szConvertedItem))
                        recInfo.hasRifle = true;
                }
                else if (IsUtilityItem(szConvertedItem))
                {
                    recInfo.utilityCount++;
                }
            }
            
            delete jInventory;
        }
        
        delete purchasedItems;
        delete jBotData;
        
        hRecInfoList.PushArray(recInfo, sizeof(RecEquipmentInfo));
    }
    
    return hRecInfoList;
}

// Calculate tactical value (with weights)
int GetTacticalValue(const char[] szItem)
{
    int basePrice = GetItemPrice(szItem);
    float multiplier = 1.0;
    
    // Primary weapon weighting
    if (IsRifleWeapon(szItem))
    {
        multiplier = 1.5;  // Rifles most important
    }
    else if (IsSniperWeapon(szItem))
    {
        multiplier = 1.8;  // Snipers more important
    }
    else if (IsSMGWeapon(szItem))
    {
        multiplier = 0.7;  // SMGs lower tactical value
    }
    
    // Utility weighting
    if (StrEqual(szItem, "smokegrenade", false))
    {
        multiplier = 2.0;  // Smoke grenades extremely important
    }
    else if (StrEqual(szItem, "flashbang", false))
    {
        multiplier = 1.5;  // Flashbangs important
    }
    else if (StrEqual(szItem, "hegrenade", false))
    {
        multiplier = 1.3;
    }
    else if (StrEqual(szItem, "molotov", false) || StrEqual(szItem, "incgrenade", false))
    {
        multiplier = 1.4;
    }
    
    // Armor weighting
    if (StrEqual(szItem, "vesthelm", false))
    {
        multiplier = 1.6;  // Helmet very important
    }
    else if (StrEqual(szItem, "vest", false))
    {
        multiplier = 1.3;
    }
    
    // Defuser
    if (StrEqual(szItem, "defuser", false))
    {
        multiplier = 1.5;
    }
    
    return RoundFloat(float(basePrice) * multiplier);
}

// Recalculate result total cost and total value
void RecalculateResult(KnapsackResult result, ArrayList hBots, ArrayList hRecInfoList)
{
    result.totalCost = 0;
    result.totalValue = 0;
    
    int iBotCount = hBots.Length;
    
    for (int i = 0; i < iBotCount; i++)
    {
        int recIndex = result.assignment[i];
        if (recIndex >= 0 && recIndex < hRecInfoList.Length)
        {
            RecEquipmentInfo recInfo;
            hRecInfoList.GetArray(recIndex, recInfo, sizeof(RecEquipmentInfo));
            
            result.totalCost += recInfo.totalCost;
            result.totalValue += recInfo.tacticalValue;
        }
    }
}

// Check if team can afford (considering virtual weapon distribution)
bool CanTeamAfford(KnapsackResult result, ArrayList hBots, ArrayList hRecInfoList)
{
    int iBotCount = hBots.Length;
    
    // Calculate total economy and total requirement
    int totalMoney = 0;
    int totalRequired = 0;
    
    for (int i = 0; i < iBotCount; i++)
    {
        int client = hBots.Get(i);
        int clientMoney = GetEntProp(client, Prop_Send, "m_iAccount");
        totalMoney += clientMoney;
        
        int recIndex = result.assignment[i];
        if (recIndex >= 0)
        {
            RecEquipmentInfo recInfo;
            hRecInfoList.GetArray(recIndex, recInfo, sizeof(RecEquipmentInfo));
            totalRequired += recInfo.totalCost;
        }
    }
    
    // As long as total economy is enough (allow virtual weapon distribution)
    return (totalMoney >= totalRequired);
}

// Virtual weapon distribution simulation
void SimulateDropSystem(ArrayList hBots, KnapsackResult result, ArrayList hRecInfoList)
{
    int iBotCount = hBots.Length;
    
    // Use ArrayList to store bot information
    ArrayList botInfos = new ArrayList(sizeof(BotEconomyInfo));
    
    for (int i = 0; i < iBotCount; i++)
    {
        int client = hBots.Get(i);
        
        BotEconomyInfo info;
        info.client = client;
        info.money = GetEntProp(client, Prop_Send, "m_iAccount");
        info.teamIndex = i;
        
        int recIndex = result.assignment[i];
        if (recIndex >= 0)
        {
            RecEquipmentInfo recInfo;
            hRecInfoList.GetArray(recIndex, recInfo, sizeof(RecEquipmentInfo));
            
            info.assignedRecIndex = recIndex;
            info.assignedCost = recInfo.totalCost;
            info.assignedValue = recInfo.totalValue;
            strcopy(info.assignedRecName, PLATFORM_MAX_PATH, recInfo.recName);
        }
        else
        {
            info.assignedRecIndex = -1;
            info.assignedCost = 0;
            info.assignedValue = 0;
            info.assignedRecName[0] = '\0';
        }
        
        botInfos.PushArray(info, sizeof(BotEconomyInfo));
    }
    
    // Sort by economy (using SortADTArrayCustom)
    SortADTArrayCustom(botInfos, Sort_BotEconomyByMoney);
    
    // Allocate "virtual weapon distribution"
    for (int i = 0; i < iBotCount; i++)
    {
        BotEconomyInfo info;
        botInfos.GetArray(i, info, sizeof(BotEconomyInfo));
        
        int deficit = info.assignedCost - info.money;
        
        if (deficit > 0)
        {
            for (int j = iBotCount - 1; j >= 0; j--)
            {
                if (j == i)
                    continue;
                
                BotEconomyInfo richInfo;
                botInfos.GetArray(j, richInfo, sizeof(BotEconomyInfo));
                
                int surplus = richInfo.money - richInfo.assignedCost;
                
                if (surplus > 0)
                {
                    int transfer = (surplus < deficit) ? surplus : deficit;
                    
                    richInfo.money -= transfer;
                    info.money += transfer;
                    deficit -= transfer;
                    
                    // Update array
                    botInfos.SetArray(j, richInfo, sizeof(BotEconomyInfo));
                    
                    char szFromName[MAX_NAME_LENGTH], szToName[MAX_NAME_LENGTH];
                    GetClientName(richInfo.client, szFromName, sizeof(szFromName));
                    GetClientName(info.client, szToName, sizeof(szToName));
                    
                    if (deficit <= 0)
                        break;
                }
            }
            
            if (deficit > 0)
            {
                char szName[MAX_NAME_LENGTH];
                GetClientName(info.client, szName, sizeof(szName));
            }
        }
    }
    
    delete botInfos;
}

// Sort function: by money ascending
public int Sort_BotEconomyByMoney(int index1, int index2, Handle array, Handle hndl)
{
    ArrayList list = view_as<ArrayList>(array);
    
    BotEconomyInfo info1, info2;
    list.GetArray(index1, info1, sizeof(BotEconomyInfo));
    list.GetArray(index2, info2, sizeof(BotEconomyInfo));
    
    if (info1.money < info2.money) return -1;
    if (info1.money > info2.money) return 1;
    return 0;
}

/**
 * Verify no duplicate RECs in assignment result
 * 
 * @param result        Assignment result
 * @param iBotCount     Bot count
 * @return              true=all RECs unique, false=duplicates exist
 */
bool ValidateAssignmentUniqueness(KnapsackResult result, int iBotCount)
{
    ArrayList usedRecs = new ArrayList();
    
    for (int i = 0; i < iBotCount; i++)
    {
        int recIndex = result.assignment[i];
        
        if (recIndex < 0)
            continue;
        
        // Check if already used
        if (usedRecs.FindValue(recIndex) != -1)
        {
            delete usedRecs;
            return false;
        }
        
        usedRecs.Push(recIndex);
    }
    
    delete usedRecs;
    return true;
}

/**
 * Schedule dynamic pause for current round
 * 
 */
void ScheduleDynamicPause(int iRound)
{
    PrintToServer("[Pause System] ===== ScheduleDynamicPause CALLED =====");
    PrintToServer("[Pause System] Game round: %d (0-based)", iRound);
    PrintToServer("[Pause System] Demo round number: round%d", iRound + 1);
    PrintToServer("[Pause System] RecFolder: %s", g_bRecFolderSelected ? g_szCurrentRecFolder : "NONE");
    
    // Check if bot_pause plugin is loaded
    if (!g_bPausePluginLoaded)
    {
        PrintToServer("[Pause System] ✗ bot_pause plugin not loaded, pause disabled");
        return;
    }
    
    // Check if round is valid
    if (iRound < 0 || iRound >= 31)
    {
        PrintToServer("[Pause System] ✗ Invalid round: %d (must be 0-30)", iRound);
        return;
    }
    
    // Check if freeze time for this round is valid
    if (!g_bAllRoundFreezeTimeValid[iRound])
    {
        PrintToServer("[Pause System] ✗ Round %d has no valid freeze time", iRound);
        return;
    }
    
    // Get server freeze time
    ConVar cvFreezeTime = FindConVar("mp_freezetime");
    float fServerFreeze = 20.0;
    
    if (cvFreezeTime != null)
    {
        fServerFreeze = cvFreezeTime.FloatValue;
        PrintToServer("[Pause System] ✓ Server freeze time: %.2f seconds", fServerFreeze);
    }
    
    float fDemoFreeze = g_fAllRoundFreezeTimes[iRound];
    
    PrintToServer("[Pause System] ===== ANALYZING ROUND %d =====", iRound);
    PrintToServer("[Pause System] Server freeze: %.2f, Demo freeze: %.2f", fServerFreeze, fDemoFreeze);
    
    // If demo freeze time <= server freeze time, no pause needed
    if (fDemoFreeze <= fServerFreeze)
    {
        PrintToServer("[Pause System] ✓ No pause needed (demo <= server)");
        return;
    }
    
    // Calculate time difference
    float fTimeDiff = fDemoFreeze - fServerFreeze;
    PrintToServer("[Pause System] ⚠ Pause required! Time difference: %.2f seconds", fTimeDiff);
    
    // Decide pause strategy
    float fPauseDelay = 0.0;
    int iPauseTime = 0;
    
    float fMaxDelayedPause = fServerFreeze + 30.0;
    
    if (fTimeDiff > fMaxDelayedPause)
    {
        // Immediate long pause
        fPauseDelay = 0.0;
        iPauseTime = RoundToNearest(fTimeDiff);
        PrintToServer("[Pause System] Strategy: IMMEDIATE LONG PAUSE (%d seconds)", iPauseTime);
    }
    else if (fTimeDiff <= 30.0)
    {
        // Immediate short pause
        fPauseDelay = 0.0;
        iPauseTime = RoundToNearest(fTimeDiff);
        PrintToServer("[Pause System] Strategy: IMMEDIATE SHORT PAUSE (%d seconds)", iPauseTime);
    }
    else
    {
        // Delayed 30 second pause
        fPauseDelay = fTimeDiff - 30.0;
        iPauseTime = 30;
        PrintToServer("[Pause System] Strategy: DELAYED 30s PAUSE (delay: %.2f)", fPauseDelay);
    }
    
// Randomly select a team's bot to execute pause
    int iBotToUse = -1;
    int iTeamToUse = -1;
    
    // Get available pause counts for both teams
    int iPausesLeftT = BotPause_GetTeamPausesLeft(CS_TEAM_T);
    int iPausesLeftCT = BotPause_GetTeamPausesLeft(CS_TEAM_CT);
    
    PrintToServer("[Pause System] Pause availability: T=%d, CT=%d", iPausesLeftT, iPausesLeftCT);
    
    // Randomly select team (prefer teams with pause counts)
    if (iPausesLeftT > 0 && iPausesLeftCT > 0)
    {
        // Both teams have pause counts, randomly select
        iTeamToUse = GetRandomInt(0, 1) == 0 ? CS_TEAM_T : CS_TEAM_CT;
        PrintToServer("[Pause System] Both teams available, randomly selected: %s", 
            iTeamToUse == CS_TEAM_T ? "T" : "CT");
    }
    else if (iPausesLeftT > 0)
    {
        iTeamToUse = CS_TEAM_T;
        PrintToServer("[Pause System] Only T team has pauses left");
    }
    else if (iPausesLeftCT > 0)
    {
        iTeamToUse = CS_TEAM_CT;
        PrintToServer("[Pause System] Only CT team has pauses left");
    }
    else
    {
        PrintToServer("[Pause System] ✗ No team has pauses left");
        return;
    }
    
    // Find a bot in selected team
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsValidClient(i) || !IsFakeClient(i) || !IsPlayerAlive(i))
            continue;
        
        if (GetClientTeam(i) != iTeamToUse)
            continue;
        
        iBotToUse = i;
        break;
    }
    
    if (iBotToUse == -1)
    {
        PrintToServer("[Pause System] ✗ No bot available in team %s, trying other team", 
            iTeamToUse == CS_TEAM_T ? "T" : "CT");
        
        // Try other team
        int iOtherTeam = (iTeamToUse == CS_TEAM_T) ? CS_TEAM_CT : CS_TEAM_T;
        int iOtherPauses = BotPause_GetTeamPausesLeft(iOtherTeam);
        
        if (iOtherPauses > 0)
        {
            for (int i = 1; i <= MaxClients; i++)
            {
                if (!IsValidClient(i) || !IsFakeClient(i) || !IsPlayerAlive(i))
                    continue;
                
                if (GetClientTeam(i) != iOtherTeam)
                    continue;
                
                iBotToUse = i;
                iTeamToUse = iOtherTeam;
                PrintToServer("[Pause System] Found bot in other team: %s", 
                    iTeamToUse == CS_TEAM_T ? "T" : "CT");
                break;
            }
        }
        
        if (iBotToUse == -1)
        {
            PrintToServer("[Pause System] ✗ No bot available in any team");
            return;
        }
    }
    
    char szBotName[MAX_NAME_LENGTH];
    GetClientName(iBotToUse, szBotName, sizeof(szBotName));
    PrintToServer("[Pause System] Using bot: %s (client %d)", szBotName, iBotToUse);
    
    // Create timer for bot to execute pause
    DataPack pack = new DataPack();
    pack.WriteCell(GetClientUserId(iBotToUse));
    pack.WriteCell(iPauseTime);
    
    CreateTimer(fPauseDelay, Timer_BotExecutePause, pack, TIMER_FLAG_NO_MAPCHANGE);
    
    PrintToServer("[Pause System] ✓ Pause scheduled: delay=%.2f, duration=%d", fPauseDelay, iPauseTime);
    PrintToServer("[Pause System] ===== PAUSE SYSTEM ACTIVE =====");
}

/**
 * Bot execute pause timer
 */
public Action Timer_BotExecutePause(Handle hTimer, DataPack pack)
{
    pack.Reset();
    int iUserId = pack.ReadCell();
    int iPauseTime = pack.ReadCell();
    delete pack;
    
    int client = GetClientOfUserId(iUserId);
    
    if (!IsValidClient(client))
    {
        return Plugin_Stop;
    }
    
    char szBotName[MAX_NAME_LENGTH];
    GetClientName(client, szBotName, sizeof(szBotName));
    
    PrintToServer("[Pause System] ===== BOT EXECUTING PAUSE =====");
    PrintToServer("[Pause System] Bot: %s (client %d)", szBotName, client);
    PrintToServer("[Pause System] Pause time: %d seconds", iPauseTime);
    
    // Make bot send pause command (without parameter if default time)
    if (iPauseTime == 30)  // DEFAULT_PAUSE_TIME
    {
        FakeClientCommand(client, "say .p");
    }
    else
    {
        FakeClientCommand(client, "say .p %d", iPauseTime);
    }
    
    return Plugin_Stop;
}

// ============================================================================
// Weapon Data System
// ============================================================================

void InitWeaponData()
{
    g_hWeaponPrices = new StringMap();
    g_hWeaponConversion_T = new StringMap();
    g_hWeaponConversion_CT = new StringMap();
    g_hWeaponTypes = new StringMap();
    
    // Price data
    g_hWeaponPrices.SetValue("ak47", 2700);
    g_hWeaponPrices.SetValue("m4a1", 3100);
    g_hWeaponPrices.SetValue("m4a1_silencer", 2900);
    g_hWeaponPrices.SetValue("awp", 4750);
    g_hWeaponPrices.SetValue("famas", 2250);
    g_hWeaponPrices.SetValue("galilar", 2000);
    g_hWeaponPrices.SetValue("ssg08", 1700);
    g_hWeaponPrices.SetValue("aug", 3300);
    g_hWeaponPrices.SetValue("sg556", 3000);
    g_hWeaponPrices.SetValue("scar20", 5000);
    g_hWeaponPrices.SetValue("g3sg1", 5000);
    g_hWeaponPrices.SetValue("mp9", 1250);
    g_hWeaponPrices.SetValue("mac10", 1050);
    g_hWeaponPrices.SetValue("ump45", 1200);
    g_hWeaponPrices.SetValue("p90", 2350);
    g_hWeaponPrices.SetValue("bizon", 1400);
    g_hWeaponPrices.SetValue("mp7", 1500);
    g_hWeaponPrices.SetValue("nova", 1050);
    g_hWeaponPrices.SetValue("xm1014", 2000);
    g_hWeaponPrices.SetValue("mag7", 1300);
    g_hWeaponPrices.SetValue("sawedoff", 1100);
    g_hWeaponPrices.SetValue("m249", 5200);
    g_hWeaponPrices.SetValue("negev", 1700);
    g_hWeaponPrices.SetValue("deagle", 700);
    g_hWeaponPrices.SetValue("p250", 300);
    g_hWeaponPrices.SetValue("tec9", 500);
    g_hWeaponPrices.SetValue("fiveseven", 500);
    g_hWeaponPrices.SetValue("cz75a", 500);
    g_hWeaponPrices.SetValue("elite", 300);
    g_hWeaponPrices.SetValue("revolver", 600);
    g_hWeaponPrices.SetValue("smokegrenade", 300);
    g_hWeaponPrices.SetValue("flashbang", 200);
    g_hWeaponPrices.SetValue("hegrenade", 300);
    g_hWeaponPrices.SetValue("molotov", 400);
    g_hWeaponPrices.SetValue("incgrenade", 600);
    g_hWeaponPrices.SetValue("decoy", 50);
    g_hWeaponPrices.SetValue("vest", 650);
    g_hWeaponPrices.SetValue("vesthelm", 1000);
    g_hWeaponPrices.SetValue("defuser", 400);
    g_hWeaponPrices.SetValue("taser", 200);
    
    // T faction weapon conversion
    g_hWeaponConversion_T.SetString("m4a1", "ak47");
    g_hWeaponConversion_T.SetString("m4a1_silencer", "ak47");
    g_hWeaponConversion_T.SetString("famas", "galilar");
    g_hWeaponConversion_T.SetString("aug", "sg556");
    g_hWeaponConversion_T.SetString("mp9", "mac10");
    g_hWeaponConversion_T.SetString("fiveseven", "tec9");
    g_hWeaponConversion_T.SetString("usp_silencer", "glock");
    g_hWeaponConversion_T.SetString("hkp2000", "glock");
    g_hWeaponConversion_T.SetString("scar20", "g3sg1");
    g_hWeaponConversion_T.SetString("mag7", "sawedoff");
    g_hWeaponConversion_T.SetString("incgrenade", "molotov");
    
    // CT faction weapon conversion
    g_hWeaponConversion_CT.SetString("ak47", "m4a1");
    g_hWeaponConversion_CT.SetString("galilar", "famas");
    g_hWeaponConversion_CT.SetString("sg556", "aug");
    g_hWeaponConversion_CT.SetString("mac10", "mp9");
    g_hWeaponConversion_CT.SetString("tec9", "fiveseven");
    g_hWeaponConversion_CT.SetString("glock", "hkp2000");
    g_hWeaponConversion_CT.SetString("g3sg1", "scar20");
    g_hWeaponConversion_CT.SetString("sawedoff", "mag7");
    g_hWeaponConversion_CT.SetString("molotov", "incgrenade");
    
    // Weapon types (bit flags: 1=rifle, 2=sniper, 4=SMG, 8=utility, 16=default pistol)
    g_hWeaponTypes.SetValue("ak47", 1);
    g_hWeaponTypes.SetValue("m4a1", 1);
    g_hWeaponTypes.SetValue("m4a1_silencer", 1);
    g_hWeaponTypes.SetValue("aug", 1);
    g_hWeaponTypes.SetValue("sg556", 1);
    g_hWeaponTypes.SetValue("famas", 1);
    g_hWeaponTypes.SetValue("galilar", 1);
    
    g_hWeaponTypes.SetValue("awp", 2);
    g_hWeaponTypes.SetValue("ssg08", 2);
    g_hWeaponTypes.SetValue("scar20", 2);
    g_hWeaponTypes.SetValue("g3sg1", 2);
    
    g_hWeaponTypes.SetValue("mp9", 4);
    g_hWeaponTypes.SetValue("mac10", 4);
    g_hWeaponTypes.SetValue("ump45", 4);
    g_hWeaponTypes.SetValue("p90", 4);
    g_hWeaponTypes.SetValue("bizon", 4);
    g_hWeaponTypes.SetValue("mp7", 4);
    
    g_hWeaponTypes.SetValue("smokegrenade", 8);
    g_hWeaponTypes.SetValue("flashbang", 8);
    g_hWeaponTypes.SetValue("hegrenade", 8);
    g_hWeaponTypes.SetValue("molotov", 8);
    g_hWeaponTypes.SetValue("incgrenade", 8);
    g_hWeaponTypes.SetValue("decoy", 8);
    
    g_hWeaponTypes.SetValue("glock", 16);
    g_hWeaponTypes.SetValue("hkp2000", 16);
    g_hWeaponTypes.SetValue("usp_silencer", 16);
}

// Weapon type constant definitions
#define WEAPON_TYPE_RIFLE 1
#define WEAPON_TYPE_SNIPER 2
#define WEAPON_TYPE_SMG 4
#define WEAPON_TYPE_UTILITY 8
#define WEAPON_TYPE_DEFAULT_PISTOL 16

// Weapon type check functions
stock bool IsWeaponType(const char[] szItem, int typeFlag)
{
    int type;
    return g_hWeaponTypes.GetValue(szItem, type) && (type & typeFlag);
}

// Get weapon price
int GetItemPrice(const char[] szItem)
{
    int price;
    return g_hWeaponPrices.GetValue(szItem, price) ? price : 0;
}

// Get faction specific weapon
bool GetTeamSpecificWeapon(const char[] szWeapon, int iTeam, char[] szOutput, int iMaxLen)
{
    strcopy(szOutput, iMaxLen, szWeapon);
    
    StringMap map = (iTeam == CS_TEAM_T) ? g_hWeaponConversion_T : g_hWeaponConversion_CT;
    return map.GetString(szWeapon, szOutput, iMaxLen);
}

// Weapon type judgment functions
bool IsSniperWeapon(const char[] szItem)
{
    return IsWeaponType(szItem, WEAPON_TYPE_SNIPER);
}

bool IsRifleWeapon(const char[] szItem)
{
    return IsWeaponType(szItem, WEAPON_TYPE_RIFLE);
}

bool IsSMGWeapon(const char[] szItem)
{
    return IsWeaponType(szItem, WEAPON_TYPE_SMG);
}

bool IsUtilityItem(const char[] szItem)
{
    return IsWeaponType(szItem, WEAPON_TYPE_UTILITY);
}

bool IsDefaultPistol(const char[] szItem)
{
    return IsWeaponType(szItem, WEAPON_TYPE_DEFAULT_PISTOL);
}

// ============================================================================
// Debug Commands
// ============================================================================

public Action Command_DebugInfo(int client, int args)
{
    char szMap[64];
    GetCurrentMap(szMap, sizeof(szMap));
    GetMapDisplayName(szMap, szMap, sizeof(szMap));
    
    char szMapPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, szMapPath, sizeof(szMapPath), "data/botmimic/all/%s", szMap);
    
    ReplyToCommand(client, "[Bot REC] ===== DEBUG INFO =====");
    ReplyToCommand(client, "Map: %s", szMap);
    ReplyToCommand(client, "Map path exists: %s", DirExists(szMapPath) ? "YES" : "NO");
    ReplyToCommand(client, "Current round: %d", g_iCurrentRound);
    ReplyToCommand(client, "Round mode: %s", g_iRoundMode == Round_Economy ? "ECONOMY" : "FULL");
    ReplyToCommand(client, "Economy mode: %s", g_iEconomyMode == Economy_SingleTeam ? "SINGLE" : "BOTH");
    ReplyToCommand(client, "Rec folder: %s", g_bRecFolderSelected ? g_szCurrentRecFolder : "NONE");
    
    // List all demo folders
    if (DirExists(szMapPath))
    {
        ReplyToCommand(client, "\nDemo folders:");
        DirectoryListing hDir = OpenDirectory(szMapPath);
        if (hDir != null)
        {
            char szFolder[PLATFORM_MAX_PATH];
            FileType iFileType;
            int iCount = 0;
            
            while (hDir.GetNext(szFolder, sizeof(szFolder), iFileType))
            {
                if (iFileType == FileType_Directory && strcmp(szFolder, ".") != 0 && strcmp(szFolder, "..") != 0)
                {
                    ReplyToCommand(client, "  %d. %s", ++iCount, szFolder);
                }
            }
            delete hDir;
            
            if (iCount == 0)
                ReplyToCommand(client, "  (No demo folders found)");
        }
    }
    
    // Show all bot status
    ReplyToCommand(client, "\nBot status:");
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsValidClient(i) || !IsFakeClient(i))
            continue;
        
        char szName[MAX_NAME_LENGTH];
        GetClientName(i, szName, sizeof(szName));
        int iMoney = GetEntProp(i, Prop_Send, "m_iAccount");
        int iTeam = GetClientTeam(i);
        
        ReplyToCommand(client, "  %d. %s (Team=%d, $%d, Rec=%s)", 
            i, szName, iTeam, iMoney, 
            g_szAssignedRecName[i][0] != '\0' ? g_szAssignedRecName[i] : "NONE");
    }
    
    return Plugin_Handled;
}

// ============================================================================
// Shared Library Function Implementation
// ============================================================================

/**
 * Initialize shared Bot function library
 */
stock bool BotShared_Init()
{
    GameData hConf = new GameData("botstuff.games");
    if (hConf == null)
    {
        LogError("[Bot Shared] Failed to load botstuff.games gamedata");
        return false;
    }
    
    g_BotShared_EnemyVisibleOffset = hConf.GetOffset("CCSBot::m_isEnemyVisible");
    g_BotShared_EnemyOffset = hConf.GetOffset("CCSBot::m_enemy");
    
    delete hConf;
    
    if (g_BotShared_EnemyVisibleOffset == -1 || g_BotShared_EnemyOffset == -1)
    {
        LogError("[Bot Shared] Failed to get offsets");
        return false;
    }
    
    for (int i = 1; i <= MaxClients; i++)
    {
        g_BotShared_State[i] = BotState_Normal;
    }
    
    PrintToServer("[Bot Shared] Initialized successfully");
    return true;
}

/**
 * Check if client is valid
 */
stock bool BotShared_IsValidClient(int client)
{
    return (client > 0 && client <= MaxClients && 
            IsClientConnected(client) && 
            IsClientInGame(client));
}

/**
 * Get Bot's current enemy
 */
stock int BotShared_GetEnemy(int client)
{
    if (g_BotShared_EnemyOffset == -1)
        return -1;
    
    return GetEntDataEnt2(client, g_BotShared_EnemyOffset);
}

/**
 * Check if Bot can see enemy
 */
stock bool BotShared_CanSeeEnemy(int client)
{
    if (g_BotShared_EnemyVisibleOffset == -1)
        return false;
    
    int iEnemy = BotShared_GetEnemy(client);
    if (!BotShared_IsValidClient(iEnemy) || !IsPlayerAlive(iEnemy))
        return false;
    
    return !!GetEntData(client, g_BotShared_EnemyVisibleOffset);
}

/**
 * Get cached enemy (performance optimized version)
 */
stock int BotShared_GetCachedEnemy(int client)
{
    float fNow = GetGameTime();
    
    if (fNow - g_BotShared_EnemyCacheTime[client] < 0.1)
    {
        return g_BotShared_CachedEnemy[client];
    }
    
    g_BotShared_CachedEnemy[client] = BotShared_GetEnemy(client);
    g_BotShared_EnemyCacheTime[client] = fNow;
    
    return g_BotShared_CachedEnemy[client];
}

/**
 * Set Bot state
 */
stock void BotShared_SetBotState(int client, BotState state)
{
    if (client < 1 || client > MaxClients)
        return;
    
    g_BotShared_State[client] = state;
}

/**
 * Get Bot state
 */
stock BotState BotShared_GetBotState(int client)
{
    if (client < 1 || client > MaxClients)
        return BotState_Normal;
    
    return g_BotShared_State[client];
}

/**
 * Reset Bot state
 */
stock void BotShared_ResetBotState(int client)
{
    BotShared_SetBotState(client, BotState_Normal);
}

/**
 * Reset bomb state
 */
stock void BotShared_ResetBombState()
{
    // Reserved function
}

// ============================================================================
// C4 Holder System
// ============================================================================

/**
 * Load C4 holder data file
 */
bool LoadC4HolderDataFile(const char[] szRecFolder)
{
    char szMap[64];
    GetCurrentMap(szMap, sizeof(szMap));
    GetMapDisplayName(szMap, szMap, sizeof(szMap));
    
    char szPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, szPath, sizeof(szPath), 
        "data/botmimic/all/%s/%s/c4_holders.json", szMap, szRecFolder);
    
    if (!FileExists(szPath))
    {
        PrintToServer("[C4 Holder] File not found: %s", szPath);
        return false;
    }
    
    // Clean old data
    if (g_jC4HolderData != null)
        delete g_jC4HolderData;
    
    // Load JSON
    g_jC4HolderData = view_as<JSONArray>(JSONArray.FromFile(szPath));
    if (g_jC4HolderData == null)
    {
        PrintToServer("[C4 Holder] Failed to parse JSON");
        return false;
    }
    
    PrintToServer("[C4 Holder] Loaded C4 holder data from: %s (entries: %d)", 
        szPath, g_jC4HolderData.Length);
    return true;
}

/**
 * Get C4 holder name for specified round
 */
bool GetC4HolderForRound(int iRound, char[] szPlayerName, int iMaxLen)
{
    if (g_jC4HolderData == null)
        return false;
    
    // round1 corresponds to iRound=0, so search with +1
    int iTargetRound = iRound + 1;
    
    for (int i = 0; i < g_jC4HolderData.Length; i++)
    {
        JSONObject jEntry = view_as<JSONObject>(g_jC4HolderData.Get(i));
        
        int iRoundNum = jEntry.GetInt("round");
        
        if (iRoundNum == iTargetRound)
        {
            jEntry.GetString("player_name", szPlayerName, iMaxLen);
            delete jEntry;
            
            PrintToServer("[C4 Holder] Round %d holder: %s", iTargetRound, szPlayerName);
            return true;
        }
        
        delete jEntry;
    }
    
    return false;
}

/**
 * Assign C4 at freeze time start
 */
public Action Timer_AssignC4AtFreezeStart(Handle hTimer)
{
    char szHolderName[MAX_NAME_LENGTH];
    
    if (!GetC4HolderForRound(g_iCurrentRound, szHolderName, sizeof(szHolderName)))
    {
        PrintToServer("[C4 Holder] No C4 holder defined for round %d", g_iCurrentRound + 1);
        return Plugin_Stop;
    }
    
    PrintToServer("[C4 Holder] ===== FREEZE START C4 ASSIGNMENT =====");
    PrintToServer("[C4 Holder] Target holder: %s (Round %d)", szHolderName, g_iCurrentRound + 1);
    
    // Find target bot
    int iTargetBot = -1;
    
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsValidClient(i) || !IsFakeClient(i) || !IsPlayerAlive(i))
            continue;
        
        if (GetClientTeam(i) != CS_TEAM_T)
            continue;
        
        // Check if REC name matches
        if (g_szCurrentRecName[i][0] == '\0')
            continue;
        
        if (StrEqual(g_szCurrentRecName[i], szHolderName, false))
        {
            iTargetBot = i;
            break;
        }
    }
    
    if (iTargetBot == -1)
    {
        PrintToServer("[C4 Holder] ✗ Target bot '%s' not found", szHolderName);
        return Plugin_Stop;
    }
    
    char szTargetName[MAX_NAME_LENGTH];
    GetClientName(iTargetBot, szTargetName, sizeof(szTargetName));
    PrintToServer("[C4 Holder] Found target: %s (client %d)", szTargetName, iTargetBot);
    
    // Remove C4 from all other T faction bots
    int iRemovedCount = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsValidClient(i) || !IsPlayerAlive(i) || i == iTargetBot)
            continue;
        
        if (GetClientTeam(i) != CS_TEAM_T)
            continue;
        
        int iC4 = GetPlayerWeaponSlot(i, CS_SLOT_C4);
        if (IsValidEntity(iC4))
        {
            char szClass[64];
            GetEntityClassname(iC4, szClass, sizeof(szClass));
            
            if (StrEqual(szClass, "weapon_c4", false))
            {
                RemovePlayerItem(i, iC4);
                AcceptEntityInput(iC4, "Kill");
                
                char szBotName[MAX_NAME_LENGTH];
                GetClientName(i, szBotName, sizeof(szBotName));
                PrintToServer("[C4 Holder]   Removed C4 from %s", szBotName);
                iRemovedCount++;
            }
        }
    }
    
    // Check if target bot already has C4
    int iTargetC4 = GetPlayerWeaponSlot(iTargetBot, CS_SLOT_C4);
    if (IsValidEntity(iTargetC4))
    {
        PrintToServer("[C4 Holder] ✓ Target %s already has C4", szTargetName);
        PrintToServer("[C4 Holder] ===== ASSIGNMENT COMPLETE =====");
        return Plugin_Stop;
    }
    
    // Assign C4 to target bot
    int iNewC4 = GivePlayerItem(iTargetBot, "weapon_c4");
    
    if (IsValidEntity(iNewC4))
    {
        PrintToServer("[C4 Holder] ✓ Successfully gave C4 to %s", szTargetName);
        PrintToServer("[C4 Holder]   Removed: %d, Assigned: 1", iRemovedCount);
    }
    else
    {
        PrintToServer("[C4 Holder] ✗ Failed to give C4 to %s", szTargetName);
    }
    
    PrintToServer("[C4 Holder] ===== ASSIGNMENT COMPLETE =====");
    return Plugin_Stop;
}

public void OnLibraryAdded(const char[] name)
{
    if (StrEqual(name, "bot_pause"))
    {
        g_bPausePluginLoaded = true;
        PrintToServer("[Bot REC] bot_pause plugin detected");
    }
}

public void OnLibraryRemoved(const char[] name)
{
    if (StrEqual(name, "bot_pause"))
    {
        g_bPausePluginLoaded = false;
        PrintToServer("[Bot REC] bot_pause plugin unloaded");
    }
}