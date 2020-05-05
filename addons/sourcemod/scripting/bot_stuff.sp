#pragma semicolon 1

#include <sourcemod>
#include <clientprefs>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#include <eItems>

bool g_bFlashed[MAXPLAYERS + 1] = false;
bool g_bFreezetimeEnd = false;
bool g_bBombPlanted = false;
bool g_bPinPulled[MAXPLAYERS + 1] = false;
int g_iaGrenadeOffsets[] = {15, 17, 16, 14, 18, 17};
int g_iProfileRank[MAXPLAYERS+1], g_iCoin[MAXPLAYERS+1], g_iProfileRankOffset, g_iCoinOffset, g_iRndSmoke[MAXPLAYERS+1], g_iRndMolotov[MAXPLAYERS+1];
ConVar g_cvPredictionConVars[1] = {null};
char g_sMap[64];
Handle hGameConfig = INVALID_HANDLE;
Handle hBotMoveTo = INVALID_HANDLE;

enum _BotRouteType
{
	SAFEST_ROUTE = 0,
	FASTEST_ROUTE,
	UNKNOWN_ROUTE
}

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

char g_sCTModels[][] = {
	"models/player/custom_player/legacy/ctm_st6_variante.mdl",
	"models/player/custom_player/legacy/ctm_st6_variantk.mdl",
	"models/player/custom_player/legacy/ctm_fbi_variantf.mdl",
	"models/player/custom_player/legacy/ctm_sas_variantf.mdl",
	"models/player/custom_player/legacy/ctm_fbi_variantg.mdl",
	"models/player/custom_player/legacy/ctm_st6_variantg.mdl",
	"models/player/custom_player/legacy/ctm_fbi_varianth.mdl",
	"models/player/custom_player/legacy/ctm_st6_variantm.mdl",
	"models/player/custom_player/legacy/ctm_st6_varianti.mdl",
	"models/player/custom_player/legacy/ctm_fbi_variantb.mdl"
};

char g_sTModels[][] = {
	"models/player/custom_player/legacy/tm_phoenix_variantf.mdl",
	"models/player/custom_player/legacy/tm_phoenix_varianth.mdl",
	"models/player/custom_player/legacy/tm_leet_variantg.mdl",
	"models/player/custom_player/legacy/tm_balkan_varianti.mdl",
	"models/player/custom_player/legacy/tm_leet_varianth.mdl",
	"models/player/custom_player/legacy/tm_phoenix_variantg.mdl",
	"models/player/custom_player/legacy/tm_balkan_variantf.mdl",
	"models/player/custom_player/legacy/tm_balkan_variantj.mdl",
	"models/player/custom_player/legacy/tm_leet_varianti.mdl",
	"models/player/custom_player/legacy/tm_balkan_variantg.mdl",
	"models/player/custom_player/legacy/tm_balkan_varianth.mdl",
	"models/player/custom_player/legacy/tm_leet_variantf.mdl"
};

static char g_sBotName[][] = {
	//MIBR Players
	"kNgV-",
	"FalleN",
	"fer",
	"TACO",
	"meyern",
	//FaZe Players
	"olofmeister",
	"broky",
	"NiKo",
	"rain",
	"coldzera",
	//Astralis Players
	"Xyp9x",
	"device",
	"gla1ve",
	"Magisk",
	"dupreeh",
	//NiP Players
	"twist",
	"Plopski",
	"nawwk",
	"Lekr0",
	"REZ",
	//C9 Players
	"JT",
	"Sonic",
	"motm",
	"oSee",
	"floppy",
	//G2 Players
	"huNter-",
	"kennyS",
	"nexa",
	"JaCkz",
	"AMANEK",
	//fnatic Players
	"flusha",
	"JW",
	"KRiMZ",
	"Brollan",
	"Golden",
	//North Players
	"MSL",
	"Kjaerbye",
	"aizy",
	"cajunb",
	"gade",
	//mouz Players
	"karrigan",
	"chrisJ",
	"woxic",
	"frozen",
	"ropz",
	//TYLOO Players
	"Summer",
	"Attacker",
	"xeta",
	"somebody",
	"Freeman",
	//EG Players
	"stanislaw",
	"tarik",
	"Brehze",
	"Ethan",
	"CeRq",
	//Thieves Players
	"AZR",
	"jks",
	"jkaem",
	"Gratisfaction",
	"Liazz",
	//Na´Vi Players
	"electronic",
	"s1mple",
	"flamie",
	"Boombl4",
	"Perfecto",
	//Liquid Players
	"Stewie2K",
	"NAF",
	"nitr0",
	"ELiGE",
	"Twistzz",
	//AGO Players
	"Furlan",
	"GruBy",
	"mhL",
	"F1KU",
	"oskarish",
	//ENCE Players
	"suNny",
	"allu",
	"sergej",
	"Aerial",
	"xseveN",
	//Vitality Players
	"shox",
	"ZywOo",
	"apEX",
	"RpK",
	"Misutaaa",
	//BIG Players
	"tiziaN",
	"syrsoN",
	"XANTARES",
	"tabseN",
	"k1to",
	//FURIA Players
	"yuurih",
	"arT",
	"VINI",
	"kscerato",
	"HEN1",
	//c0ntact Players
	"LETN1",
	"ottoNd",
	"SHiPZ",
	"emi",
	"EspiranTo",
	//coL Players
	"k0nfig",
	"poizon",
	"oBo",
	"RUSH",
	"blameF",
	//ViCi Players
	"zhokiNg",
	"kaze",
	"aumaN",
	"JamYoung",
	"advent",
	//forZe Players
	"facecrack",
	"xsepower",
	"FL1T",
	"almazer",
	"Jerry",
	//Winstrike Players
	"Lack1",
	"KrizzeN",
	"Hobbit",
	"El1an",
	"bondik",
	//Sprout Players
	"snatchie",
	"dycha",
	"Spiidi",
	"faveN",
	"denis",
	//Heroic Players
	"TeSeS",
	"b0RUP",
	"nikozan",
	"cadiaN",
	"stavn",
	//INTZ Players
	"maxcel",
	"gut0",
	"danoco",
	"detr0it",
	"kLv",
	//VP Players
	"buster",
	"Jame",
	"qikert",
	"SANJI",
	"AdreN",
	//Apeks Players
	"Marcelious",
	"truth",
	"Grusarn",
	"akEz",
	"Polly",
	//aTTaX Players
	"stfN",
	"slaxz",
	"ScrunK",
	"kressy",
	"mirbit",
	//RNG Players
	"INS",
	"sico",
	"dexter",
	"Hatz",
	"malta",
	//Envy Players
	"Nifty",
	"ryann",
	"Calyx",
	"MICHU",
	"moose",
	//Spirit Players
	"mir",
	"iDISBALANCE",
	"somedieyoung",
	"chopper",
	"magixx",
	//CeX Players
	"MT",
	"Impact",
	"Nukeddog",
	"CYPHER",
	"Murky",
	//LDLC Players
	"LOGAN",
	"Lambert",
	"hAdji",
	"Gringo",
	"SIXER",
	//GamerLegion Players
	"dennis",
	"draken",
	"freddieb",
	"RuStY",
	"hampus",
	//DIVIZON Players
	"devus",
	"akay",
	"hyped",
	"merisinho",
	"ykyli",
	//EURONICS Players
	"red",
	"pdy",
	"PerX",
	"Seeeya",
	"maRky",
	//nerdRage Players
	"Frazehh",
	"Br0die",
	"Ping",
	"Tadpole",
	"LNZ",
	//PDucks Players
	"stefank0k0",
	"ACTiV",
	"Cargo",
	"Krabbe",
	"Simply",
	//HAVU Players
	"ZOREE",
	"sLowi",
	"doto",
	"Hoody",
	"sAw",
	//Lyngby Players
	"birdfromsky",
	"Twinx",
	"maNkz",
	"Raalz",
	"Cabbi",
	//GODSENT Players
	"maden",
	"Maikelele",
	"kRYSTAL",
	"zehN",
	"STYKO",
	//Nordavind Players
	"tenzki",
	"NaToSaphiX",
	"RUBINO",
	"HS",
	"cromen",
	//SJ Players
	"arvid",
	"STOVVE",
	"SADDYX",
	"KHRN",
	"xartE",
	//Bren Players
	"Papichulo",
	"witz",
	"Pro.",
	"JA",
	"Derek",
	//Giants Players
	"NOPEEj",
	"fox",
	"pr",
	"BLOODZ",
	"renatoohaxx",
	//Lions Players
	"AcilioN",
	"acoR",
	"Sjuush",
	"Bubzkji",
	"roeJ",
	//Riders Players
	"mopoz",
	"EasTor",
	"steel",
	"alex*",
	"loWel",
	//OFFSET Players
	"sc4rx",
	"obj",
	"zlynx",
	"ZELIN",
	"drifking",
	//x6tence Players
	"NikoM",
	"JonY BoY",
	"tomi",
	"OMG",
	"tutehen",
	//eSuba Players
	"NIO",
	"Levi",
	"The eLiVe",
	"Blogg1s",
	"luko",
	//Nexus Players
	"BTN",
	"XELLOW",
	"mhN1",
	"iM",
	"sXe",
	//PACT Players
	"darko",
	"lunAtic",
	"Goofy",
	"MINISE",
	"Sobol",
	//Heretics Players
	"Nivera",
	"Maka",
	"xms",
	"kioShiMa",
	"Lucky",
	//Nemiga Players
	"speed4k",
	"mds",
	"lollipop21k",
	"Jyo",
	"boX",
	//pro100 Players
	"dimasick",
	"WorldEdit",
	"YEKINDAR",
	"wayLander",
	"NickelBack",
	//YaLLa Players
	"Remind",
	"DEAD",
	"Kheops",
	"Senpai",
	"fredi",
	//Yeah Players
	"tatazin",
	"RCF",
	"f4stzin",
	"iDk",
	"dumau",
	//Singularity Players
	"Jabbi",
	"mertz",
	"Fessor",
	"TOBIZ",
	"Celrate",
	//DETONA Players
	"rikz",
	"tiburci0",
	"v$m",
	"Lucaozy",
	"Tuurtle",
	//Infinity Players
	"k1Nky",
	"tor1towOw",
	"spamzzy",
	"sam_A",
	"Daveys",
	//Isurus Players
	"1962",
	"Noktse",
	"Reversive",
	"decov9jse",
	"maxujas",
	//paiN Players
	"PKL",
	"land1n",
	"NEKIZ",
	"biguzera",
	"hardzao",
	//Sharks Players
	"heat",
	"jnt",
	"leo_drunky",
	"exit",
	"Luken",
	//One Players
	"prt",
	"Maluk3",
	"trk",
	"pesadelo",
	"b4rtiN",
	//W7M Players
	"skullz",
	"raafa",
	"ableJ",
	"pancc",
	"realziN",
	//Avant Players
	"BL1TZ",
	"sterling",
	"apoc",
	"ofnu",
	"HaZR",
	//Chiefs Players
	"stat",
	"Jinxx",
	"apocdud",
	"SkulL",
	"Mayker",
	//ORDER Players
	"J1rah",
	"aliStair",
	"Rickeh",
	"USTILO",
	"Valiance",
	//BlackS Players
	"hue9ze",
	"addict",
	"cookie",
	"jono",
	"Wolfah",
	//SKADE Players
	"Rock1nG",
	"dennyslaw",
	"rafftu",
	"Rainwaker",
	"SPELLAN",
	//Paradox Players
	"ino",
	"Versa",
	"ekul",
	"bedonka",
	"urbz",
	//Beyond Players
	"MAIROLLS",
	"Olivia",
	"Kntz",
	"stk",
	"qqGod",
	//BOOM Players
	"chelo",
	"yeL",
	"shz",
	"boltz",
	"felps",
	//LucidDream Players
	"Jinx",
	"PTC",
	"cbbk",
	"JohnOlsen",
	"Lakia",
	//NASR Players
	"proxyyb",
	"Real1ze",
	"BOROS",
	"Dementor",
	"Just1ce",
	//Revolution Players
	"Rambutan",
	"Fog",
	"Tee",
	"Jaybk",
	"kun",
	//SHIFT Players
	"Young KillerS",
	"Kishi",
	"tozz",
	"huyhart",
	"Imcarnus",
	//nxl Players
	"soifong",
	"RamCikiciew",
	"Qbo",
	"Vask0",
	"smoof",
	//QB Players
	"MadLife",
	"Electro",
	"nafan9",
	"Raider",
	"L4F",
	//Energy Players
	"pnd",
	"disTroiT",
	"Lichl0rd",
	"Damz",
	"kreatioN",
	//Furious Players
	"nbl",
	"anarchist",
	"niox",
	"iKrystal",
	"pablek",
	//BLUEJAYS Players
	"blocker",
	"numb",
	"REDSTAR",
	"Patrick",
	"dream3r",
	//EXECUTIONERS Players
	"ZesBeeW",
	"FamouZ",
	"maestro",
	"Snyder",
	"Sys",
	//GroundZero Players
	"BURNRUOk",
	"void",
	"Llamas",
	"Noobster",
	"PEARSS",
	//AVEZ Players
	"MOLSI",
	"Markoś",
	"KEi",
	"Kylar",
	"nawrot",
	//BTRG Players
	"HeiB",
	"start",
	"xccurate",
	"ImpressioN",
	"XigN",
	//GTZ Players
	"k0mpa",
	"StepA",
	"slaxx",
	"Jaepe",
	"rafaxF",
	//Flames Players
	"Queenix",
	"farlig",
	"HooXi",
	"refrezh",
	"Nodios",
	//BPro Players
	"FlashBack",
	"viltrex",
	"POP0V",
	"Krs7N",
	"milly",
	//Syman Players
	"neaLaN",
	"mou",
	"n0rb3r7",
	"kreaz",
	"Keoz",
	//Goliath Players
	"massacRe",
	"mango",
	"deviaNt",
	"adaro",
	"ZipZip",
	//Secret Players
	"juanflatroo",
	"tudsoN",
	"PERCY",
	"sinnopsyy",
	"anarkez",
	//Incept Players
	"micalis",
	"jtr",
	"zeph",
	"Rackem",
	"yourwombat",
	//UOL Players
	"crisby",
	"kZyJL",
	"Andyy",
	"JDC",
	".P4TriCK",
	//Baecon Players
	"brA",
	"emp",
	"kst",
	"fakesS2",
	"KILLDREAM",
	//Illuminar Players
	"Vegi",
	"Snax",
	"mouz",
	"innocent",
	"reatz",
	//Queso Players
	"TheClaran",
	"rAmbi",
	"VARES",
	"mik",
	"Yaba",
	//IG Players
	"0i",
	"DeStRoYeR",
	"flying",
	"Viva",
	"XiaosaGe",
	//HR Players
	"kAliNkA",
	"jR",
	"Flarich",
	"ProbLeM",
	"JIaYm",
	//Dice Players
	"XpG",
	"nonick",
	"Kan4",
	"Polox",
	"DEVIL",
	//KPI Players
	"xikii",
	"SunPayus",
	"meisoN",
	"YuRk0",
	"NaOw",
	//PlanetKey Players
	"NinoZjE",
	"s1n",
	"skyye",
	"Kirby",
	"yannick1h",
	//mCon Players
	"k1Nzo",
	"shaGGy",
	"luosrevo",
	"ReFuZR",
	"methoDs",
	//DreamEaters Players
	"CHEHOL",
	"Quantium",
	"Kas9k",
	"minse",
	"JACKPOT",
	//HLE Players
	"kinqie",
	"rAge",
	"Krad",
	"Forester",
	"svyat",
	//Gambit Players
	"nafany",
	"sh1ro",
	"interz",
	"Ax1Le",
	"supra",
	//Wisla Players
	"hades",
	"SZPERO",
	"mynio",
	"fanatyk",
	"jedqr",
	//Imperial Players
	"KHTEX",
	"zqk",
	"dzt",
	"delboNi",
	"SHOOWTiME",
	//Big5 Players
	"kustoM_",
	"Spartan",
	"SloWye-",
	"takbok",
	"Tiaantjie",
	//Unique Players
	"R0b3n",
	"zorte",
	"PASHANOJ",
	"kenzor",
	"fenvicious",
	//Izako Players
	"Siuhy",
	"szejn",
	"EXUS",
	"avis",
	"TOAO",
	//ATK Players
	"bLazE",
	"MisteM",
	"flexeeee",
	"Fadey",
	"TenZ",
	//Chaos Players
	"Xeppaa",
	"vanity",
	"Voltage",
	"steel_",
	"leaf",
	//OneThree Players
	"ChildKing",
	"lan",
	"bottle",
	"DD",
	"Karsa",
	//Lynn Players
	"XG",
	"mitsuha",
	"Aree",
	"Yvonne",
	"XinKoiNg",
	//Triumph Players
	"Shakezullah",
	"Junior",
	"Spongey",
	"curry",
	"Grim",
	//FATE Players
	"doublemagic",
	"KalubeR",
	"Duplicate",
	"Mar",
	"niki1",
	//Canids Players
	"DeStiNy",
	"nythonzinho",
	"nak",
	"latto",
	"fnx",
	//ESPADA Players
	"Patsanchick",
	"degster",
	"FinigaN",
	"S0tF1k",
	"Dima",
	//OG Players
	"NBK-",
	"mantuu",
	"Aleksib",
	"valde",
	"ISSAA",
	//Vexed Players
	"Frei",
	"Astroo",
	"jenko",
	"Puls3",
	"stan1ey",
	//Tricked Players
	"kiR",
	"kwezz",
	"Luckyv1",
	"sycrone",
	"Toft",
	//Gen.G Players
	"autimatic",
	"koosta",
	"daps",
	"s0m",
	"BnTeT",
	//Endpoint Players
	"Surreal",
	"CRUC1AL",
	"Thomas",
	"robiin",
	"MiGHTYMAX",
	//sAw Players
	"arki",
	"stadodo",
	"JUST",
	"MUTiRiS",
	"rmn",
	//DIG Players
	"GeT_RiGhT",
	"hallzerk",
	"f0rest",
	"friberg",
	"Xizt",
	//D13 Players
	"Tamiraarita",
	"rate",
	"sKINEE",
	"sK0R",
	"ANNIHILATION",
	//ZIGMA Players
	"NIFFY",
	"Reality",
	"JUSTCAUSE",
	"PPOverdose",
	"RoLEX",
	//Ambush Players
	"Inzta",
	"Ryxxo",
	"zeq",
	"Typos",
	"IceBerg",
	//KOVA Players
	"pietola",
	"Derkeps",
	"uli",
	"peku",
	"Twixie",
	//CR4ZY Players
	"DemQQ",
	"Sergiz",
	"7oX1C",
	"Psycho",
	"SENSEi",
	//Redemption Players
	"drg",
	"ALLE",
	"remix",
	"w1",
	"dok",
	//eXploit Players
	"pizituh",
	"BuJ",
	"sark",
	"MISK",
	"Cunha",
	//SMASH Players
	"disco doplan",
	"bubble",
	"grux",
	"FejtZ",
	"shokz",
	//AGF Players
	"fr0slev",
	"Kristou",
	"netrick",
	"TMB",
	"Lukki",
	//Pompa Players
	"Miki Z Afryki",
	"splawik",
	"Czapel",
	"M4tthi",
	"grzes1x"
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
	HookEvent("round_freeze_end", OnFreezetimeEnd);
	HookEvent("bomb_planted", OnBombPlanted);
	HookEventEx("player_blind", Event_PlayerBlind, EventHookMode_Pre);
	
	g_cvPredictionConVars[0] = FindConVar("weapon_recoil_scale");
	
	hGameConfig = LoadGameConfigFile("botstuff.games");
	if (hGameConfig == INVALID_HANDLE)
		SetFailState("Failed to found botstuff.games game config.");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "MoveTo");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer); // Move Position As Vector, Pointer
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain); // Move Type As Integer
	hBotMoveTo = EndPrepSDKCall();
	
	RegConsoleCmd("team_nip", Team_NiP);
	RegConsoleCmd("team_mibr", Team_MIBR);
	RegConsoleCmd("team_faze", Team_FaZe);
	RegConsoleCmd("team_astralis", Team_Astralis);
	RegConsoleCmd("team_c9", Team_C9);
	RegConsoleCmd("team_g2", Team_G2);
	RegConsoleCmd("team_fnatic", Team_fnatic);
	RegConsoleCmd("team_north", Team_North);
	RegConsoleCmd("team_mouz", Team_mouz);
	RegConsoleCmd("team_tyloo", Team_TYLOO);
	RegConsoleCmd("team_eg", Team_EG);
	RegConsoleCmd("team_thieves", Team_Thieves);
	RegConsoleCmd("team_navi", Team_NaVi);
	RegConsoleCmd("team_liquid", Team_Liquid);
	RegConsoleCmd("team_ago", Team_AGO);
	RegConsoleCmd("team_ence", Team_ENCE);
	RegConsoleCmd("team_vitality", Team_Vitality);
	RegConsoleCmd("team_big", Team_BIG);
	RegConsoleCmd("team_furia", Team_FURIA);
	RegConsoleCmd("team_contact", Team_c0ntact);
	RegConsoleCmd("team_col", Team_coL);
	RegConsoleCmd("team_vici", Team_ViCi);
	RegConsoleCmd("team_forze", Team_forZe);
	RegConsoleCmd("team_winstrike", Team_Winstrike);
	RegConsoleCmd("team_sprout", Team_Sprout);
	RegConsoleCmd("team_heroic", Team_Heroic);
	RegConsoleCmd("team_intz", Team_INTZ);
	RegConsoleCmd("team_vp", Team_VP);
	RegConsoleCmd("team_apeks", Team_Apeks);
	RegConsoleCmd("team_attax", Team_aTTaX);
	RegConsoleCmd("team_rng", Team_Renegades);
	RegConsoleCmd("team_envy", Team_Envy);
	RegConsoleCmd("team_spirit", Team_Spirit);
	RegConsoleCmd("team_cex", Team_CeX);
	RegConsoleCmd("team_ldlc", Team_LDLC);
	RegConsoleCmd("team_gamerlegion", Team_GamerLegion);
	RegConsoleCmd("team_divizon", Team_DIVIZON);
	RegConsoleCmd("team_euronics", Team_EURONICS);
	RegConsoleCmd("team_nerdrage", Team_nerdRage);
	RegConsoleCmd("team_pducks", Team_PDucks);
	RegConsoleCmd("team_havu", Team_HAVU);
	RegConsoleCmd("team_lyngby", Team_Lyngby);
	RegConsoleCmd("team_godsent", Team_GODSENT);
	RegConsoleCmd("team_nordavind", Team_Nordavind);
	RegConsoleCmd("team_sj", Team_SJ);
	RegConsoleCmd("team_bren", Team_Bren);
	RegConsoleCmd("team_giants", Team_Giants);
	RegConsoleCmd("team_lions", Team_Lions);
	RegConsoleCmd("team_riders", Team_Riders);
	RegConsoleCmd("team_offset", Team_OFFSET);
	RegConsoleCmd("team_x6tence", Team_x6tence);
	RegConsoleCmd("team_esuba", Team_eSuba);
	RegConsoleCmd("team_nexus", Team_Nexus);
	RegConsoleCmd("team_pact", Team_PACT);
	RegConsoleCmd("team_heretics", Team_Heretics);
	RegConsoleCmd("team_nemiga", Team_Nemiga);
	RegConsoleCmd("team_pro100", Team_pro100);
	RegConsoleCmd("team_yalla", Team_YaLLa);
	RegConsoleCmd("team_yeah", Team_Yeah);
	RegConsoleCmd("team_singularity", Team_Singularity);
	RegConsoleCmd("team_detona", Team_DETONA);
	RegConsoleCmd("team_infinity", Team_Infinity);
	RegConsoleCmd("team_isurus", Team_Isurus);
	RegConsoleCmd("team_pain", Team_paiN);
	RegConsoleCmd("team_sharks", Team_Sharks);
	RegConsoleCmd("team_one", Team_One);
	RegConsoleCmd("team_w7m", Team_W7M);
	RegConsoleCmd("team_avant", Team_Avant);
	RegConsoleCmd("team_chiefs", Team_Chiefs);
	RegConsoleCmd("team_order", Team_ORDER);
	RegConsoleCmd("team_blacks", Team_BlackS);
	RegConsoleCmd("team_skade", Team_SKADE);
	RegConsoleCmd("team_paradox", Team_Paradox);
	RegConsoleCmd("team_beyond", Team_Beyond);
	RegConsoleCmd("team_boom", Team_BOOM);
	RegConsoleCmd("team_lucid", Team_Lucid);
	RegConsoleCmd("team_nasr", Team_NASR);
	RegConsoleCmd("team_revolution", Team_Revolution);
	RegConsoleCmd("team_shift", Team_SHIFT);
	RegConsoleCmd("team_nxl", Team_nxl);
	RegConsoleCmd("team_qb", Team_QB);
	RegConsoleCmd("team_energy", Team_energy);
	RegConsoleCmd("team_furious", Team_Furious);
	RegConsoleCmd("team_bluejays", Team_BLUEJAYS);
	RegConsoleCmd("team_executioners", Team_EXECUTIONERS);
	RegConsoleCmd("team_groundzero", Team_GroundZero);
	RegConsoleCmd("team_avez", Team_AVEZ);
	RegConsoleCmd("team_btrg", Team_BTRG);
	RegConsoleCmd("team_gtz", Team_GTZ);
	RegConsoleCmd("team_flames", Team_Flames);
	RegConsoleCmd("team_bpro", Team_BPro);
	RegConsoleCmd("team_syman", Team_Syman);
	RegConsoleCmd("team_goliath", Team_Goliath);
	RegConsoleCmd("team_secret", Team_Secret);
	RegConsoleCmd("team_incept", Team_Incept);
	RegConsoleCmd("team_uol", Team_UOL);
	RegConsoleCmd("team_baecon", Team_Baecon);
	RegConsoleCmd("team_illuminar", Team_Illuminar);
	RegConsoleCmd("team_queso", Team_Queso);
	RegConsoleCmd("team_ig", Team_IG);
	RegConsoleCmd("team_hr", Team_HR);
	RegConsoleCmd("team_dice", Team_Dice);
	RegConsoleCmd("team_kpi", Team_KPI);
	RegConsoleCmd("team_planetkey", Team_PlanetKey);
	RegConsoleCmd("team_mcon", Team_mCon);
	RegConsoleCmd("team_dreameaters", Team_DreamEaters);
	RegConsoleCmd("team_hle", Team_HLE);
	RegConsoleCmd("team_gambit", Team_Gambit);
	RegConsoleCmd("team_wisla", Team_Wisla);
	RegConsoleCmd("team_imperial", Team_Imperial);
	RegConsoleCmd("team_big5", Team_Big5);
	RegConsoleCmd("team_Unique", Team_Unique);
	RegConsoleCmd("team_izako", Team_Izako);
	RegConsoleCmd("team_atk", Team_ATK);
	RegConsoleCmd("team_chaos", Team_Chaos);
	RegConsoleCmd("team_onethree", Team_OneThree);
	RegConsoleCmd("team_lynn", Team_Lynn);
	RegConsoleCmd("team_triumph", Team_Triumph);
	RegConsoleCmd("team_fate", Team_FATE);
	RegConsoleCmd("team_canids", Team_Canids);
	RegConsoleCmd("team_espada", Team_ESPADA);
	RegConsoleCmd("team_og", Team_OG);
	RegConsoleCmd("team_vexed", Team_Vexed);
	RegConsoleCmd("team_tricked", Team_Tricked);
	RegConsoleCmd("team_geng", Team_GenG);
	RegConsoleCmd("team_endpoint", Team_Endpoint);
	RegConsoleCmd("team_saw", Team_sAw);
	RegConsoleCmd("team_dig", Team_DIG);
	RegConsoleCmd("team_d13", Team_D13);
	RegConsoleCmd("team_zigma", Team_ZIGMA);
	RegConsoleCmd("team_ambush", Team_Ambush);
	RegConsoleCmd("team_kova", Team_KOVA);
	RegConsoleCmd("team_cr4zy", Team_CR4ZY);
	RegConsoleCmd("team_redemption", Team_Redemption);
	RegConsoleCmd("team_exploit", Team_eXploit);
	RegConsoleCmd("team_smash", Team_SMASH);
	RegConsoleCmd("team_agf", Team_AGF);
	RegConsoleCmd("team_pompa", Team_Pompa);
}

public Action Team_NiP(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "twist");
		ServerCommand("bot_add_ct %s", "Lekr0");
		ServerCommand("bot_add_ct %s", "nawwk");
		ServerCommand("bot_add_ct %s", "Plopski");
		ServerCommand("bot_add_ct %s", "REZ");
		ServerCommand("mp_teamlogo_1 nip");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "twist");
		ServerCommand("bot_add_t %s", "Lekr0");
		ServerCommand("bot_add_t %s", "nawwk");
		ServerCommand("bot_add_t %s", "Plopski");
		ServerCommand("bot_add_t %s", "REZ");
		ServerCommand("mp_teamlogo_2 nip");
	}
	
	return Plugin_Handled;
}

public Action Team_MIBR(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "kNgV-");
		ServerCommand("bot_add_ct %s", "FalleN");
		ServerCommand("bot_add_ct %s", "fer");
		ServerCommand("bot_add_ct %s", "TACO");
		ServerCommand("bot_add_ct %s", "meyern");
		ServerCommand("mp_teamlogo_1 mibr");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "kNgV-");
		ServerCommand("bot_add_t %s", "FalleN");
		ServerCommand("bot_add_t %s", "fer");
		ServerCommand("bot_add_t %s", "TACO");
		ServerCommand("bot_add_t %s", "meyern");
		ServerCommand("mp_teamlogo_2 mibr");
	}
	
	return Plugin_Handled;
}

public Action Team_FaZe(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "olofmeister");
		ServerCommand("bot_add_ct %s", "broky");
		ServerCommand("bot_add_ct %s", "NiKo");
		ServerCommand("bot_add_ct %s", "rain");
		ServerCommand("bot_add_ct %s", "coldzera");
		ServerCommand("mp_teamlogo_1 faze");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "olofmeister");
		ServerCommand("bot_add_t %s", "broky");
		ServerCommand("bot_add_t %s", "NiKo");
		ServerCommand("bot_add_t %s", "rain");
		ServerCommand("bot_add_t %s", "coldzera");
		ServerCommand("mp_teamlogo_2 faze");
	}
	
	return Plugin_Handled;
}

