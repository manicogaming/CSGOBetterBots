public void DoDust2Smokes(int client, int& iButtons)
{
	float fClientLocation[3];

	GetClientAbsOrigin(client, fClientLocation);
	
	int iActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if (iActiveWeapon == -1)  return;

	int iDefIndex = GetEntProp(iActiveWeapon, Prop_Send, "m_iItemDefinitionIndex");

	//T Side Smokes
	float fBDoorsSmoke[3] = { -2185.968750, 1059.031250, 39.799171 };
	float fBPlatSmoke[3] = { -2168.989990, 1042.031250, 40.191010 };
	float fBSiteSmoke[3] = { -1837.996094, 982.031250, 40.587242 };
	float fXBOXSmoke[3] = { -299.968750, -1163.974243, 77.698128 };
	float fShortASmoke[3] = { 489.995728, 1446.031250, 0.553116 };
	float fShortBoostSmoke[3] = { 409.991882, 1365.005615, 0.243568 };
	float fASiteSmoke[3] = { 273.018829, 1650.439819, 26.153511 };
	float fLongCornerSmoke[3] = { 487.991608, -363.999390, 9.031250 };
	float fACarSmoke[3] = { 516.031250, 1019.968750, 2.191010 };
	float fCTSmoke[3] = { 516.031250, 983.891907, 1.477413 };

	//T Side Flashes

	float fBSiteFlash[3] = { -1832.914917, 1224.700439, 32.116920 };
	float fBPopFlash[3] = { -1925.002441, 1386.983398, 34.166260 };
	float fASiteFlash[3] = { 489.968750, 1886.926636, 96.759674 };
	float fLongFlash[3] = { 363.996399, -383.321991, 6.365173 };

	switch(g_iSmoke[client])
	{
		case 1: //B Doors Smoke
		{
			float fBDoorsSmokeDis = GetVectorDistance(fClientLocation, fBDoorsSmoke);
			
			BotMoveTo(client, fBDoorsSmoke, FASTEST_ROUTE);
			
			if(fBDoorsSmokeDis < 150.0)
			{
				if(iDefIndex != 45)
				{
					FakeClientCommandEx(client, "use weapon_smokegrenade");
				}
			}
			
			if(fBDoorsSmokeDis < 25.0)
			{
				float fLookAt[3] = { -2050.207763, 1246.720458, 411.438690 };
				float fAng[3] = { -53.021439, 54.120720, 0.000000 };

				CreateTimer(3.0, Timer_ThrowSmoke, client);

				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
				
				iButtons |= IN_ATTACK;

				if(g_bCanThrowSmoke[client])
				{
					TeleportEntity(client, fBDoorsSmoke, fAng, NULL_VECTOR);
					iButtons &= ~IN_ATTACK;
					CreateTimer(0.2, Timer_NadeDelay, client);
				}
			}
		}
		case 2: //B Plat Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				float fBPlatSmokeDis = GetVectorDistance(fClientLocation, fBPlatSmoke);
				
				BotMoveTo(client, fBPlatSmoke, FASTEST_ROUTE);
				
				if(fBPlatSmokeDis < 150.0)
				{
					if(iDefIndex != 45)
					{
						FakeClientCommandEx(client, "use weapon_smokegrenade");
					}
				}
				
				if(fBPlatSmokeDis < 25.0)
				{
					float fLookAt[3] = { -2099.615722, 1599.432250, 1055.968627 };
					float fAng[3] = { -59.452576, 82.905426, 0.000000 };

					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);

					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					iButtons |= IN_ATTACK;

					if(g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fBPlatSmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						CreateTimer(0.2, Timer_SmokeDelay, client);
					}
				}
			}
			else
			{
				float fBPopFlashDis = GetVectorDistance(fClientLocation, fBPopFlash);
				
				BotMoveTo(client, fBPopFlash, FASTEST_ROUTE);
				
				if(fBPopFlashDis < 150.0)
				{
					if(iDefIndex != 43)
					{
						FakeClientCommandEx(client, "use weapon_flashbang");
					}
				}

				if(fBPopFlashDis < 25.0)
				{
					float fLookAt[3] = { -2216.088867, 2714.819824, 499.869354 };
					float fAng[3] = { -16.462793, 102.364708, 0.000000 };

					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);

					CreateTimer(1.0, Timer_ThrowFlash, client);
					
					iButtons |= IN_ATTACK;

					if(g_bCanThrowFlash[client])
					{
						TeleportEntity(client, fBPopFlash, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						CreateTimer(0.2, Timer_NadeDelay, client);
					}
				}
			}
		}
		case 3: //B Site Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				float fBSiteSmokeDis = GetVectorDistance(fClientLocation, fBSiteSmoke);
				
				BotMoveTo(client, fBSiteSmoke, FASTEST_ROUTE);
				
				if(fBSiteSmokeDis < 150.0)
				{
					if(iDefIndex != 45)
					{
						FakeClientCommandEx(client, "use weapon_smokegrenade");
					}
				}
				
				if(fBSiteSmokeDis < 25.0)
				{
					float fLookAt[3] = { -1763.157714, 1571.791015, 1055.968750 };
					float fAng[3] = { -58.000000, 82.768028, 0.000000 };

					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);

					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					iButtons |= IN_ATTACK;

					if(g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fBSiteSmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						CreateTimer(0.2, Timer_SmokeDelay, client);
					}
				}
			}
			else
			{
				float fBSiteFlashDis = GetVectorDistance(fClientLocation, fBSiteFlash);
				
				BotMoveTo(client, fBSiteFlash, FASTEST_ROUTE);
				
				if(fBSiteFlashDis < 150.0)
				{
					if(iDefIndex != 43)
					{
						FakeClientCommandEx(client, "use weapon_flashbang");
					}
				}

				if(fBSiteFlashDis < 25.0)
				{
					float fLookAt[3] = { -2048.000000, 1598.856323, 243.819702 };
					float fAng[3] = { -21.004383, 119.892624, 0.000000 };

					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);

					CreateTimer(1.0, Timer_ThrowFlash, client);
					
					iButtons |= IN_ATTACK;
					iButtons |= IN_DUCK;

					if(g_bCanThrowFlash[client])
					{
						TeleportEntity(client, fBSiteFlash, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						iButtons |= IN_DUCK;
						CreateTimer(0.2, Timer_NadeDelay, client);
					}
				}
			}
		}
		case 4: //XBOX Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				float fXBOXSmokeDis = GetVectorDistance(fClientLocation, fXBOXSmoke);
				
				BotMoveTo(client, fXBOXSmoke, FASTEST_ROUTE);
				
				if(fXBOXSmokeDis < 150.0)
				{
					if(iDefIndex != 45)
					{
						FakeClientCommandEx(client, "use weapon_smokegrenade");
					}
				}
				
				if(fXBOXSmokeDis < 25.0)
				{
					float fLookAt[3] = { -307.881408, 292.322631, 711.968750 };
					float fAng[3] = { -21.384502, 90.311310, 0.000000 };

					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);

					CreateTimer(1.0, Timer_ThrowSmoke, client);
					
					iButtons |= IN_ATTACK;

					if(g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fXBOXSmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						iButtons |= IN_JUMP;
						CreateTimer(0.2, Timer_SmokeDelay, client);
					}
				}
			}
			else
			{
				float fASiteFlashDis = GetVectorDistance(fClientLocation, fASiteFlash);
				
				BotMoveTo(client, fASiteFlash, FASTEST_ROUTE);
				
				if(fASiteFlashDis < 150.0)
				{
					if(iDefIndex != 43)
					{
						FakeClientCommandEx(client, "use weapon_flashbang");
					}
				}

				if(fASiteFlashDis < 25.0)
				{
					float fLookAt[3] = { 256.275390, 2457.708251, 256.323944 };
					float fAng[3] = { -8.807563, 112.265518, 0.000000 };

					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);

					CreateTimer(0.5, Timer_ThrowFlash, client);
					
					iButtons |= IN_ATTACK;

					if(g_bCanThrowFlash[client])
					{
						TeleportEntity(client, fASiteFlash, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						CreateTimer(0.2, Timer_NadeDelay, client);
					}
				}
			}
		}
		case 5: //Short A Smoke
		{
			float fShortASmokeDis = GetVectorDistance(fClientLocation, fShortASmoke);
			
			BotMoveTo(client, fShortASmoke, FASTEST_ROUTE);
			
			if(fShortASmokeDis < 150.0)
			{
				if(iDefIndex != 45)
				{
					FakeClientCommandEx(client, "use weapon_smokegrenade");
				}
			}
			
			if(fShortASmokeDis < 25.0)
			{
				float fLookAt[3] = { 499.671356, 1766.008300, 95.985908 };
				float fAng[3] = { -5.607876, 88.267990, 0.000000 };

				CreateTimer(3.0, Timer_ThrowSmoke, client);

				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
				
				iButtons |= IN_ATTACK;

				if(g_bCanThrowSmoke[client])
				{
					TeleportEntity(client, fShortASmoke, fAng, NULL_VECTOR);
					iButtons &= ~IN_ATTACK;
					CreateTimer(0.2, Timer_NadeDelay, client);
				}
			}
		}
		case 6: //Short-Boost Smoke
		{
			float fShortBoostSmokeDis = GetVectorDistance(fClientLocation, fShortBoostSmoke);
			
			BotMoveTo(client, fShortBoostSmoke, FASTEST_ROUTE);
			
			if(fShortBoostSmokeDis < 150.0)
			{
				if(iDefIndex != 45)
				{
					FakeClientCommandEx(client, "use weapon_smokegrenade");
				}
			}
			
			if(fShortBoostSmokeDis < 25.0)
			{
				float fLookAt[3] = { 457.845062, 1663.229980, 711.968750 };
				float fAng[3] = { -65.000000, 80.884010, 0.000000 };

				CreateTimer(3.0, Timer_ThrowSmoke, client);

				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
				
				iButtons |= IN_ATTACK;

				if(g_bCanThrowSmoke[client])
				{
					TeleportEntity(client, fShortBoostSmoke, fAng, NULL_VECTOR);
					iButtons &= ~IN_ATTACK;
					CreateTimer(0.2, Timer_NadeDelay, client);
				}
			}
		}
		case 7: //A Site Smoke
		{
			float fASiteSmokeDis = GetVectorDistance(fClientLocation, fASiteSmoke);
			
			BotMoveTo(client, fASiteSmoke, FASTEST_ROUTE);
			
			if(fASiteSmokeDis < 150.0)
			{
				if(iDefIndex != 45)
				{
					FakeClientCommandEx(client, "use weapon_smokegrenade");
				}
			}
			
			if(fASiteSmokeDis < 25.0)
			{
				float fLookAt[3] = { 688.195800, 2048.834472, 1055.968750 };
				float fAng[3] = { -59.677898, 43.818272, 0.000000 };

				CreateTimer(3.0, Timer_ThrowSmoke, client);

				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
				
				iButtons |= IN_ATTACK;
				iButtons |= IN_DUCK;

				if(g_bCanThrowSmoke[client])
				{
					TeleportEntity(client, fASiteSmoke, fAng, NULL_VECTOR);
					iButtons &= ~IN_ATTACK;
					iButtons |= IN_DUCK;
					CreateTimer(0.2, Timer_NadeDelay, client);
				}
			}
		}
		case 8: //Long Corner Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				float fLongCornerSmokeDis = GetVectorDistance(fClientLocation, fLongCornerSmoke);
				
				BotMoveTo(client, fLongCornerSmoke, FASTEST_ROUTE);
				
				if(fLongCornerSmokeDis < 150.0)
				{
					if(iDefIndex != 45)
					{
						FakeClientCommandEx(client, "use weapon_smokegrenade");
					}
				}
				
				if(fLongCornerSmokeDis < 25.0)
				{
					float fLookAt[3] = { 773.901000, 218.274353, 711.968750 };
					float fAng[3] = { -44.566452, 63.847935, 0.000000 };

					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);

					CreateTimer(1.0, Timer_ThrowSmoke, client);
					
					iButtons |= IN_ATTACK;

					if(g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fLongCornerSmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						CreateTimer(0.2, Timer_SmokeDelay, client);
					}
				}
			}
			else
			{
				float fLongFlashDis = GetVectorDistance(fClientLocation, fLongFlash);
				
				BotMoveTo(client, fLongFlash, FASTEST_ROUTE);
				
				if(fLongFlashDis < 150.0)
				{
					if(iDefIndex != 43)
					{
						FakeClientCommandEx(client, "use weapon_flashbang");
					}
				}

				if(fLongFlashDis < 25.0)
				{
					float fLookAt[3] = { 764.960083, 71.764526, 139.333435 };
					float fAng[3] = { -6.487242, 48.617645, 0.000000 };

					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);

					CreateTimer(0.8, Timer_ThrowFlash, client);
					
					iButtons |= IN_ATTACK;

					if(g_bCanThrowFlash[client])
					{
						TeleportEntity(client, fLongFlash, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						iButtons |= IN_JUMP;
						CreateTimer(0.2, Timer_NadeDelay, client);
					}
				}
			}
		}
		case 9: //A Car Smoke
		{
			float fACarSmokeDis = GetVectorDistance(fClientLocation, fACarSmoke);
			
			BotMoveTo(client, fACarSmoke, FASTEST_ROUTE);
			
			if(fACarSmokeDis < 150.0)
			{
				if(iDefIndex != 45)
				{
					FakeClientCommandEx(client, "use weapon_smokegrenade");
				}
			}
			
			if(fACarSmokeDis < 25.0)
			{
				float fLookAt[3] = { 941.845458, 1322.355590, 711.968750 };
				float fAng[3] = { -51.036480, 35.380005, 0.000000 };

				CreateTimer(3.0, Timer_ThrowSmoke, client);

				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
				
				iButtons |= IN_ATTACK;

				if(g_bCanThrowSmoke[client])
				{
					TeleportEntity(client, fACarSmoke, fAng, NULL_VECTOR);
					iButtons &= ~IN_ATTACK;
					CreateTimer(0.2, Timer_NadeDelay, client);
				}
			}
		}
		case 10: //CT Smoke
		{
			float fCTSmokeDis = GetVectorDistance(fClientLocation, fCTSmoke);
			
			BotMoveTo(client, fCTSmoke, FASTEST_ROUTE);
			
			if(fCTSmokeDis < 150.0)
			{
				if(iDefIndex != 45)
				{
					FakeClientCommandEx(client, "use weapon_smokegrenade");
				}
			}
			
			if(fCTSmokeDis < 25.0)
			{
				float fLookAt[3] = { 526.411682, 1486.244140, 711.968750 };
				float fAng[3] = { -52.145287, 88.816231, 0.000000 };

				CreateTimer(3.0, Timer_ThrowSmoke, client);

				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
				
				iButtons |= IN_ATTACK;

				if(g_bCanThrowSmoke[client])
				{
					TeleportEntity(client, fCTSmoke, fAng, NULL_VECTOR);
					iButtons &= ~IN_ATTACK;
					CreateTimer(0.2, Timer_NadeDelay, client);
				}
			}
		}
	}

	switch(g_iPositionToHold[client])
	{
		case 1: //Lower Tunnel Position
		{
			if(!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);

				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);

				if(fHoldSpotDis < 25.0)
				{
					float fLookAt[3] = { -1085.206177, 1362.727051, -48.119759 };
					float fBentLook[3], fEyePos[3];

					GetClientEyePosition(client, fEyePos);

					BotBendLineOfSight(client, fEyePos, fLookAt, fBentLook, 135.0);
					BotSetLookAt(client, "Use entity", fBentLook, PRIORITY_HIGH, 1.0, true, 5.0, false);

					CreateTimer(5.0, Timer_ThrowSmoke, client);
				}
			}
		}
		case 2: //B Position
		{
			if(!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);

				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);

				if(fHoldSpotDis < 25.0)
				{
					float fLookAt[3] = { -1975.937500, 1821.490356, 96.745338 };
					float fBentLook[3], fEyePos[3];

					GetClientEyePosition(client, fEyePos);

					BotBendLineOfSight(client, fEyePos, fLookAt, fBentLook, 135.0);
					BotSetLookAt(client, "Use entity", fBentLook, PRIORITY_HIGH, 1.0, true, 5.0, false);

					CreateTimer(5.0, Timer_ThrowSmoke, client);
				}
			}
		}
		case 3: //Long Push Position
		{
			if(!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);

				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);

				if(fHoldSpotDis < 25.0)
				{
					float fLookAt[3] = { 176.276123, 353.036530, 63.525383 };
					float fBentLook[3], fEyePos[3];

					GetClientEyePosition(client, fEyePos);

					BotBendLineOfSight(client, fEyePos, fLookAt, fBentLook, 135.0);
					BotSetLookAt(client, "Use entity", fBentLook, PRIORITY_HIGH, 1.0, true, 5.0, false);

					CreateTimer(7.0, Timer_ThrowSmoke, client);
				}
			}
		}
		case 4: //Short Push Position
		{
			if(!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);

				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);

				if(fHoldSpotDis < 25.0)
				{
					float fLookAt[3] = { 342.916260, 1485.740845, 65.328796 };
					float fBentLook[3], fEyePos[3];

					GetClientEyePosition(client, fEyePos);

					BotBendLineOfSight(client, fEyePos, fLookAt, fBentLook, 135.0);
					BotSetLookAt(client, "Use entity", fBentLook, PRIORITY_HIGH, 1.0, true, 5.0, false);

					CreateTimer(3.0, Timer_ThrowSmoke, client);
				}
			}
		}
		case 5: //Mid Position
		{
			if(!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);

				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);

				if(fHoldSpotDis < 25.0)
				{
					float fLookAt[3] = { -462.108734, 2058.169922, -61.744308 };
					float fBentLook[3], fEyePos[3];

					GetClientEyePosition(client, fEyePos);

					BotBendLineOfSight(client, fEyePos, fLookAt, fBentLook, 135.0);
					BotSetLookAt(client, "Use entity", fBentLook, PRIORITY_HIGH, 1.0, true, 5.0, false);

					CreateTimer(5.0, Timer_ThrowSmoke, client);
				}
			}
		}
		case 6: //A Position
		{
			if(!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);

				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);

				if(fHoldSpotDis < 25.0)
				{
					float fLookAt[3] = { 776.948059, 2607.570801, 158.780182 };
					float fBentLook[3], fEyePos[3];

					GetClientEyePosition(client, fEyePos);

					BotBendLineOfSight(client, fEyePos, fLookAt, fBentLook, 135.0);
					BotSetLookAt(client, "Use entity", fBentLook, PRIORITY_HIGH, 1.0, true, 5.0, false);

					CreateTimer(3.0, Timer_ThrowSmoke, client);
				}
			}
		}
		case 7: //Mid Push Position
		{
			if(!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);

				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);

				if(fHoldSpotDis < 25.0)
				{
					float fLookAt[3] = { -161.266556, 398.383514, 62.534039 };
					float fBentLook[3], fEyePos[3];

					GetClientEyePosition(client, fEyePos);

					BotBendLineOfSight(client, fEyePos, fLookAt, fBentLook, 135.0);
					BotSetLookAt(client, "Use entity", fBentLook, PRIORITY_HIGH, 1.0, true, 5.0, false);

					CreateTimer(5.0, Timer_ThrowSmoke, client);
				}
			}
		}
		case 8: //Long Position
		{
			if(!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);

				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);

				if(fHoldSpotDis < 25.0)
				{
					float fLookAt[3] = { 1328.326050, 1216.048950, 62.165554 };
					float fBentLook[3], fEyePos[3];

					GetClientEyePosition(client, fEyePos);

					BotBendLineOfSight(client, fEyePos, fLookAt, fBentLook, 135.0);
					BotSetLookAt(client, "Use entity", fBentLook, PRIORITY_HIGH, 1.0, true, 5.0, false);

					CreateTimer(3.0, Timer_ThrowSmoke, client);
				}
			}
		}
	}
}