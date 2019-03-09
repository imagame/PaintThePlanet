package game 
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxTimer;
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	
	/**
	 * ...
	 * @author imagame
	 */
	public class Elevator extends FlxSprite
	{
		public var estado:uint;         
		public var subestado:uint; 
		
		public static const STS_STOP:uint = 0; 
		public static const STS_MOVE:uint = 1; 

		public static const SBSTS_INIT:uint = 0; 
		public static const SBSTS_CONT:uint = 1; 
		public static const SBSTS_END:uint = 2;      
		
		public static const SIZE_SMALL:uint = 0;
		public static const SIZE_MEDIUM:uint = 1;
		public static const SIZE_BIG:uint = 2;
		
		private var _posini: Number; 
		private var _posend: Number; 
		private var _size: uint; //Elevator size
		private var _dir: uint; //Movement direction 
		private var _auxTimer: FlxTimer; 
		private var _stopTime: Number; 
		private var _velocity_ant:FlxPoint;
		
		/**
		 * Elevator constructor
		 * @param	Id		Identificator
		 * @param	Size	SIZE_SMALL (16x16), SIZE_MEDIUM (32,x32), SIZE_BIG (tbd)
		 * @param	X
		 * @param	Y
		 * @param	Lim
		 * @param	Dir
		 * @param	Vel
		 * @param	StopTime
		 */
		public function Elevator(Id:int, Size: uint, X:Number, Y:Number, Lim:Number, Dir:uint, Vel: Number, StopTime: Number ) 
		{
			ID = Id;
			x = X; 
			y = Y; 
			_size = Size;
			_dir = Dir;
			
				
			switch(_dir) 
			{
				case FlxObject.PATH_HORIZONTAL_ONLY:
					_posini = X; 
					_posend = X + Lim; 
					velocity.x = maxVelocity.x = Vel;        //Basic elevator speed         
					velocity.y = 0; 
					break; 
				case FlxObject.PATH_VERTICAL_ONLY: 
					_posini = Y; 
					_posend = Y + Lim; 
					velocity.x = 0;        //Basic elevator speed         
					velocity.y = maxVelocity.y = Vel; 
					break;                                         
			} 

			immovable = true;                //Not moved after a collision 
			//solid = false;                //collisions not allowed   
			if(_size == SIZE_SMALL)
				loadGraphic(Assets.ElevatorSmallPNG, true, false, 16, 16); 
			else
				loadGraphic(Assets.ElevatorMedPNG, true, false, 32, 32); 
			
			addAnimation("idle", [1], 1, true); 
			addAnimation("stop", [2,2,3], 10, true); 
			addAnimation("move", [0,0,1], 4, true); 
				
			_stopTime = StopTime; 
			_auxTimer = new FlxTimer(); 
			_velocity_ant = new FlxPoint();

			//Iniciar en estado Stop 
			onMoveEnd(); 
		} 
		
		override public function destroy():void         
		{ 
			_velocity_ant = null;
			if (_auxTimer != null)
			{
				_auxTimer.destroy(); 
				_auxTimer = null; 
			}			
			super.destroy();                                 
		} 

		override public function update():void 
		{ 
			//Update the elevator's motion 
			super.update(); 
				
			//------------------------------------------------------------------------ STS_MOVE 
			if (estado == STS_MOVE) 
			{ 		
				if (subestado == SBSTS_INIT)
				{
					velocity.copyFrom(_velocity_ant);
					subestado++;
				}
				else
				{
				var pos:Number = (_dir == PATH_HORIZONTAL_ONLY)?x:y; 
				var blim:Boolean = false;
				//Turn around if necessary 
				if(pos > _posend) 
				{ 
					pos = _posend; 
					velocity.x = -velocity.x; 
					velocity.y = -velocity.y; 
					blim = true;
				} 
				else if(pos < _posini) 
				{ 
					pos = _posini; 
					velocity.x = -velocity.x; 
					velocity.y = -velocity.y; 
					blim = true;
				} 
						
				//Si se ha llegado a limite 
				// - Cambiar de estado a stop 
				if(blim) 
				{ 
					if(_dir = PATH_HORIZONTAL_ONLY) 
						x = pos; 
					else 
						y = pos;                                         
					onMoveEnd(); 
				}
				}
			}         
				
			//------------------------------------------------------------------------ STS_STOP 
			else if (estado == STS_STOP) 
			{ 
				if(subestado == SBSTS_INIT) 
				{ 
					_velocity_ant.copyFrom(velocity);
					velocity.x = velocity.y = 0;
					//activar timer de espera al arranque (se asume pos x,y en un extremo init/fin y velocidad en sentido acorde) 
					_auxTimer.start(_stopTime,1,onMoveInit); 
					//play anim: green light                                         
					subestado = SBSTS_CONT; 
				} 
			} 				
		}                 
		
		private function onMoveEnd() 
		{ 
			estado = STS_STOP; 
			subestado = SBSTS_INIT; 
			play("stop");                         
		} 
		
		private function onMoveInit(Timer:FlxTimer) 
		{ 
			estado  = STS_MOVE; 
			subestado = SBSTS_INIT; 
			play("move"); 
		} 
		
} 

}