#pragma semicolon 1

#include <sourcemod>
#include <clientprefs>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>

//#pragma newdecls required

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
	//MIBR Players
	"kNgV-",
	"FalleN",
	"fer",
	"TACO",
	"LUCAS1",
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
	"f0rest",
	"Lekr0",
	"REZ",
	//C9 Players
	"autimatic",
	"mixwell",
	"daps",
	"koosta",
	"Subroza",
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
	"JUGi",
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
	//TyLoo Players
	"Summer",
	"Attacker",
	"BnTneT",
	"somebody",
	"Freeman",
	//EG Players
	"stanislaw",
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
	"Boombl4",
	"GuardiaN",
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
	"Sidney",
	"leman",
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
	"ALEX",
	//BIG Players
	"tiziaN",
	"smooya",
	"XANTARES",
	"tabseN",
	"nex",
	//AVANGAR Players
	"buster",
	"Jame",
	"qikert",
	"AdreN",
	"SANJI",
	//Windigo Players
	"mirbit",
	"bubble",
	"hAdji",
	"Calyx",
	"poizon",
	//FURIA Players
	"yuurih",
	"arT",
	"VINI",
	"kscerato",
	"HEN1",
	//CR4ZY Players
	"LETN1",
	"ottoNd",
	"SHiPZ",
	"emi",
	"EspiranTo",
	//coL Players
	"dephh",
	"ShahZaM",
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
	"k1to",
	"syrsoN",
	"Spiidi",
	"faveN",
	"denis",
	//Heroic Players
	"es3tag",
	"b0RUP",
	"Snappi",
	"cadiaN",
	"stavn",
	//INTZ Players
	"chelo",
	"shz",
	"xand",
	"destinyy",
	"yeL",
	//VP Players
	"MICHU",
	"snatchie",
	"phr",
	"Snax",
	"Vegi",
	//Apeks Players
	"Marcelious",
	"truth",
	"Grusarn",
	"akEz",
	"Radifaction",
	//aTTaX Players
	"stfN",
	"slaxz",
	"DuDe",
	"kressy",
	"mantuu",
	//Grayhound Players
	"INS",
	"sico",
	"dexter",
	"DickStacy",
	"malta",
	//MVP.PK Players
	"glow",
	"xeta",
	"Rb",
	"k1Ng",
	"stax",
	//Envy Players
	"Nifty",
	"ryann",
	"s0m",
	"ANDROID",
	"FugLy",
	//Spirit Players
	"mir",
	"iDISBALANCE",
	"somedieyoung",
	"chopper",
	"magixx",
	//CeX Players
	"LiamjS",
	"resu",
	"Nukeddog",
	"JamesBT",
	"Murky",
	//LDLC Players
	"rodeN",
	"Happy",
	"MAJ3R",
	"xms",
	"SIXER",
	//Defusekids Player
	"v1N",
	"G1DO",
	"FASHR",
	"Monu",
	"rilax",
	//GamerLegion Players
	"dennis",
	"nawwk",
	"PlesseN",
	"RuStY",
	"hampus",
	//DIVIZON Players
	"TR1P",
	"glaVed",
	"hyped",
	"n1kista",
	"MajoRR",
	//EURONICS Players
	"red",
	"pdy",
	"PerX",
	"Seeeya",
	"PREET",
	//expert Players
	"Aika",
	"syncD",
	"BMLN",
	"HighKitty",
	"VENIQ",
	//PANTHERS Players
	"rUFY",
	"darkz",
	"denzel",
	"expo",
	"stowny",
	//PDucks Players
	"neviZ",
	"synx",
	"delkore",
	"nky",
	"Cargo",
	//HAVU Players
	"ZOREE",
	"sLowi",
	"doto",
	"Hoody",
	"sAw",
	//Lyngby Players
	"birdfromsky",
	"Twinx",
	"Daffu",
	"thamlike",
	"Cabbi",
	//SMASH Players
	"maden",
	"Maikelele",
	"kRYSTAL",
	"zehN",
	"STYKO",
	//Nordavind Players
	"tenzki",
	"hallzerk",
	"RUBINO",
	"H4RR3",
	"cromen",
	//SJ Players
	"arvid",
	"Jamppi",
	"SADDYX",
	"KHRN",
	"xartE",
	//Tricked Players
	"roeJ",
	"acoR",
	"HUNDEN",
	"Sjuush",
	"Bubzkji",
	//Baskonia Players
	"tatin",
	"PabLo",
	"LittlesataN1",
	"dixon",
	"jJavi",
	//Giants Players
	"rmn",
	"fox",
	"Cunha",
	"MUTiRiS",
	"arki",
	//Lions Players
	"YuRk0",
	"Jibrix",
	"Kairi",
	"HUMANZ",
	"NaOw",
	//Riders Players
	"mopoz",
	"EasTor",
	"steel",
	"alex*",
	"loWel",
	//OFFSET Players
	"RIZZ",
	"obj",
	"JUST",
	"stadodo",
	"pr",
	//x6tence Players
	"NikoM",
	"JonY BoY",
	"tomi",
	"OMG",
	"tutehen",
	//eSuba Players
	"HenkkyG",
	"ZEDKO",
	"leckr",
	"Blogg1s",
	"SHOCK",
	//Nexus Players
	"BTN",
	"XELLOW",
	"SEMINTE",
	"iM",
	"starkiller",
	//PACT Players
	"darko",
	"lunAtic",
	"Goofy",
	"Crityourface",
	"Sobol",
	//Heretics Players
	"davidp",
	"Maka",
	"devoduvek",
	"kioShiMa",
	"Lucky",
	//FCDB Players
	"razOk",
	"matusik",
	"Ao-",
	"Cludi",
	"vrs",
	//Nemiga Players
	"ROBO",
	"hutji",
	"lollipop21k",
	"Jyo",
	"boX",
	//pro100 Players
	"dimasick",
	"WorldEdit",
	"YEKINDAR",
	"wayLander",
	"NickelBack",
	//eUnited Players
	"freakazoid",
	"Cooper-",
	"MarKE",
	"food",
	"vanity",
	//Mythic Players
	"C0M",
	"fl0m",
	"Katie",
	"hazed",
	"SileNt",
	//Singularity Players
	"wrath",
	"Relyks",
	"seb",
	"dazzLe",
	"dapr",
	//DETONA Players
	"prt",
	"tiburci0",
	"v$m",
	"Lucaozy",
	"Tuurtle",
	//Infinity Players
	"cruzN",
	"malbsMd",
	"spamzzy",
	"sam_A",
	"Daveys",
	//Isurus Players
	"1962",
	"Noktse",
	"Reversive",
	"nbl",
	"maxujas",
	//paiN Players
	"PKL",
	"land1n",
	"tatazin",
	"biguzera",
	"hardzao",
	//Sharks Players
	"meyern",
	"jnt",
	"leo_drunky",
	"exit",
	"Luken",
	//One Players
	"bld V",
	"Maluk3",
	"trk",
	"bit",
	"b4rtiN",
	//W7M Players
	"skullz",
	"raafa",
	"ryotzz",
	"pancc",
	"realziN",
	//Avant Players
	"soju_j",
	"sterling",
	"apoc",
	"J1rah",
	"HaZR",
	//Chiefs Players
	"tucks",
	"BL1TZ",
	"Texta",
	"ofnu",
	"zewsy",
	//LEISURE Players
	"padow",
	"amigo",
	"fly",
	"cHap",
	"Rand",
	//ORDER Players
	"emagine",
	"aliStair",
	"hatz",
	"USTILO",
	"Valiance",
	//BlackS Players
	"hue9ze",
	"addict",
	"cookie",
	"jeepy",
	"Wolfah",
	//eXtatus Players
	"luko",
	"wEAMO",
	"desty",
	"Fraged",
	"Pechyn",
	//SYF Players
	"ino",
	"Teal",
	"ekul",
	"bedonka",
	"urbz",
	//5Power Players
	"bottle",
	"Savage",
	"xiaosaGe",
	"shuadapai",
	"Viva",
	//EHOME Players
	"insane",
	"originalheart",
	"Marek",
	"SLOWLY",
	"4king",
	//ALPHA Red Players
	"MAIROLLS",
	"Olivia",
	"Kntz",
	"SeveN89",
	"foxz",
	//dream[S]cape Players
	"Bobosaur",
	"splashske",
	"alecks",
	"Benkai",
	"d4v41",
	//Beyond Players
	"TOR",
	"bnwGiggs",
	"RoLEX",
	"veta",
	"Geniuss",
	//Entity Players
	"Amaterasu",
	"Psy",
	"Excali",
	"skillZ",
	"SnrLx",
	//FrostFire Players
	"aimaNNN",
	"hiqa1",
	"acAp",
	"Subbey",
	"Avirity",
	//LucidDream Players
	"wannafly",
	"PTC",
	"cbbk",
	"JohnOlsen",
	"qqGod",
	//NASR Players
	"breAker",
	"Nami",
	"kitkat",
	"havoK",
	"kAzoo",
	//Portal Players
	"traNz",
	"Ttyke",
	"DVDOV",
	"PokemoN",
	"Ebeee",
	//Brutals Players
	"V3nom",
	"RiX",
	"Juventa",
	"astaRR",
	"Fox",
	//iNvictus Players
	"ribbiZ",
	"Manan",
	"Pashasahil",
	"BinaryBUG",
	"blackhawk",
	//nxl Players
	"soifong",
	"RamCikiciew",
	"Qbo",
	"Vask0",
	"smoof",
	//ATK Players
	"motm",
	"oSee",
	"JT",
	"floppy",
	"Sonic",
	//Energy Players
	"TheM4N",
	"Dweezil",
	"kaNibalistic",
	"adM",
	"bLazE",
	//Furious Players
	"laser",
	"iKrystal",
	"PREDI",
	"TISAN",
	"dinamo",
	//BLUEJAYS Players
	"dEE",
	"DiMKE",
	"aVN",
	"sarenii",
	"c0llins",
	//EXECUTIONERS Players
	"ZesBeeW",
	"FamouZ",
	"maestro",
	"Snyder",
	"Sys",
	//Vexed Players
	"mezii",
	"Kray",
	"Adam9130",
	"L1NK",
	"ec1s",
	//GroundZero Players
	"BURNRUOk",
	"void",
	"zemp",
	"zeph",
	"pan1K",
	//Aristocracy Players
	"mouz",
	"rallen",
	"TaZ",
	"MINISE",
	"dycha",
	//BTRG Players
	"Eeyore",
	"Drea3er",
	"xccurate",
	"ImpressioN",
	"adrnkiNg",
	//Keyd Players
	"SHOOWTiME",
	"zqk",
	"dzt",
	"f4stzin",
	"KILLDREAM",
	//GTZ Players
	"emp",
	"MISK",
	"CarboN",
	"Kustom",
	"shellzy",
	//Flames Players
	"TeSeS",
	"farlig",
	"AcilioN",
	"TMB",
	"Nodios",
	//eu4ia Players
	"kek0",
	"MasterdaN",
	"diNk",
	"Vinice",
	"sh0wz",
	//Fierce Players
	"Astroo",
	"Impulse",
	"frei",
	"k1Ng0r",
	"ardiis",
	//Trident Players
	"TEX",
	"zorboT",
	"Rackem",
	"jhd",
	"jtr",
	//Syman Players
	"neaLaN",
	"Ramz1k",
	"n0rb3r7",
	"Perfecto",
	"Keoz",
	//wNv Players
	"k4Mi",
	"zWin",
	"Pure",
	"FairyRae",
	"kZy",
	//Goliath Players
	"massacRe",
	"Detrony",
	"deviaNt",
	"adaro",
	"ZipZip",
	//Endpoint Players
	"jenko",
	"Russ",
	"robiin",
	"Puls3",
	"Kryptix",
	//Genuine Players
	"stat",
	"Jinxx",
	"apocdud",
	"SkulL",
	"Mayker",
	//MiTH Players
	"NIFFY",
	"Leaf",
	"JUSTCAUSE",
	"Reality",
	"PPOverdose",
	//UOL Players
	"crisby",
	"kzy",
	"Andyy",
	"JDC",
	"OKOLICIOUZ",
	//9INE Players
	"PALM1",
	"phzy",
	"Djury",
	"aybeN",
	"MistFire",
	//Baecon Players
	"brA",
	"Demonos",
	"SHOUW",
	"sark",
	"axoN",
	//Corvidae Players
	"DANZ",
	"dash",
	"m1tch",
	"nibke",
	"Dirty",
	//Wizards Players
	"KALAS",
	"v1NCHENSO7",
	"Kiles",
	"Fit1nho",
	"Ryd3r-",
	//Illuminar Players
	"oskarish",
	"STOMP",
	"mono",
	"innocent",
	"reatz",
	//Queso Players
	"TheClaran",
	"rAmbi",
	"VARES",
	"mik",
	"Yaba",
	//W&R Players
	"Swaggy",
	"TotunG",
	"Ping",
	"Br0die",
	"angry",
	//GameAgents Players
	"pounh",
	"FliP1",
	"COSMEEEN",
	"kalle",
	"shadow",
	//Orange Players
	"Max",
	"cara",
	"formlesS",
	"Raph",
	"risk",
	//IG Players
	"EXPRO",
	"V4D1M",
	"flying",
	"equal",
	"Koshak",
	//HR Players
	"ANGE1",
	"nukkye",
	"Flarich",
	"crush",
	"scoobyxie",
	//Dice Players
	"XpG",
	"nonick",
	"Kan4",
	"Polox",
	"DEVIL",
	//Absolute Players
	"crow",
	"Laz",
	"barce",
	"takej",
	"Reita",
	//KPI Players
	"xikii",
	"SunPayus",
	"meisoN",
	"donQ",
	"MackDaddy"
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
	
	RegConsoleCmd("kickbots", KickBots);
	RegConsoleCmd("team_nip", Team_NiP);
	RegConsoleCmd("team_mibr", Team_MIBR);
	RegConsoleCmd("team_faze", Team_FaZe);
	RegConsoleCmd("team_astralis", Team_Astralis);
	RegConsoleCmd("team_c9", Team_C9);
	RegConsoleCmd("team_g2", Team_G2);
	RegConsoleCmd("team_fnatic", Team_fnatic);
	RegConsoleCmd("team_north", Team_North);
	RegConsoleCmd("team_mouz", Team_mouz);
	RegConsoleCmd("team_tyloo", Team_TyLoo);
	RegConsoleCmd("team_eg", Team_EG);
	RegConsoleCmd("team_rng", Team_RNG);
	RegConsoleCmd("team_navi", Team_NaVi);
	RegConsoleCmd("team_liquid", Team_Liquid);
	RegConsoleCmd("team_ago", Team_AGO);
	RegConsoleCmd("team_ence", Team_ENCE);
	RegConsoleCmd("team_vitality", Team_Vitality);
	RegConsoleCmd("team_big", Team_BIG);
	RegConsoleCmd("team_avangar", Team_AVANGAR);
	RegConsoleCmd("team_windigo", Team_Windigo);
	RegConsoleCmd("team_furia", Team_FURIA);
	RegConsoleCmd("team_cr4zy", Team_CR4ZY);
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
	RegConsoleCmd("team_grayhound", Team_Grayhound);
	RegConsoleCmd("team_mvppk", Team_MVPPK);
	RegConsoleCmd("team_envy", Team_Envy);
	RegConsoleCmd("team_spirit", Team_Spirit);
	RegConsoleCmd("team_cex", Team_CeX);
	RegConsoleCmd("team_ldlc", Team_LDLC);
	RegConsoleCmd("team_defusekids", Team_Defusekids);
	RegConsoleCmd("team_gamerlegion", Team_GamerLegion);
	RegConsoleCmd("team_divizon", Team_DIVIZON);
	RegConsoleCmd("team_euronics", Team_EURONICS);
	RegConsoleCmd("team_expert", Team_expert);
	RegConsoleCmd("team_panthers", Team_PANTHERS);
	RegConsoleCmd("team_pducks", Team_PDucks);
	RegConsoleCmd("team_havu", Team_HAVU);
	RegConsoleCmd("team_lyngby", Team_Lyngby);
	RegConsoleCmd("team_smash", Team_SMASH);
	RegConsoleCmd("team_nordavind", Team_Nordavind);
	RegConsoleCmd("team_sj", Team_SJ);
	RegConsoleCmd("team_tricked", Team_Tricked);
	RegConsoleCmd("team_baskonia", Team_Baskonia);
	RegConsoleCmd("team_giants", Team_Giants);
	RegConsoleCmd("team_lions", Team_Lions);
	RegConsoleCmd("team_riders", Team_Riders);
	RegConsoleCmd("team_offset", Team_OFFSET);
	RegConsoleCmd("team_x6tence", Team_x6tence);
	RegConsoleCmd("team_esuba", Team_eSuba);
	RegConsoleCmd("team_nexus", Team_Nexus);
	RegConsoleCmd("team_pact", Team_PACT);
	RegConsoleCmd("team_heretics", Team_Heretics);
	RegConsoleCmd("team_fcdb", Team_FCDB);
	RegConsoleCmd("team_nemiga", Team_Nemiga);
	RegConsoleCmd("team_pro100", Team_pro100);
	RegConsoleCmd("team_eunited", Team_eUnited);
	RegConsoleCmd("team_mythic", Team_Mythic);
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
	RegConsoleCmd("team_leisure", Team_LEISURE);
	RegConsoleCmd("team_order", Team_ORDER);
	RegConsoleCmd("team_blacks", Team_BlackS);
	RegConsoleCmd("team_extatus", Team_eXtatus);
	RegConsoleCmd("team_syf", Team_SYF);
	RegConsoleCmd("team_5power", Team_5Power);
	RegConsoleCmd("team_ehome", Team_EHOME);
	RegConsoleCmd("team_alpha", Team_ALPHA);
	RegConsoleCmd("team_dreamscape", Team_dreamScape);
	RegConsoleCmd("team_beyond", Team_Beyond);
	RegConsoleCmd("team_entity", Team_Entity);
	RegConsoleCmd("team_frostfire", Team_FrostFire);
	RegConsoleCmd("team_lucid", Team_Lucid);
	RegConsoleCmd("team_nasr", Team_NASR);
	RegConsoleCmd("team_portal", Team_Portal);
	RegConsoleCmd("team_brutals", Team_Brutals);
	RegConsoleCmd("team_invictus", Team_iNvictus);
	RegConsoleCmd("team_nxl", Team_nxl);
	RegConsoleCmd("team_atk", Team_ATK);
	RegConsoleCmd("team_energy", Team_energy);
	RegConsoleCmd("team_furious", Team_Furious);
	RegConsoleCmd("team_bluejays", Team_BLUEJAYS);
	RegConsoleCmd("team_executioners", Team_EXECUTIONERS);
	RegConsoleCmd("team_vexed", Team_Vexed);
	RegConsoleCmd("team_groundzero", Team_GroundZero);
	RegConsoleCmd("team_aristocracy", Team_Aristocracy);
	RegConsoleCmd("team_btrg", Team_BTRG);
	RegConsoleCmd("team_keyd", Team_Keyd);
	RegConsoleCmd("team_gtz", Team_GTZ);
	RegConsoleCmd("team_flames", Team_Flames);
	RegConsoleCmd("team_eu4ia", Team_eu4ia);
	RegConsoleCmd("team_fierce", Team_Fierce);
	RegConsoleCmd("team_trident", Team_Trident);
	RegConsoleCmd("team_syman", Team_Syman);
	RegConsoleCmd("team_wnv", Team_wNv);
	RegConsoleCmd("team_goliath", Team_Goliath);
	RegConsoleCmd("team_endpoint", Team_Endpoint);
	RegConsoleCmd("team_genuine", Team_Genuine);
	RegConsoleCmd("team_mith", Team_MiTH);
	RegConsoleCmd("team_uol", Team_UOL);
	RegConsoleCmd("team_9ine", Team_9INE);
	RegConsoleCmd("team_baecon", Team_Baecon);
	RegConsoleCmd("team_corvidae", Team_Corvidae);
	RegConsoleCmd("team_wizards", Team_Wizards);
	RegConsoleCmd("team_illuminar", Team_Illuminar);
	RegConsoleCmd("team_queso", Team_Queso);
	RegConsoleCmd("team_windrain", Team_WindRain);
	RegConsoleCmd("team_gameagents", Team_GameAgents);
	RegConsoleCmd("team_orange", Team_Orange);
	RegConsoleCmd("team_ig", Team_IG);
	RegConsoleCmd("team_hr", Team_HR);
	RegConsoleCmd("team_dice", Team_Dice);
	RegConsoleCmd("team_absolute", Team_Absolute);
	RegConsoleCmd("team_kpi", Team_KPI);
}

