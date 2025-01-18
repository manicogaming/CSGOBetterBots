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

ArrayList g_ArrayWeapons[128] =  { null, ... };
ArrayList g_ArrayGloves[128] =  { null, ... };
ArrayList g_ArrayTAgents;
ArrayList g_ArrayCTAgents;
ArrayList g_ArrayMapWeapons;

int g_iKnifeDefIndex[] =  {
	500, 503, 505, 506, 507, 508, 509, 512, 514, 515, 516, 517, 518, 519, 520, 521, 522, 523, 525, 526
};

Handle g_hSetRank;
Handle g_hForceUpdate;

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
	version = "1.0", 
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
	
	if (g_bLateLoaded)
	{
		if (eItems_AreItemsSynced())
			eItems_OnItemsSynced();
		else if (!eItems_AreItemsSyncing())
			eItems_ReSync();
	}
	
	if (PTaH_Version() < 101000)
	{
		char sBuf[16];
		PTaH_Version(sBuf, sizeof(sBuf));
		SetFailState("PTaH extension needs to be updated. (Installed Version: %s - Required Version: 1.1.0+) [ Download from: https://ptah.zizt.ru ]", sBuf);
		return;
	}
	
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Pre);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
	HookEvent("round_start", Event_OnRoundStart);
	
	PTaH(PTaH_GiveNamedItemPre, Hook, GiveNamedItemPre);
	PTaH(PTaH_GiveNamedItemPost, Hook, GiveNamedItemPost);
	
	ConVar g_cvGameType = FindConVar("game_type");
	ConVar g_cvGameMode = FindConVar("game_mode");
	
	if (g_cvGameType.IntValue == 1 && g_cvGameMode.IntValue == 2)
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
}

public void eItems_OnItemsSynced()
{
	g_iWeaponCount = eItems_GetWeaponCount();
	g_iSkinCount = eItems_GetPaintsCount();
	g_iGloveCount = eItems_GetGlovesCount();
	g_iAgentCount = eItems_GetAgentsCount();
	
	BuildSkinsArrayList();
}

