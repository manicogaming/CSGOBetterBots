public void DoDust2Smokes(int client)
{
	float fClientLocation[3];

	GetClientAbsOrigin(client, fClientLocation);

	//T Side Smokes
	float fBDoorsSmoke[3] = { -2185.968750, 1059.031250, 39.799171 };
	float fBPlatSmoke[3] = { -2168.989990, 1042.031250, 40.191010 };
	float fBWindowSmoke[3] = { -2054.375977, 1042.031250, 39.598633 };
	float fMidToBSmoke[3] = { -275.031250, 1345.382568, -122.631432 };
	float fMidToBBoxSmoke[3] = { -275.031250, 1345.633301, -120.613678 };
	float fXBOXSmoke[3] = { -299.968750, -1163.974243, 77.698128 };
	float fShortASmoke[3] = { 489.995728, 1446.031250, 0.553116 };
	float fShortBoostSmoke[3] = { 489.995789, 1943.968750, 96.031250 };
	float fASiteSmoke[3] = { 273.018829, 1650.439819, 26.153511 };
	float fLongCornerSmoke[3] = { 487.991608, -363.999390, 9.031250 };
	float fACrossSmoke[3] = { 860.031250, 790.031250, 4.314228 };
	float fCTSmoke[3] = { 516.031250, 983.891907, 1.477413 };

	float fBDoorsSmokeDis = GetVectorDistance(fClientLocation, fBDoorsSmoke);
	float fBPlatSmokeDis = GetVectorDistance(fClientLocation, fBPlatSmoke);
	float fBWindowSmokeDis = GetVectorDistance(fClientLocation, fBWindowSmoke);
	float fMidToBSmokeDis = GetVectorDistance(fClientLocation, fMidToBSmoke);
	float fMidToBBoxSmokeDis = GetVectorDistance(fClientLocation, fMidToBBoxSmoke);
	float fXBOXSmokeDis = GetVectorDistance(fClientLocation, fXBOXSmoke);
	float fShortASmokeDis = GetVectorDistance(fClientLocation, fShortASmoke);
	float fShortBoostSmokeDis = GetVectorDistance(fClientLocation, fShortBoostSmoke);
	float fASiteSmokeDis = GetVectorDistance(fClientLocation, fASiteSmoke);
	float fLongCornerSmokeDis = GetVectorDistance(fClientLocation, fLongCornerSmoke);
	float fACrossSmokeDis = GetVectorDistance(fClientLocation, fACrossSmoke);
	float fCTSmokeDis = GetVectorDistance(fClientLocation, fCTSmoke);
	
	//T Side Flashes
	
	float fBSiteFlash[3] = { -1832.914917, 1224.700439, 32.116920 };
	float fBPopFlash[3] = { -1923.962769, 1244.391357, 31.543159 };
	float fMidToBPopFlash[3] = { -275.031250, 1345.370117, -122.732834 };
	float fASiteFlash[3] = { 489.968750, 1886.926636, 96.759674 };
	float fLongFlash[3] = { 363.996399, -383.321991, 6.365173 };
	
	float fBSiteFlashDis = GetVectorDistance(fClientLocation, fBSiteFlash);
	float fBPopFlashDis = GetVectorDistance(fClientLocation, fBPopFlash);
	float fMidToBPopFlashDis = GetVectorDistance(fClientLocation, fMidToBPopFlash);
	float fASiteFlashDis = GetVectorDistance(fClientLocation, fASiteFlash);
	float fLongFlashDis = GetVectorDistance(fClientLocation, fLongFlash);
	
	switch(g_iSmoke[client])
	{
		case 1: //B Doors Smoke
		{
			BotMoveTo(client, fBDoorsSmoke, FASTEST_ROUTE);
			if(fBDoorsSmokeDis < 25.0)
			{
				float fOrigin[3] = { -2173.929443, 1075.293701, 134.734024 };
				float fVelocity[3] = { 219.085433, 295.929992, 555.731384 };
				float fLookAt[3] = { -2047.082763, 1246.631835, 411.427185 };
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}				
			}
		}
		case 2: //B Plat Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fBPlatSmoke, FASTEST_ROUTE);
				if(fBPlatSmokeDis < 25.0)
				{
					float fOrigin[3] = { -2166.843505, 1058.850219, 137.026596 };
					float fVelocity[3] = { 39.056030, 306.057525, 590.356933 };
					float fLookAt[3] = { -2097.739257, 1600.379150, 1055.968627 };
					
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
					float fOrigin[3] = { -1950.988403, 1393.770385, 106.644531 };
					float fVelocity[3] = { -166.773712, 921.804016, 230.978759 };
					float fLookAt[3] = { -2188.969726, 2712.631835, 418.597137 };
					
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
		case 3: //B Window Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fBWindowSmoke, FASTEST_ROUTE);
				if(fBWindowSmokeDis < 25.0)
				{
					float fOrigin[3] = { -2154.974365, 1070.799804, 144.198379 };
					float fVelocity[3] = { 254.659484, 523.506591, 584.126586 };
					float fLookAt[3] = { -1993.429443, 1404.036376, 274.870574 };
					
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
					float fOrigin[3] = { -1849.123291, 1252.855957, 95.863258 };
					float fVelocity[3] = { -294.947082, 512.348876, 315.775756 };
					float fLookAt[3] = { -2033.325439, 1572.494140, 251.417327 };
					
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
		case 4: //Mid to B Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fMidToBSmoke, FASTEST_ROUTE);
				if(fMidToBSmokeDis < 25.0)
				{
					float fOrigin[3] = { -293.207489, 1366.096801, -33.958496 };
					float fVelocity[3] = { -330.755065, 376.941253, 441.820037 };
					float fLookAt[3] = { -592.000000, 1705.104980, 287.539215 };
					
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
				BotMoveTo(client, fMidToBPopFlash, FASTEST_ROUTE);
					
				if(fMidToBPopFlashDis < 25.0)
				{
					float fOrigin[3] = { -261.502349, 1368.830200, -33.540878 };
					float fVelocity[3] = { 246.186660, 426.909759, 451.264770 };
					float fLookAt[3] = { -255.983062, 1378.312255, -29.524148 };
					
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
		case 5: //Mid to B Box Smoke
		{
			BotMoveTo(client, fMidToBBoxSmoke, FASTEST_ROUTE);
			if(fMidToBBoxSmokeDis < 25.0)
			{
				float fOrigin[3] = { -297.029571, 1373.973510, -8.979913 };
				float fVelocity[3] = { -400.306671, 515.712158, 406.203491 };
				float fLookAt[3] = { -297.873901, 1375.061157, -53.067520 };
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownSmoke[client] = true;
				}				
			}
		}
		case 6: //XBOX Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fXBOXSmoke, FASTEST_ROUTE);
				if(fXBOXSmokeDis < 25.0)
				{
					float fOrigin[3] = { -299.978637, -1131.513061, 197.856338 };
					float fVelocity[3] = { -0.179589, 590.701232, 561.324279 };
					float fLookAt[3] = { -308.900268, 297.964477, 711.968750 };
					
					CreateTimer(1.0, Timer_ThrowSmoke, client);
					
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
					float fOrigin[3] = { 476.668670, 1919.604370, 172.058532 };
					float fVelocity[3] = { -242.023056, 594.641418, 198.449981 };
					float fLookAt[3] = { 255.999984, 2461.778808, 258.907592 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(0.5, Timer_ThrowFlash, client);
					
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
			BotMoveTo(client, fShortASmoke, FASTEST_ROUTE);
			if(fShortASmokeDis < 25.0)
			{
				float fOrigin[3] = { 491.129272, 1481.866210, 73.910873 };
				float fVelocity[3] = { 20.627548, 652.093811, 163.127685 };
				float fLookAt[3] = { 499.854309, 1766.076904, 95.390281 };
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}				
			}
		}
		case 8: //Short-Boost Smoke
		{
			BotMoveTo(client, fShortBoostSmoke, FASTEST_ROUTE);
			if(fShortBoostSmokeDis < 25.0)
			{
				float fOrigin[3] = { 494.089050, 1972.633056, 142.517364 };
				float fVelocity[3] = { 60.845504, 423.293975, 88.089668 };
				float fLookAt[3] = { 600.057556, 2711.972656, 204.540893 };
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}				
			}
		}
		case 9: //A Site Smoke
		{
			BotMoveTo(client, fASiteSmoke, FASTEST_ROUTE);
			if(fASiteSmokeDis < 25.0)
			{
				float fOrigin[3] = { 285.125366, 1662.108886, 105.060981 };
				float fVelocity[3] = { 220.304000, 212.345291, 591.664916 };
				float fLookAt[3] = { 679.261413, 2042.006347, 1055.968750 };
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}				
			}
		}
		case 10: //Long Corner Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fLongCornerSmoke, FASTEST_ROUTE);
				if(fLongCornerSmokeDis < 25.0)
				{
					float fOrigin[3] = { 499.140136, -342.580871, 101.033569 };
					float fVelocity[3] = { 202.870849, 389.755371, 502.405334 };
					float fLookAt[3] = { 788.981933, 217.204040, 711.968750 };
					
					CreateTimer(1.0, Timer_ThrowSmoke, client);
					
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
				BotMoveTo(client, fLongFlash, FASTEST_ROUTE);
					
				if(fLongFlashDis < 25.0)
				{
					float fOrigin[3] = { 387.518829, -356.528503, 118.807830 };
					float fVelocity[3] = { 428.041076, 487.564605, 420.922576 };
					float fLookAt[3] = { 771.587707, 80.362823, 141.908721 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(0.8, Timer_ThrowFlash, client);
					
					if(g_bCanThrowFlash[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						g_bHasThrownNade[client] = true;
					}
				}
			}
		}
		case 11: //A Cross Smoke
		{
			BotMoveTo(client, fACrossSmoke, FASTEST_ROUTE);
			if(fACrossSmokeDis < 25.0)
			{
				float fOrigin[3] = { 997.804809, 921.088378, 85.138679 };
				float fVelocity[3] = { 625.270690, 596.416015, 370.031616 };
				float fLookAt[3] = { 1734.690307, 1623.968750, 691.947387 };
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}				
			}
		}
		case 12: //CT Smoke
		{
			BotMoveTo(client, fCTSmoke, FASTEST_ROUTE);
			if(fCTSmokeDis < 25.0)
			{
				float fOrigin[3] = { 516.424987, 1004.355773, 96.256927 };
				float fVelocity[3] = { 7.165000, 372.383453, 552.942443 };
				float fLookAt[3] = { 525.635009, 1483.022705, 711.968750 };
				
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