public Action Team_Astralis(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Xyp9x");
		ServerCommand("bot_add_ct %s", "device");
		ServerCommand("bot_add_ct %s", "gla1ve");
		ServerCommand("bot_add_ct %s", "Magisk");
		ServerCommand("bot_add_ct %s", "dupreeh");
		ServerCommand("mp_teamlogo_1 astr");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Xyp9x");
		ServerCommand("bot_add_t %s", "device");
		ServerCommand("bot_add_t %s", "gla1ve");
		ServerCommand("bot_add_t %s", "Magisk");
		ServerCommand("bot_add_t %s", "dupreeh");
		ServerCommand("mp_teamlogo_2 astr");
	}
	
	return Plugin_Handled;
}

public Action Team_C9(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "JT");
		ServerCommand("bot_add_ct %s", "Sonic");
		ServerCommand("bot_add_ct %s", "motm");
		ServerCommand("bot_add_ct %s", "oSee");
		ServerCommand("bot_add_ct %s", "floppy");
		ServerCommand("mp_teamlogo_1 c9");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "JT");
		ServerCommand("bot_add_t %s", "Sonic");
		ServerCommand("bot_add_t %s", "motm");
		ServerCommand("bot_add_t %s", "oSee");
		ServerCommand("bot_add_t %s", "floppy");
		ServerCommand("mp_teamlogo_2 c9");
	}
	
	return Plugin_Handled;
}

public Action Team_G2(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "huNter-");
		ServerCommand("bot_add_ct %s", "kennyS");
		ServerCommand("bot_add_ct %s", "nexa");
		ServerCommand("bot_add_ct %s", "JaCkz");
		ServerCommand("bot_add_ct %s", "AMANEK");
		ServerCommand("mp_teamlogo_1 g2");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "huNter-");
		ServerCommand("bot_add_t %s", "kennyS");
		ServerCommand("bot_add_t %s", "nexa");
		ServerCommand("bot_add_t %s", "JaCkz");
		ServerCommand("bot_add_t %s", "AMANEK");
		ServerCommand("mp_teamlogo_2 g2");
	}
	
	return Plugin_Handled;
}

public Action Team_fnatic(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "flusha");
		ServerCommand("bot_add_ct %s", "JW");
		ServerCommand("bot_add_ct %s", "KRiMZ");
		ServerCommand("bot_add_ct %s", "Brollan");
		ServerCommand("bot_add_ct %s", "Golden");
		ServerCommand("mp_teamlogo_1 fnatic");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "flusha");
		ServerCommand("bot_add_t %s", "JW");
		ServerCommand("bot_add_t %s", "KRiMZ");
		ServerCommand("bot_add_t %s", "Brollan");
		ServerCommand("bot_add_t %s", "Golden");
		ServerCommand("mp_teamlogo_2 fnatic");
	}
	
	return Plugin_Handled;
}

public Action Team_North(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "MSL");
		ServerCommand("bot_add_ct %s", "Kjaerbye");
		ServerCommand("bot_add_ct %s", "aizy");
		ServerCommand("bot_add_ct %s", "cajunb");
		ServerCommand("bot_add_ct %s", "gade");
		ServerCommand("mp_teamlogo_1 north");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "MSL");
		ServerCommand("bot_add_t %s", "Kjaerbye");
		ServerCommand("bot_add_t %s", "aizy");
		ServerCommand("bot_add_t %s", "cajunb");
		ServerCommand("bot_add_t %s", "gade");
		ServerCommand("mp_teamlogo_2 north");
	}
	
	return Plugin_Handled;
}

public Action Team_mouz(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "karrigan");
		ServerCommand("bot_add_ct %s", "chrisJ");
		ServerCommand("bot_add_ct %s", "woxic");
		ServerCommand("bot_add_ct %s", "frozen");
		ServerCommand("bot_add_ct %s", "ropz");
		ServerCommand("mp_teamlogo_1 mss");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "karrigan");
		ServerCommand("bot_add_t %s", "chrisJ");
		ServerCommand("bot_add_t %s", "woxic");
		ServerCommand("bot_add_t %s", "frozen");
		ServerCommand("bot_add_t %s", "ropz");
		ServerCommand("mp_teamlogo_2 mss");
	}
	
	return Plugin_Handled;
}

public Action Team_TYLOO(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Summer");
		ServerCommand("bot_add_ct %s", "Attacker");
		ServerCommand("bot_add_ct %s", "xeta");
		ServerCommand("bot_add_ct %s", "somebody");
		ServerCommand("bot_add_ct %s", "Freeman");
		ServerCommand("mp_teamlogo_1 tyl");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Summer");
		ServerCommand("bot_add_t %s", "Attacker");
		ServerCommand("bot_add_t %s", "xeta");
		ServerCommand("bot_add_t %s", "somebody");
		ServerCommand("bot_add_t %s", "Freeman");
		ServerCommand("mp_teamlogo_2 tyl");
	}
	
	return Plugin_Handled;
}

public Action Team_EG(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "stanislaw");
		ServerCommand("bot_add_ct %s", "tarik");
		ServerCommand("bot_add_ct %s", "Brehze");
		ServerCommand("bot_add_ct %s", "Ethan");
		ServerCommand("bot_add_ct %s", "CeRq");
		ServerCommand("mp_teamlogo_1 eg");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "stanislaw");
		ServerCommand("bot_add_t %s", "tarik");
		ServerCommand("bot_add_t %s", "Brehze");
		ServerCommand("bot_add_t %s", "Ethan");
		ServerCommand("bot_add_t %s", "CeRq");
		ServerCommand("mp_teamlogo_2 eg");
	}
	
	return Plugin_Handled;
}

public Action Team_Thieves(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "AZR");
		ServerCommand("bot_add_ct %s", "jks");
		ServerCommand("bot_add_ct %s", "jkaem");
		ServerCommand("bot_add_ct %s", "Gratisfaction");
		ServerCommand("bot_add_ct %s", "Liazz");
		ServerCommand("mp_teamlogo_1 thv");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "AZR");
		ServerCommand("bot_add_t %s", "jks");
		ServerCommand("bot_add_t %s", "jkaem");
		ServerCommand("bot_add_t %s", "Gratisfaction");
		ServerCommand("bot_add_t %s", "Liazz");
		ServerCommand("mp_teamlogo_2 thv");
	}
	
	return Plugin_Handled;
}

public Action Team_NaVi(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "electronic");
		ServerCommand("bot_add_ct %s", "s1mple");
		ServerCommand("bot_add_ct %s", "flamie");
		ServerCommand("bot_add_ct %s", "Boombl4");
		ServerCommand("bot_add_ct %s", "Perfecto");
		ServerCommand("mp_teamlogo_1 navi");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "electronic");
		ServerCommand("bot_add_t %s", "s1mple");
		ServerCommand("bot_add_t %s", "flamie");
		ServerCommand("bot_add_t %s", "Boombl4");
		ServerCommand("bot_add_t %s", "Perfecto");
		ServerCommand("mp_teamlogo_2 navi");
	}
	
	return Plugin_Handled;
}

public Action Team_Liquid(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Stewie2K");
		ServerCommand("bot_add_ct %s", "NAF");
		ServerCommand("bot_add_ct %s", "nitr0");
		ServerCommand("bot_add_ct %s", "ELiGE");
		ServerCommand("bot_add_ct %s", "Twistzz");
		ServerCommand("mp_teamlogo_1 liq");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Stewie2K");
		ServerCommand("bot_add_t %s", "NAF");
		ServerCommand("bot_add_t %s", "nitr0");
		ServerCommand("bot_add_t %s", "ELiGE");
		ServerCommand("bot_add_t %s", "Twistzz");
		ServerCommand("mp_teamlogo_2 liq");
	}
	
	return Plugin_Handled;
}

public Action Team_AGO(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Furlan");
		ServerCommand("bot_add_ct %s", "GruBy");
		ServerCommand("bot_add_ct %s", "mhL");
		ServerCommand("bot_add_ct %s", "F1KU");
		ServerCommand("bot_add_ct %s", "oskarish");
		ServerCommand("mp_teamlogo_1 ago");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Furlan");
		ServerCommand("bot_add_t %s", "GruBy");
		ServerCommand("bot_add_t %s", "mhL");
		ServerCommand("bot_add_t %s", "F1KU");
		ServerCommand("bot_add_t %s", "oskarish");
		ServerCommand("mp_teamlogo_2 ago");
	}
	
	return Plugin_Handled;
}

public Action Team_ENCE(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "suNny");
		ServerCommand("bot_add_ct %s", "allu");
		ServerCommand("bot_add_ct %s", "sergej");
		ServerCommand("bot_add_ct %s", "Aerial");
		ServerCommand("bot_add_ct %s", "xseveN");
		ServerCommand("mp_teamlogo_1 ence");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "suNny");
		ServerCommand("bot_add_t %s", "allu");
		ServerCommand("bot_add_t %s", "sergej");
		ServerCommand("bot_add_t %s", "Aerial");
		ServerCommand("bot_add_t %s", "xseveN");
		ServerCommand("mp_teamlogo_2 ence");
	}
	
	return Plugin_Handled;
}

public Action Team_Vitality(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "shox");
		ServerCommand("bot_add_ct %s", "ZywOo");
		ServerCommand("bot_add_ct %s", "apEX");
		ServerCommand("bot_add_ct %s", "RpK");
		ServerCommand("bot_add_ct %s", "Misutaaa");
		ServerCommand("mp_teamlogo_1 vita");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "shox");
		ServerCommand("bot_add_t %s", "ZywOo");
		ServerCommand("bot_add_t %s", "apEX");
		ServerCommand("bot_add_t %s", "RpK");
		ServerCommand("bot_add_t %s", "Misutaaa");
		ServerCommand("mp_teamlogo_2 vita");
	}
	
	return Plugin_Handled;
}

public Action Team_BIG(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "tiziaN");
		ServerCommand("bot_add_ct %s", "syrsoN");
		ServerCommand("bot_add_ct %s", "XANTARES");
		ServerCommand("bot_add_ct %s", "tabseN");
		ServerCommand("bot_add_ct %s", "k1to");
		ServerCommand("mp_teamlogo_1 big");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "tiziaN");
		ServerCommand("bot_add_t %s", "syrsoN");
		ServerCommand("bot_add_t %s", "XANTARES");
		ServerCommand("bot_add_t %s", "tabseN");
		ServerCommand("bot_add_t %s", "k1to");
		ServerCommand("mp_teamlogo_2 big");
	}
	
	return Plugin_Handled;
}

public Action Team_FURIA(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "yuurih");
		ServerCommand("bot_add_ct %s", "arT");
		ServerCommand("bot_add_ct %s", "VINI");
		ServerCommand("bot_add_ct %s", "kscerato");
		ServerCommand("bot_add_ct %s", "HEN1");
		ServerCommand("mp_teamlogo_1 furi");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "yuurih");
		ServerCommand("bot_add_t %s", "arT");
		ServerCommand("bot_add_t %s", "VINI");
		ServerCommand("bot_add_t %s", "kscerato");
		ServerCommand("bot_add_t %s", "HEN1");
		ServerCommand("mp_teamlogo_2 furi");
	}
	
	return Plugin_Handled;
}

public Action Team_c0ntact(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "LETN1");
		ServerCommand("bot_add_ct %s", "ottoNd");
		ServerCommand("bot_add_ct %s", "SHiPZ");
		ServerCommand("bot_add_ct %s", "emi");
		ServerCommand("bot_add_ct %s", "EspiranTo");
		ServerCommand("mp_teamlogo_1 c0n");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "LETN1");
		ServerCommand("bot_add_t %s", "ottoNd");
		ServerCommand("bot_add_t %s", "SHiPZ");
		ServerCommand("bot_add_t %s", "emi");
		ServerCommand("bot_add_t %s", "EspiranTo");
		ServerCommand("mp_teamlogo_2 c0n");
	}
	
	return Plugin_Handled;
}

public Action Team_coL(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "k0nfig");
		ServerCommand("bot_add_ct %s", "poizon");
		ServerCommand("bot_add_ct %s", "oBo");
		ServerCommand("bot_add_ct %s", "RUSH");
		ServerCommand("bot_add_ct %s", "blameF");
		ServerCommand("mp_teamlogo_1 col");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "k0nfig");
		ServerCommand("bot_add_t %s", "poizon");
		ServerCommand("bot_add_t %s", "oBo");
		ServerCommand("bot_add_t %s", "RUSH");
		ServerCommand("bot_add_t %s", "blameF");
		ServerCommand("mp_teamlogo_2 col");
	}
	
	return Plugin_Handled;
}

public Action Team_ViCi(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "zhokiNg");
		ServerCommand("bot_add_ct %s", "kaze");
		ServerCommand("bot_add_ct %s", "aumaN");
		ServerCommand("bot_add_ct %s", "JamYoung");
		ServerCommand("bot_add_ct %s", "advent");
		ServerCommand("mp_teamlogo_1 vici");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "zhokiNg");
		ServerCommand("bot_add_t %s", "kaze");
		ServerCommand("bot_add_t %s", "aumaN");
		ServerCommand("bot_add_t %s", "JamYoung");
		ServerCommand("bot_add_t %s", "advent");
		ServerCommand("mp_teamlogo_2 vici");
	}
	
	return Plugin_Handled;
}

public Action Team_forZe(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "facecrack");
		ServerCommand("bot_add_ct %s", "xsepower");
		ServerCommand("bot_add_ct %s", "FL1T");
		ServerCommand("bot_add_ct %s", "almazer");
		ServerCommand("bot_add_ct %s", "Jerry");
		ServerCommand("mp_teamlogo_1 forz");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "facecrack");
		ServerCommand("bot_add_t %s", "xsepower");
		ServerCommand("bot_add_t %s", "FL1T");
		ServerCommand("bot_add_t %s", "almazer");
		ServerCommand("bot_add_t %s", "Jerry");
		ServerCommand("mp_teamlogo_2 forz");
	}
	
	return Plugin_Handled;
}

public Action Team_Winstrike(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Lack1");
		ServerCommand("bot_add_ct %s", "KrizzeN");
		ServerCommand("bot_add_ct %s", "Hobbit");
		ServerCommand("bot_add_ct %s", "El1an");
		ServerCommand("bot_add_ct %s", "bondik");
		ServerCommand("mp_teamlogo_1 win");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Lack1");
		ServerCommand("bot_add_t %s", "KrizzeN");
		ServerCommand("bot_add_t %s", "Hobbit");
		ServerCommand("bot_add_t %s", "El1an");
		ServerCommand("bot_add_t %s", "bondik");
		ServerCommand("mp_teamlogo_2 win");
	}
	
	return Plugin_Handled;
}

public Action Team_Sprout(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "snatchie");
		ServerCommand("bot_add_ct %s", "dycha");
		ServerCommand("bot_add_ct %s", "Spiidi");
		ServerCommand("bot_add_ct %s", "faveN");
		ServerCommand("bot_add_ct %s", "denis");
		ServerCommand("mp_teamlogo_1 spr");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "snatchie");
		ServerCommand("bot_add_t %s", "dycha");
		ServerCommand("bot_add_t %s", "Spiidi");
		ServerCommand("bot_add_t %s", "faveN");
		ServerCommand("bot_add_t %s", "denis");
		ServerCommand("mp_teamlogo_2 spr");
	}
	
	return Plugin_Handled;
}

public Action Team_Heroic(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "TeSeS");
		ServerCommand("bot_add_ct %s", "b0RUP");
		ServerCommand("bot_add_ct %s", "nikozan");
		ServerCommand("bot_add_ct %s", "cadiaN");
		ServerCommand("bot_add_ct %s", "stavn");
		ServerCommand("mp_teamlogo_1 heroi");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "TeSeS");
		ServerCommand("bot_add_t %s", "b0RUP");
		ServerCommand("bot_add_t %s", "nikozan");
		ServerCommand("bot_add_t %s", "cadiaN");
		ServerCommand("bot_add_t %s", "stavn");
		ServerCommand("mp_teamlogo_2 heroi");
	}
	
	return Plugin_Handled;
}

public Action Team_INTZ(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "maxcel");
		ServerCommand("bot_add_ct %s", "gut0");
		ServerCommand("bot_add_ct %s", "danoco");
		ServerCommand("bot_add_ct %s", "detr0it");
		ServerCommand("bot_add_ct %s", "kLv");
		ServerCommand("mp_teamlogo_1 intz");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "maxcel");
		ServerCommand("bot_add_t %s", "gut0");
		ServerCommand("bot_add_t %s", "danoco");
		ServerCommand("bot_add_t %s", "detr0it");
		ServerCommand("bot_add_t %s", "kLv");
		ServerCommand("mp_teamlogo_2 intz");
	}
	
	return Plugin_Handled;
}

public Action Team_VP(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "buster");
		ServerCommand("bot_add_ct %s", "Jame");
		ServerCommand("bot_add_ct %s", "qikert");
		ServerCommand("bot_add_ct %s", "SANJI");
		ServerCommand("bot_add_ct %s", "AdreN");
		ServerCommand("mp_teamlogo_1 virtus");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "buster");
		ServerCommand("bot_add_t %s", "Jame");
		ServerCommand("bot_add_t %s", "qikert");
		ServerCommand("bot_add_t %s", "SANJI");
		ServerCommand("bot_add_t %s", "AdreN");
		ServerCommand("mp_teamlogo_2 virtus");
	}
	
	return Plugin_Handled;
}

public Action Team_Apeks(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Marcelious");
		ServerCommand("bot_add_ct %s", "truth");
		ServerCommand("bot_add_ct %s", "Grusarn");
		ServerCommand("bot_add_ct %s", "akEz");
		ServerCommand("bot_add_ct %s", "Polly");
		ServerCommand("mp_teamlogo_1 ape");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Marcelious");
		ServerCommand("bot_add_t %s", "truth");
		ServerCommand("bot_add_t %s", "Grusarn");
		ServerCommand("bot_add_t %s", "akEz");
		ServerCommand("bot_add_t %s", "Polly");
		ServerCommand("mp_teamlogo_2 ape");
	}
	
	return Plugin_Handled;
}

public Action Team_aTTaX(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "stfN");
		ServerCommand("bot_add_ct %s", "slaxz");
		ServerCommand("bot_add_ct %s", "ScrunK");
		ServerCommand("bot_add_ct %s", "kressy");
		ServerCommand("bot_add_ct %s", "mirbit");
		ServerCommand("mp_teamlogo_1 alt");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "stfN");
		ServerCommand("bot_add_t %s", "slaxz");
		ServerCommand("bot_add_t %s", "ScrunK");
		ServerCommand("bot_add_t %s", "kressy");
		ServerCommand("bot_add_t %s", "mirbit");
		ServerCommand("mp_teamlogo_2 alt");
	}
	
	return Plugin_Handled;
}

public Action Team_Renegades(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "INS");
		ServerCommand("bot_add_ct %s", "sico");
		ServerCommand("bot_add_ct %s", "dexter");
		ServerCommand("bot_add_ct %s", "Hatz");
		ServerCommand("bot_add_ct %s", "malta");
		ServerCommand("mp_teamlogo_1 ren");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "INS");
		ServerCommand("bot_add_t %s", "sico");
		ServerCommand("bot_add_t %s", "dexter");
		ServerCommand("bot_add_t %s", "Hatz");
		ServerCommand("bot_add_t %s", "malta");
		ServerCommand("mp_teamlogo_2 ren");
	}
	
	return Plugin_Handled;
}

public Action Team_Envy(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Nifty");
		ServerCommand("bot_add_ct %s", "ryann");
		ServerCommand("bot_add_ct %s", "Calyx");
		ServerCommand("bot_add_ct %s", "MICHU");
		ServerCommand("bot_add_ct %s", "moose");
		ServerCommand("mp_teamlogo_1 envy");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Nifty");
		ServerCommand("bot_add_t %s", "ryann");
		ServerCommand("bot_add_t %s", "Calyx");
		ServerCommand("bot_add_t %s", "MICHU");
		ServerCommand("bot_add_t %s", "moose");
		ServerCommand("mp_teamlogo_2 envy");
	}
	
	return Plugin_Handled;
}

public Action Team_Spirit(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "mir");
		ServerCommand("bot_add_ct %s", "iDISBALANCE");
		ServerCommand("bot_add_ct %s", "somedieyoung");
		ServerCommand("bot_add_ct %s", "chopper");
		ServerCommand("bot_add_ct %s", "magixx");
		ServerCommand("mp_teamlogo_1 spir");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "mir");
		ServerCommand("bot_add_t %s", "iDISBALANCE");
		ServerCommand("bot_add_t %s", "somedieyoung");
		ServerCommand("bot_add_t %s", "chopper");
		ServerCommand("bot_add_t %s", "magixx");
		ServerCommand("mp_teamlogo_2 spir");
	}
	
	return Plugin_Handled;
}

public Action Team_CeX(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "MT");
		ServerCommand("bot_add_ct %s", "Impact");
		ServerCommand("bot_add_ct %s", "Nukeddog");
		ServerCommand("bot_add_ct %s", "CYPHER");
		ServerCommand("bot_add_ct %s", "Murky");
		ServerCommand("mp_teamlogo_1 cex");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "MT");
		ServerCommand("bot_add_t %s", "Impact");
		ServerCommand("bot_add_t %s", "Nukeddog");
		ServerCommand("bot_add_t %s", "CYPHER");
		ServerCommand("bot_add_t %s", "Murky");
		ServerCommand("mp_teamlogo_2 cex");
	}
	
	return Plugin_Handled;
}

public Action Team_LDLC(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "LOGAN");
		ServerCommand("bot_add_ct %s", "Lambert");
		ServerCommand("bot_add_ct %s", "hAdji");
		ServerCommand("bot_add_ct %s", "Gringo");
		ServerCommand("bot_add_ct %s", "SIXER");
		ServerCommand("mp_teamlogo_1 ldl");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "LOGAN");
		ServerCommand("bot_add_t %s", "Lambert");
		ServerCommand("bot_add_t %s", "hAdji");
		ServerCommand("bot_add_t %s", "Gringo");
		ServerCommand("bot_add_t %s", "SIXER");
		ServerCommand("mp_teamlogo_2 ldl");
	}
	
	return Plugin_Handled;
}

public Action Team_GamerLegion(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "dennis");
		ServerCommand("bot_add_ct %s", "draken");
		ServerCommand("bot_add_ct %s", "freddieb");
		ServerCommand("bot_add_ct %s", "RuStY");
		ServerCommand("bot_add_ct %s", "hampus");
		ServerCommand("mp_teamlogo_1 glegion");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "dennis");
		ServerCommand("bot_add_t %s", "draken");
		ServerCommand("bot_add_t %s", "freddieb");
		ServerCommand("bot_add_t %s", "RuStY");
		ServerCommand("bot_add_t %s", "hampus");
		ServerCommand("mp_teamlogo_2 glegion");
	}
	
	return Plugin_Handled;
}

public Action Team_DIVIZON(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "devus");
		ServerCommand("bot_add_ct %s", "akay");
		ServerCommand("bot_add_ct %s", "hyped");
		ServerCommand("bot_add_ct %s", "merisinho");
		ServerCommand("bot_add_ct %s", "ykyli");
		ServerCommand("mp_teamlogo_1 divi");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "devus");
		ServerCommand("bot_add_t %s", "akay");
		ServerCommand("bot_add_t %s", "hyped");
		ServerCommand("bot_add_t %s", "merisinho");
		ServerCommand("bot_add_t %s", "ykyli");
		ServerCommand("mp_teamlogo_2 divi");
	}
	
	return Plugin_Handled;
}

public Action Team_EURONICS(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "red");
		ServerCommand("bot_add_ct %s", "maRky");
		ServerCommand("bot_add_ct %s", "PerX");
		ServerCommand("bot_add_ct %s", "Seeeya");
		ServerCommand("bot_add_ct %s", "pdy");
		ServerCommand("mp_teamlogo_1 euro");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "red");
		ServerCommand("bot_add_t %s", "maRky");
		ServerCommand("bot_add_t %s", "PerX");
		ServerCommand("bot_add_t %s", "Seeeya");
		ServerCommand("bot_add_t %s", "pdy");
		ServerCommand("mp_teamlogo_2 euro");
	}
	
	return Plugin_Handled;
}

public Action Team_nerdRage(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Frazehh");
		ServerCommand("bot_add_ct %s", "Br0die");
		ServerCommand("bot_add_ct %s", "Ping");
		ServerCommand("bot_add_ct %s", "Tadpole");
		ServerCommand("bot_add_ct %s", "LNZ");
		ServerCommand("mp_teamlogo_1 nerd");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Frazehh");
		ServerCommand("bot_add_t %s", "Br0die");
		ServerCommand("bot_add_t %s", "Ping");
		ServerCommand("bot_add_t %s", "Tadpole");
		ServerCommand("bot_add_t %s", "LNZ");
		ServerCommand("mp_teamlogo_2 nerd");
	}
	
	return Plugin_Handled;
}

public Action Team_PDucks(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "stefank0k0");
		ServerCommand("bot_add_ct %s", "ACTiV");
		ServerCommand("bot_add_ct %s", "Cargo");
		ServerCommand("bot_add_ct %s", "Krabbe");
		ServerCommand("bot_add_ct %s", "Simply");
		ServerCommand("mp_teamlogo_1 playin");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "stefank0k0");
		ServerCommand("bot_add_t %s", "ACTiV");
		ServerCommand("bot_add_t %s", "Cargo");
		ServerCommand("bot_add_t %s", "Krabbe");
		ServerCommand("bot_add_t %s", "Simply");
		ServerCommand("mp_teamlogo_2 playin");
	}
	
	return Plugin_Handled;
}

public Action Team_HAVU(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ZOREE");
		ServerCommand("bot_add_ct %s", "sLowi");
		ServerCommand("bot_add_ct %s", "doto");
		ServerCommand("bot_add_ct %s", "Hoody");
		ServerCommand("bot_add_ct %s", "sAw");
		ServerCommand("mp_teamlogo_1 havu");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ZOREE");
		ServerCommand("bot_add_t %s", "sLowi");
		ServerCommand("bot_add_t %s", "doto");
		ServerCommand("bot_add_t %s", "Hoody");
		ServerCommand("bot_add_t %s", "sAw");
		ServerCommand("mp_teamlogo_2 havu");
	}
	
	return Plugin_Handled;
}

public Action Team_Lyngby(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "birdfromsky");
		ServerCommand("bot_add_ct %s", "Twinx");
		ServerCommand("bot_add_ct %s", "maNkz");
		ServerCommand("bot_add_ct %s", "Raalz");
		ServerCommand("bot_add_ct %s", "Cabbi");
		ServerCommand("mp_teamlogo_1 lyng");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "birdfromsky");
		ServerCommand("bot_add_t %s", "Twinx");
		ServerCommand("bot_add_t %s", "maNkz");
		ServerCommand("bot_add_t %s", "Raalz");
		ServerCommand("bot_add_t %s", "Cabbi");
		ServerCommand("mp_teamlogo_2 lyng");
	}
	
	return Plugin_Handled;
}

public Action Team_GODSENT(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "maden");
		ServerCommand("bot_add_ct %s", "Maikelele");
		ServerCommand("bot_add_ct %s", "kRYSTAL");
		ServerCommand("bot_add_ct %s", "zehN");
		ServerCommand("bot_add_ct %s", "STYKO");
		ServerCommand("mp_teamlogo_1 god");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "maden");
		ServerCommand("bot_add_t %s", "Maikelele");
		ServerCommand("bot_add_t %s", "kRYSTAL");
		ServerCommand("bot_add_t %s", "zehN");
		ServerCommand("bot_add_t %s", "STYKO");
		ServerCommand("mp_teamlogo_2 god");
	}
	
	return Plugin_Handled;
}

public Action Team_Nordavind(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "tenzki");
		ServerCommand("bot_add_ct %s", "NaToSaphiX");
		ServerCommand("bot_add_ct %s", "RUBINO");
		ServerCommand("bot_add_ct %s", "HS");
		ServerCommand("bot_add_ct %s", "cromen");
		ServerCommand("mp_teamlogo_1 nord");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "tenzki");
		ServerCommand("bot_add_t %s", "NaToSaphiX");
		ServerCommand("bot_add_t %s", "RUBINO");
		ServerCommand("bot_add_t %s", "HS");
		ServerCommand("bot_add_t %s", "cromen");
		ServerCommand("mp_teamlogo_2 nord");
	}
	
	return Plugin_Handled;
}

public Action Team_SJ(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "arvid");
		ServerCommand("bot_add_ct %s", "STOVVE");
		ServerCommand("bot_add_ct %s", "SADDYX");
		ServerCommand("bot_add_ct %s", "KHRN");
		ServerCommand("bot_add_ct %s", "xartE");
		ServerCommand("mp_teamlogo_1 sjg");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "arvid");
		ServerCommand("bot_add_t %s", "STOVVE");
		ServerCommand("bot_add_t %s", "SADDYX");
		ServerCommand("bot_add_t %s", "KHRN");
		ServerCommand("bot_add_t %s", "xartE");
		ServerCommand("mp_teamlogo_2 sjg");
	}
	
	return Plugin_Handled;
}

public Action Team_Bren(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Papichulo");
		ServerCommand("bot_add_ct %s", "witz");
		ServerCommand("bot_add_ct %s", "Pro.");
		ServerCommand("bot_add_ct %s", "JA");
		ServerCommand("bot_add_ct %s", "Derek");
		ServerCommand("mp_teamlogo_1 bren");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Papichulo");
		ServerCommand("bot_add_t %s", "witz");
		ServerCommand("bot_add_t %s", "Pro.");
		ServerCommand("bot_add_t %s", "JA");
		ServerCommand("bot_add_t %s", "Derek");
		ServerCommand("mp_teamlogo_2 bren");
	}
	
	return Plugin_Handled;
}

