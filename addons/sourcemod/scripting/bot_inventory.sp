#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <cstrike>
#include <eItems>
#include <PTaH>
#include <bot_steamids>
#include <kento_rankme/rankme>
#include <smlib>
#include <modelch>

#define MAX_WEAPON_DEFS 256
#define MAX_GLOVE_DEFS 256
#define CUSTOM_KNIFE_START_INDEX 19 // Index into g_iKnifeDefIndex where custom knives begin (526, 527, 528)
#define CUSTOM_SKIN_DEF_INDEX 1300  // Skin def indices >= this are custom

bool g_bLateLoaded;
int g_iWeaponCount;
int g_iSkinCount;
int g_iGloveCount;
int g_iAgentCount;

int g_iMusicKit[MAXPLAYERS + 1];
int g_iCoin[MAXPLAYERS + 1];
bool g_bUseCustomPlayer[MAXPLAYERS + 1];
int g_iAgent[MAXPLAYERS + 1][4];
bool g_bUsePatch[MAXPLAYERS + 1];
bool g_bUsePatchCombo[MAXPLAYERS + 1];
int g_iRndPatchCombo[MAXPLAYERS + 1];
int g_iRndPatch[MAXPLAYERS + 1][4];
int g_iRndSamePatch[MAXPLAYERS + 1];

int g_iStoredKnife[MAXPLAYERS + 1];
int g_iSkinDefIndex[MAXPLAYERS + 1][1024];
float g_fWeaponSkinWear[MAXPLAYERS + 1][1024];
int g_iWeaponSkinSeed[MAXPLAYERS + 1][1024];
bool g_bUseStatTrak[MAXPLAYERS + 1][1024];
bool g_bUseSouvenir[MAXPLAYERS + 1][1024];
bool g_bUseSticker[MAXPLAYERS + 1][1024];
bool g_bUseStickerCombo[MAXPLAYERS + 1][1024];
int g_iRndStickerCombo[MAXPLAYERS + 1][1024];
int g_iRndSticker[MAXPLAYERS + 1][1024][4];
int g_iRndSameSticker[MAXPLAYERS + 1][1024];
int g_iItemIDLow[MAXPLAYERS + 1][1024];
int g_iItemIDHigh[MAXPLAYERS + 1][1024];

int g_iStoredGlove[MAXPLAYERS + 1];
int g_iGloveSkin[MAXPLAYERS + 1];
float g_fGloveWear[MAXPLAYERS + 1];
int g_iGloveSeed[MAXPLAYERS + 1];
int g_iGloveItemIDLow[MAXPLAYERS + 1];
int g_iGloveItemIDHigh[MAXPLAYERS + 1];

int g_iStatTrakKills[MAXPLAYERS + 1][1024];
bool g_bKnifeHasStatTrak[MAXPLAYERS + 1][1024];

char g_szModel[MAXPLAYERS+1][4][128];
char g_szVOPrefix[MAXPLAYERS+1][4][128];

ArrayList g_aWeaponSkins[MAX_WEAPON_DEFS] =  { null, ... };
ArrayList g_aGloveSkins[MAX_GLOVE_DEFS] =  { null, ... };
ArrayList g_aTAgents;
ArrayList g_aCTAgents;
ArrayList g_aMapWeapons;

int g_iKnifeDefIndex[] =  {
	500, 503, 505, 506, 507, 508, 509, 512, 514, 515, 516, 517, 518, 519, 520, 521, 522, 523, 525, 526, 527, 528
};

// Bitmask lookup for combo indices 1-14 (non-empty subsets of 4 slots)
// Bit 0 = slot 0, bit 1 = slot 1, bit 2 = slot 2, bit 3 = slot 3
// Index 15 = all slots (0xF), used for non-combo mode
int g_iComboSlotMask[] =  {
	0x0, // 0: unused
	0x1, // 1: slot 0
	0x3, // 2: slot 0,1
	0x5, // 3: slot 0,2
	0x9, // 4: slot 0,3
	0x7, // 5: slot 0,1,2
	0x2, // 6: slot 1
	0x6, // 7: slot 1,2
	0xA, // 8: slot 1,3
	0xD, // 9: slot 0,2,3
	0x4, // 10: slot 2
	0xC, // 11: slot 2,3
	0xE, // 12: slot 1,2,3
	0x8, // 13: slot 3
	0xB, // 14: slot 0,1,3
	0xF  // 15: all slots
};

Handle g_hSetRank;
Handle g_hForceUpdate;

int g_iNextIDLow = 2048;
int g_iNextIDHigh = 16384;

ConVar g_cvAgentChance;
ConVar g_cvStickerChance;
ConVar g_cvStickerComboChance;
ConVar g_cvStatTrakChance;
ConVar g_cvSouvenirChance;
ConVar g_cvPatchChance;
ConVar g_cvPatchComboChance;
ConVar g_cvGloveWearMin;
ConVar g_cvGloveWearMax;
ConVar g_cvCustomContent;

int g_iWeaponToRankMe[1024];

enum MedalCategory_t
{
	MEDAL_CATEGORY_NONE = -1, 
	MEDAL_CATEGORY_START = 0, 
	MEDAL_CATEGORY_TEAM_AND_OBJECTIVE = 0, 
	MEDAL_CATEGORY_COMBAT, 
	MEDAL_CATEGORY_WEAPON, 
	MEDAL_CATEGORY_MAP, 
	MEDAL_CATEGORY_ARSENAL, 
	MEDAL_CATEGORY_ACHIEVEMENTS_END, 
	MEDAL_CATEGORY_SEASON_COIN = 5, 
	MEDAL_CATEGORY_COUNT, 
};

public Plugin myinfo = 
{
	name = "BOT Inventory", 
	author = "manico", 
	description = "Gives BOTs items.", 
	version = "1.1.0", 
	url = "http://steamcommunity.com/id/manico001"
};

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] chError, int iErrMax)
{
	g_bLateLoaded = bLate;
	
	return APLRes_Success;
}

