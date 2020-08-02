#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

#define PLAYER_INFO_LEN 344

int g_iSteamIDs[MAXPLAYERS+1] = {
	76561198060367310, 76561197960359452, 76561197986490720, 76561197984560929, 76561197960599047, 76561197987713664, 76561198004854956, 76561197983956651, 76561197962125374, 76561198131369187, 76561197960428292, 76561197982036918
};

public void OnMapStart()
{
	CreateTimer(5.0, Timer_CheckPlayer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_CheckPlayer(Handle hTimer, any data)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsFakeClient(i))
		{
			int tableIdx = FindStringTable("userinfo");
		 
			if (tableIdx == INVALID_STRING_TABLE)
				return;
			 
			char userInfo[PLAYER_INFO_LEN];

			if (!GetStringTableData(tableIdx, i - 1, userInfo, PLAYER_INFO_LEN))
				return;

			userInfo[8] = g_iSteamIDs[i];
			
			if(GetRandomInt(1,2) == 1)
			{
				bool lockTable = LockStringTables(false);
				SetStringTableData(tableIdx, i - 1, userInfo, 256);
				LockStringTables(lockTable);
			}
			else
			{
				bool lockTable = LockStringTables(false);
				SetStringTableData(tableIdx, i - 1, userInfo, PLAYER_INFO_LEN);
				LockStringTables(lockTable);
			}
		}
	}	
}

stock bool IsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client);
}
