#if defined _navmesh_included
 #endinput
#endif
#define _navmesh_included

#define HalfHumanHeight 35.5
#define StepHeight 18.0

#define NAV_MAGIC_NUMBER 0xFEEDFACE

#define WALK_THRU_PROP_DOORS		0x01
#define WALK_THRU_FUNC_DOORS		0x02
#define WALK_THRU_DOORS 			(WALK_THRU_PROP_DOORS | WALK_THRU_FUNC_DOORS)
#define WALK_THRU_BREAKABLES		0x04
#define WALK_THRU_TOGGLE_BRUSHES	0x08
#define WALK_THRU_EVERYTHING		(WALK_THRU_DOORS | WALK_THRU_BREAKABLES | WALK_THRU_TOGGLE_BRUSHES)

enum 
{
	NAV_DIR_NORTH = 0,
	NAV_DIR_EAST,
	NAV_DIR_SOUTH,
	NAV_DIR_WEST,
	NAV_DIR_COUNT
};

enum
{
	NAV_LADDER_DIR_UP = 0,
	NAV_LADDER_DIR_DOWN,
	NAV_LADDER_DIR_COUNT
};

enum
{
	NAV_MESH_CROUCH = 0x0001, 
	NAV_MESH_JUMP = 0x0002, 
	NAV_MESH_PRECISE = 0x0004, 
	NAV_MESH_NO_JUMP = 0x0008, 
	NAV_MESH_STOP = 0x0010, 
	NAV_MESH_RUN = 0x0020, 
	NAV_MESH_WALK = 0x0040, 
	NAV_MESH_AVOID = 0x0080, 
	NAV_MESH_TRANSIENT = 0x0100, 
	NAV_MESH_DONT_HIDE = 0x0200, 
	NAV_MESH_STAND = 0x0400, 
	NAV_MESH_NO_HOSTAGES = 0x0800
};

enum
{
	GO_NORTH = 0,
	GO_EAST,
	GO_SOUTH,
	GO_WEST,
	GO_LADDER_UP,
	GO_LADDER_DOWN,
	GO_JUMP,
	NUM_TRAVERSE_TYPES
};

enum NavCornerType
{
	NAV_CORNER_NORTH_WEST = 0,
	NAV_CORNER_NORTH_EAST,
	NAV_CORNER_SOUTH_EAST,
	NAV_CORNER_SOUTH_WEST,
	NAV_CORNER_COUNT
};

const CNavArea INVALID_NAV_AREA = view_as<CNavArea>(-1);
const CNavLadder INVALID_NAV_LADDER = view_as<CNavLadder>(-1);
const HidingSpot INVALID_NAV_HIDING_SPOT = view_as<HidingSpot>(-1);

typedef NavPathCostFunctor = function int(CNavArea area, CNavArea from, CNavLadder ladder, any data);


// NavMesh

/**
 * Called when the plugin finishes loading the navigation mesh, even if it fails. Called within the
 * OnMapStart() forward.
 * 
 * @param success		true if sucessful, false otherwise.
 */
forward void OnNavMeshLoaded(bool success);

native bool NavMesh_Exists();

native int NavMesh_GetMagicNumber();

native int NavMesh_GetVersion();

native int NavMesh_GetSubVersion();

native int NavMesh_GetSaveBSPSize();

native bool NavMesh_IsAnalyzed();

native bool NavMesh_GetGroundHeight(const float pos[3], float &height=-1.0, float normal[3]=NULL_VECTOR);

native CNavArea NavMesh_FindAreaByID( int areaID );

native CNavArea NavMesh_GetArea(const float pos[3], float beneathLimit=120.0);

native CNavArea NavMesh_GetNearestArea(const float pos[3], bool anyZ=false, float maxDist=10000.0, bool checkLOS=false, bool checkGround=true, int team=-2);

native HidingSpot NavMesh_FindHidingSpotByID(int hidingSpotID);

native HidingSpot NavMesh_GetRandomHidingSpot();

// These grid functions are more internal than anything.
native int NavMesh_WorldToGridX(float wx);

