public void DoDust2Smokes(int client, int& iButtons)
{
	float fClientLocation[3];
	
	GetClientAbsOrigin(client, fClientLocation);
	
	int iActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if (iActiveWeapon == -1)return;
	
	int iDefIndex = GetEntProp(iActiveWeapon, Prop_Send, "m_iItemDefinitionIndex");
	
	//T Side Flashes
	
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
		case 3: //Long Push Position
		{
			if (!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if (fHoldSpotDis < 25.0)
				{
					float fLookAt[3] =  { 176.276123, 353.036530, 63.525383 };
					float fBentLook[3], fEyePos[3];
					
					GetClientEyePosition(client, fEyePos);
					
					BotBendLineOfSight(client, fEyePos, fLookAt, fBentLook, 135.0);
					BotSetLookAt(client, "Use entity", fBentLook, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(7.0, Timer_ThrowSmoke, GetClientUserId(client));
				}
			}
		}
		case 4: //Short Push Position
		{
			if (!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if (fHoldSpotDis < 25.0)
				{
					float fLookAt[3] =  { 342.916260, 1485.740845, 65.328796 };
					float fBentLook[3], fEyePos[3];
					
					GetClientEyePosition(client, fEyePos);
					
					BotBendLineOfSight(client, fEyePos, fLookAt, fBentLook, 135.0);
					BotSetLookAt(client, "Use entity", fBentLook, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, GetClientUserId(client));
				}
			}
		}
		case 5: //Mid Position
		{
			if (!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if (fHoldSpotDis < 25.0)
				{
					float fLookAt[3] =  { -462.108734, 2058.169922, -61.744308 };
					float fBentLook[3], fEyePos[3];
					
					GetClientEyePosition(client, fEyePos);
					
					BotBendLineOfSight(client, fEyePos, fLookAt, fBentLook, 135.0);
					BotSetLookAt(client, "Use entity", fBentLook, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(5.0, Timer_ThrowSmoke, GetClientUserId(client));
				}
			}
		}
		case 6: //A Position
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
		case 7: //Mid Push Position
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
		case 8: //Long Position
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