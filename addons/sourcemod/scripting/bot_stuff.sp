#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#include <eItems>
#include <csutils>

char g_szMap[128];
bool g_bFreezetimeEnd = false;
bool g_bBombPlanted = false;
bool g_bBodyShot[MAXPLAYERS+1];
bool g_bHasThrownNade[MAXPLAYERS+1];
int g_iProfileRank[MAXPLAYERS+1], g_iCoin[MAXPLAYERS+1], g_iRndSmoke[MAXPLAYERS+1], g_iProfileRankOffset, g_iCoinOffset, g_iRndExecute;
Handle g_hGameConfig;
Handle g_hBotMoveTo;
Handle g_hLookupBone;
Handle g_hGetBonePosition;
Handle g_hBotAttack;
Handle g_hBotIsVisible;
Handle g_hBotIsBusy;

enum RouteType
{
	DEFAULT_ROUTE,
	FASTEST_ROUTE,
	SAFEST_ROUTE,
	RETREAT_ROUTE,
}

int g_iPatchDefIndex[] = {
	4550, 4551, 4552, 4553, 4554, 4555, 4556, 4557, 4558, 4559, 4560, 4561, 4562, 4563, 4564, 4565, 4566, 4567, 4568, 4569,
	4570, 4589, 4591, 4592, 4593, 4594, 4595, 4596, 4597, 4598, 4599, 4600
};

char g_szCTModels[][] = {
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

char g_szTModels[][] = {
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

static char g_szBotName[][] = {
	//MIBR Players
	"kNgV-",
	"FalleN",
	"fer",
	"TACO",
	"trk",
	//FaZe Players
	"olofmeister",
	"broky",
	"NiKo",
	"rain",
	"coldzera",
	//Astralis Players
	"es3tag",
	"device",
	"Bubzkji",
	"Magisk",
	"dupreeh",
	//NiP Players
	"twist",
	"Plopski",
	"nawwk",
	"hampus",
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
	"SLOWLY",
	"somebody",
	"DANK1NG",
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
	"Snappi",
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
	"dukka",
	"paredao",
	"kLv",
	//VP Players
	"YEKINDAR",
	"Jame",
	"qikert",
	"SANJI",
	"AdreN",
	//Apeks Players
	"Marcelious",
	"truth",
	"Grusarn",
	"akEz",
	"dennis",
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
	"LEGIJA",
	//Spirit Players
	"mir",
	"iDISBALANCE",
	"somedieyoung",
	"chopper",
	"magixx",
	//LDLC Players
	"afroo",
	"Lambert",
	"hAdji",
	"bodyy",
	"SIXER",
	//GamerLegion Players
	"mezii",
	"eraa",
	"Zero",
	"RuStY",
	"Adam9130",
	//DIVIZON Players
	"devus",
	"akay",
	"hyped",
	"FabeeN",
	"ykyli",
	//EYES Players
	"Zarin",
	"HTMy",
	"Hydro",
	"SativR",
	"ACTiV",
	//Wolsung Players
	"hyskeee",
	"rAW",
	"Gekons",
	"keen",
	"shield",
	//PDucks Players
	"ChLo",
	"sTaR",
	"wizzem",
	"maxz",
	"Cl34v3rs",
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
	"farlig",
	"kRYSTAL",
	"zehN",
	"STYKO",
	//Nordavind Players
	"tenzki",
	"NaToSaphiX",
	"H4RR3",
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
	"obj",
	"RIZZ",
	//Lions Players
	"AcilioN",
	"acoR",
	"Sjuush",
	"innocent",
	"roeJ",
	//Riders Players
	"mopoz",
	"shokz",
	"steel",
	"alex*",
	"larsen",
	//OFFSET Players
	"sc4rx",
	"KILLDREAM",
	"zlynx",
	"ZELIN",
	"drifking",
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
	"fostar",
	"wayLander",
	"NickelBack",
	//YaLLa Players
	"Remind",
	"DEAD",
	"Kheops",
	"Senpai",
	"Lyhn",
	//Yeah Players
	"tatazin",
	"RCF",
	"f4stzin",
	"iDk",
	"dumau",
	//Singularity Players
	"nicoodoz",
	"mertz",
	"Remoy",
	"TOBIZ",
	"Celrate",
	//DETONA Players
	"nak",
	"piria",
	"v$m",
	"Lucaozy",
	"zevy",
	//Infinity Players
	"k1Nky",
	"tor1towOw",
	"spamzzy",
	"BRUNO",
	"points",
	//Isurus Players
	"1962",
	"Noktse",
	"Reversive",
	"decov9jse",
	"caike",
	//paiN Players
	"PKL",
	"land1n",
	"NEKIZ",
	"biguzera",
	"hardzao",
	//Sharks Players
	"supLex",
	"jnt",
	"leo_drunky",
	"exit",
	"Luken",
	//One Players
	"prt",
	"Maluk3",
	"malbsMd",
	"pesadelo",
	"b4rtiN",
	//W7M Players
	"skullz",
	"raafa",
	"Tuurtle",
	"pancc",
	"realziN",
	//Avant Players
	"BL1TZ",
	"sterling",
	"apoc",
	"ofnu",
	"HaZR",
	//Chiefs Players
	"HUGHMUNGUS",
	"Vexite",
	"apocdud",
	"zeph",
	"soju_j",
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
	"Duplicate",
	"dennyslaw",
	"Oxygen",
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
	//Berzerk Players
	"SolEk",
	"s1n",
	"tahsiN",
	"syken",
	"skyye",
	//Energy Players
	"pnd",
	"disTroiT",
	"Lichl0rd",
	"Tiaantije",
	"mango",
	//Furious Players
	"nbl",
	"tom1",
	"Owensinho",
	"iKrystal",
	"pablek",
	//GroundZero Players
	"BURNRUOk",
	"Liki",
	"Llamas",
	"Noobster",
	"PEARSS",
	//AVEZ Players
	"byali",
	"Markoś",
	"KEi",
	"Kylar",
	"nawrot",
	//BTRG Players
	"Eeyore",
	"Geniuss",
	"xccurate",
	"ImpressioN",
	"XigN",
	//GTZ Players
	"deLonge",
	"hug",
	"slaxx",
	"braadz",
	"rafaxF",
	//x6tence Players
	"Queenix",
	"HECTOz",
	"HooXi",
	"refrezh",
	"Nodios",
	//Syman Players
	"neaLaN",
	"mou",
	"n0rb3r7",
	"kade0",
	"Keoz",
	//Goliath Players
	"massacRe",
	"kaNibalistic",
	"adM",
	"adaro",
	"ZipZip",
	//Secret Players
	"juanflatroo",
	"smF",
	"PERCY",
	"sinnopsyy",
	"anarkez",
	//Incept Players
	"micalis",
	"SkulL",
	"nibke",
	"Rev",
	"yourwombat",
	//UOL Players
	"crisby",
	"kZyJL",
	"Andyy",
	"JDC",
	".P4TriCK",
	//RADIX Players
	"mrhui",
	"MBL",
	"RezzeD",
	"entz",
	"CYPHER",
	//Illuminar Players
	"Vegi",
	"Snax",
	"mouz",
	"reatz",
	"mono",
	//Queso Players
	"TheClaran",
	"thinkii",
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
	"Djoko",
	//PlanetKey Players
	"LapeX",
	"Printek",
	"glaVed",
	"ND",
	"impulsG",
	//mCon Players
	"k1Nzo",
	"shaGGy",
	"luosrevo",
	"ReFuZR",
	"methoDs",
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
	"ponczek",
	"jedqr",
	//Imperial Players
	"fnx",
	"zqk",
	"dzt",
	"delboNi",
	"SHOOWTiME",
	//Pompa Players
	"iso",
	"SKRZYNKA",
	"LAYNER",
	"OLIMP",
	"blacktear5",
	//Unique Players
	"crush",
	"AiyvaN",
	"shalfey",
	"SELLTER",
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
	"SloWye",
	"Fadey",
	"Doru",
	//Chaos Players
	"Xeppaa",
	"vanity",
	"leaf",
	"steel_",
	"Jonji",
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
	"blocker",
	"Patrick",
	"harn",
	"Mar",
	"niki1",
	//Canids Players
	"DeStiNy",
	"nythonzinho",
	"heat",
	"latto",
	"KHTEX",
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
	//Wizards Players
	"krii",
	"Kvik",
	"pounh",
	"PALM1",
	"FliP1",
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
	"shinobi",
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
	"renatoohaxx",
	"BLOODZ",
	//AGF Players
	"fr0slev",
	"Kristou",
	"netrick",
	"TMB",
	"Lukki",
	//LLL Players
	"notaN",
	"G1DO",
	"marix",
	"v1N",
	"Monu",
	//GameAgents Players
	"SEMINTE",
	"r1d3r",
	"KunKKa",
	"nJ",
	"COSMEEEN",
	//Keyd Players
	"bnc",
	"mawth",
	"tifa",
	"jota",
	"puni",
	//Epsilon Players
	"ALEXJ",
	"smogger",
	"Celebrations",
	"Masti",
	"Blytz",
	//TIGER Players
	"erkaSt",
	"nin9",
	"dobu",
	"kabal",
	"ncl",
	//LEISURE Players
	"stefank0k0",
	"NIXEED",
	"JSXIce",
	"fly",
	"ser",
	//PENTA Players
	"pdy",
	"red",
	"neviZ",
	"xenn",
	"syNx",
	//FTW Players
	"sh1zlEE",
	"Jaepe",
	"brA",
	"plat",
	"Cunha",
	//Titans Players
	"simix",
	"ritchiEE",
	"Luz",
	"sarenii",
	"DENZSTOU",
	//9INE Players
	"CyderX",
	"xfl0ud",
	"qRaxs",
	"Izzy",
	"QutionerX",
	//QBF Players
	"JACKPOT",
	"Quantium",
	"Kas9k",
	"rommi",
	"lesswill",
	//Tigers Players
	"MAXX",
	"Lastík",
	"zyored",
	"wEAMO",
	"manguss",
	//9z Players
	"dgt",
	"try",
	"maxujas",
	"bit",
	"meyern",
	//Malvinas Players
	"gAtito",
	"fakzwall",
	"minimal",
	"kissmyaug",
	"rushardo",
	//Sinister5 Players
	"zerOchaNce",
	"FreakY",
	"deviaNt",
	"spoof",
	"ELUSIVE",
	//SINNERS Players
	"ZEDKO",
	"CaNNiE",
	"SHOCK",
	"beastik",
	"NEOFRAG",
	//Impact Players
	"DaneJoris",
	"JoJo",
	"tconnors",
	"viz",
	"insane",
	//ERN Players
	"j1NZO",
	"mvN",
	"Kirby",
	"FreeZe",
	"S3NSEY",
	//BL4ZE Players
	"Rossi",
	"Marzil",
	"SkRossi",
	"Raph",
	"cara",
	//Global Players
	"HellrangeR",
	"Karam1L",
	"hellff",
	"DEATHMAKER",
	"SpawN",
	//Conquer Players
	"NiNLeX",
	"RONDE",
	"S1rva",
	"jelo",
	"KonZero"
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
	
	g_hGameConfig = LoadGameConfigFile("botstuff.games");
	if (g_hGameConfig == INVALID_HANDLE)
		SetFailState("Failed to found botstuff.games game config.");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(g_hGameConfig, SDKConf_Signature, "MoveTo");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer); // Move Position As Vector, Pointer
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain); // Move Type As Integer
	if ((g_hBotMoveTo = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for MoveTo signature!");	
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(g_hGameConfig, SDKConf_Signature, "CBaseAnimating::LookupBone");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if ((g_hLookupBone = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CBaseAnimating::LookupBone signature!");
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(g_hGameConfig, SDKConf_Signature, "CBaseAnimating::GetBonePosition");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	PrepSDKCall_AddParameter(SDKType_QAngle, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	if ((g_hGetBonePosition = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CBaseAnimating::GetBonePosition signature!");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(g_hGameConfig, SDKConf_Signature, "CCSBot::Attack");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	if ((g_hBotAttack = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CCSBot::Attack signature!");
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(g_hGameConfig, SDKConf_Signature, "CCSBot::IsVisible");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hBotIsVisible = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CCSBot::IsVisible signature!");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(g_hGameConfig, SDKConf_Signature, "CCSBot::IsBusy");
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hBotIsBusy = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CCSBot::IsBusy signature!");
	
	eItems_OnItemsSynced();
	
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
	RegConsoleCmd("team_ldlc", Team_LDLC);
	RegConsoleCmd("team_gamerlegion", Team_GamerLegion);
	RegConsoleCmd("team_divizon", Team_DIVIZON);
	RegConsoleCmd("team_eyes", Team_EYES);
	RegConsoleCmd("team_wolsung", Team_Wolsung);
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
	RegConsoleCmd("team_nasr", Team_NASR);
	RegConsoleCmd("team_revolution", Team_Revolution);
	RegConsoleCmd("team_shift", Team_SHIFT);
	RegConsoleCmd("team_nxl", Team_nxl);
	RegConsoleCmd("team_berzerk", Team_Berzerk);
	RegConsoleCmd("team_energy", Team_energy);
	RegConsoleCmd("team_furious", Team_Furious);
	RegConsoleCmd("team_groundzero", Team_GroundZero);
	RegConsoleCmd("team_avez", Team_AVEZ);
	RegConsoleCmd("team_btrg", Team_BTRG);
	RegConsoleCmd("team_gtz", Team_GTZ);
	RegConsoleCmd("team_x6tence", Team_x6tence);
	RegConsoleCmd("team_syman", Team_Syman);
	RegConsoleCmd("team_goliath", Team_Goliath);
	RegConsoleCmd("team_secret", Team_Secret);
	RegConsoleCmd("team_incept", Team_Incept);
	RegConsoleCmd("team_uol", Team_UOL);
	RegConsoleCmd("team_radix", Team_RADIX);
	RegConsoleCmd("team_illuminar", Team_Illuminar);
	RegConsoleCmd("team_queso", Team_Queso);
	RegConsoleCmd("team_ig", Team_IG);
	RegConsoleCmd("team_hr", Team_HR);
	RegConsoleCmd("team_dice", Team_Dice);
	RegConsoleCmd("team_planetkey", Team_PlanetKey);
	RegConsoleCmd("team_mcon", Team_mCon);
	RegConsoleCmd("team_hle", Team_HLE);
	RegConsoleCmd("team_gambit", Team_Gambit);
	RegConsoleCmd("team_wisla", Team_Wisla);
	RegConsoleCmd("team_imperial", Team_Imperial);
	RegConsoleCmd("team_pompa", Team_Pompa);
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
	RegConsoleCmd("team_wizards", Team_Wizards);
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
	RegConsoleCmd("team_agf", Team_AGF);
	RegConsoleCmd("team_lll", Team_LLL);
	RegConsoleCmd("team_gameagents", Team_GameAgents);
	RegConsoleCmd("team_keyd", Team_Keyd);
	RegConsoleCmd("team_epsilon", Team_Epsilon);
	RegConsoleCmd("team_tiger", Team_TIGER);
	RegConsoleCmd("team_leisure", Team_LEISURE);
	RegConsoleCmd("team_penta", Team_PENTA);
	RegConsoleCmd("team_ftw", Team_FTW);
	RegConsoleCmd("team_titans", Team_Titans);
	RegConsoleCmd("team_9ine", Team_9INE);
	RegConsoleCmd("team_qbf", Team_QBF);
	RegConsoleCmd("team_tigers", Team_Tigers);
	RegConsoleCmd("team_9z", Team_9z);
	RegConsoleCmd("team_malvinas", Team_Malvinas);
	RegConsoleCmd("team_sinister5", Team_Sinister5);
	RegConsoleCmd("team_sinners", Team_SINNERS);
	RegConsoleCmd("team_impact", Team_Impact);
	RegConsoleCmd("team_ern", Team_ERN);
	RegConsoleCmd("team_bl4ze", Team_BL4ZE);
	RegConsoleCmd("team_global", Team_Global);
	RegConsoleCmd("team_conquer", Team_Conquer);
}

public Action Team_NiP(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "twist");
		ServerCommand("bot_add_ct %s", "hampus");
		ServerCommand("bot_add_ct %s", "nawwk");
		ServerCommand("bot_add_ct %s", "Plopski");
		ServerCommand("bot_add_ct %s", "REZ");
		ServerCommand("mp_teamlogo_1 nip");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "twist");
		ServerCommand("bot_add_t %s", "hampus");
		ServerCommand("bot_add_t %s", "nawwk");
		ServerCommand("bot_add_t %s", "Plopski");
		ServerCommand("bot_add_t %s", "REZ");
		ServerCommand("mp_teamlogo_2 nip");
	}
	
	return Plugin_Handled;
}

public Action Team_MIBR(int client, int iArgs)
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
		ServerCommand("bot_add_ct %s", "trk");
		ServerCommand("mp_teamlogo_1 mibr");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "kNgV-");
		ServerCommand("bot_add_t %s", "FalleN");
		ServerCommand("bot_add_t %s", "fer");
		ServerCommand("bot_add_t %s", "TACO");
		ServerCommand("bot_add_t %s", "trk");
		ServerCommand("mp_teamlogo_2 mibr");
	}
	
	return Plugin_Handled;
}

public Action Team_FaZe(int client, int iArgs)
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

public Action Team_Astralis(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "es3tag");
		ServerCommand("bot_add_ct %s", "device");
		ServerCommand("bot_add_ct %s", "Bubzkji");
		ServerCommand("bot_add_ct %s", "Magisk");
		ServerCommand("bot_add_ct %s", "dupreeh");
		ServerCommand("mp_teamlogo_1 astr");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "es3tag");
		ServerCommand("bot_add_t %s", "device");
		ServerCommand("bot_add_t %s", "Bubzkji");
		ServerCommand("bot_add_t %s", "Magisk");
		ServerCommand("bot_add_t %s", "dupreeh");
		ServerCommand("mp_teamlogo_2 astr");
	}
	
	return Plugin_Handled;
}

public Action Team_C9(int client, int iArgs)
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

public Action Team_G2(int client, int iArgs)
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

public Action Team_fnatic(int client, int iArgs)
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

public Action Team_North(int client, int iArgs)
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

public Action Team_mouz(int client, int iArgs)
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

public Action Team_TYLOO(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Summer");
		ServerCommand("bot_add_ct %s", "Attacker");
		ServerCommand("bot_add_ct %s", "SLOWLY");
		ServerCommand("bot_add_ct %s", "somebody");
		ServerCommand("bot_add_ct %s", "DANK1NG");
		ServerCommand("mp_teamlogo_1 tyl");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Summer");
		ServerCommand("bot_add_t %s", "Attacker");
		ServerCommand("bot_add_t %s", "SLOWLY");
		ServerCommand("bot_add_t %s", "somebody");
		ServerCommand("bot_add_t %s", "DANK1NG");
		ServerCommand("mp_teamlogo_2 tyl");
	}
	
	return Plugin_Handled;
}

public Action Team_EG(int client, int iArgs)
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

public Action Team_Thieves(int client, int iArgs)
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

public Action Team_NaVi(int client, int iArgs)
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

public Action Team_Liquid(int client, int iArgs)
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

public Action Team_AGO(int client, int iArgs)
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

public Action Team_ENCE(int client, int iArgs)
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

public Action Team_Vitality(int client, int iArgs)
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

public Action Team_BIG(int client, int iArgs)
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

public Action Team_FURIA(int client, int iArgs)
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

public Action Team_c0ntact(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Snappi");
		ServerCommand("bot_add_ct %s", "ottoNd");
		ServerCommand("bot_add_ct %s", "SHiPZ");
		ServerCommand("bot_add_ct %s", "emi");
		ServerCommand("bot_add_ct %s", "EspiranTo");
		ServerCommand("mp_teamlogo_1 c0n");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Snappi");
		ServerCommand("bot_add_t %s", "ottoNd");
		ServerCommand("bot_add_t %s", "SHiPZ");
		ServerCommand("bot_add_t %s", "emi");
		ServerCommand("bot_add_t %s", "EspiranTo");
		ServerCommand("mp_teamlogo_2 c0n");
	}
	
	return Plugin_Handled;
}

public Action Team_coL(int client, int iArgs)
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

public Action Team_ViCi(int client, int iArgs)
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

public Action Team_forZe(int client, int iArgs)
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

public Action Team_Winstrike(int client, int iArgs)
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

public Action Team_Sprout(int client, int iArgs)
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

public Action Team_Heroic(int client, int iArgs)
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

public Action Team_INTZ(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "maxcel");
		ServerCommand("bot_add_ct %s", "gut0");
		ServerCommand("bot_add_ct %s", "dukka");
		ServerCommand("bot_add_ct %s", "paredao");
		ServerCommand("bot_add_ct %s", "kLv");
		ServerCommand("mp_teamlogo_1 intz");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "maxcel");
		ServerCommand("bot_add_t %s", "gut0");
		ServerCommand("bot_add_t %s", "dukka");
		ServerCommand("bot_add_t %s", "paredao");
		ServerCommand("bot_add_t %s", "kLv");
		ServerCommand("mp_teamlogo_2 intz");
	}
	
	return Plugin_Handled;
}

public Action Team_VP(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "YEKINDAR");
		ServerCommand("bot_add_ct %s", "Jame");
		ServerCommand("bot_add_ct %s", "qikert");
		ServerCommand("bot_add_ct %s", "SANJI");
		ServerCommand("bot_add_ct %s", "AdreN");
		ServerCommand("mp_teamlogo_1 virtus");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "YEKINDAR");
		ServerCommand("bot_add_t %s", "Jame");
		ServerCommand("bot_add_t %s", "qikert");
		ServerCommand("bot_add_t %s", "SANJI");
		ServerCommand("bot_add_t %s", "AdreN");
		ServerCommand("mp_teamlogo_2 virtus");
	}
	
	return Plugin_Handled;
}

public Action Team_Apeks(int client, int iArgs)
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
		ServerCommand("bot_add_ct %s", "dennis");
		ServerCommand("mp_teamlogo_1 ape");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Marcelious");
		ServerCommand("bot_add_t %s", "truth");
		ServerCommand("bot_add_t %s", "Grusarn");
		ServerCommand("bot_add_t %s", "akEz");
		ServerCommand("bot_add_t %s", "dennis");
		ServerCommand("mp_teamlogo_2 ape");
	}
	
	return Plugin_Handled;
}

public Action Team_aTTaX(int client, int iArgs)
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

public Action Team_Renegades(int client, int iArgs)
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

public Action Team_Envy(int client, int iArgs)
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
		ServerCommand("bot_add_ct %s", "LEGIJA");
		ServerCommand("mp_teamlogo_1 envy");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Nifty");
		ServerCommand("bot_add_t %s", "ryann");
		ServerCommand("bot_add_t %s", "Calyx");
		ServerCommand("bot_add_t %s", "MICHU");
		ServerCommand("bot_add_t %s", "LEGIJA");
		ServerCommand("mp_teamlogo_2 envy");
	}
	
	return Plugin_Handled;
}

public Action Team_Spirit(int client, int iArgs)
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

public Action Team_LDLC(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "afroo");
		ServerCommand("bot_add_ct %s", "Lambert");
		ServerCommand("bot_add_ct %s", "hAdji");
		ServerCommand("bot_add_ct %s", "bodyy");
		ServerCommand("bot_add_ct %s", "SIXER");
		ServerCommand("mp_teamlogo_1 ldl");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "afroo");
		ServerCommand("bot_add_t %s", "Lambert");
		ServerCommand("bot_add_t %s", "hAdji");
		ServerCommand("bot_add_t %s", "bodyy");
		ServerCommand("bot_add_t %s", "SIXER");
		ServerCommand("mp_teamlogo_2 ldl");
	}
	
	return Plugin_Handled;
}

public Action Team_GamerLegion(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "mezii");
		ServerCommand("bot_add_ct %s", "eraa");
		ServerCommand("bot_add_ct %s", "Zero");
		ServerCommand("bot_add_ct %s", "RuStY");
		ServerCommand("bot_add_ct %s", "Adam9130");
		ServerCommand("mp_teamlogo_1 glegion");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "mezii");
		ServerCommand("bot_add_t %s", "eraa");
		ServerCommand("bot_add_t %s", "Zero");
		ServerCommand("bot_add_t %s", "RuStY");
		ServerCommand("bot_add_t %s", "Adam9130");
		ServerCommand("mp_teamlogo_2 glegion");
	}
	
	return Plugin_Handled;
}

public Action Team_DIVIZON(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "devus");
		ServerCommand("bot_add_ct %s", "akay");
		ServerCommand("bot_add_ct %s", "hyped");
		ServerCommand("bot_add_ct %s", "FabeeN");
		ServerCommand("bot_add_ct %s", "ykyli");
		ServerCommand("mp_teamlogo_1 divi");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "devus");
		ServerCommand("bot_add_t %s", "akay");
		ServerCommand("bot_add_t %s", "hyped");
		ServerCommand("bot_add_t %s", "FabeeN");
		ServerCommand("bot_add_t %s", "ykyli");
		ServerCommand("mp_teamlogo_2 divi");
	}
	
	return Plugin_Handled;
}

public Action Team_EYES(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Zarin");
		ServerCommand("bot_add_ct %s", "ACTiV");
		ServerCommand("bot_add_ct %s", "Hydro");
		ServerCommand("bot_add_ct %s", "SativR");
		ServerCommand("bot_add_ct %s", "HTMy");
		ServerCommand("mp_teamlogo_1 eyes");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Zarin");
		ServerCommand("bot_add_t %s", "ACTiV");
		ServerCommand("bot_add_t %s", "Hydro");
		ServerCommand("bot_add_t %s", "SativR");
		ServerCommand("bot_add_t %s", "HTMy");
		ServerCommand("mp_teamlogo_2 eyes");
	}
	
	return Plugin_Handled;
}

