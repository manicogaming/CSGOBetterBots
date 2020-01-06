#pragma semicolon 1

#include <sourcemod>
#include <clientprefs>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>

bool g_bShouldAttack[MAXPLAYERS + 1];
bool g_bFlashed[MAXPLAYERS + 1] = false;
Handle g_hShouldAttackTimer[MAXPLAYERS + 1];
int g_iaGrenadeOffsets[] = {15, 17, 16, 14, 18, 17};
int g_iProfileRank[MAXPLAYERS+1], g_iCoin[MAXPLAYERS+1], g_iProfileRankOffset, g_iCoinOffset;
ConVar g_cvPredictionConVars[1] = {null};

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

char CTModels[][] = {
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

char TModels[][] = {
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

char g_BotName[][] = {
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
	//TYLOO Players
	"Summer",
	"Attacker",
	"BnTneT",
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
	"k1to",
	//Rejected Players
	"fara",
	"L!nKz^",
	"LEEROY",
	"FiReMaNNN",
	"akz",
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
	"oskar",
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
	"boltz",
	"yeL",
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
	"Radifaction",
	//aTTaX Players
	"stfN",
	"slaxz",
	"DuDe",
	"kressy",
	"enkay J",
	//RNG Players
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
	"MT",
	"Impact",
	"Nukeddog",
	"CYPHER",
	"Murky",
	//LDLC Players
	"rodeN",
	"Happy",
	"MAJ3R",
	"Ozstrik3r",
	"SIXER",
	//Defusekids Player
	"v1N",
	"G1DO",
	"FASHR",
	"D0cC",
	"rilax",
	//GamerLegion Players
	"dennis",
	"nawwk",
	"freddieb",
	"RuStY",
	"hampus",
	//DIVIZON Players
	"slunixx",
	"eleKz",
	"hyped",
	"n1kista",
	"ykyli",
	//EURONICS Players
	"red",
	"pdy",
	"PerX",
	"Seeeya",
	"maRky",
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
	"pony",
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
	//GODSENT Players
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
	"STOVVE",
	"SADDYX",
	"KHRN",
	"xartE",
	//Bren Players
	"Papichulo",
	"witz",
	"Pro.",
	"BORKUM",
	"Derek",
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
	"HUNDEN",
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
	"RIZZ",
	"obj",
	"zlynx",
	"ZELIN",
	"kst",
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
	"jeyN",
	"Maka",
	"xms",
	"kioShiMa",
	"Lucky",
	//Nemiga Players
	"spellfull",
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
	//eUnited Players
	"freakazoid",
	"Cooper-",
	"MarKE",
	"food",
	"moose",
	//Mythic Players
	"C0M",
	"fl0m",
	"Katie",
	"hazed",
	"SileNt",
	//Singularity Players
	"Zellsis",
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
	"decov9jse",
	"maxujas",
	//paiN Players
	"PKL",
	"land1n",
	"NEKIZ",
	"biguzera",
	"hardzao",
	//Sharks Players
	"RCF",
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
	//SKADE Players
	"Rock1nG",
	"dennyslaw",
	"rafftu",
	"Rainwaker",
	"SPELLAN",
	//SYF Players
	"ino",
	"Teal",
	"ekul",
	"bedonka",
	"urbz",
	//RisingStars Players
	"bottle",
	"HZ",
	"xiaosaGe",
	"shuadapai",
	"Viva",
	//EHOME Players
	"equal",
	"DeStRoYeR",
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
	"Ace",
	//LucidDream Players
	"wannafly",
	"PTC",
	"cbbk",
	"JohnOlsen",
	"Akino",
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
	"Tio",
	//BLUEJAYS Players
	"maxz",
	"Tsubasa",
	"jansen",
	"RykuN",
	"skillmaschine JJ_-",
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
	//AVEZ Players
	"MOLSI",
	"hades",
	"KEi",
	"Kylar",
	"nawrot",
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
	"k0mpa",
	"StepA",
	"slaxx",
	"Jaepe",
	"rafaxF",
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
	"jenko",
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
	"mango",
	"deviaNt",
	"adaro",
	"ZipZip",
	//Secret Players
	"juanflatroo",
	"tudsoN",
	"rigoN",
	"sinnopsyy",
	"anarkez",
	//Incept Players
	"flaw",
	"jtr",
	"nettik",
	"DannyG",
	"vanilla",
	//MiTH Players
	"NIFFY",
	"Leaf",
	"JUSTCAUSE",
	"Reality",
	"PPOverdose",
	//UOL Players
	"crisby",
	"kZyJL",
	"Andyy",
	"JDC",
	".P4TriCK",
	//9INE Players
	"ACM",
	"phzy",
	"Djury",
	"aybeN",
	"MistFire",
	//Baecon Players
	"brA",
	"Demonos",
	"SHOUW",
	"horvy",
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
	//GameAgents Players
	"pounh",
	"FliP1",
	"COSMEEEN",
	"kalle",
	"PALM1",
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
	"sPiNacH",
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
	"MackDaddy",
	//PlanetKey Players
	"xenn",
	"s1n",
	"boostey",
	"Kirby",
	"Krimbo",
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
	"Kap3r",
	"SZPERO",
	"mynio",
	"morelz",
	"jedqr",
	//Imperial Players
	"KHTEX",
	"dumau",
	"tatazin",
	"delboNi",
	"iDk",
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
	"Polt",
	"fenvicious",
	//Izako Players
	"Patitek",
	"Hyper",
	"EXUS",
	"Luz",
	"TOAO",
	//Riot Players
	"mitch",
	"ptr",
	"crashies",
	"FNS",
	"Jonji",
	//Chaos Players
	"cam",
	"wippie",
	"Infinite",
	"steel_",
	"ben1337",
	//OneThree Players
	"Dosia",
	"mou",
	"captainMo",
	"DD",
	"Karsa",
	//Lynn Players
	"XG",
	"mitsuha",
	"Aree",
	"Yvonne",
	"XinKoiNg",
	//Triumph Players
	"xCeeD",
	"Voltage",
	"Spongey",
	"Snakes",
	"Grim",
	//FATE Players
	"doublemagic",
	"KalubeR",
	"Duplicate",
	"Mar",
	"niki1",
	//Canids Players
	"pesadelo",
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
	//LiViD Players
	"huynh",
	"MkaeL",
	"INCRED",
	"gMd",
	"effys"
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
	HookEventEx("player_blind", Event_PlayerBlind, EventHookMode_Pre);
	
	g_cvPredictionConVars[0] = FindConVar("weapon_recoil_scale");
	
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
	RegConsoleCmd("team_rejected", Team_Rejected);
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
	RegConsoleCmd("team_rng", Team_Renegades);
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
	RegConsoleCmd("team_godsent", Team_GODSENT);
	RegConsoleCmd("team_nordavind", Team_Nordavind);
	RegConsoleCmd("team_sj", Team_SJ);
	RegConsoleCmd("team_bren", Team_Bren);
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
	RegConsoleCmd("team_order", Team_ORDER);
	RegConsoleCmd("team_blacks", Team_BlackS);
	RegConsoleCmd("team_skade", Team_SKADE);
	RegConsoleCmd("team_syf", Team_SYF);
	RegConsoleCmd("team_risingstars", Team_RisingStars);
	RegConsoleCmd("team_ehome", Team_EHOME);
	RegConsoleCmd("team_alpha", Team_ALPHA);
	RegConsoleCmd("team_dreamscape", Team_dreamScape);
	RegConsoleCmd("team_beyond", Team_Beyond);
	RegConsoleCmd("team_entity", Team_Entity);
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
	RegConsoleCmd("team_avez", Team_AVEZ);
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
	RegConsoleCmd("team_secret", Team_Secret);
	RegConsoleCmd("team_incept", Team_Incept);
	RegConsoleCmd("team_mith", Team_MiTH);
	RegConsoleCmd("team_uol", Team_UOL);
	RegConsoleCmd("team_9ine", Team_9INE);
	RegConsoleCmd("team_baecon", Team_Baecon);
	RegConsoleCmd("team_corvidae", Team_Corvidae);
	RegConsoleCmd("team_wizards", Team_Wizards);
	RegConsoleCmd("team_illuminar", Team_Illuminar);
	RegConsoleCmd("team_queso", Team_Queso);
	RegConsoleCmd("team_gameagents", Team_GameAgents);
	RegConsoleCmd("team_orange", Team_Orange);
	RegConsoleCmd("team_ig", Team_IG);
	RegConsoleCmd("team_hr", Team_HR);
	RegConsoleCmd("team_dice", Team_Dice);
	RegConsoleCmd("team_absolute", Team_Absolute);
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
	RegConsoleCmd("team_riot", Team_Riot);
	RegConsoleCmd("team_chaos", Team_Chaos);
	RegConsoleCmd("team_onethree", Team_OneThree);
	RegConsoleCmd("team_lynn", Team_Lynn);
	RegConsoleCmd("team_triumph", Team_Triumph);
	RegConsoleCmd("team_fate", Team_FATE);
	RegConsoleCmd("team_canids", Team_Canids);
	RegConsoleCmd("team_espada", Team_ESPADA);
	RegConsoleCmd("team_og", Team_OG);
	RegConsoleCmd("team_livid", Team_LiViD);
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
		ServerCommand("bot_add_ct %s", "f0rest");
		ServerCommand("bot_add_ct %s", "Plopski");
		ServerCommand("bot_add_ct %s", "REZ");
		ServerCommand("mp_teamlogo_1 nip");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_add_ct %s", "autimatic");
		ServerCommand("bot_add_ct %s", "mixwell");
		ServerCommand("bot_add_ct %s", "daps");
		ServerCommand("bot_add_ct %s", "koosta");
		ServerCommand("bot_add_ct %s", "Subroza");
		ServerCommand("mp_teamlogo_1 c9");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("mp_teamlogo_1 fntc");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "JUGi");
		ServerCommand("bot_add_ct %s", "Kjaerbye");
		ServerCommand("bot_add_ct %s", "aizy");
		ServerCommand("bot_add_ct %s", "cajunb");
		ServerCommand("bot_add_ct %s", "gade");
		ServerCommand("mp_teamlogo_1 nor");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_add_ct %s", "BnTneT");
		ServerCommand("bot_add_ct %s", "somebody");
		ServerCommand("bot_add_ct %s", "Freeman");
		ServerCommand("mp_teamlogo_1 tyl");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_add_ct %s", "GuardiaN");
		ServerCommand("mp_teamlogo_1 navi");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_add_ct %s", "Sidney");
		ServerCommand("bot_add_ct %s", "leman");
		ServerCommand("mp_teamlogo_1 ago");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_add_ct %s", "ALEX");
		ServerCommand("mp_teamlogo_1 vita");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "tiziaN");
		ServerCommand("bot_add_ct %s", "smooya");
		ServerCommand("bot_add_ct %s", "XANTARES");
		ServerCommand("bot_add_ct %s", "tabseN");
		ServerCommand("bot_add_ct %s", "k1to");
		ServerCommand("mp_teamlogo_1 big");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "tiziaN");
		ServerCommand("bot_add_t %s", "smooya");
		ServerCommand("bot_add_t %s", "XANTARES");
		ServerCommand("bot_add_t %s", "tabseN");
		ServerCommand("bot_add_t %s", "k1to");
		ServerCommand("mp_teamlogo_2 big");
	}
	
	return Plugin_Handled;
}

