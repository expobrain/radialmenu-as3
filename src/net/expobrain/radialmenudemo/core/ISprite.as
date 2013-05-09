/**
 * $Id: ISprite.as 985 2010-02-27 15:13:08Z expo $
 * $Author Daniele Esposti $
 * $Rev: 985 $ $LastChangedDate: 2010-02-27 15:13:08 +0000 (Sat, 27 Feb 2010) $
 * $URL: svn+ssh://ubuntu/media/expo/iomega/svn/prodigyt/radialmenu/src/net/expobrain/radialmenudemo/core/ISprite.as $
 * 
 */


package net.expobrain.radialmenudemo.core
{
	import flash.events.Event;

	public interface ISprite
	{
		/**
		 * This method is called when the sprite is initilialized, all user code which create
		 * children object or set grahpics elements mut be here
		 */
		function onInit(): void;
		
		/**
		 * This method automatically remove ADDED_TO_STAGE event and and REMOVED_FROM_STAGE event
		 * Also execute stage-related user code
		 */
		function onAddedToStage( event:Event ): void;
		
		/**
		 * This method automatically remove REMOVED_FROM_STAGE event and and REMOVED_FROM_STAGE event
		 * Also execute stage-related user code
		 */
		function onRemovedFromStage( event:Event ): void;	
		
		/**
		 * This method must be called manually by the user when the object must be
		 * completely removed from system memory.
		 * In this method the user must implement all the code he need to remove
		 * reference and deallocate resources to be sure the class can be deleted
		 * by the garbage collector.
		 */
		function dispose(): void;
	}
}