public Action Team_Wolsung(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "hyskeee");
		ServerCommand("bot_add_ct %s", "rAW");
		ServerCommand("bot_add_ct %s", "Gekons");
		ServerCommand("bot_add_ct %s", "keen");
		ServerCommand("bot_add_ct %s", "shield");
		ServerCommand("mp_teamlogo_1 wols");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "hyskeee");
		ServerCommand("bot_add_t %s", "rAW");
		ServerCommand("bot_add_t %s", "Gekons");
		ServerCommand("bot_add_t %s", "keen");
		ServerCommand("bot_add_t %s", "shield");
		ServerCommand("mp_teamlogo_2 wols");
	}
	
	return Plugin_Handled;
}

public Action Team_PDucks(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ChLo");
		ServerCommand("bot_add_ct %s", "sTaR");
		ServerCommand("bot_add_ct %s", "wizzem");
		ServerCommand("bot_add_ct %s", "maxz");
		ServerCommand("bot_add_ct %s", "Cl34v3rs");
		ServerCommand("mp_teamlogo_1 playin");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ChLo");
		ServerCommand("bot_add_t %s", "sTaR");
		ServerCommand("bot_add_t %s", "wizzem");
		ServerCommand("bot_add_t %s", "maxz");
		ServerCommand("bot_add_t %s", "Cl34v3rs");
		ServerCommand("mp_teamlogo_2 playin");
	}
	
	return Plugin_Handled;
}

public Action Team_HAVU(int client, int iArgs)
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

public Action Team_Lyngby(int client, int iArgs)
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

public Action Team_GODSENT(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "maden");
		ServerCommand("bot_add_ct %s", "farlig");
		ServerCommand("bot_add_ct %s", "kRYSTAL");
		ServerCommand("bot_add_ct %s", "zehN");
		ServerCommand("bot_add_ct %s", "STYKO");
		ServerCommand("mp_teamlogo_1 god");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "maden");
		ServerCommand("bot_add_t %s", "farlig");
		ServerCommand("bot_add_t %s", "kRYSTAL");
		ServerCommand("bot_add_t %s", "zehN");
		ServerCommand("bot_add_t %s", "STYKO");
		ServerCommand("mp_teamlogo_2 god");
	}
	
	return Plugin_Handled;
}

public Action Team_Nordavind(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "tenzki");
		ServerCommand("bot_add_ct %s", "NaToSaphiX");
		ServerCommand("bot_add_ct %s", "H4RR3");
		ServerCommand("bot_add_ct %s", "HS");
		ServerCommand("bot_add_ct %s", "cromen");
		ServerCommand("mp_teamlogo_1 nord");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "tenzki");
		ServerCommand("bot_add_t %s", "NaToSaphiX");
		ServerCommand("bot_add_t %s", "H4RR3");
		ServerCommand("bot_add_t %s", "HS");
		ServerCommand("bot_add_t %s", "cromen");
		ServerCommand("mp_teamlogo_2 nord");
	}
	
	return Plugin_Handled;
}

public Action Team_SJ(int client, int iArgs)
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

public Action Team_Bren(int client, int iArgs)
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

public Action Team_Giants(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "NOPEEj");
		ServerCommand("bot_add_ct %s", "fox");
		ServerCommand("bot_add_ct %s", "pr");
		ServerCommand("bot_add_ct %s", "obj");
		ServerCommand("bot_add_ct %s", "RIZZ");
		ServerCommand("mp_teamlogo_1 giant");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "NOPEEj");
		ServerCommand("bot_add_t %s", "fox");
		ServerCommand("bot_add_t %s", "pr");
		ServerCommand("bot_add_t %s", "obj");
		ServerCommand("bot_add_t %s", "RIZZ");
		ServerCommand("mp_teamlogo_2 giant");
	}
	
	return Plugin_Handled;
}

public Action Team_Lions(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "AcilioN");
		ServerCommand("bot_add_ct %s", "acoR");
		ServerCommand("bot_add_ct %s", "Sjuush");
		ServerCommand("bot_add_ct %s", "innocent");
		ServerCommand("bot_add_ct %s", "roeJ");
		ServerCommand("mp_teamlogo_1 lion");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "AcilioN");
		ServerCommand("bot_add_t %s", "acoR");
		ServerCommand("bot_add_t %s", "Sjuush");
		ServerCommand("bot_add_t %s", "innocent");
		ServerCommand("bot_add_t %s", "roeJ");
		ServerCommand("mp_teamlogo_2 lion");
	}
	
	return Plugin_Handled;
}

public Action Team_Riders(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "mopoz");
		ServerCommand("bot_add_ct %s", "shokz");
		ServerCommand("bot_add_ct %s", "steel");
		ServerCommand("bot_add_ct %s", "\"alex*\"");
		ServerCommand("bot_add_ct %s", "larsen");
		ServerCommand("mp_teamlogo_1 movis");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "mopoz");
		ServerCommand("bot_add_t %s", "shokz");
		ServerCommand("bot_add_t %s", "steel");
		ServerCommand("bot_add_t %s", "\"alex*\"");
		ServerCommand("bot_add_t %s", "larsen");
		ServerCommand("mp_teamlogo_2 movis");
	}
	
	return Plugin_Handled;
}

public Action Team_OFFSET(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "sc4rx");
		ServerCommand("bot_add_ct %s", "KILLDREAM");
		ServerCommand("bot_add_ct %s", "zlynx");
		ServerCommand("bot_add_ct %s", "ZELIN");
		ServerCommand("bot_add_ct %s", "drifking");
		ServerCommand("mp_teamlogo_1 offs");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "sc4rx");
		ServerCommand("bot_add_t %s", "KILLDREAM");
		ServerCommand("bot_add_t %s", "zlynx");
		ServerCommand("bot_add_t %s", "ZELIN");
		ServerCommand("bot_add_t %s", "drifking");
		ServerCommand("mp_teamlogo_2 offs");
	}
	
	return Plugin_Handled;
}

public Action Team_eSuba(int client, int iArgs)
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

public Action Team_Nexus(int client, int iArgs)
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

public Action Team_PACT(int client, int iArgs)
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

public Action Team_Heretics(int client, int iArgs)
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

public Action Team_Nemiga(int client, int iArgs)
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

public Action Team_pro100(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "dimasick");
		ServerCommand("bot_add_ct %s", "WorldEdit");
		ServerCommand("bot_add_ct %s", "fostar");
		ServerCommand("bot_add_ct %s", "wayLander");
		ServerCommand("bot_add_ct %s", "NickelBack");
		ServerCommand("mp_teamlogo_1 pro");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "dimasick");
		ServerCommand("bot_add_t %s", "WorldEdit");
		ServerCommand("bot_add_t %s", "fostar");
		ServerCommand("bot_add_t %s", "wayLander");
		ServerCommand("bot_add_t %s", "NickelBack");
		ServerCommand("mp_teamlogo_2 pro");
	}
	
	return Plugin_Handled;
}

public Action Team_YaLLa(int client, int iArgs)
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
		ServerCommand("bot_add_ct %s", "Lyhn");
		ServerCommand("mp_teamlogo_1 yall");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Remind");
		ServerCommand("bot_add_t %s", "DEAD");
		ServerCommand("bot_add_t %s", "Kheops");
		ServerCommand("bot_add_t %s", "Senpai");
		ServerCommand("bot_add_t %s", "Lyhn");
		ServerCommand("mp_teamlogo_2 yall");
	}
	
	return Plugin_Handled;
}

public Action Team_Yeah(int client, int iArgs)
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

public Action Team_Singularity(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "nicoodoz");
		ServerCommand("bot_add_ct %s", "mertz");
		ServerCommand("bot_add_ct %s", "Remoy");
		ServerCommand("bot_add_ct %s", "TOBIZ");
		ServerCommand("bot_add_ct %s", "Celrate");
		ServerCommand("mp_teamlogo_1 sing");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "nicoodoz");
		ServerCommand("bot_add_t %s", "mertz");
		ServerCommand("bot_add_t %s", "Remoy");
		ServerCommand("bot_add_t %s", "TOBIZ");
		ServerCommand("bot_add_t %s", "Celrate");
		ServerCommand("mp_teamlogo_2 sing");
	}
	
	return Plugin_Handled;
}

public Action Team_DETONA(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "nak");
		ServerCommand("bot_add_ct %s", "piria");
		ServerCommand("bot_add_ct %s", "v$m");
		ServerCommand("bot_add_ct %s", "Lucaozy");
		ServerCommand("bot_add_ct %s", "zevy");
		ServerCommand("mp_teamlogo_1 deto");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "nak");
		ServerCommand("bot_add_t %s", "piria");
		ServerCommand("bot_add_t %s", "v$m");
		ServerCommand("bot_add_t %s", "Lucaozy");
		ServerCommand("bot_add_t %s", "zevy");
		ServerCommand("mp_teamlogo_2 deto");
	}
	
	return Plugin_Handled;
}

public Action Team_Infinity(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "k1Nky");
		ServerCommand("bot_add_ct %s", "tor1towOw");
		ServerCommand("bot_add_ct %s", "spamzzy");
		ServerCommand("bot_add_ct %s", "BRUNO");
		ServerCommand("bot_add_ct %s", "points");
		ServerCommand("mp_teamlogo_1 infi");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "k1Nky");
		ServerCommand("bot_add_t %s", "tor1towOw");
		ServerCommand("bot_add_t %s", "spamzzy");
		ServerCommand("bot_add_t %s", "BRUNO");
		ServerCommand("bot_add_t %s", "points");
		ServerCommand("mp_teamlogo_2 infi");
	}
	
	return Plugin_Handled;
}

public Action Team_Isurus(int client, int iArgs)
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
		ServerCommand("bot_add_ct %s", "caike");
		ServerCommand("mp_teamlogo_1 isu");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "1962");
		ServerCommand("bot_add_t %s", "Noktse");
		ServerCommand("bot_add_t %s", "Reversive");
		ServerCommand("bot_add_t %s", "decov9jse");
		ServerCommand("bot_add_t %s", "caike");
		ServerCommand("mp_teamlogo_2 isu");
	}
	
	return Plugin_Handled;
}

public Action Team_paiN(int client, int iArgs)
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

public Action Team_Sharks(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "supLex");
		ServerCommand("bot_add_ct %s", "jnt");
		ServerCommand("bot_add_ct %s", "leo_drunky");
		ServerCommand("bot_add_ct %s", "exit");
		ServerCommand("bot_add_ct %s", "Luken");
		ServerCommand("mp_teamlogo_1 shark");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "supLex");
		ServerCommand("bot_add_t %s", "jnt");
		ServerCommand("bot_add_t %s", "leo_drunky");
		ServerCommand("bot_add_t %s", "exit");
		ServerCommand("bot_add_t %s", "Luken");
		ServerCommand("mp_teamlogo_2 shark");
	}
	
	return Plugin_Handled;
}

public Action Team_One(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "prt");
		ServerCommand("bot_add_ct %s", "Maluk3");
		ServerCommand("bot_add_ct %s", "malbsMd");
		ServerCommand("bot_add_ct %s", "pesadelo");
		ServerCommand("bot_add_ct %s", "b4rtiN");
		ServerCommand("mp_teamlogo_1 tone");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "prt");
		ServerCommand("bot_add_t %s", "Maluk3");
		ServerCommand("bot_add_t %s", "malbsMd");
		ServerCommand("bot_add_t %s", "pesadelo");
		ServerCommand("bot_add_t %s", "b4rtiN");
		ServerCommand("mp_teamlogo_2 tone");
	}
	
	return Plugin_Handled;
}

public Action Team_W7M(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "skullz");
		ServerCommand("bot_add_ct %s", "raafa");
		ServerCommand("bot_add_ct %s", "Tuurtle");
		ServerCommand("bot_add_ct %s", "pancc");
		ServerCommand("bot_add_ct %s", "realziN");
		ServerCommand("mp_teamlogo_1 w7m");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "skullz");
		ServerCommand("bot_add_t %s", "raafa");
		ServerCommand("bot_add_t %s", "Tuurtle");
		ServerCommand("bot_add_t %s", "pancc");
		ServerCommand("bot_add_t %s", "realziN");
		ServerCommand("mp_teamlogo_2 w7m");
	}
	
	return Plugin_Handled;
}

public Action Team_Avant(int client, int iArgs)
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

public Action Team_Chiefs(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "HUGHMUNGUS");
		ServerCommand("bot_add_ct %s", "Vexite");
		ServerCommand("bot_add_ct %s", "apocdud");
		ServerCommand("bot_add_ct %s", "zeph");
		ServerCommand("bot_add_ct %s", "soju_j");
		ServerCommand("mp_teamlogo_1 chief");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "HUGHMUNGUS");
		ServerCommand("bot_add_t %s", "Vexite");
		ServerCommand("bot_add_t %s", "apocdud");
		ServerCommand("bot_add_t %s", "zeph");
		ServerCommand("bot_add_t %s", "soju_j");
		ServerCommand("mp_teamlogo_2 chief");
	}
	
	return Plugin_Handled;
}

public Action Team_ORDER(int client, int iArgs)
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

public Action Team_BlackS(int client, int iArgs)
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

public Action Team_SKADE(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Duplicate");
		ServerCommand("bot_add_ct %s", "dennyslaw");
		ServerCommand("bot_add_ct %s", "Oxygen");
		ServerCommand("bot_add_ct %s", "Rainwaker");
		ServerCommand("bot_add_ct %s", "SPELLAN");
		ServerCommand("mp_teamlogo_1 ska");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Duplicate");
		ServerCommand("bot_add_t %s", "dennyslaw");
		ServerCommand("bot_add_t %s", "Oxygen");
		ServerCommand("bot_add_t %s", "Rainwaker");
		ServerCommand("bot_add_t %s", "SPELLAN");
		ServerCommand("mp_teamlogo_2 ska");
	}
	
	return Plugin_Handled;
}

public Action Team_Paradox(int client, int iArgs)
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

public Action Team_Beyond(int client, int iArgs)
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

public Action Team_BOOM(int client, int iArgs)
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

public Action Team_NASR(int client, int iArgs)
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

public Action Team_Revolution(int client, int iArgs)
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

public Action Team_SHIFT(int client, int iArgs)
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

public Action Team_nxl(int client, int iArgs)
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

public Action Team_Berzerk(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "SolEk");
		ServerCommand("bot_add_ct %s", "s1n");
		ServerCommand("bot_add_ct %s", "tahsiN");
		ServerCommand("bot_add_ct %s", "syken");
		ServerCommand("bot_add_ct %s", "skyye");
		ServerCommand("mp_teamlogo_1 berz");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "SolEk");
		ServerCommand("bot_add_t %s", "s1n");
		ServerCommand("bot_add_t %s", "tahsiN");
		ServerCommand("bot_add_t %s", "syken");
		ServerCommand("bot_add_t %s", "skyye");
		ServerCommand("mp_teamlogo_2 berz");
	}
	
	return Plugin_Handled;
}

public Action Team_energy(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "pnd");
		ServerCommand("bot_add_ct %s", "disTroiT");
		ServerCommand("bot_add_ct %s", "Lichl0rd");
		ServerCommand("bot_add_ct %s", "Tiaantije");
		ServerCommand("bot_add_ct %s", "mango");
		ServerCommand("mp_teamlogo_1 ener");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "pnd");
		ServerCommand("bot_add_t %s", "disTroiT");
		ServerCommand("bot_add_t %s", "Lichl0rd");
		ServerCommand("bot_add_t %s", "Tiaantije");
		ServerCommand("bot_add_t %s", "mango");
		ServerCommand("mp_teamlogo_2 ener");
	}
	
	return Plugin_Handled;
}

public Action Team_Furious(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "nbl");
		ServerCommand("bot_add_ct %s", "tom1");
		ServerCommand("bot_add_ct %s", "Owensinho");
		ServerCommand("bot_add_ct %s", "iKrystal");
		ServerCommand("bot_add_ct %s", "pablek");
		ServerCommand("mp_teamlogo_1 furio");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "nbl");
		ServerCommand("bot_add_t %s", "tom1");
		ServerCommand("bot_add_t %s", "Owensinho");
		ServerCommand("bot_add_t %s", "iKrystal");
		ServerCommand("bot_add_t %s", "pablek");
		ServerCommand("mp_teamlogo_2 furio");
	}
	
	return Plugin_Handled;
}

public Action Team_GroundZero(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "BURNRUOk");
		ServerCommand("bot_add_ct %s", "Liki");
		ServerCommand("bot_add_ct %s", "Llamas");
		ServerCommand("bot_add_ct %s", "Noobster");
		ServerCommand("bot_add_ct %s", "PEARSS");
		ServerCommand("mp_teamlogo_1 ground");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "BURNRUOk");
		ServerCommand("bot_add_t %s", "Liki");
		ServerCommand("bot_add_t %s", "Llamas");
		ServerCommand("bot_add_t %s", "Noobster");
		ServerCommand("bot_add_t %s", "PEARSS");
		ServerCommand("mp_teamlogo_2 ground");
	}
	
	return Plugin_Handled;
}

public Action Team_AVEZ(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "byali");
		ServerCommand("bot_add_ct %s", "\"Markoś\"");
		ServerCommand("bot_add_ct %s", "KEi");
		ServerCommand("bot_add_ct %s", "Kylar");
		ServerCommand("bot_add_ct %s", "nawrot");
		ServerCommand("mp_teamlogo_1 avez");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "byali");
		ServerCommand("bot_add_t %s", "\"Markoś\"");
		ServerCommand("bot_add_t %s", "KEi");
		ServerCommand("bot_add_t %s", "Kylar");
		ServerCommand("bot_add_t %s", "nawrot");
		ServerCommand("mp_teamlogo_2 avez");
	}
	
	return Plugin_Handled;
}

public Action Team_BTRG(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Eeyore");
		ServerCommand("bot_add_ct %s", "Geniuss");
		ServerCommand("bot_add_ct %s", "xccurate");
		ServerCommand("bot_add_ct %s", "ImpressioN");
		ServerCommand("bot_add_ct %s", "XigN");
		ServerCommand("mp_teamlogo_1 btrg");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Eeyore");
		ServerCommand("bot_add_t %s", "Geniuss");
		ServerCommand("bot_add_t %s", "xccurate");
		ServerCommand("bot_add_t %s", "ImpressioN");
		ServerCommand("bot_add_t %s", "XigN");
		ServerCommand("mp_teamlogo_2 btrg");
	}
	
	return Plugin_Handled;
}

public Action Team_GTZ(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "deLonge");
		ServerCommand("bot_add_ct %s", "hug");
		ServerCommand("bot_add_ct %s", "slaxx");
		ServerCommand("bot_add_ct %s", "braadz");
		ServerCommand("bot_add_ct %s", "rafaxF");
		ServerCommand("mp_teamlogo_1 gtz");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "deLonge");
		ServerCommand("bot_add_t %s", "hug");
		ServerCommand("bot_add_t %s", "slaxx");
		ServerCommand("bot_add_t %s", "braadz");
		ServerCommand("bot_add_t %s", "rafaxF");
		ServerCommand("mp_teamlogo_2 gtz");
	}
	
	return Plugin_Handled;
}

public Action Team_x6tence(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Queenix");
		ServerCommand("bot_add_ct %s", "HECTOz");
		ServerCommand("bot_add_ct %s", "HooXi");
		ServerCommand("bot_add_ct %s", "refrezh");
		ServerCommand("bot_add_ct %s", "Nodios");
		ServerCommand("mp_teamlogo_1 x6t");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Queenix");
		ServerCommand("bot_add_t %s", "HECTOz");
		ServerCommand("bot_add_t %s", "HooXi");
		ServerCommand("bot_add_t %s", "refrezh");
		ServerCommand("bot_add_t %s", "Nodios");
		ServerCommand("mp_teamlogo_2 x6t");
	}
	
	return Plugin_Handled;
}

public Action Team_Syman(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "neaLaN");
		ServerCommand("bot_add_ct %s", "mou");
		ServerCommand("bot_add_ct %s", "n0rb3r7");
		ServerCommand("bot_add_ct %s", "kade0");
		ServerCommand("bot_add_ct %s", "Keoz");
		ServerCommand("mp_teamlogo_1 syma");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "neaLaN");
		ServerCommand("bot_add_t %s", "mou");
		ServerCommand("bot_add_t %s", "n0rb3r7");
		ServerCommand("bot_add_t %s", "kade0");
		ServerCommand("bot_add_t %s", "Keoz");
		ServerCommand("mp_teamlogo_2 syma");
	}
	
	return Plugin_Handled;
}

public Action Team_Goliath(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "massacRe");
		ServerCommand("bot_add_ct %s", "kaNibalistic");
		ServerCommand("bot_add_ct %s", "adM");
		ServerCommand("bot_add_ct %s", "adaro");
		ServerCommand("bot_add_ct %s", "ZipZip");
		ServerCommand("mp_teamlogo_1 gol");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "massacRe");
		ServerCommand("bot_add_t %s", "kaNibalistic");
		ServerCommand("bot_add_t %s", "adM");
		ServerCommand("bot_add_t %s", "adaro");
		ServerCommand("bot_add_t %s", "ZipZip");
		ServerCommand("mp_teamlogo_2 gol");
	}
	
	return Plugin_Handled;
}

public Action Team_Secret(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "juanflatroo");
		ServerCommand("bot_add_ct %s", "smF");
		ServerCommand("bot_add_ct %s", "PERCY");
		ServerCommand("bot_add_ct %s", "sinnopsyy");
		ServerCommand("bot_add_ct %s", "anarkez");
		ServerCommand("mp_teamlogo_1 secr");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "juanflatroo");
		ServerCommand("bot_add_t %s", "smF");
		ServerCommand("bot_add_t %s", "PERCY");
		ServerCommand("bot_add_t %s", "sinnopsyy");
		ServerCommand("bot_add_t %s", "anarkez");
		ServerCommand("mp_teamlogo_2 secr");
	}
	
	return Plugin_Handled;
}

public Action Team_Incept(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "micalis");
		ServerCommand("bot_add_ct %s", "SkulL");
		ServerCommand("bot_add_ct %s", "nibke");
		ServerCommand("bot_add_ct %s", "Rev");
		ServerCommand("bot_add_ct %s", "yourwombat");
		ServerCommand("mp_teamlogo_1 ince");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "micalis");
		ServerCommand("bot_add_t %s", "SkulL");
		ServerCommand("bot_add_t %s", "nibke");
		ServerCommand("bot_add_t %s", "Rev");
		ServerCommand("bot_add_t %s", "yourwombat");
		ServerCommand("mp_teamlogo_2 ince");
	}
	
	return Plugin_Handled;
}

public Action Team_UOL(int client, int iArgs)
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

public Action Team_RADIX(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "mrhui");
		ServerCommand("bot_add_ct %s", "MBL");
		ServerCommand("bot_add_ct %s", "RezzeD");
		ServerCommand("bot_add_ct %s", "entz");
		ServerCommand("bot_add_ct %s", "CYPHER");
		ServerCommand("mp_teamlogo_1 radix");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "mrhui");
		ServerCommand("bot_add_t %s", "MBL");
		ServerCommand("bot_add_t %s", "RezzeD");
		ServerCommand("bot_add_t %s", "entz");
		ServerCommand("bot_add_t %s", "CYPHER");
		ServerCommand("mp_teamlogo_2 radix");
	}

	return Plugin_Handled;
}

public Action Team_Illuminar(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Vegi");
		ServerCommand("bot_add_ct %s", "Snax");
		ServerCommand("bot_add_ct %s", "mouz");
		ServerCommand("bot_add_ct %s", "reatz");
		ServerCommand("bot_add_ct %s", "mono");
		ServerCommand("mp_teamlogo_1 illu");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Vegi");
		ServerCommand("bot_add_t %s", "Snax");
		ServerCommand("bot_add_t %s", "mouz");
		ServerCommand("bot_add_t %s", "reatz");
		ServerCommand("bot_add_t %s", "mono");
		ServerCommand("mp_teamlogo_2 illu");
	}

	return Plugin_Handled;
}

public Action Team_Queso(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "TheClaran");
		ServerCommand("bot_add_ct %s", "thinkii");
		ServerCommand("bot_add_ct %s", "VARES");
		ServerCommand("bot_add_ct %s", "mik");
		ServerCommand("bot_add_ct %s", "Yaba");
		ServerCommand("mp_teamlogo_1 ques");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "TheClaran");
		ServerCommand("bot_add_t %s", "thinkii");
		ServerCommand("bot_add_t %s", "VARES");
		ServerCommand("bot_add_t %s", "mik");
		ServerCommand("bot_add_t %s", "Yaba");
		ServerCommand("mp_teamlogo_2 ques");
	}

	return Plugin_Handled;
}

public Action Team_IG(int client, int iArgs)
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

public Action Team_HR(int client, int iArgs)
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

public Action Team_Dice(int client, int iArgs)
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
		ServerCommand("bot_add_ct %s", "Djoko");
		ServerCommand("mp_teamlogo_1 dice");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "XpG");
		ServerCommand("bot_add_t %s", "nonick");
		ServerCommand("bot_add_t %s", "Kan4");
		ServerCommand("bot_add_t %s", "Polox");
		ServerCommand("bot_add_t %s", "Djoko");
		ServerCommand("mp_teamlogo_2 dice");
	}

	return Plugin_Handled;
}

public Action Team_PlanetKey(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "LapeX");
		ServerCommand("bot_add_ct %s", "Printek");
		ServerCommand("bot_add_ct %s", "glaVed");
		ServerCommand("bot_add_ct %s", "ND");
		ServerCommand("bot_add_ct %s", "impulsG");
		ServerCommand("mp_teamlogo_1 planet");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "LapeX");
		ServerCommand("bot_add_t %s", "Printek");
		ServerCommand("bot_add_t %s", "glaVed");
		ServerCommand("bot_add_t %s", "ND");
		ServerCommand("bot_add_t %s", "impulsG");
		ServerCommand("mp_teamlogo_2 planet");
	}

	return Plugin_Handled;
}

public Action Team_mCon(int client, int iArgs)
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

public Action Team_HLE(int client, int iArgs)
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

public Action Team_Gambit(int client, int iArgs)
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

