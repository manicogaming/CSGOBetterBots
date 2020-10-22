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
	
	//T Side Molotovs
	
	float fQuadMolotov[3] = { 479.274414, 2017.968750, 128.409363 };
	float fFirstBoxMolotov[3] = { 409.326080, 2009.151367, 128.031250 };
	float fSecondBoxMolotov[3] = { 409.326080, 2009.151367, 128.031250 };
	float fPitMolotov[3] = { 1841.031250, -160.031250, 256.031250 };
	
	float fQuadMolotovDis = GetVectorDistance(fClientLocation, fQuadMolotov);
	float fFirstBoxMolotovDis = GetVectorDistance(fClientLocation, fFirstBoxMolotov);
	float fSecondBoxMolotovDis = GetVectorDistance(fClientLocation, fSecondBoxMolotov);
	float fPitMolotovDis = GetVectorDistance(fClientLocation, fPitMolotov);
	
	//T Side Flashes
	
	float fCTFlash[3] = { 194.896042, 1737.721069, 122.031250 };
	float fBSiteFlash[3] = { 460.446747, 1828.490723, 136.114029 };
	float fPitFlash[3] = { 1155.149902, 589.968750, 122.031250 };
	float fBalconyFlash[3] = { 1511.952637, -365.968750, 256.031250 };
	float fASiteFlash[3] = { 970.794312, 434.021057, 88.949677 };
	
	float fCTFlashDis = GetVectorDistance(fClientLocation, fCTFlash);
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
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 126.242744;
					fOrigin[1] = 1594.645996;
					fOrigin[2] = 218.488510;
					
					fVelocity[0] = 280.251098;
					fVelocity[1] = 455.511444;
					fVelocity[2] = 401.817474;
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					TF2_LookAtPos(client, fOrigin, 0.40);
					
					if(g_bCanThrowSmoke[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
						g_bHasThrownSmoke[client] = true;
					}
				}
			}
			else
			{
				BotMoveTo(client, fCTFlash, FASTEST_ROUTE);
					
				if(fCTFlashDis < 25.0)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 232.221496;
					fOrigin[1] = 1771.950439;
					fOrigin[2] = 206.091247;
					
					fVelocity[0] = 510.910461;
					fVelocity[1] = 451.589202;
					fVelocity[2] = 357.878143;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
					CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
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
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 123.908531;
					fOrigin[1] = 1608.801513;
					fOrigin[2] = 208.180404;
					
					fVelocity[0] = 80.479454;
					fVelocity[1] = 398.531372;
					fVelocity[2] = 528.814270;

					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					TF2_LookAtPos(client, fOrigin, 0.40);
						
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
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 502.760955;
					fOrigin[1] = 1877.219116;
					fOrigin[2] = 211.888961;
					
					fVelocity[0] = 518.502197;
					fVelocity[1] = 597.576538;
					fVelocity[2] = 270.139526;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
					CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 3: //Long A Smoke
		{
			BotMoveTo(client, fLongASmoke, FASTEST_ROUTE);
			if(fLongASmokeDis < 25.0)
			{
				float fVelocity[3], fOrigin[3];
				
				fOrigin[0] = 748.566589;
				fOrigin[1] = 268.015136;
				fOrigin[2] = 177.583160;
				
				fVelocity[0] = 410.540039;
				fVelocity[1] = 353.701324;
				fVelocity[2] = 392.463989;

				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				TF2_LookAtPos(client, fOrigin, 0.40);
					
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
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 966.898254;
					fOrigin[1] = 435.972778;
					fOrigin[2] = 178.775451;
					
					fVelocity[0] = 453.395233;
					fVelocity[1] = 104.332847;
					fVelocity[2] = 479.052581;

					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					TF2_LookAtPos(client, fOrigin, 0.40);
					
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
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 1246.527587;
					fOrigin[1] = 503.508178;
					fOrigin[2] = 240.461380;
					
					fVelocity[0] = 639.973205;
					fVelocity[1] = -519.588073;
					fVelocity[2] = 649.552429;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
					CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 5: //Pit Smoke
		{
			BotMoveTo(client, fPitSmoke, FASTEST_ROUTE);
			if(fPitSmokeDis < 25.0)
			{
				float fVelocity[3], fOrigin[3];
				
				fOrigin[0] = 514.735900;
				fOrigin[1] = -263.404022;
				fOrigin[2] = 180.432846;
				
				fVelocity[0] = 422.690643;
				fVelocity[1] = 83.064659;
				fVelocity[2] = 509.670959;

				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				TF2_LookAtPos(client, fOrigin, 0.40);
					
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
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 1589.689697;
					fOrigin[1] = -296.319335;
					fOrigin[2] = 331.451446;
					
					fVelocity[0] = 496.743469;
					fVelocity[1] = -405.579101;
					fVelocity[2] = 200.657302;

					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
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
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 1538.285522;
					fOrigin[1] = -377.717254;
					fOrigin[2] = 324.803131;
					
					fVelocity[0] = 485.635070;
					fVelocity[1] = -213.789443;
					fVelocity[2] = 407.226135;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
					CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
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
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 571.783935;
					fOrigin[1] = 689.233459;
					fOrigin[2] = 168.702438;
					
					fVelocity[0] = 614.202392;
					fVelocity[1] = -195.350540;
					fVelocity[2] = 190.545516;

					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					TF2_LookAtPos(client, fOrigin, 0.40);
					
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
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 1289.101684;
					fOrigin[1] = 485.080993;
					fOrigin[2] = 247.019332;
					
					fVelocity[0] = 729.877929;
					fVelocity[1] = 116.153884;
					fVelocity[2] = 752.654418;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
					CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 8: //Arch Smoke
		{
			BotMoveTo(client, fArchSmoke, FASTEST_ROUTE);
			if(fArchSmokeDis < 25.0)
			{
				float fVelocity[3], fOrigin[3];
				
				fOrigin[0] = 748.447692;
				fOrigin[1] = 209.271453;
				fOrigin[2] = 217.875152;
				
				fVelocity[0] = 408.306976;
				fVelocity[1] = 423.423950;
				fVelocity[2] = 565.772216;
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				TF2_LookAtPos(client, fOrigin, 0.40);
					
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
				float fVelocity[3], fOrigin[3];
				
				fOrigin[0] = 749.527038;
				fOrigin[1] = 682.661010;
				fOrigin[2] = 209.790649;
				
				fVelocity[0] = 609.527587;
				fVelocity[1] = -178.700210;
				fVelocity[2] = 463.080993;
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				TF2_LookAtPos(client, fOrigin, 0.40);
					
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
				float fVelocity[3], fOrigin[3];
				
				fOrigin[0] = 747.903747;
				fOrigin[1] = 67.559135;
				fOrigin[2] = 214.205093;
				
				fVelocity[0] = 487.465698;
				fVelocity[1] = 336.380218;
				fVelocity[2] = 558.485595;
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				TF2_LookAtPos(client, fOrigin, 0.40);
					
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
		case 1: //Quad Molotov
		{
			BotMoveTo(client, fQuadMolotov, FASTEST_ROUTE);
			if(fQuadMolotovDis < 25.0)
			{
				float fVelocity[3], fOrigin[3];
				
				fOrigin[0] = 465.565948;
				fOrigin[1] = 2039.379638;
				fOrigin[2] = 257.628387;
				
				fVelocity[0] = -249.454605;
				fVelocity[1] = 389.615020;
				fVelocity[2] = 726.204895;
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				TF2_LookAtPos(client, fOrigin, 0.40);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("molotov"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 2: //First Box Molotov
		{
			BotMoveTo(client, fFirstBoxMolotov, FASTEST_ROUTE);
			if(fFirstBoxMolotovDis < 25.0)
			{
				float fVelocity[3], fOrigin[3];
				
				fOrigin[0] = 414.437194;
				fOrigin[1] = 2032.446166;
				fOrigin[2] = 258.654602;
				
				fVelocity[0] = 93.188972;
				fVelocity[1] = 423.755950;
				fVelocity[2] = 751.759277;
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				TF2_LookAtPos(client, fOrigin, 0.40);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("molotov"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 3: //Second Box Molotov
		{
			BotMoveTo(client, fSecondBoxMolotov, FASTEST_ROUTE);
			if(fSecondBoxMolotovDis < 25.0)
			{
				float fVelocity[3], fOrigin[3];
				
				fOrigin[0] = 393.667388;
				fOrigin[1] = 2036.708984;
				fOrigin[2] = 249.528472;
				
				fVelocity[0] = -284.762115;
				fVelocity[1] = 501.325134;
				fVelocity[2] = 585.690124;
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				TF2_LookAtPos(client, fOrigin, 0.40);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("molotov"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 4: //Pit Molotov
		{
			BotMoveTo(client, fPitMolotov, FASTEST_ROUTE);
			if(fPitMolotovDis < 25.0)
			{
				float fVelocity[3], fOrigin[3];
				
				fOrigin[0] = 1892.494628;
				fOrigin[1] = -161.390838;
				fOrigin[2] = 323.485076;
				
				fVelocity[0] = 775.491088;
				fVelocity[1] = -20.896572;
				fVelocity[2] = 55.693138;
				
				CreateTimer(0.2, Timer_ThrowSmoke, client);
				
				TF2_LookAtPos(client, fOrigin, 0.40);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("molotov"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}
			}
		}
	}
}