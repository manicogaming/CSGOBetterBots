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
	//MIBR Players
	"coldzera",
	"FalleN",
	"fer",
	"TACO",
	"felps",
	//FaZe Players
	"olofmeister",
	"GuardiaN",
	"NiKo",
	"rain",
	"AdreN",
	//Astralis Players
	"Xyp9x",
	"device",
	"gla1ve",
	"Magisk",
	"dupreeh",
	//NiP Players
	"GeT_RiGhT",
	"draken",
	"f0rest",
	"Lekr0",
	"REZ",
	//C9 Players
	"cajunb",
	"autimatic",
	"vice",
	"Golden",
	"RUSH",
	//G2 Players
	"shox",
	"kennyS",
	"Lucky",
	"JaCkz",
	"AMANEK",
	//fnatic Players
	"twist",
	"JW",
	"KRiMZ",
	"Brollan",
	"Xizt",
	//North Players
	"cadiaN",
	"Kjaerbye",
	"aizy",
	"valde",
	"gade",
	//mouz Players
	"karrigan",
	"chrisJ",
	"woxic",
	"frozen",
	"ropz",
	//TyLoo Players
	"Summer",
	"Attacker",
	"BnTneT",
	"somebody",
	"xccurate",
	//Gambit Players
	"Ax1Le",
	"mou",
	"Dosia",
	"dimasick",
	"mir",
	//NRG Players
	"daps",
	"tarik",
	"Brehze",
	"nahtE",
	"CeRq",
	//RNG Players
	"AZR",
	"jks",
	"jkaem",
	"Gratisfaction",
	"Liazz",
	//Na´Vi Players
	"electronic",
	"s1mple",
	"flamie",
	"Edward",
	"Zeus",
	//Liquid Players
	"Stewie2K",
	"NAF",
	"nitr0",
	"ELiGE",
	"Twistzz",
	//HR Players
	"ANGE1",
	"oskar",
	"Hobbit",
	"loWel",
	"ISSAA",
	//AGO Players
	"Furlan",
	"GruBy",
	"kap3r",
	"phr",
	"SZPERO",
	//ENCE Players
	"Aleksib",
	"allu",
	"sergej",
	"Aerial",
	"xseveN",
	//Vitality Players
	"NBK-",
	"ZywOo",
	"apEX",
	"RpK",
	"ALEX",
	//BIG Players
	"tiziaN",
	"nex",
	"XANTARES",
	"tabseN",
	"gob b",
	//AVANGAR Players
	"buster",
	"Jame",
	"qikert",
	"fitch",
	"KrizzeN",
	//Windigo Players
	"SHiPZ",
	"bubble",
	"v1c7oR",
	"blocker",
	"poizon",
	//Ghost Players
	"Wardell",
	"koosta",
	"steel",
	"neptune",
	"freakazoid",
	//FURIA Players
	"yuurih",
	"arT",
	"VINI",
	"kscerato",
	"ableJ",
	//Valience Players
	"LETN1",
	"ottoNd",
	"huNter",
	"nexa",
	"EspiranTo",
	//coL Players
	"dephh",
	"ShahZaM",
	"stanislaw",
	"Rickeh",
	"SicK",
	//ViCi Players
	"zhokiNg",
	"kaze",
	"aumaN",
	"Freeman",
	"advent",
	//forZe Players
	"facecrack",
	"xsepower",
	"FL1T",
	"almazer",
	"Jerry",
	//Winstrike Players
	"Boombl4",
	"Kvik",
	"n0rb3r7",
	"WorldEdit",
	"bondik",
	//OpTic Players
	"k0nfig",
	"JUGi",
	"niko",
	"Snappi",
	"refrezh",
	//Sprout Players
	"denis",
	"syrsoN",
	"Spiidi",
	"faveN",
	"mirbit",
	//Heroic Players
	"es3tag",
	"mertz",
	"friberg",
	"blameF",
	"stavn",
	//INTZ Players
	"chelo",
	"kNgV-",
	"xand",
	"destinyy",
	"yeL",
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
	"DIVIZON TR1P",
	"EURONICS arno",
	"EURONICS LyGHT",
	"EURONICS PerX",
	"EURONICS Seeeya",
	"EURONICS OKOLICIOUZ",
	"expert ScrunK",
	"expert Andyy",
	"expert syken",
	"expert JDC",
	"expert kRYSTAL",
	"PANTHERS zonixx",
	"PANTHERS Ultimate",
	"PANTHERS .P4TriCK",
	"PANTHERS pdy",
	"PANTHERS red",
	"Planetkey ecfN",
	"Planetkey impulsG",
	"Planetkey Cedii",
	"Planetkey Krimbo",
	"Planetkey Lemon",
	"PDucks Aika",
	"PDucks syncD",
	"PDucks BMLN",
	"PDucks HighKitty",
	"PDucks VENIQ"
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
	
	MIBR_Players(botname, client);
	FaZe_Players(botname, client);
	Astralis_Players(botname, client);
	NiP_Players(botname, client);
	C9_Players(botname, client);
	G2_Players(botname, client);
	fnatic_Players(botname, client);
	North_Players(botname, client);
	mouz_Players(botname, client);
	TyLoo_Players(botname, client);
	Gambit_Players(botname, client);
	NRG_Players(botname, client);
	RNG_Players(botname, client);
	NaVi_Players(botname, client);
	Liquid_Players(botname, client);
	HR_Players(botname, client);
	AGO_Players(botname, client);
	ENCE_Players(botname, client);
	Vitality_Players(botname, client);
	BIG_Players(botname, client);
	AVANGAR_Players(botname, client);
	Windigo_Players(botname, client);
	Ghost_Players(botname, client);
	FURIA_Players(botname, client);
	Valience_Players(botname, client);
	coL_Players(botname, client);
	ViCi_Players(botname, client);
	forZe_Players(botname, client);
	Winstrike_Players(botname, client);
	OpTic_Players(botname, client);
	Sprout_Players(botname, client);
	Heroic_Players(botname, client);
	INTZ_Players(botname, client);
	
	g_iProfileRank[client] = GetRandomInt(1,40);
}