public Action Team_Wisla(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "hades");
		ServerCommand("bot_add_ct %s", "SZPERO");
		ServerCommand("bot_add_ct %s", "mynio");
		ServerCommand("bot_add_ct %s", "ponczek");
		ServerCommand("bot_add_ct %s", "jedqr");
		ServerCommand("mp_teamlogo_1 wisla");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "hades");
		ServerCommand("bot_add_t %s", "SZPERO");
		ServerCommand("bot_add_t %s", "mynio");
		ServerCommand("bot_add_t %s", "ponczek");
		ServerCommand("bot_add_t %s", "jedqr");
		ServerCommand("mp_teamlogo_2 wisla");
	}

	return Plugin_Handled;
}

public Action Team_Imperial(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "fnx");
		ServerCommand("bot_add_ct %s", "zqk");
		ServerCommand("bot_add_ct %s", "dzt");
		ServerCommand("bot_add_ct %s", "delboNi");
		ServerCommand("bot_add_ct %s", "SHOOWTiME");
		ServerCommand("mp_teamlogo_1 imp");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "fnx");
		ServerCommand("bot_add_t %s", "zqk");
		ServerCommand("bot_add_t %s", "dzt");
		ServerCommand("bot_add_t %s", "delboNi");
		ServerCommand("bot_add_t %s", "SHOOWTiME");
		ServerCommand("mp_teamlogo_2 imp");
	}

	return Plugin_Handled;
}

public Action Team_Pompa(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "iso");
		ServerCommand("bot_add_ct %s", "SKRZYNKA");
		ServerCommand("bot_add_ct %s", "LAYNER");
		ServerCommand("bot_add_ct %s", "OLIMP");
		ServerCommand("bot_add_ct %s", "blacktear5");
		ServerCommand("mp_teamlogo_1 pompa");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "iso");
		ServerCommand("bot_add_t %s", "SKRZYNKA");
		ServerCommand("bot_add_t %s", "LAYNER");
		ServerCommand("bot_add_t %s", "OLIMP");
		ServerCommand("bot_add_t %s", "blacktear5");
		ServerCommand("mp_teamlogo_2 pompa");
	}

	return Plugin_Handled;
}

public Action Team_Unique(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "crush");
		ServerCommand("bot_add_ct %s", "AiyvaN");
		ServerCommand("bot_add_ct %s", "shalfey");
		ServerCommand("bot_add_ct %s", "SELLTER");
		ServerCommand("bot_add_ct %s", "fenvicious");
		ServerCommand("mp_teamlogo_1 uniq");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "crush");
		ServerCommand("bot_add_t %s", "AiyvaN");
		ServerCommand("bot_add_t %s", "shalfey");
		ServerCommand("bot_add_t %s", "SELLTER");
		ServerCommand("bot_add_t %s", "fenvicious");
		ServerCommand("mp_teamlogo_2 uniq");
	}

	return Plugin_Handled;
}

public Action Team_Izako(int client, int iArgs)
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

public Action Team_ATK(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "bLazE");
		ServerCommand("bot_add_ct %s", "MisteM");
		ServerCommand("bot_add_ct %s", "SloWye");
		ServerCommand("bot_add_ct %s", "Fadey");
		ServerCommand("bot_add_ct %s", "Doru");
		ServerCommand("mp_teamlogo_1 atk");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "bLazE");
		ServerCommand("bot_add_t %s", "MisteM");
		ServerCommand("bot_add_t %s", "SloWye");
		ServerCommand("bot_add_t %s", "Fadey");
		ServerCommand("bot_add_t %s", "Doru");
		ServerCommand("mp_teamlogo_2 atk");
	}

	return Plugin_Handled;
}

public Action Team_Chaos(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Xeppaa");
		ServerCommand("bot_add_ct %s", "vanity");
		ServerCommand("bot_add_ct %s", "leaf");
		ServerCommand("bot_add_ct %s", "steel_");
		ServerCommand("bot_add_ct %s", "Jonji");
		ServerCommand("mp_teamlogo_1 chaos");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Xeppaa");
		ServerCommand("bot_add_t %s", "vanity");
		ServerCommand("bot_add_t %s", "leaf");
		ServerCommand("bot_add_t %s", "steel_");
		ServerCommand("bot_add_t %s", "Jonji");
		ServerCommand("mp_teamlogo_2 chaos");
	}

	return Plugin_Handled;
}

public Action Team_OneThree(int client, int iArgs)
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

public Action Team_Lynn(int client, int iArgs)
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

public Action Team_Triumph(int client, int iArgs)
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

public Action Team_FATE(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "blocker");
		ServerCommand("bot_add_ct %s", "Patrick");
		ServerCommand("bot_add_ct %s", "harn");
		ServerCommand("bot_add_ct %s", "Mar");
		ServerCommand("bot_add_ct %s", "niki1");
		ServerCommand("mp_teamlogo_1 fate");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "blocker");
		ServerCommand("bot_add_t %s", "Patrick");
		ServerCommand("bot_add_t %s", "harn");
		ServerCommand("bot_add_t %s", "Mar");
		ServerCommand("bot_add_t %s", "niki1");
		ServerCommand("mp_teamlogo_2 fate");
	}

	return Plugin_Handled;
}

public Action Team_Canids(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "DeStiNy");
		ServerCommand("bot_add_ct %s", "nythonzinho");
		ServerCommand("bot_add_ct %s", "heat");
		ServerCommand("bot_add_ct %s", "latto");
		ServerCommand("bot_add_ct %s", "KHTEX");
		ServerCommand("mp_teamlogo_1 red");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "DeStiNy");
		ServerCommand("bot_add_t %s", "nythonzinho");
		ServerCommand("bot_add_t %s", "heat");
		ServerCommand("bot_add_t %s", "latto");
		ServerCommand("bot_add_t %s", "KHTEX");
		ServerCommand("mp_teamlogo_2 red");
	}

	return Plugin_Handled;
}

public Action Team_ESPADA(int client, int iArgs)
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

public Action Team_OG(int client, int iArgs)
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

public Action Team_Wizards(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "krii");
		ServerCommand("bot_add_ct %s", "Kvik");
		ServerCommand("bot_add_ct %s", "pounh");
		ServerCommand("bot_add_ct %s", "PALM1");
		ServerCommand("bot_add_ct %s", "FliP1");
		ServerCommand("mp_teamlogo_1 wiz");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "krii");
		ServerCommand("bot_add_t %s", "Kvik");
		ServerCommand("bot_add_t %s", "pounh");
		ServerCommand("bot_add_t %s", "PALM1");
		ServerCommand("bot_add_t %s", "FliP1");
		ServerCommand("mp_teamlogo_2 wiz");
	}

	return Plugin_Handled;
}

public Action Team_Tricked(int client, int iArgs)
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

public Action Team_GenG(int client, int iArgs)
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

public Action Team_Endpoint(int client, int iArgs)
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

public Action Team_sAw(int client, int iArgs)
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

public Action Team_DIG(int client, int iArgs)
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

public Action Team_D13(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Tamiraarita");
		ServerCommand("bot_add_ct %s", "rate");
		ServerCommand("bot_add_ct %s", "shinobi");
		ServerCommand("bot_add_ct %s", "sK0R");
		ServerCommand("bot_add_ct %s", "ANNIHILATION");
		ServerCommand("mp_teamlogo_1 d13");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Tamiraarita");
		ServerCommand("bot_add_t %s", "rate");
		ServerCommand("bot_add_t %s", "shinobi");
		ServerCommand("bot_add_t %s", "sK0R");
		ServerCommand("bot_add_t %s", "ANNIHILATION");
		ServerCommand("mp_teamlogo_2 d13");
	}

	return Plugin_Handled;
}

public Action Team_ZIGMA(int client, int iArgs)
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

public Action Team_Ambush(int client, int iArgs)
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

public Action Team_KOVA(int client, int iArgs)
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

public Action Team_CR4ZY(int client, int iArgs)
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

public Action Team_Redemption(int client, int iArgs)
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

public Action Team_eXploit(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "pizituh");
		ServerCommand("bot_add_ct %s", "BuJ");
		ServerCommand("bot_add_ct %s", "sark");
		ServerCommand("bot_add_ct %s", "renatoohaxx");
		ServerCommand("bot_add_ct %s", "BLOODZ");
		ServerCommand("mp_teamlogo_1 expl");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "pizituh");
		ServerCommand("bot_add_t %s", "BuJ");
		ServerCommand("bot_add_t %s", "sark");
		ServerCommand("bot_add_t %s", "renatoohaxx");
		ServerCommand("bot_add_t %s", "BLOODZ");
		ServerCommand("mp_teamlogo_2 expl");
	}

	return Plugin_Handled;
}

public Action Team_AGF(int client, int iArgs)
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

public Action Team_LLL(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "notaN");
		ServerCommand("bot_add_ct %s", "G1DO");
		ServerCommand("bot_add_ct %s", "marix");
		ServerCommand("bot_add_ct %s", "v1N");
		ServerCommand("bot_add_ct %s", "Monu");
		ServerCommand("mp_teamlogo_1 lll");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "notaN");
		ServerCommand("bot_add_t %s", "G1DO");
		ServerCommand("bot_add_t %s", "marix");
		ServerCommand("bot_add_t %s", "v1N");
		ServerCommand("bot_add_t %s", "Monu");
		ServerCommand("mp_teamlogo_2 lll");
	}

	return Plugin_Handled;
}

public Action Team_GameAgents(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "SEMINTE");
		ServerCommand("bot_add_ct %s", "r1d3r");
		ServerCommand("bot_add_ct %s", "KunKKa");
		ServerCommand("bot_add_ct %s", "nJ");
		ServerCommand("bot_add_ct %s", "COSMEEEN");
		ServerCommand("mp_teamlogo_1 game");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "SEMINTE");
		ServerCommand("bot_add_t %s", "r1d3r");
		ServerCommand("bot_add_t %s", "KunKKa");
		ServerCommand("bot_add_t %s", "nJ");
		ServerCommand("bot_add_t %s", "COSMEEEN");
		ServerCommand("mp_teamlogo_2 game");
	}

	return Plugin_Handled;
}

public Action Team_Keyd(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "bnc");
		ServerCommand("bot_add_ct %s", "mawth");
		ServerCommand("bot_add_ct %s", "tifa");
		ServerCommand("bot_add_ct %s", "jota");
		ServerCommand("bot_add_ct %s", "puni");
		ServerCommand("mp_teamlogo_1 keyds");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "bnc");
		ServerCommand("bot_add_t %s", "mawth");
		ServerCommand("bot_add_t %s", "tifa");
		ServerCommand("bot_add_t %s", "jota");
		ServerCommand("bot_add_t %s", "puni");
		ServerCommand("mp_teamlogo_2 keyds");
	}

	return Plugin_Handled;
}

public Action Team_Epsilon(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ALEXJ");
		ServerCommand("bot_add_ct %s", "smogger");
		ServerCommand("bot_add_ct %s", "Celebrations");
		ServerCommand("bot_add_ct %s", "Masti");
		ServerCommand("bot_add_ct %s", "Blytz");
		ServerCommand("mp_teamlogo_1 eps");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ALEXJ");
		ServerCommand("bot_add_t %s", "smogger");
		ServerCommand("bot_add_t %s", "Celebrations");
		ServerCommand("bot_add_t %s", "Masti");
		ServerCommand("bot_add_t %s", "Blytz");
		ServerCommand("mp_teamlogo_2 eps");
	}

	return Plugin_Handled;
}

public Action Team_TIGER(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "erkaSt");
		ServerCommand("bot_add_ct %s", "nin9");
		ServerCommand("bot_add_ct %s", "dobu");
		ServerCommand("bot_add_ct %s", "kabal");
		ServerCommand("bot_add_ct %s", "ncl");
		ServerCommand("mp_teamlogo_1 tiger");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "erkaSt");
		ServerCommand("bot_add_t %s", "nin9");
		ServerCommand("bot_add_t %s", "dobu");
		ServerCommand("bot_add_t %s", "kabal");
		ServerCommand("bot_add_t %s", "ncl");
		ServerCommand("mp_teamlogo_2 tiger");
	}

	return Plugin_Handled;
}

public Action Team_LEISURE(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "stefank0k0");
		ServerCommand("bot_add_ct %s", "NIXEED");
		ServerCommand("bot_add_ct %s", "JSXIce");
		ServerCommand("bot_add_ct %s", "fly");
		ServerCommand("bot_add_ct %s", "ser");
		ServerCommand("mp_teamlogo_1 leis");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "stefank0k0");
		ServerCommand("bot_add_t %s", "NIXEED");
		ServerCommand("bot_add_t %s", "JSXIce");
		ServerCommand("bot_add_t %s", "fly");
		ServerCommand("bot_add_t %s", "ser");
		ServerCommand("mp_teamlogo_2 leis");
	}

	return Plugin_Handled;
}

public Action Team_PENTA(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "pdy");
		ServerCommand("bot_add_ct %s", "red");
		ServerCommand("bot_add_ct %s", "neviZ");
		ServerCommand("bot_add_ct %s", "xenn");
		ServerCommand("bot_add_ct %s", "syNx");
		ServerCommand("mp_teamlogo_1 penta");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "pdy");
		ServerCommand("bot_add_t %s", "red");
		ServerCommand("bot_add_t %s", "neviZ");
		ServerCommand("bot_add_t %s", "xenn");
		ServerCommand("bot_add_t %s", "syNx");
		ServerCommand("mp_teamlogo_2 penta");
	}

	return Plugin_Handled;
}

public Action Team_FTW(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "sh1zlEE");
		ServerCommand("bot_add_ct %s", "Jaepe");
		ServerCommand("bot_add_ct %s", "brA");
		ServerCommand("bot_add_ct %s", "plat");
		ServerCommand("bot_add_ct %s", "Cunha");
		ServerCommand("mp_teamlogo_1 ftw");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "sh1zlEE");
		ServerCommand("bot_add_t %s", "Jaepe");
		ServerCommand("bot_add_t %s", "brA");
		ServerCommand("bot_add_t %s", "plat");
		ServerCommand("bot_add_t %s", "Cunha");
		ServerCommand("mp_teamlogo_2 ftw");
	}

	return Plugin_Handled;
}

public Action Team_Titans(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "simix");
		ServerCommand("bot_add_ct %s", "ritchiEE");
		ServerCommand("bot_add_ct %s", "Luz");
		ServerCommand("bot_add_ct %s", "sarenii");
		ServerCommand("bot_add_ct %s", "DENZSTOU");
		ServerCommand("mp_teamlogo_1 titans");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "simix");
		ServerCommand("bot_add_t %s", "ritchiEE");
		ServerCommand("bot_add_t %s", "Luz");
		ServerCommand("bot_add_t %s", "sarenii");
		ServerCommand("bot_add_t %s", "DENZSTOU");
		ServerCommand("mp_teamlogo_2 titans");
	}

	return Plugin_Handled;
}

public Action Team_9INE(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "CyderX");
		ServerCommand("bot_add_ct %s", "xfl0ud");
		ServerCommand("bot_add_ct %s", "qRaxs");
		ServerCommand("bot_add_ct %s", "Izzy");
		ServerCommand("bot_add_ct %s", "QutionerX");
		ServerCommand("mp_teamlogo_1 9ine");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "CyderX");
		ServerCommand("bot_add_t %s", "xfl0ud");
		ServerCommand("bot_add_t %s", "qRaxs");
		ServerCommand("bot_add_t %s", "Izzy");
		ServerCommand("bot_add_t %s", "QutionerX");
		ServerCommand("mp_teamlogo_2 9ine");
	}

	return Plugin_Handled;
}

public Action Team_QBF(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "JACKPOT");
		ServerCommand("bot_add_ct %s", "Quantium");
		ServerCommand("bot_add_ct %s", "Kas9k");
		ServerCommand("bot_add_ct %s", "rommi");
		ServerCommand("bot_add_ct %s", "lesswill");
		ServerCommand("mp_teamlogo_1 qbf");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "JACKPOT");
		ServerCommand("bot_add_t %s", "Quantium");
		ServerCommand("bot_add_t %s", "Kas9k");
		ServerCommand("bot_add_t %s", "rommi");
		ServerCommand("bot_add_t %s", "lesswill");
		ServerCommand("mp_teamlogo_2 qbf");
	}

	return Plugin_Handled;
}

public Action Team_Tigers(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "MAXX");
		ServerCommand("bot_add_ct %s", "Lastík");
		ServerCommand("bot_add_ct %s", "zyored");
		ServerCommand("bot_add_ct %s", "wEAMO");
		ServerCommand("bot_add_ct %s", "manguss");
		ServerCommand("mp_teamlogo_1 tigers");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "MAXX");
		ServerCommand("bot_add_t %s", "Lastík");
		ServerCommand("bot_add_t %s", "zyored");
		ServerCommand("bot_add_t %s", "wEAMO");
		ServerCommand("bot_add_t %s", "manguss");
		ServerCommand("mp_teamlogo_2 tigers");
	}

	return Plugin_Handled;
}

public Action Team_9z(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "dgt");
		ServerCommand("bot_add_ct %s", "try");
		ServerCommand("bot_add_ct %s", "maxujas");
		ServerCommand("bot_add_ct %s", "bit");
		ServerCommand("bot_add_ct %s", "meyern");
		ServerCommand("mp_teamlogo_1 9z");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "dgt");
		ServerCommand("bot_add_t %s", "try");
		ServerCommand("bot_add_t %s", "maxujas");
		ServerCommand("bot_add_t %s", "bit");
		ServerCommand("bot_add_t %s", "meyern");
		ServerCommand("mp_teamlogo_2 9z");
	}

	return Plugin_Handled;
}

public Action Team_Malvinas(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "gAtito");
		ServerCommand("bot_add_ct %s", "fakzwall");
		ServerCommand("bot_add_ct %s", "minimal");
		ServerCommand("bot_add_ct %s", "kissmyaug");
		ServerCommand("bot_add_ct %s", "rushardo");
		ServerCommand("mp_teamlogo_1 malv");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "gAtito");
		ServerCommand("bot_add_t %s", "fakzwall");
		ServerCommand("bot_add_t %s", "minimal");
		ServerCommand("bot_add_t %s", "kissmyaug");
		ServerCommand("bot_add_t %s", "rushardo");
		ServerCommand("mp_teamlogo_2 malv");
	}

	return Plugin_Handled;
}

public Action Team_Sinister5(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "zerOchaNce");
		ServerCommand("bot_add_ct %s", "FreakY");
		ServerCommand("bot_add_ct %s", "deviaNt");
		ServerCommand("bot_add_ct %s", "spoof");
		ServerCommand("bot_add_ct %s", "ELUSIVE");
		ServerCommand("mp_teamlogo_1 sini");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "zerOchaNce");
		ServerCommand("bot_add_t %s", "FreakY");
		ServerCommand("bot_add_t %s", "deviaNt");
		ServerCommand("bot_add_t %s", "spoof");
		ServerCommand("bot_add_t %s", "ELUSIVE");
		ServerCommand("mp_teamlogo_2 sini");
	}

	return Plugin_Handled;
}

public Action Team_SINNERS(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ZEDKO");
		ServerCommand("bot_add_ct %s", "CaNNiE");
		ServerCommand("bot_add_ct %s", "SHOCK");
		ServerCommand("bot_add_ct %s", "beastik");
		ServerCommand("bot_add_ct %s", "NEOFRAG");
		ServerCommand("mp_teamlogo_1 sinn");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ZEDKO");
		ServerCommand("bot_add_t %s", "CaNNiE");
		ServerCommand("bot_add_t %s", "SHOCK");
		ServerCommand("bot_add_t %s", "beastik");
		ServerCommand("bot_add_t %s", "NEOFRAG");
		ServerCommand("mp_teamlogo_2 sinn");
	}

	return Plugin_Handled;
}

public Action Team_Impact(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "DaneJoris");
		ServerCommand("bot_add_ct %s", "JoJo");
		ServerCommand("bot_add_ct %s", "tconnors");
		ServerCommand("bot_add_ct %s", "viz");
		ServerCommand("bot_add_ct %s", "insane");
		ServerCommand("mp_teamlogo_1 impa");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "DaneJoris");
		ServerCommand("bot_add_t %s", "JoJo");
		ServerCommand("bot_add_t %s", "tconnors");
		ServerCommand("bot_add_t %s", "viz");
		ServerCommand("bot_add_t %s", "insane");
		ServerCommand("mp_teamlogo_2 impa");
	}

	return Plugin_Handled;
}

public Action Team_ERN(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));

	if(strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "j1NZO");
		ServerCommand("bot_add_ct %s", "mvN");
		ServerCommand("bot_add_ct %s", "Kirby");
		ServerCommand("bot_add_ct %s", "FreeZe");
		ServerCommand("bot_add_ct %s", "S3NSEY");
		ServerCommand("mp_teamlogo_1 ern");
	}

	if(strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "j1NZO");
		ServerCommand("bot_add_t %s", "mvN");
		ServerCommand("bot_add_t %s", "Kirby");
		ServerCommand("bot_add_t %s", "FreeZe");
		ServerCommand("bot_add_t %s", "S3NSEY");
		ServerCommand("mp_teamlogo_2 ern");
	}

	return Plugin_Handled;
}

public Action Team_BL4ZE(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));

	if(strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Rossi");
		ServerCommand("bot_add_ct %s", "Marzil");
		ServerCommand("bot_add_ct %s", "SkRossi");
		ServerCommand("bot_add_ct %s", "Raph");
		ServerCommand("bot_add_ct %s", "cara");
		ServerCommand("mp_teamlogo_1 bl4ze");
	}

	if(strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Rossi");
		ServerCommand("bot_add_t %s", "Marzil");
		ServerCommand("bot_add_t %s", "SkRossi");
		ServerCommand("bot_add_t %s", "Raph");
		ServerCommand("bot_add_t %s", "cara");
		ServerCommand("mp_teamlogo_2 bl4ze");
	}

	return Plugin_Handled;
}

public Action Team_Global(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));

	if(strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "HellrangeR");
		ServerCommand("bot_add_ct %s", "Karam1L");
		ServerCommand("bot_add_ct %s", "hellff");
		ServerCommand("bot_add_ct %s", "DEATHMAKER");
		ServerCommand("bot_add_ct %s", "SpawN");
		ServerCommand("mp_teamlogo_1 global");
	}

	if(strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "HellrangeR");
		ServerCommand("bot_add_t %s", "Karam1L");
		ServerCommand("bot_add_t %s", "hellff");
		ServerCommand("bot_add_t %s", "DEATHMAKER");
		ServerCommand("bot_add_t %s", "SpawN");
		ServerCommand("mp_teamlogo_2 global");
	}

	return Plugin_Handled;
}

public Action Team_Conquer(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));

	if(strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "NiNLeX");
		ServerCommand("bot_add_ct %s", "RONDE");
		ServerCommand("bot_add_ct %s", "S1rva");
		ServerCommand("bot_add_ct %s", "jelo");
		ServerCommand("bot_add_ct %s", "KonZero");
		ServerCommand("mp_teamlogo_1 conq");
	}

	if(strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "NiNLeX");
		ServerCommand("bot_add_t %s", "RONDE");
		ServerCommand("bot_add_t %s", "S1rva");
		ServerCommand("bot_add_t %s", "jelo");
		ServerCommand("bot_add_t %s", "KonZero");
		ServerCommand("mp_teamlogo_2 conq");
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
	SDKHook(FindEntityByClassname(MaxClients + 1, "cs_player_manager"), SDKHook_ThinkPost, OnThinkPost);
}

public void OnMapEnd()
{
	SDKUnhook(FindEntityByClassname(MaxClients + 1, "cs_player_manager"), SDKHook_ThinkPost, OnThinkPost);
}

public void OnClientPostAdminCheck(int client)
{
	g_iProfileRank[client] = GetRandomInt(1,40);

	if(IsValidClient(client) && IsFakeClient(client))
	{
		char szBotName[512];
		GetClientName(client, szBotName, sizeof(szBotName));
		
		Pro_Players(szBotName, client);
		
		SetCustomPrivateRank(client);
		
		SDKHook(client, SDKHook_WeaponSwitch, OnWeaponSwitch);	
	}
}

