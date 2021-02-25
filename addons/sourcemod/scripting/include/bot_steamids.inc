#if defined _bot_steamids_included
 #endinput
#endif
#define _bot_steamids_included

native int GetBotAccountID(int client);

native int GetBotSteamID64(int client, char[] szSteamID64, int iLength);