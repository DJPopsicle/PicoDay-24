package mechanics;

import psychlua.ModchartSprite;
import flixel.system.macros.FlxMacroUtil;
import flixel.input.keyboard.FlxKey;

import flixel.util.FlxTimer;

import objects.Character;

class Dodge extends FunkinMechanic
{
    var dodgeSpr:FunkinMechanicSprite;
    var cueSpr:FunkinMechanicSprite;
    var ratingSpr:FunkinMechanicSprite;
    var smashSpr:FunkinMechanicSprite;

    public var dodging:Bool;
    public var canDodge:Bool;
    public var dodged:Bool;
    public var cancelDodge:Bool;
    public var missed:Bool;
    public var dodgeSoundPlayed:Bool = false;

    public var missing:Bool;

    public var dodgeStep:Int = 0;

    public var sprScale:Float = 1.2;

    public var projNum:Int;
    public var projMove:Map<Int, Float> = new Map<Int, Float>();

    public var projTwnManager:FlxTweenManager;

    public var storedRating:Float;

    override public function new (instance:PlayState, bf:Character, gf:Character, dad:Character, camera:FlxCamera)
    {
        super(instance, bf, gf, dad);

        projMove.set(1, 0);
        projMove.set(2, 0);
        projMove.set(3, 0);

        projTwnManager = new FlxTweenManager();
        ProjMove.resetProj();

        timingType = BEAT;
        timingCue = 4;
        timingWindows = [
            'early'   => 300,
            "perfect" => 175,
            'late'    => 300,
            'miss'    => 400
        ];

        dodgeSpr = new FunkinMechanicSprite(instance.strumLineX + 625, instance.strumLineY - 75);
        dodgeSpr.frames = Paths.getSparrowAtlas('space');
        dodgeSpr.addAnimByPrefix('bop', 'space barBop', 12, false, [0, 0]);
        //dodgeSpr.addAnimByPrefix('now', 'space now', 12, false, [0, 0]);
        dodgeSpr.addAnimByPrefix('hit', 'space barHit', 12, false, [0, 0]);
        // dodgeSpr.screenCenter(XY);
        dodgeSpr.antialiasing = ClientPrefs.data.antialiasing;
        dodgeSpr.visible = false;
        dodgeSpr.setScale(sprScale, sprScale);
        //dodgeSpr.setScale(2, 2);
        //dodgeSpr.lerped.SCALEX = YES;
        //dodgeSpr.lerped.SCALEY = YES;
        dodgeSpr.cameras = [camera];
        add(SPRITE, dodgeSpr, 'dodgeSpr');

        cueSpr = new FunkinMechanicSprite(dodgeSpr.x, dodgeSpr.y - 25);
        cueSpr.frames = Paths.getSparrowAtlas('space');
        cueSpr.addAnimByPrefix('1', 'space num1', 12, false, [0, 0]);
        cueSpr.addAnimByPrefix('2', 'space num2', 12, false, [0, 0]);
        cueSpr.addAnimByPrefix('3', 'space num3', 12, false, [0, 0]);
        cueSpr.addAnimByPrefix('now', 'space now', 12, false, [0, 0]);
        // cueSpr.screenCenter(XY);
        cueSpr.antialiasing = ClientPrefs.data.antialiasing;
        cueSpr.visible = false;
        cueSpr.setScale(sprScale, sprScale);
        //cueSpr.lerped.SCALEX = YES;
        //cueSpr.lerped.SCALEY = YES;
        cueSpr.cameras = [camera];
        add(SPRITE, cueSpr, 'cueSpr');

        ratingSpr = new FunkinMechanicSprite(dodgeSpr.x, dodgeSpr.y + 145);
        ratingSpr.frames = Paths.getSparrowAtlas('space');
        ratingSpr.addAnimByPrefix('early', 'space early', 12, false, [0, 0]);
        ratingSpr.addAnimByPrefix('late', 'space late', 12, false, [0, 0]);
        // ratingSpr.screenCenter(XY);
        ratingSpr.antialiasing = ClientPrefs.data.antialiasing;
        ratingSpr.visible = false;
        ratingSpr.setScale(sprScale, sprScale);
        //ratingSpr.lerped.SCALEX = YES;
        //ratingSpr.lerped.SCALEY = YES;
        ratingSpr.cameras = [camera];
        add(SPRITE, ratingSpr, 'ratingSpr');

        smashSpr = new FunkinMechanicSprite(0, 0);
        smashSpr.frames = Paths.getSparrowAtlas('smash');
        smashSpr.addAnimByPrefix('smash', 'smash fx', 12, false, [0, 0]);
        smashSpr.antialiasing = ClientPrefs.data.antialiasing;
        smashSpr.visible = false;
        smashSpr.scale.set(sprScale, sprScale);
        add(SPRITE, smashSpr, 'smashSpr');

        add(BIND, "space", "dodge");


        var tick:FlxSound = new FlxSound().loadEmbedded(Paths.sound("dodge/throwTick"));
        var zip:FlxSound = new FlxSound().loadEmbedded(Paths.sound("dodge/throwZip"));
        var hit:FlxSound = new FlxSound().loadEmbedded(Paths.sound("dodge/throwHit"));
        var dodge:FlxSound = new FlxSound().loadEmbedded(Paths.sound("clickText"));

        var empty:FlxSound = new FlxSound().loadEmbedded(Paths.sound("dodge/throwEmpty"));
        var miss:FlxSound = new FlxSound().loadEmbedded(Paths.sound("dodge/throwMiss"));

        add(SOUND, tick, "tick");
        add(SOUND, zip, "zip");
        add(SOUND, hit, "hit");
        add(SOUND, dodge, "dodge");
        add(SOUND, empty, "empty");
        add(SOUND, miss, "miss");

        add(ANIMATION, "dodge", "hit");
        add(ANIMATION, "hit", 'miss');

        playState.mechanicManager.addMechanic("Dodge", this);
    }

