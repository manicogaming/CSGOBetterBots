void MakeHooks()
{
	HookLR(weapon_fire);
	HookLR(player_death);
	HookLR(player_hurt);
	HookLR(round_mvp);
	HookLR(round_end);
	HookLR(round_start);
	HookLR(bomb_planted);
	HookLR(bomb_defused);
	HookLR(bomb_dropped);
	HookLR(bomb_pickup);
	HookLR(hostage_killed);
	HookLR(hostage_rescued);
}

public void LRHooks(Handle hEvent, char[] sEvName, bool bDontBroadcast)
{
	switch(sEvName[0])
	{
		case 'w':
		{
			int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
			if(g_bInitialized[iClient] && IsClientInGame(iClient))
			{
				char sWeaponName[64];
				GetEventString(hEvent, "weapon", sWeaponName, sizeof(sWeaponName));
				if(!StrEqual(sWeaponName, "hegrenade") || !StrEqual(sWeaponName, "flashbang") || !StrEqual(sWeaponName, "smokegrenade") || !StrEqual(sWeaponName, "molotov") || !StrEqual(sWeaponName, "incgrenade") || !StrEqual(sWeaponName, "decoy"))
				{
					SHOOTS(iClient)++;
				}
			}
		}

		case 'p':
		{
			switch(sEvName[7])
			{
				case 'h':
				{
					int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
					int iAttacker = GetClientOfUserId(GetEventInt(hEvent, "attacker"));

					if(iClient && iAttacker && iAttacker != iClient && g_bInitialized[iClient] && g_bInitialized[iAttacker] && IsClientInGame(iClient) && IsClientInGame(iAttacker))
					{
						if(GetEventInt(hEvent, "hitgroup"))
						{
							HITS(iAttacker)++;
						}
					}
				}

				case 'd':
				{
					int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
					int iAttacker = GetClientOfUserId(GetEventInt(hEvent, "attacker"));

					if(!iAttacker || !iClient)
						return;

					if(IsFakeClient(iClient) || IsFakeClient(iAttacker))
						return;

					if(iAttacker == iClient)
					{
						NotifClient(iClient, -g_iGiveSuicide, g_iGiveSuicide, "Suicide");
					}
					else
					{
						if(GetClientTeam(iClient) == GetClientTeam(iAttacker))
						{
							NotifClient(iAttacker, -g_iGiveTeamKill, g_iGiveTeamKill, "TeamKill");
						}
						else
						{
							if(g_iTypeStatistics != 1)
							{
								NotifClient(iAttacker, g_iGiveKill, g_iGiveKill, "Kill");
								NotifClient(iClient, -g_iGiveDeath, g_iGiveDeath, "MyDeath");
							}
							else
							{
								int iRankAttacker = EXP(iAttacker);
								int iRankVictim = EXP(iClient);

								if(iRankAttacker == 0) iRankAttacker = 1;
								if(iRankVictim == 0) iRankVictim = 1;

								int iExpCoeff = RoundToNearest((float(iRankVictim) / float(iRankAttacker)) * g_fKillCoeff);

								if(iExpCoeff < 1) iExpCoeff = 1;

								if((KILLS(iAttacker) > 9) || (DEATHS(iAttacker) > 9)) NotifClient(iAttacker, iExpCoeff, iExpCoeff, "Kill");
								else NotifClient(iAttacker, g_iGiveCalibration, g_iGiveCalibration, "CalibrationPlus");

								if((KILLS(iClient) > 9) || (DEATHS(iClient) > 9)) NotifClient(iClient, -iExpCoeff, iExpCoeff, "MyDeath");
								else NotifClient(iClient, -g_iGiveCalibration, g_iGiveCalibration, "CalibrationMinus");
							}

							if(GetEventBool(hEvent, "headshot") && g_bInitialized[iAttacker])
							{
								HEADSHOTS(iAttacker)++;
								NotifClient(iAttacker, g_iGiveHeadShot, g_iGiveHeadShot, "HeadShotKill");
							}

							if(g_iEngineGame == EngineGameCSGO)
							{
								int iAssister = GetClientOfUserId(GetEventInt(hEvent, "assister"));
								if(iAssister && g_bInitialized[iAssister])
								{
									ASSISTS(iAssister)++;
									NotifClient(iAssister, g_iGiveAssist, g_iGiveAssist, "AssisterKill");
								}
							}

							if(g_bInitialized[iAttacker])
							{
								KILLS(iAttacker)++;
								g_iKillstreak[iAttacker]++;
							}
						}
					}

					if(g_bInitialized[iClient])
					{
						DEATHS(iClient)++;
					}

					GiveExpForStreakKills(iClient);
				}
			}
		}

		case 'r':
		{
			switch(sEvName[6])
			{
				case 'e':
				{
					int iTeam, checkteam;
					for(int iClient = 1; iClient <= MaxClients; iClient++)
					{
						if(IsClientInGame(iClient))
						{
							if(IsPlayerAlive(iClient))
							{
								GiveExpForStreakKills(iClient);
							}

							if((checkteam = GetEventInt(hEvent, "winner")) > 1)
							{
								if((iTeam = GetClientTeam(iClient)) > 1)
								{
									if(iTeam == checkteam)
									{
										NotifClient(iClient, g_iRoundWin, g_iRoundWin, "RoundWin");
									}
									else NotifClient(iClient, -g_iRoundLose, g_iRoundLose, "RoundLose");
								}
							}
						}
					}
				}

				case 'm': NotifClient(GetClientOfUserId(GetEventInt(hEvent, "userid")), g_iRoundMVP, g_iRoundMVP, "RoundMVP");

				case 's':
				{
					GetCountPlayers();
					g_iCountPlayers = 0;

					for(int i = 1; i <= MaxClients; i++)
					{
						if(g_bInitialized[i] && IsClientInGame(i))
						{
							GetPlacePlayer(i);
							g_iCountPlayers++;
						}
					}

					if(g_bSpawnMessage)
					{
						char sMessage[PLATFORM_MAX_PATH];
						bool bWarningMessage = false;
						if(g_iCountPlayers < g_iMinimumPlayers && g_iTypeStatistics != 2)
						{
							bWarningMessage = true;
						}

						for(int i = 1; i <= MaxClients; i++)
						{
							if(bWarningMessage)
							{
								FormatEx(sMessage, sizeof(sMessage), "%T", "RoundStartCheckCount", i, g_iCountPlayers, g_iMinimumPlayers);
								LR_PrintToChat(i, "%s", sMessage);
							}

							FormatEx(sMessage, sizeof(sMessage), "%T", "RoundStartMessageRanks", i, g_sMainMenuStr);
							LR_PrintToChat(i, "%s", sMessage);
						}
					}
				}
			}
		}

		case 'b':
		{
			int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
			switch(sEvName[6])
			{
				case 'l': g_bHaveBomb[iClient] = false, NotifClient(iClient, g_iBombPlanted, g_iBombPlanted, "BombPlanted");
				case 'e': NotifClient(iClient, g_iBombDefused, g_iBombDefused, "BombDefused");
				case 'r': if(g_bHaveBomb[iClient]) {g_bHaveBomb[iClient] = false; NotifClient(iClient, -g_iBombDropped, g_iBombDropped, "BombDropped");}
				case 'i': if(!g_bHaveBomb[iClient]) {g_bHaveBomb[iClient] = true; NotifClient(iClient, g_iBombPickup, g_iBombPickup, "BombPickup");}
			}
		}

		case 'h':
		{
			int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
			switch(sEvName[8])
			{
				case 'k': NotifClient(iClient, -g_iHostageKilled, g_iHostageKilled, "HostageKilled");
				case 'r': NotifClient(iClient, g_iHostageRescued, g_iHostageRescued, "HostageRescued");
			}
		}
	}
}

