package;

import haxe.ui.Toolkit;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.EventDispatcher;
import simple.SPColor;
import simple.SPEngine;
import state.EditorState;
import ui.AnimationEditorUI;

@:access(simple.SPEngine)
class Main extends Sprite
{
	public function new()
	{
		super();

		Lib.current.stage.color = SPColor.PINK;

		Toolkit.init();

		var eventDispatcher = new EventDispatcher();
		
		var _ = new AnimationEditor(eventDispatcher);
		var ui = new AnimationEditorUI(eventDispatcher);
		
		SPEngine.start(this, 500, () -> new EditorState(ui, eventDispatcher));
	}
}