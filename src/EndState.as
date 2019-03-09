package  
{
	import org.flixel.*;
	import game.Assets;
	
	/**
	 * ...
	 * @author imagame
	 */
	public class EndState extends FlxState
	{

		[Embed(source='../assets/panel_big.png')]  private var _panelBigPNG:Class;
		private var _panel: FlxSprite;
		private var _txtTit: FlxText;				
		private var _playButton:FlxButton;
		private var _menuButton:FlxButton;
		
		override public function create():void
		{
			trace("EndState");
			Registry.contadorEstados++;
			add(new FlxText(0, 0, 100, "EndState: " + Registry.contadorEstados)); 
			add(new FlxText(0, 8, 100, "Level: " + Registry.lMgr.idLevel)); 		
			
			//Crear panel
			FlxG.bgColor = 0xff313210;
			_panel = new FlxSprite(0, 0, _panelBigPNG);
			_panel.x = (FlxG.width - _panel.width) / 2;
			_panel.y = (FlxG.height - _panel.height) / 3 *2;
			add(_panel)
			
			_txtTit = new FlxText(_panel.x, _panel.y + 10, _panel.width, "Level Complete");
			_txtTit.setFormat("emulogic", 12, 0xffffffff, "center", 0xff000000);
			add(_txtTit);

			
			//Crear botones de Dialogo
			_playButton = new FlxButton(_panel.x+20, _panel.y+_panel.height - 28, "Continue", onPlay);
			_playButton.color = Assets.COL_BUT;
			_playButton.label.color = Assets.COL_TITBUT;
			add(_playButton);
			
			_menuButton = new FlxButton(_panel.x+_panel.width-_playButton.width-20, _panel.y+_panel.height - 28, "Menu", onMenu);
			_menuButton.color = Assets.COL_BUT;
			_menuButton.label.color = Assets.COL_TITBUT;
			add(_menuButton);
			
			
			//OPTION 1: GAME OVER
			//If game is over display game final stats and present Dialog ( TryAgain/Menu )
			if (Registry.lMgr.bGameOver)
			{
				Registry.lMgr.bGameOver = false;
				_txtTit.text = "Game Over";
				//_txtTit.x = _panel.x + 80;
				_playButton.label.text = "Try Again";
				
			}
			
			//OPTION 2: LEVEL COMPLETE
			else //bLevelComplete=true
			{					
				Registry.lMgr.setLevelComplete(); //realizar las operaciones pertinentes de nivel completado 
				
				//If game is complete display victory message and present Dialog (Menu)
				//OPTION 2A: GAME FINISHED
				if(Registry.lMgr.isGameComplete()) //detecta si bLevelComplete y es el último
				{
					_playButton.visible = false;
					Registry.lMgr.bLevelComplete = false; 
				}
				//Else display level final stats and present Dialog (Continue/Menu)
				//OPTION 2B: NEXT LEVEL
				else
				{
					//_nextlevel = Registry.lMgr.getNextLevel(Registry.lMgr.idLevel)
					Registry.lMgr.setNextLevel(); //obtiene siguiente nivel en función de nivel actual y puerta salidad y lo establece. 
				}
				
			}
			
			FlxG.mouse.show();
		}

		override public function destroy():void
		{
			super.destroy();
			_menuButton = null;
			_playButton = null;
		}
		
		/**
		 * Continue o Try Again playing (next level o actual level)
		 */
		protected function onPlay():void
		{
			_playButton.exists = false
			FlxG.switchState(new StartState());
		}
		
		protected function onMenu():void
		{
			_menuButton.exists = false;
			FlxG.switchState(new MenuState());
		}
		
		protected function onOver():void
		{
			//replace with button mouseOver soundeffect
		}
		
		override public function update():void
		{
			super.update();
			if (FlxG.keys.justPressed("ESCAPE")){
				FlxG.switchState(new MenuState() );
			}
			if (FlxG.keys.SPACE){
				FlxG.switchState(new StartState() );
			}			
		}		
		
	}

}