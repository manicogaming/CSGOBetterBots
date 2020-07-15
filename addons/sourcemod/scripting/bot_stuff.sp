#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#include <eItems>
#include <csutils>

char g_sMap[128];
bool g_bFreezetimeEnd = false;
bool g_bBombPlanted = false;
bool g_bBodyShot[MAXPLAYERS+1];
bool g_bHasThrownNade[MAXPLAYERS+1];
int g_iProfileRank[MAXPLAYERS+1], g_iCoin[MAXPLAYERS+1], g_iRndSmoke[MAXPLAYERS+1], g_iProfileRankOffset, g_iCoinOffset, g_iRndExecute;
ConVar g_cvPredictionConVars[1] = {null};
Handle g_hGameConfig;
Handle g_hBotMoveTo;
Handle g_hLookupBone;
Handle g_hGetBonePosition;
Handle g_hBotAttack;
Handle g_hBotIsVisible;
Handle g_hBotIsBusy;

enum _BotRouteType
{
	SAFEST_ROUTE = 0,
	FASTEST_ROUTE,
	UNKNOWN_ROUTE
}

int g_iPatchDefIndex[] = {
	4550, 4551, 4552, 4553, 4554, 4555, 4556, 4557, 4558, 4559, 4560, 4561, 4562, 4563, 4564, 4565, 4566, 4567, 4568, 4569,
	4570, 4589, 4591, 4592, 4593, 4594, 4595, 4596, 4597, 4598, 4599, 4600
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
	"trk",
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
	"moose",
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
	"Jabbi",
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
	//EXECUTIONERS Players
	"ZesBeeW",
	"FamouZ",
	"maestro",
	"Snyder",
	"Sys",
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
	"rallen",
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
	"fanatyk",
	"jedqr",
	//Imperial Players
	"fnx",
	"zqk",
	"dzt",
	"delboNi",
	"SHOOWTiME",
	//Big5 Players
	"kustoM_",
	"Spartan",
	"konvict",
	"maniaq",
	"Tiaantjie",
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
	"Mistercap",
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
	"NABOWOW",
	"shellzy",
	"whatz",
	"plat",
	"RIZZ",
	//Titans Players
	"simix",
	"ritchiEE",
	"Luz",
	"sarenii",
	"DENZSTOU",
	//9INE Players
	"CyderX",
	"xfl0ud",
	"MYTH",
	"Izzy",
	"QutionerX",
	//nEophyte Players
	"tMs1k",
	"Neci",
	"traxX",
	"iNvis",
	"ANSONE",
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
	"NEOFRAG"
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
	
	g_cvPredictionConVars[0] = FindConVar("weapon_recoil_scale");
	
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
	RegConsoleCmd("team_executioners", Team_EXECUTIONERS);
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
	RegConsoleCmd("team_baecon", Team_Baecon);
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
	RegConsoleCmd("team_neophyte", Team_nEophyte);
	RegConsoleCmd("team_tigers", Team_Tigers);
	RegConsoleCmd("team_9z", Team_9z);
	RegConsoleCmd("team_malvinas", Team_Malvinas);
	RegConsoleCmd("team_sinister5", Team_Sinister5);
	RegConsoleCmd("team_sinners", Team_SINNERS);
}

public Action Team_NiP(int client, int args)
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

public Action Team_VP(int client, int args)
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

public Action Team_LDLC(int client, int args)
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

public Action Team_GamerLegion(int client, int args)
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

public Action Team_EYES(int client, int args)
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

public Action Team_Wolsung(int client, int args)
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

public Action Team_PDucks(int client, int args)
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

public Action Team_Nordavind(int client, int args)
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
		ServerCommand("bot_add_ct %s", "Remoy");
		ServerCommand("bot_add_ct %s", "TOBIZ");
		ServerCommand("bot_add_ct %s", "Celrate");
		ServerCommand("mp_teamlogo_1 sing");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Jabbi");
		ServerCommand("bot_add_t %s", "mertz");
		ServerCommand("bot_add_t %s", "Remoy");
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

public Action Team_One(int client, int args)
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

public Action Team_W7M(int client, int args)
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

public Action Team_Berzerk(int client, int args)
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

public Action Team_Furious(int client, int args)
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

public Action Team_AVEZ(int client, int args)
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

public Action Team_BTRG(int client, int args)
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

public Action Team_GTZ(int client, int args)
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

public Action Team_x6tence(int client, int args)
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

public Action Team_Goliath(int client, int args)
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

public Action Team_Secret(int client, int args)
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

public Action Team_Incept(int client, int args)
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
		ServerCommand("bot_add_ct %s", "rallen");
		ServerCommand("mp_teamlogo_1 illu");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Vegi");
		ServerCommand("bot_add_t %s", "Snax");
		ServerCommand("bot_add_t %s", "mouz");
		ServerCommand("bot_add_t %s", "innocent");
		ServerCommand("bot_add_t %s", "rallen");
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

public Action Team_PlanetKey(int client, int args)
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

public Action Team_Big5(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "kustoM_");
		ServerCommand("bot_add_ct %s", "Spartan");
		ServerCommand("bot_add_ct %s", "konvict");
		ServerCommand("bot_add_ct %s", "maniaq");
		ServerCommand("bot_add_ct %s", "Tiaantjie");
		ServerCommand("mp_teamlogo_1 big5");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "kustoM_");
		ServerCommand("bot_add_t %s", "Spartan");
		ServerCommand("bot_add_t %s", "konvict");
		ServerCommand("bot_add_t %s", "maniaq");
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

public Action Team_Chaos(int client, int args)
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

public Action Team_Canids(int client, int args)
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

public Action Team_Wizards(int client, int args)
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
		ServerCommand("bot_add_ct %s", "Mistercap");
		ServerCommand("bot_add_ct %s", "sK0R");
		ServerCommand("bot_add_ct %s", "ANNIHILATION");
		ServerCommand("mp_teamlogo_1 d13");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Tamiraarita");
		ServerCommand("bot_add_t %s", "rate");
		ServerCommand("bot_add_t %s", "Mistercap");
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

public Action Team_LLL(int client, int args)
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

public Action Team_GameAgents(int client, int args)
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

public Action Team_Keyd(int client, int args)
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

public Action Team_Epsilon(int client, int args)
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

public Action Team_TIGER(int client, int args)
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

public Action Team_LEISURE(int client, int args)
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

public Action Team_PENTA(int client, int args)
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

public Action Team_FTW(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "NABOWOW");
		ServerCommand("bot_add_ct %s", "shellzy");
		ServerCommand("bot_add_ct %s", "whatz");
		ServerCommand("bot_add_ct %s", "plat");
		ServerCommand("bot_add_ct %s", "RIZZ");
		ServerCommand("mp_teamlogo_1 ftw");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "NABOWOW");
		ServerCommand("bot_add_t %s", "shellzy");
		ServerCommand("bot_add_t %s", "whatz");
		ServerCommand("bot_add_t %s", "plat");
		ServerCommand("bot_add_t %s", "RIZZ");
		ServerCommand("mp_teamlogo_2 ftw");
	}

	return Plugin_Handled;
}

public Action Team_Titans(int client, int args)
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

public Action Team_9INE(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "CyderX");
		ServerCommand("bot_add_ct %s", "xfl0ud");
		ServerCommand("bot_add_ct %s", "MYTH");
		ServerCommand("bot_add_ct %s", "Izzy");
		ServerCommand("bot_add_ct %s", "QutionerX");
		ServerCommand("mp_teamlogo_1 9ine");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "CyderX");
		ServerCommand("bot_add_t %s", "xfl0ud");
		ServerCommand("bot_add_t %s", "MYTH");
		ServerCommand("bot_add_t %s", "Izzy");
		ServerCommand("bot_add_t %s", "QutionerX");
		ServerCommand("mp_teamlogo_2 9ine");
	}

	return Plugin_Handled;
}

public Action Team_nEophyte(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "tMs1k");
		ServerCommand("bot_add_ct %s", "Neci");
		ServerCommand("bot_add_ct %s", "traxX");
		ServerCommand("bot_add_ct %s", "iNvis");
		ServerCommand("bot_add_ct %s", "QutionerX");
		ServerCommand("mp_teamlogo_1 neo");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "tMs1k");
		ServerCommand("bot_add_t %s", "Neci");
		ServerCommand("bot_add_t %s", "traxX");
		ServerCommand("bot_add_t %s", "iNvis");
		ServerCommand("bot_add_t %s", "ANSONE");
		ServerCommand("mp_teamlogo_2 neo");
	}

	return Plugin_Handled;
}

public Action Team_Tigers(int client, int args)
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

public Action Team_9z(int client, int args)
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

public Action Team_Malvinas(int client, int args)
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

public Action Team_Sinister5(int client, int args)
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

