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
				
				g_iPositionToHold[clients[0]] = 0; //A Execute
				g_iPositionToHold[clients[1]] = 0; //A Execute
				g_iPositionToHold[clients[2]] = 0; //A Execute
				g_iPositionToHold[clients[3]] = 1; //A Execute
				g_iPositionToHold[clients[4]] = 2; //A Execute
				
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
				
				g_iPositionToHold[clients[0]] = 0; //Mid Execute
				g_iPositionToHold[clients[1]] = 0; //Mid Execute
				g_iPositionToHold[clients[2]] = 0; //Mid Execute
				g_iPositionToHold[clients[3]] = 0; //Mid Execute
				g_iPositionToHold[clients[4]] = 0; //Mid Execute
				
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
				
				g_iPositionToHold[clients[0]] = 0; //B Execute
				g_iPositionToHold[clients[1]] = 0; //B Execute
				g_iPositionToHold[clients[2]] = 0; //B Execute
				g_iPositionToHold[clients[3]] = 0; //B Execute
				g_iPositionToHold[clients[4]] = 3; //B Execute
				
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

public void DoMirageSmokes(int client, int& iButtons, int iDefIndex)
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
		case 1: //Ramp Position
		{
			if (!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if (fHoldSpotDis < 25.0)
				{
					float fLookAt[3] =  { -63.982632, -1674.684204, -103.906189 };
					float fBentLook[3], fEyePos[3];
					
					GetClientEyePosition(client, fEyePos);
					
					BotBendLineOfSight(client, fEyePos, fLookAt, fBentLook, 135.0);
					BotSetLookAt(client, "Use entity", fBentLook, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, GetClientUserId(client));
				}
			}
		}
		case 2: //Palace Position
		{
			if (!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if (fHoldSpotDis < 25.0)
				{
					float fLookAt[3] =  { 164.354736, -2315.041016, 24.093811 };
					float fBentLook[3], fEyePos[3];
					
					GetClientEyePosition(client, fEyePos);
					
					BotBendLineOfSight(client, fEyePos, fLookAt, fBentLook, 135.0);
					BotSetLookAt(client, "Use entity", fBentLook, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(1.5, Timer_ThrowSmoke, GetClientUserId(client));
				}
			}
		}
		case 3: //Underpass Position
		{
			if (!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if (fHoldSpotDis < 25.0)
				{
					float fLookAt[3] =  { -1012.153503, 387.799988, -303.906189 };
					float fBentLook[3], fEyePos[3];
					
					GetClientEyePosition(client, fEyePos);
					
					BotBendLineOfSight(client, fEyePos, fLookAt, fBentLook, 135.0);
					BotSetLookAt(client, "Use entity", fBentLook, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(5.0, Timer_ThrowSmoke, GetClientUserId(client));
				}
			}
		}
	}
} 