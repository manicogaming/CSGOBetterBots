/*  CS:GO Weapons&Knives SourceMod Plugin
 *
 *  Copyright (C) 2017 Kağan 'kgns' Üstüngel
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <PTaH>
#include <csgo_weaponstickers>

#pragma semicolon 1
#pragma newdecls required

#include "weapons/globals.sp"
#include "weapons/forwards.sp"
#include "weapons/hooks.sp"
#include "weapons/helpers.sp"
#include "weapons/database.sp"
#include "weapons/config.sp"
#include "weapons/menus.sp"

public Plugin myinfo = 
{
	name = "Weapons & Knives",
	author = "kgns | oyunhost.net",
	description = "All in one weapon skin management",
	version = "1.6.0",
	url = "https://www.oyunhost.net"
};

public void OnPluginStart()
{
	if(GetEngineVersion() != Engine_CSGO)
	{
		SetFailState("Only CS:GO servers are supported!");
		return;
	}
	
	if(PTaH_Version() < 101000)
	{
		char sBuf[16];
		PTaH_Version(sBuf, sizeof(sBuf));
		SetFailState("PTaH extension needs to be updated. (Installed Version: %s - Required Version: 1.1.0+) [ Download from: https://ptah.zizt.ru ]", sBuf);
		return;
	}
	
	LoadTranslations("weapons.phrases");
	
	g_Cvar_DBConnection 			= CreateConVar("sm_weapons_db_connection", 			"storage-local", 	"Database connection name in databases.cfg to use");
	g_Cvar_TablePrefix 			= CreateConVar("sm_weapons_table_prefix", 			"", 				"Prefix for database table (example: 'xyz_')");
	g_Cvar_ChatPrefix 			= CreateConVar("sm_weapons_chat_prefix", 			"[oyunhost.net]", 	"Prefix for chat messages");
	g_Cvar_KnifeStatTrakMode 		= CreateConVar("sm_weapons_knife_stattrak_mode", 	"0", 				"0: All knives show the same StatTrak counter (total knife kills) 1: Each type of knife shows its own separate StatTrak counter");
	g_Cvar_EnableFloat 			= CreateConVar("sm_weapons_enable_float", 			"1", 				"Enable/Disable weapon float options");
	g_Cvar_EnableNameTag 			= CreateConVar("sm_weapons_enable_nametag", 		"1", 				"Enable/Disable name tag options");
	g_Cvar_EnableStatTrak 			= CreateConVar("sm_weapons_enable_stattrak", 		"1", 				"Enable/Disable StatTrak options");
	g_Cvar_EnableSeed				= CreateConVar("sm_weapons_enable_seed",			"1",				"Enable/Disable Seed options");
	g_Cvar_FloatIncrementSize 		= CreateConVar("sm_weapons_float_increment_size", 	"0.05", 			"Increase/Decrease by value for weapon float");
	g_Cvar_EnableWeaponOverwrite 	= CreateConVar("sm_weapons_enable_overwrite", 		"1", 				"Enable/Disable players overwriting other players' weapons (picked up from the ground) by using !ws command");
	g_Cvar_GracePeriod 			= CreateConVar("sm_weapons_grace_period", 			"0", 				"Grace period in terms of seconds counted after round start for allowing the use of !ws command. 0 means no restrictions");
	g_Cvar_InactiveDays 			= CreateConVar("sm_weapons_inactive_days", 			"30", 				"Number of days before a player (SteamID) is marked as inactive and his data is deleted. (0 or any negative value to disable deleting)");
	
	AutoExecConfig(true, "weapons");
	
	RegConsoleCmd("buyammo1", CommandWeaponSkins);
	RegConsoleCmd("sm_ws", CommandWeaponSkins);
	RegConsoleCmd("buyammo2", CommandKnife);
	RegConsoleCmd("sm_knife", CommandKnife);
	RegConsoleCmd("sm_nametag", CommandNameTag);
	RegConsoleCmd("sm_wslang", CommandWSLang);
	RegConsoleCmd("sm_seed", CommandSeedMenu);
	
	PTaH(PTaH_GiveNamedItemPre, Hook, GiveNamedItemPre);
	PTaH(PTaH_GiveNamedItemPost, Hook, GiveNamedItemPost);
	
	ConVar g_cvGameType = FindConVar("game_type");
	ConVar g_cvGameMode = FindConVar("game_mode");
	
	if(g_cvGameType.IntValue == 1 && g_cvGameMode.IntValue == 2)
	{
		PTaH(PTaH_WeaponCanUsePre, Hook, WeaponCanUsePre);
	}
	
	AddCommandListener(ChatListener, "say");
	AddCommandListener(ChatListener, "say2");
	AddCommandListener(ChatListener, "say_team");
}

public Action CommandWeaponSkins(int client, int args)
{
	if (IsValidClient(client))
	{
		int menuTime;
		if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
		{
			CreateMainMenu(client).Display(client, menuTime);
		}
		else
		{
			PrintToChat(client, " %s \x02%t", g_ChatPrefix, "GracePeriod", g_iGracePeriod);
		}
	}
	return Plugin_Handled;
}

public Action CommandSeedMenu(int client, int args)
{
	if(!g_bEnableSeed)
	{
		ReplyToCommand(client, " %s \x02%T", g_ChatPrefix, "SeedDisabled", client);
		return Plugin_Handled;
	}
	ReplyToCommand(client, " %s \x04%T", g_ChatPrefix, "SeedExplanation", client);
	return Plugin_Handled;
}

public Action CommandKnife(int client, int args)
{
	if (IsValidClient(client))
	{
		int menuTime;
		if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
		{
			CreateKnifeMenu(client).Display(client, menuTime);
		}
		else
		{
			PrintToChat(client, " %s \x02%t", g_ChatPrefix, "GracePeriod", g_iGracePeriod);
		}
	}
	return Plugin_Handled;
}

public Action CommandWSLang(int client, int args)
{
	if (IsValidClient(client))
	{
		int menuTime;
		if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
		{
			CreateLanguageMenu(client).Display(client, menuTime);
		}
		else
		{
			PrintToChat(client, " %s \x02%t", g_ChatPrefix, "GracePeriod", g_iGracePeriod);
		}
	}
	return Plugin_Handled;
}

public Action CommandNameTag(int client, int args)
{
	if(!g_bEnableNameTag)
	{
		ReplyToCommand(client, " %s \x02%T", g_ChatPrefix, "NameTagDisabled", client);
		return Plugin_Handled;
	}
	ReplyToCommand(client, " %s \x04%T", g_ChatPrefix, "NameTagNew", client);
	return Plugin_Handled;
}

void SetWeaponProps(int client, int entity)
{
	int index = GetWeaponIndex(entity);
	if (index > -1 && g_iSkins[client][index] != 0)
	{
		static int IDHigh = 16384;
		SetEntProp(entity, Prop_Send, "m_iItemIDLow", -1);
		SetEntProp(entity, Prop_Send, "m_iItemIDHigh", IDHigh++);
		SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", g_iSkins[client][index] == -1 ? GetRandomSkin(client, index) : g_iSkins[client][index]);
		SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", !g_bEnableFloat || g_fFloatValue[client][index] == 0.0 ? 0.000001 : g_fFloatValue[client][index] == 1.0 ? 0.999999 : g_fFloatValue[client][index]);
		if (g_bEnableSeed && g_iWeaponSeed[client][index] != -1)
		{
			SetEntProp(entity, Prop_Send, "m_nFallbackSeed", g_iWeaponSeed[client][index]);
		}
		else
		{
			g_iSeedRandom[client][index] = GetRandomInt(0, 8192);
			SetEntProp(entity, Prop_Send, "m_nFallbackSeed", g_iSeedRandom[client][index]);
		}
		
		if(!IsKnife(entity))
		{
			if(g_bEnableStatTrak)
			{
				SetEntProp(entity, Prop_Send, "m_nFallbackStatTrak", g_iStatTrak[client][index] == 1 ? g_iStatTrakCount[client][index] : -1);
				SetEntProp(entity, Prop_Send, "m_iEntityQuality", g_iStatTrak[client][index] == 1 ? 9 : 0);
			}
		}
		else
		{
			if(g_bEnableStatTrak)
			{
				SetEntProp(entity, Prop_Send, "m_nFallbackStatTrak", g_iStatTrak[client][index] == 0 ? -1 : g_iKnifeStatTrakMode == 0 ? GetTotalKnifeStatTrakCount(client) : g_iStatTrakCount[client][index]);
			}
			SetEntProp(entity, Prop_Send, "m_iEntityQuality", 3);
		}
		if (g_bEnableNameTag && strlen(g_NameTag[client][index]) > 0)
		{
			SetEntDataString(entity, FindSendPropInfo("CBaseAttributableItem", "m_szCustomName"), g_NameTag[client][index], 128);
		}
		
		if(IsFakeClient(client))
		{
			switch(GetEntProp(entity, Prop_Send, "m_nFallbackPaintKit"))
			{
				case 562, 561, 560, 559, 558, 806, 696, 694, 693, 665, 610, 521, 462, 861, 941:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.65));
				}
				case 572, 571, 570, 569, 568, 413, 418, 419, 420, 421, 416, 415, 417, 618, 619, 617, 409, 38, 856, 855, 854, 853, 852, 453, 445, 213, 210, 197, 196, 71, 67, 61, 51, 48,
				37, 36, 34, 33, 32, 28:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.08));
				}
				case 577, 576, 575, 574, 573, 808, 644:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.85));
				}
				case 582, 581, 580:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.48));
				}
				case 579, 578, 410, 411, 858, 857, 817, 807, 803, 802, 718, 710, 685, 664, 662, 654, 650, 645, 641, 626, 624, 622, 616, 599, 590, 549, 547, 542, 786, 785, 784, 783, 782,
				781, 780, 779, 778, 777, 776, 775, 534, 518, 499, 498, 482, 452, 451, 450, 423, 407, 406, 405, 402, 399, 393, 360, 355, 354, 349, 345, 337, 313, 312, 311, 310, 306, 305,
				280, 263, 257, 238, 237, 228, 224, 223, 919, 759, 757, 758, 760, 761, 862, 742, 867, 746, 743, 744, 739, 741, 868, 727, 728, 729, 730, 726, 733, 871, 870, 873, 970:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.50));
				}
				case 98, 12, 40, 143, 5, 77, 72, 175, 735, 755, 753, 621, 620, 333, 332, 322, 297, 277, 101, 866, 151:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.06, 0.80));
				}
				case 414, 552:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.40, 1.00));
				}
				case 59:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.01, 0.26));
				}
				case 851, 813, 584, 793, 536, 523, 522, 438, 369, 362, 358, 339, 309, 295, 291, 269, 260, 256, 252, 249, 248, 246, 227, 225, 218, 913:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.40));
				}
				case 850, 483:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.14, 0.65));
				}
				case 849, 842, 836, 809, 804, 642, 636, 627, 557, 470, 469, 468, 400, 394, 388, 902, 889, 963:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.75));
				}
				case 848, 837, 723, 721, 715, 712, 706, 687, 681, 678, 672, 653, 649, 646, 638, 632, 628, 585, 789, 488, 460, 435, 374, 372, 353, 344, 336, 315, 275, 270, 266, 903, 905,
				886, 859, 864, 734, 732, 950, 959, 966:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.70));
				}
				case 847, 551, 288:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.10, 1.00));
				}
				case 845, 655:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.05, 1.00));
				}
				case 844, 839, 810, 720, 719, 707, 704, 699, 692, 667, 663, 611, 601, 600, 587, 799, 797, 529, 512, 507, 502, 495, 479, 467, 466, 465, 464, 457, 456, 454, 426, 401, 384,
				378, 273, 916, 910, 891, 892, 890, 942, 962, 972, 974:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.80));
				}
				case 843:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.25, 0.80));
				}
				case 841, 814, 812, 695, 501, 494, 493, 379, 376, 302, 301:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.90));
				}
				case 835, 708, 702, 698, 688, 661, 656, 647, 640, 637, 444, 442, 434, 375, 906, 863, 725, 872:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.55));
				}
				case 816:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.14, 1.00));
				}
				case 815:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.02, 0.80));
				}
				case 805, 686, 682, 679, 659, 658, 598, 593, 550, 796, 795, 794, 537, 492, 477, 471, 459, 458, 404, 389, 371, 370, 338, 308, 250, 244, 243, 242, 241, 240, 236, 235, 756,
				763, 736, 869, 731, 952, 968:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.60));
				}
				case 801, 380, 943:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.05, 0.70));
				}
				case 703, 359:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.92));
				}
				case 691, 533, 503:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.64));
				}
				case 690, 591:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.63));
				}
				case 800, 443, 335:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.35));
				}
				case 689, 956:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.72));
				}
				case 683:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.03, 0.70));
				}
				case 670:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.51));
				}
				case 666, 648, 639, 633, 630, 606, 597, 544, 535, 433, 424, 307, 285, 234, 896:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.45));
				}
				case 657:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.86));
				}
				case 651, 545, 480, 182:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.52));
				}
				case 643, 348:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.56));
				}
				case 634, 448, 356, 351, 298, 294, 286, 265, 262, 219, 217, 215, 184, 181, 3, 125:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.30));
				}
				case 608, 509:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.44));
				}
				case 603:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.06, 1.00));
				}
				case 592:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.05, 0.80));
				}
				case 586:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.54));
				}
				case 583:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.66));
				}
				case 556:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.77));
				}
				case 555, 319:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.43));
				}
				case 553:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.81));
				}
				case 548:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.99));
				}
				case 752, 387, 382, 221:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.25));
				}
				case 790, 788, 373:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.83));
				}
				case 530:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.61));
				}
				case 527, 180:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.76));
				}
				case 515, 437, 299, 274, 272, 271, 268, 231, 230, 220:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.20));
				}
				case 511:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.14, 0.85));
				}
				case 506:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.67));
				}
				case 500, 914:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.62));
				}
				case 490:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.02, 0.87));
				}
				case 489, 425, 386:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.46));
				}
				case 481:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.32));
				}
				case 449:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.33));
				}
				case 441:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.39));
				}
				case 440, 326, 325:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.10));
				}
				case 436:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.25, 0.35));
				}
				case 432, 395:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.10, 0.20));
				}
				case 428:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.10, 0.85));
				}
				case 427:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.10, 0.90));
				}
				case 398:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.35, 0.80));
				}
				case 396:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.47));
				}
				case 392:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.06, 0.35));
				}
				case 385:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.06, 0.49));
				}
				case 383, 907, 888:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.68));
				}
				case 381:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.02, 0.25));
				}
				case 366, 365, 276:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.58));
				}
				case 330, 329, 327, 191:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.22));
				}
				case 328, 917:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.01, 0.70));
				}
				case 320, 293, 251:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.08, 0.50));
				}
				case 314:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.03, 0.50));
				}
				case 304:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.15, 0.80));
				}
				case 296, 162:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.18));
				}
				case 290:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.38));
				}
				case 289, 282:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.10, 0.70));
				}
				case 287, 264:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.10, 0.60));
				}
				case 283:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.08, 0.75));
				}
				case 281:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.05, 0.75));
				}
				case 279, 255:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.18, 1.00));
				}
				case 278:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.06, 0.58));
				}
				case 267:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.05, 0.45));
				}
				case 261:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.05, 0.50));
				}
				case 259:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.10, 0.40));
				}
				case 253:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.03));
				}
				case 229, 174:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.28));
				}
				case 226, 154:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.02, 0.40));
				}
				case 214, 212, 211, 185, 70:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.12));
				}
				case 189:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.10, 0.22));
				}
				case 187:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.42));
				}
				case 178:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.08, 0.22));
				}
				case 177:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.02, 0.18));
				}
				case 156:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.08, 0.32));
				}
				case 155:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.02, 0.46));
				}
				case 153:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.26, 0.60));
				}
				case 73:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.14));
				}
				case 60, 11:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.10, 0.26));
				}
				case 10:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.12, 0.38));
				}
				case 911:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.57));
				}
				case 899:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.14, 0.60));
				}
				case 900:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.05, 0.65));
				}
				case 860:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.06, 0.55));
				}
				case 762, 865:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.06, 0.50));
				}
				case 946:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.84));
				}
				case 971:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.73));
				}
				case 958:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.79));
				}
				default:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 1.00));
				}
			}
			
			switch(GetEntProp(entity, Prop_Send, "m_nFallbackPaintKit"))
			{
				case 125, 255, 256, 259, 257, 258, 262, 260, 261, 263, 267, 264, 265, 266, 675, 678, 681, 683, 676, 686, 687, 688, 679, 689, 680, 674, 682, 673, 684, 677, 685, 504, 
				497, 490, 493, 503, 494, 501, 496, 500, 491, 495, 492, 498, 505, 499, 502, 639, 653, 644, 640, 643, 647, 652, 654, 648, 651, 645, 646, 650, 655, 642, 649, 641, 512, 
				522, 506, 511, 516, 519, 514, 510, 508, 521, 520, 509, 507, 515, 517, 518, 524, 533, 527, 525, 537, 529, 532, 535, 536, 530, 540, 538, 526, 528, 534, 539, 279, 280, 
				282, 286, 283, 287, 290, 284, 288, 285, 291, 281, 289, 380, 389, 391, 393, 388, 384, 383, 381, 390, 385, 386, 392, 387, 382, 662, 660, 664, 661, 658, 656, 669, 670, 
				667, 668, 657, 663, 666, 671, 659, 672, 665, 359, 360, 353, 351, 352, 358, 350, 356, 349, 361, 357, 362, 354, 355, 180, 185, 211, 212, 182, 183, 188, 187, 189, 186, 
				192, 191, 195, 193, 190, 309, 313, 310, 315, 307, 311, 336, 302, 339, 312, 301, 337, 314, 305, 306, 335, 334, 338, 303, 304, 308, 632, 624, 626, 636, 638, 637, 631, 
				634, 625, 628, 623, 627, 629, 635, 630, 633, 622, 600, 604, 601, 609, 614, 603, 607, 613, 608, 612, 611, 602, 610, 615, 616, 606, 605, 587, 586, 588, 591, 597, 584, 
				595, 583, 593, 596, 598, 585, 592, 589, 590, 599, 594, 475, 474, 487, 481, 476, 480, 483, 485, 482, 477, 478, 489, 486, 479, 488, 484, 316, 155, 9, 181, 62, 184, 13, 
				213, 20, 317, 320, 156, 14, 174, 83, 162, 176, 177, 178, 215, 231, 227, 154, 226, 228, 225, 223, 224, 230, 229, 548, 542, 551, 541, 556, 554, 557, 546, 543, 555, 553, 
				549, 550, 544, 547, 545, 552, 398, 395, 400, 394, 404, 397, 402, 405, 396, 399, 403, 401, 406, 407, 430, 433, 428, 427, 429, 424, 431, 435, 436, 422, 425, 426, 432,
				434, 423, 222, 67, 221, 214, 220, 232, 217, 218, 216, 219, 270, 269, 271, 273, 274, 272, 268, 277, 278, 276, 275, 73, 11, 51, 61, 48, 60, 695, 696, 705, 691, 690,
				694, 703, 704, 699, 698, 702, 701, 693, 697, 700, 706, 692, 707, 711, 714, 720, 723, 718, 709, 716, 719, 712, 713, 717, 708, 715, 722, 721, 710, 808, 816, 804, 814,
				809, 803, 805, 810, 802, 817, 813, 807, 812, 806, 811, 815, 917, 919, 910, 913, 911, 915, 916, 907, 906, 902, 918, 904, 908, 909, 903, 905, 914, 844, 837, 845, 850,
				843, 838, 841, 851, 846, 839, 836, 849, 848, 842, 840, 835, 847, 801, 858, 855, 854, 853, 852, 856, 857, 579, 581, 567, 577, 562, 582, 566, 576, 561, 620, 565, 59,
				38, 12, 43, 5, 42, 44, 175, 735, 143, 77, 72, 558, 573, 569, 570, 571, 572, 568, 563, 580, 578, 413, 409, 414, 418, 419, 420, 421, 415, 416, 417, 410, 411, 98, 40,
				618, 619, 617, 621, 559, 574, 564, 575, 560, 887, 898, 897, 889, 899, 885, 886, 894, 893, 884, 888, 895, 896, 900, 891, 892, 890, 946, 957, 941, 947, 948, 956, 955,
				951, 954, 953, 943, 945, 942, 949, 944, 950, 952, 958, 960, 967, 968, 973, 969, 966, 974, 965, 964, 972, 961, 963, 970, 971, 962, 959:
				{
					if(GetRandomInt(1,100) <= 30)
					{
						g_iStatTrak[client][index] = 1;
					}
					else
					{
						g_iStatTrak[client][index] = 0;
					}
				}
				default:
				{
					g_iStatTrak[client][index] = 0;
				}
			}
			
			if(GetRandomInt(1,100) <= 40)
			{
				if(GetRandomInt(1,100) <= 65)
				{
					int rndsticker = GetRandomInt(1,14);
				
					switch (rndsticker)
					{
						case 1:
						{
							CS_SetWeaponSticker(client, entity, 0, -1, 0.0);
						}
						case 2:
						{
							CS_SetWeaponSticker(client, entity, 0, -1, 0.0);
							CS_SetWeaponSticker(client, entity, 1, -1, 0.0);
						}
						case 3:
						{
							CS_SetWeaponSticker(client, entity, 0, -1, 0.0);
							CS_SetWeaponSticker(client, entity, 2, -1, 0.0);
						}
						case 4:
						{
							CS_SetWeaponSticker(client, entity, 0, -1, 0.0);
							CS_SetWeaponSticker(client, entity, 3, -1, 0.0);
						}
						case 5:
						{
							CS_SetWeaponSticker(client, entity, 0, -1, 0.0);
							CS_SetWeaponSticker(client, entity, 1, -1, 0.0);
							CS_SetWeaponSticker(client, entity, 2, -1, 0.0);
						}
						case 6:
						{
							CS_SetWeaponSticker(client, entity, 1, -1, 0.0);
						}
						case 7:
						{
							CS_SetWeaponSticker(client, entity, 1, -1, 0.0);
							CS_SetWeaponSticker(client, entity, 2, -1, 0.0);
						}
						case 8:
						{
							CS_SetWeaponSticker(client, entity, 1, -1, 0.0);
							CS_SetWeaponSticker(client, entity, 3, -1, 0.0);
						}
						case 9:
						{
							CS_SetWeaponSticker(client, entity, 0, -1, 0.0);
							CS_SetWeaponSticker(client, entity, 2, -1, 0.0);
							CS_SetWeaponSticker(client, entity, 3, -1, 0.0);
						}
						case 10:
						{
							CS_SetWeaponSticker(client, entity, 2, -1, 0.0);
						}
						case 11:
						{
							CS_SetWeaponSticker(client, entity, 2, -1, 0.0);
							CS_SetWeaponSticker(client, entity, 3, -1, 0.0);
						}
						case 12:
						{
							CS_SetWeaponSticker(client, entity, 1, -1, 0.0);
							CS_SetWeaponSticker(client, entity, 2, -1, 0.0);
							CS_SetWeaponSticker(client, entity, 3, -1, 0.0);
						}
						case 13:
						{
							CS_SetWeaponSticker(client, entity, 3, -1, 0.0);
						}
						case 14:
						{
							CS_SetWeaponSticker(client, entity, 0, -1, 0.0);
							CS_SetWeaponSticker(client, entity, 1, -1, 0.0);
							CS_SetWeaponSticker(client, entity, 3, -1, 0.0);
						}
					}
				}
				else
				{
					int rndsticker = GetRandomInt(1,2);
					
					switch(rndsticker)
					{
						case 1:
						{
							CS_SetWeaponSticker(client, entity, 0, -1, 0.0);
							CS_SetWeaponSticker(client, entity, 1, -1, 0.0);
							CS_SetWeaponSticker(client, entity, 2, -1, 0.0);
							CS_SetWeaponSticker(client, entity, 3, -1, 0.0);
						}
						case 2:
						{
							int iStickerDefIndex = CS_GetRandomSticker();
							
							CS_SetWeaponSticker(client, entity, 0, iStickerDefIndex, 0.0);
							CS_SetWeaponSticker(client, entity, 1, iStickerDefIndex, 0.0);
							CS_SetWeaponSticker(client, entity, 2, iStickerDefIndex, 0.0);
							CS_SetWeaponSticker(client, entity, 3, iStickerDefIndex, 0.0);
						}
					}
				}
			}
		}
		
		SetEntProp(entity, Prop_Send, "m_iAccountID", g_iSteam32[client]);
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
		SetEntPropEnt(entity, Prop_Send, "m_hPrevOwner", -1);
	}
}

void RefreshWeapon(int client, int index, bool defaultKnife = false)
{
	int size = GetEntPropArraySize(client, Prop_Send, "m_hMyWeapons");
	
	for (int i = 0; i < size; i++)
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i);
		if (IsValidWeapon(weapon))
		{
			bool isKnife = IsKnife(weapon);
			if ((!defaultKnife && GetWeaponIndex(weapon) == index) || (isKnife && (defaultKnife || IsKnifeClass(g_WeaponClasses[index]))))
			{
				if(!g_bOverwriteEnabled)
				{
					int previousOwner;
					if ((previousOwner = GetEntPropEnt(weapon, Prop_Send, "m_hPrevOwner")) != INVALID_ENT_REFERENCE && previousOwner != client)
					{
						return;
					}
				}
				
				int clip = -1;
				int ammo = -1;
				int offset = -1;
				int reserve = -1;
				
				if (!isKnife)
				{
					offset = FindDataMapInfo(client, "m_iAmmo") + (GetEntProp(weapon, Prop_Data, "m_iPrimaryAmmoType") * 4);
					ammo = GetEntData(client, offset);
					clip = GetEntProp(weapon, Prop_Send, "m_iClip1");
					reserve = GetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount");
				}
				
				RemovePlayerItem(client, weapon);
				AcceptEntityInput(weapon, "KillHierarchy");
				
				if (!isKnife)
				{
					weapon = GivePlayerItem(client, g_WeaponClasses[index]);
					if (clip != -1)
					{
						SetEntProp(weapon, Prop_Send, "m_iClip1", clip);
					}
					if (reserve != -1)
					{
						SetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount", reserve);
					}
					if (offset != -1 && ammo != -1)
					{
						DataPack pack;
						CreateDataTimer(0.1, ReserveAmmoTimer, pack);
						pack.WriteCell(GetClientUserId(client));
						pack.WriteCell(offset);
						pack.WriteCell(ammo);
					}
				}
				else
				{
					GivePlayerItem(client, "weapon_knife");
				}
				break;
			}
		}
	}
}

public Action ReserveAmmoTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int clientIndex = GetClientOfUserId(pack.ReadCell());
	int offset = pack.ReadCell();
	int ammo = pack.ReadCell();
	
	if(clientIndex > 0 && IsClientInGame(clientIndex))
	{
		SetEntData(clientIndex, offset, ammo, 4, true);
	}
}
