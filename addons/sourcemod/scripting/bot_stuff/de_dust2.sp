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
				g_iSmoke[clients[0]] = 1; //B Execute
				g_iSmoke[clients[1]] = 2; //B Execute
				g_iSmoke[clients[2]] = 3; //B Execute
				g_iSmoke[clients[3]] = 0; //B Execute
				g_iSmoke[clients[4]] = 0; //B Execute
				
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
				g_iSmoke[clients[0]] = 4; //Short A Execute
				g_iSmoke[clients[1]] = 5; //Short A Execute
				g_iSmoke[clients[2]] = 6; //Short A Execute
				g_iSmoke[clients[3]] = 7; //Short A Execute
				g_iSmoke[clients[4]] = 0; //Short A Execute
				
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
				g_iSmoke[clients[0]] = 8; //Long A Execute
				g_iSmoke[clients[1]] = 9; //Long A Execute
				g_iSmoke[clients[2]] = 10; //Long A Execute
				g_iSmoke[clients[3]] = 0; //Long A Execute
				g_iSmoke[clients[4]] = 0; //Long A Execute
				
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
	
	switch (g_iSmoke[client])
	{
		case 1: //B Doors Smoke
		{
			float fBDoorsSmoke[3], fLookAt[3], fAng[3];
				
			if (GetNade("B Doors Smoke", fBDoorsSmoke, fLookAt, fAng))
			{
				float fBDoorsSmokeDis = GetVectorDistance(fClientLocation, fBDoorsSmoke);
			
				BotMoveTo(client, fBDoorsSmoke, FASTEST_ROUTE);
				
				if (fBDoorsSmokeDis < 150.0)
				{
					if (iDefIndex != 45)
					{
						FakeClientCommandEx(client, "use weapon_smokegrenade");
					}
				}
				
				if (fBDoorsSmokeDis < 25.0)
				{
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, GetClientUserId(client));
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fBDoorsSmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
					}
				}
			}
		}
		case 2: //B Plat Smoke
		{
			if (!g_bHasThrownSmoke[client])
			{
				float fBPlatSmoke[3], fLookAt[3], fAng[3];
				
				if (GetNade("B Plat Smoke", fBPlatSmoke, fLookAt, fAng))
				{
					float fBPlatSmokeDis = GetVectorDistance(fClientLocation, fBPlatSmoke);
				
					BotMoveTo(client, fBPlatSmoke, FASTEST_ROUTE);
					
					if (fBPlatSmokeDis < 150.0)
					{
						if (iDefIndex != 45)
						{
							FakeClientCommandEx(client, "use weapon_smokegrenade");
						}
					}
					
					if (fBPlatSmokeDis < 25.0)
					{
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
						
						CreateTimer(3.0, Timer_ThrowSmoke, GetClientUserId(client));
						
						iButtons |= IN_ATTACK;
						
						if (g_bCanThrowSmoke[client])
						{
							TeleportEntity(client, fBPlatSmoke, fAng, NULL_VECTOR);
							iButtons &= ~IN_ATTACK;
							CreateTimer(0.2, Timer_SmokeDelay, GetClientUserId(client));
						}
					}
				}
			}
			else
			{
				float fBPopFlash[3], fLookAt[3], fAng[3];
			
				if (GetNade("B PopFlash", fBPopFlash, fLookAt, fAng))
				{
					float fBPopFlashDis = GetVectorDistance(fClientLocation, fBPopFlash);
				
					BotMoveTo(client, fBPopFlash, FASTEST_ROUTE);
					
					if (fBPopFlashDis < 150.0)
					{
						if (iDefIndex != 43)
						{
							FakeClientCommandEx(client, "use weapon_flashbang");
						}
					}
					
					if (fBPopFlashDis < 25.0)
					{
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
						
						CreateTimer(1.0, Timer_ThrowFlash, GetClientUserId(client));
						
						iButtons |= IN_ATTACK;
						
						if (g_bCanThrowFlash[client])
						{
							TeleportEntity(client, fBPopFlash, fAng, NULL_VECTOR);
							iButtons &= ~IN_ATTACK;
							CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
						}
					}
				}
			}
		}
		case 3: //B Site Smoke
		{
			if (!g_bHasThrownSmoke[client])
			{
				float fBSiteSmoke[3], fLookAt[3], fAng[3];
				
				if (GetNade("B Site Smoke", fBSiteSmoke, fLookAt, fAng))
				{
					float fBSiteSmokeDis = GetVectorDistance(fClientLocation, fBSiteSmoke);
				
					BotMoveTo(client, fBSiteSmoke, FASTEST_ROUTE);
					
					if (fBSiteSmokeDis < 150.0)
					{
						if (iDefIndex != 45)
						{
							FakeClientCommandEx(client, "use weapon_smokegrenade");
						}
					}
					
					if (fBSiteSmokeDis < 25.0)
					{
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
						
						CreateTimer(3.0, Timer_ThrowSmoke, GetClientUserId(client));
						
						iButtons |= IN_ATTACK;
						
						if (g_bCanThrowSmoke[client])
						{
							TeleportEntity(client, fBSiteSmoke, fAng, NULL_VECTOR);
							iButtons &= ~IN_ATTACK;
							CreateTimer(0.2, Timer_SmokeDelay, GetClientUserId(client));
						}
					}
				}
			}
			else
			{
				float fBSiteFlash[3], fLookAt[3], fAng[3];
				
				if (GetNade("B Site Flash", fBSiteFlash, fLookAt, fAng))
				{
					float fBSiteFlashDis = GetVectorDistance(fClientLocation, fBSiteFlash);
				
					BotMoveTo(client, fBSiteFlash, FASTEST_ROUTE);
					
					if (fBSiteFlashDis < 150.0)
					{
						if (iDefIndex != 43)
						{
							FakeClientCommandEx(client, "use weapon_flashbang");
						}
					}
					
					if (fBSiteFlashDis < 25.0)
					{
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
						
						CreateTimer(1.0, Timer_ThrowFlash, GetClientUserId(client));
						
						iButtons |= IN_ATTACK;
						iButtons |= IN_DUCK;
						
						if (g_bCanThrowFlash[client])
						{
							TeleportEntity(client, fBSiteFlash, fAng, NULL_VECTOR);
							iButtons &= ~IN_ATTACK;
							iButtons |= IN_DUCK;
							CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
						}
					}
				}
			}
		}
		case 4: //XBOX Smoke
		{
			if (!g_bHasThrownSmoke[client])
			{
				float fXBOXSmoke[3], fLookAt[3], fAng[3];
				
				if (GetNade("XBOX Smoke", fXBOXSmoke, fLookAt, fAng))
				{
					float fXBOXSmokeDis = GetVectorDistance(fClientLocation, fXBOXSmoke);
				
					BotMoveTo(client, fXBOXSmoke, FASTEST_ROUTE);
					
					if (fXBOXSmokeDis < 150.0)
					{
						if (iDefIndex != 45)
						{
							FakeClientCommandEx(client, "use weapon_smokegrenade");
						}
					}
					
					if (fXBOXSmokeDis < 25.0)
					{
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
						
						CreateTimer(1.0, Timer_ThrowSmoke, GetClientUserId(client));
						
						iButtons |= IN_ATTACK;
						
						if (g_bCanThrowSmoke[client])
						{
							TeleportEntity(client, fXBOXSmoke, fAng, NULL_VECTOR);
							iButtons &= ~IN_ATTACK;
							iButtons |= IN_JUMP;
							CreateTimer(0.2, Timer_SmokeDelay, GetClientUserId(client));
						}
					}
				}
			}
			else
			{
				float fASiteFlash[3], fLookAt[3], fAng[3];
				
				if (GetNade("A Site Flash", fASiteFlash, fLookAt, fAng))
				{
					float fASiteFlashDis = GetVectorDistance(fClientLocation, fASiteFlash);
				
					BotMoveTo(client, fASiteFlash, FASTEST_ROUTE);
					
					if (fASiteFlashDis < 150.0)
					{
						if (iDefIndex != 43)
						{
							FakeClientCommandEx(client, "use weapon_flashbang");
						}
					}
					
					if (fASiteFlashDis < 25.0)
					{
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
						
						CreateTimer(0.5, Timer_ThrowFlash, GetClientUserId(client));
						
						iButtons |= IN_ATTACK;
						
						if (g_bCanThrowFlash[client])
						{
							TeleportEntity(client, fASiteFlash, fAng, NULL_VECTOR);
							iButtons &= ~IN_ATTACK;
							CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
						}
					}
				}
			}
		}
		case 5: //Short A Smoke
		{
			float fShortASmoke[3], fLookAt[3], fAng[3];
				
			if (GetNade("Short A Smoke", fShortASmoke, fLookAt, fAng))
			{
				float fShortASmokeDis = GetVectorDistance(fClientLocation, fShortASmoke);
			
				BotMoveTo(client, fShortASmoke, FASTEST_ROUTE);
				
				if (fShortASmokeDis < 150.0)
				{
					if (iDefIndex != 45)
					{
						FakeClientCommandEx(client, "use weapon_smokegrenade");
					}
				}
				
				if (fShortASmokeDis < 25.0)
				{
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, GetClientUserId(client));
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fShortASmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
					}
				}
			}
		}
		case 6: //Short-Boost Smoke
		{
			float fShortBoostSmoke[3], fLookAt[3], fAng[3];
				
			if (GetNade("Short-Boost Smoke", fShortBoostSmoke, fLookAt, fAng))
			{
				float fShortBoostSmokeDis = GetVectorDistance(fClientLocation, fShortBoostSmoke);
			
				BotMoveTo(client, fShortBoostSmoke, FASTEST_ROUTE);
				
				if (fShortBoostSmokeDis < 150.0)
				{
					if (iDefIndex != 45)
					{
						FakeClientCommandEx(client, "use weapon_smokegrenade");
					}
				}
				
				if (fShortBoostSmokeDis < 25.0)
				{
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, GetClientUserId(client));
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fShortBoostSmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
					}
				}
			}
		}
		case 7: //A Site Smoke
		{
			float fASiteSmoke[3], fLookAt[3], fAng[3];
				
			if (GetNade("A Site Smoke", fASiteSmoke, fLookAt, fAng))
			{
				float fASiteSmokeDis = GetVectorDistance(fClientLocation, fASiteSmoke);
			
				BotMoveTo(client, fASiteSmoke, FASTEST_ROUTE);
				
				if (fASiteSmokeDis < 150.0)
				{
					if (iDefIndex != 45)
					{
						FakeClientCommandEx(client, "use weapon_smokegrenade");
					}
				}
				
				if (fASiteSmokeDis < 25.0)
				{
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, GetClientUserId(client));
					
					iButtons |= IN_ATTACK;
					iButtons |= IN_DUCK;
					
					if (g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fASiteSmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						iButtons |= IN_DUCK;
						CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
					}
				}
			}
		}
		case 8: //Long Corner Smoke
		{
			if (!g_bHasThrownSmoke[client])
			{
				float fLongCornerSmoke[3], fLookAt[3], fAng[3];
				
				if (GetNade("Long Corner Smoke", fLongCornerSmoke, fLookAt, fAng))
				{
					float fLongCornerSmokeDis = GetVectorDistance(fClientLocation, fLongCornerSmoke);
				
					BotMoveTo(client, fLongCornerSmoke, FASTEST_ROUTE);
					
					if (fLongCornerSmokeDis < 150.0)
					{
						if (iDefIndex != 45)
						{
							FakeClientCommandEx(client, "use weapon_smokegrenade");
						}
					}
					
					if (fLongCornerSmokeDis < 25.0)
					{
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
						
						CreateTimer(1.0, Timer_ThrowSmoke, GetClientUserId(client));
						
						iButtons |= IN_ATTACK;
						
						if (g_bCanThrowSmoke[client])
						{
							TeleportEntity(client, fLongCornerSmoke, fAng, NULL_VECTOR);
							iButtons &= ~IN_ATTACK;
							CreateTimer(0.2, Timer_SmokeDelay, GetClientUserId(client));
						}
					}
				}
			}
			else
			{
				float fLongFlash[3], fLookAt[3], fAng[3];
				
				if (GetNade("Long Flash", fLongFlash, fLookAt, fAng))
				{
					float fLongFlashDis = GetVectorDistance(fClientLocation, fLongFlash);
				
					BotMoveTo(client, fLongFlash, FASTEST_ROUTE);
					
					if (fLongFlashDis < 150.0)
					{
						if (iDefIndex != 43)
						{
							FakeClientCommandEx(client, "use weapon_flashbang");
						}
					}
					
					if (fLongFlashDis < 25.0)
					{
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
						
						CreateTimer(0.8, Timer_ThrowFlash, GetClientUserId(client));
						
						iButtons |= IN_ATTACK;
						
						if (g_bCanThrowFlash[client])
						{
							TeleportEntity(client, fLongFlash, fAng, NULL_VECTOR);
							iButtons &= ~IN_ATTACK;
							iButtons |= IN_JUMP;
							CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
						}
					}
				}
			}
		}
		case 9: //A Car Smoke
		{
			float fACarSmoke[3], fLookAt[3], fAng[3];
				
			if (GetNade("A Car Smoke", fACarSmoke, fLookAt, fAng))
			{
				float fACarSmokeDis = GetVectorDistance(fClientLocation, fACarSmoke);
			
				BotMoveTo(client, fACarSmoke, FASTEST_ROUTE);
				
				if (fACarSmokeDis < 150.0)
				{
					if (iDefIndex != 45)
					{
						FakeClientCommandEx(client, "use weapon_smokegrenade");
					}
				}
				
				if (fACarSmokeDis < 25.0)
				{
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, GetClientUserId(client));
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fACarSmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
					}
				}
			}
		}
		case 10: //CT Smoke
		{
			float fCTSmoke[3], fLookAt[3], fAng[3];
				
			if (GetNade("CT Smoke", fCTSmoke, fLookAt, fAng))
			{
				float fCTSmokeDis = GetVectorDistance(fClientLocation, fCTSmoke);
			
				BotMoveTo(client, fCTSmoke, FASTEST_ROUTE);
				
				if (fCTSmokeDis < 150.0)
				{
					if (iDefIndex != 45)
					{
						FakeClientCommandEx(client, "use weapon_smokegrenade");
					}
				}
				
				if (fCTSmokeDis < 25.0)
				{
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, GetClientUserId(client));
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fCTSmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
					}
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