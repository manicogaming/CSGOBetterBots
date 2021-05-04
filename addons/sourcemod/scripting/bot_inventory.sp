#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <cstrike>
#include <eItems>
#include <PTaH>
#include <bot_steamids>
#include <kento_rankme/rankme>
#include <smlib>

bool g_bLateLoaded;
int g_iWeaponCount;
int g_iSkinCount;
int g_iGloveCount;
int g_iAgentCount;

int g_iMusicKit[MAXPLAYERS + 1];
int g_iCoin[MAXPLAYERS + 1];
int g_iCustomPlayerChance[MAXPLAYERS + 1];
int g_iCTModel[MAXPLAYERS + 1];
int g_iTModel[MAXPLAYERS + 1];
int g_iPatchChance[MAXPLAYERS + 1];
int g_iPatchComboChance[MAXPLAYERS + 1];
int g_iRndPatchCombo[MAXPLAYERS + 1];
int g_iRndPatch[MAXPLAYERS + 1][4];
int g_iRndSamePatch[MAXPLAYERS + 1];

int g_iStoredKnife[MAXPLAYERS + 1];
int g_iSkinDefIndex[MAXPLAYERS + 1][1024];
float g_fWeaponSkinWear[MAXPLAYERS + 1][1024];
int g_iWeaponSkinSeed[MAXPLAYERS + 1][1024];
int g_iStatTrakChance[MAXPLAYERS + 1][1024];
int g_iSouvenirChance[MAXPLAYERS + 1][1024];
int g_iStickerChance[MAXPLAYERS + 1][1024];
int g_iStickerComboChance[MAXPLAYERS + 1][1024];
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

ArrayList g_ArrayWeapons[128] =  { null, ... };
ArrayList g_ArrayGloves[128] =  { null, ... };
ArrayList g_ArrayTAgents;
ArrayList g_ArrayCTAgents;
ArrayList g_ArrayMapWeapons;

