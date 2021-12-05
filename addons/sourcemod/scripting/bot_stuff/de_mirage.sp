public void PrepareMirageExecutes()
{
	int[] clients = new int[MaxClients];
	
	Client_Get(clients, CLIENTFILTER_TEAMONE | CLIENTFILTER_BOTS);
	
	if (IsValidClient(clients[0]) && IsValidClient(clients[1]) && IsValidClient(clients[2]) && IsValidClient(clients[3]) && IsValidClient(clients[4]))
	{
		if(g_iCurrentRound == 0 || g_iCurrentRound == 15)
		{
			switch (g_iRndExecute)
			{
				case 1: //NIP Pistol A Execute
				{
					BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_mirage/NIP Pistol A Execute/device Role.rec");
					BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_mirage/NIP Pistol A Execute/hampus Role.rec");
					BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_mirage/NIP Pistol A Execute/REZ Role.rec");
					BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_mirage/NIP Pistol A Execute/Plopski Role.rec");
					BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_mirage/NIP Pistol A Execute/LNZ Role.rec");
				}
			}
		}
		else
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
				case 9: //Vitality A Execute
				{
					BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_mirage/Vitality A Execute/apEX Role.rec"); 
					BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_mirage/Vitality A Execute/ZywOo Role.rec");
					BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_mirage/Vitality A Execute/Kyojin Role.rec");
					BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_mirage/Vitality A Execute/misutaaa Role.rec");
					BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_mirage/Vitality A Execute/shox Role.rec");
				}
				case 10: //NAVI B Execute
				{
					BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_mirage/NAVI B Execute/Boombl4 Role.rec"); 
					BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_mirage/NAVI B Execute/s1mple Role.rec");
					BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_mirage/NAVI B Execute/electronic Role.rec");
					BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_mirage/NAVI B Execute/flamie Role.rec");
					BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_mirage/NAVI B Execute/Perfecto Role.rec");
				}
				case 11: //FURIA Fast B Split
				{
					BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_mirage/FURIA Fast B Split/arT Role.rec"); 
					BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_mirage/FURIA Fast B Split/HEN1 Role.rec");
					BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_mirage/FURIA Fast B Split/KSCERATO Role.rec");
					BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_mirage/FURIA Fast B Split/VINI Role.rec");
					BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_mirage/FURIA Fast B Split/yuurih Role.rec");
				}
				case 12: //VP A Execute
				{
					BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_mirage/VP A Execute/buster Role.rec"); 
					BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_mirage/VP A Execute/Jame Role.rec");
					BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_mirage/VP A Execute/Qikert Role.rec");
					BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_mirage/VP A Execute/SANJI Role.rec");
					BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_mirage/VP A Execute/YEKINDAR Role.rec");
				}
				case 13: //G2 Connector Pop
				{
					BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_mirage/G2 Connector Pop/AmaNEk Role.rec"); 
					BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_mirage/G2 Connector Pop/kennyS Role.rec");
					BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_mirage/G2 Connector Pop/huNter- Role.rec");
					BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_mirage/G2 Connector Pop/nexa Role.rec");
					BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_mirage/G2 Connector Pop/NiKo Role.rec");
				}
				case 14: //FaZe Fast B Rush
				{
					BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_mirage/FaZe Fast B Rush/NEO Role.rec"); 
					BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_mirage/FaZe Fast B Rush/GuardiaN Role.rec");
					BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_mirage/FaZe Fast B Rush/NiKo Role.rec");
					BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_mirage/FaZe Fast B Rush/olofmeister Role.rec");
					BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_mirage/FaZe Fast B Rush/rain Role.rec");
				}
				case 15: //FaZe Palace Pop
				{
					BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_mirage/FaZe Palace Pop/coldzera Role.rec"); 
					BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_mirage/FaZe Palace Pop/broky Role.rec");
					BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_mirage/FaZe Palace Pop/NiKo Role.rec");
					BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_mirage/FaZe Palace Pop/olofmeister Role.rec");
					BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_mirage/FaZe Palace Pop/rain Role.rec");
				}
				case 16: //BIG Aps Pop
				{
					BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_mirage/BIG Aps Pop/k1to Role.rec"); 
					BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_mirage/BIG Aps Pop/syrsoN Role.rec");
					BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_mirage/BIG Aps Pop/tabseN Role.rec");
					BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_mirage/BIG Aps Pop/tiziaN Role.rec");
					BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_mirage/BIG Aps Pop/XANTARES Role.rec");
				}
				case 17: //mousesports A Split Rush
				{
					BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_mirage/mousesports A Split Rush/chrisJ Role.rec"); 
					BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_mirage/mousesports A Split Rush/woxic Role.rec");
					BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_mirage/mousesports A Split Rush/frozen Role.rec");
					BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_mirage/mousesports A Split Rush/karrigan Role.rec");
					BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_mirage/mousesports A Split Rush/ropz Role.rec");
				}
				case 18: //G2 Mirage A Split
				{
					BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_mirage/G2 Mirage A Split/nexa Role.rec"); 
					BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_mirage/G2 Mirage A Split/NiKo Role.rec");
					BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_mirage/G2 Mirage A Split/AmaNEk Role.rec");
					BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_mirage/G2 Mirage A Split/huNter- Role.rec");
					BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_mirage/G2 Mirage A Split/JACKZ Role.rec");
				}
				case 19: //Vitality A Split
				{
					BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_mirage/Vitality A Split/apEX Role.rec"); 
					BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_mirage/Vitality A Split/ZywOo Role.rec");
					BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_mirage/Vitality A Split/Kyojin Role.rec");
					BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_mirage/Vitality A Split/misutaaa Role.rec");
					BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_mirage/Vitality A Split/shox Role.rec");
				}
				case 20: //ENCE Fake A Fake B
				{
					BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_mirage/ENCE Fake A Fake B/doto Role.rec"); 
					BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_mirage/ENCE Fake A Fake B/hades Role.rec");
					BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_mirage/ENCE Fake A Fake B/dycha Role.rec");
					BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_mirage/ENCE Fake A Fake B/Snappi Role.rec");
					BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_mirage/ENCE Fake A Fake B/Spinx Role.rec");
				}
			}
		}
	}
}