public void PrepareOverpassExecutes()
{
	int[] clients = new int[MaxClients];
	
	Client_Get(clients, CLIENTFILTER_TEAMONE | CLIENTFILTER_BOTS);
	
	if (IsValidClient(clients[0]) && IsValidClient(clients[1]) && IsValidClient(clients[2]) && IsValidClient(clients[3]) && IsValidClient(clients[4]))
	{
		switch (g_iRndExecute)
		{
			case 1:
			{
				g_szSmoke[clients[0]] = "Truck Smoke"; //A Execute
				g_szSmoke[clients[1]] = "Van Smoke"; //A Execute
				g_szSmoke[clients[2]] = "Box Smoke"; //A Execute
				g_szSmoke[clients[3]] = ""; //A Execute
				g_szSmoke[clients[4]] = ""; //A Execute
				
				g_szFlashbang[clients[0]] = "A Site Flash"; //A Execute
				g_szFlashbang[clients[1]] = ""; //A Execute
				g_szFlashbang[clients[2]] = "Long Flash"; //A Execute
				g_szFlashbang[clients[3]] = ""; //A Execute
				g_szFlashbang[clients[4]] = ""; //A Execute
				
				g_szPosition[clients[0]] = ""; //A Execute
				g_szPosition[clients[1]] = ""; //A Execute
				g_szPosition[clients[2]] = ""; //A Execute
				g_szPosition[clients[3]] = "Bathroom Position"; //A Execute
				g_szPosition[clients[4]] = "A Short Position"; //A Execute
				
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
				
				if (GetPlayerWeaponSlot(clients[0], CS_SLOT_PRIMARY) != -1 && GetPlayerWeaponSlot(clients[1], CS_SLOT_PRIMARY) != -1 && GetPlayerWeaponSlot(clients[2], CS_SLOT_PRIMARY) != -1 && GetEntProp(clients[0], Prop_Send, "m_iAccount") >= 500 && GetEntProp(clients[1], Prop_Send, "m_iAccount") >= 300 && GetEntProp(clients[2], Prop_Send, "m_iAccount") >= 500)
				{
					FakeClientCommandEx(clients[0], "buy smokegrenade");
					FakeClientCommandEx(clients[0], "buy flashbang");
					
					FakeClientCommandEx(clients[1], "buy smokegrenade");
					
					FakeClientCommandEx(clients[2], "buy smokegrenade");
					FakeClientCommandEx(clients[2], "buy flashbang");
					
					g_bDoExecute = true;
				}
			}
			case 2:
			{
				g_szSmoke[clients[0]] = "Pit Smoke"; //B Execute
				g_szSmoke[clients[1]] = "Balcony Smoke"; //B Execute
				g_szSmoke[clients[2]] = "Bridge Smoke"; //B Execute
				g_szSmoke[clients[3]] = "B Site Smoke"; //B Execute
				g_szSmoke[clients[4]] = ""; //B Execute
				
				g_szFlashbang[clients[0]] = ""; //B Execute
				g_szFlashbang[clients[1]] = "B Site Flash"; //B Execute
				g_szFlashbang[clients[2]] = ""; //B Execute
				g_szFlashbang[clients[3]] = "Monster Flash"; //B Execute
				g_szFlashbang[clients[4]] = ""; //B Execute
				
				g_szPosition[clients[0]] = ""; //B Execute
				g_szPosition[clients[1]] = ""; //B Execute
				g_szPosition[clients[2]] = ""; //B Execute
				g_szPosition[clients[3]] = ""; //B Execute
				g_szPosition[clients[4]] = "Monster Position"; //B Execute
				
				int iMonsterAreaIDs[] =  {
					9897, 3532, 10433, 10273, 10108, 10103, 9953, 7587
				};
				
				navArea[clients[4]] = NavMesh_FindAreaByID(iMonsterAreaIDs[Math_GetRandomInt(0, sizeof(iMonsterAreaIDs) - 1)]);
				navArea[clients[4]].GetRandomPoint(g_fHoldPos[clients[4]]);
				
				if (GetPlayerWeaponSlot(clients[0], CS_SLOT_PRIMARY) != -1 && GetPlayerWeaponSlot(clients[1], CS_SLOT_PRIMARY) != -1 && GetPlayerWeaponSlot(clients[2], CS_SLOT_PRIMARY) != -1 && GetPlayerWeaponSlot(clients[3], CS_SLOT_PRIMARY) != -1 &&
				GetEntProp(clients[0], Prop_Send, "m_iAccount") >= 300 && GetEntProp(clients[1], Prop_Send, "m_iAccount") >= 500 && GetEntProp(clients[2], Prop_Send, "m_iAccount") >= 300 && GetEntProp(clients[3], Prop_Send, "m_iAccount") >= 500)
				{
					FakeClientCommandEx(clients[0], "buy smokegrenade");
					
					FakeClientCommandEx(clients[1], "buy smokegrenade");
					FakeClientCommandEx(clients[1], "buy flashbang");
					
					FakeClientCommandEx(clients[2], "buy smokegrenade");
					
					FakeClientCommandEx(clients[3], "buy smokegrenade");
					FakeClientCommandEx(clients[3], "buy flashbang");
					
					FakeClientCommandEx(clients[4], "buy smokegrenade");
					
					g_bDoExecute = true;
				}
			}
		}
	}
}