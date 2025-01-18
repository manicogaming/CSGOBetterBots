#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>

#pragma semicolon 1
#pragma newdecls required

int g_iKills[MAXPLAYERS+1], g_iAssists[MAXPLAYERS+1], g_iDeaths[MAXPLAYERS+1];
int g_iKASTRounds[MAXPLAYERS+1];
bool g_bEnablePlugin;
Handle hDB;

public void OnPluginStart()
{	
	g_bEnablePlugin = FindConVar("game_mode").IntValue == 1 && FindConVar("game_type").IntValue == 0 ? true : false;
	
	if(!g_bEnablePlugin)
		return;
		
	char szBuffer[1024];

	if ((hDB = SQL_Connect("sql_matches", true, szBuffer, sizeof(szBuffer))) == null)
	{
		SetFailState(szBuffer);
	}

	Format(szBuffer, sizeof(szBuffer), "CREATE TABLE IF NOT EXISTS sql_matches_scoretotal (");
	Format(szBuffer, sizeof(szBuffer), "%s match_id bigint(20) unsigned NOT NULL AUTO_INCREMENT,", szBuffer);
	Format(szBuffer, sizeof(szBuffer), "%s timestamp timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,", szBuffer);
	Format(szBuffer, sizeof(szBuffer), "%s team_0 int(11) NOT NULL,", szBuffer);
	Format(szBuffer, sizeof(szBuffer), "%s team_1 int(11) NOT NULL,", szBuffer);
	Format(szBuffer, sizeof(szBuffer), "%s team_2 int(11) NOT NULL,", szBuffer);
	Format(szBuffer, sizeof(szBuffer), "%s team_2_name varchar(128) NOT NULL,", szBuffer);
	Format(szBuffer, sizeof(szBuffer), "%s team_3 int(11) NOT NULL,", szBuffer);
	Format(szBuffer, sizeof(szBuffer), "%s team_3_name varchar(128) NOT NULL,", szBuffer);
	Format(szBuffer, sizeof(szBuffer), "%s map varchar(128) NOT NULL,", szBuffer);
	Format(szBuffer, sizeof(szBuffer), "%s PRIMARY KEY (match_id),", szBuffer);
	Format(szBuffer, sizeof(szBuffer), "%s UNIQUE KEY match_id (match_id));", szBuffer);

	if (!SQL_FastQuery(hDB, szBuffer))
	{
		SQL_GetError(hDB, szBuffer, sizeof(szBuffer));
		SetFailState(szBuffer);
	}

	Format(szBuffer, sizeof(szBuffer), "CREATE TABLE IF NOT EXISTS sql_matches (");
	Format(szBuffer, sizeof(szBuffer), "%s match_id bigint(20) NOT NULL,", szBuffer);
	Format(szBuffer, sizeof(szBuffer), "%s name varchar(65) NOT NULL,", szBuffer);
	Format(szBuffer, sizeof(szBuffer), "%s team int(11) NOT NULL,", szBuffer);
	Format(szBuffer, sizeof(szBuffer), "%s kills int(11) NOT NULL,", szBuffer);
	Format(szBuffer, sizeof(szBuffer), "%s assists int(11) NOT NULL,", szBuffer);
	Format(szBuffer, sizeof(szBuffer), "%s deaths int(11) NOT NULL,", szBuffer);
	Format(szBuffer, sizeof(szBuffer), "%s 5k int(11) NOT NULL,", szBuffer);
	Format(szBuffer, sizeof(szBuffer), "%s 4k int(11) NOT NULL,", szBuffer);
	Format(szBuffer, sizeof(szBuffer), "%s 3k int(11) NOT NULL,", szBuffer);
	Format(szBuffer, sizeof(szBuffer), "%s damage int(11) NOT NULL,", szBuffer);
	Format(szBuffer, sizeof(szBuffer), "%s kastrounds int(11) NOT NULL);", szBuffer);

	if (!SQL_FastQuery(hDB, szBuffer))
	{
		SQL_GetError(hDB, szBuffer, sizeof(szBuffer));
		SetFailState(szBuffer);
	}
	
	HookEventEx("round_start", OnRoundStart);
	HookEventEx("cs_win_panel_match", OnWinPanelMatch);
}

public void OnClientPostAdminCheck(int client)
{
	if(!g_bEnablePlugin)
		return;
		
	g_iKASTRounds[client] = 0;
}

public void OnRoundStart(Event eEvent, char[] szName, bool bDontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			g_iKills[i] = GetClientFrags(i);
			g_iAssists[i] = CS_GetClientAssists(i);
			g_iDeaths[i] = GetClientDeaths(i);
		}
	}
}

public Action CS_OnTerminateRound(float& fDelay, CSRoundEndReason& pReason)
{
	if(!g_bEnablePlugin)
		return Plugin_Continue;
		
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			if(GetClientFrags(i) > g_iKills[i] || CS_GetClientAssists(i) > g_iAssists[i] || GetClientDeaths(i) == g_iDeaths[i])
			{
				g_iKASTRounds[i]++;
			}
		}
	}
	
	return Plugin_Continue;
}

