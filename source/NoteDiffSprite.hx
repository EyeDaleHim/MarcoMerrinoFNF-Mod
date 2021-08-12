package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

class NoteDiffSprite extends FlxSpriteGroup
{
    
    var blackRect:FlxSprite;
    var sickRect:FlxSprite;
    var goodRect:FlxSprite;
    var badRect:FlxSprite;
    var shitRect:FlxSprite;

    // lines to remove
    var lines:FlxSpriteGroup;

    // Badly optimized.
    override public function new(x:Float, y:Float)
    {
        /*
        super();

        lines = new FlxSpriteGroup();

        blackRect = new FlxSprite(x, y).makeGraphic(Std.int(Conductor.safeZoneOffset), 32, FlxColor.BLACK);
        blackRect.scrollFactor.set();
        add(blackRect);
        */
    }
    
    /*
    override function update(elapsed:Float)
    {
        lines.forEachAlive(function(spr:FlxSprite) {
            trace('lines alpha' + spr.alpha);
            spr.alpha -= 0.04 * (elapsed * 10);

            if (spr.alpha < 0)
            {
                spr.kill();
                lines.remove(spr);
            }
        });
        
    }

    public function createLine(noteDiff:Float)
    {
        var colorShit:FlxColor = FlxColor.CYAN;
        
        if (noteDiff > Conductor.safeZoneOffset * 0.9)
			colorShit = FlxColor.RED;
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
			colorShit = FlxColor.YELLOW;
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
			colorShit = FlxColor.GREEN;
        
        var noteLine:FlxSprite = new FlxSprite((FlxG.width * 0.5) + noteDiff, 240).makeGraphic(8, 16, colorShit);
        lines.add(noteLine);
    }
*/
}