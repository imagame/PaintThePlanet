package game 
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxTimer;
	/**
	* Level exit portal
	 * 1.- PortalOut closed on level init
	 * 2.- PortalOut opening if open condition met (<code>chkOpenCondition</code>)
	 * 3.- PortalOut opened. Portal out closing if close condition met (<code>chkCloseCondition</code>)
	 * 4.- If actor enters in portal <code>actorIn</code> is called. If opened <code>PortalOutPre</code> method implemented by Actor is called. After x frametime <code>PortalOutPost</closed> is called. PortalOut closing         *
	 * "opening" and "closing" especial animations: override <code>calcFrame</code> for specific frame animation calculation when any of these animations is active.
	 * @author imagame
	 */ 
	public class PortalOut extends FlxSprite
	{
		public var estado:uint;	//0: cerrado, 1: en proceso de apertura, 2: abierto, 3: en proceso de cierre
		public var subestado:uint;  //0: al entrar en estado, 1: durante el estado, 2: previo a salida de estado
		
		public static const STS_CLOSED:uint = 0; 
		public static const STS_OPENING:uint = 1;
		public static const STS_OPENED:uint = 2;
		public static const STS_CLOSING:uint = 3;
		
		public static const SBSTS_INIT:uint = 0;
		public static const SBSTS_CONT:uint = 1;
		public static const SBSTS_END:uint = 2;
			
		//Bounding box interno al frame del portal para tratamiento colisiones con actores
		private static const BB_LE: uint = 12;
		private static const BB_RI: uint = 12;
		private static const BB_UP: uint = 12;
		private static const BB_DO: uint = 12;

		private var _actor: FlxSprite = null;    
		private var _auxTimer: FlxTimer; 
		
		public function PortalOut(Id: int, X: uint, Y:uint ) 
		{
			ID = Id;
			x = X;
			y = Y;
			estado = STS_CLOSED;	//portal cerrado

			//makeGraphic(32, 32, 0xffff0000);
			loadGraphic(Assets.PortalOutPNG, false, false, 32, 32);
			addAnimation("closed", [0, 0, 0, 1, 2, 3, 3, 3, 2, 1 ], 12, true);
			addAnimation("opening", [4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5], 24, false); //Pte
			addAnimation("opened", [6, 7, 8, 9, 9], 8, true);//Pte
			addAnimation("closing", [4, 4, 4], 24, false);//Pte
			//addAnimation("entering",[10,11,12,13,14,13,12,11,10],24,false);  //Fx desaparición player , o en su defecto timer pasado por param junto con Actor 
			//addAnimationCallback(onAnimationChange); //hacerlo al principio o solo cuando abra el portal

			_auxTimer = new FlxTimer();
			_auxTimer.finished = true;

			play("closed");
		}
		
		override public function destroy():void
		{
			if (_auxTimer != null)
				_auxTimer.destroy();
			_auxTimer = null; 
			super.destroy();
		}
		
		/*
		function onOpeningPortalAnimationChange(AnimName: String, FrameNumber: uint, FrameIndex: uint ):void
		{
			if(AnimName == "opening" and FrameNumber == 2)
				estado = 2; //abierto
			   
		}
		*/
		
		/**
		 * Actor entra en Portal. Se le situa y se llama a método <code>PortalOutPre</code> del Actor
		 * @return ID del portal si el Actor consigue salir, o -1 en caso contrario
		 */
		public function actorIn(Actor: FlxSprite):int
		{
			if (estado == STS_OPENED && subestado == SBSTS_INIT) //Portal abierto y no hay otro actor usándolo
			{
				var bbx1 = x + BB_LE;
				var bbx2 = x + frameWidth - BB_RI;
				var bby1 = y + BB_UP;
				var bby2 = y + frameHeight - BB_DO;
			
				//Si hay colisión del Actor con bounding box interno del portal
				if ((bbx2 > Actor.x) && (bbx1 < Actor.x + Actor.width) && (bby2 > Actor.y) && (bby1 < Actor.y + Actor.height))
				{
					subestado = SBSTS_CONT;
					//situa al Actor en el centro del PortalOut	
					_actor = Actor;      
					_actor.x = x+origin.x - _actor.frameWidth * 0.5;
					_actor.y = y+origin.y - _actor.frameHeight * 0.5;                        
					(_actor as IPortalOut).onPortalOutPre();        //Lamada a rutina Pre entrada en portalOut del actor
					play("entering"); //arranca animación de 
					
					return ID;
				}
			}
			return -1;
		}
		
		
		override public function update():void
		{
			//Portal cerrado al inicio de nivel y mientras no se llegue al nº mínimo de tiles pintados
			if (estado == STS_CLOSED)	
			{
				//Al superar el límite de tiles a pintar la primera vez el portal ya queda abierto.
				//if (Registry.lMgr.contTilesPainted >= Registry.lMgr.goal_numTilesPainted)
				//{
				//	addAnimationCallback(onOpeningPortalAnimationChange);
				//	estado = 1;
				//	play("opening");
				//}
				if (Registry.lMgr.contTilesPainted > 30)
				{
					estado = STS_OPENING;
					subestado = SBSTS_INIT;
				}
			}
			
			//Portal en acción de apertura (limitado a tiempo de ejecución de animación)
			else if (estado == STS_OPENING)
			{
				if (subestado == SBSTS_INIT)
				{
					play("opening");
					subestado++;
				}
				else
				{
					if (finished) //Si finaliza animación
					{
						estado = STS_OPENED;
						subestado = SBSTS_INIT;
					}
				}
			}
			
			//Portal abierto
			else if (estado == STS_OPENED)
			{
				if (subestado == SBSTS_INIT) //abierto sin ningún actor entrando en el portal
				{
					play("opened");
					if (Registry.lMgr.contTilesPainted <= 30)
					{
						estado = STS_CLOSING;
						subestado = SBSTS_INIT;
					}
				}
				else if (subestado == SBSTS_CONT) //abierto con un actor en proceso de entrada en el portal
				{
					if (finished) //fin animación entering
					{						
						subestado++;
					}
				}
				else if (subestado == SBSTS_END) //abierto con un actor terminando de entrar al portal
				{
					(_actor as IPortalOut).onPortalOutPost();
					estado = STS_CLOSING;
					subestado = SBSTS_INIT;
				}
					
					
			}
			
			//Portal en acción de cierre (limitado a tiempo de ejecución de animación)
			else if (estado == STS_CLOSING)
			{
				if (subestado == SBSTS_INIT)
				{
					play("closing");
					subestado++;
				}
				else
				{
					if (finished) //si finaliza animación
						estado = STS_CLOSED;
				}	
			}
		}
		
		
	}

}