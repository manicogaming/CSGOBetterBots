#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <smlib>
#include <SteamIDConverter>

#define PLAYER_INFO_LEN 344
#define MAX_COMMUNITYID_LENGTH 18

enum
{
	PlayerInfo_Version = 0,             // int64
	PlayerInfo_XUID = 8,                // int64
	PlayerInfo_Name = 16,               // char[128]
	PlayerInfo_UserID = 144,            // int
	PlayerInfo_SteamID = 148,           // char[33]
	PlayerInfo_AccountID = 184,         // int
	PlayerInfo_FriendsName = 188,       // char[128]
	PlayerInfo_IsFakePlayer = 316,      // bool
	PlayerInfo_IsHLTV = 317,            // bool
	PlayerInfo_CustomFile1 = 320,       // int
	PlayerInfo_CustomFile2 = 324,       // int
	PlayerInfo_CustomFile3 = 328,       // int
	PlayerInfo_CustomFile4 = 332,       // int
	PlayerInfo_FilesDownloaded = 336    // char
};

int g_iAccountID[MAXPLAYERS+1];
char g_szSteamID64[MAXPLAYERS+1][MAX_COMMUNITYID_LENGTH]; 

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int errMax)
{
	CreateNative("GetBotAccountID", Native_GetBotAccountID);
	CreateNative("GetBotSteamID64", Native_GetBotSteamID64);
}

public int Native_GetBotAccountID(Handle plugins, int numParams)
{
	int client = GetNativeCell(1);
	if (!client || !IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index [%i]", client);
		return -1;
	}

	return g_iAccountID[client];
}

public int Native_GetBotSteamID64(Handle plugins, int numParams)
{
	int client = GetNativeCell(1);
	if (!client || !IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index [%i]", client);
		return -1;
	}
	
	return SetNativeString(2, g_szSteamID64[client], GetNativeCell(3)) == SP_ERROR_NONE;
}

public void OnClientSettingsChanged(int client)
{
	if (!IsFakeClient(client))
	return;

	int iTableIdx = FindStringTable("userinfo");

	if (iTableIdx == INVALID_STRING_TABLE)
	return;

	char szUserInfo[PLAYER_INFO_LEN];

	if (!GetStringTableData(iTableIdx, client - 1, szUserInfo, PLAYER_INFO_LEN))
	return;

	int iAccountID;

	char szBotName[MAX_NAME_LENGTH];
	GetClientName(client, szBotName, sizeof(szBotName));

	if(!GetAccountID(szBotName, iAccountID))
	{
		iAccountID = Math_GetRandomInt(3, 2147483647);
	}

	int iSteamIdHigh = 16781313;

	szUserInfo[PlayerInfo_XUID] = iSteamIdHigh;
	szUserInfo[PlayerInfo_XUID + 1] = iSteamIdHigh >> 8;
	szUserInfo[PlayerInfo_XUID + 2] = iSteamIdHigh >> 16;
	szUserInfo[PlayerInfo_XUID + 3] = iSteamIdHigh >> 24;

	szUserInfo[PlayerInfo_XUID + 7] = iAccountID;
	szUserInfo[PlayerInfo_XUID + 6] = iAccountID >> 8;
	szUserInfo[PlayerInfo_XUID + 5] = iAccountID >> 16;
	szUserInfo[PlayerInfo_XUID + 4] = iAccountID >> 24;

	char szSteamID3[32], szSteamID32[32];
	Format(szSteamID3, sizeof(szSteamID3), "[U:1:%i]", iAccountID);
	SteamIDConverter(szSteamID3, szSteamID32, sizeof(szSteamID32), STEAM32);
	Format(szUserInfo[PlayerInfo_SteamID], 32, szSteamID32);
	SteamIDConverter(szSteamID3, g_szSteamID64[client], MAX_COMMUNITYID_LENGTH, STEAM64);

	szUserInfo[PlayerInfo_AccountID] = iAccountID;
	szUserInfo[PlayerInfo_AccountID + 1] = iAccountID >> 8;
	szUserInfo[PlayerInfo_AccountID + 2] = iAccountID >> 16;
	szUserInfo[PlayerInfo_AccountID + 3] = iAccountID >> 24;

	szUserInfo[PlayerInfo_IsFakePlayer] = 0;

	bool lockTable = LockStringTables(false);
	SetStringTableData(iTableIdx, client - 1, szUserInfo, PLAYER_INFO_LEN);
	LockStringTables(lockTable);

	g_iAccountID[client] = iAccountID;
}

bool GetAccountID(const char[] szName, int &iAccountID)
{
	char szPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, szPath, sizeof(szPath), "configs/bot_steamids.txt");
	
	if (!FileExists(szPath))
	{
		PrintToServer("Configuration file %s is not found.", szPath);
		return false;
	}
	
	KeyValues kv = new KeyValues("Names");
	
	if (!kv.ImportFromFile(szPath))
	{
		delete kv;
		PrintToServer("Unable to parse Key Values file %s.", szPath);
		return false;
	}
	
	iAccountID = kv.GetNum(szName);
	
	if(iAccountID == 0)
	{
		delete kv;
		return false;
	}
	
	delete kv;
	
	return true;
}