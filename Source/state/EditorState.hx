package state;

import events.EditorEvent;
import model.Animation;
import model.Model;
import openfl.events.IEventDispatcher;
import simple.display.SPAnimatedSprite;
import simple.display.SPState;
import ui.AnimationEditorUI;

using simple.extension.SPAnimatedSpriteTexturePackagerExtension;

@:access(simple.display.SPAnimatedSprite)
class EditorState extends SPState
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
		
        this.eventDispatcher.addEventListener(EditorEvent.MODEL_LOADED, onModelLoaded);
		this.eventDispatcher.addEventListener(EditorEvent.TEXTUREPACKER_UPDATED, onTexturePackerUpdated);
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

    //////////////////
    // EditorEvents //
    //////////////////

    function onModelLoaded(e: EditorEvent<Model>)
    {
		handleTexturePackerFileChange(e.value.texturePackerJson);

		ui.setSideBarEnabled(true);
		ui.loadModelData(e.value);
    }

	function onAnimationUpdated(e: EditorEvent<Tuple<String, Animation>>)
    {
		var animation = e.value.v2;

		if (animation.frames.length == 0)
		{
			displaySprite.visible = false;
			return;
		}

		displaySprite.visible = true;

		var animations = new Map<String, SPAnimationNameData>();

		var animation_data = {
			frames: animation.frames,
			frameRate: animation.frameRate,
			flipX: animation.flipX,
			flipY: animation.flipY,
			repeatCount: animation.repeatCount
		};

		animations.set("current", animation_data);

		displaySprite.loadNameAnimations(animations);
		displaySprite.playAnimation("current");

		ui.animation_display.width = displaySprite.width + 10;
		ui.animation_display.height = displaySprite.height + 10;
	}

    function onTexturePackerUpdated(e: EditorEvent<String>)
    {
		handleTexturePackerFileChange(e.value);
    }

    /////////////
    // Private //
    /////////////

    function handleTexturePackerFileChange(path: String)
    {
		ui.clearFramesBar();
		ui.setSideBarEnabled(false);
		ui.setTextupackerLabel(path);

		displaySprite.visible = false;

		var frameSprites: Array<FrameData>;

		try {
			frameSprites = loadTexturePackerFile(path);
		} catch (e) {
			ui.showErrorDialog(e.message);
			return;
		}

		ui.createFrameButtons(frameSprites);
    }

	function loadTexturePackerFile(path: String)
    {
		displaySprite.loadFramesFromTexturePackerJsonFile(path);
        
		var frameSprites: Array<FrameData> = [];

		for (name => _ in displaySprite._frameMap)
        {
			var frameSprite = new SPAnimatedSprite();

			frameSprite.loadFramesFromTexturePackerJsonFile(path);
			frameSprite.setFrameByName(name);

			frameSprites.push({frameName: name, sprite: frameSprite});
		}

        return frameSprites;
	}
}