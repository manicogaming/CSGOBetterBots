#pragma semicolon 1

#include <sourcemod>
#include <clientprefs>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#include <fpvm_interface>

bool g_bFlashed[MAXPLAYERS + 1] = false;
bool g_bFreezetimeEnd = false;
bool g_bPinPulled[MAXPLAYERS + 1] = false;
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

char g_sUSPModels[][] = {
	"models/weapons/v_uspstickers1.mdl",
	"models/weapons/v_uspstickers2.mdl",
	"models/weapons/v_uspstickers3.mdl",
	"models/weapons/v_uspstickers4.mdl",
	"models/weapons/v_uspstickers5.mdl",
	"models/weapons/v_uspstickers6.mdl",
	"models/weapons/v_uspstickers7.mdl",
	"models/weapons/v_uspstickers8.mdl",
	"models/weapons/v_uspstickers9.mdl",
	"models/weapons/v_uspstickers10.mdl",
	"models/weapons/v_uspstickers11.mdl",
	"models/weapons/v_uspstickers12.mdl",
	"models/weapons/v_uspstickers13.mdl",
	"models/weapons/v_uspstickers14.mdl"
};

char g_sP2000Models[][] = {
	"models/weapons/v_p2000stickers1.mdl",
	"models/weapons/v_p2000stickers2.mdl",
	"models/weapons/v_p2000stickers3.mdl",
	"models/weapons/v_p2000stickers4.mdl"
};

char g_sGlockModels[][] = {
	"models/weapons/v_glockstickers1.mdl",
	"models/weapons/v_glockstickers2.mdl",
	"models/weapons/v_glockstickers3.mdl",
	"models/weapons/v_glockstickers4.mdl",
	"models/weapons/v_glockstickers5.mdl",
	"models/weapons/v_glockstickers6.mdl",
	"models/weapons/v_glockstickers7.mdl",
	"models/weapons/v_glockstickers8.mdl",
	"models/weapons/v_glockstickers9.mdl"
};

char g_sP250Models[][] = {
	"models/weapons/v_p250stickers1.mdl",
	"models/weapons/v_p250stickers2.mdl",
	"models/weapons/v_p250stickers3.mdl",
	"models/weapons/v_p250stickers4.mdl",
	"models/weapons/v_p250stickers5.mdl",
	"models/weapons/v_p250stickers6.mdl",
	"models/weapons/v_p250stickers7.mdl"
};

char g_sFiveSevenModels[][] = {
	"models/weapons/v_fivesevenstickers1.mdl",
	"models/weapons/v_fivesevenstickers2.mdl"
};

char g_sCZ75Models[][] = {
	"models/weapons/v_cz75stickers1.mdl",
	"models/weapons/v_cz75stickers2.mdl",
	"models/weapons/v_cz75stickers3.mdl"
};

char g_sTec9Models[][] = {
	"models/weapons/v_tec9stickers1.mdl",
	"models/weapons/v_tec9stickers2.mdl",
	"models/weapons/v_tec9stickers3.mdl",
	"models/weapons/v_tec9stickers4.mdl"
};

char g_sDeagleModels[][] = {
	"models/weapons/v_deaglestickers1.mdl",
	"models/weapons/v_deaglestickers2.mdl",
	"models/weapons/v_deaglestickers3.mdl",
	"models/weapons/v_deaglestickers4.mdl",
	"models/weapons/v_deaglestickers5.mdl",
	"models/weapons/v_deaglestickers6.mdl",
	"models/weapons/v_deaglestickers7.mdl",
	"models/weapons/v_deaglestickers8.mdl",
	"models/weapons/v_deaglestickers9.mdl",
	"models/weapons/v_deaglestickers10.mdl",
	"models/weapons/v_deaglestickers11.mdl",
	"models/weapons/v_deaglestickers12.mdl"
};

char g_sEliteModels[][] = {
	"models/weapons/v_elitestickers1.mdl",
	"models/weapons/v_elitestickers2.mdl"
};

char g_sNovaModels[][] = {
	"models/weapons/v_novastickers1.mdl"
};

char g_sXM1014Models[][] = {
	"models/weapons/v_xm1014stickers1.mdl",
	"models/weapons/v_xm1014stickers2.mdl",
	"models/weapons/v_xm1014stickers3.mdl"
};

char g_sM249Models[][] = {
	"models/weapons/v_m249stickers1.mdl"
};

char g_sMP9Models[][] = {
	"models/weapons/v_mp9stickers1.mdl"
};

char g_sMAC10Models[][] = {
	"models/weapons/v_mac10stickers1.mdl",
	"models/weapons/v_mac10stickers2.mdl",
	"models/weapons/v_mac10stickers3.mdl",
	"models/weapons/v_mac10stickers4.mdl"
};

char g_sMP7Models[][] = {
	"models/weapons/v_mp7stickers1.mdl",
	"models/weapons/v_mp7stickers2.mdl",
	"models/weapons/v_mp7stickers3.mdl"
};

char g_sMP5Models[][] = {
	"models/weapons/v_mp5sdstickers1.mdl",
	"models/weapons/v_mp5sdstickers2.mdl",
	"models/weapons/v_mp5sdstickers3.mdl"
};

char g_sUMP45Models[][] = {
	"models/weapons/v_ump45stickers1.mdl",
	"models/weapons/v_ump45stickers2.mdl",
	"models/weapons/v_ump45stickers3.mdl"
};

char g_sP90Models[][] = {
	"models/weapons/v_p90stickers1.mdl"
};

char g_sBizonModels[][] = {
	"models/weapons/v_bizonstickers1.mdl"
};

char g_sGalilModels[][] = {
	"models/weapons/v_galilstickers1.mdl",
	"models/weapons/v_galilstickers2.mdl",
	"models/weapons/v_galilstickers3.mdl"
};

char g_sFamasModels[][] = {
	"models/weapons/v_famasstickers1.mdl",
	"models/weapons/v_famasstickers2.mdl",
	"models/weapons/v_famasstickers3.mdl"
};

char g_sM4A4Models[][] = {
	"models/weapons/v_m4a4stickers1.mdl",
	"models/weapons/v_m4a4stickers2.mdl",
	"models/weapons/v_m4a4stickers3.mdl",
	"models/weapons/v_m4a4stickers4.mdl",
	"models/weapons/v_m4a4stickers5.mdl",
	"models/weapons/v_m4a4stickers6.mdl",
	"models/weapons/v_m4a4stickers7.mdl",
	"models/weapons/v_m4a4stickers8.mdl",
	"models/weapons/v_m4a4stickers9.mdl",
	"models/weapons/v_m4a4stickers10.mdl",
	"models/weapons/v_m4a4stickers11.mdl",
	"models/weapons/v_m4a4stickers12.mdl",
	"models/weapons/v_m4a4stickers13.mdl",
	"models/weapons/v_m4a4stickers14.mdl",
	"models/weapons/v_m4a4stickers15.mdl",
	"models/weapons/v_m4a4stickers16.mdl",
	"models/weapons/v_m4a4stickers17.mdl",
	"models/weapons/v_m4a4stickers18.mdl",
	"models/weapons/v_m4a4stickers19.mdl",
	"models/weapons/v_m4a4stickers20.mdl",
	"models/weapons/v_m4a4stickers21.mdl",
	"models/weapons/v_m4a4stickers22.mdl",
	"models/weapons/v_m4a4stickers23.mdl",
	"models/weapons/v_m4a4stickers24.mdl",
	"models/weapons/v_m4a4stickers25.mdl",
	"models/weapons/v_m4a4stickers26.mdl",
	"models/weapons/v_m4a4stickers27.mdl",
	"models/weapons/v_m4a4stickers28.mdl",
	"models/weapons/v_m4a4stickers29.mdl",
	"models/weapons/v_m4a4stickers30.mdl",
	"models/weapons/v_m4a4stickers31.mdl",
	"models/weapons/v_m4a4stickers32.mdl",
	"models/weapons/v_m4a4stickers33.mdl",
	"models/weapons/v_m4a4stickers34.mdl",
	"models/weapons/v_m4a4stickers35.mdl",
	"models/weapons/v_m4a4stickers36.mdl",
	"models/weapons/v_m4a4stickers37.mdl"
};

char g_sSG556Models[][] = {
	"models/weapons/v_sg556stickers1.mdl"
};

char g_sAugModels[][] = {
	"models/weapons/v_augstickers1.mdl"
};

char g_sAWPModels[][] = {
	"models/weapons/v_awpstickers1.mdl",
	"models/weapons/v_awpstickers2.mdl",
	"models/weapons/v_awpstickers3.mdl",
	"models/weapons/v_awpstickers4.mdl",
	"models/weapons/v_awpstickers5.mdl",
	"models/weapons/v_awpstickers6.mdl",
	"models/weapons/v_awpstickers7.mdl",
	"models/weapons/v_awpstickers8.mdl",
	"models/weapons/v_awpstickers9.mdl",
	"models/weapons/v_awpstickers10.mdl",
	"models/weapons/v_awpstickers11.mdl",
	"models/weapons/v_awpstickers12.mdl",
	"models/weapons/v_awpstickers13.mdl",
	"models/weapons/v_awpstickers14.mdl",
	"models/weapons/v_awpstickers15.mdl",
	"models/weapons/v_awpstickers16.mdl",
	"models/weapons/v_awpstickers17.mdl",
	"models/weapons/v_awpstickers18.mdl",
	"models/weapons/v_awpstickers19.mdl",
	"models/weapons/v_awpstickers20.mdl",
	"models/weapons/v_awpstickers21.mdl",
	"models/weapons/v_awpstickers22.mdl",
	"models/weapons/v_awpstickers23.mdl",
	"models/weapons/v_awpstickers24.mdl",
	"models/weapons/v_awpstickers25.mdl",
	"models/weapons/v_awpstickers26.mdl",
	"models/weapons/v_awpstickers27.mdl",
	"models/weapons/v_awpstickers28.mdl",
	"models/weapons/v_awpstickers29.mdl",
	"models/weapons/v_awpstickers30.mdl",
	"models/weapons/v_awpstickers31.mdl",
	"models/weapons/v_awpstickers32.mdl",
	"models/weapons/v_awpstickers33.mdl",
	"models/weapons/v_awpstickers34.mdl",
	"models/weapons/v_awpstickers35.mdl",
	"models/weapons/v_awpstickers36.mdl",
	"models/weapons/v_awpstickers37.mdl",
	"models/weapons/v_awpstickers38.mdl",
	"models/weapons/v_awpstickers39.mdl",
	"models/weapons/v_awpstickers40.mdl",
	"models/weapons/v_awpstickers41.mdl",
	"models/weapons/v_awpstickers42.mdl",
	"models/weapons/v_awpstickers43.mdl",
	"models/weapons/v_awpstickers44.mdl",
	"models/weapons/v_awpstickers45.mdl",
	"models/weapons/v_awpstickers46.mdl",
	"models/weapons/v_awpstickers47.mdl",
	"models/weapons/v_awpstickers48.mdl",
	"models/weapons/v_awpstickers49.mdl",
	"models/weapons/v_awpstickers50.mdl",
	"models/weapons/v_awpstickers51.mdl",
	"models/weapons/v_awpstickers52.mdl",
	"models/weapons/v_awpstickers53.mdl",
	"models/weapons/v_awpstickers54.mdl",
	"models/weapons/v_awpstickers55.mdl",
	"models/weapons/v_awpstickers56.mdl",
	"models/weapons/v_awpstickers57.mdl",
	"models/weapons/v_awpstickers58.mdl"
};

char g_sSSG08Models[][] = {
	"models/weapons/v_ssg08stickers1.mdl",
	"models/weapons/v_ssg08stickers2.mdl",
	"models/weapons/v_ssg08stickers3.mdl",
	"models/weapons/v_ssg08stickers4.mdl"
};

char g_sSCAR20Models[][] = {
	"models/weapons/v_scar20stickers1.mdl"
};

char g_sG3SG1Models[][] = {
	"models/weapons/v_g3sg1stickers1.mdl"
};

char g_sM4A1SModels[][] = {
	"models/weapons/v_m4a1sstickers1.mdl",
	"models/weapons/v_m4a1sstickers2.mdl",
	"models/weapons/v_m4a1sstickers3.mdl",
	"models/weapons/v_m4a1sstickers4.mdl",
	"models/weapons/v_m4a1sstickers5.mdl",
	"models/weapons/v_m4a1sstickers6.mdl",
	"models/weapons/v_m4a1sstickers7.mdl",
	"models/weapons/v_m4a1sstickers8.mdl",
	"models/weapons/v_m4a1sstickers9.mdl",
	"models/weapons/v_m4a1sstickers10.mdl",
	"models/weapons/v_m4a1sstickers11.mdl",
	"models/weapons/v_m4a1sstickers12.mdl",
	"models/weapons/v_m4a1sstickers13.mdl",
	"models/weapons/v_m4a1sstickers14.mdl",
	"models/weapons/v_m4a1sstickers15.mdl",
	"models/weapons/v_m4a1sstickers16.mdl",
	"models/weapons/v_m4a1sstickers17.mdl",
	"models/weapons/v_m4a1sstickers18.mdl",
	"models/weapons/v_m4a1sstickers19.mdl",
	"models/weapons/v_m4a1sstickers20.mdl",
	"models/weapons/v_m4a1sstickers21.mdl",
	"models/weapons/v_m4a1sstickers22.mdl",
	"models/weapons/v_m4a1sstickers23.mdl",
	"models/weapons/v_m4a1sstickers24.mdl",
	"models/weapons/v_m4a1sstickers25.mdl",
	"models/weapons/v_m4a1sstickers26.mdl",
	"models/weapons/v_m4a1sstickers27.mdl",
	"models/weapons/v_m4a1sstickers28.mdl",
	"models/weapons/v_m4a1sstickers29.mdl",
	"models/weapons/v_m4a1sstickers30.mdl",
	"models/weapons/v_m4a1sstickers31.mdl",
	"models/weapons/v_m4a1sstickers32.mdl",
	"models/weapons/v_m4a1sstickers33.mdl",
	"models/weapons/v_m4a1sstickers34.mdl",
	"models/weapons/v_m4a1sstickers35.mdl",
	"models/weapons/v_m4a1sstickers36.mdl",
	"models/weapons/v_m4a1sstickers37.mdl",
	"models/weapons/v_m4a1sstickers38.mdl",
	"models/weapons/v_m4a1sstickers39.mdl",
	"models/weapons/v_m4a1sstickers40.mdl",
	"models/weapons/v_m4a1sstickers41.mdl"
};