public Action Team_SINNERS(int client, int args)
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
	g_iProfileRank[client] = GetRandomInt(1,40);

	if(IsValidClient(client) && IsFakeClient(client))
	{
		char botname[512];
		GetClientName(client, botname, sizeof(botname));
		
		Pro_Players(botname, client);
		
		SetCustomPrivateRank(client);
		
		SDKHook(client, SDKHook_WeaponSwitch, Hook_WeaponSwitch);	
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
			if(IsFakeClient(i))
			{
				SetEntProp(i, Prop_Send, "m_unMusicID", eItems_GetMusicKitDefIndexByMusicKitNum(GetRandomInt(0, eItems_GetMusicKitsCount() -1)));
			}
			
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
					SetEntityModel(i, g_sCTModels[GetRandomInt(0, sizeof(g_sCTModels) - 1)]);
					
					if(GetRandomInt(1,100) <= 40)
					{
						if(GetRandomInt(1,100) <= 75)
						{
							int rndpatches = GetRandomInt(1,14);
						
							switch (rndpatches)
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
							int rndpatches = GetRandomInt(1,2);
							
							switch(rndpatches)
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
					SetEntityModel(i, g_sTModels[GetRandomInt(0, sizeof(g_sTModels) - 1)]);
					
					if(GetRandomInt(1,100) <= 40)
					{
						if(GetRandomInt(1,100) <= 65)
						{
							int rndpatches = GetRandomInt(1,14);
						
							switch (rndpatches)
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
							int rndpatches = GetRandomInt(1,2);
							
							switch(rndpatches)
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
			
			if(StrEqual(g_sMap, "de_mirage"))
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
			else if(StrEqual(g_sMap, "de_dust2"))
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
	
	GetCurrentMap(g_sMap, sizeof(g_sMap));
	
	if(StrEqual(g_sMap, "de_mirage"))
	{
		g_iRndExecute = GetRandomInt(1,3);
	}
	else if(StrEqual(g_sMap, "de_dust2"))
	{
		g_iRndExecute = GetRandomInt(1,4);
	}
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
		
		if((GetAliveTeamCount(CS_TEAM_T) == 0 || GetAliveTeamCount(CS_TEAM_CT) == 0) && (index == 41 || index == 42 || index == 59 || index == 500 || index == 503 || index == 505 || index == 506 || index == 507 || index == 508 || index == 509 || index == 512 || index == 514 || index == 515 || index == 516 || index == 517 || index == 518 || index == 519 || index == 520 || index == 521 || index == 522 || index == 523 || index == 525))
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
		if(!g_bFreezetimeEnd && GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) != -1 && !((StrEqual(weapon,"molotov") || StrEqual(weapon,"incgrenade") || StrEqual(weapon,"decoy") || StrEqual(weapon,"flashbang") || StrEqual(weapon,"hegrenade") || StrEqual(weapon,"smokegrenade"))))
		{
			return Plugin_Handled;
		}
	
		int m_iAccount = GetEntProp(client, Prop_Send, "m_iAccount");
		
		if(StrEqual(weapon,"m4a1"))
		{
			if(GetRandomInt(1,100) <= 30)
			{
				CSGO_SetMoney(client, m_iAccount - 2900);
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_m4a1_silencer");
				
				return Plugin_Handled; 
			}
			else if(GetRandomInt(1,100) <= 5)
			{
				CSGO_SetMoney(client, m_iAccount - 3300);
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_aug");
				
				return Plugin_Handled; 
			}
			else
			{
				return Plugin_Continue;
			}
		}
		else if(StrEqual(weapon,"ak47"))
		{
			if(GetRandomInt(1,100) <= 5)
			{
				CSGO_SetMoney(client, m_iAccount - 3000);
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_sg556");
				
				return Plugin_Handled; 
			}
		}
		else if(StrEqual(weapon,"mac10"))
		{
			if(GetRandomInt(1,100) <= 40)
			{
				CSGO_SetMoney(client, m_iAccount - 1800);
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_galilar");
				
				return Plugin_Handled; 
			}
			else
			{
				return Plugin_Continue;
			}
		}
		else if(StrEqual(weapon,"mp9"))
		{
			if(GetRandomInt(1,100) <= 40)
			{
				CSGO_SetMoney(client, m_iAccount - 2050);
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

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if (!IsFakeClient(client)) return Plugin_Continue;
	
	int ActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"); 
	if (ActiveWeapon == -1)  return Plugin_Continue;
	
	int index = GetEntProp(ActiveWeapon, Prop_Send, "m_iItemDefinitionIndex");
	
	if(IsValidClient(client) && IsPlayerAlive(client))
	{
		if((GetAliveTeamCount(CS_TEAM_T) == 0 || GetAliveTeamCount(CS_TEAM_CT) == 0) && !(index == 49 || index == 41 || index == 42 || index == 59 || index == 500 || index == 503 || index == 505 || index == 506 || index == 507 || index == 508 || index == 509 || index == 512 || index == 514 || index == 515 || index == 516 || index == 517 || index == 518 || index == 519 || index == 520 || index == 521 || index == 522 || index == 523 || index == 525))
		{
			FakeClientCommandEx(client, "use weapon_knife");
		}

		char botname[512];
		GetClientName(client, botname, sizeof(botname));
		
		for(int i = 0; i <= sizeof(g_sBotName) - 1; i++)
		{
			if(StrEqual(botname, g_sBotName[i]))
			{				
				float clientEyes[3], targetEyes[3];
				GetClientEyePosition(client, clientEyes);
				int Ent = GetClosestClient(client);
				int iClipAmmo = GetEntProp(ActiveWeapon, Prop_Send, "m_iClip1");
				bool bInReload = view_as<bool>(GetEntProp(ActiveWeapon, Prop_Data, "m_bInReload"));
				
				if (g_bFreezetimeEnd && iClipAmmo > 0 && !bInReload)
				{
					if(IsValidClient(Ent))
					{	
						if(GetEntityMoveType(client) == MOVETYPE_LADDER)
						{
							buttons |= IN_JUMP;
							return Plugin_Changed;
						}
						
						GetClientAbsOrigin(Ent, targetEyes);
						
						if((IsWeaponSlotActive(client, CS_SLOT_PRIMARY) && index != 40 && index != 11 && index != 38 && index != 9) || index == 63)
						{
							if(g_bBodyShot[client])
							{
								int iBone = LookupBone(Ent, "spine_2");
								
								if(iBone < 0)
									continue;
									
								float vecBody[3], vecBad[3];
								GetBonePosition(Ent, iBone, vecBody, vecBad);
								
								targetEyes = vecBody;
							}
							else
							{
								if(GetRandomInt(1,3) == 1)
								{
									int iBone = LookupBone(Ent, "head_0");
									if(iBone < 0)
										continue;
										
									float vecHead[3], vecBad[3];
									GetBonePosition(Ent, iBone, vecHead, vecBad);
									
									targetEyes = vecHead;
								}
								else
								{
									int iBone = LookupBone(Ent, "spine_2");
									
									if(iBone < 0)
										continue;
										
									float vecBody[3], vecBad[3];
									GetBonePosition(Ent, iBone, vecBody, vecBad);
									
									if(BotIsVisible(client, vecBody, false, client))
									{
										targetEyes = vecBody;
									}
									else
									{
										iBone = LookupBone(Ent, "head_0");
										if(iBone < 0)
											continue;
											
										float vecHead[3];
										GetBonePosition(Ent, iBone, vecHead, vecBad);
										
										targetEyes = vecHead;
									}
								}	
							}
							
							buttons |= IN_ATTACK;
							
							if(!(GetEntityFlags(client) & FL_DUCKING))
							{
								vel[0] = 0.0;
								vel[1] = 0.0;
								vel[2] = 0.0;
							}
						}
						else if(IsWeaponSlotActive(client, CS_SLOT_SECONDARY) && index != 63 && index != 1)
						{
							if(g_bBodyShot[client])
							{
								int iBone = LookupBone(Ent, "spine_2");
								
								if(iBone < 0)
									continue;
									
								float vecBody[3], vecBad[3];
								GetBonePosition(Ent, iBone, vecBody, vecBad);
								
								targetEyes = vecBody;
							}
							else
							{
								if(GetRandomInt(1,3) == 1)
								{
									int iBone = LookupBone(Ent, "head_0");
									if(iBone < 0)
										continue;
										
									float vecHead[3], vecBad[3];
									GetBonePosition(Ent, iBone, vecHead, vecBad);
									
									targetEyes = vecHead;
								}
								else
								{
									int iBone = LookupBone(Ent, "spine_2");
									
									if(iBone < 0)
										continue;
										
									float vecBody[3], vecBad[3];
									GetBonePosition(Ent, iBone, vecBody, vecBad);
									
									if(BotIsVisible(client, vecBody, false, client))
									{
										targetEyes = vecBody;
									}
									else
									{
										iBone = LookupBone(Ent, "head_0");
										if(iBone < 0)
											continue;
											
										float vecHead[3];
										GetBonePosition(Ent, iBone, vecHead, vecBad);
										
										targetEyes = vecHead;
									}
								}	
							}
						}
						else if(index == 1)
						{
							if(g_bBodyShot[client])
							{
								int iBone = LookupBone(Ent, "spine_2");
								
								if(iBone < 0)
									continue;
									
								float vecBody[3], vecBad[3];
								GetBonePosition(Ent, iBone, vecBody, vecBad);
								
								targetEyes = vecBody;
							}
							else
							{
								int iBone = LookupBone(Ent, "head_0");
								if(iBone < 0)
									continue;
									
								float vecHead[3], vecBad[3];
								GetBonePosition(Ent, iBone, vecHead, vecBad);
								
								targetEyes = vecHead;	
							}
						}
						else if(index == 40 || index == 11 || index == 38)
						{
							if(g_bBodyShot[client])
							{
								int iBone = LookupBone(Ent, "spine_2");
								
								if(iBone < 0)
									continue;
									
								float vecBody[3], vecBad[3];
								GetBonePosition(Ent, iBone, vecBody, vecBad);
								
								targetEyes = vecBody;
							}
							else
							{
								if(GetRandomInt(1,3) == 1)
								{
									int iBone = LookupBone(Ent, "head_0");
									if(iBone < 0)
										continue;
										
									float vecHead[3], vecBad[3];
									GetBonePosition(Ent, iBone, vecHead, vecBad);
									
									targetEyes = vecHead;
								}
								else
								{
									int iBone = LookupBone(Ent, "spine_2");
									
									if(iBone < 0)
										continue;
										
									float vecBody[3], vecBad[3];
									GetBonePosition(Ent, iBone, vecBody, vecBad);
									
									if(BotIsVisible(client, vecBody, false, client))
									{
										targetEyes = vecBody;
									}
									else
									{
										iBone = LookupBone(Ent, "head_0");
										if(iBone < 0)
											continue;
											
										float vecHead[3];
										GetBonePosition(Ent, iBone, vecHead, vecBad);
										
										targetEyes = vecHead;
									}
								}	
							}
						}
						else if(index == 9)
						{							
							int iBone = LookupBone(Ent, "spine_2");
							if(iBone < 0)
								continue;
								
							float vecBody[3], vecBad[3];
							GetBonePosition(Ent, iBone, vecBody, vecBad);
							
							if(BotIsVisible(client, vecBody, false, client))
							{
								targetEyes = vecBody;
							}
							else
							{
								iBone = LookupBone(Ent, "head_0");
								if(iBone < 0)
									continue;
									
								float vecHead[3];
								GetBonePosition(Ent, iBone, vecHead, vecBad);
								
								targetEyes = vecHead;
							}
						}
						else
						{
							return Plugin_Continue;
						}
						
						float eye_to_target[3];
			
						SubtractVectors(VelocityExtrapolate(Ent, targetEyes), VelocityExtrapolate(client, clientEyes), eye_to_target);
										
						GetVectorAngles(eye_to_target, eye_to_target);
						
						eye_to_target[0] = AngleNormalize(eye_to_target[0]);
						eye_to_target[1] = AngleNormalize(eye_to_target[1]);
						eye_to_target[2] = 0.0;

						float vPunch[3];
						
						GetEntPropVector(client, Prop_Send, "m_aimPunchAngle", vPunch);
						
						ScaleVector(vPunch, -(FindConVar("weapon_recoil_scale").FloatValue));
						
						AddVectors(eye_to_target, vPunch, eye_to_target);
						
						if(IsTargetInSightRange(client, Ent, 5.0))
						{
							TeleportEntity(client, NULL_VECTOR, eye_to_target, NULL_VECTOR);
						}
						else
						{
							SmoothAim(client, eye_to_target, GetRandomFloat(0.5, 0.9));
						}
						
						BotAttack(client, Ent);
						
						if (buttons & IN_ATTACK)
						{
							if(index == 7 || index == 8 || index == 10 || index == 13 || index == 14 || index == 16 || index == 39 || index == 60 || index == 28)
							{
								buttons |= IN_DUCK;
								return Plugin_Changed;
							}
						}
						
						return Plugin_Changed;
					}
				}
				
				if(g_bFreezetimeEnd && !g_bBombPlanted && GetEntityMoveType(client) != MOVETYPE_LADDER && !BotIsBusy(client))
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
						
						float location_check[3];
						GetClientAbsOrigin(client, location_check);
						GetEntPropVector(weapon_ak47, Prop_Send, "m_vecOrigin", ak47location);		
						
						float distance = GetVectorDistance(location_check, ak47location);

						if(distance < 750 && ((ak47location[0] != 0.0) && (ak47location[1] != 0.0) && (ak47location[2] != 0.0)))
						{
							BotMoveTo(client, ak47location, SAFEST_ROUTE);
						}
					}
					else if(weapon_ak47 != -1 && primary == -1)
					{
						GetEntPropVector(weapon_ak47, Prop_Send, "m_vecOrigin", ak47location);		
						
						float location_check[3];
						GetClientAbsOrigin(client, location_check);
						GetEntPropVector(weapon_ak47, Prop_Send, "m_vecOrigin", ak47location);		
						
						float distance = GetVectorDistance(location_check, ak47location);

						if(distance < 750 && ((ak47location[0] != 0.0) && (ak47location[1] != 0.0) && (ak47location[2] != 0.0)))
						{
							BotMoveTo(client, ak47location, SAFEST_ROUTE);
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
						
						if(distance < 750 && ((deaglelocation[0] != 0.0) && (deaglelocation[1] != 0.0) && (deaglelocation[2] != 0.0)))
						{
							BotMoveTo(client, deaglelocation, SAFEST_ROUTE);
						}
						
						if(distance < 25 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
						{
							CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false, false);
						}
					}
					
					if(weapon_tec9 != -1 && ((secondaryindex == 4) || (secondaryindex == 32) || (secondaryindex == 61) || (secondaryindex == 36)))
					{
						float location_check[3];
						GetClientAbsOrigin(client, location_check);
						GetEntPropVector(weapon_tec9, Prop_Send, "m_vecOrigin", tec9location);		
						
						float distance = GetVectorDistance(location_check, tec9location);
						
						if(distance < 750 && ((tec9location[0] != 0.0) && (tec9location[1] != 0.0) && (tec9location[2] != 0.0)))
						{
							BotMoveTo(client, tec9location, SAFEST_ROUTE);
						}
						
						if(distance < 25 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
						{
							CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false, false);
						}
					}
					
					if(weapon_fiveseven != -1 && ((secondaryindex == 4) || (secondaryindex == 32) || (secondaryindex == 61) || (secondaryindex == 36)))
					{
						float location_check[3];
						GetClientAbsOrigin(client, location_check);
						GetEntPropVector(weapon_fiveseven, Prop_Send, "m_vecOrigin", fivesevenlocation);		
						
						float distance = GetVectorDistance(location_check, fivesevenlocation);
						
						if(distance < 750 && ((fivesevenlocation[0] != 0.0) && (fivesevenlocation[1] != 0.0) && (fivesevenlocation[2] != 0.0)))
						{
							BotMoveTo(client, fivesevenlocation, SAFEST_ROUTE);
						}
						
						if(distance < 25 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
						{
							CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false, false);
						}
					}
					
					if(weapon_p250 != -1 && ((secondaryindex == 4) || (secondaryindex == 32) || (secondaryindex == 61)))
					{
						float location_check[3];
						GetClientAbsOrigin(client, location_check);
						GetEntPropVector(weapon_p250, Prop_Send, "m_vecOrigin", p250location);		
						
						float distance = GetVectorDistance(location_check, p250location);
						
						if(distance < 750 && ((p250location[0] != 0.0) && (p250location[1] != 0.0) && (p250location[2] != 0.0)))
						{
							BotMoveTo(client, p250location, SAFEST_ROUTE);
						}
						
						if(distance < 25 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
						{
							CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false, false);
						}
					}
					
					if(weapon_usp_silencer != -1 && secondaryindex == 4)
					{
						float location_check[3];
						GetClientAbsOrigin(client, location_check);
						GetEntPropVector(weapon_usp_silencer, Prop_Send, "m_vecOrigin", usplocation);		
						
						float distance = GetVectorDistance(location_check, usplocation);
						
						if(distance < 750 && ((usplocation[0] != 0.0) && (usplocation[1] != 0.0) && (usplocation[2] != 0.0)))
						{
							BotMoveTo(client, usplocation, SAFEST_ROUTE);
						}
						
						if(distance < 25 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
						{
							CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false, false);
						}
					}
				}
				
				if (g_bFreezetimeEnd && !g_bBombPlanted && ActiveWeapon != -1)
				{
					GetCurrentMap(g_sMap, sizeof(g_sMap));
					
					if(StrEqual(g_sMap, "de_mirage"))
					{
						DoMirageSmokes(client);
					}
					else if(StrEqual(g_sMap, "de_dust2"))
					{
						DoDust2Smokes(client);
					}
				}
			}
		}
	}

	return Plugin_Continue;
}

public void CSU_OnThrowGrenade(int client, int entity, GrenadeType grenadeType, const float origin[3], const float velocity[3])
{
	PrintToChat(client, "origin[0] = %f;", origin[0]);
	PrintToChat(client, "origin[1] = %f;", origin[1]);
	PrintToChat(client, "origin[2] = %f;", origin[2]);
	PrintToChat(client, "velocity[0] = %f;", velocity[0]);
	PrintToChat(client, "velocity[1] = %f;", velocity[1]);
	PrintToChat(client, "velocity[2] = %f;", velocity[2]);
}

public void OnPlayerSpawn(Handle event, const char[] name, bool dontBroadcast) 
{
	for (int i = 1; i <= MaxClients; i++)
	{		
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
						CSGO_ReplaceWeapon(i, CS_SLOT_SECONDARY, "weapon_usp_silencer");
					}
				}
			}
		}
	}
}