native int NavMesh_WorldToGridY(float wy);

native void NavMesh_GetAreasOnGrid(ArrayStack hStack, int x, int y);

native int NavMesh_GetGridSizeX();

native int NavMesh_GetGridSizeY();


native void NavMesh_CollectSurroundingAreas(ArrayStack hStack, CNavArea startArea, float travelDistLimit=1500.0, float maxStepUpLimit=StepHeight, float maxDropDownLimit=100.0);

native bool NavMesh_BuildPath(CNavArea startArea, CNavArea goalArea, const float goalPos[3], NavPathCostFunctor costFunctor, any costData=0, CNavArea &closestArea=INVALID_NAV_AREA, float maxPathLength=0.0, float flMaxStepSize=0.0);

enum CNavMesh
{
	TheNavMesh
}

methodmap CNavMesh
{
}

// CNavArea

native int NavMeshArea_GetID(int areaIndex);

native int NavMeshArea_GetFlags(int areaIndex);

native void NavMeshArea_GetPlace(int areaIndex, char[] buffer, int maxlen);

native bool NavMeshArea_GetCenter(int areaIndex, float buffer[3]);

native void NavMeshArea_GetAdjacentList(ArrayStack buffer, int areaIndex, int dir);

native void NavMeshArea_GetLadderList(ArrayStack buffer, int areaIndex, int dir);

native void NavMeshArea_GetHidingSpots(ArrayStack buffer, int areaIndex);

native void NavMeshArea_GetClosestPointOnArea(int areaIndex, const float pos[3], float closePos[3]);

native int NavMeshArea_GetTotalCost(int areaIndex);

native int NavMeshArea_GetCostSoFar(int areaIndex);

native int NavMeshArea_GetParent(int areaIndex);

native int NavMeshArea_GetParentHow(int areaIndex);

native void NavMeshArea_SetParent(int areaIndex, int parentAreaIndex);

native void NavMeshArea_SetParentHow(int areaIndex, int parentHow);

native bool NavMeshArea_GetExtentLow(int areaIndex, float buffer[3]);

native bool NavMeshArea_GetExtentHigh(int areaIndex, float buffer[3]);

native bool NavMeshArea_IsOverlappingPoint(int areaIndex, const float pos[3], float tolerance);

native bool NavMeshArea_IsOverlappingArea(int areaIndex, int targetAreaIndex);

native float NavMeshArea_GetNECornerZ(int areaIndex);

native float NavMeshArea_GetSWCornerZ(int areaIndex);

native void NavMeshArea_GetCorner(int areaIndex, NavCornerType corner, float buffer[3]);

native float NavMeshArea_GetZ(int areaIndex, const float pos[3]);

native float NavMeshArea_GetZFromXAndY(int areaIndex, float x, float y);

native bool NavMeshArea_IsEdge(int areaIndex, int dir);

native bool NavMeshArea_Contains(int areaIndex, const float pos[3]);

native void NavMeshArea_GetRandomPoint(int areaIndex, float buffer[3]);

native bool NavMeshArea_IsConnected(int areaIndex, int targetAreaIndex, int dir);

native bool NavMeshArea_ComputePortal(int areaIndex, int areaToIndex, int dir, float center[3], float &halfWidth);

native bool NavMeshArea_ComputeClosestPointInPortal(int areaIndex, int areaToIndex, int dir, const float fromPos[3], float closePos[3]);

native int NavMeshArea_ComputeDirection(int areaIndex, const float pos[3]);

native float NavMeshArea_GetLightIntensity(int areaIndex, const float pos[3]);

