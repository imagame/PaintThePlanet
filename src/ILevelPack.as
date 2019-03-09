package  
{
	
	/**
	 * ...
	 * @author imagame
	 */
	public interface ILevelPack 
	{
		function getMapClassRef(Level: int):Class 
		function getTilesetClassRef(Filename: String): Class
		function getImgBgClassRef(Filename: String): Class

	}
	
}