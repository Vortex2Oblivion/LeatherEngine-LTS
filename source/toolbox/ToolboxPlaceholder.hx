package toolbox;

import states.MainMenuState;
import states.MusicBeatState;
import states.PlayState;
import utilities.Options;
import utilities.MusicUtilities;
import ui.Option;
import toolbox.ChartingState;
import toolbox.CharacterCreator;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import lime.utils.Assets;
import toolbox.StageMakingState;
import toolbox.util.NewModState;

class ToolboxPlaceholder extends states.MusicBeatState {
	var curSelected:Int = 0;
	var ui_Skin:Null<String>;

	public static var inMenu = false;

	public var pages:Map<String, Array<Dynamic>> = [
		"Categories" => [
			#if sys
			new GameStateOption("New Mod", 0, new NewModState()),
			#end
			new ToolboxPageOption("Tools", 1, "Tools",),
			new ToolboxPageOption("Documentation", 2, "Documentation")
		],
		"Tools" => [
			new GameStateOption("Charter", 0, new ChartingState()),
			new CharacterCreatorOption("Character Creator", 1, new CharacterCreator("dad", "stage")),
			new GameStateOption("Stage Editor", 2, new StageMakingState("stage")),
			#if MODCHARTING_TOOLS
			new GameStateOption("Modchart Editor", 3, new modcharting.ModchartEditorState())
			#end
		],
		"Documentation" => [
			new WebViewOption("Wiki", 0, "Wiki", "https://github.com/Leather128/LeatherEngine/wiki"),
			new WebViewOption("HScript Api", 1, "HScript Api", "https://vortex2oblivion.github.io/Leather-Engine-Docs/"),
			new WebViewOption("Lua Api", 2, "Lua Api", "https://github.com/Leather128/LeatherEngine/wiki/Lua-API#lua-api-documentation"),
			new WebViewOption("Polymod Docs", 3, "Polymod Docs", "https://polymod.io/docs/")
		]
	];

	public var page:FlxTypedGroup<Option> = new FlxTypedGroup<Option>();
	public static var instance:ToolboxPlaceholder;

	override function create():Void {
		if (ui_Skin == null || ui_Skin == "default")
			ui_Skin = Options.getData("uiSkin");

		if (PlayState.instance == null) {
			pages["Tools"][0] = null;
		}

		MusicBeatState.windowNameSuffix = "";
		instance = this;

		var menuBG:FlxSprite;

		if(Options.getData("menuBGs"))
			if (!Assets.exists(Paths.image('ui skins/' + ui_Skin + '/backgrounds' + '/menuToolbox')))
				menuBG = new FlxSprite().loadGraphic(Paths.image('ui skins/default/backgrounds/menuToolbox'));
			else
				menuBG = new FlxSprite().loadGraphic(Paths.image('ui skins/' + ui_Skin + '/backgrounds' + '/menuToolbox'));
		else
			menuBG = new FlxSprite().makeGraphic(1286, 730, FlxColor.fromString("#E1E1E1"), false, "optimizedMenuDesat");

		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		super.create();

		add(page);

		LoadPage("Categories");

		if (FlxG.sound.music == null)
			FlxG.sound.playMusic(MusicUtilities.GetOptionsMenuMusic(), 0.7, true);
	}

	public static function LoadPage(Page_Name:String):Void {
		inMenu = true;
		instance.curSelected = 0;

		var curPage:FlxTypedGroup<Option> = instance.page;
		curPage.clear();

		for (x in instance.pages.get(Page_Name).copy()) {
			curPage.add(x);
		}

		inMenu = false;
		var bruh:Int = 0;

		for (x in instance.page.members) {
			x.Alphabet_Text.targetY = bruh - instance.curSelected;
			bruh++;
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (!inMenu) {
			if (-1 * Math.floor(FlxG.mouse.wheel) != 0) {
				curSelected -= 1 * Math.floor(FlxG.mouse.wheel);
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			}

			if (controls.UP_P) {
				curSelected --;
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			}

			if (controls.DOWN_P) {
				curSelected ++;
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			}

			if (controls.BACK)
				FlxG.switchState(new MainMenuState());
		} else {
			if (controls.BACK)
				inMenu = false;
		}

		if (curSelected < 0)
			curSelected = page.length - 1;

		if (curSelected >= page.length)
			curSelected = 0;

		var bruh = 0;

		for (x in page.members) {
			x.Alphabet_Text.targetY = bruh - curSelected;
			bruh++;
		}

		for (x in page.members) {
			if (x.Alphabet_Text.targetY != 0) {
				for (item in x.members) {
					item.alpha = 0.6;
				}
			} else {
				for (item in x.members) {
					item.alpha = 1;
				}
			}
		}
	}
}
/**
 * Very simple option that transfers you to a different page when selecting it.
 */
 class ToolboxPageOption extends ui.Option {
	// OPTIONS //
	public var Page_Name:String = "Categories";

	override public function new(_Option_Name:String = "", _Option_Row:Int = 0, _Page_Name:String = "Categories", _Description:String = "Test Description") {
		super(_Option_Name, _Page_Name, _Option_Row);

		// SETTING VALUES //
		this.Page_Name = _Page_Name;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER && Std.int(Alphabet_Text.targetY) == 0 && !ToolboxPlaceholder.inMenu)
			ToolboxPlaceholder.LoadPage(Page_Name);
	}
}