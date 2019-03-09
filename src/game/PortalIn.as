package game 
{ 
	import org.flixel.FlxSprite; 
	
	/** 
	 * Portal in. 
	 * State flow: Its closed until an actor arrives, callback Pre and opens, callback Post once opened, and inmediatly closes. 
	 * Time managemente: Continuos state flow, based on animation sheet. 
	 * @author imagame 
	 */ 
	public class PortalIn extends FlxSprite 
	{ 
		public var estado:uint;        //0: cerrado, 1:apareciendo, 2: recargando pintura 
		public var subestado:uint;  //0: al entrar en estado, 1: durante el estado, 2: previo a salida de estado 
		
		public static const STS_CLOSED:uint = 0; 
		public static const STS_OPENING:uint = 1; 
		public static const STS_OPENED:uint = 2;                 
		public static const STS_CLOSING:uint = 3; 
		
		public static const SBSTS_INIT:uint = 0; 
		public static const SBSTS_CONT:uint = 1; 
		public static const SBSTS_END:uint = 2; 
		
		private var _actor: FlxSprite = null;                                 
				
		public function PortalIn(Id: int, X: uint, Y:uint )   
		{ 
			ID = Id; 
			x = X; 
			y = Y; 

			loadGraphic(Assets.PortalInPNG, false, false, 24, 24); 
			addAnimation("closed", [0], 0, false); 
			addAnimation("opening", [0, 1, 2, 3], 3, false); 
			addAnimation("closing", [3, 2, 1, 0], 12, false);         
			addAnimationCallback(onAnimationChange); 
			
			estado = STS_CLOSED;        //portal cerrado 
		} 

		override public function destroy():void 
		{ 
			super.destroy(); 
		} 
		
		/** 
		 * Called when an actor enters from the portal 
		 * @return Si portal acepta actor o no 
		 */ 
		public function actorIn(Actor: FlxSprite):Boolean 
		{ 
			trace ("PortalIn->actorIn"); 
		
			//Si PortalIn ocupado con otro actor retornar false 
			//if(_actor != null)        //Pte: estado==1 
			if(estado != STS_CLOSED) 
				return false; 
		
			_actor = Actor;                         
			//Acciones previas a la apertura del portalIn al entrar el actor y haberlo situado en la pos correcta 
			estado = STS_OPENING; 
			_actor.x = x+origin.x - _actor.frameWidth * 0.5; 
			_actor.y = y+origin.y - _actor.frameHeight * 0.5;                         
			(_actor as IPortalIn).onPortalInPre();        //Lamada a rutina Pre entrada en portalIn del actor 
						
			return true; 
		} 

		private function onAnimationChange(AnimName: String, FrameNumber: uint, FrameIndex: uint ):void 
		{ 
				if(AnimName=="opening") 
				{ 
						if (FrameNumber == 3) 
						{ 
								estado = STS_OPENED; 
								subestado = SBSTS_INIT; 
						} 
				 } 
				else if (AnimName=="closing") 
				{ 
						if (FrameNumber == 3) 
						{ 
								estado = STS_CLOSED;                                 
						} 
				} 
		} 
		
		
		override public function update():void 
		{ 
			if (estado == STS_CLOSED)         
			{ 
				play("closed");         
			} 
			else if (estado == STS_OPENING) 
			{ 
				play("opening"); 
			} 
			else if (estado == STS_OPENED) 
			{ 
				if(subestado == SBSTS_INIT) 
				{ 
					(_actor as IPortalIn).onPortalInPost(); 
					subestado++; 
				} 
				else 
				{ 
					estado = STS_CLOSING; 
				} 
			} 
			else if (estado == STS_CLOSING) 
			{ 
				_actor = null; 
				play("closing"); 
			} 				
		} 
		
	} 

}
