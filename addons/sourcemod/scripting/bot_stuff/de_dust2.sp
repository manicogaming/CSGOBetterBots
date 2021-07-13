public void PrepareDust2Executes()
{
	int[] clients = new int[MaxClients];
	
	Client_Get(clients, CLIENTFILTER_TEAMONE | CLIENTFILTER_BOTS);
	
	if (IsValidClient(clients[0]) && IsValidClient(clients[1]) && IsValidClient(clients[2]) && IsValidClient(clients[3]) && IsValidClient(clients[4]))
	{
		switch (g_iRndExecute)
		{
			case 1: //B Execute
			{
				BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_dust2/B Execute/B Doors Smoke.rec");
				BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_dust2/B Execute/AWP Player.rec");
				BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_dust2/B Execute/Early Flashes & Site Molotov.rec");
				BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_dust2/B Execute/B Hold Player.rec");
				BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_dust2/B Execute/Entrance Smoke & Back Plat Molotov.rec");
			}
			case 2: //Short A Execute
			{
				BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_dust2/Short A Execute/XBOX Smoke & A Flashes.rec");
				BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_dust2/Short A Execute/Short Support Flash & Site Molotov.rec");
				BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_dust2/Short A Execute/A Short Smoke.rec");
				BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_dust2/Short A Execute/Dumpster One Way.rec");
				BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_dust2/Short A Execute/Site Smoke & Goose Molotov.rec");
			}
			case 3: //Long A Execute
			{
				BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_dust2/Long A Execute/Long Corner Smoke.rec");
				BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_dust2/Long A Execute/AWP Player.rec");
				BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_dust2/Long A Execute/Fast Long Player.rec");
				BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_dust2/Long A Execute/CT Smoke & Car Molotov.rec");
				BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_dust2/Long A Execute/Long Cross Smoke.rec");
			}
			case 4: //NAVI B Execute
			{
				BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_dust2/NAVI B Execute/Boombl4 Role.rec");
				BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_dust2/NAVI B Execute/s1mple Role.rec");
				BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_dust2/NAVI B Execute/electronic Role.rec");
				BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_dust2/NAVI B Execute/flamie Role.rec");
				BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_dust2/NAVI B Execute/Perfecto Role.rec");
			}
			case 5: //Astralis A Execute
			{
				BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_dust2/Astralis A Execute/gla1ve Role.rec");
				BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_dust2/Astralis A Execute/device Role.rec");
				BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_dust2/Astralis A Execute/Magisk Role.rec");
				BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_dust2/Astralis A Execute/dupreeh Role.rec");
				BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_dust2/Astralis A Execute/es3tag Role.rec");
			}
			case 6: //Vitality A Split
			{
				BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_dust2/Vitality A Split/Nivera Role.rec");
				BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_dust2/Vitality A Split/ZywOo Role.rec");
				BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_dust2/Vitality A Split/apEX Role.rec");
				BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_dust2/Vitality A Split/RpK Role.rec");
				BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_dust2/Vitality A Split/shox Role.rec");
			}
			case 7: //Vitality B Split
			{
				BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_dust2/Vitality B Split/Nivera Role.rec");
				BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_dust2/Vitality B Split/ZywOo Role.rec");
				BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_dust2/Vitality B Split/apEX Role.rec");
				BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_dust2/Vitality B Split/RpK Role.rec");
				BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_dust2/Vitality B Split/shox Role.rec");
			}
		}
	}
}