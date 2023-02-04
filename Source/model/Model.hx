package model;

class Model
{
	public var texturePackerJson:String;
	public var animations:Map<String, Animation>;

	public function new()
	{
		animations = new Map<String, Animation>();
	}

	public function copy()
	{
		var modelCopy = new Model();
		
		modelCopy.texturePackerJson = this.texturePackerJson;

		for (key => animation in this.animations)
			modelCopy.animations.set(key, animation.copy());

		return modelCopy;
	}
}