public void OnRoundStart(Handle event, char[] name, bool dbc)
{	
	g_bFreezetimeEnd = false;
	g_bBombPlanted = false;
	
	for (int i = 1; i <= MaxClients; i++)
	{		
		if(eItems_AreItemsSynced() && IsValidClient(i))
		{			
			if(GetRandomInt(1,2) == 1)
			{
				g_iCoin[i] = eItems_GetCoinDefIndexByCoinNum(GetRandomInt(0, eItems_GetCoinsCount() -1));
			}
			else
			{
				g_iCoin[i] = eItems_GetPinDefIndexByPinNum(GetRandomInt(0, eItems_GetPinsCount() -1));
			}
		}
		
		if(IsValidClient(i) && IsFakeClient(i))
		{
			g_bHasThrownNade[i] = false;
			
			if(GetRandomInt(1,100) <= 35)
			{
				if(GetClientTeam(i) == CS_TEAM_CT)
				{
					SetEntityModel(i, g_szCTModels[GetRandomInt(0, sizeof(g_szCTModels) - 1)]);
					
					if(GetRandomInt(1,100) <= 40)
					{
						if(GetRandomInt(1,100) <= 75)
						{
							int iRndPatchCombo = GetRandomInt(1,14);
						
							switch (iRndPatchCombo)
							{
								case 1:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 0);
								}
								case 2:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 0);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 1);
								}
								case 3:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 0);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 2);
								}
								case 4:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 0);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 3);
								}
								case 5:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 0);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 1);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 2);
								}
								case 6:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 1);
								}
								case 7:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 1);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 2);
								}
								case 8:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 1);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 3);
								}
								case 9:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 0);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 2);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 3);
								}
								case 10:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 2);
								}
								case 11:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 2);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 3);
								}
								case 12:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 1);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 2);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 3);
								}
								case 13:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 3);
								}
								case 14:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 0);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 1);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 3);
								}
							}
						}
						else
						{
							int iRndPatchCombo = GetRandomInt(1,2);
							
							switch(iRndPatchCombo)
							{
								case 1:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 0);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 1);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 2);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 3);
								}
								case 2:
								{
									int iPatchDefIndex = g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)];
									
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", iPatchDefIndex, 4, 0);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", iPatchDefIndex, 4, 1);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", iPatchDefIndex, 4, 2);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", iPatchDefIndex, 4, 3);
								}
							}
						}
					}
				}
				else if(GetClientTeam(i) == CS_TEAM_T)
				{
					SetEntityModel(i, g_szTModels[GetRandomInt(0, sizeof(g_szTModels) - 1)]);
					
					if(GetRandomInt(1,100) <= 40)
					{
						if(GetRandomInt(1,100) <= 65)
						{
							int iRndPatchCombo = GetRandomInt(1,14);
						
							switch (iRndPatchCombo)
							{
								case 1:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 0);
								}
								case 2:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 0);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 1);
								}
								case 3:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 0);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 2);
								}
								case 4:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 0);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 3);
								}
								case 5:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 0);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 1);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 2);
								}
								case 6:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 1);
								}
								case 7:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 1);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 2);
								}
								case 8:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 1);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 3);
								}
								case 9:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 0);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 2);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 3);
								}
								case 10:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 2);
								}
								case 11:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 2);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 3);
								}
								case 12:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 1);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 2);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 3);
								}
								case 13:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 3);
								}
								case 14:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 0);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 1);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 3);
								}
							}
						}
						else
						{
							int iRndPatchCombo = GetRandomInt(1,2);
							
							switch(iRndPatchCombo)
							{
								case 1:
								{
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 0);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 1);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 2);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)], 4, 3);
								}
								case 2:
								{
									int iPatchDefIndex = g_iPatchDefIndex[GetRandomInt(0, sizeof(g_iPatchDefIndex) - 1)];
									
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", iPatchDefIndex, 4, 0);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", iPatchDefIndex, 4, 1);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", iPatchDefIndex, 4, 2);
									SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", iPatchDefIndex, 4, 3);
								}
							}
						}
					}
				}
			}
			
			if(strcmp(g_szMap, "de_mirage") == 0)
			{
				if(GetClientTeam(i) == CS_TEAM_T)
				{
					switch(g_iRndExecute)
					{
						case 1:
						{
							g_iRndSmoke[i] = GetRandomInt(1,4); //A Execute
						}
						case 2:
						{
							g_iRndSmoke[i] = GetRandomInt(5,9); //Mid Execute
						}
						case 3:
						{
							g_iRndSmoke[i] = GetRandomInt(10,15); //B Execute
						}
					}
				}
			}
			else if(strcmp(g_szMap, "de_dust2") == 0)
			{
				if(GetClientTeam(i) == CS_TEAM_T)
				{
					switch(g_iRndExecute)
					{
						case 1:
						{
							g_iRndSmoke[i] = GetRandomInt(1,2); //B Execute
						}
						case 2:
						{
							g_iRndSmoke[i] = GetRandomInt(3,4); //Mid to B Execute
						}
						case 3:
						{
							g_iRndSmoke[i] = GetRandomInt(5,8); //Short A Execute
						}
						case 4:
						{
							g_iRndSmoke[i] = GetRandomInt(9,11); //Long A Execute
						}
					}
				}
			}
		}
	}
}

public void OnFreezetimeEnd(Handle event, char[] name, bool dbc)
{
	g_bFreezetimeEnd = true;
	
	GetCurrentMap(g_szMap, sizeof(g_szMap));
	
	if(strcmp(g_szMap, "de_mirage") == 0)
	{
		g_iRndExecute = GetRandomInt(1,3);
	}
	else if(strcmp(g_szMap, "de_dust2") == 0)
	{
		g_iRndExecute = GetRandomInt(1,4);
	}
}

public void OnBombPlanted(Handle event, char[] name, bool dbc)
{
	g_bBombPlanted = true;
}

public void OnThinkPost(int iEnt)
{
	SetEntDataArray(iEnt, g_iProfileRankOffset, g_iProfileRank, MAXPLAYERS+1);
	SetEntDataArray(iEnt, g_iCoinOffset, g_iCoin, MAXPLAYERS+1);
}

public Action OnWeaponSwitch(int client, int iWeapon)
{
	if(IsValidClient(client) && IsFakeClient(client))
	{
		int iActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"); 
		if (iActiveWeapon == -1)  return Plugin_Continue;	
		
		int iDefIndex = GetEntProp(iActiveWeapon, Prop_Send, "m_iItemDefinitionIndex");
		
		if((GetAliveTeamCount(CS_TEAM_T) == 0 || GetAliveTeamCount(CS_TEAM_CT) == 0) && (iDefIndex == 41 || iDefIndex == 42 || iDefIndex == 59 || iDefIndex == 500 || iDefIndex == 503 || iDefIndex == 505 || iDefIndex == 506 || iDefIndex == 507 || iDefIndex == 508 || iDefIndex == 509 || iDefIndex == 512 || iDefIndex == 514 || iDefIndex == 515 || iDefIndex == 516 || iDefIndex == 517 || iDefIndex == 518 || iDefIndex == 519 || iDefIndex == 520 || iDefIndex == 521 || iDefIndex == 522 || iDefIndex == 523 || iDefIndex == 525))
		{
			return Plugin_Handled;
		}
	}
	
	return Plugin_Continue;
}

public Action CS_OnBuyCommand(int client, const char[] szWeapon)
{
	if(IsValidClient(client) && IsFakeClient(client))
	{	
		if(!g_bFreezetimeEnd && GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) != -1 && !((strcmp(szWeapon, "molotov") == 0 || strcmp(szWeapon, "incgrenade") == 0 || strcmp(szWeapon, "decoy") == 0 || strcmp(szWeapon, "flashbang") == 0 || strcmp(szWeapon, "hegrenade") == 0 || strcmp(szWeapon, "smokegrenade") == 0)))
		{
			return Plugin_Handled;
		}
	
		int iAccount = GetEntProp(client, Prop_Send, "m_iAccount");
		
		if(strcmp(szWeapon, "m4a1") == 0)
		{
			if(GetRandomInt(1,100) <= 30)
			{
				CSGO_SetMoney(client, iAccount - 2900);
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_m4a1_silencer");
				
				return Plugin_Handled; 
			}
			else if(GetRandomInt(1,100) <= 5)
			{
				CSGO_SetMoney(client, iAccount - 3300);
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_aug");
				
				return Plugin_Handled; 
			}
			else
			{
				return Plugin_Continue;
			}
		}
		else if(strcmp(szWeapon, "ak47") == 0)
		{
			if(GetRandomInt(1,100) <= 5)
			{
				CSGO_SetMoney(client, iAccount - 3000);
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_sg556");
				
				return Plugin_Handled; 
			}
		}
		else if(strcmp(szWeapon, "mac10") == 0)
		{
			if(GetRandomInt(1,100) <= 40)
			{
				CSGO_SetMoney(client, iAccount - 1800);
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_galilar");
				
				return Plugin_Handled; 
			}
			else
			{
				return Plugin_Continue;
			}
		}
		else if(strcmp(szWeapon, "mp9") == 0)
		{
			if(GetRandomInt(1,100) <= 40)
			{
				CSGO_SetMoney(client, iAccount - 2050);
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_famas");
				
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

public Action OnPlayerRunCmd(int client, int& iButtons, int& iImpulse, float fVel[3], float fAngles[3], int& iWeapon, int& iSubtype, int& iCmdNum, int& iTickCount, int& iSeed, int iMouse[2])
{
	if (!IsFakeClient(client)) return Plugin_Continue;
	
	int iActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"); 
	if (iActiveWeapon == -1)  return Plugin_Continue;
	
	int iDefIndex = GetEntProp(iActiveWeapon, Prop_Send, "m_iItemDefinitionIndex");
	
	if(IsValidClient(client) && IsPlayerAlive(client))
	{
		if((GetAliveTeamCount(CS_TEAM_T) == 0 || GetAliveTeamCount(CS_TEAM_CT) == 0) && !(iDefIndex == 49 || iDefIndex == 41 || iDefIndex == 42 || iDefIndex == 59 || iDefIndex == 500 || iDefIndex == 503 || iDefIndex == 505 || iDefIndex == 506 || iDefIndex == 507 || iDefIndex == 508 || iDefIndex == 509 || iDefIndex == 512 || iDefIndex == 514 || iDefIndex == 515 || iDefIndex == 516 || iDefIndex == 517 || iDefIndex == 518 || iDefIndex == 519 || iDefIndex == 520 || iDefIndex == 521 || iDefIndex == 522 || iDefIndex == 523 || iDefIndex == 525))
		{
			FakeClientCommandEx(client, "use weapon_knife");
		}

		char szBotName[512];
		GetClientName(client, szBotName, sizeof(szBotName));
		
		for(int i = 0; i <= sizeof(g_szBotName) - 1; i++)
		{
			if(strcmp(szBotName, g_szBotName[i]) == 0)
			{				
				float fClientEyes[3], fTargetEyes[3];
				GetClientEyePosition(client, fClientEyes);
				int iEnt = GetClosestClient(client);
				int iClipAmmo = GetEntProp(iActiveWeapon, Prop_Send, "m_iClip1");
				bool bInReload = view_as<bool>(GetEntProp(iActiveWeapon, Prop_Data, "m_bInReload"));
				
				if (g_bFreezetimeEnd && iClipAmmo > 0 && !bInReload)
				{
					if(IsValidClient(iEnt))
					{	
						if(GetEntityMoveType(client) == MOVETYPE_LADDER)
						{
							iButtons |= IN_JUMP;
							return Plugin_Changed;
						}
						
						GetClientAbsOrigin(iEnt, fTargetEyes);
						
						if((IsWeaponSlotActive(client, CS_SLOT_PRIMARY) && iDefIndex != 40 && iDefIndex != 11 && iDefIndex != 38 && iDefIndex != 9) || iDefIndex == 63)
						{
							if(g_bBodyShot[client])
							{
								int iBone = LookupBone(iEnt, "spine_2");
								
								if(iBone < 0)
									continue;
									
								float fBody[3], fBad[3];
								GetBonePosition(iEnt, iBone, fBody, fBad);
								
								fTargetEyes = fBody;
							}
							else
							{
								if(GetRandomInt(1,3) == 1)
								{
									int iBone = LookupBone(iEnt, "head_0");
									if(iBone < 0)
										continue;
										
									float fHead[3], fBad[3];
									GetBonePosition(iEnt, iBone, fHead, fBad);
									
									fTargetEyes = fHead;
								}
								else
								{
									int iBone = LookupBone(iEnt, "spine_2");
									
									if(iBone < 0)
										continue;
										
									float fBody[3], fBad[3];
									GetBonePosition(iEnt, iBone, fBody, fBad);
									
									if(BotIsVisible(client, fBody, false, client))
									{
										fTargetEyes = fBody;
									}
									else
									{
										iBone = LookupBone(iEnt, "head_0");
										if(iBone < 0)
											continue;
											
										float fHead[3];
										GetBonePosition(iEnt, iBone, fHead, fBad);
										
										fTargetEyes = fHead;
									}
								}	
							}
							
							if(IsTargetInSightRange(client, iEnt, 7.5))
							{
								iButtons |= IN_ATTACK;
							}
							
							if(!(GetEntityFlags(client) & FL_DUCKING))
							{
								fVel[0] = 0.0;
								fVel[1] = 0.0;
								fVel[2] = 0.0;
							}
						}
						else if(IsWeaponSlotActive(client, CS_SLOT_SECONDARY) && iDefIndex != 63 && iDefIndex != 1)
						{
							if(g_bBodyShot[client])
							{
								int iBone = LookupBone(iEnt, "spine_2");
								
								if(iBone < 0)
									continue;
									
								float fBody[3], fBad[3];
								GetBonePosition(iEnt, iBone, fBody, fBad);
								
								fTargetEyes = fBody;
							}
							else
							{
								if(GetRandomInt(1,3) == 1)
								{
									int iBone = LookupBone(iEnt, "head_0");
									if(iBone < 0)
										continue;
										
									float fHead[3], fBad[3];
									GetBonePosition(iEnt, iBone, fHead, fBad);
									
									fTargetEyes = fHead;
								}
								else
								{
									int iBone = LookupBone(iEnt, "spine_2");
									
									if(iBone < 0)
										continue;
										
									float fBody[3], fBad[3];
									GetBonePosition(iEnt, iBone, fBody, fBad);
									
									if(BotIsVisible(client, fBody, false, client))
									{
										fTargetEyes = fBody;
									}
									else
									{
										iBone = LookupBone(iEnt, "head_0");
										if(iBone < 0)
											continue;
											
										float fHead[3];
										GetBonePosition(iEnt, iBone, fHead, fBad);
										
										fTargetEyes = fHead;
									}
								}	
							}
						}
						else if(iDefIndex == 1)
						{
							if(g_bBodyShot[client])
							{
								int iBone = LookupBone(iEnt, "spine_2");
								
								if(iBone < 0)
									continue;
									
								float fBody[3], fBad[3];
								GetBonePosition(iEnt, iBone, fBody, fBad);
								
								fTargetEyes = fBody;
							}
							else
							{
								int iBone = LookupBone(iEnt, "head_0");
								if(iBone < 0)
									continue;
									
								float fHead[3], fBad[3];
								GetBonePosition(iEnt, iBone, fHead, fBad);
								
								fTargetEyes = fHead;	
							}
						}
						else if(iDefIndex == 40 || iDefIndex == 11 || iDefIndex == 38)
						{
							if(g_bBodyShot[client])
							{
								int iBone = LookupBone(iEnt, "spine_2");
								
								if(iBone < 0)
									continue;
									
								float fBody[3], fBad[3];
								GetBonePosition(iEnt, iBone, fBody, fBad);
								
								fTargetEyes = fBody;
							}
							else
							{
								if(GetRandomInt(1,3) == 1)
								{
									int iBone = LookupBone(iEnt, "head_0");
									if(iBone < 0)
										continue;
										
									float fHead[3], fBad[3];
									GetBonePosition(iEnt, iBone, fHead, fBad);
									
									fTargetEyes = fHead;
								}
								else
								{
									int iBone = LookupBone(iEnt, "spine_2");
									
									if(iBone < 0)
										continue;
										
									float fBody[3], fBad[3];
									GetBonePosition(iEnt, iBone, fBody, fBad);
									
									if(BotIsVisible(client, fBody, false, client))
									{
										fTargetEyes = fBody;
									}
									else
									{
										iBone = LookupBone(iEnt, "head_0");
										if(iBone < 0)
											continue;
											
										float fHead[3];
										GetBonePosition(iEnt, iBone, fHead, fBad);
										
										fTargetEyes = fHead;
									}
								}	
							}
						}
						else if(iDefIndex == 9)
						{							
							int iBone = LookupBone(iEnt, "spine_2");
							if(iBone < 0)
								continue;
								
							float fBody[3], fBad[3];
							GetBonePosition(iEnt, iBone, fBody, fBad);
							
							if(BotIsVisible(client, fBody, false, client))
							{
								fTargetEyes = fBody;
							}
							else
							{
								iBone = LookupBone(iEnt, "head_0");
								if(iBone < 0)
									continue;
									
								float fHead[3];
								GetBonePosition(iEnt, iBone, fHead, fBad);
								
								fTargetEyes = fHead;
							}
						}
						else
						{
							return Plugin_Continue;
						}
						
						float fEyeTarget[3];
			
						SubtractVectors(VelocityExtrapolate(iEnt, fTargetEyes), VelocityExtrapolate(client, fClientEyes), fEyeTarget);
										
						GetVectorAngles(fEyeTarget, fEyeTarget);
						
						fEyeTarget[0] = AngleNormalize(fEyeTarget[0]);
						fEyeTarget[1] = AngleNormalize(fEyeTarget[1]);
						fEyeTarget[2] = 0.0;

						float fPunch[3];
						
						GetEntPropVector(client, Prop_Send, "m_aimPunchAngle", fPunch);
						
						ScaleVector(fPunch, -(FindConVar("weapon_recoil_scale").FloatValue));
						
						AddVectors(fEyeTarget, fPunch, fEyeTarget);
						
						if(IsTargetInSightRange(client, iEnt, 7.5))
						{
							TeleportEntity(client, NULL_VECTOR, fEyeTarget, NULL_VECTOR);
						}
						else
						{
							SmoothAim(client, fEyeTarget, GetRandomFloat(0.50, 0.99));
						}
						
						BotAttack(client, iEnt);
						
						if (iButtons & IN_ATTACK)
						{
							if(iDefIndex == 7 || iDefIndex == 8 || iDefIndex == 10 || iDefIndex == 13 || iDefIndex == 14 || iDefIndex == 16 || iDefIndex == 39 || iDefIndex == 60 || iDefIndex == 28)
							{
								iButtons |= IN_DUCK;
								return Plugin_Changed;
							}
						}
						
						return Plugin_Changed;
					}
				}
				
				if(g_bFreezetimeEnd && !g_bBombPlanted && !BotIsBusy(client))
				{
					//Rifles
					int iAK47 = GetNearestEntity(client, "weapon_ak47"); 
					int iM4A1 = GetNearestEntity(client, "weapon_m4a1"); 
					int iPrimary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
					int iPrimaryDefIndex;
					
					if(IsValidEntity(iAK47))
					{
						float fAK47Location[3];
						
						if(iPrimary != -1)
						{
							iPrimaryDefIndex = GetEntProp(iPrimary, Prop_Send, "m_iItemDefinitionIndex");
						}

						if(iPrimaryDefIndex != 7 && iPrimaryDefIndex != 9)
						{
							GetEntPropVector(iAK47, Prop_Send, "m_vecOrigin", fAK47Location);
							
							if(fAK47Location[0] != 0.0 && fAK47Location[1] != 0.0 && fAK47Location[2] != 0.0)
							{
								float fClientLocation[3];
								GetClientAbsOrigin(client, fClientLocation);		
								
								float fDistance = GetVectorDistance(fClientLocation, fAK47Location);

								if(fDistance < 750)
								{
									BotMoveTo(client, fAK47Location, FASTEST_ROUTE);
								}
							}
						}
						else if(iPrimary == -1)
						{
							GetEntPropVector(iAK47, Prop_Send, "m_vecOrigin", fAK47Location);		
							
							if(fAK47Location[0] != 0.0 && fAK47Location[1] != 0.0 && fAK47Location[2] != 0.0)
							{
								float fClientLocation[3];
								GetClientAbsOrigin(client, fClientLocation);		
								
								float fDistance = GetVectorDistance(fClientLocation, fAK47Location);

								if(fDistance < 750)
								{
									BotMoveTo(client, fAK47Location, FASTEST_ROUTE);
								}
							}
						}
					}
					else if(IsValidEntity(iM4A1))
					{
						float fM4A1Location[3];
						
						if(iPrimary != -1)
						{
							iPrimaryDefIndex = GetEntProp(iPrimary, Prop_Send, "m_iItemDefinitionIndex");
						}

						if(iPrimaryDefIndex != 7 && iPrimaryDefIndex != 9 && iPrimaryDefIndex != 16 && iPrimaryDefIndex != 60)
						{
							GetEntPropVector(iM4A1, Prop_Send, "m_vecOrigin", fM4A1Location);
							
							if(fM4A1Location[0] != 0.0 && fM4A1Location[1] != 0.0 && fM4A1Location[2] != 0.0)
							{
								float fClientLocation[3];
								GetClientAbsOrigin(client, fClientLocation);	
								
								float fDistance = GetVectorDistance(fClientLocation, fM4A1Location);

								if(fDistance < 750)
								{
									BotMoveTo(client, fM4A1Location, FASTEST_ROUTE);
								}
							}
						}
						else if(iPrimary == -1)
						{
							GetEntPropVector(iM4A1, Prop_Send, "m_vecOrigin", fM4A1Location);		
							
							if(fM4A1Location[0] != 0.0 && fM4A1Location[1] != 0.0 && fM4A1Location[2] != 0.0)
							{
								float fClientLocation[3];
								GetClientAbsOrigin(client, fClientLocation);	
								
								float fDistance = GetVectorDistance(fClientLocation, fM4A1Location);

								if(fDistance < 750)
								{
									BotMoveTo(client, fM4A1Location, FASTEST_ROUTE);
								}
							}
						}
					}
					
					//Pistols
					int iUSP = GetNearestEntity(client, "weapon_hkp2000"); 
					int iP250 = GetNearestEntity(client, "weapon_p250"); 
					int iFiveSeven = GetNearestEntity(client, "weapon_fiveseven"); 
					int iTec9 = GetNearestEntity(client, "weapon_tec9"); 
					int iDeagle = GetNearestEntity(client, "weapon_deagle"); 
					int iSecondary = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
					int iSecondaryDefIndex;
					
					if(IsValidEntity(iDeagle))
					{
						float fDeagleLocation[3];
						
						if(iSecondary != -1)
						{
							iSecondaryDefIndex = GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex");
						}	
						
						if(iSecondaryDefIndex == 4 || iSecondaryDefIndex == 32 || iSecondaryDefIndex == 61 || iSecondaryDefIndex == 36 || iSecondaryDefIndex == 30 || iSecondaryDefIndex == 3 || iSecondaryDefIndex == 63)
						{
							GetEntPropVector(iDeagle, Prop_Send, "m_vecOrigin", fDeagleLocation);	
							
							if(fDeagleLocation[0] != 0.0 && fDeagleLocation[1] != 0.0 && fDeagleLocation[2] != 0.0)
							{
								float fClientLocation[3];
								GetClientAbsOrigin(client, fClientLocation);	
								
								float fDistance = GetVectorDistance(fClientLocation, fDeagleLocation);
								
								if(fDistance < 750)
								{
									BotMoveTo(client, fDeagleLocation, FASTEST_ROUTE);
								}
								
								if(fDistance < 25 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
								{
									CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false, false);
								}
							}
						}
					}
					else if(IsValidEntity(iTec9))
					{
						float fTec9Location[3];
						
						if(iSecondary != -1)
						{
							iSecondaryDefIndex = GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex");
						}	
						
						if(iSecondaryDefIndex == 4 || iSecondaryDefIndex == 32 || iSecondaryDefIndex == 61 || iSecondaryDefIndex == 36)
						{
							GetEntPropVector(iTec9, Prop_Send, "m_vecOrigin", fTec9Location);	
							
							if(fTec9Location[0] != 0.0 && fTec9Location[1] != 0.0 && fTec9Location[2] != 0.0)
							{
								float fClientLocation[3];
								GetClientAbsOrigin(client, fClientLocation);	
								
								float fDistance = GetVectorDistance(fClientLocation, fTec9Location);
								
								if(fDistance < 750)
								{
									BotMoveTo(client, fTec9Location, FASTEST_ROUTE);
								}
								
								if(fDistance < 25 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
								{
									CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false, false);
								}
							}
						}
					}
					else if(IsValidEntity(iFiveSeven))
					{
						float fFiveSevenLocation[3];
						
						if(iSecondary != -1)
						{
							iSecondaryDefIndex = GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex");
						}	
						
						if(iSecondaryDefIndex == 4 || iSecondaryDefIndex == 32 || iSecondaryDefIndex == 61 || iSecondaryDefIndex == 36)
						{
							GetEntPropVector(iFiveSeven, Prop_Send, "m_vecOrigin", fFiveSevenLocation);	
							
							if(fFiveSevenLocation[0] != 0.0 && fFiveSevenLocation[1] != 0.0 && fFiveSevenLocation[2] != 0.0)
							{
								float fClientLocation[3];
								GetClientAbsOrigin(client, fClientLocation);	
								
								float fDistance = GetVectorDistance(fClientLocation, fFiveSevenLocation);
								
								if(fDistance < 750)
								{
									BotMoveTo(client, fFiveSevenLocation, FASTEST_ROUTE);
								}
								
								if(fDistance < 25 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
								{
									CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false, false);
								}
							}
						}
					}
					else if(IsValidEntity(iP250))
					{
						float fP250Location[3];
						
						if(iSecondary != -1)
						{
							iSecondaryDefIndex = GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex");
						}	
						
						if(iSecondaryDefIndex == 4 || iSecondaryDefIndex == 32 || iSecondaryDefIndex == 61)
						{
							GetEntPropVector(iP250, Prop_Send, "m_vecOrigin", fP250Location);	
							
							if(fP250Location[0] != 0.0 && fP250Location[1] != 0.0 && fP250Location[2] != 0.0)
							{
								float fClientLocation[3];
								GetClientAbsOrigin(client, fClientLocation);	
								
								float fDistance = GetVectorDistance(fClientLocation, fP250Location);
								
								if(fDistance < 750)
								{
									BotMoveTo(client, fP250Location, FASTEST_ROUTE);
								}
								
								if(fDistance < 25 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
								{
									CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false, false);
								}
							}
						}
					}
					else if(IsValidEntity(iUSP))
					{
						float fUSPLocation[3];
						
						if(iSecondary != -1)
						{
							iSecondaryDefIndex = GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex");
						}	
						
						if(iSecondaryDefIndex == 4)
						{
							GetEntPropVector(iUSP, Prop_Send, "m_vecOrigin", fUSPLocation);	
							
							if(fUSPLocation[0] != 0.0 && fUSPLocation[1] != 0.0 && fUSPLocation[2] != 0.0)
							{
								float fClientLocation[3];
								GetClientAbsOrigin(client, fClientLocation);	
								
								float fDistance = GetVectorDistance(fClientLocation, fUSPLocation);
								
								if(fDistance < 750)
								{
									BotMoveTo(client, fUSPLocation, FASTEST_ROUTE);
								}
								
								if(fDistance < 25 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
								{
									CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false, false);
								}
							}
						}
					}
				}
				
				if (g_bFreezetimeEnd && !g_bBombPlanted && iActiveWeapon != -1)
				{
					GetCurrentMap(g_szMap, sizeof(g_szMap));
					
					if(strcmp(g_szMap, "de_mirage") == 0)
					{
						DoMirageSmokes(client);
					}
					else if(strcmp(g_szMap, "de_dust2") == 0)
					{
						DoDust2Smokes(client);
					}
				}
			}
		}
	}

	return Plugin_Continue;
}

public void CSU_OnThrowGrenade(int client, int iEntity, GrenadeType grenadeType, const float fOrigin[3], const float fVelocity[3])
{
	PrintToChat(client, "fOrigin[0] = %f;", fOrigin[0]);
	PrintToChat(client, "fOrigin[1] = %f;", fOrigin[1]);
	PrintToChat(client, "fOrigin[2] = %f;", fOrigin[2]);
	PrintToChat(client, "fVelocity[0] = %f;", fVelocity[0]);
	PrintToChat(client, "fVelocity[1] = %f;", fVelocity[1]);
	PrintToChat(client, "fVelocity[2] = %f;", fVelocity[2]);
}

public void OnPlayerSpawn(Handle hEvent, const char[] szName, bool bDontBroadcast) 
{
	for (int i = 1; i <= MaxClients; i++)
	{		
		if(IsValidClient(i) && IsFakeClient(i))
		{
			CreateTimer(0.5, RFrame_CheckBuyZoneValue, GetClientSerial(i)); 
			
			if(eItems_AreItemsSynced())
			{
				SetEntProp(i, Prop_Send, "m_unMusicID", eItems_GetMusicKitDefIndexByMusicKitNum(GetRandomInt(0, eItems_GetMusicKitsCount() -1)));
			}
			
			if(GetRandomInt(1,100) >= 15)
			{
				if(GetClientTeam(i) == CS_TEAM_CT)
				{
					char szUSP[32];
					
					GetClientWeapon(i, szUSP, sizeof(szUSP));

					if(strcmp(szUSP, "weapon_hkp2000") == 0)
					{
						CSGO_ReplaceWeapon(i, CS_SLOT_SECONDARY, "weapon_usp_silencer");
					}
				}
			}
		}
	}
}

public Action Timer_CheckPlayer(Handle hTimer, any data)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsFakeClient(i))
		{
			int iAccount = GetEntProp(i, Prop_Send, "m_iAccount");
			bool bInBuyZone = view_as<bool>(GetEntProp(i, Prop_Send, "m_bInBuyZone"));
			
			if(GetRandomInt(1,100) <= 5)
			{
				FakeClientCommandEx(i, "+lookatweapon");
				FakeClientCommandEx(i, "-lookatweapon");
			}
			
			if(iAccount == 800 && bInBuyZone)
			{
				FakeClientCommandEx(i, "buy vest");
			}
			else if(iAccount > 2500 && bInBuyZone && ((GetEntProp(i, Prop_Data, "m_ArmorValue") < 50) || (GetEntProp(i, Prop_Send, "m_bHasHelmet") == 0)))
			{
				FakeClientCommandEx(i, "buy vesthelm");
			}
		}
	}	
}

