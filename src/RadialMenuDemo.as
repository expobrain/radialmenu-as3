/**
 * $Id: RadialMenuDemo.as 1420 2010-12-19 18:07:23Z expo $
 * $Author Daniele Esposti $
 * $Rev: 1420 $ $LastChangedDate: 2010-12-19 18:07:23 +0000 (Sun, 19 Dec 2010) $
 * $URL: svn+ssh://ubuntu/media/expo/iomega/svn/prodigyt/radialmenu/src/RadialMenuDemo.as $
 * 
 */


package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import net.expobrain.radialmenudemo.RadialMenuDemoFacade;
	
	[SWF(framrate="60", title="aaa")]
	public class RadialMenuDemo extends Sprite
	{
		public function RadialMenuDemo()
		{
			// Setup stage
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			// Start demo
			RadialMenuDemoFacade.getInstance().startup( stage );
		}
	}
}