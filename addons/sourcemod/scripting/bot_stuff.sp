#pragma semicolon 1

#include <sourcemod>
#include <clientprefs>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>

#pragma newdecls required

bool g_bShouldAttack[MAXPLAYERS + 1];
Handle g_hShouldAttackTimer[MAXPLAYERS + 1];
int g_iaGrenadeOffsets[] = {15, 17, 16, 14, 18, 17};
int g_iProfileRank[MAXPLAYERS+1], g_iCoin[MAXPLAYERS+1],g_iProfileRankOffset, g_iCoinOffset;

char g_sTRngGrenadesList[][] = {
    "weapon_flashbang",
    "weapon_smokegrenade",
    "weapon_hegrenade",
    "weapon_molotov"
};

char g_sCTRngGrenadesList[][] = {
    "weapon_flashbang",
    "weapon_smokegrenade",
    "weapon_hegrenade",
    "weapon_incgrenade"
};

char g_BotName[][] = {
	"XD | ryu",
	"dDeath of the ART",
	"[[MxD]]X the Driplet",
	"-FaK- Phakkle of War",
	"monday",
	"[[MxD]] ChampLamp",
	"-FaK- My Sunset",
	"[[MxD]]Azimuth",
	"-FaK- The Slow Red_Fox",
	"[SPI]KoriKen Design",
	"[[tiMmaH!]]RamboGunther1337",
	"[[tiMaH!]]wolf-fang",
	"[[MxD]]DaZZerMAXX",
	"-FaK- Onslaught",
	"[[tiMaH!]]hula",
	"[[MxD]]Ne0nfaktory",
	"-FaK- ThE worlD th*t eNded yEsterdayoF lAStw33k",
	"BLuE RoMeN DeLUXe",
	"[[MxD]]ConTour",
	"[SPI]itchetrigr",
	"-FaK- JuZak",
	"[[tiMaH!]]Gen.TsoVicious",
	"-FaK- TuB",
	"[SPI]FrunkenmeisteR",
	"-FaK- .T3ch_N0ne.*",
	"[SPI]Zed-Len",
	"[[MxD]]xb9manina",
	"[[tiMaH!]]Furious_DC",
	"MIBR coldzera",
	"MIBR FalleN",
	"MIBR fer",
	"MIBR TACO",
	"MIBR felps",
	"FaZe olofmeister",
	"FaZe GuardiaN",
	"FaZe NiKo",
	"FaZe rain",
	"FaZe AdreN",
	"Astralis Xyp9x",
	"Astralis device",
	"Astralis gla1ve",
	"Astralis Magisk",
	"Astralis dupreeh",
	"NiP GeT_RiGhT",
	"NiP draken",
	"NiP f0rest",
	"NiP Lekr0",
	"NiP REZ",
	"C9 kioShiMa",
	"C9 autimatic",
	"C9 vice",
	"C9 Golden",
	"C9 RUSH",
	"G2 shox",
	"G2 kennyS",
	"G2 Lucky",
	"G2 JaCkz",
	"G2 AMANEK",
	"fnatic twist",
	"fnatic JW",
	"fnatic KRiMZ",
	"fnatic Brollan",
	"fnatic Xizt",
	"North cadiaN",
	"North Kjaerbye",
	"North aizy",
	"North valde",
	"North gade",
	"mouz karrigan",
	"mouz chrisJ",
	"mouz woxic",
	"mouz frozen",
	"mouz ropz",
	"TyLoo Summer",
	"TyLoo Attacker",
	"TyLoo BnTneT",
	"TyLoo somebody",
	"TyLoo xccurate",
	"Gambit Ax1Le",
	"Gambit mou",
	"Gambit Dosia",
	"Gambit dimasick",
	"Gambit mir",
	"NRG daps",
	"NRG tarik",
	"NRG Brehze",
	"NRG nahtE",
	"NRG CeRq",
	"RNG AZR",
	"RNG jks",
	"RNG jkaem",
	"RNG Gratisfaction",
	"RNG Liazz",
	"Na´Vi electronic",
	"Na´Vi s1mple",
	"Na´Vi flamie",
	"Na´Vi Edward",
	"Na´Vi Zeus",
	"Liquid Stewie2K",
	"Liquid NAF",
	"Liquid nitr0",
	"Liquid ELiGE",
	"Liquid Twistzz",
	"HR ANGE1",
	"HR oskar",
	"HR Hobbit",
	"HR DeadFox",
	"HR ISSAA",
	"AGO Furlan",
	"AGO GruBy",
	"AGO kap3r",
	"AGO phr",
	"AGO SZPERO",
	"ENCE Aleksib",
	"ENCE allu",
	"ENCE sergej",
	"ENCE Aerial",
	"ENCE xseveN",
	"Vitality NBK-",
	"Vitality ZywOo",
	"Vitality apEX",
	"Vitality RpK",
	"Vitality ALEX",
	"BIG tiziaN",
	"BIG nex",
	"BIG XANTARES",
	"BIG tabseN",
	"BIG gob b",
	"AVANGAR buster",
	"AVANGAR Jame",
	"AVANGAR qikert",
	"AVANGAR fitch",
	"AVANGAR KrizzeN",
	"Windigo SHiPZ",
	"Windigo bubble",
	"Windigo v1c7oR",
	"Windigo blocker",
	"Windigo poizon",
	"Ghost Wardell",
	"Ghost koosta",
	"Ghost steel",
	"Ghost neptune",
	"Ghost freakazoid",
	"FURIA yuurih",
	"FURIA arT",
	"FURIA VINI",
	"FURIA kscerato",
	"FURIA ableJ",
	"Valience LETN1",
	"Valience ottoNd",
	"Valience huNter",
	"Valience nexa",
	"Valience EspiranTo",
	"coL dephh",
	"coL ShahZaM",
	"coL stanislaw",
	"coL Rickeh",
	"coL SicK",
	"ViCi zhokiNg",
	"ViCi kaze",
	"ViCi aumaN",
	"ViCi Freeman",
	"ViCi advent",
	"forZe facecrack",
	"forZe xsepower",
	"forZe FL1T",
	"forZe almazer",
	"forZe Jerry",
	"Winstrike Boombl4",
	"Winstrike Kvik",
	"Winstrike n0rb3r7",
	"Winstrike WorldEdit",
	"Winstrike bondik",
	"OpTic k0nfig",
	"OpTic JUGi",
	"OpTic niko",
	"OpTic Snappi",
	"OpTic refrezh",
	"Sprout denis",
	"Sprout syrsoN",
	"Sprout Spiidi",
	"Sprout faveN",
	"Sprout mirbit",
	"Heroic es3tag",
	"Heroic mertz",
	"Heroic friberg",
	"Heroic blameF",
	"Heroic stavn",
	"INTZ chelo",
	"INTZ kNgV-",
	"INTZ xand",
	"INTZ destinyy",
	"INTZ yeL",
	"VP MICHU",
	"VP snatchie",
	"VP byali",
	"VP Snax",
	"VP TOAO",
	"Apeks aNdz",
	"Apeks Marcelious",
	"Apeks Grusarn",
	"Apeks akEz",
	"Apeks Polly",
	"aTTaX stfN",
	"aTTaX slaxz",
	"aTTaX DuDe",
	"aTTaX kressy",
	"aTTaX mantuu",
	"Grayhound erkaSt",
	"Grayhound sico",
	"Grayhound dexter",
	"Grayhound DickStacy",
	"Grayhound malta",
	"LG NEKIZ",
	"LG HEN1",
	"LG steel",
	"LG LUCAS1",
	"LG boltz",
	"MVP.PK zeff",
	"MVP.PK xeta",
	"MVP.PK XigN",
	"MVP.PK Jinx",
	"MVP.PK stax",
	"Envy Nifty",
	"Envy jdm64",
	"Envy s0m",
	"Envy ANDROID",
	"Envy FugLy",
	"Spirit COLDYY1",
	"Spirit iDISBALANCE",
	"Spirit somedieyoung",
	"Spirit chopper",
	"Spirit S0tF1k",
	"Vega seized",
	"Vega jR",
	"Vega crush",
	"Vega scoobyxie",
	"Vega Fierce",
	"Swole Zellsis",
	"Swole swag",
	"Swole dapr",
	"Swole Infinite",
	"Swole Subroza",
	"CeX LiamjS",
	"CeX resu",
	"CeX Nukeddog",
	"CeX JamesBT",
	"CeX znx-",
	"LDLC devoduvek",
	"LDLC to1nou",
	"LDLC matHEND",
	"LDLC xms",
	"LDLC SIXER",
	"Defusekids v1N",
	"Defusekids G1DO",
	"Defusekids FASHR",
	"Defusekids Monu",
	"Defusekids rilax",
	"Epsilon Surreal",
	"Epsilon CRUC1AL",
	"Epsilon k1to",
	"Epsilon SPELLAN",
	"Epsilon broky",
	"Maxi matHEND",
	"Maxi MAIDHEN",
	"Maxi RobiNasTy",
	"Maxi SmyLi",
	"Maxi krL",
	"EP MiGHTYMAX",
	"EP Impulse",
	"EP Puls3",
	"EP Thomas",
	"EP aVN",
	"GLegion Ex6TenZ",
	"GLegion nawwk",
	"GLegion ScreaM",
	"GLegion HS",
	"GLegion hampus",
	"Berzerk SolEk",
	"Berzerk MALI",
	"Berzerk tahsiN",
	"Berzerk cello",
	"Berzerk syNx",
	"DIVIZON dominikkk",
	"DIVIZON ChrisWa",
	"DIVIZON croic",
	"DIVIZON n1kista",
	"DIVIZON TR1P"
};
 
