#define LOGHELPER_VERSION 5

#include <sourcemod>
#include <sdktools>

char g_team_list[16][64];

// Call this on map start to cache team names in g_team_list

stock void GetTeams(bool insmod = false)
{
	if (!insmod)
	{
		int max_teams_count = GetTeamCount();
		for (int team_index = 0; (team_index < max_teams_count); team_index++)
		{
			char team_name[64];
			GetTeamName(team_index, team_name, sizeof(team_name));

			if (strcmp(team_name, "") != 0)
			{
				g_team_list[team_index] = team_name;
			}
		}
	}
	else
	{
		// they really need to get their act together... GetTeamName() would be awesome since they can't even keep their team indexes consistent
		char mapname[64];
		GetCurrentMap(mapname, sizeof(mapname));
		if (strcmp(mapname, "ins_karam") == 0 || strcmp(mapname, "ins_baghdad") == 0)
		{
			g_team_list[1] = "Iraqi Insurgents";
			g_team_list[2] = "U.S. Marines";
		}
		else
		{
			g_team_list[1] = "U.S. Marines";
			g_team_list[2] = "Iraqi Insurgents";
		}
		g_team_list[0] = "Unassigned";
		g_team_list[3] = "SPECTATOR";
	}
}

stock void LogPlayerEvent(int client, const char[] verb, const char[] event, bool display_location = false, const char[] properties = "")
{
	if (IsValidPlayer(client))
	{
		char player_authid[32];
		if (!GetClientAuthId(client, AuthId_Engine, player_authid, sizeof(player_authid), false))
		{
			strcopy(player_authid, sizeof(player_authid), "UNKNOWN");
		}

		if (display_location)
		{
			float player_origin[3];
			GetClientAbsOrigin(client, player_origin);
			LogToGame("\"%N<%d><%s><%s>\" %s \"%s\"%s (position \"%d %d %d\")", client, GetClientUserId(client), player_authid, g_team_list[GetClientTeam(client)], verb, event, properties, RoundFloat(player_origin[0]), RoundFloat(player_origin[1]), RoundFloat(player_origin[2])); 
		}
		else
		{
			LogToGame("\"%N<%d><%s><%s>\" %s \"%s\"%s", client, GetClientUserId(client), player_authid, g_team_list[GetClientTeam(client)], verb, event, properties); 
		}
	}
}

stock void LogPlyrPlyrEvent(int client, int victim, const char[] verb, const char[] event, bool display_location = false, const char[] properties = "")
{
	if (IsValidPlayer(client) && IsValidPlayer(victim))
	{
		char player_authid[32];
		if (!GetClientAuthId(client, AuthId_Engine, player_authid, sizeof(player_authid), false))
		{
			strcopy(player_authid, sizeof(player_authid), "UNKNOWN");
		}
		char victim_authid[32];
		if (!GetClientAuthId(victim, AuthId_Engine, victim_authid, sizeof(victim_authid), false))
		{
			strcopy(victim_authid, sizeof(victim_authid), "UNKNOWN");
		}
		
		if (display_location)
		{
			float player_origin[3];
			GetClientAbsOrigin(client, player_origin);
			
			float victim_origin[3];
			GetClientAbsOrigin(victim, victim_origin);
			
			LogToGame("\"%N<%d><%s><%s>\" %s \"%s\" against \"%N<%d><%s><%s>\"%s (position \"%d %d %d\") (victim_position \"%d %d %d\")", client, GetClientUserId(client), player_authid, g_team_list[GetClientTeam(client)], verb, event, victim, GetClientUserId(victim), victim_authid, g_team_list[GetClientTeam(victim)], properties, RoundFloat(player_origin[0]), RoundFloat(player_origin[1]), RoundFloat(player_origin[2]), RoundFloat(victim_origin[0]), RoundFloat(victim_origin[1]), RoundFloat(victim_origin[2])); 
		}
		else
		{
			LogToGame("\"%N<%d><%s><%s>\" %s \"%s\" against \"%N<%d><%s><%s>\"%s", client, GetClientUserId(client), player_authid, g_team_list[GetClientTeam(client)], verb, event, victim, GetClientUserId(victim), victim_authid, g_team_list[GetClientTeam(victim)], properties); 
		}
	}
}

stock void LogKill(int attacker, int victim, const char[] weapon, bool display_location = false, const char[] properties = "")
{
	if (IsValidPlayer(attacker) && IsValidPlayer(victim))
	{
		char attacker_authid[32];
		if (!GetClientAuthId(attacker, AuthId_Engine, attacker_authid, sizeof(attacker_authid), false))
		{
			strcopy(attacker_authid, sizeof(attacker_authid), "UNKNOWN");
		}
		char victim_authid[32];
		if (!GetClientAuthId(victim, AuthId_Engine, victim_authid, sizeof(victim_authid), false))
		{
			strcopy(victim_authid, sizeof(victim_authid), "UNKNOWN");
		}
			
		if (display_location)
		{
			float attacker_origin[3];
			GetClientAbsOrigin(attacker, attacker_origin);
			float victim_origin[3];
			GetClientAbsOrigin(victim, victim_origin);
			
			LogToGame("\"%N<%d><%s><%s>\" killed \"%N<%d><%s><%s>\" with \"%s\"%s (attacker_position \"%d %d %d\") (victim_position \"%d %d %d\")", attacker, GetClientUserId(attacker), attacker_authid, g_team_list[GetClientTeam(attacker)], victim, GetClientUserId(victim), victim_authid, g_team_list[GetClientTeam(victim)], weapon, properties, RoundFloat(attacker_origin[0]), RoundFloat(attacker_origin[1]), RoundFloat(attacker_origin[2]), RoundFloat(victim_origin[0]), RoundFloat(victim_origin[1]), RoundFloat(victim_origin[2])); 
		}
		else
		{
			LogToGame("\"%N<%d><%s><%s>\" killed \"%N<%d><%s><%s>\" with \"%s\"%s", attacker, GetClientUserId(attacker), attacker_authid, g_team_list[GetClientTeam(attacker)], victim, GetClientUserId(victim), victim_authid, g_team_list[GetClientTeam(victim)], weapon, properties); 
		}
	}
}

