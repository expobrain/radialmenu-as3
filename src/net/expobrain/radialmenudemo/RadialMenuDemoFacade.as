/**
 * $Id: RadialMenuDemoFacade.as 1034 2010-03-04 22:50:37Z expo $
 * $Author Daniele Esposti $
 * $Rev: 1034 $ $LastChangedDate: 2010-03-04 22:50:37 +0000 (Thu, 04 Mar 2010) $
 * $URL: svn+ssh://ubuntu/media/expo/iomega/svn/prodigyt/radialmenu/src/net/expobrain/radialmenudemo/RadialMenuDemoFacade.as $
 * 
 */


package net.expobrain.radialmenudemo
{
	import flash.display.Stage;
	
	import net.expobrain.radialmenudemo.commands.application.StartupCommand;
	import net.expobrain.radialmenudemo.notifications.ApplicationNotification;
	
	import org.puremvc.as3.interfaces.IFacade;
	import org.puremvc.as3.patterns.facade.Facade;
	
	public class RadialMenuDemoFacade extends Facade implements IFacade
	{
		public static function getInstance(): RadialMenuDemoFacade
		{
			if ( instance == null ) {
				instance = new RadialMenuDemoFacade();
			}
			
			return RadialMenuDemoFacade( instance );
		}
		
		override protected function initializeController() : void
		{
			super.initializeController();
			
			// Application
			registerCommand( ApplicationNotification.STARTUP, StartupCommand );
		}
		
		public function startup( stage:Stage ): void
		{
			sendNotification( ApplicationNotification.STARTUP, stage );
		}
	}
}