public void OnPluginStart()
{
	if (GetEngineVersion() != Engine_CSGO)
	{
		SetFailState("Only CS:GO servers are supported!");
		return;
	}
	
	if (PTaH_Version() < 101000)
	{
		char szBuf[16];
		PTaH_Version(szBuf, sizeof(szBuf));
		SetFailState("PTaH extension needs to be updated. (Installed Version: %s - Required Version: 1.1.0+) [ Download from: https://ptah.zizt.ru ]", szBuf);
		return;
	}
	
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Pre);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
	HookEvent("round_start", Event_OnRoundStart);
	
	g_cvAgentChance = CreateConVar("sm_botinv_agent_chance", "65.0", "Chance (0-100) that a bot uses a custom agent model.", _, true, 0.0, true, 100.0);
	g_cvStickerChance = CreateConVar("sm_botinv_sticker_chance", "40.0", "Chance (0-100) that a weapon has stickers.", _, true, 0.0, true, 100.0);
	g_cvStickerComboChance = CreateConVar("sm_botinv_sticker_combo_chance", "50.0", "Chance (0-100) for partial sticker combos vs full sets.", _, true, 0.0, true, 100.0);
	g_cvStatTrakChance = CreateConVar("sm_botinv_stattrak_chance", "30.0", "Chance (0-100) that an eligible weapon is StatTrak.", _, true, 0.0, true, 100.0);
	g_cvSouvenirChance = CreateConVar("sm_botinv_souvenir_chance", "30.0", "Chance (0-100) that an eligible weapon is Souvenir.", _, true, 0.0, true, 100.0);
	g_cvPatchChance = CreateConVar("sm_botinv_patch_chance", "40.0", "Chance (0-100) that an agent has patches.", _, true, 0.0, true, 100.0);
	g_cvPatchComboChance = CreateConVar("sm_botinv_patch_combo_chance", "50.0", "Chance (0-100) for partial patch combos vs full sets.", _, true, 0.0, true, 100.0);
	g_cvGloveWearMin = CreateConVar("sm_botinv_glove_wear_min", "0.06", "Minimum glove wear float.", _, true, 0.0, true, 1.0);
	g_cvGloveWearMax = CreateConVar("sm_botinv_glove_wear_max", "0.80", "Maximum glove wear float.", _, true, 0.0, true, 1.0);
	g_cvCustomContent = CreateConVar("sm_botinv_custom_content", "1", "Enable custom content (custom knives, skins with def index >= 1300).", _, true, 0.0, true, 1.0);
	
	AutoExecConfig(true, "bot_inventory");
	
	g_cvCustomContent.AddChangeHook(OnCustomContentChanged);
	
	PTaH(PTaH_GiveNamedItemPre, Hook, GiveNamedItemPre);
	PTaH(PTaH_GiveNamedItemPost, Hook, GiveNamedItemPost);
	
	ConVar cvGameType = FindConVar("game_type");
	ConVar cvGameMode = FindConVar("game_mode");
	
	if (cvGameType.IntValue == 1 && cvGameMode.IntValue == 2)
		PTaH(PTaH_WeaponCanUsePre, Hook, WeaponCanUsePre);
	
	HookUserMessage(GetUserMessageId("EndOfMatchAllPlayersData"), OnEndOfMatchAllPlayersData, true);
	
	GameData hGameData = new GameData("botinventory.games");
	
	// https://github.com/perilouswithadollarsign/cstrike15_src/blob/29e4c1fda9698d5cebcdaf1a0de4b829fa149bf8/game/server/cstrike15/cs_player.cpp#L16369-L16372
	// Changes the the rank of the player ( this case use is the coin )
	// void CCSPlayer::SetRank( MedalCategory_t category, MedalRank_t rank )
	StartPrepSDKCall(SDKCall_Player);
	
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CCSPlayer::SetRank"); // void
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain); // int MedalCategory_t category
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain); // int MedalRank_t rank
	
	if (!(g_hSetRank = EndPrepSDKCall()))
		SetFailState("Failed to get CCSPlayer::SetRank signature");
	
	StartPrepSDKCall(SDKCall_Player);
	
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Virtual, "CGameClient::UpdateAcknowledgedFramecount"); // void
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	
	if (!(g_hForceUpdate = EndPrepSDKCall()))
		SetFailState("Failed to get CGameClient::UpdateAcknowledgedFramecount signature");
	
	delete hGameData;
	
	if (g_bLateLoaded)
	{
		if (eItems_AreItemsSynced())
			eItems_OnItemsSynced();
		else if (!eItems_AreItemsSyncing())
			eItems_ReSync();
	}
}

public void eItems_OnItemsSynced()
{
	g_iWeaponCount = eItems_GetWeaponCount();
	g_iSkinCount = eItems_GetPaintsCount();
	g_iGloveCount = eItems_GetGlovesCount();
	g_iAgentCount = eItems_GetAgentsCount();
	
	BuildWeaponRankMeMap();
	BuildSkinsArrayList();
}

void BuildWeaponRankMeMap()
{
	for (int i = 0; i < sizeof(g_iWeaponToRankMe); i++)
		g_iWeaponToRankMe[i] = -1;
	
	// Knives all share RankMe index 0
	for (int i = 0; i < sizeof(g_iKnifeDefIndex); i++)
		g_iWeaponToRankMe[g_iKnifeDefIndex[i]] = 0;
	
	g_iWeaponToRankMe[4] = 1;    // HKP2000
	g_iWeaponToRankMe[32] = 2;   // P2000
	g_iWeaponToRankMe[61] = 3;   // USP-S
	g_iWeaponToRankMe[36] = 4;   // P250
	g_iWeaponToRankMe[1] = 5;    // Deagle
	g_iWeaponToRankMe[2] = 6;    // Dual Berettas
	g_iWeaponToRankMe[3] = 7;    // Five-SeveN
	g_iWeaponToRankMe[30] = 8;   // Tec-9
	g_iWeaponToRankMe[63] = 9;   // CZ75-Auto
	g_iWeaponToRankMe[64] = 10;  // R8 Revolver
	g_iWeaponToRankMe[35] = 11;  // Nova
	g_iWeaponToRankMe[25] = 12;  // XM1014
	g_iWeaponToRankMe[27] = 13;  // MAG-7
	g_iWeaponToRankMe[29] = 14;  // Sawed-Off
	g_iWeaponToRankMe[26] = 15;  // M249
	g_iWeaponToRankMe[17] = 16;  // MAC-10
	g_iWeaponToRankMe[34] = 17;  // MP9
	g_iWeaponToRankMe[33] = 18;  // MP7
	g_iWeaponToRankMe[24] = 19;  // UMP-45
	g_iWeaponToRankMe[19] = 20;  // P90
	g_iWeaponToRankMe[13] = 21;  // Galil AR
	g_iWeaponToRankMe[7] = 22;   // AK-47
	g_iWeaponToRankMe[38] = 23;  // SCAR-20
	g_iWeaponToRankMe[10] = 24;  // FAMAS
	g_iWeaponToRankMe[16] = 25;  // M4A4
	g_iWeaponToRankMe[60] = 26;  // M4A1-S
	g_iWeaponToRankMe[8] = 27;   // AUG
	g_iWeaponToRankMe[40] = 28;  // SSG 08
	g_iWeaponToRankMe[39] = 29;  // SG 553
	g_iWeaponToRankMe[9] = 30;   // AWP
	g_iWeaponToRankMe[11] = 31;  // G3SG1
	g_iWeaponToRankMe[14] = 32;  // Negev
	g_iWeaponToRankMe[28] = 33;  // Negev (alt) / PP-Bizon
}