stock void LogSuicide(int victim, const char[] weapon, bool display_location = false, const char[] properties = "")
{
	if (IsValidPlayer(victim))
	{
		char victim_authid[32];
		if (!GetClientAuthId(victim, AuthId_Engine, victim_authid, sizeof(victim_authid), false))
		{
			strcopy(victim_authid, sizeof(victim_authid), "UNKNOWN");
		}
			
		if (display_location)
		{
			float victim_origin[3];
			GetClientAbsOrigin(victim, victim_origin);
			
			LogToGame("\"%N<%d><%s><%s>\" committed suicide with \"%s\"%s (victim_position \"%d %d %d\")", victim, GetClientUserId(victim), victim_authid, g_team_list[GetClientTeam(victim)], weapon, properties, RoundFloat(victim_origin[0]), RoundFloat(victim_origin[1]), RoundFloat(victim_origin[2])); 
		}
		else
		{
			LogToGame("\"%N<%d><%s><%s>\" committed suicide with \"%s\"%s", victim, GetClientUserId(victim), victim_authid, g_team_list[GetClientTeam(victim)], weapon, properties); 
		}
	}
}

// For Psychostats "KTRAJ" kill trajectory log lines
stock void LogPSKillTraj(int attacker, int victim, const char[] weapon)
{
	if (IsValidPlayer(attacker) && IsValidPlayer(victim))
	{
		char attacker_authid[32];
		if (!GetClientAuthId(attacker, AuthId_Engine, attacker_authid, sizeof(attacker_authid), false))
		{
			strcopy(attacker_authid, sizeof(attacker_authid), "UNKNOWN");
		}
		char victim_authid[32];
		if (!GetClientAuthId(victim, AuthId_Engine, victim_authid, sizeof(victim_authid), false))
		{
			strcopy(victim_authid, sizeof(victim_authid), "UNKNOWN");
		}
		
		float attacker_origin[3];
		GetClientAbsOrigin(attacker, attacker_origin);
		float victim_origin[3];
		GetClientAbsOrigin(victim, victim_origin);
		
		LogToGame("[KTRAJ] \"%N<%d><%s><%s>\" killed \"%N<%d><%s><%s>\" with \"%s\" (attacker_position \"%d %d %d\") (victim_position \"%d %d %d\")", attacker, GetClientUserId(attacker), attacker_authid, g_team_list[GetClientTeam(attacker)], victim, GetClientUserId(victim), victim_authid, g_team_list[GetClientTeam(victim)], weapon, RoundFloat(attacker_origin[0]), RoundFloat(attacker_origin[1]), RoundFloat(attacker_origin[2]), RoundFloat(victim_origin[0]), RoundFloat(victim_origin[1]), RoundFloat(victim_origin[2]));
	}
}

// Verb should always be "triggered" for this.
stock void LogTeamEvent(int team, const char[] verb, const char[] event, const char[] properties = "")
{
	if (team > -1)
	{
		LogToGame("Team \"%s\" %s \"%s\"%s", g_team_list[team], verb, event, properties);
	}
}

stock void LogKillLoc(int attacker, int victim)
{
	if (attacker > 0 && victim > 0)
	{
		float attacker_origin[3];
		GetClientAbsOrigin(attacker, attacker_origin);
		float victim_origin[3];
		GetClientAbsOrigin(victim, victim_origin);
				
		LogToGame("World triggered \"killlocation\" (attacker_position \"%d %d %d\") (victim_position \"%d %d %d\")", RoundFloat(attacker_origin[0]), RoundFloat(attacker_origin[1]), RoundFloat(attacker_origin[2]), RoundFloat(victim_origin[0]), RoundFloat(victim_origin[1]), RoundFloat(victim_origin[2]));
	}
}

stock void LogTeamChange(int client, int newteam, const char[] properties = "")
{
	if (IsValidPlayer(client))
	{
		char player_authid[32];
		if (!GetClientAuthId(client, AuthId_Engine, player_authid, sizeof(player_authid), false))
		{
			strcopy(player_authid, sizeof(player_authid), "UNKNOWN");
		}
		
		LogToGame("\"%N<%d><%s><%s>\" joined team \"%s\"%s", client, GetClientUserId(client), player_authid, g_team_list[GetClientTeam(client)], g_team_list[newteam], properties);
	}
}

stock void LogRoleChange(int client, const char[] role, const char[] properties = "")
{
	if (IsValidPlayer(client))
	{
		char player_authid[32];
		if (!GetClientAuthId(client, AuthId_Engine, player_authid, sizeof(player_authid), false))
		{
			strcopy(player_authid, sizeof(player_authid), "UNKNOWN");
		}
		
		LogToGame("\"%N<%d><%s><%s>\" changed role to \"%s\"%s", client, GetClientUserId(client), player_authid, g_team_list[GetClientTeam(client)], role, properties);
	}
}

stock void LogMapLoad()
{
	char map[64];
	GetCurrentMap(map, sizeof(map));
	LogToGame("Loading map \"%s\"", map);
}

static stock bool IsValidPlayer(int client)
{
	if (client > 0 && client <= MaxClients && IsClientInGame(client))
	{
		return true;
	}
	return false;
}