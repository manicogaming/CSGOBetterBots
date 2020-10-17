/*
 * ============================================================================
 *
 *  [CS:GO] Weapon Stickers.
 *  Copyright (C) 2020 - Bruno "quasemago" Ronning <brunoronningfn@gmail.com>
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, per version 3 of the License, or
 *  any later version.	
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * ============================================================================
*/

/**
 * Includes.
 */
#include <sourcemod>
#include <sdktools>
#include <multicolors>
#include <PTaH>
#include <eItems>

#undef REQUIRE_EXTENSIONS
#include <sourcescramble>

#pragma semicolon 1
#pragma newdecls required

/**
 * Sub.
 */
#include "quasemago/csgo_weaponstickers/globals.inc"
#include "quasemago/csgo_weaponstickers/helpers.inc"
#include "quasemago/csgo_weaponstickers/commands.inc"
#include "quasemago/csgo_weaponstickers/menus.inc"
#include "quasemago/csgo_weaponstickers/database.inc"
#include "quasemago/csgo_weaponstickers/api.inc"

/**
 * Plugin Init.
 */
public Plugin myinfo = 
{
	name = "[CS:GO] Weapon Stickers",
	author = "quasemago",
	description = "Stickers for Weapons",
	version = PLUGIN_VERSION,
	url = "https://github.com/quasemago"
};

public void OnPluginStart()
{
	if (GetEngineVersion() != Engine_CSGO)
	{
		SetFailState("Only CS:GO support!");
		return;
	}

	// Translations.
	LoadTranslations("common.phrases");
	LoadTranslations("csgo_weaponstickers.phrases");

	// ConVars.
	CreateConVar("sm_weaponstickers_version", PLUGIN_VERSION, "Plugin Version", FCVAR_NOTIFY|FCVAR_SPONLY|FCVAR_DONTRECORD);
	g_cvarEnabled = CreateConVar("sm_weaponstickers_enabled", "1", "Enable or disable Plugin.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_cvarUpdateViewModel = CreateConVar("sm_weaponstickers_updateviewmodel", "0", "Specifies whether the view model will be updated when changing stickers (P.S: the player will experience a small rollback).", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_cvarReuseTime = CreateConVar("sm_weaponstickers_reusetime", "5", "Specifies how many seconds it will be necessary to wait to update the stickers again.", FCVAR_NOTIFY, true, 0.1);
	g_cvarOverrideViewItem = CreateConVar("sm_weaponstickers_overrideview", "1", "Specifies whether the plugin will override the weapon view (p.s: Recommended if !ws plugin is used).", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_cvarFlagUse = CreateConVar("sm_weaponstickers_flag", "", "Specifies the required flag (e.g: 'a' for reserved slot).", FCVAR_NOTIFY);

	AutoExecConfig(true, "csgo_weaponstickers");
	CSetPrefix("{green}[Weapon Stickers]{default}");

	// Forward event to modules.
	LoadSDK();
	LoadCommands();
	LoadDatabase();

	// Hooks.
	PTaH(PTaH_GiveNamedItemPre, Hook, OnGiveNamedItemPre);
	PTaH(PTaH_GiveNamedItemPost, Hook, OnGiveNamedItemPost);
	
	// Late Load.
	if (g_isLateLoad)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || IsFakeClient(i))
			{
				continue;
			}

			OnClientPostAdminCheck(i);
		}
	}
}

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int errMax)
{
	g_isLateLoad = late;

	/* API */
	LoadAPI();

	/* External Natives */
	MarkNativeAsOptional("MemoryBlock.MemoryBlock");
	MarkNativeAsOptional("MemoryBlock.Address.get");

	/* Library */
	RegPluginLibrary("csgo_weaponstickers");
	return APLRes_Success;
}

/**
 * Forwards.
 */
public void OnConfigsExecuted()
{
	g_cvarFlagUse.GetString(g_requiredFlag, sizeof(g_requiredFlag));
}

public void eItems_OnItemsSynced()
{
	g_stickerCount = eItems_GetStickersCount();
	g_stickerSetsCount = eItems_GetStickersSetsCount();

	RequestFrame(Frame_ItemsSync);
}

