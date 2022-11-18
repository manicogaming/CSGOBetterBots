#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#include <dhooks>

#define MAX_TEAMNAME_LENGTH			128

Handle g_hHalftimeTeamswitch = null;
bool g_bHalftimeTeamswitch = false;
static ConVar mp_teamname_1;
static ConVar mp_teamname_2;
bool b_wentHalftime = false;

public Plugin myinfo = 
{
	name = "BOT Teamname BETA", 
	author = "BTFighter, Bacardi", 
	description = "Changes teamname to a bot or to a player.", 
	version = "0.l", 
	url = "https://forums.alliedmods.net/member.php?u=67162"
};

public void OnPluginStart()
{
	g_hHalftimeTeamswitch = CreateConVar("teamname_halftime_teamswitch", "1", "Plugin will switch team names at half time.");
	g_bHalftimeTeamswitch = GetConVarBool(g_hHalftimeTeamswitch);
	HookConVarChange(g_hHalftimeTeamswitch, OnConvarChanged);
	
	HookEvent("announce_phase_end", OnAnnouncePhaseEnd);
    HookEvent("player_team", player_team);
}

public void OnConvarChanged(Handle cvar, const char[] oldVal, const char[] newVal)
{
	if (cvar == g_hHalftimeTeamswitch)
	{
		g_bHalftimeTeamswitch = StringToInt(newVal) == 0 ? false : true;
	}
}

public Action OnAnnouncePhaseEnd(Handle event, const char[] name, bool dontBroadcast)
{
	if (!g_bHalftimeTeamswitch)
		return Plugin_Continue;
	
	b_wentHalftime = true;
	
	char name1[MAX_TEAMNAME_LENGTH]; char name2[MAX_TEAMNAME_LENGTH];
	
	GetConVarString(mp_teamname_1, name1, MAX_TEAMNAME_LENGTH);
	if (StrEqual(name1, ""))
		return Plugin_Continue;

	GetConVarString(mp_teamname_2, name2, MAX_TEAMNAME_LENGTH);
	if (StrEqual(name2, ""))
		return Plugin_Continue;
		
	SetConVarString(mp_teamname_1, name1);
	SetConVarString(mp_teamname_2, name2);
	return Plugin_Continue;
}

public void player_team(Event event, const char[] name, bool dontBroadcast)
{
/*
Server event "player_team", Tick 24180:
- "userid" = "5"
- "team" = "3"
- "oldteam" = "0"
- "disconnect" = "0"
- "autoteam" = "0"
- "silent" = "0"
- "isbot" = "1"
*/
	if (b_wentHalftime)
		return;
	
    if(event.GetBool("disconnect"))
        return;

    int team = event.GetInt("team");

    if(team < 2)
        return;

    int client = GetClientOfUserId(event.GetInt("userid"));

    char buffer[MAX_NAME_LENGTH];
    Format(buffer, sizeof(buffer), "team_%N", client);

    switch(team)
    {
        case 2:
        {
            if(mp_teamname_2 == null)
            {
                mp_teamname_2 = FindConVar("mp_teamname_2");
                
                if(mp_teamname_2 == null) SetFailState("This game not have Console Variable mp_teamname_2");
            }
            
            mp_teamname_2.SetString(buffer);
        }
        case 3:
        {
            if(mp_teamname_1 == null)
            {
                mp_teamname_1 = FindConVar("mp_teamname_1");
                
                if(mp_teamname_1 == null) SetFailState("This game not have Console Variable mp_teamname_1");
            }
            
            mp_teamname_1.SetString(buffer);
        }
    }
} 