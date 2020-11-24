public void DoMirageSmokes(int client, int & iButtons)
{
	float fClientLocation[3];
	
	GetClientAbsOrigin(client, fClientLocation);
	
	int iActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if (iActiveWeapon == -1)return;
	
	int iDefIndex = GetEntProp(iActiveWeapon, Prop_Send, "m_iItemDefinitionIndex");
	
	//T Side Smokes
	float fJungleSmoke[3] =  { 815.968750, -1458.346680, -108.968750 };
	float fTopMidSmoke[3] =  { 1422.968750, 70.759926, -112.902664 };
	float fMidShortSmoke[3] =  { 1422.968750, -367.968750, -167.968750 };
	float fWindowSmoke[3] =  { 343.301605, -621.619263, -163.429565 };
	float fBottomConSmoke[3] =  { 1135.986816, 647.868591, -261.387939 };
	float fTopConSmoke[3] =  { 399.461334, 280.494476, -254.629471 };
	float fShortLeftSmoke[3] =  { -824.853577, 522.031250, -78.349075 };
	float fShortRightSmoke[3] =  { -148.031250, 353.031250, -34.427696 };
	float fMarketDoorSmoke[3] =  { -161.031250, 450.986938, -69.675163 };
	float fMarketWindowSmoke[3] =  { -160.018127, 887.968750, -135.328125 };
	
	//T Side Flashes
	
	float fLampFlash[3] =  { 871.768738, -1036.026489, -251.968750 };
	float fASiteFlash[3] =  { 760.967041, -1211.969727, -108.968750 };
	float fMidFlash[3] =  { 399.694031, 100.925285, -227.086563 };
	float fConnectorFlash[3] =  { 360.075439, -691.968750, -162.496780 };
	float fBCarFlash[3] =  { -539.903625, 520.031250, -81.331062 };
	float fBShortFlash[3] =  { -736.012878, 623.968750, -75.968750 };
	float fBCornerFlash[3] =  { -1471.968750, 664.031250, -47.968750 };
	
	switch (g_iSmoke[client])
	{
		case 1: //CT Smoke
		{
			if (!g_bHasThrownSmoke[client])
			{
				float fCTSmoke[3];
				
				if (!GetNadePosition("CT Smoke", fCTSmoke))
				{
					return;
				}
				
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
					float fLookAt[3] =  { -968.578002, -2475.483886, 1247.968750 };
					float fAng[3] =  { -29.747553, -144.440994, 0.000000 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 6.0, true, 5.0, false);
					
					CreateTimer(5.0, Timer_ThrowSmoke, client);
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fCTSmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						iButtons |= IN_JUMP;
						CreateTimer(0.2, Timer_SmokeDelay, client);
					}
				}
			}
			else
			{
				float fLampFlashDis = GetVectorDistance(fClientLocation, fLampFlash);
				
				BotMoveTo(client, fLampFlash, FASTEST_ROUTE);
				
				if (fLampFlashDis < 150.0)
				{
					if (iDefIndex != 43)
					{
						FakeClientCommandEx(client, "use weapon_flashbang");
					}
				}
				
				if (fLampFlashDis < 25.0)
				{
					float fLookAt[3] =  { -1101.290527, -2002.246459, 1247.968750 };
					float fAng[3] =  { -33.137276, -153.979980, 0.000000 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
					
					CreateTimer(1.0, Timer_ThrowFlash, client);
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowFlash[client])
					{
						TeleportEntity(client, fLampFlash, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						CreateTimer(0.2, Timer_NadeDelay, client);
					}
				}
			}
		}
		case 2: //Stairs Smoke
		{
			float fStairsSmoke[3];
			
			if (!GetNadePosition("Stairs Smoke", fStairsSmoke))
			{
				return;
			}
			
			float fStairsSmokeDis = GetVectorDistance(fClientLocation, fStairsSmoke);
			
			BotMoveTo(client, fStairsSmoke, FASTEST_ROUTE);
			
			if (fStairsSmokeDis < 150.0)
			{
				if (iDefIndex != 45)
				{
					FakeClientCommandEx(client, "use weapon_smokegrenade");
				}
			}
			
			if (fStairsSmokeDis < 25.0)
			{
				float fLookAt[3] =  { -381.378540, -1587.050903, 1247.968750 };
				float fAng[3] =  { -41.152348, -165.229919, 0.000000 };
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
				
				iButtons |= IN_ATTACK;
				
				if (g_bCanThrowSmoke[client])
				{
					TeleportEntity(client, fStairsSmoke, fAng, NULL_VECTOR);
					iButtons &= ~IN_ATTACK;
					CreateTimer(0.2, Timer_NadeDelay, client);
				}
			}
		}
		case 3: //Jungle Smoke
		{
			if (!g_bHasThrownSmoke[client])
			{
				float fJungleSmokeDis = GetVectorDistance(fClientLocation, fJungleSmoke);
				
				BotMoveTo(client, fJungleSmoke, FASTEST_ROUTE);
				
				if (fJungleSmokeDis < 150.0)
				{
					if (iDefIndex != 45)
					{
						FakeClientCommandEx(client, "use weapon_smokegrenade");
					}
				}
				
				if (fJungleSmokeDis < 25.0)
				{
					float fLookAt[3] =  { -1680.662597, -1692.091064, 1247.968750 };
					float fAng[3] =  { -27.276443, -174.651337, 0.000000 };
					
					CreateTimer(1.5, Timer_ThrowSmoke, client);
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fJungleSmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						CreateTimer(0.2, Timer_SmokeDelay, client);
					}
				}
			}
			else
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
					float fLookAt[3] =  { -1363.686279, -2822.454589, 1247.968750 };
					float fAng[3] =  { -25.871719, -142.837921, 0.000000 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
					
					CreateTimer(1.0, Timer_ThrowFlash, client);
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowFlash[client])
					{
						TeleportEntity(client, fASiteFlash, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						CreateTimer(0.2, Timer_NadeDelay, client);
					}
				}
			}
		}
		case 4: //Top-Mid Smoke
		{
			if (!g_bHasThrownSmoke[client])
			{
				float fTopMidSmokeDis = GetVectorDistance(fClientLocation, fTopMidSmoke);
				
				BotMoveTo(client, fTopMidSmoke, FASTEST_ROUTE);
				
				if (fTopMidSmokeDis < 150.0)
				{
					if (iDefIndex != 45)
					{
						FakeClientCommandEx(client, "use weapon_smokegrenade");
					}
				}
				
				if (fTopMidSmokeDis < 25.0)
				{
					float fLookAt[3] =  { -534.322998, -440.784057, 1247.968750 };
					float fAng[3] =  { -32.682899, -165.408432, 0.000000 };
					
					CreateTimer(1.0, Timer_ThrowSmoke, client);
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fTopMidSmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						CreateTimer(0.2, Timer_SmokeDelay, client);
					}
				}
			}
			else
			{
				float fConnectorFlashDis = GetVectorDistance(fClientLocation, fConnectorFlash);
				
				BotMoveTo(client, fConnectorFlash, FASTEST_ROUTE);
				
				if (fConnectorFlashDis < 150.0)
				{
					if (iDefIndex != 43)
					{
						FakeClientCommandEx(client, "use weapon_flashbang");
					}
				}
				
				if (fConnectorFlashDis < 25.0)
				{
					float fLookAt[3] =  { -673.912231, -807.603210, 89.318618 };
					float fAng[3] =  { -10.137602, -173.642319, 0.000000 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
					
					CreateTimer(1.0, Timer_ThrowFlash, client);
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowFlash[client])
					{
						TeleportEntity(client, fConnectorFlash, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						CreateTimer(0.2, Timer_NadeDelay, client);
					}
				}
			}
		}
		case 5: //Mid-Short Smoke
		{
			float fMidShortSmokeDis = GetVectorDistance(fClientLocation, fMidShortSmoke);
			
			BotMoveTo(client, fMidShortSmoke, FASTEST_ROUTE);
			
			if (fMidShortSmokeDis < 150.0)
			{
				if (iDefIndex != 45)
				{
					FakeClientCommandEx(client, "use weapon_smokegrenade");
				}
			}
			
			if (fMidShortSmokeDis < 25.0)
			{
				float fLookAt[3] =  { 1084.031250, -344.407287, 120.518768 };
				float fAng[3] =  { -33.454041, 176.023438, 0.000000 };
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
				
				iButtons |= IN_ATTACK;
				
				if (g_bCanThrowSmoke[client])
				{
					TeleportEntity(client, fMidShortSmoke, fAng, NULL_VECTOR);
					iButtons &= ~IN_ATTACK;
					iButtons |= IN_JUMP;
					CreateTimer(0.2, Timer_NadeDelay, client);
				}
			}
		}
		case 6: //Window Smoke
		{
			float fWindowSmokeDis = GetVectorDistance(fClientLocation, fWindowSmoke);
			
			BotMoveTo(client, fWindowSmoke, FASTEST_ROUTE);
			
			if (fWindowSmokeDis < 150.0)
			{
				if (iDefIndex != 45)
				{
					FakeClientCommandEx(client, "use weapon_smokegrenade");
				}
			}
			
			if (fWindowSmokeDis < 25.0)
			{
				float fLookAt[3] =  { -1781.744995, -616.433410, 1247.968750 };
				float fAng[3] =  { -32.376904, 179.860184, 0.000000 };
				
				CreateTimer(1.5, Timer_ThrowSmoke, client);
				
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
				
				iButtons |= IN_ATTACK;
				
				if (g_bCanThrowSmoke[client])
				{
					TeleportEntity(client, fWindowSmoke, fAng, NULL_VECTOR);
					iButtons &= ~IN_ATTACK;
					CreateTimer(0.2, Timer_NadeDelay, client);
				}
			}
		}
		case 7: //Bottom Con Smoke
		{
			if (!g_bHasThrownSmoke[client])
			{
				float fBottomConSmokeDis = GetVectorDistance(fClientLocation, fBottomConSmoke);
				
				BotMoveTo(client, fBottomConSmoke, FASTEST_ROUTE);
				
				if (fBottomConSmokeDis < 150.0)
				{
					if (iDefIndex != 45)
					{
						FakeClientCommandEx(client, "use weapon_smokegrenade");
					}
				}
				
				if (fBottomConSmokeDis < 25.0)
				{
					float fLookAt[3] =  { 871.046142, 426.846496, 35.827545 };
					float fAng[3] =  { -34.056019, -140.164047, 0.000000 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fBottomConSmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						iButtons |= IN_JUMP;
						CreateTimer(0.2, Timer_SmokeDelay, client);
					}
				}
			}
			else
			{
				float fMidFlashDis = GetVectorDistance(fClientLocation, fMidFlash);
				
				BotMoveTo(client, fMidFlash, FASTEST_ROUTE);
				
				if (fMidFlashDis < 150.0)
				{
					if (iDefIndex != 43)
					{
						FakeClientCommandEx(client, "use weapon_flashbang");
					}
				}
				
				if (fMidFlashDis < 25.0)
				{
					float fLookAt[3] =  { -705.667175, -662.211425, 1247.968750 };
					float fAng[3] =  { -46.411167, -145.378967, 0.000000 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
					
					CreateTimer(1.0, Timer_ThrowFlash, client);
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowFlash[client])
					{
						TeleportEntity(client, fMidFlash, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						CreateTimer(0.2, Timer_NadeDelay, client);
					}
				}
			}
		}
		case 8: //Top Con Smoke
		{
			float fTopConSmokeDis = GetVectorDistance(fClientLocation, fTopConSmoke);
			
			BotMoveTo(client, fTopConSmoke, FASTEST_ROUTE);
			
			if (fTopConSmokeDis < 150.0)
			{
				if (iDefIndex != 45)
				{
					FakeClientCommandEx(client, "use weapon_smokegrenade");
				}
			}
			
			if (fTopConSmokeDis < 25.0)
			{
				float fLookAt[3] =  { -721.445068, -1061.828369, 1247.968750 };
				float fAng[3] =  { -39.441586, -129.863556, 0.000000 };
				
				CreateTimer(1.5, Timer_ThrowSmoke, client);
				
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
				
				iButtons |= IN_ATTACK;
				
				if (g_bCanThrowSmoke[client])
				{
					TeleportEntity(client, fTopConSmoke, fAng, NULL_VECTOR);
					iButtons &= ~IN_ATTACK;
					iButtons |= IN_JUMP;
					CreateTimer(0.2, Timer_NadeDelay, client);
				}
			}
		}
		case 9: //Short-Left Smoke
		{
			if (!g_bHasThrownSmoke[client])
			{
				float fShotLeftSmokeDis = GetVectorDistance(fClientLocation, fShortLeftSmoke);
				
				BotMoveTo(client, fShortLeftSmoke, FASTEST_ROUTE);
				
				if (fShotLeftSmokeDis < 150.0)
				{
					if (iDefIndex != 45)
					{
						FakeClientCommandEx(client, "use weapon_smokegrenade");
					}
				}
				
				if (fShotLeftSmokeDis < 25.0)
				{
					float fLookAt[3] =  { -1099.964355, 513.915588, 1247.968750 };
					float fAng[3] =  { -77.699974, -178.310287, 0.000000 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
					
					CreateTimer(1.5, Timer_ThrowSmoke, client);
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fShortLeftSmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						CreateTimer(0.2, Timer_SmokeDelay, client);
					}
				}
			}
			else
			{
				float fBCornerFlashDis = GetVectorDistance(fClientLocation, fBCornerFlash);
				
				BotMoveTo(client, fBCornerFlash, FASTEST_ROUTE);
				
				if (fBCornerFlashDis < 150.0)
				{
					if (iDefIndex != 43)
					{
						FakeClientCommandEx(client, "use weapon_flashbang");
					}
				}
				
				if (fBCornerFlashDis < 25.0)
				{
					float fLookAt[3] =  { -1548.312500, 879.968750, 47.377731 };
					float fAng[3] =  { -7.793244, 109.470818, 0.000000 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
					
					CreateTimer(1.0, Timer_ThrowFlash, client);
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowFlash[client])
					{
						TeleportEntity(client, fBCornerFlash, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						CreateTimer(0.2, Timer_NadeDelay, client);
					}
				}
			}
		}
		case 10: //Short-Right Smoke
		{
			if (!g_bHasThrownSmoke[client])
			{
				float fShortRightSmokeDis = GetVectorDistance(fClientLocation, fShortRightSmoke);
				
				BotMoveTo(client, fShortRightSmoke, FASTEST_ROUTE);
				
				if (fShortRightSmokeDis < 150.0)
				{
					if (iDefIndex != 45)
					{
						FakeClientCommandEx(client, "use weapon_smokegrenade");
					}
				}
				
				if (fShortRightSmokeDis < 25.0)
				{
					float fLookAt[3] =  { -753.403015, 262.973724, 1247.968750 };
					float fAng[3] =  { -63.328373, -171.538513, 0.000000 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fShortRightSmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						CreateTimer(0.2, Timer_SmokeDelay, client);
					}
				}
			}
			else
			{
				float fBCarFlashDis = GetVectorDistance(fClientLocation, fBCarFlash);
				
				BotMoveTo(client, fBCarFlash, FASTEST_ROUTE);
				
				if (fBCarFlashDis < 150.0)
				{
					if (iDefIndex != 43)
					{
						FakeClientCommandEx(client, "use weapon_flashbang");
					}
				}
				
				if (fBCarFlashDis < 25.0)
				{
					float fLookAt[3] =  { -960.000000, 560.375122, 144.435302 };
					float fAng[3] =  { -20.972137, 174.514435, 0.000000 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
					
					CreateTimer(1.0, Timer_ThrowFlash, client);
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowFlash[client])
					{
						TeleportEntity(client, fBCarFlash, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						iButtons |= IN_JUMP;
						CreateTimer(0.2, Timer_NadeDelay, client);
					}
				}
			}
		}
		case 11: //Market Door Smoke
		{
			if (!g_bHasThrownSmoke[client])
			{
				float fMarketDoorSmokeDis = GetVectorDistance(fClientLocation, fMarketDoorSmoke);
				
				BotMoveTo(client, fMarketDoorSmoke, FASTEST_ROUTE);
				
				if (fMarketDoorSmokeDis < 150.0)
				{
					if (iDefIndex != 45)
					{
						FakeClientCommandEx(client, "use weapon_smokegrenade");
					}
				}
				
				if (fMarketDoorSmokeDis < 25.0)
				{
					float fLookAt[3] =  { -2019.728759, -101.377380, 1247.968627 };
					float fAng[3] =  { -32.883850, -163.449203, 0.000000 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 6.0, true, 5.0, false);
					
					CreateTimer(5.0, Timer_ThrowSmoke, client);
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fMarketDoorSmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						iButtons |= IN_JUMP;
						CreateTimer(0.2, Timer_SmokeDelay, client);
					}
				}
			}
			else
			{
				float fBShortFlashDis = GetVectorDistance(fClientLocation, fBShortFlash);
				
				BotMoveTo(client, fBShortFlash, FASTEST_ROUTE);
				
				if (fBShortFlashDis < 150.0)
				{
					if (iDefIndex != 43)
					{
						FakeClientCommandEx(client, "use weapon_flashbang");
					}
				}
				
				if (fBShortFlashDis < 25.0)
				{
					float fLookAt[3] =  { -1758.125244, 317.450500, 1247.968750 };
					float fAng[3] =  { -49.737614, -163.306702, 0.000000 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
					
					CreateTimer(1.0, Timer_ThrowFlash, client);
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowFlash[client])
					{
						TeleportEntity(client, fBShortFlash, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						iButtons |= IN_JUMP;
						CreateTimer(0.2, Timer_NadeDelay, client);
					}
				}
			}
		}
		case 12: //Market Window Smoke
		{
			float fMarketWindowSmokeDis = GetVectorDistance(fClientLocation, fMarketWindowSmoke);
			
			BotMoveTo(client, fMarketWindowSmoke, FASTEST_ROUTE);
			
			if (fMarketWindowSmokeDis < 150.0)
			{
				if (iDefIndex != 45)
				{
					FakeClientCommandEx(client, "use weapon_smokegrenade");
				}
			}
			
			if (fMarketWindowSmokeDis < 25.0)
			{
				float fLookAt[3] =  { -736.619445, 505.915191, 763.924560 };
				float fAng[3] =  { -50.371174, -146.471710, 0.000000 };
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
				
				iButtons |= IN_ATTACK;
				
				if (g_bCanThrowSmoke[client])
				{
					TeleportEntity(client, fMarketWindowSmoke, fAng, NULL_VECTOR);
					iButtons &= ~IN_ATTACK;
					iButtons |= IN_JUMP;
					CreateTimer(0.2, Timer_NadeDelay, client);
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
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
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
					
					CreateTimer(1.5, Timer_ThrowSmoke, client);
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
					
					CreateTimer(5.0, Timer_ThrowSmoke, client);
				}
			}
		}
	}
} 