#define HITGROUP_GENERIC   0
#define HITGROUP_HEAD      1
#define HITGROUP_CHEST     2
#define HITGROUP_STOMACH   3
#define HITGROUP_LEFTARM   4
#define HITGROUP_RIGHTARM  5
#define HITGROUP_LEFTLEG   6
#define HITGROUP_RIGHTLEG  7

#define LOG_HIT_OFFSET     7 

#define LOG_HIT_SHOTS      0
#define LOG_HIT_HITS       1
#define LOG_HIT_KILLS      2
#define LOG_HIT_HEADSHOTS  3
#define LOG_HIT_TEAMKILLS  4
#define LOG_HIT_DAMAGE     5
#define LOG_HIT_DEATHS     6
#define LOG_HIT_GENERIC    7
#define LOG_HIT_HEAD       8
#define LOG_HIT_CHEST      9
#define LOG_HIT_STOMACH    10
#define LOG_HIT_LEFTARM    11
#define LOG_HIT_RIGHTARM   12
#define LOG_HIT_LEFTLEG    13
#define LOG_HIT_RIGHTLEG   14

Handle g_weapon_trie = INVALID_HANDLE;

void CreatePopulateWeaponTrie()
{
	// Create a Trie
	g_weapon_trie = CreateTrie();
	
	// Initial populate
	for (int i = 0; i < MAX_LOG_WEAPONS; i++)
	{
		if (g_weapon_list[i][0] == 0)
		{
			// some games have a couple blanks as place holders (so array indexes match with weapon ids)
			char randomKey[6];
			Format(randomKey, sizeof(randomKey), "%c%c%c%c%c%c", GetURandomInt(), GetURandomInt(), GetURandomInt(), GetURandomInt(), GetURandomInt(), GetURandomInt());
			SetTrieValue(g_weapon_trie, randomKey, i);
			continue;
		}
		
		SetTrieValue(g_weapon_trie, g_weapon_list[i], i);
	}
}

void dump_player_stats(int client)
{
	if (IsClientInGame(client) && IsClientConnected(client) && !IsFakeClient(client))
	{
		char player_authid[64];
		if (!GetClientAuthId(client, AuthId_Steam2, player_authid, sizeof(player_authid)))
		{
			strcopy(player_authid, sizeof(player_authid), "UNKNOWN");
		}
		int player_team_index = GetClientTeam(client);

		int player_userid = GetClientUserId(client);

		int is_logged;
		for (int i = 0; (i < MAX_LOG_WEAPONS); i++)
		{
			if (g_weapon_stats[client][i][LOG_HIT_SHOTS] > 0)
			{
				LogToGame("\"%N<%d><%s><%s>\" triggered \"weaponstats\" (weapon \"%s\") (shots \"%d\") (hits \"%d\") (kills \"%d\") (headshots \"%d\") (tks \"%d\") (damage \"%d\") (deaths \"%d\")", client, player_userid, player_authid, g_team_list[player_team_index], g_weapon_list[i], g_weapon_stats[client][i][LOG_HIT_SHOTS], g_weapon_stats[client][i][LOG_HIT_HITS], g_weapon_stats[client][i][LOG_HIT_KILLS], g_weapon_stats[client][i][LOG_HIT_HEADSHOTS], g_weapon_stats[client][i][LOG_HIT_TEAMKILLS], g_weapon_stats[client][i][LOG_HIT_DAMAGE], g_weapon_stats[client][i][LOG_HIT_DEATHS]);
				LogToGame("\"%N<%d><%s><%s>\" triggered \"weaponstats2\" (weapon \"%s\") (head \"%d\") (chest \"%d\") (stomach \"%d\") (leftarm \"%d\") (rightarm \"%d\") (leftleg \"%d\") (rightleg \"%d\")", client, player_userid, player_authid, g_team_list[player_team_index], g_weapon_list[i], g_weapon_stats[client][i][LOG_HIT_HEAD], g_weapon_stats[client][i][LOG_HIT_CHEST], g_weapon_stats[client][i][LOG_HIT_STOMACH], g_weapon_stats[client][i][LOG_HIT_LEFTARM], g_weapon_stats[client][i][LOG_HIT_RIGHTARM], g_weapon_stats[client][i][LOG_HIT_LEFTLEG], g_weapon_stats[client][i][LOG_HIT_RIGHTLEG]);
				is_logged++;
			}
		}
		if (is_logged > 0)
		{
			reset_player_stats(client);
		}
	}
}

void reset_player_stats(int client)
{
	for (int i = 0; (i < MAX_LOG_WEAPONS); i++)
	{
		g_weapon_stats[client][i][LOG_HIT_SHOTS]     = 0;
		g_weapon_stats[client][i][LOG_HIT_HITS]      = 0;
		g_weapon_stats[client][i][LOG_HIT_KILLS]     = 0;
		g_weapon_stats[client][i][LOG_HIT_HEADSHOTS] = 0;
		g_weapon_stats[client][i][LOG_HIT_TEAMKILLS] = 0;
		g_weapon_stats[client][i][LOG_HIT_DAMAGE]    = 0;
		g_weapon_stats[client][i][LOG_HIT_DEATHS]    = 0;
		g_weapon_stats[client][i][LOG_HIT_GENERIC]   = 0;
		g_weapon_stats[client][i][LOG_HIT_HEAD]      = 0;
		g_weapon_stats[client][i][LOG_HIT_CHEST]     = 0;
		g_weapon_stats[client][i][LOG_HIT_STOMACH]   = 0;
		g_weapon_stats[client][i][LOG_HIT_LEFTARM]   = 0;
		g_weapon_stats[client][i][LOG_HIT_RIGHTARM]  = 0;
		g_weapon_stats[client][i][LOG_HIT_LEFTLEG]   = 0;
		g_weapon_stats[client][i][LOG_HIT_RIGHTLEG]  = 0;
	}
}

stock int get_weapon_index(const char[] weapon_name)
{
	int index = -1;
	GetTrieValue(g_weapon_trie, weapon_name, index);
	return index;
}


void WstatsDumpAll()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		dump_player_stats(i);
	}
}

public void OnPlayerDisconnect(int client)
{
	if(client > 0 && IsClientInGame(client))
	{
		dump_player_stats(client);
		reset_player_stats(client);
	}
}