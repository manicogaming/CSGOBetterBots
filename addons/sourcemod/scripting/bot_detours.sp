#include <sdktools>
#include <dhooks>

Handle g_hBOTBlindDetour;
Handle g_hBOTSetLookAtDetour;

public Plugin myinfo =
{
	name = "BOT Detours",
	author = "manico",
	description = "Hooks and Changes Ingame BOT functions.",
	version = "1.0",
	url = "http://steamcommunity.com/id/manico001"
};

public void OnPluginStart()
{
	Handle hGameData = LoadGameConfigFile("botstuff.games");
	if (!hGameData)
	{
		SetFailState("Failed to load botstuff gamedata.");
		return;
	}

	g_hBOTBlindDetour = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_Ignore);
	if (!g_hBOTBlindDetour)
		SetFailState("Failed to setup detour for CCSBot::Blind");

	if (!DHookSetFromConf(g_hBOTBlindDetour, hGameData, SDKConf_Signature, "CCSBot::Blind"))
		SetFailState("Failed to load CCSBot::Blind signature from gamedata");

	DHookAddParam(g_hBOTBlindDetour, HookParamType_Float); // holdTime
	DHookAddParam(g_hBOTBlindDetour, HookParamType_Float); // fadeTime
	DHookAddParam(g_hBOTBlindDetour, HookParamType_Float); // startingAlpha
	
	if (!DHookEnableDetour(g_hBOTBlindDetour, false, Detour_OnBOTBlind))
		SetFailState("Failed to detour CCSBot::Blind.");
		
	g_hBOTSetLookAtDetour = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_Ignore);
	if (!g_hBOTSetLookAtDetour)
		SetFailState("Failed to setup detour for CCSBot::SetLookAt");

	if (!DHookSetFromConf(g_hBOTSetLookAtDetour, hGameData, SDKConf_Signature, "CCSBot::SetLookAt"))
		SetFailState("Failed to load CCSBot::SetLookAt signature from gamedata");
		
	DHookAddParam(g_hBOTSetLookAtDetour, HookParamType_CharPtr); // desc
	DHookAddParam(g_hBOTSetLookAtDetour, HookParamType_VectorPtr); // pos
	DHookAddParam(g_hBOTSetLookAtDetour, HookParamType_Int); // pri
	DHookAddParam(g_hBOTSetLookAtDetour, HookParamType_Float); // duration
	DHookAddParam(g_hBOTSetLookAtDetour, HookParamType_Bool); // clearIfClose
	DHookAddParam(g_hBOTSetLookAtDetour, HookParamType_Float); // angleTolerance
	DHookAddParam(g_hBOTSetLookAtDetour, HookParamType_Bool); // attack
	
	if (!DHookEnableDetour(g_hBOTSetLookAtDetour, false, Detour_OnBOTSetLookAt))
		SetFailState("Failed to detour CCSBot::SetLookAt.");
	
	delete hGameData;
}

public MRESReturn Detour_OnBOTBlind(Handle hParams)
{
	if(DHookGetParam(hParams, 2) < 2.0)
	{
		return MRES_Supercede;
	}
	return MRES_Ignored;
}

public MRESReturn Detour_OnBOTSetLookAt(Handle hParams)
{
	char szDesc[64];
	
	DHookGetParamString(hParams, 1, szDesc, sizeof(szDesc));
	
	if(strcmp(szDesc, "Defuse bomb") == 0 || strcmp(szDesc, "Use entity") == 0 || strcmp(szDesc, "Open door") == 0 || strcmp(szDesc, "Breakable") == 0 
	|| strcmp(szDesc, "Hostage") == 0 || strcmp(szDesc, "Avoid Flashbang") == 0)
	{
		return MRES_Ignored;
	}
	else if(strcmp(szDesc, "GrenadeThrowBend") == 0 || strcmp(szDesc, "Plant bomb on floor") == 0)
	{
		float fPos[3];
		
		DHookGetParamVector(hParams, 2, fPos);
		fPos[2] += GetRandomFloat(25.0, 50.0);
		DHookSetParamVector(hParams, 2, fPos);
		
		return MRES_ChangedHandled;
	}
	else
	{
		float fPos[3];
		
		DHookGetParamVector(hParams, 2, fPos);
		fPos[2] += 30.0;
		DHookSetParamVector(hParams, 2, fPos);
		
		return MRES_ChangedHandled;
	}
}