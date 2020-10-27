public void DoInfernoSmokes(int client)
{
	float fClientLocation[3];

	GetClientAbsOrigin(client, fClientLocation);

	//T Side Smokes
	float fCTSmoke[3] = { 110.841888, 1569.614014, 132.013962 };
	float fCoffinSmoke[3] = { 119.548485, 1587.026001, 114.601593 };
	float fLongASmoke[3] = { 726.033081, 246.665131, 91.568497 };
	float fSiteLibrarySmoke[3] = { 941.968750, 429.357513, 88.082214 };
	float fPitSmoke[3] = { 492.249695, -267.968750, 88.031250 };
	float fBalconySmoke[3] = { 1562.242065, -274.097748, 256.031250 };
	float fShortASmoke[3] = { 538.006470, 699.968750, 93.837555 };
	float fArchSmoke[3] = { 726.017151, 186.010574, 97.474045 };
	float fGraveyardSmoke[3] = { 716.031250, 692.481201, 95.031250 };
	float fLibrarySmoke[3] = { 721.115723, 49.073799, 94.202866 };

	float fCTSmokeDis = GetVectorDistance(fClientLocation, fCTSmoke);
	float fCoffinSmokeDis = GetVectorDistance(fClientLocation, fCoffinSmoke);
	float fLongASmokeDis = GetVectorDistance(fClientLocation, fLongASmoke);
	float fSiteLibrarySmokeDis = GetVectorDistance(fClientLocation, fSiteLibrarySmoke);
	float fPitSmokeDis = GetVectorDistance(fClientLocation, fPitSmoke);
	float fBalconySmokeDis = GetVectorDistance(fClientLocation, fBalconySmoke);
	float fShortASmokeDis = GetVectorDistance(fClientLocation, fShortASmoke);
	float fArchSmokeDis = GetVectorDistance(fClientLocation, fArchSmoke);
	float fGraveyardSmokeDis = GetVectorDistance(fClientLocation, fGraveyardSmoke);
	float fLibrarySmokeDis = GetVectorDistance(fClientLocation, fLibrarySmoke);
	
	//T Side Flashes
	
	float fBPopFlash[3] = { 110.841888, 1569.614014, 132.013962 };
	float fBSiteFlash[3] = { 460.446747, 1828.490723, 136.114029 };
	float fPitFlash[3] = { 1016.054199, 589.945496, 96.937439 };
	float fBalconyFlash[3] = { 1511.952637, -365.968750, 256.031250 };
	float fASiteFlash[3] = { 970.794312, 434.021057, 88.949677 };
	
	float fBPopFlashDis = GetVectorDistance(fClientLocation, fBPopFlash);
	float fBSiteFlashDis = GetVectorDistance(fClientLocation, fBSiteFlash);
	float fPitFlashDis = GetVectorDistance(fClientLocation, fPitFlash);
	float fBalconyFlashDis = GetVectorDistance(fClientLocation, fBalconyFlash);
	float fASiteFlashDis = GetVectorDistance(fClientLocation, fASiteFlash);

	switch(g_iSmoke[client])
	{
		case 1: //CT Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fCTSmoke, FASTEST_ROUTE);
				if(fCTSmokeDis < 25.0)
				{
					float fOrigin[3] = { 126.180099, 1594.623535, 218.555786 };
					float fVelocity[3] = { 279.111480, 455.104156, 403.039886 };
					float fLookAt[3] = { 552.833129, 2287.626708, 703.968750 };
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					if(g_bCanThrowSmoke[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
						g_bHasThrownSmoke[client] = true;
					}
				}
			}
			else
			{
				BotMoveTo(client, fBPopFlash, FASTEST_ROUTE);
				
				if(fBPopFlashDis < 25.0)
				{
					float fOrigin[3] = { 116.239662, 1599.591674, 217.027221 };
					float fVelocity[3] = { 98.223937, 545.508056, 375.224639 };
					float fLookAt[3] = { 280.816467, 2520.380371, 703.968750 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(1.0, Timer_ThrowFlash, client);
					
					if(g_bCanThrowFlash[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						g_bHasThrownNade[client] = true;
					}
				}
			}
		}
		case 2: //Coffin Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fCoffinSmoke, FASTEST_ROUTE);
				if(fCoffinSmokeDis < 25.0)
				{
					float fOrigin[3] = { 124.223114, 1610.318237, 206.933364 };
					float fVelocity[3] = { 85.064758, 423.851562, 508.400268 };
					float fLookAt[3] = { 222.170715, 2095.091308, 703.968750 };

					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
						
					if(g_bCanThrowSmoke[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
						g_bHasThrownSmoke[client] = true;
					}
				}
			}
			else
			{
				BotMoveTo(client, fBSiteFlash, FASTEST_ROUTE);
				
				if(fBSiteFlashDis < 25.0)
				{
					float fOrigin[3] = { 502.248596, 1877.067138, 211.774047 };
					float fVelocity[3] = { 544.969848, 633.244689, 265.000732 };
					float fLookAt[3] = { 1511.968750, 3052.402343, 647.973815 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(1.0, Timer_ThrowFlash, client);
					
					if(g_bCanThrowFlash[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						g_bHasThrownNade[client] = true;
					}
				}
			}
		}
		case 3: //Long A Smoke
		{
			BotMoveTo(client, fLongASmoke, FASTEST_ROUTE);
			if(fLongASmokeDis < 25.0)
			{
				float fOrigin[3] = { 748.510131, 266.215423, 177.514587 };
				float fVelocity[3] = { 409.017822, 355.759735, 392.199462 };
				float fLookAt[3] = { 1215.006835, 671.968750, 529.096862 };

				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 4: //Site-Library Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fSiteLibrarySmoke, FASTEST_ROUTE);
				if(fSiteLibrarySmokeDis < 25.0)
				{
					float fOrigin[3] = { 966.890441, 435.123535, 178.788772 };
					float fVelocity[3] = { 453.502777, 104.925148, 478.826110 };
					float fLookAt[3] = { 1560.001220, 573.159301, 703.968750 };

					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					if(g_bCanThrowSmoke[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
						g_bHasThrownSmoke[client] = true;
					}
				}
			}
			else
			{
				BotMoveTo(client, fPitFlash, FASTEST_ROUTE);
					
				if(fPitFlashDis < 25.0)
				{
					float fOrigin[3] = { 1063.403076, 564.549133, 190.514999 };
					float fVelocity[3] = { 578.116516, -305.688720, 459.011383 };
					float fLookAt[3] = { 1621.759521, 264.356170, 703.968750 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(1.0, Timer_ThrowFlash, client);
					
					if(g_bCanThrowFlash[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						g_bHasThrownNade[client] = true;
					}
				}
			}
		}
		case 5: //Pit Smoke
		{
			BotMoveTo(client, fPitSmoke, FASTEST_ROUTE);
			if(fPitSmokeDis < 25.0)
			{
				float fOrigin[3] = { 515.464782, -263.483245, 180.456237 };
				float fVelocity[3] = { 422.448150, 81.623626, 510.096252 };
				float fLookAt[3] = { 1026.942382, -164.887878, 703.968750 };

				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 6: //Balcony Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fBalconySmoke, FASTEST_ROUTE);
				if(fBalconySmokeDis < 25.0)
				{
					float fOrigin[3] = { 1589.548828, -296.347991, 331.503387 };
					float fVelocity[3] = { 496.903106, -404.890655, 201.603057 };
					float fLookAt[3] = { 1695.691772, -382.836151, 348.034759 };

					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					if(g_bCanThrowSmoke[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
						g_bHasThrownSmoke[client] = true;
					}
				}
			}
			else
			{
				BotMoveTo(client, fBalconyFlash, FASTEST_ROUTE);
					
				if(fBalconyFlashDis < 25.0)
				{
					float fOrigin[3] = { 1538.961547, -377.482635, 324.544281 };
					float fVelocity[3] = { 491.484039, -209.519790, 402.516571 };
					float fLookAt[3] = { 2096.725585, -615.257690, 703.968750 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(1.0, Timer_ThrowFlash, client);
					
					if(g_bCanThrowFlash[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						g_bHasThrownNade[client] = true;
					}
				}
			}
		}
		case 7: //Short A Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fShortASmoke, FASTEST_ROUTE);
				if(fShortASmokeDis < 25.0)
				{
					float fOrigin[3] = { 571.750854, 689.171875, 168.667236 };
					float fVelocity[3] = { 614.051269, -196.471542, 189.912460 };
					float fLookAt[3] = { 1503.968750, 390.899963, 302.738769 };

					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					if(g_bCanThrowSmoke[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
						g_bHasThrownSmoke[client] = true;
					}
				}
			}
			else
			{
				BotMoveTo(client, fASiteFlash, FASTEST_ROUTE);
					
				if(fASiteFlashDis < 25.0)
				{
					float fOrigin[3] = { 1280.024780, 483.323242, 246.076141 };
					float fVelocity[3] = { 728.586669, 116.163909, 753.715820 };
					float fLookAt[3] = { 1119.242187, 457.688690, 304.809387 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(1.0, Timer_ThrowFlash, client);
					
					if(g_bCanThrowFlash[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						g_bHasThrownNade[client] = true;
					}
				}
			}
		}
		case 8: //Arch Smoke
		{
			BotMoveTo(client, fArchSmoke, FASTEST_ROUTE);
			if(fArchSmokeDis < 25.0)
			{
				float fOrigin[3] = { 741.996459, 202.342575, 190.538894 };
				float fVelocity[3] = { 290.778411, 297.195678, 521.740173 };
				float fLookAt[3] = { 1077.877197, 544.738891, 703.968750 };
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 9: //Graveyard Smoke
		{
			BotMoveTo(client, fGraveyardSmoke, FASTEST_ROUTE);
			if(fGraveyardSmokeDis < 25.0)
			{
				float fOrigin[3] = { 750.220031, 683.102600, 208.153045 };
				float fVelocity[3] = { 622.138061, -170.664520, 433.281555 };
				float fLookAt[3] = { 959.109985, 625.799987, 194.455810 };
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 10: //Library Smoke
		{
			BotMoveTo(client, fLibrarySmoke, FASTEST_ROUTE);
			if(fLibrarySmokeDis < 25.0)
			{
				float fOrigin[3] = { 747.903747, 67.559135, 214.205093 };
				float fVelocity[3] = { 487.465698, 336.380218, 558.485595 };
				float fLookAt[3] = { 959.841674, 213.808837, 269.541778 };
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}
			}
		}
	}
	
	switch(g_iPositionToHold[client])
	{
		case 1: //CT Position
		{
			if(!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if(fHoldSpotDis < 25.0)
				{
					float fLookAt[3] = { 921.785706, 2720.304443, 192.554459 };
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
			if(!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if(fHoldSpotDis < 25.0)
				{
					float fLookAt[3] = { 921.785706, 2720.304443, 192.554459 };
					float fBentLook[3], fEyePos[3];
					
					GetClientEyePosition(client, fEyePos);
					
					BotBendLineOfSight(client, fEyePos, fLookAt, fBentLook, 135.0);
					BotSetLookAt(client, "Use entity", fBentLook, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
				}
			}
		}
		case 3: //Bottom Banana Position
		{
			if(!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if(fHoldSpotDis < 25.0)
				{
					float fLookAt[3] = { 111.965370, 699.592651, 138.017456 };
					float fBentLook[3], fEyePos[3];
					
					GetClientEyePosition(client, fEyePos);
					
					BotBendLineOfSight(client, fEyePos, fLookAt, fBentLook, 135.0);
					BotSetLookAt(client, "Use entity", fBentLook, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
				}
			}
		}
		case 4: //Balcony Position
		{
			if(!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if(fHoldSpotDis < 25.0)
				{
					float fLookAt[3] = { 2252.379395, 149.045380, 193.250992 };
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