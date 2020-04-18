/* put the line below after all of the includes!
#pragma newdecls required
*/

/*  SM Franug CSGO Sprays
 *
 *  Copyright (C) 2017 Francisco 'Franc1sco' García
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

#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <clientprefs>

#define SOUND_SPRAY_REL "*/items/spraycan_spray.wav"
#define SOUND_SPRAY "items/spraycan_spray.wav"

#define MAX_SPRAYS 512
#define MAX_MAP_SPRAYS 200

int g_iLastSprayed[MAXPLAYERS + 1];
char path_decals[PLATFORM_MAX_PATH];
int g_sprayElegido[MAXPLAYERS + 1];

int g_time;
int g_distance;
bool g_use;
int g_maxMapSprays;
int g_resetTimeOnKill;
int g_showMsg;

Handle h_distance;
Handle h_time;
Handle hCvar;
Handle h_use;
Handle h_maxMapSprays;
Handle h_resetTimeOnKill;
Handle h_showMsg;

Handle c_GameSprays = INVALID_HANDLE;

enum struct Listado
{
	char Nombre[32];
	int index;
}

enum struct MapSpray
{
	float vecPos[3];
	int index3;
}

Listado g_sprays[MAX_SPRAYS];
int g_sprayCount = 0;

// Array to store previous sprays
MapSpray g_spraysMapAll[MAX_MAP_SPRAYS];
// Running count of all sprays on the map
int g_sprayMapCount = 0;
// Current index of the last spray in the array; this resets to 0 when g_maxMapSprays is reached (FIFO)
int g_sprayIndexLast = 0;


#define PLUGIN "1.4.5"

public Plugin myinfo =
{
	name = "SM Franug CSGO Sprays",
	author = "Franc1sco Steam: franug",
	description = "Use sprays in CSGO",
	version = PLUGIN,
	url = "http://steamcommunity.com/id/franug"
};

public void OnPluginStart()
{
	c_GameSprays = RegClientCookie("Sprays", "Sprays", CookieAccess_Private);
	hCvar = CreateConVar("sm_franugsprays_version", PLUGIN, "SM Franug CSGO Sprays", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	SetConVarString(hCvar, PLUGIN);
	
	RegConsoleCmd("sm_spray", MakeSpray);
	RegConsoleCmd("sm_sprays", GetSpray);
	HookEvent("round_start", roundStart);
	HookEvent("player_death", Event_PlayerDeath);
	
	h_time = CreateConVar("sm_csgosprays_time", "30", "Cooldown between sprays");
	h_distance = CreateConVar("sm_csgosprays_distance", "115", "How far the sprayer can reach");
	h_use = CreateConVar("sm_csgosprays_use", "1", "Spray when a player runs +use (Default: E)");
	h_maxMapSprays = CreateConVar("sm_csgosprays_mapmax", "25", "Maximum ammount of sprays on the map");
	h_resetTimeOnKill = CreateConVar("sm_csgosprays_reset_time_on_kill", "1", "Reset the cooldown on a kill");
	h_showMsg = CreateConVar("sm_csgosprays_show_messages", "1", "Print messages of this plugin to the players");
	
	g_time = GetConVarInt(h_time);
	g_distance = GetConVarInt(h_distance);
	g_use = GetConVarBool(h_use);
	g_maxMapSprays = GetConVarInt(h_maxMapSprays);
	g_resetTimeOnKill = GetConVarBool(h_resetTimeOnKill);
	g_showMsg = GetConVarBool(h_showMsg);
	
	HookConVarChange(h_time, OnConVarChanged);
	HookConVarChange(h_distance, OnConVarChanged);
	HookConVarChange(hCvar, OnConVarChanged);
	HookConVarChange(h_use, OnConVarChanged);
	HookConVarChange(h_maxMapSprays, OnConVarChanged);
	HookConVarChange(h_resetTimeOnKill, OnConVarChanged);
	HookConVarChange(h_showMsg, OnConVarChanged);
	
	SetCookieMenuItem(SprayPrefSelected, 0, "Sprays");
	AutoExecConfig();
}

public void OnPluginEnd()
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			OnClientDisconnect(client);
		}
	}
}

