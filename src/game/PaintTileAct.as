package game
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	import org.flixel.FlxObject;
   
	import org.flixel.FlxCamera;
	/**
	 * Objetos-acción PintarTile
	 * @author imagame
	 */
	public class PaintTileAct extends FlxSprite
	{
		public var xt: uint;        //Tile pos x
		public var yt: uint;        //Tile pos y
		private var _shade: Boolean;	//Tile shaded?
		private var _ruleProp: uint;
		public var paintSts: int; //Paint status:
		// 0: en inicialización
		// 1: pintando
		// 2: secando
		// 3: finalizado
	   
		private var _timer:Number;
		private var _timerLimit: Number;

		public function PaintTileAct()
		{
			loadGraphic(Assets.PaintTilePNG, true, false, 16, 16);
			addAnimation("paint", [0, 1, 2, 3], 24, false);
			addAnimation("paint_shade", [25, 26, 27, 28], 24, false);
			addAnimation("dry", [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24],10, false); //Para PaintTile25.png
			addAnimation("dry_shade", [29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49],10, false); //Para PaintTile25.png	
		//addAnimationCallback(onPaintTileAnimationChange);
		}
	   
		//Each time a PaintTileAct is recycled (in this game, by the TiledFloor object)this function is called.
		//set estado de PintarTile a inicio-pintar, y set regla heredada pintar (a vacío, a no ser que Player profile tenga un extra de pintado +N, o algo similar)
		public function init(Xt:int, Yt:int, RuleProp:uint, TimerLimit:Number):void
		{
			xt = Xt;
			yt = Yt;
			_shade = (Registry.playstate.lvlMap.getTile(xt, yt) != Assets.MAP_TILEID_NOTSHADED); //el único tile no sombreado es el tileid= 1
			
			_ruleProp = RuleProp
			visible = false;
		   
			reset(xt* Registry.lMgr.tileWidth, yt* Registry.lMgr.tileHeight);
			_timer = 0;
			_timerLimit = TimerLimit;

			paintSts = 0;
			Registry.playstate.scene.setTilePrevPaint(xt, yt);
		}
	   
	   
		override public function destroy():void
		{
			super.destroy();
		}
	   
	   
	   /*
		function onPaintTileAnimationChange(AnimName: String, FrameNumber: uint, FrameIndex: uint ):void
		{
				if (FrameNumber == 4)
						paintSts = 2;
			   
		}
	   */
	   
		//UPdate de PintarTile
		//Si estado inicio-pintar recorrer array propagación[8] y para cada valor activo llamar a SueloPintarTile(x,y,rulepaint), donde rulepaint es el valor propagación[i]. Cambiar a estado pintando y ejcecutar primer paso de Pintando
		//Si estado pintando: avanzar proceso pintado. Si fin cambiar a estado secando y cambiar valor Control Tile a Secando
		//Si estado secar: avanzar proceso secado. Si fin Borrar objeto PintarTile y cambiar valor Control Tile a Pintado

		override public function update():void
		{                
			super.update();                
			_timer += FlxG.elapsed;
		   
		   
			if(_timer >= _timerLimit)
			{
				//trace ("PaintileAct-Update(): [" + xt + ","+ yt+"] => "+ _timer+"  (sts: "+paintSts+")");
				switch(paintSts)
				{
					case 0: //en inicialización
						//Interpretar RuleProg y crear PaintTileAct derivados (con estado 0, y timer ejecución Act+200ms, y ruleprog derivada)
						//Para cada dir automática de pintado chequear si tile es pintable.
						//TODO crear objetos PaintTileAct derivados, según ruleProp                                                       
						if((_ruleProp & FlxObject.UP) > 0)
						{
							if (Registry.playstate.scene.isTilePintable(xt,yt-1))
								Registry.playstate.scene.makePaintTile(xt, yt-1, _ruleProp, 0.05); //0.05 valor de retardo en el pintado automático de tiles (idéntico para todos los niveles)																
						}
						if((_ruleProp & FlxObject.DOWN) > 0)
						{
							if (Registry.playstate.scene.isTilePintable(xt,yt+1))                                                              
								Registry.playstate.scene.makePaintTile(xt, yt+1, _ruleProp, 0.05);        
						}
						if((_ruleProp & FlxObject.LEFT) > 0)
						{
							if (Registry.playstate.scene.isTilePintable(xt-1,yt))
								Registry.playstate.scene.makePaintTile(xt-1, yt, _ruleProp, 0.05);
						}
						if((_ruleProp & FlxObject.RIGHT) > 0)
						{
							if (Registry.playstate.scene.isTilePintable(xt+1,yt))
								Registry.playstate.scene.makePaintTile(xt+1, yt, _ruleProp, 0.05);
						}
						
						paintSts = 1;
						if (_shade)
							play("paint_shade");
						else
							play("paint");
						Registry.playstate.scene.setTileInPaint(xt, yt);
						visible = true;                                          
						break;
					
					case 1: //pintando											
						if (finished) //si anim finaliza
						{
							//finished = false; (no importa, es automático)
							paintSts = 2;
							if (_shade)
								play("dry_shade");
							else
								play("dry");
							Registry.playstate.scene.setTileInDry(xt, yt);
						}
						break;
						
					case 2: //secando
						if (finished)
						{
							paintSts = 3;                                                        
							play("score")
							Registry.playstate.scene.setTilePainted(xt, yt);
						}
						break;
						
					case 3: //finalizando
						if(finished)
						{
							//TODO incrementa contador tile pintado
							_timer = 0;
							kill();
						}
				}
		}
			   
			   
		}
	}

}





