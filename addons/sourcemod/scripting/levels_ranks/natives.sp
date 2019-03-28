public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("LR_CheckCountPlayers", Native_LR_CheckCountPlayers);
	CreateNative("LR_GetTypeStatistics", Native_LR_GetTypeStatistics);
	CreateNative("LR_GetClientPos", Native_LR_GetClientPos);
	CreateNative("LR_GetClientInfo", Native_LR_GetClientInfo);
	CreateNative("LR_ChangeClientValue", Native_LR_ChangeClientValue);
	CreateNative("LR_IsClientVIP", Native_LR_IsClientVIP);
	CreateNative("LR_SetClientValue", Native_LR_SetClientValue);
	CreateNative("LR_SetMultiplierValue", Native_LR_SetMultiplierValue);
	CreateNative("LR_MenuInventory", Native_LR_MenuInventory);
	CreateNative("LR_SetClientVIP", Native_LR_SetClientVIP);
	RegPluginLibrary("levelsranks");
}

public int Native_LR_CheckCountPlayers(Handle hPlugin, int iNumParams)
{
	if(g_iCountPlayers >= g_iMinimumPlayers)
		return true;
	return false;
}

public int Native_LR_GetTypeStatistics(Handle hPlugin, int iNumParams)
{
	return g_iTypeStatistics;
}

public int Native_LR_GetClientPos(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	if(g_bInitialized[iClient])
		return g_iDBRankPlayer[iClient];
	return 0;
}

public int Native_LR_GetClientInfo(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	int iStats = GetNativeCell(2);

	if(g_bInitialized[iClient] && (-1 < iStats < 8))
	{
		return g_iClientData[iClient][iStats];
	}

	return 0;
}

public int Native_LR_ChangeClientValue(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	int iValue = GetNativeCell(2);

	if(g_bInitialized[iClient])
	{
		return SetExpEvent(iClient, iValue);
	}

	return 0;
}

public int Native_LR_SetClientValue(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	int iValue = GetNativeCell(2);

	if(g_iTypeStatistics == 2 && g_bInitialized[iClient])
	{
		EXP(iClient) = iValue;
		CheckRank(iClient);
		return true;
	}

	return false;
}

public int Native_LR_SetMultiplierValue(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	if(g_iTypeStatistics == 0 && g_bInitialized[iClient])
	{
		g_fCoefficient[iClient][0] = GetNativeCell(2);
		g_fCoefficient[iClient][1] = GetNativeCell(3);
		return true;
	}

	return false;
}

public int Native_LR_MenuInventory(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	if(g_bInitialized[iClient])
	{
		InventoryMenu(iClient);
	}
}

public int Native_LR_IsClientVIP(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	if(g_bInitialized[iClient] && IsClientVip(iClient))
	{
		return true;
	}

	return false;
}

public int Native_LR_SetClientVIP(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	int iRank = GetNativeCell(2);

	if(g_bInitialized[iClient])
	{
		if(iRank > 0)
		{
			RANK(iClient) = iRank;
			VIP(iClient) = 1;
		}
		else VIP(iClient) = 0;
		CheckRank(iClient);
		return true;
	}

	return false;
}