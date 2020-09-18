/*  SM Valve Gloves
 *
 *  Copyright (C) 2017-2019 Francisco 'Franc1sco' García
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
#include <cstrike>
#include <clientprefs>
#include <autoexecconfig>
#include <multicolors>
#undef REQUIRE_PLUGIN
#include <custom_gloves>
#include <fnemotes>

#define		PREFIX			"★ {green}[Gloves]{default}"

#define CTARMS "models/weapons/ct_arms.mdl"
#define TTARMS "models/weapons/t_arms.mdl"

const int MAX_LANG = 40;

Handle g_pSave;
Handle g_pSaveSkin;
Handle g_pSaveQ;

ConVar g_cvVipOnly, g_cvVipFlags, g_cvCloseMenu, g_cvDefaultGloves;

int g_iGlove [ MAXPLAYERS + 1 ];
int gloves [ MAXPLAYERS + 1 ];
int g_iSkin [ MAXPLAYERS + 1 ];

int g_iChangeLimit [ MAXPLAYERS + 1 ];
int clientlang [ MAXPLAYERS + 1 ];

float g_fUserQuality [ MAXPLAYERS + 1 ];

Handle cvar_thirdperson;

Menu menuGloves[MAX_LANG][24];
bool langmenus[MAX_LANG];

Handle g_RandomSkins[MAX_LANG];
Handle g_RandomGloves[MAX_LANG];

bool custom_gloves;
//bool emotes;

public Plugin myinfo =
{
	name = "SM Valve Gloves",
	author = "Franc1sco franug",
	description = "",
	version = "3.0.2",
	url = "http://steamcommunity.com/id/franug"
};

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	MarkNativeAsOptional("Custom_RemoveGloves");
	MarkNativeAsOptional("fnemotes_IsClientEmoting");
	
	RegPluginLibrary("csgo_gloves");
	
	CreateNative("CSGO_RemoveGloves", Native_CSGO_SetGloves);
	return APLRes_Success;
}

public void OnAllPluginsLoaded()
{
	custom_gloves = LibraryExists("custom_gloves");
	//emotes = LibraryExists("fnemotes");
	
}
 
public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "custom_gloves"))
	{
		custom_gloves = false;
	}
	/*
	else if (StrEqual(name, "fnemotes"))
	{
		emotes = false;
	}*/
}
 
public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "custom_gloves"))
	{
		custom_gloves = true;
	}
	/*
	else if (StrEqual(name, "fnemotes"))
	{
		emotes = true;
	}*/
}

public Native_CSGO_SetGloves(Handle:plugin, numParams)
{
	int client = GetNativeCell(1);
	
	g_iGlove [ client ] = 0;
	
	if (!IsPlayerAlive(client))return;
	
	int ent = GetEntPropEnt(client, Prop_Send, "m_hMyWearables");
	if(ent != -1)
	{
		AcceptEntityInput(ent, "KillHierarchy");
	}
	SetEntPropString(client, Prop_Send, "m_szArmsModel", "");
}