public void Frame_ItemsSync(any data)
{
	// Load stickers.
	for (int i = 0; i < g_stickerSetsCount; i++)
	{
		g_StickerSet[i].m_Id = eItems_GetStickerSetIdByStickerSetNum(i);
		eItems_GetStickerSetDisplayNameByStickerSetNum(i, g_StickerSet[i].m_displayName, MAX_LENGTH_DISPLAY);

		if (g_StickerSet[i].m_Stickers != null)
		{
			delete g_StickerSet[i].m_Stickers;
		}

		g_StickerSet[i].m_Stickers = new ArrayList(1);
		for (int j = 0; j < g_stickerCount; j++)
		{
			if (eItems_IsStickerInSet(j, g_StickerSet[i].m_Id))
			{
				g_Sticker[j].m_setId = g_StickerSet[i].m_Id;
				g_StickerSet[i].m_Stickers.Push(j);
			}
		}
	}

	for (int i = 0; i < g_stickerCount; i++)
	{
		g_Sticker[i].m_defIndex = eItems_GetStickerDefIndexByStickerNum(i);
		eItems_GetStickerDisplayNameByStickerNum(i, g_Sticker[i].m_displayName, MAX_LENGTH_DISPLAY);
	}
}

public void OnClientPostAdminCheck(int client)
{
	if (!g_cvarEnabled.BoolValue || IsFakeClient(client))
	{
		return;
	}

	LoadClientData(client);
}

public void OnClientDisconnect(int client)
{
	g_playerReuseTime[client] = 0;
	g_isStickerRefresh[client] = false;

	for (int i = 0; i < MAX_WEAPONS; i++)
	{
		for (int j = 0; j < MAX_STICKERS_SLOT; j++)
		{
			g_PlayerWeapon[client][i].m_sticker[j] = DEFAULT_PAINT;
		}
	}

	MenusClientDisconnect(client);
}

/**
 * Events & Hooks.
 */