    override public function update(elapsed:Float)
    {
        if (dodging && canDodge && justPressed("dodge"))
        {
            if (!dodgeSoundPlayed)
                playSound("hit");
            
            switch (judge())
            {
                case EARLY:
                    ratingSpr.playAnim('early', true);
                    ratingSpr.visible = true;

                    playAnimation("hit", BF);
                    playSound("dodge");

                    dodged = true;

                case PERFECT:
                    dodged = true;

                    playAnimation("hit", BF);
                    playSound("dodge");
                    
                case LATE:
                    ratingSpr.playAnim('late', true);
                    ratingSpr.visible = true;

                    playAnimation("hit", BF);
                    playSound("dodge");

                    dodged = true;

                case MISS:
                    dodged = false;

                    playAnimation("miss", BF);
                    
            }

            storedRating = rating;

            FlxTween.tween(ratingSpr, { alpha: 0 }, 1, {
                onComplete: function (twn:FlxTween){
                    ratingSpr.visible = false;
                    ratingSpr.alpha = 1;
                }
            });

            dodgeSpr.playAnim('hit', true);
            cueSpr.visible = false;
            trace("called Judge");
            //dodging = false;
            canDodge = false;

            //curCount = Std.parseInt(Std.string(timingCue));
            cancelDodge = true;


            bf.dodging = dodged;

            new FlxTimer().start(1, function(tmr:FlxTimer){
                dodgeSpr.visible = false;
                cueSpr.visible = false;
                ratingSpr.visible = false;


                dodged = false;
                dodging = false;
                canDodge = false;

                
                bf.dodging = false;
                //gf.dodging = false;
                dad.dodging = false;
            });
        }

        // if (storedRating != rating)
        // {
        //     switch (rating)
        //     {
        //         case EARLY:
        //             playAnimation("hit", BF);

        //         case PERFECT:
        //             playAnimation("hit", BF);

        //         case LATE:
        //             playAnimation("hit", BF);

        //         case MISS:
        //             playAnimation("miss", BF);

        //     }

        //     storedRating = rating;
        // }
        

        super.update(elapsed);
    }

    public function dodge(dodgeAnim:String, missAnim:String, proj:Int, ?empty:Bool = false)
    {
        dodging = !empty;
        missing = empty;

        projNum = proj;

        trace("dodging");
    }

    public function miss()
    {
        missed = true;

        rating = MISS;
        storedRating = rating;

        if (FlxG.overlap(smashSpr, bf))
        {
            trace("true");
            smashProj(playState.modchartSprites.get('proj' + projNum), true);
        }

        playAnimation("miss", BF);

        dodgeSpr.visible = false;
        cueSpr.visible = false;
        ratingSpr.visible = false;

        new FlxTimer().start(1, function(tmr:FlxTimer){
            dodged = false;
            dodging = false;
            canDodge = false;

            bf.dodging = false;
            //gf.dodging = false;
            dad.dodging = false;
        });
    }