public void OnClientCookiesCached(int client)
{
	char SprayString[12];
	GetClientCookie(client, c_GameSprays, SprayString, sizeof(SprayString));
	g_sprayElegido[client]  = StringToInt(SprayString);
}

public void OnClientDisconnect(int client)
{
	if(AreClientCookiesCached(client))
	{
		char SprayString[12];
		Format(SprayString, sizeof(SprayString), "%i", g_sprayElegido[client]);
		SetClientCookie(client, c_GameSprays, SprayString);
	}
}

public void OnConVarChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == h_time)
	{
		g_time = StringToInt(newValue);
	}
	else if (convar == h_distance)
	{
		g_distance = StringToInt(newValue);
	}
	else if (convar == hCvar)
	{
		SetConVarString(hCvar, PLUGIN);
	}
	else if (convar == h_use)
	{
		g_use = view_as<bool>(StringToInt(newValue));
	}
	else if (convar == h_maxMapSprays)
	{
		if(StringToInt(newValue) > MAX_MAP_SPRAYS)
		{		
			g_maxMapSprays = MAX_MAP_SPRAYS;
			SetConVarInt(h_maxMapSprays, MAX_MAP_SPRAYS);
		}
		else
			g_maxMapSprays = StringToInt(newValue);
	}
	else if (convar == h_resetTimeOnKill)
	{
		g_resetTimeOnKill = view_as<bool>(StringToInt(newValue));
	}
	else if (convar == h_showMsg)
	{
		g_showMsg = view_as<bool>(StringToInt(newValue));
	}
}

public Action roundStart(Handle event, const char[] name, bool dontBroadcast) 
{
	for (int i = 1; i < MaxClients; i++)
		if (IsClientInGame(i))
			g_iLastSprayed[i] = false;
			
	if(g_sprayMapCount > g_maxMapSprays)
		g_sprayMapCount = g_maxMapSprays;
	for (int j = 0; j < g_sprayMapCount; j++)
	{
		TE_SetupBSPDecalCall(g_spraysMapAll[j].vecPos, g_spraysMapAll[j].index3);
		TE_SendToAll();
	}

}

public void OnClientPostAdminCheck(int iClient)
{
	g_iLastSprayed[iClient] = false;
	//g_sprayElegido[iClient] = 0;
}

public void OnMapStart()
{
	char sBuffer[256];
	Format(sBuffer, sizeof(sBuffer), "sound/%s", SOUND_SPRAY);
	AddFileToDownloadsTable(sBuffer);
	
	FakePrecacheSound(SOUND_SPRAY_REL);
	
	BuildPath(Path_SM, path_decals, sizeof(path_decals), "configs/csgo-sprays/sprays.cfg");
	ReadDecals();
	g_sprayMapCount = 0;
	g_sprayIndexLast = 0;
}

public Action MakeSpray(int iClient, int args)
{	
	if(!iClient || !IsClientInGame(iClient))
		return Plugin_Continue;

	if(!IsPlayerAlive(iClient))
	{
		if(g_showMsg)
		{
			PrintToChat(iClient, " \x04[SM_CSGO-SPRAYS]\x01 You need to be alive to use this command!");
		}
		return Plugin_Handled;
	}

	int iTime = GetTime();
	int restante = (iTime - g_iLastSprayed[iClient]);
	
	if(restante < g_time)
	{
		if(g_showMsg)
		{
			PrintToChat(iClient, " \x04[SM_CSGO-SPRAYS]\x01 You need to wait %i second(s) to use this command again!", g_time-restante);
		}
		return Plugin_Handled;
	}

	float fClientEyePosition[3];
	GetClientEyePosition(iClient, fClientEyePosition);

	float fClientEyeViewPoint[3];
	GetPlayerEyeViewPoint(iClient, fClientEyeViewPoint);

	float fVector[3];
	MakeVectorFromPoints(fClientEyeViewPoint, fClientEyePosition, fVector);

	if(GetVectorLength(fVector) > g_distance)
	{
		if(g_showMsg)
		{
			PrintToChat(iClient, " \x04[SM_CSGO-SPRAYS]\x01 You are too far away from the wall to use this command!");
		}
		return Plugin_Handled;
	}

	if(g_sprayElegido[iClient] == 0)
	{
		TE_SetupBSPDecal(fClientEyeViewPoint, g_sprays[GetRandomInt(1, g_sprayCount-1)].index);
	}
	else
	{
		if(g_sprays[g_sprayElegido[iClient]].index == 0)
		{
			if(g_showMsg)
			{
			PrintToChat(iClient, " \x04[SM_CSGO-SPRAYS]\x01 Your spray doesn't work, choose another one with !sprays!");
			}
			return Plugin_Handled;
		}
		TE_SetupBSPDecal(fClientEyeViewPoint, g_sprays[g_sprayElegido[iClient]].index);
		
		// Save spray position and identifier
		if(g_sprayIndexLast == g_maxMapSprays)
			g_sprayIndexLast = 0;
		g_spraysMapAll[g_sprayIndexLast].vecPos = fClientEyeViewPoint;
		g_spraysMapAll[g_sprayIndexLast].index3 = g_sprays[g_sprayElegido[iClient]].index;
		g_sprayIndexLast++;
		if(g_sprayMapCount != g_maxMapSprays)
			g_sprayMapCount++;
	}
	TE_SendToAll();

	EmitSoundToAll(SOUND_SPRAY_REL, iClient, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.6);

	g_iLastSprayed[iClient] = iTime;
	return Plugin_Handled;
}