public Action Team_Rejected(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "fara");
		ServerCommand("bot_add_ct %s", "L!nKz^");
		ServerCommand("bot_add_ct %s", "LEEROY");
		ServerCommand("bot_add_ct %s", "FiReMaNNN");
		ServerCommand("bot_add_ct %s", "akz");
		ServerCommand("mp_teamlogo_1 rej");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "fara");
		ServerCommand("bot_add_t %s", "L!nKz^");
		ServerCommand("bot_add_t %s", "LEEROY");
		ServerCommand("bot_add_t %s", "FiReMaNNN");
		ServerCommand("bot_add_t %s", "akz");
		ServerCommand("mp_teamlogo_2 rej");
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

public Action Team_CR4ZY(int client, int args)
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
		ServerCommand("mp_teamlogo_1 cr4z");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("mp_teamlogo_1 wins");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "oskar");
		ServerCommand("bot_add_ct %s", "syrsoN");
		ServerCommand("bot_add_ct %s", "Spiidi");
		ServerCommand("bot_add_ct %s", "faveN");
		ServerCommand("bot_add_ct %s", "denis");
		ServerCommand("mp_teamlogo_1 spr");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "oskar");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "es3tag");
		ServerCommand("bot_add_ct %s", "b0RUP");
		ServerCommand("bot_add_ct %s", "Snappi");
		ServerCommand("bot_add_ct %s", "cadiaN");
		ServerCommand("bot_add_ct %s", "stavn");
		ServerCommand("mp_teamlogo_1 heroi");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "chelo");
		ServerCommand("bot_add_ct %s", "shz");
		ServerCommand("bot_add_ct %s", "xand");
		ServerCommand("bot_add_ct %s", "boltz");
		ServerCommand("bot_add_ct %s", "yeL");
		ServerCommand("mp_teamlogo_1 intz");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "chelo");
		ServerCommand("bot_add_t %s", "shz");
		ServerCommand("bot_add_t %s", "xand");
		ServerCommand("bot_add_t %s", "boltz");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "buster");
		ServerCommand("bot_add_ct %s", "Jame");
		ServerCommand("bot_add_ct %s", "qikert");
		ServerCommand("bot_add_ct %s", "SANJI");
		ServerCommand("bot_add_ct %s", "AdreN");
		ServerCommand("mp_teamlogo_1 vp");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "buster");
		ServerCommand("bot_add_t %s", "Jame");
		ServerCommand("bot_add_t %s", "qikert");
		ServerCommand("bot_add_t %s", "SANJI");
		ServerCommand("bot_add_t %s", "AdreN");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Marcelious");
		ServerCommand("bot_add_ct %s", "truth");
		ServerCommand("bot_add_ct %s", "Grusarn");
		ServerCommand("bot_add_ct %s", "akEz");
		ServerCommand("bot_add_ct %s", "Radifaction");
		ServerCommand("mp_teamlogo_1 ape");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "stfN");
		ServerCommand("bot_add_ct %s", "slaxz");
		ServerCommand("bot_add_ct %s", "DuDe");
		ServerCommand("bot_add_ct %s", "kressy");
		ServerCommand("bot_add_ct %s", "enkay J");
		ServerCommand("mp_teamlogo_1 alt");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "stfN");
		ServerCommand("bot_add_t %s", "slaxz");
		ServerCommand("bot_add_t %s", "DuDe");
		ServerCommand("bot_add_t %s", "kressy");
		ServerCommand("bot_add_t %s", "enkay J");
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
		ServerCommand("bot_add_ct %s", "DickStacy");
		ServerCommand("bot_add_ct %s", "malta");
		ServerCommand("mp_teamlogo_1 ren");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "INS");
		ServerCommand("bot_add_t %s", "sico");
		ServerCommand("bot_add_t %s", "dexter");
		ServerCommand("bot_add_t %s", "DickStacy");
		ServerCommand("bot_add_t %s", "malta");
		ServerCommand("mp_teamlogo_2 ren");
	}
	
	return Plugin_Handled;
}

public Action Team_MVPPK(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "glow");
		ServerCommand("bot_add_ct %s", "xeta");
		ServerCommand("bot_add_ct %s", "Rb");
		ServerCommand("bot_add_ct %s", "k1Ng");
		ServerCommand("bot_add_ct %s", "stax");
		ServerCommand("mp_teamlogo_1 mvp");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Nifty");
		ServerCommand("bot_add_ct %s", "ryann");
		ServerCommand("bot_add_ct %s", "s0m");
		ServerCommand("bot_add_ct %s", "ANDROID");
		ServerCommand("bot_add_ct %s", "FugLy");
		ServerCommand("mp_teamlogo_1 nv");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_add_ct %s", "rodeN");
		ServerCommand("bot_add_ct %s", "Happy");
		ServerCommand("bot_add_ct %s", "MAJ3R");
		ServerCommand("bot_add_ct %s", "Ozstrik3r");
		ServerCommand("bot_add_ct %s", "SIXER");
		ServerCommand("mp_teamlogo_1 ldlc");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "rodeN");
		ServerCommand("bot_add_t %s", "Happy");
		ServerCommand("bot_add_t %s", "MAJ3R");
		ServerCommand("bot_add_t %s", "Ozstrik3r");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "v1N");
		ServerCommand("bot_add_ct %s", "G1DO");
		ServerCommand("bot_add_ct %s", "FASHR");
		ServerCommand("bot_add_ct %s", "D0cC");
		ServerCommand("bot_add_ct %s", "rilax");
		ServerCommand("mp_teamlogo_1 defu");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "v1N");
		ServerCommand("bot_add_t %s", "G1DO");
		ServerCommand("bot_add_t %s", "FASHR");
		ServerCommand("bot_add_t %s", "D0cC");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "dennis");
		ServerCommand("bot_add_ct %s", "nawwk");
		ServerCommand("bot_add_ct %s", "freddieb");
		ServerCommand("bot_add_ct %s", "RuStY");
		ServerCommand("bot_add_ct %s", "hampus");
		ServerCommand("mp_teamlogo_1 glegion");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "dennis");
		ServerCommand("bot_add_t %s", "nawwk");
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
		ServerCommand("bot_add_ct %s", "slunixx");
		ServerCommand("bot_add_ct %s", "eleKz");
		ServerCommand("bot_add_ct %s", "hyped");
		ServerCommand("bot_add_ct %s", "n1kista");
		ServerCommand("bot_add_ct %s", "ykyli");
		ServerCommand("mp_teamlogo_1 divi");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "slunixx");
		ServerCommand("bot_add_t %s", "eleKz");
		ServerCommand("bot_add_t %s", "hyped");
		ServerCommand("bot_add_t %s", "n1kista");
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

public Action Team_expert(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Aika");
		ServerCommand("bot_add_ct %s", "syncD");
		ServerCommand("bot_add_ct %s", "BMLN");
		ServerCommand("bot_add_ct %s", "HighKitty");
		ServerCommand("bot_add_ct %s", "VENIQ");
		ServerCommand("mp_teamlogo_1 exp");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "rUFY");
		ServerCommand("bot_add_ct %s", "darkz");
		ServerCommand("bot_add_ct %s", "denzel");
		ServerCommand("bot_add_ct %s", "expo");
		ServerCommand("bot_add_ct %s", "stowny");
		ServerCommand("mp_teamlogo_1 pant");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "neviZ");
		ServerCommand("bot_add_ct %s", "synx");
		ServerCommand("bot_add_ct %s", "delkore");
		ServerCommand("bot_add_ct %s", "nky");
		ServerCommand("bot_add_ct %s", "pony");
		ServerCommand("mp_teamlogo_1 playin");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "neviZ");
		ServerCommand("bot_add_t %s", "synx");
		ServerCommand("bot_add_t %s", "delkore");
		ServerCommand("bot_add_t %s", "nky");
		ServerCommand("bot_add_t %s", "pony");
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
		ServerCommand("bot_add_ct %s", "Daffu");
		ServerCommand("bot_add_ct %s", "thamlike");
		ServerCommand("bot_add_ct %s", "Cabbi");
		ServerCommand("mp_teamlogo_1 lyng");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "birdfromsky");
		ServerCommand("bot_add_t %s", "Twinx");
		ServerCommand("bot_add_t %s", "Daffu");
		ServerCommand("bot_add_t %s", "thamlike");
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
		ServerCommand("bot_add_ct %s", "hallzerk");
		ServerCommand("bot_add_ct %s", "RUBINO");
		ServerCommand("bot_add_ct %s", "H4RR3");
		ServerCommand("bot_add_ct %s", "cromen");
		ServerCommand("mp_teamlogo_1 nord");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_add_ct %s", "BORKUM");
		ServerCommand("bot_add_ct %s", "Derek");
		ServerCommand("mp_teamlogo_1 bren");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Papichulo");
		ServerCommand("bot_add_t %s", "witz");
		ServerCommand("bot_add_t %s", "Pro.");
		ServerCommand("bot_add_t %s", "BORKUM");
		ServerCommand("bot_add_t %s", "Derek");
		ServerCommand("mp_teamlogo_2 bren");
	}
	
	return Plugin_Handled;
}