public Action Timer_CheckPlayer(Handle Timer, any data)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsFakeClient(i))
		{
			int m_iAccount = GetEntProp(i, Prop_Send, "m_iAccount");
			bool m_bInBuyZone = view_as<bool>(GetEntProp(i, Prop_Send, "m_bInBuyZone"));
			
			if(GetRandomInt(1,100) <= 5)
			{
				FakeClientCommandEx(i, "+lookatweapon");
				FakeClientCommandEx(i, "-lookatweapon");
			}
			
			if(m_iAccount == 800 && m_bInBuyZone)
			{
				FakeClientCommandEx(i, "buy vest");
			}
			else if(m_iAccount > 2500 && m_bInBuyZone && ((GetEntProp(i, Prop_Data, "m_ArmorValue") < 50) || (GetEntProp(i, Prop_Send, "m_bHasHelmet") == 0)))
			{
				FakeClientCommandEx(i, "buy vesthelm");
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
	
	int iPrimary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
	char default_primary[64];
	GetClientWeapon(client, default_primary, sizeof(default_primary));

	if((m_iAccount > 1500) && (m_iAccount < 2500) && iPrimary == -1 && (StrEqual(default_primary, "weapon_hkp2000") || StrEqual(default_primary, "weapon_usp_silencer") || StrEqual(default_primary, "weapon_glock")))
	{		
		int rndpistol = GetRandomInt(1,3);
		
		switch(rndpistol)
		{
			case 1:
			{
				CSGO_ReplaceWeapon(client, CS_SLOT_SECONDARY, "weapon_p250");
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
							CSGO_ReplaceWeapon(client, CS_SLOT_SECONDARY, "weapon_fiveseven");
						}
						case 2:
						{
							CSGO_ReplaceWeapon(client, CS_SLOT_SECONDARY, "weapon_cz75a");
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
	else if(m_iAccount > 2500 || iPrimary != -1)
	{
		if((GetEntProp(client, Prop_Data, "m_ArmorValue") < 50) || (GetEntProp(client, Prop_Send, "m_bHasHelmet") == 0))
		{
			SetEntProp(client, Prop_Data, "m_ArmorValue", 100, 1); 
			SetEntProp(client, Prop_Send, "m_bHasHelmet", 1);
			
			CSGO_SetMoney(client, m_iAccount - 1000);
		}
		
		if (team == CS_TEAM_CT && GetEntProp(client, Prop_Send, "m_bHasDefuser") == 0) 
		{ 
			SetEntProp(client, Prop_Send, "m_bHasDefuser", 1);
			CSGO_SetMoney(client, m_iAccount - 400);
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

public void eItems_OnItemsSynced()
{
	GetCurrentMap(g_sMap, sizeof(g_sMap));
	
	ServerCommand("changelevel %s", g_sMap);
}

public void BotMoveTo(int client, float origin[3], _BotRouteType routeType)
{
	SDKCall(g_hBotMoveTo, client, origin, routeType);
}

public void BotAttack(int client, int enemy)
{
	SDKCall(g_hBotAttack, client, enemy);
}

public bool BotIsVisible(int client, float pos[3], bool testFOV, int ignore)
{
	return SDKCall(g_hBotIsVisible, client, pos, testFOV, ignore);
}

public bool BotIsBusy(int client)
{
	return SDKCall(g_hBotIsBusy, client);
}

stock int LookupBone(int iEntity, const char[] szName)
{
	return SDKCall(g_hLookupBone, iEntity, szName);
}

stock void GetBonePosition(int iEntity, int iBone, float origin[3], float angles[3])
{
	SDKCall(g_hGetBonePosition, iEntity, iBone, origin, angles);
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

stock void CSGO_SetMoney(int client, int amount)
{
	if (amount < 0)
		amount = 0;
	
	int max = FindConVar("mp_maxmoney").IntValue;
	
	if (amount > max)
		amount = max;
	
	SetEntProp(client, Prop_Send, "m_iAccount", amount);
}

stock int CSGO_ReplaceWeapon(int client, int slot, const char[] class)
{
	int weapon = GetPlayerWeaponSlot(client, slot);

	if (IsValidEntity(weapon))
	{
		if (GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity") != client)
			SetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity", client);

		CS_DropWeapon(client, weapon, false, true);
		AcceptEntityInput(weapon, "Kill");
	}

	weapon = GivePlayerItem(client, class);

	if (IsValidEntity(weapon))
		EquipPlayerWeapon(client, weapon);

	return weapon;
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

			if(StrEqual(clantag, "Gambit")) //30th
			{
				if (!IsTargetInSightRange(client, i, 50.0))
					continue;	
			}
			else if(StrEqual(clantag, "Heretics")) //29th
			{
				if (!IsTargetInSightRange(client, i, 60.0))
					continue;	
			}
			else if(StrEqual(clantag, "HAVU")) //28th
			{
				if (!IsTargetInSightRange(client, i, 70.0))
					continue;	
			}
			else if(StrEqual(clantag, "forZe")) //27th
			{
				if (!IsTargetInSightRange(client, i, 80.0))
					continue;	
			}
			else if(StrEqual(clantag, "Nemiga")) //26th
			{
				if (!IsTargetInSightRange(client, i, 90.0))
					continue;	
			}
			else if(StrEqual(clantag, "VP")) //25th
			{
				if (!IsTargetInSightRange(client, i, 100.0))
					continue;	
			}
			else if(StrEqual(clantag, "North")) //24th
			{
				if (!IsTargetInSightRange(client, i, 110.0))
					continue;	
			}
			else if(StrEqual(clantag, "C9")) //23rd
			{
				if (!IsTargetInSightRange(client, i, 120.0))
					continue;	
			}
			else if(StrEqual(clantag, "ENCE")) //22nd
			{
				if (!IsTargetInSightRange(client, i, 130.0))
					continue;	
			}
			else if(StrEqual(clantag, "GODSENT")) //21st
			{
				if (!IsTargetInSightRange(client, i, 140.0))
					continue;	
			}
			else if(StrEqual(clantag, "Spirit")) //20th
			{
				if (!IsTargetInSightRange(client, i, 150.0))
					continue;	
			}
			else if(StrEqual(clantag, "Lions")) //19th
			{
				if (!IsTargetInSightRange(client, i, 160.0))
					continue;	
			}
			else if(StrEqual(clantag, "Heroic")) //18th
			{
				if (!IsTargetInSightRange(client, i, 170.0))
					continue;	
			}
			else if(StrEqual(clantag, "Thieves")) //17th
			{
				if (!IsTargetInSightRange(client, i, 180.0))
					continue;	
			}
			else if(StrEqual(clantag, "OG")) //16th
			{
				if (!IsTargetInSightRange(client, i, 190.0))
					continue;	
			}
			else if(StrEqual(clantag, "MIBR")) //15th
			{
				if (!IsTargetInSightRange(client, i, 200.0))
					continue;	
			}
			else if(StrEqual(clantag, "Gen.G")) //14th
			{
				if (!IsTargetInSightRange(client, i, 210.0))
					continue;	
			}
			else if(StrEqual(clantag, "mouz")) //13th
			{
				if (!IsTargetInSightRange(client, i, 220.0))
					continue;	
			}
			else if(StrEqual(clantag, "NiP")) //12th
			{
				if (!IsTargetInSightRange(client, i, 230.0))
					continue;	
			}
			else if(StrEqual(clantag, "Astralis")) //11th
			{
				if (!IsTargetInSightRange(client, i, 240.0))
					continue;	
			}
			else if(StrEqual(clantag, "coL")) //10th
			{
				if (!IsTargetInSightRange(client, i, 250.0))
					continue;	
			}
			else if(StrEqual(clantag, "FURIA")) //9th
			{
				if (!IsTargetInSightRange(client, i, 260.0))
					continue;	
			}
			else if(StrEqual(clantag, "Liquid")) //8th
			{
				if (!IsTargetInSightRange(client, i, 270.0))
					continue;	
			}
			else if(StrEqual(clantag, "fnatic")) //7th
			{
				if (!IsTargetInSightRange(client, i, 280.0))
					continue;	
			}
			else if(StrEqual(clantag, "FaZe")) //6th
			{
				if (!IsTargetInSightRange(client, i, 290.0))
					continue;	
			}
			else if(StrEqual(clantag, "G2")) //5th
			{
				if (!IsTargetInSightRange(client, i, 300.0))
					continue;	
			}
			else if(StrEqual(clantag, "Na´Vi")) //4th
			{
				if (!IsTargetInSightRange(client, i, 310.0))
					continue;	
			}
			else if(StrEqual(clantag, "EG")) //3rd
			{
				if (!IsTargetInSightRange(client, i, 320.0))
					continue;	
			}
			else if(StrEqual(clantag, "Vitality")) //2nd
			{
				if (!IsTargetInSightRange(client, i, 330.0))
					continue;	
			}
			else if(StrEqual(clantag, "BIG")) //1st
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
			
			fClosestDistance = fTargetDistance;
			iClosestTarget = i;
		}
	}
	
	return iClosestTarget;
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

stock bool ClientCanSeeTarget(int client, int iTarget, float fDistance = 0.0, float fHeight = 50.0)
{
	float fClientEyes[3], fVecHead[3], fVecBad[3];
	
	GetClientEyePosition(client, fClientEyes);
	
	int iBone = LookupBone(iTarget, "head_0");
	if(iBone < 0)
		return false;
		
	GetBonePosition(iTarget, iBone, fVecHead, fVecBad);
	
	if(BotIsVisible(client, fVecHead, false, client))
	{
		g_bBodyShot[client] = false;
	}
	else
	{
		iBone = LookupBone(iTarget, "spine_2");
		if(iBone < 0)
			return false;
			
		GetBonePosition(iTarget, iBone, fVecHead, fVecBad);
		
		g_bBodyShot[client] = true;
	}
	
	if (fDistance == 0.0 || GetVectorDistance(fClientEyes, fVecHead, false) < fDistance)
	{
		if(BotIsVisible(client, fVecHead, false, client))
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

float[] VelocityExtrapolate(int client, float eyepos[3])
{
	float absVel[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", absVel);
	
	float v[3];
	
	v[0] = eyepos[0] + (absVel[0] * GetTickInterval());
	v[1] = eyepos[1] + (absVel[1] * GetTickInterval());
	v[2] = eyepos[2] + (absVel[2] * GetTickInterval());
	
	return v;
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

stock bool IsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client);
}

public void DoMirageSmokes(int client)
{
	float location_check[3];

	GetClientAbsOrigin(client, location_check);

	//T Side Smokes
	float ct_smoke[3] = { 1086.446899, -1017.597046, -194.260651 };
	float stairs_smoke[3] = { 1147.267944, -1183.978271, -141.513763 };
	float jungle_smoke[3] = { 815.968750, -1458.905762, -44.906189 };
	float asite_smoke[3] = { 832.254761, -1255.159180, -44.906189 };
	float topmid_smoke[3] = { 1422.968750, 70.742500, -48.840103 };
	float midshort_smoke[3] = { 1422.968750, 34.830582, -103.906189 };
	float window_smoke[3] = { 1391.968750, -1012.820801, -103.906189 };
	float bottomcon_smoke[3] = { 1135.968750, 647.975647, -197.322052 };
	float topcon_smoke[3] = { 1391.858521, -1052.161865, -103.906189 };
	float shortleft_smoke[3] = { -828.584106, 522.031250, -14.286514 };
	float shortright_smoke[3] = { -148.031250, 353.031250, 29.634865 };
	float bsite_smoke[3] = { -735.981140, 623.975159, -11.906189 };
	float backofb_smoke[3] = { -783.987061, 623.968750, -11.906189 };
	float marketdoor_smoke[3] = { -160.031250, 887.968750, -71.265564 };
	float marketwindow_smoke[3] = { -160.031250, 887.968750, -71.265564 };

	float ct_smoke_distance, stairs_smoke_distance, jungle_smoke_distance, asite_smoke_distance, topmid_smoke_distance, midshort_smoke_distance, window_smoke_distance, bottomcon_smoke_distance, topcon_smoke_distance,
	shortleft_smoke_distance, shortright_smoke_distance, bsite_smoke_distance, backofb_smoke_distance, marketdoor_smoke_distance, marketwindow_smoke_distance;

	ct_smoke_distance = GetVectorDistance(location_check, ct_smoke);
	stairs_smoke_distance = GetVectorDistance(location_check, stairs_smoke);
	jungle_smoke_distance = GetVectorDistance(location_check, jungle_smoke);
	asite_smoke_distance = GetVectorDistance(location_check, asite_smoke);
	topmid_smoke_distance = GetVectorDistance(location_check, topmid_smoke);
	midshort_smoke_distance = GetVectorDistance(location_check, midshort_smoke);
	window_smoke_distance = GetVectorDistance(location_check, window_smoke);
	bottomcon_smoke_distance = GetVectorDistance(location_check, bottomcon_smoke);
	topcon_smoke_distance = GetVectorDistance(location_check, topcon_smoke);
	shortleft_smoke_distance = GetVectorDistance(location_check, shortleft_smoke);
	shortright_smoke_distance = GetVectorDistance(location_check, shortright_smoke);
	bsite_smoke_distance = GetVectorDistance(location_check, bsite_smoke);
	backofb_smoke_distance = GetVectorDistance(location_check, backofb_smoke);
	marketdoor_smoke_distance = GetVectorDistance(location_check, marketdoor_smoke);
	marketwindow_smoke_distance = GetVectorDistance(location_check, marketwindow_smoke);

	if(GetClientTeam(client) == CS_TEAM_T && !g_bHasThrownNade[client])
	{
		switch(g_iRndSmoke[client])
		{
			case 1: //CT Smoke
			{
				BotMoveTo(client, ct_smoke, FASTEST_ROUTE);
				if(ct_smoke_distance < 75)
				{
					float velocity[3], origin[3];
					
					origin[0] = 1062.801147;
					origin[1] = -1034.311279;
					origin[2] = -133.976730;
					
					velocity[0] = -441.676635;
					velocity[1] = -315.539398;
					velocity[2] = 635.904418;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), origin, velocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 2: //Stairs Smoke
			{
				BotMoveTo(client, stairs_smoke, FASTEST_ROUTE);
				if(stairs_smoke_distance < 75)
				{
					float velocity[3], origin[3];
					
					origin[0] = 1122.941772;
					origin[1] = -1190.644775;
					origin[2] = -115.101257;
					
					velocity[0] = -453.966583;
					velocity[1] = -121.504554;
					velocity[2] = 474.536865;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), origin, velocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 3: //Jungle Smoke
			{
				BotMoveTo(client, jungle_smoke, FASTEST_ROUTE);
				if(jungle_smoke_distance < 75)
				{
					float velocity[3], origin[3];
					
					origin[0] = 785.399047;
					origin[1] = -1461.760742;
					origin[2] = -24.280895;
					
					velocity[0] = -556.280883;
					velocity[1] = -48.018508;
					velocity[2] = 369.303039;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), origin, velocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 4: //A Site Smoke
			{
				BotMoveTo(client, asite_smoke, FASTEST_ROUTE);
				if(asite_smoke_distance < 75)
				{
					float velocity[3], origin[3];
					
					origin[0] = 805.123046;
					origin[1] = -1270.940185;
					origin[2] = -25.209976;
					
					velocity[0] = -491.993682;
					velocity[1] = -286.768341;
					velocity[2] = 352.396392;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), origin, velocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 5: //Top-Mid Smoke
			{
				BotMoveTo(client, topmid_smoke, FASTEST_ROUTE);
				if(topmid_smoke_distance < 75)
				{
					float velocity[3], origin[3];
					
					origin[0] = 1395.172973;
					origin[1] = 63.584007;
					origin[2] = -25.641843;
					
					velocity[0] = -505.804138;
					velocity[1] = -134.928771;
					velocity[2] = 416.123657;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), origin, velocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 6: //Mid-Short Smoke
			{
				BotMoveTo(client, midshort_smoke, FASTEST_ROUTE);
				if(midshort_smoke_distance < 75)
				{
					float velocity[3], origin[3];
					
					origin[0] = 1392.433837;
					origin[1] = -231.219055;
					origin[2] = -17.305377;
					
					velocity[0] = -557.391723;
					velocity[1] = 5.051202;
					velocity[2] = 615.354858;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), origin, velocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 7: //Window Smoke
			{
				BotMoveTo(client, window_smoke, FASTEST_ROUTE);
				if(window_smoke_distance < 75)
				{
					float velocity[3], origin[3];
					
					origin[0] = 1259.146362;
					origin[1] = -991.095458;
					origin[2] = -76.503326;
					
					velocity[0] = -748.695434;
					velocity[1] = 110.363220;
					velocity[2] = 492.635467;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), origin, velocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 8: //Bottom Con Smoke
			{
				BotMoveTo(client, bottomcon_smoke, FASTEST_ROUTE);
				if(bottomcon_smoke_distance < 75)
				{
					float velocity[3], origin[3];
					
					origin[0] = 1114.164550;
					origin[1] = 629.839660;
					origin[2] = -135.268310;
					
					velocity[0] = -396.773956;
					velocity[1] = -330.021575;
					velocity[2] = 669.743774;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), origin, velocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 9: //Top Con Smoke
			{
				BotMoveTo(client, topcon_smoke, FASTEST_ROUTE);
				if(topcon_smoke_distance < 75)
				{
					float velocity[3], origin[3];
					
					origin[0] = 1359.151489;
					origin[1] = -1055.655761;
					origin[2] = -44.968437;
					
					velocity[0] = -576.975524;
					velocity[1] = -63.035087;
					velocity[2] = 614.470214;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), origin, velocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 10: //Short-Left Smoke
			{
				BotMoveTo(client, shortleft_smoke, FASTEST_ROUTE);
				if(shortleft_smoke_distance < 75)
				{
					float velocity[3], origin[3];
					
					origin[0] = -833.705017;
					origin[1] = 521.811645;
					origin[2] = 21.933916;
					
					velocity[0] = -126.220901;
					velocity[1] = -3.954442;
					velocity[2] = 653.081909;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), origin, velocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 11: //Short-Right Smoke
			{
				BotMoveTo(client, shortright_smoke, FASTEST_ROUTE);
				if(shortright_smoke_distance < 75)
				{
					float velocity[3], origin[3];
					
					origin[0] = -163.495468;
					origin[1] = 350.919830;
					origin[2] = 63.056510;
					
					velocity[0] = -281.795989;
					velocity[1] = -38.421333;
					velocity[2] = 602.159973;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), origin, velocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 12: //B Site Smoke
			{
				BotMoveTo(client, bsite_smoke, FASTEST_ROUTE);
				if(bsite_smoke_distance < 75)
				{
					float velocity[3], origin[3];
					
					origin[0] = -756.074218;
					origin[1] = 620.800109;
					origin[2] = 18.914443;
					
					velocity[0] = -365.059570;
					velocity[1] = -57.660415;
					velocity[2] = 554.828979;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), origin, velocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 13: //Back of B Smoke
			{
				BotMoveTo(client, backofb_smoke, FASTEST_ROUTE);
				if(backofb_smoke_distance < 75)
				{
					float velocity[3], origin[3];
					
					origin[0] = -800.745422;
					origin[1] = 617.155517;
					origin[2] = 20.180675;
					
					velocity[0] = -307.670806;
					velocity[1] = -123.982215;
					velocity[2] = 577.870788;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), origin, velocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 14: //Market Door Smoke
			{
				BotMoveTo(client, marketdoor_smoke, FASTEST_ROUTE);
				if(marketdoor_smoke_distance < 75)
				{
					float velocity[3], origin[3];
					
					origin[0] = -182.211257;
					origin[1] = 875.810852;
					origin[2] = -5.834220;
					
					velocity[0] = -403.612609;
					velocity[1] = -214.881088;
					velocity[2] = 731.215209;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), origin, velocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 15: //Market Window Smoke
			{
				BotMoveTo(client, marketwindow_smoke, FASTEST_ROUTE);
				if(marketwindow_smoke_distance < 75)
				{
					float velocity[3], origin[3];
					
					origin[0] = -177.872940;
					origin[1] = 876.177795;
					origin[2] = -2.811931;
					
					velocity[0] = -324.667755;
					velocity[1] = -214.561050;
					velocity[2] = 786.203857;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), origin, velocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
		}
	}
}

public void DoDust2Smokes(int client)
{
	float location_check[3];

	GetClientAbsOrigin(client, location_check);

	//T Side Smokes
	float bdoors_smoke[3] = { -2185.970703, 1228.098267, 103.018547 };
	float bwindow_smoke[3] = { -2168.985352, 1042.009155, 104.253571 };
	float midtob_smoke[3] = { -493.977936, 746.946594, 66.300529 };
	float midtobbox_smoke[3] = { -275.119781, 1345.367065, -58.695129 };
	float xbox_smoke[3] = { -299.968750, -1163.968750, 141.760681 };
	float shorta_smoke[3] = { 489.968750, 1446.031250, 64.615715 };
	float shortboost_smoke[3] = { 489.968750, 1943.968750, 160.093811 };
	float asite_smoke[3] = { 273.010040, 1650.206909, 90.072708 };
	float longcorner_smoke[3] = { 490.603485, -363.968750, 73.093811 };
	float across_smoke[3] = { 860.031250, 790.031250, 68.376785 };
	float ct_smoke[3] = { 516.045349, 984.229309, 65.549103 };

	float bdoors_smoke_distance, bwindow_smoke_distance, midtob_smoke_distance, midtobbox_smoke_distance, xbox_smoke_distance, shorta_smoke_distance, shortboost_smoke_distance, asite_smoke_distance, longcorner_smoke_distance,
	across_smoke_distance, ct_smoke_distance;

	bdoors_smoke_distance = GetVectorDistance(location_check, bdoors_smoke);
	bwindow_smoke_distance = GetVectorDistance(location_check, bwindow_smoke);
	midtob_smoke_distance = GetVectorDistance(location_check, midtob_smoke);
	midtobbox_smoke_distance = GetVectorDistance(location_check, midtobbox_smoke);
	xbox_smoke_distance = GetVectorDistance(location_check, xbox_smoke);
	shorta_smoke_distance = GetVectorDistance(location_check, shorta_smoke);
	shortboost_smoke_distance = GetVectorDistance(location_check, shortboost_smoke);
	asite_smoke_distance = GetVectorDistance(location_check, asite_smoke);
	longcorner_smoke_distance = GetVectorDistance(location_check, longcorner_smoke);
	across_smoke_distance = GetVectorDistance(location_check, across_smoke);
	ct_smoke_distance = GetVectorDistance(location_check, ct_smoke);

	if(GetClientTeam(client) == CS_TEAM_T && !g_bHasThrownNade[client])
	{
		switch(g_iRndSmoke[client])
		{
			case 1: //B Doors Smoke
			{
				BotMoveTo(client, bdoors_smoke, SAFEST_ROUTE);
				if(bdoors_smoke_distance < 75)
				{
					float velocity[3], origin[3];
					
					origin[0] = -2175.164062;
					origin[1] = 1241.078125;
					origin[2] = 136.351242;
					
					velocity[0] = 196.042495;
					velocity[1] = 213.844100;
					velocity[2] = 599.477661;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), origin, velocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 2: //B Window Smoke
			{
				BotMoveTo(client, bwindow_smoke, SAFEST_ROUTE);
				if(bwindow_smoke_distance < 75)
				{
					float velocity[3], origin[3];
					
					origin[0] = -2154.991455;
					origin[1] = 1070.825195;
					origin[2] = 144.162094;
					
					velocity[0] = 254.350601;
					velocity[1] = 523.965026;
					velocity[2] = 583.653564;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), origin, velocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 3: //Mid to B Smoke
			{
				BotMoveTo(client, midtob_smoke, SAFEST_ROUTE);
				if(midtob_smoke_distance < 75)
				{
					float velocity[3], origin[3];
					
					origin[0] = -474.632446;
					origin[1] = 889.059265;
					origin[2] = 64.525901;
					
					velocity[0] = 124.725502;
					velocity[1] = 917.540283;
					velocity[2] = 257.509307;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), origin, velocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 4: //Mid to B Box Smoke
			{
				BotMoveTo(client, midtobbox_smoke, SAFEST_ROUTE);
				if(midtobbox_smoke_distance < 75)
				{
					float velocity[3], origin[3];
					
					origin[0] = -296.723052;
					origin[1] = 1373.351318;
					origin[2] = -9.332315;
					
					velocity[0] = -394.729125;
					velocity[1] = 508.962188;
					velocity[2] = 436.598510;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), origin, velocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 5: //XBOX Smoke
			{
				BotMoveTo(client, xbox_smoke, SAFEST_ROUTE);
				if(xbox_smoke_distance < 75)
				{
					float velocity[3], origin[3];
					
					origin[0] = -300.048492;
					origin[1] = -1130.833374;
					origin[2] = 196.540557;
					
					velocity[0] = -1.451205;
					velocity[1] = 603.327819;
					velocity[2] = 537.364562;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), origin, velocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 6: //Short A Smoke
			{
				BotMoveTo(client, shorta_smoke, SAFEST_ROUTE);
				if(shorta_smoke_distance < 75)
				{
					float velocity[3], origin[3];
					
					origin[0] = 490.998962;
					origin[1] = 1481.763061;
					origin[2] = 74.216232;
					
					velocity[0] = 18.676774;
					velocity[1] = 650.651428;
					velocity[2] = 168.686401;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), origin, velocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 7: //Short-Boost Smoke
			{
				BotMoveTo(client, shortboost_smoke, SAFEST_ROUTE);
				if(shortboost_smoke_distance < 75)
				{
					float velocity[3], origin[3];
					
					origin[0] = 494.109680;
					origin[1] = 1972.619873;
					origin[2] = 142.579330;
					
					velocity[0] = 60.718303;
					velocity[1] = 423.099121;
					velocity[2] = 89.004837;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), origin, velocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 8: //A Site Smoke
			{
				BotMoveTo(client, asite_smoke, SAFEST_ROUTE);
				if(asite_smoke_distance < 75)
				{
					float velocity[3], origin[3];
					
					origin[0] = 284.403991;
					origin[1] = 1661.423461;
					origin[2] = 105.455070;
					
					velocity[0] = 206.951477;
					velocity[1] = 201.738220;
					velocity[2] = 599.998168;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), origin, velocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 9: //Long Corner Smoke
			{
				BotMoveTo(client, longcorner_smoke, SAFEST_ROUTE);
				if(longcorner_smoke_distance < 75)
				{
					float velocity[3], origin[3];
					
					origin[0] = 500.049377;
					origin[1] = -342.446136;
					origin[2] = 101.009735;
					
					velocity[0] = 201.955673;
					velocity[1] = 390.799377;
					velocity[2] = 501.971435;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), origin, velocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 10: //A Cross Smoke
			{
				BotMoveTo(client, across_smoke, SAFEST_ROUTE);
				if(across_smoke_distance < 75)
				{
					float velocity[3], origin[3];
					
					origin[0] = 1000.792358;
					origin[1] = 925.208068;
					origin[2] = 82.876365;
					
					velocity[0] = 641.745849;
					velocity[1] = 616.289001;
					velocity[2] = 329.346618;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), origin, velocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
			case 11: //CT Smoke
			{
				BotMoveTo(client, ct_smoke, SAFEST_ROUTE);
				if(ct_smoke_distance < 75)
				{
					float velocity[3], origin[3];
					
					origin[0] = 516.411621;
					origin[1] = 1004.306518;
					origin[2] = 96.275215;
					
					velocity[0] = 6.902427;
					velocity[1] = 372.110961;
					velocity[2] = 553.125915;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), origin, velocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
		}
	}
}

public void Pro_Players(char[] botname, int client)
{

	//MIBR Players
	if((StrEqual(botname, "kNgV-")) || (StrEqual(botname, "FalleN")) || (StrEqual(botname, "fer")) || (StrEqual(botname, "TACO")) || (StrEqual(botname, "trk")))
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
	if((StrEqual(botname, "twist")) || (StrEqual(botname, "Plopski")) || (StrEqual(botname, "nawwk")) || (StrEqual(botname, "hampus")) || (StrEqual(botname, "REZ")))
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
	if((StrEqual(botname, "Summer")) || (StrEqual(botname, "Attacker")) || (StrEqual(botname, "SLOWLY")) || (StrEqual(botname, "somebody")) || (StrEqual(botname, "DANK1NG")))
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
	if((StrEqual(botname, "Snappi")) || (StrEqual(botname, "ottoNd")) || (StrEqual(botname, "SHiPZ")) || (StrEqual(botname, "emi")) || (StrEqual(botname, "EspiranTo")))
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
	if((StrEqual(botname, "maxcel")) || (StrEqual(botname, "gut0")) || (StrEqual(botname, "dukka")) || (StrEqual(botname, "paredao")) || (StrEqual(botname, "kLv")))
	{
		CS_SetClientClanTag(client, "INTZ");
	}
	
	//VP Players
	if((StrEqual(botname, "YEKINDAR")) || (StrEqual(botname, "Jame")) || (StrEqual(botname, "qikert")) || (StrEqual(botname, "SANJI")) || (StrEqual(botname, "AdreN")))
	{
		CS_SetClientClanTag(client, "VP");
	}
	
	//Apeks Players
	if((StrEqual(botname, "Marcelious")) || (StrEqual(botname, "truth")) || (StrEqual(botname, "Grusarn")) || (StrEqual(botname, "akEz")) || (StrEqual(botname, "dennis")))
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
	
	//LDLC Players
	if((StrEqual(botname, "afroo")) || (StrEqual(botname, "Lambert")) || (StrEqual(botname, "hAdji")) || (StrEqual(botname, "bodyy")) || (StrEqual(botname, "SIXER")))
	{
		CS_SetClientClanTag(client, "LDLC");
	}
	
	//GamerLegion Players
	if((StrEqual(botname, "mezii")) || (StrEqual(botname, "eraa")) || (StrEqual(botname, "Zero")) || (StrEqual(botname, "RuStY")) || (StrEqual(botname, "Adam9130")))
	{
		CS_SetClientClanTag(client, "GamerLegion");
	}
	
	//DIVIZON Players
	if((StrEqual(botname, "devus")) || (StrEqual(botname, "akay")) || (StrEqual(botname, "hyped")) || (StrEqual(botname, "FabeeN")) || (StrEqual(botname, "ykyli")))
	{
		CS_SetClientClanTag(client, "DIVIZON");
	}
	
	//EYES Players
	if((StrEqual(botname, "Zarin")) || (StrEqual(botname, "ACTiV")) || (StrEqual(botname, "Hydro")) || (StrEqual(botname, "SativR")) || (StrEqual(botname, "HTMy")))
	{
		CS_SetClientClanTag(client, "EYES");
	}
	
	//Wolsung Players
	if((StrEqual(botname, "hyskeee")) || (StrEqual(botname, "rAW")) || (StrEqual(botname, "Gekons")) || (StrEqual(botname, "keen")) || (StrEqual(botname, "shield")))
	{
		CS_SetClientClanTag(client, "Wolsung");
	}
	
	//PDucks Players
	if((StrEqual(botname, "ChLo")) || (StrEqual(botname, "sTaR")) || (StrEqual(botname, "wizzem")) || (StrEqual(botname, "maxz")) || (StrEqual(botname, "Cl34v3rs")))
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
	if((StrEqual(botname, "maden")) || (StrEqual(botname, "farlig")) || (StrEqual(botname, "kRYSTAL")) || (StrEqual(botname, "zehN")) || (StrEqual(botname, "STYKO")))
	{
		CS_SetClientClanTag(client, "GODSENT");
	}
	
	//Nordavind Players
	if((StrEqual(botname, "tenzki")) || (StrEqual(botname, "NaToSaphiX")) || (StrEqual(botname, "H4RR3")) || (StrEqual(botname, "HS")) || (StrEqual(botname, "cromen")))
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
	if((StrEqual(botname, "dimasick")) || (StrEqual(botname, "WorldEdit")) || (StrEqual(botname, "fostar")) || (StrEqual(botname, "wayLander")) || (StrEqual(botname, "NickelBack")))
	{
		CS_SetClientClanTag(client, "pro100");
	}
	
	//YaLLa Players
	if((StrEqual(botname, "Remind")) || (StrEqual(botname, "DEAD")) || (StrEqual(botname, "Kheops")) || (StrEqual(botname, "Senpai")) || (StrEqual(botname, "Lyhn")))
	{
		CS_SetClientClanTag(client, "YaLLa");
	}
	
	//Yeah Players
	if((StrEqual(botname, "tatazin")) || (StrEqual(botname, "RCF")) || (StrEqual(botname, "f4stzin")) || (StrEqual(botname, "iDk")) || (StrEqual(botname, "dumau")))
	{
		CS_SetClientClanTag(client, "Yeah");
	}
	
	//Singularity Players
	if((StrEqual(botname, "Jabbi")) || (StrEqual(botname, "mertz")) || (StrEqual(botname, "Remoy")) || (StrEqual(botname, "TOBIZ")) || (StrEqual(botname, "Celrate")))
	{
		CS_SetClientClanTag(client, "Singularity");
	}
	
	//DETONA Players
	if((StrEqual(botname, "nak")) || (StrEqual(botname, "piria")) || (StrEqual(botname, "v$m")) || (StrEqual(botname, "Lucaozy")) || (StrEqual(botname, "zevy")))
	{
		CS_SetClientClanTag(client, "DETONA");
	}
	
	//Infinity Players
	if((StrEqual(botname, "k1Nky")) || (StrEqual(botname, "tor1towOw")) || (StrEqual(botname, "spamzzy")) || (StrEqual(botname, "BRUNO")) || (StrEqual(botname, "points")))
	{
		CS_SetClientClanTag(client, "Infinity");
	}
	
	//Isurus Players
	if((StrEqual(botname, "1962")) || (StrEqual(botname, "Noktse")) || (StrEqual(botname, "Reversive")) || (StrEqual(botname, "decov9jse")) || (StrEqual(botname, "caike")))
	{
		CS_SetClientClanTag(client, "Isurus");
	}
	
	//paiN Players
	if((StrEqual(botname, "PKL")) || (StrEqual(botname, "land1n")) || (StrEqual(botname, "NEKIZ")) || (StrEqual(botname, "biguzera")) || (StrEqual(botname, "hardzao")))
	{
		CS_SetClientClanTag(client, "paiN");
	}
	
	//Sharks Players
	if((StrEqual(botname, "supLex")) || (StrEqual(botname, "jnt")) || (StrEqual(botname, "leo_drunky")) || (StrEqual(botname, "exit")) || (StrEqual(botname, "Luken")))
	{
		CS_SetClientClanTag(client, "Sharks");
	}
	
	//One Players
	if((StrEqual(botname, "prt")) || (StrEqual(botname, "Maluk3")) || (StrEqual(botname, "malbsMd")) || (StrEqual(botname, "pesadelo")) || (StrEqual(botname, "b4rtiN")))
	{
		CS_SetClientClanTag(client, "One");
	}
	
	//W7M Players
	if((StrEqual(botname, "skullz")) || (StrEqual(botname, "raafa")) || (StrEqual(botname, "Tuurtle")) || (StrEqual(botname, "pancc")) || (StrEqual(botname, "realziN")))
	{
		CS_SetClientClanTag(client, "W7M");
	}
	
	//Avant Players
	if((StrEqual(botname, "BL1TZ")) || (StrEqual(botname, "sterling")) || (StrEqual(botname, "apoc")) || (StrEqual(botname, "ofnu")) || (StrEqual(botname, "HaZR")))
	{
		CS_SetClientClanTag(client, "Avant");
	}
	
	//Chiefs Players
	if((StrEqual(botname, "HUGHMUNGUS")) || (StrEqual(botname, "Vexite")) || (StrEqual(botname, "apocdud")) || (StrEqual(botname, "zeph")) || (StrEqual(botname, "soju_j")))
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
	if((StrEqual(botname, "Duplicate")) || (StrEqual(botname, "dennyslaw")) || (StrEqual(botname, "Oxygen")) || (StrEqual(botname, "Rainwaker")) || (StrEqual(botname, "SPELLAN")))
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
	
	//Berzerk Players
	if((StrEqual(botname, "SolEk")) || (StrEqual(botname, "s1n")) || (StrEqual(botname, "tahsiN")) || (StrEqual(botname, "syken")) || (StrEqual(botname, "skyye")))
	{
		CS_SetClientClanTag(client, "Berzerk");
	}
	
	//Energy Players
	if((StrEqual(botname, "pnd")) || (StrEqual(botname, "disTroiT")) || (StrEqual(botname, "Lichl0rd")) || (StrEqual(botname, "Tiaantije")) || (StrEqual(botname, "mango")))
	{
		CS_SetClientClanTag(client, "Energy");
	}
	
	//EXECUTIONERS Players
	if((StrEqual(botname, "ZesBeeW")) || (StrEqual(botname, "FamouZ")) || (StrEqual(botname, "maestro")) || (StrEqual(botname, "Snyder")) || (StrEqual(botname, "Sys")))
	{
		CS_SetClientClanTag(client, "EXECUTIONERS");
	}
	
	//GroundZero Players
	if((StrEqual(botname, "BURNRUOk")) || (StrEqual(botname, "Liki")) || (StrEqual(botname, "Llamas")) || (StrEqual(botname, "Noobster")) || (StrEqual(botname, "PEARSS")))
	{
		CS_SetClientClanTag(client, "GroundZero");
	}
	
	//AVEZ Players
	if((StrEqual(botname, "byali")) || (StrEqual(botname, "Markoś")) || (StrEqual(botname, "KEi")) || (StrEqual(botname, "Kylar")) || (StrEqual(botname, "nawrot")))
	{
		CS_SetClientClanTag(client, "AVEZ");
	}
	
	//BTRG Players
	if((StrEqual(botname, "Eeyore")) || (StrEqual(botname, "Geniuss")) || (StrEqual(botname, "xccurate")) || (StrEqual(botname, "ImpressioN")) || (StrEqual(botname, "XigN")))
	{
		CS_SetClientClanTag(client, "BTRG");
	}
	
	//Furious Players
	if((StrEqual(botname, "nbl")) || (StrEqual(botname, "tom1")) || (StrEqual(botname, "Owensinho")) || (StrEqual(botname, "iKrystal")) || (StrEqual(botname, "pablek")))
	{
		CS_SetClientClanTag(client, "Furious");
	}
	
	//GTZ Players
	if((StrEqual(botname, "deLonge")) || (StrEqual(botname, "hug")) || (StrEqual(botname, "slaxx")) || (StrEqual(botname, "braadz")) || (StrEqual(botname, "rafaxF")))
	{
		CS_SetClientClanTag(client, "GTZ");
	}
	
	//x6tence Players
	if((StrEqual(botname, "Queenix")) || (StrEqual(botname, "HECTOz")) || (StrEqual(botname, "HooXi")) || (StrEqual(botname, "refrezh")) || (StrEqual(botname, "Nodios")))
	{
		CS_SetClientClanTag(client, "x6tence");
	}
	
	//Syman Players
	if((StrEqual(botname, "neaLaN")) || (StrEqual(botname, "mou")) || (StrEqual(botname, "n0rb3r7")) || (StrEqual(botname, "kade0")) || (StrEqual(botname, "Keoz")))
	{
		CS_SetClientClanTag(client, "Syman");
	}
	
	//Goliath Players
	if((StrEqual(botname, "massacRe")) || (StrEqual(botname, "kaNibalistic")) || (StrEqual(botname, "adM")) || (StrEqual(botname, "adaro")) || (StrEqual(botname, "ZipZip")))
	{
		CS_SetClientClanTag(client, "Goliath");
	}
	
	//Secret Players
	if((StrEqual(botname, "juanflatroo")) || (StrEqual(botname, "smF")) || (StrEqual(botname, "PERCY")) || (StrEqual(botname, "sinnopsyy")) || (StrEqual(botname, "anarkez")))
	{
		CS_SetClientClanTag(client, "Secret");
	}
	
	//Incept Players
	if((StrEqual(botname, "micalis")) || (StrEqual(botname, "SkulL")) || (StrEqual(botname, "nibke")) || (StrEqual(botname, "Rev")) || (StrEqual(botname, "yourwombat")))
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
	if((StrEqual(botname, "Vegi")) || (StrEqual(botname, "Snax")) || (StrEqual(botname, "mouz")) || (StrEqual(botname, "innocent")) || (StrEqual(botname, "rallen")))
	{
		CS_SetClientClanTag(client, "Illuminar");
	}
	
	//Queso Players
	if((StrEqual(botname, "TheClaran")) || (StrEqual(botname, "thinkii")) || (StrEqual(botname, "VARES")) || (StrEqual(botname, "mik")) || (StrEqual(botname, "Yaba")))
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
	if((StrEqual(botname, "XpG")) || (StrEqual(botname, "nonick")) || (StrEqual(botname, "Kan4")) || (StrEqual(botname, "Polox")) || (StrEqual(botname, "Djoko")))
	{
		CS_SetClientClanTag(client, "Dice");
	}
	
	//PlanetKey Players
	if((StrEqual(botname, "LapeX")) || (StrEqual(botname, "Printek")) || (StrEqual(botname, "glaVed")) || (StrEqual(botname, "ND")) || (StrEqual(botname, "impulsG")))
	{
		CS_SetClientClanTag(client, "PlanetKey");
	}
	
	//mCon Players
	if((StrEqual(botname, "k1Nzo")) || (StrEqual(botname, "shaGGy")) || (StrEqual(botname, "luosrevo")) || (StrEqual(botname, "ReFuZR")) || (StrEqual(botname, "methoDs")))
	{
		CS_SetClientClanTag(client, "mCon");
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
	if((StrEqual(botname, "fnx")) || (StrEqual(botname, "zqk")) || (StrEqual(botname, "dzt")) || (StrEqual(botname, "delboNi")) || (StrEqual(botname, "SHOOWTiME")))
	{
		CS_SetClientClanTag(client, "Imperial");
	}
	
	//Big5 Players
	if((StrEqual(botname, "kustoM_")) || (StrEqual(botname, "Spartan")) || (StrEqual(botname, "konvict")) || (StrEqual(botname, "maniaq")) || (StrEqual(botname, "Tiaantjie")))
	{
		CS_SetClientClanTag(client, "Big5");
	}
	
	//Unique Players
	if((StrEqual(botname, "crush")) || (StrEqual(botname, "AiyvaN")) || (StrEqual(botname, "shalfey")) || (StrEqual(botname, "SELLTER")) || (StrEqual(botname, "fenvicious")))
	{
		CS_SetClientClanTag(client, "Unique");
	}
	
	//Izako Players
	if((StrEqual(botname, "Siuhy")) || (StrEqual(botname, "szejn")) || (StrEqual(botname, "EXUS")) || (StrEqual(botname, "avis")) || (StrEqual(botname, "TOAO")))
	{
		CS_SetClientClanTag(client, "Izako");
	}
	
	//ATK Players
	if((StrEqual(botname, "bLazE")) || (StrEqual(botname, "MisteM")) || (StrEqual(botname, "SloWye")) || (StrEqual(botname, "Fadey")) || (StrEqual(botname, "Doru")))
	{
		CS_SetClientClanTag(client, "ATK");
	}
	
	//Chaos Players
	if((StrEqual(botname, "Xeppaa")) || (StrEqual(botname, "vanity")) || (StrEqual(botname, "leaf")) || (StrEqual(botname, "steel_")) || (StrEqual(botname, "Jonji")))
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
	if((StrEqual(botname, "blocker")) || (StrEqual(botname, "Patrick")) || (StrEqual(botname, "harn")) || (StrEqual(botname, "Mar")) || (StrEqual(botname, "niki1")))
	{
		CS_SetClientClanTag(client, "FATE");
	}
	
	//Canids Players
	if((StrEqual(botname, "DeStiNy")) || (StrEqual(botname, "nythonzinho")) || (StrEqual(botname, "heat")) || (StrEqual(botname, "latto")) || (StrEqual(botname, "KHTEX")))
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
	
	//Wizards Players
	if((StrEqual(botname, "krii")) || (StrEqual(botname, "Kvik")) || (StrEqual(botname, "pounh")) || (StrEqual(botname, "PALM1")) || (StrEqual(botname, "FliP1")))
	{
		CS_SetClientClanTag(client, "Wizards");
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
	if((StrEqual(botname, "Tamiraarita")) || (StrEqual(botname, "rate")) || (StrEqual(botname, "Mistercap")) || (StrEqual(botname, "sK0R")) || (StrEqual(botname, "ANNIHILATION")))
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
	
	//AGF Players
	if((StrEqual(botname, "fr0slev")) || (StrEqual(botname, "Kristou")) || (StrEqual(botname, "netrick")) || (StrEqual(botname, "TMB")) || (StrEqual(botname, "Lukki")))
	{
		CS_SetClientClanTag(client, "AGF");
	}
	
	//LLL Players
	if((StrEqual(botname, "notaN")) || (StrEqual(botname, "G1DO")) || (StrEqual(botname, "marix")) || (StrEqual(botname, "v1N")) || (StrEqual(botname, "Monu")))
	{
		CS_SetClientClanTag(client, "LLL");
	}
	
	//GameAgents Players
	if((StrEqual(botname, "SEMINTE")) || (StrEqual(botname, "r1d3r")) || (StrEqual(botname, "KunKKa")) || (StrEqual(botname, "nJ")) || (StrEqual(botname, "COSMEEEN")))
	{
		CS_SetClientClanTag(client, "GameAgents");
	}
	
	//Keyd Players
	if((StrEqual(botname, "bnc")) || (StrEqual(botname, "mawth")) || (StrEqual(botname, "tifa")) || (StrEqual(botname, "jota")) || (StrEqual(botname, "puni")))
	{
		CS_SetClientClanTag(client, "Keyd");
	}
	
	//Epsilon Players
	if((StrEqual(botname, "ALEXJ")) || (StrEqual(botname, "smogger")) || (StrEqual(botname, "Celebrations")) || (StrEqual(botname, "Masti")) || (StrEqual(botname, "Blytz")))
	{
		CS_SetClientClanTag(client, "Epsilon");
	}
	
	//TIGER Players
	if((StrEqual(botname, "erkaSt")) || (StrEqual(botname, "nin9")) || (StrEqual(botname, "dobu")) || (StrEqual(botname, "kabal")) || (StrEqual(botname, "ncl")))
	{
		CS_SetClientClanTag(client, "TIGER");
	}
	
	//LEISURE Players
	if((StrEqual(botname, "stefank0k0")) || (StrEqual(botname, "NIXEED")) || (StrEqual(botname, "JSXIce")) || (StrEqual(botname, "fly")) || (StrEqual(botname, "ser")))
	{
		CS_SetClientClanTag(client, "LEISURE");
	}
	
	//PENTA Players
	if((StrEqual(botname, "pdy")) || (StrEqual(botname, "red")) || (StrEqual(botname, "neviZ")) || (StrEqual(botname, "xenn")) || (StrEqual(botname, "syNx")))
	{
		CS_SetClientClanTag(client, "PENTA");
	}
	
	//PENTA Players
	if((StrEqual(botname, "NABOWOW")) || (StrEqual(botname, "shellzy")) || (StrEqual(botname, "whatz")) || (StrEqual(botname, "plat")) || (StrEqual(botname, "RIZZ")))
	{
		CS_SetClientClanTag(client, "FTW");
	}
	
	//Titans Players
	if((StrEqual(botname, "simix")) || (StrEqual(botname, "ritchiEE")) || (StrEqual(botname, "Luz")) || (StrEqual(botname, "sarenii")) || (StrEqual(botname, "DENZSTOU")))
	{
		CS_SetClientClanTag(client, "Titans");
	}
	
	//9INE Players
	if((StrEqual(botname, "simix")) || (StrEqual(botname, "ritchiEE")) || (StrEqual(botname, "Luz")) || (StrEqual(botname, "sarenii")) || (StrEqual(botname, "DENZSTOU")))
	{
		CS_SetClientClanTag(client, "9INE");
	}
	
	//nEophyte Players
	if((StrEqual(botname, "tMs1k")) || (StrEqual(botname, "Neci")) || (StrEqual(botname, "traxX")) || (StrEqual(botname, "iNvis")) || (StrEqual(botname, "ANSONE")))
	{
		CS_SetClientClanTag(client, "nEophyte");
	}
	
	//Tigers Players
	if((StrEqual(botname, "MAXX")) || (StrEqual(botname, "Lastík")) || (StrEqual(botname, "zyored")) || (StrEqual(botname, "wEAMO")) || (StrEqual(botname, "manguss")))
	{
		CS_SetClientClanTag(client, "Tigers");
	}
	
	//9z Players
	if((StrEqual(botname, "dgt")) || (StrEqual(botname, "try")) || (StrEqual(botname, "maxujas")) || (StrEqual(botname, "bit")) || (StrEqual(botname, "meyern")))
	{
		CS_SetClientClanTag(client, "9z");
	}
	
	//Malvinas Players
	if((StrEqual(botname, "gAtito")) || (StrEqual(botname, "fakzwall")) || (StrEqual(botname, "minimal")) || (StrEqual(botname, "kissmyaug")) || (StrEqual(botname, "rushardo")))
	{
		CS_SetClientClanTag(client, "Malvinas");
	}
	
	//Sinister5 Players
	if((StrEqual(botname, "zerOchaNce")) || (StrEqual(botname, "FreakY")) || (StrEqual(botname, "deviaNt")) || (StrEqual(botname, "spoof")) || (StrEqual(botname, "ELUSIVE")))
	{
		CS_SetClientClanTag(client, "Sinister5");
	}
	
	//SINNERS Players
	if((StrEqual(botname, "ZEDKO")) || (StrEqual(botname, "CaNNiE")) || (StrEqual(botname, "SHOCK")) || (StrEqual(botname, "beastik")) || (StrEqual(botname, "NEOFRAG")))
	{
		CS_SetClientClanTag(client, "SINNERS");
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
	
	if (StrEqual(sClan, "EYES"))
	{
		g_iProfileRank[client] = 82;
	}
	
	if (StrEqual(sClan, "Tricked"))
	{
		g_iProfileRank[client] = 83;
	}
	
	if (StrEqual(sClan, "Wolsung"))
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
	
	if (StrEqual(sClan, "SINNERS"))
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
	
	if (StrEqual(sClan, "Sinister5"))
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
	
	if (StrEqual(sClan, "PENTA"))
	{
		g_iProfileRank[client] = 122;
	}
	
	if (StrEqual(sClan, "FTW"))
	{
		g_iProfileRank[client] = 123;
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
	
	if (StrEqual(sClan, "NASR"))
	{
		g_iProfileRank[client] = 130;
	}
	
	if (StrEqual(sClan, "LEISURE"))
	{
		g_iProfileRank[client] = 131;
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
	
	if (StrEqual(sClan, "Berzerk"))
	{
		g_iProfileRank[client] = 135;
	}
	
	if (StrEqual(sClan, "Energy"))
	{
		g_iProfileRank[client] = 136;
	}
	
	if (StrEqual(sClan, "Titans"))
	{
		g_iProfileRank[client] = 137;
	}
	
	if (StrEqual(sClan, "EXECUTIONERS"))
	{
		g_iProfileRank[client] = 138;
	}
	
	if (StrEqual(sClan, "TIGER"))
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
	
	if (StrEqual(sClan, "x6tence"))
	{
		g_iProfileRank[client] = 146;
	}
	
	if (StrEqual(sClan, "Epsilon"))
	{
		g_iProfileRank[client] = 147;
	}
	
	if (StrEqual(sClan, "LLL"))
	{
		g_iProfileRank[client] = 148;
	}
	
	if (StrEqual(sClan, "9INE"))
	{
		g_iProfileRank[client] = 149;
	}
	
	if (StrEqual(sClan, "Syman"))
	{
		g_iProfileRank[client] = 150;
	}
	
	if (StrEqual(sClan, "nEophyte"))
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
	
	if (StrEqual(sClan, "GameAgents"))
	{
		g_iProfileRank[client] = 157;
	}
	
	if (StrEqual(sClan, "Baecon"))
	{
		g_iProfileRank[client] = 158;
	}
	
	if (StrEqual(sClan, "Redemption"))
	{
		g_iProfileRank[client] = 159;
	}
	
	if (StrEqual(sClan, "Keyd"))
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
	
	if (StrEqual(sClan, "Wizards"))
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
	
	if (StrEqual(sClan, "Tigers"))
	{
		g_iProfileRank[client] = 169;
	}
	
	if (StrEqual(sClan, "9z"))
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
	
	if (StrEqual(sClan, "Malvinas"))
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