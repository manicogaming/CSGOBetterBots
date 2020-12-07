public void PrepareMirageExecutes()
{
	int[] clients = new int[MaxClients];
	
	Client_Get(clients, CLIENTFILTER_TEAMONE | CLIENTFILTER_BOTS);
	
	if (IsValidClient(clients[0]) && IsValidClient(clients[1]) && IsValidClient(clients[2]) && IsValidClient(clients[3]) && IsValidClient(clients[4]))
	{
		switch (g_iRndExecute)
		{
			case 1:
			{
				g_szSmoke[clients[0]] = "CT Smoke"; //A Execute
				g_szSmoke[clients[1]] = "Stairs Smoke"; //A Execute
				g_szSmoke[clients[2]] = "Jungle Smoke"; //A Execute
				g_szSmoke[clients[3]] = ""; //A Execute
				g_szSmoke[clients[4]] = ""; //A Execute
				
				g_szFlashbang[clients[0]] = "Lamp Flash"; //A Execute
				g_szFlashbang[clients[1]] = ""; //A Execute
				g_szFlashbang[clients[2]] = "A Site Flash"; //A Execute
				g_szFlashbang[clients[3]] = ""; //A Execute
				g_szFlashbang[clients[4]] = ""; //A Execute
				
				g_szPosition[clients[0]] = ""; //A Execute
				g_szPosition[clients[1]] = ""; //A Execute
				g_szPosition[clients[2]] = ""; //A Execute
				g_szPosition[clients[3]] = "Ramp Position"; //A Execute
				g_szPosition[clients[4]] = "Palace Position"; //A Execute
				
				int iRampAreaIDs[] =  {
					2805, 341, 3507, 2854
				};
				
				int iPalaceAreaIDs[] =  {
					3468, 203, 3465, 96, 3475, 3476, 3463, 147, 146, 3484
				};
				
				navArea[clients[3]] = NavMesh_FindAreaByID(iRampAreaIDs[Math_GetRandomInt(0, sizeof(iRampAreaIDs) - 1)]);
				navArea[clients[3]].GetRandomPoint(g_fHoldPos[clients[3]]);
				
				navArea[clients[4]] = NavMesh_FindAreaByID(iPalaceAreaIDs[Math_GetRandomInt(0, sizeof(iPalaceAreaIDs) - 1)]);
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
				g_szSmoke[clients[0]] = "Top-Mid Smoke"; //Mid Execute
				g_szSmoke[clients[1]] = "Mid-Short Smoke"; //Mid Execute
				g_szSmoke[clients[2]] = "Window Smoke"; //Mid Execute
				g_szSmoke[clients[3]] = "Bottom Con Smoke"; //Mid Execute
				g_szSmoke[clients[4]] = "Top Con Smoke"; //Mid Execute
				
				g_szFlashbang[clients[0]] = "Connector Flash"; //Mid Execute
				g_szFlashbang[clients[1]] = ""; //Mid Execute
				g_szFlashbang[clients[2]] = ""; //Mid Execute
				g_szFlashbang[clients[3]] = "Mid Flash"; //Mid Execute
				g_szFlashbang[clients[4]] = ""; //Mid Execute
				
				g_szPosition[clients[0]] = ""; //Mid Execute
				g_szPosition[clients[1]] = ""; //Mid Execute
				g_szPosition[clients[2]] = ""; //Mid Execute
				g_szPosition[clients[3]] = ""; //Mid Execute
				g_szPosition[clients[4]] = ""; //Mid Execute
				
				if (GetPlayerWeaponSlot(clients[0], CS_SLOT_PRIMARY) != -1 && GetPlayerWeaponSlot(clients[1], CS_SLOT_PRIMARY) != -1 && GetPlayerWeaponSlot(clients[2], CS_SLOT_PRIMARY) != -1 && GetPlayerWeaponSlot(clients[3], CS_SLOT_PRIMARY) != -1 && GetPlayerWeaponSlot(clients[4], CS_SLOT_PRIMARY) != -1
					 && GetEntProp(clients[0], Prop_Send, "m_iAccount") >= 500 && GetEntProp(clients[1], Prop_Send, "m_iAccount") >= 300 && GetEntProp(clients[2], Prop_Send, "m_iAccount") >= 300 && GetEntProp(clients[3], Prop_Send, "m_iAccount") >= 500 && GetEntProp(clients[4], Prop_Send, "m_iAccount") >= 300)
				{
					FakeClientCommandEx(clients[0], "buy smokegrenade");
					FakeClientCommandEx(clients[0], "buy flashbang");
					
					FakeClientCommandEx(clients[1], "buy smokegrenade");
					
					FakeClientCommandEx(clients[2], "buy smokegrenade");
					
					FakeClientCommandEx(clients[3], "buy smokegrenade");
					FakeClientCommandEx(clients[3], "buy flashbang");
					
					FakeClientCommandEx(clients[4], "buy smokegrenade");
					
					g_bDoExecute = true;
				}
			}
			case 3:
			{
				g_szSmoke[clients[0]] = "Short-Left Smoke"; //B Execute
				g_szSmoke[clients[1]] = "Short-Right Smoke"; //B Execute
				g_szSmoke[clients[2]] = "Market Door Smoke"; //B Execute
				g_szSmoke[clients[3]] = "Market Window Smoke"; //B Execute
				g_szSmoke[clients[4]] = ""; //B Execute
				
				g_szFlashbang[clients[0]] = "B Corner Flash"; //B Execute
				g_szFlashbang[clients[1]] = "Car Flash"; //B Execute
				g_szFlashbang[clients[2]] = "B Short Flash"; //B Execute
				g_szFlashbang[clients[3]] = ""; //B Execute
				g_szFlashbang[clients[4]] = ""; //B Execute
				
				g_szPosition[clients[0]] = ""; //B Execute
				g_szPosition[clients[1]] = ""; //B Execute
				g_szPosition[clients[2]] = ""; //B Execute
				g_szPosition[clients[3]] = ""; //B Execute
				g_szPosition[clients[4]] = "Underpass Position"; //B Execute
				
				int iUnderpassAreaIDs[] =  {
					921, 270, 885
				};
				
				navArea[clients[4]] = NavMesh_FindAreaByID(iUnderpassAreaIDs[Math_GetRandomInt(0, sizeof(iUnderpassAreaIDs) - 1)]);
				navArea[clients[4]].GetRandomPoint(g_fHoldPos[clients[4]]);
				
				if (GetPlayerWeaponSlot(clients[0], CS_SLOT_PRIMARY) != -1 && GetPlayerWeaponSlot(clients[1], CS_SLOT_PRIMARY) != -1 && GetPlayerWeaponSlot(clients[2], CS_SLOT_PRIMARY) != -1 && GetPlayerWeaponSlot(clients[3], CS_SLOT_PRIMARY) != -1
					 && GetEntProp(clients[0], Prop_Send, "m_iAccount") >= 500 && GetEntProp(clients[1], Prop_Send, "m_iAccount") >= 500 && GetEntProp(clients[2], Prop_Send, "m_iAccount") >= 500 && GetEntProp(clients[3], Prop_Send, "m_iAccount") >= 300)
				{
					FakeClientCommandEx(clients[0], "buy smokegrenade");
					FakeClientCommandEx(clients[0], "buy flashbang");
					
					FakeClientCommandEx(clients[1], "buy smokegrenade");
					FakeClientCommandEx(clients[1], "buy flashbang");
					
					FakeClientCommandEx(clients[2], "buy smokegrenade");
					FakeClientCommandEx(clients[2], "buy flashbang");
					
					FakeClientCommandEx(clients[3], "buy smokegrenade");
					
					g_bDoExecute = true;
				}
			}
		}
	}
}