public Action Team_Giants(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "NOPEEj");
		ServerCommand("bot_add_ct %s", "fox");
		ServerCommand("bot_add_ct %s", "pr");
		ServerCommand("bot_add_ct %s", "BLOODZ");
		ServerCommand("bot_add_ct %s", "renatoohaxx");
		ServerCommand("mp_teamlogo_1 giant");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "NOPEEj");
		ServerCommand("bot_add_t %s", "fox");
		ServerCommand("bot_add_t %s", "pr");
		ServerCommand("bot_add_t %s", "BLOODZ");
		ServerCommand("bot_add_t %s", "renatoohaxx");
		ServerCommand("mp_teamlogo_2 giant");
	}
	
	return Plugin_Handled;
}

public Action Team_Lions(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "AcilioN");
		ServerCommand("bot_add_ct %s", "acoR");
		ServerCommand("bot_add_ct %s", "Sjuush");
		ServerCommand("bot_add_ct %s", "Bubzkji");
		ServerCommand("bot_add_ct %s", "roeJ");
		ServerCommand("mp_teamlogo_1 lion");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "AcilioN");
		ServerCommand("bot_add_t %s", "acoR");
		ServerCommand("bot_add_t %s", "Sjuush");
		ServerCommand("bot_add_t %s", "Bubzkji");
		ServerCommand("bot_add_t %s", "roeJ");
		ServerCommand("mp_teamlogo_2 lion");
	}
	
	return Plugin_Handled;
}

public Action Team_Riders(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "mopoz");
		ServerCommand("bot_add_ct %s", "EasTor");
		ServerCommand("bot_add_ct %s", "steel");
		ServerCommand("bot_add_ct %s", "\"alex*\"");
		ServerCommand("bot_add_ct %s", "loWel");
		ServerCommand("mp_teamlogo_1 movis");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "mopoz");
		ServerCommand("bot_add_t %s", "EasTor");
		ServerCommand("bot_add_t %s", "steel");
		ServerCommand("bot_add_t %s", "\"alex*\"");
		ServerCommand("bot_add_t %s", "loWel");
		ServerCommand("mp_teamlogo_2 movis");
	}
	
	return Plugin_Handled;
}

public Action Team_OFFSET(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "sc4rx");
		ServerCommand("bot_add_ct %s", "obj");
		ServerCommand("bot_add_ct %s", "zlynx");
		ServerCommand("bot_add_ct %s", "ZELIN");
		ServerCommand("bot_add_ct %s", "drifking");
		ServerCommand("mp_teamlogo_1 offs");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "sc4rx");
		ServerCommand("bot_add_t %s", "obj");
		ServerCommand("bot_add_t %s", "zlynx");
		ServerCommand("bot_add_t %s", "ZELIN");
		ServerCommand("bot_add_t %s", "drifking");
		ServerCommand("mp_teamlogo_2 offs");
	}
	
	return Plugin_Handled;
}

public Action Team_x6tence(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "NikoM");
		ServerCommand("bot_add_ct %s", "\"JonY BoY\"");
		ServerCommand("bot_add_ct %s", "tomi");
		ServerCommand("bot_add_ct %s", "OMG");
		ServerCommand("bot_add_ct %s", "tutehen");
		ServerCommand("mp_teamlogo_1 x6t");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "NikoM");
		ServerCommand("bot_add_t %s", "\"JonY BoY\"");
		ServerCommand("bot_add_t %s", "tomi");
		ServerCommand("bot_add_t %s", "OMG");
		ServerCommand("bot_add_t %s", "tutehen");
		ServerCommand("mp_teamlogo_2 x6t");
	}
	
	return Plugin_Handled;
}

public Action Team_eSuba(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "NIO");
		ServerCommand("bot_add_ct %s", "Levi");
		ServerCommand("bot_add_ct %s", "\"The eLiVe\"");
		ServerCommand("bot_add_ct %s", "Blogg1s");
		ServerCommand("bot_add_ct %s", "luko");
		ServerCommand("mp_teamlogo_1 esu");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "NIO");
		ServerCommand("bot_add_t %s", "Levi");
		ServerCommand("bot_add_t %s", "\"The eLiVe\"");
		ServerCommand("bot_add_t %s", "Blogg1s");
		ServerCommand("bot_add_t %s", "luko");
		ServerCommand("mp_teamlogo_2 esu");
	}
	
	return Plugin_Handled;
}

public Action Team_Nexus(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "BTN");
		ServerCommand("bot_add_ct %s", "XELLOW");
		ServerCommand("bot_add_ct %s", "mhN1");
		ServerCommand("bot_add_ct %s", "iM");
		ServerCommand("bot_add_ct %s", "sXe");
		ServerCommand("mp_teamlogo_1 nex");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "BTN");
		ServerCommand("bot_add_t %s", "XELLOW");
		ServerCommand("bot_add_t %s", "mhN1");
		ServerCommand("bot_add_t %s", "iM");
		ServerCommand("bot_add_t %s", "sXe");
		ServerCommand("mp_teamlogo_2 nex");
	}
	
	return Plugin_Handled;
}

public Action Team_PACT(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "darko");
		ServerCommand("bot_add_ct %s", "lunAtic");
		ServerCommand("bot_add_ct %s", "Goofy");
		ServerCommand("bot_add_ct %s", "MINISE");
		ServerCommand("bot_add_ct %s", "Sobol");
		ServerCommand("mp_teamlogo_1 pact");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "darko");
		ServerCommand("bot_add_t %s", "lunAtic");
		ServerCommand("bot_add_t %s", "Goofy");
		ServerCommand("bot_add_t %s", "MINISE");
		ServerCommand("bot_add_t %s", "Sobol");
		ServerCommand("mp_teamlogo_2 pact");
	}
	
	return Plugin_Handled;
}

public Action Team_Heretics(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Nivera");
		ServerCommand("bot_add_ct %s", "Maka");
		ServerCommand("bot_add_ct %s", "xms");
		ServerCommand("bot_add_ct %s", "kioShiMa");
		ServerCommand("bot_add_ct %s", "Lucky");
		ServerCommand("mp_teamlogo_1 here");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Nivera");
		ServerCommand("bot_add_t %s", "Maka");
		ServerCommand("bot_add_t %s", "xms");
		ServerCommand("bot_add_t %s", "kioShiMa");
		ServerCommand("bot_add_t %s", "Lucky");
		ServerCommand("mp_teamlogo_2 here");
	}
	
	return Plugin_Handled;
}

public Action Team_Nemiga(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "speed4k");
		ServerCommand("bot_add_ct %s", "mds");
		ServerCommand("bot_add_ct %s", "lollipop21k");
		ServerCommand("bot_add_ct %s", "Jyo");
		ServerCommand("bot_add_ct %s", "boX");
		ServerCommand("mp_teamlogo_1 nem");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "speed4k");
		ServerCommand("bot_add_t %s", "mds");
		ServerCommand("bot_add_t %s", "lollipop21k");
		ServerCommand("bot_add_t %s", "Jyo");
		ServerCommand("bot_add_t %s", "boX");
		ServerCommand("mp_teamlogo_2 nem");
	}
	
	return Plugin_Handled;
}

public Action Team_pro100(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "dimasick");
		ServerCommand("bot_add_ct %s", "WorldEdit");
		ServerCommand("bot_add_ct %s", "YEKINDAR");
		ServerCommand("bot_add_ct %s", "wayLander");
		ServerCommand("bot_add_ct %s", "NickelBack");
		ServerCommand("mp_teamlogo_1 pro");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "dimasick");
		ServerCommand("bot_add_t %s", "WorldEdit");
		ServerCommand("bot_add_t %s", "YEKINDAR");
		ServerCommand("bot_add_t %s", "wayLander");
		ServerCommand("bot_add_t %s", "NickelBack");
		ServerCommand("mp_teamlogo_2 pro");
	}
	
	return Plugin_Handled;
}

public Action Team_YaLLa(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Remind");
		ServerCommand("bot_add_ct %s", "DEAD");
		ServerCommand("bot_add_ct %s", "Kheops");
		ServerCommand("bot_add_ct %s", "Senpai");
		ServerCommand("bot_add_ct %s", "fredi");
		ServerCommand("mp_teamlogo_1 yall");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Remind");
		ServerCommand("bot_add_t %s", "DEAD");
		ServerCommand("bot_add_t %s", "Kheops");
		ServerCommand("bot_add_t %s", "Senpai");
		ServerCommand("bot_add_t %s", "fredi");
		ServerCommand("mp_teamlogo_2 yall");
	}
	
	return Plugin_Handled;
}

public Action Team_Yeah(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "tatazin");
		ServerCommand("bot_add_ct %s", "RCF");
		ServerCommand("bot_add_ct %s", "f4stzin");
		ServerCommand("bot_add_ct %s", "iDk");
		ServerCommand("bot_add_ct %s", "dumau");
		ServerCommand("mp_teamlogo_1 yeah");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "tatazin");
		ServerCommand("bot_add_t %s", "RCF");
		ServerCommand("bot_add_t %s", "f4stzin");
		ServerCommand("bot_add_t %s", "iDk");
		ServerCommand("bot_add_t %s", "dumau");
		ServerCommand("mp_teamlogo_2 yeah");
	}
	
	return Plugin_Handled;
}

public Action Team_Singularity(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Jabbi");
		ServerCommand("bot_add_ct %s", "mertz");
		ServerCommand("bot_add_ct %s", "Fessor");
		ServerCommand("bot_add_ct %s", "TOBIZ");
		ServerCommand("bot_add_ct %s", "Celrate");
		ServerCommand("mp_teamlogo_1 sing");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Jabbi");
		ServerCommand("bot_add_t %s", "mertz");
		ServerCommand("bot_add_t %s", "Fessor");
		ServerCommand("bot_add_t %s", "TOBIZ");
		ServerCommand("bot_add_t %s", "Celrate");
		ServerCommand("mp_teamlogo_2 sing");
	}
	
	return Plugin_Handled;
}

public Action Team_DETONA(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "rikz");
		ServerCommand("bot_add_ct %s", "tiburci0");
		ServerCommand("bot_add_ct %s", "v$m");
		ServerCommand("bot_add_ct %s", "Lucaozy");
		ServerCommand("bot_add_ct %s", "Tuurtle");
		ServerCommand("mp_teamlogo_1 deto");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "rikz");
		ServerCommand("bot_add_t %s", "tiburci0");
		ServerCommand("bot_add_t %s", "v$m");
		ServerCommand("bot_add_t %s", "Lucaozy");
		ServerCommand("bot_add_t %s", "Tuurtle");
		ServerCommand("mp_teamlogo_2 deto");
	}
	
	return Plugin_Handled;
}

public Action Team_Infinity(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "k1Nky");
		ServerCommand("bot_add_ct %s", "tor1towOw");
		ServerCommand("bot_add_ct %s", "spamzzy");
		ServerCommand("bot_add_ct %s", "sam_A");
		ServerCommand("bot_add_ct %s", "Daveys");
		ServerCommand("mp_teamlogo_1 infi");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "k1Nky");
		ServerCommand("bot_add_t %s", "tor1towOw");
		ServerCommand("bot_add_t %s", "spamzzy");
		ServerCommand("bot_add_t %s", "sam_A");
		ServerCommand("bot_add_t %s", "Daveys");
		ServerCommand("mp_teamlogo_2 infi");
	}
	
	return Plugin_Handled;
}

public Action Team_Isurus(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "1962");
		ServerCommand("bot_add_ct %s", "Noktse");
		ServerCommand("bot_add_ct %s", "Reversive");
		ServerCommand("bot_add_ct %s", "decov9jse");
		ServerCommand("bot_add_ct %s", "maxujas");
		ServerCommand("mp_teamlogo_1 isu");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "1962");
		ServerCommand("bot_add_t %s", "Noktse");
		ServerCommand("bot_add_t %s", "Reversive");
		ServerCommand("bot_add_t %s", "decov9jse");
		ServerCommand("bot_add_t %s", "maxujas");
		ServerCommand("mp_teamlogo_2 isu");
	}
	
	return Plugin_Handled;
}

public Action Team_paiN(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "PKL");
		ServerCommand("bot_add_ct %s", "land1n");
		ServerCommand("bot_add_ct %s", "NEKIZ");
		ServerCommand("bot_add_ct %s", "biguzera");
		ServerCommand("bot_add_ct %s", "hardzao");
		ServerCommand("mp_teamlogo_1 pain");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "PKL");
		ServerCommand("bot_add_t %s", "land1n");
		ServerCommand("bot_add_t %s", "NEKIZ");
		ServerCommand("bot_add_t %s", "biguzera");
		ServerCommand("bot_add_t %s", "hardzao");
		ServerCommand("mp_teamlogo_2 pain");
	}
	
	return Plugin_Handled;
}

public Action Team_Sharks(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "heat");
		ServerCommand("bot_add_ct %s", "jnt");
		ServerCommand("bot_add_ct %s", "leo_drunky");
		ServerCommand("bot_add_ct %s", "exit");
		ServerCommand("bot_add_ct %s", "Luken");
		ServerCommand("mp_teamlogo_1 shark");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "heat");
		ServerCommand("bot_add_t %s", "jnt");
		ServerCommand("bot_add_t %s", "leo_drunky");
		ServerCommand("bot_add_t %s", "exit");
		ServerCommand("bot_add_t %s", "Luken");
		ServerCommand("mp_teamlogo_2 shark");
	}
	
	return Plugin_Handled;
}

public Action Team_One(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "prt");
		ServerCommand("bot_add_ct %s", "Maluk3");
		ServerCommand("bot_add_ct %s", "trk");
		ServerCommand("bot_add_ct %s", "pesadelo");
		ServerCommand("bot_add_ct %s", "b4rtiN");
		ServerCommand("mp_teamlogo_1 tone");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "prt");
		ServerCommand("bot_add_t %s", "Maluk3");
		ServerCommand("bot_add_t %s", "trk");
		ServerCommand("bot_add_t %s", "pesadelo");
		ServerCommand("bot_add_t %s", "b4rtiN");
		ServerCommand("mp_teamlogo_2 tone");
	}
	
	return Plugin_Handled;
}

public Action Team_W7M(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "skullz");
		ServerCommand("bot_add_ct %s", "raafa");
		ServerCommand("bot_add_ct %s", "ableJ");
		ServerCommand("bot_add_ct %s", "pancc");
		ServerCommand("bot_add_ct %s", "realziN");
		ServerCommand("mp_teamlogo_1 w7m");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "skullz");
		ServerCommand("bot_add_t %s", "raafa");
		ServerCommand("bot_add_t %s", "ableJ");
		ServerCommand("bot_add_t %s", "pancc");
		ServerCommand("bot_add_t %s", "realziN");
		ServerCommand("mp_teamlogo_2 w7m");
	}
	
	return Plugin_Handled;
}

public Action Team_Avant(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "BL1TZ");
		ServerCommand("bot_add_ct %s", "sterling");
		ServerCommand("bot_add_ct %s", "apoc");
		ServerCommand("bot_add_ct %s", "ofnu");
		ServerCommand("bot_add_ct %s", "HaZR");
		ServerCommand("mp_teamlogo_1 avant");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "BL1TZ");
		ServerCommand("bot_add_t %s", "sterling");
		ServerCommand("bot_add_t %s", "apoc");
		ServerCommand("bot_add_t %s", "ofnu");
		ServerCommand("bot_add_t %s", "HaZR");
		ServerCommand("mp_teamlogo_2 avant");
	}
	
	return Plugin_Handled;
}

public Action Team_Chiefs(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "stat");
		ServerCommand("bot_add_ct %s", "Jinxx");
		ServerCommand("bot_add_ct %s", "apocdud");
		ServerCommand("bot_add_ct %s", "SkulL");
		ServerCommand("bot_add_ct %s", "Mayker");
		ServerCommand("mp_teamlogo_1 chief");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "stat");
		ServerCommand("bot_add_t %s", "Jinxx");
		ServerCommand("bot_add_t %s", "apocdud");
		ServerCommand("bot_add_t %s", "SkulL");
		ServerCommand("bot_add_t %s", "Mayker");
		ServerCommand("mp_teamlogo_2 chief");
	}
	
	return Plugin_Handled;
}

public Action Team_ORDER(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "J1rah");
		ServerCommand("bot_add_ct %s", "aliStair");
		ServerCommand("bot_add_ct %s", "Rickeh");
		ServerCommand("bot_add_ct %s", "USTILO");
		ServerCommand("bot_add_ct %s", "Valiance");
		ServerCommand("mp_teamlogo_1 order");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "J1rah");
		ServerCommand("bot_add_t %s", "aliStair");
		ServerCommand("bot_add_t %s", "Rickeh");
		ServerCommand("bot_add_t %s", "USTILO");
		ServerCommand("bot_add_t %s", "Valiance");
		ServerCommand("mp_teamlogo_2 order");
	}
	
	return Plugin_Handled;
}

public Action Team_BlackS(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "hue9ze");
		ServerCommand("bot_add_ct %s", "addict");
		ServerCommand("bot_add_ct %s", "cookie");
		ServerCommand("bot_add_ct %s", "jono");
		ServerCommand("bot_add_ct %s", "Wolfah");
		ServerCommand("mp_teamlogo_1 blacks");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "hue9ze");
		ServerCommand("bot_add_t %s", "addict");
		ServerCommand("bot_add_t %s", "cookie");
		ServerCommand("bot_add_t %s", "jono");
		ServerCommand("bot_add_t %s", "Wolfah");
		ServerCommand("mp_teamlogo_2 blacks");
	}
	
	return Plugin_Handled;
}

public Action Team_SKADE(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Rock1nG");
		ServerCommand("bot_add_ct %s", "dennyslaw");
		ServerCommand("bot_add_ct %s", "rafftu");
		ServerCommand("bot_add_ct %s", "Rainwaker");
		ServerCommand("bot_add_ct %s", "SPELLAN");
		ServerCommand("mp_teamlogo_1 ska");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Rock1nG");
		ServerCommand("bot_add_t %s", "dennyslaw");
		ServerCommand("bot_add_t %s", "rafftu");
		ServerCommand("bot_add_t %s", "Rainwaker");
		ServerCommand("bot_add_t %s", "SPELLAN");
		ServerCommand("mp_teamlogo_2 ska");
	}
	
	return Plugin_Handled;
}

public Action Team_Paradox(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ino");
		ServerCommand("bot_add_ct %s", "Versa");
		ServerCommand("bot_add_ct %s", "ekul");
		ServerCommand("bot_add_ct %s", "bedonka");
		ServerCommand("bot_add_ct %s", "urbz");
		ServerCommand("mp_teamlogo_1 para");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ino");
		ServerCommand("bot_add_t %s", "Versa");
		ServerCommand("bot_add_t %s", "ekul");
		ServerCommand("bot_add_t %s", "bedonka");
		ServerCommand("bot_add_t %s", "urbz");
		ServerCommand("mp_teamlogo_2 para");
	}
	
	return Plugin_Handled;
}

public Action Team_Beyond(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "MAIROLLS");
		ServerCommand("bot_add_ct %s", "Olivia");
		ServerCommand("bot_add_ct %s", "Kntz");
		ServerCommand("bot_add_ct %s", "stk");
		ServerCommand("bot_add_ct %s", "qqGod");
		ServerCommand("mp_teamlogo_1 bey");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "MAIROLLS");
		ServerCommand("bot_add_t %s", "Olivia");
		ServerCommand("bot_add_t %s", "Kntz");
		ServerCommand("bot_add_t %s", "stk");
		ServerCommand("bot_add_t %s", "qqGod");
		ServerCommand("mp_teamlogo_2 bey");
	}
	
	return Plugin_Handled;
}

public Action Team_BOOM(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "chelo");
		ServerCommand("bot_add_ct %s", "yeL");
		ServerCommand("bot_add_ct %s", "shz");
		ServerCommand("bot_add_ct %s", "boltz");
		ServerCommand("bot_add_ct %s", "felps");
		ServerCommand("mp_teamlogo_1 boom");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "chelo");
		ServerCommand("bot_add_t %s", "yeL");
		ServerCommand("bot_add_t %s", "shz");
		ServerCommand("bot_add_t %s", "boltz");
		ServerCommand("bot_add_t %s", "felps");
		ServerCommand("mp_teamlogo_2 boom");
	}
	
	return Plugin_Handled;
}

public Action Team_Lucid(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Jinx");
		ServerCommand("bot_add_ct %s", "PTC");
		ServerCommand("bot_add_ct %s", "cbbk");
		ServerCommand("bot_add_ct %s", "JohnOlsen");
		ServerCommand("bot_add_ct %s", "Lakia");
		ServerCommand("mp_teamlogo_1 lucid");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Jinx");
		ServerCommand("bot_add_t %s", "PTC");
		ServerCommand("bot_add_t %s", "cbbk");
		ServerCommand("bot_add_t %s", "JohnOlsen");
		ServerCommand("bot_add_t %s", "Lakia");
		ServerCommand("mp_teamlogo_2 lucid");
	}
	
	return Plugin_Handled;
}

public Action Team_NASR(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "proxyyb");
		ServerCommand("bot_add_ct %s", "Real1ze");
		ServerCommand("bot_add_ct %s", "BOROS");
		ServerCommand("bot_add_ct %s", "Dementor");
		ServerCommand("bot_add_ct %s", "Just1ce");
		ServerCommand("mp_teamlogo_1 nasr");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "proxyyb");
		ServerCommand("bot_add_t %s", "Real1ze");
		ServerCommand("bot_add_t %s", "BOROS");
		ServerCommand("bot_add_t %s", "Dementor");
		ServerCommand("bot_add_t %s", "Just1ce");
		ServerCommand("mp_teamlogo_2 nasr");
	}
	
	return Plugin_Handled;
}

public Action Team_Revolution(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Rambutan");
		ServerCommand("bot_add_ct %s", "Fog");
		ServerCommand("bot_add_ct %s", "Tee");
		ServerCommand("bot_add_ct %s", "Jaybk");
		ServerCommand("bot_add_ct %s", "kun");
		ServerCommand("mp_teamlogo_1 revo");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Rambutan");
		ServerCommand("bot_add_t %s", "Fog");
		ServerCommand("bot_add_t %s", "Tee");
		ServerCommand("bot_add_t %s", "Jaybk");
		ServerCommand("bot_add_t %s", "kun");
		ServerCommand("mp_teamlogo_2 revo");
	}
	
	return Plugin_Handled;
}

public Action Team_SHIFT(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "\"Young KillerS\"");
		ServerCommand("bot_add_ct %s", "Kishi");
		ServerCommand("bot_add_ct %s", "tozz");
		ServerCommand("bot_add_ct %s", "huyhart");
		ServerCommand("bot_add_ct %s", "Imcarnus");
		ServerCommand("mp_teamlogo_1 shift");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "\"Young KillerS\"");
		ServerCommand("bot_add_t %s", "Kishi");
		ServerCommand("bot_add_t %s", "tozz");
		ServerCommand("bot_add_t %s", "huyhart");
		ServerCommand("bot_add_t %s", "Imcarnus");
		ServerCommand("mp_teamlogo_2 shift");
	}
	
	return Plugin_Handled;
}

public Action Team_nxl(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "soifong");
		ServerCommand("bot_add_ct %s", "RamCikiciew");
		ServerCommand("bot_add_ct %s", "Qbo");
		ServerCommand("bot_add_ct %s", "Vask0");
		ServerCommand("bot_add_ct %s", "smoof");
		ServerCommand("mp_teamlogo_1 nxl");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "soifong");
		ServerCommand("bot_add_t %s", "RamCikiciew");
		ServerCommand("bot_add_t %s", "Qbo");
		ServerCommand("bot_add_t %s", "Vask0");
		ServerCommand("bot_add_t %s", "smoof");
		ServerCommand("mp_teamlogo_2 nxl");
	}
	
	return Plugin_Handled;
}

public Action Team_QB(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "MadLife");
		ServerCommand("bot_add_ct %s", "Electro");
		ServerCommand("bot_add_ct %s", "nafan9");
		ServerCommand("bot_add_ct %s", "Raider");
		ServerCommand("bot_add_ct %s", "L4F");
		ServerCommand("mp_teamlogo_1 qbf");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "MadLife");
		ServerCommand("bot_add_t %s", "Electro");
		ServerCommand("bot_add_t %s", "nafan9");
		ServerCommand("bot_add_t %s", "Raider");
		ServerCommand("bot_add_t %s", "L4F");
		ServerCommand("mp_teamlogo_2 qbf");
	}
	
	return Plugin_Handled;
}

public Action Team_energy(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "pnd");
		ServerCommand("bot_add_ct %s", "disTroiT");
		ServerCommand("bot_add_ct %s", "Lichl0rd");
		ServerCommand("bot_add_ct %s", "Damz");
		ServerCommand("bot_add_ct %s", "kreatioN");
		ServerCommand("mp_teamlogo_1 ener");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "pnd");
		ServerCommand("bot_add_t %s", "disTroiT");
		ServerCommand("bot_add_t %s", "Lichl0rd");
		ServerCommand("bot_add_t %s", "Damz");
		ServerCommand("bot_add_t %s", "kreatioN");
		ServerCommand("mp_teamlogo_2 ener");
	}
	
	return Plugin_Handled;
}

public Action Team_Furious(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "nbl");
		ServerCommand("bot_add_ct %s", "anarchist");
		ServerCommand("bot_add_ct %s", "niox");
		ServerCommand("bot_add_ct %s", "iKrystal");
		ServerCommand("bot_add_ct %s", "pablek");
		ServerCommand("mp_teamlogo_1 furio");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "nbl");
		ServerCommand("bot_add_t %s", "anarchist");
		ServerCommand("bot_add_t %s", "niox");
		ServerCommand("bot_add_t %s", "iKrystal");
		ServerCommand("bot_add_t %s", "pablek");
		ServerCommand("mp_teamlogo_2 furio");
	}
	
	return Plugin_Handled;
}

public Action Team_BLUEJAYS(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "blocker");
		ServerCommand("bot_add_ct %s", "numb");
		ServerCommand("bot_add_ct %s", "REDSTAR");
		ServerCommand("bot_add_ct %s", "Patrick");
		ServerCommand("bot_add_ct %s", "dream3r");
		ServerCommand("mp_teamlogo_1 blueja");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "blocker");
		ServerCommand("bot_add_t %s", "numb");
		ServerCommand("bot_add_t %s", "REDSTAR");
		ServerCommand("bot_add_t %s", "Patrick");
		ServerCommand("bot_add_t %s", "dream3r");
		ServerCommand("mp_teamlogo_2 blueja");
	}
	
	return Plugin_Handled;
}

public Action Team_EXECUTIONERS(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ZesBeeW");
		ServerCommand("bot_add_ct %s", "FamouZ");
		ServerCommand("bot_add_ct %s", "maestro");
		ServerCommand("bot_add_ct %s", "Snyder");
		ServerCommand("bot_add_ct %s", "Sys");
		ServerCommand("mp_teamlogo_1 exec");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ZesBeeW");
		ServerCommand("bot_add_t %s", "FamouZ");
		ServerCommand("bot_add_t %s", "maestro");
		ServerCommand("bot_add_t %s", "Snyder");
		ServerCommand("bot_add_t %s", "Sys");
		ServerCommand("mp_teamlogo_2 exec");
	}
	
	return Plugin_Handled;
}

public Action Team_GroundZero(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "BURNRUOk");
		ServerCommand("bot_add_ct %s", "void");
		ServerCommand("bot_add_ct %s", "Llamas");
		ServerCommand("bot_add_ct %s", "Noobster");
		ServerCommand("bot_add_ct %s", "PEARSS");
		ServerCommand("mp_teamlogo_1 ground");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "BURNRUOk");
		ServerCommand("bot_add_t %s", "void");
		ServerCommand("bot_add_t %s", "Llamas");
		ServerCommand("bot_add_t %s", "Noobster");
		ServerCommand("bot_add_t %s", "PEARSS");
		ServerCommand("mp_teamlogo_2 ground");
	}
	
	return Plugin_Handled;
}

public Action Team_AVEZ(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "MOLSI");
		ServerCommand("bot_add_ct %s", "\"Markoś\"");
		ServerCommand("bot_add_ct %s", "KEi");
		ServerCommand("bot_add_ct %s", "Kylar");
		ServerCommand("bot_add_ct %s", "nawrot");
		ServerCommand("mp_teamlogo_1 avez");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "MOLSI");
		ServerCommand("bot_add_t %s", "\"Markoś\"");
		ServerCommand("bot_add_t %s", "KEi");
		ServerCommand("bot_add_t %s", "Kylar");
		ServerCommand("bot_add_t %s", "nawrot");
		ServerCommand("mp_teamlogo_2 avez");
	}
	
	return Plugin_Handled;
}

public Action Team_BTRG(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "HeiB");
		ServerCommand("bot_add_ct %s", "start");
		ServerCommand("bot_add_ct %s", "xccurate");
		ServerCommand("bot_add_ct %s", "ImpressioN");
		ServerCommand("bot_add_ct %s", "XigN");
		ServerCommand("mp_teamlogo_1 btrg");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "HeiB");
		ServerCommand("bot_add_t %s", "start");
		ServerCommand("bot_add_t %s", "xccurate");
		ServerCommand("bot_add_t %s", "ImpressioN");
		ServerCommand("bot_add_t %s", "XigN");
		ServerCommand("mp_teamlogo_2 btrg");
	}
	
	return Plugin_Handled;
}

public Action Team_GTZ(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "k0mpa");
		ServerCommand("bot_add_ct %s", "StepA");
		ServerCommand("bot_add_ct %s", "slaxx");
		ServerCommand("bot_add_ct %s", "Jaepe");
		ServerCommand("bot_add_ct %s", "rafaxF");
		ServerCommand("mp_teamlogo_1 gtz");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "k0mpa");
		ServerCommand("bot_add_t %s", "StepA");
		ServerCommand("bot_add_t %s", "slaxx");
		ServerCommand("bot_add_t %s", "Jaepe");
		ServerCommand("bot_add_t %s", "rafaxF");
		ServerCommand("mp_teamlogo_2 gtz");
	}
	
	return Plugin_Handled;
}

