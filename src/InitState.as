package  
{
	import flash.display.StageScaleMode;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author imagame
	 */
	public class InitState extends FlxState
	{
		//variables públicas persistentes durante toda la vida de la app
		public var numNiveles: int;  //Acceder: InitState(Registry.initState).numNiveles
		
		override public function create():void
		{
			//Set up the view window and double buffering
			//stage.scaleMode = StageScaleMode.EXACT_FIT;
            //stage.align = StageAlign.TOP_LEFT;
           

			numNiveles = 10;
						
			//Create persistent data/objects during app life
			Registry.initState = this;			
			
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			//Registry.lMgr.idStructure = 1;
			//Registry.lMgr.loadLevelPack();

		}
		
		override public function update():void
		{
			super.update();	
			FlxG.switchState(new MenuState() );
		}
				
		
	}

}