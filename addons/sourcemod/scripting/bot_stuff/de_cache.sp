public void PrepareCacheExecutes()
{
	int[] clients = new int[MaxClients];
	
	Client_Get(clients, CLIENTFILTER_TEAMONE | CLIENTFILTER_BOTS);
	
	if (IsValidClient(clients[0]) && IsValidClient(clients[1]) && IsValidClient(clients[2]) && IsValidClient(clients[3]) && IsValidClient(clients[4]))
	{
		switch (g_iRndExecute)
		{
			case 1: //A Execute
			{
				GetNade("A Cross Smoke", g_fSmokePos[clients[0]], g_fSmokeLookAt[clients[0]], g_fSmokeAngles[clients[0]],  g_bSmokeJumpthrow[clients[0]], g_bSmokeCrouch[clients[0]], g_bIsFlashbang[clients[0]], g_bIsMolotov[clients[0]]);
				GetNade("A Default Smoke", g_fSmokePos[clients[1]], g_fSmokeLookAt[clients[1]], g_fSmokeAngles[clients[1]], g_bSmokeJumpthrow[clients[1]], g_bSmokeCrouch[clients[1]], g_bIsFlashbang[clients[1]], g_bIsMolotov[clients[1]]);
				GetNade("A Balcony Smoke", g_fSmokePos[clients[2]], g_fSmokeLookAt[clients[2]], g_fSmokeAngles[clients[2]], g_bSmokeJumpthrow[clients[2]], g_bSmokeCrouch[clients[2]], g_bIsFlashbang[clients[2]], g_bIsMolotov[clients[2]]);
				
				GetNade("A Site Flash", g_fFlashPos[clients[0]], g_fFlashLookAt[clients[0]], g_fFlashAngles[clients[0]], g_bFlashJumpthrow[clients[0]], g_bFlashCrouch[clients[0]], g_bIsFlashbang[clients[0]], g_bIsMolotov[clients[0]]);
				
				g_bDoNothing[clients[3]] = true;
				g_bDoNothing[clients[4]] = true;
				
				GetPosition("A Main Position", g_fHoldLookPos[clients[3]]);
				GetPosition("Squeaky Position", g_fHoldLookPos[clients[4]]);
				
				
				int iAMainAreaIDs[] =  {
					750, 69, 57, 33, 752, 1337, 1338, 1339
				};
				
				int iSqueakyAreaIDs[] =  {
					142, 1042, 1041, 667, 128, 547, 666
				};
				
				navArea[clients[3]] = NavMesh_FindAreaByID(iAMainAreaIDs[Math_GetRandomInt(0, sizeof(iAMainAreaIDs) - 1)]);
				navArea[clients[3]].GetRandomPoint(g_fHoldPos[clients[3]]);
				
				navArea[clients[4]] = NavMesh_FindAreaByID(iSqueakyAreaIDs[Math_GetRandomInt(0, sizeof(iSqueakyAreaIDs) - 1)]);
				navArea[clients[4]].GetRandomPoint(g_fHoldPos[clients[4]]);
				
				StripPlayerGrenades(clients[0]);
				GivePlayerItem(clients[0], "weapon_smokegrenade");
				GivePlayerItem(clients[0], "weapon_flashbang");
				
				StripPlayerGrenades(clients[1]);
				GivePlayerItem(clients[1], "weapon_smokegrenade");
				
				StripPlayerGrenades(clients[2]);
				GivePlayerItem(clients[2], "weapon_smokegrenade");
					
				g_bDoExecute = true;
				g_bNeedCoordination = true;
			}
			case 2: //Mid Execute
			{
				GetNade("Mid Right Smoke", g_fSmokePos[clients[0]], g_fSmokeLookAt[clients[0]], g_fSmokeAngles[clients[0]],  g_bSmokeJumpthrow[clients[0]], g_bSmokeCrouch[clients[0]], g_bIsFlashbang[clients[0]], g_bIsMolotov[clients[0]]);
				GetNade("Mid Left Smoke", g_fSmokePos[clients[1]], g_fSmokeLookAt[clients[1]], g_fSmokeAngles[clients[1]], g_bSmokeJumpthrow[clients[1]], g_bSmokeCrouch[clients[1]], g_bIsFlashbang[clients[1]], g_bIsMolotov[clients[1]]);
				
				GetNade("Mid Flash", g_fFlashPos[clients[2]], g_fFlashLookAt[clients[2]], g_fFlashAngles[clients[2]], g_bFlashJumpthrow[clients[2]], g_bFlashCrouch[clients[2]], g_bIsFlashbang[clients[2]], g_bIsMolotov[clients[2]]);
				
				g_bHasThrownSmoke[clients[2]] = true;
				
				g_bDoNothing[clients[3]] = true;
				g_bDoNothing[clients[4]] = true;
				
				GetPosition("Mid Push Position", g_fHoldLookPos[clients[3]]);
				GetPosition("B Push Position", g_fHoldLookPos[clients[4]]);
				
				navArea[clients[3]] = NavMesh_FindAreaByID(205);
				navArea[clients[3]].GetRandomPoint(g_fHoldPos[clients[3]]);
				
				navArea[clients[4]] = NavMesh_FindAreaByID(205);
				navArea[clients[4]].GetRandomPoint(g_fHoldPos[clients[4]]);
				
				StripPlayerGrenades(clients[0]);
				GivePlayerItem(clients[0], "weapon_smokegrenade");
				
				StripPlayerGrenades(clients[1]);
				GivePlayerItem(clients[1], "weapon_smokegrenade");
				
				StripPlayerGrenades(clients[2]);
				GivePlayerItem(clients[2], "weapon_flashbang");
					
				g_bDoExecute = true;
				g_bNeedCoordination = true;
			}
			case 3: //B Execute
			{
				GetNade("CT Smoke", g_fSmokePos[clients[0]], g_fSmokeLookAt[clients[0]], g_fSmokeAngles[clients[0]], g_bSmokeJumpthrow[clients[0]], g_bSmokeCrouch[clients[0]], g_bIsFlashbang[clients[0]], g_bIsMolotov[clients[0]]);
				GetNade("Spray Molotov", g_fSmokePos[clients[1]], g_fSmokeLookAt[clients[1]], g_fSmokeAngles[clients[1]], g_bSmokeJumpthrow[clients[1]], g_bSmokeCrouch[clients[1]], g_bIsFlashbang[clients[1]], g_bIsMolotov[clients[1]]);
				GetNade("Headshot Molotov", g_fSmokePos[clients[2]], g_fSmokeLookAt[clients[2]], g_fSmokeAngles[clients[2]], g_bSmokeJumpthrow[clients[2]], g_bSmokeCrouch[clients[2]], g_bIsFlashbang[clients[2]], g_bIsMolotov[clients[2]]);
				
				GetNade("B PopFlash", g_fFlashPos[clients[0]], g_fFlashLookAt[clients[0]], g_fFlashAngles[clients[0]], g_bFlashJumpthrow[clients[0]], g_bFlashCrouch[clients[0]], g_bIsFlashbang[clients[0]], g_bIsMolotov[clients[0]]);
				
				g_bDoNothing[clients[3]] = true;
				g_bDoNothing[clients[4]] = true;
				
				GetPosition("B Position", g_fHoldLookPos[clients[3]]);
				GetPosition("B Position", g_fHoldLookPos[clients[4]]);
				
				int iBAreaIDs[] =  {
					1277, 54, 53, 1279
				};
				
				navArea[clients[3]] = NavMesh_FindAreaByID(iBAreaIDs[Math_GetRandomInt(0, sizeof(iBAreaIDs) - 1)]);
				navArea[clients[3]].GetRandomPoint(g_fHoldPos[clients[3]]);
				
				navArea[clients[4]] = NavMesh_FindAreaByID(iBAreaIDs[Math_GetRandomInt(0, sizeof(iBAreaIDs) - 1)]);
				navArea[clients[4]].GetRandomPoint(g_fHoldPos[clients[4]]);
				
				StripPlayerGrenades(clients[0]);
				GivePlayerItem(clients[0], "weapon_smokegrenade");
				GivePlayerItem(clients[0], "weapon_flashbang");
				
				StripPlayerGrenades(clients[1]);
				GivePlayerItem(clients[1], "weapon_molotov");
				
				StripPlayerGrenades(clients[2]);
				GivePlayerItem(clients[2], "weapon_molotov");
					
				g_bDoExecute = true;
				g_bNeedCoordination = true;
			}
		}
	}
}