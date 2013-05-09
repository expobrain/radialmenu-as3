/**
 * $Id: ApplicationNotification.as 974 2010-02-24 20:41:54Z expo $
 * $Author Daniele Esposti $
 * $Rev: 974 $ $LastChangedDate: 2010-02-24 20:41:54 +0000 (Wed, 24 Feb 2010) $
 * $URL: svn+ssh://ubuntu/media/expo/iomega/svn/prodigyt/radialmenu/src/net/expobrain/radialmenudemo/notifications/ApplicationNotification.as $
 * 
 */


package net.expobrain.radialmenudemo.notifications
{
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.observer.Notification;
	
	public class ApplicationNotification extends Notification implements INotification
	{
		public static const STARTUP:String	= "startupApplicationNotification";
		public static const RESIZE:String	= "resizeApplicationNotification";
		
		public function ApplicationNotification(name:String, body:Object=null, type:String=null)
		{
			super(name, body, type);
		}
	}
}