public void OnPluginStart() {

	LoadTranslations("csgo_gloves.phrases");
	RegConsoleCmd ( "sm_gl", CommandGloves );
	RegConsoleCmd ( "sm_gls", CommandGloves );
    	
	RegConsoleCmd ( "sm_glove", CommandGloves );
	RegConsoleCmd ( "sm_gloves", CommandGloves );
    	
	RegConsoleCmd ( "sm_arm", CommandGloves );
	RegConsoleCmd ( "sm_arms", CommandGloves );
    	
	RegConsoleCmd ( "sm_manusa", CommandGloves );
	RegConsoleCmd ( "sm_manusi", CommandGloves );
 
	HookEvent ( "player_spawn", hookPlayerSpawn, EventHookMode_Post);
	//HookEvent ( "player_death", hookPlayerDeath );
	

	AutoExecConfig_SetFile("csgo_gloves");
	
	g_cvVipOnly = AutoExecConfig_CreateConVar ( "sm_csgogloves_viponly", "0", "Set gloves only for VIPs", FCVAR_NOTIFY, true, 0.0, true, 1.0 );
	g_cvVipFlags = AutoExecConfig_CreateConVar ( "sm_csgogloves_vipflags", "t", "Set gloves only for VIPs", FCVAR_NOTIFY );
	g_cvCloseMenu = AutoExecConfig_CreateConVar ( "sm_csgogloves_closemenu", "0", "Close menu after selection", FCVAR_NOTIFY, true, 0.0, true, 1.0 );
	g_cvDefaultGloves = AutoExecConfig_CreateConVar ( "sm_csgogloves_fixgloves", "1", "Prevent the bug of no arms in some maps", FCVAR_NOTIFY, true, 0.0, true, 1.0 );
	
	cvar_thirdperson = AutoExecConfig_CreateConVar ( "sm_csgogloves_thirdperson", "1", "Enable thirdperson view for gloves", FCVAR_NOTIFY, true, 0.0, true, 1.0 );
		
	g_pSave = RegClientCookie ( "FranugValveGloves", "Store Valve gloves", CookieAccess_Private );
	g_pSaveSkin = RegClientCookie ( "FranugValveGlovesSkin", "Store Valve gloves skin", CookieAccess_Private );
	
	g_pSaveQ = RegClientCookie ( "ValveGlovesQ", "Store Valve gloves quality", CookieAccess_Private );

	RefreshKV();
	
	for ( int client = 1; client <= MaxClients; client++ )
		if ( IsValidClient ( client ) )
		{
			OnClientCookiesCached ( client );
			if(IsPlayerAlive(client)) SetUserGloves(client, g_iGlove [ client ],g_iSkin [ client ], false);
		}
		
	AutoExecConfig_ExecuteFile();
	
	AutoExecConfig_CleanFile();
}

public void fnemotes_OnEmote(int client)
{
	SetUserGloves(client, g_iGlove [ client ],g_iSkin [ client ], false);
}

public void RefreshKV()
{
	char sConfig[PLATFORM_MAX_PATH];
	char language[32];
	char code[4];
	char temp[64];
	char temp2[64];
	int iTemp;
	Handle kv;
	int count;
	int skin;
	int langCount = GetLanguageCount();
	char flags[32];
	int files = 0;
	for (int i = 0; i < langCount; i++)
	{	
		if (g_RandomSkins[i] != null)CloseHandle(g_RandomSkins[i]);
		if (g_RandomGloves[i] != null)CloseHandle(g_RandomGloves[i]);
		
		GetLanguageInfo(i, code, sizeof(code), language, sizeof(language)); 
		
		BuildPath(Path_SM, sConfig, PLATFORM_MAX_PATH, "configs/franug_gloves/gloves_%s.cfg", language);
		
		if (!FileExists(sConfig))continue;
	
		kv = CreateKeyValues("Gloves");
		FileToKeyValues(kv, sConfig);
		
		if (!KvGotoFirstSubKey(kv))
		{
			SetFailState("CFG File not found: %s", sConfig);
			CloseHandle(kv);
		}
		
		g_RandomSkins[i] = CreateArray();
		g_RandomGloves[i] = CreateArray();
		files++;
		count = 0;
		
		menuGloves[i][0] = new Menu(MainMenu_Handler);
		SetMenuTitle(menuGloves[i][0], "%T", "Gloves Main menu", LANG_SERVER);

		SetMenuExitBackButton(menuGloves[i][0], true);
		
		langmenus[i] = false;
		
		do
		{
			count++;
			
			KvGetSectionName(kv, temp, 64);

			IntToString(count, temp2, 2);
			Format(temp2, 64, "%i", count);
			AddMenuItem(menuGloves[i][0], temp2, temp);
			
			iTemp = KvGetNum(kv, "index");
			
			KvGotoFirstSubKey(kv);

			menuGloves[i][count] = new Menu(SubMenu_Handler);
			SetMenuTitle(menuGloves[i][count], temp);
			SetMenuExitBackButton(menuGloves[i][count], true);

			do 
			{
				
				KvGetSectionName(kv, temp, 64);
				skin = KvGetNum(kv, "index");
				KvGetString(kv, "flags", flags, 32, "0");
				Format(temp2, 64, "%i;%i;%s", iTemp, skin, flags);
				
				if(!StrEqual(flags, "0", false))
					Format(temp, 64, "%s %T", temp, "(VIP ACCESS)", LANG_SERVER);
				
				AddMenuItem(menuGloves[i][count], temp2, temp);
				
				PushArrayCell(g_RandomSkins[i], skin);
				PushArrayCell(g_RandomGloves[i], iTemp);
				
			}while (KvGotoNextKey(kv));
			
			KvGoBack(kv);
			
		} while (KvGotoNextKey(kv));
		KvRewind(kv);
		
		CloseHandle(kv);
	}
	
	if(files == 0)
	{
		SetFailState("No CFG Files found.");
	}
}