public void MIBR_Players(char[] botname, int client)
{
	if((StrContains(botname, "coldzera", false) != -1) || (StrContains(botname, "FalleN", false) != -1) || (StrContains(botname, "fer", false) != -1) || (StrContains(botname, "TACO", false) != -1) || (StrContains(botname, "felps", false) != -1))
	{
		CS_SetClientClanTag(client, "MIBR");
	}
}

public void FaZe_Players(char[] botname, int client)
{
	if((StrContains(botname, "olofmeister", false) != -1) || (StrContains(botname, "GuardiaN", false) != -1) || (StrContains(botname, "NiKo", false) != -1) || (StrContains(botname, "rain", false) != -1) || (StrContains(botname, "AdreN", false) != -1))
	{
		CS_SetClientClanTag(client, "FaZe");
	}
}

public void Astralis_Players(char[] botname, int client)
{
	if((StrContains(botname, "Xyp9x", false) != -1) || (StrContains(botname, "device", false) != -1) || (StrContains(botname, "gla1ve", false) != -1) || (StrContains(botname, "Magisk", false) != -1) || (StrContains(botname, "dupreeh", false) != -1))
	{
		CS_SetClientClanTag(client, "Astralis");
	}
}

public void NiP_Players(char[] botname, int client)
{
	if((StrContains(botname, "GeT_RiGhT", false) != -1) || (StrContains(botname, "draken", false) != -1) || (StrContains(botname, "f0rest", false) != -1) || (StrContains(botname, "Lekr0", false) != -1) || (StrContains(botname, "REZ", false) != -1))
	{
		CS_SetClientClanTag(client, "NiP");
	}
}