char g_sAK47Models[][] = {
	"models/weapons/v_ak47stickers1.mdl",
	"models/weapons/v_ak47stickers2.mdl",
	"models/weapons/v_ak47stickers3.mdl",
	"models/weapons/v_ak47stickers4.mdl",
	"models/weapons/v_ak47stickers5.mdl",
	"models/weapons/v_ak47stickers6.mdl",
	"models/weapons/v_ak47stickers7.mdl",
	"models/weapons/v_ak47stickers8.mdl",
	"models/weapons/v_ak47stickers9.mdl",
	"models/weapons/v_ak47stickers10.mdl",
	"models/weapons/v_ak47stickers11.mdl",
	"models/weapons/v_ak47stickers12.mdl",
	"models/weapons/v_ak47stickers13.mdl",
	"models/weapons/v_ak47stickers14.mdl",
	"models/weapons/v_ak47stickers15.mdl",
	"models/weapons/v_ak47stickers16.mdl",
	"models/weapons/v_ak47stickers17.mdl",
	"models/weapons/v_ak47stickers18.mdl",
	"models/weapons/v_ak47stickers19.mdl",
	"models/weapons/v_ak47stickers20.mdl",
	"models/weapons/v_ak47stickers21.mdl",
	"models/weapons/v_ak47stickers22.mdl",
	"models/weapons/v_ak47stickers23.mdl",
	"models/weapons/v_ak47stickers24.mdl",
	"models/weapons/v_ak47stickers25.mdl",
	"models/weapons/v_ak47stickers26.mdl",
	"models/weapons/v_ak47stickers27.mdl",
	"models/weapons/v_ak47stickers28.mdl",
	"models/weapons/v_ak47stickers29.mdl",
	"models/weapons/v_ak47stickers30.mdl",
	"models/weapons/v_ak47stickers31.mdl",
	"models/weapons/v_ak47stickers32.mdl",
	"models/weapons/v_ak47stickers33.mdl",
	"models/weapons/v_ak47stickers34.mdl",
	"models/weapons/v_ak47stickers35.mdl",
	"models/weapons/v_ak47stickers36.mdl",
	"models/weapons/v_ak47stickers37.mdl",
	"models/weapons/v_ak47stickers38.mdl",
	"models/weapons/v_ak47stickers39.mdl",
	"models/weapons/v_ak47stickers40.mdl",
	"models/weapons/v_ak47stickers41.mdl",
	"models/weapons/v_ak47stickers42.mdl",
	"models/weapons/v_ak47stickers43.mdl",
	"models/weapons/v_ak47stickers44.mdl",
	"models/weapons/v_ak47stickers45.mdl",
	"models/weapons/v_ak47stickers46.mdl",
	"models/weapons/v_ak47stickers47.mdl",
	"models/weapons/v_ak47stickers48.mdl",
	"models/weapons/v_ak47stickers49.mdl",
	"models/weapons/v_ak47stickers50.mdl",
	"models/weapons/v_ak47stickers51.mdl",
	"models/weapons/v_ak47stickers52.mdl",
	"models/weapons/v_ak47stickers53.mdl",
	"models/weapons/v_ak47stickers54.mdl",
	"models/weapons/v_ak47stickers55.mdl",
	"models/weapons/v_ak47stickers56.mdl",
	"models/weapons/v_ak47stickers57.mdl",
	"models/weapons/v_ak47stickers58.mdl",
	"models/weapons/v_ak47stickers59.mdl",
	"models/weapons/v_ak47stickers60.mdl",
	"models/weapons/v_ak47stickers61.mdl",
	"models/weapons/v_ak47stickers62.mdl",
	"models/weapons/v_ak47stickers63.mdl",
	"models/weapons/v_ak47stickers64.mdl",
	"models/weapons/v_ak47stickers65.mdl",
	"models/weapons/v_ak47stickers66.mdl",
	"models/weapons/v_ak47stickers67.mdl",
	"models/weapons/v_ak47stickers68.mdl",
	"models/weapons/v_ak47stickers69.mdl",
	"models/weapons/v_ak47stickers70.mdl",
	"models/weapons/v_ak47stickers71.mdl",
	"models/weapons/v_ak47stickers72.mdl",
	"models/weapons/v_ak47stickers73.mdl",
	"models/weapons/v_ak47stickers74.mdl",
	"models/weapons/v_ak47stickers75.mdl",
	"models/weapons/v_ak47stickers76.mdl",
	"models/weapons/v_ak47stickers77.mdl",
	"models/weapons/v_ak47stickers78.mdl",
	"models/weapons/v_ak47stickers79.mdl",
	"models/weapons/v_ak47stickers80.mdl",
	"models/weapons/v_ak47stickers81.mdl",
	"models/weapons/v_ak47stickers82.mdl",
	"models/weapons/v_ak47stickers83.mdl",
	"models/weapons/v_ak47stickers84.mdl",
	"models/weapons/v_ak47stickers85.mdl",
	"models/weapons/v_ak47stickers86.mdl",
	"models/weapons/v_ak47stickers87.mdl",
	"models/weapons/v_ak47stickers88.mdl",
	"models/weapons/v_ak47stickers89.mdl",
	"models/weapons/v_ak47stickers90.mdl",
	"models/weapons/v_ak47stickers91.mdl",
	"models/weapons/v_ak47stickers92.mdl",
	"models/weapons/v_ak47stickers93.mdl",
	"models/weapons/v_ak47stickers94.mdl",
	"models/weapons/v_ak47stickers95.mdl",
	"models/weapons/v_ak47stickers96.mdl",
	"models/weapons/v_ak47stickers97.mdl",
	"models/weapons/v_ak47stickers98.mdl",
	"models/weapons/v_ak47stickers99.mdl",
	"models/weapons/v_ak47stickers100.mdl",
	"models/weapons/v_ak47stickers101.mdl",
	"models/weapons/v_ak47stickers102.mdl",
	"models/weapons/v_ak47stickers103.mdl",
	"models/weapons/v_ak47stickers104.mdl",
	"models/weapons/v_ak47stickers105.mdl",
	"models/weapons/v_ak47stickers106.mdl",
	"models/weapons/v_ak47stickers107.mdl",
	"models/weapons/v_ak47stickers108.mdl",
	"models/weapons/v_ak47stickers109.mdl",
	"models/weapons/v_ak47stickers110.mdl",
	"models/weapons/v_ak47stickers111.mdl",
	"models/weapons/v_ak47stickers112.mdl",
	"models/weapons/v_ak47stickers113.mdl",
	"models/weapons/v_ak47stickers114.mdl",
	"models/weapons/v_ak47stickers115.mdl",
	"models/weapons/v_ak47stickers116.mdl",
	"models/weapons/v_ak47stickers117.mdl",
	"models/weapons/v_ak47stickers118.mdl",
	"models/weapons/v_ak47stickers119.mdl",
	"models/weapons/v_ak47stickers120.mdl",
	"models/weapons/v_ak47stickers121.mdl"
};

char g_sBotName[][] = {
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
	"Misutaaa",
	//BIG Players
	"tiziaN",
	"syrsoN",
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
	"oskar",
	"dycha",
	"Spiidi",
	"faveN",
	"denis",
	//FPX Players
	"es3tag",
	"b0RUP",
	"Snappi",
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
	"Radifaction",
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
	//MVP.PK Players
	"glow",
	"termi",
	"Rb",
	"k1Ng",
	"stax",
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
	//Defusekids Player
	"HOLMES",
	"VANITY",
	"FASHR",
	"D0cC",
	"rilax",
	//GamerLegion Players
	"dennis",
	"draken",
	"freddieb",
	"RuStY",
	"hampus",
	//DIVIZON Players
	"slunixx",
	"CEQU",
	"hyped",
	"merisinho",
	"ykyli",
	//EURONICS Players
	"red",
	"pdy",
	"PerX",
	"Seeeya",
	"maRky",
	//PANTHERS Players
	"boostey",
	"HighKitty",
	"syncD",
	"BMLN",
	"Aika",
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
	"BORKUM",
	"Derek",
	//Baskonia Players
	"tatin",
	"PabLo",
	"LittlesataN1",
	"dixon",
	"jJavi",
	//Giants Players
	"NOPEEj",
	"fox",
	"Cunha",
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
	"SEMINTE",
	"iM",
	"starkiller",
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
	"Queenix",
	"TOBIZ",
	"Celrate",
	//DETONA Players
	"fP1",
	"tiburci0",
	"v$m",
	"Lucaozy",
	"Tuurtle",
	//Infinity Players
	"k1Nky",
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
	"heat",
	"jnt",
	"leo_drunky",
	"exit",
	"Luken",
	//One Players
	"dav1dddd",
	"Maluk3",
	"trk",
	"felps",
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
	"jeepy",
	"Wolfah",
	//SKADE Players
	"Rock1nG",
	"dennyslaw",
	"rafftu",
	"Rainwaker",
	"SPELLAN",
	//Paradox Players
	"ino",
	"1ukey",
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
	//Beyond Players
	"MAIROLLS",
	"Olivia",
	"Kntz",
	"stk",
	"foxz",
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
	"aLvAr-",
	"Just1ce",
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
	"spy",
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
	//QB Players
	"MadLife",
	"Electro",
	"nafan9",
	"Raider",
	"L4F",
	//Energy Players
	"Panda",
	"disTroiT",
	"Lichl0rd",
	"Damz",
	"kreatioN",
	//Furious Players
	"nbl",
	"EYKER",
	"niox",
	"iKrystal",
	"pablek",
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
	"Russ",
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
	"zWin",
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
	"TeSeS",
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
	//Trident Players
	"nope",
	"Quasar GT",
	"clutchyy",
	"JP",
	"Versa",
	//Syman Players
	"neaLaN",
	"mou",
	"n0rb3r7",
	"kreaz",
	"Keoz",
	//wNv Players
	"k4Mi",
	"FB",
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
	"micalis",
	"jtr",
	"Koro",
	"Rackem",
	"vanilla",
	//UOL Players
	"crisby",
	"kZyJL",
	"Andyy",
	"JDC",
	".P4TriCK",
	//9INE Players
	"nicoodoz",
	"phzy",
	"Djury",
	"aybeN",
	"MistFire",
	//Baecon Players
	"brA",
	"Demonos",
	"tyko",
	"horvy",
	"KILLDREAM",
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
	//aL Players
	"pounh",
	"FliP1",
	"Butters",
	"Remoy",
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
	"AiyvaN",
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
	"donQ",
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
	"Kap3r",
	"SZPERO",
	"mynio",
	"morelz",
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
	"Polt",
	"fenvicious",
	//Izako Players
	"azizz",
	"ewrzyn",
	"EXUS",
	"pr3e",
	"TOAO",
	//ATK Players
	"bLazE",
	"MisteM",
	"flexeeee",
	"Fadey",
	"TenZ",
	//Chaos Players
	"cam",
	"vanity",
	"smooya",
	"steel_",
	"SicK",
	//OneThree Players
	"Ayeon",
	"lan",
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
	"Shakezullah",
	"Voltage",
	"Spongey",
	"Asuna",
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
	//Reason Players
	"Frei",
	"Astroo",
	"jenko",
	"Puls3",
	"stan1ey",
	//Tricked Players
	"kiR",
	"kwezz",
	"Luckyv1",
	"torben",
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
	//Dignitas Players
	"GeT_RiGhT",
	"hallzerk",
	"f0rest",
	"friberg",
	"Xizt",
	//Skyfire Players
	"Mizzy",
	"Gumpton",
	"affiNity",
	"LikiAU",
	"lato",
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
	"Lukki",
	"IceBerg",
	//KOVA Players
	"pietola",
	"Derkeps",
	"uli",
	"peku",
	"Twixie",
	//AVANGAR Players
	"TNDKingg",
	"howl",
	"hidenway",
	"kade0",
	"spellfull",
	//CR4ZY Players
	"dERZKIY",
	"Sergiz",
	"dOBRIY",
	"Psycho",
	"SENSEi",
	//Redemption Players
	"drg",
	"ALLE",
	"remix",
	"sutecas",
	"dok"
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
	HookEvent("player_death", OnPlayerDeath);
	HookEvent("round_start", OnRoundStart);
	HookEvent("round_freeze_end", OnFreezetimeEnd);
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
	RegConsoleCmd("team_contact", Team_c0ntact);
	RegConsoleCmd("team_col", Team_coL);
	RegConsoleCmd("team_vici", Team_ViCi);
	RegConsoleCmd("team_forze", Team_forZe);
	RegConsoleCmd("team_winstrike", Team_Winstrike);
	RegConsoleCmd("team_sprout", Team_Sprout);
	RegConsoleCmd("team_fpx", Team_FPX);
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
	RegConsoleCmd("team_risingstars", Team_RisingStars);
	RegConsoleCmd("team_ehome", Team_EHOME);
	RegConsoleCmd("team_beyond", Team_Beyond);
	RegConsoleCmd("team_boom", Team_BOOM);
	RegConsoleCmd("team_lucid", Team_Lucid);
	RegConsoleCmd("team_nasr", Team_NASR);
	RegConsoleCmd("team_portal", Team_Portal);
	RegConsoleCmd("team_brutals", Team_Brutals);
	RegConsoleCmd("team_invictus", Team_iNvictus);
	RegConsoleCmd("team_nxl", Team_nxl);
	RegConsoleCmd("team_qb", Team_QB);
	RegConsoleCmd("team_energy", Team_energy);
	RegConsoleCmd("team_furious", Team_Furious);
	RegConsoleCmd("team_bluejays", Team_BLUEJAYS);
	RegConsoleCmd("team_executioners", Team_EXECUTIONERS);
	RegConsoleCmd("team_vexed", Team_Vexed);
	RegConsoleCmd("team_groundzero", Team_GroundZero);
	RegConsoleCmd("team_avez", Team_AVEZ);
	RegConsoleCmd("team_btrg", Team_BTRG);
	RegConsoleCmd("team_gtz", Team_GTZ);
	RegConsoleCmd("team_flames", Team_Flames);
	RegConsoleCmd("team_bpro", Team_BPro);
	RegConsoleCmd("team_trident", Team_Trident);
	RegConsoleCmd("team_syman", Team_Syman);
	RegConsoleCmd("team_wnv", Team_wNv);
	RegConsoleCmd("team_goliath", Team_Goliath);
	RegConsoleCmd("team_secret", Team_Secret);
	RegConsoleCmd("team_incept", Team_Incept);
	RegConsoleCmd("team_uol", Team_UOL);
	RegConsoleCmd("team_9ine", Team_9INE);
	RegConsoleCmd("team_baecon", Team_Baecon);
	RegConsoleCmd("team_wizards", Team_Wizards);
	RegConsoleCmd("team_illuminar", Team_Illuminar);
	RegConsoleCmd("team_queso", Team_Queso);
	RegConsoleCmd("team_al", Team_aL);
	RegConsoleCmd("team_orange", Team_Orange);
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
	RegConsoleCmd("team_reason", Team_Reason);
	RegConsoleCmd("team_tricked", Team_Tricked);
	RegConsoleCmd("team_geng", Team_GenG);
	RegConsoleCmd("team_endpoint", Team_Endpoint);
	RegConsoleCmd("team_saw", Team_sAw);
	RegConsoleCmd("team_dignitas", Team_Dignitas);
	RegConsoleCmd("team_skyfire", Team_Skyfire);
	RegConsoleCmd("team_zigma", Team_ZIGMA);
	RegConsoleCmd("team_ambush", Team_Ambush);
	RegConsoleCmd("team_kova", Team_KOVA);
	RegConsoleCmd("team_avangar", Team_AVANGAR);
	RegConsoleCmd("team_cr4zy", Team_CR4ZY);
	RegConsoleCmd("team_redemption", Team_Redemption);
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
		ServerCommand("bot_add_ct %s", "oskar");
		ServerCommand("bot_add_ct %s", "dycha");
		ServerCommand("bot_add_ct %s", "Spiidi");
		ServerCommand("bot_add_ct %s", "faveN");
		ServerCommand("bot_add_ct %s", "denis");
		ServerCommand("mp_teamlogo_1 spr");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "oskar");
		ServerCommand("bot_add_t %s", "dycha");
		ServerCommand("bot_add_t %s", "Spiidi");
		ServerCommand("bot_add_t %s", "faveN");
		ServerCommand("bot_add_t %s", "denis");
		ServerCommand("mp_teamlogo_2 spr");
	}
	
	return Plugin_Handled;
}

public Action Team_FPX(int client, int args)
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
		ServerCommand("mp_teamlogo_1 fpx");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "es3tag");
		ServerCommand("bot_add_t %s", "b0RUP");
		ServerCommand("bot_add_t %s", "Snappi");
		ServerCommand("bot_add_t %s", "cadiaN");
		ServerCommand("bot_add_t %s", "stavn");
		ServerCommand("mp_teamlogo_2 fpx");
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

