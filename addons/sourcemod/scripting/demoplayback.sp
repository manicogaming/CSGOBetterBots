#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#include <smlib>
#include <eItems>

char g_szMap[128];
bool g_bStartedPlaying[MAXPLAYERS+1];
int g_iCurrentTick[MAXPLAYERS+1], g_iSnapshotTick[MAXPLAYERS+1];
int g_iMaxTick;

char g_szWeapon[65535][64];
char g_szPinPulled[65535][64];
char g_szWeapon_1[65535][64];
char g_szWeapon_2[65535][64];
char g_szWeapon_3[65535][64];
char g_szWeapon_4[65535][64];
char g_szWeapon_5[65535][64];
char g_szWeapon_6[65535][64];
char g_szIsDucked[65535][64];
char g_szIsDucking[65535][64];
char g_szIsWalking[65535][64];

int g_iCurDefIndex[65535];
int g_iHasJumped[65535];
int g_iHasZoomed[65535];
int g_iHasFired[65535];
int g_iIsReloading[65535];
int g_iThrowStrength[65535];

float g_fPosition[65535][3];
float g_fAngles[65535][3];
float g_fVelocity[65535][3];
float g_flNextCommand[MAXPLAYERS+1];

Handle g_hSwitchWeaponCall = null;
Handle g_hSetOrigin = null;
Handle g_hSetAngles = null;
Handle g_hSetVelocity = null;

public void OnPluginStart()
{
	HookEventEx("round_start", OnRoundStart);

	RegConsoleCmd("sm_startplayback", Command_StartPlayback);
	
	Handle hGameData = LoadGameConfigFile("botmimic.games");
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Virtual, "Weapon_Switch");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer, VDECODE_FLAG_ALLOWNULL);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	if ((g_hSwitchWeaponCall = EndPrepSDKCall()) == INVALID_HANDLE)SetFailState("Failed to create SDKCall for Weapon_Switch offset!");
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CBaseEntity::SetLocalOrigin");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	if ((g_hSetOrigin = EndPrepSDKCall()) == INVALID_HANDLE)SetFailState("Failed to create SDKCall for CBaseEntity::SetLocalOrigin signature!");
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CBaseEntity::SetLocalAngles");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	if ((g_hSetAngles = EndPrepSDKCall()) == INVALID_HANDLE)SetFailState("Failed to create SDKCall for CBaseEntity::SetLocalAngles signature!");
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CBaseEntity::SetAbsVelocity");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	if ((g_hSetVelocity = EndPrepSDKCall()) == INVALID_HANDLE)SetFailState("Failed to create SDKCall for CBaseEntity::SetAbsVelocity signature!");
	delete hGameData;
}

public Action Command_StartPlayback(int client, int iArgs)
{
	g_bStartedPlaying[client] = true;
	g_iSnapshotTick[client] = 0;
	Client_RemoveAllWeapons(client);
	ServerCommand("sv_spawn_afk_bomb_drop_time 9999");
	
	return Plugin_Handled;
}

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int errMax)
{
	CreateNative("Demo_GetPosition", Native_GetPosition);
	CreateNative("Demo_GetVelocity", Native_GetVelocity);
	CreateNative("Demo_GetTick", Native_GetTick);
	CreateNative("Demo_IsPlaying", Native_IsPlaying);
	
	RegPluginLibrary("demoplayback");
	
	return APLRes_Success;
}

public int Native_GetPosition(Handle plugins, int numParams)
{
	int client = GetNativeCell(1);
	if (!client || !IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index [%i]", client);
		return -1;
	}

	return SetNativeArray(3, g_fPosition[GetNativeCell(2)], 3) == SP_ERROR_NONE;
}

public int Native_GetVelocity(Handle plugins, int numParams)
{
	int client = GetNativeCell(1);
	if (!client || !IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index [%i]", client);
		return -1;
	}
	
	return SetNativeArray(3, g_fVelocity[GetNativeCell(2)], 3) == SP_ERROR_NONE;
}

public int Native_GetTick(Handle plugins, int numParams)
{
	int client = GetNativeCell(1);
	if (!client || !IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index [%i]", client);
		return -1;
	}
	
	return g_iCurrentTick[client];
}

public any Native_IsPlaying(Handle plugins, int numParams)
{
	int client = GetNativeCell(1);
	if (!client || !IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index [%i]", client);
		return -1;
	}
	
	return g_bStartedPlaying[client];
}

