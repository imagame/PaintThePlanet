package  
{

	import adobe.utils.CustomActions;
	import game.Assets;
	import game.TiledFloor;
    import org.flixel.*;
	
	import net.hires.debug.MovieMonitor;
	/**
	 * ...
	 * @author imagame
	 */
	public class Registry
	{
		//Accesors		
		static public var initState:FlxState;
		static public var monitor: MovieMonitor;
		
		static public var playstate: PlayState;
		//static public var scene: TiledFloor;
		
		//Game Properties

		
		//Level Manager (esta info la colocamos en levelmanager)
		//static public var bLevelComplete: Boolean;	//Nivel actual completado
		//static public var bGameOver: Boolean;
		//static public var bGameComplete
		
		//TMP
		static public var contadorEstados: int; 
		
		//Managers
		static public var lMgr: LevelManager = new LevelManager();
		static public var gpMgr: GamePropManager = new GamePropManager();

	}

}