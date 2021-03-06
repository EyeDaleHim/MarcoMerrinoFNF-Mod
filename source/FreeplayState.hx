package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import lime.utils.Assets;

using StringTools;

class FreeplayState extends MusicBeatState
{
	public static var lastSelected:Int = 0;
	
	var songs:Array<SongMetadata> = [];
	var difficulty:Array<Dynamic> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var songDiff:FlxText;
	var totalText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIconOld> = [];

	override function create()
	{
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));

		Settings.init();

		if (lastSelected != 0)
			curSelected = lastSelected;
		
		for (i in 0...initSonglist.length)
		{
			songs.push(new SongMetadata(initSonglist[i], 1, 'gf'));
		}

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		if (StoryMenuState.weekUnlocked[2] || isDebug)
			addWeek(['Marcovid'], 1, ['marco']);

		difficulty = [1, 'achoo'];

		// LOAD MUSIC

		// LOAD CHARACTERS

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIconOld = new HealthIconOld(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.65, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.60), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		var infoBG:FlxSprite = new FlxSprite(scoreBG.x, 0 + scoreBG.height * 1.4).makeGraphic(Std.int(FlxG.width * 0.45), 66, 0xFF000000);
		infoBG.alpha = 0.6;
		add(infoBG);

		songDiff = new FlxText(infoBG.x + 6, infoBG.y + 6);
		songDiff.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		add(songDiff);

		totalText = new FlxText(FlxG.width * 0.85, FlxG.height - 28, 0, "", 24);
		totalText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		add(totalText);

		diffText = new FlxText(scoreText.x + 128, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		diffText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		diffText.alpha = 0;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
		{
			songCharacters = ['face'];
			FlxG.log.error("unknown character " + songCharacters + " in song" + songs);
		}

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		lastSelected = curSelected;

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		totalText.text = curSelected + 1 + " / " + songs.length + " Songs";
		songDiff.text = "Difficulty: " + difficulty[curSelected];

		var coolLerpScore:Int = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));
		var coolScore:String = FlxStringUtil.formatMoney(coolLerpScore, false, true);
		totalText.y = Math.floor(FlxMath.lerp(totalText.y, FlxG.height - 28, 0.6));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST: " + coolScore;
		// scoreText.text = "PERSONAL BEST: " + coolScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			FlxG.switchState(new OldNewState());
			
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);

			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = songs[curSelected].week;
			PlayState.lastSelected = lastSelected;
			trace('CUR WEEK' + PlayState.storyWeek);
			trace(poop, songs[curSelected].songName.toLowerCase());
			LoadingState.loadAndSwitchState(new PlayState());
			
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		diffText.text = "< ";
		
		switch (curDifficulty)
		{
			case 0:
				diffText.text += "EASY >";
			case 1:
				diffText.text += 'NORMAL >';
			case 2:
				diffText.text += "HARD >";
		}
	}

	function changeSelection(change:Int = 0)
	{
		// NGio.logEvent('Fresh');
		// FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		// lerpScore = 0;
		#end

		#if PRELOAD_ALL
		// FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		#end

		var bullShit:Int = 0;

		totalText.y -= 25;
		
		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			item.selected = false;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.selected = true;
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
	override function openSubState(SubState:FlxSubState)
		{
			
			super.openSubState(SubState);
		}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var difficulty:Float = 0;

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}