int g_iKnifeDefIndex[] =  {
	500, 503, 505, 506, 507, 508, 509, 512, 514, 515, 516, 517, 518, 519, 520, 521, 522, 523, 525
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
		{
			eItems_OnItemsSynced();
		}
		else if (!eItems_AreItemsSyncing())
		{
			eItems_ReSync();
		}
	}
	
	if (PTaH_Version() < 101000)
	{
		char sBuf[16];
		PTaH_Version(sBuf, sizeof(sBuf));
		SetFailState("PTaH extension needs to be updated. (Installed Version: %s - Required Version: 1.1.0+) [ Download from: https://ptah.zizt.ru ]", sBuf);
		return;
	}
	
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Pre);
	HookEvent("round_start", Event_OnRoundStart);
	
	PTaH(PTaH_GiveNamedItemPre, Hook, GiveNamedItemPre);
	PTaH(PTaH_GiveNamedItemPost, Hook, GiveNamedItemPost);
	
	ConVar g_cvGameType = FindConVar("game_type");
	ConVar g_cvGameMode = FindConVar("game_mode");
	
	if (g_cvGameType.IntValue == 1 && g_cvGameMode.IntValue == 2)
	{
		PTaH(PTaH_WeaponCanUsePre, Hook, WeaponCanUsePre);
	}
	
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
		{
			delete g_ArrayWeapons[iWeapon];
		}
		
		g_ArrayWeapons[iWeapon] = new ArrayList();
		g_ArrayWeapons[iWeapon].Clear();
		
		int iWeaponDefIndex = eItems_GetWeaponDefIndexByWeaponNum(iWeapon);
		for (int iSkin = 0; iSkin < g_iSkinCount; iSkin++)
		{
			if (eItems_IsNativeSkin(iSkin, iWeapon, ITEMTYPE_WEAPON) && iWeaponDefIndex != 42 && iWeaponDefIndex != 59)
			{
				int iSkinDefIndex = eItems_GetSkinDefIndexBySkinNum(iSkin);
				if (iSkinDefIndex > 0 && iSkinDefIndex < 10000)
				{
					
					g_ArrayWeapons[iWeapon].Push(iSkinDefIndex);
				}
			}
		}
		
		g_ArrayWeapons[iWeapon].Push(0);
	}
	
	for (int iGlove = 0; iGlove < g_iGloveCount; iGlove++)
	{
		if (g_ArrayGloves[iGlove] == null)
		{
			delete g_ArrayGloves[iGlove];
		}
		
		g_ArrayGloves[iGlove] = new ArrayList();
		g_ArrayGloves[iGlove].Clear();
		
		for (int iGloveSkin = 0; iGloveSkin < g_iSkinCount; iGloveSkin++)
		{
			if (eItems_IsSkinNumGloveApplicable(iGloveSkin) && eItems_IsNativeSkin(iGloveSkin, iGlove, ITEMTYPE_GLOVES))
			{
				int iGloveDefIndex = eItems_GetSkinDefIndexBySkinNum(iGloveSkin);
				g_ArrayGloves[iGlove].Push(iGloveDefIndex);
			}
		}
	}
	
	if (g_ArrayTAgents == null)
	{
		delete g_ArrayTAgents;
	}
	
	g_ArrayTAgents = new ArrayList();
	g_ArrayTAgents.Clear();
	
	if (g_ArrayCTAgents == null)
	{
		delete g_ArrayCTAgents;
	}
	
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
					else if (iDefIndex < 4619)
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
						
						if (g_iStickerChance[client][iDefIndex] <= 30)
						{
							if (g_iStickerComboChance[client][iDefIndex] <= 65)
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
						
						if (g_iPatchChance[client] <= 30)
						{
							if (g_iPatchComboChance[client] <= 65)
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
			
			if (Math_GetRandomInt(1, 2) == 1)
			{
				g_iCoin[client] = eItems_GetCoinDefIndexByCoinNum(Math_GetRandomInt(0, eItems_GetCoinsCount() - 1));
			}
			else
			{
				g_iCoin[client] = eItems_GetPinDefIndexByPinNum(Math_GetRandomInt(0, eItems_GetPinsCount() - 1));
			}
			
			g_iCustomPlayerChance[client] = Math_GetRandomInt(1, 100);
			
			int iRandomTAgent = Math_GetRandomInt(0, g_ArrayTAgents.Length - 1);
			int iRandomCTAgent = Math_GetRandomInt(0, g_ArrayCTAgents.Length - 1);
			
			if (iRandomTAgent != -1 && iRandomCTAgent != -1)
			{
				g_iTModel[client] = g_ArrayTAgents.Get(iRandomTAgent);
				g_iCTModel[client] = g_ArrayCTAgents.Get(iRandomCTAgent);
			}
			
			g_iPatchChance[client] = Math_GetRandomInt(1, 100);
			g_iPatchComboChance[client] = Math_GetRandomInt(1, 100);
			
			if (g_iPatchComboChance[client] <= 65)
			{
				g_iRndPatchCombo[client] = Math_GetRandomInt(1, 14);
			}
			else
			{
				g_iRndPatchCombo[client] = Math_GetRandomInt(1, 2);
			}
			
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
			{
				g_iGloveSkin[client] = g_ArrayGloves[iGloveNum].Get(iRandomGloveSkin);
			}
			
			g_fGloveWear[client] = Math_GetRandomFloat(0.06, 0.80);
			g_iGloveSeed[client] = Math_GetRandomInt(1, 1000);
			
			g_iStoredKnife[client] = g_iKnifeDefIndex[Math_GetRandomInt(0, sizeof(g_iKnifeDefIndex) - 1)];
			
			for (int iWeapon = 0; iWeapon < g_iWeaponCount; iWeapon++)
			{
				int iWeaponDefIndex = eItems_GetWeaponDefIndexByWeaponNum(iWeapon);
				int iRandomWeaponSkin = Math_GetRandomInt(0, g_ArrayWeapons[iWeapon].Length - 1);
				if (iRandomWeaponSkin != -1)
				{
					g_iSkinDefIndex[client][iWeaponDefIndex] = g_ArrayWeapons[iWeapon].Get(iRandomWeaponSkin);
				}
				
				g_iItemIDHigh[client][iWeaponDefIndex] = IDHigh++;
				g_iItemIDLow[client][iWeaponDefIndex] = IDLow++;
				
				g_iWeaponSkinSeed[client][iWeaponDefIndex] = Math_GetRandomInt(1, 1000);
				g_iStickerChance[client][iWeaponDefIndex] = Math_GetRandomInt(1, 100);
				g_iStickerComboChance[client][iWeaponDefIndex] = Math_GetRandomInt(1, 100);
				
				g_iStatTrakChance[client][iWeaponDefIndex] = 100;
				g_iSouvenirChance[client][iWeaponDefIndex] = Math_GetRandomInt(1, 100);
				
				for (int iCrateNum = 0; iCrateNum < eItems_GetCratesCount(); iCrateNum++)
				{
					int iCrateDefIndex = eItems_GetCrateDefIndexByCrateNum(iCrateNum);
					int iCrateItemsCount = eItems_GetCrateItemsCountByDefIndex(iCrateDefIndex);
					for(int iItem = 0; iItem < iCrateItemsCount; iItem++)
					{
						eItems_CrateItem CrateItem;
						eItems_GetCrateItemByDefIndex(iCrateDefIndex, iItem, CrateItem, sizeof(eItems_CrateItem));
						
						if((CrateItem.SkinDefIndex == g_iSkinDefIndex[client][iWeaponDefIndex] && CrateItem.WeaponDefIndex == iWeaponDefIndex) || eItems_IsDefIndexKnife(iWeaponDefIndex))
						{
							g_iStatTrakChance[client][iWeaponDefIndex] = Math_GetRandomInt(1, 100);
							g_iSouvenirChance[client][iWeaponDefIndex] = 100;
						}
			        }
			    }
				
				if (g_iStickerComboChance[client][iWeaponDefIndex] <= 65)
				{
					g_iRndStickerCombo[client][iWeaponDefIndex] = Math_GetRandomInt(1, 14);
				}
				else
				{
					g_iRndStickerCombo[client][iWeaponDefIndex] = Math_GetRandomInt(1, 2);
				}
				
				g_iRndSticker[client][iWeaponDefIndex][0] = eItems_GetStickerDefIndexByStickerNum(Math_GetRandomInt(0, eItems_GetStickersCount() - 1));
				g_iRndSticker[client][iWeaponDefIndex][1] = eItems_GetStickerDefIndexByStickerNum(Math_GetRandomInt(0, eItems_GetStickersCount() - 1));
				g_iRndSticker[client][iWeaponDefIndex][2] = eItems_GetStickerDefIndexByStickerNum(Math_GetRandomInt(0, eItems_GetStickersCount() - 1));
				g_iRndSticker[client][iWeaponDefIndex][3] = eItems_GetStickerDefIndexByStickerNum(Math_GetRandomInt(0, eItems_GetStickersCount() - 1));
				
				g_iRndSameSticker[client][iWeaponDefIndex] = eItems_GetStickerDefIndexByStickerNum(Math_GetRandomInt(0, eItems_GetStickersCount() - 1));
				
				switch (g_iSkinDefIndex[client][iWeaponDefIndex])
				{
					case 562, 561, 560, 559, 558, 806, 696, 694, 693, 665, 610, 521, 462, 861, 941, 996, 997, 998, 994, 1006, 1012, 1024, 1023, 1043:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.65);
					}
					case 572, 571, 570, 569, 568, 413, 418, 419, 420, 421, 416, 415, 417, 618, 619, 617, 409, 38, 856, 855, 854, 853, 852, 453, 445, 213, 210, 197, 196, 71, 67, 61, 51, 48, 
					37, 36, 34, 33, 32, 28, 1026, 1017:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.08);
					}
					case 577, 576, 575, 574, 573, 808, 644, 1044:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.85);
					}
					case 582, 581, 580:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.48);
					}
					case 579, 578, 410, 411, 858, 857, 817, 807, 803, 802, 718, 710, 685, 664, 662, 654, 650, 645, 641, 626, 624, 622, 616, 599, 590, 549, 547, 542, 786, 785, 784, 783, 782, 
					781, 780, 779, 778, 777, 776, 775, 534, 518, 499, 498, 482, 452, 451, 450, 423, 407, 406, 405, 402, 399, 393, 360, 355, 354, 349, 345, 337, 313, 312, 311, 310, 306, 305, 
					280, 263, 257, 238, 237, 228, 224, 223, 919, 759, 757, 758, 760, 761, 862, 742, 867, 746, 743, 744, 739, 741, 868, 727, 728, 729, 730, 726, 733, 871, 870, 873, 970, 1027,
					1015, 1021, 1019, 1020, 1051, 1049:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.50);
					}
					case 98, 12, 40, 143, 5, 77, 72, 175, 735, 755, 753, 621, 620, 333, 332, 322, 297, 277, 101, 866, 151, 798, 147, 78, 1030, 170:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.06, 0.80);
					}
					case 414, 552:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.40, 1.00);
					}
					case 59:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.01, 0.26);
					}
					case 851, 813, 584, 793, 536, 523, 522, 438, 369, 362, 358, 339, 309, 295, 291, 269, 260, 256, 252, 249, 248, 246, 227, 225, 218, 913, 1016:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.40);
					}
					case 850, 483:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.14, 0.65);
					}
					case 849, 842, 836, 809, 804, 642, 636, 627, 557, 470, 469, 468, 400, 394, 388, 902, 889, 963, 1003:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.75);
					}
					case 848, 837, 723, 721, 715, 712, 706, 687, 681, 678, 672, 653, 649, 646, 638, 632, 628, 585, 789, 488, 460, 435, 374, 372, 353, 344, 336, 315, 275, 270, 266, 903, 905, 
					886, 859, 864, 734, 732, 950, 959, 966, 991, 990, 982, 993, 1013, 1005, 1025, 1022, 1042:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.70);
					}
					case 847, 551, 288:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.10, 1.00);
					}
					case 845, 655:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.05, 1.00);
					}
					case 844, 839, 810, 720, 719, 707, 704, 699, 692, 667, 663, 611, 601, 600, 587, 799, 797, 529, 512, 507, 502, 495, 479, 467, 466, 465, 464, 457, 456, 454, 426, 401, 384, 
					378, 273, 916, 910, 891, 892, 890, 942, 962, 972, 974, 984, 980, 323, 1010:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.80);
					}
					case 843:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.25, 0.80);
					}
					case 841, 814, 812, 695, 501, 494, 493, 379, 376, 302, 301, 1036, 1046:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.90);
					}
					case 835, 708, 702, 698, 688, 661, 656, 647, 640, 637, 444, 442, 434, 375, 906, 863, 725, 872, 999:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.55);
					}
					case 816:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.14, 1.00);
					}
					case 815:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.02, 0.80);
					}
					case 805, 686, 682, 679, 659, 658, 598, 593, 550, 796, 795, 794, 537, 492, 477, 471, 459, 458, 404, 389, 371, 370, 338, 308, 250, 244, 243, 242, 241, 240, 236, 235, 756, 
					763, 736, 869, 731, 952, 968, 977, 1028, 995, 1029, 1011, 1007, 1008, 1014, 1032:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.60);
					}
					case 801, 380, 943:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.05, 0.70);
					}
					case 703, 359:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.92);
					}
					case 691, 533, 503:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.64);
					}
					case 690, 591:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.63);
					}
					case 800, 443, 335:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.35);
					}
					case 689, 956:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.72);
					}
					case 683:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.03, 0.70);
					}
					case 670:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.51);
					}
					case 666, 648, 639, 633, 630, 606, 597, 544, 535, 433, 424, 307, 285, 234, 896, 1031:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.45);
					}
					case 657:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.86);
					}
					case 651, 545, 480, 182:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.52);
					}
					case 643, 348:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.56);
					}
					case 634, 448, 356, 351, 298, 294, 286, 265, 262, 219, 217, 215, 184, 181, 3, 125, 992:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.30);
					}
					case 608, 509:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.44);
					}
					case 603:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.06, 1.00);
					}
					case 592:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.05, 0.80);
					}
					case 586:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.54);
					}
					case 583:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.66);
					}
					case 556:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.77);
					}
					case 555, 319:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.43);
					}
					case 553:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.81);
					}
					case 548:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.99);
					}
					case 752, 387, 382, 221:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.25);
					}
					case 790, 788, 373:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.83);
					}
					case 530:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.61);
					}
					case 527, 180, 1034:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.76);
					}
					case 515, 437, 299, 274, 272, 271, 268, 231, 230, 220, 1033:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.20);
					}
					case 511:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.14, 0.85);
					}
					case 506:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.67);
					}
					case 500, 914:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.62);
					}
					case 490:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.02, 0.87);
					}
					case 489, 425, 386:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.46);
					}
					case 481:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.32);
					}
					case 449:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.33);
					}
					case 441:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.39);
					}
					case 440, 326, 325, 1002:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.10);
					}
					case 436:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.25, 0.35);
					}
					case 432, 395:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.10, 0.20);
					}
					case 428:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.10, 0.85);
					}
					case 427:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.10, 0.90);
					}
					case 398:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.35, 0.80);
					}
					case 396:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.47);
					}
					case 392:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.06, 0.35);
					}
					case 385:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.06, 0.49);
					}
					case 383, 907, 888:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.68);
					}
					case 381:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.02, 0.25);
					}
					case 366, 365, 276:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.58);
					}
					case 330, 329, 327, 191:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.22);
					}
					case 328, 917:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.01, 0.70);
					}
					case 320, 293, 251:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.08, 0.50);
					}
					case 314:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.03, 0.50);
					}
					case 304:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.15, 0.80);
					}
					case 296, 162:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.18);
					}
					case 290:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.38);
					}
					case 289, 282:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.10, 0.70);
					}
					case 287, 264:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.10, 0.60);
					}
					case 283:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.08, 0.75);
					}
					case 281:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.05, 0.75);
					}
					case 279, 255:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.18, 1.00);
					}
					case 278:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.06, 0.58);
					}
					case 267:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.05, 0.45);
					}
					case 261:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.05, 0.50);
					}
					case 259:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.10, 0.40);
					}
					case 253:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.03);
					}
					case 229, 174:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.28);
					}
					case 226, 154:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.02, 0.40);
					}
					case 214, 212, 211, 185, 70:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.12);
					}
					case 189:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.10, 0.22);
					}
					case 187:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.42);
					}
					case 178:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.08, 0.22);
					}
					case 177:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.02, 0.18);
					}
					case 156:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.08, 0.32);
					}
					case 155:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.02, 0.46);
					}
					case 153:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.26, 0.60);
					}
					case 73:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.14);
					}
					case 60, 11:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.10, 0.26);
					}
					case 10:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.12, 0.38);
					}
					case 911:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.57);
					}
					case 899:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.14, 0.60);
					}
					case 900:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.05, 0.65);
					}
					case 860:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.06, 0.55);
					}
					case 762, 865:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.06, 0.50);
					}
					case 946:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.84);
					}
					case 971:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.73);
					}
					case 958, 1041:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.79);
					}
					case 985:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.98);
					}
					case 979:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.02, 0.90);
					}
					case 1050:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 0.97);
					}
					default:
					{
						g_fWeaponSkinWear[client][iWeaponDefIndex] = Math_GetRandomFloat(0.00, 1.00);
					}
				}
			}
		}
		
		SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
		SDKHook(client, SDKHook_WeaponEquip, SDK_OnWeaponEquip);
	}
}

