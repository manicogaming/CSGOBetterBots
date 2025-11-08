#if defined _bot_pause_included
    #endinput
#endif
#define _bot_pause_included

/**
 * Execute a pause
 * 
 * @param client        The client who triggered the pause
 * @param pauseTime     Pause duration (in seconds)
 * @return              1 = success, 0 = failure
 */
native int BotPause_ExecutePause(int client, int pauseTime);

/**
 * Get the remaining number of pauses for a team
 * 
 * @param team          Team ID (2 = T, 3 = CT)
 * @return              Remaining pause count
 */
native int BotPause_GetTeamPausesLeft(int team);

/**
 * Forward triggered when a pause is executed
 * 
 * @param client        The client who triggered the pause
 * @param pauseTime     Pause duration
 */
forward void BotPause_OnPauseExecuted(int client, int pauseTime);

public SharedPlugin __pl_bot_pause = {
    name = "bot_pause",
    file = "bot_pause.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_bot_pause_SetNTVOptional() {
    MarkNativeAsOptional("BotPause_ExecutePause");
    MarkNativeAsOptional("BotPause_GetTeamPausesLeft");
}
#endif