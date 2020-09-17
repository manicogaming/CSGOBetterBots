void LoadDatabase()
{
	if (!g_cvarEnabled.BoolValue)
	{
		return;
	}

	if (g_Database != null)
	{
		LogMessage("(WeaponStickers) Database is already connected! (Handle: %d)", g_Database);
		return;
	}

	Database.Connect(SQLCallback_Connect, MySQL_DATABASE);
}

void LoadClientData(int client)
{
	if (g_Database == null)
	{
		return;
	}

	if (!ClientHasFlag(client, g_requiredFlag))
	{
		return;
	}

	char authId[MAX_LENGTH_AUTHID];
	if (!GetClientAuthId(client, AuthId_Steam3, authId, sizeof(authId)))
	{
		LogError("[LoadClientData] Auth failed for client index %d", client);
		return;
	}

	char query[512];
	FormatEx(query, sizeof(query), "SELECT * FROM %s WHERE steamid = \"%s\";", MySQL_TABLE, authId);
	g_Database.Query(SQLCallback_LoadClientData, query, GetClientUserId(client));
}

void UpdateClientData(int client, int index, int slot)
{
	if (!client || !IsClientInGame(client))
	{
		return;
	}

	char authId[MAX_LENGTH_AUTHID];
	if (!GetClientAuthId(client, AuthId_Steam3, authId, sizeof(authId)))
	{
		LogError("[UpdateClientData] Auth failed for client index %d", client);
		return;
	}

	int defIndex = eItems_GetWeaponDefIndexByWeaponNum(index);
	if (!IsValidDefIndex(defIndex))
	{
		LogError("[UpdateClientData] Weapon failed for client index %d", client);
		return;
	}

	// Update reuse time.
	g_playerReuseTime[client] = GetTime() + g_cvarReuseTime.IntValue;

	// Update MySQL.
	char query[2048];
	FormatEx(query, sizeof(query), "INSERT INTO %s (`steamid`, `weaponindex`, `slot%i`) VALUES (\"%s\", '%i', '%i') ON DUPLICATE KEY UPDATE slot%i = '%i';", MySQL_TABLE, slot, authId, defIndex, g_PlayerWeapon[client][index].m_sticker[slot], slot, g_PlayerWeapon[client][index].m_sticker[slot]);

	g_Database.Query(SQLCallback_UpdateClientData, query);
}

/**
 * Callbacks.
 */
public Action Timer_RetryMySQL(Handle timer)
{
	LogMessage("(WeaponStickers) Reconnecting...");

	LoadDatabase();
	return Plugin_Stop;
}

public void SQLCallback_Connect(Database db, const char[] error, any data)
{
	if (db == null || strlen(error) > 0)
	{
		LogError("(WeaponStickers) Connection to database failed: %s", error);
		CreateTimer(5.0, Timer_RetryMySQL);
	}
	else
	{
		DBDriver driver = db.Driver;

		char buffer[32];
		driver.GetIdentifier(buffer, sizeof(buffer));

		if (!StrEqual(buffer, "mysql", false))
		{
			SetFailState("(WeaponStickers) Connection to database failed: Only MySQL support!");
			return;
		}

		delete driver;
		g_Database = db;

		// Create tables if not exists.
		char query[1024];
		FormatEx(query, sizeof(query),
		"CREATE TABLE IF NOT EXISTS `%s` ( \
			`id` INT NOT NULL AUTO_INCREMENT, \
			`steamid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL, \
			`weaponindex` int(11) NOT NULL DEFAULT '0', \
			`slot0` int(11) NOT NULL DEFAULT '0', \
			`slot1` int(11) NOT NULL DEFAULT '0', \
			`slot2` int(11) NOT NULL DEFAULT '0', \
			`slot3` int(11) NOT NULL DEFAULT '0', \
			`slot4` int(11) NOT NULL DEFAULT '0', \
			`slot5` int(11) NOT NULL DEFAULT '0', \
			PRIMARY KEY (`id`), \
			UNIQUE KEY (`steamid`, `weaponindex`) \
			) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;", MySQL_TABLE);
		g_Database.Query(SQLCallback_CreateTable, query);

		LogMessage("(WeaponStickers) We have a connection!");
	}
}

public void SQLCallback_CreateTable(Database db, DBResultSet results, const char[] error, any data)
{
	if (db == null || strlen(error) > 0)
	{
		LogError("(SQLCallback_CreateTable) Fail at Query: %s", error);
	}
}

public void SQLCallback_LoadClientData(Database db, DBResultSet results, const char[] error, any data)
{
	if (db == null || strlen(error) > 0)
	{
		LogError("(SQLCallback_LoadClientData) Fail at Query: %s", error);
	}
	else
	{
		if (results.HasResults)
		{
			int client = GetClientOfUserId(data);

			if (client && IsClientInGame(client))
			{
				while (results.FetchRow())
				{
					// Get weapon defIndex and check if is valid to stickers.
					int defIndex = results.FetchInt(2);
					if (IsValidDefIndex(defIndex))
					{
						// Get weapon index.
						int weaponIndex = eItems_GetWeaponNumByDefIndex(defIndex);
						if (weaponIndex != -1)
						{
							g_PlayerWeapon[client][weaponIndex].m_sticker[0] = results.FetchInt(3);
							g_PlayerWeapon[client][weaponIndex].m_sticker[1] = results.FetchInt(4);
							g_PlayerWeapon[client][weaponIndex].m_sticker[2] = results.FetchInt(5);
							g_PlayerWeapon[client][weaponIndex].m_sticker[3] = results.FetchInt(6);
							g_PlayerWeapon[client][weaponIndex].m_sticker[4] = results.FetchInt(7);
							g_PlayerWeapon[client][weaponIndex].m_sticker[5] = results.FetchInt(8);
						}
					}
				}
			}
		}
	}
}

public void SQLCallback_UpdateClientData(Database db, DBResultSet results, const char[] error, any data)
{
	if (db == null || strlen(error) > 0)
	{
		LogError("(SQLCallback_UpdateClientData) Fail at Query: %s", error);
	}
}