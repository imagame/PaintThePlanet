package game 
{
	
	/**
	 * ...
	 * @author imagame
	 */
	public interface IPortalOut 
	{
		/**
		 * Implement the <code>onPortalOutPre()</code> method to ensure that a PortalOut can safely call the object that enters in the portal at the very beginning
		 */
		function onPortalOutPre():void;
	   
		/**
		 * Implement the <code>onPortalOutPost()</code> method to ensure that a PortalOut can safely call the object that enters in the portal at the finalization of the entering process
		 */
		function onPortalOutPost():void;
	}
	
}