Action GiveNamedItemPre(int client, char szClassname[64], CEconItemView &pItem, bool &bIgnoredCEconItemView, bool &bOriginIsNULL, float fOrigin[3])
{
	if (!IsValidClient(client))
	{
		return Plugin_Continue;
	}
	
	int clientTeam = GetClientTeam(client);
	
	if (clientTeam < CS_TEAM_T)
	{
		return Plugin_Handled;
	}
	
	int iDefIndex = eItems_GetWeaponDefIndexByClassName(szClassname);
	
	if (iDefIndex <= -1)
	{
		return Plugin_Continue;
	}
	
	if (!eItems_IsDefIndexKnife(iDefIndex))
	{
		return Plugin_Continue;
	}
	
	if (!eItems_IsDefIndexKnife(g_iStoredKnife[client]))
	{
		return Plugin_Continue;
	}
	
	eItems_GetWeaponClassNameByDefIndex(g_iStoredKnife[client], szClassname, sizeof(szClassname));
	bIgnoredCEconItemView = true;
	
	return Plugin_Changed;
}

void GiveNamedItemPost(int client, const char[] szClassname, const CEconItemView pItem, int iEntity, bool bOriginIsNULL, const float fOrigin[3])
{
	int iDefIndex = eItems_GetWeaponDefIndexByClassName(szClassname);
	
	if (iDefIndex <= -1)
	{
		return;
	}
	
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
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[0];
		}
		case 4:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[1];
		}
		case 32:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[2];
		}
		case 61:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[3];
		}
		case 36:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[4];
		}
		case 1:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[5];
		}
		case 2:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[6];
		}
		case 3:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[7];
		}
		case 30:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[8];
		}
		case 63:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[9];
		}
		case 64:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[10];
		}
		case 35:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[11];
		}
		case 25:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[12];
		}
		case 27:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[13];
		}
		case 29:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[14];
		}
		case 26:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[15];
		}
		case 17:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[16];
		}
		case 34:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[17];
		}
		case 33:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[18];
		}
		case 24:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[19];
		}
		case 19:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[20];
		}
		case 13:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[21];
		}
		case 7:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[22];
		}
		case 38:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[23];
		}
		case 10:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[24];
		}
		case 16:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[25];
		}
		case 60:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[26];
		}
		case 8:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[27];
		}
		case 40:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[28];
		}
		case 39:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[29];
		}
		case 9:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[30];
		}
		case 11:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[31];
		}
		case 14:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[32];
		}
		case 28:
		{
			g_iStatTrakKills[attacker][iDefIndex] = iWeaponsReturn[33];
		}
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

