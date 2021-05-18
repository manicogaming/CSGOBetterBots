public void PrepareMirageExecutes()
{
	int[] clients = new int[MaxClients];
	
	Client_Get(clients, CLIENTFILTER_TEAMONE | CLIENTFILTER_BOTS);
	
	if (IsValidClient(clients[0]) && IsValidClient(clients[1]) && IsValidClient(clients[2]) && IsValidClient(clients[3]) && IsValidClient(clients[4]))
	{
		switch (g_iRndExecute)
		{
			case 1: //A Execute
			{
				GetNade("CT Smoke", g_fSmokePos[clients[0]], g_fSmokeLookAt[clients[0]], g_fSmokeAngles[clients[0]], g_bSmokeJumpthrow[clients[0]], g_bSmokeCrouch[clients[0]], g_bIsFlashbang[clients[0]], g_bIsMolotov[clients[0]]);
				GetNade("Stairs Smoke", g_fSmokePos[clients[1]], g_fSmokeLookAt[clients[1]], g_fSmokeAngles[clients[1]], g_bSmokeJumpthrow[clients[1]], g_bSmokeCrouch[clients[1]], g_bIsFlashbang[clients[1]], g_bIsMolotov[clients[1]]);
				GetNade("Jungle Smoke", g_fSmokePos[clients[2]], g_fSmokeLookAt[clients[2]], g_fSmokeAngles[clients[2]], g_bSmokeJumpthrow[clients[2]], g_bSmokeCrouch[clients[2]], g_bIsFlashbang[clients[2]], g_bIsMolotov[clients[2]]);
				GetNade("Sandwich Molotov", g_fSmokePos[clients[3]], g_fSmokeLookAt[clients[3]], g_fSmokeAngles[clients[3]], g_bSmokeJumpthrow[clients[3]], g_bSmokeCrouch[clients[3]], g_bIsFlashbang[clients[3]], g_bIsMolotov[clients[3]]);
				
				GetNade("Lamp Flash", g_fFlashPos[clients[0]], g_fFlashLookAt[clients[0]], g_fFlashAngles[clients[0]], g_bFlashJumpthrow[clients[0]], g_bFlashCrouch[clients[0]], g_bIsFlashbang[clients[0]], g_bIsMolotov[clients[0]]);
				GetNade("A Site Flash", g_fFlashPos[clients[2]], g_fFlashLookAt[clients[2]], g_fFlashAngles[clients[2]], g_bFlashJumpthrow[clients[2]], g_bFlashCrouch[clients[2]], g_bIsFlashbang[clients[2]], g_bIsMolotov[clients[2]]);
				GetNade("Palace Flash", g_fFlashPos[clients[4]], g_fFlashLookAt[clients[4]], g_fFlashAngles[clients[4]], g_bFlashJumpthrow[clients[4]], g_bFlashCrouch[clients[4]], g_bIsFlashbang[clients[4]], g_bIsMolotov[clients[4]]);
				
				g_bHasThrownSmoke[clients[4]] = true;
				
				StripPlayerGrenades(clients[0]);
				GivePlayerItem(clients[0], "weapon_smokegrenade");
				GivePlayerItem(clients[0], "weapon_flashbang");
				
				StripPlayerGrenades(clients[1]);
				GivePlayerItem(clients[1], "weapon_smokegrenade");
				
				StripPlayerGrenades(clients[2]);
				GivePlayerItem(clients[2], "weapon_smokegrenade");
				GivePlayerItem(clients[2], "weapon_flashbang");
				
				StripPlayerGrenades(clients[3]);
				GivePlayerItem(clients[3], "weapon_molotov");
				
				StripPlayerGrenades(clients[4]);
				GivePlayerItem(clients[4], "weapon_flashbang");
				
				g_bDoExecute = true;
				g_bNeedCoordination = true;
			}
			case 2: //Mid Execute
			{
				GetNade("Top-Mid Smoke", g_fSmokePos[clients[0]], g_fSmokeLookAt[clients[0]], g_fSmokeAngles[clients[0]], g_bSmokeJumpthrow[clients[0]], g_bSmokeCrouch[clients[0]], g_bIsFlashbang[clients[0]], g_bIsMolotov[clients[0]]);
				GetNade("Mid-Short Smoke", g_fSmokePos[clients[1]], g_fSmokeLookAt[clients[1]], g_fSmokeAngles[clients[1]], g_bSmokeJumpthrow[clients[1]], g_bSmokeCrouch[clients[1]], g_bIsFlashbang[clients[1]], g_bIsMolotov[clients[1]]);
				GetNade("Window Smoke", g_fSmokePos[clients[2]], g_fSmokeLookAt[clients[2]], g_fSmokeAngles[clients[2]], g_bSmokeJumpthrow[clients[2]], g_bSmokeCrouch[clients[2]], g_bIsFlashbang[clients[2]], g_bIsMolotov[clients[2]]);
				GetNade("Con Molotov", g_fSmokePos[clients[3]], g_fSmokeLookAt[clients[3]], g_fSmokeAngles[clients[3]], g_bSmokeJumpthrow[clients[3]], g_bSmokeCrouch[clients[3]], g_bIsFlashbang[clients[3]], g_bIsMolotov[clients[3]]);
				GetNade("Top Con Smoke", g_fSmokePos[clients[4]], g_fSmokeLookAt[clients[4]], g_fSmokeAngles[clients[4]], g_bSmokeJumpthrow[clients[4]], g_bSmokeCrouch[clients[4]], g_bIsFlashbang[clients[4]], g_bIsMolotov[clients[4]]);
				
				GetNade("Connector Flash", g_fFlashPos[clients[0]], g_fFlashLookAt[clients[0]], g_fFlashAngles[clients[0]], g_bFlashJumpthrow[clients[0]], g_bFlashCrouch[clients[0]], g_bIsFlashbang[clients[0]], g_bIsMolotov[clients[0]]);
				
				StripPlayerGrenades(clients[0]);
				GivePlayerItem(clients[0], "weapon_smokegrenade");
				GivePlayerItem(clients[0], "weapon_flashbang");
				
				StripPlayerGrenades(clients[1]);
				GivePlayerItem(clients[1], "weapon_smokegrenade");
				
				StripPlayerGrenades(clients[2]);
				GivePlayerItem(clients[2], "weapon_smokegrenade");
				
				StripPlayerGrenades(clients[3]);
				GivePlayerItem(clients[3], "weapon_molotov");
				
				StripPlayerGrenades(clients[4]);
				GivePlayerItem(clients[4], "weapon_smokegrenade");
				
				g_bDoExecute = true;
				g_bNeedCoordination = false;
			}
			case 3: //B Execute
			{
				GetNade("Short-Left Smoke", g_fSmokePos[clients[0]], g_fSmokeLookAt[clients[0]], g_fSmokeAngles[clients[0]],  g_bSmokeJumpthrow[clients[0]], g_bSmokeCrouch[clients[0]], g_bIsFlashbang[clients[0]], g_bIsMolotov[clients[0]]);
				GetNade("Short-Right Smoke", g_fSmokePos[clients[1]], g_fSmokeLookAt[clients[1]], g_fSmokeAngles[clients[1]], g_bSmokeJumpthrow[clients[1]], g_bSmokeCrouch[clients[1]], g_bIsFlashbang[clients[1]], g_bIsMolotov[clients[1]]);
				GetNade("Market Door Smoke", g_fSmokePos[clients[2]], g_fSmokeLookAt[clients[2]], g_fSmokeAngles[clients[2]], g_bSmokeJumpthrow[clients[2]], g_bSmokeCrouch[clients[2]], g_bIsFlashbang[clients[2]], g_bIsMolotov[clients[2]]);
				GetNade("Market Window Smoke", g_fSmokePos[clients[3]], g_fSmokeLookAt[clients[3]], g_fSmokeAngles[clients[3]], g_bSmokeJumpthrow[clients[3]], g_bSmokeCrouch[clients[3]], g_bIsFlashbang[clients[3]], g_bIsMolotov[clients[3]]);
				
				GetNade("B Corner Flash", g_fFlashPos[clients[0]], g_fFlashLookAt[clients[0]], g_fFlashAngles[clients[0]], g_bFlashJumpthrow[clients[0]], g_bFlashCrouch[clients[0]], g_bIsFlashbang[clients[0]], g_bIsMolotov[clients[0]]);
				GetNade("Car Flash", g_fFlashPos[clients[1]], g_fFlashLookAt[clients[1]], g_fFlashAngles[clients[1]], g_bFlashJumpthrow[clients[1]], g_bFlashCrouch[clients[1]], g_bIsFlashbang[clients[1]], g_bIsMolotov[clients[1]]);
				GetNade("B Short Flash", g_fFlashPos[clients[2]], g_fFlashLookAt[clients[2]], g_fFlashAngles[clients[2]], g_bFlashJumpthrow[clients[2]], g_bFlashCrouch[clients[2]], g_bIsFlashbang[clients[2]], g_bIsMolotov[clients[2]]);
				GetNade("B Flash", g_fFlashPos[clients[3]], g_fFlashLookAt[clients[3]], g_fFlashAngles[clients[3]], g_bFlashJumpthrow[clients[3]], g_bFlashCrouch[clients[3]], g_bIsFlashbang[clients[3]], g_bIsMolotov[clients[3]]);
				
				g_bDoNothing[clients[4]] = true;
				
				GetPosition("Underpass Position", g_fHoldLookPos[clients[4]]);
				
				int iUnderpassAreaIDs[] =  {
					921, 270, 885
				};
				
				navArea[clients[4]] = NavMesh_FindAreaByID(iUnderpassAreaIDs[Math_GetRandomInt(0, sizeof(iUnderpassAreaIDs) - 1)]);
				navArea[clients[4]].GetRandomPoint(g_fHoldPos[clients[4]]);
				
				StripPlayerGrenades(clients[0]);
				GivePlayerItem(clients[0], "weapon_smokegrenade");
				GivePlayerItem(clients[0], "weapon_flashbang");
				
				StripPlayerGrenades(clients[1]);
				GivePlayerItem(clients[1], "weapon_smokegrenade");
				GivePlayerItem(clients[1], "weapon_flashbang");
				
				StripPlayerGrenades(clients[2]);
				GivePlayerItem(clients[2], "weapon_smokegrenade");
				GivePlayerItem(clients[2], "weapon_flashbang");
				
				StripPlayerGrenades(clients[3]);
				GivePlayerItem(clients[3], "weapon_smokegrenade");
				GivePlayerItem(clients[3], "weapon_flashbang");
				
				g_bDoExecute = true;
				g_bNeedCoordination = true;
			}
		}
	}
}