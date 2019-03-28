void NotifClient(int iClient, int iValue, int iValueShow, char[] sTitlePhrase)
{
	if(g_bWarmUpCheck && (g_iEngineGame == EngineGameCSGO) && GameRules_GetProp("m_bWarmupPeriod"))
	{
		return;
	}

	if(iValue != 0 && g_iTypeStatistics != 2 && g_iCountPlayers >= g_iMinimumPlayers && g_bInitialized[iClient])
	{
		if(iValue < 0) SetExpEvent(iClient, g_fCoefficient[iClient][1] > 0.0 ? RoundToNearest(iValue * g_fCoefficient[iClient][1]) : iValue);
		else SetExpEvent(iClient, g_fCoefficient[iClient][0] > 0.0 ? RoundToNearest(iValue * g_fCoefficient[iClient][0]) : iValue);

		if(g_bUsualMessage)
		{
			char sMessage[PLATFORM_MAX_PATH];
			FormatEx(sMessage, sizeof(sMessage), "%T", sTitlePhrase, iClient, EXP(iClient), iValueShow);
			LR_PrintToChat(iClient, "%s", sMessage);
		}
	}
}

void CheckRank(int iClient)
{
	if(iClient && IsClientInGame(iClient))
	{
		int iRank = RANK(iClient);
		char sMessage[PLATFORM_MAX_PATH];

		if(!IsClientVip(iClient))
		{
			switch(g_iTypeStatistics)
			{
				case 0:
				{
					for(int i = 18; i >= 1; i--)
					{
						if(i == 1)
						{
							RANK(iClient) = 1;
						}
						else if(g_iShowExp[i] <= EXP(iClient))
						{
							RANK(iClient) = i;
							break;
						}
					}
				}

				default:
				{
					if((KILLS(iClient) > 9) || (DEATHS(iClient) > 9) || (g_iTypeStatistics == 2))
					{
						for(int i = 18; i >= 1; i--)
						{
							if(i == 1)
							{
								RANK(iClient) = 1;
							}
							else if(g_iShowExp[i] <= EXP(iClient))
							{
								RANK(iClient) = i;
								break;
							}
						}
					}
				}
			}
		}

		if(RANK(iClient) > iRank)
		{
			FormatEx(sMessage, sizeof(sMessage), "%T", "LevelUp", iClient, g_sShowRank[RANK(iClient)]);
			LR_PrintToChat(iClient, "%s", sMessage);
			LR_EmitSound(iClient, g_sSoundUp);
			LR_CallRankForward(iClient, RANK(iClient), true);
		}
		else if(RANK(iClient) < iRank)
		{
			FormatEx(sMessage, sizeof(sMessage), "%T", "LevelDown", iClient, g_sShowRank[RANK(iClient)]);
			LR_PrintToChat(iClient, "%s", sMessage);
			LR_EmitSound(iClient, g_sSoundDown);
			LR_CallRankForward(iClient, RANK(iClient), false);
		}
	}
}

int SetExpEvent(int iClient, int iAmount)
{
	EXP(iClient) += iAmount;
	switch(g_iTypeStatistics)
	{
		case 0: if(EXP(iClient) < 0) EXP(iClient) = 0;
		case 1: if(EXP(iClient) < 500) EXP(iClient) = 500;
	}

	CheckRank(iClient);
	return EXP(iClient);
}

bool IsClientVip(int iClient)
{
	if(VIP(iClient) == 1)
	{
		return true;
	}

	VIP(iClient) = 0;
	return false;
}

void LR_PrecacheSound()
{
	char sBuffer[256];
	switch(g_iEngineGame)
	{
		case EngineGameCSGO:
		{
			int iStringTable = FindStringTable("soundprecache");
			FormatEx(sBuffer, sizeof(sBuffer), "*%s", g_sSoundUp); AddToStringTable(iStringTable, sBuffer);
			FormatEx(sBuffer, sizeof(sBuffer), "*%s", g_sSoundDown); AddToStringTable(iStringTable, sBuffer);
		}

		case EngineGameCSS:
		{
			PrecacheSound(g_sSoundUp);
			PrecacheSound(g_sSoundDown);
		}
	}
}

void LR_EmitSound(int iClient, char[] sPath)
{
	if(g_bSoundLVL)
	{
		char sBuffer[256];
		switch(g_iEngineGame)
		{
			case EngineGameCSGO: FormatEx(sBuffer, sizeof(sBuffer), "*%s", sPath);
			case EngineGameCSS: strcopy(sBuffer, sizeof(sBuffer), sPath);
		}
		EmitSoundToClient(iClient, sBuffer, SOUND_FROM_PLAYER, SNDCHAN_LR_RANK);
	}
}

void LR_CallRankForward(int iClient, int iNewLevel, bool bUp)
{
	Call_StartForward(g_hForward_OnLevelChanged);
	Call_PushCell(iClient);
	Call_PushCell(iNewLevel);
	Call_PushCell(bUp);
	Call_Finish();
}