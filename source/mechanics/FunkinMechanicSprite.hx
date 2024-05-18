package mechanics;

import flixel.system.FlxAssets.FlxGraphicAsset;

enum abstract Answer(Bool) from Bool to Bool
{
    var YES = true;
    var NO = false;
}

typedef LerpData = {
    var X:Answer;
    var Y:Answer;
    var SCALEX:Answer;
    var SCALEY:Answer;
}

class FunkinMechanicSprite extends FlxSprite
{
    public var lerped:LerpData = { X: NO, Y: NO, SCALEX: NO, SCALEY: NO};

    public var targetPos:FlxPoint;
    public var targetScale:FlxPoint;

    public var defaultPos:FlxPoint;

    public var offsets:Map<String, Array<Float>> = new Map<String, Array<Float>>();

    override public function new (X:Float, Y:Float, ?SimpleGraphic:FlxGraphicAsset)
    {
        super(X, Y, SimpleGraphic);

        targetPos = new FlxPoint(x, y);
        targetScale = new FlxPoint(scale.x, scale.y);

        defaultPos = new FlxPoint(X, Y);
    }

    override public function loadGraphic(graphic:FlxGraphicAsset, animated = false, frameWidth = 0, frameHeight = 0, unique = false, ?key:String):FunkinMechanicSprite
    {
        super.loadGraphic(graphic, animated, frameWidth, frameHeight, unique, key);
        return this;
    }

    override public function setPosition(X = 0.0, Y = 0.0)
    {
        super.setPosition(X, Y);
        defaultPos = new FlxPoint(X, Y);
    }

    override public function update(elapsed:Float)
    {
        var lerpVal = FlxMath.bound(elapsed * 12, 0, 1);

        if (lerped.X == YES)
            x = FlxMath.lerp(x, targetPos.x, lerpVal);
        if (lerped.Y == YES)
            y = FlxMath.lerp(y, targetPos.y, lerpVal);
        if (lerped.SCALEX == YES)
            scale.x = FlxMath.lerp(scale.x, targetScale.x, lerpVal);
        if (lerped.SCALEY == YES)
            scale.y = FlxMath.lerp(scale.y, targetScale.y, lerpVal);

        super.update(elapsed);
    }

    public function setScale(x:Float, y:Float)
    {
        targetScale.set(x, y);
        scale.set(x, y);
    }

    public function addAnimByPrefix(name:String, prefix:String, ?framerate:Int = 24, ?loop:Bool = true, ?offset:Array<Float>, ?flipX:Bool = false, ?flipY:Bool = false)
    {
        animation.addByPrefix(name, prefix, framerate, loop, flipX, flipY);

        if (offset == null)
            offset = [0, 0];

        offsets.set(name, offset);
    }

    public function playAnim(name:String, ?force:Bool = false, ?reverse:Bool = false, ?frame:Int = 0)
    {
        var off:Array<Float> = offsets.get(name);

        animation.play(name, force, reverse, frame);

        x = defaultPos.x + off[0];
        y = defaultPos.y + off[1];
    }
}