void OnCustomContentChanged(ConVar cvConVar, const char[] szOldValue, const char[] szNewValue)
{
	if (eItems_AreItemsSynced())
		BuildSkinsArrayList();
}

public void BuildSkinsArrayList()
{
	for (int iWeapon = 0; iWeapon < g_iWeaponCount; iWeapon++)
	{
		if (g_aWeaponSkins[iWeapon] != null)
			delete g_aWeaponSkins[iWeapon];
		
		g_aWeaponSkins[iWeapon] = new ArrayList();
		
		int iWeaponDefIndex = eItems_GetWeaponDefIndexByWeaponNum(iWeapon);
		for (int iSkin = 0; iSkin < g_iSkinCount; iSkin++)
		{
			if (eItems_IsNativeSkin(iSkin, iWeapon, ITEMTYPE_WEAPON) && iWeaponDefIndex != 42 && iWeaponDefIndex != 59)
			{
				int iSkinDefIndex = eItems_GetSkinDefIndexBySkinNum(iSkin);
				if (iSkinDefIndex > 0 && iSkinDefIndex < 10000)
				{
					if (!g_cvCustomContent.BoolValue && iSkinDefIndex >= CUSTOM_SKIN_DEF_INDEX)
						continue;
					
					g_aWeaponSkins[iWeapon].Push(iSkinDefIndex);
				}
			}
		}
		
		g_aWeaponSkins[iWeapon].Push(0);
	}
	
	for (int iGlove = 0; iGlove < g_iGloveCount; iGlove++)
	{
		if (g_aGloveSkins[iGlove] != null)
			delete g_aGloveSkins[iGlove];
		
		g_aGloveSkins[iGlove] = new ArrayList();
		
		for (int iGloveSkin = 0; iGloveSkin < g_iSkinCount; iGloveSkin++)
		{
			if (eItems_IsSkinNumGloveApplicable(iGloveSkin) && eItems_IsNativeSkin(iGloveSkin, iGlove, ITEMTYPE_GLOVES))
			{
				int iGloveSkinDefIndex = eItems_GetSkinDefIndexBySkinNum(iGloveSkin);
				g_aGloveSkins[iGlove].Push(iGloveSkinDefIndex);
			}
		}
	}
	
	if (g_aTAgents != null)
		delete g_aTAgents;
	
	g_aTAgents = new ArrayList();
	
	if (g_aCTAgents != null)
		delete g_aCTAgents;
	
	g_aCTAgents = new ArrayList();
	
	for (int iAgent = 0; iAgent < g_iAgentCount; iAgent++)
	{
		if(eItems_GetAgentTeamByAgentNum(iAgent) == CS_TEAM_T)
		{
			int iAgentDefIndex = eItems_GetAgentDefIndexByAgentNum(iAgent);
			g_aTAgents.Push(iAgentDefIndex);
		}	
		else if(eItems_GetAgentTeamByAgentNum(iAgent) == CS_TEAM_CT)
		{
			int iAgentDefIndex = eItems_GetAgentDefIndexByAgentNum(iAgent);
			g_aCTAgents.Push(iAgentDefIndex);
		}
	}
}

Action OnEndOfMatchAllPlayersData(UserMsg iMsgId, Protobuf hMessage, const int[] iPlayers, int iPlayersNum, bool bReliable, bool bInit)
{
	if (bReliable)
	{
		int iDefIndex;
		int client;
		for (int i = 0; i < hMessage.GetRepeatedFieldCount("allplayerdata"); i++)
		{
			Protobuf pbPlayerData = hMessage.ReadRepeatedMessage("allplayerdata", i);
			
			client = pbPlayerData.ReadInt("entindex");
			
			if (IsValidClient(client))
			{
				int iXuid[2];
				
				iXuid[1] = 17825793;
				iXuid[0] = GetBotAccountID(client);
				
				pbPlayerData.SetBool("isbot", false);
				pbPlayerData.SetInt64("xuid", iXuid);
				
				for (int j = 0; j < pbPlayerData.GetRepeatedFieldCount("items"); j++)
				{
					Protobuf pbItem = pbPlayerData.ReadRepeatedMessage("items", j);
					iDefIndex = pbItem.ReadInt("defindex");
					
					if (iDefIndex == 5028 || iDefIndex == 5029)
					{
						pbItem.SetInt("defindex", g_iStoredGlove[client]);
						pbItem.SetInt("paintindex", g_iGloveSkin[client]);
						pbItem.SetInt("paintwear", view_as<int>(g_fGloveWear[client]));
						pbItem.SetInt("paintseed", g_iGloveSeed[client]);
						
						int itemID[2];
						itemID[0] = g_iGloveItemIDHigh[client];
						itemID[1] = g_iGloveItemIDLow[client];
						
						pbItem.SetInt64("itemid", itemID);
					}
					else if (iDefIndex < 4613)
					{
						if (IsPlayerAlive(client) && !(iDefIndex == 41 || iDefIndex == 42 || iDefIndex == 59))
						{
							pbItem.SetInt("paintindex", g_iSkinDefIndex[client][iDefIndex]);
							pbItem.SetInt("paintwear", view_as<int>(g_fWeaponSkinWear[client][iDefIndex]));
							pbItem.SetInt("paintseed", g_iWeaponSkinSeed[client][iDefIndex]);
						}
						else
						{
							pbItem.SetInt("defindex", g_iStoredKnife[client]);
							pbItem.SetInt("paintindex", g_iSkinDefIndex[client][g_iStoredKnife[client]]);
							pbItem.SetInt("paintwear", view_as<int>(g_fWeaponSkinWear[client][g_iStoredKnife[client]]));
							pbItem.SetInt("paintseed", g_iWeaponSkinSeed[client][g_iStoredKnife[client]]);
						}
						
						int itemID[2];
						itemID[0] = g_iItemIDLow[client][iDefIndex];
						itemID[1] = g_iItemIDHigh[client][iDefIndex];
						
						pbItem.SetInt64("itemid", itemID);
						
						Protobuf pbSticker0 = pbItem.AddMessage("stickers");
						Protobuf pbSticker1 = pbItem.AddMessage("stickers");
						Protobuf pbSticker2 = pbItem.AddMessage("stickers");
						Protobuf pbSticker3 = pbItem.AddMessage("stickers");
						
						if (g_bUseSticker[client][iDefIndex])
						{
							if (g_bUseStickerCombo[client][iDefIndex])
							{
								ApplyProtobufStickers(pbSticker0, pbSticker1, pbSticker2, pbSticker3,
									g_iRndStickerCombo[client][iDefIndex],
									g_iRndSticker[client][iDefIndex][0], g_iRndSticker[client][iDefIndex][1],
									g_iRndSticker[client][iDefIndex][2], g_iRndSticker[client][iDefIndex][3]);
							}
							else if (g_iRndStickerCombo[client][iDefIndex] == 1)
							{
								ApplyProtobufStickers(pbSticker0, pbSticker1, pbSticker2, pbSticker3, 15,
									g_iRndSticker[client][iDefIndex][0], g_iRndSticker[client][iDefIndex][1],
									g_iRndSticker[client][iDefIndex][2], g_iRndSticker[client][iDefIndex][3]);
							}
							else
							{
								int iSame = g_iRndSameSticker[client][iDefIndex];
								ApplyProtobufStickers(pbSticker0, pbSticker1, pbSticker2, pbSticker3, 15,
									iSame, iSame, iSame, iSame);
							}
						}
					}
					else
					{
						int itemID[2];
						itemID[0] = Math_GetRandomInt(1, 2048);
						itemID[1] = Math_GetRandomInt(1, 16384);
						
						pbItem.SetInt64("itemid", itemID);
						
						Protobuf pbPatch0 = pbItem.AddMessage("stickers");
						Protobuf pbPatch1 = pbItem.AddMessage("stickers");
						Protobuf pbPatch2 = pbItem.AddMessage("stickers");
						Protobuf pbPatch3 = pbItem.AddMessage("stickers");
						
						if (g_bUsePatch[client])
						{
							if (g_bUsePatchCombo[client])
							{
								ApplyProtobufStickers(pbPatch0, pbPatch1, pbPatch2, pbPatch3,
									g_iRndPatchCombo[client],
									g_iRndPatch[client][0], g_iRndPatch[client][1],
									g_iRndPatch[client][2], g_iRndPatch[client][3]);
							}
							else if (g_iRndPatchCombo[client] == 1)
							{
								ApplyProtobufStickers(pbPatch0, pbPatch1, pbPatch2, pbPatch3, 15,
									g_iRndPatch[client][0], g_iRndPatch[client][1],
									g_iRndPatch[client][2], g_iRndPatch[client][3]);
							}
							else
							{
								ApplyProtobufStickers(pbPatch0, pbPatch1, pbPatch2, pbPatch3, 15,
									g_iRndSamePatch[client], g_iRndSamePatch[client],
									g_iRndSamePatch[client], g_iRndSamePatch[client]);
							}
						}
					}
				}
			}
		}
	}
	return Plugin_Changed;
}