public Action Team_Baskonia(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "tatin");
		ServerCommand("bot_add_ct %s", "PabLo");
		ServerCommand("bot_add_ct %s", "LittlesataN1");
		ServerCommand("bot_add_ct %s", "dixon");
		ServerCommand("bot_add_ct %s", "jJavi");
		ServerCommand("mp_teamlogo_1 bask");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "rmn");
		ServerCommand("bot_add_ct %s", "fox");
		ServerCommand("bot_add_ct %s", "Cunha");
		ServerCommand("bot_add_ct %s", "MUTiRiS");
		ServerCommand("bot_add_ct %s", "arki");
		ServerCommand("mp_teamlogo_1 giant");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "HUNDEN");
		ServerCommand("bot_add_ct %s", "acoR");
		ServerCommand("bot_add_ct %s", "Sjuush");
		ServerCommand("bot_add_ct %s", "Bubzkji");
		ServerCommand("bot_add_ct %s", "roeJ");
		ServerCommand("mp_teamlogo_1 lion");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "HUNDEN");
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
		ServerCommand("bot_add_ct %s", "RIZZ");
		ServerCommand("bot_add_ct %s", "obj");
		ServerCommand("bot_add_ct %s", "zlynx");
		ServerCommand("bot_add_ct %s", "ZELIN");
		ServerCommand("bot_add_ct %s", "kst");
		ServerCommand("mp_teamlogo_1 offs");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "RIZZ");
		ServerCommand("bot_add_t %s", "obj");
		ServerCommand("bot_add_t %s", "zlynx");
		ServerCommand("bot_add_t %s", "ZELIN");
		ServerCommand("bot_add_t %s", "kst");
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
		ServerCommand("bot_add_ct %s", "HenkkyG");
		ServerCommand("bot_add_ct %s", "ZEDKO");
		ServerCommand("bot_add_ct %s", "leckr");
		ServerCommand("bot_add_ct %s", "Blogg1s");
		ServerCommand("bot_add_ct %s", "SHOCK");
		ServerCommand("mp_teamlogo_1 esu");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "BTN");
		ServerCommand("bot_add_ct %s", "XELLOW");
		ServerCommand("bot_add_ct %s", "SEMINTE");
		ServerCommand("bot_add_ct %s", "iM");
		ServerCommand("bot_add_ct %s", "starkiller");
		ServerCommand("mp_teamlogo_1 nex");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "darko");
		ServerCommand("bot_add_ct %s", "lunAtic");
		ServerCommand("bot_add_ct %s", "Goofy");
		ServerCommand("bot_add_ct %s", "Crityourface");
		ServerCommand("bot_add_ct %s", "Sobol");
		ServerCommand("mp_teamlogo_1 pact");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "jeyN");
		ServerCommand("bot_add_ct %s", "Maka");
		ServerCommand("bot_add_ct %s", "xms");
		ServerCommand("bot_add_ct %s", "kioShiMa");
		ServerCommand("bot_add_ct %s", "Lucky");
		ServerCommand("mp_teamlogo_1 here");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "jeyN");
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
		ServerCommand("bot_add_ct %s", "spellfull");
		ServerCommand("bot_add_ct %s", "mds");
		ServerCommand("bot_add_ct %s", "lollipop21k");
		ServerCommand("bot_add_ct %s", "Jyo");
		ServerCommand("bot_add_ct %s", "boX");
		ServerCommand("mp_teamlogo_1 nem");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "spellfull");
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

public Action Team_eUnited(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "freakazoid");
		ServerCommand("bot_add_ct %s", "Cooper-");
		ServerCommand("bot_add_ct %s", "MarKE");
		ServerCommand("bot_add_ct %s", "food");
		ServerCommand("bot_add_ct %s", "moose");
		ServerCommand("mp_teamlogo_1 eun");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "freakazoid");
		ServerCommand("bot_add_t %s", "Cooper-");
		ServerCommand("bot_add_t %s", "MarKE");
		ServerCommand("bot_add_t %s", "food");
		ServerCommand("bot_add_t %s", "moose");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "C0M");
		ServerCommand("bot_add_ct %s", "fl0m");
		ServerCommand("bot_add_ct %s", "Katie");
		ServerCommand("bot_add_ct %s", "hazed");
		ServerCommand("bot_add_ct %s", "SileNt");
		ServerCommand("mp_teamlogo_1 myth");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Zellsis");
		ServerCommand("bot_add_ct %s", "Relyks");
		ServerCommand("bot_add_ct %s", "seb");
		ServerCommand("bot_add_ct %s", "dazzLe");
		ServerCommand("bot_add_ct %s", "dapr");
		ServerCommand("mp_teamlogo_1 sing");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Zellsis");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "prt");
		ServerCommand("bot_add_ct %s", "tiburci0");
		ServerCommand("bot_add_ct %s", "v$m");
		ServerCommand("bot_add_ct %s", "Lucaozy");
		ServerCommand("bot_add_ct %s", "Tuurtle");
		ServerCommand("mp_teamlogo_1 deto");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "cruzN");
		ServerCommand("bot_add_ct %s", "malbsMd");
		ServerCommand("bot_add_ct %s", "spamzzy");
		ServerCommand("bot_add_ct %s", "sam_A");
		ServerCommand("bot_add_ct %s", "Daveys");
		ServerCommand("mp_teamlogo_1 infi");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_add_ct %s", "RCF");
		ServerCommand("bot_add_ct %s", "jnt");
		ServerCommand("bot_add_ct %s", "leo_drunky");
		ServerCommand("bot_add_ct %s", "exit");
		ServerCommand("bot_add_ct %s", "Luken");
		ServerCommand("mp_teamlogo_1 shark");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "RCF");
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
		ServerCommand("bot_add_ct %s", "\"bld V\"");
		ServerCommand("bot_add_ct %s", "Maluk3");
		ServerCommand("bot_add_ct %s", "trk");
		ServerCommand("bot_add_ct %s", "bit");
		ServerCommand("bot_add_ct %s", "b4rtiN");
		ServerCommand("mp_teamlogo_1 tone");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "\"bld V\"");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "skullz");
		ServerCommand("bot_add_ct %s", "raafa");
		ServerCommand("bot_add_ct %s", "ryotzz");
		ServerCommand("bot_add_ct %s", "pancc");
		ServerCommand("bot_add_ct %s", "realziN");
		ServerCommand("mp_teamlogo_1 w7m");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "soju_j");
		ServerCommand("bot_add_ct %s", "sterling");
		ServerCommand("bot_add_ct %s", "apoc");
		ServerCommand("bot_add_ct %s", "J1rah");
		ServerCommand("bot_add_ct %s", "HaZR");
		ServerCommand("mp_teamlogo_1 avant");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "tucks");
		ServerCommand("bot_add_ct %s", "BL1TZ");
		ServerCommand("bot_add_ct %s", "Texta");
		ServerCommand("bot_add_ct %s", "ofnu");
		ServerCommand("bot_add_ct %s", "zewsy");
		ServerCommand("mp_teamlogo_1 chief");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "tucks");
		ServerCommand("bot_add_t %s", "BL1TZ");
		ServerCommand("bot_add_t %s", "Texta");
		ServerCommand("bot_add_t %s", "ofnu");
		ServerCommand("bot_add_t %s", "zewsy");
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
		ServerCommand("bot_add_ct %s", "emagine");
		ServerCommand("bot_add_ct %s", "aliStair");
		ServerCommand("bot_add_ct %s", "hatz");
		ServerCommand("bot_add_ct %s", "USTILO");
		ServerCommand("bot_add_ct %s", "Valiance");
		ServerCommand("mp_teamlogo_1 order");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "hue9ze");
		ServerCommand("bot_add_ct %s", "addict");
		ServerCommand("bot_add_ct %s", "cookie");
		ServerCommand("bot_add_ct %s", "jeepy");
		ServerCommand("bot_add_ct %s", "Wolfah");
		ServerCommand("mp_teamlogo_1 blacks");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "hue9ze");
		ServerCommand("bot_add_t %s", "addict");
		ServerCommand("bot_add_t %s", "cookie");
		ServerCommand("bot_add_t %s", "jeepy");
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

public Action Team_SYF(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ino");
		ServerCommand("bot_add_ct %s", "Teal");
		ServerCommand("bot_add_ct %s", "ekul");
		ServerCommand("bot_add_ct %s", "bedonka");
		ServerCommand("bot_add_ct %s", "urbz");
		ServerCommand("mp_teamlogo_1 syf");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ino");
		ServerCommand("bot_add_t %s", "Teal");
		ServerCommand("bot_add_t %s", "ekul");
		ServerCommand("bot_add_t %s", "bedonka");
		ServerCommand("bot_add_t %s", "urbz");
		ServerCommand("mp_teamlogo_2 syf");
	}
	
	return Plugin_Handled;
}

public Action Team_RisingStars(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "bottle");
		ServerCommand("bot_add_ct %s", "HZ");
		ServerCommand("bot_add_ct %s", "xiaosaGe");
		ServerCommand("bot_add_ct %s", "shuadapai");
		ServerCommand("bot_add_ct %s", "Viva");
		ServerCommand("mp_teamlogo_1 stars");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "bottle");
		ServerCommand("bot_add_t %s", "HZ");
		ServerCommand("bot_add_t %s", "xiaosaGe");
		ServerCommand("bot_add_t %s", "shuadapai");
		ServerCommand("bot_add_t %s", "Viva");
		ServerCommand("mp_teamlogo_2 stars");
	}
	
	return Plugin_Handled;
}

