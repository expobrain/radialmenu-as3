/**
 * $Id: StartupCommand.as 974 2010-02-24 20:41:54Z expo $
 * $Author Daniele Esposti $
 * $Rev: 974 $ $LastChangedDate: 2010-02-24 20:41:54 +0000 (Wed, 24 Feb 2010) $
 * $URL: svn+ssh://ubuntu/media/expo/iomega/svn/prodigyt/radialmenu/src/net/expobrain/radialmenudemo/commands/application/StartupCommand.as $
 * 
 */


package net.expobrain.radialmenudemo.commands.application
{
	import flash.display.Stage;
	
	import net.expobrain.radialmenudemo.mediators.StageMediator;
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class StartupCommand extends SimpleCommand implements ICommand
	{
		override public function execute(notification:INotification):void
		{
			var stage: Stage = notification.getBody() as Stage;
			
			// Register mediators
	    	facade.registerMediator( new StageMediator( stage ) );
		}
	}
}