Action WeaponCanUsePre(int client, int iWeapon, bool & bPickup)
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
    {
        return Plugin_Continue;
    }

    if(!eItems_IsValidWeapon(iWeapon))
    {
        return Plugin_Continue;
    }

    int iPrevOwner = GetEntProp(iWeapon, Prop_Send, "m_hPrevOwner");
    if(iPrevOwner > 0)
    {
        return Plugin_Continue;
    }

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
	ResetPack(datapack);
	int client = ReadPackCell(datapack);
	int iWeapon = ReadPackCell(datapack);
	delete datapack;

	if(!IsValidClient(client))
	{
		return Plugin_Continue;
	}

	if(!eItems_IsValidWeapon(iWeapon))
	{
		return Plugin_Continue;
	}

	int iWeaponSlot = eItems_GetWeaponSlotByWeapon(iWeapon);
	if (iWeaponSlot == CS_SLOT_C4)
	{
		return Plugin_Continue;
	}

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
		{
			continue;
		}

		GetEntityClassname(i, szWeaponClassname, sizeof(szWeaponClassname));
		if((StrContains(szWeaponClassname, "weapon_")) == -1)
		{
			continue;
		}

		if(GetEntProp(i, Prop_Send, "m_hOwnerEntity") != -1)
		{
			continue;
		}
		
		int iDefIndex;
		if((iDefIndex = eItems_GetWeaponDefIndexByClassName(szWeaponClassname)) == -1)
		{
			continue;
		}

		if(eItems_IsDefIndexKnife(iDefIndex))
		{
			continue;
		}

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
			{
				SDKCall(g_hSetRank, client, MEDAL_CATEGORY_SEASON_COIN, g_iCoin[client]);
			}
			else
			{
				SDKCall(g_hSetRank, client, MEDAL_CATEGORY_SEASON_COIN, g_iCoin[client]);
			}
		}
		
		if (g_iCustomPlayerChance[client] <= 35)
		{
			CreateTimer(1.3, Timer_ApplyAgent, GetClientUserId(client));
		}
	}
}