public Action KickBots(int client, int args)
{
	ServerCommand("bot_kick");
	
	return Plugin_Handled;
}

public Action Team_NiP(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "twist");
		ServerCommand("bot_add_ct %s", "Lekr0");
		ServerCommand("bot_add_ct %s", "f0rest");
		ServerCommand("bot_add_ct %s", "Plopski");
		ServerCommand("bot_add_ct %s", "REZ");
		ServerCommand("mp_teamlogo_1 nip");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "twist");
		ServerCommand("bot_add_t %s", "Lekr0");
		ServerCommand("bot_add_t %s", "f0rest");
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
		ServerCommand("bot_add_ct %s", "kNgV-");
		ServerCommand("bot_add_ct %s", "FalleN");
		ServerCommand("bot_add_ct %s", "fer");
		ServerCommand("bot_add_ct %s", "TACO");
		ServerCommand("bot_add_ct %s", "LUCAS1");
		ServerCommand("mp_teamlogo_1 mibr");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "kNgV-");
		ServerCommand("bot_add_t %s", "FalleN");
		ServerCommand("bot_add_t %s", "fer");
		ServerCommand("bot_add_t %s", "TACO");
		ServerCommand("bot_add_t %s", "LUCAS1");
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
		ServerCommand("bot_add_ct %s", "olofmeister");
		ServerCommand("bot_add_ct %s", "broky");
		ServerCommand("bot_add_ct %s", "NiKo");
		ServerCommand("bot_add_ct %s", "rain");
		ServerCommand("bot_add_ct %s", "coldzera");
		ServerCommand("mp_teamlogo_1 faze");
	}
	
	if(StrEqual(arg, "t"))
	{
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
		ServerCommand("bot_add_ct %s", "Xyp9x");
		ServerCommand("bot_add_ct %s", "device");
		ServerCommand("bot_add_ct %s", "gla1ve");
		ServerCommand("bot_add_ct %s", "Magisk");
		ServerCommand("bot_add_ct %s", "dupreeh");
		ServerCommand("mp_teamlogo_1 astr");
	}
	
	if(StrEqual(arg, "t"))
	{
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
		ServerCommand("bot_add_ct %s", "autimatic");
		ServerCommand("bot_add_ct %s", "mixwell");
		ServerCommand("bot_add_ct %s", "daps");
		ServerCommand("bot_add_ct %s", "koosta");
		ServerCommand("bot_add_ct %s", "Subroza");
		ServerCommand("mp_teamlogo_1 c9");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "autimatic");
		ServerCommand("bot_add_t %s", "mixwell");
		ServerCommand("bot_add_t %s", "daps");
		ServerCommand("bot_add_t %s", "koosta");
		ServerCommand("bot_add_t %s", "Subroza");
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
		ServerCommand("bot_add_ct %s", "huNter-");
		ServerCommand("bot_add_ct %s", "kennyS");
		ServerCommand("bot_add_ct %s", "nexa");
		ServerCommand("bot_add_ct %s", "JaCkz");
		ServerCommand("bot_add_ct %s", "AMANEK");
		ServerCommand("mp_teamlogo_1 g2");
	}
	
	if(StrEqual(arg, "t"))
	{
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
		ServerCommand("bot_add_ct %s", "flusha");
		ServerCommand("bot_add_ct %s", "JW");
		ServerCommand("bot_add_ct %s", "KRiMZ");
		ServerCommand("bot_add_ct %s", "Brollan");
		ServerCommand("bot_add_ct %s", "Golden");
		ServerCommand("mp_teamlogo_1 fntc");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "flusha");
		ServerCommand("bot_add_t %s", "JW");
		ServerCommand("bot_add_t %s", "KRiMZ");
		ServerCommand("bot_add_t %s", "Brollan");
		ServerCommand("bot_add_t %s", "Golden");
		ServerCommand("mp_teamlogo_2 fntc");
	}
	
	return Plugin_Handled;
}

public Action Team_North(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "JUGi");
		ServerCommand("bot_add_ct %s", "Kjaerbye");
		ServerCommand("bot_add_ct %s", "aizy");
		ServerCommand("bot_add_ct %s", "cajunb");
		ServerCommand("bot_add_ct %s", "gade");
		ServerCommand("mp_teamlogo_1 nor");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "JUGi");
		ServerCommand("bot_add_t %s", "Kjaerbye");
		ServerCommand("bot_add_t %s", "aizy");
		ServerCommand("bot_add_t %s", "cajunb");
		ServerCommand("bot_add_t %s", "gade");
		ServerCommand("mp_teamlogo_2 nor");
	}
	
	return Plugin_Handled;
}

public Action Team_mouz(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "karrigan");
		ServerCommand("bot_add_ct %s", "chrisJ");
		ServerCommand("bot_add_ct %s", "woxic");
		ServerCommand("bot_add_ct %s", "frozen");
		ServerCommand("bot_add_ct %s", "ropz");
		ServerCommand("mp_teamlogo_1 mss");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "karrigan");
		ServerCommand("bot_add_t %s", "chrisJ");
		ServerCommand("bot_add_t %s", "woxic");
		ServerCommand("bot_add_t %s", "frozen");
		ServerCommand("bot_add_t %s", "ropz");
		ServerCommand("mp_teamlogo_2 mss");
	}
	
	return Plugin_Handled;
}

public Action Team_TyLoo(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "Summer");
		ServerCommand("bot_add_ct %s", "Attacker");
		ServerCommand("bot_add_ct %s", "BnTneT");
		ServerCommand("bot_add_ct %s", "somebody");
		ServerCommand("bot_add_ct %s", "Freeman");
		ServerCommand("mp_teamlogo_1 tyl");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "Summer");
		ServerCommand("bot_add_t %s", "Attacker");
		ServerCommand("bot_add_t %s", "BnTneT");
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
		ServerCommand("bot_add_ct %s", "stanislaw");
		ServerCommand("bot_add_ct %s", "tarik");
		ServerCommand("bot_add_ct %s", "Brehze");
		ServerCommand("bot_add_ct %s", "nahtE");
		ServerCommand("bot_add_ct %s", "CeRq");
		ServerCommand("mp_teamlogo_1 eg");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "stanislaw");
		ServerCommand("bot_add_t %s", "tarik");
		ServerCommand("bot_add_t %s", "Brehze");
		ServerCommand("bot_add_t %s", "nahtE");
		ServerCommand("bot_add_t %s", "CeRq");
		ServerCommand("mp_teamlogo_2 eg");
	}
	
	return Plugin_Handled;
}

public Action Team_RNG(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "AZR");
		ServerCommand("bot_add_ct %s", "jks");
		ServerCommand("bot_add_ct %s", "jkaem");
		ServerCommand("bot_add_ct %s", "Gratisfaction");
		ServerCommand("bot_add_ct %s", "Liazz");
		ServerCommand("mp_teamlogo_1 ren");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "AZR");
		ServerCommand("bot_add_t %s", "jks");
		ServerCommand("bot_add_t %s", "jkaem");
		ServerCommand("bot_add_t %s", "Gratisfaction");
		ServerCommand("bot_add_t %s", "Liazz");
		ServerCommand("mp_teamlogo_2 ren");
	}
	
	return Plugin_Handled;
}

public Action Team_NaVi(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "electronic");
		ServerCommand("bot_add_ct %s", "s1mple");
		ServerCommand("bot_add_ct %s", "flamie");
		ServerCommand("bot_add_ct %s", "Boombl4");
		ServerCommand("bot_add_ct %s", "GuardiaN");
		ServerCommand("mp_teamlogo_1 navi");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "electronic");
		ServerCommand("bot_add_t %s", "s1mple");
		ServerCommand("bot_add_t %s", "flamie");
		ServerCommand("bot_add_t %s", "Boombl4");
		ServerCommand("bot_add_t %s", "GuardiaN");
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
		ServerCommand("bot_add_ct %s", "Stewie2K");
		ServerCommand("bot_add_ct %s", "NAF");
		ServerCommand("bot_add_ct %s", "nitr0");
		ServerCommand("bot_add_ct %s", "ELiGE");
		ServerCommand("bot_add_ct %s", "Twistzz");
		ServerCommand("mp_teamlogo_1 liq");
	}
	
	if(StrEqual(arg, "t"))
	{
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
		ServerCommand("bot_add_ct %s", "Furlan");
		ServerCommand("bot_add_ct %s", "GruBy");
		ServerCommand("bot_add_ct %s", "mhL");
		ServerCommand("bot_add_ct %s", "Sidney");
		ServerCommand("bot_add_ct %s", "leman");
		ServerCommand("mp_teamlogo_1 ago");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "Furlan");
		ServerCommand("bot_add_t %s", "GruBy");
		ServerCommand("bot_add_t %s", "mhL");
		ServerCommand("bot_add_t %s", "Sidney");
		ServerCommand("bot_add_t %s", "leman");
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
		ServerCommand("bot_add_ct %s", "suNny");
		ServerCommand("bot_add_ct %s", "allu");
		ServerCommand("bot_add_ct %s", "sergej");
		ServerCommand("bot_add_ct %s", "Aerial");
		ServerCommand("bot_add_ct %s", "xseveN");
		ServerCommand("mp_teamlogo_1 ence");
	}
	
	if(StrEqual(arg, "t"))
	{
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
		ServerCommand("bot_add_ct %s", "shox");
		ServerCommand("bot_add_ct %s", "ZywOo");
		ServerCommand("bot_add_ct %s", "apEX");
		ServerCommand("bot_add_ct %s", "RpK");
		ServerCommand("bot_add_ct %s", "ALEX");
		ServerCommand("mp_teamlogo_1 vita");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "shox");
		ServerCommand("bot_add_t %s", "ZywOo");
		ServerCommand("bot_add_t %s", "apEX");
		ServerCommand("bot_add_t %s", "RpK");
		ServerCommand("bot_add_t %s", "ALEX");
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
		ServerCommand("bot_add_ct %s", "tiziaN");
		ServerCommand("bot_add_ct %s", "smooya");
		ServerCommand("bot_add_ct %s", "XANTARES");
		ServerCommand("bot_add_ct %s", "tabseN");
		ServerCommand("bot_add_ct %s", "nex");
		ServerCommand("mp_teamlogo_1 big");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "tiziaN");
		ServerCommand("bot_add_t %s", "smooya");
		ServerCommand("bot_add_t %s", "XANTARES");
		ServerCommand("bot_add_t %s", "tabseN");
		ServerCommand("bot_add_t %s", "nex");
		ServerCommand("mp_teamlogo_2 big");
	}
	
	return Plugin_Handled;
}

public Action Team_AVANGAR(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "buster");
		ServerCommand("bot_add_ct %s", "Jame");
		ServerCommand("bot_add_ct %s", "qikert");
		ServerCommand("bot_add_ct %s", "AdreN");
		ServerCommand("bot_add_ct %s", "SANJI");
		ServerCommand("mp_teamlogo_1 avg");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "buster");
		ServerCommand("bot_add_t %s", "Jame");
		ServerCommand("bot_add_t %s", "qikert");
		ServerCommand("bot_add_t %s", "AdreN");
		ServerCommand("bot_add_t %s", "SANJI");
		ServerCommand("mp_teamlogo_2 avg");
	}
	
	return Plugin_Handled;
}

public Action Team_Windigo(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "mirbit");
		ServerCommand("bot_add_ct %s", "bubble");
		ServerCommand("bot_add_ct %s", "hAdji");
		ServerCommand("bot_add_ct %s", "Calyx");
		ServerCommand("bot_add_ct %s", "poizon");
		ServerCommand("mp_teamlogo_1 wind");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "mirbit");
		ServerCommand("bot_add_t %s", "bubble");
		ServerCommand("bot_add_t %s", "hAdji");
		ServerCommand("bot_add_t %s", "Calyx");
		ServerCommand("bot_add_t %s", "poizon");
		ServerCommand("mp_teamlogo_2 wind");
	}
	
	return Plugin_Handled;
}

public Action Team_FURIA(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "yuurih");
		ServerCommand("bot_add_ct %s", "arT");
		ServerCommand("bot_add_ct %s", "VINI");
		ServerCommand("bot_add_ct %s", "kscerato");
		ServerCommand("bot_add_ct %s", "HEN1");
		ServerCommand("mp_teamlogo_1 furi");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "yuurih");
		ServerCommand("bot_add_t %s", "arT");
		ServerCommand("bot_add_t %s", "VINI");
		ServerCommand("bot_add_t %s", "kscerato");
		ServerCommand("bot_add_t %s", "HEN1");
		ServerCommand("mp_teamlogo_2 furi");
	}
	
	return Plugin_Handled;
}

public Action Team_CR4ZY(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "LETN1");
		ServerCommand("bot_add_ct %s", "ottoNd");
		ServerCommand("bot_add_ct %s", "SHiPZ");
		ServerCommand("bot_add_ct %s", "emi");
		ServerCommand("bot_add_ct %s", "EspiranTo");
		ServerCommand("mp_teamlogo_1 cr4z");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "LETN1");
		ServerCommand("bot_add_t %s", "ottoNd");
		ServerCommand("bot_add_t %s", "SHiPZ");
		ServerCommand("bot_add_t %s", "emi");
		ServerCommand("bot_add_t %s", "EspiranTo");
		ServerCommand("mp_teamlogo_2 cr4z");
	}
	
	return Plugin_Handled;
}

public Action Team_coL(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "dephh");
		ServerCommand("bot_add_ct %s", "ShahZaM");
		ServerCommand("bot_add_ct %s", "oBo");
		ServerCommand("bot_add_ct %s", "RUSH");
		ServerCommand("bot_add_ct %s", "blameF");
		ServerCommand("mp_teamlogo_1 col");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "dephh");
		ServerCommand("bot_add_t %s", "ShahZaM");
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
		ServerCommand("bot_add_ct %s", "zhokiNg");
		ServerCommand("bot_add_ct %s", "kaze");
		ServerCommand("bot_add_ct %s", "aumaN");
		ServerCommand("bot_add_ct %s", "JamYoung");
		ServerCommand("bot_add_ct %s", "advent");
		ServerCommand("mp_teamlogo_1 vici");
	}
	
	if(StrEqual(arg, "t"))
	{
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
		ServerCommand("bot_add_ct %s", "facecrack");
		ServerCommand("bot_add_ct %s", "xsepower");
		ServerCommand("bot_add_ct %s", "FL1T");
		ServerCommand("bot_add_ct %s", "almazer");
		ServerCommand("bot_add_ct %s", "Jerry");
		ServerCommand("mp_teamlogo_1 forz");
	}
	
	if(StrEqual(arg, "t"))
	{
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
		ServerCommand("bot_add_ct %s", "Lack1");
		ServerCommand("bot_add_ct %s", "KrizzeN");
		ServerCommand("bot_add_ct %s", "Hobbit");
		ServerCommand("bot_add_ct %s", "El1an");
		ServerCommand("bot_add_ct %s", "bondik");
		ServerCommand("mp_teamlogo_1 wins");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "Lack1");
		ServerCommand("bot_add_t %s", "KrizzeN");
		ServerCommand("bot_add_t %s", "Hobbit");
		ServerCommand("bot_add_t %s", "El1an");
		ServerCommand("bot_add_t %s", "bondik");
		ServerCommand("mp_teamlogo_2 wins");
	}
	
	return Plugin_Handled;
}

public Action Team_Sprout(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "k1to");
		ServerCommand("bot_add_ct %s", "syrsoN");
		ServerCommand("bot_add_ct %s", "Spiidi");
		ServerCommand("bot_add_ct %s", "faveN");
		ServerCommand("bot_add_ct %s", "denis");
		ServerCommand("mp_teamlogo_1 spr");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "k1to");
		ServerCommand("bot_add_t %s", "syrsoN");
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
		ServerCommand("bot_add_ct %s", "es3tag");
		ServerCommand("bot_add_ct %s", "b0RUP");
		ServerCommand("bot_add_ct %s", "Snappi");
		ServerCommand("bot_add_ct %s", "cadiaN");
		ServerCommand("bot_add_ct %s", "stavn");
		ServerCommand("mp_teamlogo_1 heroi");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "es3tag");
		ServerCommand("bot_add_t %s", "b0RUP");
		ServerCommand("bot_add_t %s", "Snappi");
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
		ServerCommand("bot_add_ct %s", "chelo");
		ServerCommand("bot_add_ct %s", "shz");
		ServerCommand("bot_add_ct %s", "xand");
		ServerCommand("bot_add_ct %s", "destinyy");
		ServerCommand("bot_add_ct %s", "yeL");
		ServerCommand("mp_teamlogo_1 intz");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "chelo");
		ServerCommand("bot_add_t %s", "shz");
		ServerCommand("bot_add_t %s", "xand");
		ServerCommand("bot_add_t %s", "destinyy");
		ServerCommand("bot_add_t %s", "yeL");
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
		ServerCommand("bot_add_ct %s", "MICHU");
		ServerCommand("bot_add_ct %s", "snatchie");
		ServerCommand("bot_add_ct %s", "phr");
		ServerCommand("bot_add_ct %s", "Snax");
		ServerCommand("bot_add_ct %s", "Vegi");
		ServerCommand("mp_teamlogo_1 vp");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "MICHU");
		ServerCommand("bot_add_t %s", "snatchie");
		ServerCommand("bot_add_t %s", "phr");
		ServerCommand("bot_add_t %s", "Snax");
		ServerCommand("bot_add_t %s", "Vegi");
		ServerCommand("mp_teamlogo_2 vp");
	}
	
	return Plugin_Handled;
}

