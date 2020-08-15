#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

#define PLAYER_INFO_LEN 344

int g_iSteamIDs[MAXPLAYERS+1] = {
	76561198060367310, 76561197960359452, 76561197986490720, 76561197984560929, 76561197960599047, 76561197987713664, 76561198004854956, 76561197983956651, 76561197962125374, 76561198131369187, 76561197960428292, 76561197982036918
};

public void OnClientSettingsChanged(int client)
{
	if (!IsFakeClient(client) || !g_iSteamIDs[client])
		return;

	int tableIdx = FindStringTable("userinfo");
		 
	if (tableIdx == INVALID_STRING_TABLE)
		return;
	 
	char userInfo[PLAYER_INFO_LEN];

	if (!GetStringTableData(tableIdx, client - 1, userInfo, PLAYER_INFO_LEN))
		return;
	
	userInfo[8] = g_iSteamIDs[client];
	
	if(GetRandomInt(1,100) <= 70)
	{
		userInfo[184] = GetRandomInt(1,500);
	}
	
	userInfo[316] = 0;
	
	bool lockTable1 = LockStringTables(false);
	SetStringTableData(tableIdx, client - 1, userInfo, PLAYER_INFO_LEN);
	LockStringTables(lockTable1);
}