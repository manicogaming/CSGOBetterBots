#include <sourcemod>
#include <sdktools>

int g_iMaxClients		= 0;

float g_fTimer		= 0.0;

char g_szPlayerManager[50] = "";

// Entities
int g_iPlayerManager	= -1;

// Offsets
int g_iPing				= -1;

// ConVars
ConVar g_hMinPing 	= null;
ConVar g_hMaxPing	= null;
ConVar g_hInterval	= null;

#define PLUGIN_VERSION "1.0.1"

public Plugin myinfo =
{
	name = "Bot Ping",
	author = "Knagg0",
	description = "Changes the ping of a BOT on the scoreboard",
	version = PLUGIN_VERSION,
	url = "http://www.mfzb.de"
};

public void OnPluginStart()
{
	CreateConVar("bp_version", PLUGIN_VERSION, "", FCVAR_REPLICATED | FCVAR_NOTIFY);

	g_hMinPing	= CreateConVar("bp_minping", "25");
	g_hMaxPing	= CreateConVar("bp_maxping", "100");
	g_hInterval	= CreateConVar("bp_interval", "5");

	g_iPing	= FindSendPropInfo("CPlayerResource", "m_iPing");

	char szBuffer[100];
	GetGameFolderName(szBuffer, sizeof(szBuffer));

	if(StrEqual("csgo", szBuffer))
	strcopy(g_szPlayerManager, sizeof(g_szPlayerManager), "cs_player_manager");
	else if(StrEqual("dod", szBuffer))
	strcopy(g_szPlayerManager, sizeof(g_szPlayerManager), "dod_player_manager");
	else
	strcopy(g_szPlayerManager, sizeof(g_szPlayerManager), "player_manager");
}

public void OnMapStart()
{
	g_iMaxClients		= MaxClients;
	g_iPlayerManager	= FindEntityByClassname(g_iMaxClients + 1, g_szPlayerManager);
	g_fTimer			= 0.0;
}

public void OnGameFrame()
{
	if(g_fTimer < GetGameTime() - g_hInterval.IntValue)
	{
		g_fTimer = GetGameTime();

		if(g_iPlayerManager == -1 || g_iPing == -1)
		return;

		for(int i = 1; i <= g_iMaxClients; i++)
		{
			if(!IsValidEdict(i) || !IsClientInGame(i) || !IsFakeClient(i))
			continue;

			SetEntData(g_iPlayerManager, g_iPing + (i * 4), GetRandomInt(g_hMinPing.IntValue, g_hMaxPing.IntValue));
		}
	}
}