public Action Team_Apeks(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "Marcelious");
		ServerCommand("bot_add_ct %s", "truth");
		ServerCommand("bot_add_ct %s", "Grusarn");
		ServerCommand("bot_add_ct %s", "akEz");
		ServerCommand("bot_add_ct %s", "Radifaction");
		ServerCommand("mp_teamlogo_1 ape");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "Marcelious");
		ServerCommand("bot_add_t %s", "truth");
		ServerCommand("bot_add_t %s", "Grusarn");
		ServerCommand("bot_add_t %s", "akEz");
		ServerCommand("bot_add_t %s", "Radifaction");
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
		ServerCommand("bot_add_ct %s", "stfN");
		ServerCommand("bot_add_ct %s", "slaxz");
		ServerCommand("bot_add_ct %s", "DuDe");
		ServerCommand("bot_add_ct %s", "kressy");
		ServerCommand("bot_add_ct %s", "mantuu");
		ServerCommand("mp_teamlogo_1 alt");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "stfN");
		ServerCommand("bot_add_t %s", "slaxz");
		ServerCommand("bot_add_t %s", "DuDe");
		ServerCommand("bot_add_t %s", "kressy");
		ServerCommand("bot_add_t %s", "mantuu");
		ServerCommand("mp_teamlogo_2 alt");
	}
	
	return Plugin_Handled;
}

public Action Team_Grayhound(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "INS");
		ServerCommand("bot_add_ct %s", "sico");
		ServerCommand("bot_add_ct %s", "dexter");
		ServerCommand("bot_add_ct %s", "DickStacy");
		ServerCommand("bot_add_ct %s", "malta");
		ServerCommand("mp_teamlogo_1 gray");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "INS");
		ServerCommand("bot_add_t %s", "sico");
		ServerCommand("bot_add_t %s", "dexter");
		ServerCommand("bot_add_t %s", "DickStacy");
		ServerCommand("bot_add_t %s", "malta");
		ServerCommand("mp_teamlogo_2 gray");
	}
	
	return Plugin_Handled;
}

public Action Team_MVPPK(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "glow");
		ServerCommand("bot_add_ct %s", "xeta");
		ServerCommand("bot_add_ct %s", "Rb");
		ServerCommand("bot_add_ct %s", "k1Ng");
		ServerCommand("bot_add_ct %s", "stax");
		ServerCommand("mp_teamlogo_1 mvp");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "glow");
		ServerCommand("bot_add_t %s", "xeta");
		ServerCommand("bot_add_t %s", "Rb");
		ServerCommand("bot_add_t %s", "k1Ng");
		ServerCommand("bot_add_t %s", "stax");
		ServerCommand("mp_teamlogo_2 mvp");
	}
	
	return Plugin_Handled;
}

public Action Team_Envy(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "Nifty");
		ServerCommand("bot_add_ct %s", "ryann");
		ServerCommand("bot_add_ct %s", "s0m");
		ServerCommand("bot_add_ct %s", "ANDROID");
		ServerCommand("bot_add_ct %s", "FugLy");
		ServerCommand("mp_teamlogo_1 nv");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "Nifty");
		ServerCommand("bot_add_t %s", "ryann");
		ServerCommand("bot_add_t %s", "s0m");
		ServerCommand("bot_add_t %s", "ANDROID");
		ServerCommand("bot_add_t %s", "FugLy");
		ServerCommand("mp_teamlogo_2 nv");
	}
	
	return Plugin_Handled;
}

public Action Team_Spirit(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "mir");
		ServerCommand("bot_add_ct %s", "iDISBALANCE");
		ServerCommand("bot_add_ct %s", "somedieyoung");
		ServerCommand("bot_add_ct %s", "chopper");
		ServerCommand("bot_add_ct %s", "magixx");
		ServerCommand("mp_teamlogo_1 spir");
	}
	
	if(StrEqual(arg, "t"))
	{
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
		ServerCommand("bot_add_ct %s", "LiamjS");
		ServerCommand("bot_add_ct %s", "resu");
		ServerCommand("bot_add_ct %s", "Nukeddog");
		ServerCommand("bot_add_ct %s", "JamesBT");
		ServerCommand("bot_add_ct %s", "Murky");
		ServerCommand("mp_teamlogo_1 cex");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "LiamjS");
		ServerCommand("bot_add_t %s", "resu");
		ServerCommand("bot_add_t %s", "Nukeddog");
		ServerCommand("bot_add_t %s", "JamesBT");
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
		ServerCommand("bot_add_ct %s", "rodeN");
		ServerCommand("bot_add_ct %s", "Happy");
		ServerCommand("bot_add_ct %s", "MAJ3R");
		ServerCommand("bot_add_ct %s", "xms");
		ServerCommand("bot_add_ct %s", "SIXER");
		ServerCommand("mp_teamlogo_1 ldlc");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "rodeN");
		ServerCommand("bot_add_t %s", "Happy");
		ServerCommand("bot_add_t %s", "MAJ3R");
		ServerCommand("bot_add_t %s", "xms");
		ServerCommand("bot_add_t %s", "SIXER");
		ServerCommand("mp_teamlogo_2 ldlc");
	}
	
	return Plugin_Handled;
}

public Action Team_Defusekids(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "v1N");
		ServerCommand("bot_add_ct %s", "G1DO");
		ServerCommand("bot_add_ct %s", "FASHR");
		ServerCommand("bot_add_ct %s", "Monu");
		ServerCommand("bot_add_ct %s", "rilax");
		ServerCommand("mp_teamlogo_1 defu");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "v1N");
		ServerCommand("bot_add_t %s", "G1DO");
		ServerCommand("bot_add_t %s", "FASHR");
		ServerCommand("bot_add_t %s", "Monu");
		ServerCommand("bot_add_t %s", "rilax");
		ServerCommand("mp_teamlogo_2 defu");
	}
	
	return Plugin_Handled;
}

public Action Team_GamerLegion(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "dennis");
		ServerCommand("bot_add_ct %s", "nawwk");
		ServerCommand("bot_add_ct %s", "PlesseN");
		ServerCommand("bot_add_ct %s", "RuStY");
		ServerCommand("bot_add_ct %s", "hampus");
		ServerCommand("mp_teamlogo_1 glegion");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "dennis");
		ServerCommand("bot_add_t %s", "nawwk");
		ServerCommand("bot_add_t %s", "PlesseN");
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
		ServerCommand("bot_add_ct %s", "TR1P");
		ServerCommand("bot_add_ct %s", "glaVed");
		ServerCommand("bot_add_ct %s", "hyped");
		ServerCommand("bot_add_ct %s", "n1kista");
		ServerCommand("bot_add_ct %s", "MajoRR");
		ServerCommand("mp_teamlogo_1 divi");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "TR1P");
		ServerCommand("bot_add_t %s", "glaVed");
		ServerCommand("bot_add_t %s", "hyped");
		ServerCommand("bot_add_t %s", "n1kista");
		ServerCommand("bot_add_t %s", "MajoRR");
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
		ServerCommand("bot_add_ct %s", "red");
		ServerCommand("bot_add_ct %s", "PREET");
		ServerCommand("bot_add_ct %s", "PerX");
		ServerCommand("bot_add_ct %s", "Seeeya");
		ServerCommand("bot_add_ct %s", "pdy");
		ServerCommand("mp_teamlogo_1 euro");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "red");
		ServerCommand("bot_add_t %s", "PREET");
		ServerCommand("bot_add_t %s", "PerX");
		ServerCommand("bot_add_t %s", "Seeeya");
		ServerCommand("bot_add_t %s", "pdy");
		ServerCommand("mp_teamlogo_2 euro");
	}
	
	return Plugin_Handled;
}

public Action Team_expert(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "Aika");
		ServerCommand("bot_add_ct %s", "syncD");
		ServerCommand("bot_add_ct %s", "BMLN");
		ServerCommand("bot_add_ct %s", "HighKitty");
		ServerCommand("bot_add_ct %s", "VENIQ");
		ServerCommand("mp_teamlogo_1 exp");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "Aika");
		ServerCommand("bot_add_t %s", "syncD");
		ServerCommand("bot_add_t %s", "BMLN");
		ServerCommand("bot_add_t %s", "HighKitty");
		ServerCommand("bot_add_t %s", "VENIQ");
		ServerCommand("mp_teamlogo_2 exp");
	}
	
	return Plugin_Handled;
}

public Action Team_PANTHERS(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "rUFY");
		ServerCommand("bot_add_ct %s", "darkz");
		ServerCommand("bot_add_ct %s", "denzel");
		ServerCommand("bot_add_ct %s", "expo");
		ServerCommand("bot_add_ct %s", "stowny");
		ServerCommand("mp_teamlogo_1 pant");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "rUFY");
		ServerCommand("bot_add_t %s", "darkz");
		ServerCommand("bot_add_t %s", "denzel");
		ServerCommand("bot_add_t %s", "expo");
		ServerCommand("bot_add_t %s", "stowny");
		ServerCommand("mp_teamlogo_2 pant");
	}
	
	return Plugin_Handled;
}

public Action Team_PDucks(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "neviZ");
		ServerCommand("bot_add_ct %s", "synx");
		ServerCommand("bot_add_ct %s", "delkore");
		ServerCommand("bot_add_ct %s", "nky");
		ServerCommand("bot_add_ct %s", "Cargo");
		ServerCommand("mp_teamlogo_1 playin");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "neviZ");
		ServerCommand("bot_add_t %s", "synx");
		ServerCommand("bot_add_t %s", "delkore");
		ServerCommand("bot_add_t %s", "nky");
		ServerCommand("bot_add_t %s", "Cargo");
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
		ServerCommand("bot_add_ct %s", "ZOREE");
		ServerCommand("bot_add_ct %s", "sLowi");
		ServerCommand("bot_add_ct %s", "doto");
		ServerCommand("bot_add_ct %s", "Hoody");
		ServerCommand("bot_add_ct %s", "sAw");
		ServerCommand("mp_teamlogo_1 havu");
	}
	
	if(StrEqual(arg, "t"))
	{
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
		ServerCommand("bot_add_ct %s", "birdfromsky");
		ServerCommand("bot_add_ct %s", "Twinx");
		ServerCommand("bot_add_ct %s", "Daffu");
		ServerCommand("bot_add_ct %s", "thamlike");
		ServerCommand("bot_add_ct %s", "Cabbi");
		ServerCommand("mp_teamlogo_1 lyng");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "birdfromsky");
		ServerCommand("bot_add_t %s", "Twinx");
		ServerCommand("bot_add_t %s", "Daffu");
		ServerCommand("bot_add_t %s", "thamlike");
		ServerCommand("bot_add_t %s", "Cabbi");
		ServerCommand("mp_teamlogo_2 lyng");
	}
	
	return Plugin_Handled;
}

public Action Team_SMASH(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "maden");
		ServerCommand("bot_add_ct %s", "Maikelele");
		ServerCommand("bot_add_ct %s", "kRYSTAL");
		ServerCommand("bot_add_ct %s", "zehN");
		ServerCommand("bot_add_ct %s", "STYKO");
		ServerCommand("mp_teamlogo_1 smash");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "maden");
		ServerCommand("bot_add_t %s", "Maikelele");
		ServerCommand("bot_add_t %s", "kRYSTAL");
		ServerCommand("bot_add_t %s", "zehN");
		ServerCommand("bot_add_t %s", "STYKO");
		ServerCommand("mp_teamlogo_2 smash");
	}
	
	return Plugin_Handled;
}

public Action Team_Nordavind(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "tenzki");
		ServerCommand("bot_add_ct %s", "hallzerk");
		ServerCommand("bot_add_ct %s", "RUBINO");
		ServerCommand("bot_add_ct %s", "H4RR3");
		ServerCommand("bot_add_ct %s", "cromen");
		ServerCommand("mp_teamlogo_1 nord");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "tenzki");
		ServerCommand("bot_add_t %s", "hallzerk");
		ServerCommand("bot_add_t %s", "RUBINO");
		ServerCommand("bot_add_t %s", "H4RR3");
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
		ServerCommand("bot_add_ct %s", "arvid");
		ServerCommand("bot_add_ct %s", "Jamppi");
		ServerCommand("bot_add_ct %s", "SADDYX");
		ServerCommand("bot_add_ct %s", "KHRN");
		ServerCommand("bot_add_ct %s", "xartE");
		ServerCommand("mp_teamlogo_1 sjg");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "arvid");
		ServerCommand("bot_add_t %s", "Jamppi");
		ServerCommand("bot_add_t %s", "SADDYX");
		ServerCommand("bot_add_t %s", "KHRN");
		ServerCommand("bot_add_t %s", "xartE");
		ServerCommand("mp_teamlogo_2 sjg");
	}
	
	return Plugin_Handled;
}

public Action Team_Tricked(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "roeJ");
		ServerCommand("bot_add_ct %s", "acoR");
		ServerCommand("bot_add_ct %s", "HUNDEN");
		ServerCommand("bot_add_ct %s", "Sjuush");
		ServerCommand("bot_add_ct %s", "Bubzkji");
		ServerCommand("mp_teamlogo_1 tricked");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "roeJ");
		ServerCommand("bot_add_t %s", "acoR");
		ServerCommand("bot_add_t %s", "HUNDEN");
		ServerCommand("bot_add_t %s", "Sjuush");
		ServerCommand("bot_add_t %s", "Bubzkji");
		ServerCommand("mp_teamlogo_2 tricked");
	}
	
	return Plugin_Handled;
}

public Action Team_Baskonia(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "tatin");
		ServerCommand("bot_add_ct %s", "PabLo");
		ServerCommand("bot_add_ct %s", "LittlesataN1");
		ServerCommand("bot_add_ct %s", "dixon");
		ServerCommand("bot_add_ct %s", "jJavi");
		ServerCommand("mp_teamlogo_1 bask");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "tatin");
		ServerCommand("bot_add_t %s", "PabLo");
		ServerCommand("bot_add_t %s", "LittlesataN1");
		ServerCommand("bot_add_t %s", "dixon");
		ServerCommand("bot_add_t %s", "jJavi");
		ServerCommand("mp_teamlogo_2 bask");
	}
	
	return Plugin_Handled;
}

public Action Team_Giants(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "rmn");
		ServerCommand("bot_add_ct %s", "fox");
		ServerCommand("bot_add_ct %s", "Cunha");
		ServerCommand("bot_add_ct %s", "MUTiRiS");
		ServerCommand("bot_add_ct %s", "arki");
		ServerCommand("mp_teamlogo_1 giant");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "rmn");
		ServerCommand("bot_add_t %s", "fox");
		ServerCommand("bot_add_t %s", "Cunha");
		ServerCommand("bot_add_t %s", "MUTiRiS");
		ServerCommand("bot_add_t %s", "arki");
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
		ServerCommand("bot_add_ct %s", "YuRk0");
		ServerCommand("bot_add_ct %s", "Jibrix");
		ServerCommand("bot_add_ct %s", "Kairi");
		ServerCommand("bot_add_ct %s", "HUMANZ");
		ServerCommand("bot_add_ct %s", "NaOw");
		ServerCommand("mp_teamlogo_1 lion");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "YuRk0");
		ServerCommand("bot_add_t %s", "Jibrix");
		ServerCommand("bot_add_t %s", "Kairi");
		ServerCommand("bot_add_t %s", "HUMANZ");
		ServerCommand("bot_add_t %s", "NaOw");
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
		ServerCommand("bot_add_ct %s", "mopoz");
		ServerCommand("bot_add_ct %s", "EasTor");
		ServerCommand("bot_add_ct %s", "steel");
		ServerCommand("bot_add_ct %s", "\"alex*\"");
		ServerCommand("bot_add_ct %s", "loWel");
		ServerCommand("mp_teamlogo_1 movis");
	}
	
	if(StrEqual(arg, "t"))
	{
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
		ServerCommand("bot_add_ct %s", "RIZZ");
		ServerCommand("bot_add_ct %s", "obj");
		ServerCommand("bot_add_ct %s", "JUST");
		ServerCommand("bot_add_ct %s", "stadodo");
		ServerCommand("bot_add_ct %s", "pr");
		ServerCommand("mp_teamlogo_1 offs");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "RIZZ");
		ServerCommand("bot_add_t %s", "obj");
		ServerCommand("bot_add_t %s", "JUST");
		ServerCommand("bot_add_t %s", "stadodo");
		ServerCommand("bot_add_t %s", "pr");
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
		ServerCommand("bot_add_ct %s", "NikoM");
		ServerCommand("bot_add_ct %s", "\"JonY BoY\"");
		ServerCommand("bot_add_ct %s", "tomi");
		ServerCommand("bot_add_ct %s", "OMG");
		ServerCommand("bot_add_ct %s", "tutehen");
		ServerCommand("mp_teamlogo_1 x6t");
	}
	
	if(StrEqual(arg, "t"))
	{
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
		ServerCommand("bot_add_ct %s", "HenkkyG");
		ServerCommand("bot_add_ct %s", "ZEDKO");
		ServerCommand("bot_add_ct %s", "leckr");
		ServerCommand("bot_add_ct %s", "Blogg1s");
		ServerCommand("bot_add_ct %s", "SHOCK");
		ServerCommand("mp_teamlogo_1 esu");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "HenkkyG");
		ServerCommand("bot_add_t %s", "ZEDKO");
		ServerCommand("bot_add_t %s", "leckr");
		ServerCommand("bot_add_t %s", "Blogg1s");
		ServerCommand("bot_add_t %s", "SHOCK");
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
		ServerCommand("bot_add_ct %s", "BTN");
		ServerCommand("bot_add_ct %s", "XELLOW");
		ServerCommand("bot_add_ct %s", "SEMINTE");
		ServerCommand("bot_add_ct %s", "iM");
		ServerCommand("bot_add_ct %s", "starkiller");
		ServerCommand("mp_teamlogo_1 nex");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "BTN");
		ServerCommand("bot_add_t %s", "XELLOW");
		ServerCommand("bot_add_t %s", "SEMINTE");
		ServerCommand("bot_add_t %s", "iM");
		ServerCommand("bot_add_t %s", "starkiller");
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
		ServerCommand("bot_add_ct %s", "darko");
		ServerCommand("bot_add_ct %s", "lunAtic");
		ServerCommand("bot_add_ct %s", "Goofy");
		ServerCommand("bot_add_ct %s", "Crityourface");
		ServerCommand("bot_add_ct %s", "Sobol");
		ServerCommand("mp_teamlogo_1 pact");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "darko");
		ServerCommand("bot_add_t %s", "lunAtic");
		ServerCommand("bot_add_t %s", "Goofy");
		ServerCommand("bot_add_t %s", "Crityourface");
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
		ServerCommand("bot_add_ct %s", "davidp");
		ServerCommand("bot_add_ct %s", "Maka");
		ServerCommand("bot_add_ct %s", "devoduvek");
		ServerCommand("bot_add_ct %s", "kioShiMa");
		ServerCommand("bot_add_ct %s", "Lucky");
		ServerCommand("mp_teamlogo_1 here");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "davidp");
		ServerCommand("bot_add_t %s", "Maka");
		ServerCommand("bot_add_t %s", "devoduvek");
		ServerCommand("bot_add_t %s", "kioShiMa");
		ServerCommand("bot_add_t %s", "Lucky");
		ServerCommand("mp_teamlogo_2 here");
	}
	
	return Plugin_Handled;
}

