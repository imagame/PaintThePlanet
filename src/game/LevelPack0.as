package game 
{
	/**
	 * Datos y recursos del Level Pack 0 del juego PtP
	 * @author imagame
	 */
	public class LevelPack0 implements ILevelPack
	{
		//Información requerida en Level Pack
               
        //Nº de niveles
               
		//Nº de portales de entrada y salida de cada nivel
               
		//Embeded level .tmx filenames in this Level Pack
		[Embed(source='../../assets/levels/Level01.tmx', mimeType='application/octet-stream')] public var LevelMap0:Class;
		[Embed(source = '../../assets/levels/Level02.tmx', mimeType = 'application/octet-stream')] public var LevelMap1:Class;
		
		//Embeded tileset filenames used in level .tmx files in this Level Pack
		[Embed(source = '../../assets/gfx/Tileset0.png')] public var ImgTileset0:Class;
		[Embed(source='../../assets/gfx/Tileset1.png')] public var ImgTileset1:Class;

		//Embeded background images used in level .tmx files in this Level Pack
		[Embed(source = '../../assets/gfx/Background0.png')] public var ImgBg0:Class;
		[Embed(source = '../../assets/gfx/Background1.png')] public var ImgBg1:Class;
		[Embed(source = '../../assets/gfx/Background2.png')] public var ImgBg2:Class;
	   
		//Tilesets de objetos gráficos de cada nivel-Tema
	   
		//Tileset de entidades
		
		
		public function LevelPack0() 
		{

		}
		
		/* INTERFACE ILevelPack */
		
		/**
		 * Get a class reference to the level requested by param
		 * @param	Level
		 * @return	Class name representing the .tmx file of the scene level
		 */
		public function getMapClassRef(Level:int):Class
		{
			switch(Level)
			{
				case 0: return LevelMap0;
				case 1: return LevelMap0;
				case 2: return LevelMap1;
			}
			return LevelMap0;
		}
		
		/**
		 * Get a class reference to a .png tileset file 
		 * @param	Filename
		 * @return
		 */
		public function getTilesetClassRef(Filename:String):Class
		{
			switch(Filename)
			{
				case "Tileset0.png": return ImgTileset0;
				case "Tileset1.png": return ImgTileset1;
			}
			return ImgTileset0;
		}
		
		/**
		 * Get a class reference to a .png image background file 
		 * @param	Filename
		 * @return
		 */
		public function getImgBgClassRef(Filename:String):Class
		{
			switch(Filename)
			{
				case "Background0.png": return ImgBg0;
				case "Background1.png": return ImgBg1;
				case "Background2.png": return ImgBg2; 
			}
			return ImgBg0;
		}
		
	}

}