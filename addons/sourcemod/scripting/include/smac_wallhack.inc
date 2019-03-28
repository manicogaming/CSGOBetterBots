#if defined _smac_wallhack_included
  #endinput
#endif
#define _smac_wallhack_included

/**
 * Sets whether to ignore a client from visibility tests.
 * Processing time for anti-wallhack will decrease with every ignored client.
 *
 * @param client		Client index.
 * @param bIgnore		If true, client will not undergo visibility tests. If false, results in default behavior.
 * @noreturn
 * @error				If the client is not InGame or the index is invalid.
 */
native SMAC_WH_SetClientIgnore(client, bool:bIgnore);

/**
 * Returns whether a client is ignored from visibility tests.
 *
 * @param client		Client index.
 * @return				True if client is ignored from visibility tests, false otherwise.
 * @error				If the client is not connected or the index is invalid.
 */
native bool:SMAC_WH_GetClientIgnore(client);


public SharedPlugin:__pl_smac_wallhack = 
{
	name = "smac_wallhack",
	file = "smac_wallhack.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_smac_wallhack_SetNTVOptional()
{
	MarkNativeAsOptional("SMAC_WH_SetClientIgnore");
	MarkNativeAsOptional("SMAC_WH_GetClientIgnore");
}
#endif
