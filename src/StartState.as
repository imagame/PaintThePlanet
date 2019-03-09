package   
{ 
        import org.flixel.*; 
		
		import game.Assets;
        
        /** 
         * Pre start of a level game 
         * Precondition: LevelManager.idLevel contains the level to start 
         * @author imagame 
         */ 
        public class StartState extends FlxState 
        {                 
                private var _panel: FlxSprite; 
                private var _startButton:FlxButton; 
                private var _txtTit: FlxText; 
                private var _txtObjTiles: FlxText; 
				private var _txtObjName: FlxText;
				private var _txtCapVal: FlxText;
                
                /** 
                 * Create a new StartState object, in charge of: 
                 * - Loading the current level (LevelManager creates a new Level object loading the tmx file identifed by LevelMgr.idLevel) 
                 * - Initialize the level status data (read goals from level and set in lMgr, read resources, set level stats to default) 
                 * Prerequisite: LevelMgr.idLevel must be set 
                 */ 
                override public function create():void 
                { 
                        trace("StartState"); 
                        Registry.contadorEstados++; 
                        add(new FlxText(0, 0, 100, "StartState: " + Registry.contadorEstados));         
                        add(new FlxText(0, 8, 100, "Level: " + Registry.lMgr.idLevel));                         

                        FlxG.bgColor = 0xff313210; 
                        _panel = new FlxSprite(0, 0, Assets._panelBigPNG); 
                        _panel.x = (FlxG.width - _panel.width) / 2; 
                        _panel.y = (FlxG.height - _panel.height) / 3 *2; 
                        add(_panel) 
                        
                        _txtTit = new FlxText(_panel.x, _panel.y + 10, _panel.width, "Level: " + (Registry.lMgr.idLevel+1)); 
						_txtTit.setFormat("emulogic", 12, 0xffffffff, "center", 0xff000000);
                        add(_txtTit); 

                        //Indica al Level Mgr que cargue el nivel actual en la estructura de datos del nivel 
                        Registry.lMgr.loadLevel(); 
                        //Init goals and resources to default level values, and initializes goal tracking variables.
                        Registry.lMgr.initLevelStatus();                         
                       //Init gameplay variables based on profile capacity values 
                        Registry.gpMgr.initPlayerInventoryOnNewLevel(); //Carga el player inventory con la info de initial resources de la definición del nivel actual 
                
                        
                        //Display Level Status 
                        //Muestra la info del level status (válido para inicio de nivel como para continuación del nivel) 
                        _txtObjName = new FlxText(_panel.x, _panel.y + 40, _panel.width, Registry.lMgr.rsrc_nameLevel);
						//_txtObjName.size = 12;
						//_txtObjName.color = 0xffffffff;
						//_txtObjName.shadow = 0xff000000;
						_txtObjName.setFormat("emulogic", 12, 0xffffffff, "center", 0xffff0000);
						add(_txtObjName);
						
						_txtObjTiles = new FlxText(_panel.x + 16, _panel.y + 66, _panel.width-32, "Area to be painted: " + FlxU.floor(Registry.lMgr.goal_numTilesPainted / Registry.lMgr.rsrc_numTiles*100).toString() + "%"); 
						_txtObjTiles.setFormat("emulogic", 8, 0xffffffff, "left", 0xff0000ff);
						add(_txtObjTiles); 
                        
                        //Display Player inventory (level+Game+App) 
                        //Muestra la info del player level inventory (válido para inicio de nivel como para continuación del nivel)
						
						_txtCapVal = new FlxText(_panel.x, _panel.y + 82, _panel.width, "E:[" + Registry.gpMgr.val_amountPaint + "] T:[" + Registry.gpMgr.val_dryPaint + "] S:[" + Registry.gpMgr.val_distanceBomb +"]" );
						_txtCapVal.setFormat("emulogic", 8, 0xffffffff, "center", 0xff0000ff);
						add(_txtCapVal); 

                        
                        _startButton = new FlxButton(FlxG.width/2-40,_panel.y+_panel.height - 28, "Start", onStart); 
                        _startButton.color = Assets.COL_BUT; 
                        _startButton.label.color = Assets.COL_TITBUT;
                        add(_startButton); 
                        
                        FlxG.mouse.show(); 
                } 

                override public function destroy():void 
                { 
                        super.destroy(); 
                        _panel = null; 
                        _txtTit = null; 
                        _startButton = null; 
                        _txtObjTiles = null; 
                } 
                
                protected function onStart():void 
                { 
                        _startButton.exists = false; 
                        FlxG.switchState(new PlayState()); 
                } 
                
                protected function onOver():void 
                { 
                        //replace with button mouseOver soundeffect 
                } 
                
                override public function update():void 
                { 
                        super.update(); 
                        if (FlxG.keys.justPressed("SPACE")){ 
                        //if (FlxG.keys.ESCAPE){ 
                                FlxG.switchState(new PlayState() ); 
                        } 
                } 
        } 

}
