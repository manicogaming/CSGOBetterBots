int		g_iAdminFlag,
		g_iTypeStatistics,
		g_iMinimumPlayers,
		g_iDaysDeleteFromBase,
		g_iDBReconnectCount,
		g_iGiveCalibration,
		g_iGiveKill,
		g_iGiveDeath,
		g_iGiveHeadShot,
		g_iGiveAssist,
		g_iGiveSuicide,
		g_iGiveTeamKill,
		g_iRoundWin,
		g_iRoundLose,
		g_iRoundMVP,
		g_iBombPlanted,
		g_iBombDefused,
		g_iBombDropped,
		g_iBombPickup,
		g_iHostageKilled,
		g_iHostageRescued,
		g_iShowExp[20],
		g_iBonus[11];
float		g_fKillCoeff = 0.0,
		g_fDBReconnectTime = 0.0;
bool		g_bSpawnMessage = false,
		g_bRankMessage = false,
		g_bUsualMessage = false,
		g_bInventory = false,
		g_bSoundLVL = false,
		g_bWarmUpCheck = false;
char		g_sMainMenuStr[16],
		g_sSoundUp[256],
		g_sSoundDown[256],
		g_sShowRank[20][192];

public void SetSettings()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/levels_ranks/settings.ini");
	KeyValues hLR_Settings = new KeyValues("LR_Settings");

	if(!hLR_Settings.ImportFromFile(sPath) || !hLR_Settings.GotoFirstSubKey())
	{
		CrashLR("(%s) is not found", sPath);
	}

	hLR_Settings.Rewind();

	if(hLR_Settings.JumpToKey("MainSettings"))
	{
		char sBuffer[32];
		hLR_Settings.GetString("lr_call_menu", g_sMainMenuStr, sizeof(g_sMainMenuStr), "lvl"); FormatEx(sBuffer, sizeof(sBuffer), "sm_%s", g_sMainMenuStr); RegConsoleCmd(sBuffer, CallMainMenu);
		hLR_Settings.GetString("lr_flag_adminmenu", sBuffer, sizeof(sBuffer), "z"); g_iAdminFlag = ReadFlagString(sBuffer);

		g_iTypeStatistics = hLR_Settings.GetNum("lr_type_statistics", 0);
		g_iMinimumPlayers = hLR_Settings.GetNum("lr_minplayers_count", 4);

		if(g_iTypeStatistics == 2)
		{
			int iCount;
			Call_StartForward(g_hForward_OnLevelCheckSynhc);
			Call_PushCellRef(iCount);
			Call_Finish();

			if(iCount > 1)
			{
				CrashLR("More than one synchronization modules");
			}
		}

		g_bSoundLVL = view_as<bool>(hLR_Settings.GetNum("lr_sound", 1));
		if(g_bSoundLVL)
		{
			hLR_Settings.GetString("lr_sound_lvlup", g_sSoundUp, sizeof(g_sSoundUp), "levels_ranks/levelup.mp3");
			hLR_Settings.GetString("lr_sound_lvldown", g_sSoundDown, sizeof(g_sSoundDown), "levels_ranks/leveldown.mp3");
		}

		g_bInventory = view_as<bool>(hLR_Settings.GetNum("lr_show_capabilities", 0));
		g_bUsualMessage = view_as<bool>(hLR_Settings.GetNum("lr_show_usualmessage", 1));
		g_bSpawnMessage = view_as<bool>(hLR_Settings.GetNum("lr_show_spawnmessage", 1));
		g_bRankMessage = view_as<bool>(hLR_Settings.GetNum("lr_show_rankmessage", 1));
		g_bWarmUpCheck = view_as<bool>(hLR_Settings.GetNum("lr_block_warmup", 1));
		g_iDaysDeleteFromBase = hLR_Settings.GetNum("lr_db_cleaner", 30);
		g_iDBReconnectCount = hLR_Settings.GetNum("lr_dbreconnect_count", 5);
		g_fDBReconnectTime = hLR_Settings.GetFloat("lr_dbreconnect_time", 5.0);

		if(g_iDBReconnectCount <= 0) {g_iDBReconnectCount = 5;}
		if(g_fDBReconnectTime <= 0.0) {g_fDBReconnectTime = 5.0;}

	}
	else CrashLR("Section MainSettings is not found (%s)", sPath);

	delete hLR_Settings;
	SetSettingsType();
}

