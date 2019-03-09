package game
{
	import org.flixel.FlxG;
	import org.flixel.FlxU;
	import org.flixel.FlxState;
	import org.flixel.FlxObject; 
	import org.flixel.FlxSprite;
	
	import game.Assets;
	
	
	/**
	 * ImaFlixel
	 * Player Entity
	 * @author imagame
	 */
	public class Player extends FlxSprite implements IPortalIn, IPortalOut
	{
		public var estado:uint; //0: en inicialización, 1: entrando en level (portalIn), 2: in-game en level, 3: saliendo de level (portalOut), 4: muriendo
		public var subestado:uint;  //0: al entrar en estado, 1: durante el estado, 2: previo a salida de estado
		
		public static const STS_INIT:uint = 0; 
		public static const STS_ENTERLVL:uint = 1;
		public static const STS_INGAME:uint = 2;
		public static const STS_EXITLVL:uint = 3;
		public static const STS_ENDKILL:uint = 4;
		
		public static const SBSTS_INIT:uint = 0;
		public static const SBSTS_CONT:uint = 1;
		public static const SBSTS_END:uint = 2;		
		
		
		//TODO: Valores de variables derivadas de las Capacidades del Player
		//velocidad (heredada de FlxSprite)
		public var amountColor: int; //Capacidad actual de pintura que almacena el player
		public var bOnElevator: Boolean;

		private var _xt:int; //tile X donde el player está situado para poder pintar
		private var _yt:int; //tile Y donde el player está situado para poder pintar
		private var _xtant:int //Tile X correspondiente a la posición anterior
		private var _ytant:int; //Tyle Y correspondiente a la posición anterior
		private var _xtpaint: int; //TileX potencial a pintar
		private var _ytpaint: int; //Tiley potencial a pintar
		//private var _tileAct:int; //Indicador del tile actual sobre el que está el player
		private var _facingant: uint;
	
		private var _portalInID: int;	//Portal ID del portal por el que entra al Nivel de juego el Player
		private var _elevatorID: int;
		
		//Bounding box interno al frame del sprite para tratamiento colisiones (con vacío,..)
		private static const BB_LE: uint = 6;
		private static const BB_RI: uint = 6;
		private static const BB_UP: uint = 8;
		private static const BB_DO: uint = 6;
		
		//Constructor
		//Events:
		// - onAnimationChange
		// - onElevator
		//Services:
		//- UpdateStatus
		//- chkTileCollision
		//Actions:
		//- EnterLvl
		//- ExitLvl
		//- PintarTilePintable
		//FSM
		// - update()
		
		public function Player(PortalInID: int)
		{
			trace("Player");
			_portalInID: PortalInID;
			
			loadGraphic(Assets.PlayerPNG, true, false, 16, 16);
			//makeGraphic(16, 16, 0xffff0000);
			addAnimation("idle", [4, 4, 6,], 1, true);
			addAnimation("walk_le", [8, 9, 8, 10, 11, 10], 12, false);
			addAnimation("walk_ri", [12, 13, 12, 14, 15, 14], 12, false);
			addAnimation("walk_up", [0, 1, 0, 2, 3, 2], 12, false);	
			addAnimation("walk_do", [4, 5, 4, 6, 7, 6], 12, false);	
			addAnimation("enter", [8, 9, 8, 10, 11, 10, 12, 13, 14, 15], 20, false);
			addAnimation("morir", [1, 3,1, 3,1, 3,1, 3,1, 3,1, 3,1, 3,1, 3,1, 3,1, 3,1, 3], 20, false);
			addAnimationCallback(onAnimationChange);

			//bounding box
			//width = 12;
			//height = 12;
			//offset.x = 4;
			//offset.y = 4;
			//[ERR] No funciona el bounding box do-ri
			width = 16
			height = 16;

			//Entrada en nivel de juego (a través de portal) que le posiciona en punto partida. 
			estado = STS_INIT; 
			subestado = SBSTS_INIT;  
			
			bOnElevator = false;
		}

		////////////////////////////////////////////////////////////////////////////////////////////// EVENTS
		
		//******************************************************************** Métodos implementación Interface
		// Son eventos para activación-estados 
		
		public function onPortalInPre():void 
		{
			estado = STS_ENTERLVL;
			subestado = SBSTS_CONT;							
		}
		
		public function onPortalInPost():void
		{
			estado = STS_ENTERLVL;
			subestado = SBSTS_END;
		}
		
		public function onPortalOutPre():void 
		{
			estado = STS_EXITLVL;
			subestado = SBSTS_INIT;
		}
		
		public function onPortalOutPost():void
		{
			estado = STS_EXITLVL;
			subestado = SBSTS_CONT;
		}
		
		/**
		 * Event to move the player from Init state to Enterlevel state (activate the player into the game)
		 */
		public function onActivate():void
		{
			estado = STS_ENTERLVL;
			subestado = SBSTS_INIT;
		}
	
		/**
		 * Evento para matar al protagonista por cualquier tipo de muerte (caida en el espacio,...)
		 */
		private function onKill():void
		{
			estado = STS_ENDKILL; //muriendo
			subestado = SBSTS_INIT;
		}
		
		function onAnimationChange(AnimName: String, FrameNumber: uint, FrameIndex: uint ):void
		{
			if(AnimName=="morir")
				if (FrameNumber == 10)
				{
					estado = STS_ENDKILL; //muriendo
					subestado = SBSTS_END;				
				}
		}
		
		public function onElevator(ElevatorID: int):void 
		{
			bOnElevator = true;
			_elevatorID = ElevatorID;							
		}
		
		/**
		 * Chequea colisión de player-bb interno con los tiles que rodean el player, siendo uno el Xt,Yt
		 * @param	Xt Pos Tile x del primero (de hasta 2) tiles en la misma fila/columna con los que tiene overlapping el player
		 * @param	Yt
		 * @param	MapIndex
		 * @return	Si hay colision con el bb interno (12x12)
		 */
		public function OnCollisionSpace(Xt:uint, Yt:uint, MapIndex:uint):Boolean
		{
			if (estado != STS_INGAME)
			{
				trace("Player->OnCollisionSpace: PLAYER KILLED");
				return false;
			}
			
			 //Chequear colision tile vacío con bb interno del player 
			var xvacio = Xt * frameWidth; 
			var yvacio = Yt * frameHeight 
			var bbx1 = x  + BB_LE; 
			var bbx2 = x + frameWidth - BB_RI; 
			var bby1 = y + BB_UP; 
			var bby2 = y + frameHeight  - BB_DO; 
			
			if ((xvacio+frameWidth > bbx1) && (xvacio < bbx2) && (yvacio+frameHeight > bby1) && (yvacio < bby2)) 
			{ 
				//Ajustar pos x,y del player a vacío según dirección de movimiento
				if (velocity.x != 0)
					x = Xt * frameWidth; 
				if (velocity.y != 0)
					y = Yt * frameHeight;
				//Comprobar si el player queda situado sobre dos tiles, y si alguno no es vacio, entonces ajustar al tile vacio de colisión.
				var xtn = x / Registry.lMgr.tileWidth;
				var ytn = y / Registry.lMgr.tileHeight;    
				if (x % frameWidth != 0)
				{
					if (Registry.playstate.lvlMap.getTile(xtn, ytn) > Assets.MAP_TILEID_VOIDEND || 
						Registry.playstate.lvlMap.getTile(xtn+1, ytn) > Assets.MAP_TILEID_VOIDEND)
						x = Xt * frameWidth; 
				}
				if (y % frameHeight != 0)
				{
					if (Registry.playstate.lvlMap.getTile(xtn, ytn) > Assets.MAP_TILEID_VOIDEND || 
						Registry.playstate.lvlMap.getTile(xtn, ytn+1) > Assets.MAP_TILEID_VOIDEND)
						y = Yt * frameHeight; 
				}
				
				
				//Ejecuta proceso de muerte por caida //Alternativa: pasar x,y destino a onMorirPre(x,y), y hacer transición mov hasta pos caida
				onKill(); //TODO onKill(tipo_muerte);
				return true;
			}
			return false;
		}
		
		////////////////////////////////////////////////////////////////////////////////////////////// SERVICES
		
		/**
		 * Update player variables:  physics, rendering, capacity-based,...
		 * @param	ValStatus	identifies the kind of status to update (init, dec, inc,...)
		 */
		private function updateStatus(ValStatus: String):void
		{
			switch(ValStatus)
			{
				case "init":
					//variables física
					velocity.x = velocity.y = 0;
					acceleration.x = acceleration.y = 0;
					maxVelocity.x = maxVelocity.y = Registry.gpMgr.val_iniVelocity;
					//player.acceleration.y = 200;
					drag.x = maxVelocity.x * 4;
					drag.y = maxVelocity.y * 4;
							
					facing = FlxObject.DOWN;
					_facingant = facing;
					//Establece variables de control del player en función del nivel de las capacidades registradas en el profile del jugador
					//TODO: establecer habilidades player en función de nivel capacidades en profile
					//maxVelocity.x = Registry.gpMgr.cap_velocity * 100;
					
					solid = true;
					exists = true;
					break;
			}
		}
	
		/*
		public function chkCollision(X:Number, Y:Number):Boolean
		{
			
		}
			*/

		////////////////////////////////////////////////////////////////////////////////////////////// ACTIONS	   
						
	   /**
		* Enter in the game level throug a portal-In. 
		* Called when inits or continues playing the level
		* @param	PortalInID	Portal-in identifier (0..N)
		*/
		public function enterLevel(PortalInID: int):void
		{
			//identifica el objeto portal-in con id <PortalInID>
			for each(var obj:FlxSprite in Registry.playstate.portalsGrp.members)
			{
				if (obj is PortalIn && obj.ID == PortalInID)
				{
					//Llama al portal-in para que actualice la pos del player
					(obj as PortalIn).actorIn(this);
					break;
				}
			}					
		}
		
		/**
		 * Exit from current Level
		 * Called after entering a Portal Out
		 */
		public function exitLevel():void
		{
			//TODO Computa datos final de nivel
			//TODO: any HUD related action ?? o any gameprop mgr status update??
			super.kill();			
		}
		
		
		override public function kill():void
		{
			if(!alive)
				return;
			solid = false;
			//FlxG.play(SndExplode);
			//FlxG.play(SndExplode2);
			super.kill();
			flicker(0);
			exists = true;
			visible = true;
			velocity.make();
			acceleration.make();
			play("morir"); //Anim morir en "CAIDA" //TODO diferentes animacionese en función tipo muerte
			FlxG.camera.shake(0.005,0.35);
			FlxG.camera.flash(0xffd8eba2, 0.35);
			//alive = false
		}
		
		/**
		 * Pintar tile si es pintable y si se tiene pintura suficiente.
		 * @param	Xt	Pos Tile x del tile a pintar
		 * @param	Yt	Pos Tile y del tile a pintar
		 */
		public function paintTile(Xt: int, Yt:int):void
		{
			if(Registry.playstate.scene.isTilePintable(Xt,Yt)) //si activeTile pintable
			{
				//Comprobar si pintura suficiente
				//TODO if player.capacidadpaint > consumopaint1tile_enlevelact
				if(true)
				{				
					Registry.playstate.scene.PintarTile(Xt, Yt, Registry.playstate.lvlMap.getTile(Xt, Yt)) //Suelo->pintarTile(x,y, tipo automatismo tile)
					//Descontar cantidad pintura
					//TODO player.capacidadpaint--
				}
			}
		}

		
	 

		
		private function slideOnTouchingUp():void
		{
			var posXinTile: uint = x % Registry.lMgr.tileWidth;
			var posYinTile: uint = y % Registry.lMgr.tileHeight;
			if (FlxG.keys.UP && isTouching(FlxObject.UP)) // && posXinTile != 0)
			{
				//ajusta x para entrar entre 2 obstáculos
				if (posXinTile == 0)
				{
					x = Math.floor(x);
					return;
				}
				
				//mirar si tile y-1 izq es vacio
				if (Registry.playstate.lvlMap.getTile(_xt, _yt - 1) < Assets.MAP_TILESET_COLLIDEINDEX)
				{
					acceleration.x = -maxVelocity.x;
					facing = FlxObject.LEFT;
				}
				else if (Registry.playstate.lvlMap.getTile(_xt+ 1 ,_yt- 1) < Assets.MAP_TILESET_COLLIDEINDEX)
				{
					acceleration.x = maxVelocity.x;
					facing = FlxObject.RIGHT;
				}
				
			}
		}

		public function slideOnTouchingDown():void
		{
			var posXinTile: uint = x % Registry.lMgr.tileWidth;
			if (FlxG.keys.DOWN && isTouching(FlxObject.DOWN)) 
			{
				//ajusta x para entrar entre 2 obstáculos
				if (posXinTile == 0)
				{
					x = Math.floor(x);
					return;
				}
				
				//mirar si tile y+1 izq es vacio
				if (Registry.playstate.lvlMap.getTile(_xt, _yt + 1) < Assets.MAP_TILESET_COLLIDEINDEX)
				{
					acceleration.x = -maxVelocity.x;
					facing = FlxObject.LEFT;
				}
				else if (Registry.playstate.lvlMap.getTile(_xt+ 1 ,_yt+ 1) < Assets.MAP_TILESET_COLLIDEINDEX)
				{
					acceleration.x = maxVelocity.x;
					facing = FlxObject.RIGHT;
				}
			}
		}
		
		public function slideOnTouchingLeft():void
		{
			var posYinTile: uint = y % Registry.lMgr.tileHeight;
			if (FlxG.keys.LEFT && isTouching(FlxObject.LEFT)) // && posXinTile != 0)
			{
				//ajusta y para entrar entre 2 obstáculos
				if (posYinTile == 0)
				{
					y = Math.floor(y);
					return;
				}
				
				//mirar si tile y-1 izq es vacio
				if (Registry.playstate.lvlMap.getTile(_xt-1, _yt) < Assets.MAP_TILESET_COLLIDEINDEX)
				{
					acceleration.y = -maxVelocity.y;
					facing = FlxObject.UP;
				}
				else if (Registry.playstate.lvlMap.getTile(_xt-1 ,_yt+ 1) < Assets.MAP_TILESET_COLLIDEINDEX)
				{
					acceleration.y = maxVelocity.y;
					facing = FlxObject.DOWN;
				}
				
			}
		}

		public function slideOnTouchingRight():void
		{
			var posYinTile: uint = y % Registry.lMgr.tileHeight;
			if (FlxG.keys.RIGHT && isTouching(FlxObject.RIGHT)) // && posXinTile != 0)
			{
				//ajusta y para entrar entre 2 obstáculos
				if (posYinTile == 0)
				{
					y = Math.floor(y);
					return;
				}
				
				//mirar si tile y-1 izq es vacio
				if (Registry.playstate.lvlMap.getTile(_xt+1, _yt) < Assets.MAP_TILESET_COLLIDEINDEX)
				{
					acceleration.y = -maxVelocity.y;
					facing = FlxObject.UP;
				}
				else if (Registry.playstate.lvlMap.getTile(_xt+1 ,_yt+ 1) < Assets.MAP_TILESET_COLLIDEINDEX)
				{
					acceleration.y = maxVelocity.y;
					facing = FlxObject.DOWN;
				}
				
			}
		}

		private function moveByKeys():void
		{
			acceleration.x = acceleration.y = 0;
			if (FlxG.keys.LEFT)
			{
				acceleration.x = -maxVelocity.x * 4;
				facing = FlxObject.LEFT;
			}
			if (FlxG.keys.RIGHT)
			{
				acceleration.x = drag.x; // maxVelocity.x * 4;
				facing = FlxObject.RIGHT;
			}
			if (FlxG.keys.UP)
			{
				acceleration.y = -maxVelocity.y * 4;
				facing = FlxObject.UP;
			}
			if (FlxG.keys.DOWN)
			{
				acceleration.y = maxVelocity.y * 4;
				facing = FlxObject.DOWN;
			}
		
			//TMP (to avoid diagonal movement)
			if (acceleration.x != 0)
				if (! isTouching(FlxObject.LEFT) && ! isTouching(FlxObject.RIGHT))
					acceleration.y = 0;
				
			//Slide when touching if near a corner
			slideOnTouchingUp();
			slideOnTouchingDown();
			slideOnTouchingLeft();
			slideOnTouchingRight();			
		}
		
		private function animate():void
		{
			if (velocity.x > 0)
			{
				play("walk_ri");
			}
			else if (velocity.x < 0)
			{
				play("walk_le");
			}
			else if (velocity.y < 0)
			{
				play("walk_up");
			}
			else if (velocity.y > 0)
			{
				play("walk_do");
			}
			else
			{
				//switch(facing)
				play("idle");
			}			
		}
		
	
		/**
		 * seleccionar tile a pintar [_xtpaint, _ytpaint] en función del facing y de pos relativa dentro del tile
		 */
		
		private function detectActiveTile(): void
		{
			switch(facing)
			{
				//Si facing UP seleccionar tile up-le or up-ri, según pos x mod 16 sea <=7
				case FlxObject.UP:
					_ytpaint = _yt;
					if(x % frameWidth < (frameWidth*0.5))
						_xtpaint = _xt;
					else
						_xtpaint = _xt+1;
				break;
			   
				//Si facing DOWN seleccionar tile up-le or up-ri, según pos x mod 16 sea <=7
				case FlxObject.DOWN:
					_ytpaint = _yt+1;
					if(x % frameWidth < (frameWidth*0.5))
						_xtpaint = _xt;
					else
						_xtpaint = _xt+1;
				break;
			   
				//Si facing LEFT seleccionar tile up-le or up-ri, según pos x mod 16 sea <=7
				case FlxObject.LEFT:
					_xtpaint = _xt;
					if(y % frameHeight <= (frameHeight*0.5))
						_ytpaint = _yt;
					else
						_ytpaint = _yt+1;
				break;
																						   
				//Si facing RIGHT seleccionar tile up-le or up-ri, según pos x mod 16 sea <=7
				case FlxObject.RIGHT:
					_xtpaint = _xt+1;
					if(y % frameHeight <= (frameHeight*0.5))
						_ytpaint = _yt;
					else
						_ytpaint = _yt+1;
				break;																																											   
			}			
			//_tileChange = true;
			//trace("Player Tile: ["+_xtpaint+","+_ytpaint+"]  => ",Registry.playstate.lvlCtrl.getVal(_xtpaint, _ytpaint)+ "Facing: "+facing);
		}
		
		/**
		 * Automatically called after update() by the game loop,
		 * this function just calls updateAnimation().
		 */
		
		override public function postUpdate():void
		{
			//si ya no existe colisión con elevator
			if (bOnElevator)
				//bOnElevator = chkCollision(Registry.playstate.elevator1.x, Registry.playstate.elevator1.y, 
				//Registry.playstate.elevator1.width, Registry.playstate.elevator1.height)
				
				//bOnElevator = overlaps(Registry.playstate.elevator1);
				bOnElevator = overlaps(Registry.playstate.elevatorsGrp.members[_elevatorID]);
				//bOnElevator = false;
			
				
			super.postUpdate();
			//trace("Player->postUpdate()  bOnelevator: " + bOnElevator);
		}
		
		
		
		/**
		 * update
		 */		
		override public function update():void
		{
			//trace("Player->update() " + FlxU.getTicks() + " x: " + x);
			super.update();
			
		
			//------------------------------------------------------------------------ STS_INGAME
			if (estado == STS_INGAME)
			{
				//trace("OnElevator: " + bOnElevator);
				if (bOnElevator)
				{
					//x = Registry.playstate.elevator1.x;
					//velocity.x = Registry.playstate.elevator1.velocity.x;
					//acceleration.x = Registry.playstate.elevator1.acceleration.x;
					//moves = false;
					//var obj1delta:Number = Registry.playstate.elevator1.x - Registry.playstate.elevator1.last.x;
					var obj1delta:Number = Registry.playstate.elevatorsGrp.members[_elevatorID].x - Registry.playstate.elevatorsGrp.members[_elevatorID].last.x;
					x += obj1delta;
					
					//velocity.x = obj1delta / FlxG.elapsed;
					
					
				}
				moveByKeys();
				animate();
				
				//Tile painting process
				//Detectar tile activo (tile pintable de los 4 posible tiles que puede pisar el player)
				_xtant = _xt;
				_ytant = _yt;
				_xt = x / Registry.lMgr.tileWidth;
				_yt = y / Registry.lMgr.tileHeight;                        
				//Detectar cambio de tile o cambio de dirección. 
				if (_xtant != _xt || _ytant != _yt || _facingant != facing) //Si hay cambio intentar pintar tile
				{
					detectActiveTile();
					paintTile(_xtpaint, _ytpaint); //Pintar active tile si es pintable y hay pintura suficiente
				}
				_facingant = facing;
				
				//bOnElevator = false;
			}
			
			//------------------------------------------------------------------------ STS_ENTERLVL                         
			else if (estado == STS_INIT) 
			{ 
				switch(subestado) 
				{ 
					case SBSTS_INIT: 
						trace("Player: [STS_INIT::SBSTS_INIT]");
						updateStatus("init"); // inicializa variables físicas y de visualización gráfica 
						subestado = SBSTS_END; 
						break; 
					case SBSTS_END: 
						trace("Player: [STS_INIT::SBSTS_END]");
						revive();
						//Waiting for activation from playstate
						//enterLevel(_portalInID); 
				} 
			} 
			//------------------------------------------------------------------------ STS_ENTERLVL                         
			else if (estado == STS_ENTERLVL) 
			{ 
				switch(subestado) 
				{ 
					case SBSTS_INIT: 
						enterLevel(_portalInID); 
						break;
					case SBSTS_CONT:
						play("enter"); //Play anim init portal-in, once the player is correctly located in portal
						break;
					case SBSTS_END:
						//Post acciones
						//TODO Llenar depósito pintura + otras acciones asociadas a entrar en el nivel por el portal-in   
						play("idle");
						estado = STS_INGAME;
						revive();         //necesario?  si si vuelve a jugar, ponerlo antes ,no?  
						//Fx parpadeo
						//flicker(1.3); 
				} 
			} 
			
			//------------------------------------------------------------------------ STS_EXITVL			
			else if (estado == STS_EXITLVL)
			{
				switch(subestado)
				{
					case SBSTS_INIT:
						play("enter"); //Play anim init portal-in, once the player is correctly located in portal	
						//el paso al siguiente subestado lo determina el método onPortalOutPost() invocado desde el PortalOut
						break;
					case SBSTS_CONT:
						exitLevel();
						subestado = SBSTS_END;
						break;
					case SBSTS_END:
						//FX salida (fade out del player) 
						break;
				}			
			}		

			//------------------------------------------------------------------------ STS_ENDKILL		
			else if (estado == STS_ENDKILL)
			{
				switch(subestado)
				{
					case SBSTS_INIT:
						trace("Player: [STS_ENDKILL::SBSTS_INIT]");
						kill();						
						break;
					case SBSTS_END:
						trace("Player: [STS_ENDKILL::SBSTS_END]");
						estado = STS_INIT;
						subestado = SBSTS_INIT;
						//alive = true; //o despues del portal, como se prefiera !!
						break;
				}
			}

		}
	}

} 