public Action RFrame_CheckBuyZoneValue(Handle hTimer, int iSerial) 
{
	int client = GetClientFromSerial(iSerial);

	if (!client || !IsClientInGame(client) || !IsPlayerAlive(client)) return Plugin_Stop;
	int iTeam = GetClientTeam(client);
	if (iTeam < 2) return Plugin_Stop;

	int iAccount = GetEntProp(client, Prop_Send, "m_iAccount");
	
	bool bInBuyZone = view_as<bool>(GetEntProp(client, Prop_Send, "m_bInBuyZone"));
	
	if (!bInBuyZone) return Plugin_Stop;
	
	int iPrimary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
	char szDefaultPrimary[64];
	GetClientWeapon(client, szDefaultPrimary, sizeof(szDefaultPrimary));

	if((iAccount > 1500) && (iAccount < 2500) && iPrimary == -1 && (strcmp(szDefaultPrimary, "weapon_hkp2000") == 0 || strcmp(szDefaultPrimary, "weapon_usp_silencer") == 0 || strcmp(szDefaultPrimary, "weapon_glock") == 0))
	{		
		int iRndPistol = GetRandomInt(1,3);
		
		switch(iRndPistol)
		{
			case 1:
			{
				CSGO_ReplaceWeapon(client, CS_SLOT_SECONDARY, "weapon_p250");
			}
			case 2:
			{
				if(iTeam == CS_TEAM_CT)
				{
					int iCZ = GetRandomInt(1,2);
					
					switch(iCZ)
					{
						case 1:
						{
							CSGO_ReplaceWeapon(client, CS_SLOT_SECONDARY, "weapon_fiveseven");
						}
						case 2:
						{
							CSGO_ReplaceWeapon(client, CS_SLOT_SECONDARY, "weapon_cz75a");
						}
					}
				}
				else if(iTeam == CS_TEAM_T)
				{
					int iCZ = GetRandomInt(1,2);
					
					switch(iCZ)
					{
						case 1:
						{
							CSGO_ReplaceWeapon(client, CS_SLOT_SECONDARY, "weapon_tec9");
						}
						case 2:
						{
							CSGO_ReplaceWeapon(client, CS_SLOT_SECONDARY, "weapon_cz75a");
						}
					}
				}
			}
			case 3:
			{
				CSGO_ReplaceWeapon(client, CS_SLOT_SECONDARY, "weapon_deagle");
			}
		}
	}
	else if(iAccount > 2500 || iPrimary != -1)
	{
		if((GetEntProp(client, Prop_Data, "m_ArmorValue") < 50) || (GetEntProp(client, Prop_Send, "m_bHasHelmet") == 0))
		{
			SetEntProp(client, Prop_Data, "m_ArmorValue", 100, 1); 
			SetEntProp(client, Prop_Send, "m_bHasHelmet", 1);
			
			CSGO_SetMoney(client, iAccount - 1000);
		}
		
		if (iTeam == CS_TEAM_CT && GetEntProp(client, Prop_Send, "m_bHasDefuser") == 0) 
		{ 
			SetEntProp(client, Prop_Send, "m_bHasDefuser", 1);
			CSGO_SetMoney(client, iAccount - 400);
		}
		
	}
	return Plugin_Stop;
}

public void OnClientDisconnect(int client)
{
	if(IsValidClient(client) && IsFakeClient(client))
	{
		g_iCoin[client] = 0;
		g_iProfileRank[client] = 0;
		SDKUnhook(client, SDKHook_WeaponSwitch, OnWeaponSwitch);
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

public void eItems_OnItemsSynced()
{
	GetCurrentMap(g_szMap, sizeof(g_szMap));
	
	ServerCommand("changelevel %s", g_szMap);
}

public void BotMoveTo(int client, float fOrigin[3], RouteType routeType)
{
	SDKCall(g_hBotMoveTo, client, fOrigin, routeType);
}

public void BotAttack(int client, int iEnemy)
{
	SDKCall(g_hBotAttack, client, iEnemy);
}

public bool BotIsVisible(int client, float fPos[3], bool bTestFOV, int iIgnore)
{
	return SDKCall(g_hBotIsVisible, client, fPos, bTestFOV, iIgnore);
}

public bool BotIsBusy(int client)
{
	return SDKCall(g_hBotIsBusy, client);
}

stock int LookupBone(int iEntity, const char[] szName)
{
	return SDKCall(g_hLookupBone, iEntity, szName);
}

stock void GetBonePosition(int iEntity, int iBone, float fOrigin[3], float fAngles[3])
{
	SDKCall(g_hGetBonePosition, iEntity, iBone, fOrigin, fAngles);
}

public int GetNearestEntity(int client, char[] szClassname)
{
    int iNearestEntity = -1;
    float fClientOrigin[3], fEntityOrigin[3];
    
    GetEntPropVector(client, Prop_Data, "m_vecOrigin", fClientOrigin); // Line 2607
    
    //Get the distance between the first entity and client
    float fDistance, fNearestDistance = -1.0;
    
    //Find all the entity and compare the distances
    int iEntity = -1;
    while ((iEntity = FindEntityByClassname(iEntity, szClassname)) != -1)
    {
        GetEntPropVector(iEntity, Prop_Data, "m_vecOrigin", fEntityOrigin); // Line 2610
        fDistance = GetVectorDistance(fClientOrigin, fEntityOrigin);
        
        if (fDistance < fNearestDistance || fNearestDistance == -1.0)
        {
            iNearestEntity = iEntity;
            fNearestDistance = fDistance;
        }
    }
    
    return iNearestEntity;
}

stock void CSGO_SetMoney(int client, int iAmount)
{
	if (iAmount < 0)
		iAmount = 0;
	
	int iMax = FindConVar("mp_maxmoney").IntValue;
	
	if (iAmount > iMax)
		iAmount = iMax;
	
	SetEntProp(client, Prop_Send, "m_iAccount", iAmount);
}

stock int CSGO_ReplaceWeapon(int client, int iSlot, const char[] szClass)
{
	int iWeapon = GetPlayerWeaponSlot(client, iSlot);

	if (IsValidEntity(iWeapon))
	{
		if (GetEntPropEnt(iWeapon, Prop_Send, "m_hOwnerEntity") != client)
			SetEntPropEnt(iWeapon, Prop_Send, "m_hOwnerEntity", client);

		CS_DropWeapon(client, iWeapon, false, true);
		AcceptEntityInput(iWeapon, "Kill");
	}

	iWeapon = GivePlayerItem(client, szClass);

	if (IsValidEntity(iWeapon))
		EquipPlayerWeapon(client, iWeapon);

	return iWeapon;
}

stock bool IsWeaponSlotActive(int client, int iSlot)
{
    return GetPlayerWeaponSlot(client, iSlot) == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
}

stock int GetClosestClient(int client)
{
	float fClientOrigin[3], fTargetOrigin[3];
	
	GetClientAbsOrigin(client, fClientOrigin);
	
	int iClientTeam = GetClientTeam(client);
	int iClosestTarget = -1;
	
	float fClosestDistance = -1.0;
	float fTargetDistance;
	int iActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	int iDefIndex;
	char szClanTag[64];
	
	CS_GetClientClanTag(client, szClanTag, sizeof(szClanTag));
	
	if(iActiveWeapon != -1)
	{
		iDefIndex = GetEntProp(iActiveWeapon, Prop_Send, "m_iItemDefinitionIndex");
	}
	
	CS_GetClientClanTag(client, szClanTag, sizeof(szClanTag));
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			if (client == i || GetClientTeam(i) == iClientTeam || !IsPlayerAlive(i))
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

			if(strcmp(szClanTag, "Heretics") == 0) //30th
			{
				if (!IsTargetInSightRange(client, i, 50.0))
					continue;	
			}
			else if(strcmp(szClanTag, "HLE") == 0) //29th
			{
				if (!IsTargetInSightRange(client, i, 60.0))
					continue;	
			}
			else if(strcmp(szClanTag, "forZe") == 0) //28th
			{
				if (!IsTargetInSightRange(client, i, 70.0))
					continue;	
			}
			else if(strcmp(szClanTag, "Gambit") == 0) //27th
			{
				if (!IsTargetInSightRange(client, i, 80.0))
					continue;	
			}
			else if(strcmp(szClanTag, "Nemiga") == 0) //26th
			{
				if (!IsTargetInSightRange(client, i, 90.0))
					continue;	
			}
			else if(strcmp(szClanTag, "VP") == 0) //25th
			{
				if (!IsTargetInSightRange(client, i, 100.0))
					continue;	
			}
			else if(strcmp(szClanTag, "North") == 0) //24th
			{
				if (!IsTargetInSightRange(client, i, 110.0))
					continue;	
			}
			else if(strcmp(szClanTag, "Lions") == 0) //23rd
			{
				if (!IsTargetInSightRange(client, i, 120.0))
					continue;	
			}
			else if(strcmp(szClanTag, "ENCE") == 0) //22nd
			{
				if (!IsTargetInSightRange(client, i, 130.0))
					continue;	
			}
			else if(strcmp(szClanTag, "C9") == 0) //21st
			{
				if (!IsTargetInSightRange(client, i, 140.0))
					continue;	
			}
			else if(strcmp(szClanTag, "Spirit") == 0) //20th
			{
				if (!IsTargetInSightRange(client, i, 150.0))
					continue;	
			}
			else if(strcmp(szClanTag, "Heroic") == 0) //19th
			{
				if (!IsTargetInSightRange(client, i, 160.0))
					continue;	
			}
			else if(strcmp(szClanTag, "GODSENT") == 0) //18th
			{
				if (!IsTargetInSightRange(client, i, 170.0))
					continue;	
			}
			else if(strcmp(szClanTag, "Thieves") == 0) //17th
			{
				if (!IsTargetInSightRange(client, i, 180.0))
					continue;	
			}
			else if(strcmp(szClanTag, "MIBR") == 0) //16th
			{
				if (!IsTargetInSightRange(client, i, 190.0))
					continue;	
			}
			else if(strcmp(szClanTag, "OG") == 0) //15th
			{
				if (!IsTargetInSightRange(client, i, 200.0))
					continue;	
			}
			else if(strcmp(szClanTag, "mouz") == 0) //14th
			{
				if (!IsTargetInSightRange(client, i, 210.0))
					continue;	
			}
			else if(strcmp(szClanTag, "Gen.G") == 0) //13th
			{
				if (!IsTargetInSightRange(client, i, 220.0))
					continue;	
			}
			else if(strcmp(szClanTag, "NiP") == 0) //12th
			{
				if (!IsTargetInSightRange(client, i, 230.0))
					continue;	
			}
			else if(strcmp(szClanTag, "Astralis") == 0) //11th
			{
				if (!IsTargetInSightRange(client, i, 240.0))
					continue;	
			}
			else if(strcmp(szClanTag, "coL") == 0) //10th
			{
				if (!IsTargetInSightRange(client, i, 250.0))
					continue;	
			}
			else if(strcmp(szClanTag, "Liquid") == 0) //9th
			{
				if (!IsTargetInSightRange(client, i, 260.0))
					continue;	
			}
			else if(strcmp(szClanTag, "FURIA") == 0) //8th
			{
				if (!IsTargetInSightRange(client, i, 270.0))
					continue;	
			}
			else if(strcmp(szClanTag, "fnatic") == 0) //7th
			{
				if (!IsTargetInSightRange(client, i, 280.0))
					continue;	
			}
			else if(strcmp(szClanTag, "FaZe") == 0) //6th
			{
				if (!IsTargetInSightRange(client, i, 290.0))
					continue;	
			}
			else if(strcmp(szClanTag, "G2") == 0) //5th
			{
				if (!IsTargetInSightRange(client, i, 300.0))
					continue;	
			}
			else if(strcmp(szClanTag, "Na´Vi") == 0) //4th
			{
				if (!IsTargetInSightRange(client, i, 310.0))
					continue;	
			}
			else if(strcmp(szClanTag, "EG") == 0) //3rd
			{
				if (!IsTargetInSightRange(client, i, 320.0))
					continue;	
			}
			else if(strcmp(szClanTag, "Vitality") == 0) //2nd
			{
				if (!IsTargetInSightRange(client, i, 330.0))
					continue;	
			}
			else if(strcmp(szClanTag, "BIG") == 0) //1st
			{
				if (!IsTargetInSightRange(client, i, 340.0))
					continue;	
			}
			else if(iDefIndex == 9)
			{
				if (!IsTargetInSightRange(client, i, 180.0))
					continue;	
			}
			else
			{
				if (!IsTargetInSightRange(client, i))
					continue;
			}
			
			fClosestDistance = fTargetDistance;
			iClosestTarget = i;
		}
	}
	
	return iClosestTarget;
}

stock bool IsTargetInSightRange(int client, int iTarget, float fAngle = 40.0, float fDistance = 0.0, bool bHeightcheck = true, bool bNegativeangle = false)
{
	if (fAngle > 360.0)
		fAngle = 360.0;
	
	if (fAngle < 0.0)
		return false;
	
	float fClientPos[3];
	float fTargetPos[3];
	float fAngleVector[3];
	float fTargetVector[3];
	float fResultAngle;
	float fResultDistance;
	
	GetClientEyeAngles(client, fAngleVector);
	fAngleVector[0] = fAngleVector[2] = 0.0;
	GetAngleVectors(fAngleVector, fAngleVector, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(fAngleVector, fAngleVector);
	if (bNegativeangle)
		NegateVector(fAngleVector);
	
	GetClientAbsOrigin(client, fClientPos);
	GetClientAbsOrigin(iTarget, fTargetPos);
	
	if (bHeightcheck && fDistance > 0)
		fResultDistance = GetVectorDistance(fClientPos, fTargetPos);
	
	fClientPos[2] = fTargetPos[2] = 0.0;
	MakeVectorFromPoints(fClientPos, fTargetPos, fTargetVector);
	NormalizeVector(fTargetVector, fTargetVector);
	
	fResultAngle = RadToDeg(ArcCosine(GetVectorDotProduct(fTargetVector, fAngleVector)));
	
	if (fResultAngle <= fAngle / 2)
	{
		if (fDistance > 0)
		{
			if (!bHeightcheck)
				fResultDistance = GetVectorDistance(fClientPos, fTargetPos);
			
			if (fDistance >= fResultDistance)
				return true;
			else return false;
		}
		else return true;
	}
	
	return false;
}

stock bool ClientCanSeeTarget(int client, int iTarget, float fDistance = 0.0, float fHeight = 50.0)
{
	float fClientEyes[3], fHead[3], fBad[3];
	
	GetClientEyePosition(client, fClientEyes);
	
	int iBone = LookupBone(iTarget, "head_0");
	if(iBone < 0)
		return false;
		
	GetBonePosition(iTarget, iBone, fHead, fBad);
	
	if(BotIsVisible(client, fHead, false, client))
	{
		g_bBodyShot[client] = false;
	}
	else
	{
		iBone = LookupBone(iTarget, "spine_2");
		if(iBone < 0)
			return false;
			
		GetBonePosition(iTarget, iBone, fHead, fBad);
		
		g_bBodyShot[client] = true;
	}
	
	if (fDistance == 0.0 || GetVectorDistance(fClientEyes, fHead, false) < fDistance)
	{
		if(BotIsVisible(client, fHead, false, client))
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	return false;
}

float[] VelocityExtrapolate(int client, float fEyePos[3])
{
	float fAbsVel[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fAbsVel);
	
	float fV[3];
	
	fV[0] = fEyePos[0] + (fAbsVel[0] * GetTickInterval());
	fV[1] = fEyePos[1] + (fAbsVel[1] * GetTickInterval());
	fV[2] = fEyePos[2] + (fAbsVel[2] * GetTickInterval());
	
	return fV;
}

public void SmoothAim(int client, float fDesiredAngles[3], float fSmoothing) 
{
	float fAngles[3], fTargetAngles[3];
	
	GetClientEyeAngles(client, fAngles);
	
	fTargetAngles[0] = fAngles[0] + AngleNormalize(fDesiredAngles[0] - fAngles[0]) * (1 - fSmoothing);
	fTargetAngles[1] = fAngles[1] + AngleNormalize(fDesiredAngles[1] - fAngles[1]) * (1 - fSmoothing);
	fTargetAngles[2] = fAngles[2];
	
	TeleportEntity(client, NULL_VECTOR, fTargetAngles, NULL_VECTOR);
}

stock float AngleNormalize(float fAngle)
{
    fAngle = fmodf(fAngle, 360.0);
    if (fAngle > 180) 
    {
        fAngle -= 360;
    }
    if (fAngle < -180)
    {
        fAngle += 360;
    }
    
    return fAngle;
}

stock float fmodf(float fNumber, float fDenom)
{
    return fNumber - RoundToFloor(fNumber / fDenom) * fDenom;
}

stock int GetAliveTeamCount(int iTeam)
{
    int iNumber = 0;
    for (int i=1; i<=MaxClients; i++)
    {
        if (IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == iTeam) 
            iNumber++;
    }
    return iNumber;
}

stock bool IsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client);
}

