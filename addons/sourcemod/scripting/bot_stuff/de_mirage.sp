public void PrepareMirageExecutes()
{
	int[] clients = new int[MaxClients];
	
	Client_Get(clients, CLIENTFILTER_TEAMONE | CLIENTFILTER_BOTS);
	
	if (IsValidClient(clients[0]) && IsValidClient(clients[1]) && IsValidClient(clients[2]) && IsValidClient(clients[3]) && IsValidClient(clients[4]))
	{
		switch (g_iRndExecute)
		{
			case 1: //A Execute
			{
				BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_mirage/A Execute/CT Smoke & Lamp Flash.rec");
				BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_mirage/A Execute/AWP Player.rec");
				BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_mirage/A Execute/Stairs Smoke & Sandwich Molotov.rec");
				BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_mirage/A Execute/Jungle Smoke.rec");
				BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_mirage/A Execute/Palace Player.rec");
			}
			case 2: //Mid Execute
			{
				BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_mirage/Mid Execute/Short Smoke & Under Molotov.rec"); 
				BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_mirage/Mid Execute/AWP Player.rec");
				BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_mirage/Mid Execute/Top Con Smoke.rec");
				BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_mirage/Mid Execute/Top Mid Smoke & Mid Flash.rec");
				BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_mirage/Mid Execute/Window Smoke & Connector Molotov.rec");
			}
			case 3: //B Execute
			{
				BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_mirage/B Execute/Arches Smoke.rec"); 
				BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_mirage/B Execute/AWP Player.rec");
				BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_mirage/B Execute/Left Arches Smoke.rec");
				BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_mirage/B Execute/Market Door Smoke.rec");
				BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_mirage/B Execute/Market Window Smoke.rec");
			}
			case 4: //99 Win Execute
			{
				BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_mirage/99 Win Execute/Stairs Smoke.rec"); 
				BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_mirage/99 Win Execute/Safe Plant Smoke.rec");
				BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_mirage/99 Win Execute/Close Triple Smoke.rec");
				BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_mirage/99 Win Execute/Under Palace Smoke.rec");
				BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_mirage/99 Win Execute/Close Jungle Smoke.rec");
			}
			case 5: //NIP A Execute
			{
				BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_mirage/NIP A Execute/hampus Role.rec"); 
				BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_mirage/NIP A Execute/nawwk Role.rec");
				BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_mirage/NIP A Execute/twist Role.rec");
				BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_mirage/NIP A Execute/Plopski Role.rec");
				BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_mirage/NIP A Execute/REZ Role.rec");
			}
			case 6: //Heroic Fast A Execute
			{
				BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_mirage/Heroic Fast A Execute/b0RUP Role.rec"); 
				BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_mirage/Heroic Fast A Execute/cadiaN Role.rec");
				BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_mirage/Heroic Fast A Execute/niko Role.rec");
				BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_mirage/Heroic Fast A Execute/stavn Role.rec");
				BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_mirage/Heroic Fast A Execute/TeSeS Role.rec");
			}
			case 7: //TYLOO A Execute
			{
				BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_mirage/TYLOO A Execute/Attacker Role.rec"); 
				BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_mirage/TYLOO A Execute/xeta Role.rec");
				BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_mirage/TYLOO A Execute/somebody Role.rec");
				BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_mirage/TYLOO A Execute/Freeman Role.rec");
				BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_mirage/TYLOO A Execute/Summer Role.rec");
			}
			case 8: //mousesports Fast B Execute
			{
				BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_mirage/mousesports Fast B Execute/chrisJ Role.rec"); 
				BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_mirage/mousesports Fast B Execute/woxic Role.rec");
				BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_mirage/mousesports Fast B Execute/frozen Role.rec");
				BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_mirage/mousesports Fast B Execute/karrigan Role.rec");
				BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_mirage/mousesports Fast B Execute/ropz Role.rec");
			}
		}
	}
}