public Action Team_MVPPK(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "glow");
		ServerCommand("bot_add_ct %s", "termi");
		ServerCommand("bot_add_ct %s", "Rb");
		ServerCommand("bot_add_ct %s", "k1Ng");
		ServerCommand("bot_add_ct %s", "stax");
		ServerCommand("mp_teamlogo_1 mvp");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "glow");
		ServerCommand("bot_add_t %s", "termi");
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

public Action Team_Defusekids(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "HOLMES");
		ServerCommand("bot_add_ct %s", "VANITY");
		ServerCommand("bot_add_ct %s", "FASHR");
		ServerCommand("bot_add_ct %s", "D0cC");
		ServerCommand("bot_add_ct %s", "rilax");
		ServerCommand("mp_teamlogo_1 defu");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "HOLMES");
		ServerCommand("bot_add_t %s", "VANITY");
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
		ServerCommand("bot_add_ct %s", "slunixx");
		ServerCommand("bot_add_ct %s", "CEQU");
		ServerCommand("bot_add_ct %s", "hyped");
		ServerCommand("bot_add_ct %s", "merisinho");
		ServerCommand("bot_add_ct %s", "ykyli");
		ServerCommand("mp_teamlogo_1 divi");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "slunixx");
		ServerCommand("bot_add_t %s", "CEQU");
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

public Action Team_PANTHERS(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "boostey");
		ServerCommand("bot_add_ct %s", "HighKitty");
		ServerCommand("bot_add_ct %s", "syncD");
		ServerCommand("bot_add_ct %s", "BMLN");
		ServerCommand("bot_add_ct %s", "Aika");
		ServerCommand("mp_teamlogo_1 pant");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "boostey");
		ServerCommand("bot_add_t %s", "HighKitty");
		ServerCommand("bot_add_t %s", "syncD");
		ServerCommand("bot_add_t %s", "BMLN");
		ServerCommand("bot_add_t %s", "Aika");
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
		ServerCommand("bot_add_ct %s", "thamlike");
		ServerCommand("bot_add_ct %s", "Cabbi");
		ServerCommand("mp_teamlogo_1 lyng");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "birdfromsky");
		ServerCommand("bot_add_t %s", "Twinx");
		ServerCommand("bot_add_t %s", "maNkz");
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
		ServerCommand("bot_add_ct %s", "NOPEEj");
		ServerCommand("bot_add_ct %s", "fox");
		ServerCommand("bot_add_ct %s", "Cunha");
		ServerCommand("bot_add_ct %s", "BLOODZ");
		ServerCommand("bot_add_ct %s", "renatoohaxx");
		ServerCommand("mp_teamlogo_1 giant");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "NOPEEj");
		ServerCommand("bot_add_t %s", "fox");
		ServerCommand("bot_add_t %s", "Cunha");
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
		ServerCommand("bot_add_ct %s", "The eLiVe");
		ServerCommand("bot_add_ct %s", "Blogg1s");
		ServerCommand("bot_add_ct %s", "luko");
		ServerCommand("mp_teamlogo_1 esu");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "NIO");
		ServerCommand("bot_add_t %s", "Levi");
		ServerCommand("bot_add_t %s", "The eLiVe");
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
		ServerCommand("bot_add_ct %s", "Queenix");
		ServerCommand("bot_add_ct %s", "TOBIZ");
		ServerCommand("bot_add_ct %s", "Celrate");
		ServerCommand("mp_teamlogo_1 sing");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Jabbi");
		ServerCommand("bot_add_t %s", "mertz");
		ServerCommand("bot_add_t %s", "Queenix");
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
		ServerCommand("bot_add_ct %s", "fP1");
		ServerCommand("bot_add_ct %s", "tiburci0");
		ServerCommand("bot_add_ct %s", "v$m");
		ServerCommand("bot_add_ct %s", "Lucaozy");
		ServerCommand("bot_add_ct %s", "Tuurtle");
		ServerCommand("mp_teamlogo_1 deto");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "fP1");
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
		ServerCommand("bot_add_ct %s", "malbsMd");
		ServerCommand("bot_add_ct %s", "spamzzy");
		ServerCommand("bot_add_ct %s", "sam_A");
		ServerCommand("bot_add_ct %s", "Daveys");
		ServerCommand("mp_teamlogo_1 infi");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "k1Nky");
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
		ServerCommand("bot_add_ct %s", "dav1dddd");
		ServerCommand("bot_add_ct %s", "Maluk3");
		ServerCommand("bot_add_ct %s", "trk");
		ServerCommand("bot_add_ct %s", "felps");
		ServerCommand("bot_add_ct %s", "b4rtiN");
		ServerCommand("mp_teamlogo_1 tone");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "dav1dddd");
		ServerCommand("bot_add_t %s", "Maluk3");
		ServerCommand("bot_add_t %s", "trk");
		ServerCommand("bot_add_t %s", "felps");
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

public Action Team_Paradox(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ino");
		ServerCommand("bot_add_ct %s", "1ukey");
		ServerCommand("bot_add_ct %s", "ekul");
		ServerCommand("bot_add_ct %s", "bedonka");
		ServerCommand("bot_add_ct %s", "urbz");
		ServerCommand("mp_teamlogo_1 para");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ino");
		ServerCommand("bot_add_t %s", "1ukey");
		ServerCommand("bot_add_t %s", "ekul");
		ServerCommand("bot_add_t %s", "bedonka");
		ServerCommand("bot_add_t %s", "urbz");
		ServerCommand("mp_teamlogo_2 para");
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
		ServerCommand("bot_add_ct %s", "foxz");
		ServerCommand("mp_teamlogo_1 bey");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "MAIROLLS");
		ServerCommand("bot_add_t %s", "Olivia");
		ServerCommand("bot_add_t %s", "Kntz");
		ServerCommand("bot_add_t %s", "stk");
		ServerCommand("bot_add_t %s", "foxz");
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
		ServerCommand("bot_add_ct %s", "aLvAr-");
		ServerCommand("bot_add_ct %s", "Just1ce");
		ServerCommand("mp_teamlogo_1 nasr");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "proxyyb");
		ServerCommand("bot_add_t %s", "Real1ze");
		ServerCommand("bot_add_t %s", "BOROS");
		ServerCommand("bot_add_t %s", "aLvAr-");
		ServerCommand("bot_add_t %s", "Just1ce");
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
		ServerCommand("bot_add_ct %s", "Panda");
		ServerCommand("bot_add_ct %s", "disTroiT");
		ServerCommand("bot_add_ct %s", "Lichl0rd");
		ServerCommand("bot_add_ct %s", "Damz");
		ServerCommand("bot_add_ct %s", "kreatioN");
		ServerCommand("mp_teamlogo_1 ener");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Panda");
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
		ServerCommand("bot_add_ct %s", "EYKER");
		ServerCommand("bot_add_ct %s", "niox");
		ServerCommand("bot_add_ct %s", "iKrystal");
		ServerCommand("bot_add_ct %s", "pablek");
		ServerCommand("mp_teamlogo_1 furio");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "nbl");
		ServerCommand("bot_add_t %s", "EYKER");
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
		ServerCommand("bot_add_ct %s", "maxz");
		ServerCommand("bot_add_ct %s", "Tsubasa");
		ServerCommand("bot_add_ct %s", "jansen");
		ServerCommand("bot_add_ct %s", "RykuN");
		ServerCommand("bot_add_ct %s", "\"skillmaschine JJ_-\"");
		ServerCommand("mp_teamlogo_1 blueja");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "maxz");
		ServerCommand("bot_add_t %s", "Tsubasa");
		ServerCommand("bot_add_t %s", "jansen");
		ServerCommand("bot_add_t %s", "RykuN");
		ServerCommand("bot_add_t %s", "\"skillmaschine JJ_-\"");
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
		ServerCommand("bot_add_ct %s", "Russ");
		ServerCommand("mp_teamlogo_1 vex");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "mezii");
		ServerCommand("bot_add_t %s", "Kray");
		ServerCommand("bot_add_t %s", "Adam9130");
		ServerCommand("bot_add_t %s", "L1NK");
		ServerCommand("bot_add_t %s", "Russ");
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
		ServerCommand("bot_add_ct %s", "zWin");
		ServerCommand("bot_add_ct %s", "xccurate");
		ServerCommand("bot_add_ct %s", "ImpressioN");
		ServerCommand("bot_add_ct %s", "XigN");
		ServerCommand("mp_teamlogo_1 btrg");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "HeiB");
		ServerCommand("bot_add_t %s", "zWin");
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
		ServerCommand("bot_add_ct %s", "TeSeS");
		ServerCommand("bot_add_ct %s", "farlig");
		ServerCommand("bot_add_ct %s", "HooXi");
		ServerCommand("bot_add_ct %s", "refrezh");
		ServerCommand("bot_add_ct %s", "Nodios");
		ServerCommand("mp_teamlogo_1 copen");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "TeSeS");
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

public Action Team_Trident(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "nope");
		ServerCommand("bot_add_ct %s", "\"Quasar GT\"");
		ServerCommand("bot_add_ct %s", "clutchyy");
		ServerCommand("bot_add_ct %s", "JP");
		ServerCommand("bot_add_ct %s", "Versa");
		ServerCommand("mp_teamlogo_1 trid");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "nope");
		ServerCommand("bot_add_t %s", "\"Quasar GT\"");
		ServerCommand("bot_add_t %s", "clutchyy");
		ServerCommand("bot_add_t %s", "JP");
		ServerCommand("bot_add_t %s", "Versa");
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

public Action Team_wNv(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "k4Mi");
		ServerCommand("bot_add_ct %s", "FB");
		ServerCommand("bot_add_ct %s", "Pure");
		ServerCommand("bot_add_ct %s", "FairyRae");
		ServerCommand("bot_add_ct %s", "kZy");
		ServerCommand("mp_teamlogo_1 wnv");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "k4Mi");
		ServerCommand("bot_add_t %s", "FB");
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
		ServerCommand("bot_add_ct %s", "micalis");
		ServerCommand("bot_add_ct %s", "jtr");
		ServerCommand("bot_add_ct %s", "Koro");
		ServerCommand("bot_add_ct %s", "Rackem");
		ServerCommand("bot_add_ct %s", "vanilla");
		ServerCommand("mp_teamlogo_1 ince");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "micalis");
		ServerCommand("bot_add_t %s", "jtr");
		ServerCommand("bot_add_t %s", "Koro");
		ServerCommand("bot_add_t %s", "Rackem");
		ServerCommand("bot_add_t %s", "vanilla");
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

public Action Team_9INE(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "nicoodoz");
		ServerCommand("bot_add_ct %s", "phzy");
		ServerCommand("bot_add_ct %s", "Djury");
		ServerCommand("bot_add_ct %s", "aybeN");
		ServerCommand("bot_add_ct %s", "MistFire");
		ServerCommand("mp_teamlogo_1 9ine");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "nicoodoz");
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
		ServerCommand("bot_add_ct %s", "tyko");
		ServerCommand("bot_add_ct %s", "horvy");
		ServerCommand("bot_add_ct %s", "KILLDREAM");
		ServerCommand("mp_teamlogo_1 baec");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "brA");
		ServerCommand("bot_add_t %s", "Demonos");
		ServerCommand("bot_add_t %s", "tyko");
		ServerCommand("bot_add_t %s", "horvy");
		ServerCommand("bot_add_t %s", "KILLDREAM");
		ServerCommand("mp_teamlogo_2 baec");
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

public Action Team_aL(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "pounh");
		ServerCommand("bot_add_ct %s", "FliP1");
		ServerCommand("bot_add_ct %s", "Butters");
		ServerCommand("bot_add_ct %s", "Remoy");
		ServerCommand("bot_add_ct %s", "PALM1");
		ServerCommand("mp_teamlogo_1 aL");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "pounh");
		ServerCommand("bot_add_t %s", "FliP1");
		ServerCommand("bot_add_t %s", "Butters");
		ServerCommand("bot_add_t %s", "Remoy");
		ServerCommand("bot_add_t %s", "PALM1");
		ServerCommand("mp_teamlogo_2 aL");
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
		ServerCommand("bot_add_ct %s", "AiyvaN");
		ServerCommand("mp_teamlogo_1 hlr");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ANGE1");
		ServerCommand("bot_add_t %s", "nukkye");
		ServerCommand("bot_add_t %s", "Flarich");
		ServerCommand("bot_add_t %s", "crush");
		ServerCommand("bot_add_t %s", "AiyvaN");
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
		ServerCommand("bot_add_ct %s", "donQ");
		ServerCommand("bot_add_ct %s", "NaOw");
		ServerCommand("mp_teamlogo_1 kpi");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "xikii");
		ServerCommand("bot_add_t %s", "SunPayus");
		ServerCommand("bot_add_t %s", "meisoN");
		ServerCommand("bot_add_t %s", "donQ");
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
		ServerCommand("bot_add_ct %s", "azizz");
		ServerCommand("bot_add_ct %s", "ewrzyn");
		ServerCommand("bot_add_ct %s", "EXUS");
		ServerCommand("bot_add_ct %s", "pr3e");
		ServerCommand("bot_add_ct %s", "TOAO");
		ServerCommand("mp_teamlogo_1 izak");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "azizz");
		ServerCommand("bot_add_t %s", "ewrzyn");
		ServerCommand("bot_add_t %s", "EXUS");
		ServerCommand("bot_add_t %s", "pr3e");
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
		ServerCommand("bot_add_ct %s", "cam");
		ServerCommand("bot_add_ct %s", "vanity");
		ServerCommand("bot_add_ct %s", "smooya");
		ServerCommand("bot_add_ct %s", "steel_");
		ServerCommand("bot_add_ct %s", "SicK");
		ServerCommand("mp_teamlogo_1 chaos");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "cam");
		ServerCommand("bot_add_t %s", "vanity");
		ServerCommand("bot_add_t %s", "smooya");
		ServerCommand("bot_add_t %s", "steel_");
		ServerCommand("bot_add_t %s", "SicK");
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
		ServerCommand("bot_add_ct %s", "Ayeon");
		ServerCommand("bot_add_ct %s", "lan");
		ServerCommand("bot_add_ct %s", "captainMo");
		ServerCommand("bot_add_ct %s", "DD");
		ServerCommand("bot_add_ct %s", "Karsa");
		ServerCommand("mp_teamlogo_1 one");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Ayeon");
		ServerCommand("bot_add_t %s", "lan");
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
		ServerCommand("bot_add_ct %s", "Shakezullah");
		ServerCommand("bot_add_ct %s", "Voltage");
		ServerCommand("bot_add_ct %s", "Spongey");
		ServerCommand("bot_add_ct %s", "Asuna");
		ServerCommand("bot_add_ct %s", "Grim");
		ServerCommand("mp_teamlogo_1 tri");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Shakezullah");
		ServerCommand("bot_add_t %s", "Voltage");
		ServerCommand("bot_add_t %s", "Spongey");
		ServerCommand("bot_add_t %s", "Asuna");
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

public Action Team_Reason(int client, int args)
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
		ServerCommand("mp_teamlogo_1 r");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Frei");
		ServerCommand("bot_add_t %s", "Astroo");
		ServerCommand("bot_add_t %s", "jenko");
		ServerCommand("bot_add_t %s", "Puls3");
		ServerCommand("bot_add_t %s", "stan1ey");
		ServerCommand("mp_teamlogo_2 r");
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
		ServerCommand("bot_add_ct %s", "torben");
		ServerCommand("bot_add_ct %s", "Toft");
		ServerCommand("mp_teamlogo_1 trick");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "kiR");
		ServerCommand("bot_add_t %s", "kwezz");
		ServerCommand("bot_add_t %s", "Luckyv1");
		ServerCommand("bot_add_t %s", "torben");
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

