package  
{
	import flash.events.DataEvent;
	import flash.display.Bitmap;
	import game.Elevator;
	import net.pixelpracht.tmx.TmxLevel;
	import net.pixelpracht.tmx.TmxObject;
	import net.pixelpracht.tmx.TmxObjectGroup;
	import org.flixel.*;
	
	import game.Player;
	import game.ControlStruct;
	import game.PortalIn;
	import game.PortalOut;
	import game.Assets;
	

	
	/**
	 * Contiene la definición completa de un Nivel de juego de PtP 
	 * Se encarga de:
	 * 1- OPERATIVA DE CARGA/LIBERACION DE DEFINICION DEL NIVEL
	 * - Cargar un fichero de nivel tmx en la estructura TmxMap contenida en TmxLevel
	 * - Limpiar la estructura de nivel
	 * 2- SERVICIOS DE INFORMACION DEL NIVEL:
	 * - Ofrece rutinas para la obtención de info de goals and constraints de la definición del nivel
	 * 3- GENERACIÓN DEL MAPA Y CONTENIDO DEL NIVEL:
	 * - Generación de mapa del juego
	 * - Generación de objetos y entidades contenidas en el mapa
	 * - Generación de estructuras de control (necesarias para el seguimiento del pintado del escenario) ???Aquí o en LevelMgr?
	 * @author imagame
	 */
	public class Level extends TmxLevel
	{
		//Constantes a usar como nombres identificadores (valor atributo "name" en los ficheros de niveles .tmx
		
		static public const MAINLAYER_NAME:String = "Main";	//Id de Layer
		static public const MAINTILESET_NAME:String = "Tileset_Main";	//Id de Tileset graphics
		static public const CTRLLAYER_NAME:String = "Control";	//Id de Layer
		static public const CTRLTILESET_NAME:String = "Tileset_Ctrl";	//Id de Tileset	control	
		static public const BG_NAME:String = "img_bg";	//Id de Property de Map
		static public const OBJECTGROUP_NAME_PORTALS:String = "Portals";
		static public const OBJECTGROUP_NAME_ENTITIES:String = "Entities";
		
		static public const OBJECT_TYPE_PLAYER:String = "Player";

				
		protected var _lmgr: LevelManager;
		protected var _lpack: ILevelPack;
		
		public function Level(Mgr: LevelManager, Lvl:int) 
		{
			_lmgr = Mgr;
			_lpack = _lmgr.aLevelPack[_lmgr.idPack].packObj;
			
			//obtener ref a clase correspondiente al fichero .tmx asociado al nivel <Level> del pack <_lmgr.idPack>
			var levelClass: Class = _lpack.getMapClassRef(Lvl);
			super(Lvl, levelClass);
			
			//Parsear tmx file y cargar en estructura de objetos tmx
			loadTmxFile();
			
			//Asignar imagenes asociadas a tilesets
			var tsClass: Class = _lpack.getTilesetClassRef( tmx.getTileSet(MAINTILESET_NAME).imageSource );
			tmx.getTileSet(MAINTILESET_NAME).image = (new tsClass() as Bitmap).bitmapData;
			
			
		}
		
		public function destroy():void
		{
			//TODO Level.destroy()
			//unloadTmxFile() ???
			//Borrar bitmapDatas de tileset.image
			
		}
		

		///////////////////////////////////// Funciones de generación de Mapa, objetos y entidades contenidas en el TmxMap apuntado por <tmx>
		
		public function createBackground():FlxSprite
		{
			var imgBg:FlxSprite = new FlxSprite(0,0,_lpack.getImgBgClassRef(tmx.properties[BG_NAME]));

			//imgBg.scale.x = imgBg.scale.y = 1;
            //imgBg.alpha = 1.9;
            imgBg.scrollFactor.x = 0.2; // 0.25;
            imgBg.scrollFactor.y = 0.2; // 0.25;
	
			return imgBg;
		}
		
		public function createLvlMap():FlxTilemap
		{
			//Mapa = new FlxTilemap(); 
			var Mapa:FlxTilemap = new FlxTilemap();
			
			//Obtiene mapa de tiles del nivel a partir del Layer Main, en formato csv
			var mapCsv:String = tmx.getLayer(MAINLAYER_NAME).toCsv(tmx.getTileSet(MAINTILESET_NAME));
			//Carga Mapa
			Mapa.loadMap( mapCsv, 
						_lpack.getTilesetClassRef(tmx.getTileSet(MAINTILESET_NAME).imageSource),
						tmx.tileWidth,
						tmx.tileHeight,
						FlxTilemap.OFF,
						0,
						Assets.MAP_TILESET_DRAWINDEX,
						Assets.MAP_TILESET_COLLIDEINDEX
						);
																	
			return Mapa;
		}
		
		/**
		 * Creates a control map array from a Control Layer, to check and track painted tiles.
		 * Set default valuest to:
		 * -1: tile not paintable/not accesible
		 * 0: tile not paintable/accesible
		 * 1: tile paintable and not painted
		 * @return	ControlStruct filled with default level control data: 
		 */
		public function createLvlCtrl():ControlStruct
		{
			//Read control layer and convert to a unidim array.
			var mapCSV: String = tmx.getLayer(CTRLLAYER_NAME).toCsv();		
			var firstGID: uint = tmx.getTileSet(CTRLTILESET_NAME).firstGID;
			var ctrl: Array = new Array();			
			var columns:Array;
			var rows:Array = mapCSV.split("\n");
			var ht:uint = rows.length;
			var wt:uint = 0;
			var row:uint = 0;
			var column:uint;
			var val:uint = 0;
			while(row < ht)
			{
				columns = rows[row++].split(",");
				if(columns.length <= 1)
				{
					ht = ht - 1;
					continue; 
					
				}
				if(wt == 0)
					wt = columns.length;
				column = 0;
				while (column < wt)
				{
					val = uint(columns[column++]) - firstGID;
					ctrl.push(val);
					//ctrl.push(uint(columns[column++]));
					//ctrl.push(uint(columns[column++]) - tmx.getTileSet(CTRLTILESET_NAME).firstGID - 1); //TMP +1 mientrar no reordene tileset (1º pintable)
					//ctrl.push(uint(columns[column++]) - firstGID - 1); //TMP +1 mientrar no reordene tileset (1º pintable)
				}
			}
		
			//Create control structure and fill with control layer data
			return new ControlStruct(ctrl, wt, ht);
		}
	
		public function createPlayer():Player
		{
			//create the flixel implementation of the objects specified in the ObjectGroup 'objects'
			var group:TmxObjectGroup  = tmx.getObjectGroup(OBJECTGROUP_NAME_ENTITIES);
			if (group == null) {
				trace("ERR: No Objectgroup " + OBJECTGROUP_NAME_ENTITIES + " in tmx file");
				return null;
			}
			else
			{
				for each(var object:TmxObject in group.objects)
					if (object.type == OBJECT_TYPE_PLAYER)
					{
						var player: Player = new Player(0); //TODO: Id del portalIn. (0..N-1)
						return player;
					}
			}
			trace("ERR: No type object " + OBJECT_TYPE_PLAYER + " in objectgroup " + OBJECTGROUP_NAME_ENTITIES  );
			return null;			
		}
		
		public function createPortals():FlxGroup
		{
			var objPortalOut: PortalOut;
			var group:TmxObjectGroup  = tmx.getObjectGroup(OBJECTGROUP_NAME_PORTALS);
			if (group == null) {
				trace("ERR: No Objectgroup " + OBJECTGROUP_NAME_PORTALS + " in tmx file");
				return null;
			}
			else
			{
				var grp:FlxGroup = new FlxGroup();
				var idPortalIn:int = 0;
				var idPortalOut:int = 0;
				for each(var obj:TmxObject in group.objects)
					switch(obj.type)
					{
					case 'Portal_In':
						grp.add(new PortalIn(idPortalIn++, obj.x, obj.y));
					break;
					case 'Portal_Out':
						grp.add(new PortalOut(idPortalOut++, obj.x, obj.y));
					break
					}
				return grp;
			}		
		}

		public function createElevators():FlxGroup
		{
			var grp:FlxGroup = new FlxGroup();
			var idElevator:int = 0;
			grp.add(new Elevator(idElevator, Elevator.SIZE_SMALL, 25 * 16, 6 * 16, 5 * 16, FlxObject.PATH_HORIZONTAL_ONLY, 32, 1));
			
			idElevator++;
			grp.add(new Elevator(idElevator, Elevator.SIZE_MEDIUM, 23 * 16, 8 * 16, 8 * 16, FlxObject.PATH_HORIZONTAL_ONLY, 32, 1));
			
			/*
			for (var i:int; i < 10; i++)
			{
			idElevator++;
			grp.add(new Elevator(idElevator, 23 * 16, 8+i * 16, 8 * 16, FlxObject.PATH_HORIZONTAL_ONLY,10, 2));
			}
			*/
			
			return grp;
		}
		
		public function createObjects():FlxGroup
		{
			var objGrp: FlxGroup = new FlxGroup()
		   
			//create the flixel implementation of the objects specified in the ObjectGroup 'objects'
			var group:TmxObjectGroup  = tmx.getObjectGroup('Objetos');
			if (group == null)
				return null;
				
			for each(var object:TmxObject in group.objects)
				
				//spawnObject(object, objGrp)
				trace("OBJETO: " + object.name + "  Type: "+object.type);
								   
			return objGrp;
		}
               
		
               
		//---------------------------------------------------------------------------------------------
	   
		private function spawnObject(obj: TmxObject, ObjGrp:FlxGroup):void
		{
			trace("Name: " + obj.name + "  type:" +obj.type);
		}
		
		/*
		private function spawnObject(obj:TmxObject, ObjGrp:FlxGroup):void
		{
			//Add game objects based on the 'type' property
			switch(obj.type)
			{
					case "elevator":
							ObjGrp.add(new Elevator(obj.x, obj.y, obj.height));
							return;
					case "pusher":
							ObjGrp.add(new Pusher(obj.x, obj.y, obj.width));
							return;
					case "player":
							ObjGrp.add(new Player(obj.x,obj.y));
							return;
					case "crate":
							ObjGrp.add(new Crate(obj.x,obj.y));
							return;
			}
               
			//This is the thing that spews nuts and bolts
			if(obj.type == "dispenser")
			{
					var dispenser:FlxEmitter = new FlxEmitter(obj.x,obj.y);
					dispenser.setSize(obj.width,obj.height);
					dispenser.setXSpeed(obj.custom['minvx'],obj.custom['maxvx']);
					dispenser.setYSpeed(obj.custom['minvy'],obj.custom['maxvy']);
					dispenser.createSprites(ImgGibs,120,16,true,0.8);
					dispenser.start(false,obj.custom['quantity']);
					add(dispenser);
			}
		} 
		*/
		
		
		/*
		public function loadLevelContent(Level: int)
		{
			idLevel = Level;
			
			if (levelMap != null)
			{
				levelMap = null;
			}
			levelMap = new FlxTilemap();
			levelMap.loadMap(FlxTilemap.arrayToCSV(_lmgr.aLevelDef[idLevel].map, 40), FlxTilemap.ImgAuto, 0, 0, FlxTilemap.AUTO);
		}
		*/
		
		/*
		public function loadState()
		{
			//TODO: Crea objetos flixel para el mapa y objetos del nivel cargado en <tmx>
			levelMap = new FlxTilemap();
			//levelMap.loadMap(FlxTilemap.arrayToCSV(_lmgr.aLevelDef[idLevel].map, 40), FlxTilemap.ImgAuto, 0, 0, FlxTilemap.AUTO);
			
			//var mapCsv:String = tmx.getLayer('Capa1').toCsv(tmx.getTileSet('Tema1'));
			var mapCsv:String = tmx.getLayer('Capa1b').toCsv(tmx.getTileSet('Tileset1'));
			levelMap.loadMap( mapCsv,ImgTiles,32,32,FlxTilemap.OFF,0,1,16);
		}
		*/
	}

}