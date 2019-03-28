bool			g_bInitialized[MAXPLAYERS+1];
char			g_sSQL_CreateTable_SQLITE[] = "CREATE TABLE IF NOT EXISTS lvl_base (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, value INTEGER NOT NULL default 0, name varchar(128) NOT NULL default '', rank INTEGER NOT NULL default 0, kills INTEGER NOT NULL default 0, deaths INTEGER NOT NULL default 0, shoots INTEGER NOT NULL default 0, hits INTEGER NOT NULL default 0, headshots INTEGER NOT NULL default 0, assists INTEGER NOT NULL default 0, vip INTEGER NOT NULL default 0, lastconnect INTEGER NOT NULL default 0);",
			g_sSQL_CreateTable_MYSQL[] = "CREATE TABLE IF NOT EXISTS lvl_base (id int(12) NOT NULL AUTO_INCREMENT, value int(12) NOT NULL default 0, name varchar(128) NOT NULL default '', rank int(12) NOT NULL default 0, kills int(12) NOT NULL default 0, deaths int(12) NOT NULL default 0, shoots int(12) NOT NULL default 0, hits int(12) NOT NULL default 0, headshots int(12) NOT NULL default 0, assists int(12) NOT NULL default 0, vip int(12) NOT NULL default 0, lastconnect int(12) NOT NULL default 0, PRIMARY KEY (id)) CHARSET=utf8 COLLATE utf8_general_ci",
			g_sSQL_CreatePlayer[] = "INSERT INTO lvl_base (value, name, lastconnect) VALUES (%d, '%s', %d);",
			g_sSQL_LoadPlayer[] = "SELECT value, rank, kills, deaths, shoots, hits, headshots, assists, vip FROM lvl_base WHERE name = '%s';",
			g_sSQL_SavePlayer[] = "UPDATE lvl_base SET value = %d, rank = %d, kills = %d, deaths = %d, shoots = %d, hits = %d, headshots = %d, assists = %d, vip = %d, lastconnect = %d WHERE name = '%s';",
			g_sSQL_CountPlayers[] = "SELECT name FROM lvl_base;",
			g_sSQL_PlacePlayer[] = "SELECT name FROM lvl_base WHERE value >= %d;",
			g_sSQL_PurgeDB[] = "DELETE FROM lvl_base WHERE lastconnect < %d;",
			g_sSQL_CallTOP[] = "SELECT name, value FROM lvl_base ORDER BY value DESC LIMIT %i, 10;",
			g_sName[MAXPLAYERS+1][32];
Database	g_hDatabase = null;

void ConnectDB()
{
	char sIdent[16], sError[256];
	g_hDatabase = SQL_Connect("levels_ranks", false, sError, 256);
	if(!g_hDatabase)
	{
		g_hDatabase = SQLite_UseDatabase("lr_base", sError, 256);
		if(!g_hDatabase)
		{
			CrashLR("Could not connect to the database (%s)", sError);
		}
	}

	DBDriver hDatabaseDriver = g_hDatabase.Driver;
	hDatabaseDriver.GetIdentifier(sIdent, sizeof(sIdent));

	SQL_LockDatabase(g_hDatabase);
	switch(sIdent[0])
	{
		case 's': if(!SQL_FastQuery(g_hDatabase, g_sSQL_CreateTable_SQLITE)) CrashLR("ConnectDB - could not create table in SQLite");
		case 'm': if(!SQL_FastQuery(g_hDatabase, g_sSQL_CreateTable_MYSQL)) CrashLR("ConnectDB - could not create table in MySQL");
		default: CrashLR("ConnectDB - type database is invalid");
	}
	SQL_UnlockDatabase(g_hDatabase);

	g_hDatabase.SetCharset("utf8");
}

void GetCountPlayers()
{
	if(!g_hDatabase)
	{
		LogLR("GetCountPlayers - database is invalid");
		return;
	}

	g_hDatabase.Query(SQL_GetCountPlayers, g_sSQL_CountPlayers);
}