public Action Team_FCDB(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "razOk");
		ServerCommand("bot_add_ct %s", "matusik");
		ServerCommand("bot_add_ct %s", "Ao-");
		ServerCommand("bot_add_ct %s", "Cludi");
		ServerCommand("bot_add_ct %s", "vrs");
		ServerCommand("mp_teamlogo_1 fcdb");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "razOk");
		ServerCommand("bot_add_t %s", "matusik");
		ServerCommand("bot_add_t %s", "Ao-");
		ServerCommand("bot_add_t %s", "Cludi");
		ServerCommand("bot_add_t %s", "vrs");
		ServerCommand("mp_teamlogo_2 fcdb");
	}
	
	return Plugin_Handled;
}

public Action Team_Nemiga(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "ROBO");
		ServerCommand("bot_add_ct %s", "hutji");
		ServerCommand("bot_add_ct %s", "lollipop21k");
		ServerCommand("bot_add_ct %s", "Jyo");
		ServerCommand("bot_add_ct %s", "boX");
		ServerCommand("mp_teamlogo_1 nem");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "ROBO");
		ServerCommand("bot_add_t %s", "hutji");
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
		ServerCommand("bot_add_ct %s", "dimasick");
		ServerCommand("bot_add_ct %s", "WorldEdit");
		ServerCommand("bot_add_ct %s", "YEKINDAR");
		ServerCommand("bot_add_ct %s", "wayLander");
		ServerCommand("bot_add_ct %s", "NickelBack");
		ServerCommand("mp_teamlogo_1 pro");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "dimasick");
		ServerCommand("bot_add_t %s", "WorldEdit");
		ServerCommand("bot_add_t %s", "YEKINDAR");
		ServerCommand("bot_add_t %s", "wayLander");
		ServerCommand("bot_add_t %s", "NickelBack");
		ServerCommand("mp_teamlogo_2 pro");
	}
	
	return Plugin_Handled;
}

public Action Team_eUnited(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "freakazoid");
		ServerCommand("bot_add_ct %s", "Cooper-");
		ServerCommand("bot_add_ct %s", "MarKE");
		ServerCommand("bot_add_ct %s", "food");
		ServerCommand("bot_add_ct %s", "vanity");
		ServerCommand("mp_teamlogo_1 eun");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "freakazoid");
		ServerCommand("bot_add_t %s", "Cooper-");
		ServerCommand("bot_add_t %s", "MarKE");
		ServerCommand("bot_add_t %s", "food");
		ServerCommand("bot_add_t %s", "vanity");
		ServerCommand("mp_teamlogo_2 eun");
	}
	
	return Plugin_Handled;
}

public Action Team_Mythic(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "C0M");
		ServerCommand("bot_add_ct %s", "fl0m");
		ServerCommand("bot_add_ct %s", "Katie");
		ServerCommand("bot_add_ct %s", "hazed");
		ServerCommand("bot_add_ct %s", "SileNt");
		ServerCommand("mp_teamlogo_1 myth");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "C0M");
		ServerCommand("bot_add_t %s", "fl0m");
		ServerCommand("bot_add_t %s", "Katie");
		ServerCommand("bot_add_t %s", "hazed");
		ServerCommand("bot_add_t %s", "SileNt");
		ServerCommand("mp_teamlogo_2 myth");
	}
	
	return Plugin_Handled;
}

public Action Team_Singularity(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "wrath");
		ServerCommand("bot_add_ct %s", "Relyks");
		ServerCommand("bot_add_ct %s", "seb");
		ServerCommand("bot_add_ct %s", "dazzLe");
		ServerCommand("bot_add_ct %s", "dapr");
		ServerCommand("mp_teamlogo_1 sing");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "wrath");
		ServerCommand("bot_add_t %s", "Relyks");
		ServerCommand("bot_add_t %s", "seb");
		ServerCommand("bot_add_t %s", "dazzLe");
		ServerCommand("bot_add_t %s", "dapr");
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
		ServerCommand("bot_add_ct %s", "prt");
		ServerCommand("bot_add_ct %s", "tiburci0");
		ServerCommand("bot_add_ct %s", "v$m");
		ServerCommand("bot_add_ct %s", "Lucaozy");
		ServerCommand("bot_add_ct %s", "Tuurtle");
		ServerCommand("mp_teamlogo_1 deto");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "prt");
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
		ServerCommand("bot_add_ct %s", "cruzN");
		ServerCommand("bot_add_ct %s", "malbsMd");
		ServerCommand("bot_add_ct %s", "spamzzy");
		ServerCommand("bot_add_ct %s", "sam_A");
		ServerCommand("bot_add_ct %s", "Daveys");
		ServerCommand("mp_teamlogo_1 infi");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "cruzN");
		ServerCommand("bot_add_t %s", "malbsMd");
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
		ServerCommand("bot_add_ct %s", "1962");
		ServerCommand("bot_add_ct %s", "Noktse");
		ServerCommand("bot_add_ct %s", "Reversive");
		ServerCommand("bot_add_ct %s", "nbl");
		ServerCommand("bot_add_ct %s", "maxujas");
		ServerCommand("mp_teamlogo_1 isu");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "1962");
		ServerCommand("bot_add_t %s", "Noktse");
		ServerCommand("bot_add_t %s", "Reversive");
		ServerCommand("bot_add_t %s", "nbl");
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
		ServerCommand("bot_add_ct %s", "PKL");
		ServerCommand("bot_add_ct %s", "land1n");
		ServerCommand("bot_add_ct %s", "tatazin");
		ServerCommand("bot_add_ct %s", "biguzera");
		ServerCommand("bot_add_ct %s", "hardzao");
		ServerCommand("mp_teamlogo_1 pain");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "PKL");
		ServerCommand("bot_add_t %s", "land1n");
		ServerCommand("bot_add_t %s", "tatazin");
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
		ServerCommand("bot_add_ct %s", "meyern");
		ServerCommand("bot_add_ct %s", "jnt");
		ServerCommand("bot_add_ct %s", "leo_drunky");
		ServerCommand("bot_add_ct %s", "exit");
		ServerCommand("bot_add_ct %s", "Luken");
		ServerCommand("mp_teamlogo_1 shark");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "meyern");
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
		ServerCommand("bot_add_ct %s", "bld V");
		ServerCommand("bot_add_ct %s", "Maluk3");
		ServerCommand("bot_add_ct %s", "trk");
		ServerCommand("bot_add_ct %s", "bit");
		ServerCommand("bot_add_ct %s", "b4rtiN");
		ServerCommand("mp_teamlogo_1 tone");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "bld V");
		ServerCommand("bot_add_t %s", "Maluk3");
		ServerCommand("bot_add_t %s", "trk");
		ServerCommand("bot_add_t %s", "bit");
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
		ServerCommand("bot_add_ct %s", "skullz");
		ServerCommand("bot_add_ct %s", "raafa");
		ServerCommand("bot_add_ct %s", "ryotzz");
		ServerCommand("bot_add_ct %s", "pancc");
		ServerCommand("bot_add_ct %s", "realziN");
		ServerCommand("mp_teamlogo_1 w7m");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "skullz");
		ServerCommand("bot_add_t %s", "raafa");
		ServerCommand("bot_add_t %s", "ryotzz");
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
		ServerCommand("bot_add_ct %s", "soju_j");
		ServerCommand("bot_add_ct %s", "sterling");
		ServerCommand("bot_add_ct %s", "apoc");
		ServerCommand("bot_add_ct %s", "J1rah");
		ServerCommand("bot_add_ct %s", "HaZR");
		ServerCommand("mp_teamlogo_1 avant");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "soju_j");
		ServerCommand("bot_add_t %s", "sterling");
		ServerCommand("bot_add_t %s", "apoc");
		ServerCommand("bot_add_t %s", "J1rah");
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
		ServerCommand("bot_add_ct %s", "tucks");
		ServerCommand("bot_add_ct %s", "BL1TZ");
		ServerCommand("bot_add_ct %s", "Texta");
		ServerCommand("bot_add_ct %s", "ofnu");
		ServerCommand("bot_add_ct %s", "zewsy");
		ServerCommand("mp_teamlogo_1 chief");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "tucks");
		ServerCommand("bot_add_t %s", "BL1TZ");
		ServerCommand("bot_add_t %s", "Texta");
		ServerCommand("bot_add_t %s", "ofnu");
		ServerCommand("bot_add_t %s", "zewsy");
		ServerCommand("mp_teamlogo_2 chief");
	}
	
	return Plugin_Handled;
}

public Action Team_LEISURE(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "padow");
		ServerCommand("bot_add_ct %s", "amigo");
		ServerCommand("bot_add_ct %s", "fly");
		ServerCommand("bot_add_ct %s", "cHap");
		ServerCommand("bot_add_ct %s", "Rand");
		ServerCommand("mp_teamlogo_1 leis");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "padow");
		ServerCommand("bot_add_t %s", "amigo");
		ServerCommand("bot_add_t %s", "fly");
		ServerCommand("bot_add_t %s", "cHap");
		ServerCommand("bot_add_t %s", "Rand");
		ServerCommand("mp_teamlogo_2 leis");
	}
	
	return Plugin_Handled;
}

public Action Team_ORDER(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "emagine");
		ServerCommand("bot_add_ct %s", "aliStair");
		ServerCommand("bot_add_ct %s", "hatz");
		ServerCommand("bot_add_ct %s", "USTILO");
		ServerCommand("bot_add_ct %s", "Valiance");
		ServerCommand("mp_teamlogo_1 order");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "emagine");
		ServerCommand("bot_add_t %s", "aliStair");
		ServerCommand("bot_add_t %s", "hatz");
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
		ServerCommand("bot_add_ct %s", "hue9ze");
		ServerCommand("bot_add_ct %s", "addict");
		ServerCommand("bot_add_ct %s", "cookie");
		ServerCommand("bot_add_ct %s", "jeepy");
		ServerCommand("bot_add_ct %s", "Wolfah");
		ServerCommand("mp_teamlogo_1 black");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "hue9ze");
		ServerCommand("bot_add_t %s", "addict");
		ServerCommand("bot_add_t %s", "cookie");
		ServerCommand("bot_add_t %s", "jeepy");
		ServerCommand("bot_add_t %s", "Wolfah");
		ServerCommand("mp_teamlogo_2 black");
	}
	
	return Plugin_Handled;
}

public Action Team_eXtatus(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "luko");
		ServerCommand("bot_add_ct %s", "wEAMO");
		ServerCommand("bot_add_ct %s", "desty");
		ServerCommand("bot_add_ct %s", "Fraged");
		ServerCommand("bot_add_ct %s", "Pechyn");
		ServerCommand("mp_teamlogo_1 ext");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "luko");
		ServerCommand("bot_add_t %s", "wEAMO");
		ServerCommand("bot_add_t %s", "desty");
		ServerCommand("bot_add_t %s", "Fraged");
		ServerCommand("bot_add_t %s", "Pechyn");
		ServerCommand("mp_teamlogo_2 ext");
	}
	
	return Plugin_Handled;
}

public Action Team_SYF(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "ino");
		ServerCommand("bot_add_ct %s", "Teal");
		ServerCommand("bot_add_ct %s", "ekul");
		ServerCommand("bot_add_ct %s", "bedonka");
		ServerCommand("bot_add_ct %s", "urbz");
		ServerCommand("mp_teamlogo_1 syf");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "ino");
		ServerCommand("bot_add_t %s", "Teal");
		ServerCommand("bot_add_t %s", "ekul");
		ServerCommand("bot_add_t %s", "bedonka");
		ServerCommand("bot_add_t %s", "urbz");
		ServerCommand("mp_teamlogo_2 syf");
	}
	
	return Plugin_Handled;
}

public Action Team_5Power(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "bottle");
		ServerCommand("bot_add_ct %s", "Savage");
		ServerCommand("bot_add_ct %s", "xiaosaGe");
		ServerCommand("bot_add_ct %s", "shuadapai");
		ServerCommand("bot_add_ct %s", "Viva");
		ServerCommand("mp_teamlogo_1 5pow");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "bottle");
		ServerCommand("bot_add_t %s", "Savage");
		ServerCommand("bot_add_t %s", "xiaosaGe");
		ServerCommand("bot_add_t %s", "shuadapai");
		ServerCommand("bot_add_t %s", "Viva");
		ServerCommand("mp_teamlogo_2 5pow");
	}
	
	return Plugin_Handled;
}

public Action Team_EHOME(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "insane");
		ServerCommand("bot_add_ct %s", "originalheart");
		ServerCommand("bot_add_ct %s", "Marek");
		ServerCommand("bot_add_ct %s", "SLOWLY");
		ServerCommand("bot_add_ct %s", "4king");
		ServerCommand("mp_teamlogo_1 ehome");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "insane");
		ServerCommand("bot_add_t %s", "originalheart");
		ServerCommand("bot_add_t %s", "Marek");
		ServerCommand("bot_add_t %s", "SLOWLY");
		ServerCommand("bot_add_t %s", "4king");
		ServerCommand("mp_teamlogo_2 ehome");
	}
	
	return Plugin_Handled;
}

public Action Team_ALPHA(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "MAIROLLS");
		ServerCommand("bot_add_ct %s", "Olivia");
		ServerCommand("bot_add_ct %s", "Kntz");
		ServerCommand("bot_add_ct %s", "SeveN89");
		ServerCommand("bot_add_ct %s", "foxz");
		ServerCommand("mp_teamlogo_1 alpha");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "MAIROLLS");
		ServerCommand("bot_add_t %s", "Olivia");
		ServerCommand("bot_add_t %s", "Kntz");
		ServerCommand("bot_add_t %s", "SeveN89");
		ServerCommand("bot_add_t %s", "foxz");
		ServerCommand("mp_teamlogo_2 alpha");
	}
	
	return Plugin_Handled;
}

public Action Team_dreamScape(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "Bobosaur");
		ServerCommand("bot_add_ct %s", "splashske");
		ServerCommand("bot_add_ct %s", "alecks");
		ServerCommand("bot_add_ct %s", "Benkai");
		ServerCommand("bot_add_ct %s", "d4v41");
		ServerCommand("mp_teamlogo_1 boot");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "Bobosaur");
		ServerCommand("bot_add_t %s", "splashske");
		ServerCommand("bot_add_t %s", "alecks");
		ServerCommand("bot_add_t %s", "Benkai");
		ServerCommand("bot_add_t %s", "d4v41");
		ServerCommand("mp_teamlogo_2 boot");
	}
	
	return Plugin_Handled;
}

public Action Team_Beyond(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "TOR");
		ServerCommand("bot_add_ct %s", "bnwGiggs");
		ServerCommand("bot_add_ct %s", "RoLEX");
		ServerCommand("bot_add_ct %s", "veta");
		ServerCommand("bot_add_ct %s", "Geniuss");
		ServerCommand("mp_teamlogo_1 bey");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "TOR");
		ServerCommand("bot_add_t %s", "bnwGiggs");
		ServerCommand("bot_add_t %s", "RoLEX");
		ServerCommand("bot_add_t %s", "veta");
		ServerCommand("bot_add_t %s", "Geniuss");
		ServerCommand("mp_teamlogo_2 bey");
	}
	
	return Plugin_Handled;
}

public Action Team_Entity(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "Amaterasu");
		ServerCommand("bot_add_ct %s", "Psy");
		ServerCommand("bot_add_ct %s", "Excali");
		ServerCommand("bot_add_ct %s", "skillZ");
		ServerCommand("bot_add_ct %s", "SnrLx");
		ServerCommand("mp_teamlogo_1 enti");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "Amaterasu");
		ServerCommand("bot_add_t %s", "Psy");
		ServerCommand("bot_add_t %s", "Excali");
		ServerCommand("bot_add_t %s", "skillZ");
		ServerCommand("bot_add_t %s", "SnrLx");
		ServerCommand("mp_teamlogo_2 enti");
	}
	
	return Plugin_Handled;
}

public Action Team_FrostFire(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "aimaNNN");
		ServerCommand("bot_add_ct %s", "hiqa1");
		ServerCommand("bot_add_ct %s", "acAp");
		ServerCommand("bot_add_ct %s", "Subbey");
		ServerCommand("bot_add_ct %s", "Avirity");
		ServerCommand("mp_teamlogo_1 frost");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "aimaNNN");
		ServerCommand("bot_add_t %s", "hiqa1");
		ServerCommand("bot_add_t %s", "acAp");
		ServerCommand("bot_add_t %s", "Subbey");
		ServerCommand("bot_add_t %s", "Avirity");
		ServerCommand("mp_teamlogo_2 frost");
	}
	
	return Plugin_Handled;
}