public void OnMapStart()
{
	GetCurrentMap(g_szMap, sizeof(g_szMap));
	
	ParseTicks();
}

public void OnClientPostAdminCheck(int client)
{
	g_bStartedPlaying[client] = false;
	g_flNextCommand[client] = 0.0;
}

public void OnRoundStart(Event eEvent, char[] szName, bool bDontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && !IsFakeClient(i) && IsPlayerAlive(i))
		{
			g_bStartedPlaying[i] = false;
			g_iCurrentTick[i] = 0;
		}
	}
}

public Action OnPlayerRunCmd(int client, int &iButtons, int &iImpulse, float fVel[3], float fAngles[3], int &iWeapon, int &iSubtype, int &iCmdNum, int &iTickCount, int &iSeed, int iMouse[2])
{
	if (IsValidClient(client) && IsPlayerAlive(client) && !IsFakeClient(client) && g_bStartedPlaying[client] && g_iCurrentTick[client] <= g_iMaxTick)
	{
		char szUseWeapon[128];
	
		int iNewWeapon;
		int iKnifeSlot = GetPlayerWeaponSlot(client, CS_SLOT_KNIFE);
	
		if(iKnifeSlot == -1)
			GivePlayerItem(client, "weapon_knife");
		
		if(strcmp(g_szWeapon_1[g_iCurrentTick[client]], "NULL") != 0 && eItems_FindWeaponByClassName(client, g_szWeapon_1[g_iCurrentTick[client]]) == -1)
		{
			iNewWeapon = GivePlayerItem(client, g_szWeapon_1[g_iCurrentTick[client]]);
			if(StrContains(g_szWeapon_1[g_iCurrentTick[client]], "grenade") == -1 
			&& StrContains(g_szWeapon_1[g_iCurrentTick[client]], "flashbang") == -1 
			&& StrContains(g_szWeapon_1[g_iCurrentTick[client]], "decoy") == -1 
			&& StrContains(g_szWeapon_1[g_iCurrentTick[client]], "molotov") == -1)
				EquipPlayerWeapon(client, iNewWeapon);
		}
		
		if(strcmp(g_szWeapon_2[g_iCurrentTick[client]], "NULL") != 0 && eItems_FindWeaponByClassName(client, g_szWeapon_2[g_iCurrentTick[client]]) == -1)
		{
			iNewWeapon = GivePlayerItem(client, g_szWeapon_2[g_iCurrentTick[client]]);
			if(StrContains(g_szWeapon_2[g_iCurrentTick[client]], "grenade") == -1 
			&& StrContains(g_szWeapon_2[g_iCurrentTick[client]], "flashbang") == -1 
			&& StrContains(g_szWeapon_2[g_iCurrentTick[client]], "decoy") == -1 
			&& StrContains(g_szWeapon_2[g_iCurrentTick[client]], "molotov") == -1)
				EquipPlayerWeapon(client, iNewWeapon);
		}
		
		if(strcmp(g_szWeapon_3[g_iCurrentTick[client]], "NULL") != 0 && eItems_FindWeaponByClassName(client, g_szWeapon_3[g_iCurrentTick[client]]) == -1)
		{
			iNewWeapon = GivePlayerItem(client, g_szWeapon_3[g_iCurrentTick[client]]);
			if(StrContains(g_szWeapon_3[g_iCurrentTick[client]], "grenade") == -1 
			&& StrContains(g_szWeapon_3[g_iCurrentTick[client]], "flashbang") == -1 
			&& StrContains(g_szWeapon_3[g_iCurrentTick[client]], "decoy") == -1 
			&& StrContains(g_szWeapon_3[g_iCurrentTick[client]], "molotov") == -1)
				EquipPlayerWeapon(client, iNewWeapon);
		}
		
		if(strcmp(g_szWeapon_4[g_iCurrentTick[client]], "NULL") != 0 && eItems_FindWeaponByClassName(client, g_szWeapon_4[g_iCurrentTick[client]]) == -1)
		{
			iNewWeapon = GivePlayerItem(client, g_szWeapon_4[g_iCurrentTick[client]]);
			if(StrContains(g_szWeapon_4[g_iCurrentTick[client]], "grenade") == -1 
			&& StrContains(g_szWeapon_4[g_iCurrentTick[client]], "flashbang") == -1 
			&& StrContains(g_szWeapon_4[g_iCurrentTick[client]], "decoy") == -1 
			&& StrContains(g_szWeapon_4[g_iCurrentTick[client]], "molotov") == -1)
				EquipPlayerWeapon(client, iNewWeapon);
		}
		
		if(strcmp(g_szWeapon_5[g_iCurrentTick[client]], "NULL") != 0 && eItems_FindWeaponByClassName(client, g_szWeapon_5[g_iCurrentTick[client]]) == -1)
		{
			iNewWeapon = GivePlayerItem(client, g_szWeapon_5[g_iCurrentTick[client]]);
			if(StrContains(g_szWeapon_5[g_iCurrentTick[client]], "grenade") == -1 
			&& StrContains(g_szWeapon_5[g_iCurrentTick[client]], "flashbang") == -1 
			&& StrContains(g_szWeapon_5[g_iCurrentTick[client]], "decoy") == -1 
			&& StrContains(g_szWeapon_5[g_iCurrentTick[client]], "molotov") == -1)
				EquipPlayerWeapon(client, iNewWeapon);
		}
		
		if(strcmp(g_szWeapon_6[g_iCurrentTick[client]], "NULL") != 0 && eItems_FindWeaponByClassName(client, g_szWeapon_6[g_iCurrentTick[client]]) == -1)
		{
			iNewWeapon = GivePlayerItem(client, g_szWeapon_6[g_iCurrentTick[client]]);
			if(StrContains(g_szWeapon_6[g_iCurrentTick[client]], "grenade") == -1 
			&& StrContains(g_szWeapon_6[g_iCurrentTick[client]], "flashbang") == -1 
			&& StrContains(g_szWeapon_6[g_iCurrentTick[client]], "decoy") == -1 
			&& StrContains(g_szWeapon_6[g_iCurrentTick[client]], "molotov") == -1)
				EquipPlayerWeapon(client, iNewWeapon);
		}		
		
		if(g_iCurrentTick[client] == 0)
			TeleportEntity(client, g_fPosition[g_iCurrentTick[client]], g_fAngles[g_iCurrentTick[client]], g_fVelocity[g_iCurrentTick[client]]);
		
		if(eItems_GetWeaponSlotByDefIndex(g_iCurDefIndex[g_iCurrentTick[client]]) == CS_SLOT_GRENADE)
		{
			if(strcmp(g_szPinPulled[g_iCurrentTick[client]], "true") == 0 && g_iThrowStrength[g_iCurrentTick[client]] == 1)
			{
				if(!(g_iCurrentTick[client] <= g_iMaxTick && strcmp(g_szPinPulled[g_iCurrentTick[client]+1], "false") == 0))
					iButtons |= IN_ATTACK;
			}
			else if(strcmp(g_szPinPulled[g_iCurrentTick[client]], "true") == 0 && g_iThrowStrength[g_iCurrentTick[client]] == 0)
			{
				if(!(g_iCurrentTick[client] <= g_iMaxTick && strcmp(g_szPinPulled[g_iCurrentTick[client]+1], "false") == 0))
					iButtons |= IN_ATTACK2;
			}
		}
		
		if(strcmp(g_szIsDucked[g_iCurrentTick[client]], "true") == 0 || strcmp(g_szIsDucking[g_iCurrentTick[client]], "true") == 0)
			iButtons |= IN_DUCK;
		
		if(strcmp(g_szIsWalking[g_iCurrentTick[client]], "true") == 0)
			iButtons |= IN_SPEED;
		
		if(g_iHasJumped[g_iCurrentTick[client]] == 1)
			iButtons |= IN_JUMP;
		
		if(g_iHasZoomed[g_iCurrentTick[client]] == 1)
			iButtons |= IN_ATTACK2;
		
		if(g_iHasFired[g_iCurrentTick[client]] == 1 && g_iCurDefIndex[g_iCurrentTick[client]] != 43 && g_iCurDefIndex[g_iCurrentTick[client]] != 44 && g_iCurDefIndex[g_iCurrentTick[client]] != 45 && g_iCurDefIndex[g_iCurrentTick[client]] != 46 && g_iCurDefIndex[g_iCurrentTick[client]] != 47 && g_iCurDefIndex[g_iCurrentTick[client]] != 48)
			iButtons |= IN_ATTACK;
		
		if(g_iIsReloading[g_iCurrentTick[client]] == 1)
			iButtons |= IN_RELOAD;
		
		float fNormalizedAngles[3];
		fNormalizedAngles[0] = AngleNormalize(g_fAngles[g_iCurrentTick[client]][0]);
		fNormalizedAngles[1] = AngleNormalize(g_fAngles[g_iCurrentTick[client]][1]);
		
		Array_Copy(fNormalizedAngles, fAngles, 2);
		
		SDKCall(g_hSetOrigin, client, g_fPosition[g_iCurrentTick[client]]);
		SDKCall(g_hSetAngles, client, fAngles);
		SDKCall(g_hSetVelocity, client, g_fVelocity[g_iCurrentTick[client]]);
		
		if(g_iCurDefIndex[g_iCurrentTick[client]] != 49)
		{
			eItems_GetWeaponClassNameByDefIndex(g_iCurDefIndex[g_iCurrentTick[client]], szUseWeapon, sizeof(szUseWeapon));
			
			if(eItems_IsDefIndexKnife(g_iCurDefIndex[g_iCurrentTick[client]]))
			{
				SDKCall(g_hSwitchWeaponCall, client, GetPlayerWeaponSlot(client, CS_SLOT_KNIFE), 0);
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(client, CS_SLOT_KNIFE));
			}
			else
			{
				SDKCall(g_hSwitchWeaponCall, client, eItems_FindWeaponByClassName(client, szUseWeapon), 0);
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", eItems_FindWeaponByClassName(client, szUseWeapon));
			}
		}
		
		g_iCurrentTick[client]++;
		
		return Plugin_Changed;
	}
	
	return Plugin_Changed;
}