public Action Team_EHOME(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "equal");
		ServerCommand("bot_add_ct %s", "DeStRoYeR");
		ServerCommand("bot_add_ct %s", "Marek");
		ServerCommand("bot_add_ct %s", "SLOWLY");
		ServerCommand("bot_add_ct %s", "4king");
		ServerCommand("mp_teamlogo_1 ehome");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "equal");
		ServerCommand("bot_add_t %s", "DeStRoYeR");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "MAIROLLS");
		ServerCommand("bot_add_ct %s", "Olivia");
		ServerCommand("bot_add_ct %s", "Kntz");
		ServerCommand("bot_add_ct %s", "SeveN89");
		ServerCommand("bot_add_ct %s", "foxz");
		ServerCommand("mp_teamlogo_1 alpha");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Bobosaur");
		ServerCommand("bot_add_ct %s", "splashske");
		ServerCommand("bot_add_ct %s", "alecks");
		ServerCommand("bot_add_ct %s", "Benkai");
		ServerCommand("bot_add_ct %s", "d4v41");
		ServerCommand("mp_teamlogo_1 dream");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Bobosaur");
		ServerCommand("bot_add_t %s", "splashske");
		ServerCommand("bot_add_t %s", "alecks");
		ServerCommand("bot_add_t %s", "Benkai");
		ServerCommand("bot_add_t %s", "d4v41");
		ServerCommand("mp_teamlogo_2 dream");
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
		ServerCommand("bot_add_ct %s", "TOR");
		ServerCommand("bot_add_ct %s", "bnwGiggs");
		ServerCommand("bot_add_ct %s", "RoLEX");
		ServerCommand("bot_add_ct %s", "veta");
		ServerCommand("bot_add_ct %s", "Geniuss");
		ServerCommand("mp_teamlogo_1 bey");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Amaterasu");
		ServerCommand("bot_add_ct %s", "Psy");
		ServerCommand("bot_add_ct %s", "Excali");
		ServerCommand("bot_add_ct %s", "skillZ");
		ServerCommand("bot_add_ct %s", "Ace");
		ServerCommand("mp_teamlogo_1 enti");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Amaterasu");
		ServerCommand("bot_add_t %s", "Psy");
		ServerCommand("bot_add_t %s", "Excali");
		ServerCommand("bot_add_t %s", "skillZ");
		ServerCommand("bot_add_t %s", "Ace");
		ServerCommand("mp_teamlogo_2 enti");
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
		ServerCommand("bot_add_ct %s", "wannafly");
		ServerCommand("bot_add_ct %s", "PTC");
		ServerCommand("bot_add_ct %s", "cbbk");
		ServerCommand("bot_add_ct %s", "JohnOlsen");
		ServerCommand("bot_add_ct %s", "Akino");
		ServerCommand("mp_teamlogo_1 lucid");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "wannafly");
		ServerCommand("bot_add_t %s", "PTC");
		ServerCommand("bot_add_t %s", "cbbk");
		ServerCommand("bot_add_t %s", "JohnOlsen");
		ServerCommand("bot_add_t %s", "Akino");
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
		ServerCommand("bot_add_ct %s", "breAker");
		ServerCommand("bot_add_ct %s", "Nami");
		ServerCommand("bot_add_ct %s", "kitkat");
		ServerCommand("bot_add_ct %s", "havoK");
		ServerCommand("bot_add_ct %s", "kAzoo");
		ServerCommand("mp_teamlogo_1 nasr");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "traNz");
		ServerCommand("bot_add_ct %s", "Ttyke");
		ServerCommand("bot_add_ct %s", "DVDOV");
		ServerCommand("bot_add_ct %s", "PokemoN");
		ServerCommand("bot_add_ct %s", "Ebeee");
		ServerCommand("mp_teamlogo_1 port");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "V3nom");
		ServerCommand("bot_add_ct %s", "RiX");
		ServerCommand("bot_add_ct %s", "Juventa");
		ServerCommand("bot_add_ct %s", "astaRR");
		ServerCommand("bot_add_ct %s", "spy");
		ServerCommand("mp_teamlogo_1 brut");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ribbiZ");
		ServerCommand("bot_add_ct %s", "Manan");
		ServerCommand("bot_add_ct %s", "Pashasahil");
		ServerCommand("bot_add_ct %s", "BinaryBUG");
		ServerCommand("bot_add_ct %s", "blackhawk");
		ServerCommand("mp_teamlogo_1 inv");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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

public Action Team_ATK(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "motm");
		ServerCommand("bot_add_ct %s", "oSee");
		ServerCommand("bot_add_ct %s", "JT");
		ServerCommand("bot_add_ct %s", "floppy");
		ServerCommand("bot_add_ct %s", "Sonic");
		ServerCommand("mp_teamlogo_1 atk");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "TheM4N");
		ServerCommand("bot_add_ct %s", "Dweezil");
		ServerCommand("bot_add_ct %s", "kaNibalistic");
		ServerCommand("bot_add_ct %s", "adM");
		ServerCommand("bot_add_ct %s", "bLazE");
		ServerCommand("mp_teamlogo_1 ener");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "laser");
		ServerCommand("bot_add_ct %s", "iKrystal");
		ServerCommand("bot_add_ct %s", "PREDI");
		ServerCommand("bot_add_ct %s", "TISAN");
		ServerCommand("bot_add_ct %s", "Tio");
		ServerCommand("mp_teamlogo_1 furio");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "laser");
		ServerCommand("bot_add_t %s", "iKrystal");
		ServerCommand("bot_add_t %s", "PREDI");
		ServerCommand("bot_add_t %s", "TISAN");
		ServerCommand("bot_add_t %s", "Tio");
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
		ServerCommand("bot_add_ct %s", "maxz");
		ServerCommand("bot_add_ct %s", "Tsubasa");
		ServerCommand("bot_add_ct %s", "jansen");
		ServerCommand("bot_add_ct %s", "RykuN");
		ServerCommand("bot_add_ct %s", "skillmaschine JJ_-");
		ServerCommand("mp_teamlogo_1 blueja");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "maxz");
		ServerCommand("bot_add_t %s", "Tsubasa");
		ServerCommand("bot_add_t %s", "jansen");
		ServerCommand("bot_add_t %s", "RykuN");
		ServerCommand("bot_add_t %s", "skillmaschine JJ_-");
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

public Action Team_Vexed(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "mezii");
		ServerCommand("bot_add_ct %s", "Kray");
		ServerCommand("bot_add_ct %s", "Adam9130");
		ServerCommand("bot_add_ct %s", "L1NK");
		ServerCommand("bot_add_ct %s", "ec1s");
		ServerCommand("mp_teamlogo_1 vex");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "BURNRUOk");
		ServerCommand("bot_add_ct %s", "void");
		ServerCommand("bot_add_ct %s", "zemp");
		ServerCommand("bot_add_ct %s", "zeph");
		ServerCommand("bot_add_ct %s", "pan1K");
		ServerCommand("mp_teamlogo_1 ground");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "BURNRUOk");
		ServerCommand("bot_add_t %s", "void");
		ServerCommand("bot_add_t %s", "zemp");
		ServerCommand("bot_add_t %s", "zeph");
		ServerCommand("bot_add_t %s", "pan1K");
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
		ServerCommand("bot_add_ct %s", "hades");
		ServerCommand("bot_add_ct %s", "KEi");
		ServerCommand("bot_add_ct %s", "Kylar");
		ServerCommand("bot_add_ct %s", "nawrot");
		ServerCommand("mp_teamlogo_1 avez");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "MOLSI");
		ServerCommand("bot_add_t %s", "hades");
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
		ServerCommand("bot_add_ct %s", "Eeyore");
		ServerCommand("bot_add_ct %s", "Drea3er");
		ServerCommand("bot_add_ct %s", "xccurate");
		ServerCommand("bot_add_ct %s", "ImpressioN");
		ServerCommand("bot_add_ct %s", "adrnkiNg");
		ServerCommand("mp_teamlogo_1 btrg");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "SHOOWTiME");
		ServerCommand("bot_add_ct %s", "zqk");
		ServerCommand("bot_add_ct %s", "dzt");
		ServerCommand("bot_add_ct %s", "f4stzin");
		ServerCommand("bot_add_ct %s", "KILLDREAM");
		ServerCommand("mp_teamlogo_1 keyd");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_add_ct %s", "TeSeS");
		ServerCommand("bot_add_ct %s", "farlig");
		ServerCommand("bot_add_ct %s", "AcilioN");
		ServerCommand("bot_add_ct %s", "TMB");
		ServerCommand("bot_add_ct %s", "Nodios");
		ServerCommand("mp_teamlogo_1 copen");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "kek0");
		ServerCommand("bot_add_ct %s", "MasterdaN");
		ServerCommand("bot_add_ct %s", "diNk");
		ServerCommand("bot_add_ct %s", "Vinice");
		ServerCommand("bot_add_ct %s", "sh0wz");
		ServerCommand("mp_teamlogo_1 eu4ia");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Astroo");
		ServerCommand("bot_add_ct %s", "Impulse");
		ServerCommand("bot_add_ct %s", "frei");
		ServerCommand("bot_add_ct %s", "jenko");
		ServerCommand("bot_add_ct %s", "ardiis");
		ServerCommand("mp_teamlogo_1 fierce");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Astroo");
		ServerCommand("bot_add_t %s", "Impulse");
		ServerCommand("bot_add_t %s", "frei");
		ServerCommand("bot_add_t %s", "jenko");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "TEX");
		ServerCommand("bot_add_ct %s", "zorboT");
		ServerCommand("bot_add_ct %s", "Rackem");
		ServerCommand("bot_add_ct %s", "jhd");
		ServerCommand("bot_add_ct %s", "jtr");
		ServerCommand("mp_teamlogo_1 trid");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "neaLaN");
		ServerCommand("bot_add_ct %s", "Ramz1k");
		ServerCommand("bot_add_ct %s", "n0rb3r7");
		ServerCommand("bot_add_ct %s", "Perfecto");
		ServerCommand("bot_add_ct %s", "Keoz");
		ServerCommand("mp_teamlogo_1 syma");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "k4Mi");
		ServerCommand("bot_add_ct %s", "zWin");
		ServerCommand("bot_add_ct %s", "Pure");
		ServerCommand("bot_add_ct %s", "FairyRae");
		ServerCommand("bot_add_ct %s", "kZy");
		ServerCommand("mp_teamlogo_1 wnv");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_add_ct %s", "rigoN");
		ServerCommand("bot_add_ct %s", "sinnopsyy");
		ServerCommand("bot_add_ct %s", "anarkez");
		ServerCommand("mp_teamlogo_1 secr");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "juanflatroo");
		ServerCommand("bot_add_t %s", "tudsoN");
		ServerCommand("bot_add_t %s", "rigoN");
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
		ServerCommand("bot_add_ct %s", "flaw");
		ServerCommand("bot_add_ct %s", "jtr");
		ServerCommand("bot_add_ct %s", "nettik");
		ServerCommand("bot_add_ct %s", "DannyG");
		ServerCommand("bot_add_ct %s", "vanilla");
		ServerCommand("mp_teamlogo_1 ince");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "flaw");
		ServerCommand("bot_add_t %s", "jtr");
		ServerCommand("bot_add_t %s", "nettik");
		ServerCommand("bot_add_t %s", "DannyG");
		ServerCommand("bot_add_t %s", "vanilla");
		ServerCommand("mp_teamlogo_2 ince");
	}
	
	return Plugin_Handled;
}

public Action Team_MiTH(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "NIFFY");
		ServerCommand("bot_add_ct %s", "Leaf");
		ServerCommand("bot_add_ct %s", "JUSTCAUSE");
		ServerCommand("bot_add_ct %s", "Reality");
		ServerCommand("bot_add_ct %s", "PPOverdose");
		ServerCommand("mp_teamlogo_1 mith");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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

public Action Team_9INE(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ACM");
		ServerCommand("bot_add_ct %s", "phzy");
		ServerCommand("bot_add_ct %s", "Djury");
		ServerCommand("bot_add_ct %s", "aybeN");
		ServerCommand("bot_add_ct %s", "MistFire");
		ServerCommand("mp_teamlogo_1 9ine");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ACM");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "brA");
		ServerCommand("bot_add_ct %s", "Demonos");
		ServerCommand("bot_add_ct %s", "SHOUW");
		ServerCommand("bot_add_ct %s", "horvy");
		ServerCommand("bot_add_ct %s", "axoN");
		ServerCommand("mp_teamlogo_1 baec");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "brA");
		ServerCommand("bot_add_t %s", "Demonos");
		ServerCommand("bot_add_t %s", "SHOUW");
		ServerCommand("bot_add_t %s", "horvy");
		ServerCommand("bot_add_t %s", "axoN");
		ServerCommand("mp_teamlogo_2 baec");
	}

	return Plugin_Handled;
}

