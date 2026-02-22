#if defined _bot_steamids_included
  #endinput
#endif
#define _bot_steamids_included

native int GetBotAccountID(int client);
native bool GetBotSteamID64(int client, char[] szBuffer, int iMaxLen);
native bool GetBotCrosshairCode(int client, char[] szBuffer, int iMaxLen);
native bool IsBotInDatabase(int client);
native bool IsNameInBotDatabase(const char[] szName);

public SharedPlugin __pl_bot_steamids =
{
	name = "bot_steamids",
	file = "bot_steamids.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_bot_steamids_SetNTVOptional()
{
	MarkNativeAsOptional("GetBotAccountID");
	MarkNativeAsOptional("GetBotSteamID64");
	MarkNativeAsOptional("GetBotCrosshairCode");
	MarkNativeAsOptional("IsBotInDatabase");
	MarkNativeAsOptional("IsNameInBotDatabase");
}
#endif