void GiveExpForStreakKills(int iClient)
{
	if(g_iKillstreak[iClient] > 1)
	{
		switch(g_iKillstreak[iClient])
		{
			case 2: NotifClient(iClient, g_iBonus[0], g_iBonus[0], "DoubleKill");
			case 3: NotifClient(iClient, g_iBonus[1], g_iBonus[1], "TripleKill");
			case 4: NotifClient(iClient, g_iBonus[2], g_iBonus[2], "Domination");
			case 5: NotifClient(iClient, g_iBonus[3], g_iBonus[3], "Rampage");
			case 6: NotifClient(iClient, g_iBonus[4], g_iBonus[4], "MegaKill");
			case 7: NotifClient(iClient, g_iBonus[5], g_iBonus[5], "Ownage");
			case 8: NotifClient(iClient, g_iBonus[6], g_iBonus[6], "UltraKill");
			case 9: NotifClient(iClient, g_iBonus[7], g_iBonus[7], "KillingSpree");
			case 10: NotifClient(iClient, g_iBonus[8], g_iBonus[8], "MonsterKill");
			case 11: NotifClient(iClient, g_iBonus[9], g_iBonus[9], "Unstoppable");
			default: NotifClient(iClient, g_iBonus[10], g_iBonus[10], "GodLike");
		}
	}

	g_iKillstreak[iClient] = 0;
	SaveDataPlayer(iClient);
}