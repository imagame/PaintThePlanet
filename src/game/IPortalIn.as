package game 
{
	
	/**
	 * ...
	 * @author imagame
	 */
	public interface IPortalIn 
	{
		/**
		 * Implement the <code>onPortalInPre()</code> method to ensure that a PortalIn can safely call the object that enters in the portal at the very beginning
		 */
		function onPortalInPre():void;
	   
		/**
		 * Implement the <code>onPortalInPost()</code> method to ensure that a PortalIn can safely call the object that enters in the portal at the finalization of the entering process
		 */
		function onPortalInPost():void;
	
	}
	
}