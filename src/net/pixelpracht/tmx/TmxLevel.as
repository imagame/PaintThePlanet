package net.pixelpracht.tmx 
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;

	import net.pixelpracht.tmx.TmxMap;
	import net.pixelpracht.tmx.TmxObject;
	import net.pixelpracht.tmx.TmxObjectGroup;
	
	import org.flixel.*;

	/**
	 * ...
	 * @author imagame
	 */
	public class TmxLevel
	{
		public var idLevel: int; //Id del nivel actualmente cargado 		
		
		private var _levelMapClass: Class;
		
		public var tmx: TmxMap;
		
		public function TmxLevel(Level: int, LevelMapClass: Class) 
		{
			idLevel = Level;
			_levelMapClass = LevelMapClass; 

			//MEJORAS: alternativas de mejora para no depende de clases embeded
			//Intento 1: Automatizar conversión dinámica de string a Class 
			//_levelMapClass = getDefinitionByName("../../../../assets/Level01.tmx") as Class; 
			//var data:XML = new _levelMapClass() as XML; 
			
			//Intento 2: Cargar ficheros XML y generar objeto XML tras la carga 
			//var loader:URLLoader = new URLLoader(); 
			//loader.addEventListener(Event.COMPLETE, onFileLoaded); 
			//var u: URLRequest = new URLRequest("file:/net.pixelpracht.tmx/Level01.tmx"); 
			//loader.load(u);          

		}
		
		
		public function loadTmxFile():void
		{
			/*
			var loader:URLLoader = new URLLoader(); 
			loader.addEventListener(Event.COMPLETE, onTmxLoaded); 
			var u: URLRequest = new URLRequest('C:\Downloads\Level01.tmx');
			//var u: URLRequest = new URLRequest(new levelMap());
			loader.load(u); //TODO
			*/
			onTmxLoaded();
		}
		
		/*
		private function onFileLoaded(e:Event):void
		{
			var xml:XML = new XML(e.target.data);
			tmx = new TmxMap(xml);
		}
		*/
		
		public function getTileWidth():int
		{
			return tmx.tileWidth;
		}
		public function getTileHeight():int
		{
			return tmx.tileHeight;
		}
		
		public function getPropertyMap(Prop: String):String
		{
			return tmx.properties[Prop];
		}
		
		private function onTmxLoaded():void
		{
			//var xml:XML = new XML (new levelMap());
			var xml:XML = new XML (new _levelMapClass());
			tmx = new TmxMap(xml);
		}
		
		

	}

}