public Action Team_Dignitas(int client, int args)
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

public Action Team_Skyfire(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Mizzy");
		ServerCommand("bot_add_ct %s", "Gumpton");
		ServerCommand("bot_add_ct %s", "affiNity");
		ServerCommand("bot_add_ct %s", "LikiAU");
		ServerCommand("bot_add_ct %s", "lato");
		ServerCommand("mp_teamlogo_1 sky");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Mizzy");
		ServerCommand("bot_add_t %s", "Gumpton");
		ServerCommand("bot_add_t %s", "affiNity");
		ServerCommand("bot_add_t %s", "LikiAU");
		ServerCommand("bot_add_t %s", "lato");
		ServerCommand("mp_teamlogo_2 sky");
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
		ServerCommand("bot_add_ct %s", "Lukki");
		ServerCommand("bot_add_ct %s", "IceBerg");
		ServerCommand("mp_teamlogo_1 ambu");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Inzta");
		ServerCommand("bot_add_t %s", "Ryxxo");
		ServerCommand("bot_add_t %s", "zeq");
		ServerCommand("bot_add_t %s", "Lukki");
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

public Action Team_AVANGAR(int client, int args)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "TNDKingg");
		ServerCommand("bot_add_ct %s", "howl");
		ServerCommand("bot_add_ct %s", "hidenway");
		ServerCommand("bot_add_ct %s", "kade0");
		ServerCommand("bot_add_ct %s", "spellfull");
		ServerCommand("mp_teamlogo_1 avg");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "TNDKingg");
		ServerCommand("bot_add_t %s", "howl");
		ServerCommand("bot_add_t %s", "hidenway");
		ServerCommand("bot_add_t %s", "kade0");
		ServerCommand("bot_add_t %s", "spellfull");
		ServerCommand("mp_teamlogo_2 avg");
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
		ServerCommand("bot_add_ct %s", "dERZKIY");
		ServerCommand("bot_add_ct %s", "Sergiz");
		ServerCommand("bot_add_ct %s", "dOBRIY");
		ServerCommand("bot_add_ct %s", "Psycho");
		ServerCommand("bot_add_ct %s", "SENSEi");
		ServerCommand("mp_teamlogo_1 cr4z");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "dERZKIY");
		ServerCommand("bot_add_t %s", "Sergiz");
		ServerCommand("bot_add_t %s", "dOBRIY");
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
		ServerCommand("bot_add_ct %s", "sutecas");
		ServerCommand("bot_add_ct %s", "dok");
		ServerCommand("mp_teamlogo_1 redem");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "drg");
		ServerCommand("bot_add_t %s", "ALLE");
		ServerCommand("bot_add_t %s", "remix");
		ServerCommand("bot_add_t %s", "sutecas");
		ServerCommand("bot_add_t %s", "dok");
		ServerCommand("mp_teamlogo_2 redem");
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
	SDKHook(client, SDKHook_WeaponEquipPost, OnWeaponEquipPost);
}

public void OnRoundStart(Handle event, char[] name, bool dbc)
{	
	g_bFreezetimeEnd = false;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i) && IsFakeClient(i))
		{			
			if(GetRandomInt(1,100) <= 35)
			{
				if(GetClientTeam(i) == CS_TEAM_CT)
				{
					SetEntityModel(i, g_sCTModels[GetRandomInt(0, sizeof(g_sCTModels) - 1)]);
				}
				else if(GetClientTeam(i) == CS_TEAM_T)
				{
					SetEntityModel(i, g_sTModels[GetRandomInt(0, sizeof(g_sTModels) - 1)]);
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

public void OnFreezetimeEnd(Handle event, char[] name, bool dbc)
{
	g_bFreezetimeEnd = true;
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
	
	int index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
	
	if(IsValidClient(client))
	{	
		if(GetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nModelIndex") != 0)
		{
			switch(index)
			{
				case 61:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 504:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 653:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 705:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
						case 339:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 313:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 221:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
						case 817:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 637:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
						case 290:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 183:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
						case 60:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15);
						}
						case 318:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16);
						}
						case 657:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 540:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17);
						}
						case 489:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18);
						}
						case 217:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19);
						}
						case 277:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9);
						}
						case 796:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
						case 364:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20);
						}
						case 236:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 443:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21);
						}
						case 454:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22);
						}
						case 332:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23);
						}
						case 25:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24);
						}
					}
				}
				case 32:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 389:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
						case 591:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 184:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 211:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
						case 894:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9);
						}
						case 667:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 485:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 246:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 71:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 700:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 635:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
						case 550:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 515:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
						case 357:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15);
						}
						case 338:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16);
						}
						case 275:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17);
						}
						case 32:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18);
						}
						case 443:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19);
						}
						case 346:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20);
						}
						case 95:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21);
						}
						case 21:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22);
						}
						case 104:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23);
						}
					}
				}
				case 4:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 586:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17);
						}
						case 353:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18);
						}
						case 437:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15);
						}
						case 694:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 607:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19);
						}
						case 532:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 381:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
						case 230:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
						case 48:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20);
						}
						case 732:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21);
						}
						case 789:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9);
						}
						case 38:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 159:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
						case 918:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 808:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 713:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16);
						}
						case 680:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 623:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22);
						}
						case 495:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23);
						}
						case 479:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
						case 399:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 278:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24);
						}
						case 367:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
						case 3:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25);
						}
						case 799:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26);
						}
						case 40:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27);
						}
						case 293:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 28);
						}
						case 2:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 208:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 29);
						}
					}
				}
				case 36:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 678:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
						case 551:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 404:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 388:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
						case 271:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9);
						}
						case 258:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 295:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
						case 907:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15);
						}
						case 125:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16);
						}
						case 813:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17);
						}
						case 668:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
						case 501:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18);
						}
						case 358:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19);
						}
						case 162:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 749:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 168:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 848:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20);
						}
						case 650:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21);
						}
						case 592:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22);
						}
						case 426:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23);
						}
						case 230:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24);
						}
						case 219:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25);
						}
						case 786:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26);
						}
						case 102:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27);
						}
						case 164:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 28);
						}
						case 741:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 29);
						}
						case 466:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 30);
						}
						case 373:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 34:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 31);
						}
						case 207:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 32);
						}
						case 15:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 33);
						}
						case 777:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 467:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 34);
						}
						case 77:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 35);
						}
						case 99:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
						case 27:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 36);
						}
					}
				}
				case 3:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 837:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24);
						}
						case 660:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 427:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 352:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15);
						}
						case 906:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25);
						}
						case 530:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 510:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
						case 274:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18);
						}
						case 44:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20);
						}
						case 464:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9);
						}
						case 693:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17);
						}
						case 646:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21);
						}
						case 605:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
						case 585:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 387:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 223:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 265:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 729:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26);
						}
						case 254:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
						case 252:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 377:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
						case 141:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27);
						}
						case 3:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22);
						}
						case 784:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 28);
						}
						case 46:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19);
						}
						case 78:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16);
						}
						case 210:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23);
						}
						case 151:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
					}
				}
				case 63:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 270:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
						case 643:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15);
						}
						case 476:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16);
						}
						case 269:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 709:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 687:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 543:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 435:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
						case 350:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
						case 268:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17);
						}
						case 325:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9);
						}
						case 622:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
						case 602:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 218:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 334:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 315:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18);
						}
						case 12:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 859:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19);
						}
						case 453:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20);
						}
						case 322:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
						case 297:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21);
						}
						case 333:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22);
						}
						case 298:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24);
						}
						case 366:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23);
						}
					}
				}
				case 30:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 889:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16);
						}
						case 614:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 791:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 839:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17);
						}
						case 555:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18);
						}
						case 520:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15);
						}
						case 272:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
						case 248:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 179:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 905:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19);
						}
						case 816:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20);
						}
						case 722:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21);
						}
						case 684:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
						case 671:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22);
						}
						case 599:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23);
						}
						case 539:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9);
						}
						case 303:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 289:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
						case 216:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 463:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 374:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
						case 159:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24);
						}
						case 36:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 733:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25);
						}
						case 738:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26);
						}
						case 439:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27);
						}
						case 235:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 28);
						}
						case 459:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
						case 17:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 29);
						}
						case 242:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 30);
						}
						case 2:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 31);
						}
						case 206:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 32);
						}
					}
				}
				case 1:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 711:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 185:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
						case 805:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 527:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 351:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
						case 231:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 61:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
						case 841:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 603:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
						case 397:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
						case 232:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15);
						}
						case 273:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16);
						}
						case 757:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17);
						}
						case 470:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18);
						}
						case 469:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19);
						}
						case 328:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20);
						}
						case 347:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21);
						}
						case 37:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9);
						}
						case 645:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 509:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 425:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 296:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22);
						}
						case 237:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23);
						}
						case 40:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24);
						}
						case 468:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25);
						}
						case 17:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26);
						}
						case 90:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27);
						}
					}
				}
				case 2:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 658:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 747:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9);
						}
						case 625:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 396:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 261:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 220:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 447:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 249:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 153:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
						case 895:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 903:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
						case 710:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15);
						}
						case 544:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
						case 528:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16);
						}
						case 491:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17);
						}
						case 307:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
						case 276:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
						case 190:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18);
						}
						case 453:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19);
						}
						case 28:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20);
						}
						case 860:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21);
						}
						case 43:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22);
						}
						case 450:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23);
						}
						case 330:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24);
						}
						case 46:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25);
						}
						case 47:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26);
						}
					}
				}
				case 35:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 537:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
						case 62:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 286:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 716:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 699:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 634:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 356:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9);
						}
						case 263:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 214:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 746:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
						case 890:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 809:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
						case 590:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15);
						}
						case 484:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16);
						}
						case 225:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17);
						}
						case 191:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18);
						}
						case 164:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
						case 166:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19);
						}
						case 294:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20);
						}
						case 299:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21);
						}
						case 3:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22);
						}
						case 785:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23);
						}
						case 450:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24);
						}
						case 99:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
						case 107:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25);
						}
						case 170:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26);
						}
						case 25:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27);
						}
						case 158:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 28);
						}
					}
				}
				case 25:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 850:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 393:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 689:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 654:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
						case 557:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9);
						}
						case 521:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
						case 314:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 706:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
						case 616:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 505:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
						case 407:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 320:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
						case 760:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15);
						}
						case 370:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16);
						}
						case 348:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17);
						}
						case 238:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18);
						}
						case 166:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19);
						}
						case 731:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20);
						}
						case 42:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 240:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21);
						}
						case 169:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 96:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22);
						}
						case 205:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23);
						}
						case 95:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24);
						}
						case 135:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25);
						}
					}
				}
				case 14:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 902:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
						case 648:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
						case 496:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
						case 900:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 547:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 401:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 266:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 452:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 243:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9);
						}
						case 75:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 151:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 472:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
						case 22:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 202:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
					}
				}
				case 34:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 910:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 609:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9);
						}
						case 734:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 679:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
						case 482:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
						case 262:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
						case 61:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 867:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 39:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 804:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
						case 715:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
						case 697:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15);
						}
						case 630:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16);
						}
						case 549:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17);
						}
						case 403:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 386:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 448:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18);
						}
						case 368:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 329:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19);
						}
						case 33:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20);
						}
						case 141:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21);
						}
						case 755:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22);
						}
						case 100:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23);
						}
						case 366:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24);
						}
						case 148:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25);
						}
						case 199:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26);
						}
					}
				}
				case 17:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 898:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26);
						}
						case 433:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 812:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 651:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 402:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
						case 337:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
						case 310:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19);
						}
						case 284:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16);
						}
						case 188:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17);
						}
						case 742:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27);
						}
						case 908:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 28);
						}
						case 840:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 682:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9);
						}
						case 665:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25);
						}
						case 589:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21);
						}
						case 534:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
						case 498:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 98:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 29);
						}
						case 761:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 30);
						}
						case 38:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18);
						}
						case 372:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 246:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24);
						}
						case 748:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23);
						}
						case 343:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20);
						}
						case 32:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 3:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22);
						}
						case 157:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 871:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 31);
						}
						case 333:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15);
						}
						case 101:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
						case 17:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
					}
				}
				case 33:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 696:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22);
						}
						case 481:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9);
						}
						case 893:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23);
						}
						case 719:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 536:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 500:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
						case 213:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 752:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15);
						}
						case 847:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24);
						}
						case 649:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21);
						}
						case 627:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16);
						}
						case 423:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19);
						}
						case 354:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
						case 11:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
						case 728:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25);
						}
						case 250:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 28:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20);
						}
						case 102:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 782:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26);
						}
						case 15:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 141:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 175:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27);
						}
						case 442:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17);
						}
						case 365:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 5:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
						case 245:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18);
						}
						case 209:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
					}
				}
				case 23:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 810:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 915:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 846:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 800:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
						case 888:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 781:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
						case 872:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 753:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
					}
				}
				case 24:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 802:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 556:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
						case 916:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 851:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
						case 704:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9);
						}
						case 688:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 652:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
						case 436:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 672:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 615:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
						case 488:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
						case 392:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15);
						}
						case 362:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16);
						}
						case 281:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17);
						}
						case 193:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18);
						}
						case 725:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19);
						}
						case 441:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20);
						}
						case 37:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 70:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21);
						}
						case 15:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22);
						}
						case 169:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 778:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23);
						}
						case 90:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24);
						}
						case 333:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25);
						}
						case 175:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26);
						}
						case 17:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 93:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27);
						}
					}
				}
				case 19:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 359:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
						case 156:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 911:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15);
						}
						case 636:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
						case 516:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
						case 283:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 67:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
						case 182:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 669:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 593:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 20:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16);
						}
						case 228:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17);
						}
						case 759:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18);
						}
						case 849:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 717:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
						case 611:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 486:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9);
						}
						case 335:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 311:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19);
						}
						case 744:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20);
						}
						case 776:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21);
						}
						case 244:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22);
						}
						case 111:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23);
						}
						case 726:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24);
						}
						case 342:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25);
						}
						case 234:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26);
						}
						case 169:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27);
						}
						case 100:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 28);
						}
						case 175:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 29);
						}
						case 124:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 30);
						}
					}
				}
				case 26:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 542:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 676:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
						case 884:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
						case 508:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
						case 13:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 349:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 306:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 692:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 641:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9);
						}
						case 594:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 526:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 224:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
						case 267:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 159:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
						case 203:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15);
						}
						case 164:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16);
						}
						case 3:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17);
						}
						case 376:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18);
						}
						case 236:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19);
						}
						case 70:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20);
						}
						case 873:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21);
						}
						case 775:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22);
						}
						case 457:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23);
						}
						case 148:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24);
						}
						case 149:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25);
						}
						case 25:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26);
						}
						case 171:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27);
						}
					}
				}
				case 13:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 398:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 661:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 428:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 807:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
						case 647:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9);
						}
						case 546:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 494:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
						case 83:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 379:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 842:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15);
						}
						case 629:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 478:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 308:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16);
						}
						case 216:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
						case 264:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
						case 192:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17);
						}
						case 460:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
						case 297:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18);
						}
						case 790:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19);
						}
						case 237:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20);
						}
						case 235:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21);
						}
						case 76:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22);
						}
						case 101:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23);
						}
						case 119:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24);
						}
						case 241:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25);
						}
					}
				}
				case 10:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 919:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 604:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 723:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 626:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 429:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 154:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
						case 529:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 477:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15);
						}
						case 288:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 260:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 371:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
						case 194:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
						case 904:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16);
						}
						case 835:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17);
						}
						case 659:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9);
						}
						case 492:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
						case 218:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18);
						}
						case 178:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19);
						}
						case 869:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20);
						}
						case 244:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21);
						}
						case 92:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
						case 863:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22);
						}
						case 47:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23);
						}
						case 22:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24);
						}
					}
				}
				case 16:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 309:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 844:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 695:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 632:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9);
						}
						case 533:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 512:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 155:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
						case 336:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 255:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
						case 215:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 664:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15);
						}
						case 588:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16);
						}
						case 400:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17);
						}
						case 449:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18);
						}
						case 480:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19);
						}
						case 384:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20);
						}
						case 187:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21);
						}
						case 471:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22);
						}
						case 164:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23);
						}
						case 811:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
						case 176:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24);
						}
						case 793:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 167:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25);
						}
						case 730:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26);
						}
						case 780:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
						case 17:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27);
						}
						case 101:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 28);
						}
						case 16:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
						case 8:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 29);
						}
					}
				}
				case 39:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 897:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 487:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 750:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
						case 686:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 613:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
						case 519:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
						case 287:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 39:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9);
						}
						case 815:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
						case 702:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15);
						}
						case 598:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 553:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16);
						}
						case 186:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17);
						}
						case 98:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 28:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18);
						}
						case 247:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 864:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19);
						}
						case 378:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 363:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
						case 243:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20);
						}
						case 861:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21);
						}
						case 298:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22);
						}
						case 136:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23);
						}
						case 101:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24);
						}
					}
				}
				case 8:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 280:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 455:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
						case 913:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15);
						}
						case 845:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16);
						}
						case 690:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
						case 601:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
						case 541:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 9:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 886:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17);
						}
						case 583:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
						case 305:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
						case 758:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18);
						}
						case 727:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 779:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20);
						}
						case 708:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19);
						}
						case 674:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21);
						}
						case 507:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 73:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 197:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 33:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22);
						}
						case 10:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23);
						}
						case 375:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 740:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24);
						}
						case 794:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25);
						}
						case 444:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26);
						}
						case 46:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27);
						}
						case 100:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 28);
						}
						case 47:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 29);
						}
					}
				}
				case 9:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 887:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 917:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 803:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 662:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15);
						}
						case 475:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 395:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16);
						}
						case 279:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17);
						}
						case 51:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9);
						}
						case 736:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18);
						}
						case 756:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19);
						}
						case 446:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 344:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
						case 691:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 640:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20);
						}
						case 525:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21);
						}
						case 181:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22);
						}
						case 227:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23);
						}
						case 259:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24);
						}
						case 212:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 174:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25);
						}
						case 838:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26);
						}
						case 718:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 584:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27);
						}
						case 424:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 28);
						}
						case 84:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
						case 251:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 29);
						}
						case 788:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
						case 30:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 30);
						}
						case 451:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
						case 72:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
					}
				}
				case 40:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 624:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
						case 222:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 899:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
						case 503:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9);
						}
						case 670:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 554:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
						case 868:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 538:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
						case 60:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 361:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 304:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 743:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
						case 751:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15);
						}
						case 319:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 253:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 233:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16);
						}
						case 200:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17);
						}
						case 762:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18);
						}
						case 99:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19);
						}
						case 96:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20);
						}
						case 26:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21);
						}
					}
				}
				case 38:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 597:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
						case 391:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9);
						}
						case 312:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 165:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 612:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
						case 196:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 896:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15);
						}
						case 914:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16);
						}
						case 685:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17);
						}
						case 642:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 518:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
						case 502:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 406:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
						case 232:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 159:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18);
						}
						case 70:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 157:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19);
						}
						case 865:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20);
						}
						case 298:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21);
						}
						case 100:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 46:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22);
						}
						case 116:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
					}
				}
				case 11:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 511:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 493:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
						case 806:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 712:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 628:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
						case 438:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
						case 891:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 677:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 606:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9);
						}
						case 545:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 382:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 229:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
						case 195:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 739:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
						case 294:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15);
						}
						case 235:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16);
						}
						case 6:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17);
						}
						case 465:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18);
						}
						case 46:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19);
						}
						case 147:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20);
						}
						case 74:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21);
						}
						case 72:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22);
						}
						case 8:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23);
						}
					}
				}
				case 60:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 587:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
						case 548:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 497:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 430:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
						case 360:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 714:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 681:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
						case 644:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15);
						}
						case 301:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16);
						}
						case 257:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 792:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9);
						}
						case 445:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 326:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
						case 321:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17);
						}
						case 631:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 383:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18);
						}
						case 189:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19);
						}
						case 60:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 440:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
						case 254:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20);
						}
						case 663:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21);
						}
						case 217:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22);
						}
						case 235:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23);
						}
						case 862:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24);
						}
						case 77:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25);
						}
					}
				}
				case 7:
				{
					switch(GetEntProp(weapon, Prop_Send, "m_nFallbackPaintKit"))
					{
						case 801:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14);
						}
						case 707:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15);
						}
						case 675:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16);
						}
						case 639:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17);
						}
						case 600:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18);
						}
						case 524:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7);
						}
						case 474:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19);
						}
						case 380:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20);
						}
						case 316:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6);
						}
						case 302:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11);
						}
						case 180:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9);
						}
						case 724:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21);
						}
						case 506:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22);
						}
						case 490:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23);
						}
						case 394:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24);
						}
						case 282:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3);
						}
						case 14:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25);
						}
						case 44:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10);
						}
						case 456:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26);
						}
						case 340:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27);
						}
						case 885:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 28);
						}
						case 656:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5);
						}
						case 226:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12);
						}
						case 795:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1);
						}
						case 341:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8);
						}
						case 300:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 29);
						}
						case 836:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 30);
						}
						case 422:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 31);
						}
						case 172:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13);
						}
						case 745:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 32);
						}
						case 72:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2);
						}
						case 122:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 33);
						}
						case 170:
						{
							SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4);
						}
					}
				}
			}
		}
	}
	return Plugin_Continue;
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
			
	if(buttons & IN_ATTACK && IsWeaponSlotActive(client, CS_SLOT_GRENADE))
	{
		g_bPinPulled[client] = true;
	}
	else
	{
		CreateTimer(0.1, PinNotPulled, GetClientSerial(client));
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
				float clientEyes[3], targetEyes[3], targetEyes2[3], targetEyes3[3], targetEyesBase[3];
				GetClientEyePosition(client, clientEyes);
				int Ent = Client_GetClosest(clientEyes, client);
				
				float angle[3];
				
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
						GetClientAbsOrigin(Ent, targetEyesBase);
						GetClientAbsOrigin(Ent, targetEyes3);
						GetEntPropVector(Ent, Prop_Data, "m_angRotation", angle);
						GetClientEyePosition(Ent, targetEyes2);
						
						if((IsWeaponSlotActive(client, CS_SLOT_PRIMARY) && index != 40 && index != 11 && index != 38 && index != 9) || index == 63)
						{
							if(GetRandomInt(1,4) == 1)
							{
								targetEyes[2] = targetEyes2[2];
							}
							else
							{
								targetEyes[2] += GetRandomFloat(35.5, 50.5);
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
								targetEyes[2] += GetRandomFloat(35.5, 50.5);
							}
						}
						else if(buttons & IN_ATTACK && (index == 40 || index == 11 || index == 38))
						{
							if(GetRandomInt(1,4) == 1)
							{
								targetEyes[2] = targetEyes2[2];
							}
							else
							{
								targetEyes[2] += GetRandomFloat(35.5, 50.5);
							}
						}
						else if(buttons & IN_ATTACK && IsWeaponSlotActive(client, CS_SLOT_GRENADE))
						{
							targetEyes[2] += GetRandomFloat(35.5, 50.5);
							buttons &= ~IN_ATTACK; 
						}
						else if(buttons & IN_ATTACK && index == 9)
						{
							targetEyes[2] += 50.5;
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
	}

	return Plugin_Continue;
}