methodmap CNavArea
{
	public CNavArea( int index )
	{
		return view_as<CNavArea>(index);
	}
	
	property int Index
	{
		public get() { return view_as<int>(this); }
	}
	
	property int ID
	{
		public get() { return NavMeshArea_GetID(this.Index); }
	}
	
	property int Attributes
	{
		public get() { return NavMeshArea_GetFlags(this.Index); }
	}
	
	property CNavArea Parent
	{
		public get() { return CNavArea(NavMeshArea_GetParent(this.Index)); }
		public set( CNavArea area ) { NavMeshArea_SetParent(this.Index, area.Index); }
	}
	
	property int ParentHow
	{
		public get() { return NavMeshArea_GetParentHow(this.Index); }
		public set( int how ) { NavMeshArea_SetParentHow(this.Index, how); }
	}
	
	property int TotalCost
	{
		public get() { return NavMeshArea_GetTotalCost(this.Index); }
	}
	
	property int CostSoFar
	{
		public get() { return NavMeshArea_GetCostSoFar(this.Index); }
	}
	
	property float NECornerZ
	{
		public get() { return NavMeshArea_GetNECornerZ(this.Index); }
	}
	
	property float SWCornerZ
	{
		public get() { return NavMeshArea_GetSWCornerZ(this.Index); }
	}
	
	public void GetPlace( char[] buffer, int maxlen )
	{
		NavMeshArea_GetPlace(this.Index, buffer, maxlen);
	}
	
	public bool GetCenter( float buffer[3] )
	{
		return NavMeshArea_GetCenter(this.Index, buffer);
	}
	
	public bool GetExtentLow( float buffer[3] )
	{
		return NavMeshArea_GetExtentLow(this.Index, buffer);
	}
	
	public bool GetExtentHigh( float buffer[3] )
	{
		return NavMeshArea_GetExtentHigh(this.Index, buffer);
	}
	
	public void GetCorner( NavCornerType corner, float buffer[3] )
	{
		NavMeshArea_GetCorner( this.Index, corner, buffer );
	}
	
	public float GetZ( const float point[3] )
	{
		return NavMeshArea_GetZ(this.Index, point);
	}
	
	public float GetZFromXAndY( float x, float y )
	{
		return NavMeshArea_GetZFromXAndY(this.Index, x, y);
	}
	
	/**
	 * Returns whether or not the area overlaps the given point. The Z-axis is not checked.
	 *
	 * @param	point		The point to check.
	 * @param	tolerance	How many units the point can be away from the edge of the area.
	 * @return				true if overlapping, false otherwise.
	 */
	public bool IsOverlappingPoint( const float point[3], float tolerance=0.0 )
	{
		return NavMeshArea_IsOverlappingPoint(this.Index, point, tolerance);
	}
	
	/**
	 * Returns whether or not the area overlaps the given area. The Z-axis is not checked.
	 *
	 * @param	area	The area to check.
	 * @return			true if overlapping, false otherwise.
	 */
	public bool IsOverlappingArea( CNavArea area )
	{
		return NavMeshArea_IsOverlappingArea(this.Index, area.Index);
	}
	
	/**
	 * Returns whether or not the given point is contained by the area.
	 *
	 * Note: If the point overlaps the area, the given point can be at most StepHeight units above the 
	 * area to still be considered "contained".
	 *
	 * @param	point	The point to check.
	 * @return			true if the point is contained by the area, false otherwise.
	 */
	public bool Contains( const float point[3] )
	{
		return NavMeshArea_Contains(this.Index, point);
	}
	
	/**
	 * Returns whether or not if there are no bi-directional links in the given direction of the area.
	 * 
	 * Note: For the longest time this only checked for presence of an outgoing connection, regardless
	 * if the connection was two-way or not. This has been recently changed to properly reflect
	 * CNavArea::IsEdge( NavDirType dir )'s functionality.
	 *
	 * @param	dir		Direction to check.
	 * @return			true if there are no bi-directional connections; false otherwise.
	 */
	public bool IsEdge( int dir )
	{
		return NavMeshArea_IsEdge(this.Index, dir);
	}
	
	public void GetRandomPoint( float buffer[3] )
	{
		NavMeshArea_GetRandomPoint(this.Index, buffer);
	}
	
	/**
	 * Returns whether or not there exists a bi-directional/outgoing one-way link to targetArea in
	 * the provided direction.
	 *
	 * @param	targetArea	The area to check for.
	 * @param	dir			The direction to check. If NAV_DIR_COUNT is the direction, all directions will be checked.
	 * @return				true if there exists a link, false otherwise.
	 */
	public bool IsConnected( CNavArea targetArea, int dir )
	{
		return NavMeshArea_IsConnected(this.Index, targetArea.Index, dir);
	}
	
	public void GetClosestPointOnArea( const float pos[3], float buffer[3] )
	{
		NavMeshArea_GetClosestPointOnArea(this.Index, pos, buffer);
	}
	
	/**
	 * Retrieves all bi-directional and one-way OUTGOING connections from this area and stores CNavArea's in the
	 * provided buffer.
	 *
	 * Note: This does NOT include one-way INCOMING connections. Use GetIncomingConnections() for that.
	 *
	 * @param	dir		Direction to check.
	 * @param	buffer	An ArrayStack to insert the CNavArea's in.
	 * @deprecated		Use CNavArea.GetAdjacentList() instead.
	 */
	#pragma deprecated Use CNavArea.GetAdjacentList() instead.
	public void GetAdjacentAreas( int dir, ArrayStack buffer )
	{
		NavMeshArea_GetAdjacentList( buffer, this.Index, dir );
	}

	/**
	 * Retrieves all bi-directional and one-way OUTGOING connections from this area and stores CNavArea's in the
	 * provided buffer.
	 *
	 * Note: This does NOT include one-way INCOMING connections. Use GetIncomingConnections() for that.
	 *
	 * @param	dir		Direction to check. If NAV_DIR_COUNT is the direction, all directions will be checked.
	 * @param	buffer	An ArrayList to insert the CNavArea's in.
	 */
	public native void GetAdjacentList( int dir, ArrayList buffer );
	
	public CNavArea GetRandomAdjacentArea( int dir )
	{
		ArrayList list = new ArrayList();
		this.GetAdjacentList(dir, list);
		CNavArea area = list.Length > 0 ? CNavArea( list.Get( GetRandomInt(0, list.Length - 1) ) ) : INVALID_NAV_AREA;
		delete list;
		return area;
	}

	/**
	 * Returns the amount of bi-directional and one-way OUTGOING connections from this area in the provided
	 * direction.
	 *
	 * Note: This does NOT count one-way INCOMING connections.
	 *
	 * @param	dir		Direction to check. If NAV_DIR_COUNT is the direction, all directions will be checked.
	 * @return			The amount of connections.
	 */
	public int GetAdjacentCount( int dir )
	{
		int count = 0;
		ArrayList list = new ArrayList();
		this.GetAdjacentList(dir, list);
		count = list.Length;
		delete list;
		return count;
	}

	/**
	 * Retrieves all one-way INCOMING connections to this area and stores CNavArea's in the provided
	 * buffer.
	 *
	 * @param	dir		Direction to check. If NAV_DIR_COUNT is the direction, all directions will be checked.
	 * @param	buffer	An ArrayList to insert the CNavArea's in.
	 */
	public native void GetIncomingConnections( int dir, ArrayList buffer );
	
	public void GetLadders( int dir, ArrayStack buffer )
	{
		NavMeshArea_GetLadderList( buffer, this.Index, dir );
	}
	
	public void GetHidingSpots( ArrayStack buffer )
	{
		NavMeshArea_GetHidingSpots( buffer, this.Index );
	}
	
	public void ComputePortal( CNavArea to, int dir, float center[3], float &halfWidth )
	{
		NavMeshArea_ComputePortal(this.Index, to.Index, dir, center, halfWidth);
	}
	
	public void ComputeClosestPointInPortal( CNavArea to, int dir, const float fromPos[3], float closePos[3] )
	{
		NavMeshArea_ComputeClosestPointInPortal(this.Index, to.Index, dir, fromPos, closePos);
	}
	
	public int ComputeDirection( const float point[3] )
	{
		return NavMeshArea_ComputeDirection(this.Index, point);
	}
	
	public float GetLightIntensity( const float point[3] )
	{
		return NavMeshArea_GetLightIntensity(this.Index, point);
	}
}