public Action Team_Lucid(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "wannafly");
		ServerCommand("bot_add_ct %s", "PTC");
		ServerCommand("bot_add_ct %s", "cbbk");
		ServerCommand("bot_add_ct %s", "JohnOlsen");
		ServerCommand("bot_add_ct %s", "qqGod");
		ServerCommand("mp_teamlogo_1 lucid");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "wannafly");
		ServerCommand("bot_add_t %s", "PTC");
		ServerCommand("bot_add_t %s", "cbbk");
		ServerCommand("bot_add_t %s", "JohnOlsen");
		ServerCommand("bot_add_t %s", "qqGod");
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
		ServerCommand("bot_add_ct %s", "breAker");
		ServerCommand("bot_add_ct %s", "Nami");
		ServerCommand("bot_add_ct %s", "kitkat");
		ServerCommand("bot_add_ct %s", "havoK");
		ServerCommand("bot_add_ct %s", "kAzoo");
		ServerCommand("mp_teamlogo_1 nasr");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "breAker");
		ServerCommand("bot_add_t %s", "Nami");
		ServerCommand("bot_add_t %s", "kitkat");
		ServerCommand("bot_add_t %s", "havoK");
		ServerCommand("bot_add_t %s", "kAzoo");
		ServerCommand("mp_teamlogo_2 nasr");
	}
	
	return Plugin_Handled;
}

public Action Team_Portal(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "traNz");
		ServerCommand("bot_add_ct %s", "Ttyke");
		ServerCommand("bot_add_ct %s", "DVDOV");
		ServerCommand("bot_add_ct %s", "PokemoN");
		ServerCommand("bot_add_ct %s", "Ebeee");
		ServerCommand("mp_teamlogo_1 port");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "traNz");
		ServerCommand("bot_add_t %s", "Ttyke");
		ServerCommand("bot_add_t %s", "DVDOV");
		ServerCommand("bot_add_t %s", "PokemoN");
		ServerCommand("bot_add_t %s", "Ebeee");
		ServerCommand("mp_teamlogo_2 port");
	}
	
	return Plugin_Handled;
}

public Action Team_Brutals(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "V3nom");
		ServerCommand("bot_add_ct %s", "RiX");
		ServerCommand("bot_add_ct %s", "Juventa");
		ServerCommand("bot_add_ct %s", "astaRR");
		ServerCommand("bot_add_ct %s", "spy");
		ServerCommand("mp_teamlogo_1 brut");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "V3nom");
		ServerCommand("bot_add_t %s", "RiX");
		ServerCommand("bot_add_t %s", "Juventa");
		ServerCommand("bot_add_t %s", "astaRR");
		ServerCommand("bot_add_t %s", "spy");
		ServerCommand("mp_teamlogo_2 brut");
	}
	
	return Plugin_Handled;
}

public Action Team_iNvictus(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "ribbiZ");
		ServerCommand("bot_add_ct %s", "Manan");
		ServerCommand("bot_add_ct %s", "Pashasahil");
		ServerCommand("bot_add_ct %s", "BinaryBUG");
		ServerCommand("bot_add_ct %s", "blackhawk");
		ServerCommand("mp_teamlogo_1 inv");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "ribbiZ");
		ServerCommand("bot_add_t %s", "Manan");
		ServerCommand("bot_add_t %s", "Pashasahil");
		ServerCommand("bot_add_t %s", "BinaryBUG");
		ServerCommand("bot_add_t %s", "blackhawk");
		ServerCommand("mp_teamlogo_2 inv");
	}
	
	return Plugin_Handled;
}

public Action Team_nxl(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "soifong");
		ServerCommand("bot_add_ct %s", "RamCikiciew");
		ServerCommand("bot_add_ct %s", "Qbo");
		ServerCommand("bot_add_ct %s", "Vask0");
		ServerCommand("bot_add_ct %s", "smoof");
		ServerCommand("mp_teamlogo_1 nxl");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "soifong");
		ServerCommand("bot_add_t %s", "RamCikiciew");
		ServerCommand("bot_add_t %s", "Qbo");
		ServerCommand("bot_add_t %s", "Vask0");
		ServerCommand("bot_add_t %s", "smoof");
		ServerCommand("mp_teamlogo_2 nxl");
	}
	
	return Plugin_Handled;
}

public Action Team_ATK(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "motm");
		ServerCommand("bot_add_ct %s", "oSee");
		ServerCommand("bot_add_ct %s", "JT");
		ServerCommand("bot_add_ct %s", "floppy");
		ServerCommand("bot_add_ct %s", "Sonic");
		ServerCommand("mp_teamlogo_1 atk");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "motm");
		ServerCommand("bot_add_t %s", "oSee");
		ServerCommand("bot_add_t %s", "JT");
		ServerCommand("bot_add_t %s", "floppy");
		ServerCommand("bot_add_t %s", "Sonic");
		ServerCommand("mp_teamlogo_2 atk");
	}
	
	return Plugin_Handled;
}

public Action Team_energy(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "TheM4N");
		ServerCommand("bot_add_ct %s", "Dweezil");
		ServerCommand("bot_add_ct %s", "kaNibalistic");
		ServerCommand("bot_add_ct %s", "adM");
		ServerCommand("bot_add_ct %s", "bLazE");
		ServerCommand("mp_teamlogo_1 ener");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "TheM4N");
		ServerCommand("bot_add_t %s", "Dweezil");
		ServerCommand("bot_add_t %s", "kaNibalistic");
		ServerCommand("bot_add_t %s", "adM");
		ServerCommand("bot_add_t %s", "bLazE");
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
		ServerCommand("bot_add_ct %s", "laser");
		ServerCommand("bot_add_ct %s", "iKrystal");
		ServerCommand("bot_add_ct %s", "PREDI");
		ServerCommand("bot_add_ct %s", "TISAN");
		ServerCommand("bot_add_ct %s", "dinamo");
		ServerCommand("mp_teamlogo_1 furio");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "laser");
		ServerCommand("bot_add_t %s", "iKrystal");
		ServerCommand("bot_add_t %s", "PREDI");
		ServerCommand("bot_add_t %s", "TISAN");
		ServerCommand("bot_add_t %s", "dinamo");
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
		ServerCommand("bot_add_ct %s", "dEE");
		ServerCommand("bot_add_ct %s", "DiMKE");
		ServerCommand("bot_add_ct %s", "aVN");
		ServerCommand("bot_add_ct %s", "sarenii");
		ServerCommand("bot_add_ct %s", "c0llins");
		ServerCommand("mp_teamlogo_1 blueja");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "dEE");
		ServerCommand("bot_add_t %s", "DiMKE");
		ServerCommand("bot_add_t %s", "aVN");
		ServerCommand("bot_add_t %s", "sarenii");
		ServerCommand("bot_add_t %s", "c0llins");
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
		ServerCommand("bot_add_ct %s", "ZesBeeW");
		ServerCommand("bot_add_ct %s", "FamouZ");
		ServerCommand("bot_add_ct %s", "maestro");
		ServerCommand("bot_add_ct %s", "Snyder");
		ServerCommand("bot_add_ct %s", "Sys");
		ServerCommand("mp_teamlogo_1 exec");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "ZesBeeW");
		ServerCommand("bot_add_t %s", "FamouZ");
		ServerCommand("bot_add_t %s", "maestro");
		ServerCommand("bot_add_t %s", "Snyder");
		ServerCommand("bot_add_t %s", "Sys");
		ServerCommand("mp_teamlogo_2 exec");
	}
	
	return Plugin_Handled;
}

public Action Team_Vexed(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "mezii");
		ServerCommand("bot_add_ct %s", "Kray");
		ServerCommand("bot_add_ct %s", "Adam9130");
		ServerCommand("bot_add_ct %s", "L1NK");
		ServerCommand("bot_add_ct %s", "ec1s");
		ServerCommand("mp_teamlogo_1 vex");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "mezii");
		ServerCommand("bot_add_t %s", "Kray");
		ServerCommand("bot_add_t %s", "Adam9130");
		ServerCommand("bot_add_t %s", "L1NK");
		ServerCommand("bot_add_t %s", "ec1s");
		ServerCommand("mp_teamlogo_2 vex");
	}
	
	return Plugin_Handled;
}

public Action Team_GroundZero(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "BURNRUOk");
		ServerCommand("bot_add_ct %s", "void");
		ServerCommand("bot_add_ct %s", "zemp");
		ServerCommand("bot_add_ct %s", "zeph");
		ServerCommand("bot_add_ct %s", "pan1K");
		ServerCommand("mp_teamlogo_1 ground");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "BURNRUOk");
		ServerCommand("bot_add_t %s", "void");
		ServerCommand("bot_add_t %s", "zemp");
		ServerCommand("bot_add_t %s", "zeph");
		ServerCommand("bot_add_t %s", "pan1K");
		ServerCommand("mp_teamlogo_2 ground");
	}
	
	return Plugin_Handled;
}

public Action Team_Aristocracy(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "mouz");
		ServerCommand("bot_add_ct %s", "rallen");
		ServerCommand("bot_add_ct %s", "TaZ");
		ServerCommand("bot_add_ct %s", "MINISE");
		ServerCommand("bot_add_ct %s", "dycha");
		ServerCommand("mp_teamlogo_1 arist");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "mouz");
		ServerCommand("bot_add_t %s", "rallen");
		ServerCommand("bot_add_t %s", "TaZ");
		ServerCommand("bot_add_t %s", "MINISE");
		ServerCommand("bot_add_t %s", "dycha");
		ServerCommand("mp_teamlogo_2 arist");
	}
	
	return Plugin_Handled;
}

public Action Team_BTRG(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "Eeyore");
		ServerCommand("bot_add_ct %s", "Drea3er");
		ServerCommand("bot_add_ct %s", "xccurate");
		ServerCommand("bot_add_ct %s", "ImpressioN");
		ServerCommand("bot_add_ct %s", "adrnkiNg");
		ServerCommand("mp_teamlogo_1 btrg");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "Eeyore");
		ServerCommand("bot_add_t %s", "Drea3er");
		ServerCommand("bot_add_t %s", "xccurate");
		ServerCommand("bot_add_t %s", "ImpressioN");
		ServerCommand("bot_add_t %s", "adrnkiNg");
		ServerCommand("mp_teamlogo_2 btrg");
	}
	
	return Plugin_Handled;
}

public Action Team_Keyd(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "SHOOWTiME");
		ServerCommand("bot_add_ct %s", "zqk");
		ServerCommand("bot_add_ct %s", "dzt");
		ServerCommand("bot_add_ct %s", "f4stzin");
		ServerCommand("bot_add_ct %s", "KILLDREAM");
		ServerCommand("mp_teamlogo_1 keyd");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "SHOOWTiME");
		ServerCommand("bot_add_t %s", "zqk");
		ServerCommand("bot_add_t %s", "dzt");
		ServerCommand("bot_add_t %s", "f4stzin");
		ServerCommand("bot_add_t %s", "KILLDREAM");
		ServerCommand("mp_teamlogo_2 keyd");
	}
	
	return Plugin_Handled;
}

public Action Team_GTZ(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "emp");
		ServerCommand("bot_add_ct %s", "MISK");
		ServerCommand("bot_add_ct %s", "CarboN");
		ServerCommand("bot_add_ct %s", "Kustom");
		ServerCommand("bot_add_ct %s", "shellzy");
		ServerCommand("mp_teamlogo_1 gtz");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "emp");
		ServerCommand("bot_add_t %s", "MISK");
		ServerCommand("bot_add_t %s", "CarboN");
		ServerCommand("bot_add_t %s", "Kustom");
		ServerCommand("bot_add_t %s", "shellzy");
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
		ServerCommand("bot_add_ct %s", "TeSeS");
		ServerCommand("bot_add_ct %s", "farlig");
		ServerCommand("bot_add_ct %s", "AcilioN");
		ServerCommand("bot_add_ct %s", "TMB");
		ServerCommand("bot_add_ct %s", "Nodios");
		ServerCommand("mp_teamlogo_1 copen");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "TeSeS");
		ServerCommand("bot_add_t %s", "farlig");
		ServerCommand("bot_add_t %s", "AcilioN");
		ServerCommand("bot_add_t %s", "TMB");
		ServerCommand("bot_add_t %s", "Nodios");
		ServerCommand("mp_teamlogo_2 copen");
	}
	
	return Plugin_Handled;
}

public Action Team_eu4ia(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "kek0");
		ServerCommand("bot_add_ct %s", "MasterdaN");
		ServerCommand("bot_add_ct %s", "diNk");
		ServerCommand("bot_add_ct %s", "Vinice");
		ServerCommand("bot_add_ct %s", "sh0wz");
		ServerCommand("mp_teamlogo_1 eu4ia");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "kek0");
		ServerCommand("bot_add_t %s", "MasterdaN");
		ServerCommand("bot_add_t %s", "diNk");
		ServerCommand("bot_add_t %s", "Vinice");
		ServerCommand("bot_add_t %s", "sh0wz");
		ServerCommand("mp_teamlogo_2 eu4ia");
	}
	
	return Plugin_Handled;
}

public Action Team_Fierce(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "Astroo");
		ServerCommand("bot_add_ct %s", "Impulse");
		ServerCommand("bot_add_ct %s", "frei");
		ServerCommand("bot_add_ct %s", "k1Ng0r");
		ServerCommand("bot_add_ct %s", "ardiis");
		ServerCommand("mp_teamlogo_1 fierce");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "Astroo");
		ServerCommand("bot_add_t %s", "Impulse");
		ServerCommand("bot_add_t %s", "frei");
		ServerCommand("bot_add_t %s", "k1Ng0r");
		ServerCommand("bot_add_t %s", "ardiis");
		ServerCommand("mp_teamlogo_2 fierce");
	}
	
	return Plugin_Handled;
}

public Action Team_Trident(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "TEX");
		ServerCommand("bot_add_ct %s", "zorboT");
		ServerCommand("bot_add_ct %s", "Rackem");
		ServerCommand("bot_add_ct %s", "jhd");
		ServerCommand("bot_add_ct %s", "jtr");
		ServerCommand("mp_teamlogo_1 trid");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "TEX");
		ServerCommand("bot_add_t %s", "zorboT");
		ServerCommand("bot_add_t %s", "Rackem");
		ServerCommand("bot_add_t %s", "jhd");
		ServerCommand("bot_add_t %s", "jtr");
		ServerCommand("mp_teamlogo_2 trid");
	}
	
	return Plugin_Handled;
}

public Action Team_Syman(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "neaLaN");
		ServerCommand("bot_add_ct %s", "Ramz1k");
		ServerCommand("bot_add_ct %s", "n0rb3r7");
		ServerCommand("bot_add_ct %s", "Perfecto");
		ServerCommand("bot_add_ct %s", "Keoz");
		ServerCommand("mp_teamlogo_1 syma");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "neaLaN");
		ServerCommand("bot_add_t %s", "Ramz1k");
		ServerCommand("bot_add_t %s", "n0rb3r7");
		ServerCommand("bot_add_t %s", "Perfecto");
		ServerCommand("bot_add_t %s", "Keoz");
		ServerCommand("mp_teamlogo_2 syma");
	}
	
	return Plugin_Handled;
}

public Action Team_wNv(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "k4Mi");
		ServerCommand("bot_add_ct %s", "zWin");
		ServerCommand("bot_add_ct %s", "Pure");
		ServerCommand("bot_add_ct %s", "FairyRae");
		ServerCommand("bot_add_ct %s", "kZy");
		ServerCommand("mp_teamlogo_1 wnv");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "k4Mi");
		ServerCommand("bot_add_t %s", "zWin");
		ServerCommand("bot_add_t %s", "Pure");
		ServerCommand("bot_add_t %s", "FairyRae");
		ServerCommand("bot_add_t %s", "kZy");
		ServerCommand("mp_teamlogo_2 wnv");
	}
	
	return Plugin_Handled;
}

public Action Team_Goliath(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "massacRe");
		ServerCommand("bot_add_ct %s", "Detrony");
		ServerCommand("bot_add_ct %s", "deviaNt");
		ServerCommand("bot_add_ct %s", "adaro");
		ServerCommand("bot_add_ct %s", "ZipZip");
		ServerCommand("mp_teamlogo_1 gol");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "massacRe");
		ServerCommand("bot_add_t %s", "Detrony");
		ServerCommand("bot_add_t %s", "deviaNt");
		ServerCommand("bot_add_t %s", "adaro");
		ServerCommand("bot_add_t %s", "ZipZip");
		ServerCommand("mp_teamlogo_2 gol");
	}
	
	return Plugin_Handled;
}

public Action Team_Endpoint(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "jenko");
		ServerCommand("bot_add_ct %s", "Russ");
		ServerCommand("bot_add_ct %s", "robiin");
		ServerCommand("bot_add_ct %s", "Puls3");
		ServerCommand("bot_add_ct %s", "Kryptix");
		ServerCommand("mp_teamlogo_1 endp");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "jenko");
		ServerCommand("bot_add_t %s", "Russ");
		ServerCommand("bot_add_t %s", "robiin");
		ServerCommand("bot_add_t %s", "Puls3");
		ServerCommand("bot_add_t %s", "Kryptix");
		ServerCommand("mp_teamlogo_2 endp");
	}
	
	return Plugin_Handled;
}

public Action Team_Genuine(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "stat");
		ServerCommand("bot_add_ct %s", "Jinxx");
		ServerCommand("bot_add_ct %s", "apocdud");
		ServerCommand("bot_add_ct %s", "SkulL");
		ServerCommand("bot_add_ct %s", "Mayker");
		ServerCommand("mp_teamlogo_1 genu");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "stat");
		ServerCommand("bot_add_t %s", "Jinxx");
		ServerCommand("bot_add_t %s", "apocdud");
		ServerCommand("bot_add_t %s", "SkulL");
		ServerCommand("bot_add_t %s", "Mayker");
		ServerCommand("mp_teamlogo_2 genu");
	}
	
	return Plugin_Handled;
}

public Action Team_MiTH(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "NIFFY");
		ServerCommand("bot_add_ct %s", "Leaf");
		ServerCommand("bot_add_ct %s", "JUSTCAUSE");
		ServerCommand("bot_add_ct %s", "Reality");
		ServerCommand("bot_add_ct %s", "PPOverdose");
		ServerCommand("mp_teamlogo_1 mith");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "NIFFY");
		ServerCommand("bot_add_t %s", "Leaf");
		ServerCommand("bot_add_t %s", "JUSTCAUSE");
		ServerCommand("bot_add_t %s", "Reality");
		ServerCommand("bot_add_t %s", "PPOverdose");
		ServerCommand("mp_teamlogo_2 mith");
	}

	return Plugin_Handled;
}