public OnMapStart()
{
	PrecacheModel(CTARMS, true);
	PrecacheModel(TTARMS, true);
}

public void OnPluginEnd() {
	for(int i = 1; i <= MaxClients; i++)
		if(gloves[i] != -1 && IsWearable(gloves[i])) {
			if(IsClientConnected(i) && IsPlayerAlive(i)) {
				SetEntPropEnt(i, Prop_Send, "m_hMyWearables", -1);
				SetEntProp(i, Prop_Send, "m_nBody", 0);
			}
			AcceptEntityInput(gloves[i], "Kill");
		}
}

public Action hookPlayerSpawn(Handle event, const char[] name, bool dontBroadcast) {
	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
		
	SetUserGloves(client, g_iGlove[client],g_iSkin[client], false, true);	

	if(IsFakeClient(client))
	{
		SetUserGloves(client, -1,-1, false, true);	
	}	
}

/*
public Action hookPlayerDeath ( Handle event, const char [ ] name, bool dontBroadcast ) {

	int client = GetClientOfUserId ( GetEventInt ( event, "userid" ) );

	int wear = GetEntPropEnt(client, Prop_Send, "m_hMyWearables");
	
	if(wear == -1) 
		SetEntProp(client, Prop_Send, "m_nBody", 0);
	
	return Plugin_Continue;
}*/

public void OnClientCookiesCached ( int Client ) {
	
	char Data [ 32 ];

	GetClientCookie ( Client, g_pSave, Data, sizeof ( Data ) );

	g_iGlove [ Client ] = StringToInt(Data);
	
	GetClientCookie ( Client, g_pSaveQ, Data, sizeof ( Data ) );
	
	g_fUserQuality [ Client ] = StringToFloat ( Data );
	
	GetClientCookie ( Client, g_pSaveSkin, Data, sizeof ( Data ) );
	
	g_iSkin [ Client ] = StringToInt ( Data );
	
	gloves[Client] = -1;
}

public OnClientPostAdminCheck(int Client)
{
	if ( GetConVarInt ( g_cvVipOnly ) ) {
		
		if (!IsUserVip ( Client ) )
		{
			g_iGlove[ Client ] = 0;
			g_iSkin[Client] = 0;
			g_fUserQuality[Client] = 0.0;
			
			return;	
		}
	}	
}

public Action CommandGloves ( int client, int args ) {
	
	if ( !IsValidClient ( client ) )
		return Plugin_Handled;
		
	if ( GetConVarInt ( g_cvVipOnly ) ) {
		
		if ( !IsUserVip ( client ) ) {

			CPrintToChat ( client, "%s %T", PREFIX, "This command is only for VIPs", client);
			return Plugin_Handled;
		}
	}
	clientlang[client] = GetClientLanguage(client);
	
	
	if(custom_gloves)
	{
		ValveGlovesMenu2(client);
		
		return Plugin_Handled;
	}
	ValveGlovesMenu ( client );

	return Plugin_Handled;
	
}

public void ValveGlovesMenu2 ( int client ) 
{	
	
	Menu tmenu = new Menu(Menu_HandlerF);
	SetMenuTitle(tmenu, "Select gloves");
	
	AddMenuItem(tmenu, "custom", "Custom Gloves");
	AddMenuItem(tmenu, "valve", "Valve Gloves");
	
	
	DisplayMenu(tmenu, client, 0);
}