public Action Timer_ApplyAgent(Handle hTimer, any client)
{
	int i = GetClientOfUserId(client);
	
	if(i != 0 && IsClientInGame(i))
    {
        if (GetClientTeam(i) == CS_TEAM_CT)
		{
			char szModel[64];
			
			if(eItems_GetAgentPlayerModelByDefIndex(g_iCTModel[i], szModel, sizeof(szModel)))
			{
				SetEntityModel(i, szModel);
				
				if (g_iPatchChance[i] <= 30)
				{
					if (g_iPatchComboChance[i] <= 65)
					{
						switch (g_iRndPatchCombo[i])
						{
							case 1:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][0], 4, 0);
							}
							case 2:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][0], 4, 0);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][1], 4, 1);
							}
							case 3:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][0], 4, 0);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][2], 4, 2);
							}
							case 4:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][0], 4, 0);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][3], 4, 3);
							}
							case 5:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][0], 4, 0);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][1], 4, 1);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][2], 4, 2);
							}
							case 6:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][1], 4, 1);
							}
							case 7:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][1], 4, 1);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][2], 4, 2);
							}
							case 8:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][1], 4, 1);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][3], 4, 3);
							}
							case 9:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][0], 4, 0);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][2], 4, 2);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][3], 4, 3);
							}
							case 10:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][2], 4, 2);
							}
							case 11:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][2], 4, 2);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][3], 4, 3);
							}
							case 12:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][1], 4, 1);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][2], 4, 2);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][3], 4, 3);
							}
							case 13:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][3], 4, 3);
							}
							case 14:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][0], 4, 0);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][1], 4, 1);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][3], 4, 3);
							}
						}
					}
					else
					{
						switch (g_iRndPatchCombo[i])
						{
							case 1:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][0], 4, 0);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][1], 4, 1);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][2], 4, 2);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][3], 4, 3);
							}
							case 2:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndSamePatch[i], 4, 0);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndSamePatch[i], 4, 1);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndSamePatch[i], 4, 2);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndSamePatch[i], 4, 3);
							}
						}
					}
				}	
			}
		}
		else if (GetClientTeam(i) == CS_TEAM_T)
		{
			char szModel[64];
			
			if(eItems_GetAgentPlayerModelByDefIndex(g_iTModel[i], szModel, sizeof(szModel)))
			{
				SetEntityModel(i, szModel);
				
				if (g_iPatchChance[i] <= 40)
				{
					if (g_iPatchComboChance[i] <= 65)
					{
						switch (g_iRndPatchCombo[i])
						{
							case 1:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][0], 4, 0);
							}
							case 2:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][0], 4, 0);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][1], 4, 1);
							}
							case 3:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][0], 4, 0);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][2], 4, 2);
							}
							case 4:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][0], 4, 0);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][3], 4, 3);
							}
							case 5:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][0], 4, 0);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][1], 4, 1);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][2], 4, 2);
							}
							case 6:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][1], 4, 1);
							}
							case 7:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][1], 4, 1);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][2], 4, 2);
							}
							case 8:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][1], 4, 1);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][3], 4, 3);
							}
							case 9:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][0], 4, 0);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][2], 4, 2);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][3], 4, 3);
							}
							case 10:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][2], 4, 2);
							}
							case 11:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][2], 4, 2);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][3], 4, 3);
							}
							case 12:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][1], 4, 1);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][2], 4, 2);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][3], 4, 3);
							}
							case 13:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][3], 4, 3);
							}
							case 14:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][0], 4, 0);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][1], 4, 1);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][3], 4, 3);
							}
						}
					}
					else
					{
						switch (g_iRndPatchCombo[i])
						{
							case 1:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][0], 4, 0);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][1], 4, 1);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][2], 4, 2);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndPatch[i][3], 4, 3);
							}
							case 2:
							{
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndSamePatch[i], 4, 0);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndSamePatch[i], 4, 1);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndSamePatch[i], 4, 2);
								SetEntProp(i, Prop_Send, "m_vecPlayerPatchEconIndices", g_iRndSamePatch[i], 4, 3);
							}
						}
					}
				}	
			}
		}
    }
	
	return Plugin_Stop;
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
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[0];
			}
			case 4:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[1];
			}
			case 32:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[2];
			}
			case 61:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[3];
			}
			case 36:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[4];
			}
			case 1:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[5];
			}
			case 2:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[6];
			}
			case 3:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[7];
			}
			case 30:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[8];
			}
			case 63:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[9];
			}
			case 64:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[10];
			}
			case 35:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[11];
			}
			case 25:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[12];
			}
			case 27:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[13];
			}
			case 29:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[14];
			}
			case 26:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[15];
			}
			case 17:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[16];
			}
			case 34:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[17];
			}
			case 33:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[18];
			}
			case 24:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[19];
			}
			case 19:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[20];
			}
			case 13:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[21];
			}
			case 7:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[22];
			}
			case 38:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[23];
			}
			case 10:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[24];
			}
			case 16:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[25];
			}
			case 60:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[26];
			}
			case 8:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[27];
			}
			case 40:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[28];
			}
			case 39:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[29];
			}
			case 9:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[30];
			}
			case 11:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[31];
			}
			case 14:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[32];
			}
			case 28:
			{
				g_iStatTrakKills[client][iDefIndex] = iWeaponsReturn[33];
			}
		}
		
		if (eItems_IsDefIndexKnife(iDefIndex))
		{
			if (g_iStatTrakChance[client][iDefIndex] <= 30)
			{
				pDynamicAttributes.SetOrAddAttributeValue(80, g_iStatTrakKills[client][iDefIndex]);
				pDynamicAttributes.SetOrAddAttributeValue(81, 0);
				
				g_bKnifeHasStatTrak[client][iDefIndex] = true;
			}
		}
		else
		{
			if (g_iStatTrakChance[client][iDefIndex] <= 30)
			{
				pDynamicAttributes.SetOrAddAttributeValue(80, g_iStatTrakKills[client][iDefIndex]);
				pDynamicAttributes.SetOrAddAttributeValue(81, 0);
				
				SetEntProp(iEntity, Prop_Send, "m_iEntityQuality", 9);
			}
			
			switch (g_iSkinDefIndex[client][iDefIndex])
			{
				case 254, 253, 252, 110, 25, 242, 245, 249, 236, 244, 92, 147, 136, 96, 251, 250, 21, 800, 28, 101, 158, 344, 326, 328, 325, 327, 329, 332, 32, 294, 323, 333, 330, 
				179, 168, 167, 169, 171, 379, 371, 367, 368, 372, 370, 374, 378, 375, 377, 373, 369, 376, 750, 747, 795, 749, 752, 793, 796, 751, 797, 799, 798, 748, 753, 794, 755, 
				90, 754, 39, 37, 33, 2, 233, 243, 240, 46, 27, 241, 523, 30, 141, 157, 99, 8, 148, 124, 170, 116, 247, 235, 159, 321, 84, 318, 322, 319, 238, 15, 95, 100, 22, 119, 
				248, 237, 246, 3, 34, 234, 74, 78, 47, 107, 149, 792, 791, 789, 779, 787, 788, 781, 776, 786, 780, 790, 783, 782, 777, 784, 778, 775, 785, 153, 172, 111, 70, 17, 135:
				{
					if (g_iSouvenirChance[client][iDefIndex] <= 30)
					{
						pDynamicAttributes.RemoveAttributeByDefIndex(80);
						pDynamicAttributes.RemoveAttributeByDefIndex(81);
						SetEntProp(iEntity, Prop_Send, "m_iEntityQuality", 12);
					}
				}
			}
		}
		
		if (g_iStickerChance[client][iDefIndex] <= 30)
		{
			if (g_iStickerComboChance[client][iDefIndex] <= 65)
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
	{
		AcceptEntityInput(iEntity, "KillHierarchy");
	}
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
		{
			OnClientDisconnect(i);
		}
	}
}

stock bool IsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && IsFakeClient(client) && !IsClientSourceTV(client);
} 

stock int FloatToInt(const char[] szValue, any ...)
{
	int len = strlen(szValue) + 255;
	char[] myFormattedString = new char[len];
	VFormat(myFormattedString, len, szValue, 2);
 
	return StringToInt(myFormattedString);
}

stock bool IsMapWeapon(int iWeapon, bool bRemove = false)
{
	if(g_ArrayMapWeapons == null)
	{
		return false;
	}
	for(int i = 0; i < g_ArrayMapWeapons.Length; i++)
	{
		if(g_ArrayMapWeapons.Get(i) != iWeapon)
		{
			continue;
		}

		if(bRemove)
		{
			g_ArrayMapWeapons.Erase(i);
		}
		return true;
	}
	return false;
}