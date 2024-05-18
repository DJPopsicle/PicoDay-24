package mechanics;

import flixel.FlxSprite;

import flixel.group.FlxSpriteGroup;


import flixel.sound.FlxSoundGroup;

import flixel.input.keyboard.FlxKey;

import objects.Character;
import objects.StrumNote;

import mechanics.FunkinMechanicSprite;
import backend.utils.MacroTools;

typedef RatingData = {
    var name:String;
    var mod:Float;
}

enum abstract ObjectType(Int) from Int to Int 
{
    var SPRITE = 1;  
    var BIND = 2;  
    var SOUND = 3;
    var ANIMATION = 4;
}

enum abstract TimingType(Int) from Int to Int
{
    var BEAT = 1;
    var STEP = 2;
    var NOTE = 3;
}

enum abstract Rating(Float) from Float to Float
{
    var EARLY = 0.5;
    var PERFECT = 0;
    var LATE = 0.4;
    var MISS = 1;
}

enum abstract CharacterType(Int) from Int to Int
{
    var BF = 1;
    var GF = 2;
    var DAD = 3;
}

class FunkinMechanic
{
    // CLASS VARS //

    var sprites:Map<String, FunkinMechanicSprite> = new Map<String, FunkinMechanicSprite>();
    var sprStrings:Array<String> = [];
    var binds:Map<String, String> = new Map<String, String>();
    var sounds:Map<String, FlxSound> = new Map<String, FlxSound>();
    var animations:Map<String, String> = new Map<String, String>();

    var timingType:TimingType;
    var timingWindows:Map<String, Float> = new Map<String, Float>();
    var timingCue:Float;

    var tmr:FlxTimer;

    var beat:Int;
    var step:Int;

    var curCount:Int = 4;

    var rating:Rating;


    // PLAYSTATE VARS //

    var playState:PlayState;

    var bf:Character;
    var gf:Character;
    var dad:Character;

    var strumNotes:FlxTypedGroup<StrumNote>;

    public function new (instance:PlayState, bf:Character, gf:Character, dad:Character)
    {
        playState = instance;

        this.bf = bf;
        this.gf = gf;
        this.dad = dad;

        tmr = new FlxTimer();

        update(FlxG.elapsed);
    }

    public function add(type:ObjectType, object:Dynamic, name:String)
    {
        switch (type)
        {
            case SPRITE:
                var spr:FunkinMechanicSprite = object;
                sprites.set(name, object);
                sprStrings.push(name);

                trace(object);
                trace(spr);
                trace(sprites);
            
            case BIND:
                var bind:String = object;
                binds.set(name, bind);

                trace(object);
                trace(bind);
                trace(binds);

            case SOUND:
                var sound:FlxSound = object;
                sounds.set(name, sound);

                trace(object);
                trace(sound);
                trace(sounds);

            case ANIMATION:
                var animation:String = object;
                animations.set(name, animation);

                trace(object);
                trace(animation);
                trace(animations);

        }
    }

    public function create()
    {
        for (i in 0...sprStrings.length)
        {
            playState.add(sprites.get(sprStrings[i]));
        }

        curCount = Std.parseInt(Std.string(timingCue));

        beat = playState.curBeat;
        step = playState.curStep;
    }

    public function playSound(sound:String)
    {
        sounds.get(sound).play(true, 0);
    }

    public function playAnimation(animation:String, character:CharacterType)
    {
        var anim:String = animations.get(animation);
        trace("playing: " + anim);
        switch (character)
        {
            case BF:
                bf.playAnim(anim, true);

            case GF:
                gf.playAnim(anim, true);

            case DAD:
                dad.playAnim(anim, true);

        }
    }

    public function pressed(key:String)
    {
        //trace(FlxKey.fromString(binds.get(key)));

        return FlxG.keys.anyPressed([FlxKey.fromString(binds.get(key))]);
    }

    public function justPressed(key:String)
    {
        //trace(FlxKey.fromString(binds.get(key)));

        return FlxG.keys.anyJustPressed([FlxKey.fromString(binds.get(key))]);
    }

    public function update(elapsed:Float)
    {
        if (playState.curBeat != beat)
        {
            beat = playState.curBeat;
            beatHit();
        }

        if (playState.curStep != step)
        {
            step = playState.curStep;
            stepHit();
        }

        //trace("updating");

        //update(elapsed);
    }

    public function beatHit()
    {
        // nothin idiot

        //trace("beat");
    }

    public function stepHit()
    {
        // still nothin doofus

        //trace("step");
    }

    public function judge():Rating
    {
        trace("judging");
        trace(curCount);

        var time:Float = tmr.elapsedTime;
        var count:Int = curCount;

        trace(curCount);
        trace(count);

        if (count == 5)
        {
            count = 0;
        }

        trace(count);

        tmr.cancel();

        switch (timingType)
        {
            case BEAT:
                switch (count)
                {
                    case 2:
                        rating = EARLY;
                        trace("Judged. Time: " + time + ", Rating: " + rating);
                    case 1:
                        rating = EARLY;
                        trace("Judged. Time: " + time + ", Rating: " + rating);
                    case 0:
                        if (time <= (timingWindows.get("perfect") / 1000))
                            rating = PERFECT;
                        else if (time > (timingWindows.get("perfect") / 1000) && (time <= (timingWindows.get("late") / 1000)))
                            rating = LATE;
                        else if (time > (timingWindows.get("late") / 1000) && time <= (timingWindows.get("miss") / 1000))
                            rating = MISS;

                        trace("Judged. Time: " + (time * 1000) + "ms, Rating: " + rating);

                }

                return rating;

            case STEP:
                return rating;
            case NOTE:
                return rating;


        }
    }

    // public function getRatingName(Value:Rating):String
    // {
    //     var map = MacroTools.getMapFromAbstract(Rating, true);
    //     return map.get(Value);
    // }
}