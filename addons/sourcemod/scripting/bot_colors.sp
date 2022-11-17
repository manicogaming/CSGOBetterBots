#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#include <dhooks>

int g_iPlayerColor[MAXPLAYERS + 1], g_iPlayerColorOffset;

public void OnMapStart()
{
	HookEventEx("player_spawn", OnPlayerSpawn);
	g_iPlayerColorOffset = FindSendPropInfo("CCSPlayerResource", "m_iCompTeammateColor");
	SDKHook(FindEntityByClassname(MaxClients + 1, "cs_player_manager"), SDKHook_ThinkPost, OnThinkPost);
}

public void OnThinkPost(int iEnt)
{
	SetEntDataArray(iEnt, g_iPlayerColorOffset, g_iPlayerColor, MAXPLAYERS + 1);
}

public void OnPlayerSpawn(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(eEvent.GetInt("userid"));
	
	SetPlayerTeammateColor(client);
}

stock void SetPlayerTeammateColor(int client)
{
	if(GetClientTeam(client) > CS_TEAM_SPECTATOR)
	{
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

stock bool IsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client);
}