public Plugin myinfo =
{
	name = "BOT Stuff",
	author = "manico",
	description = "Improves bots and does other things.",
	version = "1.0",
	url = "http://steamcommunity.com/id/manico001"
};

public void OnPluginStart()
{
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Post);
	HookEvent("round_start", OnRoundStart);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsFakeClient(i))
		{
			OnClientPostAdminCheck(i);
		}
	}
}

public void OnMapStart()
{
	g_iProfileRankOffset = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicLevel");
	g_iCoinOffset = FindSendPropInfo("CCSPlayerResource", "m_nActiveCoinRank");
	
	CreateTimer(1.0, Timer_CheckPlayer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	SDKHook(FindEntityByClassname(MaxClients + 1, "cs_player_manager"), SDKHook_ThinkPost, Hook_OnThinkPost);
}

public void OnMapEnd()
{
	SDKUnhook(FindEntityByClassname(MaxClients + 1, "cs_player_manager"), SDKHook_ThinkPost, Hook_OnThinkPost);
}

public void OnClientPostAdminCheck(int client)
{
	char botname[512];
	GetClientName(client, botname, sizeof(botname));
	
	for(int i = 0; i <= sizeof(g_BotName) - 1; i++)
	{
		if(StrContains(botname, g_BotName[i], false) != -1)
		{
			FakeClientCommand(client, "say !aimbot");
		}
	}
	
	g_iProfileRank[client] = GetRandomInt(1,40);
}

public void OnRoundStart(Handle event, char[] name, bool dbc)
{
	for(int i = 1; i <= MaxClients; i++)
    {
        if(IsClientInGame(i))
        {
            if(g_hShouldAttackTimer[i] != INVALID_HANDLE)
			{
				KillTimer(g_hShouldAttackTimer[i]);
				g_hShouldAttackTimer[i] = INVALID_HANDLE;
			}
        }
    }
}  

public void Hook_OnThinkPost(int iEnt)
{
	SetEntDataArray(iEnt, g_iProfileRankOffset, g_iProfileRank, MAXPLAYERS+1);
	SetEntDataArray(iEnt, g_iCoinOffset, g_iCoin, MAXPLAYERS+1);
}

public Action CS_OnBuyCommand(int client, const char[] weapon)
{
	if(IsFakeClient(client))
	{
		int m_iAccount = GetEntProp(client, Prop_Send, "m_iAccount");
		if(StrEqual(weapon,"m4a1"))
		{ 
			int iWeapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
			
			if(GetRandomInt(1,3) == 1)
			{
				if (iWeapon != -1)
				{
					RemovePlayerItem(client, iWeapon);
				}
				
				m_iAccount -= 3100;
				GivePlayerItem(client, "weapon_m4a1_silencer");
				if ((m_iAccount > 16000) || (m_iAccount < 0))
					m_iAccount = 1500;
				SetClientMoney(client, m_iAccount);
				return Plugin_Handled; 
			}
			else
			{
				return Plugin_Continue;
			}
		}
		else
		{
			return Plugin_Continue;
		}
	}
	else
	{
		return Plugin_Continue;
	}
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{  
    if (!IsFakeClient(client)) return Plugin_Continue;

    int ActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"); 
    if (ActiveWeapon == -1)  return Plugin_Continue;

    int index = GetEntProp(ActiveWeapon, Prop_Send, "m_iItemDefinitionIndex");  
    
    if (index == 43 || index == 44 || index == 45 || index == 46 || index == 48)
    {
        if (buttons & IN_ATTACK && g_bShouldAttack[client]) {
            // release attack
            buttons &= ~IN_ATTACK; 
            g_bShouldAttack[client] = false;
        }
        else {
            buttons |= IN_ATTACK; 

            if (g_hShouldAttackTimer[client] == null) {
                CreateTimer(2.0, Timer_ShouldAttack, GetClientSerial(client));
            }
        }

        return Plugin_Changed;
    } else if (g_hShouldAttackTimer[client] != null) {
        // kill timer since the client has switch weapon and it's pointless to continue
        KillTimer(g_hShouldAttackTimer[client], false);
        g_hShouldAttackTimer[client] = null;
        return Plugin_Continue;
    }

    return Plugin_Continue;
}

public Action Timer_CheckPlayer(Handle Timer, any data)
{
	for (int i = 1; i <= GetMaxClients(); i++)
	{
		if (IsClientInGame(i) && IsFakeClient(i))
		{
			int m_iAccount = GetEntProp(i, Prop_Send, "m_iAccount");
			
			
			if(GetRandomInt(1,10) == 1)
			{
				FakeClientCommand(i, "+lookatweapon");
				FakeClientCommand(i, "-lookatweapon");
			}
			
			if(m_iAccount == 800)
			{
				FakeClientCommand(i, "buy vest");
			}
			else if(m_iAccount > 3000)
			{
				FakeClientCommand(i, "buy vesthelm");
				FakeClientCommand(i, "buy vest");
			}
		}
	}	
}  

public Action Timer_ShouldAttack(Handle timer, int serial) {
    int client = GetClientFromSerial(serial);

    // check if client is the same has the one before when the timer started
    if (client != 0) {
        // set variable so next frame knows that client need to release attack
        g_bShouldAttack[client] = true;
    }

    g_hShouldAttackTimer[client] = null;
    return Plugin_Handled;
}  

public void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	
	int rnd = GetRandomInt(1,15);
	
	switch(rnd)
	{
		case 1:
		{
			g_iCoin[client] = GetRandomInt(874,970);
		}
		case 2:
		{
			g_iCoin[client] = GetRandomInt(1001,1010);
		}
		case 3:
		{
			g_iCoin[client] = GetRandomInt(1013,1022);
		}
		case 4:
		{
			g_iCoin[client] = GetRandomInt(1024,1026);
		}
		case 5:
		{
			g_iCoin[client] = GetRandomInt(1028,1055);
		}
		case 6:
		{
			g_iCoin[client] = GetRandomInt(1316,1318);
		}
		case 7:
		{
			g_iCoin[client] = GetRandomInt(1327,1329);
		}
		case 8:
		{
			g_iCoin[client] = GetRandomInt(1331,1332);
		}
		case 9:
		{
			g_iCoin[client] = GetRandomInt(1336,1344);
		}
		case 10:
		{
			g_iCoin[client] = GetRandomInt(1357,1363);
		}
		case 11:
		{
			g_iCoin[client] = GetRandomInt(1367,1372);
		}
		case 12:
		{
			g_iCoin[client] = GetRandomInt(1376,1381);
		}
		case 13:
		{
			g_iCoin[client] = GetRandomInt(4353,4356);
		}
		case 14:
		{
			g_iCoin[client] = GetRandomInt(6001,6033);
		}
		case 15:
		{
			g_iCoin[client] = GetRandomInt(4555,4558);
		}
	}

	int team = GetClientTeam(client);
	
	if (!client) return;

	if(IsFakeClient(client))
    {
        CreateTimer(0.1, RFrame_CheckBuyZoneValue, GetClientSerial(client)); 
		
        if(GetRandomInt(1,10) == 1)
        {
            if(team == 3)
            {
                char usp[32];
                
                GetClientWeapon(client, usp, sizeof(usp));
                
                if(StrEqual(usp, "weapon_usp_silencer"))
                {
                    int uspslot = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
                    
                    if (uspslot != -1)
                    {
                        RemovePlayerItem(client, uspslot);
                    }
                    GivePlayerItem(client, "weapon_hkp2000");
                }
            }
        }
    }
}

public Action RFrame_CheckBuyZoneValue(Handle timer, int serial) 
{
	int client = GetClientFromSerial(serial);

	if (!client || !IsClientInGame(client) || !IsPlayerAlive(client)) return Plugin_Stop;
	int team = GetClientTeam(client);
	if (team < 2) return Plugin_Stop;

	int m_iAccount = GetEntProp(client, Prop_Send, "m_iAccount");
	
	bool m_bInBuyZone = view_as<bool>(GetEntProp(client, Prop_Send, "m_bInBuyZone"));
	
	if (!m_bInBuyZone) return Plugin_Stop;

	if((m_iAccount > 1500) && (m_iAccount < 3000))
	{
		int iWeapon = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
		
		if (iWeapon != -1)
		{
			RemovePlayerItem(client, iWeapon);
		}
		
		int rndpistol = GetRandomInt(1,3);
		
		switch(rndpistol)
		{
			case 1:
			{
				GivePlayerItem(client, "weapon_p250");
				SetClientMoney(client, m_iAccount - 300);
			}
			case 2:
			{
				if(team == 3)
				{
					int ctcz = GetRandomInt(1,2);
					
					switch(ctcz)
					{
						case 1:
						{
							GivePlayerItem(client, "weapon_fiveseven");
							SetClientMoney(client, m_iAccount - 500);
						}
						case 2:
						{
							GivePlayerItem(client, "weapon_cz75a");
							SetClientMoney(client, m_iAccount - 500);
						}
					}
				}
				else if(team == 2)
				{
					int tcz = GetRandomInt(1,2);
					
					switch(tcz)
					{
						case 1:
						{
							GivePlayerItem(client, "weapon_tec9");
							SetClientMoney(client, m_iAccount - 500);
						}
						case 2:
						{
							GivePlayerItem(client, "weapon_cz75a");
							SetClientMoney(client, m_iAccount - 500);
						}
					}
				}
			}
			case 3:
			{
				GivePlayerItem(client, "weapon_deagle");
				SetClientMoney(client, m_iAccount - 700);
			}
		}
	}
	else if(m_iAccount > 3000)
	{
		RemoveNades(client);

		if (team == 2) { 
            GivePlayerItem(client, g_sTRngGrenadesList[GetRandomInt(0, sizeof(g_sTRngGrenadesList) - 1)]); 
        }
		else { 
            GivePlayerItem(client, g_sCTRngGrenadesList[GetRandomInt(0, sizeof(g_sTRngGrenadesList) - 1)]); 
            SetEntProp(client, Prop_Send, "m_bHasDefuser", 1); 
        } 
		
	}
	return Plugin_Stop;
}

public void OnClientDisconnect(int client)
{
	if(client)
	{
		g_iCoin[client] = 0;
		g_iProfileRank[client] = 0;
	}
}

public void OnPluginEnd()
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsFakeClient(client))
		{
			OnClientDisconnect(client);
		}
	}
}

stock void SetClientMoney(int client, int money)
{
	SetEntProp(client, Prop_Send, "m_iAccount", money);
	
	int moneyEntity = CreateEntityByName("game_money");
	
	DispatchKeyValue(moneyEntity, "Award Text", "");
	
	DispatchSpawn(moneyEntity);
	
	AcceptEntityInput(moneyEntity, "SetMoneyAmount 0");

	AcceptEntityInput(moneyEntity, "AddMoneyPlayer", client);
	
	AcceptEntityInput(moneyEntity, "Kill");
}

stock void RemoveNades(int client)
{
    while(RemoveWeaponBySlot(client, 3)){}
    for(int i = 0; i < 6; i++)
        SetEntProp(client, Prop_Send, "m_iAmmo", 0, _, g_iaGrenadeOffsets[i]);
}

stock bool RemoveWeaponBySlot(int client, int iSlot)
{
    int iEntity = GetPlayerWeaponSlot(client, iSlot);
    if(IsValidEdict(iEntity)) {
        RemovePlayerItem(client, iEntity);
        AcceptEntityInput(iEntity, "Kill");
        return true;
    }
    return false;
} 