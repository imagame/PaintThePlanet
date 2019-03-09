package
{
	import flash.events.Event;
	import game.Elevator;
	import game.PortalOut;
	import game.PortalIn;
	
	import net.hires.debug.Stats;
	import net.hires.debug.MovieMonitor;
	import org.flixel.system.FlxTile;
	
	import org.flixel.*;
	import org.flixel.FlxSprite;
	import game.Player;
	import game.ControlStruct;
	import game.TiledFloor;
	import game.Assets;

	public class PlayState extends FlxState
	{
		public var estado:uint; 
		public static const STS_INGAME: uint = 0;
		public static const STS_INILVL: uint = 1; //Level complete
		public static const STS_ENDLVL: uint = 2; //Level complete
		public static const STS_ENDGAM: uint = 3; //Game over
		public static const STS_PAUSE: uint = 4;
		
		public var subestado: uint; //0: en juego, 1: level complete, 2: game over
		public static const SBSTS_INIT:uint = 0;
		public static const SBSTS_CONT:uint = 1;
		public static const SBSTS_END:uint = 2;		
		
		public var lvlMap: FlxTilemap;
		public var scene: TiledFloor;
		public var portalsGrp: FlxGroup;
		public var elevatorsGrp: FlxGroup;
		public var player: Player;
	
		//public var elevator1: Elevator;
		public var objectsGrp: FlxGroup;
		public var paintTilePool: FlxGroup;
		
		protected var _imgBg:FlxSprite;
		protected var _imgBgClass:Class;
		
		protected var _hudtilepaintcont: FlxText;
		protected var _hud:FlxGroup;
		protected var _msg:FlxGroup;
		
		private var _portalOutID: int; //ID del portal por el que sale de nivel el player (-1 si no ha salido)
				
	
	/*	
		[Embed(source='/../data/backgrounds/mr_mnml_mountain_bg.png')] private var BackgroundImageFile:Class;
		[Embed(source = 'sprites/backgroundRocks68x68.png')] static public var BackgroundRocks:Class;	
		[Embed(source = 'MapFiles/Stage2/MapCSV_Map1_BackgroundRocks.txt', mimeType = "application/octet-stream")] static public var BackgroundRocksMap2:Class;
*/
		
		
		override public function create():void
		{
			trace("PlayState");		
			Registry.contadorEstados++;
			add(new FlxText(0, 0, 100, "PlayState: " + Registry.contadorEstados)); 	
			add(new FlxText(0, 8, 100, "Level: " + Registry.lMgr.idLevel)); 			
			
			FlxG.mouse.hide();
			Registry.playstate = this;
			
			//El nivel ya está cargado en el objeto Level del LevelMgr
			//if (Registry.playstate == null)
			//	trace ("playstate null");
			
			//Background image
            _imgBg = Registry.lMgr.levelObj.createBackground();
			
			//Generación del lvlMap, generarse los objetos del escenario y generarse las entidades del nivel
			lvlMap = Registry.lMgr.levelObj.createLvlMap();
			for (var i:uint = Assets.MAP_TILEID_VOIDINI; i <= Assets.MAP_TILEID_VOIDEND; i++)
				lvlMap.setTileProperties(i, FlxObject.NONE, vacioTileCallback); //TODO activar param Range cuando tiles vacios mayor que 1
			//lvlMap.setTileProperties(2, FlxObject.NONE, vacioTileCallback); //TODO activar param Range cuando tiles vacios mayor que 1
			//lvlMap.setTileProperties(3, FlxObject.NONE, vacioTileCallback); //TODO activar param Range cuando tiles vacios mayor que 1
			
			//Objects
			objectsGrp = Registry.lMgr.levelObj.createObjects();
			//elevator1 = new Elevator(25 * 16, 6 * 16, 5 * 16);
			
			//Portales	
			portalsGrp = Registry.lMgr.levelObj.createPortals();
			
			//Elevators
			elevatorsGrp = Registry.lMgr.levelObj.createElevators();
			
			//Player
			player = Registry.lMgr.levelObj.createPlayer();	 //Crea Player y lo ubica en el PortalIn de entrada que ????
			
						
			//HUD
			_hud = new FlxGroup();				
			//Hud - Mensaje inicio
			_msg = new FlxGroup();
			_msg.add(new FlxSprite(0,FlxG.height-22).makeGraphic(FlxG.width,24,0xff131c1b));
			_msg.add(new FlxText(0,FlxG.height-22,FlxG.width,"GO AND PAINT!!").setFormat(null,16,0xd8eba2,"center"));
			_msg.visible = true;
			//_hud.add(_msg);		
			//Hud Score: tiles painted
			_hudtilepaintcont = new FlxText(FlxG.width-100, 0, 100);
			_hudtilepaintcont.setFormat(null, 8, 0xffff0000, "right");
			hudUpdateScore();
			_hud.add(_hudtilepaintcont);
			//Hud general
			_hud.setAll("scrollFactor", new FlxPoint(0, 0));
			
			//Generación de estructuras para interaccionar con el escenario 
			//PaintTile Pool
			paintTilePool = new FlxGroup(500); //TODO 50: hacerlo depender de Registry.lMgr.rsrc_numTiles
			scene = new TiledFloor(paintTilePool);
			scene.initPool(500);

			//Añadir en orden sprites a la escena
			
			add(_imgBg);
			add(lvlMap);
			add(paintTilePool);
			for each(var portal:FlxSprite in portalsGrp.members)
				add(portal)
			for each(var elevator:FlxSprite in elevatorsGrp.members)
				add(elevator);
				
			//add(_spawners)
			//add(enemies)
			//if(objectsGrp != null) 	add(objectsGrp) 
			
			add(player);
			//FlxG.worldBounds = new FlxRect(0, 0, level.width, level.height);
			FlxG.camera.setBounds(0, 0, lvlMap.width, lvlMap.height, true); // Registry.lMgr.levelObj.tmx.width * Registry.lMgr.levelObj.tmx.tileWidth, Registry.lMgr.levelObj.tmx.height * Registry.lMgr.levelObj.tmx.tileHeight);
			FlxG.camera.follow(player, FlxCamera.STYLE_PLATFORMER);			
			add(_hud);
			
			//Iniciar estado de juego
			estado = STS_INILVL;
			subestado = SBSTS_INIT;
			
			//TMP: Estadísticas
			//FlxG.stage.addChild( new Stats() );
			if (Registry.monitor == null)
			{
				Registry.monitor = new MovieMonitor();
				FlxG.stage.addChild( Registry.monitor );
			}
		}

		override public function destroy():void
		{
			//super.destroy(); //Destruye todos los objetos flixel added al estado
			
			//Destruir nivel
			//lvlMap.destroy(); //Ya se ha ejecutado destroy(). Porque?
			lvlMap = null;
			
			//Destruir entidades
			player.destroy();
			player = null;
			_hud = null;
			_msg = null;
			_hudtilepaintcont = null;
			
			//Destruir estructuras
			portalsGrp.destroy(); 
			portalsGrp = null;
			elevatorsGrp.destroy(); 
			elevatorsGrp = null;
			scene.destroy();
			scene = null
			
			paintTilePool.destroy();
			
			super.destroy();

		}
		
		override public function update():void
		{
			//trace("Playstate->update() " + FlxU.getTicks() + " x: "+player.x);
			super.update();
			
			switch(estado)
			{
				case STS_INGAME:  //estado de juego
					//collision logics
					FlxG.collide(player, lvlMap);
					//lvlMap.overlapsWithCallback(player, FlxObject.separate);
					FlxG.overlap(player, portalsGrp, notifyOverlapPortal); // , notifyFunc, ProcessFun) 
					FlxG.overlap(player, elevatorsGrp, notifyOverlapElevator);
					
					//Finalizar juego: 1) Fin nivel (Que implica o no Finalización del juego) 2) Game over
					if (FlxG.keys.F1) {
						estado = STS_ENDLVL;
						subestado = SBSTS_END;
					}
					if (FlxG.keys.F2) {
						estado = STS_ENDGAM;
						subestado = SBSTS_INIT;
					}

					//Game quit
					if (FlxG.keys.ESCAPE) {
						//Registry.lMgr.bLevelComplete = false;
						FlxG.switchState(new MenuState() );
					}
					break;
				
				case STS_INILVL:	//estado de inicio de nivel, o reinicio tras muerte de player
					switch(subestado)
					{
						case SBSTS_INIT: 
							//ToDo Mensaje Ready con timer para habilitar player 
							trace("PlayState [STS_INILVL::SBSTS_INIT]"); 
							if(chkInitReady()) //Necesario para situación de Reinit después de muerte player
								subestado = SBSTS_END;
							break; 
						//case SBSTS_CONT:
							//Mensaje inicio partida (asíncrono)
							//break;
						case SBSTS_END: 
							trace("PlayState [STS_INILVL::SBSTS_END]"); 
							//Habilitar entidades
							player.onActivate(); //Activa player forzándolo a entrar en Portal-In
							estado = STS_INGAME;                                         
							break; 
					}
					break;
				
				case STS_ENDLVL:	//estado de fin de nivel
					switch(subestado)
					{
						case SBSTS_INIT:
							if (FlxG.keys.F1)
								subestado = SBSTS_END;
							break;
						case SBSTS_END:
							//TODO Mensaje con timer indicando portalid de salida
							Registry.lMgr.bLevelComplete = true;
							Registry.lMgr.idPortalOut = _portalOutID; //Establece el id del portal de salida por el que se ha completado el nivel
							FlxG.switchState(new EndState() );
							break;
					}								
					break;
					
				case STS_ENDGAM:	//estado de game over
					Registry.lMgr.bGameOver = true;
					FlxG.switchState(new EndState() );	
					break;
				
				case STS_PAUSE:
					//Todo Estado Pausa PlayState
					break;
			}			 
		}
	
		//Callbacks asociados a Tipo de Tiles de LevelMap, llamados al colisionar con Player
		
		/**
		 * Callback asociado a tipo de tiles VACIO de LevelMap
		 * @param	Tile
		 * @param	Obj
		 */
		public function vacioTileCallback(Tile:FlxTile, Obj: FlxObject):void
		{
			var vx:uint = Tile.mapIndex % lvlMap.widthInTiles;
			var vy:uint = Tile.mapIndex / lvlMap.widthInTiles;
			
			if (Obj is Player)
			{
				var px:Number = (Obj as Player).x;
				var py:Number = (Obj as Player).y;
				if (!player.bOnElevator) //player.alive)
				{
					if( player.OnCollisionSpace(vx, vy, Tile.mapIndex)) //check collision with space and if true player kill process starts.
					{
						trace("REINIT LEVEL");
						estado = STS_INILVL;	
						subestado = SBSTS_INIT;
					}
				}
			//trace("=> " + FlxU.getTicks() + "  Tile Vacio: " + Tile.mapIndex + " [" + vx + "," + vy + "]  X,Y: " + px + "," + py + " COL: " + player.chkTileCollision(vx, vy, Tile.mapIndex)); 			
			}
		}
		
		/**
		 * Overlap function called when player collides with any Elevator
		 * @param	Obj1	Player	
		 * @param	Obj2	Elevator
		 */
		public function notifyOverlapElevator(Obj1:FlxObject, Obj2:FlxObject)
		{
			//trace("Elevator: " + Obj2.x);
			player.onElevator(Obj2.ID);
		}
		
		/**
		 * Overlap function called when player collides with any portal included in portal list.
		 * @param	Obj1	Player
		 * @param	Obj2	Portal
		 */
		public function notifyOverlapPortal(Obj1:FlxObject, Obj2:FlxObject)
		{
			trace("Portal: " + Obj1.x);
			if (Obj2 is PortalOut)
			{
				if ((_portalOutID = (Obj2 as PortalOut).actorIn(player)) >= 0) //Si portal está abierto y no está en uso
				{
					trace("EXIT LEVEL");
					estado = STS_ENDLVL;					
					subestado = SBSTS_INIT;			
				}
			}
			/*TODO regenerar pintura
			 *
			else if (Obj2 is PortalIn)
				(Obj2 as PortalIn).actorIn(player); //recarga pintura si depósito no está al máximo
			*/
		}
		
		/**
		 * 
		 * @return	If 
		 */
		private function chkInitReady():Boolean
		{
			return player.alive;
		}
		
		
		
		public function hudUpdateScore():void
		{
			_hudtilepaintcont.text = Registry.lMgr.contTilesPainted.toString() +" /" + Registry.lMgr.goal_numTilesPainted.toString();
		}
	}
}

