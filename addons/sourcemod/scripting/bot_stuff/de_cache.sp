public void PrepareCacheExecutes()
{
	int[] clients = new int[MaxClients];
	
	Client_Get(clients, CLIENTFILTER_TEAMONE | CLIENTFILTER_BOTS);
	
	if (IsValidClient(clients[0]) && IsValidClient(clients[1]) && IsValidClient(clients[2]) && IsValidClient(clients[3]) && IsValidClient(clients[4]))
	{
		switch (g_iRndExecute)
		{
			case 1: //A Execute
			{
				BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_cache/A Execute/A Cross Smoke.rec");
				BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_cache/A Execute/AWP Player.rec");
				BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_cache/A Execute/A Default Smoke.rec");
				BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_cache/A Execute/A Balcony Smoke.rec");
				BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_cache/A Execute/A Main Player.rec");
			}
			case 2: //Mid Execute
			{
				BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_cache/Mid Execute/Mid Left Smoke.rec");
				BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_cache/Mid Execute/AWP Player.rec");
				BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_cache/Mid Execute/Mid Right Smoke.rec");
				BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_cache/Mid Execute/B Push Player.rec");
				BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_cache/Mid Execute/Mid Push Player.rec");
			}
			case 3: //B Execute
			{
				BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_cache/B Execute/CT Smoke.rec");
				BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_cache/B Execute/AWP Player.rec");
				BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_cache/B Execute/Spray Molotov.rec");
				BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_cache/B Execute/Headshot Molotov.rec");
				BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_cache/B Execute/B Control Player.rec");
			}
		}
	}
}