public void BuildSkinsArrayList()
{
	for (int iWeapon = 0; iWeapon < g_iWeaponCount; iWeapon++)
	{
		if (g_ArrayWeapons[iWeapon] == null)
			delete g_ArrayWeapons[iWeapon];
		
		g_ArrayWeapons[iWeapon] = new ArrayList();
		g_ArrayWeapons[iWeapon].Clear();
		
		int iWeaponDefIndex = eItems_GetWeaponDefIndexByWeaponNum(iWeapon);
		for (int iSkin = 0; iSkin < g_iSkinCount; iSkin++)
		{
			if (eItems_IsNativeSkin(iSkin, iWeapon, ITEMTYPE_WEAPON) && iWeaponDefIndex != 42 && iWeaponDefIndex != 59)
			{
				int iSkinDefIndex = eItems_GetSkinDefIndexBySkinNum(iSkin);
				if (iSkinDefIndex > 0 && iSkinDefIndex < 10000)
					g_ArrayWeapons[iWeapon].Push(iSkinDefIndex);
			}
		}
		
		g_ArrayWeapons[iWeapon].Push(0);
	}
	
	for (int iGlove = 0; iGlove < g_iGloveCount; iGlove++)
	{
		if (g_ArrayGloves[iGlove] == null)
			delete g_ArrayGloves[iGlove];
		
		g_ArrayGloves[iGlove] = new ArrayList();
		g_ArrayGloves[iGlove].Clear();
		
		for (int iGloveSkin = 0; iGloveSkin < g_iSkinCount; iGloveSkin++)
		{
			if (eItems_IsSkinNumGloveApplicable(iGloveSkin) && eItems_IsNativeSkin(iGloveSkin, iGlove, ITEMTYPE_GLOVES))
			{
				int iGloveSkinDefIndex = eItems_GetSkinDefIndexBySkinNum(iGloveSkin);
				g_ArrayGloves[iGlove].Push(iGloveSkinDefIndex);
			}
		}
	}
	
	if (g_ArrayTAgents == null)
		delete g_ArrayTAgents;
	
	g_ArrayTAgents = new ArrayList();
	g_ArrayTAgents.Clear();
	
	if (g_ArrayCTAgents == null)
		delete g_ArrayCTAgents;
	
	g_ArrayCTAgents = new ArrayList();
	g_ArrayCTAgents.Clear();
	
	for (int iAgent = 0; iAgent < g_iAgentCount; iAgent++)
	{
		if(eItems_GetAgentTeamByAgentNum(iAgent) == CS_TEAM_T)
		{
			int iAgentDefIndex = eItems_GetAgentDefIndexByAgentNum(iAgent);
			g_ArrayTAgents.Push(iAgentDefIndex);
		}	
		else if(eItems_GetAgentTeamByAgentNum(iAgent) == CS_TEAM_CT)
		{
			int iAgentDefIndex = eItems_GetAgentDefIndexByAgentNum(iAgent);
			g_ArrayCTAgents.Push(iAgentDefIndex);
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
			Protobuf allplayerdata = hMessage.ReadRepeatedMessage("allplayerdata", i);
			
			client = allplayerdata.ReadInt("entindex");
			
			if (IsValidClient(client))
			{
				int iXuid[2];
				
				iXuid[1] = 17825793;
				iXuid[0] = GetBotAccountID(client);
				
				allplayerdata.SetBool("isbot", false);
				allplayerdata.SetInt64("xuid", iXuid);
				
				for (int j = 0; j < allplayerdata.GetRepeatedFieldCount("items"); j++)
				{
					Protobuf items = allplayerdata.ReadRepeatedMessage("items", j);
					iDefIndex = items.ReadInt("defindex");
					
					if (iDefIndex == 5028 || iDefIndex == 5029)
					{
						items.SetInt("defindex", g_iStoredGlove[client]);
						items.SetInt("paintindex", g_iGloveSkin[client]);
						items.SetInt("paintwear", FloatToInt("%d", g_fGloveWear[client]));
						items.SetInt("paintseed", g_iGloveSeed[client]);
						
						int itemID[2];
						itemID[0] = g_iGloveItemIDHigh[client];
						itemID[1] = g_iGloveItemIDLow[client];
						
						items.SetInt64("itemid", itemID);
					}
					else if (iDefIndex < 4613)
					{
						if (IsPlayerAlive(client) && !(iDefIndex == 41 || iDefIndex == 42 || iDefIndex == 59))
						{
							items.SetInt("paintindex", g_iSkinDefIndex[client][iDefIndex]);
							items.SetInt("paintwear", FloatToInt("%d", g_fWeaponSkinWear[client][iDefIndex]));
							items.SetInt("paintseed", g_iWeaponSkinSeed[client][iDefIndex]);
						}
						else
						{
							items.SetInt("defindex", g_iStoredKnife[client]);
							items.SetInt("paintindex", g_iSkinDefIndex[client][g_iStoredKnife[client]]);
							items.SetInt("paintwear", FloatToInt("%d", g_fWeaponSkinWear[client][g_iStoredKnife[client]]));
							items.SetInt("paintseed", g_iWeaponSkinSeed[client][g_iStoredKnife[client]]);
						}
						
						int itemID[2];
						itemID[0] = g_iItemIDLow[client][iDefIndex];
						itemID[1] = g_iItemIDHigh[client][iDefIndex];
						
						items.SetInt64("itemid", itemID);
						
						Protobuf stickers = items.AddMessage("stickers");
						Protobuf stickers1 = items.AddMessage("stickers");
						Protobuf stickers2 = items.AddMessage("stickers");
						Protobuf stickers3 = items.AddMessage("stickers");
						
						if (g_bUseSticker[client][iDefIndex])
						{
							if (g_bUseStickerCombo[client][iDefIndex])
							{
								switch (g_iRndStickerCombo[client][iDefIndex])
								{
									case 1:
									{
										stickers.SetInt("slot", 0);
										stickers.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][0]);
									}
									case 2:
									{
										stickers.SetInt("slot", 0);
										stickers.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][0]);
										stickers1.SetInt("slot", 1);
										stickers1.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][1]);
									}
									case 3:
									{
										stickers.SetInt("slot", 0);
										stickers.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][0]);
										stickers2.SetInt("slot", 2);
										stickers2.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][2]);
									}
									case 4:
									{
										stickers.SetInt("slot", 0);
										stickers.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][0]);
										stickers3.SetInt("slot", 3);
										stickers3.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][3]);
									}
									case 5:
									{
										stickers.SetInt("slot", 0);
										stickers.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][0]);
										stickers1.SetInt("slot", 1);
										stickers1.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][1]);
										stickers2.SetInt("slot", 2);
										stickers2.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][2]);
									}
									case 6:
									{
										stickers1.SetInt("slot", 1);
										stickers1.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][1]);
									}
									case 7:
									{
										stickers1.SetInt("slot", 1);
										stickers1.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][1]);
										stickers2.SetInt("slot", 2);
										stickers2.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][2]);
									}
									case 8:
									{
										stickers1.SetInt("slot", 1);
										stickers1.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][1]);
										stickers3.SetInt("slot", 3);
										stickers3.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][3]);
									}
									case 9:
									{
										stickers.SetInt("slot", 0);
										stickers.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][0]);
										stickers2.SetInt("slot", 2);
										stickers2.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][2]);
										stickers3.SetInt("slot", 3);
										stickers3.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][3]);
									}
									case 10:
									{
										stickers2.SetInt("slot", 2);
										stickers2.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][2]);
									}
									case 11:
									{
										stickers2.SetInt("slot", 2);
										stickers2.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][2]);
										stickers3.SetInt("slot", 3);
										stickers3.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][3]);
									}
									case 12:
									{
										stickers1.SetInt("slot", 1);
										stickers1.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][1]);
										stickers2.SetInt("slot", 2);
										stickers2.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][2]);
										stickers3.SetInt("slot", 3);
										stickers3.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][3]);
									}
									case 13:
									{
										stickers.SetInt("slot", 3);
										stickers.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][3]);
									}
									case 14:
									{
										stickers.SetInt("slot", 0);
										stickers.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][0]);
										stickers1.SetInt("slot", 1);
										stickers1.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][1]);
										stickers3.SetInt("slot", 3);
										stickers3.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][3]);
									}
								}
							}
							else
							{
								switch (g_iRndStickerCombo[client][iDefIndex])
								{
									case 1:
									{
										stickers.SetInt("slot", 0);
										stickers.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][0]);
										stickers1.SetInt("slot", 1);
										stickers1.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][1]);
										stickers2.SetInt("slot", 2);
										stickers2.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][2]);
										stickers3.SetInt("slot", 3);
										stickers3.SetInt("sticker_id", g_iRndSticker[client][iDefIndex][3]);
									}
									case 2:
									{
										stickers.SetInt("slot", 0);
										stickers.SetInt("sticker_id", g_iRndSameSticker[client][iDefIndex]);
										stickers1.SetInt("slot", 1);
										stickers1.SetInt("sticker_id", g_iRndSameSticker[client][iDefIndex]);
										stickers2.SetInt("slot", 2);
										stickers2.SetInt("sticker_id", g_iRndSameSticker[client][iDefIndex]);
										stickers3.SetInt("slot", 3);
										stickers3.SetInt("sticker_id", g_iRndSameSticker[client][iDefIndex]);
									}
								}
							}
						}
					}
					else
					{
						int itemID[2];
						itemID[0] = Math_GetRandomInt(1, 2048);
						itemID[1] = Math_GetRandomInt(1, 16384);
						
						items.SetInt64("itemid", itemID);
						
						Protobuf patch = items.AddMessage("stickers");
						Protobuf patch1 = items.AddMessage("stickers");
						Protobuf patch2 = items.AddMessage("stickers");
						Protobuf patch3 = items.AddMessage("stickers");
						
						if (g_bUsePatch[client])
						{
							if (g_bUsePatchCombo[client])
							{
								switch (g_iRndPatchCombo[client])
								{
									case 1:
									{
										patch.SetInt("slot", 0);
										patch.SetInt("sticker_id", g_iRndPatch[client][0]);
									}
									case 2:
									{
										patch.SetInt("slot", 0);
										patch.SetInt("sticker_id", g_iRndPatch[client][0]);
										patch1.SetInt("slot", 1);
										patch1.SetInt("sticker_id", g_iRndPatch[client][1]);
									}
									case 3:
									{
										patch.SetInt("slot", 0);
										patch.SetInt("sticker_id", g_iRndPatch[client][0]);
										patch2.SetInt("slot", 2);
										patch2.SetInt("sticker_id", g_iRndPatch[client][2]);
									}
									case 4:
									{
										patch.SetInt("slot", 0);
										patch.SetInt("sticker_id", g_iRndPatch[client][0]);
										patch3.SetInt("slot", 3);
										patch3.SetInt("sticker_id", g_iRndPatch[client][3]);
									}
									case 5:
									{
										patch.SetInt("slot", 0);
										patch.SetInt("sticker_id", g_iRndPatch[client][0]);
										patch1.SetInt("slot", 1);
										patch1.SetInt("sticker_id", g_iRndPatch[client][1]);
										patch2.SetInt("slot", 2);
										patch2.SetInt("sticker_id", g_iRndPatch[client][2]);
									}
									case 6:
									{
										patch1.SetInt("slot", 1);
										patch1.SetInt("sticker_id", g_iRndPatch[client][1]);
									}
									case 7:
									{
										patch1.SetInt("slot", 1);
										patch1.SetInt("sticker_id", g_iRndPatch[client][1]);
										patch2.SetInt("slot", 2);
										patch2.SetInt("sticker_id", g_iRndPatch[client][2]);
									}
									case 8:
									{
										patch1.SetInt("slot", 1);
										patch1.SetInt("sticker_id", g_iRndPatch[client][1]);
										patch3.SetInt("slot", 3);
										patch3.SetInt("sticker_id", g_iRndPatch[client][3]);
									}
									case 9:
									{
										patch.SetInt("slot", 0);
										patch.SetInt("sticker_id", g_iRndPatch[client][0]);
										patch2.SetInt("slot", 2);
										patch2.SetInt("sticker_id", g_iRndPatch[client][2]);
										patch3.SetInt("slot", 3);
										patch3.SetInt("sticker_id", g_iRndPatch[client][3]);
									}
									case 10:
									{
										patch2.SetInt("slot", 2);
										patch2.SetInt("sticker_id", g_iRndPatch[client][2]);
									}
									case 11:
									{
										patch2.SetInt("slot", 2);
										patch2.SetInt("sticker_id", g_iRndPatch[client][2]);
										patch3.SetInt("slot", 3);
										patch3.SetInt("sticker_id", g_iRndPatch[client][3]);
									}
									case 12:
									{
										patch1.SetInt("slot", 1);
										patch1.SetInt("sticker_id", g_iRndPatch[client][1]);
										patch2.SetInt("slot", 2);
										patch2.SetInt("sticker_id", g_iRndPatch[client][2]);
										patch3.SetInt("slot", 3);
										patch3.SetInt("sticker_id", g_iRndPatch[client][3]);
									}
									case 13:
									{
										patch.SetInt("slot", 3);
										patch.SetInt("sticker_id", g_iRndPatch[client][3]);
									}
									case 14:
									{
										patch.SetInt("slot", 0);
										patch.SetInt("sticker_id", g_iRndPatch[client][0]);
										patch1.SetInt("slot", 1);
										patch1.SetInt("sticker_id", g_iRndPatch[client][1]);
										patch3.SetInt("slot", 3);
										patch3.SetInt("sticker_id", g_iRndPatch[client][3]);
									}
								}
							}
							else
							{
								switch (g_iRndPatchCombo[client])
								{
									case 1:
									{
										patch.SetInt("slot", 0);
										patch.SetInt("sticker_id", g_iRndPatch[client][0]);
										patch1.SetInt("slot", 1);
										patch1.SetInt("sticker_id", g_iRndPatch[client][1]);
										patch2.SetInt("slot", 2);
										patch2.SetInt("sticker_id", g_iRndPatch[client][2]);
										patch3.SetInt("slot", 3);
										patch3.SetInt("sticker_id", g_iRndPatch[client][3]);
									}
									case 2:
									{
										patch.SetInt("slot", 0);
										patch.SetInt("sticker_id", g_iRndSamePatch[client]);
										patch1.SetInt("slot", 1);
										patch1.SetInt("sticker_id", g_iRndSamePatch[client]);
										patch2.SetInt("slot", 2);
										patch2.SetInt("sticker_id", g_iRndSamePatch[client]);
										patch3.SetInt("slot", 3);
										patch3.SetInt("sticker_id", g_iRndSamePatch[client]);
									}
								}
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
	if(g_ArrayMapWeapons != null)
	{
		delete g_ArrayMapWeapons;
		g_ArrayMapWeapons = null;
	}

	g_ArrayMapWeapons = new ArrayList();
}

public void OnClientPostAdminCheck(int client)
{
	if (IsValidClient(client))
	{
		if (eItems_AreItemsSynced())
		{
			static int IDLow = 2048;
			static int IDHigh = 16384;
		
			g_iMusicKit[client] = eItems_GetMusicKitDefIndexByMusicKitNum(Math_GetRandomInt(0, eItems_GetMusicKitsCount() - 1));
			g_iCoin[client] = Math_GetRandomInt(1, 2) == 1 ? eItems_GetCoinDefIndexByCoinNum(Math_GetRandomInt(0, eItems_GetCoinsCount() - 1)) : eItems_GetPinDefIndexByPinNum(Math_GetRandomInt(0, eItems_GetPinsCount() - 1));
			g_bUseCustomPlayer[client] = IsItMyChance(65.0) ? true : false;
			
			int iRandomTAgent = Math_GetRandomInt(0, g_ArrayTAgents.Length - 1);
			int iRandomCTAgent = Math_GetRandomInt(0, g_ArrayCTAgents.Length - 1);
			
			if (iRandomTAgent != -1 && iRandomCTAgent != -1)
			{
				g_iAgent[client][CS_TEAM_T] = g_ArrayTAgents.Get(iRandomTAgent);
				g_iAgent[client][CS_TEAM_CT] = g_ArrayCTAgents.Get(iRandomCTAgent);
			
				eItems_GetAgentPlayerModelByDefIndex(g_iAgent[client][CS_TEAM_CT], g_szModel[client][CS_TEAM_CT], 128);
				PrecacheModel(g_szModel[client][CS_TEAM_CT]);
				eItems_GetAgentVOPrefixByDefIndex(g_iAgent[client][CS_TEAM_CT], g_szVOPrefix[client][CS_TEAM_CT], 128);

				eItems_GetAgentPlayerModelByDefIndex(g_iAgent[client][CS_TEAM_T], g_szModel[client][CS_TEAM_T], 128);
				PrecacheModel(g_szModel[client][CS_TEAM_T]);
				eItems_GetAgentVOPrefixByDefIndex(g_iAgent[client][CS_TEAM_T], g_szVOPrefix[client][CS_TEAM_T], 128);
			}
			
			g_bUsePatch[client] = IsItMyChance(40.0) ? true : false;
			g_bUsePatchCombo[client] = IsItMyChance(50.0) ? true : false;
			g_iRndPatchCombo[client] = g_bUsePatchCombo[client] ? Math_GetRandomInt(1, 14) : Math_GetRandomInt(1, 2);
			
			g_iRndPatch[client][0] = eItems_GetPatchDefIndexByPatchNum(Math_GetRandomInt(0, eItems_GetPatchesCount() - 1));
			g_iRndPatch[client][1] = eItems_GetPatchDefIndexByPatchNum(Math_GetRandomInt(0, eItems_GetPatchesCount() - 1));
			g_iRndPatch[client][2] = eItems_GetPatchDefIndexByPatchNum(Math_GetRandomInt(0, eItems_GetPatchesCount() - 1));
			g_iRndPatch[client][3] = eItems_GetPatchDefIndexByPatchNum(Math_GetRandomInt(0, eItems_GetPatchesCount() - 1));
			
			g_iRndSamePatch[client] = eItems_GetPatchDefIndexByPatchNum(Math_GetRandomInt(0, eItems_GetPatchesCount() - 1));
			
			g_iStoredGlove[client] = eItems_GetGlovesDefIndexByGlovesNum(Math_GetRandomInt(0, g_iGloveCount - 1));
			g_iGloveItemIDLow[client] = IDLow++;
			g_iGloveItemIDHigh[client] = IDHigh++;
			
			int iGloveNum = eItems_GetGlovesNumByDefIndex(g_iStoredGlove[client]);
			int iRandomGloveSkin = Math_GetRandomInt(0, g_ArrayGloves[iGloveNum].Length - 1);
			
			if (iRandomGloveSkin != -1)
				g_iGloveSkin[client] = g_ArrayGloves[iGloveNum].Get(iRandomGloveSkin);
			
			g_fGloveWear[client] = Math_GetRandomFloat(0.06, 0.80);
			g_iGloveSeed[client] = Math_GetRandomInt(1, 1000);
			
			g_iStoredKnife[client] = g_iKnifeDefIndex[Math_GetRandomInt(0, sizeof(g_iKnifeDefIndex) - 1)];
			
			for (int iWeapon = 0; iWeapon < g_iWeaponCount; iWeapon++)
			{
				int iWeaponDefIndex = eItems_GetWeaponDefIndexByWeaponNum(iWeapon);
				int iRandomWeaponSkin = Math_GetRandomInt(0, g_ArrayWeapons[iWeapon].Length - 1);
				if (iRandomWeaponSkin != -1)
					g_iSkinDefIndex[client][iWeaponDefIndex] = g_ArrayWeapons[iWeapon].Get(iRandomWeaponSkin);
				
				g_iItemIDHigh[client][iWeaponDefIndex] = IDHigh++;
				g_iItemIDLow[client][iWeaponDefIndex] = IDLow++;
				
				g_iWeaponSkinSeed[client][iWeaponDefIndex] = Math_GetRandomInt(1, 1000);
				g_bUseSticker[client][iWeaponDefIndex] = IsItMyChance(40.0) ? true : false;
				g_bUseStickerCombo[client][iWeaponDefIndex] = IsItMyChance(50.0) ? true : false;
				
				g_bUseStatTrak[client][iWeaponDefIndex] = false;
				g_bUseSouvenir[client][iWeaponDefIndex] = false;
				
				for (int iCrateNum = 0; iCrateNum < eItems_GetCratesCount(); iCrateNum++)
				{
					char szCrateName[128];
					int iCrateDefIndex = eItems_GetCrateDefIndexByCrateNum(iCrateNum);
					int iCrateItemsCount = eItems_GetCrateItemsCountByDefIndex(iCrateDefIndex);
					eItems_GetCrateDisplayNameByCrateNum(iCrateNum, szCrateName, sizeof(szCrateName));
					eItems_CrateItem CrateItem;
					
					if(StrContains(szCrateName, "Case") != -1)
					{
						for(int iItem = 0; iItem < iCrateItemsCount; iItem++)
						{
							eItems_GetCrateItemByDefIndex(iCrateDefIndex, iItem, CrateItem, sizeof(eItems_CrateItem));
							
							if((CrateItem.SkinDefIndex == g_iSkinDefIndex[client][iWeaponDefIndex] && CrateItem.WeaponDefIndex == iWeaponDefIndex) || eItems_IsDefIndexKnife(iWeaponDefIndex) || g_iSkinDefIndex[client][iWeaponDefIndex] >= 1300)
								g_bUseStatTrak[client][iWeaponDefIndex] = IsItMyChance(30.0) ? true : false;
						}
					}
					else if(StrContains(szCrateName, "Souvenir") != -1)
					{
						for(int iItem = 0; iItem < iCrateItemsCount; iItem++)
						{
							eItems_GetCrateItemByDefIndex(iCrateDefIndex, iItem, CrateItem, sizeof(eItems_CrateItem));
							
							if((CrateItem.SkinDefIndex == g_iSkinDefIndex[client][iWeaponDefIndex] && CrateItem.WeaponDefIndex == iWeaponDefIndex))
								g_bUseSouvenir[client][iWeaponDefIndex] = IsItMyChance(30.0) ? true : false;
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
	
	int clientTeam = GetClientTeam(client);
	
	if (clientTeam < CS_TEAM_T)
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
		int iPrevOwner = GetEntProp(iEntity, Prop_Send, "m_hPrevOwner");
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
	
	switch (iDefIndex)
	{
		case 500, 503, 505, 506, 507, 508, 509, 512, 514, 515, 516, 517, 518, 519, 520, 521, 522, 523, 525:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[0];
		case 4:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[1];
		case 32:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[2];
		case 61:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[3];
		case 36:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[4];
		case 1:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[5];
		case 2:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[6];
		case 3:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[7];
		case 30:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[8];
		case 63:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[9];
		case 64:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[10];
		case 35:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[11];
		case 25:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[12];
		case 27:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[13];
		case 29:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[14];
		case 26:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[15];
		case 17:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[16];
		case 34:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[17];
		case 33:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[18];
		case 24:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[19];
		case 19:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[20];
		case 13:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[21];
		case 7:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[22];
		case 38:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[23];
		case 10:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[24];
		case 16:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[25];
		case 60:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[26];
		case 8:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[27];
		case 40:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[28];
		case 39:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[29];
		case 9:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[30];
		case 11:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[31];
		case 14:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[32];
		case 28:
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[33];
	}
	
	
	if (GetEntProp(iWeapon, Prop_Send, "m_iAccountID") == GetBotAccountID(attacker) && (GetEntProp(iWeapon, Prop_Send, "m_iEntityQuality") == 9 || g_bKnifeHasStatTrak[attacker][iDefIndex]))
	{
		CEconItemView pItem = PTaH_GetEconItemViewFromEconEntity(iWeapon);
		CAttributeList pDynamicAttributes = pItem.NetworkedDynamicAttributesForDemos;
		
		pDynamicAttributes.SetOrAddAttributeValue(80, g_iStatTrakKills[attacker][iDefIndex] + 1);
		
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

    int iPrevOwner = GetEntProp(iWeapon, Prop_Send, "m_hPrevOwner");
    if(iPrevOwner > 0)
        return Plugin_Continue;

    if(IsMapWeapon(iWeapon, true))
    {
        DataPack datapack = new DataPack();
        datapack.WriteCell(client);
        datapack.WriteCell(iWeapon);

        CreateTimer(0.1, Timer_MapWeaponEquipped, datapack);
    }
    return Plugin_Continue;
}

public Action Timer_MapWeaponEquipped(Handle timer, DataPack datapack)
{
	datapack.Reset();
	int client = datapack.ReadCell();
	int iWeapon = datapack.ReadCell();
	delete datapack;

	if(!IsValidClient(client))
		return Plugin_Continue;
	if(!eItems_IsValidWeapon(iWeapon))
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

		if(GetEntProp(i, Prop_Send, "m_hOwnerEntity") != -1)
			continue;
		
		int iDefIndex;
		if((iDefIndex = eItems_GetWeaponDefIndexByClassName(szWeaponClassname)) == -1)
			continue;

		if(eItems_IsDefIndexKnife(iDefIndex))
			continue;

		g_ArrayMapWeapons.Push(i);
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
			
			if (Math_GetRandomInt(1, 2) == 1)
				SDKCall(g_hSetRank, client, MEDAL_CATEGORY_SEASON_COIN, g_iCoin[client]);
			else
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
	if (!IsValidClient(client) || g_bUseCustomPlayer[client])
		return Plugin_Continue;
	
	if (GetClientTeam(client) == CS_TEAM_CT)
	{
		strcopy(szModel, iModelLength, g_szModel[client][CS_TEAM_CT]);
		strcopy(szVoPrefix, iPrefixLength, g_szVOPrefix[client][CS_TEAM_CT]);
			
		if (g_bUsePatch[client])
		{
			if (g_bUsePatchCombo[client])
			{
				switch (g_iRndPatchCombo[client])
				{
					case 1:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][0], 4, 0);
					}
					case 2:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][0], 4, 0);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][1], 4, 1);
					}
					case 3:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][0], 4, 0);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][2], 4, 2);
					}
					case 4:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][0], 4, 0);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][3], 4, 3);
					}
					case 5:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][0], 4, 0);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][1], 4, 1);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][2], 4, 2);
					}
					case 6:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][1], 4, 1);
					}
					case 7:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][1], 4, 1);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][2], 4, 2);
					}
					case 8:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][1], 4, 1);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][3], 4, 3);
					}
					case 9:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][0], 4, 0);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][2], 4, 2);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][3], 4, 3);
					}
					case 10:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][2], 4, 2);
					}
					case 11:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][2], 4, 2);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][3], 4, 3);
					}
					case 12:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][1], 4, 1);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][2], 4, 2);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][3], 4, 3);
					}
					case 13:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][3], 4, 3);
					}
					case 14:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][0], 4, 0);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][1], 4, 1);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][3], 4, 3);
					}
				}
			}
			else
			{
				switch (g_iRndPatchCombo[client])
				{
					case 1:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][0], 4, 0);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][1], 4, 1);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][2], 4, 2);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][3], 4, 3);
					}
					case 2:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndSamePatch[client], 4, 0);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndSamePatch[client], 4, 1);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndSamePatch[client], 4, 2);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndSamePatch[client], 4, 3);
					}
				}
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
				switch (g_iRndPatchCombo[client])
				{
					case 1:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][0], 4, 0);
					}
					case 2:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][0], 4, 0);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][1], 4, 1);
					}
					case 3:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][0], 4, 0);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][2], 4, 2);
					}
					case 4:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][0], 4, 0);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][3], 4, 3);
					}
					case 5:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][0], 4, 0);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][1], 4, 1);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][2], 4, 2);
					}
					case 6:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][1], 4, 1);
					}
					case 7:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][1], 4, 1);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][2], 4, 2);
					}
					case 8:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][1], 4, 1);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][3], 4, 3);
					}
					case 9:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][0], 4, 0);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][2], 4, 2);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][3], 4, 3);
					}
					case 10:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][2], 4, 2);
					}
					case 11:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][2], 4, 2);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][3], 4, 3);
					}
					case 12:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][1], 4, 1);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][2], 4, 2);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][3], 4, 3);
					}
					case 13:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][3], 4, 3);
					}
					case 14:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][0], 4, 0);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][1], 4, 1);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][3], 4, 3);
					}
				}
			}
			else
			{
				switch (g_iRndPatchCombo[client])
				{
					case 1:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][0], 4, 0);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][1], 4, 1);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][2], 4, 2);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[client][3], 4, 3);
					}
					case 2:
					{
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndSamePatch[client], 4, 0);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndSamePatch[client], 4, 1);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndSamePatch[client], 4, 2);
						SetEntProp(client, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndSamePatch[client], 4, 3);
					}
				}
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
		
		switch (iDefIndex)
		{
			case 500, 503, 505, 506, 507, 508, 509, 512, 514, 515, 516, 517, 518, 519, 520, 521, 522, 523, 525:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[0];
			case 4:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[1];
			case 32:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[2];
			case 61:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[3];
			case 36:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[4];
			case 1:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[5];
			case 2:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[6];
			case 3:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[7];
			case 30:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[8];
			case 63:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[9];
			case 64:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[10];
			case 35:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[11];
			case 25:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[12];
			case 27:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[13];
			case 29:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[14];
			case 26:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[15];
			case 17:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[16];
			case 34:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[17];
			case 33:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[18];
			case 24:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[19];
			case 19:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[20];
			case 13:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[21];
			case 7:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[22];
			case 38:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[23];
			case 10:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[24];
			case 16:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[25];
			case 60:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[26];
			case 8:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[27];
			case 40:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[28];
			case 39:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[29];
			case 9:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[30];
			case 11:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[31];
			case 14:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[32];
			case 28:
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[33];
		}
		
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
				switch (g_iRndStickerCombo[client][iDefIndex])
				{
					case 1:
					{
						pDynamicAttributes.SetOrAddAttributeValue(113, g_iRndSticker[client][iDefIndex][0]);
					}
					case 2:
					{
						pDynamicAttributes.SetOrAddAttributeValue(113, g_iRndSticker[client][iDefIndex][0]);
						pDynamicAttributes.SetOrAddAttributeValue(117, g_iRndSticker[client][iDefIndex][1]);
					}
					case 3:
					{
						pDynamicAttributes.SetOrAddAttributeValue(113, g_iRndSticker[client][iDefIndex][0]);
						pDynamicAttributes.SetOrAddAttributeValue(121, g_iRndSticker[client][iDefIndex][2]);
					}
					case 4:
					{
						pDynamicAttributes.SetOrAddAttributeValue(113, g_iRndSticker[client][iDefIndex][0]);
						pDynamicAttributes.SetOrAddAttributeValue(125, g_iRndSticker[client][iDefIndex][3]);
					}
					case 5:
					{
						pDynamicAttributes.SetOrAddAttributeValue(113, g_iRndSticker[client][iDefIndex][0]);
						pDynamicAttributes.SetOrAddAttributeValue(117, g_iRndSticker[client][iDefIndex][1]);
						pDynamicAttributes.SetOrAddAttributeValue(121, g_iRndSticker[client][iDefIndex][2]);
					}
					case 6:
					{
						pDynamicAttributes.SetOrAddAttributeValue(117, g_iRndSticker[client][iDefIndex][1]);
					}
					case 7:
					{
						pDynamicAttributes.SetOrAddAttributeValue(117, g_iRndSticker[client][iDefIndex][1]);
						pDynamicAttributes.SetOrAddAttributeValue(121, g_iRndSticker[client][iDefIndex][2]);
					}
					case 8:
					{
						pDynamicAttributes.SetOrAddAttributeValue(117, g_iRndSticker[client][iDefIndex][1]);
						pDynamicAttributes.SetOrAddAttributeValue(125, g_iRndSticker[client][iDefIndex][3]);
					}
					case 9:
					{
						pDynamicAttributes.SetOrAddAttributeValue(113, g_iRndSticker[client][iDefIndex][0]);
						pDynamicAttributes.SetOrAddAttributeValue(121, g_iRndSticker[client][iDefIndex][2]);
						pDynamicAttributes.SetOrAddAttributeValue(125, g_iRndSticker[client][iDefIndex][3]);
					}
					case 10:
					{
						pDynamicAttributes.SetOrAddAttributeValue(121, g_iRndSticker[client][iDefIndex][2]);
					}
					case 11:
					{
						pDynamicAttributes.SetOrAddAttributeValue(121, g_iRndSticker[client][iDefIndex][2]);
						pDynamicAttributes.SetOrAddAttributeValue(125, g_iRndSticker[client][iDefIndex][3]);
					}
					case 12:
					{
						pDynamicAttributes.SetOrAddAttributeValue(117, g_iRndSticker[client][iDefIndex][1]);
						pDynamicAttributes.SetOrAddAttributeValue(121, g_iRndSticker[client][iDefIndex][2]);
						pDynamicAttributes.SetOrAddAttributeValue(125, g_iRndSticker[client][iDefIndex][3]);
					}
					case 13:
					{
						pDynamicAttributes.SetOrAddAttributeValue(125, g_iRndSticker[client][iDefIndex][3]);
					}
					case 14:
					{
						pDynamicAttributes.SetOrAddAttributeValue(113, g_iRndSticker[client][iDefIndex][0]);
						pDynamicAttributes.SetOrAddAttributeValue(117, g_iRndSticker[client][iDefIndex][1]);
						pDynamicAttributes.SetOrAddAttributeValue(125, g_iRndSticker[client][iDefIndex][3]);
					}
				}
			}
			else
			{
				switch (g_iRndStickerCombo[client][iDefIndex])
				{
					case 1:
					{
						pDynamicAttributes.SetOrAddAttributeValue(113, g_iRndSticker[client][iDefIndex][0]);
						pDynamicAttributes.SetOrAddAttributeValue(117, g_iRndSticker[client][iDefIndex][1]);
						pDynamicAttributes.SetOrAddAttributeValue(121, g_iRndSticker[client][iDefIndex][2]);
						pDynamicAttributes.SetOrAddAttributeValue(125, g_iRndSticker[client][iDefIndex][3]);
					}
					case 2:
					{
						pDynamicAttributes.SetOrAddAttributeValue(113, g_iRndSameSticker[client][iDefIndex]);
						pDynamicAttributes.SetOrAddAttributeValue(117, g_iRndSameSticker[client][iDefIndex]);
						pDynamicAttributes.SetOrAddAttributeValue(121, g_iRndSameSticker[client][iDefIndex]);
						pDynamicAttributes.SetOrAddAttributeValue(125, g_iRndSameSticker[client][iDefIndex]);
					}
				}
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
}

public void OnPluginEnd()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
			OnClientDisconnect(i);
	}
}

stock bool IsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && IsFakeClient(client) && !IsClientSourceTV(client);
}

stock int FloatToInt(const char[] szValue, any ...)
{
	int szLen = strlen(szValue) + 255;
	char[] szFormattedString = new char[szLen];
	VFormat(szFormattedString, szLen, szValue, 2);
 
	return StringToInt(szFormattedString);
}

stock bool IsItMyChance(float fChance = 0.0)
{
	float flRand = Math_GetRandomFloat(0.0, 100.0);
	if(fChance <= 0.0)
		return false;
	return flRand <= fChance;
}

stock bool IsMapWeapon(int iWeapon, bool bRemove = false)
{
	if(g_ArrayMapWeapons == null)
		return false;
		
	for(int i = 0; i < g_ArrayMapWeapons.Length; i++)
	{
		if(g_ArrayMapWeapons.Get(i) != iWeapon)
			continue;

		if(bRemove)
			g_ArrayMapWeapons.Erase(i);
			
		return true;
	}
	return false;
}