// CTFNavArea
// Admittedly VERY questionable to include this (because it's from the recent leak), but feel free to not use them if you so please.
// Bitflags for CTFNavArea's AttributeFlags property.
enum
{
	TF_NAV_INVALID						= 0x00000000,

	TF_NAV_BLOCKED						= 0x00000001,
	TF_NAV_SPAWN_ROOM_RED				= 0x00000002,
	TF_NAV_SPAWN_ROOM_BLUE				= 0x00000004,
	TF_NAV_SPAWN_ROOM_EXIT				= 0x00000008,
	TF_NAV_HAS_AMMO						= 0x00000010,
	TF_NAV_HAS_HEALTH					= 0x00000020,
	TF_NAV_CONTROL_POINT				= 0x00000040,

	TF_NAV_BLUE_SENTRY_DANGER			= 0x00000080,			// sentry can potentially fire upon enemies in this area
	TF_NAV_RED_SENTRY_DANGER			= 0x00000100,

	TF_NAV_BLUE_SETUP_GATE				= 0x00000800,			// this area is blocked until the setup period is over
	TF_NAV_RED_SETUP_GATE				= 0x00001000,			// this area is blocked until the setup period is over
	TF_NAV_BLOCKED_AFTER_POINT_CAPTURE	= 0x00002000,			// this area becomes blocked after the first point is capped
	TF_NAV_BLOCKED_UNTIL_POINT_CAPTURE  = 0x00004000,			// this area is blocked until the first point is capped, then is unblocked
	TF_NAV_BLUE_ONE_WAY_DOOR			= 0x00008000,
	TF_NAV_RED_ONE_WAY_DOOR				= 0x00010000,

