#if defined _modelch_included
    #endinput
#endif
#define _modelch_included

public Extension __ext_modelch = {
	name = "modelch",
	file = "modelch.ext",
#if defined AUTOLOAD_EXTENSIONS
	autoload = 1,
#else
	autoload = 0,
#endif
#if defined REQUIRE_EXTENSIONS
	required = 1,
#else
	required = 0,
#endif
};

// return:
// Plugin_Continue - has no effect
// Plugin_Changed - uses the specified parameters for inventory model
// Plugin_Handled & Plugin_Stop - force to use common model insted inventory model
forward Action MdlCh_PlayerSpawn(int client, bool custom, char[] model, int model_maxlen, char[] vo_prefix, int prefix_maxlen);
