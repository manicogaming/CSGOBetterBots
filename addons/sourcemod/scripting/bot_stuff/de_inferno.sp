public void PrepareInfernoExecutes()
{
	int[] clients = new int[MaxClients];
	
	Client_Get(clients, CLIENTFILTER_TEAMONE | CLIENTFILTER_BOTS);
	
	if (IsValidClient(clients[0]) && IsValidClient(clients[1]) && IsValidClient(clients[2]) && IsValidClient(clients[3]) && IsValidClient(clients[4]))
	{
		switch (g_iRndExecute)
		{
			case 1: //B Execute
			{
				GetNade("CT Smoke", g_fSmokePos[clients[0]], g_fSmokeLookAt[clients[0]], g_fSmokeAngles[clients[0]], g_fSmokeWaitTime[clients[0]], g_bSmokeJumpthrow[clients[0]], g_bSmokeCrouch[clients[0]], g_bIsFlashbang[clients[0]], g_bIsMolotov[clients[0]]);
				GetNade("Coffin Smoke", g_fSmokePos[clients[1]], g_fSmokeLookAt[clients[1]], g_fSmokeAngles[clients[1]], g_fSmokeWaitTime[clients[1]], g_bSmokeJumpthrow[clients[1]], g_bSmokeCrouch[clients[1]], g_bIsFlashbang[clients[1]], g_bIsMolotov[clients[1]]);
				GetNade("1st Box Molotov", g_fSmokePos[clients[2]], g_fSmokeLookAt[clients[2]], g_fSmokeAngles[clients[2]], g_fSmokeWaitTime[clients[2]], g_bSmokeJumpthrow[clients[2]], g_bSmokeCrouch[clients[2]], g_bIsFlashbang[clients[2]], g_bIsMolotov[clients[2]]);
				GetNade("2nd Box Molotov", g_fSmokePos[clients[3]], g_fSmokeLookAt[clients[3]], g_fSmokeAngles[clients[3]], g_fSmokeWaitTime[clients[3]], g_bSmokeJumpthrow[clients[3]], g_bSmokeCrouch[clients[3]], g_bIsFlashbang[clients[3]], g_bIsMolotov[clients[3]]);
				GetNade("Dark Molotov", g_fSmokePos[clients[4]], g_fSmokeLookAt[clients[4]], g_fSmokeAngles[clients[4]], g_fSmokeWaitTime[clients[4]], g_bSmokeJumpthrow[clients[4]], g_bSmokeCrouch[clients[4]], g_bIsFlashbang[clients[4]], g_bIsMolotov[clients[4]]);
				
				GetNade("B PopFlash", g_fFlashPos[clients[0]], g_fFlashLookAt[clients[0]], g_fFlashAngles[clients[0]], g_fFlashWaitTime[clients[0]], g_bFlashJumpthrow[clients[0]], g_bFlashCrouch[clients[0]], g_bIsFlashbang[clients[0]], g_bIsMolotov[clients[0]]);
				GetNade("B Site Flash", g_fFlashPos[clients[1]], g_fFlashLookAt[clients[1]], g_fFlashAngles[clients[1]], g_fFlashWaitTime[clients[1]], g_bFlashJumpthrow[clients[1]], g_bFlashCrouch[clients[1]], g_bIsFlashbang[clients[1]], g_bIsMolotov[clients[1]]);
			
				StripPlayerGrenades(clients[0]);
				GivePlayerItem(clients[0], "weapon_smokegrenade");
				GivePlayerItem(clients[0], "weapon_flashbang");
				
				StripPlayerGrenades(clients[1]);
				GivePlayerItem(clients[1], "weapon_smokegrenade");
				GivePlayerItem(clients[1], "weapon_flashbang");

				StripPlayerGrenades(clients[2]);
				GivePlayerItem(clients[2], "weapon_molotov");
				
				StripPlayerGrenades(clients[3]);
				GivePlayerItem(clients[3], "weapon_molotov");
				
				StripPlayerGrenades(clients[4]);
				GivePlayerItem(clients[4], "weapon_molotov");
				
				g_bDoExecute = true;
			}
			case 2: //A Short/Apps Execute
			{
				GetNade("Long A Smoke", g_fSmokePos[clients[0]], g_fSmokeLookAt[clients[0]], g_fSmokeAngles[clients[0]], g_fSmokeWaitTime[clients[0]], g_bSmokeJumpthrow[clients[0]], g_bSmokeCrouch[clients[0]], g_bIsFlashbang[clients[0]], g_bIsMolotov[clients[0]]);
				GetNade("Site-Library Smoke", g_fSmokePos[clients[1]], g_fSmokeLookAt[clients[1]], g_fSmokeAngles[clients[1]], g_fSmokeWaitTime[clients[1]], g_bSmokeJumpthrow[clients[1]], g_bSmokeCrouch[clients[1]], g_bIsFlashbang[clients[1]], g_bIsMolotov[clients[1]]);
				GetNade("Pit Smoke", g_fSmokePos[clients[2]], g_fSmokeLookAt[clients[2]], g_fSmokeAngles[clients[2]], g_fSmokeWaitTime[clients[2]], g_bSmokeJumpthrow[clients[2]], g_bSmokeCrouch[clients[2]], g_bIsFlashbang[clients[2]], g_bIsMolotov[clients[2]]);
				GetNade("Balcony Smoke", g_fSmokePos[clients[3]], g_fSmokeLookAt[clients[3]], g_fSmokeAngles[clients[3]], g_fSmokeWaitTime[clients[3]], g_bSmokeJumpthrow[clients[3]], g_bSmokeCrouch[clients[3]], g_bIsFlashbang[clients[3]], g_bIsMolotov[clients[3]]);
				
				GetNade("Pit Flash", g_fFlashPos[clients[1]], g_fFlashLookAt[clients[1]], g_fFlashAngles[clients[1]], g_fFlashWaitTime[clients[1]], g_bFlashJumpthrow[clients[1]], g_bFlashCrouch[clients[1]], g_bIsFlashbang[clients[1]], g_bIsMolotov[clients[1]]);
				GetNade("Balcony Flash", g_fFlashPos[clients[3]], g_fFlashLookAt[clients[3]], g_fFlashAngles[clients[3]], g_fFlashWaitTime[clients[3]], g_bFlashJumpthrow[clients[3]], g_bFlashCrouch[clients[3]], g_bIsFlashbang[clients[3]], g_bIsMolotov[clients[3]]);
				
				g_bDoNothing[clients[4]] = true;
				
				GetPosition("Balcony Position", g_fHoldLookPos[clients[4]], g_fPosWaitTime[clients[4]]);
				
				navArea[clients[4]] = NavMesh_FindAreaByID(3048);
				navArea[clients[4]].GetRandomPoint(g_fHoldPos[clients[4]]);
				
				StripPlayerGrenades(clients[0]);
				GivePlayerItem(clients[0], "weapon_smokegrenade");
				
				StripPlayerGrenades(clients[1]);
				GivePlayerItem(clients[1], "weapon_smokegrenade");
				GivePlayerItem(clients[1], "weapon_flashbang");

				StripPlayerGrenades(clients[2]);
				GivePlayerItem(clients[2], "weapon_smokegrenade");
				
				StripPlayerGrenades(clients[3]);
				GivePlayerItem(clients[3], "weapon_smokegrenade");
				GivePlayerItem(clients[3], "weapon_flashbang");
				
				g_bDoExecute = true;
			}
			case 3: //A Long Execute
			{
				GetNade("Short A Smoke", g_fSmokePos[clients[0]], g_fSmokeLookAt[clients[0]], g_fSmokeAngles[clients[0]], g_fSmokeWaitTime[clients[0]], g_bSmokeJumpthrow[clients[0]], g_bSmokeCrouch[clients[0]], g_bIsFlashbang[clients[0]], g_bIsMolotov[clients[0]]);
				GetNade("Arch Smoke", g_fSmokePos[clients[1]], g_fSmokeLookAt[clients[1]], g_fSmokeAngles[clients[1]], g_fSmokeWaitTime[clients[1]], g_bSmokeJumpthrow[clients[1]], g_bSmokeCrouch[clients[1]], g_bIsFlashbang[clients[1]], g_bIsMolotov[clients[1]]);
				GetNade("Graveyard Smoke", g_fSmokePos[clients[2]], g_fSmokeLookAt[clients[2]], g_fSmokeAngles[clients[2]], g_fSmokeWaitTime[clients[2]], g_bSmokeJumpthrow[clients[2]], g_bSmokeCrouch[clients[2]], g_bIsFlashbang[clients[2]], g_bIsMolotov[clients[2]]);
				GetNade("Library Smoke", g_fSmokePos[clients[3]], g_fSmokeLookAt[clients[3]], g_fSmokeAngles[clients[3]], g_fSmokeWaitTime[clients[3]], g_bSmokeJumpthrow[clients[3]], g_bSmokeCrouch[clients[3]], g_bIsFlashbang[clients[3]], g_bIsMolotov[clients[3]]);
				
				g_bDoNothing[clients[4]] = true;
				
				GetPosition("Balcony Position", g_fHoldLookPos[clients[4]], g_fPosWaitTime[clients[4]]);
				
				navArea[clients[4]] = NavMesh_FindAreaByID(3048);
				navArea[clients[4]].GetRandomPoint(g_fHoldPos[clients[4]]);
				
				StripPlayerGrenades(clients[0]);
				GivePlayerItem(clients[0], "weapon_smokegrenade");
				
				StripPlayerGrenades(clients[1]);
				GivePlayerItem(clients[1], "weapon_smokegrenade");

				StripPlayerGrenades(clients[2]);
				GivePlayerItem(clients[2], "weapon_smokegrenade");
				
				StripPlayerGrenades(clients[3]);
				GivePlayerItem(clients[3], "weapon_smokegrenade");
					
				g_bDoExecute = true;
			}
		}
	}
}