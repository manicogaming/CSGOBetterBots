public void DoInfernoSmokes(int client, int& iButtons, int iDefIndex)
{
	float fClientLocation[3];
	
	GetClientAbsOrigin(client, fClientLocation);
	
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
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
						
						CreateTimer(3.0, Timer_ThrowSmoke, GetClientUserId(client));
						
						iButtons |= IN_ATTACK;
						
						if (g_bCanThrowSmoke[client])
						{
							TeleportEntity(client, fCTSmoke, fAng, NULL_VECTOR);
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
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 3.0, true, 5.0, false);
						
						CreateTimer(2.0, Timer_ThrowFlash, GetClientUserId(client));
						
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
		case 2: //Coffin Smoke
		{
			if (!g_bHasThrownSmoke[client])
			{
				float fCoffinSmoke[3], fLookAt[3], fAng[3];
				
				if (GetNade("Coffin Smoke", fCoffinSmoke, fLookAt, fAng))
				{
					float fCoffinSmokeDis = GetVectorDistance(fClientLocation, fCoffinSmoke);
				
					BotMoveTo(client, fCoffinSmoke, FASTEST_ROUTE);
					
					if (fCoffinSmokeDis < 150.0)
					{
						if (iDefIndex != 45)
						{
							FakeClientCommandEx(client, "use weapon_smokegrenade");
						}
					}
					
					if (fCoffinSmokeDis < 25.0)
					{					
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
						
						CreateTimer(3.0, Timer_ThrowSmoke, GetClientUserId(client));
						
						iButtons |= IN_ATTACK;
						
						if (g_bCanThrowSmoke[client])
						{
							TeleportEntity(client, fCoffinSmoke, fAng, NULL_VECTOR);
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
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
						
						CreateTimer(0.5, Timer_ThrowFlash, GetClientUserId(client));
						
						iButtons |= IN_ATTACK;
						
						if (g_bCanThrowFlash[client])
						{
							TeleportEntity(client, fBSiteFlash, fAng, NULL_VECTOR);
							iButtons &= ~IN_ATTACK;
							CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
						}
					}
				}
			}
		}
		case 3: //Long A Smoke
		{
			float fLongASmoke[3], fLookAt[3], fAng[3];
			
			if (GetNade("Long A Smoke", fLongASmoke, fLookAt, fAng))
			{
				float fLongASmokeDis = GetVectorDistance(fClientLocation, fLongASmoke);
			
				BotMoveTo(client, fLongASmoke, FASTEST_ROUTE);
				
				if (fLongASmokeDis < 150.0)
				{
					if (iDefIndex != 45)
					{
						FakeClientCommandEx(client, "use weapon_smokegrenade");
					}
				}
				
				if (fLongASmokeDis < 25.0)
				{
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, GetClientUserId(client));
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fLongASmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
					}
				}
			}
		}
		case 4: //Site-Library Smoke
		{
			if (!g_bHasThrownSmoke[client])
			{
				float fSiteLibrarySmoke[3], fLookAt[3], fAng[3];
				
				if (GetNade("Site-Library Smoke", fSiteLibrarySmoke, fLookAt, fAng))
				{
					float fSiteLibrarySmokeDis = GetVectorDistance(fClientLocation, fSiteLibrarySmoke);
				
					BotMoveTo(client, fSiteLibrarySmoke, FASTEST_ROUTE);
					
					if (fSiteLibrarySmokeDis < 150.0)
					{
						if (iDefIndex != 45)
						{
							FakeClientCommandEx(client, "use weapon_smokegrenade");
						}
					}
					
					if (fSiteLibrarySmokeDis < 25.0)
					{					
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
						
						CreateTimer(3.0, Timer_ThrowSmoke, GetClientUserId(client));
						
						iButtons |= IN_ATTACK;
						
						if (g_bCanThrowSmoke[client])
						{
							TeleportEntity(client, fSiteLibrarySmoke, fAng, NULL_VECTOR);
							iButtons &= ~IN_ATTACK;
							CreateTimer(0.2, Timer_SmokeDelay, GetClientUserId(client));
						}
					}
				}
			}
			else
			{
				float fPitFlash[3], fLookAt[3], fAng[3];
			
				if (GetNade("Pit Flash", fPitFlash, fLookAt, fAng))
				{
					float fPitFlashDis = GetVectorDistance(fClientLocation, fPitFlash);
				
					BotMoveTo(client, fPitFlash, FASTEST_ROUTE);
					
					if (fPitFlashDis < 150.0)
					{
						if (iDefIndex != 43)
						{
							FakeClientCommandEx(client, "use weapon_flashbang");
						}
					}
					
					if (fPitFlashDis < 25.0)
					{
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
						
						CreateTimer(1.0, Timer_ThrowFlash, GetClientUserId(client));
						
						iButtons |= IN_ATTACK;
						
						if (g_bCanThrowFlash[client])
						{
							TeleportEntity(client, fPitFlash, fAng, NULL_VECTOR);
							iButtons &= ~IN_ATTACK;
							iButtons |= IN_JUMP;
							CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
						}
					}
				}
			}
		}
		case 5: //Pit Smoke
		{
			float fPitSmoke[3], fLookAt[3], fAng[3];
			
			if (GetNade("Pit Smoke", fPitSmoke, fLookAt, fAng))
			{
				float fPitSmokeDis = GetVectorDistance(fClientLocation, fPitSmoke);
			
				BotMoveTo(client, fPitSmoke, FASTEST_ROUTE);
				
				if (fPitSmokeDis < 150.0)
				{
					if (iDefIndex != 45)
					{
						FakeClientCommandEx(client, "use weapon_smokegrenade");
					}
				}
				
				if (fPitSmokeDis < 25.0)
				{
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, GetClientUserId(client));
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fPitSmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
					}
				}
			}
		}
		case 6: //Balcony Smoke
		{
			if (!g_bHasThrownSmoke[client])
			{
				float fBalconySmoke[3], fLookAt[3], fAng[3];
				
				if (GetNade("Balcony Smoke", fBalconySmoke, fLookAt, fAng))
				{
					float fBalconySmokeDis = GetVectorDistance(fClientLocation, fBalconySmoke);
				
					BotMoveTo(client, fBalconySmoke, FASTEST_ROUTE);
					
					if (fBalconySmokeDis < 150.0)
					{
						if (iDefIndex != 45)
						{
							FakeClientCommandEx(client, "use weapon_smokegrenade");
						}
					}
					
					if (fBalconySmokeDis < 25.0)
					{					
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
						
						CreateTimer(3.0, Timer_ThrowSmoke, GetClientUserId(client));
						
						iButtons |= IN_ATTACK;
						
						if (g_bCanThrowSmoke[client])
						{
							TeleportEntity(client, fBalconySmoke, fAng, NULL_VECTOR);
							iButtons &= ~IN_ATTACK;
							CreateTimer(0.2, Timer_SmokeDelay, GetClientUserId(client));
						}
					}
				}
			}
			else
			{
				float fBalconyFlash[3], fLookAt[3], fAng[3];
			
				if (GetNade("Balcony Flash", fBalconyFlash, fLookAt, fAng))
				{
					float fBalconyFlashDis = GetVectorDistance(fClientLocation, fBalconyFlash);
				
					BotMoveTo(client, fBalconyFlash, FASTEST_ROUTE);
					
					if (fBalconyFlashDis < 150.0)
					{
						if (iDefIndex != 43)
						{
							FakeClientCommandEx(client, "use weapon_flashbang");
						}
					}
					
					if (fBalconyFlashDis < 25.0)
					{
						BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 2.0, true, 5.0, false);
						
						CreateTimer(1.0, Timer_ThrowFlash, GetClientUserId(client));
						
						iButtons |= IN_ATTACK;
						iButtons |= IN_DUCK;
						
						if (g_bCanThrowFlash[client])
						{
							TeleportEntity(client, fBalconyFlash, fAng, NULL_VECTOR);
							iButtons &= ~IN_ATTACK;
							iButtons |= IN_DUCK;
							CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
						}
					}
				}
			}
		}
		case 7: //Short A Smoke
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
		case 8: //Arch Smoke
		{
			float fArchSmoke[3], fLookAt[3], fAng[3];
			
			if (GetNade("Arch Smoke", fArchSmoke, fLookAt, fAng))
			{
				float fArchSmokeDis = GetVectorDistance(fClientLocation, fArchSmoke);
			
				BotMoveTo(client, fArchSmoke, FASTEST_ROUTE);
				
				if (fArchSmokeDis < 150.0)
				{
					if (iDefIndex != 45)
					{
						FakeClientCommandEx(client, "use weapon_smokegrenade");
					}
				}
				
				if (fArchSmokeDis < 25.0)
				{
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, GetClientUserId(client));
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fArchSmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
					}
				}
			}
		}
		case 9: //Graveyard Smoke
		{
			float fGraveyardSmoke[3], fLookAt[3], fAng[3];
			
			if (GetNade("Graveyard Smoke", fGraveyardSmoke, fLookAt, fAng))
			{
				float fGraveyardSmokeDis = GetVectorDistance(fClientLocation, fGraveyardSmoke);
			
				BotMoveTo(client, fGraveyardSmoke, FASTEST_ROUTE);
				
				if (fGraveyardSmokeDis < 150.0)
				{
					if (iDefIndex != 45)
					{
						FakeClientCommandEx(client, "use weapon_smokegrenade");
					}
				}
				
				if (fGraveyardSmokeDis < 25.0)
				{
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, GetClientUserId(client));
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fGraveyardSmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						iButtons |= IN_JUMP;
						CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
					}
				}
			}
		}
		case 10: //Library Smoke
		{
			float fLibrarySmoke[3], fLookAt[3], fAng[3];
			
			if (GetNade("Library Smoke", fLibrarySmoke, fLookAt, fAng))
			{
				float fLibrarySmokeDis = GetVectorDistance(fClientLocation, fLibrarySmoke);
			
				BotMoveTo(client, fLibrarySmoke, FASTEST_ROUTE);
				
				if (fLibrarySmokeDis < 150.0)
				{
					if (iDefIndex != 45)
					{
						FakeClientCommandEx(client, "use weapon_smokegrenade");
					}
				}
				
				if (fLibrarySmokeDis < 25.0)
				{
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 4.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, GetClientUserId(client));
					
					iButtons |= IN_ATTACK;
					
					if (g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fLibrarySmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
					}
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
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
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
					
					CreateTimer(5.0, Timer_ThrowSmoke, client);
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
					
					CreateTimer(5.0, Timer_ThrowSmoke, client);
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
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
				}
			}
		}
	}
} 