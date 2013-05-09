/**
 * $Id: RadialMenuEvent.as 1018 2010-03-02 07:48:45Z expo $
 * $Author Daniele Esposti $
 * $Rev: 1018 $ $LastChangedDate: 2010-03-02 07:48:45 +0000 (Tue, 02 Mar 2010) $
 * $URL: svn+ssh://ubuntu/media/expo/iomega/svn/prodigyt/radialmenu/src/net/expobrain/radialmenudemo/core/controls/radialmenu/RadialMenuEvent.as $
 * 
 */


package net.expobrain.radialmenudemo.core.controls.radialmenu
{
	import flash.events.Event;
	
	public class RadialMenuEvent extends Event
	{
		public static const ITEM_CLICK:String = "itemClick";
		
		private var _id:uint;
		
		public function RadialMenuEvent(type:String, id:uint)
		{
			_id = id;
			
			super(type);
		}
		
		override public function clone(): Event
		{
			return new RadialMenuEvent( type, id );
		}

		public function get id():uint
		{
			return _id;
		}
	}
}