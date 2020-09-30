#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

#define PLAYER_INFO_LEN 344

enum
{
	PlayerInfo_Version = 0,             // int64
	PlayerInfo_XUID = 8,                // int64
	PlayerInfo_Name = 16,               // char[128]
	PlayerInfo_UserID = 144,            // int
	PlayerInfo_SteamID = 148,           // char[33]
	PlayerInfo_AccountID = 184,         // int
	PlayerInfo_FriendsName = 188,       // char[128]
	PlayerInfo_IsFakePlayer = 316,      // bool
	PlayerInfo_IsHLTV = 317,            // bool
	PlayerInfo_CustomFile1 = 320,       // int
	PlayerInfo_CustomFile2 = 324,       // int
	PlayerInfo_CustomFile3 = 328,       // int
	PlayerInfo_CustomFile4 = 332,       // int
	PlayerInfo_FilesDownloaded = 336    // char
};

int iAccountID[MAXPLAYERS+1];

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int errMax)
{
	CreateNative("GetBotAccountID", Native_GetBotAccountID);
}

public int Native_GetBotAccountID(Handle plugins, int numParams)
{
	int client = GetNativeCell(1);
	if (!client || !IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index [%i]", client);
		return false;
	}
	
	return iAccountID[client];
}

public void OnClientSettingsChanged(int client)
{
	if (!IsFakeClient(client))
		return;

	int tableIdx = FindStringTable("userinfo");

	if (tableIdx == INVALID_STRING_TABLE)
		return;

	char userInfo[PLAYER_INFO_LEN];

	if (!GetStringTableData(tableIdx, client - 1, userInfo, PLAYER_INFO_LEN))
		return;

	int accountId;
	
	char szBotName[512];
	GetClientName(client, szBotName, sizeof(szBotName));
	
	//Vitality Players
	if(strcmp(szBotName, "ZywOo") == 0)
	{
		accountId = 153400465;
	}
	else if(strcmp(szBotName, "apEX") == 0)
	{
		accountId = 29478439;
	}
	else if(strcmp(szBotName, "RpK") == 0)
	{
		accountId = 53985773;
	}
	else if(strcmp(szBotName, "shox") == 0)
	{
		accountId = 46654567;
	}
	else if(strcmp(szBotName, "Misutaaa") == 0)
	{
		accountId = 121263183;
	}
	//MIBR Players
	else if(strcmp(szBotName, "kNgV-") == 0)
	{
		accountId = 6732863;
	}
	else if(strcmp(szBotName, "trk") == 0)
	{
		accountId = 74113976;
	}
	else if(strcmp(szBotName, "FalleN") == 0)
	{
		accountId = 424467;
	}
	else if(strcmp(szBotName, "fer") == 0)
	{
		accountId = 38921219;
	}
	else if(strcmp(szBotName, "TACO") == 0)
	{
		accountId = 52876568;
	}
	//FaZe Players
	else if(strcmp(szBotName, "Kjaerbye") == 0)
	{
		accountId = 59614824;
	}
	else if(strcmp(szBotName, "broky") == 0)
	{
		accountId = 241354762;
	}
	else if(strcmp(szBotName, "rain") == 0)
	{
		accountId = 37085479;
	}
	else if(strcmp(szBotName, "NiKo") == 0)
	{
		accountId = 81417650;
	}
	else if(strcmp(szBotName, "coldzera") == 0)
	{
		accountId = 79720871;
	}
	//Astralis Players
	else if(strcmp(szBotName, "device") == 0)
	{
		accountId = 27447936;
	}
	else if(strcmp(szBotName, "dupreeh") == 0)
	{
		accountId = 44589228;
	}
	else if(strcmp(szBotName, "gla1ve") == 0)
	{
		accountId = 50245293;
	}
	else if(strcmp(szBotName, "Magisk") == 0)
	{
		accountId = 23690923;
	}
	else if(strcmp(szBotName, "es3tag") == 0)
	{
		accountId = 1859646;
	}
	//NiP Players
	else if(strcmp(szBotName, "REZ") == 0)
	{
		accountId = 73906687;
	}
	else if(strcmp(szBotName, "Plopski") == 0)
	{
		accountId = 175613070;
	}
	else if(strcmp(szBotName, "twist") == 0)
	{
		accountId = 19979131;
	}
	else if(strcmp(szBotName, "hampus") == 0)
	{
		accountId = 126680222;
	}
	else if(strcmp(szBotName, "nawwk") == 0)
	{
		accountId = 193386133;
	}
	//C9 Players
	else if(strcmp(szBotName, "JT") == 0)
	{
		accountId = 61449372;
	}
	else if(strcmp(szBotName, "motm") == 0)
	{
		accountId = 60208330;
	}
	else if(strcmp(szBotName, "oSee") == 0)
	{
		accountId = 87206806;
	}
	else if(strcmp(szBotName, "floppy") == 0)
	{
		accountId = 346253535;
	}
	else if(strcmp(szBotName, "Sonic") == 0)
	{
		accountId = 14864123;
	}
	//G2 Players
	else if(strcmp(szBotName, "kennyS") == 0)
	{
		accountId = 64640068;
	}
	else if(strcmp(szBotName, "JaCkz") == 0)
	{
		accountId = 11977189;
	}
	else if(strcmp(szBotName, "AmaNEk") == 0)
	{
		accountId = 108679223;
	}
	else if(strcmp(szBotName, "nexa") == 0)
	{
		accountId = 39559694;
	}
	else if(strcmp(szBotName, "huNter-") == 0)
	{
		accountId = 52606325;
	}
	//fnatic Players
	else if(strcmp(szBotName, "KRIMZ") == 0)
	{
		accountId = 71385856;
	}
	else if(strcmp(szBotName, "JW") == 0)
	{
		accountId = 71288472;
	}
	else if(strcmp(szBotName, "Brollan") == 0)
	{
		accountId = 178562747;
	}
	else if(strcmp(szBotName, "flusha") == 0)
	{
		accountId = 31082355;
	}
	else if(strcmp(szBotName, "Golden") == 0)
	{
		accountId = 116509497;
	}
	//North Players
	else if(strcmp(szBotName, "aizy") == 0)
	{
		accountId = 90685224;
	}
	else if(strcmp(szBotName, "gade") == 0)
	{
		accountId = 21355604;
	}
	else if(strcmp(szBotName, "cajunb") == 0)
	{
		accountId = 18062315;
	}
	else if(strcmp(szBotName, "MSL") == 0)
	{
		accountId = 24134891;
	}
	else if(strcmp(szBotName, "Lekr0") == 0)
	{
		accountId = 1093135;
	}
	//mouz Players
	else if(strcmp(szBotName, "chrisJ") == 0)
	{
		accountId = 28273376;
	}
	else if(strcmp(szBotName, "ropz") == 0)
	{
		accountId = 31006590;
	}
	else if(strcmp(szBotName, "karrigan") == 0)
	{
		accountId = 29164525;
	}
	else if(strcmp(szBotName, "frozen") == 0)
	{
		accountId = 108157034;
	}
	else if(strcmp(szBotName, "Bymas") == 0)
	{
		accountId = 133120627;
	}
	//TyLoo Players
	else if(strcmp(szBotName, "somebody") == 0)
	{
		accountId = 85131873;
	}
	else if(strcmp(szBotName, "Summer") == 0)
	{
		accountId = 52964519;
	}
	else if(strcmp(szBotName, "Attacker") == 0)
	{
		accountId = 88001036;
	}
	else if(strcmp(szBotName, "SLOWLY") == 0)
	{
		accountId = 443449867;
	}
	else if(strcmp(szBotName, "DANK1NG") == 0)
	{
		accountId = 191648575;
	}
	//EG Players
	else if(strcmp(szBotName, "Brehze") == 0)
	{
		accountId = 94595411;
	}
	else if(strcmp(szBotName, "CeRq") == 0)
	{
		accountId = 196088155;
	}
	else if(strcmp(szBotName, "Ethan") == 0)
	{
		accountId = 169177802;
	}
	else if(strcmp(szBotName, "tarik") == 0)
	{
		accountId = 18216247;
	}
	else if(strcmp(szBotName, "stanislaw") == 0)
	{
		accountId = 21583315;
	}
	//Thieves Players
	else if(strcmp(szBotName, "AZR") == 0)
	{
		accountId = 24832266;
	}
	else if(strcmp(szBotName, "jks") == 0)
	{
		accountId = 16839456;
	}
	else if(strcmp(szBotName, "jkaem") == 0)
	{
		accountId = 42442914;
	}
	else if(strcmp(szBotName, "Liazz") == 0)
	{
		accountId = 112055988;
	}
	else if(strcmp(szBotName, "Gratisfaction") == 0)
	{
		accountId = 5543683;
	}
	//Na´Vi Players
	else if(strcmp(szBotName, "flamie") == 0)
	{
		accountId = 156257548;
	}
	else if(strcmp(szBotName, "s1mple") == 0)
	{
		accountId = 73936547;
	}
	else if(strcmp(szBotName, "electronic") == 0)
	{
		accountId = 83779379;
	}
	else if(strcmp(szBotName, "Boombl4") == 0)
	{
		accountId = 185941338;
	}
	else if(strcmp(szBotName, "Perfecto") == 0)
	{
		accountId = 160954758;
	}
	//Liquid Players
	else if(strcmp(szBotName, "EliGE") == 0)
	{
		accountId = 106428011;
	}
	else if(strcmp(szBotName, "Twistzz") == 0)
	{
		accountId = 55989477;
	}
	else if(strcmp(szBotName, "NAF") == 0)
	{
		accountId = 40885967;
	}
	else if(strcmp(szBotName, "Stewie2K") == 0)
	{
		accountId = 38738282;
	}
	else if(strcmp(szBotName, "Grim") == 0)
	{
		accountId = 230970467;
	}
	//AGO Players
	else if(strcmp(szBotName, "Furlan") == 0)
	{
		accountId = 177495873;
	}
	else if(strcmp(szBotName, "GruBy") == 0)
	{
		accountId = 44752530;
	}
	else if(strcmp(szBotName, "F1KU") == 0)
	{
		accountId = 292168772;
	}
	else if(strcmp(szBotName, "leman") == 0)
	{
		accountId = 40398517;
	}
	//ENCE Players
	else if(strcmp(szBotName, "allu") == 0)
	{
		accountId = 1345246;
	}
	else if(strcmp(szBotName, "sergej") == 0)
	{
		accountId = 67574097;
	}
	else if(strcmp(szBotName, "Aerial") == 0)
	{
		accountId = 2445180;
	}
	else if(strcmp(szBotName, "suNny") == 0)
	{
		accountId = 57405333;
	}
	else if(strcmp(szBotName, "Jamppi") == 0)
	{
		accountId = 206686473;
	}
	//BIG Players
	else if(strcmp(szBotName, "tabseN") == 0)
	{
		accountId = 1225952;
	}
	else if(strcmp(szBotName, "tiziaN") == 0)
	{
		accountId = 37291208;
	}
	else if(strcmp(szBotName, "XANTARES") == 0)
	{
		accountId = 83853068;
	}
	else if(strcmp(szBotName, "syrsoN") == 0)
	{
		accountId = 19857269;
	}
	else if(strcmp(szBotName, "k1to") == 0)
	{
		accountId = 222196859;
	}
	//FURIA Players
	else if(strcmp(szBotName, "yuurih") == 0)
	{
		accountId = 204704832;
	}
	else if(strcmp(szBotName, "arT") == 0)
	{
		accountId = 83503844;
	}
	else if(strcmp(szBotName, "VINI") == 0)
	{
		accountId = 36104456;
	}
	else if(strcmp(szBotName, "KSCERATO") == 0)
	{
		accountId = 98234764;
	}
	//c0ntact Players
	else if(strcmp(szBotName, "EspiranTo") == 0)
	{
		accountId = 84772046;
	}
	else if(strcmp(szBotName, "ottoNd") == 0)
	{
		accountId = 75069143;
	}
	else if(strcmp(szBotName, "SHiPZ") == 0)
	{
		accountId = 254948893;
	}
	else if(strcmp(szBotName, "emi") == 0)
	{
		accountId = 43348704;
	}
	else if(strcmp(szBotName, "Snappi") == 0)
	{
		accountId = 29157337;
	}
	//coL Players
	else if(strcmp(szBotName, "blameF") == 0)
	{
		accountId = 68193075;
	}
	else if(strcmp(szBotName, "RUSH") == 0)
	{
		accountId = 63326592;
	}
	else if(strcmp(szBotName, "k0nfig") == 0)
	{
		accountId = 19403447;
	}
	else if(strcmp(szBotName, "poizon") == 0)
	{
		accountId = 117537138;
	}
	else if(strcmp(szBotName, "oBo") == 0)
	{
		accountId = 138156260;
	}
	//ViCi Players
	else if(strcmp(szBotName, "zhokiNg") == 0)
	{
		accountId = 99494192;
	}
	else if(strcmp(szBotName, "aumaN") == 0)
	{
		accountId = 46223698;
	}
	else if(strcmp(szBotName, "advent") == 0)
	{
		accountId = 41786057;
	}
	else if(strcmp(szBotName, "kaze") == 0)
	{
		accountId = 16127541;
	}
	else if(strcmp(szBotName, "JamYoung") == 0)
	{
		accountId = 404671310;
	}
	//forZe Players
	else if(strcmp(szBotName, "facecrack") == 0)
	{
		accountId = 115742145;
	}
	else if(strcmp(szBotName, "Jerry") == 0)
	{
		accountId = 65822428;
	}
	else if(strcmp(szBotName, "almazer") == 0)
	{
		accountId = 83782305;
	}
	else if(strcmp(szBotName, "xsepower") == 0)
	{
		accountId = 112014226;
	}
	else if(strcmp(szBotName, "FL1T") == 0)
	{
		accountId = 35551773;
	}
	//Winstrike Players
	else if(strcmp(szBotName, "bondik") == 0)
	{
		accountId = 46918643;
	}
	else if(strcmp(szBotName, "El1an") == 0)
	{
		accountId = 250498109;
	}
	else if(strcmp(szBotName, "Lack1") == 0)
	{
		accountId = 185937269;
	}
	else if(strcmp(szBotName, "KrizzeN") == 0)
	{
		accountId = 107672171;
	}
	else if(strcmp(szBotName, "Hobbit") == 0)
	{
		accountId = 68027030;
	}
	//Sprout Players
	else if(strcmp(szBotName, "Spiidi") == 0)
	{
		accountId = 13465075;
	}
	else if(strcmp(szBotName, "faveN") == 0)
	{
		accountId = 157930364;
	}
	else if(strcmp(szBotName, "denis") == 0)
	{
		accountId = 31185376;
	}
	else if(strcmp(szBotName, "dycha") == 0)
	{
		accountId = 81151265;
	}
	else if(strcmp(szBotName, "snatchie") == 0)
	{
		accountId = 111436809;
	}
	//Heroic Players
	else if(strcmp(szBotName, "stavn") == 0)
	{
		accountId = 62099910;
	}
	else if(strcmp(szBotName, "b0RUP") == 0)
	{
		accountId = 146876280;
	}
	else if(strcmp(szBotName, "cadiaN") == 0)
	{
		accountId = 43849788;
	}
	else if(strcmp(szBotName, "TeSeS") == 0)
	{
		accountId = 36412550;
	}
	else if(strcmp(szBotName, "nikozan") == 0)
	{
		accountId = 29470855;
	}
	//INTZ Players
	//VP Players
	else if(strcmp(szBotName, "buster") == 0)
	{
		accountId = 212936195;
	}
	else if(strcmp(szBotName, "qikert") == 0)
	{
		accountId = 166970562;
	}
	else if(strcmp(szBotName, "Jame") == 0)
	{
		accountId = 75859856;
	}
	else if(strcmp(szBotName, "SANJI") == 0)
	{
		accountId = 357361556;
	}
	else if(strcmp(szBotName, "YEKINDAR") == 0)
	{
		accountId = 174136197;
	}
	//Apeks Players
	else if(strcmp(szBotName, "Marcelious") == 0)
	{
		accountId = 158860221;
	}
	else if(strcmp(szBotName, "Grus") == 0)
	{
		accountId = 34633571;
	}
	else if(strcmp(szBotName, "truth") == 0)
	{
		accountId = 79528796;
	}
	else if(strcmp(szBotName, "dennis") == 0)
	{
		accountId = 108076825;
	}
	//aTTaX Players
	else if(strcmp(szBotName, "stfN") == 0)
	{
		accountId = 47322750;
	}
	else if(strcmp(szBotName, "kressy") == 0)
	{
		accountId = 50709599;
	}
	else if(strcmp(szBotName, "slaxz") == 0)
	{
		accountId = 104087441;
	}
	else if(strcmp(szBotName, "mirbit") == 0)
	{
		accountId = 183980241;
	}
	else if(strcmp(szBotName, "ScrunK") == 0)
	{
		accountId = 13840460;
	}
	//RNG Players
	else if(strcmp(szBotName, "dexter") == 0)
	{
		accountId = 101535513;
	}
	else if(strcmp(szBotName, "malta") == 0)
	{
		accountId = 181905573;
	}
	else if(strcmp(szBotName, "sico") == 0)
	{
		accountId = 39266546;
	}
	else if(strcmp(szBotName, "INS") == 0)
	{
		accountId = 26946895;
	}
	else if(strcmp(szBotName, "Hatz") == 0)
	{
		accountId = 64662058;
	}
	//Envy Players
	else if(strcmp(szBotName, "Nifty") == 0)
	{
		accountId = 163358521;
	}
	else if(strcmp(szBotName, "Calyx") == 0)
	{
		accountId = 92280537;
	}
	else if(strcmp(szBotName, "MICHU") == 0)
	{
		accountId = 60359075;
	}
	else if(strcmp(szBotName, "LEGIJA") == 0)
	{
		accountId = 21242287;
	}
	else if(strcmp(szBotName, "Thomas") == 0)
	{
		accountId = 65182402;
	}
	//Spirit Players
	else if(strcmp(szBotName, "somedieyoung") == 0)
	{
		accountId = 80311472;
	}
	else if(strcmp(szBotName, "chopper") == 0)
	{
		accountId = 85633136;
	}
	else if(strcmp(szBotName, "iDISBALANCE") == 0)
	{
		accountId = 210384169;
	}
	else if(strcmp(szBotName, "mir") == 0)
	{
		accountId = 40562076;
	}
	else if(strcmp(szBotName, "magixx") == 0)
	{
		accountId = 868554;
	}
	//LDLC Players
	else if(strcmp(szBotName, "SIXER") == 0)
	{
		accountId = 3429256;
	}
	else if(strcmp(szBotName, "hAdji") == 0)
	{
		accountId = 20679059;
	}
	else if(strcmp(szBotName, "Lambert") == 0)
	{
		accountId = 16837;
	}
	else if(strcmp(szBotName, "bodyy") == 0)
	{
		accountId = 53029647;
	}
	//GamerLegion Players
	else if(strcmp(szBotName, "RuStY") == 0)
	{
		accountId = 122394166;
	}
	else if(strcmp(szBotName, "eraa") == 0)
	{
		accountId = 413888723;
	}
	else if(strcmp(szBotName, "Zero") == 0)
	{
		accountId = 34322135;
	}
	else if(strcmp(szBotName, "Adam9130") == 0)
	{
		accountId = 80281757;
	}
	else if(strcmp(szBotName, "mezii") == 0)
	{
		accountId = 12874964;
	}
	//DIVIZON Players
	//PDucks Players
	//HAVU Players
	else if(strcmp(szBotName, "sLowi") == 0)
	{
		accountId = 15932016;
	}
	else if(strcmp(szBotName, "ZOREE") == 0)
	{
		accountId = 41867139;
	}
	else if(strcmp(szBotName, "sAw") == 0)
	{
		accountId = 11999475;
	}
	else if(strcmp(szBotName, "doto") == 0)
	{
		accountId = 39318615;
	}
	else if(strcmp(szBotName, "xseveN") == 0)
	{
		accountId = 52906775;
	}
	//Lyngby Players
	else if(strcmp(szBotName, "Twinx") == 0)
	{
		accountId = 114782035;
	}
	else if(strcmp(szBotName, "birdfromsky") == 0)
	{
		accountId = 4338476;
	}
	else if(strcmp(szBotName, "Cabbi") == 0)
	{
		accountId = 230664742;
	}
	else if(strcmp(szBotName, "raalz") == 0)
	{
		accountId = 35794427;
	}
	//GODSENT Players
	else if(strcmp(szBotName, "kRYSTAL") == 0)
	{
		accountId = 17526007;
	}
	else if(strcmp(szBotName, "STYKO") == 0)
	{
		accountId = 55928431;
	}
	else if(strcmp(szBotName, "zehN") == 0)
	{
		accountId = 16308501;
	}
	else if(strcmp(szBotName, "maden") == 0)
	{
		accountId = 205186299;
	}
	else if(strcmp(szBotName, "farlig") == 0)
	{
		accountId = 63982401;
	}
	//Nordavind Players
	else if(strcmp(szBotName, "tenzki") == 0)
	{
		accountId = 37214922;
	}
	else if(strcmp(szBotName, "cromen") == 0)
	{
		accountId = 21397689;
	}
	else if(strcmp(szBotName, "H4RR3") == 0)
	{
		accountId = 195566724;
	}
	else if(strcmp(szBotName, "NaToSaphiX") == 0)
	{
		accountId = 41330524;
	}
	else if(strcmp(szBotName, "HS") == 0)
	{
		accountId = 3417033;
	}
	//SJ Players
	else if(strcmp(szBotName, "arvid") == 0)
	{
		accountId = 66355043;
	}
	else if(strcmp(szBotName, "SADDYX") == 0)
	{
		accountId = 135594020;
	}
	else if(strcmp(szBotName, "KHRN") == 0)
	{
		accountId = 3069751;
	}
	//Bren Players
	else if(strcmp(szBotName, "Papichulo") == 0)
	{
		accountId = 141015515;
	}
	else if(strcmp(szBotName, "Pro.") == 0)
	{
		accountId = 103948760;
	}
	else if(strcmp(szBotName, "witz") == 0)
	{
		accountId = 154457179;
	}
	else if(strcmp(szBotName, "Derek") == 0)
	{
		accountId = 115108105;
	}
	//Giants Players
	else if(strcmp(szBotName, "fox") == 0)
	{
		accountId = 1939536;
	}
	else if(strcmp(szBotName, "NOPEEj") == 0)
	{
		accountId = 200528981;
	}
	else if(strcmp(szBotName, "pr") == 0)
	{
		accountId = 149329940;
	}
	else if(strcmp(szBotName, "obj") == 0)
	{
		accountId = 42675741;
	}
	else if(strcmp(szBotName, "RIZZ") == 0)
	{
		accountId = 31830670;
	}
	//Lions Players
	else if(strcmp(szBotName, "acoR") == 0)
	{
		accountId = 42677035;
	}
	else if(strcmp(szBotName, "Sjuush") == 0)
	{
		accountId = 200443857;
	}
	else if(strcmp(szBotName, "roeJ") == 0)
	{
		accountId = 30968963;
	}
	else if(strcmp(szBotName, "AcilioN") == 0)
	{
		accountId = 56749436;
	}
	else if(strcmp(szBotName, "innocent") == 0)
	{
		accountId = 26563533;
	}
	//Riders Players
	else if(strcmp(szBotName, "mopoz") == 0)
	{
		accountId = 37931638;
	}
	else if(strcmp(szBotName, "alex*") == 0)
	{
		accountId = 40718819;
	}
	else if(strcmp(szBotName, "steel") == 0)
	{
		accountId = 54512474;
	}
	else if(strcmp(szBotName, "larsen") == 0)
	{
		accountId = 60274028;
	}
	else if(strcmp(szBotName, "shokz") == 0)
	{
		accountId = 39590183;
	}
	//OFFSET Players
	else if(strcmp(szBotName, "ZELIN") == 0)
	{
		accountId = 20906101;
	}
	else if(strcmp(szBotName, "drifking") == 0)
	{
		accountId = 2526923;
	}
	else if(strcmp(szBotName, "KILLDREAM") == 0)
	{
		accountId = 109013755;
	}
	else if(strcmp(szBotName, "EasTor") == 0)
	{
		accountId = 3460360;
	}
	//eSuba Players
	else if(strcmp(szBotName, "NIO") == 0)
	{
		accountId = 170307600;
	}
	else if(strcmp(szBotName, "The eLiVe") == 0)
	{
		accountId = 111025647;
	}
	//Nexus Players
	else if(strcmp(szBotName, "BTN") == 0)
	{
		accountId = 21090119;
	}
	else if(strcmp(szBotName, "XELLOW") == 0)
	{
		accountId = 92089093;
	}
	else if(strcmp(szBotName, "iM") == 0)
	{
		accountId = 89984505;
	}
	else if(strcmp(szBotName, "SEMINTE") == 0)
	{
		accountId = 36171013;
	}
	//PACT Players
	else if(strcmp(szBotName, "darko") == 0)
	{
		accountId = 31199105;
	}
	else if(strcmp(szBotName, "lunAtic") == 0)
	{
		accountId = 27202715;
	}
	else if(strcmp(szBotName, "Sobol") == 0)
	{
		accountId = 190359589;
	}
	else if(strcmp(szBotName, "Goofy") == 0)
	{
		accountId = 300617878;
	}
	else if(strcmp(szBotName, "MINISE") == 0)
	{
		accountId = 29354726;
	}
	//Heretics Players
	else if(strcmp(szBotName, "Maka") == 0)
	{
		accountId = 85474033;
	}
	else if(strcmp(szBotName, "kioShiMa") == 0)
	{
		accountId = 40517167;
	}
	else if(strcmp(szBotName, "Lucky") == 0)
	{
		accountId = 71624387;
	}
	else if(strcmp(szBotName, "xms") == 0)
	{
		accountId = 38509481;
	}
	else if(strcmp(szBotName, "Nivera") == 0)
	{
		accountId = 200530203;
	}
	//Nemiga Players
	else if(strcmp(szBotName, "mds") == 0)
	{
		accountId = 114045115;
	}
	else if(strcmp(szBotName, "lollipop21k") == 0)
	{
		accountId = 54552870;
	}
	else if(strcmp(szBotName, "Jyo") == 0)
	{
		accountId = 43255799;
	}
	else if(strcmp(szBotName, "boX") == 0)
	{
		accountId = 127393261;
	}
	else if(strcmp(szBotName, "speed4k") == 0)
	{
		accountId = 79928921;
	}
	//pro100 Players
	else if(strcmp(szBotName, "WorldEdit") == 0)
	{
		accountId = 36732188;
	}
	else if(strcmp(szBotName, "wayLander") == 0)
	{
		accountId = 38340970;
	}
	else if(strcmp(szBotName, "dimasick") == 0)
	{
		accountId = 825268;
	}
	else if(strcmp(szBotName, "NickelBack") == 0)
	{
		accountId = 1882779;
	}
	else if(strcmp(szBotName, "pipsoN") == 0)
	{
		accountId = 49523492;
	}
	//YaLLa Players
	else if(strcmp(szBotName, "Remind") == 0)
	{
		accountId = 121767731;
	}
	else if(strcmp(szBotName, "Senpai") == 0)
	{
		accountId = 348984664;
	}
	//Yeah Players
	else if(strcmp(szBotName, "RCF") == 0)
	{
		accountId = 206261197;
	}
	else if(strcmp(szBotName, "tatazin") == 0)
	{
		accountId = 34836484;
	}
	else if(strcmp(szBotName, "f4stzin") == 0)
	{
		accountId = 476343738;
	}
	else if(strcmp(szBotName, "dumau") == 0)
	{
		accountId = 234059589;
	}
	//Singularity Players
	else if(strcmp(szBotName, "Celrate") == 0)
	{
		accountId = 32535180;
	}
	else if(strcmp(szBotName, "Remoy") == 0)
	{
		accountId = 68675449;
	}
	else if(strcmp(szBotName, "notaN") == 0)
	{
		accountId = 70656220;
	}
	//DETONA Players
	else if(strcmp(szBotName, "v$m") == 0)
	{
		accountId = 51467095;
	}
	else if(strcmp(szBotName, "Lucaozy") == 0)
	{
		accountId = 197122745;
	}
	else if(strcmp(szBotName, "nak") == 0)
	{
		accountId = 182601;
	}
	//Infinity Players
	else if(strcmp(szBotName, "spamzzy") == 0)
	{
		accountId = 43458302;
	}
	else if(strcmp(szBotName, "k1Nky") == 0)
	{
		accountId = 4645867;
	}
	else if(strcmp(szBotName, "tor1towOw") == 0)
	{
		accountId = 112244062;
	}
	else if(strcmp(szBotName, "points") == 0)
	{
		accountId = 79878687;
	}
	else if(strcmp(szBotName, "chuti") == 0)
	{
		accountId = 27511954;
	}
	//Isurus Players
	else if(strcmp(szBotName, "Noktse") == 0)
	{
		accountId = 54233223;
	}
	else if(strcmp(szBotName, "Reversive") == 0)
	{
		accountId = 229334739;
	}
	else if(strcmp(szBotName, "decov9jse") == 0)
	{
		accountId = 311766666;
	}
	else if(strcmp(szBotName, "caike") == 0)
	{
		accountId = 28130755;
	}
	else if(strcmp(szBotName, "JonY BoY") == 0)
	{
		accountId = 77140654;
	}
	//paiN Players
	else if(strcmp(szBotName, "PKL") == 0)
	{
		accountId = 65313136;
	}
	else if(strcmp(szBotName, "biguzera") == 0)
	{
		accountId = 55043156;
	}
	else if(strcmp(szBotName, "hardzao") == 0)
	{
		accountId = 160642472;
	}
	else if(strcmp(szBotName, "NEKIZ") == 0)
	{
		accountId = 76618432;
	}
	//Sharks Players
	else if(strcmp(szBotName, "exit") == 0)
	{
		accountId = 50230614;
	}
	else if(strcmp(szBotName, "leo_drunky") == 0)
	{
		accountId = 58291277;
	}
	else if(strcmp(szBotName, "jnt") == 0)
	{
		accountId = 43326019;
	}
	else if(strcmp(szBotName, "Luken") == 0)
	{
		accountId = 46114258;
	}
	//One Players
	else if(strcmp(szBotName, "Maluk3") == 0)
	{
		accountId = 36056013;
	}
	else if(strcmp(szBotName, "b4rtiN") == 0)
	{
		accountId = 169818854;
	}
	else if(strcmp(szBotName, "prt") == 0)
	{
		accountId = 92304643;
	}
	else if(strcmp(szBotName, "pesadelo") == 0)
	{
		accountId = 295715770;
	}
	else if(strcmp(szBotName, "malbsMd") == 0)
	{
		accountId = 120437415;
	}
	//W7M Players
	else if(strcmp(szBotName, "raafa") == 0)
	{
		accountId = 68219494;
	}
	else if(strcmp(szBotName, "pancc") == 0)
	{
		accountId = 85456730;
	}
	else if(strcmp(szBotName, "realziN") == 0)
	{
		accountId = 44664741;
	}
	else if(strcmp(szBotName, "skullz") == 0)
	{
		accountId = 158380916;
	}
	else if(strcmp(szBotName, "Tuurtle") == 0)
	{
		accountId = 34114868;
	}
	//Avant Players
	else if(strcmp(szBotName, "apoc") == 0)
	{
		accountId = 45914082;
	}
	else if(strcmp(szBotName, "HaZR") == 0)
	{
		accountId = 64081874;
	}
	else if(strcmp(szBotName, "sterling") == 0)
	{
		accountId = 100224621;
	}
	else if(strcmp(szBotName, "BL1TZ") == 0)
	{
		accountId = 21572661;
	}
	else if(strcmp(szBotName, "HUGHMUNGUS") == 0)
	{
		accountId = 104743037;
	}
	//Chiefs Players
	else if(strcmp(szBotName, "apocdud") == 0)
	{
		accountId = 58325300;
	}
	else if(strcmp(szBotName, "zeph") == 0)
	{
		accountId = 177441352;
	}
	else if(strcmp(szBotName, "soju_j") == 0)
	{
		accountId = 86871337;
	}
	else if(strcmp(szBotName, "Vexite") == 0)
	{
		accountId = 92622415;
	}
	else if(strcmp(szBotName, "ofnu") == 0)
	{
		accountId = 23343104;
	}
	//ORDER Players
	else if(strcmp(szBotName, "aliStair") == 0)
	{
		accountId = 138080982;
	}
	else if(strcmp(szBotName, "Valiance") == 0)
	{
		accountId = 236090787;
	}
	else if(strcmp(szBotName, "USTILO") == 0)
	{
		accountId = 18903255;
	}
	else if(strcmp(szBotName, "Rickeh") == 0)
	{
		accountId = 3215921;
	}
	else if(strcmp(szBotName, "J1rah") == 0)
	{
		accountId = 82535956;
	}
	//SKADE Players
	else if(strcmp(szBotName, "dennyslaw") == 0)
	{
		accountId = 300693622;
	}
	else if(strcmp(szBotName, "Rainwaker") == 0)
	{
		accountId = 177848062;
	}
	else if(strcmp(szBotName, "SPELLAN") == 0)
	{
		accountId = 196103646;
	}
	else if(strcmp(szBotName, "Duplicate") == 0)
	{
		accountId = 191809961;
	}
	else if(strcmp(szBotName, "Oxygen") == 0)
	{
		accountId = 124914887;
	}
	//Paradox Players
	else if(strcmp(szBotName, "rbz") == 0)
	{
		accountId = 6510851;
	}
	//Beyond Players
	else if(strcmp(szBotName, "MAIROLLS") == 0)
	{
		accountId = 108192155;
	}
	else if(strcmp(szBotName, "Kntz") == 0)
	{
		accountId = 80230397;
	}
	else if(strcmp(szBotName, "Olivia") == 0)
	{
		accountId = 101480074;
	}
	else if(strcmp(szBotName, "stk") == 0)
	{
		accountId = 102456905;
	}
	else if(strcmp(szBotName, "qqGod") == 0)
	{
		accountId = 36933299;
	}
	//BOOM Players
	else if(strcmp(szBotName, "chelo") == 0)
	{
		accountId = 107498100;
	}
	else if(strcmp(szBotName, "yel") == 0)
	{
		accountId = 90069456;
	}
	else if(strcmp(szBotName, "shz") == 0)
	{
		accountId = 178194613;
	}
	else if(strcmp(szBotName, "boltz") == 0)
	{
		accountId = 58113672;
	}
	else if(strcmp(szBotName, "felps") == 0)
	{
		accountId = 22765766;
	}
	//NASR Players
	//Revolution Players
	else if(strcmp(szBotName, "Rambutan") == 0)
	{
		accountId = 138575149;
	}
	//SHIFT Players
	else if(strcmp(szBotName, "Kishi") == 0)
	{
		accountId = 141118399;
	}
	//nxl Players
	else if(strcmp(szBotName, "soifong") == 0)
	{
		accountId = 113144130;
	}
	else if(strcmp(szBotName, "frgd[ibtJ]") == 0)
	{
		accountId = 41830668;
	}
	//LLL Players
	else if(strcmp(szBotName, "simix") == 0)
	{
		accountId = 11657532;
	}
	else if(strcmp(szBotName, "ritchiEE") == 0)
	{
		accountId = 9173024;
	}
	else if(strcmp(szBotName, "Stev0se") == 0)
	{
		accountId = 180588172;
	}
	else if(strcmp(szBotName, "rilax") == 0)
	{
		accountId = 74315848;
	}
	else if(strcmp(szBotName, "FASHR") == 0)
	{
		accountId = 3238867;
	}
	//energy Players
	//Furious Players
	else if(strcmp(szBotName, "nbl") == 0)
	{
		accountId = 132456979;
	}
	//GroundZero Players
	else if(strcmp(szBotName, "BURNRUOk") == 0)
	{
		accountId = 40368480;
	}
	else if(strcmp(szBotName, "Llamas") == 0)
	{
		accountId = 112275273;
	}
	else if(strcmp(szBotName, "Noobster") == 0)
	{
		accountId = 48794627;
	}
	else if(strcmp(szBotName, "Mayker") == 0)
	{
		accountId = 88236677;
	}
	//AVEZ Players
	else if(strcmp(szBotName, "Kylar") == 0)
	{
		accountId = 116431013;
	}
	else if(strcmp(szBotName, "nawrot") == 0)
	{
		accountId = 74178566;
	}
	else if(strcmp(szBotName, "Markoś") == 0)
	{
		accountId = 68256934;
	}
	else if(strcmp(szBotName, "byali") == 0)
	{
		accountId = 18860354;
	}
	else if(strcmp(szBotName, "tudsoN") == 0)
	{
		accountId = 58354081;
	}
	//BTRG Players
	else if(strcmp(szBotName, "xccurate") == 0)
	{
		accountId = 177428807;
	}
	else if(strcmp(szBotName, "XigN") == 0)
	{
		accountId = 49809482;
	}
	else if(strcmp(szBotName, "Eeyore") == 0)
	{
		accountId = 119081987;
	}
	else if(strcmp(szBotName, "Geniuss") == 0)
	{
		accountId = 119384281;
	}
	else if(strcmp(szBotName, "ImpressioN") == 0)
	{
		accountId = 134688940;
	}
	//GTZ Players
	else if(strcmp(szBotName, "fakes2") == 0)
	{
		accountId = 96848867;
	}
	//x6tence Players
	else if(strcmp(szBotName, "Nodios") == 0)
	{
		accountId = 110610542;
	}
	else if(strcmp(szBotName, "HooXi") == 0)
	{
		accountId = 38661042;
	}
	else if(strcmp(szBotName, "refrezh") == 0)
	{
		accountId = 104598470;
	}
	else if(strcmp(szBotName, "Queenix") == 0)
	{
		accountId = 70280269;
	}
	else if(strcmp(szBotName, "HECTOz") == 0)
	{
		accountId = 82890714;
	}
	//K23 Players
	else if(strcmp(szBotName, "neaLaN") == 0)
	{
		accountId = 93777050;
	}
	else if(strcmp(szBotName, "Keoz") == 0)
	{
		accountId = 138078516;
	}
	else if(strcmp(szBotName, "mou") == 0)
	{
		accountId = 52678767;
	}
	else if(strcmp(szBotName, "n0rb3r7") == 0)
	{
		accountId = 262176776;
	}
	else if(strcmp(szBotName, "kade0") == 0)
	{
		accountId = 343115451;
	}
	//Goliath Players
	else if(strcmp(szBotName, "massacRe") == 0)
	{
		accountId = 117421285;
	}
	else if(strcmp(szBotName, "adaro") == 0)
	{
		accountId = 165184216;
	}
	else if(strcmp(szBotName, "ZipZip") == 0)
	{
		accountId = 115878514;
	}
	else if(strcmp(szBotName, "adM") == 0)
	{
		accountId = 119663636;
	}
	else if(strcmp(szBotName, "kaNibalistic") == 0)
	{
		accountId = 32730121;
	}
	//Secret Players
	else if(strcmp(szBotName, "sinnopsyy") == 0)
	{
		accountId = 205062167;
	}
	else if(strcmp(szBotName, "anarkez") == 0)
	{
		accountId = 73126768;
	}
	else if(strcmp(szBotName, "PERCY") == 0)
	{
		accountId = 36210122;
	}
	else if(strcmp(szBotName, "smF") == 0)
	{
		accountId = 11160541;
	}
	else if(strcmp(szBotName, "juanflatroo") == 0)
	{
		accountId = 135528227;
	}
	//UOL Players
	else if(strcmp(szBotName, "crisby") == 0)
	{
		accountId = 13127256;
	}
	else if(strcmp(szBotName, "kzy") == 0)
	{
		accountId = 6367027;
	}
	else if(strcmp(szBotName, "Andyy") == 0)
	{
		accountId = 84137166;
	}
	else if(strcmp(szBotName, "JDC") == 0)
	{
		accountId = 118505645;
	}
	else if(strcmp(szBotName, "P4TriCK") == 0)
	{
		accountId = 60152488;
	}
	//RADIX Players
	//Illuminar Players
	else if(strcmp(szBotName, "reatz") == 0)
	{
		accountId = 58300666;
	}
	else if(strcmp(szBotName, "Vegi") == 0)
	{
		accountId = 90369423;
	}
	else if(strcmp(szBotName, "mouz") == 0)
	{
		accountId = 38464805;
	}
	else if(strcmp(szBotName, "Snax") == 0)
	{
		accountId = 21875845;
	}
	else if(strcmp(szBotName, "phr") == 0)
	{
		accountId = 19304486;
	}
	//Queso Players
	else if(strcmp(szBotName, "thinkii") == 0)
	{
		accountId = 66876997;
	}
	else if(strcmp(szBotName, "HUMANZ") == 0)
	{
		accountId = 163171683;
	}
	//IG Players
	else if(strcmp(szBotName, "flying") == 0)
	{
		accountId = 441964070;
	}
	else if(strcmp(szBotName, "DeStRoYeR") == 0)
	{
		accountId = 85113804;
	}
	else if(strcmp(szBotName, "Viva") == 0)
	{
		accountId = 191787089;
	}
	else if(strcmp(szBotName, "XiaosaGe") == 0)
	{
		accountId = 225577877;
	}
	else if(strcmp(szBotName, "bottle") == 0)
	{
		accountId = 86991268;
	}
	//HR Players
	else if(strcmp(szBotName, "Flarich") == 0)
	{
		accountId = 191627594;
	}
	else if(strcmp(szBotName, "jR") == 0)
	{
		accountId = 43490511;
	}
	else if(strcmp(szBotName, "kAliNkA") == 0)
	{
		accountId = 26484630;
	}
	else if(strcmp(szBotName, "ProbLeM") == 0)
	{
		accountId = 3164241;
	}
	//Dice Players
	else if(strcmp(szBotName, "XpG") == 0)
	{
		accountId = 30253348;
	}
	else if(strcmp(szBotName, "Kan4") == 0)
	{
		accountId = 142410641;
	}
	else if(strcmp(szBotName, "Polox") == 0)
	{
		accountId = 109597705;
	}
	else if(strcmp(szBotName, "nonick") == 0)
	{
		accountId = 63995864;
	}
	//PlanetKey Players
	//Vexed Players
	//HLE Players
	else if(strcmp(szBotName, "kinqie") == 0)
	{
		accountId = 42106423;
	}
	else if(strcmp(szBotName, "Krad") == 0)
	{
		accountId = 71642904;
	}
	else if(strcmp(szBotName, "Forester") == 0)
	{
		accountId = 67083025;
	}
	else if(strcmp(szBotName, "svyat") == 0)
	{
		accountId = 35632848;
	}
	else if(strcmp(szBotName, "starix") == 0)
	{
		accountId = 53338238;
	}
	//Gambit Players
	else if(strcmp(szBotName, "nafany") == 0)
	{
		accountId = 99448400;
	}
	else if(strcmp(szBotName, "supra") == 0)
	{
		accountId = 164802191;
	}
	else if(strcmp(szBotName, "sh1ro") == 0)
	{
		accountId = 121219047;
	}
	else if(strcmp(szBotName, "interz") == 0)
	{
		accountId = 247808592;
	}
	else if(strcmp(szBotName, "Ax1Le") == 0)
	{
		accountId = 85167576;
	}
	//Wisla Players
	else if(strcmp(szBotName, "SZPERO") == 0)
	{
		accountId = 19554985;
	}
	else if(strcmp(szBotName, "mynio") == 0)
	{
		accountId = 24981058;
	}
	else if(strcmp(szBotName, "hades") == 0)
	{
		accountId = 90656280;
	}
	else if(strcmp(szBotName, "jedqr") == 0)
	{
		accountId = 125090121;
	}
	else if(strcmp(szBotName, "ponczek") == 0)
	{
		accountId = 150374922;
	}
	//Imperial Players
	else if(strcmp(szBotName, "delboNi") == 0)
	{
		accountId = 49145432;
	}
	else if(strcmp(szBotName, "zqk") == 0)
	{
		accountId = 4032008;
	}
	else if(strcmp(szBotName, "SHOOWTiME") == 0)
	{
		accountId = 97938914;
	}
	else if(strcmp(szBotName, "fnx") == 0)
	{
		accountId = 170178574;
	}
	else if(strcmp(szBotName, "LUCAS1") == 0)
	{
		accountId = 4780624;
	}
	//Pompa Players
	//Unique Players
	else if(strcmp(szBotName, "fenvicious") == 0)
	{
		accountId = 72984;
	}
	else if(strcmp(szBotName, "crush") == 0)
	{
		accountId = 36981424;
	}
	//Izako Players
	else if(strcmp(szBotName, "EXUS") == 0)
	{
		accountId = 101479930;
	}
	else if(strcmp(szBotName, "TOAO") == 0)
	{
		accountId = 196107432;
	}
	//ATK Players
	else if(strcmp(szBotName, "bLazE") == 0)
	{
		accountId = 209701855;
	}
	else if(strcmp(szBotName, "MisteM") == 0)
	{
		accountId = 175149890;
	}
	else if(strcmp(szBotName, "Fadey") == 0)
	{
		accountId = 181493840;
	}
	else if(strcmp(szBotName, "SloWye") == 0)
	{
		accountId = 50695439;
	}
	//Chaos Players
	else if(strcmp(szBotName, "vanity") == 0)
	{
		accountId = 205001140;
	}
	else if(strcmp(szBotName, "Xeppaa") == 0)
	{
		accountId = 282149574;
	}
	else if(strcmp(szBotName, "Jonji") == 0)
	{
		accountId = 114675386;
	}
	else if(strcmp(szBotName, "leaf") == 0)
	{
		accountId = 55470723;
	}
	else if(strcmp(szBotName, "MarKE") == 0)
	{
		accountId = 2637435;
	}
	//Wings Players
	else if(strcmp(szBotName, "DD") == 0)
	{
		accountId = 169982617;
	}
	else if(strcmp(szBotName, "lan") == 0)
	{
		accountId = 183602582;
	}
	else if(strcmp(szBotName, "gas") == 0)
	{
		accountId = 41822010;
	}
	else if(strcmp(szBotName, "ChildKing") == 0)
	{
		accountId = 392390376;
	}
	//Lynn Players
	else if(strcmp(szBotName, "XG") == 0)
	{
		accountId = 146974312;
	}
	else if(strcmp(szBotName, "Aree") == 0)
	{
		accountId = 164785320;
	}
	else if(strcmp(szBotName, "mitsuha") == 0)
	{
		accountId = 177517735;
	}
	else if(strcmp(szBotName, "EXPRO") == 0)
	{
		accountId = 219759475;
	}
	//Triumph Players
	else if(strcmp(szBotName, "Shakezullah") == 0)
	{
		accountId = 68248927;
	}
	else if(strcmp(szBotName, "Junior") == 0)
	{
		accountId = 103793230;
	}
	else if(strcmp(szBotName, "penny") == 0)
	{
		accountId = 148776454;
	}
	else if(strcmp(szBotName, "moose") == 0)
	{
		accountId = 364130150;
	}
	else if(strcmp(szBotName, "ryann") == 0)
	{
		accountId = 108181457;
	}
	//FATE Players
	else if(strcmp(szBotName, "Mar") == 0)
	{
		accountId = 158849219;
	}
	else if(strcmp(szBotName, "niki1") == 0)
	{
		accountId = 932616892;
	}
	else if(strcmp(szBotName, "blocker") == 0)
	{
		accountId = 104330322;
	}
	else if(strcmp(szBotName, "Patrick") == 0)
	{
		accountId = 98715951;
	}
	else if(strcmp(szBotName, "h4rn") == 0)
	{
		accountId = 88360844;
	}
	//Canids Players
	else if(strcmp(szBotName, "nython") == 0)
	{
		accountId = 170224923;
	}
	else if(strcmp(szBotName, "latto") == 0)
	{
		accountId = 889754458;
	}
	else if(strcmp(szBotName, "DeStiNy") == 0)
	{
		accountId = 89528706;
	}
	else if(strcmp(szBotName, "KHTEX") == 0)
	{
		accountId = 82196374;
	}
	//ESPADA Players
	else if(strcmp(szBotName, "degster") == 0)
	{
		accountId = 839074394;
	}
	else if(strcmp(szBotName, "FinigaN") == 0)
	{
		accountId = 226095351;
	}
	else if(strcmp(szBotName, "Dima") == 0)
	{
		accountId = 51718767;
	}
	else if(strcmp(szBotName, "S0tF1k") == 0)
	{
		accountId = 174857712;
	}
	else if(strcmp(szBotName, "Patsanchick") == 0)
	{
		accountId = 328275073;
	}
	//OG Players
	else if(strcmp(szBotName, "NBK-") == 0)
	{
		accountId = 444845;
	}
	else if(strcmp(szBotName, "Aleksib") == 0)
	{
		accountId = 52977598;
	}
	else if(strcmp(szBotName, "valde") == 0)
	{
		accountId = 154664140;
	}
	else if(strcmp(szBotName, "ISSAA") == 0)
	{
		accountId = 77546728;
	}
	else if(strcmp(szBotName, "mantuu") == 0)
	{
		accountId = 56166832;
	}
	//Wizards Players
	else if(strcmp(szBotName, "pounh") == 0)
	{
		accountId = 77088025;
	}
	else if(strcmp(szBotName, "Kvik") == 0)
	{
		accountId = 40982505;
	}
	else if(strcmp(szBotName, "kolor") == 0)
	{
		accountId = 159382791;
	}
	//Tricked Players
	else if(strcmp(szBotName, "kwezz") == 0)
	{
		accountId = 110193409;
	}
	else if(strcmp(szBotName, "sycrone") == 0)
	{
		accountId = 49161935;
	}
	//Gen.G Players
	else if(strcmp(szBotName, "autimatic") == 0)
	{
		accountId = 94605121;
	}
	else if(strcmp(szBotName, "koosta") == 0)
	{
		accountId = 161590;
	}
	else if(strcmp(szBotName, "s0m") == 0)
	{
		accountId = 287288432;
	}
	else if(strcmp(szBotName, "BnTeT") == 0)
	{
		accountId = 111817512;
	}
	else if(strcmp(szBotName, "daps") == 0)
	{
		accountId = 19892353;
	}
	//Endpoint Players
	else if(strcmp(szBotName, "Surreal") == 0)
	{
		accountId = 84574729;
	}
	else if(strcmp(szBotName, "CRUC1AL") == 0)
	{
		accountId = 158832564;
	}
	else if(strcmp(szBotName, "robiin") == 0)
	{
		accountId = 41292034;
	}
	else if(strcmp(szBotName, "MiGHTYMAX") == 0)
	{
		accountId = 15522824;
	}
	else if(strcmp(szBotName, "flameZ") == 0)
	{
		accountId = 18569432;
	}
	//sAw Players
	else if(strcmp(szBotName, "arki") == 0)
	{
		accountId = 18055753;
	}
	else if(strcmp(szBotName, "JUST") == 0)
	{
		accountId = 52722111;
	}
	else if(strcmp(szBotName, "MUTiRiS") == 0)
	{
		accountId = 37715442;
	}
	else if(strcmp(szBotName, "rmn") == 0)
	{
		accountId = 34129763;
	}
	else if(strcmp(szBotName, "stadodo") == 0)
	{
		accountId = 87137134;
	}
	//DIG Players
	else if(strcmp(szBotName, "f0rest") == 0)
	{
		accountId = 93724;
	}
	else if(strcmp(szBotName, "friberg") == 0)
	{
		accountId = 24295201;
	}
	else if(strcmp(szBotName, "hallzerk") == 0)
	{
		accountId = 100101582;
	}
	else if(strcmp(szBotName, "GeT_RiGhT") == 0)
	{
		accountId = 21771190;
	}
	else if(strcmp(szBotName, "Xizt") == 0)
	{
		accountId = 26224992;
	}
	//D13 Players
	//ZIGMA Players
	else if(strcmp(szBotName, "NIFFY") == 0)
	{
		accountId = 167797237;
	}
	else if(strcmp(szBotName, "JUSTCAUSE") == 0)
	{
		accountId = 106292739;
	}
	else if(strcmp(szBotName, "Reality") == 0)
	{
		accountId = 101927360;
	}
	else if(strcmp(szBotName, "PPOverdose") == 0)
	{
		accountId = 173729018;
	}
	else if(strcmp(szBotName, "RoLEX") == 0)
	{
		accountId = 160401860;
	}
	//Ambush Players
	else if(strcmp(szBotName, "Inzta") == 0)
	{
		accountId = 5098230;
	}
	else if(strcmp(szBotName, "Ryxxo") == 0)
	{
		accountId = 66562222;
	}
	else if(strcmp(szBotName, "zeq") == 0)
	{
		accountId = 59530192;
	}
	//KOVA Players
	else if(strcmp(szBotName, "pietola") == 0)
	{
		accountId = 78197987;
	}
	else if(strcmp(szBotName, "uli") == 0)
	{
		accountId = 52262697;
	}
	else if(strcmp(szBotName, "peku") == 0)
	{
		accountId = 39287363;
	}
	else if(strcmp(szBotName, "Twixie") == 0)
	{
		accountId = 187781829;
	}
	else if(strcmp(szBotName, "spargo") == 0)
	{
		accountId = 109596532;
	}
	//CR4ZY Players
	else if(strcmp(szBotName, "Sergiz") == 0)
	{
		accountId = 110022176;
	}
	//eXploit Players
	else if(strcmp(szBotName, "pizituh") == 0)
	{
		accountId = 25514716;
	}
	else if(strcmp(szBotName, "BuJ") == 0)
	{
		accountId = 264471;
	}
	else if(strcmp(szBotName, "sark") == 0)
	{
		accountId = 76263371;
	}
	else if(strcmp(szBotName, "renatoohaxx") == 0)
	{
		accountId = 39166438;
	}
	else if(strcmp(szBotName, "BLOODZ") == 0)
	{
		accountId = 1004703971;
	}
	//Wolsung Players
	//AGF Players
	else if(strcmp(szBotName, "fr0slev") == 0)
	{
		accountId = 75073497;
	}
	else if(strcmp(szBotName, "netrick") == 0)
	{
		accountId = 43725742;
	}
	else if(strcmp(szBotName, "TMB") == 0)
	{
		accountId = 124341526;
	}
	else if(strcmp(szBotName, "Lukki") == 0)
	{
		accountId = 53001420;
	}
	else if(strcmp(szBotName, "kristou") == 0)
	{
		accountId = 147274330;
	}
	//GameAgents Players
	//Keyd Players
	else if(strcmp(szBotName, "mawth") == 0)
	{
		accountId = 1074151;
	}
	else if(strcmp(szBotName, "tifa") == 0)
	{
		accountId = 28405622;
	}
	//Epsilon Players
	else if(strcmp(szBotName, "Celebrations") == 0)
	{
		accountId = 23315665;
	}
	//TIGER Players
	else if(strcmp(szBotName, "erkaSt") == 0)
	{
		accountId = 131305548;
	}
	else if(strcmp(szBotName, "dobu") == 0)
	{
		accountId = 159891913;
	}
	else if(strcmp(szBotName, "kabal") == 0)
	{
		accountId = 161246388;
	}
	else if(strcmp(szBotName, "ncl") == 0)
	{
		accountId = 156030485;
	}
	else if(strcmp(szBotName, "nin9") == 0)
	{
		accountId = 168197870;
	}
	//LEISURE Players
	//PENTA Players
	else if(strcmp(szBotName, "red") == 0)
	{
		accountId = 204660292;
	}
	else if(strcmp(szBotName, "pdy") == 0)
	{
		accountId = 199029474;
	}
	else if(strcmp(szBotName, "xenn") == 0)
	{
		accountId = 167173287;
	}
	//FTW Players
	else if(strcmp(szBotName, "plat") == 0)
	{
		accountId = 300562274;
	}
	else if(strcmp(szBotName, "Cunha") == 0)
	{
		accountId = 203400597;
	}
	else if(strcmp(szBotName, "brA") == 0)
	{
		accountId = 8661121;
	}
	//Titans Players
	else if(strcmp(szBotName, "sarenii") == 0)
	{
		accountId = 114087818;
	}
	else if(strcmp(szBotName, "doublemagic") == 0)
	{
		accountId = 161282046;
	}
	else if(strcmp(szBotName, "KalubeR") == 0)
	{
		accountId = 132424531;
	}
	else if(strcmp(szBotName, "rafftu") == 0)
	{
		accountId = 78588859;
	}
	//9INE Players
	//QBF Players
	else if(strcmp(szBotName, "JACKPOT") == 0)
	{
		accountId = 147382385;
	}
	else if(strcmp(szBotName, "hiji") == 0)
	{
		accountId = 46433989;
	}
	//Tigers Players
	//9z Players
	else if(strcmp(szBotName, "dgt") == 0)
	{
		accountId = 256625848;
	}
	else if(strcmp(szBotName, "maxujas") == 0)
	{
		accountId = 282684656;
	}
	else if(strcmp(szBotName, "bit") == 0)
	{
		accountId = 9224396;
	}
	else if(strcmp(szBotName, "meyern") == 0)
	{
		accountId = 235377137;
	}
	//Malvinas Players
	else if(strcmp(szBotName, "minimal") == 0)
	{
		accountId = 81466127;
	}
	//Sinister5 Players
	else if(strcmp(szBotName, "minimal") == 0)
	{
		accountId = 81466127;
	}
	//Sinister5 Players
	else if(strcmp(szBotName, "zerOchaNce") == 0)
	{
		accountId = 982445;
	}
	else if(strcmp(szBotName, "deviaNt") == 0)
	{
		accountId = 7077099;
	}
	else if(strcmp(szBotName, "ELUSIVE") == 0)
	{
		accountId = 16704419;
	}
	//SINNERS Players
	else if(strcmp(szBotName, "CaNNiE") == 0)
	{
		accountId = 161157255;
	}
	else if(strcmp(szBotName, "ZEDKO") == 0)
	{
		accountId = 173898955;
	}
	else if(strcmp(szBotName, "SHOCK") == 0)
	{
		accountId = 209294569;
	}
	else if(strcmp(szBotName, "beastik") == 0)
	{
		accountId = 73173022;
	}
	else if(strcmp(szBotName, "NEOFRAG") == 0)
	{
		accountId = 255168957;
	}
	//Impact Players
	//ERN Players
	else if(strcmp(szBotName, "ReacTioNNN") == 0)
	{
		accountId = 85434976;
	}
	else if(strcmp(szBotName, "preet") == 0)
	{
		accountId = 34228517;
	}
	//BL4ZE Players
	else if(strcmp(szBotName, "Marzil") == 0)
	{
		accountId = 141417673;
	}
	else if(strcmp(szBotName, "Rossi") == 0)
	{
		accountId = 433932660;
	}
	//Global Players
	else if(strcmp(szBotName, "HellrangeR") == 0)
	{
		accountId = 69467185;
	}
	else if(strcmp(szBotName, "hellff") == 0)
	{
		accountId = 337045725;
	}
	else if(strcmp(szBotName, "Karam1L") == 0)
	{
		accountId = 916558403;
	}
	else if(strcmp(szBotName, "DEATHMAKER") == 0)
	{
		accountId = 364178390;
	}
	//Conquer Players
	//Rooster Players
	else if(strcmp(szBotName, "DannyG") == 0)
	{
		accountId = 193412411;
	}
	else if(strcmp(szBotName, "chelleos") == 0)
	{
		accountId = 198705922;
	}
	//Flames Players
	else if(strcmp(szBotName, "mertz") == 0)
	{
		accountId = 119498324;
	}
	else if(strcmp(szBotName, "Basso") == 0)
	{
		accountId = 152862;
	}
	else if(strcmp(szBotName, "Daffu") == 0)
	{
		accountId = 70645401;
	}
	//Baecon Players
	else if(strcmp(szBotName, "emp") == 0)
	{
		accountId = 646249586;
	}
	else if(strcmp(szBotName, "kst") == 0)
	{
		accountId = 83276408;
	}
	else if(strcmp(szBotName, "whatz") == 0)
	{
		accountId = 31318693;
	}
	else if(strcmp(szBotName, "shellzi") == 0)
	{
		accountId = 243140003;
	}
	else if(strcmp(szBotName, "vts") == 0)
	{
		accountId = 41960703;
	}
	//KPI Players
	else if(strcmp(szBotName, "Aaron") == 0)
	{
		accountId = 95940281;
	}
	else if(strcmp(szBotName, "Butters") == 0)
	{
		accountId = 75717540;
	}
	//hREDS Players
	else if(strcmp(szBotName, "eDi") == 0)
	{
		accountId = 57731578;
	}
	else if(strcmp(szBotName, "VORMISTO") == 0)
	{
		accountId = 18354065;
	}
	else if(strcmp(szBotName, "Samppa") == 0)
	{
		accountId = 37105524;
	}
	else if(strcmp(szBotName, "xartE") == 0)
	{
		accountId = 26565773;
	}
	//Lemondogs Players
	else if(strcmp(szBotName, "xelos") == 0)
	{
		accountId = 28004721;
	}
	else if(strcmp(szBotName, "Gamersdont") == 0)
	{
		accountId = 153319644;
	}
	//Alpha Players
	//CeX Players
	else
	{
		accountId = GetRandomInt(3, 1091249497);
	}
	
	int steamIdHigh = 16781313;
	
	userInfo[PlayerInfo_XUID] = steamIdHigh;
	userInfo[PlayerInfo_XUID + 1] = steamIdHigh >> 8;
	userInfo[PlayerInfo_XUID + 2] = steamIdHigh >> 16;
	userInfo[PlayerInfo_XUID + 3] = steamIdHigh >> 24;
	
	userInfo[PlayerInfo_XUID + 7] = accountId;
	userInfo[PlayerInfo_XUID + 6] = accountId >> 8;
	userInfo[PlayerInfo_XUID + 5] = accountId >> 16;
	userInfo[PlayerInfo_XUID + 4] = accountId >> 24;
	
	Format(userInfo[PlayerInfo_SteamID], 32, "STEAM_1:%d:%d", accountId & 1, accountId >>> 1);
	
	userInfo[PlayerInfo_AccountID] = accountId;
	userInfo[PlayerInfo_AccountID + 1] = accountId >> 8;
	userInfo[PlayerInfo_AccountID + 2] = accountId >> 16;
	userInfo[PlayerInfo_AccountID + 3] = accountId >> 24;
	
	userInfo[PlayerInfo_IsFakePlayer] = 0;
	
	bool lockTable = LockStringTables(false);
	SetStringTableData(tableIdx, client - 1, userInfo, PLAYER_INFO_LEN);
	LockStringTables(lockTable);
	
	iAccountID[client] = accountId;
}