DBCallbackLR(SQL_GetCountPlayers)
{
	if(dbRs == null)
	{
		LogLR("SQL_GetCountPlayers - error while working with data (%s)", sError);
		if(StrContains(sError, "Lost connection to MySQL", false) != -1)
		{
			TryReconnectDB();
		}
		return;
	}

	g_iDBCountPlayers = dbRs.RowCount;
}

void GetPlacePlayer(int iClient)
{
	if(!g_hDatabase)
	{
		LogLR("GetPlacePlayer - database is invalid");
		return;
	}

	char sQuery[256];
	FormatEx(sQuery, 256, g_sSQL_PlacePlayer, EXP(iClient));
	g_hDatabase.Query(SQL_GetPlacePlayer, sQuery, iClient);
}

DBCallbackLR(SQL_GetPlacePlayer)
{
	if(dbRs == null)
	{
		LogLR("SQL_GetPlacePlayer - error while working with data (%s)", sError);
		if(StrContains(sError, "Lost connection to MySQL", false) != -1)
		{
			TryReconnectDB();
		}
		return;
	}

	g_iDBRankPlayer[iClient] = dbRs.RowCount;
}

void CreateDataPlayer(int iClient)
{
	if(!g_hDatabase)
	{
		LogLR("CreateDataPlayer - database is invalid");
		return;
	}

	if(IsClientConnected(iClient) && IsClientInGame(iClient))
	{
		char sQuery[512], sSaveName[MAX_NAME_LENGTH * 2 + 1];
		g_hDatabase.Escape(GetFixNamePlayer(iClient), sSaveName, sizeof(sSaveName));

		switch(g_iTypeStatistics)
		{
			case 1: EXP(iClient) = 1000;
			default: EXP(iClient) = 0;
		}

		FormatEx(sQuery, sizeof(sQuery), g_sSQL_CreatePlayer, EXP(iClient), g_sName[iClient], GetTime());
		g_hDatabase.Query(SQL_CreateDataPlayer, sQuery, iClient);
	}
}

DBCallbackLR(SQL_CreateDataPlayer)
{
	if(dbRs == null)
	{
		LogLR("SQL_CreateDataPlayer - error while working with data (%s)", sError);
		if(StrContains(sError, "Lost connection to MySQL", false) != -1)
		{
			TryReconnectDB();
		}
		return;
	}

	g_bInitialized[iClient] = true;
	RANK(iClient) = 0;
	KILLS(iClient) = 0;
	DEATHS(iClient) = 0;
	SHOOTS(iClient) = 0;
	HITS(iClient) = 0;
	HEADSHOTS(iClient) = 0;
	ASSISTS(iClient) = 0;
	VIP(iClient) = 0;
	CheckRank(iClient);
}

void LoadDataPlayer(int iClient)
{
	if(!g_hDatabase)
	{
		LogLR("LoadDataPlayer - database is invalid");
		return;
	}

	if(IsClientInGame(iClient) || IsFakeClient(iClient))
	{
		char sQuery[256];
		GetClientName(iClient, g_sName[iClient], 128);
		FormatEx(sQuery, sizeof(sQuery), g_sSQL_LoadPlayer, g_sName[iClient]);
		g_hDatabase.Query(SQL_LoadDataPlayer, sQuery, iClient);
	}
}

DBCallbackLR(SQL_LoadDataPlayer)
{
	if(dbRs == null)
	{
		LogLR("SQL_LoadDataPlayer - error while working with data (%s)", sError);
		if(StrContains(sError, "Lost connection to MySQL", false) != -1)
		{
			TryReconnectDB();
		}
		return;
	}
	
	if(dbRs.HasResults && dbRs.FetchRow())
	{
		for(int i = 0; i < 9; i++)
		{
			g_iClientData[iClient][i] = dbRs.FetchInt(i);
		}
		g_bInitialized[iClient] = true;
		CheckRank(iClient);
	}
	else CreateDataPlayer(iClient);
}

