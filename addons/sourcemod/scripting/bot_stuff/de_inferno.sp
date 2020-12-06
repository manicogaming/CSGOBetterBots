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
				
				g_iPositionToHold[clients[0]] = 0; //B Execute
				g_iPositionToHold[clients[1]] = 0; //B Execute
				g_iPositionToHold[clients[2]] = 1; //B Execute
				g_iPositionToHold[clients[3]] = 2; //B Execute
				g_iPositionToHold[clients[4]] = 3; //B Execute
				
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
				
				g_iPositionToHold[clients[0]] = 0; //A Short/Apps Execute
				g_iPositionToHold[clients[1]] = 0; //A Short/Apps Execute
				g_iPositionToHold[clients[2]] = 0; //A Short/Apps Execute
				g_iPositionToHold[clients[3]] = 0; //A Short/Apps Execute
				g_iPositionToHold[clients[4]] = 4; //A Short/Apps Execute
				
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
				
				g_iPositionToHold[clients[0]] = 0; //A Long Execute
				g_iPositionToHold[clients[1]] = 0; //A Long Execute
				g_iPositionToHold[clients[2]] = 0; //A Long Execute
				g_iPositionToHold[clients[3]] = 0; //A Long Execute
				g_iPositionToHold[clients[4]] = 4; //A Long Execute
				
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

public void DoInfernoSmokes(int client, int& iButtons, int iDefIndex)
{
	float fClientLocation[3];
	
	GetClientAbsOrigin(client, fClientLocation);
	
	if(strcmp(g_szSmoke[client], "") != 0)
	{
		if (!g_bHasThrownSmoke[client])
		{
			float fSmoke[3], fLookAt[3], fAng[3], fWaitTime;
			bool bJumpthrow, bCrouch;
			
			if (GetNade(g_szSmoke[client], fSmoke, fLookAt, fAng, fWaitTime, bJumpthrow, bCrouch))
			{
				float fSmokeDis = GetVectorDistance(fClientLocation, fSmoke);
			
				BotMoveTo(client, fSmoke, FASTEST_ROUTE);
				
				if (fSmokeDis < 150.0)
				{
					if (iDefIndex != 45)
					{
						FakeClientCommandEx(client, "use weapon_smokegrenade");
					}
				}
				
				if (fSmokeDis < 25.0)
				{					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, fWaitTime, true, 5.0, false);
					
					CreateTimer(fWaitTime, Timer_ThrowSmoke, GetClientUserId(client));
					
					iButtons |= IN_ATTACK;
					
					if(bCrouch)
					{
						iButtons |= IN_DUCK;
					}
					
					if (g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fSmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						
						if(bJumpthrow)
						{
							iButtons |= IN_JUMP;
						}
						
						if(bCrouch)
						{
							iButtons |= IN_DUCK;
						}
						
						if(strcmp(g_szFlashbang[client], "") != 0)
						{
							CreateTimer(0.2, Timer_SmokeDelay, GetClientUserId(client));	
						}
						else
						{
							CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
						}
					}
				}
			}
		}
	}
	
	if(strcmp(g_szFlashbang[client], "") != 0 && g_bHasThrownSmoke[client])
	{
		float fFlash[3], fLookAt[3], fAng[3], fWaitTime;
		bool bJumpthrow, bCrouch;
		
		if (GetNade(g_szFlashbang[client], fFlash, fLookAt, fAng, fWaitTime, bJumpthrow, bCrouch))
		{
			float fFlashDis = GetVectorDistance(fClientLocation, fFlash);
		
			BotMoveTo(client, fFlash, FASTEST_ROUTE);
			
			if (fFlashDis < 150.0)
			{
				if (iDefIndex != 43)
				{
					FakeClientCommandEx(client, "use weapon_flashbang");
				}
			}
			
			if (fFlashDis < 25.0)
			{
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, fWaitTime, true, 5.0, false);
				
				CreateTimer(fWaitTime, Timer_ThrowFlash, GetClientUserId(client));
				
				iButtons |= IN_ATTACK;
				
				if(bCrouch)
				{
					iButtons |= IN_DUCK;
				}
				
				if (g_bCanThrowFlash[client])
				{
					TeleportEntity(client, fFlash, fAng, NULL_VECTOR);
					iButtons &= ~IN_ATTACK;
					
					if(bJumpthrow)
					{
						iButtons |= IN_JUMP;
					}
					
					if(bCrouch)
					{
						iButtons |= IN_DUCK;
					}
					
					CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
				}
			}
		}
	}
	
	switch (g_iPositionToHold[client])
	{
		case 1: //CT Position
		{
			if (!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if (fHoldSpotDis < 25.0)
				{
					float fLookAt[3] =  { 921.785706, 2720.304443, 192.554459 };
					float fBentLook[3], fEyePos[3];
					
					GetClientEyePosition(client, fEyePos);
					
					BotBendLineOfSight(client, fEyePos, fLookAt, fBentLook, 135.0);
					BotSetLookAt(client, "Use entity", fBentLook, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, GetClientUserId(client));
				}
			}
		}
		case 2: //CT Push Position
		{
			if (!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if (fHoldSpotDis < 25.0)
				{
					float fLookAt[3] =  { 921.785706, 2720.304443, 192.554459 };
					float fBentLook[3], fEyePos[3];
					
					GetClientEyePosition(client, fEyePos);
					
					BotBendLineOfSight(client, fEyePos, fLookAt, fBentLook, 135.0);
					BotSetLookAt(client, "Use entity", fBentLook, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(5.0, Timer_ThrowSmoke, GetClientUserId(client));
				}
			}
		}
		case 3: //Bottom Banana Position
		{
			if (!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if (fHoldSpotDis < 25.0)
				{
					float fLookAt[3] =  { 111.965370, 699.592651, 138.017456 };
					float fBentLook[3], fEyePos[3];
					
					GetClientEyePosition(client, fEyePos);
					
					BotBendLineOfSight(client, fEyePos, fLookAt, fBentLook, 135.0);
					BotSetLookAt(client, "Use entity", fBentLook, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(5.0, Timer_ThrowSmoke, GetClientUserId(client));
				}
			}
		}
		case 4: //Balcony Position
		{
			if (!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if (fHoldSpotDis < 25.0)
				{
					float fLookAt[3] =  { 2252.379395, 149.045380, 193.250992 };
					float fBentLook[3], fEyePos[3];
					
					GetClientEyePosition(client, fEyePos);
					
					BotBendLineOfSight(client, fEyePos, fLookAt, fBentLook, 135.0);
					BotSetLookAt(client, "Use entity", fBentLook, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, GetClientUserId(client));
				}
			}
		}
	}
} 