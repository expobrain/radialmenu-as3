/**
 * $Id: BaseSprite.as 1016 2010-03-01 23:13:35Z expo $
 * $Author Daniele Esposti $
 * $Rev: 1016 $ $LastChangedDate: 2010-03-01 23:13:35 +0000 (Mon, 01 Mar 2010) $
 * $URL: svn+ssh://ubuntu/media/expo/iomega/svn/prodigyt/radialmenu/src/net/expobrain/radialmenudemo/core/BaseSprite.as $
 * 
 */


package net.expobrain.radialmenudemo.core
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * BaseSprite class implements a base sprite management and events.
	 * This	class automatically implements ADDED_TO_STAGE and REMOVED_FROM_STAGE events
	 * so the user don't need to re-implement these events every time but
	 * he must only override onAddedToStage and onRemovedFromStage methods
	 */ 
	public class BaseSprite extends Sprite implements ISprite
	{
		public function BaseSprite()
		{
			super();

			// Call user initialization
			onInit();
			
			// Add events
			addEventListener( Event.ADDED_TO_STAGE, _onAddedToStage );
		}
		
		private function _onAddedToStage( event:Event ): void
		{
			// Remove events
			removeEventListener( Event.ADDED_TO_STAGE, _onAddedToStage );
			
			// Add events
			addEventListener( Event.REMOVED_FROM_STAGE, _onRemovedFromStage );
			
			// Execute stage-related user code 
			onAddedToStage( event );
		}
		
		private function _onRemovedFromStage( event:Event ): void
		{
			// Remove events
			removeEventListener( Event.REMOVED_FROM_STAGE, _onRemovedFromStage );
			
			// Call stage-related user code
			onRemovedFromStage( event );
		}
		
		// Implements empty methods
		public function onInit():void {}
		public function onAddedToStage(event:Event):void {}
		public function onRemovedFromStage(event:Event):void {}
		public function dispose(): void {}
	}
}