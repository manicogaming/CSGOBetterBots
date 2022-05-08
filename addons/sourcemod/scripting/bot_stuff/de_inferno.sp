public void PrepareInfernoExecutes()
{
	int[] clients = new int[MaxClients];
	
	Client_Get(clients, CLIENTFILTER_TEAMONE | CLIENTFILTER_BOTS);
	
	if (IsValidClient(clients[0]) && IsValidClient(clients[1]) && IsValidClient(clients[2]) && IsValidClient(clients[3]) && IsValidClient(clients[4]))
	{
		if(g_iCurrentRound == 0 || g_iCurrentRound == 15)
		{
			switch (g_iRndExecute)
			{
				case 1: //NIP Pistol B Split					<----- I was here
				{
					BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_inferno/NIP Pistol B Split/device Role.rec");
					BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_inferno/NIP Pistol B Split/hampus Role.rec");
					BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_inferno/NIP Pistol B Split/LNZ Role.rec");
					BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_inferno/NIP Pistol B Split/Plopski Role.rec");
					BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_inferno/NIP Pistol B Split/REZ Role.rec");
				}
				case 2: //Liquid Pistol Halls Pop
				{
					BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_inferno/Liquid Pistol Halls Pop/NAF Role.rec");
					BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_inferno/Liquid Pistol Halls Pop/Grim Role.rec");
					BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_inferno/Liquid Pistol Halls Pop/Stewie2K Role.rec");
					BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_inferno/Liquid Pistol Halls Pop/FalleN Role.rec");
					BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_inferno/Liquid Pistol Halls Pop/EliGE Role.rec");
				}
				case 3: //G2 Pistol Long Wrap
				{
					BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_inferno/G2 Pistol Long Wrap/AmaNEk Role.rec");
					BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_inferno/G2 Pistol Long Wrap/huNter- Role.rec");
					BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_inferno/G2 Pistol Long Wrap/JACKZ Role.rec");
					BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_inferno/G2 Pistol Long Wrap/nexa Role.rec");
					BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_inferno/G2 Pistol Long Wrap/NiKo Role.rec");
				}
				case 4: //BIG Pistol Aps Pop
				{
					BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_inferno/BIG Pistol Aps Pop/tabseN Role.rec");
					BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_inferno/BIG Pistol Aps Pop/tiziaN Role.rec");
					BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_inferno/BIG Pistol Aps Pop/XANTARES Role.rec");
					BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_inferno/BIG Pistol Aps Pop/k1to Role.rec");
					BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_inferno/BIG Pistol Aps Pop/syrsoN Role.rec");
				}
				case 5: //OG Pistol B Execute
				{
					BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_inferno/OG Pistol B Execute/Aleksib Role.rec");
					BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_inferno/OG Pistol B Execute/ISSAA Role.rec");
					BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_inferno/OG Pistol B Execute/mantuu Role.rec");
					BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_inferno/OG Pistol B Execute/niko Role.rec");
					BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_inferno/OG Pistol B Execute/valde Role.rec");
				}
				case 6: //Fnatic Pistol B Split
				{
					BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_inferno/Fnatic Pistol B Split/Brollan Role.rec");
					BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_inferno/Fnatic Pistol B Split/flusha Role.rec");
					BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_inferno/Fnatic Pistol B Split/KRIMZ Role.rec");
					BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_inferno/Fnatic Pistol B Split/Golden Role.rec");
					BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_inferno/Fnatic Pistol B Split/JW Role.rec");
				}
				case 7: //Liquid Pistol A Execute
				{
					BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_inferno/Liquid Pistol A Execute/Stewie2K Role.rec");
					BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_inferno/Liquid Pistol A Execute/Twistzz Role.rec");
					BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_inferno/Liquid Pistol A Execute/EliGE Role.rec");
					BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_inferno/Liquid Pistol A Execute/NAF Role.rec");
					BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_inferno/Liquid Pistol A Execute/nitr0 Role.rec");
				}
			}
		}
		else
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
				case 11: //Spirit Lane Execute
				{
					BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_inferno/Spirit Lane Execute/sdy Role.rec");
					BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_inferno/Spirit Lane Execute/mir Role.rec");
					BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_inferno/Spirit Lane Execute/chopper Role.rec");
					BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_inferno/Spirit Lane Execute/iDISBALANCE Role.rec");
					BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_inferno/Spirit Lane Execute/tarik Role.rec");
				}
				case 12: //FaZe B Pop
				{
					BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_inferno/FaZe B Pop/Kjaerbye Role.rec");
					BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_inferno/FaZe B Pop/broky Role.rec");
					BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_inferno/FaZe B Pop/rain Role.rec");
					BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_inferno/FaZe B Pop/NiKo Role.rec");
					BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_inferno/FaZe B Pop/coldzera Role.rec");
				}
				case 13: //Cloud9 A Execute
				{
					BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_inferno/Cloud9 A Execute/Sonic Role.rec");
					BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_inferno/Cloud9 A Execute/floppy Role.rec");
					BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_inferno/Cloud9 A Execute/JT Role.rec");
					BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_inferno/Cloud9 A Execute/motm Role.rec");
					BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_inferno/Cloud9 A Execute/oSee Role.rec");
				}
				case 14: //mouz A Crunch
				{
					BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_inferno/mouz A Crunch/chrisJ Role.rec");
					BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_inferno/mouz A Crunch/frozen Role.rec");
					BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_inferno/mouz A Crunch/ropz Role.rec");
					BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_inferno/mouz A Crunch/woxic Role.rec");
					BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_inferno/mouz A Crunch/karrigan Role.rec");
				}
				case 15: //EG Aps Pop
				{
					BotMimic_PlayRecordFromFile(clients[0], "addons/sourcemod/data/botmimic/Executes/de_inferno/EG Aps Pop/stanislaw Role.rec");
					BotMimic_PlayRecordFromFile(clients[1], "addons/sourcemod/data/botmimic/Executes/de_inferno/EG Aps Pop/Ethan Role.rec");
					BotMimic_PlayRecordFromFile(clients[2], "addons/sourcemod/data/botmimic/Executes/de_inferno/EG Aps Pop/Brehze Role.rec");
					BotMimic_PlayRecordFromFile(clients[3], "addons/sourcemod/data/botmimic/Executes/de_inferno/EG Aps Pop/tarik Role.rec");
					BotMimic_PlayRecordFromFile(clients[4], "addons/sourcemod/data/botmimic/Executes/de_inferno/EG Aps Pop/CeRq Role.rec");
				}
			}
		}
	}
}