public void C9_Players(char[] botname, int client)
{
	if((StrContains(botname, "cajunb", false) != -1) || (StrContains(botname, "autimatic", false) != -1) || (StrContains(botname, "vice", false) != -1) || (StrContains(botname, "Golden", false) != -1) || (StrContains(botname, "RUSH", false) != -1))
	{
		CS_SetClientClanTag(client, "C9");
	}
}

public void G2_Players(char[] botname, int client)
{
	if((StrContains(botname, "shox", false) != -1) || (StrContains(botname, "kennyS", false) != -1) || (StrContains(botname, "Lucky", false) != -1) || (StrContains(botname, "JaCkz", false) != -1) || (StrContains(botname, "AMANEK", false) != -1))
	{
		CS_SetClientClanTag(client, "G2");
	}
}

public void fnatic_Players(char[] botname, int client)
{
	if((StrContains(botname, "twist", false) != -1) || (StrContains(botname, "JW", false) != -1) || (StrContains(botname, "KRiMZ", false) != -1) || (StrContains(botname, "Brollan", false) != -1) || (StrContains(botname, "Xizt", false) != -1))
	{
		CS_SetClientClanTag(client, "fnatic");
	}
}

public void North_Players(char[] botname, int client)
{
	if((StrContains(botname, "cadiaN", false) != -1) || (StrContains(botname, "Kjaerbye", false) != -1) || (StrContains(botname, "aizy", false) != -1) || (StrContains(botname, "valde", false) != -1) || (StrContains(botname, "gade", false) != -1))
	{
		CS_SetClientClanTag(client, "North");
	}
}

public void mouz_Players(char[] botname, int client)
{
	if((StrContains(botname, "karrigan", false) != -1) || (StrContains(botname, "chrisJ", false) != -1) || (StrContains(botname, "woxic", false) != -1) || (StrContains(botname, "frozen", false) != -1) || (StrContains(botname, "ropz", false) != -1))
	{
		CS_SetClientClanTag(client, "mouz");
	}
}

public void TyLoo_Players(char[] botname, int client)
{
	if((StrContains(botname, "Summer", false) != -1) || (StrContains(botname, "Attacker", false) != -1) || (StrContains(botname, "BnTneT", false) != -1) || (StrContains(botname, "somebody", false) != -1) || (StrContains(botname, "xccurate", false) != -1))
	{
		CS_SetClientClanTag(client, "TyLoo");
	}
}

public void Gambit_Players(char[] botname, int client)
{
	if((StrContains(botname, "Ax1Le", false) != -1) || (StrContains(botname, "mou", false) != -1) || (StrContains(botname, "Dosia", false) != -1) || (StrContains(botname, "dimasick", false) != -1) || (StrContains(botname, "mir", false) != -1))
	{
		CS_SetClientClanTag(client, "Gambit");
	}
}

public void NRG_Players(char[] botname, int client)
{
	if((StrContains(botname, "daps", false) != -1) || (StrContains(botname, "tarik", false) != -1) || (StrContains(botname, "Brehze", false) != -1) || (StrContains(botname, "nahtE", false) != -1) || (StrContains(botname, "CeRq", false) != -1))
	{
		CS_SetClientClanTag(client, "NRG");
	}
}

public void RNG_Players(char[] botname, int client)
{
	if((StrContains(botname, "AZR", false) != -1) || (StrContains(botname, "jks", false) != -1) || (StrContains(botname, "jkaem", false) != -1) || (StrContains(botname, "Gratisfaction", false) != -1) || (StrContains(botname, "Liazz", false) != -1))
	{
		CS_SetClientClanTag(client, "RNG");
	}
}

public void NaVi_Players(char[] botname, int client)
{
	if((StrContains(botname, "electronic", false) != -1) || (StrContains(botname, "s1mple", false) != -1) || (StrContains(botname, "flamie", false) != -1) || (StrContains(botname, "Edward", false) != -1) || (StrContains(botname, "Zeus", false) != -1))
	{
		CS_SetClientClanTag(client, "Na´Vi");
	}
}

