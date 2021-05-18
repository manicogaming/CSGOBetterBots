public void PrepareVertigoExecutes()
{
	int[] clients = new int[MaxClients];
	
	Client_Get(clients, CLIENTFILTER_TEAMONE | CLIENTFILTER_BOTS);
	
	if (IsValidClient(clients[0]) && IsValidClient(clients[1]) && IsValidClient(clients[2]) && IsValidClient(clients[3]) && IsValidClient(clients[4]))
	{
		switch (g_iRndExecute)
		{
			case 1: //A Execute
			{
				GetNade("A Site Smoke", g_fSmokePos[clients[0]], g_fSmokeLookAt[clients[0]], g_fSmokeAngles[clients[0]],  g_bSmokeJumpthrow[clients[0]], g_bSmokeCrouch[clients[0]], g_bIsFlashbang[clients[0]], g_bIsMolotov[clients[0]]);
				GetNade("A Connector Smoke", g_fSmokePos[clients[1]], g_fSmokeLookAt[clients[1]], g_fSmokeAngles[clients[1]], g_bSmokeJumpthrow[clients[1]], g_bSmokeCrouch[clients[1]], g_bIsFlashbang[clients[1]], g_bIsMolotov[clients[1]]);
				GetNade("Headshot Smoke", g_fSmokePos[clients[2]], g_fSmokeLookAt[clients[2]], g_fSmokeAngles[clients[2]], g_bSmokeJumpthrow[clients[2]], g_bSmokeCrouch[clients[2]], g_bIsFlashbang[clients[2]], g_bIsMolotov[clients[2]]);
				GetNade("Sandbags Molotov", g_fSmokePos[clients[3]], g_fSmokeLookAt[clients[3]], g_fSmokeAngles[clients[3]], g_bSmokeJumpthrow[clients[3]], g_bSmokeCrouch[clients[3]], g_bIsFlashbang[clients[3]], g_bIsMolotov[clients[3]]);
				GetNade("Short Smoke", g_fSmokePos[clients[4]], g_fSmokeLookAt[clients[4]], g_fSmokeAngles[clients[4]], g_bSmokeJumpthrow[clients[4]], g_bSmokeCrouch[clients[4]], g_bIsFlashbang[clients[4]], g_bIsMolotov[clients[4]]);
				
				GetNade("A Site Flash", g_fFlashPos[clients[2]], g_fFlashLookAt[clients[2]], g_fFlashAngles[clients[2]], g_bFlashJumpthrow[clients[2]], g_bFlashCrouch[clients[2]], g_bIsFlashbang[clients[2]], g_bIsMolotov[clients[2]]);
				GetNade("A Deep Flash", g_fFlashPos[clients[3]], g_fFlashLookAt[clients[3]], g_fFlashAngles[clients[3]], g_bFlashJumpthrow[clients[3]], g_bFlashCrouch[clients[3]], g_bIsFlashbang[clients[3]], g_bIsMolotov[clients[3]]);
				GetNade("A Connector Flash", g_fFlashPos[clients[4]], g_fFlashLookAt[clients[4]], g_fFlashAngles[clients[4]], g_bFlashJumpthrow[clients[4]], g_bFlashCrouch[clients[4]], g_bIsFlashbang[clients[4]], g_bIsMolotov[clients[4]]);
				
				g_bSkipPosition[clients[4]] = true;
				
				StripPlayerGrenades(clients[0]);
				GivePlayerItem(clients[0], "weapon_smokegrenade");
				
				StripPlayerGrenades(clients[1]);
				GivePlayerItem(clients[1], "weapon_smokegrenade");
				
				StripPlayerGrenades(clients[2]);
				GivePlayerItem(clients[2], "weapon_smokegrenade");
				GivePlayerItem(clients[2], "weapon_flashbang");
				
				StripPlayerGrenades(clients[3]);
				GivePlayerItem(clients[3], "weapon_molotov");
				GivePlayerItem(clients[3], "weapon_flashbang");
				
				StripPlayerGrenades(clients[4]);
				GivePlayerItem(clients[4], "weapon_smokegrenade");
				GivePlayerItem(clients[4], "weapon_flashbang");
					
				g_bDoExecute = true;
				g_bNeedCoordination = true;
			}
			case 2: //B Execute
			{
				GetNade("Generator Right Smoke", g_fSmokePos[clients[0]], g_fSmokeLookAt[clients[0]], g_fSmokeAngles[clients[0]],  g_bSmokeJumpthrow[clients[0]], g_bSmokeCrouch[clients[0]], g_bIsFlashbang[clients[0]], g_bIsMolotov[clients[0]]);
				GetNade("Generator Left Smoke", g_fSmokePos[clients[1]], g_fSmokeLookAt[clients[1]], g_fSmokeAngles[clients[1]], g_bSmokeJumpthrow[clients[1]], g_bSmokeCrouch[clients[1]], g_bIsFlashbang[clients[1]], g_bIsMolotov[clients[1]]);
				GetNade("B Pillar Smoke", g_fSmokePos[clients[2]], g_fSmokeLookAt[clients[2]], g_fSmokeAngles[clients[2]], g_bSmokeJumpthrow[clients[2]], g_bSmokeCrouch[clients[2]], g_bIsFlashbang[clients[2]], g_bIsMolotov[clients[2]]);
				GetNade("Quad Molotov", g_fSmokePos[clients[3]], g_fSmokeLookAt[clients[3]], g_fSmokeAngles[clients[3]], g_bSmokeJumpthrow[clients[3]], g_bSmokeCrouch[clients[3]], g_bIsFlashbang[clients[3]], g_bIsMolotov[clients[3]]);
				GetNade("Big Molotov", g_fSmokePos[clients[4]], g_fSmokeLookAt[clients[4]], g_fSmokeAngles[clients[4]], g_bSmokeJumpthrow[clients[4]], g_bSmokeCrouch[clients[4]], g_bIsFlashbang[clients[4]], g_bIsMolotov[clients[4]]);
				
				GetNade("B Short Flash", g_fFlashPos[clients[1]], g_fFlashLookAt[clients[1]], g_fFlashAngles[clients[1]], g_bFlashJumpthrow[clients[1]], g_bFlashCrouch[clients[1]], g_bIsFlashbang[clients[1]], g_bIsMolotov[clients[1]]);
				GetNade("B Site Flash", g_fFlashPos[clients[2]], g_fFlashLookAt[clients[2]], g_fFlashAngles[clients[2]], g_bFlashJumpthrow[clients[2]], g_bFlashCrouch[clients[2]], g_bIsFlashbang[clients[2]], g_bIsMolotov[clients[2]]);
				GetNade("B Site Flash", g_fFlashPos[clients[4]], g_fFlashLookAt[clients[4]], g_fFlashAngles[clients[4]], g_bFlashJumpthrow[clients[4]], g_bFlashCrouch[clients[4]], g_bIsFlashbang[clients[4]], g_bIsMolotov[clients[4]]);
				
				StripPlayerGrenades(clients[0]);
				GivePlayerItem(clients[0], "weapon_smokegrenade");
				
				StripPlayerGrenades(clients[1]);
				GivePlayerItem(clients[1], "weapon_smokegrenade");
				GivePlayerItem(clients[1], "weapon_flashbang");
				
				StripPlayerGrenades(clients[2]);
				GivePlayerItem(clients[2], "weapon_smokegrenade");
				GivePlayerItem(clients[2], "weapon_flashbang");
				
				StripPlayerGrenades(clients[3]);
				GivePlayerItem(clients[3], "weapon_molotov");
				
				StripPlayerGrenades(clients[4]);
				GivePlayerItem(clients[4], "weapon_molotov");
				GivePlayerItem(clients[4], "weapon_flashbang");
					
				g_bDoExecute = true;
				g_bNeedCoordination = true;
			}
		}
	}
}