public Action Team_Flames(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Queenix");
		ServerCommand("bot_add_ct %s", "farlig");
		ServerCommand("bot_add_ct %s", "HooXi");
		ServerCommand("bot_add_ct %s", "refrezh");
		ServerCommand("bot_add_ct %s", "Nodios");
		ServerCommand("mp_teamlogo_1 copen");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Queenix");
		ServerCommand("bot_add_t %s", "farlig");
		ServerCommand("bot_add_t %s", "HooXi");
		ServerCommand("bot_add_t %s", "refrezh");
		ServerCommand("bot_add_t %s", "Nodios");
		ServerCommand("mp_teamlogo_2 copen");
	}
	
	return Plugin_Handled;
}

public Action Team_BPro(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "FlashBack");
		ServerCommand("bot_add_ct %s", "viltrex");
		ServerCommand("bot_add_ct %s", "POP0V");
		ServerCommand("bot_add_ct %s", "Krs7N");
		ServerCommand("bot_add_ct %s", "milly");
		ServerCommand("mp_teamlogo_1 bpro");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "FlashBack");
		ServerCommand("bot_add_t %s", "viltrex");
		ServerCommand("bot_add_t %s", "POP0V");
		ServerCommand("bot_add_t %s", "Krs7N");
		ServerCommand("bot_add_t %s", "milly");
		ServerCommand("mp_teamlogo_2 bpro");
	}
	
	return Plugin_Handled;
}

public Action Team_Syman(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "neaLaN");
		ServerCommand("bot_add_ct %s", "mou");
		ServerCommand("bot_add_ct %s", "n0rb3r7");
		ServerCommand("bot_add_ct %s", "kreaz");
		ServerCommand("bot_add_ct %s", "Keoz");
		ServerCommand("mp_teamlogo_1 syma");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "neaLaN");
		ServerCommand("bot_add_t %s", "mou");
		ServerCommand("bot_add_t %s", "n0rb3r7");
		ServerCommand("bot_add_t %s", "kreaz");
		ServerCommand("bot_add_t %s", "Keoz");
		ServerCommand("mp_teamlogo_2 syma");
	}
	
	return Plugin_Handled;
}

public Action Team_Goliath(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "massacRe");
		ServerCommand("bot_add_ct %s", "mango");
		ServerCommand("bot_add_ct %s", "deviaNt");
		ServerCommand("bot_add_ct %s", "adaro");
		ServerCommand("bot_add_ct %s", "ZipZip");
		ServerCommand("mp_teamlogo_1 gol");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "massacRe");
		ServerCommand("bot_add_t %s", "mango");
		ServerCommand("bot_add_t %s", "deviaNt");
		ServerCommand("bot_add_t %s", "adaro");
		ServerCommand("bot_add_t %s", "ZipZip");
		ServerCommand("mp_teamlogo_2 gol");
	}
	
	return Plugin_Handled;
}

public Action Team_Secret(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "juanflatroo");
		ServerCommand("bot_add_ct %s", "tudsoN");
		ServerCommand("bot_add_ct %s", "PERCY");
		ServerCommand("bot_add_ct %s", "sinnopsyy");
		ServerCommand("bot_add_ct %s", "anarkez");
		ServerCommand("mp_teamlogo_1 secr");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "juanflatroo");
		ServerCommand("bot_add_t %s", "tudsoN");
		ServerCommand("bot_add_t %s", "PERCY");
		ServerCommand("bot_add_t %s", "sinnopsyy");
		ServerCommand("bot_add_t %s", "anarkez");
		ServerCommand("mp_teamlogo_2 secr");
	}
	
	return Plugin_Handled;
}

public Action Team_Incept(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "micalis");
		ServerCommand("bot_add_ct %s", "jtr");
		ServerCommand("bot_add_ct %s", "zeph");
		ServerCommand("bot_add_ct %s", "Rackem");
		ServerCommand("bot_add_ct %s", "yourwombat");
		ServerCommand("mp_teamlogo_1 ince");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "micalis");
		ServerCommand("bot_add_t %s", "jtr");
		ServerCommand("bot_add_t %s", "zeph");
		ServerCommand("bot_add_t %s", "Rackem");
		ServerCommand("bot_add_t %s", "yourwombat");
		ServerCommand("mp_teamlogo_2 ince");
	}
	
	return Plugin_Handled;
}

public Action Team_UOL(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "crisby");
		ServerCommand("bot_add_ct %s", "kZyJL");
		ServerCommand("bot_add_ct %s", "Andyy");
		ServerCommand("bot_add_ct %s", "JDC");
		ServerCommand("bot_add_ct %s", ".P4TriCK");
		ServerCommand("mp_teamlogo_1 uni");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "crisby");
		ServerCommand("bot_add_t %s", "kZyJL");
		ServerCommand("bot_add_t %s", "Andyy");
		ServerCommand("bot_add_t %s", "JDC");
		ServerCommand("bot_add_t %s", ".P4TriCK");
		ServerCommand("mp_teamlogo_2 uni");
	}

	return Plugin_Handled;
}

public Action Team_Baecon(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "brA");
		ServerCommand("bot_add_ct %s", "emp");
		ServerCommand("bot_add_ct %s", "kst");
		ServerCommand("bot_add_ct %s", "fakesS2");
		ServerCommand("bot_add_ct %s", "KILLDREAM");
		ServerCommand("mp_teamlogo_1 baec");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "brA");
		ServerCommand("bot_add_t %s", "emp");
		ServerCommand("bot_add_t %s", "kst");
		ServerCommand("bot_add_t %s", "fakesS2");
		ServerCommand("bot_add_t %s", "KILLDREAM");
		ServerCommand("mp_teamlogo_2 baec");
	}

	return Plugin_Handled;
}

public Action Team_Illuminar(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Vegi");
		ServerCommand("bot_add_ct %s", "Snax");
		ServerCommand("bot_add_ct %s", "mouz");
		ServerCommand("bot_add_ct %s", "innocent");
		ServerCommand("bot_add_ct %s", "reatz");
		ServerCommand("mp_teamlogo_1 illu");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Vegi");
		ServerCommand("bot_add_t %s", "Snax");
		ServerCommand("bot_add_t %s", "mouz");
		ServerCommand("bot_add_t %s", "innocent");
		ServerCommand("bot_add_t %s", "reatz");
		ServerCommand("mp_teamlogo_2 illu");
	}

	return Plugin_Handled;
}

public Action Team_Queso(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "TheClaran");
		ServerCommand("bot_add_ct %s", "rAmbi");
		ServerCommand("bot_add_ct %s", "VARES");
		ServerCommand("bot_add_ct %s", "mik");
		ServerCommand("bot_add_ct %s", "Yaba");
		ServerCommand("mp_teamlogo_1 ques");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "TheClaran");
		ServerCommand("bot_add_t %s", "rAmbi");
		ServerCommand("bot_add_t %s", "VARES");
		ServerCommand("bot_add_t %s", "mik");
		ServerCommand("bot_add_t %s", "Yaba");
		ServerCommand("mp_teamlogo_2 ques");
	}

	return Plugin_Handled;
}

public Action Team_IG(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "0i");
		ServerCommand("bot_add_ct %s", "DeStRoYeR");
		ServerCommand("bot_add_ct %s", "flying");
		ServerCommand("bot_add_ct %s", "Viva");
		ServerCommand("bot_add_ct %s", "XiaosaGe");
		ServerCommand("mp_teamlogo_1 ig");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "0i");
		ServerCommand("bot_add_t %s", "DeStRoYeR");
		ServerCommand("bot_add_t %s", "flying");
		ServerCommand("bot_add_t %s", "Viva");
		ServerCommand("bot_add_t %s", "XiaosaGe");
		ServerCommand("mp_teamlogo_2 ig");
	}

	return Plugin_Handled;
}

public Action Team_HR(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "kAliNkA");
		ServerCommand("bot_add_ct %s", "jR");
		ServerCommand("bot_add_ct %s", "Flarich");
		ServerCommand("bot_add_ct %s", "ProbLeM");
		ServerCommand("bot_add_ct %s", "JIaYm");
		ServerCommand("mp_teamlogo_1 hlr");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "kAliNkA");
		ServerCommand("bot_add_t %s", "jR");
		ServerCommand("bot_add_t %s", "Flarich");
		ServerCommand("bot_add_t %s", "ProbLeM");
		ServerCommand("bot_add_t %s", "JIaYm");
		ServerCommand("mp_teamlogo_2 hlr");
	}

	return Plugin_Handled;
}

public Action Team_Dice(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "XpG");
		ServerCommand("bot_add_ct %s", "nonick");
		ServerCommand("bot_add_ct %s", "Kan4");
		ServerCommand("bot_add_ct %s", "Polox");
		ServerCommand("bot_add_ct %s", "DEVIL");
		ServerCommand("mp_teamlogo_1 dice");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "XpG");
		ServerCommand("bot_add_t %s", "nonick");
		ServerCommand("bot_add_t %s", "Kan4");
		ServerCommand("bot_add_t %s", "Polox");
		ServerCommand("bot_add_t %s", "DEVIL");
		ServerCommand("mp_teamlogo_2 dice");
	}

	return Plugin_Handled;
}

public Action Team_KPI(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "xikii");
		ServerCommand("bot_add_ct %s", "SunPayus");
		ServerCommand("bot_add_ct %s", "meisoN");
		ServerCommand("bot_add_ct %s", "YuRk0");
		ServerCommand("bot_add_ct %s", "NaOw");
		ServerCommand("mp_teamlogo_1 kpi");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "xikii");
		ServerCommand("bot_add_t %s", "SunPayus");
		ServerCommand("bot_add_t %s", "meisoN");
		ServerCommand("bot_add_t %s", "YuRk0");
		ServerCommand("bot_add_t %s", "NaOw");
		ServerCommand("mp_teamlogo_2 kpi");
	}

	return Plugin_Handled;
}

public Action Team_PlanetKey(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "NinoZjE");
		ServerCommand("bot_add_ct %s", "s1n");
		ServerCommand("bot_add_ct %s", "skyye");
		ServerCommand("bot_add_ct %s", "Kirby");
		ServerCommand("bot_add_ct %s", "yannick1h");
		ServerCommand("mp_teamlogo_1 planet");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "NinoZjE");
		ServerCommand("bot_add_t %s", "s1n");
		ServerCommand("bot_add_t %s", "skyye");
		ServerCommand("bot_add_t %s", "Kirby");
		ServerCommand("bot_add_t %s", "yannick1h");
		ServerCommand("mp_teamlogo_2 planet");
	}

	return Plugin_Handled;
}

public Action Team_mCon(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "k1Nzo");
		ServerCommand("bot_add_ct %s", "shaGGy");
		ServerCommand("bot_add_ct %s", "luosrevo");
		ServerCommand("bot_add_ct %s", "ReFuZR");
		ServerCommand("bot_add_ct %s", "methoDs");
		ServerCommand("mp_teamlogo_1 mcon");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "k1Nzo");
		ServerCommand("bot_add_t %s", "shaGGy");
		ServerCommand("bot_add_t %s", "luosrevo");
		ServerCommand("bot_add_t %s", "ReFuZR");
		ServerCommand("bot_add_t %s", "methoDs");
		ServerCommand("mp_teamlogo_2 mcon");
	}

	return Plugin_Handled;
}

public Action Team_DreamEaters(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "CHEHOL");
		ServerCommand("bot_add_ct %s", "Quantium");
		ServerCommand("bot_add_ct %s", "Kas9k");
		ServerCommand("bot_add_ct %s", "minse");
		ServerCommand("bot_add_ct %s", "JACKPOT");
		ServerCommand("mp_teamlogo_1 dream");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "CHEHOL");
		ServerCommand("bot_add_t %s", "Quantium");
		ServerCommand("bot_add_t %s", "Kas9k");
		ServerCommand("bot_add_t %s", "minse");
		ServerCommand("bot_add_t %s", "JACKPOT");
		ServerCommand("mp_teamlogo_2 dream");
	}

	return Plugin_Handled;
}

public Action Team_HLE(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "kinqie");
		ServerCommand("bot_add_ct %s", "rAge");
		ServerCommand("bot_add_ct %s", "Krad");
		ServerCommand("bot_add_ct %s", "Forester");
		ServerCommand("bot_add_ct %s", "svyat");
		ServerCommand("mp_teamlogo_1 hle");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "kinqie");
		ServerCommand("bot_add_t %s", "rAge");
		ServerCommand("bot_add_t %s", "Krad");
		ServerCommand("bot_add_t %s", "Forester");
		ServerCommand("bot_add_t %s", "svyat");
		ServerCommand("mp_teamlogo_2 hle");
	}

	return Plugin_Handled;
}

public Action Team_Gambit(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "nafany");
		ServerCommand("bot_add_ct %s", "sh1ro");
		ServerCommand("bot_add_ct %s", "interz");
		ServerCommand("bot_add_ct %s", "Ax1Le");
		ServerCommand("bot_add_ct %s", "supra");
		ServerCommand("mp_teamlogo_1 gamb");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "nafany");
		ServerCommand("bot_add_t %s", "sh1ro");
		ServerCommand("bot_add_t %s", "interz");
		ServerCommand("bot_add_t %s", "Ax1Le");
		ServerCommand("bot_add_t %s", "supra");
		ServerCommand("mp_teamlogo_2 gamb");
	}

	return Plugin_Handled;
}

public Action Team_Wisla(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "hades");
		ServerCommand("bot_add_ct %s", "SZPERO");
		ServerCommand("bot_add_ct %s", "mynio");
		ServerCommand("bot_add_ct %s", "fanatyk");
		ServerCommand("bot_add_ct %s", "jedqr");
		ServerCommand("mp_teamlogo_1 wisla");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "hades");
		ServerCommand("bot_add_t %s", "SZPERO");
		ServerCommand("bot_add_t %s", "mynio");
		ServerCommand("bot_add_t %s", "fanatyk");
		ServerCommand("bot_add_t %s", "jedqr");
		ServerCommand("mp_teamlogo_2 wisla");
	}

	return Plugin_Handled;
}

public Action Team_Imperial(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "KHTEX");
		ServerCommand("bot_add_ct %s", "zqk");
		ServerCommand("bot_add_ct %s", "dzt");
		ServerCommand("bot_add_ct %s", "delboNi");
		ServerCommand("bot_add_ct %s", "SHOOWTiME");
		ServerCommand("mp_teamlogo_1 imp");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "KHTEX");
		ServerCommand("bot_add_t %s", "zqk");
		ServerCommand("bot_add_t %s", "dzt");
		ServerCommand("bot_add_t %s", "delboNi");
		ServerCommand("bot_add_t %s", "SHOOWTiME");
		ServerCommand("mp_teamlogo_2 imp");
	}

	return Plugin_Handled;
}

public Action Team_Big5(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "kustoM_");
		ServerCommand("bot_add_ct %s", "Spartan");
		ServerCommand("bot_add_ct %s", "SloWye-");
		ServerCommand("bot_add_ct %s", "takbok");
		ServerCommand("bot_add_ct %s", "Tiaantjie");
		ServerCommand("mp_teamlogo_1 big5");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "kustoM_");
		ServerCommand("bot_add_t %s", "Spartan");
		ServerCommand("bot_add_t %s", "SloWye-");
		ServerCommand("bot_add_t %s", "takbok");
		ServerCommand("bot_add_t %s", "Tiaantjie");
		ServerCommand("mp_teamlogo_2 big5");
	}

	return Plugin_Handled;
}

public Action Team_Unique(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "R0b3n");
		ServerCommand("bot_add_ct %s", "zorte");
		ServerCommand("bot_add_ct %s", "PASHANOJ");
		ServerCommand("bot_add_ct %s", "kenzor");
		ServerCommand("bot_add_ct %s", "fenvicious");
		ServerCommand("mp_teamlogo_1 uniq");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "R0b3n");
		ServerCommand("bot_add_t %s", "zorte");
		ServerCommand("bot_add_t %s", "PASHANOJ");
		ServerCommand("bot_add_t %s", "kenzor");
		ServerCommand("bot_add_t %s", "fenvicious");
		ServerCommand("mp_teamlogo_2 uniq");
	}

	return Plugin_Handled;
}

public Action Team_Izako(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Siuhy");
		ServerCommand("bot_add_ct %s", "szejn");
		ServerCommand("bot_add_ct %s", "EXUS");
		ServerCommand("bot_add_ct %s", "avis");
		ServerCommand("bot_add_ct %s", "TOAO");
		ServerCommand("mp_teamlogo_1 izak");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Siuhy");
		ServerCommand("bot_add_t %s", "szejn");
		ServerCommand("bot_add_t %s", "EXUS");
		ServerCommand("bot_add_t %s", "avis");
		ServerCommand("bot_add_t %s", "TOAO");
		ServerCommand("mp_teamlogo_2 izak");
	}

	return Plugin_Handled;
}

public Action Team_ATK(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "bLazE");
		ServerCommand("bot_add_ct %s", "MisteM");
		ServerCommand("bot_add_ct %s", "flexeeee");
		ServerCommand("bot_add_ct %s", "Fadey");
		ServerCommand("bot_add_ct %s", "TenZ");
		ServerCommand("mp_teamlogo_1 atk");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "bLazE");
		ServerCommand("bot_add_t %s", "MisteM");
		ServerCommand("bot_add_t %s", "flexeeee");
		ServerCommand("bot_add_t %s", "Fadey");
		ServerCommand("bot_add_t %s", "TenZ");
		ServerCommand("mp_teamlogo_2 atk");
	}

	return Plugin_Handled;
}

public Action Team_Chaos(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Xeppaa");
		ServerCommand("bot_add_ct %s", "vanity");
		ServerCommand("bot_add_ct %s", "Voltage");
		ServerCommand("bot_add_ct %s", "steel_");
		ServerCommand("bot_add_ct %s", "leaf");
		ServerCommand("mp_teamlogo_1 chaos");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Xeppaa");
		ServerCommand("bot_add_t %s", "vanity");
		ServerCommand("bot_add_t %s", "Voltage");
		ServerCommand("bot_add_t %s", "steel_");
		ServerCommand("bot_add_t %s", "leaf");
		ServerCommand("mp_teamlogo_2 chaos");
	}

	return Plugin_Handled;
}

public Action Team_OneThree(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ChildKing");
		ServerCommand("bot_add_ct %s", "lan");
		ServerCommand("bot_add_ct %s", "bottle");
		ServerCommand("bot_add_ct %s", "DD");
		ServerCommand("bot_add_ct %s", "Karsa");
		ServerCommand("mp_teamlogo_1 one");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ChildKing");
		ServerCommand("bot_add_t %s", "lan");
		ServerCommand("bot_add_t %s", "bottle");
		ServerCommand("bot_add_t %s", "DD");
		ServerCommand("bot_add_t %s", "Karsa");
		ServerCommand("mp_teamlogo_2 one");
	}

	return Plugin_Handled;
}

public Action Team_Lynn(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "XG");
		ServerCommand("bot_add_ct %s", "mitsuha");
		ServerCommand("bot_add_ct %s", "Aree");
		ServerCommand("bot_add_ct %s", "Yvonne");
		ServerCommand("bot_add_ct %s", "XinKoiNg");
		ServerCommand("mp_teamlogo_1 lynn");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "XG");
		ServerCommand("bot_add_t %s", "mitsuha");
		ServerCommand("bot_add_t %s", "Aree");
		ServerCommand("bot_add_t %s", "Yvonne");
		ServerCommand("bot_add_t %s", "XinKoiNg");
		ServerCommand("mp_teamlogo_2 lynn");
	}

	return Plugin_Handled;
}

public Action Team_Triumph(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Shakezullah");
		ServerCommand("bot_add_ct %s", "Junior");
		ServerCommand("bot_add_ct %s", "Spongey");
		ServerCommand("bot_add_ct %s", "curry");
		ServerCommand("bot_add_ct %s", "Grim");
		ServerCommand("mp_teamlogo_1 tri");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Shakezullah");
		ServerCommand("bot_add_t %s", "Junior");
		ServerCommand("bot_add_t %s", "Spongey");
		ServerCommand("bot_add_t %s", "curry");
		ServerCommand("bot_add_t %s", "Grim");
		ServerCommand("mp_teamlogo_2 tri");
	}

	return Plugin_Handled;
}

public Action Team_FATE(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "doublemagic");
		ServerCommand("bot_add_ct %s", "KalubeR");
		ServerCommand("bot_add_ct %s", "Duplicate");
		ServerCommand("bot_add_ct %s", "Mar");
		ServerCommand("bot_add_ct %s", "niki1");
		ServerCommand("mp_teamlogo_1 fate");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "doublemagic");
		ServerCommand("bot_add_t %s", "KalubeR");
		ServerCommand("bot_add_t %s", "Duplicate");
		ServerCommand("bot_add_t %s", "Mar");
		ServerCommand("bot_add_t %s", "niki1");
		ServerCommand("mp_teamlogo_2 fate");
	}

	return Plugin_Handled;
}

public Action Team_Canids(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "DeStiNy");
		ServerCommand("bot_add_ct %s", "nythonzinho");
		ServerCommand("bot_add_ct %s", "nak");
		ServerCommand("bot_add_ct %s", "latto");
		ServerCommand("bot_add_ct %s", "fnx");
		ServerCommand("mp_teamlogo_1 red");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "DeStiNy");
		ServerCommand("bot_add_t %s", "nythonzinho");
		ServerCommand("bot_add_t %s", "nak");
		ServerCommand("bot_add_t %s", "latto");
		ServerCommand("bot_add_t %s", "fnx");
		ServerCommand("mp_teamlogo_2 red");
	}

	return Plugin_Handled;
}

public Action Team_ESPADA(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Patsanchick");
		ServerCommand("bot_add_ct %s", "degster");
		ServerCommand("bot_add_ct %s", "FinigaN");
		ServerCommand("bot_add_ct %s", "S0tF1k");
		ServerCommand("bot_add_ct %s", "Dima");
		ServerCommand("mp_teamlogo_1 esp");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Patsanchick");
		ServerCommand("bot_add_t %s", "degster");
		ServerCommand("bot_add_t %s", "FinigaN");
		ServerCommand("bot_add_t %s", "S0tF1k");
		ServerCommand("bot_add_t %s", "Dima");
		ServerCommand("mp_teamlogo_2 esp");
	}

	return Plugin_Handled;
}

public Action Team_OG(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "NBK-");
		ServerCommand("bot_add_ct %s", "mantuu");
		ServerCommand("bot_add_ct %s", "Aleksib");
		ServerCommand("bot_add_ct %s", "valde");
		ServerCommand("bot_add_ct %s", "ISSAA");
		ServerCommand("mp_teamlogo_1 og");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "NBK-");
		ServerCommand("bot_add_t %s", "mantuu");
		ServerCommand("bot_add_t %s", "Aleksib");
		ServerCommand("bot_add_t %s", "valde");
		ServerCommand("bot_add_t %s", "ISSAA");
		ServerCommand("mp_teamlogo_2 og");
	}

	return Plugin_Handled;
}

public Action Team_Vexed(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Frei");
		ServerCommand("bot_add_ct %s", "Astroo");
		ServerCommand("bot_add_ct %s", "jenko");
		ServerCommand("bot_add_ct %s", "Puls3");
		ServerCommand("bot_add_ct %s", "stan1ey");
		ServerCommand("mp_teamlogo_1 vex");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Frei");
		ServerCommand("bot_add_t %s", "Astroo");
		ServerCommand("bot_add_t %s", "jenko");
		ServerCommand("bot_add_t %s", "Puls3");
		ServerCommand("bot_add_t %s", "stan1ey");
		ServerCommand("mp_teamlogo_2 vex");
	}

	return Plugin_Handled;
}

public Action Team_Tricked(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "kiR");
		ServerCommand("bot_add_ct %s", "kwezz");
		ServerCommand("bot_add_ct %s", "Luckyv1");
		ServerCommand("bot_add_ct %s", "sycrone");
		ServerCommand("bot_add_ct %s", "Toft");
		ServerCommand("mp_teamlogo_1 trick");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "kiR");
		ServerCommand("bot_add_t %s", "kwezz");
		ServerCommand("bot_add_t %s", "Luckyv1");
		ServerCommand("bot_add_t %s", "sycrone");
		ServerCommand("bot_add_t %s", "Toft");
		ServerCommand("mp_teamlogo_2 trick");
	}

	return Plugin_Handled;
}

public Action Team_GenG(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "autimatic");
		ServerCommand("bot_add_ct %s", "koosta");
		ServerCommand("bot_add_ct %s", "daps");
		ServerCommand("bot_add_ct %s", "s0m");
		ServerCommand("bot_add_ct %s", "BnTeT");
		ServerCommand("mp_teamlogo_1 gen");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "autimatic");
		ServerCommand("bot_add_t %s", "koosta");
		ServerCommand("bot_add_t %s", "daps");
		ServerCommand("bot_add_t %s", "s0m");
		ServerCommand("bot_add_t %s", "BnTeT");
		ServerCommand("mp_teamlogo_2 gen");
	}

	return Plugin_Handled;
}

public Action Team_Endpoint(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Surreal");
		ServerCommand("bot_add_ct %s", "CRUC1AL");
		ServerCommand("bot_add_ct %s", "Thomas");
		ServerCommand("bot_add_ct %s", "robiin");
		ServerCommand("bot_add_ct %s", "MiGHTYMAX");
		ServerCommand("mp_teamlogo_1 endp");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Surreal");
		ServerCommand("bot_add_t %s", "CRUC1AL");
		ServerCommand("bot_add_t %s", "Thomas");
		ServerCommand("bot_add_t %s", "robiin");
		ServerCommand("bot_add_t %s", "MiGHTYMAX");
		ServerCommand("mp_teamlogo_2 endp");
	}

	return Plugin_Handled;
}

public Action Team_sAw(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "arki");
		ServerCommand("bot_add_ct %s", "stadodo");
		ServerCommand("bot_add_ct %s", "JUST");
		ServerCommand("bot_add_ct %s", "MUTiRiS");
		ServerCommand("bot_add_ct %s", "rmn");
		ServerCommand("mp_teamlogo_1 saw");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "arki");
		ServerCommand("bot_add_t %s", "stadodo");
		ServerCommand("bot_add_t %s", "JUST");
		ServerCommand("bot_add_t %s", "MUTiRiS");
		ServerCommand("bot_add_t %s", "rmn");
		ServerCommand("mp_teamlogo_2 saw");
	}

	return Plugin_Handled;
}

public Action Team_DIG(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "GeT_RiGhT");
		ServerCommand("bot_add_ct %s", "hallzerk");
		ServerCommand("bot_add_ct %s", "f0rest");
		ServerCommand("bot_add_ct %s", "friberg");
		ServerCommand("bot_add_ct %s", "Xizt");
		ServerCommand("mp_teamlogo_1 dign");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "GeT_RiGhT");
		ServerCommand("bot_add_t %s", "hallzerk");
		ServerCommand("bot_add_t %s", "f0rest");
		ServerCommand("bot_add_t %s", "friberg");
		ServerCommand("bot_add_t %s", "Xizt");
		ServerCommand("mp_teamlogo_2 dign");
	}

	return Plugin_Handled;
}

public Action Team_D13(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Tamiraarita");
		ServerCommand("bot_add_ct %s", "rate");
		ServerCommand("bot_add_ct %s", "sKINEE");
		ServerCommand("bot_add_ct %s", "sK0R");
		ServerCommand("bot_add_ct %s", "ANNIHILATION");
		ServerCommand("mp_teamlogo_1 d13");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Tamiraarita");
		ServerCommand("bot_add_t %s", "rate");
		ServerCommand("bot_add_t %s", "sKINEE");
		ServerCommand("bot_add_t %s", "sK0R");
		ServerCommand("bot_add_t %s", "ANNIHILATION");
		ServerCommand("mp_teamlogo_2 d13");
	}

	return Plugin_Handled;
}

public Action Team_ZIGMA(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "NIFFY");
		ServerCommand("bot_add_ct %s", "Reality");
		ServerCommand("bot_add_ct %s", "JUSTCAUSE");
		ServerCommand("bot_add_ct %s", "PPOverdose");
		ServerCommand("bot_add_ct %s", "RoLEX");
		ServerCommand("mp_teamlogo_1 zigma");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "NIFFY");
		ServerCommand("bot_add_t %s", "Reality");
		ServerCommand("bot_add_t %s", "JUSTCAUSE");
		ServerCommand("bot_add_t %s", "PPOverdose");
		ServerCommand("bot_add_t %s", "RoLEX");
		ServerCommand("mp_teamlogo_2 zigma");
	}

	return Plugin_Handled;
}

public Action Team_Ambush(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Inzta");
		ServerCommand("bot_add_ct %s", "Ryxxo");
		ServerCommand("bot_add_ct %s", "zeq");
		ServerCommand("bot_add_ct %s", "Typos");
		ServerCommand("bot_add_ct %s", "IceBerg");
		ServerCommand("mp_teamlogo_1 ambu");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Inzta");
		ServerCommand("bot_add_t %s", "Ryxxo");
		ServerCommand("bot_add_t %s", "zeq");
		ServerCommand("bot_add_t %s", "Typos");
		ServerCommand("bot_add_t %s", "IceBerg");
		ServerCommand("mp_teamlogo_2 ambu");
	}

	return Plugin_Handled;
}

public Action Team_KOVA(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "pietola");
		ServerCommand("bot_add_ct %s", "Derkeps");
		ServerCommand("bot_add_ct %s", "uli");
		ServerCommand("bot_add_ct %s", "peku");
		ServerCommand("bot_add_ct %s", "Twixie");
		ServerCommand("mp_teamlogo_1 kova");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "pietola");
		ServerCommand("bot_add_t %s", "Derkeps");
		ServerCommand("bot_add_t %s", "uli");
		ServerCommand("bot_add_t %s", "peku");
		ServerCommand("bot_add_t %s", "Twixie");
		ServerCommand("mp_teamlogo_2 kova");
	}

	return Plugin_Handled;
}

public Action Team_CR4ZY(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "DemQQ");
		ServerCommand("bot_add_ct %s", "Sergiz");
		ServerCommand("bot_add_ct %s", "7oX1C");
		ServerCommand("bot_add_ct %s", "Psycho");
		ServerCommand("bot_add_ct %s", "SENSEi");
		ServerCommand("mp_teamlogo_1 cr4z");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "DemQQ");
		ServerCommand("bot_add_t %s", "Sergiz");
		ServerCommand("bot_add_t %s", "7oX1C");
		ServerCommand("bot_add_t %s", "Psycho");
		ServerCommand("bot_add_t %s", "SENSEi");
		ServerCommand("mp_teamlogo_2 cr4z");
	}

	return Plugin_Handled;
}

