#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>

#pragma semicolon 1
#pragma newdecls required

#define TRADE_WINDOW 5.0 // Seconds within which a kill counts as a trade

int g_iDeaths[MAXPLAYERS+1];           // Deaths snapshot at round start (for survival check)
int g_iKASTRounds[MAXPLAYERS+1];       // Total KAST rounds accumulated per player
bool g_bKASTRound[MAXPLAYERS+1];       // Whether this player has KAST credit this round
float g_fDeathTime[MAXPLAYERS+1];      // When this player died this round
int g_iKilledBy[MAXPLAYERS+1];         // Who killed this player this round
bool g_bEnablePlugin;
Handle g_hDatabase;

public void OnPluginStart()
{	
	CheckGameMode();
	
	if (!g_bEnablePlugin)
		return;
		
	ConnectDatabase();
	
	HookEventEx("round_start", OnRoundStart);
	HookEventEx("player_death", OnPlayerDeath);
	HookEventEx("cs_win_panel_match", OnWinPanelMatch);
}

/**
 * Re-check game mode on each map start.
 * Handles cases where game_mode/game_type change between maps.
 */
public void OnMapStart()
{
	CheckGameMode();
}

void CheckGameMode()
{
	g_bEnablePlugin = FindConVar("game_mode").IntValue == 1 && FindConVar("game_type").IntValue == 0;
}

void ConnectDatabase()
{
	char szBuffer[1024];

	if ((g_hDatabase = SQL_Connect("sql_matches", true, szBuffer, sizeof(szBuffer))) == null)
	{
		SetFailState("[SQLMatch] Database connection failed: %s", szBuffer);
	}

	// Create scoretotal table
	Format(szBuffer, sizeof(szBuffer), "%s%s%s%s%s%s%s%s%s%s%s",
		"CREATE TABLE IF NOT EXISTS sql_matches_scoretotal (",
		" match_id bigint(20) unsigned NOT NULL AUTO_INCREMENT,",
		" timestamp timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,",
		" team_0 int(11) NOT NULL,",
		" team_1 int(11) NOT NULL,",
		" team_2 int(11) NOT NULL,",
		" team_2_name varchar(128) NOT NULL,",
		" team_3 int(11) NOT NULL,",
		" team_3_name varchar(128) NOT NULL,",
		" map varchar(128) NOT NULL,",
		" PRIMARY KEY (match_id), UNIQUE KEY match_id (match_id));"
	);

	if (!SQL_FastQuery(g_hDatabase, szBuffer))
	{
		SQL_GetError(g_hDatabase, szBuffer, sizeof(szBuffer));
		SetFailState("[SQLMatch] Failed to create scoretotal table: %s", szBuffer);
	}

	// Create matches table with index on match_id for join performance
	Format(szBuffer, sizeof(szBuffer), "%s%s%s%s%s%s%s%s%s%s%s%s",
		"CREATE TABLE IF NOT EXISTS sql_matches (",
		" match_id bigint(20) NOT NULL,",
		" name varchar(65) NOT NULL,",
		" team int(11) NOT NULL,",
		" kills int(11) NOT NULL,",
		" assists int(11) NOT NULL,",
		" deaths int(11) NOT NULL,",
		" `5k` int(11) NOT NULL,",
		" `4k` int(11) NOT NULL,",
		" `3k` int(11) NOT NULL,",
		" damage int(11) NOT NULL,",
		" kastrounds int(11) NOT NULL, INDEX idx_match_id (match_id), INDEX idx_match_name (match_id, name));"
	);

	if (!SQL_FastQuery(g_hDatabase, szBuffer))
	{
		SQL_GetError(g_hDatabase, szBuffer, sizeof(szBuffer));
		SetFailState("[SQLMatch] Failed to create matches table: %s", szBuffer);
	}
}

public void OnClientPostAdminCheck(int iClient)
{
	if (!g_bEnablePlugin)
		return;
		
	g_iKASTRounds[iClient] = 0;
	g_iDeaths[iClient] = 0;
	g_bKASTRound[iClient] = false;
	g_fDeathTime[iClient] = 0.0;
	g_iKilledBy[iClient] = 0;
}

public void OnRoundStart(Event hEvent, char[] szName, bool bDontBroadcast)
{
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (IsClientInGame(iClient))
		{
			g_iDeaths[iClient] = GetClientDeaths(iClient);
		}
		// Reset per-round KAST tracking
		g_bKASTRound[iClient] = false;
		g_fDeathTime[iClient] = 0.0;
		g_iKilledBy[iClient] = 0;
	}
}

/**
 * Track kills, assists, and trades for KAST calculation.
 */
