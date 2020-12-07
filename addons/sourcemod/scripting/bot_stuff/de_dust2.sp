public void PrepareDust2Executes()
{
	int[] clients = new int[MaxClients];
	
	Client_Get(clients, CLIENTFILTER_TEAMONE | CLIENTFILTER_BOTS);
	
	if (IsValidClient(clients[0]) && IsValidClient(clients[1]) && IsValidClient(clients[2]) && IsValidClient(clients[3]) && IsValidClient(clients[4]))
	{
		switch (g_iRndExecute)
		{
			case 1:
			{
				g_szSmoke[clients[0]] = "B Doors Smoke"; //B Execute
				g_szSmoke[clients[1]] = "B Plat Smoke"; //B Execute
				g_szSmoke[clients[2]] = "B Site Smoke"; //B Execute
				g_szSmoke[clients[3]] = ""; //B Execute
				g_szSmoke[clients[4]] = ""; //B Execute
				
				g_szFlashbang[clients[0]] = ""; //B Execute
				g_szFlashbang[clients[1]] = "B PopFlash"; //B Execute
				g_szFlashbang[clients[2]] = "B Site Flash"; //B Execute
				g_szFlashbang[clients[3]] = ""; //B Execute
				g_szFlashbang[clients[4]] = ""; //B Execute
				
				g_szPosition[clients[0]] = ""; //B Execute
				g_szPosition[clients[1]] = ""; //B Execute
				g_szPosition[clients[2]] = ""; //B Execute
				g_szPosition[clients[3]] = "Lower Tunnel Position"; //B Execute
				g_szPosition[clients[4]] = "B Position"; //B Execute
				
				int iLowerTunnelAreaIDs[] =  {
					7998, 8002, 6617, 6659, 8001, 6616, 6668, 6641, 6669, 6625, 6618, 6653, 6635, 1373, 6649, 6623, 505, 521, 558
				};
				
				int iBAreaIDs[] =  {
					8224, 1230, 7957
				};
				
				navArea[clients[3]] = NavMesh_FindAreaByID(iLowerTunnelAreaIDs[Math_GetRandomInt(0, sizeof(iLowerTunnelAreaIDs) - 1)]);
				navArea[clients[3]].GetRandomPoint(g_fHoldPos[clients[3]]);
				
				navArea[clients[4]] = NavMesh_FindAreaByID(iBAreaIDs[Math_GetRandomInt(0, sizeof(iBAreaIDs) - 1)]);
				navArea[clients[4]].GetRandomPoint(g_fHoldPos[clients[4]]);
				
				if (GetPlayerWeaponSlot(clients[0], CS_SLOT_PRIMARY) != -1 && GetPlayerWeaponSlot(clients[1], CS_SLOT_PRIMARY) != -1 && GetPlayerWeaponSlot(clients[2], CS_SLOT_PRIMARY) != -1
					 && GetEntProp(clients[0], Prop_Send, "m_iAccount") >= 300 && GetEntProp(clients[1], Prop_Send, "m_iAccount") >= 500 && GetEntProp(clients[2], Prop_Send, "m_iAccount") >= 500)
				{
					FakeClientCommandEx(clients[0], "buy smokegrenade");
					
					FakeClientCommandEx(clients[1], "buy smokegrenade");
					FakeClientCommandEx(clients[1], "buy flashbang");
					
					FakeClientCommandEx(clients[2], "buy smokegrenade");
					FakeClientCommandEx(clients[2], "buy flashbang");
					
					g_bDoExecute = true;
				}
			}
			case 2:
			{
				g_szSmoke[clients[0]] = "XBOX Smoke"; //Short A Execute
				g_szSmoke[clients[1]] = "Short A Smoke"; //Short A Execute
				g_szSmoke[clients[2]] = "Short-Boost Smoke"; //Short A Execute
				g_szSmoke[clients[3]] = "A Site Smoke"; //Short A Execute
				g_szSmoke[clients[4]] = ""; //Short A Execute
				
				g_szFlashbang[clients[0]] = "A Site Flash"; //Short A Execute
				g_szFlashbang[clients[1]] = ""; //Short A Execute
				g_szFlashbang[clients[2]] = ""; //Short A Execute
				g_szFlashbang[clients[3]] = ""; //Short A Execute
				g_szFlashbang[clients[4]] = ""; //Short A Execute
				
				g_szPosition[clients[0]] = ""; //Short A Execute
				g_szPosition[clients[1]] = ""; //Short A Execute
				g_szPosition[clients[2]] = ""; //Short A Execute
				g_szPosition[clients[3]] = ""; //Short A Execute
				g_szPosition[clients[4]] = "A Position"; //Short A Execute
				
				int iMidAreaIDs[] =  {
					7566, 7558, 4051, 7581, 4139
				};
				
				navArea[clients[4]] = NavMesh_FindAreaByID(iMidAreaIDs[Math_GetRandomInt(0, sizeof(iMidAreaIDs) - 1)]);
				navArea[clients[4]].GetRandomPoint(g_fHoldPos[clients[4]]);
				
				if (GetPlayerWeaponSlot(clients[0], CS_SLOT_PRIMARY) != -1 && GetPlayerWeaponSlot(clients[1], CS_SLOT_PRIMARY) != -1 && GetPlayerWeaponSlot(clients[2], CS_SLOT_PRIMARY) != -1 && GetPlayerWeaponSlot(clients[3], CS_SLOT_PRIMARY) != -1
					 && GetEntProp(clients[0], Prop_Send, "m_iAccount") >= 500 && GetEntProp(clients[1], Prop_Send, "m_iAccount") >= 300 && GetEntProp(clients[2], Prop_Send, "m_iAccount") >= 300 && GetEntProp(clients[3], Prop_Send, "m_iAccount") >= 300)
				{
					FakeClientCommandEx(clients[0], "buy smokegrenade");
					FakeClientCommandEx(clients[0], "buy flashbang");
					
					FakeClientCommandEx(clients[1], "buy smokegrenade");
					
					FakeClientCommandEx(clients[2], "buy smokegrenade");
					
					FakeClientCommandEx(clients[3], "buy smokegrenade");
					
					g_bDoExecute = true;
				}
			}
			case 3:
			{
				g_szSmoke[clients[0]] = "Long Corner Smoke"; //Short A Execute
				g_szSmoke[clients[1]] = "A Car Smoke"; //Short A Execute
				g_szSmoke[clients[2]] = "CT Smoke"; //Short A Execute
				g_szSmoke[clients[3]] = ""; //Short A Execute
				g_szSmoke[clients[4]] = ""; //Short A Execute
				
				g_szFlashbang[clients[0]] = "Long Flash"; //Short A Execute
				g_szFlashbang[clients[1]] = ""; //Short A Execute
				g_szFlashbang[clients[2]] = ""; //Short A Execute
				g_szFlashbang[clients[3]] = ""; //Short A Execute
				g_szFlashbang[clients[4]] = ""; //Short A Execute
				
				g_szPosition[clients[0]] = ""; //Long A Execute
				g_szPosition[clients[1]] = ""; //Long A Execute
				g_szPosition[clients[2]] = ""; //Long A Execute
				g_szPosition[clients[3]] = "Mid Push Position"; //Long A Execute
				g_szPosition[clients[4]] = "Long Position"; //Long A Execute
				
				int iMidPushAreaIDs[] =  {
					7342, 7343, 7348, 5370
				};
				
				int iLongAreaIDs[] =  {
					3661, 9156, 9155, 3698, 9154, 9153, 3659
				};
				
				navArea[clients[3]] = NavMesh_FindAreaByID(iMidPushAreaIDs[Math_GetRandomInt(0, sizeof(iMidPushAreaIDs) - 1)]);
				navArea[clients[3]].GetRandomPoint(g_fHoldPos[clients[3]]);
				
				navArea[clients[4]] = NavMesh_FindAreaByID(iLongAreaIDs[Math_GetRandomInt(0, sizeof(iLongAreaIDs) - 1)]);
				navArea[clients[4]].GetRandomPoint(g_fHoldPos[clients[4]]);
				
				if (GetPlayerWeaponSlot(clients[0], CS_SLOT_PRIMARY) != -1 && GetPlayerWeaponSlot(clients[1], CS_SLOT_PRIMARY) != -1 && GetPlayerWeaponSlot(clients[2], CS_SLOT_PRIMARY) != -1
					 && GetEntProp(clients[0], Prop_Send, "m_iAccount") >= 500 && GetEntProp(clients[1], Prop_Send, "m_iAccount") >= 300 && GetEntProp(clients[2], Prop_Send, "m_iAccount") >= 300)
				{
					FakeClientCommandEx(clients[0], "buy smokegrenade");
					FakeClientCommandEx(clients[0], "buy flashbang");
					
					FakeClientCommandEx(clients[1], "buy smokegrenade");
					
					FakeClientCommandEx(clients[2], "buy smokegrenade");
					
					g_bDoExecute = true;
				}
			}
		}
	}
}