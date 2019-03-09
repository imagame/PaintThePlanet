package game 
{
	/**
	 * ...
	 * @author imagame
	 */
	public class Assets
	{
		//Gfx idx Constants
		static public const MAP_TILESET_DRAWINDEX:uint = 1;		//Init index for Visible tiles
		static public const MAP_TILESET_COLLIDEINDEX:uint = 60;	//Init index for collidable tiles
		static public const MAP_TILEID_VOIDINI:uint = 1; //Tile vacío inicial,
		static public const MAP_TILEID_VOIDEND:uint = 3; //Tile vacío final,
		static public const MAP_TILEID_NOTSHADED:uint = 38; //Baldosa no sombreada. Resto de baldosas (40+) se proyecta sombra sobre ellas
		static public const MAP_TILESET_AUTOVERT:uint = 46; //Tile pintado automático vertical
		static public const MAP_TILESET_AUTOHORZ:uint = 47; //Tile pintado automático horizontal
		static public const MAP_TILESET_AUTOUP:uint = 48; //Tile pintado automático up
		static public const MAP_TILESET_AUTODO:uint = 49; //Tile pintado automático down
		static public const MAP_TILESET_AUTOLE:uint = 50; //Tile pintado automático left
		static public const MAP_TILESET_AUTORI:uint = 51; //Tile pintado automático right
		
		
		//Menu graphics
		[Embed(source = '../../assets/panel_big.png')]  public static var _panelBigPNG:Class; 
		
		//Fonts
		[Embed(source = '../../assets/font/emulogic.ttf', fontFamily = "emulogic", embedAsCFF = "false")] public static var fnt1:Class;
		[Embed(source = '../../assets/font/neuropolxrg.ttf', fontFamily = "neuro", embedAsCFF = "false")] public static var fnt2:Class;
		[Embed(source = '../../assets/font/internationalist.ttf',fontFamily="internationalist",embedAsCFF="false")] public static var fnt3:Class;
			
		//Constantes colores
		public static const COL_BUT:uint = 0xffffaa66; // 0xffA1A7B7;
		public static const COL_TITBUT:uint = 0xffffeeee;
		
		//Sprite graphics
		[Embed(source = '../../assets/gfx/player64x64.png')] public static var PlayerPNG:Class;
		[Embed(source = '../../assets/gfx/ElevatorSmall.png')] public static var ElevatorSmallPNG:Class;
		[Embed(source='../../assets/gfx/ElevatorMed.png')] public static var ElevatorMedPNG:Class;
		
		//Object graphics
		[Embed(source = '../../assets/gfx/PaintTile25.png')] public static var PaintTilePNG:Class;
		[Embed(source = '../../assets/gfx/PortalIn.png')] public static var PortalInPNG:Class;		
		[Embed(source = '../../assets/gfx/PortalOut.png')] public static var PortalOutPNG:Class;		

	}

}