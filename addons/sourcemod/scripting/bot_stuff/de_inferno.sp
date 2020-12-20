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
				GetNade("CT Smoke", g_fSmokePos[clients[0]], g_fSmokeLookAt[clients[0]], g_fSmokeAngles[clients[0]], g_fSmokeWaitTime[clients[0]], g_bSmokeJumpthrow[clients[0]], g_bSmokeCrouch[clients[0]], g_bIsFlashbang[clients[0]]);
				GetNade("Coffin Smoke", g_fSmokePos[clients[1]], g_fSmokeLookAt[clients[1]], g_fSmokeAngles[clients[1]], g_fSmokeWaitTime[clients[1]], g_bSmokeJumpthrow[clients[1]], g_bSmokeCrouch[clients[1]], g_bIsFlashbang[clients[1]]);
				
				GetNade("B PopFlash", g_fFlashPos[clients[0]], g_fFlashLookAt[clients[0]], g_fFlashAngles[clients[0]], g_fFlashWaitTime[clients[0]], g_bFlashJumpthrow[clients[0]], g_bFlashCrouch[clients[0]], g_bIsFlashbang[clients[0]]);
				GetNade("B Site Flash", g_fFlashPos[clients[1]], g_fFlashLookAt[clients[1]], g_fFlashAngles[clients[1]], g_fFlashWaitTime[clients[1]], g_bFlashJumpthrow[clients[1]], g_bFlashCrouch[clients[1]], g_bIsFlashbang[clients[1]]);
				
				g_bDoNothing[clients[2]] = true;
				g_bDoNothing[clients[3]] = true;
				g_bDoNothing[clients[4]] = true;
				
				GetPosition("CT Position", g_fHoldLookPos[clients[2]], g_fPosWaitTime[clients[2]]);
				GetPosition("CT Push Position", g_fHoldLookPos[clients[3]], g_fPosWaitTime[clients[3]]);
				GetPosition("Bottom Banana Position", g_fHoldLookPos[clients[4]], g_fPosWaitTime[clients[4]]);
				
				int iCTIDs[] =  {
					9, 3214, 3212, 507, 1823
				};
				
				int iCTPushIDs[] =  {
					118, 1824, 367, 1820, 1256
				};
				
				int iBottomBananaIDs[] =  {
					975, 313, 3353, 973, 56
				};
				
				navArea[clients[2]] = NavMesh_FindAreaByID(iCTIDs[Math_GetRandomInt(0, sizeof(iCTIDs) - 1)]);
				navArea[clients[2]].GetRandomPoint(g_fHoldPos[clients[2]]);
				
				navArea[clients[3]] = NavMesh_FindAreaByID(iCTPushIDs[Math_GetRandomInt(0, sizeof(iCTPushIDs) - 1)]);
				navArea[clients[3]].GetRandomPoint(g_fHoldPos[clients[3]]);
				
				navArea[clients[4]] = NavMesh_FindAreaByID(iBottomBananaIDs[Math_GetRandomInt(0, sizeof(iBottomBananaIDs) - 1)]);
				navArea[clients[4]].GetRandomPoint(g_fHoldPos[clients[4]]);
				
				if (GetPlayerWeaponSlot(clients[0], CS_SLOT_PRIMARY) != -1 && GetPlayerWeaponSlot(clients[1], CS_SLOT_PRIMARY) != -1 && GetEntProp(clients[0], Prop_Send, "m_iAccount") >= 500 && GetEntProp(clients[1], Prop_Send, "m_iAccount") >= 500)
				{
					FakeClientCommandEx(clients[0], "buy smokegrenade");
					FakeClientCommandEx(clients[0], "buy flashbang");
					
					FakeClientCommandEx(clients[1], "buy smokegrenade");
					FakeClientCommandEx(clients[1], "buy flashbang");
					
					g_bDoExecute = true;
				}
			}
			case 2: //A Short/Apps Execute
			{
				GetNade("Long A Smoke", g_fSmokePos[clients[0]], g_fSmokeLookAt[clients[0]], g_fSmokeAngles[clients[0]], g_fSmokeWaitTime[clients[0]], g_bSmokeJumpthrow[clients[0]], g_bSmokeCrouch[clients[0]], g_bIsFlashbang[clients[0]]);
				GetNade("Site-Library Smoke", g_fSmokePos[clients[1]], g_fSmokeLookAt[clients[1]], g_fSmokeAngles[clients[1]], g_fSmokeWaitTime[clients[1]], g_bSmokeJumpthrow[clients[1]], g_bSmokeCrouch[clients[1]], g_bIsFlashbang[clients[1]]);
				GetNade("Pit Smoke", g_fSmokePos[clients[2]], g_fSmokeLookAt[clients[2]], g_fSmokeAngles[clients[2]], g_fSmokeWaitTime[clients[2]], g_bSmokeJumpthrow[clients[2]], g_bSmokeCrouch[clients[2]], g_bIsFlashbang[clients[2]]);
				GetNade("Balcony Smoke", g_fSmokePos[clients[3]], g_fSmokeLookAt[clients[3]], g_fSmokeAngles[clients[3]], g_fSmokeWaitTime[clients[3]], g_bSmokeJumpthrow[clients[3]], g_bSmokeCrouch[clients[3]], g_bIsFlashbang[clients[3]]);
				
				GetNade("Pit Flash", g_fFlashPos[clients[1]], g_fFlashLookAt[clients[1]], g_fFlashAngles[clients[1]], g_fFlashWaitTime[clients[1]], g_bFlashJumpthrow[clients[1]], g_bFlashCrouch[clients[1]], g_bIsFlashbang[clients[1]]);
				GetNade("Balcony Flash", g_fFlashPos[clients[3]], g_fFlashLookAt[clients[3]], g_fFlashAngles[clients[3]], g_fFlashWaitTime[clients[3]], g_bFlashJumpthrow[clients[3]], g_bFlashCrouch[clients[3]], g_bIsFlashbang[clients[3]]);
				
				g_bDoNothing[clients[4]] = true;
				
				GetPosition("Balcony Position", g_fHoldLookPos[clients[4]], g_fPosWaitTime[clients[4]]);
				
				navArea[clients[4]] = NavMesh_FindAreaByID(3048);
				navArea[clients[4]].GetRandomPoint(g_fHoldPos[clients[4]]);
				
				if (GetPlayerWeaponSlot(clients[0], CS_SLOT_PRIMARY) != -1 && GetPlayerWeaponSlot(clients[1], CS_SLOT_PRIMARY) != -1 && GetPlayerWeaponSlot(clients[2], CS_SLOT_PRIMARY) != -1 && GetPlayerWeaponSlot(clients[3], CS_SLOT_PRIMARY) != -1
					 && GetEntProp(clients[0], Prop_Send, "m_iAccount") >= 300 && GetEntProp(clients[1], Prop_Send, "m_iAccount") >= 500 && GetEntProp(clients[2], Prop_Send, "m_iAccount") >= 300 && GetEntProp(clients[3], Prop_Send, "m_iAccount") >= 500)
				{
					FakeClientCommandEx(clients[0], "buy smokegrenade");
					
					FakeClientCommandEx(clients[1], "buy smokegrenade");
					FakeClientCommandEx(clients[1], "buy flashbang");
					
					FakeClientCommandEx(clients[2], "buy smokegrenade");
					
					FakeClientCommandEx(clients[3], "buy smokegrenade");
					FakeClientCommandEx(clients[3], "buy flashbang");
					
					g_bDoExecute = true;
				}
			}
			case 3: //A Long Execute
			{
				GetNade("Short A Smoke", g_fSmokePos[clients[0]], g_fSmokeLookAt[clients[0]], g_fSmokeAngles[clients[0]], g_fSmokeWaitTime[clients[0]], g_bSmokeJumpthrow[clients[0]], g_bSmokeCrouch[clients[0]], g_bIsFlashbang[clients[0]]);
				GetNade("Arch Smoke", g_fSmokePos[clients[1]], g_fSmokeLookAt[clients[1]], g_fSmokeAngles[clients[1]], g_fSmokeWaitTime[clients[1]], g_bSmokeJumpthrow[clients[1]], g_bSmokeCrouch[clients[1]], g_bIsFlashbang[clients[1]]);
				GetNade("Graveyard Smoke", g_fSmokePos[clients[2]], g_fSmokeLookAt[clients[2]], g_fSmokeAngles[clients[2]], g_fSmokeWaitTime[clients[2]], g_bSmokeJumpthrow[clients[2]], g_bSmokeCrouch[clients[2]], g_bIsFlashbang[clients[2]]);
				GetNade("Library Smoke", g_fSmokePos[clients[3]], g_fSmokeLookAt[clients[3]], g_fSmokeAngles[clients[3]], g_fSmokeWaitTime[clients[3]], g_bSmokeJumpthrow[clients[3]], g_bSmokeCrouch[clients[3]], g_bIsFlashbang[clients[3]]);
				
				g_bDoNothing[clients[4]] = true;
				
				GetPosition("Balcony Position", g_fHoldLookPos[clients[4]], g_fPosWaitTime[clients[4]]);
				
				navArea[clients[4]] = NavMesh_FindAreaByID(3048);
				navArea[clients[4]].GetRandomPoint(g_fHoldPos[clients[4]]);
				
				if (GetPlayerWeaponSlot(clients[0], CS_SLOT_PRIMARY) != -1 && GetPlayerWeaponSlot(clients[1], CS_SLOT_PRIMARY) != -1 && GetPlayerWeaponSlot(clients[2], CS_SLOT_PRIMARY) != -1 && GetPlayerWeaponSlot(clients[3], CS_SLOT_PRIMARY) != -1
					 && GetEntProp(clients[0], Prop_Send, "m_iAccount") >= 300 && GetEntProp(clients[1], Prop_Send, "m_iAccount") >= 300 && GetEntProp(clients[2], Prop_Send, "m_iAccount") >= 300 && GetEntProp(clients[3], Prop_Send, "m_iAccount") >= 300)
				{
					FakeClientCommandEx(clients[0], "buy smokegrenade");
					
					FakeClientCommandEx(clients[1], "buy smokegrenade");
					
					FakeClientCommandEx(clients[2], "buy smokegrenade");
					
					FakeClientCommandEx(clients[3], "buy smokegrenade");
					
					g_bDoExecute = true;
				}
			}
		}
	}
}