public int Menu_HandlerF(Handle menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			//param1 is client, param2 is item

			char item[64];
			GetMenuItem(menu, param2, item, sizeof(item));
			if (StrEqual(item, "custom"))
			{
				FakeClientCommand(param1, "sm_carms");
			}
			else if (StrEqual(item, "valve"))
			{
				ValveGlovesMenu(param1);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}

	}
}

public void ValveGlovesMenu ( int client ) 
{	
	
	if (menuGloves[clientlang[client]][0] == null) clientlang[client] = GetLanguageByName("english");
	
	
	if(!langmenus[clientlang[client]])
	{
		char temp[64];
		
		Format(temp, 64, "%T", "Set Quality on gloves", client);
		InsertMenuItem(menuGloves[clientlang[client]][0], 0,  "Quality", temp);
		
		Format(temp, 64, "%T", "Random gloves", client);
		InsertMenuItem(menuGloves[clientlang[client]][0], 0,  "random", temp);
		
		Format(temp, 64, "%T", "Default gloves", client);
		InsertMenuItem(menuGloves[clientlang[client]][0], 0,  "default", temp);
		
		SetMenuTitle(menuGloves[clientlang[client]][0], "%T", "Gloves Main menu", client);
		
		langmenus[clientlang[client]] = true;
		
	}
	
	DisplayMenu(menuGloves[clientlang[client]][0], client, MENU_TIME_FOREVER);
}

public int MainMenu_Handler(Handle menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			//param1 is client, param2 is item

			char item[64];
			GetMenuItem(menu, param2, item, sizeof(item));
			if (StrEqual(item, "default"))
			{
				g_iGlove [ param1 ] = 0;
	        	
				char Data [ 32 ];
				IntToString ( g_iGlove [ param1 ], Data, sizeof ( Data ) );
				SetClientCookie ( param1, g_pSave, Data );
			
				CPrintToChat ( param1, "%s %T", PREFIX, "You have default gloves now", param1 );
				SetUserGloves(param1, 0, 0,  false);
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					CommandGloves(param1, 0);
				
				
			}
			else if (StrEqual(item, "Quality"))
			{
				Quality_Menu ( param1 );
			}
			else if (StrEqual(item, "random"))
			{
				g_iGlove [ param1 ] = -1;
	        	
				char Data [ 32 ];
				IntToString ( g_iGlove [ param1 ], Data, sizeof ( Data ) );
				SetClientCookie ( param1, g_pSave, Data );
			
				CPrintToChat ( param1, "%s %T", PREFIX, "You have random gloves now", param1 );
				SetUserGloves(param1, -1, -1,  false);
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					CommandGloves(param1, 0);
			}
			else
			{
				DisplayMenu(menuGloves[clientlang[param1]][StringToInt(item)], param1, MENU_TIME_FOREVER);
				
			}
		}
		case MenuAction_Cancel:
		{
			if(param2==MenuCancel_ExitBack)
			{
				CommandGloves(param1, 0);
			}
		}

	}
}

public int SubMenu_Handler(Handle menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			//param1 is client, param2 is item

			char item[64];
			GetMenuItem(menu, param2, item, sizeof(item));
			char temp[3][32];
			
			ExplodeString(item, ";", temp, 3, 32);
			
			if (!StrEqual(temp[2], "0", false) && !CheckAdminFlagsByString(param1, temp[2]))
			{
				CPrintToChat ( param1, "%s %T", PREFIX, "This command is only for VIPs", param1);
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					CommandGloves(param1, 0);
					
					
				return;
			}
			
			g_iSkin[param1] = StringToInt(temp[1]);
			g_iGlove[param1] = StringToInt(temp[0]);
			
			
			CPrintToChat(param1, "%s %T", PREFIX, "You have a new glove", param1);
			
			SetUserGloves(param1, g_iGlove[param1],g_iSkin[param1], true);	
			
			if ( !GetConVarInt ( g_cvCloseMenu ) )
					CommandGloves(param1, 0);
			
		}
		case MenuAction_Cancel:
		{
			if(param2==MenuCancel_ExitBack)
			{
				CommandGloves(param1, 0);
			}
		}

	}
}