public void OnMapStart()
{
	if(g_aMapWeapons != null)
	{
		delete g_aMapWeapons;
		g_aMapWeapons = null;
	}

	g_aMapWeapons = new ArrayList();
	
	g_iNextIDLow = 2048;
	g_iNextIDHigh = 16384;
}

public void OnClientPostAdminCheck(int client)
{
	if (IsValidClient(client))
	{
		if (eItems_AreItemsSynced())
		{
			g_iMusicKit[client] = eItems_GetMusicKitDefIndexByMusicKitNum(Math_GetRandomInt(0, eItems_GetMusicKitsCount() - 1));
			g_iCoin[client] = Math_GetRandomInt(1, 2) == 1 ? eItems_GetCoinDefIndexByCoinNum(Math_GetRandomInt(0, eItems_GetCoinsCount() - 1)) : eItems_GetPinDefIndexByPinNum(Math_GetRandomInt(0, eItems_GetPinsCount() - 1));
			g_bUseCustomPlayer[client] = IsItMyChance(g_cvAgentChance.FloatValue);
			
			if (g_aTAgents.Length > 0 && g_aCTAgents.Length > 0)
			{
				int iRandomTAgent = Math_GetRandomInt(0, g_aTAgents.Length - 1);
				int iRandomCTAgent = Math_GetRandomInt(0, g_aCTAgents.Length - 1);
				
				g_iAgent[client][CS_TEAM_T] = g_aTAgents.Get(iRandomTAgent);
				g_iAgent[client][CS_TEAM_CT] = g_aCTAgents.Get(iRandomCTAgent);
			
				eItems_GetAgentPlayerModelByDefIndex(g_iAgent[client][CS_TEAM_CT], g_szModel[client][CS_TEAM_CT], 128);
				PrecacheModel(g_szModel[client][CS_TEAM_CT]);
				eItems_GetAgentVOPrefixByDefIndex(g_iAgent[client][CS_TEAM_CT], g_szVOPrefix[client][CS_TEAM_CT], 128);

				eItems_GetAgentPlayerModelByDefIndex(g_iAgent[client][CS_TEAM_T], g_szModel[client][CS_TEAM_T], 128);
				PrecacheModel(g_szModel[client][CS_TEAM_T]);
				eItems_GetAgentVOPrefixByDefIndex(g_iAgent[client][CS_TEAM_T], g_szVOPrefix[client][CS_TEAM_T], 128);
			}
			
			g_bUsePatch[client] = IsItMyChance(g_cvPatchChance.FloatValue);
			g_bUsePatchCombo[client] = IsItMyChance(g_cvPatchComboChance.FloatValue);
			g_iRndPatchCombo[client] = g_bUsePatchCombo[client] ? Math_GetRandomInt(1, 14) : Math_GetRandomInt(1, 2);
			
			g_iRndPatch[client][0] = eItems_GetPatchDefIndexByPatchNum(Math_GetRandomInt(0, eItems_GetPatchesCount() - 1));
			g_iRndPatch[client][1] = eItems_GetPatchDefIndexByPatchNum(Math_GetRandomInt(0, eItems_GetPatchesCount() - 1));
			g_iRndPatch[client][2] = eItems_GetPatchDefIndexByPatchNum(Math_GetRandomInt(0, eItems_GetPatchesCount() - 1));
			g_iRndPatch[client][3] = eItems_GetPatchDefIndexByPatchNum(Math_GetRandomInt(0, eItems_GetPatchesCount() - 1));
			
			g_iRndSamePatch[client] = eItems_GetPatchDefIndexByPatchNum(Math_GetRandomInt(0, eItems_GetPatchesCount() - 1));
			
			g_iStoredGlove[client] = eItems_GetGlovesDefIndexByGlovesNum(Math_GetRandomInt(0, g_iGloveCount - 1));
			g_iGloveItemIDLow[client] = g_iNextIDLow++;
			g_iGloveItemIDHigh[client] = g_iNextIDHigh++;
			
			int iGloveNum = eItems_GetGlovesNumByDefIndex(g_iStoredGlove[client]);
			int iRandomGloveSkin = Math_GetRandomInt(0, g_aGloveSkins[iGloveNum].Length - 1);
			
			if (iRandomGloveSkin != -1)
				g_iGloveSkin[client] = g_aGloveSkins[iGloveNum].Get(iRandomGloveSkin);
			
			g_fGloveWear[client] = Math_GetRandomFloat(g_cvGloveWearMin.FloatValue, g_cvGloveWearMax.FloatValue);
			g_iGloveSeed[client] = Math_GetRandomInt(1, 1000);
			
			int iKnifeCount = g_cvCustomContent.BoolValue ? sizeof(g_iKnifeDefIndex) : CUSTOM_KNIFE_START_INDEX;
			g_iStoredKnife[client] = g_iKnifeDefIndex[Math_GetRandomInt(0, iKnifeCount - 1)];
			
			for (int iWeapon = 0; iWeapon < g_iWeaponCount; iWeapon++)
			{
				int iWeaponDefIndex = eItems_GetWeaponDefIndexByWeaponNum(iWeapon);
				int iRandomWeaponSkin = Math_GetRandomInt(0, g_aWeaponSkins[iWeapon].Length - 1);
				if (iRandomWeaponSkin != -1)
					g_iSkinDefIndex[client][iWeaponDefIndex] = g_aWeaponSkins[iWeapon].Get(iRandomWeaponSkin);
				
				g_iItemIDHigh[client][iWeaponDefIndex] = g_iNextIDHigh++;
				g_iItemIDLow[client][iWeaponDefIndex] = g_iNextIDLow++;
				
				g_iWeaponSkinSeed[client][iWeaponDefIndex] = Math_GetRandomInt(1, 1000);
				g_bUseSticker[client][iWeaponDefIndex] = IsItMyChance(g_cvStickerChance.FloatValue);
				g_bUseStickerCombo[client][iWeaponDefIndex] = IsItMyChance(g_cvStickerComboChance.FloatValue);
				
				g_bUseStatTrak[client][iWeaponDefIndex] = false;
				g_bUseSouvenir[client][iWeaponDefIndex] = false;
				
				for (int iCrateNum = 0; iCrateNum < eItems_GetCratesCount(); iCrateNum++)
				{
					char szCrateName[128];
					int iCrateDefIndex = eItems_GetCrateDefIndexByCrateNum(iCrateNum);
					int iCrateItemsCount = eItems_GetCrateItemsCountByDefIndex(iCrateDefIndex);
					eItems_GetCrateDisplayNameByCrateNum(iCrateNum, szCrateName, sizeof(szCrateName));
					eItems_CrateItem eCrateItem;
					
					if(StrContains(szCrateName, "Case") != -1)
					{
						for(int iItem = 0; iItem < iCrateItemsCount; iItem++)
						{
							eItems_GetCrateItemByDefIndex(iCrateDefIndex, iItem, eCrateItem, sizeof(eItems_CrateItem));
							
							if((eCrateItem.SkinDefIndex == g_iSkinDefIndex[client][iWeaponDefIndex] && eCrateItem.WeaponDefIndex == iWeaponDefIndex) || eItems_IsDefIndexKnife(iWeaponDefIndex) || (g_cvCustomContent.BoolValue && g_iSkinDefIndex[client][iWeaponDefIndex] >= CUSTOM_SKIN_DEF_INDEX))
								g_bUseStatTrak[client][iWeaponDefIndex] = IsItMyChance(g_cvStatTrakChance.FloatValue);
						}
					}
					else if(StrContains(szCrateName, "Souvenir") != -1)
					{
						for(int iItem = 0; iItem < iCrateItemsCount; iItem++)
						{
							eItems_GetCrateItemByDefIndex(iCrateDefIndex, iItem, eCrateItem, sizeof(eItems_CrateItem));
							
							if((eCrateItem.SkinDefIndex == g_iSkinDefIndex[client][iWeaponDefIndex] && eCrateItem.WeaponDefIndex == iWeaponDefIndex))
								g_bUseSouvenir[client][iWeaponDefIndex] = IsItMyChance(g_cvSouvenirChance.FloatValue);
						}
					}
			    }
				
				g_iRndStickerCombo[client][iWeaponDefIndex] = g_bUseStickerCombo[client][iWeaponDefIndex] ? Math_GetRandomInt(1, 14) : Math_GetRandomInt(1, 2);
				
				g_iRndSticker[client][iWeaponDefIndex][0] = eItems_GetStickerDefIndexByStickerNum(Math_GetRandomInt(0, eItems_GetStickersCount() - 1));
				g_iRndSticker[client][iWeaponDefIndex][1] = eItems_GetStickerDefIndexByStickerNum(Math_GetRandomInt(0, eItems_GetStickersCount() - 1));
				g_iRndSticker[client][iWeaponDefIndex][2] = eItems_GetStickerDefIndexByStickerNum(Math_GetRandomInt(0, eItems_GetStickersCount() - 1));
				g_iRndSticker[client][iWeaponDefIndex][3] = eItems_GetStickerDefIndexByStickerNum(Math_GetRandomInt(0, eItems_GetStickersCount() - 1));
				
				g_iRndSameSticker[client][iWeaponDefIndex] = eItems_GetStickerDefIndexByStickerNum(Math_GetRandomInt(0, eItems_GetStickersCount() - 1));
				
				float fMinFloat = eItems_GetSkinWearRemapByDefIndex(g_iSkinDefIndex[client][iWeaponDefIndex], Min);
				float fMaxFloat = eItems_GetSkinWearRemapByDefIndex(g_iSkinDefIndex[client][iWeaponDefIndex], Max);
				
				g_fWeaponSkinWear[client][iWeaponDefIndex] = fMinFloat == 0.0 && fMaxFloat == 0.0 ? Math_GetRandomFloat(0.00, 1.00) : Math_GetRandomFloat(fMinFloat, fMaxFloat);
			}
		}
		
		SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
		SDKHook(client, SDKHook_WeaponEquip, SDK_OnWeaponEquip);
	}
}

