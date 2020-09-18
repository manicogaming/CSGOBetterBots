void LoadAPI()
{
	CreateNative("CS_SetWeaponSticker", Native_SetWeaponSticker);
	CreateNative("CS_SetAttributeValue", Native_SetAttributeValue);
	CreateNative("CS_GetRandomSticker", Native_GetRandomSticker);
}

public int Native_SetWeaponSticker(Handle plugins, int numParams)
{
	int client = GetNativeCell(1);
	if (!client || !IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index [%i]", client);
		return false;
	}
	
	int weapon = GetNativeCell(2);
	if (!IsValidEntity(weapon))
	{
		return false;
	}

	Address pWeapon = GetEntityAddress(weapon);
	if (pWeapon == Address_Null)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Invalid weapon address [%i]", weapon);
		return false;
	}

	int slot = GetNativeCell(3);
	if (slot < 0 || slot > 5)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Invalid sticker slot");
		return false;
	}

	int defIndex = GetNativeCell(4);
	if (defIndex == -1) // random
	{
		defIndex = GetRandomSticker();
	}

	Address pEconItemView = pWeapon + view_as<Address>(g_EconItemOffset);
	SetAttributeValue(client, pEconItemView, defIndex, "sticker slot %i id", slot);
	SetAttributeValue(client, pEconItemView, view_as<int>(GetNativeCell(5)), "sticker slot %i wear", slot);

	PTaH_ForceFullUpdate(client);
	return true;
}

public int Native_SetAttributeValue(Handle plugins, int numParams)
{
	int client = GetNativeCell(1);
	if (!client || !IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index [%i]", client);
		return false;
	}
	
	int weapon = GetNativeCell(2);
	if (!IsValidEntity(weapon))
	{
		return false;
	}

	Address pWeapon = GetEntityAddress(weapon);
	if (pWeapon == Address_Null)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Invalid weapon address [%i]", weapon);
		return false;
	}

	char attrname[128];
	
	GetNativeString(3, attrname, sizeof(attrname));

	int attrvalue = view_as<int>(GetNativeCell(4));

	Address pEconItemView = pWeapon + view_as<Address>(g_EconItemOffset);
	
	SetAttributeValue(client, pEconItemView, attrvalue, attrname);

	PTaH_ForceFullUpdate(client);
	return true;
}

public int Native_GetRandomSticker(Handle plugins, int numParams)
{
	return GetRandomSticker();
}