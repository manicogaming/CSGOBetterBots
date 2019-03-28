#pragma semicolon 1
#include <sourcemod>
#undef REQUIRE_PLUGIN
#include <rankme>
#include <lvl_ranks>
#define REQUIRE_PLUGIN

#pragma newdecls required
#define PLUGIN_NAME "Levels Ranks"
#define PLUGIN_AUTHOR "RoadSide Romeo"

public Plugin myinfo = {name = "[LR] Module - Synchronization RankMe", author = PLUGIN_AUTHOR, version = PLUGIN_VERSION}
public void OnPluginStart()
{
	HookEvent("round_start", Synch_Hooks);
	HookEvent("player_death", Synch_Hooks);
}

public void OnAllPluginsLoaded()
{
	if(LR_GetTypeStatistics() == 2)
	{
		if(!LibraryExists("rankme"))
		{
			SetFailState("[" ... PLUGIN_NAME ... " Synchronization RankMe] Synchronization is not possible, plugin not found or not launched");
		}
	}
}

public void LR_OnCheckSync(int &iCount)
{
    iCount++;
}

public void Synch_Hooks(Handle hEvent, char[] sEvName, bool bDontBroadcast)
{
	switch(sEvName[0])
	{
		case 'r':
		{
			for(int iClient = 1; iClient <= MaxClients; iClient++)
			{
				if(IsClientInGame(iClient))
				{
					LR_SetClientValue(iClient, RankMe_GetPoints(iClient));
				}
			}
		}

		case 'p':
		{
			int iAttacker = GetClientOfUserId(GetEventInt(hEvent, "attacker"));
			int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));

			if(iAttacker && IsClientInGame(iAttacker))
			{
				LR_SetClientValue(iAttacker, RankMe_GetPoints(iAttacker));
			}

			if(iClient && IsClientInGame(iClient))
			{
				LR_SetClientValue(iClient, RankMe_GetPoints(iClient));
			}
		}
	}
}