 	TF_NAV_WITH_SECOND_POINT			= 0x00020000,
 	TF_NAV_WITH_THIRD_POINT				= 0x00040000,
  	TF_NAV_WITH_FOURTH_POINT			= 0x00080000,
 	TF_NAV_WITH_FIFTH_POINT				= 0x00100000,

	TF_NAV_SNIPER_SPOT					= 0x00200000,			// this is a good place for a sniper to lurk
	TF_NAV_SENTRY_SPOT					= 0x00400000,			// this is a good place to build a sentry

	TF_NAV_ESCAPE_ROUTE					= 0x00800000,			// for Raid mode
	TF_NAV_ESCAPE_ROUTE_VISIBLE			= 0x01000000,			// all areas that have visibility to the escape route

	TF_NAV_NO_SPAWNING					= 0x02000000,			// don't spawn bots in this area

 	TF_NAV_RESCUE_CLOSET				= 0x04000000,			// for respawning friends in Raid mode

 	TF_NAV_BOMB_CAN_DROP_HERE			= 0x08000000,			// the bomb can be dropped here and reached by the invaders in MvM

	TF_NAV_DOOR_NEVER_BLOCKS			= 0x10000000,
	TF_NAV_DOOR_ALWAYS_BLOCKS			= 0x20000000,

	TF_NAV_UNBLOCKABLE					= 0x40000000,			// this area cannot be blocked

	// save/load these manually set flags, and don't clear them between rounds
	TF_NAV_PERSISTENT_ATTRIBUTES		= TF_NAV_SNIPER_SPOT | TF_NAV_SENTRY_SPOT | TF_NAV_NO_SPAWNING | TF_NAV_BLUE_SETUP_GATE | TF_NAV_RED_SETUP_GATE | TF_NAV_BLOCKED_AFTER_POINT_CAPTURE | TF_NAV_BLOCKED_UNTIL_POINT_CAPTURE | TF_NAV_BLUE_ONE_WAY_DOOR | TF_NAV_RED_ONE_WAY_DOOR | TF_NAV_DOOR_NEVER_BLOCKS | TF_NAV_DOOR_ALWAYS_BLOCKS | TF_NAV_UNBLOCKABLE | TF_NAV_WITH_SECOND_POINT | TF_NAV_WITH_THIRD_POINT | TF_NAV_WITH_FOURTH_POINT | TF_NAV_WITH_FIFTH_POINT | TF_NAV_RESCUE_CLOSET
};

