package ui;

import events.EditorEvent;
import haxe.ui.components.Button;
import haxe.ui.components.CheckBox;
import haxe.ui.components.Label;
import haxe.ui.containers.ListView;
import haxe.ui.containers.VBox;
import haxe.ui.containers.dialogs.Dialogs;
import haxe.ui.containers.dialogs.MessageBox.MessageBoxType;
import haxe.ui.containers.menus.MenuBar;
import haxe.ui.events.UIEvent;
import lime.ui.FileDialog;
import lime.ui.FileDialogType;
import model.Animation;
import model.Model;
import openfl.display.DisplayObject;
import openfl.events.IEventDispatcher;

using tink.CoreApi;

typedef FrameData =
{
	frameName: String,
	sprite: DisplayObject
};

@:build(haxe.ui.macros.ComponentMacros.build("assets/xml/main.xml"))
class AnimationEditorUI extends VBox
{
	var eventDispatcher: IEventDispatcher;
	var renameAnimationDialog: RenameAnimationDialog;
	var animationCount: Int;

	public function new(eventDispatcher: IEventDispatcher)
	{
		super();

		this.sideBar.disabled = true;
		this.animationCount = 0;
		this.eventDispatcher = eventDispatcher;

		this.renameAnimationDialog = new RenameAnimationDialog();
		this.renameAnimationDialog.destroyOnClose = false;

		// Subscribing to extrenal events
		this.eventDispatcher.addEventListener(EditorEvent.MODEL_RESET, onModelReset);
		this.eventDispatcher.addEventListener(EditorEvent.ANIMATION_CREATED, onAnimationCreated);
		this.eventDispatcher.addEventListener(EditorEvent.ANIMATION_SELECTED, onAnimationCreated);
		this.eventDispatcher.addEventListener(EditorEvent.FRAME_ADDED, onFrameAdded);
		
		// Subscribing to UI Events
		this.frameList.onChange = onFrameSelected;
		this.animationList.onChange = onAnimationSelected;
		this.loadTexturepacker.onClick = onLoadTexturePackerFile;
		this.addAnimation.onClick = onAddAnimationClicked;
		this.renameAnimation.onClick = onRenameAnimationClicked;
		this.deleteAnimation.onClick = onDeleteAnimationClicked;
		this.deleteFrame.onClick = onDeleteFrameClicked;
		this.flipXCheckBox.onChange = onFlipXChanged;
		this.flipYCheckBox.onChange = onFlipYChanged;
		this.repeatCountStepper.onChange = onRepeatCountChanged;
		this.frameRateSlider.onChange = onFrameRateChanged;
		
		this.menuBar.onMenuSelected = e ->
		{
			switch (e.menuItem.id)
			{
				case "menuNewModel": this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.NEW_ANIMATION));
				case "menuLoadModel": loadAnimation();
				case "menuSaveModel": saveAnimation();
				case "menuQuit": this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.EXIT));
			}
		};
	}

	////////////
	// Public //
	////////////

	public function showErrorDialog(message: String)
	{
		Dialogs.messageBox(message, 'Error', MessageBoxType.TYPE_ERROR);
	}

	public function clearFramesBar()
	{
		this.frame_bar.removeAllComponents();
	}

	public function setSideBarEnabled(enabled: Bool)
	{
		this.sideBar.disabled = !enabled;
	}

	public function setTextupackerLabel(text: String)
	{
		this.loadedTexturepacker.text = text;
	}

	public function loadModelData(model: Model)
	{
		animationList.dataSource.clear();

		var first: Animation = null;

		for (name => _ in model.animations)
		{
			if (first == null)
				first = model.animations.get(name);

			animationList.dataSource.add({
				text: name
			});
		}

		if (first != null)
		{
			loadSelectedAnimation(animationList.dataSource.get(0).text, first);
		}
	}

	public function createFrameButtons(frameSprites: Array<FrameData>)
	{
		for (frameSprite in frameSprites)
		{
			var button = new Button();

			frameSprite.sprite.x = 5;
			frameSprite.sprite.y = 5;
			button.width = frameSprite.sprite.width + 10;
			button.height = frameSprite.sprite.height + 10;
			
			button.addChild(frameSprite.sprite);
			frame_bar.addComponent(button);
			
			button.onClick = e ->
			{
				if (animationList.selectedItem == null)
				{
					Dialogs.messageBox('No animation selected', 'Error', MessageBoxType.TYPE_ERROR);
					return;
				}
				
				onAddFrame(frameSprite.frameName);
			};
		}
	}
	
	//////////////////
	// EditorEvents //
	//////////////////
	
	function onFrameAdded(e: EditorEvent<String>)
	{
		frameList.dataSource.add({
			text: e.value
		});
	}

	function onAddFrame(frameName: String)
	{
		if (animationList.selectedItem == null)
			return;

		var name = animationList.selectedItem.text;

		this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.ADD_FRAME, new Tuple(name, frameName)));
	}
	
	function onModelReset(e: EditorEvent<Model>)
	{
		loadedTexturepacker.text = e.value.texturePackerJson;

		this.sideBar.disabled = e.value.texturePackerJson != null;

		animationList.dataSource.clear();
		frameList.dataSource.clear();
	}

	// function onModelUpdate(e: EditorEvent)
	// {
	// 	loadedTexturepacker.text = e.model.texturePackerJson;

	// 	animationList.dataSource.clear();

	// 	var first: Animation = null;

	// 	for (name => _ in e.model.animations)
	// 	{
	// 		if (first == null)
	// 			first = e.model.animations.get(name);

	// 		animationList.dataSource.add({
	// 			text: name
	// 		});
	// 	}

	// 	if(first != null)
	// 	{
	// 		selectAnimation(animationList.dataSource.get(0).text, first);
	// 	}
	// }

	/////////////////////
	// AnimationEvents //
	/////////////////////

	function onAnimationCreated(e: EditorEvent<Tuple<String, Animation>>)
	{
		var name = e.value.v1;
		var animation = e.value.v2;
		
		loadSelectedAnimation(name, animation);
	}

	/////////////////////
	// AnimationEvents //
	/////////////////////

	function loadSelectedAnimation(name: String, animation: Animation)
	{
		currentAnimation.text = name;

		flipXCheckBox.selected = animation.flipX;
		flipYCheckBox.selected = animation.flipY;
		repeatCountStepper.value = animation.repeatCount;
		frameRateSlider.value = animation.frameRate;

		frameList.dataSource.clear();

		for (frame in animation.frames)
		{
			frameList.dataSource.add({
				text: frame
			});
		}

		animationInfo.disabled = false;
	}

	function loadAnimation()
	{
		var dialog = new FileDialog();
		dialog.onSelect.add(path -> this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.LOAD_ANIMATION, path)));
		dialog.browse(FileDialogType.OPEN, "json", null, 'TexturePacker json');
	}

	function saveAnimation()
	{
		var dialog = new FileDialog();
		dialog.onSelect.add(path -> this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.SAVE_ANIMATION, path)));
		dialog.browse(FileDialogType.SAVE, "json", null, 'save animation to...');
	}

	function onLoadTexturePackerFile(event: UIEvent)
	{
		var dialog = new FileDialog();
		dialog.onSelect.add(path ->
		{
			this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.LOAD_TEXTUREPACKER_FILE, path));
		});
		dialog.browse(FileDialogType.OPEN, "json", null, 'TexturePacker json');
	}

	function onFrameSelected(event: UIEvent) {}

	function onAddAnimationClicked(event: UIEvent)
	{
		var name = '<new_animation_${animationCount++}>';

		animationList.dataSource.add({
			text: name
		});
		
		animationList.selectedIndex = animationList.numComponents;

		this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.ADD_ANIMATION, name));
	}
	
	function onRenameAnimationClicked(event:UIEvent)
	{
		if (animationList.selectedItem == null)
		{
			Dialogs.messageBox('No animation selected', 'Error', MessageBoxType.TYPE_ERROR);
			return;
		}
		
		var name = animationList.selectedItem.text;

		renameAnimationDialog.open(name).handle(newName ->
		{
			animationList.dataSource.update(animationList.selectedIndex, {
				text: newName
			});

			currentAnimation.text = newName;

			this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.RENAME_ANIMATION, new Tuple(name, newName)));
		});
	}

	function onDeleteAnimationClicked(event: UIEvent)
	{
		if (animationList.selectedItem == null)
		{
			return;
		}

		var name = animationList.selectedItem.text;

		animationList.dataSource.remove(animationList.selectedItem);

		if(animationList.selectedItem == null)
		{
			animationInfo.disabled = true;
			frameList.dataSource.clear();
		}
		else
		{
			var name = animationList.selectedItem.text;
			this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.SELECT_ANIMATION, name));
		}

		this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.DELETE_ANIMATION, name));
	}

	function onDeleteFrameClicked(event: UIEvent)
	{
		if (animationList.selectedItem == null)
		{
			return;
		}

		if (frameList.selectedItem == null)
		{
			return;
		}

		var name = animationList.selectedItem.text;

		this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.DELETE_FRAME, new Tuple(name, frameList.selectedIndex)));

		frameList.dataSource.remove(frameList.selectedItem);
	}

	function onAnimationSelected(event: UIEvent)
	{
		if (animationList.selectedItem == null)
		{
			animationInfo.disabled = true;
			return;
		}
		else
		{
			animationInfo.disabled = false;
		}

		var selectedName = animationList.selectedItem.text;
		
		this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.SELECT_ANIMATION, selectedName));
	}

	function onFlipXChanged(event: UIEvent)
	{
		if (animationList.selectedItem == null)
			return;
		
		this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.CHANGE_FLIP_X, new Tuple(animationList.selectedItem.text, flipXCheckBox.selected)));
	}

	function onFlipYChanged(event: UIEvent)
	{
		if (animationList.selectedItem == null)
			return;

		this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.CHANGE_FLIP_Y, new Tuple(animationList.selectedItem.text, flipYCheckBox.selected)));
	}

	function onRepeatCountChanged(event: UIEvent)
	{
		if (animationList.selectedItem == null)
			return;
		
		this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.CHANGE_REPEAT_COUNT, new Tuple(animationList.selectedItem.text, repeatCountStepper.value)));
	}

	function onFrameRateChanged(event:  UIEvent)
	{
		if (animationList.selectedItem == null)
			return;
		
		this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.CHANGE_FRAMERATE, new Tuple(animationList.selectedItem.text, frameRateSlider.value)));
	}
}
