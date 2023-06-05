package events;

import openfl.events.Event;

class Tuple<T1, T2>
{
	public var v1: T1;
	public var v2: T2;

	public function new(v1: T1, v2: T2)
	{
		this.v1 = v1;
		this.v2 = v2;
	}
}

class EditorEvent<T> extends Event
{
	// UI Events
	public static inline var ADD_ANIMATION 						= "UI_0";
	public static inline var DELETE_ANIMATION 					= "UI_1";
	public static inline var RENAME_ANIMATION 					= "UI_2";
	public static inline var SELECT_ANIMATION 					= "UI_3";
	public static inline var ADD_FRAME 							= "UI_4";
	public static inline var DELETE_FRAME 						= "UI_5";
	public static inline var CHANGE_FLIP_X 						= "UI_6";
	public static inline var CHANGE_FLIP_Y 						= "UI_7";
	public static inline var CHANGE_FRAMERATE 					= "UI_6";
	public static inline var CHANGE_REPEAT_COUNT	 			= "UI_7";
	public static inline var NEW_ANIMATION 						= "UI_8";
	public static inline var LOAD_ANIMATION 					= "UI_9";
	public static inline var SAVE_ANIMATION 					= "UI_10";
	public static inline var LOAD_TEXTUREPACKER_FILE 			= "UI_11";
	public static inline var EXIT 								= "UI_12";

	// Model Events
	public static inline var ANIMATION_CREATED 					= "Model_0";
	public static inline var ANIMATION_UPDATED 					= "Model_1";
	public static inline var ANIMATION_SELECTED 				= "Model_2";
	public static inline var TEXTUREPACKER_UPDATED				= "Model 3";
	public static inline var FRAME_ADDED 						= "Model_4";
	public static inline var MODEL_RESET 						= "Model_5";
	public static inline var MODEL_LOADED 						= "Model_6";

	// Runtime Events
	public static inline var TEXTUREPACKER_FRAMES_LOADED		= "Runtime_0";
	
	public var value(default, null): T;

	public function new(type: String, value: T = null)
    {
		super(type);

        this.value = value;
	}
}