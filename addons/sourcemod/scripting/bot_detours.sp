#include <sdktools>
#include <dhooks>

Handle g_hBOTBlindDetour;

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
	delete hGameData;

	DHookAddParam(g_hBOTBlindDetour, HookParamType_Float); // holdTime
	DHookAddParam(g_hBOTBlindDetour, HookParamType_Float); // fadeTime
	DHookAddParam(g_hBOTBlindDetour, HookParamType_Float); // startingAlpha
	
	if (!DHookEnableDetour(g_hBOTBlindDetour, false, Detour_OnBOTBlind))
		SetFailState("Failed to detour CCSBot::Blind.");

	PrintToServer("CCSBot::Blind detoured!");
}

public MRESReturn Detour_OnBOTBlind(Handle hParams)
{
	if(DHookGetParam(hParams, 2) < 2.0)
	{
		return MRES_Supercede;
	}
	return MRES_Ignored;
}