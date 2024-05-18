function onCreate()
	setScrollFactor('gfGroup', 0.95, 0.95);
	setProperty('gfGroup.antialiasing', true);
	setObjectOrder('gfGroup', 0);

	makeLuaSprite('sky', 'class/sky', -440, -235);
	scaleObject('sky', 0.8, 0.8);
	setScrollFactor('sky', 0.4, 0.4);
	setProperty('sky.antialiasing', true);
	setObjectOrder('sky', 1);

	makeLuaSprite('bg', 'class/bg', -380, -150);
	scaleObject('bg', 0.8, 0.8);
	setScrollFactor('bg', 1, 1);
	setProperty('bg.antialiasing', true);
	setObjectOrder('bg', 2);

	makeLuaSprite('proj1', 'class/proj1', -425, -170, false, true, 1, 1);
	scaleObject('proj1', 0.8, 0.8);
	setScrollFactor('proj1', 1, 1);
	setProperty('proj1.antialiasing', true);
	setObjectOrder('proj1', 3);

	makeLuaSprite('proj2', 'class/proj2', -385, -110, false, true, 1.5, 2);
	scaleObject('proj2', 0.8, 0.8);
	setScrollFactor('proj2', 1, 1);
	setProperty('proj2.antialiasing', true);
	setObjectOrder('proj2', 4);

	makeLuaSprite('proj3', 'class/proj2', -585, -360, false, true, 1.25, 3);
	scaleObject('proj3', 0.8, 0.8);
	setScrollFactor('proj3', 1, 1);
	setProperty('proj3.antialiasing', true);
	setObjectOrder('proj3', 5);

	setScrollFactor('dadGroup', 1, 1);
	setProperty('dadGroup.antialiasing', true);
	setObjectOrder('dadGroup', 6);

	setScrollFactor('boyfriendGroup', 1, 1);
	setProperty('boyfriendGroup.antialiasing', true);
	setObjectOrder('boyfriendGroup', 7);

	makeLuaSprite('deadtable', 'class/deadtable', -380, -160, true);
	scaleObject('deadtable', 0.8, 0.8);
	setScrollFactor('deadtable', 1, 1);
	setProperty('deadtable.antialiasing', true);
	setObjectOrder('deadtable', 8);

	makeLuaSprite('fg', 'class/fg', -115, -130);
	scaleObject('fg', 0.8, 0.8);
	setScrollFactor('fg', 1.1, 1.1);
	setProperty('fg.antialiasing', true);
	setObjectOrder('fg', 9);

	makeLuaSprite('glow', 'class/glow', -380, -150);
	scaleObject('glow', 0.8, 0.8);
	setScrollFactor('glow', 1, 1);
	setProperty('glow.antialiasing', true);
	setBlendMode("glow", "add")
	setObjectOrder('glow', 10);

	makeLuaSprite('shadow', 'class/shadow', -385, -150);
	scaleObject('shadow', 0.8, 0.8);
	setScrollFactor('shadow', 1, 1);
	setProperty('shadow.antialiasing', true);
	setBlendMode("shadow", "difference")
	setObjectOrder('shadow', 11);

	close(true);
end