public Action Team_UOL(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "crisby");
		ServerCommand("bot_add_ct %s", "kzy");
		ServerCommand("bot_add_ct %s", "Andyy");
		ServerCommand("bot_add_ct %s", "JDC");
		ServerCommand("bot_add_ct %s", "OKOLICIOUZ");
		ServerCommand("mp_teamlogo_1 uni");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "crisby");
		ServerCommand("bot_add_t %s", "kzy");
		ServerCommand("bot_add_t %s", "Andyy");
		ServerCommand("bot_add_t %s", "JDC");
		ServerCommand("bot_add_t %s", "OKOLICIOUZ");
		ServerCommand("mp_teamlogo_2 uni");
	}

	return Plugin_Handled;
}

public Action Team_9INE(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "PALM1");
		ServerCommand("bot_add_ct %s", "phzy");
		ServerCommand("bot_add_ct %s", "Djury");
		ServerCommand("bot_add_ct %s", "aybeN");
		ServerCommand("bot_add_ct %s", "MistFire");
		ServerCommand("mp_teamlogo_1 9ine");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "PALM1");
		ServerCommand("bot_add_t %s", "phzy");
		ServerCommand("bot_add_t %s", "Djury");
		ServerCommand("bot_add_t %s", "aybeN");
		ServerCommand("bot_add_t %s", "MistFire");
		ServerCommand("mp_teamlogo_2 9ine");
	}

	return Plugin_Handled;
}

public Action Team_Baecon(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "brA");
		ServerCommand("bot_add_ct %s", "Demonos");
		ServerCommand("bot_add_ct %s", "SHOUW");
		ServerCommand("bot_add_ct %s", "sark");
		ServerCommand("bot_add_ct %s", "axoN");
		ServerCommand("mp_teamlogo_1 baec");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "brA");
		ServerCommand("bot_add_t %s", "Demonos");
		ServerCommand("bot_add_t %s", "SHOUW");
		ServerCommand("bot_add_t %s", "sark");
		ServerCommand("bot_add_t %s", "axoN");
		ServerCommand("mp_teamlogo_2 9ine");
	}

	return Plugin_Handled;
}

public Action Team_Corvidae(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "DANZ");
		ServerCommand("bot_add_ct %s", "dash");
		ServerCommand("bot_add_ct %s", "m1tch");
		ServerCommand("bot_add_ct %s", "nibke");
		ServerCommand("bot_add_ct %s", "Dirty");
		ServerCommand("mp_teamlogo_1 corv");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "DANZ");
		ServerCommand("bot_add_t %s", "dash");
		ServerCommand("bot_add_t %s", "m1tch");
		ServerCommand("bot_add_t %s", "nibke");
		ServerCommand("bot_add_t %s", "Dirty");
		ServerCommand("mp_teamlogo_2 corv");
	}

	return Plugin_Handled;
}

public Action Team_Wizards(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "KALAS");
		ServerCommand("bot_add_ct %s", "v1NCHENSO7");
		ServerCommand("bot_add_ct %s", "Kiles");
		ServerCommand("bot_add_ct %s", "Fit1nho");
		ServerCommand("bot_add_ct %s", "Ryd3r-");
		ServerCommand("mp_teamlogo_1 wiz");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "KALAS");
		ServerCommand("bot_add_t %s", "v1NCHENSO7");
		ServerCommand("bot_add_t %s", "Kiles");
		ServerCommand("bot_add_t %s", "Fit1nho");
		ServerCommand("bot_add_t %s", "Ryd3r-");
		ServerCommand("mp_teamlogo_2 wiz");
	}

	return Plugin_Handled;
}

public Action Team_Illuminar(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "oskarish");
		ServerCommand("bot_add_ct %s", "STOMP");
		ServerCommand("bot_add_ct %s", "mono");
		ServerCommand("bot_add_ct %s", "innocent");
		ServerCommand("bot_add_ct %s", "reatz");
		ServerCommand("mp_teamlogo_1 illu");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "oskarish");
		ServerCommand("bot_add_t %s", "STOMP");
		ServerCommand("bot_add_t %s", "mono");
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
		ServerCommand("bot_add_ct %s", "TheClaran");
		ServerCommand("bot_add_ct %s", "rAmbi");
		ServerCommand("bot_add_ct %s", "VARES");
		ServerCommand("bot_add_ct %s", "mik");
		ServerCommand("bot_add_ct %s", "Yaba");
		ServerCommand("mp_teamlogo_1 ques");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "TheClaran");
		ServerCommand("bot_add_t %s", "rAmbi");
		ServerCommand("bot_add_t %s", "VARES");
		ServerCommand("bot_add_t %s", "mik");
		ServerCommand("bot_add_t %s", "Yaba");
		ServerCommand("mp_teamlogo_2 ques");
	}

	return Plugin_Handled;
}

public Action Team_WindRain(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "Swaggy");
		ServerCommand("bot_add_ct %s", "TotunG");
		ServerCommand("bot_add_ct %s", "Ping");
		ServerCommand("bot_add_ct %s", "Br0die");
		ServerCommand("bot_add_ct %s", "angry");
		ServerCommand("mp_teamlogo_1 wr");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "Swaggy");
		ServerCommand("bot_add_t %s", "TotunG");
		ServerCommand("bot_add_t %s", "Ping");
		ServerCommand("bot_add_t %s", "Br0die");
		ServerCommand("bot_add_t %s", "angry");
		ServerCommand("mp_teamlogo_2 wr");
	}

	return Plugin_Handled;
}

public Action Team_GameAgents(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "pounh");
		ServerCommand("bot_add_ct %s", "FliP1");
		ServerCommand("bot_add_ct %s", "COSMEEEN");
		ServerCommand("bot_add_ct %s", "kalle");
		ServerCommand("bot_add_ct %s", "shadow");
		ServerCommand("mp_teamlogo_1 game");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "pounh");
		ServerCommand("bot_add_t %s", "FliP1");
		ServerCommand("bot_add_t %s", "COSMEEEN");
		ServerCommand("bot_add_t %s", "kalle");
		ServerCommand("bot_add_t %s", "shadow");
		ServerCommand("mp_teamlogo_2 game");
	}

	return Plugin_Handled;
}

public Action Team_Orange(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "Max");
		ServerCommand("bot_add_ct %s", "cara");
		ServerCommand("bot_add_ct %s", "formlesS");
		ServerCommand("bot_add_ct %s", "Raph");
		ServerCommand("bot_add_ct %s", "risk");
		ServerCommand("mp_teamlogo_1 oran");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "Max");
		ServerCommand("bot_add_t %s", "cara");
		ServerCommand("bot_add_t %s", "formlesS");
		ServerCommand("bot_add_t %s", "Raph");
		ServerCommand("bot_add_t %s", "risk");
		ServerCommand("mp_teamlogo_2 oran");
	}

	return Plugin_Handled;
}

public Action Team_IG(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "EXPRO");
		ServerCommand("bot_add_ct %s", "V4D1M");
		ServerCommand("bot_add_ct %s", "flying");
		ServerCommand("bot_add_ct %s", "equal");
		ServerCommand("bot_add_ct %s", "Koshak");
		ServerCommand("mp_teamlogo_1 ig");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "EXPRO");
		ServerCommand("bot_add_t %s", "V4D1M");
		ServerCommand("bot_add_t %s", "flying");
		ServerCommand("bot_add_t %s", "equal");
		ServerCommand("bot_add_t %s", "Koshak");
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
		ServerCommand("bot_add_ct %s", "ANGE1");
		ServerCommand("bot_add_ct %s", "nukkye");
		ServerCommand("bot_add_ct %s", "Flarich");
		ServerCommand("bot_add_ct %s", "crush");
		ServerCommand("bot_add_ct %s", "scoobyxie");
		ServerCommand("mp_teamlogo_1 hlr");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "ANGE1");
		ServerCommand("bot_add_t %s", "nukkye");
		ServerCommand("bot_add_t %s", "Flarich");
		ServerCommand("bot_add_t %s", "crush");
		ServerCommand("bot_add_t %s", "scoobyxie");
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
		ServerCommand("bot_add_ct %s", "XpG");
		ServerCommand("bot_add_ct %s", "nonick");
		ServerCommand("bot_add_ct %s", "Kan4");
		ServerCommand("bot_add_ct %s", "Polox");
		ServerCommand("bot_add_ct %s", "DEVIL");
		ServerCommand("mp_teamlogo_1 dice");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "XpG");
		ServerCommand("bot_add_t %s", "nonick");
		ServerCommand("bot_add_t %s", "Kan4");
		ServerCommand("bot_add_t %s", "Polox");
		ServerCommand("bot_add_t %s", "DEVIL");
		ServerCommand("mp_teamlogo_2 dice");
	}

	return Plugin_Handled;
}

public Action Team_Absolute(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "crow");
		ServerCommand("bot_add_ct %s", "Laz");
		ServerCommand("bot_add_ct %s", "barce");
		ServerCommand("bot_add_ct %s", "takej");
		ServerCommand("bot_add_ct %s", "Reita");
		ServerCommand("mp_teamlogo_1 abs");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "crow");
		ServerCommand("bot_add_t %s", "Laz");
		ServerCommand("bot_add_t %s", "barce");
		ServerCommand("bot_add_t %s", "takej");
		ServerCommand("bot_add_t %s", "Reita");
		ServerCommand("mp_teamlogo_2 abs");
	}

	return Plugin_Handled;
}