public Action Team_Redemption(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "drg");
		ServerCommand("bot_add_ct %s", "ALLE");
		ServerCommand("bot_add_ct %s", "remix");
		ServerCommand("bot_add_ct %s", "w1");
		ServerCommand("bot_add_ct %s", "dok");
		ServerCommand("mp_teamlogo_1 redem");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "drg");
		ServerCommand("bot_add_t %s", "ALLE");
		ServerCommand("bot_add_t %s", "remix");
		ServerCommand("bot_add_t %s", "w1");
		ServerCommand("bot_add_t %s", "dok");
		ServerCommand("mp_teamlogo_2 redem");
	}

	return Plugin_Handled;
}

public Action Team_eXploit(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "pizituh");
		ServerCommand("bot_add_ct %s", "BuJ");
		ServerCommand("bot_add_ct %s", "sark");
		ServerCommand("bot_add_ct %s", "MISK");
		ServerCommand("bot_add_ct %s", "Cunha");
		ServerCommand("mp_teamlogo_1 expl");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "pizituh");
		ServerCommand("bot_add_t %s", "BuJ");
		ServerCommand("bot_add_t %s", "sark");
		ServerCommand("bot_add_t %s", "MISK");
		ServerCommand("bot_add_t %s", "Cunha");
		ServerCommand("mp_teamlogo_2 expl");
	}

	return Plugin_Handled;
}

public Action Team_SMASH(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "disco doplan");
		ServerCommand("bot_add_ct %s", "bubble");
		ServerCommand("bot_add_ct %s", "grux");
		ServerCommand("bot_add_ct %s", "FejtZ");
		ServerCommand("bot_add_ct %s", "shokz");
		ServerCommand("mp_teamlogo_1 smash");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "disco doplan");
		ServerCommand("bot_add_t %s", "bubble");
		ServerCommand("bot_add_t %s", "grux");
		ServerCommand("bot_add_t %s", "FejtZ");
		ServerCommand("bot_add_t %s", "shokz");
		ServerCommand("mp_teamlogo_2 smash");
	}

	return Plugin_Handled;
}

public Action Team_AGF(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "fr0slev");
		ServerCommand("bot_add_ct %s", "Kristou");
		ServerCommand("bot_add_ct %s", "netrick");
		ServerCommand("bot_add_ct %s", "TMB");
		ServerCommand("bot_add_ct %s", "Lukki");
		ServerCommand("mp_teamlogo_1 agf");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "fr0slev");
		ServerCommand("bot_add_t %s", "Kristou");
		ServerCommand("bot_add_t %s", "netrick");
		ServerCommand("bot_add_t %s", "TMB");
		ServerCommand("bot_add_t %s", "Lukki");
		ServerCommand("mp_teamlogo_2 agf");
	}

	return Plugin_Handled;
}

public Action Team_Pompa(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "\"Miki Z Afryki\"");
		ServerCommand("bot_add_ct %s", "splawik");
		ServerCommand("bot_add_ct %s", "Czapel");
		ServerCommand("bot_add_ct %s", "M4tthi");
		ServerCommand("bot_add_ct %s", "grzes1x");
		ServerCommand("mp_teamlogo_1 pompa");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "\"Miki Z Afryki\"");
		ServerCommand("bot_add_t %s", "splawik");
		ServerCommand("bot_add_t %s", "Czapel");
		ServerCommand("bot_add_t %s", "M4tthi");
		ServerCommand("bot_add_t %s", "grzes1x");
		ServerCommand("mp_teamlogo_2 pompa");
	}

	return Plugin_Handled;
}

public void OnMapStart()
{
	g_iProfileRankOffset = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicLevel");
	g_iCoinOffset = FindSendPropInfo("CCSPlayerResource", "m_nActiveCoinRank");
	
	GameRules_SetProp("m_bIsValveDS", 1);
	GameRules_SetProp("m_bIsQuestEligible", 1);

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
	
	Pro_Players(botname, client);
	
	g_iProfileRank[client] = GetRandomInt(1,40);
	
	SetCustomPrivateRank(client);
	
	SDKHook(client, SDKHook_WeaponSwitch, Hook_WeaponSwitch);
}

public void OnRoundStart(Handle event, char[] name, bool dbc)
{	
	g_bFreezetimeEnd = false;
	g_bBombPlanted = false;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i) && IsFakeClient(i))
		{			
			if(GetRandomInt(1,100) <= 35)
			{
				if(GetClientTeam(i) == CS_TEAM_CT)
				{
					SetEntityModel(i, g_sCTModels[GetRandomInt(0, sizeof(g_sCTModels) - 1)]);
					
					if(GetRandomInt(1,100) <= 40)
					{
						int rndpatches = GetRandomInt(1,15);
						
						switch (rndpatches)
						{
							case 1:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 0);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 0);
									}
								}
							}
							case 2:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 0);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 1);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 0);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 1);
									}
								}
							}
							case 3:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 0);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 2);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 0);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 2);
									}
								}
							}
							case 4:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 0);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 3);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 0);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 3);
									}
								}
							}
							case 5:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 0);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 1);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 2);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 0);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 1);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 2);
									}
								}
							}
							case 6:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 1);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 1);
									}
								}
							}
							case 7:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 1);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 2);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 1);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 2);
									}
								}
							}
							case 8:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 1);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 3);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 1);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 3);
									}
								}
							}
							case 9:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 0);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 2);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 3);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 0);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 2);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 3);
									}
								}
							}
							case 10:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 2);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 2);
									}
								}
							}
							case 11:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 2);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 3);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 2);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 3);
									}
								}
							}
							case 12:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 1);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 2);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 3);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 1);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 2);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 3);
									}
								}
							}
							case 13:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 3);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 3);
									}
								}
							}
							case 14:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 0);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 1);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 3);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 0);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 1);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 3);
									}
								}
							}
							case 15:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 0);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 1);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 2);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 3);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 0);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 1);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 2);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 3);
									}
								}
							}
						}
					}
				}
				else if(GetClientTeam(i) == CS_TEAM_T)
				{
					SetEntityModel(i, g_sTModels[GetRandomInt(0, sizeof(g_sTModels) - 1)]);
					
					if(GetRandomInt(1,100) <= 25)
					{
						int rndpatches = GetRandomInt(1,15);
						
						switch (rndpatches)
						{
							case 1:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 0);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 0);
									}
								}
							}
							case 2:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 0);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 1);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 0);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 1);
									}
								}
							}
							case 3:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 0);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 2);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 0);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 2);
									}
								}
							}
							case 4:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 0);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 3);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 0);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 3);
									}
								}
							}
							case 5:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 0);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 1);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 2);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 0);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 1);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 2);
									}
								}
							}
							case 6:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 1);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 1);
									}
								}
							}
							case 7:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 1);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 2);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 1);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 2);
									}
								}
							}
							case 8:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 1);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 3);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 1);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 3);
									}
								}
							}
							case 9:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 0);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 2);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 3);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 0);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 2);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 3);
									}
								}
							}
							case 10:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 2);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 2);
									}
								}
							}
							case 11:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 2);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 3);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 2);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 3);
									}
								}
							}
							case 12:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 1);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 2);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 3);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 1);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 2);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 3);
									}
								}
							}
							case 13:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 3);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 3);
									}
								}
							}
							case 14:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 0);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 1);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 3);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 0);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 1);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 3);
									}
								}
							}
							case 15:
							{
								int rndpatch = GetRandomInt(1,2);
						
								switch(rndpatch)
								{
									case 1:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 0);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 1);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 2);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4550, 4570), 4, 3);
									}
									case 2:
									{
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 0);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 1);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 2);
										SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", GetRandomInt(4589, 4600), 4, 3);
									}
								}
							}
						}
					}
				}
			}
			
			SetEntProp(i, Prop_Send, "m_unMusicID", eItems_GetMusicKitDefIndexByMusicKitNum(GetRandomInt(0, eItems_GetMusicKitsCount() -1)));
			
			GetCurrentMap(g_sMap, sizeof(g_sMap));
			
			if(StrEqual(g_sMap, "de_mirage"))
			{
				if(GetClientTeam(i) == CS_TEAM_T)
				{
					g_iRndSmoke[i] = GetRandomInt(1,12);
					g_iRndMolotov[i] = GetRandomInt(1,4);
				}
				else if(GetClientTeam(i) == CS_TEAM_CT)
				{
					g_iRndSmoke[i] = GetRandomInt(1,3);
					g_iRndMolotov[i] = GetRandomInt(1,3);
				}
			}
		}
	}
}

public void OnFreezetimeEnd(Handle event, char[] name, bool dbc)
{
	g_bFreezetimeEnd = true;
}

public void OnBombPlanted(Handle event, char[] name, bool dbc)
{
	g_bBombPlanted = true;
}

public void Hook_OnThinkPost(int iEnt)
{
	SetEntDataArray(iEnt, g_iProfileRankOffset, g_iProfileRank, MAXPLAYERS+1);
	SetEntDataArray(iEnt, g_iCoinOffset, g_iCoin, MAXPLAYERS+1);
}

public Action Hook_WeaponSwitch(int client, int weapon)
{
	if(IsValidClient(client) && IsFakeClient(client))
	{
		int ActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"); 
		if (ActiveWeapon == -1)  return Plugin_Continue;	
		
		int index = GetEntProp(ActiveWeapon, Prop_Send, "m_iItemDefinitionIndex");
		
		if(g_bFlashed[client])
		{
			return Plugin_Handled;
		}
		else if((GetAliveTeamCount(CS_TEAM_T) == 0 || GetAliveTeamCount(CS_TEAM_CT) == 0) && (index == 41 || index == 42 || index == 59 || index == 500 || index == 503 || index == 505 || index == 506 || index == 507 || index == 508 || index == 509 || index == 512 || index == 514 || index == 515 || index == 516 || index == 517 || index == 518 || index == 519 || index == 520 || index == 521 || index == 522 || index == 523 || index == 525))
		{
			return Plugin_Handled;
		}
	}
	
	return Plugin_Continue;
}

public Action CS_OnBuyCommand(int client, const char[] weapon)
{
	if(IsValidClient(client) && IsFakeClient(client))
	{	
		if(!g_bFreezetimeEnd && GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) != -1)
		{
			return Plugin_Handled;
		}
	
		int m_iAccount = GetEntProp(client, Prop_Send, "m_iAccount");
		if(StrEqual(weapon,"m4a1"))
		{ 
			int iWeapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
			
			if(GetRandomInt(1,100) <= 30)
			{
				if (iWeapon != -1)
				{
					RemovePlayerItem(client, iWeapon);
				}
				
				m_iAccount -= 2900;
				GivePlayerItem(client, "weapon_m4a1_silencer");
				if ((m_iAccount > 16000) || (m_iAccount < 0))
					m_iAccount = 0;
				SetClientMoney(client, m_iAccount);
				return Plugin_Handled; 
			}
			else if(GetRandomInt(1,100) <= 5)
			{
				if (iWeapon != -1)
				{
					RemovePlayerItem(client, iWeapon);
				}
				
				m_iAccount -= 3300;
				GivePlayerItem(client, "weapon_aug");
				if ((m_iAccount > 16000) || (m_iAccount < 0))
					m_iAccount = 0;
				SetClientMoney(client, m_iAccount);
				return Plugin_Handled; 
			}
			else
			{
				return Plugin_Continue;
			}
		}
		else if(StrEqual(weapon,"ak47"))
		{
			int iWeapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
			
			if(GetRandomInt(1,100) <= 5)
			{
				if (iWeapon != -1)
				{
					RemovePlayerItem(client, iWeapon);
				}
				
				m_iAccount -= 3000;
				GivePlayerItem(client, "weapon_sg556");
				if ((m_iAccount > 16000) || (m_iAccount < 0))
					m_iAccount = 0;
				SetClientMoney(client, m_iAccount);
				return Plugin_Handled; 
			}
		}
		else if(StrEqual(weapon,"mac10"))
		{
			int iWeapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
			
			if(GetRandomInt(1,100) <= 40)
			{
				if (iWeapon != -1)
				{
					RemovePlayerItem(client, iWeapon);
				}
				
				m_iAccount -= 1800;
				GivePlayerItem(client, "weapon_galilar");
				if ((m_iAccount > 16000) || (m_iAccount < 0))
					m_iAccount = 0;
				SetClientMoney(client, m_iAccount);
				return Plugin_Handled; 
			}
			else
			{
				return Plugin_Continue;
			}
		}
		else if(StrEqual(weapon,"mp9"))
		{
			int iWeapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
			
			if(GetRandomInt(1,100) <= 40)
			{
				if (iWeapon != -1)
				{
					RemovePlayerItem(client, iWeapon);
				}
				
				m_iAccount -= 2050;
				GivePlayerItem(client, "weapon_famas");
				if ((m_iAccount > 16000) || (m_iAccount < 0))
					m_iAccount = 0;
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
	return Plugin_Continue;
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{  
	if (!IsFakeClient(client)) return Plugin_Continue;
	
	int ActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"); 
	if (ActiveWeapon == -1)  return Plugin_Continue;
	
	int index = GetEntProp(ActiveWeapon, Prop_Send, "m_iItemDefinitionIndex");
	
	if(buttons & IN_ATTACK && IsWeaponSlotActive(client, CS_SLOT_GRENADE))
	{
		g_bPinPulled[client] = true;
	}
	else
	{
		CreateTimer(0.1, PinNotPulled, GetClientUserId(client));
	}
	
	if(IsValidClient(client) && IsPlayerAlive(client))
	{
		if((GetAliveTeamCount(CS_TEAM_T) == 0 || GetAliveTeamCount(CS_TEAM_CT) == 0) && !(index == 49 || index == 41 || index == 42 || index == 59 || index == 500 || index == 503 || index == 505 || index == 506 || index == 507 || index == 508 || index == 509 || index == 512 || index == 514 || index == 515 || index == 516 || index == 517 || index == 518 || index == 519 || index == 520 || index == 521 || index == 522 || index == 523 || index == 525))
		{
			FakeClientCommand(client, "use weapon_knife");
		}

		char botname[512];
		GetClientName(client, botname, sizeof(botname));
		
		for(int i = 0; i <= sizeof(g_sBotName) - 1; i++)
		{
			if(StrEqual(botname, g_sBotName[i]))
			{				
				float clientEyes[3], targetEyes[3], targetEyes2[3];
				GetClientEyePosition(client, clientEyes);
				int Ent = GetClosestClient(client);
				
				int iClipAmmo = GetEntProp(ActiveWeapon, Prop_Send, "m_iClip1");
				if (iClipAmmo > 0 && g_bFreezetimeEnd)
				{
					if(IsValidClient(Ent))
					{						
						if(GetEntityMoveType(client) == MOVETYPE_LADDER)
						{
							buttons |= IN_JUMP;
							return Plugin_Changed;
						}
						
						GetClientAbsOrigin(Ent, targetEyes);
						GetClientEyePosition(Ent, targetEyes2);
						
						if((IsWeaponSlotActive(client, CS_SLOT_PRIMARY) && index != 40 && index != 11 && index != 38 && index != 9) || index == 63)
						{
							if(GetRandomInt(1,3) == 1)
							{
								targetEyes[2] = targetEyes2[2];
							}
							else
							{
								targetEyes[2] = targetEyes2[2] - GetRandomFloat(10.5, 17.5);
							}
							
							buttons |= IN_ATTACK;
						}
						else if(buttons & IN_ATTACK && IsWeaponSlotActive(client, CS_SLOT_SECONDARY) && index != 63 && index != 1)
						{
							if(GetRandomInt(1,3) == 1)
							{
								targetEyes[2] = targetEyes2[2];
							}
							else
							{
								targetEyes[2] = targetEyes2[2] - GetRandomFloat(10.5, 17.5);
							}
						}
						else if(buttons & IN_ATTACK && index == 1)
						{
							targetEyes[2] = targetEyes2[2];
						}
						else if(buttons & IN_ATTACK && (index == 40 || index == 11 || index == 38))
						{
							if(GetRandomInt(1,3) == 1)
							{
								targetEyes[2] = targetEyes2[2];
							}
							else
							{
								targetEyes[2] = targetEyes2[2] - GetRandomFloat(10.5, 17.5);
							}
						}
						else if(buttons & IN_ATTACK && IsWeaponSlotActive(client, CS_SLOT_GRENADE))
						{
							targetEyes[2] = targetEyes2[2] - GetRandomFloat(35.5, 45.5);
							buttons &= ~IN_ATTACK; 
						}
						else if(buttons & IN_ATTACK && index == 9)
						{
							targetEyes[2] = targetEyes2[2] - 10.5;
						}
						else
						{
							return Plugin_Continue;
						}
						
						float flAng[3];
						GetClientEyeAngles(client, flAng);
						
						// get normalised direction from target to client
						float desired_dir[3];
						MakeVectorFromPoints(clientEyes, targetEyes, desired_dir);
						GetVectorAngles(desired_dir, desired_dir);			
						
						flAng[0] += AngleNormalize(desired_dir[0] - flAng[0]);
						flAng[1] += AngleNormalize(desired_dir[1] - flAng[1]);
						
						float vecPunchAngle[3];
			
						if (GetEngineVersion() == Engine_CSGO || GetEngineVersion() == Engine_CSS)
						{
							GetEntPropVector(client, Prop_Send, "m_aimPunchAngle", vecPunchAngle);
						}
						else
						{
							GetEntPropVector(client, Prop_Send, "m_vecPunchAngle", vecPunchAngle);
						}
						
						if(g_cvPredictionConVars[0] != null)
						{
							flAng[0] -= vecPunchAngle[0] * GetConVarFloat(g_cvPredictionConVars[0]);
							flAng[1] -= vecPunchAngle[1] * GetConVarFloat(g_cvPredictionConVars[0]);
						}
						
						TeleportEntity(client, NULL_VECTOR, flAng, NULL_VECTOR);	
						
						if (buttons & IN_ATTACK)
						{
							if(index == 7 || index == 8 || index == 10 || index == 13 || index == 14 || index == 16 || index == 39 || index == 60 || index == 28)
							{
								buttons |= IN_DUCK;
								return Plugin_Changed;
							}
						}
					}
				}
				
				if(g_bFreezetimeEnd && !g_bBombPlanted)
				{
					//Rifles
					int weapon_ak47 = GetNearestEntity(client, "weapon_ak47"); 
					int primary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
					float ak47location[3];
					int primaryindex;
					
					if(primary != -1)
					{
						primaryindex = GetEntProp(primary, Prop_Send, "m_iItemDefinitionIndex");
					}

					if(weapon_ak47 != -1 && (primaryindex != 7 && primaryindex != 9))
					{
						GetEntPropVector(weapon_ak47, Prop_Send, "m_vecOrigin", ak47location);

						if((ak47location[0] != 0.0) && (ak47location[1] != 0.0) && (ak47location[2] != 0.0))
						{
							BotMoveTo(client, ak47location, FASTEST_ROUTE);
						}
					}
					else if(weapon_ak47 != -1 && primary == -1)
					{
						GetEntPropVector(weapon_ak47, Prop_Send, "m_vecOrigin", ak47location);		
						
						if((ak47location[0] != 0.0) && (ak47location[1] != 0.0) && (ak47location[2] != 0.0))						
						{
							BotMoveTo(client, ak47location, FASTEST_ROUTE);
						}
					}
					
					//Pistols
					int weapon_usp_silencer = GetNearestEntity(client, "weapon_hkp2000"); 
					int weapon_p250 = GetNearestEntity(client, "weapon_p250"); 
					int weapon_fiveseven = GetNearestEntity(client, "weapon_fiveseven"); 
					int weapon_tec9 = GetNearestEntity(client, "weapon_tec9"); 
					int weapon_deagle = GetNearestEntity(client, "weapon_deagle"); 
					int secondary = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
					float usplocation[3], p250location[3], fivesevenlocation[3], tec9location[3], deaglelocation[3];
					int secondaryindex;
					
					if(secondary != -1)
					{
						secondaryindex = GetEntProp(secondary, Prop_Send, "m_iItemDefinitionIndex");
					}	
					
					if(weapon_deagle != -1 && ((secondaryindex == 4) || (secondaryindex == 32) || (secondaryindex == 61) || (secondaryindex == 36) || (secondaryindex == 30) || (secondaryindex == 3) || (secondaryindex == 63)))
					{
						float location_check[3];
						GetClientAbsOrigin(client, location_check);
						GetEntPropVector(weapon_deagle, Prop_Send, "m_vecOrigin", deaglelocation);		
						
						float distance = GetVectorDistance(location_check, deaglelocation);
						
						if((deaglelocation[0] != 0.0) && (deaglelocation[1] != 0.0) && (deaglelocation[2] != 0.0))
						{
							BotMoveTo(client, deaglelocation, FASTEST_ROUTE);
						}
						
						if(distance < 25 && secondary != -1)
						{
							CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false, false);
						}
					}
					else if(weapon_deagle != -1 && secondary == -1)
					{
						GetEntPropVector(weapon_deagle, Prop_Send, "m_vecOrigin", deaglelocation);			
						
						if((deaglelocation[0] != 0.0) && (deaglelocation[1] != 0.0) && (deaglelocation[2] != 0.0))
						{
							BotMoveTo(client, deaglelocation, FASTEST_ROUTE);
						}
					}
					
					if(weapon_tec9 != -1 && ((secondaryindex == 4) || (secondaryindex == 32) || (secondaryindex == 61) || (secondaryindex == 36)))
					{
						float location_check[3];
						GetClientAbsOrigin(client, location_check);
						GetEntPropVector(weapon_tec9, Prop_Send, "m_vecOrigin", tec9location);		
						
						float distance = GetVectorDistance(location_check, tec9location);
						
						if((tec9location[0] != 0.0) && (tec9location[1] != 0.0) && (tec9location[2] != 0.0))
						{
							BotMoveTo(client, tec9location, FASTEST_ROUTE);
						}
						
						if(distance < 25 && secondary != -1)
						{
							CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false, false);
						}
					}
					else if(weapon_tec9 != -1 && secondary == -1)
					{
						GetEntPropVector(weapon_tec9, Prop_Send, "m_vecOrigin", tec9location);			
						
						if((tec9location[0] != 0.0) && (tec9location[1] != 0.0) && (tec9location[2] != 0.0))
						{
							BotMoveTo(client, tec9location, FASTEST_ROUTE);
						}
					}
					
					if(weapon_fiveseven != -1 && ((secondaryindex == 4) || (secondaryindex == 32) || (secondaryindex == 61) || (secondaryindex == 36)))
					{
						float location_check[3];
						GetClientAbsOrigin(client, location_check);
						GetEntPropVector(weapon_fiveseven, Prop_Send, "m_vecOrigin", fivesevenlocation);		
						
						float distance = GetVectorDistance(location_check, fivesevenlocation);
						
						if((fivesevenlocation[0] != 0.0) && (fivesevenlocation[1] != 0.0) && (fivesevenlocation[2] != 0.0))
						{
							BotMoveTo(client, fivesevenlocation, FASTEST_ROUTE);
						}
						
						if(distance < 25 && secondary != -1)
						{
							CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false, false);
						}
					}
					else if(weapon_fiveseven != -1 && secondary == -1)
					{
						GetEntPropVector(weapon_fiveseven, Prop_Send, "m_vecOrigin", fivesevenlocation);			
						
						if((fivesevenlocation[0] != 0.0) && (fivesevenlocation[1] != 0.0) && (fivesevenlocation[2] != 0.0))
						{
							BotMoveTo(client, fivesevenlocation, FASTEST_ROUTE);
						}
					}
					
					if(weapon_p250 != -1 && ((secondaryindex == 4) || (secondaryindex == 32) || (secondaryindex == 61)))
					{
						float location_check[3];
						GetClientAbsOrigin(client, location_check);
						GetEntPropVector(weapon_p250, Prop_Send, "m_vecOrigin", p250location);		
						
						float distance = GetVectorDistance(location_check, p250location);
						
						if((p250location[0] != 0.0) && (p250location[1] != 0.0) && (p250location[2] != 0.0))
						{
							BotMoveTo(client, p250location, FASTEST_ROUTE);
						}
						
						if(distance < 25 && secondary != -1)
						{
							CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false, false);
						}
					}
					else if(weapon_p250 != -1 && secondary == -1)
					{
						GetEntPropVector(weapon_p250, Prop_Send, "m_vecOrigin", p250location);			
						
						if((p250location[0] != 0.0) && (p250location[1] != 0.0) && (p250location[2] != 0.0))
						{
							BotMoveTo(client, p250location, FASTEST_ROUTE);
						}
					}
					
					if(weapon_usp_silencer != -1 && secondaryindex == 4)
					{
						float location_check[3];
						GetClientAbsOrigin(client, location_check);
						GetEntPropVector(weapon_usp_silencer, Prop_Send, "m_vecOrigin", usplocation);		
						
						float distance = GetVectorDistance(location_check, usplocation);
						
						if((usplocation[0] != 0.0) && (usplocation[1] != 0.0) && (usplocation[2] != 0.0))
						{
							BotMoveTo(client, usplocation, FASTEST_ROUTE);
						}
						
						if(distance < 25 && secondary != -1)
						{
							CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false, false);
						}
					}
					else if(weapon_usp_silencer != -1 && secondary == -1)
					{
						GetEntPropVector(weapon_usp_silencer, Prop_Send, "m_vecOrigin", usplocation);			
						
						if((usplocation[0] != 0.0) && (usplocation[1] != 0.0) && (usplocation[2] != 0.0))
						{
							BotMoveTo(client, usplocation, FASTEST_ROUTE);
						}
					}	
				}
				
				if (g_bFreezetimeEnd && !g_bBombPlanted)
				{
					if (ActiveWeapon != -1)
					{
						GetCurrentMap(g_sMap, sizeof(g_sMap));
						
						if(StrEqual(g_sMap, "de_mirage"))
						{
							float location_check[3];
							
							GetClientAbsOrigin(client, location_check);
							
							//T Side Smokes
							float stairs_smoke[3] = { 1152.0252685546875, -1183.9996337890625, -205.57168579101562 };
							float jungle_smoke[3] = { 815.9910888671875, -1416.0472412109375, -108.96875 };
							float topmid_smoke[3] = { 1422.737548828125, 34.83058547973633, -167.96875 };
							float triple_smoke[3] = { 815.375732421875, -1335.2979736328125, -108.96875 };
							float short_smoke[3] = { 343.3015441894531, -621.6193237304688, -163.42958068847656 };
							float rightbshort_smoke[3] = { -540.6637573242188, 520.0005493164062, -81.35236358642578 };
							float leftbshort_smoke[3] = { -148.03125, 353.0000305175781, -34.42769432067871 };
							float siteb_smoke[3] = { -736.1307983398438, 623.972900390625, -75.96875 };
							float bench_smoke[3] = { -540.6637573242188, 520.0005493164062, -81.35236358642578 };
							float connector_smoke[3] = { 343.3015441894531, -621.6193237304688, -163.42958068847656 };
							float window_smoke[3] = { 343.3015441894531, -621.6193237304688, -163.42958068847656 };
							float backb_smoke[3] = { -736.1307983398438, 623.972900390625, -75.96875 };
							
							float stairs_smoke_distance, jungle_smoke_distance, topmid_smoke_distance, triple_smoke_distance, short_smoke_distance, rightbshort_smoke_distance, leftbshort_smoke_distance, siteb_smoke_distance, bench_smoke_distance, connector_smoke_distance, window_smoke_distance, backb_smoke_distance;
							
							stairs_smoke_distance = GetVectorDistance(location_check, stairs_smoke);
							jungle_smoke_distance = GetVectorDistance(location_check, jungle_smoke);
							topmid_smoke_distance = GetVectorDistance(location_check, topmid_smoke);
							triple_smoke_distance = GetVectorDistance(location_check, triple_smoke);
							short_smoke_distance = GetVectorDistance(location_check, short_smoke);
							rightbshort_smoke_distance = GetVectorDistance(location_check, rightbshort_smoke);
							leftbshort_smoke_distance = GetVectorDistance(location_check, leftbshort_smoke);
							siteb_smoke_distance = GetVectorDistance(location_check, siteb_smoke);
							bench_smoke_distance = GetVectorDistance(location_check, bench_smoke);
							connector_smoke_distance = GetVectorDistance(location_check, connector_smoke);
							window_smoke_distance = GetVectorDistance(location_check, window_smoke);
							backb_smoke_distance = GetVectorDistance(location_check, backb_smoke);
							
							//CT Side Smokes
							float ramp_smoke[3] = { -879.9768676757812, -2263.990478515625, -171.08224487304688 };
							float apps_smoke[3] = { -2635.96875, 104.00126647949219, -159.52517700195312 };
							float palace_smoke[3] = { -971.3928833007812, -2458.048583984375, -167.97039794921875 };
							
							float ramp_smoke_distance, apps_smoke_distance, palace_smoke_distance;
							
							ramp_smoke_distance = GetVectorDistance(location_check, ramp_smoke);
							apps_smoke_distance = GetVectorDistance(location_check, apps_smoke);
							palace_smoke_distance = GetVectorDistance(location_check, palace_smoke);
							
							//T Side Molotovs
							
							float sandwich_molotov[3] = { 545.7005615234375, -1557.8095703125, -263.96875 };
							float underwindowb_molotov[3] = { -1471.96875, 664.0037841796875, -47.96874809265137 };
							float carb_molotov[3] = { -1607.9808349609375, 863.890869140625, -47.96874809265137 };
							float bench_molotov[3] = { -1607.9808349609375, 863.890869140625, -47.96874809265137 };
							
							float sandwich_molotov_distance, underwindowb_molotov_distance, carb_molotov_distance, bench_molotov_distance;
							
							sandwich_molotov_distance = GetVectorDistance(location_check, sandwich_molotov);
							underwindowb_molotov_distance = GetVectorDistance(location_check, underwindowb_molotov);
							carb_molotov_distance = GetVectorDistance(location_check, carb_molotov);
							bench_molotov_distance = GetVectorDistance(location_check, bench_molotov);
							
							//CT Side Molotovs
							float apps_molotov[3] = { -2411.96875, -247.99261474609375, -164.74143981933594 };
							float ramp_molotov[3] = { -783.987060546875, -2177.00146484375, -179.96875 };
							float palace_molotov[3] = { -783.987060546875, -2177.00146484375, -179.96875 };
							
							float apps_molotov_distance, ramp_molotov_distance, palace_molotov_distance;
							
							apps_molotov_distance = GetVectorDistance(location_check, apps_molotov);
							ramp_molotov_distance = GetVectorDistance(location_check, ramp_molotov);
							palace_molotov_distance = GetVectorDistance(location_check, palace_molotov);
							
							if(GetClientTeam(client) == CS_TEAM_T)
							{
								if (index == 45)
								{
									switch(g_iRndSmoke[client])
									{
										case 1: //Stairs Smoke
										{
											BotMoveTo(client, stairs_smoke, FASTEST_ROUTE);
											if(buttons & IN_ATTACK && stairs_smoke_distance < 50)
											{
												angles[0] = -43.0;
												angles[1] = -165.7000274658203;
												vel[0] = 0.0;
												vel[1] = 0.0;
												vel[2] = 0.0;
												TeleportEntity(client, stairs_smoke, angles, vel);
												buttons &= ~IN_ATTACK; 
											}
										}
										case 2: //Jungle Smoke
										{
											BotMoveTo(client, jungle_smoke, FASTEST_ROUTE);
											if(buttons & IN_ATTACK && jungle_smoke_distance < 50)
											{
												angles[0] = -28.0;
												angles[1] = -173.18418884277344;
												vel[0] = 0.0;
												vel[1] = 0.0;
												vel[2] = 0.0;
												TeleportEntity(client, jungle_smoke, angles, vel);
												buttons &= ~IN_ATTACK; 
											}
										}
										case 3: //Top-Mid Smoke
										{
											BotMoveTo(client, topmid_smoke, FASTEST_ROUTE);
											buttons &= ~IN_ATTACK; 
											if(buttons & IN_ATTACK && topmid_smoke_distance < 50)
											{
												angles[0] = -39.0;
												angles[1] = 196.81642150878906;
												vel[0] = 0.0;
												vel[1] = 0.0;
												vel[2] = 0.0;
												TeleportEntity(client, topmid_smoke, angles, vel);
												buttons &= ~IN_ATTACK; 
											}
										}
										case 4: //Triple Smoke
										{
											BotMoveTo(client, triple_smoke, FASTEST_ROUTE);
											if(buttons & IN_ATTACK && triple_smoke_distance < 50)
											{
												angles[0] = -46.0;
												angles[1] = -151.66416931152344;
												vel[0] = 0.0;
												vel[1] = 0.0;
												vel[2] = 0.0;
												TeleportEntity(client, triple_smoke, angles, vel);
												buttons &= ~IN_ATTACK; 
											}
										}
										case 5: //Short Smoke
										{
											BotMoveTo(client, short_smoke, FASTEST_ROUTE);
											if(buttons & IN_ATTACK && short_smoke_distance < 50)
											{
												angles[0] = -53.0;
												angles[1] = -197.30368041992188;
												vel[0] = 0.0;
												vel[1] = 0.0;
												vel[2] = 0.0;
												TeleportEntity(client, short_smoke, angles, vel);
												buttons &= ~IN_ATTACK; 
											}
										}
										case 6: //Right B Short Smoke
										{
											BotMoveTo(client, rightbshort_smoke, FASTEST_ROUTE);
											if(buttons & IN_ATTACK && rightbshort_smoke_distance < 50)
											{
												angles[0] = -70.0;
												angles[1] = -179.62820434570312;
												vel[0] = 0.0;
												vel[1] = 0.0;
												vel[2] = 0.0;
												TeleportEntity(client, rightbshort_smoke, angles, vel);
												buttons &= ~IN_ATTACK; 
											}
										}
										case 7: //Left B Short Smoke
										{
											BotMoveTo(client, leftbshort_smoke, FASTEST_ROUTE);
											if(buttons & IN_ATTACK && leftbshort_smoke_distance < 50)
											{
												angles[0] = -60.0;
												angles[1] = -173.82362365722656;
												vel[0] = 0.0;
												vel[1] = 0.0;
												vel[2] = 0.0;
												TeleportEntity(client, leftbshort_smoke, angles, vel);
												buttons &= ~IN_ATTACK; 
											}
										}
										case 8: //Site B Smoke
										{
											BotMoveTo(client, siteb_smoke, FASTEST_ROUTE);
											if(buttons & IN_ATTACK && siteb_smoke_distance < 50)
											{
												angles[0] = -57.0;
												angles[1] = -161.13607788085938;
												vel[0] = 0.0;
												vel[1] = 0.0;
												vel[2] = 0.0;
												TeleportEntity(client, siteb_smoke, angles, vel);
												buttons &= ~IN_ATTACK; 
											}
										}
										case 9: //Bench Smoke
										{
											BotMoveTo(client, bench_smoke, FASTEST_ROUTE);
											if(buttons & IN_ATTACK && bench_smoke_distance < 50)
											{
												angles[0] = -40.0;
												angles[1] = -179.62820434570312;
												vel[0] = 0.0;
												vel[1] = 0.0;
												vel[2] = 0.0;
												TeleportEntity(client, bench_smoke, angles, vel);
												buttons &= ~IN_ATTACK; 
											}
										}
										case 10: //Connector Smoke
										{
											BotMoveTo(client, connector_smoke, FASTEST_ROUTE);
											if(buttons & IN_ATTACK && connector_smoke_distance < 50)
											{
												angles[0] = -12.0;
												angles[1] = -170.30368041992188;
												vel[0] = 0.0;
												vel[1] = 0.0;
												vel[2] = 0.0;
												TeleportEntity(client, connector_smoke, angles, vel);
												buttons &= ~IN_ATTACK; 
											}
										}
										case 11: //Window Smoke
										{
											BotMoveTo(client, window_smoke, FASTEST_ROUTE);
											if(buttons & IN_ATTACK && window_smoke_distance < 50)
											{
												angles[0] = -31.0;
												angles[1] = -180.30368041992188;
												vel[0] = 0.0;
												vel[1] = 0.0;
												vel[2] = 0.0;
												TeleportEntity(client, window_smoke, angles, vel);
												buttons &= ~IN_ATTACK; 
											}
										}
										case 12: //Back B Smoke
										{
											BotMoveTo(client, backb_smoke, FASTEST_ROUTE);
											if(buttons & IN_ATTACK && backb_smoke_distance < 50)
											{
												angles[0] = -56.0;
												angles[1] = -158.13607788085938;
												vel[0] = 0.0;
												vel[1] = 0.0;
												vel[2] = 0.0;
												TeleportEntity(client, backb_smoke, angles, vel);
												buttons &= ~IN_ATTACK; 
											}
										}
									}
								}
								else if(index == 46 || index == 48)
								{
									switch(g_iRndMolotov[client])
									{
										case 1: //Sandwich Molotv
										{
											BotMoveTo(client, sandwich_molotov, FASTEST_ROUTE);
											if(buttons & IN_ATTACK && sandwich_molotov_distance < 50)
											{
												angles[0] = -23.0;
												angles[1] = -180.61326599121094;
												vel[0] = 0.0;
												vel[1] = 0.0;
												vel[2] = 0.0;
												TeleportEntity(client, sandwich_molotov, angles, vel);
												buttons &= ~IN_ATTACK; 
											}
										}
										case 2: //Under Window B Molotv
										{
											BotMoveTo(client, underwindowb_molotov, FASTEST_ROUTE);
											if(buttons & IN_ATTACK && underwindowb_molotov_distance < 50)
											{
												angles[0] = -9.0;
												angles[1] = 114.92156982421875;
												vel[0] = 0.0;
												vel[1] = 0.0;
												vel[2] = 0.0;
												TeleportEntity(client, underwindowb_molotov, angles, vel);
												buttons &= ~IN_ATTACK; 
											}
										}
										case 3: //Car B Molotv
										{
											BotMoveTo(client, carb_molotov, FASTEST_ROUTE);
											if(buttons & IN_ATTACK && carb_molotov_distance < 50)
											{
												angles[0] = 0.0;
												angles[1] = -153.24478149414062;
												vel[0] = 0.0;
												vel[1] = 0.0;
												vel[2] = 0.0;
												TeleportEntity(client, carb_molotov, angles, vel);
												buttons &= ~IN_ATTACK; 
											}
										}
										case 4: //Bench Molotv
										{
											BotMoveTo(client, bench_molotov, FASTEST_ROUTE);
											if(buttons & IN_ATTACK && bench_molotov_distance < 50)
											{
												angles[0] = -1.0;
												angles[1] = -154.24478149414062;
												vel[0] = 0.0;
												vel[1] = 0.0;
												vel[2] = 0.0;
												TeleportEntity(client, bench_molotov, angles, vel);
												buttons &= ~IN_ATTACK; 
											}
										}
									}
								}
							}
							else if(GetClientTeam(client) == CS_TEAM_CT)
							{
								if (index == 45)
								{
									switch(g_iRndSmoke[client])
									{
										case 1: //Ramp Smoke
										{
											BotMoveTo(client, ramp_smoke, FASTEST_ROUTE);
											if(buttons & IN_ATTACK && ramp_smoke_distance < 50)
											{
												angles[0] = -9.0;
												angles[1] = 34.35212707519531;
												vel[0] = 0.0;
												vel[1] = 0.0;
												vel[2] = 0.0;
												TeleportEntity(client, ramp_smoke, angles, vel);
												buttons &= ~IN_ATTACK; 
											}
										}
										case 2: //Apps Smoke
										{
											BotMoveTo(client, apps_smoke, FASTEST_ROUTE);
											if(buttons & IN_ATTACK && apps_smoke_distance < 50)
											{
												angles[0] = -21.0;
												angles[1] = 32.99325180053711;
												vel[0] = 0.0;
												vel[1] = 0.0;
												vel[2] = 0.0;
												TeleportEntity(client, apps_smoke, angles, vel);
												buttons &= ~IN_ATTACK; 
											}
										}
										case 3: //Palace Smoke
										{
											BotMoveTo(client, palace_smoke, FASTEST_ROUTE);
											if(buttons & IN_ATTACK && palace_smoke_distance < 50)
											{
												angles[0] = -55.0;
												angles[1] = 15.02410888671875;
												vel[0] = 0.0;
												vel[1] = 0.0;
												vel[2] = 0.0;
												TeleportEntity(client, palace_smoke, angles, vel);
												buttons &= ~IN_ATTACK; 
											}
										}
									}
								}
								else if(index == 46 || index == 48)
								{
									switch(g_iRndMolotov[client])
									{
										case 1: //Apps Molotv
										{
											BotMoveTo(client, apps_molotov, FASTEST_ROUTE);
											if(buttons & IN_ATTACK && apps_molotov_distance < 50)
											{
												angles[0] = -24.0;
												angles[1] = 56.12193298339844;
												vel[0] = 0.0;
												vel[1] = 0.0;
												vel[2] = 0.0;
												TeleportEntity(client, apps_molotov, angles, vel);
												buttons &= ~IN_ATTACK; 
											}
										}
										case 2: //Ramp Molotv
										{
											BotMoveTo(client, ramp_molotov, FASTEST_ROUTE);
											if(buttons & IN_ATTACK && ramp_molotov_distance < 50)
											{
												angles[0] = -22.0;
												angles[1] = 44.734649658203125;
												vel[0] = 0.0;
												vel[1] = 0.0;
												vel[2] = 0.0;
												TeleportEntity(client, ramp_molotov, angles, vel);
												buttons &= ~IN_ATTACK; 
											}
										}
										case 3: //Palace Molotv
										{
											BotMoveTo(client, palace_molotov, FASTEST_ROUTE);
											if(buttons & IN_ATTACK && palace_molotov_distance < 50)
											{
												angles[0] = -17.0;
												angles[1] = 3.734649658203125;
												vel[0] = 0.0;
												vel[1] = 0.0;
												vel[2] = 0.0;
												TeleportEntity(client, palace_molotov, angles, vel);
												buttons &= ~IN_ATTACK; 
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}

	return Plugin_Continue;
}

public Action PinNotPulled(Handle timer, any client)
{
	client = GetClientOfUserId(client);
	if(client != 0 && IsClientInGame(client))
	{
		g_bPinPulled[client] = false;
	}
	
	return Plugin_Handled;
} 

public Action Timer_CheckPlayer(Handle Timer, any data)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsFakeClient(i))
		{
			int m_iAccount = GetEntProp(i, Prop_Send, "m_iAccount");
			
			if(GetRandomInt(1,100) <= 5)
			{
				FakeClientCommand(i, "+lookatweapon");
				FakeClientCommand(i, "-lookatweapon");
			}
			
			if(m_iAccount == 800)
			{
				FakeClientCommand(i, "buy vest");
			}
			else if(m_iAccount > 2500)
			{
				FakeClientCommand(i, "buy vesthelm");
			}
		}
	}	
}

public void OnPlayerSpawn(Handle event, const char[] name, bool dontBroadcast) 
{
	for (int i = 1; i <= MaxClients; i++)
	{
		int rndcoin = GetRandomInt(1,2);
		
		switch(rndcoin)
		{
			case 1:
			{				
				g_iCoin[i] = eItems_GetPinDefIndexByPinNum(GetRandomInt(0, eItems_GetPinsCount() -1));
			}
			case 2:
			{				
				g_iCoin[i] = eItems_GetCoinDefIndexByCoinNum(GetRandomInt(0, eItems_GetCoinsCount() -1));
			}
		}
		
		if(IsValidClient(i) && IsFakeClient(i))
		{
			if (!i) return;
			
			CreateTimer(0.5, RFrame_CheckBuyZoneValue, GetClientSerial(i)); 
			
			if(GetRandomInt(1,100) >= 15)
			{
				if(GetClientTeam(i) == CS_TEAM_CT)
				{
					char usp[32];
					
					GetClientWeapon(i, usp, sizeof(usp));

					if(StrEqual(usp, "weapon_hkp2000"))
					{
						int uspslot = GetPlayerWeaponSlot(i, CS_SLOT_SECONDARY);
						
						if (uspslot != -1)
						{
							RemovePlayerItem(i, uspslot);
						}
						GivePlayerItem(i, "weapon_usp_silencer");
					}
				}
			}
			
			SetEntProp(i, Prop_Send, "m_unMusicID", eItems_GetMusicKitDefIndexByMusicKitNum(GetRandomInt(0, eItems_GetMusicKitsCount() -1)));
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
	
	int iWeapon = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
	int iPrimary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
	char default_primary[64];
	GetClientWeapon(client, default_primary, sizeof(default_primary));

	if((m_iAccount > 1500) && (m_iAccount < 2500) && iPrimary == -1 && (StrEqual(default_primary, "weapon_hkp2000") || StrEqual(default_primary, "weapon_usp_silencer") || StrEqual(default_primary, "weapon_glock")))
	{
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
			}
			case 2:
			{
				if(team == CS_TEAM_CT)
				{
					int ctcz = GetRandomInt(1,2);
					
					switch(ctcz)
					{
						case 1:
						{
							GivePlayerItem(client, "weapon_fiveseven");
						}
						case 2:
						{
							GivePlayerItem(client, "weapon_cz75a");
						}
					}
				}
				else if(team == CS_TEAM_T)
				{
					int tcz = GetRandomInt(1,2);
					
					switch(tcz)
					{
						case 1:
						{
							GivePlayerItem(client, "weapon_tec9");
						}
						case 2:
						{
							GivePlayerItem(client, "weapon_cz75a");
						}
					}
				}
			}
			case 3:
			{
				GivePlayerItem(client, "weapon_deagle");
			}
		}
	}
	else if(m_iAccount > 2500 || iPrimary != -1)
	{
		RemoveNades(client);

		if((GetEntProp(client, Prop_Data, "m_ArmorValue") < 50) || (GetEntProp(client, Prop_Send, "m_bHasHelmet") == 0))
		{
			SetEntProp(client, Prop_Data, "m_ArmorValue", 100, 1); 
			SetEntProp(client, Prop_Send, "m_bHasHelmet", 1);
			
			m_iAccount -= 1000;
			if ((m_iAccount > 16000) || (m_iAccount < 0))
					m_iAccount = 0;
			SetClientMoney(client, m_iAccount);
		}
		
		if (team == CS_TEAM_T) { 
			GivePlayerItem(client, g_sTRngGrenadesList[GetRandomInt(0, sizeof(g_sTRngGrenadesList) - 1)]);
		}
		else { 
			GivePlayerItem(client, g_sCTRngGrenadesList[GetRandomInt(0, sizeof(g_sTRngGrenadesList) - 1)]);
			SetEntProp(client, Prop_Send, "m_bHasDefuser", 1); 
		}
		
	}
	return Plugin_Stop;
}

public Action Event_PlayerBlind(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (GetEntPropFloat(client, Prop_Send, "m_flFlashMaxAlpha") >= 180.0)
	{
		float duration = GetEntPropFloat(client, Prop_Send, "m_flFlashDuration");
		if (duration >= 1.5)
		{
			if(IsFakeClient(client))
			{
				FakeClientCommand(client, "use weapon_knife");
			}
			g_bFlashed[client] = true;
			CreateTimer(duration, UnFlashed_Timer, client);
		}
	}
}

public Action UnFlashed_Timer(Handle timer, int client)
{
	g_bFlashed[client] = false;
}

public void OnClientDisconnect(int client)
{
	if(client)
	{
		g_iCoin[client] = 0;
		g_iProfileRank[client] = 0;
		SDKUnhook(client, SDKHook_WeaponSwitch, Hook_WeaponSwitch);
	}
}

public void OnPluginEnd()
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsValidClient(client) && IsFakeClient(client))
		{
			OnClientDisconnect(client);
		}
	}
}

stock int GetAliveTeamCount(int team)
{
    int number = 0;
    for (int i=1; i<=MaxClients; i++)
    {
        if (IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == team) 
            number++;
    }
    return number;
}

public void BotMoveTo(int client, float origin[3], _BotRouteType routeType)
{
	SDKCall(hBotMoveTo, client, origin, routeType);
}

public int GetNearestEntity(int client, char[] classname)
{
    int nearestEntity = -1;
    float clientVecOrigin[3], entityVecOrigin[3];
    
    GetEntPropVector(client, Prop_Data, "m_vecOrigin", clientVecOrigin); // Line 2607
    
    //Get the distance between the first entity and client
    float distance, nearestDistance = -1.0;
    
    //Find all the entity and compare the distances
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, classname)) != -1)
    {
        GetEntPropVector(entity, Prop_Data, "m_vecOrigin", entityVecOrigin); // Line 2610
        distance = GetVectorDistance(clientVecOrigin, entityVecOrigin);
        
        if (distance < nearestDistance || nearestDistance == -1.0)
        {
            nearestEntity = entity;
            nearestDistance = distance;
        }
    }
    
    return nearestEntity;
} 