public void Liquid_Players(char[] botname, int client)
{
	if((StrContains(botname, "Stewie2K", false) != -1) || (StrContains(botname, "NAF", false) != -1) || (StrContains(botname, "nitr0", false) != -1) || (StrContains(botname, "ELiGE", false) != -1) || (StrContains(botname, "Twistzz", false) != -1))
	{
		CS_SetClientClanTag(client, "Liquid");
	}
}

public void HR_Players(char[] botname, int client)
{
	if((StrContains(botname, "ANGE1", false) != -1) || (StrContains(botname, "oskar", false) != -1) || (StrContains(botname, "Hobbit", false) != -1) || (StrContains(botname, "loWel", false) != -1) || (StrContains(botname, "ISSAA", false) != -1))
	{
		CS_SetClientClanTag(client, "HR");
	}
}

public void AGO_Players(char[] botname, int client)
{
	if((StrContains(botname, "Furlan", false) != -1) || (StrContains(botname, "GruBy", false) != -1) || (StrContains(botname, "kap3r", false) != -1) || (StrContains(botname, "phr", false) != -1) || (StrContains(botname, "SZPERO", false) != -1))
	{
		CS_SetClientClanTag(client, "AGO");
	}
}

public void ENCE_Players(char[] botname, int client)
{
	if((StrContains(botname, "Aleksib", false) != -1) || (StrContains(botname, "Aerial", false) != -1) || (StrContains(botname, "allu", false) != -1) || (StrContains(botname, "sergej", false) != -1) || (StrContains(botname, "xseveN", false) != -1))
	{
		CS_SetClientClanTag(client, "ENCE");
	}
}

public void Vitality_Players(char[] botname, int client)
{
	if((StrContains(botname, "NBK-", false) != -1) || (StrContains(botname, "ZywOo", false) != -1) || (StrContains(botname, "apEX", false) != -1) || (StrContains(botname, "RpK", false) != -1) || (StrContains(botname, "ALEX", false) != -1))
	{
		CS_SetClientClanTag(client, "Vitality");
	}
}

public void BIG_Players(char[] botname, int client)
{
	if((StrContains(botname, "tiziaN", false) != -1) || (StrContains(botname, "nex", false) != -1) || (StrContains(botname, "XANTARES", false) != -1) || (StrContains(botname, "tabseN", false) != -1) || (StrContains(botname, "gob b", false) != -1))
	{
		CS_SetClientClanTag(client, "BIG");
	}
}

public void AVANGAR_Players(char[] botname, int client)
{
	if((StrContains(botname, "buster", false) != -1) || (StrContains(botname, "Jame", false) != -1) || (StrContains(botname, "qikert", false) != -1) || (StrContains(botname, "fitch", false) != -1) || (StrContains(botname, "KrizzeN", false) != -1))
	{
		CS_SetClientClanTag(client, "AVANGAR");
	}
}

public void Windigo_Players(char[] botname, int client)
{
	if((StrContains(botname, "SHiPZ", false) != -1) || (StrContains(botname, "bubble", false) != -1) || (StrContains(botname, "v1c7oR", false) != -1) || (StrContains(botname, "blocker", false) != -1) || (StrContains(botname, "poizon", false) != -1))
	{
		CS_SetClientClanTag(client, "Windigo");
	}
}

public void Ghost_Players(char[] botname, int client)
{
	if((StrContains(botname, "Wardell", false) != -1) || (StrContains(botname, "koosta", false) != -1) || (StrContains(botname, "steel", false) != -1) || (StrContains(botname, "neptune", false) != -1) || (StrContains(botname, "freakazoid", false) != -1))
	{
		CS_SetClientClanTag(client, "Ghost");
	}
}