public Action Team_KPI(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_add_ct %s", "xikii");
		ServerCommand("bot_add_ct %s", "SunPayus");
		ServerCommand("bot_add_ct %s", "meisoN");
		ServerCommand("bot_add_ct %s", "donQ");
		ServerCommand("bot_add_ct %s", "MackDaddy");
		ServerCommand("mp_teamlogo_1 kpi");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_add_t %s", "xikii");
		ServerCommand("bot_add_t %s", "SunPayus");
		ServerCommand("bot_add_t %s", "meisoN");
		ServerCommand("bot_add_t %s", "donQ");
		ServerCommand("bot_add_t %s", "MackDaddy");
		ServerCommand("mp_teamlogo_2 kpi");
	}

	return Plugin_Handled;
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
		if(StrEqual(botname, g_BotName[i]))
		{
			FakeClientCommand(client, "say !aimbot");
		}
	}
	
	Pro_Players(botname, client);
	
	g_iProfileRank[client] = GetRandomInt(1,40);
	
	SetCustomPrivateRank(client);
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
			
			if(GetRandomInt(1,5) == 1)
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
		else if(StrEqual(weapon,"ak47"))
		{
			int iWeapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
			
			if(GetRandomInt(1,3) == 1)
			{
				if (iWeapon != -1)
				{
					RemovePlayerItem(client, iWeapon);
				}
				
				m_iAccount -= 2750;
				GivePlayerItem(client, "weapon_sg556");
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
        KillTimer(g_hShouldAttackTimer[client]);
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
			g_iCoin[client] = GetRandomInt(1028,1057);
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
		int iPrimary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
		
		if (iPrimary != -1)
		{
			return Plugin_Stop;
		}
		
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

public void Pro_Players(char[] botname, int client)
{

	//MIBR Players
	if((StrEqual(botname, "kNgV-")) || (StrEqual(botname, "FalleN")) || (StrEqual(botname, "fer")) || (StrEqual(botname, "TACO")) || (StrEqual(botname, "LUCAS1")))
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
	if((StrEqual(botname, "twist")) || (StrEqual(botname, "Plopski")) || (StrEqual(botname, "f0rest")) || (StrEqual(botname, "Lekr0")) || (StrEqual(botname, "REZ")))
	{
		CS_SetClientClanTag(client, "NiP");
	}
	
	//C9 Players
	if((StrEqual(botname, "autimatic")) || (StrEqual(botname, "mixwell")) || (StrEqual(botname, "daps")) || (StrEqual(botname, "koosta")) || (StrEqual(botname, "Subroza")))
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
	if((StrEqual(botname, "JUGi")) || (StrEqual(botname, "Kjaerbye")) || (StrEqual(botname, "aizy")) || (StrEqual(botname, "cajunb")) || (StrEqual(botname, "gade")))
	{
		CS_SetClientClanTag(client, "North");
	}
	
	//mouz Players
	if((StrEqual(botname, "karrigan")) || (StrEqual(botname, "chrisJ")) || (StrEqual(botname, "woxic")) || (StrEqual(botname, "frozen")) || (StrEqual(botname, "ropz")))
	{
		CS_SetClientClanTag(client, "mouz");
	}
	
	//TyLoo Players
	if((StrEqual(botname, "Summer")) || (StrEqual(botname, "Attacker")) || (StrEqual(botname, "BnTneT")) || (StrEqual(botname, "somebody")) || (StrEqual(botname, "Freeman")))
	{
		CS_SetClientClanTag(client, "TyLoo");
	}
	
	//EG Players
	if((StrEqual(botname, "stanislaw")) || (StrEqual(botname, "tarik")) || (StrEqual(botname, "Brehze")) || (StrEqual(botname, "nahtE")) || (StrEqual(botname, "CeRq")))
	{
		CS_SetClientClanTag(client, "EG");
	}
	
	//RNG Players
	if((StrEqual(botname, "AZR")) || (StrEqual(botname, "jks")) || (StrEqual(botname, "jkaem")) || (StrEqual(botname, "Gratisfaction")) || (StrEqual(botname, "Liazz")))
	{
		CS_SetClientClanTag(client, "RNG");
	}
	
	//Na´Vi Players
	if((StrEqual(botname, "electronic")) || (StrEqual(botname, "s1mple")) || (StrEqual(botname, "flamie")) || (StrEqual(botname, "Boombl4")) || (StrEqual(botname, "GuardiaN")))
	{
		CS_SetClientClanTag(client, "Na´Vi");
	}
	
	//Liquid Players
	if((StrEqual(botname, "Stewie2K")) || (StrEqual(botname, "NAF")) || (StrEqual(botname, "nitr0")) || (StrEqual(botname, "ELiGE")) || (StrEqual(botname, "Twistzz")))
	{
		CS_SetClientClanTag(client, "Liquid");
	}
	
	//AGO Players
	if((StrEqual(botname, "Furlan")) || (StrEqual(botname, "GruBy")) || (StrEqual(botname, "mhL")) || (StrEqual(botname, "Sidney")) || (StrEqual(botname, "leman")))
	{
		CS_SetClientClanTag(client, "AGO");
	}
	
	//ENCE Players
	if((StrEqual(botname, "suNny")) || (StrEqual(botname, "Aerial")) || (StrEqual(botname, "allu")) || (StrEqual(botname, "sergej")) || (StrEqual(botname, "xseveN")))
	{
		CS_SetClientClanTag(client, "ENCE");
	}
	
	//Vitality Players
	if((StrEqual(botname, "shox")) || (StrEqual(botname, "ZywOo")) || (StrEqual(botname, "apEX")) || (StrEqual(botname, "RpK")) || (StrEqual(botname, "ALEX")))
	{
		CS_SetClientClanTag(client, "Vitality");
	}
	
	//BIG Players
	if((StrEqual(botname, "tiziaN")) || (StrEqual(botname, "smooya")) || (StrEqual(botname, "XANTARES")) || (StrEqual(botname, "tabseN")) || (StrEqual(botname, "nex")))
	{
		CS_SetClientClanTag(client, "BIG");
	}
	
	//AVANGAR Players
	if((StrEqual(botname, "buster")) || (StrEqual(botname, "Jame")) || (StrEqual(botname, "qikert")) || (StrEqual(botname, "AdreN")) || (StrEqual(botname, "SANJI")))
	{
		CS_SetClientClanTag(client, "AVANGAR");
	}
	
	//Windigo Players
	if((StrEqual(botname, "mirbit")) || (StrEqual(botname, "bubble")) || (StrEqual(botname, "hAdji")) || (StrEqual(botname, "Calyx")) || (StrEqual(botname, "poizon")))
	{
		CS_SetClientClanTag(client, "Windigo");
	}
	
	//FURIA Players
	if((StrEqual(botname, "yuurih")) || (StrEqual(botname, "arT")) || (StrEqual(botname, "VINI")) || (StrEqual(botname, "kscerato")) || (StrEqual(botname, "HEN1")))
	{
		CS_SetClientClanTag(client, "FURIA");
	}
	
	//CR4ZY Players
	if((StrEqual(botname, "LETN1")) || (StrEqual(botname, "ottoNd")) || (StrEqual(botname, "SHiPZ")) || (StrEqual(botname, "emi")) || (StrEqual(botname, "EspiranTo")))
	{
		CS_SetClientClanTag(client, "CR4ZY");
	}
	
	//coL Players
	if((StrEqual(botname, "dephh")) || (StrEqual(botname, "ShahZaM")) || (StrEqual(botname, "oBo")) || (StrEqual(botname, "RUSH")) || (StrEqual(botname, "blameF")))
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
	if((StrEqual(botname, "k1to")) || (StrEqual(botname, "syrsoN")) || (StrEqual(botname, "Spiidi")) || (StrEqual(botname, "faveN")) || (StrEqual(botname, "denis")))
	{
		CS_SetClientClanTag(client, "Sprout");
	}
	
	//Heroic Players
	if((StrEqual(botname, "es3tag")) || (StrEqual(botname, "b0RUP")) || (StrEqual(botname, "Snappi")) || (StrEqual(botname, "cadiaN")) || (StrEqual(botname, "stavn")))
	{
		CS_SetClientClanTag(client, "Heroic");
	}
	
	//INTZ Players
	if((StrEqual(botname, "chelo")) || (StrEqual(botname, "shz")) || (StrEqual(botname, "xand")) || (StrEqual(botname, "destinyy")) || (StrEqual(botname, "yeL")))
	{
		CS_SetClientClanTag(client, "INTZ");
	}
	
	//VP Players
	if((StrEqual(botname, "MICHU")) || (StrEqual(botname, "snatchie")) || (StrEqual(botname, "phr")) || (StrEqual(botname, "Snax")) || (StrEqual(botname, "Vegi")))
	{
		CS_SetClientClanTag(client, "VP");
	}
	
	//Apeks Players
	if((StrEqual(botname, "Marcelious")) || (StrEqual(botname, "truth")) || (StrEqual(botname, "Grusarn")) || (StrEqual(botname, "akEz")) || (StrEqual(botname, "Radifaction")))
	{
		CS_SetClientClanTag(client, "Apeks");
	}
	
	//aTTaX Players
	if((StrEqual(botname, "stfN")) || (StrEqual(botname, "slaxz")) || (StrEqual(botname, "DuDe")) || (StrEqual(botname, "kressy")) || (StrEqual(botname, "mantuu")))
	{
		CS_SetClientClanTag(client, "aTTaX");
	}
	
	//Grayhound Players
	if((StrEqual(botname, "INS")) || (StrEqual(botname, "sico")) || (StrEqual(botname, "dexter")) || (StrEqual(botname, "DickStacy")) || (StrEqual(botname, "malta")))
	{
		CS_SetClientClanTag(client, "Grayhound");
	}
	
	//MVP.PK Players
	if((StrEqual(botname, "glow")) || (StrEqual(botname, "xeta")) || (StrEqual(botname, "Rb")) || (StrEqual(botname, "k1Ng")) || (StrEqual(botname, "stax")))
	{
		CS_SetClientClanTag(client, "MVP.PK");
	}
	
	//Envy Players
	if((StrEqual(botname, "Nifty")) || (StrEqual(botname, "ryann")) || (StrEqual(botname, "s0m")) || (StrEqual(botname, "ANDROID")) || (StrEqual(botname, "FugLy")))
	{
		CS_SetClientClanTag(client, "Envy");
	}
	
	//Spirit Players
	if((StrEqual(botname, "mir")) || (StrEqual(botname, "iDISBALANCE")) || (StrEqual(botname, "somedieyoung")) || (StrEqual(botname, "chopper")) || (StrEqual(botname, "magixx")))
	{
		CS_SetClientClanTag(client, "Spirit");
	}
	
	//CeX Players
	if((StrEqual(botname, "LiamjS")) || (StrEqual(botname, "resu")) || (StrEqual(botname, "Nukeddog")) || (StrEqual(botname, "JamesBT")) || (StrEqual(botname, "Murky")))
	{
		CS_SetClientClanTag(client, "CeX");
	}
	
	//LDLC Players
	if((StrEqual(botname, "rodeN")) || (StrEqual(botname, "Happy")) || (StrEqual(botname, "MAJ3R")) || (StrEqual(botname, "xms")) || (StrEqual(botname, "SIXER")))
	{
		CS_SetClientClanTag(client, "LDLC");
	}
	
	//Defusekids Players
	if((StrEqual(botname, "v1N")) || (StrEqual(botname, "G1DO")) || (StrEqual(botname, "FASHR")) || (StrEqual(botname, "Monu")) || (StrEqual(botname, "rilax")))
	{
		CS_SetClientClanTag(client, "Defusekids");
	}
	
	//GamerLegion Players
	if((StrEqual(botname, "dennis")) || (StrEqual(botname, "nawwk")) || (StrEqual(botname, "PlesseN")) || (StrEqual(botname, "RuStY")) || (StrEqual(botname, "hampus")))
	{
		CS_SetClientClanTag(client, "GamerLegion");
	}
	
	//DIVIZON Players
	if((StrEqual(botname, "TR1P")) || (StrEqual(botname, "glaVed")) || (StrEqual(botname, "hyped")) || (StrEqual(botname, "n1kista")) || (StrEqual(botname, "MajoRR")))
	{
		CS_SetClientClanTag(client, "DIVIZON");
	}
	
	//EURONICS Players
	if((StrEqual(botname, "red")) || (StrEqual(botname, "PREET")) || (StrEqual(botname, "PerX")) || (StrEqual(botname, "Seeeya")) || (StrEqual(botname, "pdy")))
	{
		CS_SetClientClanTag(client, "EURONICS");
	}
	
	//expert Players
	if((StrEqual(botname, "Aika")) || (StrEqual(botname, "syncD")) || (StrEqual(botname, "BMLN")) || (StrEqual(botname, "HighKitty")) || (StrEqual(botname, "VENIQ")))
	{
		CS_SetClientClanTag(client, "expert");
	}
	
	//PANTHERS Players
	if((StrEqual(botname, "rUFY")) || (StrEqual(botname, "darkz")) || (StrEqual(botname, "denzel")) || (StrEqual(botname, "expo")) || (StrEqual(botname, "stowny")))
	{
		CS_SetClientClanTag(client, "PANTHERS");
	}
	
	//PDucks Players
	if((StrEqual(botname, "neviZ")) || (StrEqual(botname, "synx")) || (StrEqual(botname, "delkore")) || (StrEqual(botname, "nky")) || (StrEqual(botname, "Cargo")))
	{
		CS_SetClientClanTag(client, "PDucks");
	}
	
	//HAVU Players
	if((StrEqual(botname, "ZOREE")) || (StrEqual(botname, "sLowi")) || (StrEqual(botname, "doto")) || (StrEqual(botname, "Hoody")) || (StrEqual(botname, "sAw")))
	{
		CS_SetClientClanTag(client, "HAVU");
	}
	
	//Lyngby Players
	if((StrEqual(botname, "birdfromsky")) || (StrEqual(botname, "Twinx")) || (StrEqual(botname, "Daffu")) || (StrEqual(botname, "thamlike")) || (StrEqual(botname, "Cabbi")))
	{
		CS_SetClientClanTag(client, "Lyngby");
	}
	
	//SMASH Players
	if((StrEqual(botname, "maden")) || (StrEqual(botname, "Maikelele")) || (StrEqual(botname, "kRYSTAL")) || (StrEqual(botname, "zehN")) || (StrEqual(botname, "STYKO")))
	{
		CS_SetClientClanTag(client, "SMASH");
	}
	
	//Nordavind Players
	if((StrEqual(botname, "tenzki")) || (StrEqual(botname, "hallzerk")) || (StrEqual(botname, "RUBINO")) || (StrEqual(botname, "H4RR3")) || (StrEqual(botname, "cromen")))
	{
		CS_SetClientClanTag(client, "Nordavind");
	}
	
	//SJ Players
	if((StrEqual(botname, "arvid")) || (StrEqual(botname, "Jamppi")) || (StrEqual(botname, "SADDYX")) || (StrEqual(botname, "KHRN")) || (StrEqual(botname, "xartE")))
	{
		CS_SetClientClanTag(client, "SJ");
	}
	
	//Tricked Players
	if((StrEqual(botname, "roeJ")) || (StrEqual(botname, "acoR")) || (StrEqual(botname, "HUNDEN")) || (StrEqual(botname, "Sjuush")) || (StrEqual(botname, "Bubzkji")))
	{
		CS_SetClientClanTag(client, "Tricked");
	}
	
	//Baskonia Players
	if((StrEqual(botname, "tatin")) || (StrEqual(botname, "PabLo")) || (StrEqual(botname, "LittlesataN1")) || (StrEqual(botname, "dixon")) || (StrEqual(botname, "jJavi")))
	{
		CS_SetClientClanTag(client, "Baskonia");
	}
	
	//Giants Players
	if((StrEqual(botname, "rmn")) || (StrEqual(botname, "fox")) || (StrEqual(botname, "Cunha")) || (StrEqual(botname, "MUTiRiS")) || (StrEqual(botname, "arki")))
	{
		CS_SetClientClanTag(client, "Giants");
	}
	
	//Lions Players
	if((StrEqual(botname, "YuRk0")) || (StrEqual(botname, "Jibrix")) || (StrEqual(botname, "Kairi")) || (StrEqual(botname, "HUMANZ")) || (StrEqual(botname, "NaOw")))
	{
		CS_SetClientClanTag(client, "Lions");
	}
	
	//Riders Players
	if((StrEqual(botname, "mopoz")) || (StrEqual(botname, "EasTor")) || (StrEqual(botname, "steel")) || (StrEqual(botname, "alex*")) || (StrEqual(botname, "loWel")))
	{
		CS_SetClientClanTag(client, "Riders");
	}
	
	//OFFSET Players
	if((StrEqual(botname, "RIZZ")) || (StrEqual(botname, "obj")) || (StrEqual(botname, "JUST")) || (StrEqual(botname, "stadodo")) || (StrEqual(botname, "pr")))
	{
		CS_SetClientClanTag(client, "OFFSET");
	}
	
	//x6tence Players
	if((StrEqual(botname, "NikoM")) || (StrEqual(botname, "JonY BoY")) || (StrEqual(botname, "tomi")) || (StrEqual(botname, "OMG")) || (StrEqual(botname, "tutehen")))
	{
		CS_SetClientClanTag(client, "x6tence");
	}
	
	//eSuba Players
	if((StrEqual(botname, "HenkkyG")) || (StrEqual(botname, "ZEDKO")) || (StrEqual(botname, "SHOCK")) || (StrEqual(botname, "Blogg1s")) || (StrEqual(botname, "leckr")))
	{
		CS_SetClientClanTag(client, "eSuba");
	}
	
	//Nexus Players
	if((StrEqual(botname, "BTN")) || (StrEqual(botname, "XELLOW")) || (StrEqual(botname, "SEMINTE")) || (StrEqual(botname, "iM")) || (StrEqual(botname, "starkiller")))
	{
		CS_SetClientClanTag(client, "Nexus");
	}
	
	//PACT Players
	if((StrEqual(botname, "darko")) || (StrEqual(botname, "lunAtic")) || (StrEqual(botname, "Goofy")) || (StrEqual(botname, "Crityourface")) || (StrEqual(botname, "Sobol")))
	{
		CS_SetClientClanTag(client, "PACT");
	}
	
	//Heretics Players
	if((StrEqual(botname, "davidp")) || (StrEqual(botname, "Maka")) || (StrEqual(botname, "devoduvek")) || (StrEqual(botname, "kioShiMa")) || (StrEqual(botname, "Lucky")))
	{
		CS_SetClientClanTag(client, "Heretics");
	}
	
	//FCDB Players
	if((StrEqual(botname, "razOk")) || (StrEqual(botname, "matusik")) || (StrEqual(botname, "Ao-")) || (StrEqual(botname, "Cludi")) || (StrEqual(botname, "vrs")))
	{
		CS_SetClientClanTag(client, "FCDB");
	}
	
	//Nemiga Players
	if((StrEqual(botname, "ROBO")) || (StrEqual(botname, "hutji")) || (StrEqual(botname, "lollipop21k")) || (StrEqual(botname, "Jyo")) || (StrEqual(botname, "boX")))
	{
		CS_SetClientClanTag(client, "Nemiga");
	}
	
	//pro100 Players
	if((StrEqual(botname, "dimasick")) || (StrEqual(botname, "WorldEdit")) || (StrEqual(botname, "YEKINDAR")) || (StrEqual(botname, "wayLander")) || (StrEqual(botname, "NickelBack")))
	{
		CS_SetClientClanTag(client, "pro100");
	}
	
	//eUnited Players
	if((StrEqual(botname, "freakazoid")) || (StrEqual(botname, "Cooper-")) || (StrEqual(botname, "MarKE")) || (StrEqual(botname, "food")) || (StrEqual(botname, "vanity")))
	{
		CS_SetClientClanTag(client, "eUnited");
	}
	
	//Mythic Players
	if((StrEqual(botname, "C0M")) || (StrEqual(botname, "fl0m")) || (StrEqual(botname, "Katie")) || (StrEqual(botname, "hazed")) || (StrEqual(botname, "SileNt")))
	{
		CS_SetClientClanTag(client, "Mythic");
	}
	
	//Singularity Players
	if((StrEqual(botname, "wrath")) || (StrEqual(botname, "Relyks")) || (StrEqual(botname, "seb")) || (StrEqual(botname, "dazzLe")) || (StrEqual(botname, "dapr")))
	{
		CS_SetClientClanTag(client, "Singularity");
	}
	
	//DETONA Players
	if((StrEqual(botname, "prt")) || (StrEqual(botname, "tiburci0")) || (StrEqual(botname, "v$m")) || (StrEqual(botname, "Lucaozy")) || (StrEqual(botname, "Tuurtle")))
	{
		CS_SetClientClanTag(client, "DETONA");
	}
	
	//Infinity Players
	if((StrEqual(botname, "cruzN")) || (StrEqual(botname, "malbsMd")) || (StrEqual(botname, "spamzzy")) || (StrEqual(botname, "sam_A")) || (StrEqual(botname, "Daveys")))
	{
		CS_SetClientClanTag(client, "Infinity");
	}
	
	//Isurus Players
	if((StrEqual(botname, "1962")) || (StrEqual(botname, "Noktse")) || (StrEqual(botname, "Reversive")) || (StrEqual(botname, "nbl")) || (StrEqual(botname, "maxujas")))
	{
		CS_SetClientClanTag(client, "Isurus");
	}
	
	//paiN Players
	if((StrEqual(botname, "PKL")) || (StrEqual(botname, "land1n")) || (StrEqual(botname, "tatazin")) || (StrEqual(botname, "biguzera")) || (StrEqual(botname, "hardzao")))
	{
		CS_SetClientClanTag(client, "paiN");
	}
	
	//Sharks Players
	if((StrEqual(botname, "meyern")) || (StrEqual(botname, "jnt")) || (StrEqual(botname, "leo_drunky")) || (StrEqual(botname, "exit")) || (StrEqual(botname, "Luken")))
	{
		CS_SetClientClanTag(client, "Sharks");
	}
	
	//One Players
	if((StrEqual(botname, "bld V")) || (StrEqual(botname, "Maluk3")) || (StrEqual(botname, "trk")) || (StrEqual(botname, "bit")) || (StrEqual(botname, "b4rtiN")))
	{
		CS_SetClientClanTag(client, "One");
	}
	
	//W7M Players
	if((StrEqual(botname, "skullz")) || (StrEqual(botname, "raafa")) || (StrEqual(botname, "ryotzz")) || (StrEqual(botname, "pancc")) || (StrEqual(botname, "realziN")))
	{
		CS_SetClientClanTag(client, "W7M");
	}
	
	//Avant Players
	if((StrEqual(botname, "soju_j")) || (StrEqual(botname, "sterling")) || (StrEqual(botname, "apoc")) || (StrEqual(botname, "J1rah")) || (StrEqual(botname, "HaZR")))
	{
		CS_SetClientClanTag(client, "Avant");
	}
	
	//Chiefs Players
	if((StrEqual(botname, "tucks")) || (StrEqual(botname, "BL1TZ")) || (StrEqual(botname, "Texta")) || (StrEqual(botname, "ofnu")) || (StrEqual(botname, "zewsy")))
	{
		CS_SetClientClanTag(client, "Chiefs");
	}
	
	//LEISURE Players
	if((StrEqual(botname, "padow")) || (StrEqual(botname, "amigo")) || (StrEqual(botname, "fly")) || (StrEqual(botname, "cHap")) || (StrEqual(botname, "Rand")))
	{
		CS_SetClientClanTag(client, "LEISURE");
	}
	
	//ORDER Players
	if((StrEqual(botname, "emagine")) || (StrEqual(botname, "aliStair")) || (StrEqual(botname, "hatz")) || (StrEqual(botname, "USTILO")) || (StrEqual(botname, "Valiance")))
	{
		CS_SetClientClanTag(client, "ORDER");
	}
	
	//BlackS Players
	if((StrEqual(botname, "hue9ze")) || (StrEqual(botname, "addict")) || (StrEqual(botname, "cookie")) || (StrEqual(botname, "jeepy")) || (StrEqual(botname, "Wolfah")))
	{
		CS_SetClientClanTag(client, "BlackS");
	}
	
	//eXtatus Players
	if((StrEqual(botname, "luko")) || (StrEqual(botname, "wEAMO")) || (StrEqual(botname, "desty")) || (StrEqual(botname, "Fraged")) || (StrEqual(botname, "Pechyn")))
	{
		CS_SetClientClanTag(client, "eXtatus");
	}
	
	//SYF Players
	if((StrEqual(botname, "ino")) || (StrEqual(botname, "Teal")) || (StrEqual(botname, "ekul")) || (StrEqual(botname, "bedonka")) || (StrEqual(botname, "urbz")))
	{
		CS_SetClientClanTag(client, "SYF");
	}
	
	//5Power Players
	if((StrEqual(botname, "bottle")) || (StrEqual(botname, "Savage")) || (StrEqual(botname, "xiaosaGe")) || (StrEqual(botname, "shuadapai")) || (StrEqual(botname, "Viva")))
	{
		CS_SetClientClanTag(client, "5Power");
	}
	
	//EHOME Players
	if((StrEqual(botname, "insane")) || (StrEqual(botname, "originalheart")) || (StrEqual(botname, "Marek")) || (StrEqual(botname, "SLOWLY")) || (StrEqual(botname, "4king")))
	{
		CS_SetClientClanTag(client, "EHOME");
	}
	
	//ALPHA Red Players
	if((StrEqual(botname, "MAIROLLS")) || (StrEqual(botname, "Olivia")) || (StrEqual(botname, "Kntz")) || (StrEqual(botname, "SeveN89")) || (StrEqual(botname, "foxz")))
	{
		CS_SetClientClanTag(client, "ALPHA Red");
	}
	
	//dream[S]cape Players
	if((StrEqual(botname, "Bobosaur")) || (StrEqual(botname, "splashske")) || (StrEqual(botname, "alecks")) || (StrEqual(botname, "Benkai")) || (StrEqual(botname, "d4v41")))
	{
		CS_SetClientClanTag(client, "dream[S]cape");
	}
	
	//Beyond Players
	if((StrEqual(botname, "TOR")) || (StrEqual(botname, "bnwGiggs")) || (StrEqual(botname, "RoLEX")) || (StrEqual(botname, "veta")) || (StrEqual(botname, "Geniuss")))
	{
		CS_SetClientClanTag(client, "Beyond");
	}
	
	//Entity Players
	if((StrEqual(botname, "Amaterasu")) || (StrEqual(botname, "Psy")) || (StrEqual(botname, "Excali")) || (StrEqual(botname, "skillZ")) || (StrEqual(botname, "SnrLx")))
	{
		CS_SetClientClanTag(client, "Entity");
	}
	
	//FrostFire Players
	if((StrEqual(botname, "aimaNNN")) || (StrEqual(botname, "hiqa1")) || (StrEqual(botname, "acAp")) || (StrEqual(botname, "Subbey")) || (StrEqual(botname, "Avirity")))
	{
		CS_SetClientClanTag(client, "FrostFire");
	}
	
	//LucidDream Players
	if((StrEqual(botname, "wannafly")) || (StrEqual(botname, "PTC")) || (StrEqual(botname, "cbbk")) || (StrEqual(botname, "JohnOlsen")) || (StrEqual(botname, "qqGod")))
	{
		CS_SetClientClanTag(client, "LucidDream");
	}
	
	//NASR Players
	if((StrEqual(botname, "breAker")) || (StrEqual(botname, "Nami")) || (StrEqual(botname, "kitkat")) || (StrEqual(botname, "havoK")) || (StrEqual(botname, "kAzoo")))
	{
		CS_SetClientClanTag(client, "NASR");
	}
	
	//Portal Players
	if((StrEqual(botname, "traNz")) || (StrEqual(botname, "Ttyke")) || (StrEqual(botname, "DVDOV")) || (StrEqual(botname, "PokemoN")) || (StrEqual(botname, "Ebeee")))
	{
		CS_SetClientClanTag(client, "Portal");
	}
	
	//Brutals Players
	if((StrEqual(botname, "V3nom")) || (StrEqual(botname, "RiX")) || (StrEqual(botname, "Juventa")) || (StrEqual(botname, "astaRR")) || (StrEqual(botname, "Fox")))
	{
		CS_SetClientClanTag(client, "Brutals");
	}
	
	//iNvictus Players
	if((StrEqual(botname, "ribbiZ")) || (StrEqual(botname, "Manan")) || (StrEqual(botname, "Pashasahil")) || (StrEqual(botname, "BinaryBUG")) || (StrEqual(botname, "blackhawk")))
	{
		CS_SetClientClanTag(client, "iNvictus");
	}
	
	//nxl Players
	if((StrEqual(botname, "soifong")) || (StrEqual(botname, "RamCikiciew")) || (StrEqual(botname, "Qbo")) || (StrEqual(botname, "Vask0")) || (StrEqual(botname, "smoof")))
	{
		CS_SetClientClanTag(client, "nxl");
	}
	
	//ATK Players
	if((StrEqual(botname, "motm")) || (StrEqual(botname, "oSee")) || (StrEqual(botname, "JT")) || (StrEqual(botname, "floppy")) || (StrEqual(botname, "Sonic")))
	{
		CS_SetClientClanTag(client, "ATK");
	}
	
	//Energy Players
	if((StrEqual(botname, "TheM4N")) || (StrEqual(botname, "Dweezil")) || (StrEqual(botname, "kaNibalistic")) || (StrEqual(botname, "adM")) || (StrEqual(botname, "bLazE")))
	{
		CS_SetClientClanTag(client, "Energy");
	}
	
	//BLUEJAYS Players
	if((StrEqual(botname, "dEE")) || (StrEqual(botname, "DiMKE")) || (StrEqual(botname, "aVN")) || (StrEqual(botname, "sarenii")) || (StrEqual(botname, "c0llins")))
	{
		CS_SetClientClanTag(client, "BLUEJAYS");
	}
	
	//EXECUTIONERS Players
	if((StrEqual(botname, "ZesBeeW")) || (StrEqual(botname, "FamouZ")) || (StrEqual(botname, "maestro")) || (StrEqual(botname, "Snyder")) || (StrEqual(botname, "Sys")))
	{
		CS_SetClientClanTag(client, "EXECUTIONERS");
	}
	
	//Vexed Players
	if((StrEqual(botname, "mezii")) || (StrEqual(botname, "Kray")) || (StrEqual(botname, "Adam9130")) || (StrEqual(botname, "L1NK")) || (StrEqual(botname, "ec1s")))
	{
		CS_SetClientClanTag(client, "Vexed");
	}
	
	//GroundZero Players
	if((StrEqual(botname, "BURNRUOk")) || (StrEqual(botname, "void")) || (StrEqual(botname, "zemp")) || (StrEqual(botname, "zeph")) || (StrEqual(botname, "pan1K")))
	{
		CS_SetClientClanTag(client, "GroundZero");
	}
	
	//Aristocracy Players
	if((StrEqual(botname, "mouz")) || (StrEqual(botname, "rallen")) || (StrEqual(botname, "TaZ")) || (StrEqual(botname, "MINISE")) || (StrEqual(botname, "dycha")))
	{
		CS_SetClientClanTag(client, "Aristocracy");
	}
	
	//BTRG Players
	if((StrEqual(botname, "Eeyore")) || (StrEqual(botname, "Drea3er")) || (StrEqual(botname, "xccurate")) || (StrEqual(botname, "ImpressioN")) || (StrEqual(botname, "adrnkiNg")))
	{
		CS_SetClientClanTag(client, "BTRG");
	}
	
	//Keyd Players
	if((StrEqual(botname, "SHOOWTiME")) || (StrEqual(botname, "zqk")) || (StrEqual(botname, "dzt")) || (StrEqual(botname, "f4stzin")) || (StrEqual(botname, "KILLDREAM")))
	{
		CS_SetClientClanTag(client, "Keyd");
	}
	
	//Furious Players
	if((StrEqual(botname, "laser")) || (StrEqual(botname, "iKrystal")) || (StrEqual(botname, "PREDI")) || (StrEqual(botname, "TISAN")) || (StrEqual(botname, "dinamo")))
	{
		CS_SetClientClanTag(client, "Furious");
	}
	
	//GTZ Players
	if((StrEqual(botname, "emp")) || (StrEqual(botname, "MISK")) || (StrEqual(botname, "CarboN")) || (StrEqual(botname, "Kustom")) || (StrEqual(botname, "shellzy")))
	{
		CS_SetClientClanTag(client, "GTZ");
	}
	
	//Flames Players
	if((StrEqual(botname, "TeSeS")) || (StrEqual(botname, "farlig")) || (StrEqual(botname, "AcilioN")) || (StrEqual(botname, "TMB")) || (StrEqual(botname, "Nodios")))
	{
		CS_SetClientClanTag(client, "Flames");
	}
	
	//eu4ia Players
	if((StrEqual(botname, "kek0")) || (StrEqual(botname, "MasterdaN")) || (StrEqual(botname, "diNk")) || (StrEqual(botname, "Vinice")) || (StrEqual(botname, "sh0wz")))
	{
		CS_SetClientClanTag(client, "eu4ia");
	}
	
	//Fierce Players
	if((StrEqual(botname, "Astroo")) || (StrEqual(botname, "Impulse")) || (StrEqual(botname, "frei")) || (StrEqual(botname, "k1Ng0r")) || (StrEqual(botname, "ardiis")))
	{
		CS_SetClientClanTag(client, "Fierce");
	}
	
	//Trident Players
	if((StrEqual(botname, "TEX")) || (StrEqual(botname, "zorboT")) || (StrEqual(botname, "Rackem")) || (StrEqual(botname, "jhd")) || (StrEqual(botname, "jtr")))
	{
		CS_SetClientClanTag(client, "Trident");
	}
	
	//Syman Players
	if((StrEqual(botname, "neaLaN")) || (StrEqual(botname, "Ramz1k")) || (StrEqual(botname, "n0rb3r7")) || (StrEqual(botname, "Perfecto")) || (StrEqual(botname, "Keoz")))
	{
		CS_SetClientClanTag(client, "Syman");
	}
	
	//wNv Players
	if((StrEqual(botname, "k4Mi")) || (StrEqual(botname, "zWin")) || (StrEqual(botname, "Pure")) || (StrEqual(botname, "FairyRae")) || (StrEqual(botname, "kZy")))
	{
		CS_SetClientClanTag(client, "wNv");
	}
	
	//Goliath Players
	if((StrEqual(botname, "massacRe")) || (StrEqual(botname, "Detrony")) || (StrEqual(botname, "deviaNt")) || (StrEqual(botname, "adaro")) || (StrEqual(botname, "ZipZip")))
	{
		CS_SetClientClanTag(client, "Goliath");
	}
	
	//Endpoint Players
	if((StrEqual(botname, "jenko")) || (StrEqual(botname, "Russ")) || (StrEqual(botname, "robiin")) || (StrEqual(botname, "Puls3")) || (StrEqual(botname, "Kryptix")))
	{
		CS_SetClientClanTag(client, "Endpoint");
	}
	
	//Genuine Players
	if((StrEqual(botname, "stat")) || (StrEqual(botname, "Jinxx")) || (StrEqual(botname, "apocdud")) || (StrEqual(botname, "SkulL")) || (StrEqual(botname, "Mayker")))
	{
		CS_SetClientClanTag(client, "Genuine");
	}
	
	//MiTH Players
	if((StrEqual(botname, "NIFFY")) || (StrEqual(botname, "Leaf")) || (StrEqual(botname, "JUSTCAUSE")) || (StrEqual(botname, "Reality")) || (StrEqual(botname, "PPOverdose")))
	{
		CS_SetClientClanTag(client, "MiTH");
	}
	
	//UOL Players
	if((StrEqual(botname, "crisby")) || (StrEqual(botname, "kzy")) || (StrEqual(botname, "Andyy")) || (StrEqual(botname, "JDC")) || (StrEqual(botname, "OKOLICIOUZ")))
	{
		CS_SetClientClanTag(client, "UOL");
	}
	
	//9INE Players
	if((StrEqual(botname, "PALM1")) || (StrEqual(botname, "phzy")) || (StrEqual(botname, "Djury")) || (StrEqual(botname, "aybeN")) || (StrEqual(botname, "MistFire")))
	{
		CS_SetClientClanTag(client, "9INE");
	}
	
	//Baecon Players
	if((StrEqual(botname, "brA")) || (StrEqual(botname, "Demonos")) || (StrEqual(botname, "SHOUW")) || (StrEqual(botname, "sark")) || (StrEqual(botname, "axoN")))
	{
		CS_SetClientClanTag(client, "Baecon");
	}
	
	//Corvidae Players
	if((StrEqual(botname, "DANZ")) || (StrEqual(botname, "dash")) || (StrEqual(botname, "m1tch")) || (StrEqual(botname, "nibke")) || (StrEqual(botname, "Dirty")))
	{
		CS_SetClientClanTag(client, "Corvidae");
	}
	
	//Wizards Players
	if((StrEqual(botname, "KALAS")) || (StrEqual(botname, "v1NCHENSO7")) || (StrEqual(botname, "Kiles")) || (StrEqual(botname, "Fit1nho")) || (StrEqual(botname, "Ryd3r-")))
	{
		CS_SetClientClanTag(client, "Wizards");
	}
	
	//Illuminar Players
	if((StrEqual(botname, "oskarish")) || (StrEqual(botname, "STOMP")) || (StrEqual(botname, "mono")) || (StrEqual(botname, "innocent")) || (StrEqual(botname, "reatz")))
	{
		CS_SetClientClanTag(client, "Illuminar");
	}
	
	//Queso Players
	if((StrEqual(botname, "TheClaran")) || (StrEqual(botname, "rAmbi")) || (StrEqual(botname, "VARES")) || (StrEqual(botname, "mik")) || (StrEqual(botname, "Yaba")))
	{
		CS_SetClientClanTag(client, "Queso");
	}
	
	//W&R Players
	if((StrEqual(botname, "Swaggy")) || (StrEqual(botname, "TotunG")) || (StrEqual(botname, "Ping")) || (StrEqual(botname, "Br0die")) || (StrEqual(botname, "angry")))
	{
		CS_SetClientClanTag(client, "W&R");
	}
	
	//GameAgents Players
	if((StrEqual(botname, "pounh")) || (StrEqual(botname, "FliP1")) || (StrEqual(botname, "COSMEEEN")) || (StrEqual(botname, "kalle")) || (StrEqual(botname, "shadow")))
	{
		CS_SetClientClanTag(client, "GameAgents");
	}
	
	//Orange Players
	if((StrEqual(botname, "Max")) || (StrEqual(botname, "cara")) || (StrEqual(botname, "formlesS")) || (StrEqual(botname, "Raph")) || (StrEqual(botname, "risk")))
	{
		CS_SetClientClanTag(client, "Orange");
	}
	
	//IG Players
	if((StrEqual(botname, "EXPRO")) || (StrEqual(botname, "V4D1M")) || (StrEqual(botname, "flying")) || (StrEqual(botname, "equal")) || (StrEqual(botname, "Koshak")))
	{
		CS_SetClientClanTag(client, "IG");
	}
	
	//HR Players
	if((StrEqual(botname, "ANGE1")) || (StrEqual(botname, "nukkye")) || (StrEqual(botname, "Flarich")) || (StrEqual(botname, "crush")) || (StrEqual(botname, "scoobyxie")))
	{
		CS_SetClientClanTag(client, "HR");
	}
	
	//Dice Players
	if((StrEqual(botname, "XpG")) || (StrEqual(botname, "nonick")) || (StrEqual(botname, "Kan4")) || (StrEqual(botname, "Polox")) || (StrEqual(botname, "DEVIL")))
	{
		CS_SetClientClanTag(client, "Dice");
	}
	
	//Absolute Players
	if((StrEqual(botname, "Laz")) || (StrEqual(botname, "crow")) || (StrEqual(botname, "barce")) || (StrEqual(botname, "takej")) || (StrEqual(botname, "Reita")))
	{
		CS_SetClientClanTag(client, "Absolute");
	}
	
	//KPI Players
	if((StrEqual(botname, "xikii")) || (StrEqual(botname, "SunPayus")) || (StrEqual(botname, "meisoN")) || (StrEqual(botname, "donQ")) || (StrEqual(botname, "MackDaddy")))
	{
		CS_SetClientClanTag(client, "KPI");
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
	
	if (StrEqual(sClan, "TyLoo"))
	{
		g_iProfileRank[client] = 50;
	}
	
	if (StrEqual(sClan, "EG"))
	{
		g_iProfileRank[client] = 51;
	}
	
	if (StrEqual(sClan, "RNG"))
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
	
	if (StrEqual(sClan, "AVANGAR"))
	{
		g_iProfileRank[client] = 59;
	}
	
	if (StrEqual(sClan, "Windigo"))
	{
		g_iProfileRank[client] = 60;
	}
	
	if (StrEqual(sClan, "FURIA"))
	{
		g_iProfileRank[client] = 61;
	}
	
	if (StrEqual(sClan, "CR4ZY"))
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
	
	if (StrEqual(sClan, "Grayhound"))
	{
		g_iProfileRank[client] = 73;
	}
	
	if (StrEqual(sClan, "MVP.PK"))
	{
		g_iProfileRank[client] = 74;
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
	
	if (StrEqual(sClan, "Defusekids"))
	{
		g_iProfileRank[client] = 79;
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
	
	if (StrEqual(sClan, "expert"))
	{
		g_iProfileRank[client] = 83;
	}
	
	if (StrEqual(sClan, "PANTHERS"))
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
	
	if (StrEqual(sClan, "SMASH"))
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
	
	if (StrEqual(sClan, "Tricked"))
	{
		g_iProfileRank[client] = 91;
	}
	
	if (StrEqual(sClan, "Baskonia"))
	{
		g_iProfileRank[client] = 92;
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
	
	if (StrEqual(sClan, "FCDB"))
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
	
	if (StrEqual(sClan, "eUnited"))
	{
		g_iProfileRank[client] = 105;
	}
	
	if (StrEqual(sClan, "Mythic"))
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
	
	if (StrEqual(sClan, "LEISURE"))
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
	
	if (StrEqual(sClan, "eXtatus"))
	{
		g_iProfileRank[client] = 120;
	}
	
	if (StrEqual(sClan, "SYF"))
	{
		g_iProfileRank[client] = 121;
	}
	
	if (StrEqual(sClan, "5Power"))
	{
		g_iProfileRank[client] = 122;
	}
	
	if (StrEqual(sClan, "EHOME"))
	{
		g_iProfileRank[client] = 123;
	}
	
	if (StrEqual(sClan, "ALPHA Red"))
	{
		g_iProfileRank[client] = 124;
	}
	
	if (StrEqual(sClan, "dream[S]cape"))
	{
		g_iProfileRank[client] = 125;
	}
	
	if (StrEqual(sClan, "Beyond"))
	{
		g_iProfileRank[client] = 126;
	}
	
	if (StrEqual(sClan, "Entity"))
	{
		g_iProfileRank[client] = 127;
	}
	
	if (StrEqual(sClan, "FrostFire"))
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
	
	if (StrEqual(sClan, "Portal"))
	{
		g_iProfileRank[client] = 131;
	}
	
	if (StrEqual(sClan, "Brutals"))
	{
		g_iProfileRank[client] = 132;
	}
	
	if (StrEqual(sClan, "iNvictus"))
	{
		g_iProfileRank[client] = 133;
	}
	
	if (StrEqual(sClan, "nxl"))
	{
		g_iProfileRank[client] = 134;
	}
	
	if (StrEqual(sClan, "ATK"))
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
	
	if (StrEqual(sClan, "Vexed"))
	{
		g_iProfileRank[client] = 139;
	}
	
	if (StrEqual(sClan, "GroundZero"))
	{
		g_iProfileRank[client] = 140;
	}
	
	if (StrEqual(sClan, "Aristocracy"))
	{
		g_iProfileRank[client] = 141;
	}
	
	if (StrEqual(sClan, "BTRG"))
	{
		g_iProfileRank[client] = 142;
	}
	
	if (StrEqual(sClan, "Keyd"))
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
	
	if (StrEqual(sClan, "eu4ia"))
	{
		g_iProfileRank[client] = 147;
	}
	
	if (StrEqual(sClan, "Fierce"))
	{
		g_iProfileRank[client] = 148;
	}
	
	if (StrEqual(sClan, "Trident"))
	{
		g_iProfileRank[client] = 149;
	}
	
	if (StrEqual(sClan, "Syman"))
	{
		g_iProfileRank[client] = 150;
	}
	
	if (StrEqual(sClan, "wNv"))
	{
		g_iProfileRank[client] = 151;
	}
	
	if (StrEqual(sClan, "Goliath"))
	{
		g_iProfileRank[client] = 152;
	}
	
	if (StrEqual(sClan, "Endpoint"))
	{
		g_iProfileRank[client] = 153;
	}
	
	if (StrEqual(sClan, "Genuine"))
	{
		g_iProfileRank[client] = 154;
	}
	
	if (StrEqual(sClan, "MiTH"))
	{
		g_iProfileRank[client] = 155;
	}
	
	if (StrEqual(sClan, "UOL"))
	{
		g_iProfileRank[client] = 156;
	}
	
	if (StrEqual(sClan, "9INE"))
	{
		g_iProfileRank[client] = 157;
	}
	
	if (StrEqual(sClan, "Baecon"))
	{
		g_iProfileRank[client] = 158;
	}
	
	if (StrEqual(sClan, "Corvidae"))
	{
		g_iProfileRank[client] = 159;
	}
	
	if (StrEqual(sClan, "Wizards"))
	{
		g_iProfileRank[client] = 160;
	}
	
	if (StrEqual(sClan, "Illuminar"))
	{
		g_iProfileRank[client] = 161;
	}
	
	if (StrEqual(sClan, "Queso"))
	{
		g_iProfileRank[client] = 162;
	}
	
	if (StrEqual(sClan, "W&R"))
	{
		g_iProfileRank[client] = 163;
	}
	
	if (StrEqual(sClan, "GameAgents"))
	{
		g_iProfileRank[client] = 164;
	}
	
	if (StrEqual(sClan, "Orange"))
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
	
	if (StrEqual(sClan, "Absolute"))
	{
		g_iProfileRank[client] = 169;
	}
	
	if (StrEqual(sClan, "KPI"))
	{
		g_iProfileRank[client] = 170;
	}
}