methodmap CTFNavArea < CNavArea
{
	property int AttributeFlags
	{
		public native get();
	}
}

// CCSNavArea
enum struct CCSNavArea_ApproachInfo
{
	int HereArea;
	int PrevArea;
	int PrevToHereHow;
	int NextArea;
	int HereToNextHow;
}

methodmap CCSNavArea < CNavArea
{
	public native void GetApproachInfoList( ArrayList buffer );
}

// TerrorNavArea
// Bitflags for TerrorNavArea.SpawnAttributes
enum
{
	TERROR_NAV_EMPTY = 2,
	TERROR_NAV_STOP = 4,
	TERROR_NAV_FINALE = 0x40,
	TERROR_NAV_BATTLEFIELD = 0x100,
	TERROR_NAV_PLAYER_START = 0x80,
	TERROR_NAV_IGNORE_VISIBILITY = 0x200,
	TERROR_NAV_NOT_CLEARABLE = 0x400,
	TERROR_NAV_CHECKPOINT = 0x800,
	TERROR_NAV_OBSCURED = 0x1000,
	TERROR_NAV_NO_MOBS = 0x2000,
	TERROR_NAV_THREAT = 0x4000,
	TERROR_NAV_NOTHREAT = 0x80000,
	TERROR_NAV_LYINGDOWN = 0x100000,
	TERROR_NAV_RESCUE_CLOSET = 0x10000,
	TERROR_NAV_RESCUE_VEHICLE = 0x8000
}

methodmap TerrorNavArea < CNavArea
{
	property int SpawnAttributes
	{
		public native get();
	}
}

methodmap TerrorNavMesh < CNavMesh
{
	property float NavMaxViewDistance
	{
		public native get();
	}

	public native void GetZombiePopulation(char[] buffer, int maxSize);
}

// HidingSpot

enum
{
	NAV_HIDING_SPOT_IN_COVER = 0x01,
	NAV_HIDING_SPOT_GOOD_SNIPER_SPOT = 0x02,
	NAV_HIDING_SPOT_IDEAL_SNIPER_SPOT = 0x04,
	NAV_HIDING_SPOT_EXPOSED = 0x08
}

native int NavHidingSpot_GetID(int hidingSpotIndex);

native int NavHidingSpot_GetFlags(int hidingSpotIndex);

native void NavHidingSpot_GetPosition(int hidingSpotIndex, float buffer[3]);

native CNavArea NavHidingSpot_GetArea(int hidingSpotIndex);

methodmap HidingSpot
{
	public HidingSpot( int index )
	{
		return view_as<HidingSpot>(index);
	}
	
	property int Index
	{
		public get() { return view_as<int>(this); }
	}
	
	property int ID
	{
		public get() { return NavHidingSpot_GetID( this.Index ); }
	}
	
	property int Flags
	{
		public get() { return NavHidingSpot_GetFlags( this.Index ); }
	}
	
	public void GetPosition( float buffer[3] )
	{
		NavHidingSpot_GetPosition( this.Index, buffer );
	}
	
	public bool HasGoodCover()
	{
		return this.Flags & NAV_HIDING_SPOT_IN_COVER ? true : false;
	}
	
	public bool IsGoodSniperSpot()
	{
		return this.Flags & NAV_HIDING_SPOT_GOOD_SNIPER_SPOT ? true : false;
	}
	
	public bool IsIdealSniperSpot()
	{
		return this.Flags & NAV_HIDING_SPOT_IDEAL_SNIPER_SPOT ? true : false;
	}
	
	public bool IsExposed()
	{
		return this.Flags & NAV_HIDING_SPOT_EXPOSED ? true : false;
	}
	
	public CNavArea GetArea()
	{
		return NavHidingSpot_GetArea(this.Index);
	}
}


// CNavLadder

native float NavMeshLadder_GetLength(int ladderIndex);

native float NavMeshLadder_GetWidth(int ladderIndex);