public void SetClientMoney(int client, int money)
{
	SetEntProp(client, Prop_Send, "m_iAccount", money);
	
	int moneyEntity = CreateEntityByName("game_money");
	
	DispatchKeyValue(moneyEntity, "Award Text", "");
	
	DispatchSpawn(moneyEntity);
	
	AcceptEntityInput(moneyEntity, "SetMoneyAmount 0");

	AcceptEntityInput(moneyEntity, "AddMoneyPlayer", client);
	
	AcceptEntityInput(moneyEntity, "Kill");
}

public void RemoveNades(int client)
{
	while(RemoveWeaponBySlot(client, 3)){}
	for(int i = 0; i < 6; i++)
		SetEntProp(client, Prop_Send, "m_iAmmo", 0, _, g_iaGrenadeOffsets[i]);
}

public bool RemoveWeaponBySlot(int client, int iSlot)
{
	int iEntity = GetPlayerWeaponSlot(client, iSlot);
	if(IsValidEdict(iEntity)) {
		RemovePlayerItem(client, iEntity);
		AcceptEntityInput(iEntity, "Kill");
		return true;
	}
	return false;
}

stock float AngleNormalize(float angle)
{
	angle = fmodf(angle, 360.0);
	if (angle > 180) 
	{
		angle -= 360;
	}
	if (angle < -180)
	{
		angle += 360;
	}
	
	return angle;
}

stock float fmodf(float number, float denom)
{
	return number - RoundToFloor(number / denom) * denom;
}

stock bool IsWeaponSlotActive(int client, int slot)
{
    return GetPlayerWeaponSlot(client, slot) == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
}

stock int GetClosestClient(int client)
{
	float fClientOrigin[3], fTargetOrigin[3];
	
	GetClientAbsOrigin(client, fClientOrigin);
	
	int clientTeam = GetClientTeam(client);
	int iClosestTarget = -1;
	
	float fClosestDistance = -1.0;
	float fTargetDistance;
	int ActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	int index;
	char clantag[64];
	
	CS_GetClientClanTag(client, clantag, sizeof(clantag));
	
	if(ActiveWeapon != -1)
	{
		index = GetEntProp(ActiveWeapon, Prop_Send, "m_iItemDefinitionIndex");
	}
	
	CS_GetClientClanTag(client, clantag, sizeof(clantag));
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			if (client == i || GetClientTeam(i) == clientTeam || !IsPlayerAlive(i))
			{
				continue;
			}
			
			GetClientAbsOrigin(i, fTargetOrigin);
			fTargetDistance = GetVectorDistance(fClientOrigin, fTargetOrigin);

			if (fTargetDistance > fClosestDistance && fClosestDistance > -1.0)
			{
				continue;
			}

			if (!ClientCanSeeTarget(client, i))
			{
				continue;
			}

			if (GetEngineVersion() == Engine_CSGO)
			{
				if (GetEntPropFloat(i, Prop_Send, "m_fImmuneToGunGameDamageTime") > 0.0)
				{
					continue;
				}
			}

			if(StrEqual(clantag, "DIG")) //30th
			{
				if (!IsTargetInSightRange(client, i, 50.0))
					continue;	
			}
			else if(StrEqual(clantag, "Heretics")) //29th
			{
				if (!IsTargetInSightRange(client, i, 60.0))
					continue;	
			}
			else if(StrEqual(clantag, "Envy")) //28th
			{
				if (!IsTargetInSightRange(client, i, 70.0))
					continue;	
			}
			else if(StrEqual(clantag, "Heroic")) //27th
			{
				if (!IsTargetInSightRange(client, i, 80.0))
					continue;	
			}
			else if(StrEqual(clantag, "coL")) //26th
			{
				if (!IsTargetInSightRange(client, i, 90.0))
					continue;	
			}
			else if(StrEqual(clantag, "North")) //25th
			{
				if (!IsTargetInSightRange(client, i, 100.0))
					continue;	
			}
			else if(StrEqual(clantag, "HAVU")) //24th
			{
				if (!IsTargetInSightRange(client, i, 110.0))
					continue;	
			}
			else if(StrEqual(clantag, "Gen.G")) //23rd
			{
				if (!IsTargetInSightRange(client, i, 120.0))
					continue;	
			}
			else if(StrEqual(clantag, "VP")) //22nd
			{
				if (!IsTargetInSightRange(client, i, 130.0))
					continue;	
			}
			else if(StrEqual(clantag, "ENCE")) //21st
			{
				if (!IsTargetInSightRange(client, i, 140.0))
					continue;	
			}
			else if(StrEqual(clantag, "C9")) //20th
			{
				if (!IsTargetInSightRange(client, i, 150.0))
					continue;	
			}
			else if(StrEqual(clantag, "Spirit")) //19th
			{
				if (!IsTargetInSightRange(client, i, 160.0))
					continue;	
			}
			else if(StrEqual(clantag, "forZe")) //18th
			{
				if (!IsTargetInSightRange(client, i, 170.0))
					continue;	
			}
			else if(StrEqual(clantag, "GODSENT")) //17th
			{
				if (!IsTargetInSightRange(client, i, 180.0))
					continue;	
			}
			else if(StrEqual(clantag, "BIG")) //16th
			{
				if (!IsTargetInSightRange(client, i, 190.0))
					continue;	
			}
			else if(StrEqual(clantag, "OG")) //15th
			{
				if (!IsTargetInSightRange(client, i, 200.0))
					continue;	
			}
			else if(StrEqual(clantag, "MIBR")) //14th
			{
				if (!IsTargetInSightRange(client, i, 210.0))
					continue;	
			}
			else if(StrEqual(clantag, "NiP")) //13th
			{
				if (!IsTargetInSightRange(client, i, 220.0))
					continue;	
			}
			else if(StrEqual(clantag, "Lions")) //12th
			{
				if (!IsTargetInSightRange(client, i, 230.0))
					continue;	
			}
			else if(StrEqual(clantag, "FURIA")) //11th
			{
				if (!IsTargetInSightRange(client, i, 240.0))
					continue;	
			}
			else if(StrEqual(clantag, "Thieves")) //10th
			{
				if (!IsTargetInSightRange(client, i, 250.0))
					continue;	
			}
			else if(StrEqual(clantag, "Vitality")) //9th
			{
				if (!IsTargetInSightRange(client, i, 260.0))
					continue;	
			}
			else if(StrEqual(clantag, "EG")) //8th
			{
				if (!IsTargetInSightRange(client, i, 270.0))
					continue;	
			}
			else if(StrEqual(clantag, "FaZe")) //7th
			{
				if (!IsTargetInSightRange(client, i, 280.0))
					continue;	
			}
			else if(StrEqual(clantag, "G2")) //6th
			{
				if (!IsTargetInSightRange(client, i, 290.0))
					continue;	
			}
			else if(StrEqual(clantag, "Liquid")) //5th
			{
				if (!IsTargetInSightRange(client, i, 300.0))
					continue;	
			}
			else if(StrEqual(clantag, "mouz")) //4th
			{
				if (!IsTargetInSightRange(client, i, 310.0))
					continue;	
			}
			else if(StrEqual(clantag, "Na´Vi")) //3rd
			{
				if (!IsTargetInSightRange(client, i, 320.0))
					continue;	
			}
			else if(StrEqual(clantag, "fnatic")) //2nd
			{
				if (!IsTargetInSightRange(client, i, 330.0))
					continue;	
			}
			else if(StrEqual(clantag, "Astralis")) //1st
			{
				if (!IsTargetInSightRange(client, i, 340.0))
					continue;	
			}
			else if(index == 9)
			{
				if (!IsTargetInSightRange(client, i, 180.0))
					continue;	
			}
			else
			{
				if (!IsTargetInSightRange(client, i))
					continue;
			}
			
			if (g_bFlashed[client])
			{
				continue;
			}
			
			if(LineGoesThroughSmoke(fClientOrigin, fTargetOrigin))
			{
				continue;
			}
			
			int iPrimary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
			int iSecondary = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
			int iClipAmmo;
			
			if(iPrimary != -1)
			{
				iClipAmmo = GetEntProp(iPrimary, Prop_Send, "m_iClip1");
			}
			
			if(IsWeaponSlotActive(client, CS_SLOT_GRENADE) && !g_bPinPulled[client])
			{
				if(iClipAmmo > 0 && iPrimary != -1)
				{
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", iPrimary); 
				}
				else if(iPrimary == -1 && iSecondary != -1)
				{
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", iSecondary); 
				}
			}
			
			fClosestDistance = fTargetDistance;
			iClosestTarget = i;
		}
	}
	
	return iClosestTarget;
}

stock bool ClientCanSeeTarget(int client, int iTarget, float fDistance = 0.0, float fHeight = 50.0)
{
	float fClientPosition[3]; float fTargetPosition[3];
	
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", fClientPosition);
	fClientPosition[2] += fHeight;
	
	GetClientEyePosition(iTarget, fTargetPosition);
	
	if (fDistance == 0.0 || GetVectorDistance(fClientPosition, fTargetPosition, false) < fDistance)
	{
		Handle hTrace = TR_TraceRayFilterEx(fClientPosition, fTargetPosition, MASK_SOLID_BRUSHONLY, RayType_EndPoint, Base_TraceFilter);
		
		if (TR_DidHit(hTrace))
		{
			delete hTrace;
			return false;
		}
		
		delete hTrace;
		return true;
	}
	
	return false;
}

public bool Base_TraceFilter(int iEntity, int iContentsMask, int iData)
{
	return iEntity == iData;
}

bool IsValidClient(int client) 
{
	if(!(1 <= client <= MaxClients ) || !IsClientInGame(client)) 
		return false; 
	return true; 
}

stock bool IsTargetInSightRange(int client, int target, float angle = 40.0, float distance = 0.0, bool heightcheck = true, bool negativeangle = false)
{
	if (angle > 360.0)
		angle = 360.0;
	
	if (angle < 0.0)
		return false;
	
	float clientpos[3];
	float targetpos[3];
	float anglevector[3];
	float targetvector[3];
	float resultangle;
	float resultdistance;
	
	GetClientEyeAngles(client, anglevector);
	anglevector[0] = anglevector[2] = 0.0;
	GetAngleVectors(anglevector, anglevector, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(anglevector, anglevector);
	if (negativeangle)
		NegateVector(anglevector);
	
	GetClientAbsOrigin(client, clientpos);
	GetClientAbsOrigin(target, targetpos);
	
	if (heightcheck && distance > 0)
		resultdistance = GetVectorDistance(clientpos, targetpos);
	
	clientpos[2] = targetpos[2] = 0.0;
	MakeVectorFromPoints(clientpos, targetpos, targetvector);
	NormalizeVector(targetvector, targetvector);
	
	resultangle = RadToDeg(ArcCosine(GetVectorDotProduct(targetvector, anglevector)));
	
	if (resultangle <= angle / 2)
	{
		if (distance > 0)
		{
			if (!heightcheck)
				resultdistance = GetVectorDistance(clientpos, targetpos);
			
			if (distance >= resultdistance)
				return true;
			else return false;
		}
		else return true;
	}
	
	return false;
}

stock bool LineGoesThroughSmoke(float from[3], float to[3])
{
	static Address TheBots;
	static Handle CBotManager_IsLineBlockedBySmoke;
	static int OS;

	if(OS == 0)
	{
		Handle hGameConf = LoadGameConfigFile("LineGoesThroughSmoke.games");
		if(!hGameConf)
		{
			SetFailState("Could not read LineGoesThroughSmoke.games.txt");
			return false;
		}
		
		OS = GameConfGetOffset(hGameConf, "OS");
		
		TheBots = GameConfGetAddress(hGameConf, "TheBots");
		if(!TheBots)
		{
			CloseHandle(hGameConf);
			SetFailState("TheBots == null");
			return false;
		}
		
		StartPrepSDKCall(SDKCall_Raw);
		PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "CBotManager::IsLineBlockedBySmoke");
		PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
		PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
		if(OS == 1) PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
		PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
		if(!(CBotManager_IsLineBlockedBySmoke = EndPrepSDKCall()))
		{
			CloseHandle(hGameConf);
			SetFailState("Failed to get CBotManager::IsLineBlockedBySmoke function");
			return false;
		}
		
		CloseHandle(hGameConf);
	}

	if(OS == 1) return SDKCall(CBotManager_IsLineBlockedBySmoke, TheBots, from, to, 1.0);
	return SDKCall(CBotManager_IsLineBlockedBySmoke, TheBots, from, to);
}

