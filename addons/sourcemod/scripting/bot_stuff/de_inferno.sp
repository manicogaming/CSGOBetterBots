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
			case 4: //Heroic A Arch
			{
				BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_inferno/Heroic A Arch/niko Role.rec");
				BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_inferno/Heroic A Arch/cadiaN Role.rec");
				BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_inferno/Heroic A Arch/b0RUP Role.rec");
				BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_inferno/Heroic A Arch/TeSeS Role.rec");
				BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_inferno/Heroic A Arch/stavn Role.rec");
			}
			case 5: //Heroic B Execute
			{
				BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_inferno/Heroic B Execute/niko Role.rec");
				BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_inferno/Heroic B Execute/cadiaN Role.rec");
				BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_inferno/Heroic B Execute/b0RUP Role.rec");
				BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_inferno/Heroic B Execute/TeSeS Role.rec");
				BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_inferno/Heroic B Execute/stavn Role.rec");
			}
			case 6: //G2 Fast A Execute
			{
				BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_inferno/G2 Fast A Execute/AmaNEk Role.rec");
				BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_inferno/G2 Fast A Execute/kennyS Role.rec");
				BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_inferno/G2 Fast A Execute/huNter- Role.rec");
				BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_inferno/G2 Fast A Execute/NiKo Role.rec");
				BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_inferno/G2 Fast A Execute/nexa Role.rec");
			}
			case 7: //Astralis Apps Execute
			{
				BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_inferno/Astralis Apps Execute/gla1ve Role.rec");
				BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_inferno/Astralis Apps Execute/device Role.rec");
				BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_inferno/Astralis Apps Execute/Xyp9x Role.rec");
				BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_inferno/Astralis Apps Execute/Magisk Role.rec");
				BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_inferno/Astralis Apps Execute/dupreeh Role.rec");
			}
			case 8: //Cloud9 Lane Pop
			{
				BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_inferno/Cloud9 Lane Pop/mezii Role.rec");
				BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_inferno/Cloud9 Lane Pop/ALEX Role.rec");
				BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_inferno/Cloud9 Lane Pop/floppy Role.rec");
				BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_inferno/Cloud9 Lane Pop/Xeppaa Role.rec");
				BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_inferno/Cloud9 Lane Pop/es3tag Role.rec");
			}
			case 9: //Astralis B Pop
			{
				BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_inferno/Astralis B Pop/gla1ve Role.rec");
				BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_inferno/Astralis B Pop/device Role.rec");
				BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_inferno/Astralis B Pop/es3tag Role.rec");
				BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_inferno/Astralis B Pop/Magisk Role.rec");
				BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_inferno/Astralis B Pop/dupreeh Role.rec");
			}
			case 10: //Vitality Apps Pop
			{
				BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_inferno/Vitality Apps Pop/apEX Role.rec");
				BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_inferno/Vitality Apps Pop/ZywOo Role.rec");
				BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_inferno/Vitality Apps Pop/RpK Role.rec");
				BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_inferno/Vitality Apps Pop/misutaaa Role.rec");
				BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_inferno/Vitality Apps Pop/shox Role.rec");
			}
		}
	}
}