public Action Team_Corvidae(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "DANZ");
		ServerCommand("bot_add_ct %s", "dash");
		ServerCommand("bot_add_ct %s", "m1tch");
		ServerCommand("bot_add_ct %s", "nibke");
		ServerCommand("bot_add_ct %s", "Dirty");
		ServerCommand("mp_teamlogo_1 corv");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "KALAS");
		ServerCommand("bot_add_ct %s", "v1NCHENSO7");
		ServerCommand("bot_add_ct %s", "Kiles");
		ServerCommand("bot_add_ct %s", "Fit1nho");
		ServerCommand("bot_add_ct %s", "Ryd3r-");
		ServerCommand("mp_teamlogo_1 wiz");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "oskarish");
		ServerCommand("bot_add_ct %s", "STOMP");
		ServerCommand("bot_add_ct %s", "mono");
		ServerCommand("bot_add_ct %s", "innocent");
		ServerCommand("bot_add_ct %s", "reatz");
		ServerCommand("mp_teamlogo_1 illu");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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

public Action Team_GameAgents(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "pounh");
		ServerCommand("bot_add_ct %s", "FliP1");
		ServerCommand("bot_add_ct %s", "COSMEEEN");
		ServerCommand("bot_add_ct %s", "kalle");
		ServerCommand("bot_add_ct %s", "PALM1");
		ServerCommand("mp_teamlogo_1 game");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "pounh");
		ServerCommand("bot_add_t %s", "FliP1");
		ServerCommand("bot_add_t %s", "COSMEEEN");
		ServerCommand("bot_add_t %s", "kalle");
		ServerCommand("bot_add_t %s", "PALM1");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Max");
		ServerCommand("bot_add_ct %s", "cara");
		ServerCommand("bot_add_ct %s", "formlesS");
		ServerCommand("bot_add_ct %s", "Raph");
		ServerCommand("bot_add_ct %s", "risk");
		ServerCommand("mp_teamlogo_1 oran");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "EXPRO");
		ServerCommand("bot_add_ct %s", "V4D1M");
		ServerCommand("bot_add_ct %s", "flying");
		ServerCommand("bot_add_ct %s", "sPiNacH");
		ServerCommand("bot_add_ct %s", "Koshak");
		ServerCommand("mp_teamlogo_1 ig");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "EXPRO");
		ServerCommand("bot_add_t %s", "V4D1M");
		ServerCommand("bot_add_t %s", "flying");
		ServerCommand("bot_add_t %s", "sPiNacH");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ANGE1");
		ServerCommand("bot_add_ct %s", "nukkye");
		ServerCommand("bot_add_ct %s", "Flarich");
		ServerCommand("bot_add_ct %s", "crush");
		ServerCommand("bot_add_ct %s", "scoobyxie");
		ServerCommand("mp_teamlogo_1 hlr");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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

public Action Team_Absolute(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "crow");
		ServerCommand("bot_add_ct %s", "Laz");
		ServerCommand("bot_add_ct %s", "barce");
		ServerCommand("bot_add_ct %s", "takej");
		ServerCommand("bot_add_ct %s", "Reita");
		ServerCommand("mp_teamlogo_1 abs");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
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
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "xikii");
		ServerCommand("bot_add_ct %s", "SunPayus");
		ServerCommand("bot_add_ct %s", "meisoN");
		ServerCommand("bot_add_ct %s", "donQ");
		ServerCommand("bot_add_ct %s", "MackDaddy");
		ServerCommand("mp_teamlogo_1 kpi");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "xikii");
		ServerCommand("bot_add_t %s", "SunPayus");
		ServerCommand("bot_add_t %s", "meisoN");
		ServerCommand("bot_add_t %s", "donQ");
		ServerCommand("bot_add_t %s", "MackDaddy");
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
		ServerCommand("bot_add_ct %s", "xenn");
		ServerCommand("bot_add_ct %s", "s1n");
		ServerCommand("bot_add_ct %s", "boostey");
		ServerCommand("bot_add_ct %s", "Kirby");
		ServerCommand("bot_add_ct %s", "Krimbo");
		ServerCommand("mp_teamlogo_1 pkd");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "xenn");
		ServerCommand("bot_add_t %s", "s1n");
		ServerCommand("bot_add_t %s", "boostey");
		ServerCommand("bot_add_t %s", "Kirby");
		ServerCommand("bot_add_t %s", "Krimbo");
		ServerCommand("mp_teamlogo_2 pkd");
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
		ServerCommand("mp_teamlogo_1 drea");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "CHEHOL");
		ServerCommand("bot_add_t %s", "Quantium");
		ServerCommand("bot_add_t %s", "Kas9k");
		ServerCommand("bot_add_t %s", "minse");
		ServerCommand("bot_add_t %s", "JACKPOT");
		ServerCommand("mp_teamlogo_2 drea");
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
		ServerCommand("bot_add_ct %s", "Kap3r");
		ServerCommand("bot_add_ct %s", "SZPERO");
		ServerCommand("bot_add_ct %s", "mynio");
		ServerCommand("bot_add_ct %s", "morelz");
		ServerCommand("bot_add_ct %s", "jedqr");
		ServerCommand("mp_teamlogo_1 wisla");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Kap3r");
		ServerCommand("bot_add_t %s", "SZPERO");
		ServerCommand("bot_add_t %s", "mynio");
		ServerCommand("bot_add_t %s", "morelz");
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
		ServerCommand("bot_add_ct %s", "dumau");
		ServerCommand("bot_add_ct %s", "tatazin");
		ServerCommand("bot_add_ct %s", "delboNi");
		ServerCommand("bot_add_ct %s", "iDk");
		ServerCommand("mp_teamlogo_1 imp");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "KHTEX");
		ServerCommand("bot_add_t %s", "dumau");
		ServerCommand("bot_add_t %s", "tatazin");
		ServerCommand("bot_add_t %s", "delboNi");
		ServerCommand("bot_add_t %s", "iDk");
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
		ServerCommand("bot_add_ct %s", "Polt");
		ServerCommand("bot_add_ct %s", "fenvicious");
		ServerCommand("mp_teamlogo_1 uniq");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "R0b3n");
		ServerCommand("bot_add_t %s", "zorte");
		ServerCommand("bot_add_t %s", "PASHANOJ");
		ServerCommand("bot_add_t %s", "Polt");
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
		ServerCommand("bot_add_ct %s", "Patitek");
		ServerCommand("bot_add_ct %s", "Hyper");
		ServerCommand("bot_add_ct %s", "EXUS");
		ServerCommand("bot_add_ct %s", "Luz");
		ServerCommand("bot_add_ct %s", "TOAO");
		ServerCommand("mp_teamlogo_1 izak");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Patitek");
		ServerCommand("bot_add_t %s", "Hyper");
		ServerCommand("bot_add_t %s", "EXUS");
		ServerCommand("bot_add_t %s", "Luz");
		ServerCommand("bot_add_t %s", "TOAO");
		ServerCommand("mp_teamlogo_2 izak");
	}

	return Plugin_Handled;
}

public Action Team_Riot(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "mitch");
		ServerCommand("bot_add_ct %s", "ptr");
		ServerCommand("bot_add_ct %s", "crashies");
		ServerCommand("bot_add_ct %s", "FNS");
		ServerCommand("bot_add_ct %s", "Jonji");
		ServerCommand("mp_teamlogo_1 riot");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "mitch");
		ServerCommand("bot_add_t %s", "ptr");
		ServerCommand("bot_add_t %s", "crashies");
		ServerCommand("bot_add_t %s", "FNS");
		ServerCommand("bot_add_t %s", "Jonji");
		ServerCommand("mp_teamlogo_2 riot");
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
		ServerCommand("bot_add_ct %s", "cam");
		ServerCommand("bot_add_ct %s", "wippie");
		ServerCommand("bot_add_ct %s", "Infinite");
		ServerCommand("bot_add_ct %s", "steel_");
		ServerCommand("bot_add_ct %s", "ben1337");
		ServerCommand("mp_teamlogo_1 chaos");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "cam");
		ServerCommand("bot_add_t %s", "wippie");
		ServerCommand("bot_add_t %s", "Infinite");
		ServerCommand("bot_add_t %s", "steel_");
		ServerCommand("bot_add_t %s", "ben1337");
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
		ServerCommand("bot_add_ct %s", "Dosia");
		ServerCommand("bot_add_ct %s", "mou");
		ServerCommand("bot_add_ct %s", "captainMo");
		ServerCommand("bot_add_ct %s", "DD");
		ServerCommand("bot_add_ct %s", "Karsa");
		ServerCommand("mp_teamlogo_1 one");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Dosia");
		ServerCommand("bot_add_t %s", "mou");
		ServerCommand("bot_add_t %s", "captainMo");
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
		ServerCommand("bot_add_ct %s", "xCeeD");
		ServerCommand("bot_add_ct %s", "Voltage");
		ServerCommand("bot_add_ct %s", "Spongey");
		ServerCommand("bot_add_ct %s", "Snakes");
		ServerCommand("bot_add_ct %s", "Grim");
		ServerCommand("mp_teamlogo_1 tri");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "xCeeD");
		ServerCommand("bot_add_t %s", "Voltage");
		ServerCommand("bot_add_t %s", "Spongey");
		ServerCommand("bot_add_t %s", "Snakes");
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
		ServerCommand("bot_add_ct %s", "pesadelo");
		ServerCommand("bot_add_ct %s", "nythonzinho");
		ServerCommand("bot_add_ct %s", "nak");
		ServerCommand("bot_add_ct %s", "latto");
		ServerCommand("bot_add_ct %s", "fnx");
		ServerCommand("mp_teamlogo_1 red");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "pesadelo");
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

public Action Team_LiViD(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "huynh");
		ServerCommand("bot_add_ct %s", "MkaeL");
		ServerCommand("bot_add_ct %s", "INCRED");
		ServerCommand("bot_add_ct %s", "gMd");
		ServerCommand("bot_add_ct %s", "ISSAA");
		ServerCommand("mp_teamlogo_1 livid");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "huynh");
		ServerCommand("bot_add_t %s", "MkaeL");
		ServerCommand("bot_add_t %s", "INCRED");
		ServerCommand("bot_add_t %s", "gMd");
		ServerCommand("bot_add_t %s", "effys");
		ServerCommand("mp_teamlogo_2 livid");
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
	
	Pro_Players(botname, client);
	
	g_iProfileRank[client] = GetRandomInt(1,40);
	
	SetCustomPrivateRank(client);
}

