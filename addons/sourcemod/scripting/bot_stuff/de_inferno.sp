public void PrepareInfernoExecutes()
{
	int[] clients = new int[MaxClients];
	
	Client_Get(clients, CLIENTFILTER_TEAMONE | CLIENTFILTER_BOTS);
	
	if (IsValidClient(clients[0]) && IsValidClient(clients[1]) && IsValidClient(clients[2]) && IsValidClient(clients[3]) && IsValidClient(clients[4]))
	{
		switch (g_iRndExecute)
		{
			case 1:
			{
				g_szSmoke[clients[0]] = "CT Smoke"; //B Execute
				g_szSmoke[clients[1]] = "Coffin Smoke"; //B Execute
				g_szSmoke[clients[2]] = ""; //B Execute
				g_szSmoke[clients[3]] = ""; //B Execute
				g_szSmoke[clients[4]] = ""; //B Execute
				
				g_szFlashbang[clients[0]] = "B PopFlash"; //B Execute
				g_szFlashbang[clients[1]] = "B Site Flash"; //B Execute
				g_szFlashbang[clients[2]] = ""; //B Execute
				g_szFlashbang[clients[3]] = ""; //B Execute
				g_szFlashbang[clients[4]] = ""; //B Execute
				
				g_szPosition[clients[0]] = ""; //B Execute
				g_szPosition[clients[1]] = ""; //B Execute
				g_szPosition[clients[2]] = "CT Position"; //B Execute
				g_szPosition[clients[3]] = "CT Push Position"; //B Execute
				g_szPosition[clients[4]] = "Bottom Banana Position"; //B Execute
				
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
			case 2:
			{
				g_szSmoke[clients[0]] = "Long A Smoke"; //A Short/Apps Execute
				g_szSmoke[clients[1]] = "Site-Library Smoke"; //A Short/Apps Execute
				g_szSmoke[clients[2]] = "Pit Smoke"; //A Short/Apps Execute
				g_szSmoke[clients[3]] = "Balcony Smoke"; //A Short/Apps Execute
				g_szSmoke[clients[4]] = ""; //A Short/Apps Execute
				
				g_szFlashbang[clients[0]] = ""; //A Short/Apps Execute
				g_szFlashbang[clients[1]] = "Pit Flash"; //A Short/Apps Execute
				g_szFlashbang[clients[2]] = ""; //A Short/Apps Execute
				g_szFlashbang[clients[3]] = "Balcony Flash"; //A Short/Apps Execute
				g_szFlashbang[clients[4]] = ""; //A Short/Apps Execute
				
				g_szPosition[clients[0]] = ""; //A Short/Apps Execute
				g_szPosition[clients[1]] = ""; //A Short/Apps Execute
				g_szPosition[clients[2]] = ""; //A Short/Apps Execute
				g_szPosition[clients[3]] = ""; //A Short/Apps Execute
				g_szPosition[clients[4]] = "Balcony Position"; //A Short/Apps Execute
				
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
			case 3:
			{
				g_szSmoke[clients[0]] = "Short A Smoke"; //A Long Execute
				g_szSmoke[clients[1]] = "Arch Smoke"; //A Long Execute
				g_szSmoke[clients[2]] = "Graveyard Smoke"; //A Long Execute
				g_szSmoke[clients[3]] = "Library Smoke"; //A Long Execute
				g_szSmoke[clients[4]] = ""; //A Long Execute
				
				g_szFlashbang[clients[0]] = ""; //A Long Execute
				g_szFlashbang[clients[1]] = ""; //A Long Execute
				g_szFlashbang[clients[2]] = ""; //A Long Execute
				g_szFlashbang[clients[3]] = ""; //A Long Execute
				g_szFlashbang[clients[4]] = ""; //A Long Execute
				
				g_szPosition[clients[0]] = ""; //A Long Execute
				g_szPosition[clients[1]] = ""; //A Long Execute
				g_szPosition[clients[2]] = ""; //A Long Execute
				g_szPosition[clients[3]] = ""; //A Long Execute
				g_szPosition[clients[4]] = "Balcony Position"; //A Long Execute
				
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