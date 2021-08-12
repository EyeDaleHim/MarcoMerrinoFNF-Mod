package;

import flixel.FlxG;
import flixel.FlxSprite;

class HealthIconOld extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		
		loadGraphic(Paths.image('iconGrid'), true, 150, 150);

		antialiasing = FlxG.save.data.antialiasing;
		animation.add('bf', [0, 1], 0, false, isPlayer);
		animation.add('marco', [2, 3], 0, false, isPlayer);
		animation.add('gf', [16, 16], 0, false, isPlayer);
		animation.add('scared-bf', [24, 24], 0, false, isPlayer);
		animation.play(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
