public void PrepareNukeExecutes()
{
	int[] clients = new int[MaxClients];
	
	Client_Get(clients, CLIENTFILTER_TEAMONE | CLIENTFILTER_BOTS);
	
	if (IsValidClient(clients[0]) && IsValidClient(clients[1]) && IsValidClient(clients[2]) && IsValidClient(clients[3]) && IsValidClient(clients[4]))
	{
		switch (g_iRndExecute)
		{
			case 1: //Outside Execute
			{
				GetNade("T Red Smoke", g_fSmokePos[clients[0]], g_fSmokeLookAt[clients[0]], g_fSmokeAngles[clients[0]],  g_bSmokeJumpthrow[clients[0]], g_bSmokeCrouch[clients[0]], g_bIsFlashbang[clients[0]], g_bIsMolotov[clients[0]]);
				GetNade("1st Outside Smoke", g_fSmokePos[clients[1]], g_fSmokeLookAt[clients[1]], g_fSmokeAngles[clients[1]], g_bSmokeJumpthrow[clients[1]], g_bSmokeCrouch[clients[1]], g_bIsFlashbang[clients[1]], g_bIsMolotov[clients[1]]);
				GetNade("2nd Outside Smoke", g_fSmokePos[clients[2]], g_fSmokeLookAt[clients[2]], g_fSmokeAngles[clients[2]], g_bSmokeJumpthrow[clients[2]], g_bSmokeCrouch[clients[2]], g_bIsFlashbang[clients[2]], g_bIsMolotov[clients[2]]);
				GetNade("Secret Molotov", g_fSmokePos[clients[3]], g_fSmokeLookAt[clients[3]], g_fSmokeAngles[clients[3]], g_bSmokeJumpthrow[clients[3]], g_bSmokeCrouch[clients[3]], g_bIsFlashbang[clients[3]], g_bIsMolotov[clients[3]]);
				
				GetNade("Outside Flash", g_fFlashPos[clients[0]], g_fFlashLookAt[clients[0]], g_fFlashAngles[clients[0]], g_bFlashJumpthrow[clients[0]], g_bFlashCrouch[clients[0]], g_bIsFlashbang[clients[0]], g_bIsMolotov[clients[0]]);
				
				g_bDoNothing[clients[4]] = true;
				
				GetPosition("Outside Position", g_fHoldLookPos[clients[4]]);
				
				int iOutsideAreaIDs[] =  {
					3607, 413, 2198, 2199, 160, 252
				};
				
				navArea[clients[4]] = NavMesh_FindAreaByID(iOutsideAreaIDs[Math_GetRandomInt(0, sizeof(iOutsideAreaIDs) - 1)]);
				navArea[clients[4]].GetRandomPoint(g_fHoldPos[clients[4]]);
				
				StripPlayerGrenades(clients[0]);
				GivePlayerItem(clients[0], "weapon_smokegrenade");
				GivePlayerItem(clients[0], "weapon_flashbang");
				
				StripPlayerGrenades(clients[1]);
				GivePlayerItem(clients[1], "weapon_smokegrenade");
				
				StripPlayerGrenades(clients[2]);
				GivePlayerItem(clients[2], "weapon_smokegrenade");
				
				StripPlayerGrenades(clients[3]);
				GivePlayerItem(clients[3], "weapon_molotov");
					
				g_bDoExecute = true;
				g_bNeedCoordination = true;
			}
			case 2: //A Execute
			{
				GetNade("Main Smoke", g_fSmokePos[clients[0]], g_fSmokeLookAt[clients[0]], g_fSmokeAngles[clients[0]],  g_bSmokeJumpthrow[clients[0]], g_bSmokeCrouch[clients[0]], g_bIsFlashbang[clients[0]], g_bIsMolotov[clients[0]]);
				GetNade("A Site Smoke", g_fSmokePos[clients[1]], g_fSmokeLookAt[clients[1]], g_fSmokeAngles[clients[1]], g_bSmokeJumpthrow[clients[1]], g_bSmokeCrouch[clients[1]], g_bIsFlashbang[clients[1]], g_bIsMolotov[clients[1]]);
				GetNade("Above Hut Molotov", g_fSmokePos[clients[2]], g_fSmokeLookAt[clients[2]], g_fSmokeAngles[clients[2]], g_bSmokeJumpthrow[clients[2]], g_bSmokeCrouch[clients[2]], g_bIsFlashbang[clients[2]], g_bIsMolotov[clients[2]]);
				
				GetNade("A Site Flash", g_fFlashPos[clients[2]], g_fFlashLookAt[clients[2]], g_fFlashAngles[clients[2]], g_bFlashJumpthrow[clients[2]], g_bFlashCrouch[clients[2]], g_bIsFlashbang[clients[2]], g_bIsMolotov[clients[2]]);
				
				g_bDoNothing[clients[3]] = true;
				g_bDoNothing[clients[4]] = true;
				
				GetPosition("Ramp Position", g_fHoldLookPos[clients[3]]);
				GetPosition("Squeaky Position", g_fHoldLookPos[clients[4]]);
				
				int iRampAreaIDs[] =  {
					449, 61, 112, 587, 1588
				};
				
				int iSqueakyAreaIDs[] =  {
					4236, 3919
				};
				
				navArea[clients[3]] = NavMesh_FindAreaByID(iRampAreaIDs[Math_GetRandomInt(0, sizeof(iRampAreaIDs) - 1)]);
				navArea[clients[3]].GetRandomPoint(g_fHoldPos[clients[3]]);
				
				navArea[clients[4]] = NavMesh_FindAreaByID(iSqueakyAreaIDs[Math_GetRandomInt(0, sizeof(iSqueakyAreaIDs) - 1)]);
				navArea[clients[4]].GetRandomPoint(g_fHoldPos[clients[4]]);
				
				StripPlayerGrenades(clients[0]);
				GivePlayerItem(clients[0], "weapon_smokegrenade");
				
				StripPlayerGrenades(clients[1]);
				GivePlayerItem(clients[1], "weapon_smokegrenade");
				
				StripPlayerGrenades(clients[2]);
				GivePlayerItem(clients[2], "weapon_molotov");
				GivePlayerItem(clients[2], "weapon_flashbang");
					
				g_bDoExecute = true;
				g_bNeedCoordination = true;
			}
		}
	}
}