native CNavArea NavMeshLadder_GetTopForwardArea(int ladderIndex);

native CNavArea NavMeshLadder_GetTopLeftArea(int ladderIndex);

native CNavArea NavMeshLadder_GetTopRightArea(int ladderIndex);

native CNavArea NavMeshLadder_GetTopBehindArea(int ladderIndex);

native CNavArea NavMeshLadder_GetBottomArea(int ladderIndex);

native void NavMeshLadder_GetTop(int ladderIndex, float buffer[3]);

native void NavMeshLadder_GetBottom(int ladderIndex, float buffer[3]);

methodmap CNavLadder
{
	public CNavLadder( int index )
	{
		return view_as<CNavLadder>(index);
	}
	
	property int Index
	{
		public get() { return view_as<int>(this); }
	}
	
	property float Length
	{
		public get() { return NavMeshLadder_GetLength(this.Index); }
	}
	
	property float Width
	{
		public get() { return NavMeshLadder_GetWidth(this.Index); }
	}
	
	property CNavArea TopForwardArea
	{
		public get() { return NavMeshLadder_GetTopForwardArea(this.Index); }
	}
	
	property CNavArea TopLeftArea
	{
		public get() { return NavMeshLadder_GetTopLeftArea(this.Index); }
	}
	
	property CNavArea TopRightArea
	{
		public get() { return NavMeshLadder_GetTopRightArea(this.Index); }
	}
	
	property CNavArea TopBehindArea
	{
		public get() { return NavMeshLadder_GetTopBehindArea(this.Index); }
	}
	
	property CNavArea BottomArea
	{
		public get() { return NavMeshLadder_GetBottomArea(this.Index); }
	}
	
	public void GetTop( float buffer[3] )
	{
		NavMeshLadder_GetTop(this.Index, buffer);
	}
	
	public void GetBottom( float buffer[3] )
	{
		NavMeshLadder_GetBottom(this.Index, buffer);
	}
}


// SpotEncounter

native CNavArea NavSpotEncounter_GetFrom(int spotEncounterIndex);

native int NavSpotEncounter_GetFromDirection(int spotEncounterIndex);

native CNavArea NavSpotEncounter_GetTo(int spotEncounterIndex);

native int NavSpotEncounter_GetToDirection(int spotEncounterIndex);

native void NavSpotEncounter_GetSpots(int spotEncounterIndex, ArrayStack buffer);

methodmap SpotEncounter
{
	public SpotEncounter( int index )
	{
		return view_as<SpotEncounter>(index);
	}
	
	property int Index
	{
		public get() { return view_as<int>(this); }
	}
	
	property CNavArea From
	{
		public get() { return NavSpotEncounter_GetFrom(this.Index); }
	}
	
	property int FromDirection
	{
		public get() { return NavSpotEncounter_GetFromDirection(this.Index); }
	}
	
	property CNavArea To
	{
		public get() { return NavSpotEncounter_GetTo(this.Index); }
	}
	
	property int ToDirection
	{
		public get() { return NavSpotEncounter_GetToDirection(this.Index); }
	}
	
	public void GetSpots( ArrayStack buffer )
	{
		NavSpotEncounter_GetSpots(this.Index, buffer);
	}
}


// SpotOrder

native HidingSpot NavSpotOrder_GetHidingSpot(int spotOrderIndex);

native int NavSpotOrder_GetParametricDistance(int spotOrderIndex);

methodmap SpotOrder
{
	public SpotOrder( int index )
	{
		return view_as<SpotOrder>(index);
	}
	
	property int Index
	{
		public get() { return view_as<int>(this); }
	}
	
	property HidingSpot HidingSpot
	{
		public get() { return NavSpotOrder_GetHidingSpot(this.Index); }
	}
	
	property int ParametricDistance
	{
		public get() { return NavSpotOrder_GetParametricDistance(this.Index); }
	}
}


