public void DoMirageSmokes(int client, int& iButtons, int iDefIndex)
{
	float fClientLocation[3];
	
	GetClientAbsOrigin(client, fClientLocation);
	
	int[] clients = new int[MaxClients];
	
	Client_Get(clients, CLIENTFILTER_TEAMONE | CLIENTFILTER_BOTS);
	
	switch (g_iSmoke[client])
	{
		case 1: //CT Smoke
		{
			if (!g_bHasThrownSmoke[client])
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
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 6.0, true, 5.0, false);
						
						CreateTimer(5.0, Timer_ThrowSmoke, GetClientUserId(client));
						
						iButtons |= IN_ATTACK;
						
						if (g_bCanThrowSmoke[client])
						{
							TeleportEntity(client, fCTSmoke, fAng, NULL_VECTOR);
							iButtons &= ~IN_ATTACK;
							iButtons |= IN_JUMP;
							CreateTimer(0.2, Timer_SmokeDelay, GetClientUserId(client));
						}
					}
				}
			}
			else
			{
				float fLampFlash[3], fLookAt[3], fAng[3];
			
				if (GetNade("Lamp Flash", fLampFlash, fLookAt, fAng))
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
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
						
						CreateTimer(1.0, Timer_ThrowFlash, GetClientUserId(client));
						
						iButtons |= IN_ATTACK;
						
						if (g_bCanThrowFlash[client])
						{
							TeleportEntity(client, fLampFlash, fAng, NULL_VECTOR);
							iButtons &= ~IN_ATTACK;
							CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
						}
					}
				}
			}
		}
		case 2: //Stairs Smoke
		{
			float fStairsSmoke[3], fLookAt[3], fAng[3];
			
			if (GetNade("Stairs Smoke", fStairsSmoke, fLookAt, fAng))
			{
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
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, GetClientUserId(client));
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fStairsSmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
					}
				}
			}
		}
		case 3: //Jungle Smoke
		{
			if (!g_bHasThrownSmoke[client])
			{
				float fJungleSmoke[3], fLookAt[3], fAng[3];
				
				if (GetNade("Jungle Smoke", fJungleSmoke, fLookAt, fAng))
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
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
						
						CreateTimer(1.5, Timer_ThrowSmoke, GetClientUserId(client));
						
						iButtons |= IN_ATTACK;
						
						if (g_bCanThrowSmoke[client])
						{
							TeleportEntity(client, fJungleSmoke, fAng, NULL_VECTOR);
							iButtons &= ~IN_ATTACK;
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
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
						
						CreateTimer(1.0, Timer_ThrowFlash, GetClientUserId(client));
						
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
		case 4: //Top-Mid Smoke
		{
			if (!g_bHasThrownSmoke[client])
			{
				float fTopMidSmoke[3], fLookAt[3], fAng[3];
				
				if (GetNade("Top-Mid Smoke", fTopMidSmoke, fLookAt, fAng))
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
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
						
						CreateTimer(1.0, Timer_ThrowSmoke, GetClientUserId(client));
						
						iButtons |= IN_ATTACK;
						
						if (g_bCanThrowSmoke[client])
						{
							TeleportEntity(client, fTopMidSmoke, fAng, NULL_VECTOR);
							iButtons &= ~IN_ATTACK;
							CreateTimer(0.2, Timer_SmokeDelay, GetClientUserId(client));
						}
					}
				}
			}
			else
			{
				float fConnectorFlash[3], fLookAt[3], fAng[3];
			
				if (GetNade("Connector Flash", fConnectorFlash, fLookAt, fAng))
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
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
						
						CreateTimer(1.0, Timer_ThrowFlash, GetClientUserId(client));
						
						iButtons |= IN_ATTACK;
						
						if (g_bCanThrowFlash[client])
						{
							TeleportEntity(client, fConnectorFlash, fAng, NULL_VECTOR);
							iButtons &= ~IN_ATTACK;
							CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
						}
					}
				}
			}
		}
		case 5: //Mid-Short Smoke
		{
			float fMidShortSmoke[3], fLookAt[3], fAng[3];
			
			if (GetNade("Mid-Short Smoke", fMidShortSmoke, fLookAt, fAng))
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
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, GetClientUserId(client));
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fMidShortSmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						iButtons |= IN_JUMP;
						CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
					}
				}
			}
		}
		case 6: //Window Smoke
		{
			float fWindowSmoke[3], fLookAt[3], fAng[3];
			
			if (GetNade("Window Smoke", fWindowSmoke, fLookAt, fAng))
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
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
					
					CreateTimer(1.5, Timer_ThrowSmoke, GetClientUserId(client));
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fWindowSmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
					}
				}
			}
		}
		case 7: //Bottom Con Smoke
		{
			if (!g_bHasThrownSmoke[client])
			{
				float fBottomConSmoke[3], fLookAt[3], fAng[3];
			
				if (GetNade("Bottom Con Smoke", fBottomConSmoke, fLookAt, fAng))
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
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
						
						CreateTimer(3.0, Timer_ThrowSmoke, GetClientUserId(client));
						
						iButtons |= IN_ATTACK;
						
						if (g_bCanThrowSmoke[client])
						{
							TeleportEntity(client, fBottomConSmoke, fAng, NULL_VECTOR);
							iButtons &= ~IN_ATTACK;
							iButtons |= IN_JUMP;
							CreateTimer(0.2, Timer_SmokeDelay, GetClientUserId(client));
						}
					}
				}
			}
			else
			{
				float fMidFlash[3], fLookAt[3], fAng[3];
			
				if (GetNade("Mid Flash", fMidFlash, fLookAt, fAng))
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
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
						
						CreateTimer(1.0, Timer_ThrowFlash, GetClientUserId(client));
						
						iButtons |= IN_ATTACK;
						
						if (g_bCanThrowFlash[client])
						{
							TeleportEntity(client, fMidFlash, fAng, NULL_VECTOR);
							iButtons &= ~IN_ATTACK;
							CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
						}
					}
				}
			}
		}
		case 8: //Top Con Smoke
		{
			float fTopConSmoke[3], fLookAt[3], fAng[3];
			
			if (GetNade("Top Con Smoke", fTopConSmoke, fLookAt, fAng))
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
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
					
					CreateTimer(1.5, Timer_ThrowSmoke, GetClientUserId(client));
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fTopConSmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						iButtons |= IN_JUMP;
						CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
					}
				}
			}
		}
		case 9: //Short-Left Smoke
		{
			if (!g_bHasThrownSmoke[client])
			{
				float fShortLeftSmoke[3], fLookAt[3], fAng[3];
			
				if (GetNade("Short-Left Smoke", fShortLeftSmoke, fLookAt, fAng))
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
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
						
						CreateTimer(1.5, Timer_ThrowSmoke, GetClientUserId(client));
						
						iButtons |= IN_ATTACK;
						
						if (g_bCanThrowSmoke[client])
						{
							TeleportEntity(client, fShortLeftSmoke, fAng, NULL_VECTOR);
							iButtons &= ~IN_ATTACK;
							CreateTimer(0.2, Timer_SmokeDelay, GetClientUserId(client));
						}
					}
				}
			}
			else
			{
				float fBCornerFlash[3], fLookAt[3], fAng[3];
			
				if (GetNade("B Corner Flash", fBCornerFlash, fLookAt, fAng))
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
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
						
						CreateTimer(1.0, Timer_ThrowFlash, GetClientUserId(client));
						
						iButtons |= IN_ATTACK;
						
						if (g_bCanThrowFlash[client])
						{
							TeleportEntity(client, fBCornerFlash, fAng, NULL_VECTOR);
							iButtons &= ~IN_ATTACK;
							CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
						}
					}
				}
			}
		}
		case 10: //Short-Right Smoke
		{
			if (!g_bHasThrownSmoke[client])
			{
				float fShortRightSmoke[3], fLookAt[3], fAng[3];
			
				if (GetNade("Short-Right Smoke", fShortRightSmoke, fLookAt, fAng))
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
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
						
						CreateTimer(3.0, Timer_ThrowSmoke, GetClientUserId(client));
						
						iButtons |= IN_ATTACK;
						
						if (g_bCanThrowSmoke[client])
						{
							TeleportEntity(client, fShortRightSmoke, fAng, NULL_VECTOR);
							iButtons &= ~IN_ATTACK;
							CreateTimer(0.2, Timer_SmokeDelay, GetClientUserId(client));
						}
					}
				}
			}
			else
			{
				float fBCarFlash[3], fLookAt[3], fAng[3];
			
				if (GetNade("Car Flash", fBCarFlash, fLookAt, fAng))
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
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
						
						CreateTimer(1.0, Timer_ThrowFlash, GetClientUserId(client));
						
						iButtons |= IN_ATTACK;
						
						if (g_bCanThrowFlash[client])
						{
							TeleportEntity(client, fBCarFlash, fAng, NULL_VECTOR);
							iButtons &= ~IN_ATTACK;
							iButtons |= IN_JUMP;
							CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
						}
					}
				}
			}
		}
		case 11: //Market Door Smoke
		{
			if (!g_bHasThrownSmoke[client])
			{
				float fMarketDoorSmoke[3], fLookAt[3], fAng[3];
			
				if (GetNade("Market Door Smoke", fMarketDoorSmoke, fLookAt, fAng))
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
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 6.0, true, 5.0, false);
						
						CreateTimer(5.0, Timer_ThrowSmoke, GetClientUserId(client));
						
						iButtons |= IN_ATTACK;
						
						if (g_bCanThrowSmoke[client])
						{
							TeleportEntity(client, fMarketDoorSmoke, fAng, NULL_VECTOR);
							iButtons &= ~IN_ATTACK;
							iButtons |= IN_JUMP;
							CreateTimer(0.2, Timer_SmokeDelay, GetClientUserId(client));
						}
					}
				}
			}
			else
			{
				float fBShortFlash[3], fLookAt[3], fAng[3];
			
				if (GetNade("B Short Flash", fBShortFlash, fLookAt, fAng))
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
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
						
						CreateTimer(1.0, Timer_ThrowFlash, GetClientUserId(client));
						
						iButtons |= IN_ATTACK;
						
						if (g_bCanThrowFlash[client])
						{
							TeleportEntity(client, fBShortFlash, fAng, NULL_VECTOR);
							iButtons &= ~IN_ATTACK;
							CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
						}
					}
				}
			}
		}
		case 12: //Market Window Smoke
		{
			float fMarketWindowSmoke[3], fLookAt[3], fAng[3];
			
			if (GetNade("Market Window Smoke", fMarketWindowSmoke, fLookAt, fAng))
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
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, GetClientUserId(client));
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fMarketWindowSmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						iButtons |= IN_JUMP;
						CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
					}
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