public void FURIA_Players(char[] botname, int client)
{
	if((StrContains(botname, "yuurih", false) != -1) || (StrContains(botname, "arT", false) != -1) || (StrContains(botname, "VINI", false) != -1) || (StrContains(botname, "kscerato", false) != -1) || (StrContains(botname, "ableJ", false) != -1))
	{
		CS_SetClientClanTag(client, "FURIA");
	}
}

public void Valience_Players(char[] botname, int client)
{
	if((StrContains(botname, "LETN1", false) != -1) || (StrContains(botname, "ottoNd", false) != -1) || (StrContains(botname, "huNter", false) != -1) || (StrContains(botname, "nexa", false) != -1) || (StrContains(botname, "EspiranTo", false) != -1))
	{
		CS_SetClientClanTag(client, "Valience");
	}
}

public void coL_Players(char[] botname, int client)
{
	if((StrContains(botname, "dephh", false) != -1) || (StrContains(botname, "ShahZaM", false) != -1) || (StrContains(botname, "stanislaw", false) != -1) || (StrContains(botname, "Rickeh", false) != -1) || (StrContains(botname, "SicK", false) != -1))
	{
		CS_SetClientClanTag(client, "coL");
	}
}

public void ViCi_Players(char[] botname, int client)
{
	if((StrContains(botname, "zhokiNg", false) != -1) || (StrContains(botname, "kaze", false) != -1) || (StrContains(botname, "aumaN", false) != -1) || (StrContains(botname, "Freeman", false) != -1) || (StrContains(botname, "advent", false) != -1))
	{
		CS_SetClientClanTag(client, "ViCi");
	}
}

public void forZe_Players(char[] botname, int client)
{
	if((StrContains(botname, "facecrack", false) != -1) || (StrContains(botname, "xsepower", false) != -1) || (StrContains(botname, "FL1T", false) != -1) || (StrContains(botname, "almazer", false) != -1) || (StrContains(botname, "Jerry", false) != -1))
	{
		CS_SetClientClanTag(client, "forZe");
	}
}

public void Winstrike_Players(char[] botname, int client)
{
	if((StrContains(botname, "Boombl4", false) != -1) || (StrContains(botname, "Kvik", false) != -1) || (StrContains(botname, "n0rb3r7", false) != -1) || (StrContains(botname, "WorldEdit", false) != -1) || (StrContains(botname, "bondik", false) != -1))
	{
		CS_SetClientClanTag(client, "Winstrike");
	}
}

public void OpTic_Players(char[] botname, int client)
{
	if((StrContains(botname, "k0nfig", false) != -1) || (StrContains(botname, "JUGi", false) != -1) || (StrContains(botname, "niko", false) != -1) || (StrContains(botname, "Snappi", false) != -1) || (StrContains(botname, "refrezh", false) != -1))
	{
		CS_SetClientClanTag(client, "OpTic");
	}
}

public void Sprout_Players(char[] botname, int client)
{
	if((StrContains(botname, "denis", false) != -1) || (StrContains(botname, "syrsoN", false) != -1) || (StrContains(botname, "Spiidi", false) != -1) || (StrContains(botname, "faveN", false) != -1) || (StrContains(botname, "mirbit", false) != -1))
	{
		CS_SetClientClanTag(client, "Sprout");
	}
}

public void Heroic_Players(char[] botname, int client)
{
	if((StrContains(botname, "es3tag", false) != -1) || (StrContains(botname, "mertz", false) != -1) || (StrContains(botname, "friberg", false) != -1) || (StrContains(botname, "blameF", false) != -1) || (StrContains(botname, "stavn", false) != -1))
	{
		CS_SetClientClanTag(client, "Heroic");
	}
}

public void INTZ_Players(char[] botname, int client)
{
	if((StrContains(botname, "chelo", false) != -1) || (StrContains(botname, "kNgV-", false) != -1) || (StrContains(botname, "xand", false) != -1) || (StrContains(botname, "destinyy", false) != -1) || (StrContains(botname, "yeL", false) != -1))
	{
		CS_SetClientClanTag(client, "INTZ");
	}
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