package

{

	import org.flixel.*;

	[SWF(width = "960", height = "640", backgroundColor = "#000000")]
	//[SWF(width="640", height="480", backgroundColor="#000000")]
	[Frame(factoryClass="Preloader")]



	public class Flixel0 extends FlxGame
	{
		public function Flixel0()
		{			
			//iPhone 3GS Resolution
			//super(240,160,InitState, 2, 60, 60);
			//super(480,320,InitState, 1, 60, 60);
			
			//iPhone 4,4S Resolution (Retina Display)
			//super(480, 320, InitState, 2, 60, 60);
			//super(960, 640, InitState, 1, 60, 60);
			
			//Custom Resolution
			//super(960, 640, InitState, 1, 60, 60);
			//super(320, 240, InitState, 2, 60, 60);	
			
			super(480, 320, InitState, 2, 60, 60);	
		//	super(240, 160, InitState, 4, 60, 60);
			//super(640, 480,InitState,1, 60, 60);
			
			
			forceDebugger = true;

		}

	}

}

