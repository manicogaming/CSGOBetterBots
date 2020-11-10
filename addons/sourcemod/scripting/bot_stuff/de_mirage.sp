public void DoMirageSmokes(int client)
{
	float fClientLocation[3];

	GetClientAbsOrigin(client, fClientLocation);

	//T Side Smokes
	float fCTSmoke[3] = { 1086.991821, -1017.052612, -258.250946 };
	float fStairsSmoke[3] = { 1147.428345, -1183.695313, -205.599060 };
	float fJungleSmoke[3] = { 815.810974, -1404.633789, -108.968750 };
	float fTopMidSmoke[3] = { 1422.968750, 70.759926, -112.902664 };
	float fMidShortSmoke[3] = { 1423.128906, -231.116898, -140.400681 };
	float fWindowSmoke[3] = { 1391.968750, -1012.190308, -167.968750 };
	float fBottomConSmoke[3] = { 1135.986816, 647.868591, -261.387939 };
	float fTopConSmoke[3] = { 1391.974731, -1051.666992, -167.968750 };
	float fShortLeftSmoke[3] = { -824.853577, 522.031250, -78.349075 };
	float fShortRightSmoke[3] = { -148.031250, 353.031250, -34.427696 };
	float fMarketDoorSmoke[3] = { -160.018127, 887.968750, -135.328125 };
	float fMarketWindowSmoke[3] = { -160.018127, 887.968750, -135.328125 };

	float fCTSmokeDis = GetVectorDistance(fClientLocation, fCTSmoke);
	float fStairsSmokeDis = GetVectorDistance(fClientLocation, fStairsSmoke);
	float fJungleSmokeDis = GetVectorDistance(fClientLocation, fJungleSmoke);
	float fTopMidSmokeDis = GetVectorDistance(fClientLocation, fTopMidSmoke);
	float fMidShortSmokeDis = GetVectorDistance(fClientLocation, fMidShortSmoke);
	float fWindowSmokeDis = GetVectorDistance(fClientLocation, fWindowSmoke);
	float fBottomConSmokeDis = GetVectorDistance(fClientLocation, fBottomConSmoke);
	float fTopConSmokeDis = GetVectorDistance(fClientLocation, fTopConSmoke);
	float fShotLeftSmokeDis = GetVectorDistance(fClientLocation, fShortLeftSmoke);
	float fShortRightSmokeDis = GetVectorDistance(fClientLocation, fShortRightSmoke);
	float fMarketDoorSmokeDis = GetVectorDistance(fClientLocation, fMarketDoorSmoke);
	float fMarketWindowSmokeDis = GetVectorDistance(fClientLocation, fMarketWindowSmoke);

	//T Side Flashes

	float fLampFlash[3] = { 871.768738, -1036.026489, -251.968750 };
	float fASiteFlash[3] = { 815.461670, -1497.127197, -108.968750 };
	float fMidFlash[3] = { 686.608215, 671.248047, -135.968750 };
	float fConnectorFlash[3] = { 360.075439, -691.968750, -162.496780 };
	float fBCarFlash[3] = { -161.022049, 571.791138, -69.669495 };
	float fBShortFlash[3] = { -736.012878, 623.968750, -75.968750 };
	float fBCornerFlash[3] = { -905.040466, 522.031250, -80.139946 };

	float fLampFlashDis = GetVectorDistance(fClientLocation, fLampFlash);
	float fMidFlashDis = GetVectorDistance(fClientLocation, fMidFlash);
	float fASiteFlashDis = GetVectorDistance(fClientLocation, fASiteFlash);
	float fConnectorFlashDis = GetVectorDistance(fClientLocation, fConnectorFlash);
	float fBCarFlashDis = GetVectorDistance(fClientLocation, fBCarFlash);
	float fBShortFlashDis = GetVectorDistance(fClientLocation, fBShortFlash);
	float fBCornerFlashDis = GetVectorDistance(fClientLocation, fBCornerFlash);

	switch(g_iSmoke[client])
	{
		case 1: //CT Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fCTSmoke, FASTEST_ROUTE);
				if(fCTSmokeDis < 25.0)
				{
					float fOrigin[3] = { 1062.656372, -1034.303344, -133.994354 };
					float fVelocity[3] = { -442.833282, -313.916076, 635.902832 };
					float fLookAt[3] = { -968.578002, -2475.483886, 1247.968750 };

					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);

					CreateTimer(7.0, Timer_ThrowSmoke, client);

					if(g_bCanThrowSmoke[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
						g_bHasThrownSmoke[client] = true;
					}
				}
			}
			else
			{
				BotMoveTo(client, fLampFlash, FASTEST_ROUTE);

				if(fLampFlashDis < 25.0)
				{
					float fOrigin[3] = { 846.057006, -1048.617797, -164.538711 };
					float fVelocity[3] = { -467.880340, -229.124023, 419.202911 };
					float fLookAt[3] = { -1101.290527, -2002.246459, 1247.968750 };

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
		case 2: //Stairs Smoke
		{
			BotMoveTo(client, fStairsSmoke, FASTEST_ROUTE);
			if(fStairsSmokeDis < 25.0)
			{
				float fOrigin[3] = { 1122.725341, -1190.267456, -114.875701 };
				float fVelocity[3] = { -449.523773, -119.596504, 479.131927 };
				float fLookAt[3] = { -381.378540, -1587.050903, 1247.968750 };

				CreateTimer(3.0, Timer_ThrowSmoke, client);

				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);

				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 3: //Jungle Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fJungleSmoke, FASTEST_ROUTE);
				if(fJungleSmokeDis < 25.0)
				{
					float fOrigin[3] = { 786.237731, -1409.484741, -23.414875 };
					float fVelocity[3] = { -540.984558, -82.985595, 385.062072 };
					float fLookAt[3] = { -1490.079833, -1764.229858, 1247.968750 };

					CreateTimer(1.5, Timer_ThrowSmoke, client);

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
					float fOrigin[3] = { 784.713562, -1499.222778, -24.482593 };
					float fVelocity[3] = { -559.527160, -38.136615, 365.632720 };
					float fLookAt[3] = { -1739.268310, -1671.254150, 1247.968750 };

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
		case 4: //Top-Mid Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fTopMidSmoke, FASTEST_ROUTE);
				if(fTopMidSmokeDis < 25.0)
				{
					float fOrigin[3] = { 1395.121459, 63.597442, -25.689208 };
					float fVelocity[3] = { -506.739288, -134.136840, 415.261779 };
					float fLookAt[3] = { -534.322998, -440.784057, 1247.968750 };

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
				BotMoveTo(client, fConnectorFlash, FASTEST_ROUTE);

				if(fConnectorFlashDis < 25.0)
				{
					float fOrigin[3] = { 325.308929, -695.885864, -86.328613 };
					float fVelocity[3] = { -632.651184, -71.279739, 214.269134 };
					float fLookAt[3] = { -673.912231, -807.603210, 89.318618 };

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
		case 5: //Mid-Short Smoke
		{
			BotMoveTo(client, fMidShortSmoke, FASTEST_ROUTE);
			if(fMidShortSmokeDis < 25.0)
			{
				float fOrigin[3] = { 1392.466430, -231.284988, -17.280963 };
				float fVelocity[3] = { -557.085876, 4.736944, 615.806396 };
				float fLookAt[3] = { 1026.031250, -228.226913, 129.468246 };

				CreateTimer(3.0, Timer_ThrowSmoke, client);

				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);

				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 6: //Window Smoke
		{
			BotMoveTo(client, fWindowSmoke, FASTEST_ROUTE);
			if(fWindowSmokeDis < 25.0)
			{
				float fOrigin[3] = { 1274.139526, -996.191772, -76.605072 };
				float fVelocity[3] = { -746.536376, 103.599502, 490.783843 };
				float fLookAt[3] = { -58.549804, -807.813232, 1247.968750 };

				CreateTimer(3.0, Timer_ThrowSmoke, client);

				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);

				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 7: //Bottom Con Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fBottomConSmoke, FASTEST_ROUTE);
				if(fBottomConSmokeDis < 25.0)
				{
					float fOrigin[3] = { 1114.211303, 629.887756, -135.189559 };
					float fVelocity[3] = { -395.924011, -329.148590, 671.177124 };
					float fLookAt[3] = { 869.895507, 426.846496, 36.145904 };

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
				BotMoveTo(client, fMidFlash, FASTEST_ROUTE);

				if(fMidFlashDis < 25.0)
				{
					float fOrigin[3] = { 552.326171, 556.816955, -26.138240 };
					float fVelocity[3] = { -735.888305, -627.101074, 373.389343 };
					float fLookAt[3] = { 215.999969, 271.140686, -50.784938 };

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
		case 8: //Top Con Smoke
		{
			BotMoveTo(client, fTopConSmoke, FASTEST_ROUTE);
			if(fTopConSmokeDis < 25.0)
			{
				float fOrigin[3] = { 1359.137817, -1055.348144, -44.989799 };
				float fVelocity[3] = { -577.226684, -63.052207, 614.102783 };
				float fLookAt[3] = { -1195.210327, -1349.580322, 1247.968627 };

				CreateTimer(3.0, Timer_ThrowSmoke, client);

				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);

				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 9: //Short-Left Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fShortLeftSmoke, FASTEST_ROUTE);
				if(fShotLeftSmokeDis < 25.0)
				{
					float fOrigin[3] = { -831.811828, 521.822814, 21.893959 };
					float fVelocity[3] = { -127.920066, -5.121991, 652.748229 };
					float fLookAt[3] = { -1101.803833, 510.950866, 1247.968750 };

					CreateTimer(1.5, Timer_ThrowSmoke, client);

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
				BotMoveTo(client, fBCornerFlash, FASTEST_ROUTE);

				if(fBCornerFlashDis < 25.0)
				{
					float fOrigin[3] = { -1107.965820, 644.296081, -5.499357 };
					float fVelocity[3] = { -816.253417, 491.802368, 183.356262 };
					float fLookAt[3] = { -1373.903564, 803.997192, 55.968750 };

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
		case 10: //Short-Right Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fShortRightSmoke, FASTEST_ROUTE);
				if(fShortRightSmokeDis < 25.0)
				{
					float fOrigin[3] = { -162.757492, 350.828277, 63.391471 };
					float fVelocity[3] = { -267.975524, -39.678741, 608.255371 };
					float fLookAt[3] = { -755.933654, 268.693511, 1247.968750 };

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
				BotMoveTo(client, fBCarFlash, FASTEST_ROUTE);

				if(fBCarFlashDis < 25.0)
				{
					float fOrigin[3] = { -353.906921, 570.741271, 37.888614 };
					float fVelocity[3] = { -918.088073, -4.998743, 519.744873 };
					float fLookAt[3] = { -942.028808, 567.538757, 230.933624 };

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
		case 11: //Market Door Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fMarketDoorSmoke, FASTEST_ROUTE);
				if(fMarketDoorSmokeDis < 25.0)
				{
					float fOrigin[3] = { -177.884231, 876.140869, -2.832973 };
					float fVelocity[3] = { -324.872985, -215.233276, 785.820922 };
					float fLookAt[3] = { -737.791992, 506.064849, 766.888061 };

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
				BotMoveTo(client, fBShortFlash, FASTEST_ROUTE);

				if(fBShortFlashDis < 25.0)
				{
					float fOrigin[3] = { -756.722534, 617.715454, 18.007228 };
					float fVelocity[3] = { -376.857208, -113.791618, 538.320251 };
					float fLookAt[3] = { -1752.971801, 316.899139, 1247.968750 };

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
		case 12: //Market Window Smoke
		{
			BotMoveTo(client, fMarketWindowSmoke, FASTEST_ROUTE);
			if(fMarketWindowSmokeDis < 25.0)
			{
				float fOrigin[3] = { -182.219451, 876.147033, -5.846139 };
				float fVelocity[3] = { -403.761627, -215.121276, 730.989990 };
				float fLookAt[3] = { -876.840881, 506.064788, 659.370727 };

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
		case 1: //Ramp Position
		{
			if(!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);

				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);

				if(fHoldSpotDis < 25.0)
				{
					float fLookAt[3] = { -63.982632, -1674.684204, -103.906189 };
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
			if(!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);

				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);

				if(fHoldSpotDis < 25.0)
				{
					float fLookAt[3] = { 164.354736, -2315.041016, 24.093811 };
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
			if(!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);

				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);

				if(fHoldSpotDis < 25.0)
				{
					float fLookAt[3] = { -1012.153503, 387.799988, -303.906189 };
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