void SaveDataPlayer(int iClient)
{
	if(!g_hDatabase)
	{
		LogLR("SaveDataPlayer - database is invalid");
		return;
	}

	if(g_bInitialized[iClient])
	{
		char sQuery[512], sSaveName[MAX_NAME_LENGTH * 2 + 1];
		g_hDatabase.Escape(GetFixNamePlayer(iClient), sSaveName, sizeof(sSaveName));

		FormatEx(sQuery, 512, g_sSQL_SavePlayer, EXP(iClient), RANK(iClient), KILLS(iClient), DEATHS(iClient), SHOOTS(iClient), HITS(iClient), HEADSHOTS(iClient), ASSISTS(iClient), VIP(iClient), GetTime(), g_sName[iClient]);
		g_hDatabase.Query(SQL_SaveDataPlayer, sQuery, iClient, DBPrio_High);
	}
}

DBCallbackLR(SQL_SaveDataPlayer)
{
	if(dbRs == null)
	{
		LogLR("SQL_SaveDataPlayer - error while working with data (%s)", sError);
		if(StrContains(sError, "Lost connection to MySQL", false) != -1)
		{
			TryReconnectDB();
		}
	}
}

void PurgeDatabase()
{
	if(!g_hDatabase)
	{
		LogLR("PurgeDatabase - database is invalid");
		return;
	}

	char sQuery[256];
	FormatEx(sQuery, 256, g_sSQL_PurgeDB, GetTime() - (g_iDaysDeleteFromBase * 86400));
	g_hDatabase.Query(SQL_PurgeDatabase, sQuery);
}

DBCallbackLR(SQL_PurgeDatabase)
{
	if(dbRs == null)
	{
		LogLR("SQL_PurgeDatabase - error while working with data (%s)", sError);
		if(StrContains(sError, "Lost connection to MySQL", false) != -1)
		{
			TryReconnectDB();
		}
	}
}

void ResetStats()
{
	if(!g_hDatabase)
	{
		LogLR("ResetStats - database is invalid");
		return;
	}

	SQL_LockDatabase(g_hDatabase);
	SQL_FastQuery(g_hDatabase, "DELETE FROM lvl_base;");
	SQL_UnlockDatabase(g_hDatabase);

	for(int i = 1; i <= MaxClients; i++)
	{
		if(g_bInitialized[i])
		{
			g_bInitialized[i] = false;
			CreateDataPlayer(i);
		}
	}
}

void TryReconnectDB()
{
	delete g_hDatabase;
	g_hDatabase = null;
	g_iCountRetryConnect = 0;
	CreateTimer(g_fDBReconnectTime, TryReconnectDBTimer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action TryReconnectDBTimer(Handle hTimer)
{
	char sError[256];
	g_hDatabase = SQL_Connect("levels_ranks", false, sError, 256);

	if(!g_hDatabase)
	{
		g_iCountRetryConnect++;
		if(g_iCountRetryConnect == g_iDBReconnectCount)
		{
			CrashLR("The attempt to restore the connection was failed, plugin disabled (%s)", sError);
		}
		else LogLR("The attempt to restore the connection was failed #%i", g_iCountRetryConnect);
	}
	else
	{
		g_hDatabase.SetCharset("utf8");
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

/*
* Fix name by Феникс
*/
char[] GetFixNamePlayer(int iClient)
{
	char sName[MAX_NAME_LENGTH * 2 + 1];
	GetClientName(iClient, sName, sizeof(sName));

	for(int i = 0, len = strlen(sName), CharBytes; i < len;)
	{
		if((CharBytes = GetCharBytes(sName[i])) == 4)
		{
			len -= 4;
			for(int u = i; u <= len; u++)
			{
				sName[u] = sName[u+4];
			}
		}
		else i += CharBytes;
	}
	return sName;
}