    override public function beatHit()
    {
        var sz:Float = 0.9;

        if (dodging)
        {
            bf.dodging = dodged;
            //gf.dodging = canDodge;
            dad.dodging = dodging;

            curCount--;
            
            switch (curCount)
            {
                case 4:
                    if (!dodged)
                        miss();

                    dodging = false;
                    canDodge = false;
                    dodgeSpr.visible = false;
                    cancelDodge = false;
                    dodgeSoundPlayed = false;
                    tmr.cancel();
                case 3:
                    dodgeStep = 4;
                    //dodgeSpr.scale.set(0, 0);
                    trace("3");
                    dad.playAnim('getProj');
                    playSound("tick");
                    dodgeSpr.playAnim('bop', true);
                    cueSpr.playAnim('3', true);
                    dodgeSpr.visible = true;
                    cueSpr.visible = true;
                    //dodged = false;
                    missed = false;
                    //dodgeSpr.scale.set(sz, sz);

                case 2:
                    canDodge = true;
                    //tmr.reset(timingWindows.get("early") + timingWindows.get("miss"));
                    trace("2");
                    playSound("tick");
                    dad.playAnim('readyBump');
                    dodgeSpr.playAnim('bop', true);
                    cueSpr.playAnim('2', true);
                    //dodgeSpr.scale.set(sz, sz);

                case 1:
                    trace("1");
                    playSound("tick");
                    dad.playAnim('readyBump');
                    dodgeSpr.playAnim('bop', true);
                    cueSpr.playAnim('1', true);
                    //dodgeSpr.scale.set(sz, sz);

                case 0:
                    if (!cancelDodge)
                    {
                        tmr = new FlxTimer();
                        tmr.start(timingWindows.get("miss"));
                        trace("go");
                        dodgeSoundPlayed = true;
                        playSound("hit");
    
                        if(canDodge)
                        {
                            dodgeSpr.playAnim('bop');
                            cueSpr.playAnim('now', true);
                        }
    
                        //dodgeSpr.scale.set(sz, sz);
                    }

                    curCount = Std.parseInt(Std.string(timingCue)) + 1;

            }
        }

        if (missing)
        {
            bf.dodging = true;
            //gf.dodging = canDodge;
            dad.dodging = true;

            curCount--;

            switch (curCount)
            {
                case 4:
                    dodging = false;
                    missing = false;
                    canDodge = false;
                    dodgeSpr.visible = false;
                    tmr.cancel();
                case 3:
                    dodgeStep = 4;
                    //dodgeSpr.scale.set(0, 0);
                    trace("3");
                    dad.playAnim('getProj');
                    playSound("tick");
                    dodgeSpr.playAnim('bop', true);
                    cueSpr.playAnim('3', true);
                    dodgeSpr.visible = true;
                    cueSpr.visible = true;
                    //dodged = false;
                    //dodgeSpr.scale.set(sz, sz);

                case 2:
                    //tmr.reset(timingWindows.get("early") + timingWindows.get("miss"));
                    trace("2");
                    playSound("tick");
                    dad.playAnim('outtaProj');
                    dodgeSpr.playAnim('bop', true);
                    cueSpr.playAnim('2', true);
                    FlxTween.tween(cueSpr, { alpha: 0 }, 1);
                    FlxTween.tween(dodgeSpr, { alpha: 0 }, 1);
                    //dodgeSpr.scale.set(sz, sz);

                case 1:

                case 0:
                    tmr = new FlxTimer();
                    tmr.start(timingWindows.get("miss"));
                    dad.playAnim('shot');
                    trace("go");
                    playSound("miss");

                    //dodgeSpr.scale.set(sz, sz);
                    curCount = Std.parseInt(Std.string(timingCue)) + 1;


            }
        }
    }

    override public function stepHit()
    {
        dodgeStep++;

        if (!missing && dodging)
        {
            switch (dodgeStep)
            {
                case 15:
                    playSound("zip"); 
                case 17:
                    throwProj(projNum);

            }
        }
    }

    public function throwProj(projNum:Int)
    {
        dad.playAnim('throwProj');
        var proj = playState.modchartSprites.get('proj' + projNum);
        var projData = playState.modchartFloatingSprites.get('proj' + projNum);

        FlxTween.tween(proj, { x: projData[0] + 1200 }, 0.4, {
            ease: FlxEase.quintIn,
            onComplete: function(twn:FlxTween){
                if (!missed)
                    smashProj(proj, missed);
            }
        });

        switch (projNum)
        {
            case 1:
                FlxTween.tween(ProjMove, { proj1: 500 }, 0.30, {
                    ease: FlxEase.sineInOut
                });
                
            case 2:
                FlxTween.tween(ProjMove, { proj2: 500 }, 0.30, {
                    ease: FlxEase.sineInOut
                });

            case 3:
                FlxTween.tween(ProjMove, { proj3: 700 }, 0.30, {
                    ease: FlxEase.sineInOut
                });
        
        
        }
    }

    public function smashProj(proj:ModchartSprite, miss:Bool)
    {

        if (!miss)
        {
            proj.visible = false;
            smashSpr.setPosition(proj.x, proj.y);
            smashSpr.visible = true;
            smashSpr.playAnim('smash');
        } else {
            new FlxTimer().start(.025, function(tmr:FlxTimer){
                smashSpr.setPosition(bf.x - 350, bf.y - 500); 
                proj.visible = false;
                FlxTween.globalManager.cancelTweensOf(proj);
                FlxTween.globalManager.cancelTweensOf(ProjMove);
                smashSpr.visible = true;
                smashSpr.playAnim('smash');
            });
        }

        playState.health -= 1 * Std.parseInt(Std.string(rating));
        trace(1 * Std.parseFloat(Std.string(rating)));
    }
}

class ProjMove
{
    public static var proj1:Float = 0;
    public static var proj2:Float = 0;
    public static var proj3:Float = 0;

    public function new()
    {
        resetProj();
    }

    public static function getProj(num:Int):Float
    {
        switch (num)
        {
            case 1:
                return proj1;

            case 2:
                return proj2;

            case 3:
                return proj3;
        }

        return 0;
    }

    public static function resetProj()
    {
        proj1 = 0;
        proj2 = 0;
        proj3 = 0;
    }
}