public void OnPlayerDeath(Event hEvent, char[] szName, bool bDontBroadcast)
{
	if (!g_bEnablePlugin)
		return;

	int iVictim = GetClientOfUserId(hEvent.GetInt("userid"));
	int iAttacker = GetClientOfUserId(hEvent.GetInt("attacker"));
	int iAssister = GetClientOfUserId(hEvent.GetInt("assister"));

	// K - Attacker got a kill
	if (iAttacker > 0 && iAttacker <= MaxClients && IsClientInGame(iAttacker) && iAttacker != iVictim)
	{
		g_bKASTRound[iAttacker] = true;

		// T - Check if this kill trades a teammate.
		// If the victim had recently killed a teammate of the attacker, that teammate was traded.
		int iAttackerTeam = GetClientTeam(iAttacker);
		for (int iClient = 1; iClient <= MaxClients; iClient++)
		{
			if (iClient == iAttacker || !IsClientInGame(iClient) || GetClientTeam(iClient) != iAttackerTeam)
				continue;

			if (g_iKilledBy[iClient] == iVictim && (GetGameTime() - g_fDeathTime[iClient]) <= TRADE_WINDOW)
			{
				g_bKASTRound[iClient] = true; // Teammate was traded
			}
		}
	}

	// A - Assister
	if (iAssister > 0 && iAssister <= MaxClients && IsClientInGame(iAssister))
	{
		g_bKASTRound[iAssister] = true;
	}

	// Record death info for trade tracking
	if (iVictim > 0 && iVictim <= MaxClients && IsClientInGame(iVictim))
	{
		g_fDeathTime[iVictim] = GetGameTime();
		g_iKilledBy[iVictim] = iAttacker;
	}
}

/**
 * On round end: check survival and count KAST.
 */
public Action CS_OnTerminateRound(float& fDelay, CSRoundEndReason& eReason)
{
	if (!g_bEnablePlugin)
		return Plugin_Continue;
		
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (!IsClientInGame(iClient))
			continue;

		// S - Survived the round (deaths didn't increase)
		if (GetClientDeaths(iClient) == g_iDeaths[iClient])
		{
			g_bKASTRound[iClient] = true;
		}

		if (g_bKASTRound[iClient])
		{
			g_iKASTRounds[iClient]++;
		}
	}
	
	return Plugin_Continue;
}

