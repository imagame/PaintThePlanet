package game 
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	
	/**
	 * ...
	 * @author imagame
	 */
	public class PaintTile extends FlxSprite
	{
		public var tilex: int;	//Tile pos x
		public var tiley: int;	//Tile pos y
		public var paintSts: int; //Paint status: 
		
		public function PaintTile(Serie: int, X:Number = 0, Y:Number = 0, SimpleGraphic:Class = null) 
		{
			super(X, Y, SimpleGraphic);
			ID = Serie;
			
			tilex = X * Registry.lMgr.tileWidth;
			tiley = Y * Registry.lMgr.tileHeight;
			paintSts = 0;
		}
		
		override public function destroy():void
		{
			super.destroy();
		}
		
		public function Pintar():void
		{
			
		}
		
		public function Secar(): void
		{
			
		}
		
		//UPdate de PintarTile
		//Si estado inicio-pintar recorrer array propagación[8] y para cada valor activo llamar a SueloPintarTile(x,y,rulepaint), donde rulepaint es el valor propagación[i]. Cambiar a estado pintando y ejcecutar primer paso de Pintando
		//Si estado pintando: avanzar proceso pintado. Si fin cambiar a estado secando y cambiar valor Control Tile a Secando
		//Si estado secar: avanzar proceso secado. Si fin Borrar objeto PintarTile y cambiar valor Control Tile a Pintado

		override public function update():void
		{		
			super.update();
			trace ("Paintile: " + ID + "  => "+ FlxG.elapsed);
		}
	}

}