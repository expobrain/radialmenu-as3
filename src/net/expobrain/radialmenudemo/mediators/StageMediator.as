/**
 * $Id: StageMediator.as 1017 2010-03-01 23:40:54Z expo $
 * $Author Daniele Esposti $
 * $Rev: 1017 $ $LastChangedDate: 2010-03-01 23:40:54 +0000 (Mon, 01 Mar 2010) $
 * $URL: svn+ssh://ubuntu/media/expo/iomega/svn/prodigyt/radialmenu/src/net/expobrain/radialmenudemo/mediators/StageMediator.as $
 * 
 */


package net.expobrain.radialmenudemo.mediators
{
	import flash.display.Stage;
	import flash.events.Event;
	
	import net.expobrain.radialmenudemo.mediators.views.stage.StageView;
	import net.expobrain.radialmenudemo.mediators.views.stage.StageViewEvent;
	import net.expobrain.radialmenudemo.notifications.ApplicationNotification;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class StageMediator extends Mediator implements IMediator
	{
    	public static const NAME:String = "stageMediator";
		
		private var _stageView:StageView;
		
	    public function StageMediator( viewComponent:Object )
	    {
			// Ensure the viewComponent is a Stage instance
			super( NAME, Stage( viewComponent ) );
	    }
		
		/**
		 * Get the view component as a Stage instance
		 */
		private function get stage(): Stage
		{
			return Stage( viewComponent );
		}
		
		/**
		 * When the mediator is registered it loas the view, add it to the stage 
		 * and register the others children mediators
		 */
		override public function onRegister(): void
		{
			// Load View
			_stageView = new StageView();
			
			stage.addChild( _stageView );
			
			// Add events
			_stageView.addEventListener( StageViewEvent.RESIZE, onResizeEvent );
		}
		
		/**
		 * When the mediator is removed it remove the view from the stage 
		 * and remove the other children mediators too
		 */
		override public function onRemove(): void
		{
			// Remove view
			stage.removeChild( _stageView );
			
			// Remove events
			_stageView.removeEventListener( StageViewEvent.RESIZE, onResizeEvent );
		}
		
		/**
		 * Dispatch stage resize notification to the business logic
		 */
		private function onResizeEvent( event:Event ): void
		{
			sendNotification( ApplicationNotification.RESIZE, event.currentTarget );
		}
  }
}