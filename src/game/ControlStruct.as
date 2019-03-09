package game 
{
	import game.ObjectPool;
	/**
	 * ...
	 * @author imagame
	 */
	public class ControlStruct
	{
		protected var _mapCtrl: Array;	//Layer de control del mapa de la escena de juego (Valores: )
		// Valores Control Layer: (0..9: pintables -en algún momento o circunstancia-, 10..: no pintables)
		public static const VAL_PAINTABLE:uint = 0; 
		public static const VAL_PAINTING_1:uint = 1; 
		public static const VAL_PAINTING_2:uint = 2; 
		public static const VAL_PAINTING_3:uint = 3; 
		public static const VAL_PAINTED:uint = 4; 
		public static const VAL_NOT_PAINTABLE_COL:uint = 10; 
		public static const VAL_NOT_PAINTABLE:uint = 20; 
		
		// 0: pintable sin pintar, 
		// 1: pintable en proceso de inicialización (marcado para pintar)
		// 2: pintable en proceso de pintado
		// 3: pintable en proceso de secado
		// 4: pintable pintado
		// 5..9: sin uso (tmp: pintable bloqueado, pintable nublado, pintable peligro,pinntable oculto...) 
		//10: no pintable (sólido: pared)
		
		//20: no pintable y accesible
		//11: no pintable (muerte: vacío, pinchos)
		//12: no pintable (resta-energía: lava, agua)
		//13: no pintable (portal-in)
		//14: no pintable (portal-out)
		//15: no pintable (spawn)
		public var wt: uint;	//Ancho en tiles del mapa 
		public var ht: uint;	//Alto en tiles en mapa

		public function ControlStruct(CtrlMap: Array, Wt: uint, Ht: uint) 
		{
			trace("ControlStruct");
			transformCtrlLayer2CtrlStruct(CtrlMap);
			wt = Wt;
			ht = Ht;
		}
		
		public function destroy():void
		{
			_mapCtrl = null;
			//TODO Eliminar objetos pool
		}
		
		/**
		 * Check the value of a particular tile.
		 * 
		 * @param	X		The X coordinate of the tile (in tiles, not pixels).
		 * @param	Y		The Y coordinate of the tile (in tiles, not pixels).
		 * 
		 * @return	A uint containing the value of the tile at this spot in the array.
		 */
		public function getVal(X:uint,Y:uint):int
		{
			return _mapCtrl[Y * wt + X];
		}
		
		public function setVal(X:uint, Y:uint, Val:int):void
		{
			_mapCtrl[Y * wt + X] = Val;
		}
		
		private function transformCtrlLayer2CtrlStruct(CtrlMap: Array)
		{
			_mapCtrl = CtrlMap;
			for (var i = 0; i < _mapCtrl.length; i++)
			{
				if (_mapCtrl[i] == 0)
					_mapCtrl[i] = 10;
				else if (_mapCtrl[i] == 1)
					_mapCtrl[i] = 0;
				else if (_mapCtrl[i] == 2)
					_mapCtrl[i] = 20;
				else	
					_mapCtrl[i] = 100; //not found
			}
		}
	
		//UPdate de PintarTile
		//Si estado inicio-pintar recorrer array propagación[8] y para cada valor activo llamar a SueloPintarTile(x,y,rulepaint), donde rulepaint es el valor propagación[i]. Cambiar a estado pintando y ejcecutar primer paso de Pintando
		//Si estado pintando: avanzar proceso pintado. Si fin cambiar a estado secando y cambiar valor Control Tile a Secando
		//Si estado secar: avanzar proceso secado. Si fin Borrar objeto PintarTile y cambiar valor Control Tile a Pintado
	}

}