public void OnWinPanelMatch(Event eEvent, char[] szName, bool bDontBroadcast)
{
	CreateTimer(0.1, Timer_Delay, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_Delay(Handle hTimer)
{
	if(GetPlayerTeamCount(CS_TEAM_CT) > 5 || GetPlayerTeamCount(CS_TEAM_T) > 5)
		return Plugin_Stop;

	Transaction hTransaction = SQL_CreateTransaction();

	char szMap[128];
	GetCurrentMap(szMap, sizeof(szMap));
	GetMapDisplayName(szMap, szMap, sizeof(szMap));

	char szBuffer[512];
	
	char szCTName[64];
	char szTName[64];
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

	GetEntPropString(iTeamIndex_T, Prop_Send, "m_szClanTeamname", szTName, 64);
	GetEntPropString(iTeamIndex_CT, Prop_Send, "m_szClanTeamname", szCTName, 64);

	Format(szBuffer, sizeof(szBuffer), "INSERT INTO sql_matches_scoretotal (team_0, team_1, team_2, team_2_name, team_3, team_3_name, map) VALUES (0, 0, 0, '%s', 0, '%s', '%s');", szTName, szCTName, szMap);
	SQL_AddQuery(hTransaction, szBuffer);

	Format(szBuffer, sizeof(szBuffer), "UPDATE sql_matches_scoretotal SET team_2 = %i, team_3 = %i WHERE match_id = LAST_INSERT_ID();", CS_GetTeamScore(CS_TEAM_T), CS_GetTeamScore(CS_TEAM_CT));
	SQL_AddQuery(hTransaction, szBuffer);

	char szName[MAX_NAME_LENGTH];

	int iTeam;
	int iKills;
	int iAssists;
	int iDeaths;
	int iMatchStats_5k_Total;
	int iMatchStats_4k_Total;
	int iMatchStats_3k_Total;
	int iMatchStats_Damage_Total;

	int iEnt = MaxClients+1;
	if ((iEnt = FindEntityByClassname(-1, "cs_player_manager")) != -1)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
			{
				continue;
			}

			iTeam = GetEntProp(iEnt, Prop_Send, "m_iTeam", _, i);
			
			if((iTeam == CS_TEAM_NONE) || (iTeam == CS_TEAM_SPECTATOR))
			{
				continue;
			}
			
			iKills = GetEntProp(iEnt, Prop_Send, "m_iKills", _, i);
			iAssists = GetEntProp(iEnt, Prop_Send, "m_iAssists", _, i);
			iDeaths = GetEntProp(iEnt, Prop_Send, "m_iDeaths", _, i);
			iMatchStats_5k_Total = GetEntProp(iEnt, Prop_Send, "m_iMatchStats_5k_Total", _, i);
			iMatchStats_4k_Total = GetEntProp(iEnt, Prop_Send, "m_iMatchStats_4k_Total", _, i);
			iMatchStats_3k_Total = GetEntProp(iEnt, Prop_Send, "m_iMatchStats_3k_Total", _, i);
			iMatchStats_Damage_Total = GetEntProp(iEnt, Prop_Send, "m_iMatchStats_Damage_Total", _, i);
			
			Format(szName, MAX_NAME_LENGTH, "%N", i);
			SQL_EscapeString(hDB, szName, szName, sizeof(szName));

			Format(szBuffer, sizeof(szBuffer), "INSERT INTO sql_matches");
			Format(szBuffer, sizeof(szBuffer), "%s (match_id, team, name, kills, assists, deaths, 5k, 4k, 3k, damage, kastrounds)", szBuffer);
			Format(szBuffer, sizeof(szBuffer), "%s VALUES (LAST_INSERT_ID(), '%i', '%s', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i');", szBuffer, iTeam, szName, iKills, iAssists, iDeaths, iMatchStats_5k_Total, iMatchStats_4k_Total, iMatchStats_3k_Total, iMatchStats_Damage_Total, g_iKASTRounds[i]);
			SQL_AddQuery(hTransaction, szBuffer);
		}
	}

	SQL_ExecuteTransaction(hDB, hTransaction);
	return Plugin_Stop;
}

public void onSuccess(Database hDatabase, any data, int iNumQueries, Handle[] hResults, any[] bufferData)
{
	PrintToServer("onSuccess");
}

public void onError(Database hDatabase, any data, int iNumQueries, const char[] szError, int iFailIndex, any[] queryData)
{
	PrintToServer("onError");
}

stock int GetPlayerTeamCount(int iTeam)
{
	int iNumber = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && GetClientTeam(i) == iTeam)
			iNumber++;
	}
	return iNumber;
}

stock bool IsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client);
}