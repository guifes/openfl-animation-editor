package;

import events.EditorEvent;
import haxe.Json;
import json2object.JsonParser;
import model.Animation;
import model.Model;
import openfl.events.IEventDispatcher;
import simple.SPEngine;
import simple.SPLogLevel;
import sys.io.File;

class AnimationEditor
{	
	var eventDispatcher: IEventDispatcher;
	var model: Model;

	public function new(eventDispatcher: IEventDispatcher)
	{
		this.model = new Model();

		this.eventDispatcher = eventDispatcher;

		this.eventDispatcher.addEventListener(EditorEvent.NEW_ANIMATION, onNewFile);
		this.eventDispatcher.addEventListener(EditorEvent.LOAD_ANIMATION, onLoadFile);
		this.eventDispatcher.addEventListener(EditorEvent.SAVE_ANIMATION, onSaveFile);
		this.eventDispatcher.addEventListener(EditorEvent.EXIT, onExit);
		this.eventDispatcher.addEventListener(EditorEvent.ADD_ANIMATION, onAddAnimation);
		this.eventDispatcher.addEventListener(EditorEvent.DELETE_ANIMATION, onDeleteAnimation);
		this.eventDispatcher.addEventListener(EditorEvent.RENAME_ANIMATION, onRenameAnimation);
		this.eventDispatcher.addEventListener(EditorEvent.SELECT_ANIMATION, onSelectAnimation);
		this.eventDispatcher.addEventListener(EditorEvent.CHANGE_FLIP_X, onChangeFlipX);
		this.eventDispatcher.addEventListener(EditorEvent.CHANGE_FLIP_Y, onChangeFlipY);
		this.eventDispatcher.addEventListener(EditorEvent.CHANGE_FRAMERATE, onChangeFrameRate);
		this.eventDispatcher.addEventListener(EditorEvent.CHANGE_REPEAT_COUNT, onChangeRepeatCount);
		this.eventDispatcher.addEventListener(EditorEvent.ADD_FRAME, onAddFrame);
		this.eventDispatcher.addEventListener(EditorEvent.DELETE_FRAME, onDeleteFrame);
	}

	////////////////
	// FileEvents //
	////////////////

	public function onNewFile(e: EditorEvent<String>)
	{
		var texturePackerJson = this.model.texturePackerJson;
		this.model = new Model();
		this.model.texturePackerJson = texturePackerJson;
		
		this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.MODEL_RESET, this.model));
	}

	public function onSaveFile(e: EditorEvent<String>)
	{
		var handle = File.write(e.value, false);

		var json = Json.stringify(model, null, "\t");

		handle.writeString(json);
	}

	public function onLoadFile(e: EditorEvent<String>)
	{
		var json = File.getContent(e.value);

		var parser = new JsonParser<Model>();
		parser.fromJson(json);

		var parsed: Model = parser.value;

		if (parsed.texturePackerJson == null && parsed.animations == null)
		{
			SPEngine.log(SPLogLevel.ERROR, "Loaded file is invalid");
			return;
		}

		this.model = parsed;
		
		this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.MODEL_LOADED, this.model.copy()));
	}

	///////////////////
	// EditorUIEvent //
	///////////////////

	public function onExit(e: EditorEvent<String>)
	{
		Sys.exit(0);
	}

	///////////////////////
	// AnimationUIEvents //
	///////////////////////


	public function onSelectAnimation(e: EditorEvent<String>)
	{
		var animation = model.animations.get(e.value);
		
		this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.ANIMATION_SELECTED, new Tuple(e.value, animation)));
	}

	public function onAddAnimation(e: EditorEvent<String>)
	{
		var animation = new Animation();
		model.animations.set(e.value, animation);
		
		this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.ANIMATION_CREATED, new Tuple(e.value, animation)));
	}

	public function onRenameAnimation(e: EditorEvent<Tuple<String, String>>)
	{
		var animation = model.animations.get(e.value.v1);
		model.animations.remove(e.value.v1);
		model.animations.set(e.value.v2, animation);
	}

	public function onDeleteAnimation(e: EditorEvent<String>)
	{
		model.animations.remove(e.value);
	}

	public function onChangeFlipX(e: EditorEvent<Tuple<String, Bool>>)
	{
		var animation = model.animations.get(e.value.v1);
		animation.flipX = e.value.v2;

		this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.ANIMATION_UPDATED, new Tuple(e.value.v1, animation)));
	}

	public function onChangeFlipY(e: EditorEvent<Tuple<String, Bool>>)
	{
		var animation = model.animations.get(e.value.v1);
		animation.flipY = e.value.v2;

		this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.ANIMATION_UPDATED, new Tuple(e.value.v1, animation)));
	}

	public function onChangeRepeatCount(e: EditorEvent<Tuple<String, Int>>)
	{
		var animation = model.animations.get(e.value.v1);
		animation.repeatCount = e.value.v2;

		this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.ANIMATION_UPDATED, new Tuple(e.value.v1, animation)));
	}

	public function onChangeFrameRate(e: EditorEvent<Tuple<String, Int>>)
	{
		var animation = model.animations.get(e.value.v1);
		animation.frameRate = e.value.v2;

		this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.ANIMATION_UPDATED, new Tuple(e.value.v1, animation)));
	}

	public function onAddFrame(e: EditorEvent<Tuple<String, String>>)
	{
		if (e.value.v1 == null)
			return;

		var animation = model.animations.get(e.value.v1);

		animation.frames.push(e.value.v2);

		this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.FRAME_ADDED, e.value.v2));
		this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.ANIMATION_UPDATED, new Tuple(e.value.v1, animation)));
	}

	public function onDeleteFrame(e: EditorEvent<Tuple<String, Int>>)
	{
		var animation = model.animations.get(e.value.v1);
		animation.frames.splice(e.value.v2, 1);

		this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.ANIMATION_UPDATED, new Tuple(e.value.v1, animation)));
	}
}
