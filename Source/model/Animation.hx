package model;

class Animation
{
	public var frames: Array<String>;
	public var frameRate: Int;
	public var flipX: Bool;
	public var flipY: Bool;
	public var repeatCount: Int;

	public function new()
	{
		frames = new Array<String>();
		frameRate = 30;
	}

	public function copy()
	{
		var animationCopy = new Animation();

		animationCopy.frameRate = this.frameRate;
		animationCopy.flipX = this.flipX;
		animationCopy.flipY = this.flipY;
		animationCopy.repeatCount = this.repeatCount;
		animationCopy.frames = this.frames.copy();

		return animationCopy;
	}
}