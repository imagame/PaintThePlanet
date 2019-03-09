package  
{
	import game.LevelPack0;
	import Level;
        /**
         * Game levels manager
         * - Level structure definition + level structure manager
         * - Levels definition + level definition manager
         * - Structure status
         * - Level status
         * @author imagame
         */
        public class LevelManager
        {
			
				//Level Packs
				public var aLevelPack: Array;	//Array de packs de niveles (cada elemento una clase que implementa ILevelPack)
				
                //Level Pack Definition
                public var idPack: int;	//0..N
				private var _packDef: Object;		//		
                public var numLevels: int;         //number of levels included in the current pack structur
                
				//Levels Definition
				public var aLevelDef: Array; //Array de niveles. Atributos: abierto(T)/bloqueado(F) en inicio
				public var levelObj: Level;	//Nivel cargado de fichero 
				//Level Goals&Resource&params&rewards definition
                public var goal_numTilesPainted: int; //nº de tiles minimos que deben pintarse para pasar el nivel
				public var rsrc_numTiles: int; //nº de tiles del nivel que pueden ser pintados
				public var rsrc_contBombs: int; //nº de bombas iniciales por defecto
				public var rsrc_amountPaint: int; //Nº de unidades de pintura disponibles en la mochila del player
				//public var reward_contBombs: int;
				public var rsrc_nameLevel: String;
				
				public var tileWidth: int;
				public var tileHeight: int;
				public var param_effort: int; //Nº de unidades de pintura necesarios para pintar un tile
				
               
                //Level Status
                public var idLevel: int;   //Actual level: 0..numlevels-1 (-1: not initialized)
                public var bLevelComplete: Boolean; //indicador de que nivel actual ha sido recien completado (activable por PlayState)
				public var idPortalOut: int;	//Portal de salida del nivel completado
                public var bGameOver: Boolean;
                public var timeGameHours: int; //Nº de horas jugadas en el nivel
				public var timeGameMinutes: int; //Nº de minutos jugados en el nivel
				public var timeGameSeconds: int; //Nº de segundos jugados en el nivel              
				
				//Goals&Resource status
                public var contTilesPainted: int; //nº de tiles actuales pintados del color <paintColor>
				public var contTilesDeleted: int; //nº de tiles actuales pintados del color <paintColor>
                
				//Control structures
				//TODO public var painTilePool: ObjectPool; 
				   
				
               
                public function LevelManager()
                {
					trace("LevelManager");
					
					aLevelPack = new Array();
					//TODO: Lectura del archivo XML que contiene los packs disponibles (id, nombre)
					var olevelPack = new Object();
					olevelPack.id = 0;
					olevelPack.name = "Initial Levels";
					olevelPack.packObj = new LevelPack0(); //PTE: Tipo LevelPack 
					olevelPack.status = 1; //open by default (other status: to be adquired,....)
					aLevelPack.push(olevelPack);
					//aLevelPack[0] = { id:0, name:"Initial Levels", numLevels: 20 };
					
					//Establece primer pack por defecto
					idPack = -1;
					setLevelPack(0);
					
					//Establece 
					idLevel = -1;
					levelObj = null;
					
					//Crea estructuras control
					//paintTilePool = new ObjectPool(PaintTile);
                }

				/////////////////////////////////////////////////////////////////////////  PACK

				/**
				 * Set a level Pack for the game. Loads its level definition, necessary por the Menu State. 
				 * Rest of levels definition in the proper level tmx file.
				 * @param	Id identificator of the pack: 0..N
				 */              
                public function setLevelPack(Id: int): void
                {
					if (idPack != Id)
					{
						clearLevelPack(idPack);
						idPack = Id;
						
						loadLevelPack();	//Carga estructura de niveles incluida en pack actual					
                        loadLevelsDefinition(); //Cargar info de definición de niveles necesaria para Menu de selección de Nivel. R
					}
                }
               
				private function clearLevelPack(Id:int): void
				{
					for each(var leveldef:Object in aLevelDef)
						leveldef = null;
					aLevelDef = null;
					_packDef = null
					
					//TODO borrar nivel
				}
				
                /**
                 * Load de level structure included in the current level pack
                 */
                protected function loadLevelPack():void
                {                        
                        //Lectura de datos del level pack idPack
                        //TODO: Lectura de datos del fichero xml indicado por variable idPack "pack"+idpack+".xml"
						//- Nºniveles
						//- Inicio: Número niveles de inicio, lista niveles,
						//- Final: Número niveles 
						//- Conexiones: Idnivel, portalout, idNivel, portalin
						_packDef = new Object();
						_packDef.numLevels = 20;
						_packDef.numLevelsIni = 1;
						_packDef.numLevelsEnd = 1;
						_packDef.aLevelsIni = [0]; //niveles de inicio de juego
						_packDef.aLevelsEnd = [17, 19]; //niveles de finalización de juego
						_packDef.aConnect = [
												[{pout:0,level:1,pin:0}], //Conexiones de salida del nivel 0 (sale por portal 0 para entrar por portal 0 del nivel 1)
												[{pout:0,level:2,pin:0},{pout:1,level:3,pin:0}], //Conexiones de salida del nivel 1
												[{pout:0,level:3,pin:1}] //Conexiones de salida del nivel 2
											]	//array de numlevels pos que contiene obj de conexión de puertas salida.
						//EndToDo
						numLevels = _packDef.numLevels;
                }
               
				
                /////////////////////////////////////////////////////////////////////////  LEVELS DEFINITION

                protected function loadLevelsDefinition():void
                {           
					//Lectura de datos de definición de los niveles del pack idPack
					//TODO: Lectura fichero xml indicado por variable idPack "pack"+idpack+"_"+idlevel+".xml"
					aLevelDef = new Array();
					for (var i:int = 0; i < numLevels; i++)
					{
						var levelDef = new Object();
						//Identification
						levelDef.id = i;
						
						//Lock status
						if (i == 0)
							levelDef.locked = false;
						else
							levelDef.locked = true;
						
						//Level general attributes (accounting)
						levelDef.numPortalIn = 1;	// number of portals in
						levelDef.numPortalOut = 1;	//number of portals out
						
						levelDef.mapFile = "Level01.tmx";
						
						//In the file: => 
						//goals, constraints, initial resources
						//num objects/mechanism of each type
						//num enemies
						//num items

						aLevelDef.push(levelDef);
					}
					//EndToDo
					

                }

               
                /////////////////////////////////////////////////////////////////////////  LEVEL STATUS
               
                /**
                 *
                 * @return
                 */
               
                public function isGameComplete(): Boolean
                {
					return (bLevelComplete && idLevel == numLevels-1);
                }
				
				/**
				 * Acciones tras completar el nivel (consolidar datos, desbloquear siguiente nivel,..)
				 */
				public function setLevelComplete(): void
				{
					aLevelDef[getNextLevel(idLevel)].locked = false; //Desbloquea nivel siguiente en estructura de niveles
					//TODO recompensa por finalización nivel en función de % de pintado
					//Registry.gpMgr.updPlayerInventoryOnEndLevel();
				}
				
				
                /**
                 * Establece como nuevo nivel el siguiente nivel al actual
				 * No realiza ninguna acción de carga de datos del nivel.
                 * @return
                 */
                public function setNextLevel(): int
                {
					idLevel = getNextLevel(idLevel);
					bLevelComplete = false; //inicializa para este nivel de juego (a pesar de que pudiera haber sido completado previamente)
					return idLevel;
                }
				
				protected function getNextLevel(Level:int):int
				{
					if (Level < numLevels-1)
					{
                        Level++;
					}	
                    return Level;
				}

				/**
				 * Carga el Nivel de juego actual (crea objeto Level que se encarga de parsear el fichero .tmx) 
				 */
				public function loadLevel():void
				{	
					if (levelObj==null || idLevel != levelObj.idLevel)
					{
						levelObj = null; //TODO levelObj.destroy()
						levelObj = new Level(this, idLevel);
					}
				}
								
				/**
                 * Inicializa el status del nivel cargado (nivel goals conseguido a valor defecto)
				*/
                public function initLevelStatus():void
                {     
					
					//[GAME] Leer info de goals and constraints de la definición del nivel de la estructura de objetos tmx del nivel
					goal_numTilesPainted = (int)(levelObj.getPropertyMap("goal_tiles")); 
					// ....
					// val_constr = levelObj.getPropertyMapXXX(); 

					//[GAME] Leer info de recursos iniciales del nivel, o recursos del Player asignados por defecto para el nivel
					rsrc_numTiles = (int)(levelObj.getPropertyMap("rsrc_tiles")); 
					rsrc_contBombs = (int)(levelObj.getPropertyMap("rsrc_bombs"));
					//...

					
					rsrc_nameLevel = levelObj.getPropertyMap("name_level");
					
					tileWidth = levelObj.getTileWidth();
					tileHeight = levelObj.getTileHeight();
					
                    //Inicializar estado de variables para el seguimiento de goals y constraints
					contTilesPainted = 0;
					contTilesDeleted = 0;
					//contHabPress = rsrc_player_numPress
                   				
					//TODO: Aumento de capacidades basado en avance de niveles
					//if (bFirstTimeinLevel)
					//	Registry.gpMgr.CapsInc("tipo_desbloqueo_nivel", idLevel); //llamada a método de incremento de capacities pasando evento y valor.
                }   
				
				
				

        }

		

		// ====================================================================
		
}


