/**
 * $Id: StageViewEvent.as 974 2010-02-24 20:41:54Z expo $
 * $Author Daniele Esposti $
 * $Rev: 974 $ $LastChangedDate: 2010-02-24 20:41:54 +0000 (Wed, 24 Feb 2010) $
 * $URL: svn+ssh://ubuntu/media/expo/iomega/svn/prodigyt/radialmenu/src/net/expobrain/radialmenudemo/mediators/views/stage/StageViewEvent.as $
 * 
 */


package net.expobrain.radialmenudemo.mediators.views.stage
{
	import flash.events.DataEvent;
	
	public class StageViewEvent extends DataEvent
	{
		public static const RESIZE:String = "resizeViewEvent";
		
		public function StageViewEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, data:String="")
		{
			super(type, bubbles, cancelable, data);
		}
	}
}