public void DoMirageSmokes(int client)
{
	float fClientLocation[3];

	GetClientAbsOrigin(client, fClientLocation);

	//T Side Smokes
	float fCTSmoke[3] = { 1086.446899, -1017.597046, -194.260651 };
	float fStairsSmoke[3] = { 1147.267944, -1183.978271, -141.513763 };
	float fJungleSmoke[3] = { 815.968750, -1458.905762, -44.906189 };
	float fASiteSmoke[3] = { 832.254761, -1255.159180, -44.906189 };
	float fTopMidSmoke[3] = { 1422.968750, 70.742500, -48.840103 };
	float fMidShortSmoke[3] = { 1422.968750, 34.830582, -103.906189 };
	float fWindowSmoke[3] = { 1391.968750, -1012.820801, -103.906189 };
	float fBottomConSmoke[3] = { 1135.968750, 647.975647, -197.322052 };
	float fTopConSmoke[3] = { 1391.858521, -1052.161865, -103.906189 };
	float fShortLeftSmoke[3] = { -828.584106, 522.031250, -14.286514 };
	float fShortRightSmoke[3] = { -148.031250, 353.031250, 29.634865 };
	float fBSiteSmoke[3] = { -735.981140, 623.975159, -11.906189 };
	float fBackOfBSmoke[3] = { -783.987061, 623.968750, -11.906189 };
	float fMarketDoorSmoke[3] = { -160.031250, 887.968750, -71.265564 };
	float fMarketWindowSmoke[3] = { -160.031250, 887.968750, -71.265564 };

	float fCTSmokeDis, fStairsSmokeDis, fJungleSmokeDis, fASiteSmokeDis, fTopMidSmokeDis, fMidShortSmokeDis, fWindowSmokeDis, fBottomConSmokeDis, fTopConSmokeDis,
	fShotLeftSmokeDis, fShortRightSmokeDis, fBSiteSmokeDis, fBackOfBSmokeDis, fMarketDoorSmokeDis, fMarketWindowSmokeDis;

	fCTSmokeDis = GetVectorDistance(fClientLocation, fCTSmoke);
	fStairsSmokeDis = GetVectorDistance(fClientLocation, fStairsSmoke);
	fJungleSmokeDis = GetVectorDistance(fClientLocation, fJungleSmoke);
	fASiteSmokeDis = GetVectorDistance(fClientLocation, fASiteSmoke);
	fTopMidSmokeDis = GetVectorDistance(fClientLocation, fTopMidSmoke);
	fMidShortSmokeDis = GetVectorDistance(fClientLocation, fMidShortSmoke);
	fWindowSmokeDis = GetVectorDistance(fClientLocation, fWindowSmoke);
	fBottomConSmokeDis = GetVectorDistance(fClientLocation, fBottomConSmoke);
	fTopConSmokeDis = GetVectorDistance(fClientLocation, fTopConSmoke);
	fShotLeftSmokeDis = GetVectorDistance(fClientLocation, fShortLeftSmoke);
	fShortRightSmokeDis = GetVectorDistance(fClientLocation, fShortRightSmoke);
	fBSiteSmokeDis = GetVectorDistance(fClientLocation, fBSiteSmoke);
	fBackOfBSmokeDis = GetVectorDistance(fClientLocation, fBackOfBSmoke);
	fMarketDoorSmokeDis = GetVectorDistance(fClientLocation, fMarketDoorSmoke);
	fMarketWindowSmokeDis = GetVectorDistance(fClientLocation, fMarketWindowSmoke);

	if(GetClientTeam(client) == CS_TEAM_T && !g_bHasThrownNade[client])
	{
		switch(g_iRndSmoke[client])
		{
			case 1: //CT Smoke
			{
				BotMoveTo(client, fCTSmoke, SAFEST_ROUTE);
				if(fCTSmokeDis < 75)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 1062.801147;
					fOrigin[1] = -1034.311279;
					fOrigin[2] = -133.976730;
					
					fVelocity[0] = -441.676635;
					fVelocity[1] = -315.539398;
					fVelocity[2] = 635.904418;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 2: //Stairs Smoke
			{
				BotMoveTo(client, fStairsSmoke, SAFEST_ROUTE);
				if(fStairsSmokeDis < 75)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 1122.941772;
					fOrigin[1] = -1190.644775;
					fOrigin[2] = -115.101257;
					
					fVelocity[0] = -453.966583;
					fVelocity[1] = -121.504554;
					fVelocity[2] = 474.536865;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 3: //Jungle Smoke
			{
				BotMoveTo(client, fJungleSmoke, SAFEST_ROUTE);
				if(fJungleSmokeDis < 75)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 785.399047;
					fOrigin[1] = -1461.760742;
					fOrigin[2] = -24.280895;
					
					fVelocity[0] = -556.280883;
					fVelocity[1] = -48.018508;
					fVelocity[2] = 369.303039;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 4: //A Site Smoke
			{
				BotMoveTo(client, fASiteSmoke, SAFEST_ROUTE);
				if(fASiteSmokeDis < 75)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 805.123046;
					fOrigin[1] = -1270.940185;
					fOrigin[2] = -25.209976;
					
					fVelocity[0] = -491.993682;
					fVelocity[1] = -286.768341;
					fVelocity[2] = 352.396392;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 5: //Top-Mid Smoke
			{
				BotMoveTo(client, fTopMidSmoke, SAFEST_ROUTE);
				if(fTopMidSmokeDis < 75)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 1395.172973;
					fOrigin[1] = 63.584007;
					fOrigin[2] = -25.641843;
					
					fVelocity[0] = -505.804138;
					fVelocity[1] = -134.928771;
					fVelocity[2] = 416.123657;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 6: //Mid-Short Smoke
			{
				BotMoveTo(client, fMidShortSmoke, SAFEST_ROUTE);
				if(fMidShortSmokeDis < 75)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 1392.433837;
					fOrigin[1] = -231.219055;
					fOrigin[2] = -17.305377;
					
					fVelocity[0] = -557.391723;
					fVelocity[1] = 5.051202;
					fVelocity[2] = 615.354858;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 7: //Window Smoke
			{
				BotMoveTo(client, fWindowSmoke, SAFEST_ROUTE);
				if(fWindowSmokeDis < 75)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 1259.146362;
					fOrigin[1] = -991.095458;
					fOrigin[2] = -76.503326;
					
					fVelocity[0] = -748.695434;
					fVelocity[1] = 110.363220;
					fVelocity[2] = 492.635467;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 8: //Bottom Con Smoke
			{
				BotMoveTo(client, fBottomConSmoke, SAFEST_ROUTE);
				if(fBottomConSmokeDis < 75)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 1114.164550;
					fOrigin[1] = 629.839660;
					fOrigin[2] = -135.268310;
					
					fVelocity[0] = -396.773956;
					fVelocity[1] = -330.021575;
					fVelocity[2] = 669.743774;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 9: //Top Con Smoke
			{
				BotMoveTo(client, fTopConSmoke, SAFEST_ROUTE);
				if(fTopConSmokeDis < 75)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 1359.151489;
					fOrigin[1] = -1055.655761;
					fOrigin[2] = -44.968437;
					
					fVelocity[0] = -576.975524;
					fVelocity[1] = -63.035087;
					fVelocity[2] = 614.470214;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 10: //Short-Left Smoke
			{
				BotMoveTo(client, fShortLeftSmoke, SAFEST_ROUTE);
				if(fShotLeftSmokeDis < 75)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = -833.705017;
					fOrigin[1] = 521.811645;
					fOrigin[2] = 21.933916;
					
					fVelocity[0] = -126.220901;
					fVelocity[1] = -3.954442;
					fVelocity[2] = 653.081909;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 11: //Short-Right Smoke
			{
				BotMoveTo(client, fShortRightSmoke, SAFEST_ROUTE);
				if(fShortRightSmokeDis < 75)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = -163.495468;
					fOrigin[1] = 350.919830;
					fOrigin[2] = 63.056510;
					
					fVelocity[0] = -281.795989;
					fVelocity[1] = -38.421333;
					fVelocity[2] = 602.159973;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 12: //B Site Smoke
			{
				BotMoveTo(client, fBSiteSmoke, SAFEST_ROUTE);
				if(fBSiteSmokeDis < 75)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = -756.074218;
					fOrigin[1] = 620.800109;
					fOrigin[2] = 18.914443;
					
					fVelocity[0] = -365.059570;
					fVelocity[1] = -57.660415;
					fVelocity[2] = 554.828979;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 13: //Back of B Smoke
			{
				BotMoveTo(client, fBackOfBSmoke, SAFEST_ROUTE);
				if(fBackOfBSmokeDis < 75)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = -800.745422;
					fOrigin[1] = 617.155517;
					fOrigin[2] = 20.180675;
					
					fVelocity[0] = -307.670806;
					fVelocity[1] = -123.982215;
					fVelocity[2] = 577.870788;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 14: //Market Door Smoke
			{
				BotMoveTo(client, fMarketDoorSmoke, SAFEST_ROUTE);
				if(fMarketDoorSmokeDis < 75)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = -182.211257;
					fOrigin[1] = 875.810852;
					fOrigin[2] = -5.834220;
					
					fVelocity[0] = -403.612609;
					fVelocity[1] = -214.881088;
					fVelocity[2] = 731.215209;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 15: //Market Window Smoke
			{
				BotMoveTo(client, fMarketWindowSmoke, SAFEST_ROUTE);
				if(fMarketWindowSmokeDis < 75)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = -177.872940;
					fOrigin[1] = 876.177795;
					fOrigin[2] = -2.811931;
					
					fVelocity[0] = -324.667755;
					fVelocity[1] = -214.561050;
					fVelocity[2] = 786.203857;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
		}
	}
}

public void DoDust2Smokes(int client)
{
	float fClientLocation[3];

	GetClientAbsOrigin(client, fClientLocation);

	//T Side Smokes
	float fBDoorsSmoke[3] = { -2185.970703, 1228.098267, 103.018547 };
	float fBWindowSmoke[3] = { -2168.985352, 1042.009155, 104.253571 };
	float fMidToBSmoke[3] = { -493.977936, 746.946594, 66.300529 };
	float fMidToBBoxSmoke[3] = { -275.119781, 1345.367065, -58.695129 };
	float fXBOXSmoke[3] = { -299.968750, -1163.968750, 141.760681 };
	float fShortASmoke[3] = { 489.968750, 1446.031250, 64.615715 };
	float fShortBoostSmoke[3] = { 489.968750, 1943.968750, 160.093811 };
	float fASiteSmoke[3] = { 273.010040, 1650.206909, 90.072708 };
	float fLongCornerSmoke[3] = { 490.603485, -363.968750, 73.093811 };
	float fACrossSmoke[3] = { 860.031250, 790.031250, 68.376785 };
	float fCTSmoke[3] = { 516.045349, 984.229309, 65.549103 };

	float fBDoorsSmokeDis, fBWindowSmokeDis, fMidToBSmokeDis, fMidToBBoxSmokeDis, fXBOXSmokeDis, fShortASmokeDis, fShortBoostSmokeDis, fASiteSmokeDis, fLongCornerSmokeDis,
	fACrossSmokeDis, fCTSmokeDis;

	fBDoorsSmokeDis = GetVectorDistance(fClientLocation, fBDoorsSmoke);
	fBWindowSmokeDis = GetVectorDistance(fClientLocation, fBWindowSmoke);
	fMidToBSmokeDis = GetVectorDistance(fClientLocation, fMidToBSmoke);
	fMidToBBoxSmokeDis = GetVectorDistance(fClientLocation, fMidToBBoxSmoke);
	fXBOXSmokeDis = GetVectorDistance(fClientLocation, fXBOXSmoke);
	fShortASmokeDis = GetVectorDistance(fClientLocation, fShortASmoke);
	fShortBoostSmokeDis = GetVectorDistance(fClientLocation, fShortBoostSmoke);
	fASiteSmokeDis = GetVectorDistance(fClientLocation, fASiteSmoke);
	fLongCornerSmokeDis = GetVectorDistance(fClientLocation, fLongCornerSmoke);
	fACrossSmokeDis = GetVectorDistance(fClientLocation, fACrossSmoke);
	fCTSmokeDis = GetVectorDistance(fClientLocation, fCTSmoke);

	if(GetClientTeam(client) == CS_TEAM_T && !g_bHasThrownNade[client])
	{
		switch(g_iRndSmoke[client])
		{
			case 1: //B Doors Smoke
			{
				BotMoveTo(client, fBDoorsSmoke, SAFEST_ROUTE);
				if(fBDoorsSmokeDis < 75)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = -2175.164062;
					fOrigin[1] = 1241.078125;
					fOrigin[2] = 136.351242;
					
					fVelocity[0] = 196.042495;
					fVelocity[1] = 213.844100;
					fVelocity[2] = 599.477661;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 2: //B Window Smoke
			{
				BotMoveTo(client, fBWindowSmoke, SAFEST_ROUTE);
				if(fBWindowSmokeDis < 75)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = -2154.991455;
					fOrigin[1] = 1070.825195;
					fOrigin[2] = 144.162094;
					
					fVelocity[0] = 254.350601;
					fVelocity[1] = 523.965026;
					fVelocity[2] = 583.653564;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 3: //Mid to B Smoke
			{
				BotMoveTo(client, fMidToBSmoke, SAFEST_ROUTE);
				if(fMidToBSmokeDis < 75)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = -474.632446;
					fOrigin[1] = 889.059265;
					fOrigin[2] = 64.525901;
					
					fVelocity[0] = 124.725502;
					fVelocity[1] = 917.540283;
					fVelocity[2] = 257.509307;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 4: //Mid to B Box Smoke
			{
				BotMoveTo(client, fMidToBBoxSmoke, SAFEST_ROUTE);
				if(fMidToBBoxSmokeDis < 75)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = -296.723052;
					fOrigin[1] = 1373.351318;
					fOrigin[2] = -9.332315;
					
					fVelocity[0] = -394.729125;
					fVelocity[1] = 508.962188;
					fVelocity[2] = 436.598510;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 5: //XBOX Smoke
			{
				BotMoveTo(client, fXBOXSmoke, SAFEST_ROUTE);
				if(fXBOXSmokeDis < 75)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = -300.048492;
					fOrigin[1] = -1130.833374;
					fOrigin[2] = 196.540557;
					
					fVelocity[0] = -1.451205;
					fVelocity[1] = 603.327819;
					fVelocity[2] = 537.364562;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 6: //Short A Smoke
			{
				BotMoveTo(client, fShortASmoke, SAFEST_ROUTE);
				if(fShortASmokeDis < 75)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 490.998962;
					fOrigin[1] = 1481.763061;
					fOrigin[2] = 74.216232;
					
					fVelocity[0] = 18.676774;
					fVelocity[1] = 650.651428;
					fVelocity[2] = 168.686401;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 7: //Short-Boost Smoke
			{
				BotMoveTo(client, fShortBoostSmoke, SAFEST_ROUTE);
				if(fShortBoostSmokeDis < 75)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 494.109680;
					fOrigin[1] = 1972.619873;
					fOrigin[2] = 142.579330;
					
					fVelocity[0] = 60.718303;
					fVelocity[1] = 423.099121;
					fVelocity[2] = 89.004837;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 8: //A Site Smoke
			{
				BotMoveTo(client, fASiteSmoke, SAFEST_ROUTE);
				if(fASiteSmokeDis < 75)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 284.403991;
					fOrigin[1] = 1661.423461;
					fOrigin[2] = 105.455070;
					
					fVelocity[0] = 206.951477;
					fVelocity[1] = 201.738220;
					fVelocity[2] = 599.998168;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 9: //Long Corner Smoke
			{
				BotMoveTo(client, fLongCornerSmoke, SAFEST_ROUTE);
				if(fLongCornerSmokeDis < 75)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 500.049377;
					fOrigin[1] = -342.446136;
					fOrigin[2] = 101.009735;
					
					fVelocity[0] = 201.955673;
					fVelocity[1] = 390.799377;
					fVelocity[2] = 501.971435;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 10: //A Cross Smoke
			{
				BotMoveTo(client, fACrossSmoke, SAFEST_ROUTE);
				if(fACrossSmokeDis < 75)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 1000.792358;
					fOrigin[1] = 925.208068;
					fOrigin[2] = 82.876365;
					
					fVelocity[0] = 641.745849;
					fVelocity[1] = 616.289001;
					fVelocity[2] = 329.346618;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 11: //CT Smoke
			{
				BotMoveTo(client, fCTSmoke, SAFEST_ROUTE);
				if(fCTSmokeDis < 75)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 516.411621;
					fOrigin[1] = 1004.306518;
					fOrigin[2] = 96.275215;
					
					fVelocity[0] = 6.902427;
					fVelocity[1] = 372.110961;
					fVelocity[2] = 553.125915;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
		}
	}
}

public void Pro_Players(char[] szBotName, int client)
{

	//MIBR Players
	if((StrEqual(szBotName, "kNgV-")) || (StrEqual(szBotName, "FalleN")) || (StrEqual(szBotName, "fer")) || (StrEqual(szBotName, "TACO")) || (StrEqual(szBotName, "trk")))
	{
		CS_SetClientClanTag(client, "MIBR");
	}
	
	//FaZe Players
	if((StrEqual(szBotName, "olofmeister")) || (StrEqual(szBotName, "broky")) || (StrEqual(szBotName, "NiKo")) || (StrEqual(szBotName, "rain")) || (StrEqual(szBotName, "coldzera")))
	{
		CS_SetClientClanTag(client, "FaZe");
	}
	
	//Astralis Players
	if((StrEqual(szBotName, "es3tag")) || (StrEqual(szBotName, "device")) || (StrEqual(szBotName, "Bubzkji")) || (StrEqual(szBotName, "Magisk")) || (StrEqual(szBotName, "dupreeh")))
	{
		CS_SetClientClanTag(client, "Astralis");
	}
	
	//NiP Players
	if((StrEqual(szBotName, "twist")) || (StrEqual(szBotName, "Plopski")) || (StrEqual(szBotName, "nawwk")) || (StrEqual(szBotName, "hampus")) || (StrEqual(szBotName, "REZ")))
	{
		CS_SetClientClanTag(client, "NiP");
	}
	
	//C9 Players
	if((StrEqual(szBotName, "JT")) || (StrEqual(szBotName, "Sonic")) || (StrEqual(szBotName, "motm")) || (StrEqual(szBotName, "oSee")) || (StrEqual(szBotName, "floppy")))
	{
		CS_SetClientClanTag(client, "C9");
	}
	
	//G2 Players
	if((StrEqual(szBotName, "huNter-")) || (StrEqual(szBotName, "kennyS")) || (StrEqual(szBotName, "nexa")) || (StrEqual(szBotName, "JaCkz")) || (StrEqual(szBotName, "AMANEK")))
	{
		CS_SetClientClanTag(client, "G2");
	}
	
	//fnatic Players
	if((StrEqual(szBotName, "flusha")) || (StrEqual(szBotName, "JW")) || (StrEqual(szBotName, "KRiMZ")) || (StrEqual(szBotName, "Brollan")) || (StrEqual(szBotName, "Golden")))
	{
		CS_SetClientClanTag(client, "fnatic");
	}
	
	//North Players
	if((StrEqual(szBotName, "MSL")) || (StrEqual(szBotName, "Kjaerbye")) || (StrEqual(szBotName, "aizy")) || (StrEqual(szBotName, "cajunb")) || (StrEqual(szBotName, "gade")))
	{
		CS_SetClientClanTag(client, "North");
	}
	
	//mouz Players
	if((StrEqual(szBotName, "karrigan")) || (StrEqual(szBotName, "chrisJ")) || (StrEqual(szBotName, "woxic")) || (StrEqual(szBotName, "frozen")) || (StrEqual(szBotName, "ropz")))
	{
		CS_SetClientClanTag(client, "mouz");
	}
	
	//TYLOO Players
	if((StrEqual(szBotName, "Summer")) || (StrEqual(szBotName, "Attacker")) || (StrEqual(szBotName, "SLOWLY")) || (StrEqual(szBotName, "somebody")) || (StrEqual(szBotName, "DANK1NG")))
	{
		CS_SetClientClanTag(client, "TYLOO");
	}
	
	//EG Players
	if((StrEqual(szBotName, "stanislaw")) || (StrEqual(szBotName, "tarik")) || (StrEqual(szBotName, "Brehze")) || (StrEqual(szBotName, "Ethan")) || (StrEqual(szBotName, "CeRq")))
	{
		CS_SetClientClanTag(client, "EG");
	}
	
	//Thieves Players
	if((StrEqual(szBotName, "AZR")) || (StrEqual(szBotName, "jks")) || (StrEqual(szBotName, "jkaem")) || (StrEqual(szBotName, "Gratisfaction")) || (StrEqual(szBotName, "Liazz")))
	{
		CS_SetClientClanTag(client, "Thieves");
	}
	
	//Na´Vi Players
	if((StrEqual(szBotName, "electronic")) || (StrEqual(szBotName, "s1mple")) || (StrEqual(szBotName, "flamie")) || (StrEqual(szBotName, "Boombl4")) || (StrEqual(szBotName, "Perfecto")))
	{
		CS_SetClientClanTag(client, "Na´Vi");
	}
	
	//Liquid Players
	if((StrEqual(szBotName, "Stewie2K")) || (StrEqual(szBotName, "NAF")) || (StrEqual(szBotName, "nitr0")) || (StrEqual(szBotName, "ELiGE")) || (StrEqual(szBotName, "Twistzz")))
	{
		CS_SetClientClanTag(client, "Liquid");
	}
	
	//AGO Players
	if((StrEqual(szBotName, "Furlan")) || (StrEqual(szBotName, "GruBy")) || (StrEqual(szBotName, "mhL")) || (StrEqual(szBotName, "F1KU")) || (StrEqual(szBotName, "oskarish")))
	{
		CS_SetClientClanTag(client, "AGO");
	}
	
	//ENCE Players
	if((StrEqual(szBotName, "suNny")) || (StrEqual(szBotName, "Aerial")) || (StrEqual(szBotName, "allu")) || (StrEqual(szBotName, "sergej")) || (StrEqual(szBotName, "xseveN")))
	{
		CS_SetClientClanTag(client, "ENCE");
	}
	
	//Vitality Players
	if((StrEqual(szBotName, "shox")) || (StrEqual(szBotName, "ZywOo")) || (StrEqual(szBotName, "apEX")) || (StrEqual(szBotName, "RpK")) || (StrEqual(szBotName, "Misutaaa")))
	{
		CS_SetClientClanTag(client, "Vitality");
	}
	
	//BIG Players
	if((StrEqual(szBotName, "tiziaN")) || (StrEqual(szBotName, "syrsoN")) || (StrEqual(szBotName, "XANTARES")) || (StrEqual(szBotName, "tabseN")) || (StrEqual(szBotName, "k1to")))
	{
		CS_SetClientClanTag(client, "BIG");
	}
	
	//FURIA Players
	if((StrEqual(szBotName, "yuurih")) || (StrEqual(szBotName, "arT")) || (StrEqual(szBotName, "VINI")) || (StrEqual(szBotName, "kscerato")) || (StrEqual(szBotName, "HEN1")))
	{
		CS_SetClientClanTag(client, "FURIA");
	}
	
	//c0ntact Players
	if((StrEqual(szBotName, "Snappi")) || (StrEqual(szBotName, "ottoNd")) || (StrEqual(szBotName, "SHiPZ")) || (StrEqual(szBotName, "emi")) || (StrEqual(szBotName, "EspiranTo")))
	{
		CS_SetClientClanTag(client, "c0ntact");
	}
	
	//coL Players
	if((StrEqual(szBotName, "k0nfig")) || (StrEqual(szBotName, "poizon")) || (StrEqual(szBotName, "oBo")) || (StrEqual(szBotName, "RUSH")) || (StrEqual(szBotName, "blameF")))
	{
		CS_SetClientClanTag(client, "coL");
	}
	
	//ViCi Players
	if((StrEqual(szBotName, "zhokiNg")) || (StrEqual(szBotName, "kaze")) || (StrEqual(szBotName, "aumaN")) || (StrEqual(szBotName, "JamYoung")) || (StrEqual(szBotName, "advent")))
	{
		CS_SetClientClanTag(client, "ViCi");
	}
	
	//forZe Players
	if((StrEqual(szBotName, "facecrack")) || (StrEqual(szBotName, "xsepower")) || (StrEqual(szBotName, "FL1T")) || (StrEqual(szBotName, "almazer")) || (StrEqual(szBotName, "Jerry")))
	{
		CS_SetClientClanTag(client, "forZe");
	}
	
	//Winstrike Players
	if((StrEqual(szBotName, "Lack1")) || (StrEqual(szBotName, "KrizzeN")) || (StrEqual(szBotName, "Hobbit")) || (StrEqual(szBotName, "El1an")) || (StrEqual(szBotName, "bondik")))
	{
		CS_SetClientClanTag(client, "Winstrike");
	}
	
	//Sprout Players
	if((StrEqual(szBotName, "snatchie")) || (StrEqual(szBotName, "dycha")) || (StrEqual(szBotName, "Spiidi")) || (StrEqual(szBotName, "faveN")) || (StrEqual(szBotName, "denis")))
	{
		CS_SetClientClanTag(client, "Sprout");
	}
	
	//Heroic Players
	if((StrEqual(szBotName, "TeSeS")) || (StrEqual(szBotName, "b0RUP")) || (StrEqual(szBotName, "nikozan")) || (StrEqual(szBotName, "cadiaN")) || (StrEqual(szBotName, "stavn")))
	{
		CS_SetClientClanTag(client, "Heroic");
	}
	
	//INTZ Players
	if((StrEqual(szBotName, "maxcel")) || (StrEqual(szBotName, "gut0")) || (StrEqual(szBotName, "dukka")) || (StrEqual(szBotName, "paredao")) || (StrEqual(szBotName, "kLv")))
	{
		CS_SetClientClanTag(client, "INTZ");
	}
	
	//VP Players
	if((StrEqual(szBotName, "YEKINDAR")) || (StrEqual(szBotName, "Jame")) || (StrEqual(szBotName, "qikert")) || (StrEqual(szBotName, "SANJI")) || (StrEqual(szBotName, "AdreN")))
	{
		CS_SetClientClanTag(client, "VP");
	}
	
	//Apeks Players
	if((StrEqual(szBotName, "Marcelious")) || (StrEqual(szBotName, "truth")) || (StrEqual(szBotName, "Grusarn")) || (StrEqual(szBotName, "akEz")) || (StrEqual(szBotName, "dennis")))
	{
		CS_SetClientClanTag(client, "Apeks");
	}
	
	//aTTaX Players
	if((StrEqual(szBotName, "stfN")) || (StrEqual(szBotName, "slaxz")) || (StrEqual(szBotName, "ScrunK")) || (StrEqual(szBotName, "kressy")) || (StrEqual(szBotName, "mirbit")))
	{
		CS_SetClientClanTag(client, "aTTaX");
	}
	
	//RNG Players
	if((StrEqual(szBotName, "INS")) || (StrEqual(szBotName, "sico")) || (StrEqual(szBotName, "dexter")) || (StrEqual(szBotName, "Hatz")) || (StrEqual(szBotName, "malta")))
	{
		CS_SetClientClanTag(client, "RNG");
	}
	
	//Envy Players
	if((StrEqual(szBotName, "Nifty")) || (StrEqual(szBotName, "ryann")) || (StrEqual(szBotName, "Calyx")) || (StrEqual(szBotName, "MICHU")) || (StrEqual(szBotName, "LEGIJA")))
	{
		CS_SetClientClanTag(client, "Envy");
	}
	
	//Spirit Players
	if((StrEqual(szBotName, "mir")) || (StrEqual(szBotName, "iDISBALANCE")) || (StrEqual(szBotName, "somedieyoung")) || (StrEqual(szBotName, "chopper")) || (StrEqual(szBotName, "magixx")))
	{
		CS_SetClientClanTag(client, "Spirit");
	}
	
	//LDLC Players
	if((StrEqual(szBotName, "afroo")) || (StrEqual(szBotName, "Lambert")) || (StrEqual(szBotName, "hAdji")) || (StrEqual(szBotName, "bodyy")) || (StrEqual(szBotName, "SIXER")))
	{
		CS_SetClientClanTag(client, "LDLC");
	}
	
	//GamerLegion Players
	if((StrEqual(szBotName, "mezii")) || (StrEqual(szBotName, "eraa")) || (StrEqual(szBotName, "Zero")) || (StrEqual(szBotName, "RuStY")) || (StrEqual(szBotName, "Adam9130")))
	{
		CS_SetClientClanTag(client, "GamerLegion");
	}
	
	//DIVIZON Players
	if((StrEqual(szBotName, "devus")) || (StrEqual(szBotName, "akay")) || (StrEqual(szBotName, "hyped")) || (StrEqual(szBotName, "FabeeN")) || (StrEqual(szBotName, "ykyli")))
	{
		CS_SetClientClanTag(client, "DIVIZON");
	}
	
	//EYES Players
	if((StrEqual(szBotName, "Zarin")) || (StrEqual(szBotName, "ACTiV")) || (StrEqual(szBotName, "Hydro")) || (StrEqual(szBotName, "SativR")) || (StrEqual(szBotName, "HTMy")))
	{
		CS_SetClientClanTag(client, "EYES");
	}
	
	//Wolsung Players
	if((StrEqual(szBotName, "hyskeee")) || (StrEqual(szBotName, "rAW")) || (StrEqual(szBotName, "Gekons")) || (StrEqual(szBotName, "keen")) || (StrEqual(szBotName, "shield")))
	{
		CS_SetClientClanTag(client, "Wolsung");
	}
	
	//PDucks Players
	if((StrEqual(szBotName, "ChLo")) || (StrEqual(szBotName, "sTaR")) || (StrEqual(szBotName, "wizzem")) || (StrEqual(szBotName, "maxz")) || (StrEqual(szBotName, "Cl34v3rs")))
	{
		CS_SetClientClanTag(client, "PDucks");
	}
	
	//HAVU Players
	if((StrEqual(szBotName, "ZOREE")) || (StrEqual(szBotName, "sLowi")) || (StrEqual(szBotName, "doto")) || (StrEqual(szBotName, "Hoody")) || (StrEqual(szBotName, "sAw")))
	{
		CS_SetClientClanTag(client, "HAVU");
	}
	
	//Lyngby Players
	if((StrEqual(szBotName, "birdfromsky")) || (StrEqual(szBotName, "Twinx")) || (StrEqual(szBotName, "maNkz")) || (StrEqual(szBotName, "Raalz")) || (StrEqual(szBotName, "Cabbi")))
	{
		CS_SetClientClanTag(client, "Lyngby");
	}
	
	//GODSENT Players
	if((StrEqual(szBotName, "maden")) || (StrEqual(szBotName, "farlig")) || (StrEqual(szBotName, "kRYSTAL")) || (StrEqual(szBotName, "zehN")) || (StrEqual(szBotName, "STYKO")))
	{
		CS_SetClientClanTag(client, "GODSENT");
	}
	
	//Nordavind Players
	if((StrEqual(szBotName, "tenzki")) || (StrEqual(szBotName, "NaToSaphiX")) || (StrEqual(szBotName, "H4RR3")) || (StrEqual(szBotName, "HS")) || (StrEqual(szBotName, "cromen")))
	{
		CS_SetClientClanTag(client, "Nordavind");
	}
	
	//SJ Players
	if((StrEqual(szBotName, "arvid")) || (StrEqual(szBotName, "STOVVE")) || (StrEqual(szBotName, "SADDYX")) || (StrEqual(szBotName, "KHRN")) || (StrEqual(szBotName, "xartE")))
	{
		CS_SetClientClanTag(client, "SJ");
	}
	
	//Bren Players
	if((StrEqual(szBotName, "Papichulo")) || (StrEqual(szBotName, "witz")) || (StrEqual(szBotName, "Pro.")) || (StrEqual(szBotName, "JA")) || (StrEqual(szBotName, "Derek")))
	{
		CS_SetClientClanTag(client, "Bren");
	}
	
	//Giants Players
	if((StrEqual(szBotName, "NOPEEj")) || (StrEqual(szBotName, "fox")) || (StrEqual(szBotName, "pr")) || (StrEqual(szBotName, "obj")) || (StrEqual(szBotName, "RIZZ")))
	{
		CS_SetClientClanTag(client, "Giants");
	}
	
	//Lions Players
	if((StrEqual(szBotName, "AcilioN")) || (StrEqual(szBotName, "acoR")) || (StrEqual(szBotName, "Sjuush")) || (StrEqual(szBotName, "innocent")) || (StrEqual(szBotName, "roeJ")))
	{
		CS_SetClientClanTag(client, "Lions");
	}
	
	//Riders Players
	if((StrEqual(szBotName, "mopoz")) || (StrEqual(szBotName, "shokz")) || (StrEqual(szBotName, "steel")) || (StrEqual(szBotName, "alex*")) || (StrEqual(szBotName, "larsen")))
	{
		CS_SetClientClanTag(client, "Riders");
	}
	
	//OFFSET Players
	if((StrEqual(szBotName, "sc4rx")) || (StrEqual(szBotName, "KILLDREAM")) || (StrEqual(szBotName, "zlynx")) || (StrEqual(szBotName, "ZELIN")) || (StrEqual(szBotName, "drifking")))
	{
		CS_SetClientClanTag(client, "OFFSET");
	}
	
	//eSuba Players
	if((StrEqual(szBotName, "NIO")) || (StrEqual(szBotName, "Levi")) || (StrEqual(szBotName, "luko")) || (StrEqual(szBotName, "Blogg1s")) || (StrEqual(szBotName, "The eLiVe")))
	{
		CS_SetClientClanTag(client, "eSuba");
	}
	
	//Nexus Players
	if((StrEqual(szBotName, "BTN")) || (StrEqual(szBotName, "XELLOW")) || (StrEqual(szBotName, "mhN1")) || (StrEqual(szBotName, "iM")) || (StrEqual(szBotName, "sXe")))
	{
		CS_SetClientClanTag(client, "Nexus");
	}
	
	//PACT Players
	if((StrEqual(szBotName, "darko")) || (StrEqual(szBotName, "lunAtic")) || (StrEqual(szBotName, "Goofy")) || (StrEqual(szBotName, "MINISE")) || (StrEqual(szBotName, "Sobol")))
	{
		CS_SetClientClanTag(client, "PACT");
	}
	
	//Heretics Players
	if((StrEqual(szBotName, "Nivera")) || (StrEqual(szBotName, "Maka")) || (StrEqual(szBotName, "xms")) || (StrEqual(szBotName, "kioShiMa")) || (StrEqual(szBotName, "Lucky")))
	{
		CS_SetClientClanTag(client, "Heretics");
	}
	
	//Nemiga Players
	if((StrEqual(szBotName, "speed4k")) || (StrEqual(szBotName, "mds")) || (StrEqual(szBotName, "lollipop21k")) || (StrEqual(szBotName, "Jyo")) || (StrEqual(szBotName, "boX")))
	{
		CS_SetClientClanTag(client, "Nemiga");
	}
	
	//pro100 Players
	if((StrEqual(szBotName, "dimasick")) || (StrEqual(szBotName, "WorldEdit")) || (StrEqual(szBotName, "fostar")) || (StrEqual(szBotName, "wayLander")) || (StrEqual(szBotName, "NickelBack")))
	{
		CS_SetClientClanTag(client, "pro100");
	}
	
	//YaLLa Players
	if((StrEqual(szBotName, "Remind")) || (StrEqual(szBotName, "DEAD")) || (StrEqual(szBotName, "Kheops")) || (StrEqual(szBotName, "Senpai")) || (StrEqual(szBotName, "Lyhn")))
	{
		CS_SetClientClanTag(client, "YaLLa");
	}
	
	//Yeah Players
	if((StrEqual(szBotName, "tatazin")) || (StrEqual(szBotName, "RCF")) || (StrEqual(szBotName, "f4stzin")) || (StrEqual(szBotName, "iDk")) || (StrEqual(szBotName, "dumau")))
	{
		CS_SetClientClanTag(client, "Yeah");
	}
	
	//Singularity Players
	if((StrEqual(szBotName, "nicoodoz")) || (StrEqual(szBotName, "mertz")) || (StrEqual(szBotName, "Remoy")) || (StrEqual(szBotName, "TOBIZ")) || (StrEqual(szBotName, "Celrate")))
	{
		CS_SetClientClanTag(client, "Singularity");
	}
	
	//DETONA Players
	if((StrEqual(szBotName, "nak")) || (StrEqual(szBotName, "piria")) || (StrEqual(szBotName, "v$m")) || (StrEqual(szBotName, "Lucaozy")) || (StrEqual(szBotName, "zevy")))
	{
		CS_SetClientClanTag(client, "DETONA");
	}
	
	//Infinity Players
	if((StrEqual(szBotName, "k1Nky")) || (StrEqual(szBotName, "tor1towOw")) || (StrEqual(szBotName, "spamzzy")) || (StrEqual(szBotName, "BRUNO")) || (StrEqual(szBotName, "points")))
	{
		CS_SetClientClanTag(client, "Infinity");
	}
	
	//Isurus Players
	if((StrEqual(szBotName, "1962")) || (StrEqual(szBotName, "Noktse")) || (StrEqual(szBotName, "Reversive")) || (StrEqual(szBotName, "decov9jse")) || (StrEqual(szBotName, "caike")))
	{
		CS_SetClientClanTag(client, "Isurus");
	}
	
	//paiN Players
	if((StrEqual(szBotName, "PKL")) || (StrEqual(szBotName, "land1n")) || (StrEqual(szBotName, "NEKIZ")) || (StrEqual(szBotName, "biguzera")) || (StrEqual(szBotName, "hardzao")))
	{
		CS_SetClientClanTag(client, "paiN");
	}
	
	//Sharks Players
	if((StrEqual(szBotName, "supLex")) || (StrEqual(szBotName, "jnt")) || (StrEqual(szBotName, "leo_drunky")) || (StrEqual(szBotName, "exit")) || (StrEqual(szBotName, "Luken")))
	{
		CS_SetClientClanTag(client, "Sharks");
	}
	
	//One Players
	if((StrEqual(szBotName, "prt")) || (StrEqual(szBotName, "Maluk3")) || (StrEqual(szBotName, "malbsMd")) || (StrEqual(szBotName, "pesadelo")) || (StrEqual(szBotName, "b4rtiN")))
	{
		CS_SetClientClanTag(client, "One");
	}
	
	//W7M Players
	if((StrEqual(szBotName, "skullz")) || (StrEqual(szBotName, "raafa")) || (StrEqual(szBotName, "Tuurtle")) || (StrEqual(szBotName, "pancc")) || (StrEqual(szBotName, "realziN")))
	{
		CS_SetClientClanTag(client, "W7M");
	}
	
	//Avant Players
	if((StrEqual(szBotName, "BL1TZ")) || (StrEqual(szBotName, "sterling")) || (StrEqual(szBotName, "apoc")) || (StrEqual(szBotName, "ofnu")) || (StrEqual(szBotName, "HaZR")))
	{
		CS_SetClientClanTag(client, "Avant");
	}
	
	//Chiefs Players
	if((StrEqual(szBotName, "HUGHMUNGUS")) || (StrEqual(szBotName, "Vexite")) || (StrEqual(szBotName, "apocdud")) || (StrEqual(szBotName, "zeph")) || (StrEqual(szBotName, "soju_j")))
	{
		CS_SetClientClanTag(client, "Chiefs");
	}
	
	//ORDER Players
	if((StrEqual(szBotName, "J1rah")) || (StrEqual(szBotName, "aliStair")) || (StrEqual(szBotName, "Rickeh")) || (StrEqual(szBotName, "USTILO")) || (StrEqual(szBotName, "Valiance")))
	{
		CS_SetClientClanTag(client, "ORDER");
	}
	
	//BlackS Players
	if((StrEqual(szBotName, "hue9ze")) || (StrEqual(szBotName, "addict")) || (StrEqual(szBotName, "cookie")) || (StrEqual(szBotName, "jono")) || (StrEqual(szBotName, "Wolfah")))
	{
		CS_SetClientClanTag(client, "BlackS");
	}
	
	//SKADE Players
	if((StrEqual(szBotName, "Duplicate")) || (StrEqual(szBotName, "dennyslaw")) || (StrEqual(szBotName, "Oxygen")) || (StrEqual(szBotName, "Rainwaker")) || (StrEqual(szBotName, "SPELLAN")))
	{
		CS_SetClientClanTag(client, "SKADE");
	}
	
	//Paradox Players
	if((StrEqual(szBotName, "ino")) || (StrEqual(szBotName, "Versa")) || (StrEqual(szBotName, "ekul")) || (StrEqual(szBotName, "bedonka")) || (StrEqual(szBotName, "urbz")))
	{
		CS_SetClientClanTag(client, "Paradox");
	}
	
	//Beyond Players
	if((StrEqual(szBotName, "MAIROLLS")) || (StrEqual(szBotName, "Olivia")) || (StrEqual(szBotName, "Kntz")) || (StrEqual(szBotName, "stk")) || (StrEqual(szBotName, "qqGod")))
	{
		CS_SetClientClanTag(client, "Beyond");
	}
	
	//BOOM Players
	if((StrEqual(szBotName, "chelo")) || (StrEqual(szBotName, "yeL")) || (StrEqual(szBotName, "shz")) || (StrEqual(szBotName, "boltz")) || (StrEqual(szBotName, "felps")))
	{
		CS_SetClientClanTag(client, "BOOM");
	}
	
	//NASR Players
	if((StrEqual(szBotName, "proxyyb")) || (StrEqual(szBotName, "Real1ze")) || (StrEqual(szBotName, "BOROS")) || (StrEqual(szBotName, "Dementor")) || (StrEqual(szBotName, "Just1ce")))
	{
		CS_SetClientClanTag(client, "NASR");
	}
	
	//Revolution Players
	if((StrEqual(szBotName, "Rambutan")) || (StrEqual(szBotName, "Fog")) || (StrEqual(szBotName, "Tee")) || (StrEqual(szBotName, "Jaybk")) || (StrEqual(szBotName, "kun")))
	{
		CS_SetClientClanTag(client, "Revolution");
	}
	
	//SHIFT Players
	if((StrEqual(szBotName, "Young KillerS")) || (StrEqual(szBotName, "Kishi")) || (StrEqual(szBotName, "tozz")) || (StrEqual(szBotName, "huyhart")) || (StrEqual(szBotName, "Imcarnus")))
	{
		CS_SetClientClanTag(client, "SHIFT");
	}
	
	//nxl Players
	if((StrEqual(szBotName, "soifong")) || (StrEqual(szBotName, "RamCikiciew")) || (StrEqual(szBotName, "Qbo")) || (StrEqual(szBotName, "Vask0")) || (StrEqual(szBotName, "smoof")))
	{
		CS_SetClientClanTag(client, "nxl");
	}
	
	//Berzerk Players
	if((StrEqual(szBotName, "SolEk")) || (StrEqual(szBotName, "s1n")) || (StrEqual(szBotName, "tahsiN")) || (StrEqual(szBotName, "syken")) || (StrEqual(szBotName, "skyye")))
	{
		CS_SetClientClanTag(client, "Berzerk");
	}
	
	//Energy Players
	if((StrEqual(szBotName, "pnd")) || (StrEqual(szBotName, "disTroiT")) || (StrEqual(szBotName, "Lichl0rd")) || (StrEqual(szBotName, "Tiaantije")) || (StrEqual(szBotName, "mango")))
	{
		CS_SetClientClanTag(client, "Energy");
	}
	
	//GroundZero Players
	if((StrEqual(szBotName, "BURNRUOk")) || (StrEqual(szBotName, "Liki")) || (StrEqual(szBotName, "Llamas")) || (StrEqual(szBotName, "Noobster")) || (StrEqual(szBotName, "PEARSS")))
	{
		CS_SetClientClanTag(client, "GroundZero");
	}
	
	//AVEZ Players
	if((StrEqual(szBotName, "byali")) || (StrEqual(szBotName, "Markoś")) || (StrEqual(szBotName, "KEi")) || (StrEqual(szBotName, "Kylar")) || (StrEqual(szBotName, "nawrot")))
	{
		CS_SetClientClanTag(client, "AVEZ");
	}
	
	//BTRG Players
	if((StrEqual(szBotName, "Eeyore")) || (StrEqual(szBotName, "Geniuss")) || (StrEqual(szBotName, "xccurate")) || (StrEqual(szBotName, "ImpressioN")) || (StrEqual(szBotName, "XigN")))
	{
		CS_SetClientClanTag(client, "BTRG");
	}
	
	//Furious Players
	if((StrEqual(szBotName, "nbl")) || (StrEqual(szBotName, "tom1")) || (StrEqual(szBotName, "Owensinho")) || (StrEqual(szBotName, "iKrystal")) || (StrEqual(szBotName, "pablek")))
	{
		CS_SetClientClanTag(client, "Furious");
	}
	
	//GTZ Players
	if((StrEqual(szBotName, "deLonge")) || (StrEqual(szBotName, "hug")) || (StrEqual(szBotName, "slaxx")) || (StrEqual(szBotName, "braadz")) || (StrEqual(szBotName, "rafaxF")))
	{
		CS_SetClientClanTag(client, "GTZ");
	}
	
	//x6tence Players
	if((StrEqual(szBotName, "Queenix")) || (StrEqual(szBotName, "HECTOz")) || (StrEqual(szBotName, "HooXi")) || (StrEqual(szBotName, "refrezh")) || (StrEqual(szBotName, "Nodios")))
	{
		CS_SetClientClanTag(client, "x6tence");
	}
	
	//Syman Players
	if((StrEqual(szBotName, "neaLaN")) || (StrEqual(szBotName, "mou")) || (StrEqual(szBotName, "n0rb3r7")) || (StrEqual(szBotName, "kade0")) || (StrEqual(szBotName, "Keoz")))
	{
		CS_SetClientClanTag(client, "Syman");
	}
	
	//Goliath Players
	if((StrEqual(szBotName, "massacRe")) || (StrEqual(szBotName, "kaNibalistic")) || (StrEqual(szBotName, "adM")) || (StrEqual(szBotName, "adaro")) || (StrEqual(szBotName, "ZipZip")))
	{
		CS_SetClientClanTag(client, "Goliath");
	}
	
	//Secret Players
	if((StrEqual(szBotName, "juanflatroo")) || (StrEqual(szBotName, "smF")) || (StrEqual(szBotName, "PERCY")) || (StrEqual(szBotName, "sinnopsyy")) || (StrEqual(szBotName, "anarkez")))
	{
		CS_SetClientClanTag(client, "Secret");
	}
	
	//Incept Players
	if((StrEqual(szBotName, "micalis")) || (StrEqual(szBotName, "SkulL")) || (StrEqual(szBotName, "nibke")) || (StrEqual(szBotName, "Rev")) || (StrEqual(szBotName, "yourwombat")))
	{
		CS_SetClientClanTag(client, "Incept");
	}
	
	//UOL Players
	if((StrEqual(szBotName, "crisby")) || (StrEqual(szBotName, "kZyJL")) || (StrEqual(szBotName, "Andyy")) || (StrEqual(szBotName, "JDC")) || (StrEqual(szBotName, ".P4TriCK")))
	{
		CS_SetClientClanTag(client, "UOL");
	}
	
	//RADIX Players
	if((StrEqual(szBotName, "mrhui")) || (StrEqual(szBotName, "MBL")) || (StrEqual(szBotName, "RezzeD")) || (StrEqual(szBotName, "entz")) || (StrEqual(szBotName, "CYPHER")))
	{
		CS_SetClientClanTag(client, "RADIX");
	}
	
	//Illuminar Players
	if((StrEqual(szBotName, "Vegi")) || (StrEqual(szBotName, "Snax")) || (StrEqual(szBotName, "mouz")) || (StrEqual(szBotName, "reatz")) || (StrEqual(szBotName, "mono")))
	{
		CS_SetClientClanTag(client, "Illuminar");
	}
	
	//Queso Players
	if((StrEqual(szBotName, "TheClaran")) || (StrEqual(szBotName, "thinkii")) || (StrEqual(szBotName, "VARES")) || (StrEqual(szBotName, "mik")) || (StrEqual(szBotName, "Yaba")))
	{
		CS_SetClientClanTag(client, "Queso");
	}
	
	//IG Players
	if((StrEqual(szBotName, "0i")) || (StrEqual(szBotName, "DeStRoYeR")) || (StrEqual(szBotName, "flying")) || (StrEqual(szBotName, "Viva")) || (StrEqual(szBotName, "XiaosaGe")))
	{
		CS_SetClientClanTag(client, "IG");
	}
	
	//HR Players
	if((StrEqual(szBotName, "kAliNkA")) || (StrEqual(szBotName, "jR")) || (StrEqual(szBotName, "Flarich")) || (StrEqual(szBotName, "ProbLeM")) || (StrEqual(szBotName, "JIaYm")))
	{
		CS_SetClientClanTag(client, "HR");
	}
	
	//Dice Players
	if((StrEqual(szBotName, "XpG")) || (StrEqual(szBotName, "nonick")) || (StrEqual(szBotName, "Kan4")) || (StrEqual(szBotName, "Polox")) || (StrEqual(szBotName, "Djoko")))
	{
		CS_SetClientClanTag(client, "Dice");
	}
	
	//PlanetKey Players
	if((StrEqual(szBotName, "LapeX")) || (StrEqual(szBotName, "Printek")) || (StrEqual(szBotName, "glaVed")) || (StrEqual(szBotName, "ND")) || (StrEqual(szBotName, "impulsG")))
	{
		CS_SetClientClanTag(client, "PlanetKey");
	}
	
	//mCon Players
	if((StrEqual(szBotName, "k1Nzo")) || (StrEqual(szBotName, "shaGGy")) || (StrEqual(szBotName, "luosrevo")) || (StrEqual(szBotName, "ReFuZR")) || (StrEqual(szBotName, "methoDs")))
	{
		CS_SetClientClanTag(client, "mCon");
	}
	
	//HLE Players
	if((StrEqual(szBotName, "kinqie")) || (StrEqual(szBotName, "rAge")) || (StrEqual(szBotName, "Krad")) || (StrEqual(szBotName, "Forester")) || (StrEqual(szBotName, "svyat")))
	{
		CS_SetClientClanTag(client, "HLE");
	}
	
	//Gambit Players
	if((StrEqual(szBotName, "nafany")) || (StrEqual(szBotName, "sh1ro")) || (StrEqual(szBotName, "interz")) || (StrEqual(szBotName, "Ax1Le")) || (StrEqual(szBotName, "supra")))
	{
		CS_SetClientClanTag(client, "Gambit");
	}
	
	//Wisla Players
	if((StrEqual(szBotName, "hades")) || (StrEqual(szBotName, "SZPERO")) || (StrEqual(szBotName, "mynio")) || (StrEqual(szBotName, "ponczek")) || (StrEqual(szBotName, "jedqr")))
	{
		CS_SetClientClanTag(client, "Wisla");
	}
	
	//Imperial Players
	if((StrEqual(szBotName, "fnx")) || (StrEqual(szBotName, "zqk")) || (StrEqual(szBotName, "dzt")) || (StrEqual(szBotName, "delboNi")) || (StrEqual(szBotName, "SHOOWTiME")))
	{
		CS_SetClientClanTag(client, "Imperial");
	}
	
	//Pompa Players
	if((StrEqual(szBotName, "iso")) || (StrEqual(szBotName, "SKRZYNKA")) || (StrEqual(szBotName, "LAYNER")) || (StrEqual(szBotName, "OLIMP")) || (StrEqual(szBotName, "blacktear5")))
	{
		CS_SetClientClanTag(client, "Pompa");
	}
	
	//Unique Players
	if((StrEqual(szBotName, "crush")) || (StrEqual(szBotName, "AiyvaN")) || (StrEqual(szBotName, "shalfey")) || (StrEqual(szBotName, "SELLTER")) || (StrEqual(szBotName, "fenvicious")))
	{
		CS_SetClientClanTag(client, "Unique");
	}
	
	//Izako Players
	if((StrEqual(szBotName, "Siuhy")) || (StrEqual(szBotName, "szejn")) || (StrEqual(szBotName, "EXUS")) || (StrEqual(szBotName, "avis")) || (StrEqual(szBotName, "TOAO")))
	{
		CS_SetClientClanTag(client, "Izako");
	}
	
	//ATK Players
	if((StrEqual(szBotName, "bLazE")) || (StrEqual(szBotName, "MisteM")) || (StrEqual(szBotName, "SloWye")) || (StrEqual(szBotName, "Fadey")) || (StrEqual(szBotName, "Doru")))
	{
		CS_SetClientClanTag(client, "ATK");
	}
	
	//Chaos Players
	if((StrEqual(szBotName, "Xeppaa")) || (StrEqual(szBotName, "vanity")) || (StrEqual(szBotName, "leaf")) || (StrEqual(szBotName, "steel_")) || (StrEqual(szBotName, "Jonji")))
	{
		CS_SetClientClanTag(client, "Chaos");
	}
	
	//OneThree Players
	if((StrEqual(szBotName, "ChildKing")) || (StrEqual(szBotName, "lan")) || (StrEqual(szBotName, "bottle")) || (StrEqual(szBotName, "DD")) || (StrEqual(szBotName, "Karsa")))
	{
		CS_SetClientClanTag(client, "OneThree");
	}
	
	//Lynn Players
	if((StrEqual(szBotName, "XG")) || (StrEqual(szBotName, "mitsuha")) || (StrEqual(szBotName, "Aree")) || (StrEqual(szBotName, "Yvonne")) || (StrEqual(szBotName, "XinKoiNg")))
	{
		CS_SetClientClanTag(client, "Lynn");
	}
	
	//Triumph Players
	if((StrEqual(szBotName, "Shakezullah")) || (StrEqual(szBotName, "Junior")) || (StrEqual(szBotName, "Spongey")) || (StrEqual(szBotName, "curry")) || (StrEqual(szBotName, "Grim")))
	{
		CS_SetClientClanTag(client, "Triumph");
	}
	
	//FATE Players
	if((StrEqual(szBotName, "blocker")) || (StrEqual(szBotName, "Patrick")) || (StrEqual(szBotName, "harn")) || (StrEqual(szBotName, "Mar")) || (StrEqual(szBotName, "niki1")))
	{
		CS_SetClientClanTag(client, "FATE");
	}
	
	//Canids Players
	if((StrEqual(szBotName, "DeStiNy")) || (StrEqual(szBotName, "nythonzinho")) || (StrEqual(szBotName, "heat")) || (StrEqual(szBotName, "latto")) || (StrEqual(szBotName, "KHTEX")))
	{
		CS_SetClientClanTag(client, "Canids");
	}
	
	//ESPADA Players
	if((StrEqual(szBotName, "Patsanchick")) || (StrEqual(szBotName, "degster")) || (StrEqual(szBotName, "FinigaN")) || (StrEqual(szBotName, "S0tF1k")) || (StrEqual(szBotName, "Dima")))
	{
		CS_SetClientClanTag(client, "ESPADA");
	}
	
	//OG Players
	if((StrEqual(szBotName, "NBK-")) || (StrEqual(szBotName, "mantuu")) || (StrEqual(szBotName, "Aleksib")) || (StrEqual(szBotName, "valde")) || (StrEqual(szBotName, "ISSAA")))
	{
		CS_SetClientClanTag(client, "OG");
	}
	
	//Wizards Players
	if((StrEqual(szBotName, "krii")) || (StrEqual(szBotName, "Kvik")) || (StrEqual(szBotName, "pounh")) || (StrEqual(szBotName, "PALM1")) || (StrEqual(szBotName, "FliP1")))
	{
		CS_SetClientClanTag(client, "Wizards");
	}
	
	//Tricked Players
	if((StrEqual(szBotName, "kiR")) || (StrEqual(szBotName, "kwezz")) || (StrEqual(szBotName, "Luckyv1")) || (StrEqual(szBotName, "sycrone")) || (StrEqual(szBotName, "Toft")))
	{
		CS_SetClientClanTag(client, "Tricked");
	}
	
	//Gen.G Players
	if((StrEqual(szBotName, "autimatic")) || (StrEqual(szBotName, "koosta")) || (StrEqual(szBotName, "daps")) || (StrEqual(szBotName, "s0m")) || (StrEqual(szBotName, "BnTeT")))
	{
		CS_SetClientClanTag(client, "Gen.G");
	}
	
	//Endpoint Players
	if((StrEqual(szBotName, "Surreal")) || (StrEqual(szBotName, "CRUC1AL")) || (StrEqual(szBotName, "Thomas")) || (StrEqual(szBotName, "robiin")) || (StrEqual(szBotName, "MiGHTYMAX")))
	{
		CS_SetClientClanTag(client, "Endpoint");
	}
	
	//sAw Players
	if((StrEqual(szBotName, "arki")) || (StrEqual(szBotName, "stadodo")) || (StrEqual(szBotName, "JUST")) || (StrEqual(szBotName, "MUTiRiS")) || (StrEqual(szBotName, "rmn")))
	{
		CS_SetClientClanTag(client, "sAw");
	}
	
	//DIG Players
	if((StrEqual(szBotName, "GeT_RiGhT")) || (StrEqual(szBotName, "hallzerk")) || (StrEqual(szBotName, "f0rest")) || (StrEqual(szBotName, "friberg")) || (StrEqual(szBotName, "Xizt")))
	{
		CS_SetClientClanTag(client, "DIG");
	}
	
	//D13 Players
	if((StrEqual(szBotName, "Tamiraarita")) || (StrEqual(szBotName, "rate")) || (StrEqual(szBotName, "shinobi")) || (StrEqual(szBotName, "sK0R")) || (StrEqual(szBotName, "ANNIHILATION")))
	{
		CS_SetClientClanTag(client, "D13");
	}
	
	//ZIGMA Players
	if((StrEqual(szBotName, "NIFFY")) || (StrEqual(szBotName, "Reality")) || (StrEqual(szBotName, "JUSTCAUSE")) || (StrEqual(szBotName, "PPOverdose")) || (StrEqual(szBotName, "RoLEX")))
	{
		CS_SetClientClanTag(client, "ZIGMA");
	}
	
	//Ambush Players
	if((StrEqual(szBotName, "Inzta")) || (StrEqual(szBotName, "Ryxxo")) || (StrEqual(szBotName, "zeq")) || (StrEqual(szBotName, "Typos")) || (StrEqual(szBotName, "IceBerg")))
	{
		CS_SetClientClanTag(client, "Ambush");
	}
	
	//KOVA Players
	if((StrEqual(szBotName, "pietola")) || (StrEqual(szBotName, "Derkeps")) || (StrEqual(szBotName, "uli")) || (StrEqual(szBotName, "peku")) || (StrEqual(szBotName, "Twixie")))
	{
		CS_SetClientClanTag(client, "KOVA");
	}
	
	//CR4ZY Players
	if((StrEqual(szBotName, "DemQQ")) || (StrEqual(szBotName, "Sergiz")) || (StrEqual(szBotName, "7oX1C")) || (StrEqual(szBotName, "Psycho")) || (StrEqual(szBotName, "SENSEi")))
	{
		CS_SetClientClanTag(client, "CR4ZY");
	}
	
	//Redemption Players
	if((StrEqual(szBotName, "drg")) || (StrEqual(szBotName, "ALLE")) || (StrEqual(szBotName, "remix")) || (StrEqual(szBotName, "w1")) || (StrEqual(szBotName, "dok")))
	{
		CS_SetClientClanTag(client, "Redemption");
	}
	
	//eXploit Players
	if((StrEqual(szBotName, "pizituh")) || (StrEqual(szBotName, "BuJ")) || (StrEqual(szBotName, "sark")) || (StrEqual(szBotName, "renatoohaxx")) || (StrEqual(szBotName, "BLOODZ")))
	{
		CS_SetClientClanTag(client, "eXploit");
	}
	
	//AGF Players
	if((StrEqual(szBotName, "fr0slev")) || (StrEqual(szBotName, "Kristou")) || (StrEqual(szBotName, "netrick")) || (StrEqual(szBotName, "TMB")) || (StrEqual(szBotName, "Lukki")))
	{
		CS_SetClientClanTag(client, "AGF");
	}
	
	//LLL Players
	if((StrEqual(szBotName, "notaN")) || (StrEqual(szBotName, "G1DO")) || (StrEqual(szBotName, "marix")) || (StrEqual(szBotName, "v1N")) || (StrEqual(szBotName, "Monu")))
	{
		CS_SetClientClanTag(client, "LLL");
	}
	
	//GameAgents Players
	if((StrEqual(szBotName, "SEMINTE")) || (StrEqual(szBotName, "r1d3r")) || (StrEqual(szBotName, "KunKKa")) || (StrEqual(szBotName, "nJ")) || (StrEqual(szBotName, "COSMEEEN")))
	{
		CS_SetClientClanTag(client, "GameAgents");
	}
	
	//Keyd Players
	if((StrEqual(szBotName, "bnc")) || (StrEqual(szBotName, "mawth")) || (StrEqual(szBotName, "tifa")) || (StrEqual(szBotName, "jota")) || (StrEqual(szBotName, "puni")))
	{
		CS_SetClientClanTag(client, "Keyd");
	}
	
	//Epsilon Players
	if((StrEqual(szBotName, "ALEXJ")) || (StrEqual(szBotName, "smogger")) || (StrEqual(szBotName, "Celebrations")) || (StrEqual(szBotName, "Masti")) || (StrEqual(szBotName, "Blytz")))
	{
		CS_SetClientClanTag(client, "Epsilon");
	}
	
	//TIGER Players
	if((StrEqual(szBotName, "erkaSt")) || (StrEqual(szBotName, "nin9")) || (StrEqual(szBotName, "dobu")) || (StrEqual(szBotName, "kabal")) || (StrEqual(szBotName, "ncl")))
	{
		CS_SetClientClanTag(client, "TIGER");
	}
	
	//LEISURE Players
	if((StrEqual(szBotName, "stefank0k0")) || (StrEqual(szBotName, "NIXEED")) || (StrEqual(szBotName, "JSXIce")) || (StrEqual(szBotName, "fly")) || (StrEqual(szBotName, "ser")))
	{
		CS_SetClientClanTag(client, "LEISURE");
	}
	
	//PENTA Players
	if((StrEqual(szBotName, "pdy")) || (StrEqual(szBotName, "red")) || (StrEqual(szBotName, "neviZ")) || (StrEqual(szBotName, "xenn")) || (StrEqual(szBotName, "syNx")))
	{
		CS_SetClientClanTag(client, "PENTA");
	}
	
	//PENTA Players
	if((StrEqual(szBotName, "sh1zlEE")) || (StrEqual(szBotName, "Jaepe")) || (StrEqual(szBotName, "brA")) || (StrEqual(szBotName, "plat")) || (StrEqual(szBotName, "Cunha")))
	{
		CS_SetClientClanTag(client, "FTW");
	}
	
	//Titans Players
	if((StrEqual(szBotName, "simix")) || (StrEqual(szBotName, "ritchiEE")) || (StrEqual(szBotName, "Luz")) || (StrEqual(szBotName, "sarenii")) || (StrEqual(szBotName, "DENZSTOU")))
	{
		CS_SetClientClanTag(client, "Titans");
	}
	
	//9INE Players
	if((StrEqual(szBotName, "CyderX")) || (StrEqual(szBotName, "xfl0ud")) || (StrEqual(szBotName, "qRaxs")) || (StrEqual(szBotName, "Izzy")) || (StrEqual(szBotName, "QutionerX")))
	{
		CS_SetClientClanTag(client, "9INE");
	}
	
	//QBF Players
	if((StrEqual(szBotName, "JACKPOT")) || (StrEqual(szBotName, "Quantium")) || (StrEqual(szBotName, "Kas9k")) || (StrEqual(szBotName, "rommi")) || (StrEqual(szBotName, "lesswill")))
	{
		CS_SetClientClanTag(client, "QBF");
	}
	
	//Tigers Players
	if((StrEqual(szBotName, "MAXX")) || (StrEqual(szBotName, "Lastík")) || (StrEqual(szBotName, "zyored")) || (StrEqual(szBotName, "wEAMO")) || (StrEqual(szBotName, "manguss")))
	{
		CS_SetClientClanTag(client, "Tigers");
	}
	
	//9z Players
	if((StrEqual(szBotName, "dgt")) || (StrEqual(szBotName, "try")) || (StrEqual(szBotName, "maxujas")) || (StrEqual(szBotName, "bit")) || (StrEqual(szBotName, "meyern")))
	{
		CS_SetClientClanTag(client, "9z");
	}
	
	//Malvinas Players
	if((StrEqual(szBotName, "gAtito")) || (StrEqual(szBotName, "fakzwall")) || (StrEqual(szBotName, "minimal")) || (StrEqual(szBotName, "kissmyaug")) || (StrEqual(szBotName, "rushardo")))
	{
		CS_SetClientClanTag(client, "Malvinas");
	}
	
	//Sinister5 Players
	if((StrEqual(szBotName, "zerOchaNce")) || (StrEqual(szBotName, "FreakY")) || (StrEqual(szBotName, "deviaNt")) || (StrEqual(szBotName, "spoof")) || (StrEqual(szBotName, "ELUSIVE")))
	{
		CS_SetClientClanTag(client, "Sinister5");
	}
	
	//SINNERS Players
	if((StrEqual(szBotName, "ZEDKO")) || (StrEqual(szBotName, "CaNNiE")) || (StrEqual(szBotName, "SHOCK")) || (StrEqual(szBotName, "beastik")) || (StrEqual(szBotName, "NEOFRAG")))
	{
		CS_SetClientClanTag(client, "SINNERS");
	}
	
	//Impact Players
	if((StrEqual(szBotName, "DaneJoris")) || (StrEqual(szBotName, "JoJo")) || (StrEqual(szBotName, "tconnors")) || (StrEqual(szBotName, "viz")) || (StrEqual(szBotName, "insane")))
	{
		CS_SetClientClanTag(client, "Impact");
	}
	
	//ERN Players
	if((strcmp(szBotName, "j1NZO") == 0) || (strcmp(szBotName, "mvN") == 0) || (strcmp(szBotName, "Kirby") == 0) || (strcmp(szBotName, "FreeZe") == 0) || (strcmp(szBotName, "S3NSEY") == 0))
	{
		CS_SetClientClanTag(client, "ERN");
	}
	
	//BL4ZE Players
	if((strcmp(szBotName, "Rossi") == 0) || (strcmp(szBotName, "Marzil") == 0) || (strcmp(szBotName, "SkRossi") == 0) || (strcmp(szBotName, "Raph") == 0) || (strcmp(szBotName, "cara") == 0))
	{
		CS_SetClientClanTag(client, "BL4ZE");
	}
	
	//Global Players
	if((strcmp(szBotName, "HellrangeR") == 0) || (strcmp(szBotName, "Karam1L") == 0) || (strcmp(szBotName, "hellff") == 0) || (strcmp(szBotName, "DEATHMAKER") == 0) || (strcmp(szBotName, "SpawN") == 0))
	{
		CS_SetClientClanTag(client, "Global");
	}
	
	//Conquer Players
	if((strcmp(szBotName, "NiNLeX") == 0) || (strcmp(szBotName, "RONDE") == 0) || (strcmp(szBotName, "S1rva") == 0) || (strcmp(szBotName, "jelo") == 0) || (strcmp(szBotName, "KonZero") == 0))
	{
		CS_SetClientClanTag(client, "Conquer");
	}
}

public void SetCustomPrivateRank(int client)
{
	char szClan[64];
	
	CS_GetClientClanTag(client, szClan, sizeof(szClan));
	
	if (StrEqual(szClan, "NiP"))
	{
		g_iProfileRank[client] = 41;
	}
	
	if (StrEqual(szClan, "MIBR"))
	{
		g_iProfileRank[client] = 42;
	}
	
	if (StrEqual(szClan, "FaZe"))
	{
		g_iProfileRank[client] = 43;
	}
	
	if (StrEqual(szClan, "Astralis"))
	{
		g_iProfileRank[client] = 44;
	}
	
	if (StrEqual(szClan, "C9"))
	{
		g_iProfileRank[client] = 45;
	}
	
	if (StrEqual(szClan, "G2"))
	{
		g_iProfileRank[client] = 46;
	}
	
	if (StrEqual(szClan, "fnatic"))
	{
		g_iProfileRank[client] = 47;
	}
	
	if (StrEqual(szClan, "North"))
	{
		g_iProfileRank[client] = 48;
	}
	
	if (StrEqual(szClan, "mouz"))
	{
		g_iProfileRank[client] = 49;
	}
	
	if (StrEqual(szClan, "TYLOO"))
	{
		g_iProfileRank[client] = 50;
	}
	
	if (StrEqual(szClan, "EG"))
	{
		g_iProfileRank[client] = 51;
	}
	
	if (StrEqual(szClan, "Thieves"))
	{
		g_iProfileRank[client] = 52;
	}
	
	if (StrEqual(szClan, "Na´Vi"))
	{
		g_iProfileRank[client] = 53;
	}
	
	if (StrEqual(szClan, "Liquid"))
	{
		g_iProfileRank[client] = 54;
	}
	
	if (StrEqual(szClan, "AGO"))
	{
		g_iProfileRank[client] = 55;
	}
	
	if (StrEqual(szClan, "ENCE"))
	{
		g_iProfileRank[client] = 56;
	}
	
	if (StrEqual(szClan, "Vitality"))
	{
		g_iProfileRank[client] = 57;
	}
	
	if (StrEqual(szClan, "BIG"))
	{
		g_iProfileRank[client] = 58;
	}
	
	if (StrEqual(szClan, "Triumph"))
	{
		g_iProfileRank[client] = 59;
	}
	
	if (StrEqual(szClan, "FURIA"))
	{
		g_iProfileRank[client] = 61;
	}
	
	if (StrEqual(szClan, "c0ntact"))
	{
		g_iProfileRank[client] = 62;
	}
	
	if (StrEqual(szClan, "coL"))
	{
		g_iProfileRank[client] = 63;
	}
	
	if (StrEqual(szClan, "ViCi"))
	{
		g_iProfileRank[client] = 64;
	}
	
	if (StrEqual(szClan, "forZe"))
	{
		g_iProfileRank[client] = 65;
	}
	
	if (StrEqual(szClan, "Winstrike"))
	{
		g_iProfileRank[client] = 66;
	}
	
	if (StrEqual(szClan, "Sprout"))
	{
		g_iProfileRank[client] = 67;
	}
	
	if (StrEqual(szClan, "Heroic"))
	{
		g_iProfileRank[client] = 68;
	}
	
	if (StrEqual(szClan, "INTZ"))
	{
		g_iProfileRank[client] = 69;
	}
	
	if (StrEqual(szClan, "VP"))
	{
		g_iProfileRank[client] = 70;
	}
	
	if (StrEqual(szClan, "Apeks"))
	{
		g_iProfileRank[client] = 71;
	}
	
	if (StrEqual(szClan, "aTTaX"))
	{
		g_iProfileRank[client] = 72;
	}
	
	if (StrEqual(szClan, "RNG"))
	{
		g_iProfileRank[client] = 73;
	}
	
	if (strcmp(szClan, "BL4ZE") == 0)
	{
		g_iProfileRank[client] = 74;
	}
	
	if (StrEqual(szClan, "Envy"))
	{
		g_iProfileRank[client] = 75;
	}
	
	if (StrEqual(szClan, "Spirit"))
	{
		g_iProfileRank[client] = 76;
	}
	
	if (strcmp(szClan, "ERN") == 0)
	{
		g_iProfileRank[client] = 77;
	}
	
	if (StrEqual(szClan, "LDLC"))
	{
		g_iProfileRank[client] = 78;
	}
	
	if (StrEqual(szClan, "Impact"))
	{
		g_iProfileRank[client] = 79;
	}
	
	if (StrEqual(szClan, "GamerLegion"))
	{
		g_iProfileRank[client] = 80;
	}
	
	if (StrEqual(szClan, "DIVIZON"))
	{
		g_iProfileRank[client] = 81;
	}
	
	if (StrEqual(szClan, "EYES"))
	{
		g_iProfileRank[client] = 82;
	}
	
	if (StrEqual(szClan, "Tricked"))
	{
		g_iProfileRank[client] = 83;
	}
	
	if (StrEqual(szClan, "Wolsung"))
	{
		g_iProfileRank[client] = 84;
	}
	
	if (StrEqual(szClan, "PDucks"))
	{
		g_iProfileRank[client] = 85;
	}
	
	if (StrEqual(szClan, "HAVU"))
	{
		g_iProfileRank[client] = 86;
	}
	
	if (StrEqual(szClan, "Lyngby"))
	{
		g_iProfileRank[client] = 87;
	}
	
	if (StrEqual(szClan, "GODSENT"))
	{
		g_iProfileRank[client] = 88;
	}
	
	if (StrEqual(szClan, "Nordavind"))
	{
		g_iProfileRank[client] = 89;
	}
	
	if (StrEqual(szClan, "SJ"))
	{
		g_iProfileRank[client] = 90;
	}
	
	if (StrEqual(szClan, "Bren"))
	{
		g_iProfileRank[client] = 91;
	}
	
	if (StrEqual(szClan, "SINNERS"))
	{
		g_iProfileRank[client] = 92;
	}
	
	if (StrEqual(szClan, "Giants"))
	{
		g_iProfileRank[client] = 93;
	}
	
	if (StrEqual(szClan, "Lions"))
	{
		g_iProfileRank[client] = 94;
	}
	
	if (StrEqual(szClan, "Riders"))
	{
		g_iProfileRank[client] = 95;
	}
	
	if (StrEqual(szClan, "OFFSET"))
	{
		g_iProfileRank[client] = 96;
	}
	
	if (StrEqual(szClan, "Sinister5"))
	{
		g_iProfileRank[client] = 97;
	}
	
	if (StrEqual(szClan, "eSuba"))
	{
		g_iProfileRank[client] = 98;
	}
	
	if (StrEqual(szClan, "Nexus"))
	{
		g_iProfileRank[client] = 99;
	}
	
	if (StrEqual(szClan, "PACT"))
	{
		g_iProfileRank[client] = 100;
	}
	
	if (StrEqual(szClan, "Heretics"))
	{
		g_iProfileRank[client] = 101;
	}
	
	if (StrEqual(szClan, "Lynn"))
	{
		g_iProfileRank[client] = 102;
	}
	
	if (StrEqual(szClan, "Nemiga"))
	{
		g_iProfileRank[client] = 103;
	}
	
	if (StrEqual(szClan, "pro100"))
	{
		g_iProfileRank[client] = 104;
	}
	
	if (StrEqual(szClan, "YaLLa"))
	{
		g_iProfileRank[client] = 105;
	}
	
	if (StrEqual(szClan, "Yeah"))
	{
		g_iProfileRank[client] = 106;
	}
	
	if (StrEqual(szClan, "Singularity"))
	{
		g_iProfileRank[client] = 107;
	}
	
	if (StrEqual(szClan, "DETONA"))
	{
		g_iProfileRank[client] = 108;
	}
	
	if (StrEqual(szClan, "Infinity"))
	{
		g_iProfileRank[client] = 109;
	}
	
	if (StrEqual(szClan, "Isurus"))
	{
		g_iProfileRank[client] = 110;
	}
	
	if (StrEqual(szClan, "paiN"))
	{
		g_iProfileRank[client] = 111;
	}
	
	if (StrEqual(szClan, "Sharks"))
	{
		g_iProfileRank[client] = 112;
	}
	
	if (StrEqual(szClan, "One"))
	{
		g_iProfileRank[client] = 113;
	}
	
	if (StrEqual(szClan, "W7M"))
	{
		g_iProfileRank[client] = 114;
	}
	
	if (StrEqual(szClan, "Avant"))
	{
		g_iProfileRank[client] = 115;
	}
	
	if (StrEqual(szClan, "Chiefs"))
	{
		g_iProfileRank[client] = 116;
	}
	
	if (StrEqual(szClan, "DIG"))
	{
		g_iProfileRank[client] = 117;
	}
	
	if (StrEqual(szClan, "ORDER"))
	{
		g_iProfileRank[client] = 118;
	}
	
	if (StrEqual(szClan, "BlackS"))
	{
		g_iProfileRank[client] = 119;
	}
	
	if (StrEqual(szClan, "SKADE"))
	{
		g_iProfileRank[client] = 120;
	}
	
	if (StrEqual(szClan, "Paradox"))
	{
		g_iProfileRank[client] = 121;
	}
	
	if (StrEqual(szClan, "PENTA"))
	{
		g_iProfileRank[client] = 122;
	}
	
	if (StrEqual(szClan, "FTW"))
	{
		g_iProfileRank[client] = 123;
	}
	
	if (StrEqual(szClan, "Beyond"))
	{
		g_iProfileRank[client] = 124;
	}
	
	if (StrEqual(szClan, "BOOM"))
	{
		g_iProfileRank[client] = 125;
	}
	
	if (StrEqual(szClan, "sAw"))
	{
		g_iProfileRank[client] = 126;
	}
	
	if (StrEqual(szClan, "CR4ZY"))
	{
		g_iProfileRank[client] = 127;
	}
	
	if (StrEqual(szClan, "OneThree"))
	{
		g_iProfileRank[client] = 128;
	}
	
	if (strcmp(szClan, "Global") == 0)
	{
		g_iProfileRank[client] = 129;
	}
	
	if (StrEqual(szClan, "NASR"))
	{
		g_iProfileRank[client] = 130;
	}
	
	if (StrEqual(szClan, "LEISURE"))
	{
		g_iProfileRank[client] = 131;
	}
	
	if (StrEqual(szClan, "Revolution"))
	{
		g_iProfileRank[client] = 132;
	}
	
	if (StrEqual(szClan, "SHIFT"))
	{
		g_iProfileRank[client] = 133;
	}
	
	if (StrEqual(szClan, "nxl"))
	{
		g_iProfileRank[client] = 134;
	}
	
	if (StrEqual(szClan, "Berzerk"))
	{
		g_iProfileRank[client] = 135;
	}
	
	if (StrEqual(szClan, "Energy"))
	{
		g_iProfileRank[client] = 136;
	}
	
	if (StrEqual(szClan, "Titans"))
	{
		g_iProfileRank[client] = 137;
	}
	
	if (strcmp(szClan, "Conquer") == 0)
	{
		g_iProfileRank[client] = 138;
	}
	
	if (StrEqual(szClan, "TIGER"))
	{
		g_iProfileRank[client] = 139;
	}
	
	if (StrEqual(szClan, "GroundZero"))
	{
		g_iProfileRank[client] = 140;
	}
	
	if (StrEqual(szClan, "AVEZ"))
	{
		g_iProfileRank[client] = 141;
	}
	
	if (StrEqual(szClan, "BTRG"))
	{
		g_iProfileRank[client] = 142;
	}
	
	if (StrEqual(szClan, "Gen.G"))
	{
		g_iProfileRank[client] = 143;
	}
	
	if (StrEqual(szClan, "Furious"))
	{
		g_iProfileRank[client] = 144;
	}
	
	if (StrEqual(szClan, "GTZ"))
	{
		g_iProfileRank[client] = 145;
	}
	
	if (StrEqual(szClan, "x6tence"))
	{
		g_iProfileRank[client] = 146;
	}
	
	if (StrEqual(szClan, "Epsilon"))
	{
		g_iProfileRank[client] = 147;
	}
	
	if (StrEqual(szClan, "LLL"))
	{
		g_iProfileRank[client] = 148;
	}
	
	if (StrEqual(szClan, "9INE"))
	{
		g_iProfileRank[client] = 149;
	}
	
	if (StrEqual(szClan, "Syman"))
	{
		g_iProfileRank[client] = 150;
	}
	
	if (StrEqual(szClan, "QBF"))
	{
		g_iProfileRank[client] = 151;
	}
	
	if (StrEqual(szClan, "Goliath"))
	{
		g_iProfileRank[client] = 152;
	}
	
	if (StrEqual(szClan, "Secret"))
	{
		g_iProfileRank[client] = 153;
	}
	
	if (StrEqual(szClan, "Incept"))
	{
		g_iProfileRank[client] = 154;
	}
	
	if (StrEqual(szClan, "Endpoint"))
	{
		g_iProfileRank[client] = 155;
	}
	
	if (StrEqual(szClan, "UOL"))
	{
		g_iProfileRank[client] = 156;
	}
	
	if (StrEqual(szClan, "GameAgents"))
	{
		g_iProfileRank[client] = 157;
	}
	
	if (StrEqual(szClan, "RADIX"))
	{
		g_iProfileRank[client] = 158;
	}
	
	if (StrEqual(szClan, "Redemption"))
	{
		g_iProfileRank[client] = 159;
	}
	
	if (StrEqual(szClan, "Keyd"))
	{
		g_iProfileRank[client] = 160;
	}
	
	if (StrEqual(szClan, "Illuminar"))
	{
		g_iProfileRank[client] = 161;
	}
	
	if (StrEqual(szClan, "Queso"))
	{
		g_iProfileRank[client] = 162;
	}
	
	if (StrEqual(szClan, "Wizards"))
	{
		g_iProfileRank[client] = 163;
	}
	
	if (StrEqual(szClan, "AGF"))
	{
		g_iProfileRank[client] = 164;
	}
	
	if (StrEqual(szClan, "eXploit"))
	{
		g_iProfileRank[client] = 165;
	}
	
	if (StrEqual(szClan, "IG"))
	{
		g_iProfileRank[client] = 166;
	}
	
	if (StrEqual(szClan, "HR"))
	{
		g_iProfileRank[client] = 167;
	}
	
	if (StrEqual(szClan, "Dice"))
	{
		g_iProfileRank[client] = 168;
	}
	
	if (StrEqual(szClan, "Tigers"))
	{
		g_iProfileRank[client] = 169;
	}
	
	if (StrEqual(szClan, "9z"))
	{
		g_iProfileRank[client] = 170;
	}
	
	if (StrEqual(szClan, "PlanetKey"))
	{
		g_iProfileRank[client] = 171;
	}
	
	if (StrEqual(szClan, "mCon"))
	{
		g_iProfileRank[client] = 172;
	}
	
	if (StrEqual(szClan, "Malvinas"))
	{
		g_iProfileRank[client] = 173;
	}
	
	if (StrEqual(szClan, "HLE"))
	{
		g_iProfileRank[client] = 174;
	}
	
	if (StrEqual(szClan, "Gambit"))
	{
		g_iProfileRank[client] = 175;
	}
	
	if (StrEqual(szClan, "Wisla"))
	{
		g_iProfileRank[client] = 176;
	}
	
	if (StrEqual(szClan, "Imperial"))
	{
		g_iProfileRank[client] = 177;
	}
	
	if (StrEqual(szClan, "Pompa"))
	{
		g_iProfileRank[client] = 178;
	}
	
	if (StrEqual(szClan, "Unique"))
	{
		g_iProfileRank[client] = 179;
	}
	
	if (StrEqual(szClan, "D13"))
	{
		g_iProfileRank[client] = 180;
	}
	
	if (StrEqual(szClan, "Izako"))
	{
		g_iProfileRank[client] = 181;
	}
	
	if (StrEqual(szClan, "ATK"))
	{
		g_iProfileRank[client] = 182;
	}
	
	if (StrEqual(szClan, "Chaos"))
	{
		g_iProfileRank[client] = 183;
	}
	
	if (StrEqual(szClan, "FATE"))
	{
		g_iProfileRank[client] = 184;
	}
	
	if (StrEqual(szClan, "Canids"))
	{
		g_iProfileRank[client] = 185;
	}
	
	if (StrEqual(szClan, "ESPADA"))
	{
		g_iProfileRank[client] = 186;
	}
	
	if (StrEqual(szClan, "OG"))
	{
		g_iProfileRank[client] = 187;
	}
	
	if (StrEqual(szClan, "ZIGMA"))
	{
		g_iProfileRank[client] = 188;
	}
	
	if (StrEqual(szClan, "Ambush"))
	{
		g_iProfileRank[client] = 189;
	}
	
	if (StrEqual(szClan, "KOVA"))
	{
		g_iProfileRank[client] = 190;
	}
}