public void Pro_Players(char[] botname, int client)
{

	//MIBR Players
	if((StrEqual(botname, "kNgV-")) || (StrEqual(botname, "FalleN")) || (StrEqual(botname, "fer")) || (StrEqual(botname, "TACO")) || (StrEqual(botname, "meyern")))
	{
		CS_SetClientClanTag(client, "MIBR");
	}
	
	//FaZe Players
	if((StrEqual(botname, "olofmeister")) || (StrEqual(botname, "broky")) || (StrEqual(botname, "NiKo")) || (StrEqual(botname, "rain")) || (StrEqual(botname, "coldzera")))
	{
		CS_SetClientClanTag(client, "FaZe");
	}
	
	//Astralis Players
	if((StrEqual(botname, "Xyp9x")) || (StrEqual(botname, "device")) || (StrEqual(botname, "gla1ve")) || (StrEqual(botname, "Magisk")) || (StrEqual(botname, "dupreeh")))
	{
		CS_SetClientClanTag(client, "Astralis");
	}
	
	//NiP Players
	if((StrEqual(botname, "twist")) || (StrEqual(botname, "Plopski")) || (StrEqual(botname, "nawwk")) || (StrEqual(botname, "Lekr0")) || (StrEqual(botname, "REZ")))
	{
		CS_SetClientClanTag(client, "NiP");
	}
	
	//C9 Players
	if((StrEqual(botname, "JT")) || (StrEqual(botname, "Sonic")) || (StrEqual(botname, "motm")) || (StrEqual(botname, "oSee")) || (StrEqual(botname, "floppy")))
	{
		CS_SetClientClanTag(client, "C9");
	}
	
	//G2 Players
	if((StrEqual(botname, "huNter-")) || (StrEqual(botname, "kennyS")) || (StrEqual(botname, "nexa")) || (StrEqual(botname, "JaCkz")) || (StrEqual(botname, "AMANEK")))
	{
		CS_SetClientClanTag(client, "G2");
	}
	
	//fnatic Players
	if((StrEqual(botname, "flusha")) || (StrEqual(botname, "JW")) || (StrEqual(botname, "KRiMZ")) || (StrEqual(botname, "Brollan")) || (StrEqual(botname, "Golden")))
	{
		CS_SetClientClanTag(client, "fnatic");
	}
	
	//North Players
	if((StrEqual(botname, "MSL")) || (StrEqual(botname, "Kjaerbye")) || (StrEqual(botname, "aizy")) || (StrEqual(botname, "cajunb")) || (StrEqual(botname, "gade")))
	{
		CS_SetClientClanTag(client, "North");
	}
	
	//mouz Players
	if((StrEqual(botname, "karrigan")) || (StrEqual(botname, "chrisJ")) || (StrEqual(botname, "woxic")) || (StrEqual(botname, "frozen")) || (StrEqual(botname, "ropz")))
	{
		CS_SetClientClanTag(client, "mouz");
	}
	
	//TYLOO Players
	if((StrEqual(botname, "Summer")) || (StrEqual(botname, "Attacker")) || (StrEqual(botname, "xeta")) || (StrEqual(botname, "somebody")) || (StrEqual(botname, "Freeman")))
	{
		CS_SetClientClanTag(client, "TYLOO");
	}
	
	//EG Players
	if((StrEqual(botname, "stanislaw")) || (StrEqual(botname, "tarik")) || (StrEqual(botname, "Brehze")) || (StrEqual(botname, "Ethan")) || (StrEqual(botname, "CeRq")))
	{
		CS_SetClientClanTag(client, "EG");
	}
	
	//Thieves Players
	if((StrEqual(botname, "AZR")) || (StrEqual(botname, "jks")) || (StrEqual(botname, "jkaem")) || (StrEqual(botname, "Gratisfaction")) || (StrEqual(botname, "Liazz")))
	{
		CS_SetClientClanTag(client, "Thieves");
	}
	
	//Na´Vi Players
	if((StrEqual(botname, "electronic")) || (StrEqual(botname, "s1mple")) || (StrEqual(botname, "flamie")) || (StrEqual(botname, "Boombl4")) || (StrEqual(botname, "Perfecto")))
	{
		CS_SetClientClanTag(client, "Na´Vi");
	}
	
	//Liquid Players
	if((StrEqual(botname, "Stewie2K")) || (StrEqual(botname, "NAF")) || (StrEqual(botname, "nitr0")) || (StrEqual(botname, "ELiGE")) || (StrEqual(botname, "Twistzz")))
	{
		CS_SetClientClanTag(client, "Liquid");
	}
	
	//AGO Players
	if((StrEqual(botname, "Furlan")) || (StrEqual(botname, "GruBy")) || (StrEqual(botname, "mhL")) || (StrEqual(botname, "F1KU")) || (StrEqual(botname, "oskarish")))
	{
		CS_SetClientClanTag(client, "AGO");
	}
	
	//ENCE Players
	if((StrEqual(botname, "suNny")) || (StrEqual(botname, "Aerial")) || (StrEqual(botname, "allu")) || (StrEqual(botname, "sergej")) || (StrEqual(botname, "xseveN")))
	{
		CS_SetClientClanTag(client, "ENCE");
	}
	
	//Vitality Players
	if((StrEqual(botname, "shox")) || (StrEqual(botname, "ZywOo")) || (StrEqual(botname, "apEX")) || (StrEqual(botname, "RpK")) || (StrEqual(botname, "Misutaaa")))
	{
		CS_SetClientClanTag(client, "Vitality");
	}
	
	//BIG Players
	if((StrEqual(botname, "tiziaN")) || (StrEqual(botname, "syrsoN")) || (StrEqual(botname, "XANTARES")) || (StrEqual(botname, "tabseN")) || (StrEqual(botname, "k1to")))
	{
		CS_SetClientClanTag(client, "BIG");
	}
	
	//FURIA Players
	if((StrEqual(botname, "yuurih")) || (StrEqual(botname, "arT")) || (StrEqual(botname, "VINI")) || (StrEqual(botname, "kscerato")) || (StrEqual(botname, "HEN1")))
	{
		CS_SetClientClanTag(client, "FURIA");
	}
	
	//c0ntact Players
	if((StrEqual(botname, "LETN1")) || (StrEqual(botname, "ottoNd")) || (StrEqual(botname, "SHiPZ")) || (StrEqual(botname, "emi")) || (StrEqual(botname, "EspiranTo")))
	{
		CS_SetClientClanTag(client, "c0ntact");
	}
	
	//coL Players
	if((StrEqual(botname, "k0nfig")) || (StrEqual(botname, "poizon")) || (StrEqual(botname, "oBo")) || (StrEqual(botname, "RUSH")) || (StrEqual(botname, "blameF")))
	{
		CS_SetClientClanTag(client, "coL");
	}
	
	//ViCi Players
	if((StrEqual(botname, "zhokiNg")) || (StrEqual(botname, "kaze")) || (StrEqual(botname, "aumaN")) || (StrEqual(botname, "JamYoung")) || (StrEqual(botname, "advent")))
	{
		CS_SetClientClanTag(client, "ViCi");
	}
	
	//forZe Players
	if((StrEqual(botname, "facecrack")) || (StrEqual(botname, "xsepower")) || (StrEqual(botname, "FL1T")) || (StrEqual(botname, "almazer")) || (StrEqual(botname, "Jerry")))
	{
		CS_SetClientClanTag(client, "forZe");
	}
	
	//Winstrike Players
	if((StrEqual(botname, "Lack1")) || (StrEqual(botname, "KrizzeN")) || (StrEqual(botname, "Hobbit")) || (StrEqual(botname, "El1an")) || (StrEqual(botname, "bondik")))
	{
		CS_SetClientClanTag(client, "Winstrike");
	}
	
	//Sprout Players
	if((StrEqual(botname, "snatchie")) || (StrEqual(botname, "dycha")) || (StrEqual(botname, "Spiidi")) || (StrEqual(botname, "faveN")) || (StrEqual(botname, "denis")))
	{
		CS_SetClientClanTag(client, "Sprout");
	}
	
	//Heroic Players
	if((StrEqual(botname, "TeSeS")) || (StrEqual(botname, "b0RUP")) || (StrEqual(botname, "nikozan")) || (StrEqual(botname, "cadiaN")) || (StrEqual(botname, "stavn")))
	{
		CS_SetClientClanTag(client, "Heroic");
	}
	
	//INTZ Players
	if((StrEqual(botname, "maxcel")) || (StrEqual(botname, "gut0")) || (StrEqual(botname, "danoco")) || (StrEqual(botname, "detr0it")) || (StrEqual(botname, "kLv")))
	{
		CS_SetClientClanTag(client, "INTZ");
	}
	
	//VP Players
	if((StrEqual(botname, "buster")) || (StrEqual(botname, "Jame")) || (StrEqual(botname, "qikert")) || (StrEqual(botname, "SANJI")) || (StrEqual(botname, "AdreN")))
	{
		CS_SetClientClanTag(client, "VP");
	}
	
	//Apeks Players
	if((StrEqual(botname, "Marcelious")) || (StrEqual(botname, "truth")) || (StrEqual(botname, "Grusarn")) || (StrEqual(botname, "akEz")) || (StrEqual(botname, "Polly")))
	{
		CS_SetClientClanTag(client, "Apeks");
	}
	
	//aTTaX Players
	if((StrEqual(botname, "stfN")) || (StrEqual(botname, "slaxz")) || (StrEqual(botname, "ScrunK")) || (StrEqual(botname, "kressy")) || (StrEqual(botname, "mirbit")))
	{
		CS_SetClientClanTag(client, "aTTaX");
	}
	
	//RNG Players
	if((StrEqual(botname, "INS")) || (StrEqual(botname, "sico")) || (StrEqual(botname, "dexter")) || (StrEqual(botname, "Hatz")) || (StrEqual(botname, "malta")))
	{
		CS_SetClientClanTag(client, "RNG");
	}
	
	//Envy Players
	if((StrEqual(botname, "Nifty")) || (StrEqual(botname, "ryann")) || (StrEqual(botname, "Calyx")) || (StrEqual(botname, "MICHU")) || (StrEqual(botname, "moose")))
	{
		CS_SetClientClanTag(client, "Envy");
	}
	
	//Spirit Players
	if((StrEqual(botname, "mir")) || (StrEqual(botname, "iDISBALANCE")) || (StrEqual(botname, "somedieyoung")) || (StrEqual(botname, "chopper")) || (StrEqual(botname, "magixx")))
	{
		CS_SetClientClanTag(client, "Spirit");
	}
	
	//CeX Players
	if((StrEqual(botname, "MT")) || (StrEqual(botname, "Impact")) || (StrEqual(botname, "Nukeddog")) || (StrEqual(botname, "CYPHER")) || (StrEqual(botname, "Murky")))
	{
		CS_SetClientClanTag(client, "CeX");
	}
	
	//LDLC Players
	if((StrEqual(botname, "LOGAN")) || (StrEqual(botname, "Lambert")) || (StrEqual(botname, "hAdji")) || (StrEqual(botname, "Gringo")) || (StrEqual(botname, "SIXER")))
	{
		CS_SetClientClanTag(client, "LDLC");
	}
	
	//GamerLegion Players
	if((StrEqual(botname, "dennis")) || (StrEqual(botname, "draken")) || (StrEqual(botname, "freddieb")) || (StrEqual(botname, "RuStY")) || (StrEqual(botname, "hampus")))
	{
		CS_SetClientClanTag(client, "GamerLegion");
	}
	
	//DIVIZON Players
	if((StrEqual(botname, "devus")) || (StrEqual(botname, "akay")) || (StrEqual(botname, "hyped")) || (StrEqual(botname, "merisinho")) || (StrEqual(botname, "ykyli")))
	{
		CS_SetClientClanTag(client, "DIVIZON");
	}
	
	//EURONICS Players
	if((StrEqual(botname, "red")) || (StrEqual(botname, "maRky")) || (StrEqual(botname, "PerX")) || (StrEqual(botname, "Seeeya")) || (StrEqual(botname, "pdy")))
	{
		CS_SetClientClanTag(client, "EURONICS");
	}
	
	//nerdRage Players
	if((StrEqual(botname, "Frazehh")) || (StrEqual(botname, "Br0die")) || (StrEqual(botname, "Ping")) || (StrEqual(botname, "Tadpole")) || (StrEqual(botname, "LNZ")))
	{
		CS_SetClientClanTag(client, "nerdRage");
	}
	
	//PDucks Players
	if((StrEqual(botname, "stefank0k0")) || (StrEqual(botname, "ACTiV")) || (StrEqual(botname, "Cargo")) || (StrEqual(botname, "Krabbe")) || (StrEqual(botname, "Simply")))
	{
		CS_SetClientClanTag(client, "PDucks");
	}
	
	//HAVU Players
	if((StrEqual(botname, "ZOREE")) || (StrEqual(botname, "sLowi")) || (StrEqual(botname, "doto")) || (StrEqual(botname, "Hoody")) || (StrEqual(botname, "sAw")))
	{
		CS_SetClientClanTag(client, "HAVU");
	}
	
	//Lyngby Players
	if((StrEqual(botname, "birdfromsky")) || (StrEqual(botname, "Twinx")) || (StrEqual(botname, "maNkz")) || (StrEqual(botname, "Raalz")) || (StrEqual(botname, "Cabbi")))
	{
		CS_SetClientClanTag(client, "Lyngby");
	}
	
	//GODSENT Players
	if((StrEqual(botname, "maden")) || (StrEqual(botname, "Maikelele")) || (StrEqual(botname, "kRYSTAL")) || (StrEqual(botname, "zehN")) || (StrEqual(botname, "STYKO")))
	{
		CS_SetClientClanTag(client, "GODSENT");
	}
	
	//Nordavind Players
	if((StrEqual(botname, "tenzki")) || (StrEqual(botname, "NaToSaphiX")) || (StrEqual(botname, "RUBINO")) || (StrEqual(botname, "HS")) || (StrEqual(botname, "cromen")))
	{
		CS_SetClientClanTag(client, "Nordavind");
	}
	
	//SJ Players
	if((StrEqual(botname, "arvid")) || (StrEqual(botname, "STOVVE")) || (StrEqual(botname, "SADDYX")) || (StrEqual(botname, "KHRN")) || (StrEqual(botname, "xartE")))
	{
		CS_SetClientClanTag(client, "SJ");
	}
	
	//Bren Players
	if((StrEqual(botname, "Papichulo")) || (StrEqual(botname, "witz")) || (StrEqual(botname, "Pro.")) || (StrEqual(botname, "JA")) || (StrEqual(botname, "Derek")))
	{
		CS_SetClientClanTag(client, "Bren");
	}
	
	//Giants Players
	if((StrEqual(botname, "NOPEEj")) || (StrEqual(botname, "fox")) || (StrEqual(botname, "pr")) || (StrEqual(botname, "BLOODZ")) || (StrEqual(botname, "renatoohaxx")))
	{
		CS_SetClientClanTag(client, "Giants");
	}
	
	//Lions Players
	if((StrEqual(botname, "AcilioN")) || (StrEqual(botname, "acoR")) || (StrEqual(botname, "Sjuush")) || (StrEqual(botname, "Bubzkji")) || (StrEqual(botname, "roeJ")))
	{
		CS_SetClientClanTag(client, "Lions");
	}
	
	//Riders Players
	if((StrEqual(botname, "mopoz")) || (StrEqual(botname, "EasTor")) || (StrEqual(botname, "steel")) || (StrEqual(botname, "alex*")) || (StrEqual(botname, "loWel")))
	{
		CS_SetClientClanTag(client, "Riders");
	}
	
	//OFFSET Players
	if((StrEqual(botname, "sc4rx")) || (StrEqual(botname, "obj")) || (StrEqual(botname, "zlynx")) || (StrEqual(botname, "ZELIN")) || (StrEqual(botname, "drifking")))
	{
		CS_SetClientClanTag(client, "OFFSET");
	}
	
	//x6tence Players
	if((StrEqual(botname, "NikoM")) || (StrEqual(botname, "JonY BoY")) || (StrEqual(botname, "tomi")) || (StrEqual(botname, "OMG")) || (StrEqual(botname, "tutehen")))
	{
		CS_SetClientClanTag(client, "x6tence");
	}
	
	//eSuba Players
	if((StrEqual(botname, "NIO")) || (StrEqual(botname, "Levi")) || (StrEqual(botname, "luko")) || (StrEqual(botname, "Blogg1s")) || (StrEqual(botname, "The eLiVe")))
	{
		CS_SetClientClanTag(client, "eSuba");
	}
	
	//Nexus Players
	if((StrEqual(botname, "BTN")) || (StrEqual(botname, "XELLOW")) || (StrEqual(botname, "mhN1")) || (StrEqual(botname, "iM")) || (StrEqual(botname, "sXe")))
	{
		CS_SetClientClanTag(client, "Nexus");
	}
	
	//PACT Players
	if((StrEqual(botname, "darko")) || (StrEqual(botname, "lunAtic")) || (StrEqual(botname, "Goofy")) || (StrEqual(botname, "MINISE")) || (StrEqual(botname, "Sobol")))
	{
		CS_SetClientClanTag(client, "PACT");
	}
	
	//Heretics Players
	if((StrEqual(botname, "Nivera")) || (StrEqual(botname, "Maka")) || (StrEqual(botname, "xms")) || (StrEqual(botname, "kioShiMa")) || (StrEqual(botname, "Lucky")))
	{
		CS_SetClientClanTag(client, "Heretics");
	}
	
	//Nemiga Players
	if((StrEqual(botname, "speed4k")) || (StrEqual(botname, "mds")) || (StrEqual(botname, "lollipop21k")) || (StrEqual(botname, "Jyo")) || (StrEqual(botname, "boX")))
	{
		CS_SetClientClanTag(client, "Nemiga");
	}
	
	//pro100 Players
	if((StrEqual(botname, "dimasick")) || (StrEqual(botname, "WorldEdit")) || (StrEqual(botname, "YEKINDAR")) || (StrEqual(botname, "wayLander")) || (StrEqual(botname, "NickelBack")))
	{
		CS_SetClientClanTag(client, "pro100");
	}
	
	//YaLLa Players
	if((StrEqual(botname, "Remind")) || (StrEqual(botname, "DEAD")) || (StrEqual(botname, "Kheops")) || (StrEqual(botname, "Senpai")) || (StrEqual(botname, "fredi")))
	{
		CS_SetClientClanTag(client, "YaLLa");
	}
	
	//Yeah Players
	if((StrEqual(botname, "tatazin")) || (StrEqual(botname, "RCF")) || (StrEqual(botname, "f4stzin")) || (StrEqual(botname, "iDk")) || (StrEqual(botname, "dumau")))
	{
		CS_SetClientClanTag(client, "Yeah");
	}
	
	//Singularity Players
	if((StrEqual(botname, "Jabbi")) || (StrEqual(botname, "mertz")) || (StrEqual(botname, "Fessor")) || (StrEqual(botname, "TOBIZ")) || (StrEqual(botname, "Celrate")))
	{
		CS_SetClientClanTag(client, "Singularity");
	}
	
	//DETONA Players
	if((StrEqual(botname, "rikz")) || (StrEqual(botname, "tiburci0")) || (StrEqual(botname, "v$m")) || (StrEqual(botname, "Lucaozy")) || (StrEqual(botname, "Tuurtle")))
	{
		CS_SetClientClanTag(client, "DETONA");
	}
	
	//Infinity Players
	if((StrEqual(botname, "k1Nky")) || (StrEqual(botname, "tor1towOw")) || (StrEqual(botname, "spamzzy")) || (StrEqual(botname, "sam_A")) || (StrEqual(botname, "Daveys")))
	{
		CS_SetClientClanTag(client, "Infinity");
	}
	
	//Isurus Players
	if((StrEqual(botname, "1962")) || (StrEqual(botname, "Noktse")) || (StrEqual(botname, "Reversive")) || (StrEqual(botname, "decov9jse")) || (StrEqual(botname, "maxujas")))
	{
		CS_SetClientClanTag(client, "Isurus");
	}
	
	//paiN Players
	if((StrEqual(botname, "PKL")) || (StrEqual(botname, "land1n")) || (StrEqual(botname, "NEKIZ")) || (StrEqual(botname, "biguzera")) || (StrEqual(botname, "hardzao")))
	{
		CS_SetClientClanTag(client, "paiN");
	}
	
	//Sharks Players
	if((StrEqual(botname, "heat")) || (StrEqual(botname, "jnt")) || (StrEqual(botname, "leo_drunky")) || (StrEqual(botname, "exit")) || (StrEqual(botname, "Luken")))
	{
		CS_SetClientClanTag(client, "Sharks");
	}
	
	//One Players
	if((StrEqual(botname, "prt")) || (StrEqual(botname, "Maluk3")) || (StrEqual(botname, "trk")) || (StrEqual(botname, "pesadelo")) || (StrEqual(botname, "b4rtiN")))
	{
		CS_SetClientClanTag(client, "One");
	}
	
	//W7M Players
	if((StrEqual(botname, "skullz")) || (StrEqual(botname, "raafa")) || (StrEqual(botname, "ableJ")) || (StrEqual(botname, "pancc")) || (StrEqual(botname, "realziN")))
	{
		CS_SetClientClanTag(client, "W7M");
	}
	
	//Avant Players
	if((StrEqual(botname, "BL1TZ")) || (StrEqual(botname, "sterling")) || (StrEqual(botname, "apoc")) || (StrEqual(botname, "ofnu")) || (StrEqual(botname, "HaZR")))
	{
		CS_SetClientClanTag(client, "Avant");
	}
	
	//Chiefs Players
	if((StrEqual(botname, "stat")) || (StrEqual(botname, "Jinxx")) || (StrEqual(botname, "apocdud")) || (StrEqual(botname, "SkulL")) || (StrEqual(botname, "Mayker")))
	{
		CS_SetClientClanTag(client, "Chiefs");
	}
	
	//ORDER Players
	if((StrEqual(botname, "J1rah")) || (StrEqual(botname, "aliStair")) || (StrEqual(botname, "Rickeh")) || (StrEqual(botname, "USTILO")) || (StrEqual(botname, "Valiance")))
	{
		CS_SetClientClanTag(client, "ORDER");
	}
	
	//BlackS Players
	if((StrEqual(botname, "hue9ze")) || (StrEqual(botname, "addict")) || (StrEqual(botname, "cookie")) || (StrEqual(botname, "jono")) || (StrEqual(botname, "Wolfah")))
	{
		CS_SetClientClanTag(client, "BlackS");
	}
	
	//SKADE Players
	if((StrEqual(botname, "Rock1nG")) || (StrEqual(botname, "dennyslaw")) || (StrEqual(botname, "rafftu")) || (StrEqual(botname, "Rainwaker")) || (StrEqual(botname, "SPELLAN")))
	{
		CS_SetClientClanTag(client, "SKADE");
	}
	
	//Paradox Players
	if((StrEqual(botname, "ino")) || (StrEqual(botname, "Versa")) || (StrEqual(botname, "ekul")) || (StrEqual(botname, "bedonka")) || (StrEqual(botname, "urbz")))
	{
		CS_SetClientClanTag(client, "Paradox");
	}
	
	//Beyond Players
	if((StrEqual(botname, "MAIROLLS")) || (StrEqual(botname, "Olivia")) || (StrEqual(botname, "Kntz")) || (StrEqual(botname, "stk")) || (StrEqual(botname, "qqGod")))
	{
		CS_SetClientClanTag(client, "Beyond");
	}
	
	//BOOM Players
	if((StrEqual(botname, "chelo")) || (StrEqual(botname, "yeL")) || (StrEqual(botname, "shz")) || (StrEqual(botname, "boltz")) || (StrEqual(botname, "felps")))
	{
		CS_SetClientClanTag(client, "BOOM");
	}
	
	//LucidDream Players
	if((StrEqual(botname, "Jinx")) || (StrEqual(botname, "PTC")) || (StrEqual(botname, "cbbk")) || (StrEqual(botname, "JohnOlsen")) || (StrEqual(botname, "Lakia")))
	{
		CS_SetClientClanTag(client, "LucidDream");
	}
	
	//NASR Players
	if((StrEqual(botname, "proxyyb")) || (StrEqual(botname, "Real1ze")) || (StrEqual(botname, "BOROS")) || (StrEqual(botname, "Dementor")) || (StrEqual(botname, "Just1ce")))
	{
		CS_SetClientClanTag(client, "NASR");
	}
	
	//Revolution Players
	if((StrEqual(botname, "Rambutan")) || (StrEqual(botname, "Fog")) || (StrEqual(botname, "Tee")) || (StrEqual(botname, "Jaybk")) || (StrEqual(botname, "kun")))
	{
		CS_SetClientClanTag(client, "Revolution");
	}
	
	//SHIFT Players
	if((StrEqual(botname, "Young KillerS")) || (StrEqual(botname, "Kishi")) || (StrEqual(botname, "tozz")) || (StrEqual(botname, "huyhart")) || (StrEqual(botname, "Imcarnus")))
	{
		CS_SetClientClanTag(client, "SHIFT");
	}
	
	//nxl Players
	if((StrEqual(botname, "soifong")) || (StrEqual(botname, "RamCikiciew")) || (StrEqual(botname, "Qbo")) || (StrEqual(botname, "Vask0")) || (StrEqual(botname, "smoof")))
	{
		CS_SetClientClanTag(client, "nxl");
	}
	
	//QB Players
	if((StrEqual(botname, "MadLife")) || (StrEqual(botname, "Electro")) || (StrEqual(botname, "nafan9")) || (StrEqual(botname, "Raider")) || (StrEqual(botname, "L4F")))
	{
		CS_SetClientClanTag(client, "QB");
	}
	
	//Energy Players
	if((StrEqual(botname, "pnd")) || (StrEqual(botname, "disTroiT")) || (StrEqual(botname, "Lichl0rd")) || (StrEqual(botname, "Damz")) || (StrEqual(botname, "kreatioN")))
	{
		CS_SetClientClanTag(client, "Energy");
	}
	
	//BLUEJAYS Players
	if((StrEqual(botname, "blocker")) || (StrEqual(botname, "numb")) || (StrEqual(botname, "REDSTAR")) || (StrEqual(botname, "Patrick")) || (StrEqual(botname, "dream3r")))
	{
		CS_SetClientClanTag(client, "BLUEJAYS");
	}
	
	//EXECUTIONERS Players
	if((StrEqual(botname, "ZesBeeW")) || (StrEqual(botname, "FamouZ")) || (StrEqual(botname, "maestro")) || (StrEqual(botname, "Snyder")) || (StrEqual(botname, "Sys")))
	{
		CS_SetClientClanTag(client, "EXECUTIONERS");
	}
	
	//GroundZero Players
	if((StrEqual(botname, "BURNRUOk")) || (StrEqual(botname, "void")) || (StrEqual(botname, "Llamas")) || (StrEqual(botname, "Noobster")) || (StrEqual(botname, "PEARSS")))
	{
		CS_SetClientClanTag(client, "GroundZero");
	}
	
	//AVEZ Players
	if((StrEqual(botname, "MOLSI")) || (StrEqual(botname, "Markoś")) || (StrEqual(botname, "KEi")) || (StrEqual(botname, "Kylar")) || (StrEqual(botname, "nawrot")))
	{
		CS_SetClientClanTag(client, "AVEZ");
	}
	
	//BTRG Players
	if((StrEqual(botname, "HeiB")) || (StrEqual(botname, "start")) || (StrEqual(botname, "xccurate")) || (StrEqual(botname, "ImpressioN")) || (StrEqual(botname, "XigN")))
	{
		CS_SetClientClanTag(client, "BTRG");
	}
	
	//Furious Players
	if((StrEqual(botname, "nbl")) || (StrEqual(botname, "anarchist")) || (StrEqual(botname, "niox")) || (StrEqual(botname, "iKrystal")) || (StrEqual(botname, "pablek")))
	{
		CS_SetClientClanTag(client, "Furious");
	}
	
	//GTZ Players
	if((StrEqual(botname, "k0mpa")) || (StrEqual(botname, "StepA")) || (StrEqual(botname, "slaxx")) || (StrEqual(botname, "Jaepe")) || (StrEqual(botname, "rafaxF")))
	{
		CS_SetClientClanTag(client, "GTZ");
	}
	
	//Flames Players
	if((StrEqual(botname, "Queenix")) || (StrEqual(botname, "farlig")) || (StrEqual(botname, "HooXi")) || (StrEqual(botname, "refrezh")) || (StrEqual(botname, "Nodios")))
	{
		CS_SetClientClanTag(client, "Flames");
	}
	
	//BPro Players
	if((StrEqual(botname, "FlashBack")) || (StrEqual(botname, "viltrex")) || (StrEqual(botname, "POP0V")) || (StrEqual(botname, "Krs7N")) || (StrEqual(botname, "milly")))
	{
		CS_SetClientClanTag(client, "BPro");
	}
	
	//Syman Players
	if((StrEqual(botname, "neaLaN")) || (StrEqual(botname, "mou")) || (StrEqual(botname, "n0rb3r7")) || (StrEqual(botname, "kreaz")) || (StrEqual(botname, "Keoz")))
	{
		CS_SetClientClanTag(client, "Syman");
	}
	
	//Goliath Players
	if((StrEqual(botname, "massacRe")) || (StrEqual(botname, "mango")) || (StrEqual(botname, "deviaNt")) || (StrEqual(botname, "adaro")) || (StrEqual(botname, "ZipZip")))
	{
		CS_SetClientClanTag(client, "Goliath");
	}
	
	//Secret Players
	if((StrEqual(botname, "juanflatroo")) || (StrEqual(botname, "tudsoN")) || (StrEqual(botname, "PERCY")) || (StrEqual(botname, "sinnopsyy")) || (StrEqual(botname, "anarkez")))
	{
		CS_SetClientClanTag(client, "Secret");
	}
	
	//Incept Players
	if((StrEqual(botname, "micalis")) || (StrEqual(botname, "jtr")) || (StrEqual(botname, "zeph")) || (StrEqual(botname, "Rackem")) || (StrEqual(botname, "yourwombat")))
	{
		CS_SetClientClanTag(client, "Incept");
	}
	
	//UOL Players
	if((StrEqual(botname, "crisby")) || (StrEqual(botname, "kZyJL")) || (StrEqual(botname, "Andyy")) || (StrEqual(botname, "JDC")) || (StrEqual(botname, ".P4TriCK")))
	{
		CS_SetClientClanTag(client, "UOL");
	}
	
	//Baecon Players
	if((StrEqual(botname, "brA")) || (StrEqual(botname, "emp")) || (StrEqual(botname, "kst")) || (StrEqual(botname, "fakesS2")) || (StrEqual(botname, "KILLDREAM")))
	{
		CS_SetClientClanTag(client, "Baecon");
	}
	
	//Illuminar Players
	if((StrEqual(botname, "Vegi")) || (StrEqual(botname, "Snax")) || (StrEqual(botname, "mouz")) || (StrEqual(botname, "innocent")) || (StrEqual(botname, "reatz")))
	{
		CS_SetClientClanTag(client, "Illuminar");
	}
	
	//Queso Players
	if((StrEqual(botname, "TheClaran")) || (StrEqual(botname, "rAmbi")) || (StrEqual(botname, "VARES")) || (StrEqual(botname, "mik")) || (StrEqual(botname, "Yaba")))
	{
		CS_SetClientClanTag(client, "Queso");
	}
	
	//IG Players
	if((StrEqual(botname, "0i")) || (StrEqual(botname, "DeStRoYeR")) || (StrEqual(botname, "flying")) || (StrEqual(botname, "Viva")) || (StrEqual(botname, "XiaosaGe")))
	{
		CS_SetClientClanTag(client, "IG");
	}
	
	//HR Players
	if((StrEqual(botname, "kAliNkA")) || (StrEqual(botname, "jR")) || (StrEqual(botname, "Flarich")) || (StrEqual(botname, "ProbLeM")) || (StrEqual(botname, "JIaYm")))
	{
		CS_SetClientClanTag(client, "HR");
	}
	
	//Dice Players
	if((StrEqual(botname, "XpG")) || (StrEqual(botname, "nonick")) || (StrEqual(botname, "Kan4")) || (StrEqual(botname, "Polox")) || (StrEqual(botname, "DEVIL")))
	{
		CS_SetClientClanTag(client, "Dice");
	}
	
	//KPI Players
	if((StrEqual(botname, "xikii")) || (StrEqual(botname, "SunPayus")) || (StrEqual(botname, "meisoN")) || (StrEqual(botname, "YuRk0")) || (StrEqual(botname, "NaOw")))
	{
		CS_SetClientClanTag(client, "KPI");
	}
	
	//PlanetKey Players
	if((StrEqual(botname, "NinoZjE")) || (StrEqual(botname, "s1n")) || (StrEqual(botname, "skyye")) || (StrEqual(botname, "Kirby")) || (StrEqual(botname, "yannick1h")))
	{
		CS_SetClientClanTag(client, "PlanetKey");
	}
	
	//mCon Players
	if((StrEqual(botname, "k1Nzo")) || (StrEqual(botname, "shaGGy")) || (StrEqual(botname, "luosrevo")) || (StrEqual(botname, "ReFuZR")) || (StrEqual(botname, "methoDs")))
	{
		CS_SetClientClanTag(client, "mCon");
	}
	
	//DreamEaters Players
	if((StrEqual(botname, "CHEHOL")) || (StrEqual(botname, "Quantium")) || (StrEqual(botname, "Kas9k")) || (StrEqual(botname, "minse")) || (StrEqual(botname, "JACKPOT")))
	{
		CS_SetClientClanTag(client, "DreamEaters");
	}
	
	//HLE Players
	if((StrEqual(botname, "kinqie")) || (StrEqual(botname, "rAge")) || (StrEqual(botname, "Krad")) || (StrEqual(botname, "Forester")) || (StrEqual(botname, "svyat")))
	{
		CS_SetClientClanTag(client, "HLE");
	}
	
	//Gambit Players
	if((StrEqual(botname, "nafany")) || (StrEqual(botname, "sh1ro")) || (StrEqual(botname, "interz")) || (StrEqual(botname, "Ax1Le")) || (StrEqual(botname, "supra")))
	{
		CS_SetClientClanTag(client, "Gambit");
	}
	
	//Wisla Players
	if((StrEqual(botname, "hades")) || (StrEqual(botname, "SZPERO")) || (StrEqual(botname, "mynio")) || (StrEqual(botname, "fanatyk")) || (StrEqual(botname, "jedqr")))
	{
		CS_SetClientClanTag(client, "Wisla");
	}
	
	//Imperial Players
	if((StrEqual(botname, "KHTEX")) || (StrEqual(botname, "zqk")) || (StrEqual(botname, "dzt")) || (StrEqual(botname, "delboNi")) || (StrEqual(botname, "SHOOWTiME")))
	{
		CS_SetClientClanTag(client, "Imperial");
	}
	
	//Big5 Players
	if((StrEqual(botname, "kustoM_")) || (StrEqual(botname, "Spartan")) || (StrEqual(botname, "SloWye-")) || (StrEqual(botname, "takbok")) || (StrEqual(botname, "Tiaantjie")))
	{
		CS_SetClientClanTag(client, "Big5");
	}
	
	//Unique Players
	if((StrEqual(botname, "R0b3n")) || (StrEqual(botname, "zorte")) || (StrEqual(botname, "PASHANOJ")) || (StrEqual(botname, "kenzor")) || (StrEqual(botname, "fenvicious")))
	{
		CS_SetClientClanTag(client, "Unique");
	}
	
	//Izako Players
	if((StrEqual(botname, "Siuhy")) || (StrEqual(botname, "szejn")) || (StrEqual(botname, "EXUS")) || (StrEqual(botname, "avis")) || (StrEqual(botname, "TOAO")))
	{
		CS_SetClientClanTag(client, "Izako");
	}
	
	//ATK Players
	if((StrEqual(botname, "bLazE")) || (StrEqual(botname, "MisteM")) || (StrEqual(botname, "flexeeee")) || (StrEqual(botname, "Fadey")) || (StrEqual(botname, "TenZ")))
	{
		CS_SetClientClanTag(client, "ATK");
	}
	
	//Chaos Players
	if((StrEqual(botname, "Xeppaa")) || (StrEqual(botname, "vanity")) || (StrEqual(botname, "Voltage")) || (StrEqual(botname, "steel_")) || (StrEqual(botname, "leaf")))
	{
		CS_SetClientClanTag(client, "Chaos");
	}
	
	//OneThree Players
	if((StrEqual(botname, "ChildKing")) || (StrEqual(botname, "lan")) || (StrEqual(botname, "bottle")) || (StrEqual(botname, "DD")) || (StrEqual(botname, "Karsa")))
	{
		CS_SetClientClanTag(client, "OneThree");
	}
	
	//Lynn Players
	if((StrEqual(botname, "XG")) || (StrEqual(botname, "mitsuha")) || (StrEqual(botname, "Aree")) || (StrEqual(botname, "Yvonne")) || (StrEqual(botname, "XinKoiNg")))
	{
		CS_SetClientClanTag(client, "Lynn");
	}
	
	//Triumph Players
	if((StrEqual(botname, "Shakezullah")) || (StrEqual(botname, "Junior")) || (StrEqual(botname, "Spongey")) || (StrEqual(botname, "curry")) || (StrEqual(botname, "Grim")))
	{
		CS_SetClientClanTag(client, "Triumph");
	}
	
	//FATE Players
	if((StrEqual(botname, "doublemagic")) || (StrEqual(botname, "KalubeR")) || (StrEqual(botname, "Duplicate")) || (StrEqual(botname, "Mar")) || (StrEqual(botname, "niki1")))
	{
		CS_SetClientClanTag(client, "FATE");
	}
	
	//Canids Players
	if((StrEqual(botname, "DeStiNy")) || (StrEqual(botname, "nythonzinho")) || (StrEqual(botname, "nak")) || (StrEqual(botname, "latto")) || (StrEqual(botname, "fnx")))
	{
		CS_SetClientClanTag(client, "Canids");
	}
	
	//ESPADA Players
	if((StrEqual(botname, "Patsanchick")) || (StrEqual(botname, "degster")) || (StrEqual(botname, "FinigaN")) || (StrEqual(botname, "S0tF1k")) || (StrEqual(botname, "Dima")))
	{
		CS_SetClientClanTag(client, "ESPADA");
	}
	
	//OG Players
	if((StrEqual(botname, "NBK-")) || (StrEqual(botname, "mantuu")) || (StrEqual(botname, "Aleksib")) || (StrEqual(botname, "valde")) || (StrEqual(botname, "ISSAA")))
	{
		CS_SetClientClanTag(client, "OG");
	}
	
	//Vexed Players
	if((StrEqual(botname, "Frei")) || (StrEqual(botname, "Astroo")) || (StrEqual(botname, "jenko")) || (StrEqual(botname, "Puls3")) || (StrEqual(botname, "stan1ey")))
	{
		CS_SetClientClanTag(client, "Vexed");
	}
	
	//Tricked Players
	if((StrEqual(botname, "kiR")) || (StrEqual(botname, "kwezz")) || (StrEqual(botname, "Luckyv1")) || (StrEqual(botname, "sycrone")) || (StrEqual(botname, "Toft")))
	{
		CS_SetClientClanTag(client, "Tricked");
	}
	
	//Gen.G Players
	if((StrEqual(botname, "autimatic")) || (StrEqual(botname, "koosta")) || (StrEqual(botname, "daps")) || (StrEqual(botname, "s0m")) || (StrEqual(botname, "BnTeT")))
	{
		CS_SetClientClanTag(client, "Gen.G");
	}
	
	//Endpoint Players
	if((StrEqual(botname, "Surreal")) || (StrEqual(botname, "CRUC1AL")) || (StrEqual(botname, "Thomas")) || (StrEqual(botname, "robiin")) || (StrEqual(botname, "MiGHTYMAX")))
	{
		CS_SetClientClanTag(client, "Endpoint");
	}
	
	//sAw Players
	if((StrEqual(botname, "arki")) || (StrEqual(botname, "stadodo")) || (StrEqual(botname, "JUST")) || (StrEqual(botname, "MUTiRiS")) || (StrEqual(botname, "rmn")))
	{
		CS_SetClientClanTag(client, "sAw");
	}
	
	//DIG Players
	if((StrEqual(botname, "GeT_RiGhT")) || (StrEqual(botname, "hallzerk")) || (StrEqual(botname, "f0rest")) || (StrEqual(botname, "friberg")) || (StrEqual(botname, "Xizt")))
	{
		CS_SetClientClanTag(client, "DIG");
	}
	
	//D13 Players
	if((StrEqual(botname, "Tamiraarita")) || (StrEqual(botname, "rate")) || (StrEqual(botname, "sKINEE")) || (StrEqual(botname, "sK0R")) || (StrEqual(botname, "ANNIHILATION")))
	{
		CS_SetClientClanTag(client, "D13");
	}
	
	//ZIGMA Players
	if((StrEqual(botname, "NIFFY")) || (StrEqual(botname, "Reality")) || (StrEqual(botname, "JUSTCAUSE")) || (StrEqual(botname, "PPOverdose")) || (StrEqual(botname, "RoLEX")))
	{
		CS_SetClientClanTag(client, "ZIGMA");
	}
	
	//Ambush Players
	if((StrEqual(botname, "Inzta")) || (StrEqual(botname, "Ryxxo")) || (StrEqual(botname, "zeq")) || (StrEqual(botname, "Typos")) || (StrEqual(botname, "IceBerg")))
	{
		CS_SetClientClanTag(client, "Ambush");
	}
	
	//KOVA Players
	if((StrEqual(botname, "pietola")) || (StrEqual(botname, "Derkeps")) || (StrEqual(botname, "uli")) || (StrEqual(botname, "peku")) || (StrEqual(botname, "Twixie")))
	{
		CS_SetClientClanTag(client, "KOVA");
	}
	
	//CR4ZY Players
	if((StrEqual(botname, "DemQQ")) || (StrEqual(botname, "Sergiz")) || (StrEqual(botname, "7oX1C")) || (StrEqual(botname, "Psycho")) || (StrEqual(botname, "SENSEi")))
	{
		CS_SetClientClanTag(client, "CR4ZY");
	}
	
	//Redemption Players
	if((StrEqual(botname, "drg")) || (StrEqual(botname, "ALLE")) || (StrEqual(botname, "remix")) || (StrEqual(botname, "w1")) || (StrEqual(botname, "dok")))
	{
		CS_SetClientClanTag(client, "Redemption");
	}
	
	//eXploit Players
	if((StrEqual(botname, "pizituh")) || (StrEqual(botname, "BuJ")) || (StrEqual(botname, "sark")) || (StrEqual(botname, "MISK")) || (StrEqual(botname, "Cunha")))
	{
		CS_SetClientClanTag(client, "eXploit");
	}
	
	//SMASH Players
	if((StrEqual(botname, "disco doplan")) || (StrEqual(botname, "bubble")) || (StrEqual(botname, "grux")) || (StrEqual(botname, "FejtZ")) || (StrEqual(botname, "shokz")))
	{
		CS_SetClientClanTag(client, "SMASH");
	}
	
	//AGF Players
	if((StrEqual(botname, "fr0slev")) || (StrEqual(botname, "Kristou")) || (StrEqual(botname, "netrick")) || (StrEqual(botname, "TMB")) || (StrEqual(botname, "Lukki")))
	{
		CS_SetClientClanTag(client, "AGF");
	}
	
	//Pompa Players
	if((StrEqual(botname, "Miki Z Afryki")) || (StrEqual(botname, "splawik")) || (StrEqual(botname, "Czapel")) || (StrEqual(botname, "M4tthi")) || (StrEqual(botname, "grzes1x")))
	{
		CS_SetClientClanTag(client, "Pompa");
	}
}