Action GiveNamedItemPre(int client, char szClassname[64], CEconItemView &pItem, bool &bIgnoredCEconItemView, bool &bOriginIsNULL, float fOrigin[3])
{
	if (!IsValidClient(client))
		return Plugin_Continue;
	
	int iClientTeam = GetClientTeam(client);
	
	if (iClientTeam < CS_TEAM_T)
		return Plugin_Handled;
	
	int iDefIndex = eItems_GetWeaponDefIndexByClassName(szClassname);
	
	if (iDefIndex <= -1)
		return Plugin_Continue;
	
	if (!eItems_IsDefIndexKnife(iDefIndex))
		return Plugin_Continue;
	
	if (!eItems_IsDefIndexKnife(g_iStoredKnife[client]))
		return Plugin_Continue;
	
	eItems_GetWeaponClassNameByDefIndex(g_iStoredKnife[client], szClassname, sizeof(szClassname));
	bIgnoredCEconItemView = true;
	
	return Plugin_Changed;
}

void GiveNamedItemPost(int client, const char[] szClassname, const CEconItemView pItem, int iEntity, bool bOriginIsNULL, const float fOrigin[3])
{
	int iDefIndex = eItems_GetWeaponDefIndexByClassName(szClassname);
	
	if (iDefIndex <= -1)
		return;
	
	if (IsValidClient(client) && eItems_IsValidWeapon(iEntity))
	{
		int iPrevOwner = GetEntPropEnt(iEntity, Prop_Send, "m_hPrevOwner");
		if (iPrevOwner == -1)
		{
			if (eItems_IsDefIndexKnife(iDefIndex))
			{
				EquipPlayerWeapon(client, iEntity);
				SetEntProp(iEntity, Prop_Send, "m_iEntityQuality", 3);
			}
			SetWeaponProps(client, iEntity);
		}
	}
}

