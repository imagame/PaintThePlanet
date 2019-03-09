package game
{
        import org.flixel.FlxGroup;
		import org.flixel.FlxObject;
       
        import game.PaintTileAct;
       
        /**
         * Scene gameplay management
		 * - manages a pool of tiles that are being painted
		 * - updates lvlmap to change tiles when they are painted/cleaned
         * @author imagame
         */
        public class TiledFloor
        {
                private var _paintTilePool:FlxGroup; //Pool de objetos-acción PintarTile
				private var _lvlCtrl: ControlStruct; //Map control struct to check and track painted tiles
               
                public function TiledFloor(Pool: FlxGroup)
                {
					_paintTilePool = Pool;
					_lvlCtrl = Registry.lMgr.levelObj.createLvlCtrl(); //Control struct created from map Control Layer (to get which tiles are paintable and which not)
                }
               
                public function destroy():void
                {
					_paintTilePool = null;
					_lvlCtrl.destroy();
					_lvlCtrl = null;
                }

				//Inicializar pool con creación del máximo nº de objetos <PaintTileAct> simultaneos que puede haber en el nivel
				public function initPool(Maxsize:uint):void
				{
				   for (var i:int = 0; i < Maxsize; i++)
					{
						(_paintTilePool.recycle(PaintTileAct) as PaintTileAct).init(0, 0, FlxObject.NONE, 0);
					}					
				}
				
                /**
                 * Inicia el proceso de pintado de un tile, decodificando el tipo de tile para reconocer si procede pintado automático de tiles anexos.
                 * Asume que el tile [Xt,Yt] es pintable, e interpreta el tipo de tile pasado por parámetro (con independencia del tipo de tile que sea)
				 * @param        Xt
                 * @param        Yt
                 * @param        RulePaint
                 */
                public function PintarTile(Xt: uint, Yt: uint, TileId: uint):void
                {
                        //Determina RulePaint en función del tipo de tile //OPEN: Tipo Tile u objeto??? objeto: mayor flexib, tipo tile: 10 tiles distintos para soportar combinaciones lógicas
                        // Tipo extensión: UP, DO, LE, RI, con attr nº (0: sin límite, 1,2,...) o combinación de extensiones (mismo nº para cada dirección)
                        // Tipo extensión diagonal
                        // Tipo estrella
                        var rulePaint:uint = FlxObject.NONE;
						switch(TileId)
						{
							case Assets.MAP_TILESET_AUTOVERT:
							case (Assets.MAP_TILESET_AUTOVERT+6): rulePaint = FlxObject.UP | FlxObject.DOWN;
							break;

							case Assets.MAP_TILESET_AUTOHORZ:
							case (Assets.MAP_TILESET_AUTOHORZ+6): rulePaint = FlxObject.LEFT | FlxObject.RIGHT;
							break;

							case Assets.MAP_TILESET_AUTOUP:
							case (Assets.MAP_TILESET_AUTOUP + 6): rulePaint = FlxObject.UP;
							break;
							case Assets.MAP_TILESET_AUTODO:
							case (Assets.MAP_TILESET_AUTODO + 6): rulePaint = FlxObject.DOWN;
							break;
							case Assets.MAP_TILESET_AUTOLE:
							case (Assets.MAP_TILESET_AUTOLE + 6): rulePaint = FlxObject.LEFT;
							break;
							case Assets.MAP_TILESET_AUTORI:
							case (Assets.MAP_TILESET_AUTORI + 6): rulePaint = FlxObject.RIGHT;
							break;
							

							
							//case 20: rulePaint = FlxObject.UP | FlxObject.DOWN;
						}
                       
                        makePaintTile(Xt,Yt,rulePaint,0); //pool.Get objeto PintarTile con timerlimit=0 (pintar al instante, sin espera)
                       
                        //PintarTile.detectar_activación_automática_otros_tiles y dejar marcados
                        // (detectar: leyendo reglas heredadas, y reflas fijas de tile en mapa)
                        // (dejar marcados: recalcular reglas heredadas -descuento tiles,etc..- y marcar en array propagación[8])
                        //Para cada tile: SueloPintarTile (Xt, Yt)+ info propagación
						
                }                

                //PintarTile.init 
                public function makePaintTile(Xt:uint, Yt:uint, RulePaint: uint, TimerLimit:Number):void
                {

					(_paintTilePool.recycle(PaintTileAct) as PaintTileAct).init(Xt, Yt, RulePaint, TimerLimit);        
					//Scoring just painting init (a pesar de que puede que no se finalice) ???		
					Registry.lMgr.contTilesPainted++;
					Registry.playstate.hudUpdateScore();
                }        
               
				/**
				 * Is the tile [x,y] paintable ?
				 * @param	Xt
				 * @param	Yt
				 * @return  Boolean
				 */
                public function isTilePintable(Xt:uint, Yt:uint): Boolean
                {
					return (_lvlCtrl.getVal(Xt, Yt) == 0);
                }
               
				public function setTilePrevPaint(Xt:uint, Yt:uint): void
                {
					_lvlCtrl.setVal(Xt, Yt, 1);
                }
               
				
                public function setTileInPaint(Xt:uint, Yt:uint): void
                {
					_lvlCtrl.setVal(Xt, Yt, 2);
                }
               
                public function setTileInDry(Xt:uint, Yt:uint): void
                {
					_lvlCtrl.setVal(Xt, Yt, 3);
                }
               
				/**
				 * Cambia un tile del map por su correspondiente tile pintado. No afecta al layer de control
				 * @param	Xt
				 * @param	Yt
				 */
                public function setTilePainted(Xt:uint, Yt:uint): void
                {
                        //Ctrl value
						_lvlCtrl.setVal(Xt, Yt, 4); //Layer control: Pintado
                        //Map tile value
						var tileval:uint = Registry.playstate.lvlMap.getTile(Xt, Yt);
						/*if (tileval >= 9 && tileval <= 9)
							tileval = 2;
						else if (tileval >= 10 && tileval <= 10)
							tileval = 4;*/
						if (tileval >= Assets.MAP_TILESET_AUTOVERT && tileval <= Assets.MAP_TILESET_AUTORI)
							tileval = Assets.MAP_TILEID_NOTSHADED + 1;
						else if (tileval >= Assets.MAP_TILESET_AUTOVERT + 6 && tileval <= Assets.MAP_TILESET_AUTORI + 6)
							tileval = Assets.MAP_TILEID_NOTSHADED + 3;
						else //if(tileval >=1 && tileval <=6)
							tileval++;
                        Registry.playstate.lvlMap.setTile(Xt, Yt, tileval);                
                }
        }

}