stock bool FakeClientCommandThrottled(int client, const char[] command)
{
	if(g_flNextCommand[client] > GetGameTime())
		return false;
	
	FakeClientCommand(client, command);
	
	g_flNextCommand[client] = GetGameTime() + 0.4;
	
	return true;
}

void ParseTicks()
{
	char szPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, szPath, sizeof(szPath), "configs/bot_demos.txt");
	
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
	
	if (!kv.JumpToKey(g_szMap))
	{
		delete kv;
		PrintToServer("Unable to find %s section in file %s.", g_szMap, szPath);
		return;
	}
	
	if (!kv.GotoFirstSubKey())
	{
		delete kv;
		PrintToServer("Unable to find %s section in file %s.", g_szMap, szPath);
		return;
	}
	
	char szTick[64];
	do {

		kv.GetSectionName(szTick, sizeof(szTick));
		
		kv.GetVector("position", g_fPosition[StringToInt(szTick)]);
		kv.GetVector("angles", g_fAngles[StringToInt(szTick)]);
		kv.GetVector("velocity", g_fVelocity[StringToInt(szTick)]);
		kv.GetString("cur_name", g_szWeapon[StringToInt(szTick)], 64);
		g_iCurDefIndex[StringToInt(szTick)] = kv.GetNum("cur_itemindex");
		kv.GetString("pinpulled", g_szPinPulled[StringToInt(szTick)], 64);
		g_iThrowStrength[StringToInt(szTick)] = kv.GetNum("throwStrength");
		kv.GetString("weapon_1", g_szWeapon_1[StringToInt(szTick)], 64);
		kv.GetString("weapon_2", g_szWeapon_2[StringToInt(szTick)], 64);
		kv.GetString("weapon_3", g_szWeapon_3[StringToInt(szTick)], 64);
		kv.GetString("weapon_4", g_szWeapon_4[StringToInt(szTick)], 64);
		kv.GetString("weapon_5", g_szWeapon_5[StringToInt(szTick)], 64);
		kv.GetString("weapon_6", g_szWeapon_6[StringToInt(szTick)], 64);
		kv.GetString("isducked", g_szIsDucked[StringToInt(szTick)], 64);
		kv.GetString("iswalking", g_szIsWalking[StringToInt(szTick)], 64);
		g_iHasJumped[StringToInt(szTick)] = kv.GetNum("hasJumped");
		g_iHasZoomed[StringToInt(szTick)] = kv.GetNum("hasZoomed");
		g_iHasFired[StringToInt(szTick)] = kv.GetNum("hasFired");
		g_iIsReloading[StringToInt(szTick)] = kv.GetNum("isReloading");
	} while (kv.GotoNextKey());
	
	g_iMaxTick = StringToInt(szTick);
	
	delete kv;
}

stock float AngleNormalize(float fAngle)
{
	fAngle -= RoundToFloor(fAngle / 360.0) * 360.0;
	
	if (fAngle > 180)
		fAngle -= 360;
	
	if (fAngle < -180)
		fAngle += 360;

	return fAngle;
}

stock bool IsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client);
}