public Action OnTakeDamageAlive(int victim, int &attacker, int &iInflictor, float &fDamage, int &iDamageType, int &iWeapon, float fDamageForce[3], float fDamagePosition[3])
{
	if (float(GetClientHealth(victim)) - fDamage > 0.0)
		return Plugin_Continue;
	
	if (!(iDamageType & DMG_SLASH) && !(iDamageType & DMG_BULLET))
		return Plugin_Continue;
	
	if (!IsValidClient(attacker))
		return Plugin_Continue;
	
	if (!eItems_IsValidWeapon(iWeapon))
		return Plugin_Continue;
	
	int iDefIndex = eItems_GetWeaponDefIndexByWeapon(iWeapon);
	
	int iWeaponsReturn[42];
	
	RankMe_GetWeaponStats(attacker, iWeaponsReturn);
	
	UpdateStatTrakFromRankMe(attacker, iDefIndex, iWeaponsReturn);
	
	
	if (GetEntProp(iWeapon, Prop_Send, "m_iAccountID") == GetBotAccountID(attacker) && (GetEntProp(iWeapon, Prop_Send, "m_iEntityQuality") == 9 || g_bKnifeHasStatTrak[attacker][iDefIndex]))
	{
		CEconItemView pItem = PTaH_GetEconItemViewFromEconEntity(iWeapon);
		CAttributeList pDynamicAttributes = pItem.NetworkedDynamicAttributesForDemos;
		
		g_iStatTrakKills[attacker][iDefIndex]++;
		pDynamicAttributes.SetOrAddAttributeValue(80, g_iStatTrakKills[attacker][iDefIndex]);
		
		SDKCall(g_hForceUpdate, attacker, -1);
	}
	
	return Plugin_Continue;
}