public Action OnGiveNamedItemPre(int client, char classname[64], CEconItemView &item, bool &ignoredCEconItemView, bool &isOriginNULL, float origin[3])
{
	if (!g_cvarEnabled.BoolValue || !g_cvarOverrideViewItem.BoolValue)
	{
		return Plugin_Continue;
	}

	if (IsClientInGame(client) && !IsFakeClient(client))
	{
		int defIndex = eItems_GetWeaponDefIndexByClassName(classname);
		if (IsValidDefIndex(defIndex))
		{
			if (ClientWeaponHasStickers(client, defIndex))
			{
				ignoredCEconItemView = true;
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}

public void OnGiveNamedItemPost(int client, const char[] classname, const CEconItemView item, int entity, bool isOriginNULL, const float origin[3])
{
	if (!g_cvarEnabled.BoolValue)
	{
		return;
	}

	SetWeaponSticker(client, entity);
}

void SetWeaponSticker(int client, int entity)
{
	if (IsClientInGame(client) && !IsFakeClient(client) && IsValidEntity(entity))
	{
		int defIndex = eItems_GetWeaponDefIndexByWeapon(entity);
		if (IsValidDefIndex(defIndex) && ClientWeaponHasStickers(client, defIndex))
		{
			int index = eItems_GetWeaponNumByDefIndex(defIndex);
			if (index != -1)
			{
				// Check if item is already initialized by external ws.
				if (GetEntProp(entity, Prop_Send, "m_iItemIDHigh") < 16384)
				{
					static int IDHigh = 16384;
					SetEntProp(entity, Prop_Send, "m_iItemIDLow", -1);
					SetEntProp(entity, Prop_Send, "m_iItemIDHigh", IDHigh++);
					SetEntProp(entity, Prop_Send, "m_iAccountID", GetSteamAccountID(client, true));
					SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
					SetEntPropEnt(entity, Prop_Send, "m_hPrevOwner", -1);
				}

				// Change stickers.
				Address pWeapon = GetEntityAddress(entity);
				if (pWeapon == Address_Null)
				{
					CPrintToChat(client, "%t", "Unknown Error");
					return;
				}

				Address pEconItemView = pWeapon + view_as<Address>(g_econItemOffset);
			
				bool isUpdated = false;
				for (int i = 0; i < MAX_STICKERS_SLOT; i++)
				{
					if (g_PlayerWeapon[client][index].m_sticker[i] != 0)
					{
						// Sticker updated.
						isUpdated = true;

						SetAttributeValue(client, pEconItemView, g_PlayerWeapon[client][index].m_sticker[i], "sticker slot %i id", i);
						SetAttributeValue(client, pEconItemView, view_as<int>(0.0), "sticker slot %i wear", i); // default wear.
					}
				}

				// Update viewmodel if enabled.
				if (isUpdated && g_isStickerRefresh[client])
				{
					g_isStickerRefresh[client] = false;
			
					if (g_cvarUpdateViewModel.BoolValue)
					{
						PTaH_ForceFullUpdate(client);
					}
				}
			}
		}
	}	
}

/**
 * Functions.
 */
void LoadSDK()
{	
	Handle gameConf = LoadGameConfigFile("csgo_weaponstickers.games");

	if (gameConf == null)
	{
		SetFailState("Game config was not loaded right.");
		return;
	}

	// Get Server Platform.
	g_ServerPlatform = view_as<ServerPlatform>(GameConfGetOffset(gameConf, "ServerPlatform"));
	if (g_ServerPlatform == OS_Mac || g_ServerPlatform == OS_Unknown)
	{
		SetFailState("Only Linux/Windows support!");
		return;
	}

	// Setup CEconItem::GetItemDefinition.
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(gameConf, SDKConf_Virtual, "CEconItem::GetItemDefinition");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);

	if (!(g_SDKGetItemDefinition = EndPrepSDKCall()))
	{
		SetFailState("Method \"CEconItem::GetItemDefinition\" was not loaded right.");
		return;
	}

	// Setup CEconItemDefinition::GetNumSupportedStickerSlots.
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(gameConf, SDKConf_Virtual, "CEconItemDefinition::GetNumSupportedStickerSlots");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);

	if (!(g_SDKGetNumSupportedStickerSlots = EndPrepSDKCall()))
	{
		SetFailState("Method \"CEconItemDefinition::GetNumSupportedStickerSlots\" was not loaded right.");
		return;
	}

	// Setup ItemSystem.
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(gameConf, SDKConf_Signature, "ItemSystem");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);

	Handle SDKItemSystem;
	if (!(SDKItemSystem = EndPrepSDKCall()))
	{
		SetFailState("Method \"ItemSystem\" was not loaded right.");
		return;
	}

	g_pItemSystem = SDKCall(SDKItemSystem);
	if (g_pItemSystem == Address_Null)
	{
		SetFailState("Failed to get \"ItemSystem\" pointer address.");
		return;
	}

	delete SDKItemSystem;
	g_pItemSchema = g_pItemSystem + view_as<Address>(4);

	// Setup CAttributeList::AddAttribute.
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(gameConf, SDKConf_Signature, "CAttributeList::AddAttribute");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);

	if (g_ServerPlatform == OS_Windows)
	{
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	}

	if (!(g_SDKAddAttribute = EndPrepSDKCall()))
	{
		SetFailState("Method \"CAttributeList::AddAttribute\" was not loaded right.");
		return;
	}

	// Linux only.
	if (g_ServerPlatform == OS_Linux)
	{
		// Setup CEconItemSystem::GenerateAttribute.
		StartPrepSDKCall(SDKCall_Raw);
		PrepSDKCall_SetFromConf(gameConf, SDKConf_Signature, "CEconItemSystem::GenerateAttribute");
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
		PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);

		if (!(g_SDKGenerateAttribute = EndPrepSDKCall()))
		{
			SetFailState("Method \"CEconItemSystem::GenerateAttribute\" was not loaded right.");
			return;
		}
	}

	// Setup CEconItemSchema::GetAttributeDefinitionByName.
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(gameConf, SDKConf_Signature, "CEconItemSchema::GetAttributeDefinitionByName");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);

	if (!(g_SDKGetAttributeDefinitionByName = EndPrepSDKCall()))
	{
		SetFailState("Method \"CEconItemSchema::GetAttributeDefinitionByName\" was not loaded right.");
		return;
	}

	// Get Offsets.
	FindGameConfOffset(gameConf, g_networkedDynamicAttributesOffset, "m_NetworkedDynamicAttributesForDemos");
	FindGameConfOffset(gameConf, g_attributeListReadOffset, "CAttributeList_Read");
	FindGameConfOffset(gameConf, g_attributeListCountOffset, "CAttributeList_Count");

	delete gameConf;

	// Find netprops Offsets.
	g_econItemOffset = FindSendPropOffset("CBaseCombatWeapon", "m_Item");
}

void RefreshClientWeapon(int client, int index)
{
	// Validate weapon defIndex or knife.
	int defIndex = eItems_GetWeaponDefIndexByWeaponNum(index);
	if (!IsValidDefIndex(defIndex) || eItems_IsDefIndexKnife(defIndex))
	{
		return;
	}

	// Get weapon classname.
	char classname[MAX_LENGTH_CLASSNAME];
	if (!eItems_GetWeaponClassNameByWeaponNum(index, classname, sizeof(classname)))
	{
		return;
	}

	int size = GetEntPropArraySize(client, Prop_Send, "m_hMyWeapons");
	for (int i = 0; i < size; i++)
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i);
		if (eItems_IsValidWeapon(weapon))
		{
			int temp = eItems_GetWeaponNumByWeapon(weapon);
			if (temp == index)
			{
				eItems_RespawnWeapon(client, weapon);
				break;
			}
		}
	}
}