stock bool CheckAdminFlagsByString(int client, const char[] flagString)
{
    AdminId admin = view_as<AdminId>(GetUserAdmin(client));
    if (admin != INVALID_ADMIN_ID){
        int count, found, flags = ReadFlagString(flagString);
        for (int i = 0; i <= 20; i++){
            if (flags & (1<<i))
            {
                count++;

                if(GetAdminFlag(admin, view_as<AdminFlag>(i))){
                    found++;
                }
            }
        }

        if (count == found || GetUserFlagBits(client) & ADMFLAG_ROOT){
            return true;
        }
    }

    return false;
}  

public void Quality_Menu ( client ) {
	
	Handle menu = CreateMenu(Quality_Handler, MenuAction_Select | MenuAction_End);
	SetMenuTitle(menu, "%T", "Quality Menu",client);
	
	char temp[64];
	Format(temp, 64, "%T", "Factory New", client);
	AddMenuItem(menu, "FactoryNew", temp, g_fUserQuality [ client ] == 0.0?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		
		
	Format(temp, 64, "%T", "Minimal Wear", client);
	AddMenuItem(menu, "MinimalWear", temp, g_fUserQuality [ client ] == 0.25?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	
	Format(temp, 64, "%T", "Field-Tested", client);
	AddMenuItem(menu, "FieldTested", temp, g_fUserQuality [ client ] == 0.50?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	
	Format(temp, 64, "%T", "Well-worn", client);
	AddMenuItem(menu, "Well-worn", temp, g_fUserQuality [ client ] == 0.75?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	
	Format(temp, 64, "%T", "Battle-Scarred", client);
	AddMenuItem(menu, "BattleScared", temp, g_fUserQuality [ client ] == 1.0?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
				
}

public Quality_Handler(Handle menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			//param1 is client, param2 is item

			char item[64];
			GetMenuItem(menu, param2, item, sizeof(item));

			if (StrEqual(item, "FactoryNew"))
			{
				g_fUserQuality [ param1 ] = 0.0;
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Quality_Menu ( param1 );
				
				CPrintToChat ( param1, "%s %T", PREFIX , "Your new Glove Quality is Factory New", param1);
			}
			else if (StrEqual(item, "MinimalWear"))
			{
				g_fUserQuality [ param1 ] = 0.25;
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Quality_Menu ( param1 );
				
				CPrintToChat ( param1, "%s %T", PREFIX , "Your new Glove Quality is Minimal Wear", param1);
			}
			else if (StrEqual(item, "FieldTested"))
			{
				g_fUserQuality [ param1 ] = 0.50;
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Quality_Menu ( param1 );
				
				CPrintToChat ( param1, "%s %T", PREFIX , "Your new Glove Quality is Field-Tested", param1);
			}
			else if (StrEqual(item, "Well-worn"))
			{
				g_fUserQuality [ param1 ] = 0.75;
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Quality_Menu ( param1 );
				
				CPrintToChat ( param1, "%s %T", PREFIX , "Your new Glove Quality is Well-worn", param1);
			}
			else if (StrEqual(item, "BattleScared"))
			{
				g_fUserQuality [ param1 ] = 1.0;
				
				if ( !GetConVarInt ( g_cvCloseMenu ) )
					Quality_Menu ( param1 );
				
				CPrintToChat ( param1, "%s %T", PREFIX , "Your new Glove Quality is Battle-Scarred", param1);
			}
			
			char Data [ 32 ];
			
			FloatToString ( g_fUserQuality [ param1 ], Data, sizeof ( Data ) );
			SetClientCookie ( param1, g_pSaveQ, Data );
			
			SetUserGloves ( param1, g_iGlove [ param1 ],g_iSkin [ param1 ], false );
			
			
		}
		case MenuAction_Cancel:
		{
			if(param2==MenuCancel_ExitBack)
			{
				ValveGlovesMenu(param1);
			}
		}
		case MenuAction_End:
		{
			//param1 is MenuEnd reason, if canceled param2 is MenuCancel reason
			CloseHandle(menu);

		}

	}
}

stock void SetUserGloves (int client, int glove = -1, int skin = -1, bool bSave = false, bool onSpawn = false) 
{
	
	if ( IsValidClient ( client )) 
	{
		gloves[client] = -1;
		if ( IsPlayerAlive ( client ) ) 
		{
			if(glove != 0) 
			{
				if(!onSpawn)
				{
					int activeWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
					if(activeWeapon != -1)
					{
						SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", -1);
					}
					if(activeWeapon != -1)
					{
						DataPack dpack;
						CreateDataTimer(0.1, ResetGlovesTimer, dpack);
						dpack.WriteCell(client);
						dpack.WriteCell(activeWeapon);
					}
				}
				int ent = GetEntPropEnt(client, Prop_Send, "m_hMyWearables");
				if(ent != -1)
				{
					AcceptEntityInput(ent, "KillHierarchy");
				}
				FixCustomArms(client);
				ent = CreateEntityByName("wearable_item");
				if(ent != -1)
				{
					if(glove == -1)
					{
						int random = GetRandomInt(0, GetArraySize(g_RandomGloves[clientlang[client]])-1);
						
						glove = GetArrayCell(g_RandomGloves[clientlang[client]], random);
						skin = GetArrayCell(g_RandomSkins[clientlang[client]], random);
					}
					
					SetEntProp(ent, Prop_Send, "m_iItemIDLow", -1);
					SetEntProp(ent, Prop_Send, "m_iItemDefinitionIndex", glove);
					SetEntProp(ent, Prop_Send, "m_nFallbackPaintKit", skin);
					SetEntProp(ent, Prop_Send, "m_nFallbackSeed", GetRandomInt(1,1000));
					
					if(IsFakeClient(client))
					{
						SetEntPropFloat(ent, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.06, 0.80));
					}
					else
					{
						SetEntPropFloat(ent, Prop_Send, "m_flFallbackWear", g_fUserQuality [ client ]);
					}
					SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", client);
					SetEntPropEnt(ent, Prop_Data, "m_hParent", client);
					bool g_iEnableWorldModel = GetConVarBool(cvar_thirdperson);
					if(g_iEnableWorldModel) SetEntPropEnt(ent, Prop_Data, "m_hMoveParent", client);
					SetEntProp(ent, Prop_Send, "m_bInitialized", 1);
			
					DispatchSpawn(ent);
					
					gloves[client] = ent;
					
					SetEntPropEnt(client, Prop_Send, "m_hMyWearables", ent);
					if(g_iEnableWorldModel) SetEntProp(client, Prop_Send, "m_nBody", 1);
			
				}
			}
			else
			{
				if(!onSpawn)
				{
					//PrintToChat(client, "pasado");
					int ent = GetEntPropEnt(client, Prop_Send, "m_hMyWearables");
					if(ent != -1)
					{
						AcceptEntityInput(ent, "KillHierarchy");
					}
					
					//NormalGloves(client);
					int activeWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
					if(activeWeapon != -1)
					{
						SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", -1);
					}
					if(activeWeapon != -1)
					{
						DataPack dpack;
						CreateDataTimer(0.1, ResetGlovesTimer2, dpack);
						dpack.WriteCell(client);
						dpack.WriteCell(activeWeapon);
					}
					else NormalGloves(client);

					
				}
				else{
					CreateTimer(0.1, ResetGlovesTimer3, client);
				}
			}		
			
		}
			
	}
	        
	if ( bSave ) 
	{
	        	
		g_iGlove [ client ] = glove;
	        	
		char Data [ 32 ];
		IntToString ( glove, Data, sizeof ( Data ) );
		SetClientCookie ( client, g_pSave, Data );
			
		FloatToString ( g_fUserQuality [ client ], Data, sizeof ( Data ) );
		SetClientCookie ( client, g_pSaveQ, Data );
		
		IntToString ( skin, Data, sizeof ( Data ) );
		SetClientCookie ( client, g_pSaveSkin, Data );
	}
		
}

stock bool IsWearable(int ent) {
	if(!IsValidEdict(ent)) return false;
	char weaponclass[32]; GetEdictClassname(ent, weaponclass, sizeof(weaponclass));
	if(StrContains(weaponclass, "wearable", false) == -1) return false;
	return true;
}

stock NormalGloves(client)
{
	if(!g_cvDefaultGloves.BoolValue)
		return;
	
	char temp[2];
	GetEntPropString(client, Prop_Send, "m_szArmsModel", temp, sizeof(temp));
	if(!temp[0] && GetEntPropEnt(client, Prop_Send, "m_hMyWearables") == -1)
	{
		//PrintToChat(client, "pasado");
		switch(GetClientTeam(client))
		{
			case 2: SetEntPropString(client, Prop_Send, "m_szArmsModel", TTARMS);
			case 3: SetEntPropString(client, Prop_Send, "m_szArmsModel", CTARMS);
		}
	}
}

stock void FixCustomArms(int client)
{
	char temp[2];
	GetEntPropString(client, Prop_Send, "m_szArmsModel", temp, sizeof(temp));
	if(temp[0])
	{
		SetEntPropString(client, Prop_Send, "m_szArmsModel", "");
	}
}

public Action ResetGlovesTimer(Handle timer, DataPack pack)
{
	ResetPack(pack);
	int clientIndex = pack.ReadCell();
	int activeWeapon = pack.ReadCell();
	
	if(IsClientInGame(clientIndex))
	{
		if(IsValidEntity(activeWeapon)) SetEntPropEnt(clientIndex, Prop_Send, "m_hActiveWeapon", activeWeapon);
	}
}

public Action ResetGlovesTimer2(Handle timer, DataPack pack)
{
	ResetPack(pack);
	int clientIndex = pack.ReadCell();
	int activeWeapon = pack.ReadCell();
	
	if(IsClientInGame(clientIndex))
	{
		NormalGloves(clientIndex);
		
		if(IsValidEntity(activeWeapon)) SetEntPropEnt(clientIndex, Prop_Send, "m_hActiveWeapon", activeWeapon);
	}
}

public Action ResetGlovesTimer3(Handle timer, any client)
{
	if(IsClientInGame(client))
	{
		if (GetEntPropEnt(client, Prop_Send, "m_hMyWearables") != -1)
		{
			//PrintToChat(client, "pasado1");
			FixCustomArms(client);
			return;
		}
		
		//PrintToChat(client, "pasado");
		int activeWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(activeWeapon != -1)
		{
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", -1);
		}
		if(activeWeapon != -1)
		{
			DataPack dpack;
			CreateDataTimer(0.1, ResetGlovesTimer2, dpack);
			dpack.WriteCell(client);
			dpack.WriteCell(activeWeapon);
		}
		else NormalGloves(client);
	}
}

public Action Timer_CheckLimit ( Handle timer, any user_index ) {

	int client = GetClientOfUserId ( user_index );
	if ( !client || !IsValidClient ( client ) || !g_iChangeLimit [ client ] )
		return;

	g_iChangeLimit [ client ]--;
	CreateTimer ( 1.0, Timer_CheckLimit, user_index );

}

stock IsValidClient ( client ) {

	if ( !( 1 <= client <= MaxClients ) || !IsClientInGame ( client ) || GetEntProp(client, Prop_Send, "m_bIsControllingBot") == 1 )
		return false;

	return true;
}

bool IsUserVip ( int client ) {
	
	char szFlags [ 32 ];
	GetConVarString ( g_cvVipFlags, szFlags, sizeof ( szFlags ) );

	AdminId admin = GetUserAdmin ( client );
	if ( admin != INVALID_ADMIN_ID ) {

		int count, found, flags = ReadFlagString ( szFlags );
		for ( int i = 0; i <= 20; i++ ) {

			if ( flags & ( 1<<i ) ) {

				count++;

				if ( GetAdminFlag ( admin, AdminFlag: i ) )
					found++;

			}
		}

		if ( count == found )
			return true;

	}

	return false;
}

stock bool IsValidated( client )
{
    #define is_valid_player(%1) (1 <= %1 <= 32)
    
    if( !is_valid_player( client ) ) return false;
    if( !IsClientConnected ( client ) ) return false;   
    if( IsFakeClient ( client ) ) return false;
    if( !IsClientInGame ( client ) ) return false;

    return true;
}

