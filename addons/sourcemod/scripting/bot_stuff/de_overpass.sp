public void PrepareOverpassExecutes()
{
	int[] clients = new int[MaxClients];
	
	Client_Get(clients, CLIENTFILTER_TEAMONE | CLIENTFILTER_BOTS);
	
	if (IsValidClient(clients[0]) && IsValidClient(clients[1]) && IsValidClient(clients[2]) && IsValidClient(clients[3]) && IsValidClient(clients[4]))
	{
		if(g_iCurrentRound == 0 || g_iCurrentRound == 15)
		{
			switch (g_iRndExecute)
			{
				case 1: //Liquid Pistol A Execute
				{
					BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_overpass/Liquid Pistol A Execute/Stewie2K Role.rec");
					BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_overpass/Liquid Pistol A Execute/nitr0 Role.rec");
					BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_overpass/Liquid Pistol A Execute/Twistzz Role.rec");
					BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_overpass/Liquid Pistol A Execute/EliGE Role.rec");
					BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_overpass/Liquid Pistol A Execute/NAF Role.rec");
				}
			}
		}
		else
		{
			switch (g_iRndExecute)
			{
				case 1: //A Execute
				{
					BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_overpass/A Execute/Truck Smoke.rec");
					BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_overpass/A Execute/AWP Player.rec");
					BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_overpass/A Execute/Mid Site Smoke.rec");
					BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_overpass/A Execute/Van Smoke.rec");
					BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_overpass/A Execute/Long Player.rec");
				}
				case 2: //B Execute
				{
					BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_overpass/B Execute/Pit Smoke.rec");
					BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_overpass/B Execute/B Site Smoke & Monster Flash.rec");
					BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_overpass/B Execute/Balcony Smoke & Short Molotov.rec");
					BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_overpass/B Execute/Bridge Smoke.rec");
					BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_overpass/B Execute/Toxic Molotov & Site Flash.rec");
				}
			}
		}
	}
}