public Action PinNotPulled(Handle timer, any serial)
{
	int client = GetClientFromSerial(serial); // Validate the client serial
 
	if (client == 0) // The serial is no longer valid, the player must have disconnected
	{
		return Plugin_Stop;
	}
	
	if (IsValidClient(client) && IsFakeClient(client))
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
		}
	}	
}

public void OnPlayerSpawn(Handle event, const char[] name, bool dontBroadcast) 
{
	for (int i = 1; i <= MaxClients; i++)
	{
		int rnd = GetRandomInt(1,18);
		
		switch(rnd)
		{
			case 1:
			{
				g_iCoin[i] = GetRandomInt(874,978);
			}
			case 2:
			{
				g_iCoin[i] = GetRandomInt(1001,1010);
			}
			case 3:
			{
				g_iCoin[i] = GetRandomInt(1013,1022);
			}
			case 4:
			{
				g_iCoin[i] = GetRandomInt(1024,1026);
			}
			case 5:
			{
				g_iCoin[i] = GetRandomInt(1028,1060);
			}
			case 6:
			{
				g_iCoin[i] = GetRandomInt(1316,1318);
			}
			case 7:
			{
				g_iCoin[i] = GetRandomInt(1327,1329);
			}
			case 8:
			{
				g_iCoin[i] = GetRandomInt(1331,1332);
			}
			case 9:
			{
				g_iCoin[i] = GetRandomInt(1336,1344);
			}
			case 10:
			{
				g_iCoin[i] = GetRandomInt(1357,1363);
			}
			case 11:
			{
				g_iCoin[i] = GetRandomInt(1367,1372);
			}
			case 12:
			{
				g_iCoin[i] = GetRandomInt(1376,1381);
			}
			case 13:
			{
				g_iCoin[i] = GetRandomInt(4353,4356);
			}
			case 14:
			{
				g_iCoin[i] = GetRandomInt(6001,6033);
			}
			case 15:
			{
				g_iCoin[i] = GetRandomInt(4555,4558);
			}
			case 16:
			{
				g_iCoin[i] = GetRandomInt(4623,4626);
			}
			case 17:
			{
				g_iCoin[i] = GetRandomInt(4550,4553);
			}
			case 18:
			{
				g_iCoin[i] = GetRandomInt(4674,4679);
			}
		}
		
		if(IsValidClient(i) && IsFakeClient(i))
		{
			if (!i) return;
			CreateTimer(0.5, RFrame_CheckBuyZoneValue, GetClientSerial(i)); 
			
			if(GetRandomInt(1,100) >= 10)
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

public void OnWeaponEquipPost(int client, int weapon)
{
	int index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
	
	if(IsValidClient(client) && IsFakeClient(client))
	{		
		if(GetEntPropEnt(weapon, Prop_Send, "m_hPrevOwner") == -1)
		{
			if(GetRandomInt(1,100) <= 25)
			{
				switch(index)
				{
					case 61:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_usp_silencer") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_usp_silencer", PrecacheModel(g_sUSPModels[GetRandomInt(0, sizeof(g_sUSPModels) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_usp_silencer");
								
								int rndskin = GetRandomInt(1,25);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 657);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 796);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 705);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 637);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 817);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 504);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 236);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 313);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 277);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 653);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 339);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 221);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 290);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 183);
									}
									case 16:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 60);
									}
									case 17:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 318);
									}
									case 18:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 540);
									}
									case 19:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 489);
									}
									case 20:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 217);
									}
									case 21:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 364);
									}
									case 22:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 443);
									}
									case 23:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 454);
									}
									case 24:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 332);
									}
									case 25:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 25);
									}
								}
							}
						}
					}
					case 32:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_hkp2000") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_hkp2000", PrecacheModel(g_sP2000Models[GetRandomInt(0, sizeof(g_sP2000Models) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_hkp2000");
								
								int rndskin = GetRandomInt(1,24);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 71);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 211);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 389);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 327);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 700);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 667);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 591);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 184);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 894);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 485);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 246);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 635);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 550);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 515);
									}
									case 16:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 357);
									}
									case 17:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 338);
									}
									case 18:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 275);
									}
									case 19:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 32);
									}
									case 20:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 443);
									}
									case 21:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 346);
									}
									case 22:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 95);
									}
									case 23:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 21);
									}
									case 24:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 104);
									}
								}
							}
						}
					}
					case 4:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_glock") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_glock", PrecacheModel(g_sGlockModels[GetRandomInt(0, sizeof(g_sGlockModels) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_glock");
								
								int rndskin = GetRandomInt(1,30);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 532);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 381);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 159);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 479);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 399);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 38);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 2);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 694);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 789);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 680);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 808);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 367);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 918);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 230);
									}
									case 16:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 437);
									}
									case 17:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 713);
									}
									case 18:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 586);
									}
									case 19:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 353);
									}
									case 20:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 607);
									}
									case 21:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 48);
									}
									case 22:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 732);
									}
									case 23:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 623);
									}
									case 24:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 495);
									}
									case 25:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 278);
									}
									case 26:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 3);
									}
									case 27:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 799);
									}
									case 28:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 40);
									}
									case 29:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 28); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 293);
									}
									case 30:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 29); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 208);
									}
								}
							}
						}
					}
					case 36:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_p250") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_p250", PrecacheModel(g_sP250Models[GetRandomInt(0, sizeof(g_sP250Models) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_p250");
								
								int rndskin = GetRandomInt(1,37);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 162);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 678);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 99);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 668);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 168);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 777);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 373);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 551);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 271);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 749);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 404);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 388);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 258);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 295);
									}
									case 16:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 907);
									}
									case 17:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 125);
									}
									case 18:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 813);
									}
									case 19:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 501);
									}
									case 20:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 358);
									}
									case 21:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 848);
									}
									case 22:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 650);
									}
									case 23:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 592);
									}
									case 24:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 426);
									}
									case 25:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 230);
									}
									case 26:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 219);
									}
									case 27:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 786);
									}
									case 28:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 102);
									}
									case 29:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 28); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 164);
									}
									case 30:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 29); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 741);
									}
									case 31:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 30); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 466);
									}
									case 32:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 31); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 34);
									}
									case 33:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 32); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 207);
									}
									case 34:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 33); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 15);
									}
									case 35:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 34); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 467);
									}
									case 36:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 35); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 77);
									}
									case 37:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 36); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 27);
									}
								}
							}
						}
					}
					case 3:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_fiveseven") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_fiveseven", PrecacheModel(g_sFiveSevenModels[GetRandomInt(0, sizeof(g_sFiveSevenModels) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_fiveseven");
								
								int rndskin = GetRandomInt(1,29);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 252);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 605);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 510);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 254);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 530);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 387);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 585);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 223);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 464);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 427);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 265);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 151);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 660);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 377);
									}
									case 16:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 352);
									}
									case 17:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 78);
									}
									case 18:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 693);
									}
									case 19:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 274);
									}
									case 20:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 46);
									}
									case 21:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 44);
									}
									case 22:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 646);
									}
									case 23:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 3);
									}
									case 24:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 210);
									}
									case 25:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 837);
									}
									case 26:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 906);
									}
									case 27:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 729);
									}
									case 28:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 141);
									}
									case 29:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 28); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 784);
									}
								}
							}
						}
					}
					case 63:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_cz75a") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_cz75a", PrecacheModel(g_sCZ75Models[GetRandomInt(0, sizeof(g_sCZ75Models) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_cz75a");
								
								int rndskin = GetRandomInt(1,25);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 543);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 622);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 435);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 322);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 602);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 218);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 709);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 12);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 325);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 687);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 269);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 350);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 334);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 270);
									}
									case 16:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 643);
									}
									case 17:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 476);
									}
									case 18:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 268);
									}
									case 19:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 315);
									}
									case 20:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 859);
									}
									case 21:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 453);
									}
									case 22:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 297);
									}
									case 23:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 333);
									}
									case 24:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 366);
									}
									case 25:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 298);
									}
								}
							}
						}
					}
					case 30:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_tec9") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_tec9", PrecacheModel(g_sTec9Models[GetRandomInt(0, sizeof(g_sTec9Models) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_tec9");
								
								int rndskin = GetRandomInt(1,33);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 463);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 272);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 374);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 289);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 791);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 248);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 36);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 179);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 539);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 303);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 614);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 684);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 216);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 459);
									}
									case 16:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 520);
									}
									case 17:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 889);
									}
									case 18:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 839);
									}
									case 19:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 555);
									}
									case 20:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 905);
									}
									case 21:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 816);
									}
									case 22:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 722);
									}
									case 23:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 671);
									}
									case 24:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 599);
									}
									case 25:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 159);
									}
									case 26:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 733);
									}
									case 27:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 738);
									}
									case 28:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 439);
									}
									case 29:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 28); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 235);
									}
									case 30:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 29); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 17);
									}
									case 31:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 30); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 242);
									}
									case 32:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 31); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 2);
									}
									case 33:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 32); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 206);
									}
								}
							}
						}
					}
					case 1:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_deagle") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_deagle", PrecacheModel(g_sDeagleModels[GetRandomInt(0, sizeof(g_sDeagleModels) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_deagle");
								
								int rndskin = GetRandomInt(1,28);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 645);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 61);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 185);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 603);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 509);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 711);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 231);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 425);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 37);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 805);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 527);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 351);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 841);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 397);
									}
									case 16:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 232);
									}
									case 17:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 273);
									}
									case 18:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 757);
									}
									case 19:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 470);
									}
									case 20:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 469);
									}
									case 21:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 328);
									}
									case 22:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 347);
									}
									case 23:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 296);
									}
									case 24:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 237);
									}
									case 25:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 40);
									}
									case 26:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 468);
									}
									case 27:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 17);
									}
									case 28:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 90);
									}
								}
							}
						}
					}
					case 2:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_elite") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_elite", PrecacheModel(g_sEliteModels[GetRandomInt(0, sizeof(g_sEliteModels) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_elite");
								
								int rndskin = GetRandomInt(1,27);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 396);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 544);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 307);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 276);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 261);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 220);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 249);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 658);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 747);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 625);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 447);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 153);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 895);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 903);
									}
									case 16:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 710);
									}
									case 17:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 528);
									}
									case 18:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 491);
									}
									case 19:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 190);
									}
									case 20:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 453);
									}
									case 21:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 28);
									}
									case 22:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 860);
									}
									case 23:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 43);
									}
									case 24:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 450);
									}
									case 25:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 330);
									}
									case 26:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 46);
									}
									case 27:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 47);
									}
								}
							}
						}
					}
					case 35:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_nova") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_nova", PrecacheModel(g_sNovaModels[GetRandomInt(0, sizeof(g_sNovaModels) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_nova");
								
								int rndskin = GetRandomInt(1,29);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 716);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 99);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 164);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 537);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 634);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 62);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 286);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 699);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 356);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 263);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 214);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 746);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 890);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 809);
									}
									case 16:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 590);
									}
									case 17:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 484);
									}
									case 18:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 225);
									}
									case 19:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 191);
									}
									case 20:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 166);
									}
									case 21:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 294);
									}
									case 22:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 299);
									}
									case 23:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 3);
									}
									case 24:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 785);
									}
									case 25:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 450);
									}
									case 26:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 107);
									}
									case 27:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 170);
									}
									case 28:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 25);
									}
									case 29:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 28); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 158);
									}
								}
							}
						}
					}
					case 25:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_xm1014") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_xm1014", PrecacheModel(g_sXM1014Models[GetRandomInt(0, sizeof(g_sXM1014Models) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_xm1014");
								
								int rndskin = GetRandomInt(1,26);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 393);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 521);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 654);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 505);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 407);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 314);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 169);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 42);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 557);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 850);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 689);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 706);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 616);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 320);
									}
									case 16:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 760);
									}
									case 17:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 370);
									}
									case 18:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 348);
									}
									case 19:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 238);
									}
									case 20:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 166);
									}
									case 21:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 731);
									}
									case 22:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 240);
									}
									case 23:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 96);
									}
									case 24:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 205);
									}
									case 25:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 95);
									}
									case 26:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 135);
									}
								}
							}
						}
					}
					case 14:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_m249") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_m249", PrecacheModel(g_sM249Models[GetRandomInt(0, sizeof(g_sM249Models) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_m249");
								
								int rndskin = GetRandomInt(1,15);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 401);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 496);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 902);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 648);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 900);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 547);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 266);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 452);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 243);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 75);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 151);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 472);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 22);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 202);
									}
								}
							}
						}
					}
					case 34:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_mp9") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_mp9", PrecacheModel(g_sMP9Models[GetRandomInt(0, sizeof(g_sMP9Models) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_mp9");
								
								int rndskin = GetRandomInt(1,27);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 368);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 482);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 262);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 804);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 61);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 403);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 386);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 39);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 609);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 910);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 734);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 679);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 867);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 715);
									}
									case 16:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 697);
									}
									case 17:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 630);
									}
									case 18:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 549);
									}
									case 19:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 448);
									}
									case 20:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 329);
									}
									case 21:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 33);
									}
									case 22:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 141);
									}
									case 23:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 755);
									}
									case 24:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 100);
									}
									case 25:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 366);
									}
									case 26:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 148);
									}
									case 27:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 199);
									}
								}
							}
						}
					}
					case 17:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_mac10") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_mac10", PrecacheModel(g_sMAC10Models[GetRandomInt(0, sizeof(g_sMAC10Models) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_mac10");
								
								int rndskin = GetRandomInt(1,32);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 840);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 17);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 101);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 337);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 32);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 498);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 812);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 157);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 682);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 372);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 433);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 402);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 651);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 534);
									}
									case 16:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 333);
									}
									case 17:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 284);
									}
									case 18:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 188);
									}
									case 19:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 38);
									}
									case 20:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 310);
									}
									case 21:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 343);
									}
									case 22:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 589);
									}
									case 23:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 3);
									}
									case 24:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 748);
									}
									case 25:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 246);
									}
									case 26:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 665);
									}
									case 27:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 898);
									}
									case 28:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 742);
									}
									case 29:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 28); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 908);
									}
									case 30:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 29); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 98);
									}
									case 31:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 30); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 761);
									}
									case 32:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 31); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 871);
									}
								}
							}
						}
					}
					case 33:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_mp7") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_mp7", PrecacheModel(g_sMP7Models[GetRandomInt(0, sizeof(g_sMP7Models) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_mp7");
								
								int rndskin = GetRandomInt(1,28);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 102);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 354);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 500);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 11);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 719);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 141);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 365);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 213);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 481);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 536);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 15);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 209);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 250);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 5);
									}
									case 16:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 752);
									}
									case 17:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 627);
									}
									case 18:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 442);
									}
									case 19:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 245);
									}
									case 20:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 423);
									}
									case 21:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 28);
									}
									case 22:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 649);
									}
									case 23:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 696);
									}
									case 24:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 893);
									}
									case 25:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 847);
									}
									case 26:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 728);
									}
									case 27:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 782);
									}
									case 28:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 175);
									}
								}
							}
						}
					}
					case 23:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_mp5sd") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_mp5sd", PrecacheModel(g_sMP5Models[GetRandomInt(0, sizeof(g_sMP5Models) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_mp5sd");
								
								int rndskin = GetRandomInt(1,9);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 810);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 800);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 753);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 781);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 915);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 846);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 888);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 872);
									}
								}
							}
						}
					}
					case 24:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_ump45") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_ump45", PrecacheModel(g_sUMP45Models[GetRandomInt(0, sizeof(g_sUMP45Models) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_ump45");
								
								int rndskin = GetRandomInt(1,28);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 17);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 652);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 488);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 556);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 436);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 169);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 688);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 37);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 704);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 802);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 916);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 851);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 672);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 615);
									}
									case 16:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 392);
									}
									case 17:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 362);
									}
									case 18:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 281);
									}
									case 19:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 193);
									}
									case 20:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 725);
									}
									case 21:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 441);
									}
									case 22:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 70);
									}
									case 23:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 15);
									}
									case 24:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 778);
									}
									case 25:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 90);
									}
									case 26:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 333);
									}
									case 27:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 175);
									}
									case 28:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 93);
									}
								}
							}
						}
					}
					case 19:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_p90") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_p90", PrecacheModel(g_sP90Models[GetRandomInt(0, sizeof(g_sP90Models) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_p90");
								
								int rndskin = GetRandomInt(1,28);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 283);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 717);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 516);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 636);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 849);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 335);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 611);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 182);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 486);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 669);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 156);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 67);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 593);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 359);
									}
									case 16:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 911);
									}
									case 17:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 20);
									}
									case 18:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 228);
									}
									case 19:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 759);
									}
									case 20:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 311);
									}
									case 21:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 744);
									}
									case 22:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 776);
									}
									case 23:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 244);
									}
									case 24:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 111);
									}
									case 25:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 726);
									}
									case 26:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 342);
									}
									case 27:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 234);
									}
									case 28:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 169);
									}
									case 29:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 28); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 100);
									}
									case 30:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 29); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 175);
									}
									case 31:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 30); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 124);
									}
								}
							}
						}
					}
					case 26:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_bizon") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_bizon", PrecacheModel(g_sBizonModels[GetRandomInt(0, sizeof(g_sBizonModels) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_bizon");
								
								int rndskin = GetRandomInt(1,28);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 542);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 676);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 508);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 884);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 13);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 349);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 306);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 692);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 641);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 594);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 526);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 224);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 267);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 159);
									}
									case 16:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 203);
									}
									case 17:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 164);
									}
									case 18:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 3);
									}
									case 19:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 376);
									}
									case 20:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 236);
									}
									case 21:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 70);
									}
									case 22:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 873);
									}
									case 23:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 775);
									}
									case 24:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 457);
									}
									case 25:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 148);
									}
									case 26:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 149);
									}
									case 27:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 25);
									}
									case 28:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 171);
									}
								}
							}
						}
					}
					case 13:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_galilar") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_galilar", PrecacheModel(g_sGalilModels[GetRandomInt(0, sizeof(g_sGalilModels) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_galilar");
								
								int rndskin = GetRandomInt(1,26);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 661);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 494);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 807);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 264);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 478);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 83);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 546);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 428);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 647);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 398);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 379);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 216);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 629);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 460);
									}
									case 16:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 842);
									}
									case 17:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 308);
									}
									case 18:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 192);
									}
									case 19:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 297);
									}
									case 20:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 790);
									}
									case 21:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 237);
									}
									case 22:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 235);
									}
									case 23:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 76);
									}
									case 24:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 101);
									}
									case 25:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 119);
									}
									case 26:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 241);
									}
								}
							}
						}
					}
					case 10:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_famas") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_famas", PrecacheModel(g_sFamasModels[GetRandomInt(0, sizeof(g_sFamasModels) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_famas");
								
								int rndskin = GetRandomInt(1,25);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 529);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 492);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 371);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 194);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 288);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 604);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 260);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 626);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 659);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 723);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 429);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 92);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 919);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 154);
									}
									case 16:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 477);
									}
									case 17:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 904);
									}
									case 18:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 835);
									}
									case 19:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 218);
									}
									case 20:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 178);
									}
									case 21:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 869);
									}
									case 22:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 244);
									}
									case 23:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 863);
									}
									case 24:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 47);
									}
									case 25:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 22);
									}
								}
							}
						}
					}
					case 16:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_m4a1") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_m4a1", PrecacheModel(g_sM4A4Models[GetRandomInt(0, sizeof(g_sM4A4Models) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_m4a1");
								
								int rndskin = GetRandomInt(1,30);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 215);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 780);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 811);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 16);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 793);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 309);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 844);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 695);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 632);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 533);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 512);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 155);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 336);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 255);
									}
									case 16:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 664);
									}
									case 17:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 588);
									}
									case 18:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 400);
									}
									case 19:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 449);
									}
									case 20:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 480);
									}
									case 21:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 384);
									}
									case 22:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 187);
									}
									case 23:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 471);
									}
									case 24:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 164);
									}
									case 25:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 176);
									}
									case 26:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 167);
									}
									case 27:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 730);
									}
									case 28:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 17);
									}
									case 29:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 28); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 101);
									}
									case 30:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 29); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 8);
									}
								}
							}
						}
					}
					case 39:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_sg556") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_sg556", PrecacheModel(g_sSG556Models[GetRandomInt(0, sizeof(g_sSG556Models) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_sg556");
								
								int rndskin = GetRandomInt(1,25);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 98);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 613);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 363);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 519);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 686);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 378);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 247);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 487);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 39);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 598);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 897);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 750);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 287);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 815);
									}
									case 16:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 702);
									}
									case 17:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 553);
									}
									case 18:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 186);
									}
									case 19:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 28);
									}
									case 20:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 864);
									}
									case 21:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 243);
									}
									case 22:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 861);
									}
									case 23:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 298);
									}
									case 24:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 136);
									}
									case 25:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 101);
									}
								}
							}
						}
					}
					case 8:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_aug") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_aug", PrecacheModel(g_sAugModels[GetRandomInt(0, sizeof(g_sAugModels) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_aug");
								
								int rndskin = GetRandomInt(1,30);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 73);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 305);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 601);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 690);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 507);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 375);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 727);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 541);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 10);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 280);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 9);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 583);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 197);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 455);
									}
									case 16:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 913);
									}
									case 17:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 845);
									}
									case 18:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 886);
									}
									case 19:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 758);
									}
									case 20:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 708);
									}
									case 21:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 779);
									}
									case 22:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 674);
									}
									case 23:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 33);
									}
									case 24:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 110);
									}
									case 25:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 740);
									}
									case 26:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 794);
									}
									case 27:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 444);
									}
									case 28:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 46);
									}
									case 29:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 28); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 100);
									}
									case 30:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 29); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 47);
									}
								}
							}
						}
					}
					case 9:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_awp") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_awp", PrecacheModel(g_sAWPModels[GetRandomInt(0, sizeof(g_sAWPModels) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_awp");
								
								int rndskin = GetRandomInt(1,31);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 917);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 451);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 72);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 84);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 718);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 803);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 691);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 446);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 51);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 475);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 212);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 344);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 887);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 788);
									}
									case 16:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 662);
									}
									case 17:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 395);
									}
									case 18:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 279);
									}
									case 19:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 736);
									}
									case 20:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 756);
									}
									case 21:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 640);
									}
									case 22:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 525);
									}
									case 23:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 181);
									}
									case 24:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 227);
									}
									case 25:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 259);
									}
									case 26:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 174);
									}
									case 27:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 838);
									}
									case 28:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 584);
									}
									case 29:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 28); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 424);
									}
									case 30:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 29); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 251);
									}
									case 31:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 30); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 30);
									}
								}
							}
						}
					}
					case 40:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_ssg08") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_ssg08", PrecacheModel(g_sSSG08Models[GetRandomInt(0, sizeof(g_sSSG08Models) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_ssg08");
								
								int rndskin = GetRandomInt(1,22);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 304);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 538);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 554);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 624);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 319);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 670);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 60);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 222);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 503);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 253);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 361);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 899);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 868);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 743);
									}
									case 16:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 751);
									}
									case 17:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 233);
									}
									case 18:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 200);
									}
									case 19:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 762);
									}
									case 20:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 99);
									}
									case 21:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 96);
									}
									case 22:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 26);
									}
								}
							}
						}
					}
					case 38:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_scar20") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_scar20", PrecacheModel(g_sSCAR20Models[GetRandomInt(0, sizeof(g_sSCAR20Models) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_scar20");
								
								int rndskin = GetRandomInt(1,23);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 100);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 116);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 518);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 406);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 502);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 196);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 312);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 232);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 391);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 70);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 642);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 597);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 165);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 612);
									}
									case 16:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 896);
									}
									case 17:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 914);
									}
									case 18:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 685);
									}
									case 19:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 159);
									}
									case 20:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 157);
									}
									case 21:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 865);
									}
									case 22:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 298);
									}
									case 23:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 46);
									}
								}
							}
						}
					}
					case 11:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_g3sg1") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_g3sg1", PrecacheModel(g_sG3SG1Models[GetRandomInt(0, sizeof(g_sG3SG1Models) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_g3sg1");
								
								int rndskin = GetRandomInt(1,24);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 511);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 628);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 493);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 438);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 806);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 712);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 891);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 677);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 606);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 545);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 382);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 229);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 195);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 739);
									}
									case 16:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 294);
									}
									case 17:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 235);
									}
									case 18:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 6);
									}
									case 19:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 465);
									}
									case 20:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 46);
									}
									case 21:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 147);
									}
									case 22:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 74);
									}
									case 23:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 72);
									}
									case 24:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 8);
									}
								}
							}
						}
					}
					case 60:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_m4a1_silencer") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_m4a1_silencer", PrecacheModel(g_sM4A1SModels[GetRandomInt(0, sizeof(g_sM4A1SModels) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_m4a1_silencer");
								
								int rndskin = GetRandomInt(1,26);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 714);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 587);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 326);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 440);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 445);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 257);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 631);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 60);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 792);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 548);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 497);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 430);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 360);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 681);
									}
									case 16:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 644);
									}
									case 17:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 301);
									}
									case 18:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 321);
									}
									case 19:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 383);
									}
									case 20:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 189);
									}
									case 21:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 254);
									}
									case 22:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 663);
									}
									case 23:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 217);
									}
									case 24:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 235);
									}
									case 25:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 862);
									}
									case 26:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 77);
									}
								}
							}
						}
					}
					case 7:
					{
						if(FPVMI_GetClientViewModel(client, "weapon_ak47") == -1)
						{
							int slot = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY); 
							
							if (slot != -1)
							{
								RemovePlayerItem(client, slot);
								FPVMI_SetClientModel(client, "weapon_ak47", PrecacheModel(g_sAK47Models[GetRandomInt(0, sizeof(g_sAK47Models) - 1)])); // add custom view model to the player
								int entity = GivePlayerItem(client, "weapon_ak47");
								
								int rndskin = GetRandomInt(1,34);
								
								switch(rndskin)
								{
									case 1:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 0); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 0);
									}
									case 2:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 1); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 795);
									}
									case 3:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 2); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 72);
									}
									case 4:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 3); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 282);
									}
									case 5:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 4); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 170);
									}
									case 6:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 5); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 656);
									}
									case 7:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 6); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 316);
									}
									case 8:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 7); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 524);
									}
									case 9:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 8); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 341);
									}
									case 10:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 9); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 180);
									}
									case 11:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 10); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 44);
									}
									case 12:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 11); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 302);
									}
									case 13:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 12); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 226);
									}
									case 14:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 13); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 172);
									}
									case 15:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 14); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 801);
									}
									case 16:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 15); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 707);
									}
									case 17:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 16); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 675);
									}
									case 18:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 17); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 639);
									}
									case 19:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 18); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 600);
									}
									case 20:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 19); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 474);
									}
									case 21:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 20); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 380);
									}
									case 22:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 21); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 724);
									}
									case 23:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 22); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 506);
									}
									case 24:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 23); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 490);
									}
									case 25:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 24); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 394);
									}
									case 26:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 25); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 14);
									}
									case 27:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 26); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 456);
									}
									case 28:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 27); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 340);
									}
									case 29:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 28); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 885);
									}
									case 30:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 29); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 300);
									}
									case 31:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 30); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 836);
									}
									case 32:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 31); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 422);
									}
									case 33:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 32); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 745);
									}
									case 34:
									{
										SetEntProp(Weapon_GetViewModelIndex(client, -1), Prop_Send, "m_nSkin", 33); 
										SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", 122);
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

public Action OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	
	if(IsValidClient(client) && IsFakeClient(client))
	{
		if(FPVMI_GetClientViewModel(client, "weapon_glock") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_glock");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_usp_silencer") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_usp_silencer");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_hkp2000") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_hkp2000");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_p250") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_p250");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_cz75a") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_cz75a");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_deagle") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_deagle");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_revolver") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_revolver");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_fiveseven") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_fiveseven");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_tec9") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_tec9");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_elite") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_elite");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_nova") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_nova");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_sawedoff") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_sawedoff");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_mag7") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_mag7");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_xm1014") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_xm1014");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_m249") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_m249");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_negev") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_negev");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_mp9") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_mp9");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_mac10") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_mac10");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_mp7") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_mp7");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_mp5sd") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_mp5sd");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_ump45") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_ump45");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_p90") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_p90");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_bizon") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_bizon");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_galilar") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_galilar");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_famas") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_famas");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_ak47") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_ak47");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_m4a1") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_m4a1");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_m4a1_silencer") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_m4a1_silencer");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_sg556") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_sg556");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_aug") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_aug");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_scar20") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_scar20");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_g3sg1") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_g3sg1");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_ssg08") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_ssg08");
		}
		if(FPVMI_GetClientViewModel(client, "weapon_awp") != -1)
		{
			FPVMI_RemoveViewModelToClient(client, "weapon_awp");
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

	if((m_iAccount > 1500) && (m_iAccount < 3000) && iPrimary == -1 && (StrEqual(default_primary, "weapon_hkp2000") || StrEqual(default_primary, "weapon_usp_silencer") || StrEqual(default_primary, "weapon_glock")))
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
	else if(m_iAccount > 3000 || iPrimary != -1)
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
		SDKUnhook(client, SDKHook_WeaponEquipPost, OnWeaponEquipPost);
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

// Get model index and prevent server from crash
Weapon_GetViewModelIndex(client, sIndex)
{
    while ((sIndex = FindEntityByClassname2(sIndex, "predicted_viewmodel")) != -1)
    {
        new Owner = GetEntPropEnt(sIndex, Prop_Send, "m_hOwner");
        
        if (Owner != client)
            continue;
        
        return sIndex;
    }
    return -1;
}
// Get entity name
FindEntityByClassname2(sStartEnt, String:szClassname[])
{
    while (sStartEnt > -1 && !IsValidEntity(sStartEnt)) sStartEnt--;
    return FindEntityByClassname(sStartEnt, szClassname);
}

float g_flNextCommand[MAXPLAYERS + 1];
stock bool FakeClientCommandThrottled(int client, const char[] command)
{
	if(g_flNextCommand[client] > GetGameTime())
		return false;
	
	FakeClientCommand(client, command);
	
	g_flNextCommand[client] = GetGameTime() + 0.4;
	
	return true;
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
	int ActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	int index;
	char clantag[64];
	
	CS_GetClientClanTag(client, clantag, sizeof(clantag));
	
	if(ActiveWeapon != -1)
	{
		index = GetEntProp(ActiveWeapon, Prop_Send, "m_iItemDefinitionIndex");
	}
	
	for(int i = 1; i <= MaxClients ; i++)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i) || (i == client))
			continue;
		
		if(StrEqual(clantag, "HAVU")) //30th
		{
			if (!IsTargetInSightRange(client, i, 50.0))
				continue;	
		}
		else if(StrEqual(clantag, "TYLOO")) //29th
		{
			if (!IsTargetInSightRange(client, i, 60.0))
				continue;	
		}
		else if(StrEqual(clantag, "C9")) //28th
		{
			if (!IsTargetInSightRange(client, i, 70.0))
				continue;	
		}
		else if(StrEqual(clantag, "Spirit")) //27th
		{
			if (!IsTargetInSightRange(client, i, 80.0))
				continue;	
		}
		else if(StrEqual(clantag, "MIBR")) //26th
		{
			if (!IsTargetInSightRange(client, i, 90.0))
				continue;	
		}
		else if(StrEqual(clantag, "RNG")) //25th
		{
			if (!IsTargetInSightRange(client, i, 100.0))
				continue;	
		}
		else if(StrEqual(clantag, "forZe")) //24th
		{
			if (!IsTargetInSightRange(client, i, 110.0))
				continue;	
		}
		else if(StrEqual(clantag, "North")) //23rd
		{
			if (!IsTargetInSightRange(client, i, 120.0))
				continue;	
		}
		else if(StrEqual(clantag, "ENCE")) //22nd
		{
			if (!IsTargetInSightRange(client, i, 130.0))
				continue;	
		}
		else if(StrEqual(clantag, "OG")) //21st
		{
			if (!IsTargetInSightRange(client, i, 140.0))
				continue;	
		}
		else if(StrEqual(clantag, "VP")) //20th
		{
			if (!IsTargetInSightRange(client, i, 150.0))
				continue;	
		}
		else if(StrEqual(clantag, "c0ntact")) //19th
		{
			if (!IsTargetInSightRange(client, i, 160.0))
				continue;	
		}
		else if(StrEqual(clantag, "BIG")) //18th
		{
			if (!IsTargetInSightRange(client, i, 170.0))
				continue;	
		}
		else if(StrEqual(clantag, "coL")) //17th
		{
			if (!IsTargetInSightRange(client, i, 180.0))
				continue;	
		}
		else if(StrEqual(clantag, "GODSENT")) //16th
		{
			if (!IsTargetInSightRange(client, i, 190.0))
				continue;	
		}
		else if(StrEqual(clantag, "FPX")) //15th
		{
			if (!IsTargetInSightRange(client, i, 200.0))
				continue;	
		}
		else if(StrEqual(clantag, "Gen.G")) //14th
		{
			if (!IsTargetInSightRange(client, i, 210.0))
				continue;	
		}
		else if(StrEqual(clantag, "Lions")) //13th
		{
			if (!IsTargetInSightRange(client, i, 220.0))
				continue;	
		}
		else if(StrEqual(clantag, "NiP")) //12th
		{
			if (!IsTargetInSightRange(client, i, 230.0))
				continue;	
		}
		else if(StrEqual(clantag, "FURIA")) //11th
		{
			if (!IsTargetInSightRange(client, i, 240.0))
				continue;	
		}
		else if(StrEqual(clantag, "Vitality")) //10th
		{
			if (!IsTargetInSightRange(client, i, 250.0))
				continue;	
		}
		else if(StrEqual(clantag, "Thieves")) //9th
		{
			if (!IsTargetInSightRange(client, i, 260.0))
				continue;	
		}
		else if(StrEqual(clantag, "FaZe")) //8th
		{
			if (!IsTargetInSightRange(client, i, 270.0))
				continue;	
		}
		else if(StrEqual(clantag, "EG")) //7th
		{
			if (!IsTargetInSightRange(client, i, 280.0))
				continue;	
		}
		else if(StrEqual(clantag, "Liquid")) //6th
		{
			if (!IsTargetInSightRange(client, i, 290.0))
				continue;	
		}
		else if(StrEqual(clantag, "fnatic")) //5th
		{
			if (!IsTargetInSightRange(client, i, 300.0))
				continue;	
		}
		else if(StrEqual(clantag, "mouz")) //4th
		{
			if (!IsTargetInSightRange(client, i, 310.0))
				continue;	
		}
		else if(StrEqual(clantag, "G2")) //3rd
		{
			if (!IsTargetInSightRange(client, i, 320.0))
				continue;	
		}
		else if(StrEqual(clantag, "Astralis")) //2nd
		{
			if (!IsTargetInSightRange(client, i, 330.0))
				continue;	
		}
		else if(StrEqual(clantag, "Na´Vi")) //1st
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
			continue;
		
		GetEntPropVector(i, Prop_Data, "m_vecOrigin", vecOrigin_edict);
		GetClientEyePosition(i, vecOrigin_edict);
		if(LineGoesThroughSmoke(vecOrigin_center, vecOrigin_edict))
			continue;
		if(GetClientTeam(i) != GetClientTeam(client))
		{
			if(IsPointVisible(vecOrigin_center, vecOrigin_edict) && ClientViews(client, i))
			{
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
	if((StrEqual(botname, "shox")) || (StrEqual(botname, "ZywOo")) || (StrEqual(botname, "apEX")) || (StrEqual(botname, "RpK")) || (StrEqual(botname, "Misutaaa")))
	{
		CS_SetClientClanTag(client, "Vitality");
	}
	
	//BIG Players
	if((StrEqual(botname, "tiziaN")) || (StrEqual(botname, "syrsoN")) || (StrEqual(botname, "XANTARES")) || (StrEqual(botname, "tabseN")) || (StrEqual(botname, "k1to")))
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
	if((StrEqual(botname, "oskar")) || (StrEqual(botname, "dycha")) || (StrEqual(botname, "Spiidi")) || (StrEqual(botname, "faveN")) || (StrEqual(botname, "denis")))
	{
		CS_SetClientClanTag(client, "Sprout");
	}
	
	//FPX Players
	if((StrEqual(botname, "es3tag")) || (StrEqual(botname, "b0RUP")) || (StrEqual(botname, "Snappi")) || (StrEqual(botname, "cadiaN")) || (StrEqual(botname, "stavn")))
	{
		CS_SetClientClanTag(client, "FPX");
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
	if((StrEqual(botname, "Marcelious")) || (StrEqual(botname, "truth")) || (StrEqual(botname, "Grusarn")) || (StrEqual(botname, "akEz")) || (StrEqual(botname, "Radifaction")))
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
	
	//MVP.PK Players
	if((StrEqual(botname, "glow")) || (StrEqual(botname, "termi")) || (StrEqual(botname, "Rb")) || (StrEqual(botname, "k1Ng")) || (StrEqual(botname, "stax")))
	{
		CS_SetClientClanTag(client, "MVP.PK");
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
	
	//Defusekids Players
	if((StrEqual(botname, "HOLMES")) || (StrEqual(botname, "VANITY")) || (StrEqual(botname, "FASHR")) || (StrEqual(botname, "D0cC")) || (StrEqual(botname, "rilax")))
	{
		CS_SetClientClanTag(client, "Defusekids");
	}
	
	//GamerLegion Players
	if((StrEqual(botname, "dennis")) || (StrEqual(botname, "draken")) || (StrEqual(botname, "freddieb")) || (StrEqual(botname, "RuStY")) || (StrEqual(botname, "hampus")))
	{
		CS_SetClientClanTag(client, "GamerLegion");
	}
	
	//DIVIZON Players
	if((StrEqual(botname, "slunixx")) || (StrEqual(botname, "CEQU")) || (StrEqual(botname, "hyped")) || (StrEqual(botname, "merisinho")) || (StrEqual(botname, "ykyli")))
	{
		CS_SetClientClanTag(client, "DIVIZON");
	}
	
	//EURONICS Players
	if((StrEqual(botname, "red")) || (StrEqual(botname, "maRky")) || (StrEqual(botname, "PerX")) || (StrEqual(botname, "Seeeya")) || (StrEqual(botname, "pdy")))
	{
		CS_SetClientClanTag(client, "EURONICS");
	}
	
	//PANTHERS Players
	if((StrEqual(botname, "boostey")) || (StrEqual(botname, "HighKitty")) || (StrEqual(botname, "syncD")) || (StrEqual(botname, "BMLN")) || (StrEqual(botname, "Aika")))
	{
		CS_SetClientClanTag(client, "PANTHERS");
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
	if((StrEqual(botname, "birdfromsky")) || (StrEqual(botname, "Twinx")) || (StrEqual(botname, "maNkz")) || (StrEqual(botname, "thamlike")) || (StrEqual(botname, "Cabbi")))
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
	if((StrEqual(botname, "NOPEEj")) || (StrEqual(botname, "fox")) || (StrEqual(botname, "Cunha")) || (StrEqual(botname, "BLOODZ")) || (StrEqual(botname, "renatoohaxx")))
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
	if((StrEqual(botname, "BTN")) || (StrEqual(botname, "XELLOW")) || (StrEqual(botname, "SEMINTE")) || (StrEqual(botname, "iM")) || (StrEqual(botname, "starkiller")))
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
	if((StrEqual(botname, "Jabbi")) || (StrEqual(botname, "mertz")) || (StrEqual(botname, "Queenix")) || (StrEqual(botname, "TOBIZ")) || (StrEqual(botname, "Celrate")))
	{
		CS_SetClientClanTag(client, "Singularity");
	}
	
	//DETONA Players
	if((StrEqual(botname, "fP1")) || (StrEqual(botname, "tiburci0")) || (StrEqual(botname, "v$m")) || (StrEqual(botname, "Lucaozy")) || (StrEqual(botname, "Tuurtle")))
	{
		CS_SetClientClanTag(client, "DETONA");
	}
	
	//Infinity Players
	if((StrEqual(botname, "k1Nky")) || (StrEqual(botname, "malbsMd")) || (StrEqual(botname, "spamzzy")) || (StrEqual(botname, "sam_A")) || (StrEqual(botname, "Daveys")))
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
	if((StrEqual(botname, "dav1dddd")) || (StrEqual(botname, "Maluk3")) || (StrEqual(botname, "trk")) || (StrEqual(botname, "felps")) || (StrEqual(botname, "b4rtiN")))
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
	if((StrEqual(botname, "hue9ze")) || (StrEqual(botname, "addict")) || (StrEqual(botname, "cookie")) || (StrEqual(botname, "jeepy")) || (StrEqual(botname, "Wolfah")))
	{
		CS_SetClientClanTag(client, "BlackS");
	}
	
	//SKADE Players
	if((StrEqual(botname, "Rock1nG")) || (StrEqual(botname, "dennyslaw")) || (StrEqual(botname, "rafftu")) || (StrEqual(botname, "Rainwaker")) || (StrEqual(botname, "SPELLAN")))
	{
		CS_SetClientClanTag(client, "SKADE");
	}
	
	//Paradox Players
	if((StrEqual(botname, "ino")) || (StrEqual(botname, "1ukey")) || (StrEqual(botname, "ekul")) || (StrEqual(botname, "bedonka")) || (StrEqual(botname, "urbz")))
	{
		CS_SetClientClanTag(client, "Paradox");
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
	
	//Beyond Players
	if((StrEqual(botname, "MAIROLLS")) || (StrEqual(botname, "Olivia")) || (StrEqual(botname, "Kntz")) || (StrEqual(botname, "stk")) || (StrEqual(botname, "foxz")))
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
	if((StrEqual(botname, "proxyyb")) || (StrEqual(botname, "Real1ze")) || (StrEqual(botname, "BOROS")) || (StrEqual(botname, "aLvAr-")) || (StrEqual(botname, "Just1ce")))
	{
		CS_SetClientClanTag(client, "NASR");
	}
	
	//Portal Players
	if((StrEqual(botname, "traNz")) || (StrEqual(botname, "Ttyke")) || (StrEqual(botname, "DVDOV")) || (StrEqual(botname, "PokemoN")) || (StrEqual(botname, "Ebeee")))
	{
		CS_SetClientClanTag(client, "Portal");
	}
	
	//Brutals Players
	if((StrEqual(botname, "V3nom")) || (StrEqual(botname, "RiX")) || (StrEqual(botname, "Juventa")) || (StrEqual(botname, "astaRR")) || (StrEqual(botname, "spy")))
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
	
	//QB Players
	if((StrEqual(botname, "MadLife")) || (StrEqual(botname, "Electro")) || (StrEqual(botname, "nafan9")) || (StrEqual(botname, "Raider")) || (StrEqual(botname, "L4F")))
	{
		CS_SetClientClanTag(client, "QB");
	}
	
	//Energy Players
	if((StrEqual(botname, "Panda")) || (StrEqual(botname, "disTroiT")) || (StrEqual(botname, "Lichl0rd")) || (StrEqual(botname, "Damz")) || (StrEqual(botname, "kreatioN")))
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
	if((StrEqual(botname, "mezii")) || (StrEqual(botname, "Kray")) || (StrEqual(botname, "Adam9130")) || (StrEqual(botname, "L1NK")) || (StrEqual(botname, "Russ")))
	{
		CS_SetClientClanTag(client, "Vexed");
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
	if((StrEqual(botname, "HeiB")) || (StrEqual(botname, "zWin")) || (StrEqual(botname, "xccurate")) || (StrEqual(botname, "ImpressioN")) || (StrEqual(botname, "XigN")))
	{
		CS_SetClientClanTag(client, "BTRG");
	}
	
	//Furious Players
	if((StrEqual(botname, "nbl")) || (StrEqual(botname, "EYKER")) || (StrEqual(botname, "niox")) || (StrEqual(botname, "iKrystal")) || (StrEqual(botname, "pablek")))
	{
		CS_SetClientClanTag(client, "Furious");
	}
	
	//GTZ Players
	if((StrEqual(botname, "k0mpa")) || (StrEqual(botname, "StepA")) || (StrEqual(botname, "slaxx")) || (StrEqual(botname, "Jaepe")) || (StrEqual(botname, "rafaxF")))
	{
		CS_SetClientClanTag(client, "GTZ");
	}
	
	//Flames Players
	if((StrEqual(botname, "TeSeS")) || (StrEqual(botname, "farlig")) || (StrEqual(botname, "HooXi")) || (StrEqual(botname, "refrezh")) || (StrEqual(botname, "Nodios")))
	{
		CS_SetClientClanTag(client, "Flames");
	}
	
	//BPro Players
	if((StrEqual(botname, "FlashBack")) || (StrEqual(botname, "viltrex")) || (StrEqual(botname, "POP0V")) || (StrEqual(botname, "Krs7N")) || (StrEqual(botname, "milly")))
	{
		CS_SetClientClanTag(client, "BPro");
	}
	
	//Trident Players
	if((StrEqual(botname, "nope")) || (StrEqual(botname, "Quasar GT")) || (StrEqual(botname, "clutchyy")) || (StrEqual(botname, "JP")) || (StrEqual(botname, "Versa")))
	{
		CS_SetClientClanTag(client, "Trident");
	}
	
	//Syman Players
	if((StrEqual(botname, "neaLaN")) || (StrEqual(botname, "mou")) || (StrEqual(botname, "n0rb3r7")) || (StrEqual(botname, "kreaz")) || (StrEqual(botname, "Keoz")))
	{
		CS_SetClientClanTag(client, "Syman");
	}
	
	//wNv Players
	if((StrEqual(botname, "k4Mi")) || (StrEqual(botname, "FB")) || (StrEqual(botname, "Pure")) || (StrEqual(botname, "FairyRae")) || (StrEqual(botname, "kZy")))
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
	if((StrEqual(botname, "micalis")) || (StrEqual(botname, "jtr")) || (StrEqual(botname, "Koro")) || (StrEqual(botname, "Rackem")) || (StrEqual(botname, "vanilla")))
	{
		CS_SetClientClanTag(client, "Incept");
	}
	
	//UOL Players
	if((StrEqual(botname, "crisby")) || (StrEqual(botname, "kZyJL")) || (StrEqual(botname, "Andyy")) || (StrEqual(botname, "JDC")) || (StrEqual(botname, ".P4TriCK")))
	{
		CS_SetClientClanTag(client, "UOL");
	}
	
	//9INE Players
	if((StrEqual(botname, "nicoodoz")) || (StrEqual(botname, "phzy")) || (StrEqual(botname, "Djury")) || (StrEqual(botname, "aybeN")) || (StrEqual(botname, "MistFire")))
	{
		CS_SetClientClanTag(client, "9INE");
	}
	
	//Baecon Players
	if((StrEqual(botname, "brA")) || (StrEqual(botname, "Demonos")) || (StrEqual(botname, "tyko")) || (StrEqual(botname, "horvy")) || (StrEqual(botname, "KILLDREAM")))
	{
		CS_SetClientClanTag(client, "Baecon");
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
	
	//aL Players
	if((StrEqual(botname, "pounh")) || (StrEqual(botname, "FliP1")) || (StrEqual(botname, "Butters")) || (StrEqual(botname, "Remoy")) || (StrEqual(botname, "PALM1")))
	{
		CS_SetClientClanTag(client, "aL");
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
	if((StrEqual(botname, "ANGE1")) || (StrEqual(botname, "nukkye")) || (StrEqual(botname, "Flarich")) || (StrEqual(botname, "crush")) || (StrEqual(botname, "AiyvaN")))
	{
		CS_SetClientClanTag(client, "HR");
	}
	
	//Dice Players
	if((StrEqual(botname, "XpG")) || (StrEqual(botname, "nonick")) || (StrEqual(botname, "Kan4")) || (StrEqual(botname, "Polox")) || (StrEqual(botname, "DEVIL")))
	{
		CS_SetClientClanTag(client, "Dice");
	}
	
	//KPI Players
	if((StrEqual(botname, "xikii")) || (StrEqual(botname, "SunPayus")) || (StrEqual(botname, "meisoN")) || (StrEqual(botname, "donQ")) || (StrEqual(botname, "NaOw")))
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
	if((StrEqual(botname, "Kap3r")) || (StrEqual(botname, "SZPERO")) || (StrEqual(botname, "mynio")) || (StrEqual(botname, "morelz")) || (StrEqual(botname, "jedqr")))
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
	if((StrEqual(botname, "R0b3n")) || (StrEqual(botname, "zorte")) || (StrEqual(botname, "PASHANOJ")) || (StrEqual(botname, "Polt")) || (StrEqual(botname, "fenvicious")))
	{
		CS_SetClientClanTag(client, "Unique");
	}
	
	//Izako Players
	if((StrEqual(botname, "azizz")) || (StrEqual(botname, "ewrzyn")) || (StrEqual(botname, "EXUS")) || (StrEqual(botname, "pr3e")) || (StrEqual(botname, "TOAO")))
	{
		CS_SetClientClanTag(client, "Izako");
	}
	
	//ATK Players
	if((StrEqual(botname, "bLazE")) || (StrEqual(botname, "MisteM")) || (StrEqual(botname, "flexeeee")) || (StrEqual(botname, "Fadey")) || (StrEqual(botname, "TenZ")))
	{
		CS_SetClientClanTag(client, "ATK");
	}
	
	//Chaos Players
	if((StrEqual(botname, "cam")) || (StrEqual(botname, "vanity")) || (StrEqual(botname, "smooya")) || (StrEqual(botname, "steel_")) || (StrEqual(botname, "SicK")))
	{
		CS_SetClientClanTag(client, "Chaos");
	}
	
	//OneThree Players
	if((StrEqual(botname, "Ayeon")) || (StrEqual(botname, "lan")) || (StrEqual(botname, "captainMo")) || (StrEqual(botname, "DD")) || (StrEqual(botname, "Karsa")))
	{
		CS_SetClientClanTag(client, "OneThree");
	}
	
	//Lynn Players
	if((StrEqual(botname, "XG")) || (StrEqual(botname, "mitsuha")) || (StrEqual(botname, "Aree")) || (StrEqual(botname, "Yvonne")) || (StrEqual(botname, "XinKoiNg")))
	{
		CS_SetClientClanTag(client, "Lynn");
	}
	
	//Triumph Players
	if((StrEqual(botname, "Shakezullah")) || (StrEqual(botname, "Voltage")) || (StrEqual(botname, "Spongey")) || (StrEqual(botname, "Asuna")) || (StrEqual(botname, "Grim")))
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
	
	//Reason Players
	if((StrEqual(botname, "Frei")) || (StrEqual(botname, "Astroo")) || (StrEqual(botname, "jenko")) || (StrEqual(botname, "Puls3")) || (StrEqual(botname, "stan1ey")))
	{
		CS_SetClientClanTag(client, "Reason");
	}
	
	//Tricked Players
	if((StrEqual(botname, "kiR")) || (StrEqual(botname, "kwezz")) || (StrEqual(botname, "Luckyv1")) || (StrEqual(botname, "torben")) || (StrEqual(botname, "Toft")))
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
	
	//Dignitas Players
	if((StrEqual(botname, "GeT_RiGhT")) || (StrEqual(botname, "hallzerk")) || (StrEqual(botname, "f0rest")) || (StrEqual(botname, "friberg")) || (StrEqual(botname, "Xizt")))
	{
		CS_SetClientClanTag(client, "Dignitas");
	}
	
	//Skyfire Players
	if((StrEqual(botname, "Mizzy")) || (StrEqual(botname, "Gumpton")) || (StrEqual(botname, "affiNity")) || (StrEqual(botname, "LikiAU")) || (StrEqual(botname, "lato")))
	{
		CS_SetClientClanTag(client, "Skyfire");
	}
	
	//ZIGMA Players
	if((StrEqual(botname, "NIFFY")) || (StrEqual(botname, "Reality")) || (StrEqual(botname, "JUSTCAUSE")) || (StrEqual(botname, "PPOverdose")) || (StrEqual(botname, "RoLEX")))
	{
		CS_SetClientClanTag(client, "ZIGMA");
	}
	
	//Ambush Players
	if((StrEqual(botname, "Inzta")) || (StrEqual(botname, "Ryxxo")) || (StrEqual(botname, "zeq")) || (StrEqual(botname, "Lukki")) || (StrEqual(botname, "IceBerg")))
	{
		CS_SetClientClanTag(client, "Ambush");
	}
	
	//KOVA Players
	if((StrEqual(botname, "pietola")) || (StrEqual(botname, "Derkeps")) || (StrEqual(botname, "uli")) || (StrEqual(botname, "peku")) || (StrEqual(botname, "Twixie")))
	{
		CS_SetClientClanTag(client, "KOVA");
	}
	
	//AVANGAR Players
	if((StrEqual(botname, "TNDKingg")) || (StrEqual(botname, "howl")) || (StrEqual(botname, "hidenway")) || (StrEqual(botname, "kade0")) || (StrEqual(botname, "spellfull")))
	{
		CS_SetClientClanTag(client, "AVANGAR");
	}
	
	//CR4ZY Players
	if((StrEqual(botname, "dERZKIY")) || (StrEqual(botname, "Sergiz")) || (StrEqual(botname, "dOBRIY")) || (StrEqual(botname, "Psycho")) || (StrEqual(botname, "SENSEi")))
	{
		CS_SetClientClanTag(client, "CR4ZY");
	}
	
	//Redemption Players
	if((StrEqual(botname, "drg")) || (StrEqual(botname, "ALLE")) || (StrEqual(botname, "remix")) || (StrEqual(botname, "sutecas")) || (StrEqual(botname, "dok")))
	{
		CS_SetClientClanTag(client, "Redemption");
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
	
	if (StrEqual(sClan, "FPX"))
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
	
	if (StrEqual(sClan, "Tricked"))
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
	
	if (StrEqual(sClan, "Dignitas"))
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
	
	if (StrEqual(sClan, "RisingStars"))
	{
		g_iProfileRank[client] = 122;
	}
	
	if (StrEqual(sClan, "EHOME"))
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
	
	if (StrEqual(sClan, "Endpoint"))
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
	
	if (StrEqual(sClan, "Redemption"))
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
	
	if (StrEqual(sClan, "Reason"))
	{
		g_iProfileRank[client] = 163;
	}
	
	if (StrEqual(sClan, "aL"))
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
	
	if (StrEqual(sClan, "Skyfire"))
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
	
	if (StrEqual(sClan, "AVANGAR"))
	{
		g_iProfileRank[client] = 191;
	}
}