Action WeaponCanUsePre(int client, int iWeapon, bool &bPickup)
{
	int iDefIndex = eItems_GetWeaponDefIndexByWeapon(iWeapon);
	if (eItems_IsDefIndexKnife(iDefIndex))
	{
		bPickup = true;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action SDK_OnWeaponEquip(int client, int iWeapon)
{
    if(!IsValidClient(client))
        return Plugin_Continue;

    if(!eItems_IsValidWeapon(iWeapon))
        return Plugin_Continue;

    int iPrevOwner = GetEntPropEnt(iWeapon, Prop_Send, "m_hPrevOwner");
    if(iPrevOwner > 0)
        return Plugin_Continue;

    if(IsMapWeapon(iWeapon, true))
    {
        DataPack hPack = new DataPack();
        hPack.WriteCell(GetClientUserId(client));
        hPack.WriteCell(EntIndexToEntRef(iWeapon));

        CreateTimer(0.1, Timer_MapWeaponEquipped, hPack);
    }
    return Plugin_Continue;
}

public Action Timer_MapWeaponEquipped(Handle hTimer, DataPack hPack)
{
	hPack.Reset();
	int client = GetClientOfUserId(hPack.ReadCell());
	int iWeapon = EntRefToEntIndex(hPack.ReadCell());
	delete hPack;

	if(client == 0 || !IsValidClient(client))
		return Plugin_Continue;
	if(iWeapon == INVALID_ENT_REFERENCE || !eItems_IsValidWeapon(iWeapon))
		return Plugin_Continue;

	int iWeaponSlot = eItems_GetWeaponSlotByWeapon(iWeapon);
	if (iWeaponSlot == CS_SLOT_C4)
		return Plugin_Continue;

	SetEntProp(iWeapon, Prop_Send, "m_OriginalOwnerXuidLow", GetBotAccountID(client));
	SetEntProp(iWeapon, Prop_Send, "m_OriginalOwnerXuidHigh", 17825793);
	
	SDKCall(g_hForceUpdate, client, -1);
	
	return Plugin_Stop;
}

public Action Event_OnRoundStart(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	char szWeaponClassname[64];
	for(int i = MaxClients; i < GetMaxEntities(); i++)
	{
		if(!IsValidEntity(i))
			continue;

		GetEntityClassname(i, szWeaponClassname, sizeof(szWeaponClassname));
		if((StrContains(szWeaponClassname, "weapon_")) == -1)
			continue;

		if(GetEntPropEnt(i, Prop_Send, "m_hOwnerEntity") != -1)
			continue;
		
		int iDefIndex;
		if((iDefIndex = eItems_GetWeaponDefIndexByClassName(szWeaponClassname)) == -1)
			continue;

		if(eItems_IsDefIndexKnife(iDefIndex))
			continue;

		g_aMapWeapons.Push(i);
	}

	return Plugin_Continue;
}

public void Event_PlayerSpawn(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(eEvent.GetInt("userid"));
	if (IsValidClient(client))
	{
		GivePlayerGloves(client);
		
		if (eItems_AreItemsSynced())
		{
			SetEntProp(client, Prop_Send, "m_unMusicID", g_iMusicKit[client]);
			
			SDKCall(g_hSetRank, client, MEDAL_CATEGORY_SEASON_COIN, g_iCoin[client]);
		}
	}
}

public Action Event_PlayerDeath(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(eEvent.GetInt("attacker"));
	if (IsValidClient(client))
	{
		char szWeaponName[128];
	
		eEvent.GetString("weapon", szWeaponName, sizeof(szWeaponName));
		
		int iActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		
		if(IsValidEntity(iActiveWeapon))
		{
			int iDefIndex = eItems_GetWeaponDefIndexByWeapon(iActiveWeapon);
			
			char szItemID[128];
			int iItemID[2];
			
			iItemID[0] = g_iItemIDLow[client][iDefIndex];
			iItemID[1] = g_iItemIDHigh[client][iDefIndex];
			
			Int64ToString(iItemID, szItemID, sizeof(szItemID));
			
			eEvent.SetString("weapon_itemid", szItemID);
		}
	}
	
	return Plugin_Continue;
}

public Action MdlCh_PlayerSpawn(int client, bool bCustom, char[] szModel, int iModelLength, char[] szVoPrefix, int iPrefixLength)
{	
	if (!IsValidClient(client) || !g_bUseCustomPlayer[client])
		return Plugin_Continue;
	
	if (GetClientTeam(client) == CS_TEAM_CT)
	{
		strcopy(szModel, iModelLength, g_szModel[client][CS_TEAM_CT]);
		strcopy(szVoPrefix, iPrefixLength, g_szVOPrefix[client][CS_TEAM_CT]);
			
		if (g_bUsePatch[client])
		{
			if (g_bUsePatchCombo[client])
			{
				ApplyPatches(client, g_iRndPatchCombo[client],
					g_iRndPatch[client][0], g_iRndPatch[client][1],
					g_iRndPatch[client][2], g_iRndPatch[client][3]);
			}
			else if (g_iRndPatchCombo[client] == 1)
			{
				ApplyPatches(client, 15,
					g_iRndPatch[client][0], g_iRndPatch[client][1],
					g_iRndPatch[client][2], g_iRndPatch[client][3]);
			}
			else
			{
				ApplyPatches(client, 15,
					g_iRndSamePatch[client], g_iRndSamePatch[client],
					g_iRndSamePatch[client], g_iRndSamePatch[client]);
			}
		}
	}
	else if(GetClientTeam(client) == CS_TEAM_T)
	{
		strcopy(szModel, iModelLength, g_szModel[client][CS_TEAM_T]);
		strcopy(szVoPrefix, iPrefixLength, g_szVOPrefix[client][CS_TEAM_T]);
			
		if (g_bUsePatch[client])
		{
			if (g_bUsePatchCombo[client])
			{
				ApplyPatches(client, g_iRndPatchCombo[client],
					g_iRndPatch[client][0], g_iRndPatch[client][1],
					g_iRndPatch[client][2], g_iRndPatch[client][3]);
			}
			else if (g_iRndPatchCombo[client] == 1)
			{
				ApplyPatches(client, 15,
					g_iRndPatch[client][0], g_iRndPatch[client][1],
					g_iRndPatch[client][2], g_iRndPatch[client][3]);
			}
			else
			{
				ApplyPatches(client, 15,
					g_iRndSamePatch[client], g_iRndSamePatch[client],
					g_iRndSamePatch[client], g_iRndSamePatch[client]);
			}
		}	
	}

	return Plugin_Changed;
}

void SetWeaponProps(int client, int iEntity)
{
	int iDefIndex = eItems_GetWeaponDefIndexByWeapon(iEntity);
	
	if (iDefIndex > -1)
	{
		SetEntProp(iEntity, Prop_Send, "m_iItemIDLow", g_iItemIDLow[client][iDefIndex]);
		SetEntProp(iEntity, Prop_Send, "m_iItemIDHigh", g_iItemIDHigh[client][iDefIndex]);
		SetEntProp(iEntity, Prop_Send, "m_OriginalOwnerXuidLow", GetBotAccountID(client));
		SetEntProp(iEntity, Prop_Send, "m_OriginalOwnerXuidHigh", 17825793);
		
		CEconItemView pItem = PTaH_GetEconItemViewFromEconEntity(iEntity);
		CAttributeList pDynamicAttributes = pItem.NetworkedDynamicAttributesForDemos;
		
		pDynamicAttributes.SetOrAddAttributeValue(6, float(g_iSkinDefIndex[client][iDefIndex]));
		pDynamicAttributes.SetOrAddAttributeValue(7, float(g_iWeaponSkinSeed[client][iDefIndex]));
		pDynamicAttributes.SetOrAddAttributeValue(8, g_fWeaponSkinWear[client][iDefIndex]);
		
		int iWeaponsReturn[42];
		
		RankMe_GetWeaponStats(client, iWeaponsReturn);
		
		UpdateStatTrakFromRankMe(client, iDefIndex, iWeaponsReturn);
		
		if (eItems_IsDefIndexKnife(iDefIndex))
		{
			if (g_bUseStatTrak[client][iDefIndex])
			{
				pDynamicAttributes.SetOrAddAttributeValue(80, g_iStatTrakKills[client][iDefIndex]);
				pDynamicAttributes.SetOrAddAttributeValue(81, 0);
				
				g_bKnifeHasStatTrak[client][iDefIndex] = true;
			}
		}
		else
		{
			if (g_bUseStatTrak[client][iDefIndex])
			{
				pDynamicAttributes.SetOrAddAttributeValue(80, g_iStatTrakKills[client][iDefIndex]);
				pDynamicAttributes.SetOrAddAttributeValue(81, 0);
				
				SetEntProp(iEntity, Prop_Send, "m_iEntityQuality", 9);
			}
			
			if (g_bUseSouvenir[client][iDefIndex])
			{
				pDynamicAttributes.RemoveAttributeByDefIndex(80);
				pDynamicAttributes.RemoveAttributeByDefIndex(81);
				SetEntProp(iEntity, Prop_Send, "m_iEntityQuality", 12);
			}
		}
		
		if (g_bUseSticker[client][iDefIndex])
		{
			if (g_bUseStickerCombo[client][iDefIndex])
			{
				ApplyStickerAttributes(pDynamicAttributes, g_iRndStickerCombo[client][iDefIndex],
					g_iRndSticker[client][iDefIndex][0], g_iRndSticker[client][iDefIndex][1],
					g_iRndSticker[client][iDefIndex][2], g_iRndSticker[client][iDefIndex][3]);
			}
			else if (g_iRndStickerCombo[client][iDefIndex] == 1)
			{
				ApplyStickerAttributes(pDynamicAttributes, 15,
					g_iRndSticker[client][iDefIndex][0], g_iRndSticker[client][iDefIndex][1],
					g_iRndSticker[client][iDefIndex][2], g_iRndSticker[client][iDefIndex][3]);
			}
			else
			{
				int iSame = g_iRndSameSticker[client][iDefIndex];
				ApplyStickerAttributes(pDynamicAttributes, 15,
					iSame, iSame, iSame, iSame);
			}
		}
		
		SetEntProp(iEntity, Prop_Send, "m_iAccountID", GetBotAccountID(client));
		SetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity", client);
		SetEntPropEnt(iEntity, Prop_Send, "m_hPrevOwner", -1);
		
		SDKCall(g_hForceUpdate, client, -1);
	}
}

public void GivePlayerGloves(int client)
{
	int iEntity = GetEntPropEnt(client, Prop_Send, "m_hMyWearables");
	if (iEntity != -1)
		AcceptEntityInput(iEntity, "KillHierarchy");
		
	iEntity = CreateEntityByName("wearable_item");
	if (iEntity != -1 && eItems_AreItemsSynced())
	{
		CEconItemView pItem = PTaH_GetEconItemViewFromEconEntity(iEntity);
		CAttributeList pDynamicAttributes = pItem.NetworkedDynamicAttributesForDemos;
		
		SetEntProp(iEntity, Prop_Send, "m_iItemIDLow", g_iGloveItemIDLow[client]);
		SetEntProp(iEntity, Prop_Send, "m_iItemIDHigh", g_iGloveItemIDHigh[client]);
		
		SetEntProp(iEntity, Prop_Send, "m_iItemDefinitionIndex", g_iStoredGlove[client]);
		
		pDynamicAttributes.SetOrAddAttributeValue(6, float(g_iGloveSkin[client]));
		pDynamicAttributes.SetOrAddAttributeValue(7, float(g_iGloveSeed[client]));
		pDynamicAttributes.SetOrAddAttributeValue(8, g_fGloveWear[client]);
		
		SetEntPropEnt(iEntity, Prop_Data, "m_hOwnerEntity", client);
		SetEntPropEnt(iEntity, Prop_Data, "m_hParent", client);
		SetEntPropEnt(iEntity, Prop_Data, "m_hMoveParent", client);
		SetEntProp(iEntity, Prop_Send, "m_bInitialized", 1);
		
		DispatchSpawn(iEntity);
		
		SetEntPropEnt(client, Prop_Send, "m_hMyWearables", iEntity);
		SetEntProp(client, Prop_Send, "m_nBody", 1);
		
		SDKCall(g_hForceUpdate, client, -1);
	}
}

public void OnClientDisconnect(int client)
{
	if (IsValidClient(client))
	{
		SDKUnhook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
		SDKUnhook(client, SDKHook_WeaponEquip, SDK_OnWeaponEquip);
	}
	
	ResetClientData(client);
}

void ResetClientData(int client)
{
	g_iMusicKit[client] = 0;
	g_iCoin[client] = 0;
	g_bUseCustomPlayer[client] = false;
	g_bUsePatch[client] = false;
	g_bUsePatchCombo[client] = false;
	g_iRndPatchCombo[client] = 0;
	g_iRndSamePatch[client] = 0;
	g_iStoredKnife[client] = 0;
	g_iStoredGlove[client] = 0;
	g_iGloveSkin[client] = 0;
	g_fGloveWear[client] = 0.0;
	g_iGloveSeed[client] = 0;
	g_iGloveItemIDLow[client] = 0;
	g_iGloveItemIDHigh[client] = 0;
	
	for (int i = 0; i < 4; i++)
	{
		g_iAgent[client][i] = 0;
		g_iRndPatch[client][i] = 0;
		g_szModel[client][i][0] = '\0';
		g_szVOPrefix[client][i][0] = '\0';
	}
	
	for (int i = 0; i < 1024; i++)
	{
		g_iSkinDefIndex[client][i] = 0;
		g_fWeaponSkinWear[client][i] = 0.0;
		g_iWeaponSkinSeed[client][i] = 0;
		g_bUseStatTrak[client][i] = false;
		g_bUseSouvenir[client][i] = false;
		g_bUseSticker[client][i] = false;
		g_bUseStickerCombo[client][i] = false;
		g_iRndStickerCombo[client][i] = 0;
		g_iRndSameSticker[client][i] = 0;
		g_iItemIDLow[client][i] = 0;
		g_iItemIDHigh[client][i] = 0;
		g_iStatTrakKills[client][i] = 0;
		g_bKnifeHasStatTrak[client][i] = false;
		
		for (int j = 0; j < 4; j++)
			g_iRndSticker[client][i][j] = 0;
	}
}

public void OnPluginEnd()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
			OnClientDisconnect(i);
	}
}