public Action GetSpray(int client, int args)
{	
	Menu menu = new Menu(DIDMenuHandler);
	menu.SetTitle("Choose your Spray");
	char item[4];
	menu.AddItem("0", "Random spray");
	for (int i=1; i<g_sprayCount; ++i) {
		Format(item, 4, "%i", i);
		menu.AddItem(item, g_sprays[i].Nombre);
	}
	menu.ExitButton = true;
	menu.Display(client, 0);
}

public int DIDMenuHandler(Menu menu, MenuAction action, int client, int itemNum) 
{
	if ( action == MenuAction_Select ) 
	{
		char info[4];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		g_sprayElegido[client] = StringToInt(info);
		if(g_showMsg)
		{
			if(g_sprayElegido[client] == 0)
			{
				PrintToChat(client, " \x04[SM_CSGO-SPRAYS]\x01 You have choosen\x03 a random spray \x01as your spray!");
			}
			else
			{
			PrintToChat(client, " \x04[SM_CSGO-SPRAYS]\x01 You have choosen\x03 %s \x01as your spray!",g_sprays[g_sprayElegido[client]].Nombre);
			}
		}
	}
	else if (action == MenuAction_Cancel) 
	{ 
		PrintToServer("Client %d's menu was cancelled.  Reason: %d", client, itemNum); 
	} 
		
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

stock bool GetPlayerEyeViewPoint(int iClient, float fPosition[3])
{
	float fAngles[3];
	GetClientEyeAngles(iClient, fAngles);

	float fOrigin[3];
	GetClientEyePosition(iClient, fOrigin);

	Handle hTrace = TR_TraceRayFilterEx(fOrigin, fAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	if(TR_DidHit(hTrace))
	{
		TR_GetEndPosition(fPosition, hTrace);
		CloseHandle(hTrace);
		return true;
	}
	CloseHandle(hTrace);
	return false;
}

public bool TraceEntityFilterPlayer(int iEntity, int iContentsMask)
{
	return iEntity > MaxClients;
}

void TE_SetupBSPDecalCall(const float[] vecOrigin, int index2) {
	
	// I know.. couldn't get the array to play nice with the compiler.
	float vector[3];
	for (int i=0; i < 3; i++)
		vector[i] = vecOrigin[i];
	TE_SetupBSPDecal(vector, index2);
}

void TE_SetupBSPDecal(const float vecOrigin[3], int index2) {
	
	TE_Start("World Decal");
	TE_WriteVector("m_vecOrigin",vecOrigin);
	TE_WriteNum("m_nIndex",index2);
}

void ReadDecals() {
	
	char buffer[PLATFORM_MAX_PATH];
	char download[PLATFORM_MAX_PATH];
	Handle kv;
	Handle vtf;
	g_sprayCount = 1;
	

	kv = CreateKeyValues("Sprays");
	FileToKeyValues(kv, path_decals);

	if (!KvGotoFirstSubKey(kv)) {

		SetFailState("CFG File not found: %s", path_decals);
		CloseHandle(kv);
	}
	do {

		KvGetSectionName(kv, buffer, sizeof(buffer));
		Format(g_sprays[g_sprayCount].Nombre, 32, "%s", buffer);
		KvGetString(kv, "path", buffer, sizeof(buffer));
		
		int precacheId = PrecacheDecal(buffer, true);
		g_sprays[g_sprayCount].index = precacheId;
		char decalpath[PLATFORM_MAX_PATH];
		Format(decalpath, sizeof(decalpath), buffer);
		Format(download, sizeof(download), "materials/%s.vmt", buffer);
		AddFileToDownloadsTable(download);
		vtf = CreateKeyValues("LightmappedGeneric");
		FileToKeyValues(vtf, download);
		KvGetString(vtf, "$basetexture", buffer, sizeof(buffer), buffer);
		CloseHandle(vtf);
		Format(download, sizeof(download), "materials/%s.vtf", buffer);
		AddFileToDownloadsTable(download);
		g_sprayCount++;
	} while (KvGotoNextKey(kv));
	CloseHandle(kv);
	
	for (int i=g_sprayCount; i<MAX_SPRAYS; ++i) 
	{
		g_sprays[i].index = 0;
	}
}

public Action OnPlayerRunCmd(int iClient, int &buttons, int &impulse)
{
	if(!g_use) return;
	
	if (buttons & IN_USE || IsFakeClient(iClient))
	{
		if(!IsPlayerAlive(iClient))
		{
			return;
		}

		int iTime = GetTime();
		int restante = (iTime - g_iLastSprayed[iClient]);
	
		if(restante < g_time)
		{
			return;
		}

		float fClientEyePosition[3];
		GetClientEyePosition(iClient, fClientEyePosition);

		float fClientEyeViewPoint[3];
		GetPlayerEyeViewPoint(iClient, fClientEyeViewPoint);

		float fVector[3];
		MakeVectorFromPoints(fClientEyeViewPoint, fClientEyePosition, fVector);

		if(GetVectorLength(fVector) > g_distance)
		{
			return;
		}


		if(g_sprayElegido[iClient] == 0)
		{
			TE_SetupBSPDecal(fClientEyeViewPoint, g_sprays[GetRandomInt(1, g_sprayCount-1)].index);
		}
		else
		{
			if(g_sprays[g_sprayElegido[iClient]].index == 0)
			{
				if(g_showMsg)
				{
					PrintToChat(iClient, " \x04[SM_CSGO-SPRAYS]\x01 Your spray doesn't work, choose another one with !sprays!");
				}
				return;
			}
			TE_SetupBSPDecal(fClientEyeViewPoint, g_sprays[g_sprayElegido[iClient]].index);
			
			// Save spray position and identifier
			if(g_sprayIndexLast == g_maxMapSprays)
				g_sprayIndexLast = 0;
			g_spraysMapAll[g_sprayIndexLast].vecPos = fClientEyeViewPoint;
			g_spraysMapAll[g_sprayIndexLast].index3 = g_sprays[g_sprayElegido[iClient]].index;
			g_sprayIndexLast++;
			if(g_sprayMapCount != g_maxMapSprays)
				g_sprayMapCount++;
		}
		TE_SendToAll();

		if(g_showMsg)
		{
			PrintToChat(iClient, " \x04[SM_CSGO-SPRAYS]\x01 You have used your spray.");
		}
		EmitAmbientSound(SOUND_SPRAY_REL, fVector, iClient, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.6);

		g_iLastSprayed[iClient] = iTime;
	}
}

public Action Event_PlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	if(g_resetTimeOnKill)
	{
		int user = GetClientOfUserId(GetEventInt(event, "attacker"));
		int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	
		if(user == 0 || user == victim || IsFakeClient(user))
			return Plugin_Continue;
		
		// Reset attacker's spray time on a kill
		g_iLastSprayed[user] = false;
	}
	
	return Plugin_Continue;
}

stock void FakePrecacheSound(const char[] szPath)
{
	AddToStringTable( FindStringTable( "soundprecache" ), szPath );
}

public int SprayPrefSelected(int client, CookieMenuAction action, any info, char[] buffer, int maxlen) 
{ 
    if (action == CookieMenuAction_SelectOption) 
    { 
        GetSpray(client,0); 
    } 
}