public void OnRoundStart(Handle event, char[] name, bool dbc)
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i) && IsFakeClient(i))
		{			
			if(g_hShouldAttackTimer[i] != null)
			{
				KillTimer(g_hShouldAttackTimer[i]);
				g_hShouldAttackTimer[i] = null;
			}
			
			if(GetRandomInt(1,100) <= 35)
			{
				if(GetClientTeam(i) == CS_TEAM_CT)
				{
					SetEntityModel(i, CTModels[GetRandomInt(0, sizeof(CTModels) - 1)]);
				}
				else if(GetClientTeam(i) == CS_TEAM_T)
				{
					SetEntityModel(i, TModels[GetRandomInt(0, sizeof(TModels) - 1)]);
				}
				
			}
			int rndm = GetRandomInt(1,2);
		
			switch(rndm)
			{
				case 1:
				{
					SetEntProp(i, Prop_Send, "m_unMusicID", GetRandomInt(3,31));
				}
				case 2:
				{
					SetEntProp(i, Prop_Send, "m_unMusicID", GetRandomInt(39,41));
				}
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
	if(IsValidClient(client) && IsFakeClient(client))
	{	
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) != -1)
		{
			SetEntProp(client, Prop_Send, "m_bInBuyZone", 0);
			return Plugin_Continue;
		}
	
		int m_iAccount = GetEntProp(client, Prop_Send, "m_iAccount");
		if(StrEqual(weapon,"m4a1"))
		{ 
			int iWeapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
			
			if(GetRandomInt(1,100) <= 20)
			{
				if (iWeapon != -1)
				{
					RemovePlayerItem(client, iWeapon);
				}
				
				m_iAccount -= 3100;
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
			
			if(GetRandomInt(1,100) <= 35)
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
				CreateTimer(GetRandomFloat(3.0, 20.0), Timer_ShouldAttack, GetClientSerial(client));
			}
		}
	} else if (g_hShouldAttackTimer[client] != null) {
		// kill timer since the client has switch weapon and it's pointless to continue
		KillTimer(g_hShouldAttackTimer[client]);
		g_hShouldAttackTimer[client] = null;
	}
	
	if(IsValidClient(client) && IsPlayerAlive(client))
	{
		char botname[512];
		GetClientName(client, botname, sizeof(botname));
		
		for(int i = 0; i <= sizeof(g_BotName) - 1; i++)
		{
			if(StrEqual(botname, g_BotName[i]))
			{
				if(index == 9)
				{
					return Plugin_Continue;
				}
				float clientEyes[3], targetEyes[3], targetEyes2[3], targetEyes3[3], targetEyesBase[3];
				GetClientEyePosition(client, clientEyes);
				int Ent = Client_GetClosest(clientEyes, client);
				
				float angle[3];
				int iClipAmmo = GetEntProp(ActiveWeapon, Prop_Send, "m_iClip1");
				if (iClipAmmo > 0)
				{
					if(IsValidClient(Ent))
					{
						if(GetEntityMoveType(client) == MOVETYPE_LADDER)
						{
							buttons |= IN_JUMP;
							return Plugin_Changed;
						}
						
						GetClientAbsOrigin(Ent, targetEyes);
						GetClientAbsOrigin(Ent, targetEyesBase);
						GetClientAbsOrigin(Ent, targetEyes3);
						GetEntPropVector(Ent, Prop_Data, "m_angRotation", angle);
						GetClientEyePosition(Ent, targetEyes2);
						if((IsWeaponSlotActive(client, CS_SLOT_PRIMARY) && index != 40 && index != 11 && index != 38) || index == 63)
						{
							if(GetRandomInt(1,4) == 1)
							{
								targetEyes[2] = targetEyes2[2];
							}
							else
							{
								targetEyes[2] += GetRandomFloat(37.5, 55.5);
							}
							buttons |= IN_ATTACK;
						}
						else if(buttons & IN_ATTACK && IsWeaponSlotActive(client, CS_SLOT_SECONDARY) && index != 63)
						{
							if(GetRandomInt(1,4) == 1)
							{
								targetEyes[2] = targetEyes2[2];
							}
							else
							{
								targetEyes[2] += GetRandomFloat(37.5, 55.5);
							}
						}
						else if(buttons & IN_ATTACK && (index == 40 || index == 11 || index == 38))
						{
							if(GetRandomInt(1,3) == 1)
							{
								targetEyes[2] = targetEyes2[2];
							}
							else
							{
								targetEyes[2] += GetRandomFloat(37.5, 55.5);
							}
						}
						else if(IsWeaponSlotActive(client, CS_SLOT_GRENADE))
						{
							targetEyes[2] += 78.5;
							g_bShouldAttack[client] = true;
							buttons &= ~IN_ATTACK; 
							g_hShouldAttackTimer[client] = null;
						}
						else
						{
							return Plugin_Continue;
						}
						float flPos[3];
						GetClientEyePosition(client, flPos);

						float flAng[3];
						GetClientEyeAngles(client, flAng);
						
						// get normalised direction from target to client
						float desired_dir[3];
						MakeVectorFromPoints(flPos, targetEyes, desired_dir);
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
					}
					
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
		}
	}

	return Plugin_Continue;
}

public Action Timer_CheckPlayer(Handle Timer, any data)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsFakeClient(i))
		{
			int m_iAccount = GetEntProp(i, Prop_Send, "m_iAccount");
			
			if(GetRandomInt(1,100) <= 10)
			{
				FakeClientCommand(i, "+lookatweapon");
				FakeClientCommand(i, "-lookatweapon");
			}
			
			if(m_iAccount == 800)
			{
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
	
	int rnd = GetRandomInt(1,18);
	
	switch(rnd)
	{
		case 1:
		{
			g_iCoin[client] = GetRandomInt(874,978);
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
			g_iCoin[client] = GetRandomInt(1028,1060);
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
		case 16:
		{
			g_iCoin[client] = GetRandomInt(4623,4626);
		}
		case 17:
		{
			g_iCoin[client] = GetRandomInt(4550,4553);
		}
		case 18:
		{
			g_iCoin[client] = GetRandomInt(4674,4679);
		}
	}

	int team = GetClientTeam(client);
	
	if (!client) return;
	
	if(IsValidClient(client) && IsFakeClient(client))
	{
		CreateTimer(0.1, RFrame_CheckBuyZoneValue, GetClientSerial(client)); 
		
		if(GetRandomInt(1,100) >= 10)
		{
			if(team == CS_TEAM_CT)
			{
				char usp[32];
				
				GetClientWeapon(client, usp, sizeof(usp));

				if(StrEqual(usp, "weapon_hkp2000"))
				{
					int uspslot = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
					
					if (uspslot != -1)
					{
						RemovePlayerItem(client, uspslot);
					}
					GivePlayerItem(client, "weapon_usp_silencer");
				}
			}
		}
		
		int rndm = GetRandomInt(1,2);
		
		switch(rndm)
		{
			case 1:
			{
				SetEntProp(client, Prop_Send, "m_unMusicID", GetRandomInt(3,31));
			}
			case 2:
			{
				SetEntProp(client, Prop_Send, "m_unMusicID", GetRandomInt(39,41));
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
		
		if (iPrimary == -1)
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
					SetClientMoney(client, m_iAccount - 300);
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
								SetClientMoney(client, m_iAccount - 500);
							}
							case 2:
							{
								GivePlayerItem(client, "weapon_cz75a");
								SetClientMoney(client, m_iAccount - 500);
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
	}
	else if(m_iAccount > 3000)
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

stock bool IsPointVisible(float start[3], float end[3])
{
	TR_TraceRayFilter(start, end, MASK_PLAYERSOLID, RayType_EndPoint, TraceEntityFilterStuff);
	return TR_GetFraction() >= 0.9;
}

public bool TraceEntityFilterStuff(int entity, int mask)
{
	return entity > MaxClients;
}

public bool ClientViewsFilter(int Entity, int Mask, any Junk)
{
	if (Entity >= 1 && Entity <= MaxClients) return false;
	return true;
}

stock bool IsWeaponSlotActive(int client, int slot)
{
    return GetPlayerWeaponSlot(client, slot) == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
}

stock int Client_GetClosest(float vecOrigin_center[3], int client)
{
	float vecOrigin_edict[3];
	float distance = -1.0;
	int closestEdict = -1;
	for(int i = 1; i <= MaxClients ; i++)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i) || (i == client))
			continue;
		if (!IsTargetInSightRange(client, i))
			continue;
		if (g_bFlashed[client])
			continue;
		
		GetEntPropVector(i, Prop_Data, "m_vecOrigin", vecOrigin_edict);
		GetClientEyePosition(i, vecOrigin_edict);
		if(LineGoesThroughSmoke(vecOrigin_center, vecOrigin_edict))
			continue;
		if(GetClientTeam(i) != GetClientTeam(client))
		{
			if(IsPointVisible(vecOrigin_center, vecOrigin_edict) && ClientViews(client, i))
			{
				float edict_distance = GetVectorDistance(vecOrigin_center, vecOrigin_edict);
				if((edict_distance < distance) || (distance == -1.0))
				{
					distance = edict_distance;
					closestEdict = i;
				}
			}
		}
	}
	return closestEdict;
}

stock bool ClientViews(int Viewer, int Target, float fMaxDistance=0.0, float fThreshold=0.70)
{
    // Retrieve view and target eyes position
    float fViewPos[3];   GetClientEyePosition(Viewer, fViewPos);
    float fViewAng[3];   GetClientEyeAngles(Viewer, fViewAng);
    float fViewDir[3];
    float fTargetPos[3]; GetClientEyePosition(Target, fTargetPos);
    float fTargetDir[3];
    float fDistance[3];
	
    // Calculate view direction
    fViewAng[0] = fViewAng[2] = 0.0;
    GetAngleVectors(fViewAng, fViewDir, NULL_VECTOR, NULL_VECTOR);
    
    // Calculate distance to viewer to see if it can be seen.
    fDistance[0] = fTargetPos[0]-fViewPos[0];
    fDistance[1] = fTargetPos[1]-fViewPos[1];
    fDistance[2] = 0.0;
    if (fMaxDistance != 0.0)
    {
        if (((fDistance[0]*fDistance[0])+(fDistance[1]*fDistance[1])) >= (fMaxDistance*fMaxDistance))
            return false;
    }
    
    // Check dot product. If it's negative, that means the viewer is facing
    // backwards to the target.
    NormalizeVector(fDistance, fTargetDir);
    if (GetVectorDotProduct(fViewDir, fTargetDir) < fThreshold) return false;
    
    // Now check if there are no obstacles in between through raycasting
    Handle hTrace = TR_TraceRayFilterEx(fViewPos, fTargetPos, MASK_PLAYERSOLID_BRUSHONLY, RayType_EndPoint, ClientViewsFilter);
    if (TR_DidHit(hTrace)) {CloseHandle(hTrace); return false;}
    CloseHandle(hTrace);
    
    // Done, it's visible
    return true;
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
	
	//TYLOO Players
	if((StrEqual(botname, "Summer")) || (StrEqual(botname, "Attacker")) || (StrEqual(botname, "BnTneT")) || (StrEqual(botname, "somebody")) || (StrEqual(botname, "Freeman")))
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
	if((StrEqual(botname, "tiziaN")) || (StrEqual(botname, "smooya")) || (StrEqual(botname, "XANTARES")) || (StrEqual(botname, "tabseN")) || (StrEqual(botname, "k1to")))
	{
		CS_SetClientClanTag(client, "BIG");
	}
	
	//Rejected Players
	if((StrEqual(botname, "fara")) || (StrEqual(botname, "L!nKz^")) || (StrEqual(botname, "LEEROY")) || (StrEqual(botname, "FiReMaNNN")) || (StrEqual(botname, "akz")))
	{
		CS_SetClientClanTag(client, "Rejected");
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
	if((StrEqual(botname, "oskar")) || (StrEqual(botname, "syrsoN")) || (StrEqual(botname, "Spiidi")) || (StrEqual(botname, "faveN")) || (StrEqual(botname, "denis")))
	{
		CS_SetClientClanTag(client, "Sprout");
	}
	
	//Heroic Players
	if((StrEqual(botname, "es3tag")) || (StrEqual(botname, "b0RUP")) || (StrEqual(botname, "Snappi")) || (StrEqual(botname, "cadiaN")) || (StrEqual(botname, "stavn")))
	{
		CS_SetClientClanTag(client, "Heroic");
	}
	
	//INTZ Players
	if((StrEqual(botname, "chelo")) || (StrEqual(botname, "shz")) || (StrEqual(botname, "xand")) || (StrEqual(botname, "boltz")) || (StrEqual(botname, "yeL")))
	{
		CS_SetClientClanTag(client, "INTZ");
	}
	
	//VP Players
	if((StrEqual(botname, "buster")) || (StrEqual(botname, "Jame")) || (StrEqual(botname, "qikert")) || (StrEqual(botname, "SANJI")) || (StrEqual(botname, "AdreN")))
	{
		CS_SetClientClanTag(client, "VP");
	}
	
	//Apeks Players
	if((StrEqual(botname, "Marcelious")) || (StrEqual(botname, "truth")) || (StrEqual(botname, "Grusarn")) || (StrEqual(botname, "akEz")) || (StrEqual(botname, "Radifaction")))
	{
		CS_SetClientClanTag(client, "Apeks");
	}
	
	//aTTaX Players
	if((StrEqual(botname, "stfN")) || (StrEqual(botname, "slaxz")) || (StrEqual(botname, "DuDe")) || (StrEqual(botname, "kressy")) || (StrEqual(botname, "enkay J")))
	{
		CS_SetClientClanTag(client, "aTTaX");
	}
	
	//RNG Players
	if((StrEqual(botname, "INS")) || (StrEqual(botname, "sico")) || (StrEqual(botname, "dexter")) || (StrEqual(botname, "DickStacy")) || (StrEqual(botname, "malta")))
	{
		CS_SetClientClanTag(client, "RNG");
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
	if((StrEqual(botname, "MT")) || (StrEqual(botname, "Impact")) || (StrEqual(botname, "Nukeddog")) || (StrEqual(botname, "CYPHER")) || (StrEqual(botname, "Murky")))
	{
		CS_SetClientClanTag(client, "CeX");
	}
	
	//LDLC Players
	if((StrEqual(botname, "rodeN")) || (StrEqual(botname, "Happy")) || (StrEqual(botname, "MAJ3R")) || (StrEqual(botname, "Ozstrik3r")) || (StrEqual(botname, "SIXER")))
	{
		CS_SetClientClanTag(client, "LDLC");
	}
	
	//Defusekids Players
	if((StrEqual(botname, "v1N")) || (StrEqual(botname, "G1DO")) || (StrEqual(botname, "FASHR")) || (StrEqual(botname, "D0cC")) || (StrEqual(botname, "rilax")))
	{
		CS_SetClientClanTag(client, "Defusekids");
	}
	
	//GamerLegion Players
	if((StrEqual(botname, "dennis")) || (StrEqual(botname, "nawwk")) || (StrEqual(botname, "freddieb")) || (StrEqual(botname, "RuStY")) || (StrEqual(botname, "hampus")))
	{
		CS_SetClientClanTag(client, "GamerLegion");
	}
	
	//DIVIZON Players
	if((StrEqual(botname, "slunixx")) || (StrEqual(botname, "eleKz")) || (StrEqual(botname, "hyped")) || (StrEqual(botname, "n1kista")) || (StrEqual(botname, "ykyli")))
	{
		CS_SetClientClanTag(client, "DIVIZON");
	}
	
	//EURONICS Players
	if((StrEqual(botname, "red")) || (StrEqual(botname, "maRky")) || (StrEqual(botname, "PerX")) || (StrEqual(botname, "Seeeya")) || (StrEqual(botname, "pdy")))
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
	if((StrEqual(botname, "neviZ")) || (StrEqual(botname, "synx")) || (StrEqual(botname, "delkore")) || (StrEqual(botname, "nky")) || (StrEqual(botname, "pony")))
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
	
	//GODSENT Players
	if((StrEqual(botname, "maden")) || (StrEqual(botname, "Maikelele")) || (StrEqual(botname, "kRYSTAL")) || (StrEqual(botname, "zehN")) || (StrEqual(botname, "STYKO")))
	{
		CS_SetClientClanTag(client, "GODSENT");
	}
	
	//Nordavind Players
	if((StrEqual(botname, "tenzki")) || (StrEqual(botname, "hallzerk")) || (StrEqual(botname, "RUBINO")) || (StrEqual(botname, "H4RR3")) || (StrEqual(botname, "cromen")))
	{
		CS_SetClientClanTag(client, "Nordavind");
	}
	
	//SJ Players
	if((StrEqual(botname, "arvid")) || (StrEqual(botname, "STOVVE")) || (StrEqual(botname, "SADDYX")) || (StrEqual(botname, "KHRN")) || (StrEqual(botname, "xartE")))
	{
		CS_SetClientClanTag(client, "SJ");
	}
	
	//Bren Players
	if((StrEqual(botname, "Papichulo")) || (StrEqual(botname, "witz")) || (StrEqual(botname, "Pro.")) || (StrEqual(botname, "BORKUM")) || (StrEqual(botname, "Derek")))
	{
		CS_SetClientClanTag(client, "Bren");
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
	if((StrEqual(botname, "HUNDEN")) || (StrEqual(botname, "acoR")) || (StrEqual(botname, "Sjuush")) || (StrEqual(botname, "Bubzkji")) || (StrEqual(botname, "roeJ")))
	{
		CS_SetClientClanTag(client, "Lions");
	}
	
	//Riders Players
	if((StrEqual(botname, "mopoz")) || (StrEqual(botname, "EasTor")) || (StrEqual(botname, "steel")) || (StrEqual(botname, "alex*")) || (StrEqual(botname, "loWel")))
	{
		CS_SetClientClanTag(client, "Riders");
	}
	
	//OFFSET Players
	if((StrEqual(botname, "RIZZ")) || (StrEqual(botname, "obj")) || (StrEqual(botname, "zlynx")) || (StrEqual(botname, "ZELIN")) || (StrEqual(botname, "kst")))
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
	if((StrEqual(botname, "jeyN")) || (StrEqual(botname, "Maka")) || (StrEqual(botname, "xms")) || (StrEqual(botname, "kioShiMa")) || (StrEqual(botname, "Lucky")))
	{
		CS_SetClientClanTag(client, "Heretics");
	}
	
	//Nemiga Players
	if((StrEqual(botname, "spellfull")) || (StrEqual(botname, "mds")) || (StrEqual(botname, "lollipop21k")) || (StrEqual(botname, "Jyo")) || (StrEqual(botname, "boX")))
	{
		CS_SetClientClanTag(client, "Nemiga");
	}
	
	//pro100 Players
	if((StrEqual(botname, "dimasick")) || (StrEqual(botname, "WorldEdit")) || (StrEqual(botname, "YEKINDAR")) || (StrEqual(botname, "wayLander")) || (StrEqual(botname, "NickelBack")))
	{
		CS_SetClientClanTag(client, "pro100");
	}
	
	//eUnited Players
	if((StrEqual(botname, "freakazoid")) || (StrEqual(botname, "Cooper-")) || (StrEqual(botname, "MarKE")) || (StrEqual(botname, "food")) || (StrEqual(botname, "moose")))
	{
		CS_SetClientClanTag(client, "eUnited");
	}
	
	//Mythic Players
	if((StrEqual(botname, "C0M")) || (StrEqual(botname, "fl0m")) || (StrEqual(botname, "Katie")) || (StrEqual(botname, "hazed")) || (StrEqual(botname, "SileNt")))
	{
		CS_SetClientClanTag(client, "Mythic");
	}
	
	//Singularity Players
	if((StrEqual(botname, "Zellsis")) || (StrEqual(botname, "Relyks")) || (StrEqual(botname, "seb")) || (StrEqual(botname, "dazzLe")) || (StrEqual(botname, "dapr")))
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
	if((StrEqual(botname, "RCF")) || (StrEqual(botname, "jnt")) || (StrEqual(botname, "leo_drunky")) || (StrEqual(botname, "exit")) || (StrEqual(botname, "Luken")))
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
	
	//SKADE Players
	if((StrEqual(botname, "Rock1nG")) || (StrEqual(botname, "dennyslaw")) || (StrEqual(botname, "rafftu")) || (StrEqual(botname, "Rainwaker")) || (StrEqual(botname, "SPELLAN")))
	{
		CS_SetClientClanTag(client, "SKADE");
	}
	
	//SYF Players
	if((StrEqual(botname, "ino")) || (StrEqual(botname, "Teal")) || (StrEqual(botname, "ekul")) || (StrEqual(botname, "bedonka")) || (StrEqual(botname, "urbz")))
	{
		CS_SetClientClanTag(client, "SYF");
	}
	
	//RisingStars Players
	if((StrEqual(botname, "bottle")) || (StrEqual(botname, "HZ")) || (StrEqual(botname, "xiaosaGe")) || (StrEqual(botname, "shuadapai")) || (StrEqual(botname, "Viva")))
	{
		CS_SetClientClanTag(client, "RisingStars");
	}
	
	//EHOME Players
	if((StrEqual(botname, "equal")) || (StrEqual(botname, "DeStRoYeR")) || (StrEqual(botname, "Marek")) || (StrEqual(botname, "SLOWLY")) || (StrEqual(botname, "4king")))
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
	if((StrEqual(botname, "Amaterasu")) || (StrEqual(botname, "Psy")) || (StrEqual(botname, "Excali")) || (StrEqual(botname, "skillZ")) || (StrEqual(botname, "Ace")))
	{
		CS_SetClientClanTag(client, "Entity");
	}
	
	//LucidDream Players
	if((StrEqual(botname, "wannafly")) || (StrEqual(botname, "PTC")) || (StrEqual(botname, "cbbk")) || (StrEqual(botname, "JohnOlsen")) || (StrEqual(botname, "Akino")))
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
	if((StrEqual(botname, "maxz")) || (StrEqual(botname, "Tsubasa")) || (StrEqual(botname, "jansen")) || (StrEqual(botname, "RykuN")) || (StrEqual(botname, "skillmaschine JJ_-")))
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
	
	//AVEZ Players
	if((StrEqual(botname, "MOLSI")) || (StrEqual(botname, "hades")) || (StrEqual(botname, "KEi")) || (StrEqual(botname, "Kylar")) || (StrEqual(botname, "nawrot")))
	{
		CS_SetClientClanTag(client, "AVEZ");
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
	if((StrEqual(botname, "laser")) || (StrEqual(botname, "iKrystal")) || (StrEqual(botname, "PREDI")) || (StrEqual(botname, "TISAN")) || (StrEqual(botname, "Tio")))
	{
		CS_SetClientClanTag(client, "Furious");
	}
	
	//GTZ Players
	if((StrEqual(botname, "k0mpa")) || (StrEqual(botname, "StepA")) || (StrEqual(botname, "slaxx")) || (StrEqual(botname, "Jaepe")) || (StrEqual(botname, "rafaxF")))
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
	if((StrEqual(botname, "Astroo")) || (StrEqual(botname, "Impulse")) || (StrEqual(botname, "frei")) || (StrEqual(botname, "jenko")) || (StrEqual(botname, "ardiis")))
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
	if((StrEqual(botname, "massacRe")) || (StrEqual(botname, "mango")) || (StrEqual(botname, "deviaNt")) || (StrEqual(botname, "adaro")) || (StrEqual(botname, "ZipZip")))
	{
		CS_SetClientClanTag(client, "Goliath");
	}
	
	//Secret Players
	if((StrEqual(botname, "juanflatroo")) || (StrEqual(botname, "tudsoN")) || (StrEqual(botname, "rigoN")) || (StrEqual(botname, "sinnopsyy")) || (StrEqual(botname, "anarkez")))
	{
		CS_SetClientClanTag(client, "Secret");
	}
	
	//Incept Players
	if((StrEqual(botname, "flaw")) || (StrEqual(botname, "jtr")) || (StrEqual(botname, "nettik")) || (StrEqual(botname, "DannyG")) || (StrEqual(botname, "vanilla")))
	{
		CS_SetClientClanTag(client, "Incept");
	}
	
	//MiTH Players
	if((StrEqual(botname, "NIFFY")) || (StrEqual(botname, "Leaf")) || (StrEqual(botname, "JUSTCAUSE")) || (StrEqual(botname, "Reality")) || (StrEqual(botname, "PPOverdose")))
	{
		CS_SetClientClanTag(client, "MiTH");
	}
	
	//UOL Players
	if((StrEqual(botname, "crisby")) || (StrEqual(botname, "kZyJL")) || (StrEqual(botname, "Andyy")) || (StrEqual(botname, "JDC")) || (StrEqual(botname, ".P4TriCK")))
	{
		CS_SetClientClanTag(client, "UOL");
	}
	
	//9INE Players
	if((StrEqual(botname, "ACM")) || (StrEqual(botname, "phzy")) || (StrEqual(botname, "Djury")) || (StrEqual(botname, "aybeN")) || (StrEqual(botname, "MistFire")))
	{
		CS_SetClientClanTag(client, "9INE");
	}
	
	//Baecon Players
	if((StrEqual(botname, "brA")) || (StrEqual(botname, "Demonos")) || (StrEqual(botname, "SHOUW")) || (StrEqual(botname, "horvy")) || (StrEqual(botname, "axoN")))
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
	
	//GameAgents Players
	if((StrEqual(botname, "pounh")) || (StrEqual(botname, "FliP1")) || (StrEqual(botname, "COSMEEEN")) || (StrEqual(botname, "kalle")) || (StrEqual(botname, "PALM1")))
	{
		CS_SetClientClanTag(client, "GameAgents");
	}
	
	//Orange Players
	if((StrEqual(botname, "Max")) || (StrEqual(botname, "cara")) || (StrEqual(botname, "formlesS")) || (StrEqual(botname, "Raph")) || (StrEqual(botname, "risk")))
	{
		CS_SetClientClanTag(client, "Orange");
	}
	
	//IG Players
	if((StrEqual(botname, "EXPRO")) || (StrEqual(botname, "V4D1M")) || (StrEqual(botname, "flying")) || (StrEqual(botname, "sPiNacH")) || (StrEqual(botname, "Koshak")))
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
	
	//PlanetKey Players
	if((StrEqual(botname, "xenn")) || (StrEqual(botname, "s1n")) || (StrEqual(botname, "boostey")) || (StrEqual(botname, "Kirby")) || (StrEqual(botname, "Krimbo")))
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
	if((StrEqual(botname, "Kap3r")) || (StrEqual(botname, "SZPERO")) || (StrEqual(botname, "mynio")) || (StrEqual(botname, "morelz")) || (StrEqual(botname, "jedqr")))
	{
		CS_SetClientClanTag(client, "Wisla");
	}
	
	//Imperial Players
	if((StrEqual(botname, "KHTEX")) || (StrEqual(botname, "dumau")) || (StrEqual(botname, "tatazin")) || (StrEqual(botname, "delboNi")) || (StrEqual(botname, "iDk")))
	{
		CS_SetClientClanTag(client, "Imperial");
	}
	
	//Big5 Players
	if((StrEqual(botname, "kustoM_")) || (StrEqual(botname, "Spartan")) || (StrEqual(botname, "SloWye-")) || (StrEqual(botname, "takbok")) || (StrEqual(botname, "Tiaantjie")))
	{
		CS_SetClientClanTag(client, "Big5");
	}
	
	//Unique Players
	if((StrEqual(botname, "R0b3n")) || (StrEqual(botname, "zorte")) || (StrEqual(botname, "PASHANOJ")) || (StrEqual(botname, "Polt")) || (StrEqual(botname, "fenvicious")))
	{
		CS_SetClientClanTag(client, "Unique");
	}
	
	//Izako Players
	if((StrEqual(botname, "Patitek")) || (StrEqual(botname, "Hyper")) || (StrEqual(botname, "EXUS")) || (StrEqual(botname, "Luz")) || (StrEqual(botname, "TOAO")))
	{
		CS_SetClientClanTag(client, "Izako");
	}
	
	//Riot Players
	if((StrEqual(botname, "mitch")) || (StrEqual(botname, "ptr")) || (StrEqual(botname, "crashies")) || (StrEqual(botname, "FNS")) || (StrEqual(botname, "Jonji")))
	{
		CS_SetClientClanTag(client, "Riot");
	}
	
	//Chaos Players
	if((StrEqual(botname, "cam")) || (StrEqual(botname, "wippie")) || (StrEqual(botname, "Infinite")) || (StrEqual(botname, "steel_")) || (StrEqual(botname, "ben1337")))
	{
		CS_SetClientClanTag(client, "Chaos");
	}
	
	//OneThree Players
	if((StrEqual(botname, "Dosia")) || (StrEqual(botname, "mou")) || (StrEqual(botname, "captainMo")) || (StrEqual(botname, "DD")) || (StrEqual(botname, "Karsa")))
	{
		CS_SetClientClanTag(client, "OneThree");
	}
	
	//Lynn Players
	if((StrEqual(botname, "XG")) || (StrEqual(botname, "mitsuha")) || (StrEqual(botname, "Aree")) || (StrEqual(botname, "Yvonne")) || (StrEqual(botname, "XinKoiNg")))
	{
		CS_SetClientClanTag(client, "Lynn");
	}
	
	//Triumph Players
	if((StrEqual(botname, "xCeeD")) || (StrEqual(botname, "Voltage")) || (StrEqual(botname, "Spongey")) || (StrEqual(botname, "Snakes")) || (StrEqual(botname, "Grim")))
	{
		CS_SetClientClanTag(client, "Triumph");
	}
	
	//FATE Players
	if((StrEqual(botname, "doublemagic")) || (StrEqual(botname, "KalubeR")) || (StrEqual(botname, "Duplicate")) || (StrEqual(botname, "Mar")) || (StrEqual(botname, "niki1")))
	{
		CS_SetClientClanTag(client, "FATE");
	}
	
	//Canids Players
	if((StrEqual(botname, "pesadelo")) || (StrEqual(botname, "nythonzinho")) || (StrEqual(botname, "nak")) || (StrEqual(botname, "latto")) || (StrEqual(botname, "fnx")))
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
	
	//LiViD Players
	if((StrEqual(botname, "huynh")) || (StrEqual(botname, "MkaeL")) || (StrEqual(botname, "INCRED")) || (StrEqual(botname, "gMd")) || (StrEqual(botname, "effys")))
	{
		CS_SetClientClanTag(client, "LiViD");
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
	
	if (StrEqual(sClan, "Rejected"))
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
	
	if (StrEqual(sClan, "RNG"))
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
	
	if (StrEqual(sClan, "SYF"))
	{
		g_iProfileRank[client] = 121;
	}
	
	if (StrEqual(sClan, "RisingStars"))
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
	
	if (StrEqual(sClan, "AVEZ"))
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
	
	if (StrEqual(sClan, "Secret"))
	{
		g_iProfileRank[client] = 153;
	}
	
	if (StrEqual(sClan, "Incept"))
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
	
	if (StrEqual(sClan, "LiViD"))
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
	
	if (StrEqual(sClan, "Izako"))
	{
		g_iProfileRank[client] = 181;
	}
	
	if (StrEqual(sClan, "Riot"))
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
}