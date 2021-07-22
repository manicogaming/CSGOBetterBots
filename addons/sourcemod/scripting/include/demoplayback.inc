#if defined _demoplayback_included
 #endinput
#endif
#define _demoplayback_included

native int Demo_GetPosition(int client, int iTick, const float fPosition[3]);

native int Demo_GetVelocity(int client, int iTick, const float fVelocity[3]);

native int Demo_GetAngles(int client, int iTick, const float fAngles[3]);

native int Demo_GetTick(int client);

native bool Demo_IsPlaying(int client);