package backend;

import events.EditorEvent;
import model.Animation;
import openfl.events.IEventDispatcher;
import simple.display.SPAnimatedSprite;
import simple.display.SPState;
import ui.AnimationEditorUI;

using simple.extension.SPAnimatedSpriteTexturePackagerExtension;

@:access(simple.display.SPAnimatedSprite)
class Runtime extends SPState
{
	private var eventDispatcher: IEventDispatcher;

	private var displaySprite: SPAnimatedSprite;

	private var ui: AnimationEditorUI;

	public function new(ui: AnimationEditorUI, eventDispatcher: IEventDispatcher)
	{
		super();

		this.eventDispatcher = eventDispatcher;
		this.ui = ui;
		this.displaySprite = new SPAnimatedSprite();

		this.eventDispatcher.addEventListener(EditorEvent.LOAD_TEXTUREPACKER_FILE, onLoadTexturePackerFile);
		this.eventDispatcher.addEventListener(EditorEvent.ANIMATION_UPDATED, onAnimationUpdated);
		this.eventDispatcher.addEventListener(EditorEvent.ANIMATION_SELECTED, onAnimationUpdated);
	}

	public override function init()
    {
		addUI(ui);
		
		displaySprite.x = 5;
		displaySprite.y = 5;
		
		ui.animation_display.addChild(displaySprite);
	}

	public function onLoadTexturePackerFile(e: EditorEvent<String>)
	{
		try {
			displaySprite.loadFramesFromTexturePackerJsonFile(e.value);
		} catch(e) {
			trace(e.message);
			return;
		}

		ui.frame_bar.removeAllComponents();
		
		displaySprite.visible = false;

		var frameSprites: Array<FrameData> = [];
		
		for (name => _ in displaySprite._frameMap)
		{
			var frameSprite = new SPAnimatedSprite();
			
			frameSprite.loadFramesFromTexturePackerJsonFile(e.value);
			frameSprite.setFrameByName(name);
			
			frameSprites.push({frameName: name, sprite: frameSprite});
		}

		ui.createFrameButtons(frameSprites);
	}

	public function onAnimationUpdated(e: EditorEvent<Tuple<String, Animation>>)
	{
		var animation = e.value.v2;
		
		if(animation.frames.length == 0)
		{
			displaySprite.visible = false;
			return;
		}

		displaySprite.visible = true;
		
		var animations = new Map<String, SPAnimationNameData>();

		var animation_data =
		{
			frames: animation.frames,
			frameRate: animation.frameRate,
			repeatCount: animation.looped ? -1 : 1,
			flipX: animation.flipX,
			flipY: animation.flipY
		};

		animations.set("current", animation_data);

		displaySprite.loadNameAnimations(animations);
		displaySprite.playAnimation("current");

		ui.animation_display.width = displaySprite.width + 10;
		ui.animation_display.height = displaySprite.height + 10;
	}
}