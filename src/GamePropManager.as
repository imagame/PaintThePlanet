package  
{
        /**
         * ...
         * @author imagame
         */
        public class GamePropManager
        {
				//App Profile data *************************************************
				public var profile_id: String
				// Statistics
				public var profile_totalNumGames: int;        //Nº de partidas jugadas
				public var profile_totalTimeGameHours: int; //Nº de horas totales jugadas
				public var profile_totalTimeGameMinutes: int; //Nº de minutos a partir de la última hora jugada
				public var profile_totalTimeGameSeconds: int; //Nº de segundos a partir del último minuto jugado
				public var profile_totalTilesPainted; //Nº de tiles pintados
				public var profile_totalTilesDeleted; //Nº de tiles borrados
				//Game progress
				public var profile_level: int; //Nivel del player
				public var profile_exp: int; //Experiencia del jugador
									   
				//Player Inventory (Capacity levels in profile)
				//[GAME] Capacidades a nivel de Profile
				public var cap_maxAmountPaint: int; //Cantidad máxima de unidades de pintura máxima transportables por el Player
				public var cap_velDryPaint: int; //Valor máximo de grados de reducción del proceso de secado de tiles pintados (-1 si máximo sujeto a valor instantaneo de secado)
				public var cap_distanceBomb: int; //Valor máximo de onda expansiva de explosión.
				//public var cap_maxVelocity: int; //Valores: 1..5. Afecta a velocidad movimiento
				//public var cap_maxStrength: int; //Valores: 1..5 Afecta a potencia salto y fuerza destrucción
				//[GAME](Items recogidos/comprados y disponibles a nivel de Profile)
				public var cont_bombs: int; //contador de bombas
				//public var cont_velocity: int; //contador de aceleradores temporales de velocidad
   
                               
				//Inventory Manager  (Items a nivel de Level) ***********************************
				//[GAME](Estado de los valores de las capacidades a nivel de Level. Se mantienen valores distintos a la cap a pesar de existir dependencia -e incluso poder coincidir-)
                public var val_amountPaint: int; //Cantidad de unidades de pintura que transporta el Player                                                        
				public var val_dryPaint: int; //tiempo (grados) de secado
				public var val_distanceBomb: int; //alcance de bomba (depende de cap_distanceBomb)                                
				//public var val_strengthBomb: int; //potencia explosión (también depende de cap_distanceBomb)                
				public var val_iniVelocity: int; //Velocidad estandar de movimiento del player
                               
                               

                public function GamePropManager()
                {
                    trace("GamePropManager");
                                        resetPlayerInventory();
                }
               
				public function resetPlayerInventory():void
				{
					profile_totalNumGames = 0;
					profile_totalTilesDeleted = 0;
					profile_totalTilesPainted = 0;
					profile_totalTimeGameHours = 0;
					profile_totalTimeGameMinutes = 0;
					profile_totalTimeGameSeconds = 0;
					cap_maxAmountPaint = 5;  //valores seleccionables en inicio (primera distribución de 3 puntos)
					cap_velDryPaint = 10; //valores seleccionable en inicio
					cap_distanceBomb = 2; //valores seleccionable en inicio
					cont_bombs = 1;
					//cont_velocity = 1;
				   
				}
                               
                               
                /////////////////////////////////////////////////////////////////////////  APP PLAYER DATA
               
                /////////////////////////////////////////////////////////////////////////  GAME PLAYER INVENTORY
               
                /////////////////////////////////////////////////////////////////////////  LEVEL PLAYER INVENTORY
               
				/**
				 * Init player inventory status
				 */
                public function initPlayerInventoryOnNewLevel():void
                {
                    //inicialización valores a partir de capacidades del profile
					val_amountPaint = cap_maxAmountPaint;                                                                                
					val_dryPaint = 10 - cap_velDryPaint;
					val_distanceBomb = cap_distanceBomb;
					//actualización valores items con valores otorgados por inicio del nivel
					cont_bombs += Registry.lMgr.rsrc_contBombs;        //Se suma el nº de bombas que se regalan al inicio del nivel
					//inicialización valores fijos para inicio del nivel (con independencia del nivel)
					val_iniVelocity = 100;      
                }                              
               
				/**
				 * Update player inventory with level rewards when completing it
				 */
				public function updPlayerInventoryOnEndLevel():void
                {
					//TODO - Recompensar valores de capacidad en función de % finalización nivel
					cap_maxAmountPaint += 5;                    
                }    
               
        }

} 