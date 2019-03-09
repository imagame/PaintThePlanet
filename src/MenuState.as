package
{

	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxButtonPlus;
	
	import game.Assets;

	public class MenuState extends FlxState
	{
		[Embed(source = '../assets/game_title.png')] private var _gameTitlePNG:Class;
		[Embed(source = '../assets/button_small_up.png')] private var _buttonSmallUpPNG:Class;
		[Embed(source = '../assets/button_small_down.png')] private var _buttonSmallDownPNG:Class;
		[Embed(source = '../assets/button_small_up_locked.png')] private var _buttonSmallUpLockedPNG:Class;
		[Embed(source='../assets/panel_big.png')]  private var _panelBigPNG:Class;
	   
		private var _panel: FlxSprite;
		private var _title: FlxSprite;
		private var _playButton:FlxButton;
		private var _devButton:FlxButton;
		private var _statsButton:FlxButton
		private var _creditsButton:FlxButton
	   
		private var _txtTit1:FlxText;
		private var _backButton:FlxButton;
	   
		private var _grpMenu: FlxGroup;
		private var _grpLevelSelect: FlxGroup;;
	   
		override public function create():void{
			trace("MenuState");
			Registry.contadorEstados++;
			add(new FlxText(0, 0, 100, "MenuState: " + Registry.contadorEstados));        
			add(new FlxText(0, 8, 300, "Pack: " + Registry.lMgr.idPack+" ("+Registry.lMgr.aLevelPack[Registry.lMgr.idPack].name+")"));                        
						
			FlxG.mouse.reset();
			FlxG.bgColor = 0xff313210;
			_panel = new FlxSprite(0, 0, _panelBigPNG);
			_panel.x = (FlxG.width - _panel.width) / 2;
			_panel.y = (FlxG.height - _panel.height) / 3 *2;
			add(_panel)
		   
						
						//MENU Group
						_grpMenu = new FlxGroup();
						
						_title = new FlxSprite(_panel.x, 0);
						_title.loadGraphic(_gameTitlePNG, false, false, 252, 43);  
						_grpMenu.add(_title);
						
                        
                        _playButton = new FlxButton(FlxG.width/2-40,FlxG.height / 3 + 100, "Play", onLevelSelectPanel);
                        _playButton.color = Assets.COL_BUT;
                        _playButton.label.color = Assets.COL_TITBUT;
                        _grpMenu.add(_playButton);
						
						_statsButton = new FlxButton(FlxG.width/2-40,FlxG.height / 3 + 60, "Stats", onSite);
                        _statsButton.color = Assets.COL_BUT; //  0xffA1A7B7;
						_statsButton.label.setFormat("emulogic", 8, Assets.COL_TITBUT, "center");
                        _grpMenu.add(_statsButton);
                       
						_devButton = new FlxButton(FlxG.width/2-40,FlxG.height / 3 + 60, "imagame", onSite);
                        _devButton.color = Assets.COL_BUT; //  0xffA1A7B7;
						_devButton.label.setFormat("emulogic", 8, Assets.COL_TITBUT, "center");
                        _grpMenu.add(_devButton);
                       
                       
                        //LEVEL SELECTION Group
						_grpLevelSelect = new FlxGroup();
						_txtTit1 = new FlxText(_panel.x, _panel.y + 10, _panel.width, "Level Select");
						_txtTit1.setFormat("emulogic", 12, 0xffffffff, "center", 0xff000000);
                        _grpLevelSelect.add(_txtTit1);
                       
                        var step:int = 24;        //Widht+Height of space for level button
                        var numbutx:int = 5; //Todo: hacer depender de Registry.lMgr.numLevels
                        var numbuty:int = 4; //TODO hacer depender de Registry.lMgr.numLevels
                        var xini:int = (FlxG.width - step * numbutx) / 2;
                        var yini:int = _panel.y + 48; // (FlxG.height - step * numbuty) / 2;
                        var x:int = xini;
                        var y:int = yini;
                       
                       
                       
                        for (var i:int = 0; i < Registry.lMgr.numLevels; i++)
                        {
                               
                                //Creación de array de 1pos, si el lenguaje no permite convertir explictiamente un valor en un array
                                //var val: Array = new Array(1);
                                //val[0] = i+1;
                                //_grpLevelSelect.add(new FlxButtonPlus(x, y, onLevelSelect, val, (i + 1).toString(), 24, 24));
                                //_grpLevelSelect.add(new FlxButtonPlus(x, y, onLevelSelect, [i+1], (i + 1).toString(), 24, 24));
                               
                                var tempButton:FlxButtonPlus = new FlxButtonPlus(x, y, onLevelSelect, [i], (i + 1).toString(), 24, 24);
                               
                                //Detectar si nivel abierto o bloqueado
                                if(! Registry.lMgr.aLevelDef[i].locked)                                
                                {
                                        tempButton.loadGraphic(new FlxSprite(0, 0, _buttonSmallUpPNG), new FlxSprite(0, 0, _buttonSmallDownPNG));
                                       
                                        //tempButton.updateInactiveButtonColors([0xff008000, 0xff008000]);
                                        //tempButton.setMouseOverCallback(buttonOver, [option.state.description]);
                                        //tempButton.setMouseOutCallback(buttonOut);
                                }                                
                                else
                                {                                        
                                        tempButton.loadGraphic(new FlxSprite(0, 0, _buttonSmallUpLockedPNG), new FlxSprite(0, 0, _buttonSmallUpLockedPNG));
                                        tempButton.text = '';
                                        tempButton.active = false;
                                }
                                _grpLevelSelect.add(tempButton);                                
                               
                                x += step;
                                if (x >= step*numbutx+xini)
                                {
                                        x = xini;
                                        y += step;
                                }
                                       
                        }

                                               
                       
                        _backButton = new FlxButton(FlxG.width/2-40,_panel.y+_panel.height - 28, "Back", onBack);
                        _backButton.color = Assets.COL_BUT;
                        _backButton.label.color = Assets.COL_TITBUT;
                        _grpLevelSelect.add(_backButton);

                       
                        add(_grpMenu);
                        add(_grpLevelSelect);
                       
						_grpMenu.exists = true;
						//_grpMenu.active = true;
                        _grpLevelSelect.exists = false;
						//_grpLevelSelect.active = false;
                        //_grpMenu.setAll("active", true); // = true
                       
                        FlxG.mouse.show();
                       
                }
               
                override public function destroy():void
                {
					trace("Menustate:destroy()");
                        super.destroy();
                        _panel = null;
						_title = null;
						_devButton = null;
                        _playButton = null;
                        _backButton = null;
                        
                        _txtTit1 = null;
                        //TODO destroy groups? nullify groups?
						_grpMenu.destroy();
						_grpLevelSelect.destroy();
						_grpMenu = null;
						_grpLevelSelect = null;
                }
               
                override public function update():void
                {
                        super.update();        
                }
               
                protected function onSite():void
                {
                       
                        FlxU.openURL("http://www.imagame.com/");
                }
				
                protected function onLevelSelectPanel():void
                {
					trace("onLevelSelectPanel");
                        _grpMenu.exists = false;
						//_grpMenu.active = false;
                        _grpLevelSelect.exists = true;
						//_grpLevelSelect.active = true;
						//_grpLevelSelect.setAll("exists", true);
						//_grpLevelSelect.setAll("active", true);
						//_grpLevelSelect.revive();
                }
               
                protected function onBack():void
                {
					_grpLevelSelect.exists = false;
					_grpMenu.exists = true;
					_backButton.status = FlxButton.NORMAL; 
                }
               
                protected function onPlay():void
                {
                        _playButton.exists = false;
                        FlxG.switchState(new StartState());
                }
               
               
                protected function onLevelSelect(Level: int):void
                {
                        //replace with button mouseOver soundeffect
                        trace("LeveL: " + Level);
                        Registry.lMgr.idLevel = Level;
						FlxG.fade(0xff000000,0.6,onPlay);
                        //onPlay();
                }
        }
} 