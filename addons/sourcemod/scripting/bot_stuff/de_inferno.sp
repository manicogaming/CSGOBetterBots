public void PrepareInfernoExecutes()
{
	int[] clients = new int[MaxClients];
	
	Client_Get(clients, CLIENTFILTER_TEAMONE | CLIENTFILTER_BOTS);
	
	if (IsValidClient(clients[0]) && IsValidClient(clients[1]) && IsValidClient(clients[2]) && IsValidClient(clients[3]) && IsValidClient(clients[4]))
	{
		switch (g_iRndExecute)
		{
			case 1: //B Execute
			{
				BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_inferno/B Execute/CT Smoke.rec");
				BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_inferno/B Execute/Dark Molotov.rec");
				BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_inferno/B Execute/Coffins Smoke.rec");
				BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_inferno/B Execute/1st & 2nd Box Molotov.rec");
				BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_inferno/B Execute/NewBox Molotov.rec");
			}
			case 2: //A Short & Apps Execute
			{
				BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_inferno/A Short & Apps Execute/Long Smoke.rec");
				BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_inferno/A Short & Apps Execute/Moto Smoke.rec");
				BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_inferno/A Short & Apps Execute/Pit Smoke.rec");
				BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_inferno/A Short & Apps Execute/Balcony Smoke.rec");
				BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_inferno/A Short & Apps Execute/Apps Support Player.rec");
			}
			case 3: //A Long Execute
			{
				BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_inferno/A Long Execute/Short Smoke.rec");
				BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_inferno/A Long Execute/Cubby Molotov.rec");
				BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_inferno/A Long Execute/Arch Smoke.rec");
				BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_inferno/A Long Execute/Library Smoke.rec");
				BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_inferno/A Long Execute/Site Smoke.rec");
			}
		}
	}
}