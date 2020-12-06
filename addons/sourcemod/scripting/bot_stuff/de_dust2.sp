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
				
				g_iPositionToHold[clients[0]] = 0; //B Execute
				g_iPositionToHold[clients[1]] = 0; //B Execute
				g_iPositionToHold[clients[2]] = 0; //B Execute
				g_iPositionToHold[clients[3]] = 1; //B Execute
				g_iPositionToHold[clients[4]] = 2; //B Execute
				
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
				
				g_iPositionToHold[clients[0]] = 0; //Short A Execute
				g_iPositionToHold[clients[1]] = 0; //Short A Execute
				g_iPositionToHold[clients[2]] = 0; //Short A Execute
				g_iPositionToHold[clients[3]] = 0; //Short A Execute
				g_iPositionToHold[clients[4]] = 3; //Short A Execute
				
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
				
				g_iPositionToHold[clients[0]] = 0; //Long A Execute
				g_iPositionToHold[clients[1]] = 0; //Long A Execute
				g_iPositionToHold[clients[2]] = 0; //Long A Execute
				g_iPositionToHold[clients[3]] = 4; //Long A Execute
				g_iPositionToHold[clients[4]] = 5; //Long A Execute
				
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

public void DoDust2Smokes(int client, int& iButtons, int iDefIndex)
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
		case 1: //Lower Tunnel Position
		{
			if (!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if (fHoldSpotDis < 25.0)
				{
					float fLookAt[3] =  { -1085.206177, 1362.727051, -48.119759 };
					float fBentLook[3], fEyePos[3];
					
					GetClientEyePosition(client, fEyePos);
					
					BotBendLineOfSight(client, fEyePos, fLookAt, fBentLook, 135.0);
					BotSetLookAt(client, "Use entity", fBentLook, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(5.0, Timer_ThrowSmoke, GetClientUserId(client));
				}
			}
		}
		case 2: //B Position
		{
			if (!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if (fHoldSpotDis < 25.0)
				{
					float fLookAt[3] =  { -1975.937500, 1821.490356, 96.745338 };
					float fBentLook[3], fEyePos[3];
					
					GetClientEyePosition(client, fEyePos);
					
					BotBendLineOfSight(client, fEyePos, fLookAt, fBentLook, 135.0);
					BotSetLookAt(client, "Use entity", fBentLook, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(5.0, Timer_ThrowSmoke, GetClientUserId(client));
				}
			}
		}
		case 3: //A Position
		{
			if (!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if (fHoldSpotDis < 25.0)
				{
					float fLookAt[3] =  { 776.948059, 2607.570801, 158.780182 };
					float fBentLook[3], fEyePos[3];
					
					GetClientEyePosition(client, fEyePos);
					
					BotBendLineOfSight(client, fEyePos, fLookAt, fBentLook, 135.0);
					BotSetLookAt(client, "Use entity", fBentLook, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, GetClientUserId(client));
				}
			}
		}
		case 4: //Mid Push Position
		{
			if (!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if (fHoldSpotDis < 25.0)
				{
					float fLookAt[3] =  { -161.266556, 398.383514, 62.534039 };
					float fBentLook[3], fEyePos[3];
					
					GetClientEyePosition(client, fEyePos);
					
					BotBendLineOfSight(client, fEyePos, fLookAt, fBentLook, 135.0);
					BotSetLookAt(client, "Use entity", fBentLook, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(5.0, Timer_ThrowSmoke, GetClientUserId(client));
				}
			}
		}
		case 5: //Long Position
		{
			if (!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if (fHoldSpotDis < 25.0)
				{
					float fLookAt[3] =  { 1328.326050, 1216.048950, 62.165554 };
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