// Shortest-path cost function for NavMesh_BuildPath.
public int NavMeshShortestPathCost(CNavArea area, CNavArea from, CNavLadder ladder, any data)
{
	if (from == INVALID_NAV_AREA)
	{
		return 0;
	}
	else
	{
		int iDist = 0;
		if (ladder != INVALID_NAV_LADDER)
		{
			iDist = RoundFloat(ladder.Length);
		}
		else
		{
			float flAreaCenter[3]; float flFromAreaCenter[3];
			area.GetCenter(flAreaCenter);
			from.GetCenter(flFromAreaCenter);
			
			iDist = RoundFloat(GetVectorDistance(flAreaCenter, flFromAreaCenter));
		}
		
		int iCost = iDist + from.CostSoFar;
		int iAreaFlags = area.Attributes;
		if (iAreaFlags & NAV_MESH_CROUCH) iCost += 20;
		if (iAreaFlags & NAV_MESH_JUMP) iCost += (5 * iDist);
		return iCost;
	}
}

// stocks

stock bool IsEntityWalkable(int iEnt, int iFlags)
{
	char sClass[64];
	GetEntityClassname(iEnt, sClass, sizeof(sClass));
	
	if (!strcmp(sClass, "worldspawn")) return false;
	if (!strcmp(sClass, "player")) return false;
	
	if (!strcmp(sClass, "func_door*"))
	{
		return (iFlags & WALK_THRU_PROP_DOORS) ? true : false;
	}
	
	if (!strcmp(sClass, "prop_door*"))
	{
		return (iFlags & WALK_THRU_PROP_DOORS) ? true : false;
	}
	
	if (!strcmp(sClass, "func_brush"))
	{
		int iSolidity = GetEntProp(iEnt, Prop_Data, "m_iSolidity");
		
		switch (iSolidity)
		{
			case 2: // BRUSHSOLID_ALWAYS
			{
				return false;
			}
			case 1: // BRUSHSOLID_NEVER
			{
				return true;
			}
			case 0: // BRUSHSOLID_TOGGLE
			{
				return (iFlags & WALK_THRU_TOGGLE_BRUSHES) ? true : false;
			}
		}
		
		return (iFlags & WALK_THRU_PROP_DOORS) ? true : false;
	}
	
	if (!strcmp(sClass, "func_breakable") && GetEntProp(iEnt, Prop_Data, "m_iHealth") && GetEntProp(iEnt, Prop_Data, "m_takedamage") == 2) // DAMAGE_YES
	{
		return (iFlags & WALK_THRU_BREAKABLES) ? true : false;
	}
	
	if (!strcmp(sClass, "func_playerinfected_clip"))
	{
		return true;
	}
	
	return false;
}

stock bool IsWalkableTraceLineClear(const float flFrom[3], const float flTo[3], int iFlags)
{
	float flUseFrom[3];
	flUseFrom[0] = flFrom[0];
	flUseFrom[1] = flFrom[1];
	flUseFrom[2] = flFrom[2];
	
	Handle hTrace;
	
	float flFraction = 0.0;
	
	for (int t = 0; t < 50; t++)
	{
		hTrace = TR_TraceRayFilterEx(flUseFrom, flTo, MASK_NPCSOLID, RayType_EndPoint, TraceFilterWalkableEntities, iFlags);
		flFraction = TR_GetFraction(hTrace);
		int iResEnt = TR_GetEntityIndex(hTrace);
		float flResPos[3];
		TR_GetEndPosition(flResPos, hTrace);
		delete hTrace;
		
		if (flFraction != 1.0 && IsEntityWalkable(iResEnt, iFlags))
		{
			float flDir[3];
			SubtractVectors(flTo, flFrom, flDir);
			NormalizeVector(flDir, flDir);
			ScaleVector(flDir, 5.0);
			AddVectors(flResPos, flDir, flUseFrom);
		}
		else
		{
			break;
		}
	}
	
	if (flFraction == 1.0) return true;
	
	return false;
}

public bool TraceFilterWalkableEntities(int entity, int mask, any iFlags)
{
	return !IsEntityWalkable(entity, iFlags);
}


public SharedPlugin __pl_navmesh = 
{
	name = "navmesh",
	file = "navmesh.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};