public void OnWinPanelMatch(Event hEvent, char[] szName, bool bDontBroadcast)
{
	CreateTimer(0.1, Timer_Delay, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_Delay(Handle hTimer)
{
	int iCTCount = GetPlayerTeamCount(CS_TEAM_CT);
	int iTCount = GetPlayerTeamCount(CS_TEAM_T);

	if (iCTCount > 5 || iTCount > 5)
	{
		LogMessage("[SQLMatch] Match skipped: CT=%d T=%d (>5 per team)", iCTCount, iTCount);
		return Plugin_Stop;
	}

	Transaction hTransaction = SQL_CreateTransaction();

	char szMap[128];
	GetCurrentMap(szMap, sizeof(szMap));
	GetMapDisplayName(szMap, szMap, sizeof(szMap));

	char szBuffer[512];
	
	char szCTName[128];
	char szTName[128];
	int iTeamIndex_T = -1, iTeamIndex_CT = -1;

	int iIndex = -1;
	while ((iIndex = FindEntityByClassname(iIndex, "cs_team_manager")) != -1) 
	{
		int iTeamNum = GetEntProp(iIndex, Prop_Send, "m_iTeamNum");
		if (iTeamNum == CS_TEAM_T)
			iTeamIndex_T = iIndex;
		else if (iTeamNum == CS_TEAM_CT)
			iTeamIndex_CT = iIndex;
	}

	// Guard against missing team manager entities
	if (iTeamIndex_T == -1 || iTeamIndex_CT == -1)
	{
		LogError("[SQLMatch] Could not find cs_team_manager entities (T=%d CT=%d)", iTeamIndex_T, iTeamIndex_CT);
		return Plugin_Stop;
	}

	GetEntPropString(iTeamIndex_T, Prop_Send, "m_szClanTeamname", szTName, sizeof(szTName));
	GetEntPropString(iTeamIndex_CT, Prop_Send, "m_szClanTeamname", szCTName, sizeof(szCTName));

	// Escape team names and map name to prevent SQL injection
	char szTNameEsc[256];
	char szCTNameEsc[256];
	char szMapEsc[256];
	SQL_EscapeString(g_hDatabase, szTName, szTNameEsc, sizeof(szTNameEsc));
	SQL_EscapeString(g_hDatabase, szCTName, szCTNameEsc, sizeof(szCTNameEsc));
	SQL_EscapeString(g_hDatabase, szMap, szMapEsc, sizeof(szMapEsc));

	Format(szBuffer, sizeof(szBuffer), "INSERT INTO sql_matches_scoretotal (team_0, team_1, team_2, team_2_name, team_3, team_3_name, map) VALUES (0, 0, 0, '%s', 0, '%s', '%s');", szTNameEsc, szCTNameEsc, szMapEsc);
	SQL_AddQuery(hTransaction, szBuffer);

	Format(szBuffer, sizeof(szBuffer), "UPDATE sql_matches_scoretotal SET team_2 = %i, team_3 = %i WHERE match_id = LAST_INSERT_ID();", CS_GetTeamScore(CS_TEAM_T), CS_GetTeamScore(CS_TEAM_CT));
	SQL_AddQuery(hTransaction, szBuffer);

	char szPlayerName[MAX_NAME_LENGTH];

	int iTeam;
	int iKills;
	int iAssists;
	int iPlayerDeaths;
	int iMatchStats_5k_Total;
	int iMatchStats_4k_Total;
	int iMatchStats_3k_Total;
	int iMatchStats_Damage_Total;

	int iEnt;
	if ((iEnt = FindEntityByClassname(-1, "cs_player_manager")) == -1)
	{
		LogError("[SQLMatch] Could not find cs_player_manager entity. Player stats will not be recorded for this match.");
		// Still execute the transaction to save the scoretotal row
		SQL_ExecuteTransaction(g_hDatabase, hTransaction, OnTransactionSuccess, OnTransactionError);
		return Plugin_Stop;
	}

	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (!IsClientInGame(iClient))
			continue;

		iTeam = GetEntProp(iEnt, Prop_Send, "m_iTeam", _, iClient);
		
		if ((iTeam == CS_TEAM_NONE) || (iTeam == CS_TEAM_SPECTATOR))
			continue;
		
		iKills = GetEntProp(iEnt, Prop_Send, "m_iKills", _, iClient);
		iAssists = GetEntProp(iEnt, Prop_Send, "m_iAssists", _, iClient);
		iPlayerDeaths = GetEntProp(iEnt, Prop_Send, "m_iDeaths", _, iClient);
		iMatchStats_5k_Total = GetEntProp(iEnt, Prop_Send, "m_iMatchStats_5k_Total", _, iClient);
		iMatchStats_4k_Total = GetEntProp(iEnt, Prop_Send, "m_iMatchStats_4k_Total", _, iClient);
		iMatchStats_3k_Total = GetEntProp(iEnt, Prop_Send, "m_iMatchStats_3k_Total", _, iClient);
		iMatchStats_Damage_Total = GetEntProp(iEnt, Prop_Send, "m_iMatchStats_Damage_Total", _, iClient);
		
		Format(szPlayerName, MAX_NAME_LENGTH, "%N", iClient);
		SQL_EscapeString(g_hDatabase, szPlayerName, szPlayerName, sizeof(szPlayerName));

		Format(szBuffer, sizeof(szBuffer),
			"INSERT INTO sql_matches (match_id, team, name, kills, assists, deaths, `5k`, `4k`, `3k`, damage, kastrounds) VALUES (LAST_INSERT_ID(), %i, '%s', %i, %i, %i, %i, %i, %i, %i, %i);",
			iTeam, szPlayerName, iKills, iAssists, iPlayerDeaths, iMatchStats_5k_Total, iMatchStats_4k_Total, iMatchStats_3k_Total, iMatchStats_Damage_Total, g_iKASTRounds[iClient]);
		SQL_AddQuery(hTransaction, szBuffer);
	}

	SQL_ExecuteTransaction(g_hDatabase, hTransaction, OnTransactionSuccess, OnTransactionError);
	return Plugin_Stop;
}

public void OnTransactionSuccess(Database hDatabase, any aData, int iNumQueries, Handle[] hResults, any[] aBufferData)
{
	LogMessage("[SQLMatch] Match saved successfully (%d queries)", iNumQueries);
}

public void OnTransactionError(Database hDatabase, any aData, int iNumQueries, const char[] szError, int iFailIndex, any[] aQueryData)
{
	LogError("[SQLMatch] Transaction failed at query %d/%d: %s", iFailIndex, iNumQueries, szError);
}

stock int GetPlayerTeamCount(int iTeam)
{
	int iCount = 0;
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (IsValidClient(iClient) && GetClientTeam(iClient) == iTeam)
			iCount++;
	}
	return iCount;
}

stock bool IsValidClient(int iClient)
{
	return iClient > 0 && iClient <= MaxClients && IsClientConnected(iClient) && IsClientInGame(iClient) && !IsClientSourceTV(iClient);
}