stock void UpdateStatTrakFromRankMe(int client, int iDefIndex, int[] iWeaponsReturn)
{
	if (iDefIndex >= 0 && iDefIndex < sizeof(g_iWeaponToRankMe) && g_iWeaponToRankMe[iDefIndex] != -1)
		g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[g_iWeaponToRankMe[iDefIndex]];
}

stock bool IsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && IsFakeClient(client) && !IsClientSourceTV(client);
}

stock bool IsItMyChance(float fChance = 0.0)
{
	float flRand = Math_GetRandomFloat(0.0, 100.0);
	if(fChance <= 0.0)
		return false;
	return flRand <= fChance;
}

stock void ApplyProtobufStickers(Protobuf pb0, Protobuf pb1, Protobuf pb2, Protobuf pb3, int iComboIndex, int s0, int s1, int s2, int s3)
{
	int iMask = g_iComboSlotMask[iComboIndex];
	if (iMask & 0x1) { pb0.SetInt("slot", 0); pb0.SetInt("sticker_id", s0); }
	if (iMask & 0x2) { pb1.SetInt("slot", 1); pb1.SetInt("sticker_id", s1); }
	if (iMask & 0x4) { pb2.SetInt("slot", 2); pb2.SetInt("sticker_id", s2); }
	if (iMask & 0x8) { pb3.SetInt("slot", 3); pb3.SetInt("sticker_id", s3); }
}

stock void ApplyStickerAttributes(CAttributeList pAttribs, int iComboIndex, int s0, int s1, int s2, int s3)
{
	int iMask = g_iComboSlotMask[iComboIndex];
	if (iMask & 0x1) pAttribs.SetOrAddAttributeValue(113, s0);
	if (iMask & 0x2) pAttribs.SetOrAddAttributeValue(117, s1);
	if (iMask & 0x4) pAttribs.SetOrAddAttributeValue(121, s2);
	if (iMask & 0x8) pAttribs.SetOrAddAttributeValue(125, s3);
}

stock void ApplyPatches(int client, int iComboIndex, int p0, int p1, int p2, int p3)
{
	int iMask = g_iComboSlotMask[iComboIndex];
	if (iMask & 0x1) SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", p0, 4, 0);
	if (iMask & 0x2) SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", p1, 4, 1);
	if (iMask & 0x4) SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", p2, 4, 2);
	if (iMask & 0x8) SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", p3, 4, 3);
}

stock bool IsMapWeapon(int iWeapon, bool bRemove = false)
{
	if(g_aMapWeapons == null)
		return false;
		
	for(int i = 0; i < g_aMapWeapons.Length; i++)
	{
		if(g_aMapWeapons.Get(i) != iWeapon)
			continue;

		if(bRemove)
			g_aMapWeapons.Erase(i);
			
		return true;
	}
	return false;
}