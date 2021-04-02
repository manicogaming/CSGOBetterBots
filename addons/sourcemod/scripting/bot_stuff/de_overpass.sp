public void PrepareOverpassExecutes()
{
	int[] clients = new int[MaxClients];
	
	Client_Get(clients, CLIENTFILTER_TEAMONE | CLIENTFILTER_BOTS);
	
	if (IsValidClient(clients[0]) && IsValidClient(clients[1]) && IsValidClient(clients[2]) && IsValidClient(clients[3]) && IsValidClient(clients[4]))
	{
		switch (g_iRndExecute)
		{
			case 1: //A Execute
			{
				GetNade("Truck Smoke", g_fSmokePos[clients[0]], g_fSmokeLookAt[clients[0]], g_fSmokeAngles[clients[0]], g_fSmokeWaitTime[clients[0]], g_bSmokeJumpthrow[clients[0]], g_bSmokeCrouch[clients[0]], g_bIsFlashbang[clients[0]], g_bIsMolotov[clients[0]]);
				GetNade("Van Smoke", g_fSmokePos[clients[1]], g_fSmokeLookAt[clients[1]], g_fSmokeAngles[clients[1]], g_fSmokeWaitTime[clients[1]], g_bSmokeJumpthrow[clients[1]], g_bSmokeCrouch[clients[1]], g_bIsFlashbang[clients[1]], g_bIsMolotov[clients[1]]);
				GetNade("Box Smoke", g_fSmokePos[clients[2]], g_fSmokeLookAt[clients[2]], g_fSmokeAngles[clients[2]], g_fSmokeWaitTime[clients[2]], g_bSmokeJumpthrow[clients[2]], g_bSmokeCrouch[clients[2]], g_bIsFlashbang[clients[2]], g_bIsMolotov[clients[2]]);
				
				GetNade("A Site Flash", g_fFlashPos[clients[0]], g_fFlashLookAt[clients[0]], g_fFlashAngles[clients[0]], g_fFlashWaitTime[clients[0]], g_bFlashJumpthrow[clients[0]], g_bFlashCrouch[clients[0]], g_bIsFlashbang[clients[0]], g_bIsMolotov[clients[0]]);
				GetNade("Long Flash", g_fFlashPos[clients[2]], g_fFlashLookAt[clients[2]], g_fFlashAngles[clients[2]], g_fFlashWaitTime[clients[2]], g_bFlashJumpthrow[clients[2]], g_bFlashCrouch[clients[2]], g_bIsFlashbang[clients[2]], g_bIsMolotov[clients[2]]);
				
				g_bDoNothing[clients[3]] = true;
				g_bDoNothing[clients[4]] = true;
				
				GetPosition("Bathroom Position", g_fHoldLookPos[clients[3]], g_fPosWaitTime[clients[3]]);
				GetPosition("A Short Position", g_fHoldLookPos[clients[4]], g_fPosWaitTime[clients[4]]);
				
				int iBathroomAreaIDs[] =  {
					2349, 320, 1074, 2348, 455, 144, 4016, 2319, 12590, 81, 12587
				};
				
				int iShortAAreaIDs[] =  {
					50, 12626, 887, 12465
				};
				
				navArea[clients[3]] = NavMesh_FindAreaByID(iBathroomAreaIDs[Math_GetRandomInt(0, sizeof(iBathroomAreaIDs) - 1)]);
				navArea[clients[3]].GetRandomPoint(g_fHoldPos[clients[3]]);
				
				navArea[clients[4]] = NavMesh_FindAreaByID(iShortAAreaIDs[Math_GetRandomInt(0, sizeof(iShortAAreaIDs) - 1)]);
				navArea[clients[4]].GetRandomPoint(g_fHoldPos[clients[4]]);
				
				StripPlayerGrenades(clients[0]);
				GivePlayerItem(clients[0], "weapon_smokegrenade");
				GivePlayerItem(clients[0], "weapon_flashbang");
				
				StripPlayerGrenades(clients[1]);
				GivePlayerItem(clients[1], "weapon_smokegrenade");
				
				StripPlayerGrenades(clients[2]);
				GivePlayerItem(clients[2], "weapon_smokegrenade");
				GivePlayerItem(clients[2], "weapon_flashbang");
					
				g_bDoExecute = true;
			}
			case 2: //B Execute
			{
				GetNade("Pit Smoke", g_fSmokePos[clients[0]], g_fSmokeLookAt[clients[0]], g_fSmokeAngles[clients[0]], g_fSmokeWaitTime[clients[0]], g_bSmokeJumpthrow[clients[0]], g_bSmokeCrouch[clients[0]], g_bIsFlashbang[clients[0]], g_bIsMolotov[clients[0]]);
				GetNade("Balcony Smoke", g_fSmokePos[clients[1]], g_fSmokeLookAt[clients[1]], g_fSmokeAngles[clients[1]], g_fSmokeWaitTime[clients[1]], g_bSmokeJumpthrow[clients[1]], g_bSmokeCrouch[clients[1]], g_bIsFlashbang[clients[1]], g_bIsMolotov[clients[1]]);
				GetNade("Bridge Smoke", g_fSmokePos[clients[2]], g_fSmokeLookAt[clients[2]], g_fSmokeAngles[clients[2]], g_fSmokeWaitTime[clients[2]], g_bSmokeJumpthrow[clients[2]], g_bSmokeCrouch[clients[2]], g_bIsFlashbang[clients[2]], g_bIsMolotov[clients[2]]);
				GetNade("B Site Smoke", g_fSmokePos[clients[3]], g_fSmokeLookAt[clients[3]], g_fSmokeAngles[clients[3]], g_fSmokeWaitTime[clients[3]], g_bSmokeJumpthrow[clients[3]], g_bSmokeCrouch[clients[3]], g_bIsFlashbang[clients[3]], g_bIsMolotov[clients[3]]);
				GetNade("Toxic Molotov", g_fSmokePos[clients[4]], g_fSmokeLookAt[clients[4]], g_fSmokeAngles[clients[4]], g_fSmokeWaitTime[clients[4]], g_bSmokeJumpthrow[clients[4]], g_bSmokeCrouch[clients[4]], g_bIsFlashbang[clients[4]], g_bIsMolotov[clients[4]]);
				
				GetNade("B Site Flash", g_fFlashPos[clients[1]], g_fFlashLookAt[clients[1]], g_fFlashAngles[clients[1]], g_fFlashWaitTime[clients[1]], g_bFlashJumpthrow[clients[1]], g_bFlashCrouch[clients[1]], g_bIsFlashbang[clients[1]], g_bIsMolotov[clients[1]]);
				GetNade("Monster Flash", g_fFlashPos[clients[3]], g_fFlashLookAt[clients[3]], g_fFlashAngles[clients[3]], g_fFlashWaitTime[clients[3]], g_bFlashJumpthrow[clients[3]], g_bFlashCrouch[clients[3]], g_bIsFlashbang[clients[3]], g_bIsMolotov[clients[3]]);
				
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
				
				StripPlayerGrenades(clients[4]);
				GivePlayerItem(clients[4], "weapon_molotov");
					
				g_bDoExecute = true;
			}
		}
	}
}