public void SetSettingsType()
{
	char sBuffer[64], sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/levels_ranks/settings_stats.ini");
	KeyValues hLR_Settings = new KeyValues("LR_Settings");

	if(!hLR_Settings.ImportFromFile(sPath) || !hLR_Settings.GotoFirstSubKey())
	{
		CrashLR("(%s) is not found", sPath);
	}

	hLR_Settings.Rewind();

	switch(g_iTypeStatistics)
	{
		case 0:
		{
			if(hLR_Settings.JumpToKey("Exp_Stats"))
			{
				g_iGiveKill = hLR_Settings.GetNum("lr_kill", 5);
				g_iGiveDeath = hLR_Settings.GetNum("lr_death", 5);
				g_iGiveHeadShot = hLR_Settings.GetNum("lr_headshot", 1);
				g_iGiveAssist = hLR_Settings.GetNum("lr_assist", 1);
				g_iGiveSuicide = hLR_Settings.GetNum("lr_suicide", 6);
				g_iGiveTeamKill = hLR_Settings.GetNum("lr_teamkill", 6);
				g_iRoundWin = hLR_Settings.GetNum("lr_winround", 2);
				g_iRoundLose = hLR_Settings.GetNum("lr_loseround", 2);
				g_iRoundMVP = hLR_Settings.GetNum("lr_mvpround", 3);
				g_iBombPlanted = hLR_Settings.GetNum("lr_bombplanted", 2);
				g_iBombDefused = hLR_Settings.GetNum("lr_bombdefused", 2);
				g_iBombDropped = hLR_Settings.GetNum("lr_bombdropped", 1);
				g_iBombPickup = hLR_Settings.GetNum("lr_bombpickup", 1);
				g_iHostageKilled = hLR_Settings.GetNum("lr_hostagekilled", 4);
				g_iHostageRescued = hLR_Settings.GetNum("lr_hostagerescued", 3);

				for(int i = 0; i <= 10; i++)
				{
					FormatEx(sBuffer, sizeof(sBuffer), "lr_bonus_%i", i + 1);
					g_iBonus[i] = hLR_Settings.GetNum(sBuffer, i + 2);
				}
			}
			else CrashLR("Section Exp_Stats is not found (%s)", sPath);
		}

		case 1:
		{
			if(hLR_Settings.JumpToKey("Elo_Stats"))
			{
				g_fKillCoeff = hLR_Settings.GetFloat("lr_killcoeff", 5.0);

				if(g_fKillCoeff < 2.0 || g_fKillCoeff > 8.0)
				{
					g_fKillCoeff = 5.0;
				}

				g_iGiveCalibration = hLR_Settings.GetNum("lr_calibration", 15);

				if(g_iGiveCalibration > 20)
				{
					g_iGiveCalibration = 15;
				}

				g_iGiveHeadShot = hLR_Settings.GetNum("lr_headshot", 1);
				g_iGiveAssist = hLR_Settings.GetNum("lr_assist", 1);
				g_iGiveSuicide = hLR_Settings.GetNum("lr_suicide", 1);
				g_iGiveTeamKill = hLR_Settings.GetNum("lr_teamkill", 4);
				g_iRoundWin = hLR_Settings.GetNum("lr_winround", 2);
				g_iRoundLose = hLR_Settings.GetNum("lr_loseround", 2);
				g_iRoundMVP = hLR_Settings.GetNum("lr_mvpround", 1);
				g_iBombPlanted = hLR_Settings.GetNum("lr_bombplanted", 5);
				g_iBombDefused = hLR_Settings.GetNum("lr_bombdefused", 5);
				g_iBombDropped = hLR_Settings.GetNum("lr_bombdropped", 2);
				g_iBombPickup = hLR_Settings.GetNum("lr_bombpickup", 2);
				g_iHostageKilled = hLR_Settings.GetNum("lr_hostagekilled", 15);
				g_iHostageRescued = hLR_Settings.GetNum("lr_hostagerescued", 5);

				for(int i = 0; i <= 10; i++)
				{
					FormatEx(sBuffer, sizeof(sBuffer), "lr_bonus_%i", i + 1);
					g_iBonus[i] = hLR_Settings.GetNum(sBuffer, i + 1);
				}
			}
			else CrashLR("Section Elo_Stats is not found (%s)", sPath);
		}
	}

	delete hLR_Settings;
	SetSettingsRank();
}

public void SetSettingsRank()
{
	char sPath[PLATFORM_MAX_PATH];
	KeyValues hLR_Settings = new KeyValues("LR_Settings");

	switch(g_iTypeStatistics)
	{
		case 2:
		{
			BuildPath(Path_SM, sPath, sizeof(sPath), "configs/levels_ranks/settings_ranks_synhc.ini");

			if(!hLR_Settings.ImportFromFile(sPath) || !hLR_Settings.GotoFirstSubKey())
			{
				CrashLR("(%s) is not found", sPath);
			}

			hLR_Settings.Rewind();

			if(hLR_Settings.JumpToKey("Ranks"))
			{
				int iRanksCount = 0;
				hLR_Settings.GotoFirstSubKey();

				do
				{
					hLR_Settings.GetString("name", g_sShowRank[iRanksCount], sizeof(g_sShowRank[]));

					if(iRanksCount > 1)
					{
						g_iShowExp[iRanksCount] = hLR_Settings.GetNum("value", 0);
					}
					iRanksCount++;
				}
				while(hLR_Settings.GotoNextKey());
			}
			else CrashLR("Section Ranks is not found (%s)", sPath);
		}

		default:
		{
			BuildPath(Path_SM, sPath, sizeof(sPath), "configs/levels_ranks/settings_ranks.ini");

			if(!hLR_Settings.ImportFromFile(sPath) || !hLR_Settings.GotoFirstSubKey())
			{
				CrashLR("(%s) is not found", sPath);
			}

			hLR_Settings.Rewind();

			if(hLR_Settings.JumpToKey("Ranks"))
			{
				int iRanksCount = 0;
				hLR_Settings.GotoFirstSubKey();

				do
				{
					hLR_Settings.GetString("name", g_sShowRank[iRanksCount], sizeof(g_sShowRank[]));

					if(iRanksCount > 1)
					{
						switch(g_iTypeStatistics)
						{
							case 0: g_iShowExp[iRanksCount] = hLR_Settings.GetNum("value_0", 0);
							case 1: g_iShowExp[iRanksCount] = hLR_Settings.GetNum("value_1", 0);
						}
					}
					iRanksCount++;
				}
				while(hLR_Settings.GotoNextKey());
			}
			else CrashLR("Section Ranks is not found (%s)", sPath);
		}
	}

	delete hLR_Settings;
}