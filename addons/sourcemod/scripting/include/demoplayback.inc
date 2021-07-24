public SharedPlugin __pl_demoplayback = 
{
    name = "demoplayback",
    file = "demoplayback.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};
 
#if !defined REQUIRE_PLUGIN
public void __pl_demoplayback_SetNTVOptional()
{
    MarkNativeAsOptional("Demo_GetPosition");
    MarkNativeAsOptional("Demo_GetVelocity");
    MarkNativeAsOptional("Demo_GetAngles");
    MarkNativeAsOptional("Demo_GetTick");
    MarkNativeAsOptional("Demo_IsPlaying");
}
#endif

native int Demo_GetPosition(int client, int iTick, const float fPosition[3]);

native int Demo_GetVelocity(int client, int iTick, const float fVelocity[3]);

native int Demo_GetAngles(int client, int iTick, const float fAngles[3]);

native int Demo_GetTick(int client);

native bool Demo_IsPlaying(int client);