public void SetCustomPrivateRank(int client)
{
	char sClan[64];
	
	CS_GetClientClanTag(client, sClan, sizeof(sClan));
	
	if (StrEqual(sClan, "NiP"))
	{
		g_iProfileRank[client] = 41;
	}
	
	if (StrEqual(sClan, "MIBR"))
	{
		g_iProfileRank[client] = 42;
	}
	
	if (StrEqual(sClan, "FaZe"))
	{
		g_iProfileRank[client] = 43;
	}
	
	if (StrEqual(sClan, "Astralis"))
	{
		g_iProfileRank[client] = 44;
	}
	
	if (StrEqual(sClan, "C9"))
	{
		g_iProfileRank[client] = 45;
	}
	
	if (StrEqual(sClan, "G2"))
	{
		g_iProfileRank[client] = 46;
	}
	
	if (StrEqual(sClan, "fnatic"))
	{
		g_iProfileRank[client] = 47;
	}
	
	if (StrEqual(sClan, "North"))
	{
		g_iProfileRank[client] = 48;
	}
	
	if (StrEqual(sClan, "mouz"))
	{
		g_iProfileRank[client] = 49;
	}
	
	if (StrEqual(sClan, "TYLOO"))
	{
		g_iProfileRank[client] = 50;
	}
	
	if (StrEqual(sClan, "EG"))
	{
		g_iProfileRank[client] = 51;
	}
	
	if (StrEqual(sClan, "Thieves"))
	{
		g_iProfileRank[client] = 52;
	}
	
	if (StrEqual(sClan, "Na´Vi"))
	{
		g_iProfileRank[client] = 53;
	}
	
	if (StrEqual(sClan, "Liquid"))
	{
		g_iProfileRank[client] = 54;
	}
	
	if (StrEqual(sClan, "AGO"))
	{
		g_iProfileRank[client] = 55;
	}
	
	if (StrEqual(sClan, "ENCE"))
	{
		g_iProfileRank[client] = 56;
	}
	
	if (StrEqual(sClan, "Vitality"))
	{
		g_iProfileRank[client] = 57;
	}
	
	if (StrEqual(sClan, "BIG"))
	{
		g_iProfileRank[client] = 58;
	}
	
	if (StrEqual(sClan, "Triumph"))
	{
		g_iProfileRank[client] = 59;
	}
	
	if (StrEqual(sClan, "FURIA"))
	{
		g_iProfileRank[client] = 61;
	}
	
	if (StrEqual(sClan, "c0ntact"))
	{
		g_iProfileRank[client] = 62;
	}
	
	if (StrEqual(sClan, "coL"))
	{
		g_iProfileRank[client] = 63;
	}
	
	if (StrEqual(sClan, "ViCi"))
	{
		g_iProfileRank[client] = 64;
	}
	
	if (StrEqual(sClan, "forZe"))
	{
		g_iProfileRank[client] = 65;
	}
	
	if (StrEqual(sClan, "Winstrike"))
	{
		g_iProfileRank[client] = 66;
	}
	
	if (StrEqual(sClan, "Sprout"))
	{
		g_iProfileRank[client] = 67;
	}
	
	if (StrEqual(sClan, "Heroic"))
	{
		g_iProfileRank[client] = 68;
	}
	
	if (StrEqual(sClan, "INTZ"))
	{
		g_iProfileRank[client] = 69;
	}
	
	if (StrEqual(sClan, "VP"))
	{
		g_iProfileRank[client] = 70;
	}
	
	if (StrEqual(sClan, "Apeks"))
	{
		g_iProfileRank[client] = 71;
	}
	
	if (StrEqual(sClan, "aTTaX"))
	{
		g_iProfileRank[client] = 72;
	}
	
	if (StrEqual(sClan, "RNG"))
	{
		g_iProfileRank[client] = 73;
	}
	
	if (StrEqual(sClan, "Envy"))
	{
		g_iProfileRank[client] = 75;
	}
	
	if (StrEqual(sClan, "Spirit"))
	{
		g_iProfileRank[client] = 76;
	}
	
	if (StrEqual(sClan, "CeX"))
	{
		g_iProfileRank[client] = 77;
	}
	
	if (StrEqual(sClan, "LDLC"))
	{
		g_iProfileRank[client] = 78;
	}
	
	if (StrEqual(sClan, "GamerLegion"))
	{
		g_iProfileRank[client] = 80;
	}
	
	if (StrEqual(sClan, "DIVIZON"))
	{
		g_iProfileRank[client] = 81;
	}
	
	if (StrEqual(sClan, "EURONICS"))
	{
		g_iProfileRank[client] = 82;
	}
	
	if (StrEqual(sClan, "Tricked"))
	{
		g_iProfileRank[client] = 83;
	}
	
	if (StrEqual(sClan, "nerdRage"))
	{
		g_iProfileRank[client] = 84;
	}
	
	if (StrEqual(sClan, "PDucks"))
	{
		g_iProfileRank[client] = 85;
	}
	
	if (StrEqual(sClan, "HAVU"))
	{
		g_iProfileRank[client] = 86;
	}
	
	if (StrEqual(sClan, "Lyngby"))
	{
		g_iProfileRank[client] = 87;
	}
	
	if (StrEqual(sClan, "GODSENT"))
	{
		g_iProfileRank[client] = 88;
	}
	
	if (StrEqual(sClan, "Nordavind"))
	{
		g_iProfileRank[client] = 89;
	}
	
	if (StrEqual(sClan, "SJ"))
	{
		g_iProfileRank[client] = 90;
	}
	
	if (StrEqual(sClan, "Bren"))
	{
		g_iProfileRank[client] = 91;
	}
	
	if (StrEqual(sClan, "Giants"))
	{
		g_iProfileRank[client] = 93;
	}
	
	if (StrEqual(sClan, "Lions"))
	{
		g_iProfileRank[client] = 94;
	}
	
	if (StrEqual(sClan, "Riders"))
	{
		g_iProfileRank[client] = 95;
	}
	
	if (StrEqual(sClan, "OFFSET"))
	{
		g_iProfileRank[client] = 96;
	}
	
	if (StrEqual(sClan, "x6tence"))
	{
		g_iProfileRank[client] = 97;
	}
	
	if (StrEqual(sClan, "eSuba"))
	{
		g_iProfileRank[client] = 98;
	}
	
	if (StrEqual(sClan, "Nexus"))
	{
		g_iProfileRank[client] = 99;
	}
	
	if (StrEqual(sClan, "PACT"))
	{
		g_iProfileRank[client] = 100;
	}
	
	if (StrEqual(sClan, "Heretics"))
	{
		g_iProfileRank[client] = 101;
	}
	
	if (StrEqual(sClan, "Lynn"))
	{
		g_iProfileRank[client] = 102;
	}
	
	if (StrEqual(sClan, "Nemiga"))
	{
		g_iProfileRank[client] = 103;
	}
	
	if (StrEqual(sClan, "pro100"))
	{
		g_iProfileRank[client] = 104;
	}
	
	if (StrEqual(sClan, "YaLLa"))
	{
		g_iProfileRank[client] = 105;
	}
	
	if (StrEqual(sClan, "Yeah"))
	{
		g_iProfileRank[client] = 106;
	}
	
	if (StrEqual(sClan, "Singularity"))
	{
		g_iProfileRank[client] = 107;
	}
	
	if (StrEqual(sClan, "DETONA"))
	{
		g_iProfileRank[client] = 108;
	}
	
	if (StrEqual(sClan, "Infinity"))
	{
		g_iProfileRank[client] = 109;
	}
	
	if (StrEqual(sClan, "Isurus"))
	{
		g_iProfileRank[client] = 110;
	}
	
	if (StrEqual(sClan, "paiN"))
	{
		g_iProfileRank[client] = 111;
	}
	
	if (StrEqual(sClan, "Sharks"))
	{
		g_iProfileRank[client] = 112;
	}
	
	if (StrEqual(sClan, "One"))
	{
		g_iProfileRank[client] = 113;
	}
	
	if (StrEqual(sClan, "W7M"))
	{
		g_iProfileRank[client] = 114;
	}
	
	if (StrEqual(sClan, "Avant"))
	{
		g_iProfileRank[client] = 115;
	}
	
	if (StrEqual(sClan, "Chiefs"))
	{
		g_iProfileRank[client] = 116;
	}
	
	if (StrEqual(sClan, "DIG"))
	{
		g_iProfileRank[client] = 117;
	}
	
	if (StrEqual(sClan, "ORDER"))
	{
		g_iProfileRank[client] = 118;
	}
	
	if (StrEqual(sClan, "BlackS"))
	{
		g_iProfileRank[client] = 119;
	}
	
	if (StrEqual(sClan, "SKADE"))
	{
		g_iProfileRank[client] = 120;
	}
	
	if (StrEqual(sClan, "Paradox"))
	{
		g_iProfileRank[client] = 121;
	}
	
	if (StrEqual(sClan, "Beyond"))
	{
		g_iProfileRank[client] = 124;
	}
	
	if (StrEqual(sClan, "BOOM"))
	{
		g_iProfileRank[client] = 125;
	}
	
	if (StrEqual(sClan, "sAw"))
	{
		g_iProfileRank[client] = 126;
	}
	
	if (StrEqual(sClan, "CR4ZY"))
	{
		g_iProfileRank[client] = 127;
	}
	
	if (StrEqual(sClan, "OneThree"))
	{
		g_iProfileRank[client] = 128;
	}
	
	if (StrEqual(sClan, "LucidDream"))
	{
		g_iProfileRank[client] = 129;
	}
	
	if (StrEqual(sClan, "NASR"))
	{
		g_iProfileRank[client] = 130;
	}
	
	if (StrEqual(sClan, "Revolution"))
	{
		g_iProfileRank[client] = 132;
	}
	
	if (StrEqual(sClan, "SHIFT"))
	{
		g_iProfileRank[client] = 133;
	}
	
	if (StrEqual(sClan, "nxl"))
	{
		g_iProfileRank[client] = 134;
	}
	
	if (StrEqual(sClan, "QB"))
	{
		g_iProfileRank[client] = 135;
	}
	
	if (StrEqual(sClan, "Energy"))
	{
		g_iProfileRank[client] = 136;
	}
	
	if (StrEqual(sClan, "BLUEJAYS"))
	{
		g_iProfileRank[client] = 137;
	}
	
	if (StrEqual(sClan, "EXECUTIONERS"))
	{
		g_iProfileRank[client] = 138;
	}
	
	if (StrEqual(sClan, "GroundZero"))
	{
		g_iProfileRank[client] = 140;
	}
	
	if (StrEqual(sClan, "AVEZ"))
	{
		g_iProfileRank[client] = 141;
	}
	
	if (StrEqual(sClan, "BTRG"))
	{
		g_iProfileRank[client] = 142;
	}
	
	if (StrEqual(sClan, "Gen.G"))
	{
		g_iProfileRank[client] = 143;
	}
	
	if (StrEqual(sClan, "Furious"))
	{
		g_iProfileRank[client] = 144;
	}
	
	if (StrEqual(sClan, "GTZ"))
	{
		g_iProfileRank[client] = 145;
	}
	
	if (StrEqual(sClan, "Flames"))
	{
		g_iProfileRank[client] = 146;
	}
	
	if (StrEqual(sClan, "BPro"))
	{
		g_iProfileRank[client] = 147;
	}
	
	if (StrEqual(sClan, "Syman"))
	{
		g_iProfileRank[client] = 150;
	}
	
	if (StrEqual(sClan, "Pompa"))
	{
		g_iProfileRank[client] = 151;
	}
	
	if (StrEqual(sClan, "Goliath"))
	{
		g_iProfileRank[client] = 152;
	}
	
	if (StrEqual(sClan, "Secret"))
	{
		g_iProfileRank[client] = 153;
	}
	
	if (StrEqual(sClan, "Incept"))
	{
		g_iProfileRank[client] = 154;
	}
	
	if (StrEqual(sClan, "Endpoint"))
	{
		g_iProfileRank[client] = 155;
	}
	
	if (StrEqual(sClan, "UOL"))
	{
		g_iProfileRank[client] = 156;
	}
	
	if (StrEqual(sClan, "Baecon"))
	{
		g_iProfileRank[client] = 158;
	}
	
	if (StrEqual(sClan, "Redemption"))
	{
		g_iProfileRank[client] = 159;
	}
	
	if (StrEqual(sClan, "Illuminar"))
	{
		g_iProfileRank[client] = 161;
	}
	
	if (StrEqual(sClan, "Queso"))
	{
		g_iProfileRank[client] = 162;
	}
	
	if (StrEqual(sClan, "Vexed"))
	{
		g_iProfileRank[client] = 163;
	}
	
	if (StrEqual(sClan, "AGF"))
	{
		g_iProfileRank[client] = 164;
	}
	
	if (StrEqual(sClan, "eXploit"))
	{
		g_iProfileRank[client] = 165;
	}
	
	if (StrEqual(sClan, "IG"))
	{
		g_iProfileRank[client] = 166;
	}
	
	if (StrEqual(sClan, "HR"))
	{
		g_iProfileRank[client] = 167;
	}
	
	if (StrEqual(sClan, "Dice"))
	{
		g_iProfileRank[client] = 168;
	}
	
	if (StrEqual(sClan, "SMASH"))
	{
		g_iProfileRank[client] = 169;
	}
	
	if (StrEqual(sClan, "KPI"))
	{
		g_iProfileRank[client] = 170;
	}
	
	if (StrEqual(sClan, "PlanetKey"))
	{
		g_iProfileRank[client] = 171;
	}
	
	if (StrEqual(sClan, "mCon"))
	{
		g_iProfileRank[client] = 172;
	}
	
	if (StrEqual(sClan, "DreamEaters"))
	{
		g_iProfileRank[client] = 173;
	}
	
	if (StrEqual(sClan, "HLE"))
	{
		g_iProfileRank[client] = 174;
	}
	
	if (StrEqual(sClan, "Gambit"))
	{
		g_iProfileRank[client] = 175;
	}
	
	if (StrEqual(sClan, "Wisla"))
	{
		g_iProfileRank[client] = 176;
	}
	
	if (StrEqual(sClan, "Imperial"))
	{
		g_iProfileRank[client] = 177;
	}
	
	if (StrEqual(sClan, "Big5"))
	{
		g_iProfileRank[client] = 178;
	}
	
	if (StrEqual(sClan, "Unique"))
	{
		g_iProfileRank[client] = 179;
	}
	
	if (StrEqual(sClan, "D13"))
	{
		g_iProfileRank[client] = 180;
	}
	
	if (StrEqual(sClan, "Izako"))
	{
		g_iProfileRank[client] = 181;
	}
	
	if (StrEqual(sClan, "ATK"))
	{
		g_iProfileRank[client] = 182;
	}
	
	if (StrEqual(sClan, "Chaos"))
	{
		g_iProfileRank[client] = 183;
	}
	
	if (StrEqual(sClan, "FATE"))
	{
		g_iProfileRank[client] = 184;
	}
	
	if (StrEqual(sClan, "Canids"))
	{
		g_iProfileRank[client] = 185;
	}
	
	if (StrEqual(sClan, "ESPADA"))
	{
		g_iProfileRank[client] = 186;
	}
	
	if (StrEqual(sClan, "OG"))
	{
		g_iProfileRank[client] = 187;
	}
	
	if (StrEqual(sClan, "ZIGMA"))
	{
		g_iProfileRank[client] = 188;
	}
	
	if (StrEqual(sClan, "Ambush"))
	{
		g_iProfileRank[client] = 189;
	}
	
	if (StrEqual(sClan, "KOVA"))
	{
		g_iProfileRank[client] = 190;
	}
}