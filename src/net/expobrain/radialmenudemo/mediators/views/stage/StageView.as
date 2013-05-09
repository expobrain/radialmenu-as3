/**
 * $Id: StageView.as 1420 2010-12-19 18:07:23Z expo $
 * $Author Daniele Esposti $
 * $Rev: 1420 $ $LastChangedDate: 2010-12-19 18:07:23 +0000 (Sun, 19 Dec 2010) $
 * $URL: svn+ssh://ubuntu/media/expo/iomega/svn/prodigyt/radialmenu/src/net/expobrain/radialmenudemo/mediators/views/stage/StageView.as $
 * 
 */


package net.expobrain.radialmenudemo.mediators.views.stage
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.utils.getTimer;
	
	import net.expobrain.radialmenudemo.core.BaseSprite;
	import net.expobrain.radialmenudemo.core.ISprite;
	import net.expobrain.radialmenudemo.core.controls.radialmenu.RadialMenuControl;
	import net.expobrain.radialmenudemo.core.controls.radialmenu.RadialMenuEvent;
	
	public class StageView extends BaseSprite implements ISprite
	{
		public static const NAME:String = "stageView";
		
		public static const BACKGROUND_COLOR:uint	= 0xffffff;
		public static const MENU_CONFIG_XML:String	= "assets/menudemo.xml";
		
		private var _menu:RadialMenuControl;
		private var _status:TextField;
		private var _mouseClick:Boolean;
		private var _menuRotation:Number = 0;
			
		override public function onAddedToStage( event:Event) : void
		{
			// Draw background
			drawBackground();
			
			// Open the menu by default
			openMenu( new Point( stage.width / 2, stage.height / 2 ) );
			
			// Add events
			stage.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDownEvent );
			stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUpEvent );
			stage.addEventListener( Event.RESIZE, onResizeEvent );
		}
		
		private function openMenu( position:Point ): void
		{
			// Open the menu int the given position
			_menu = new RadialMenuControl( MENU_CONFIG_XML );
			
			_menu.x = position.x;
			_menu.y = position.y;
			
			// Add events
			_menu.addEventListener( RadialMenuEvent.ITEM_CLICK, onItemClickEvent );
			
			// Set last rotation
			_menu.rotation = _menuRotation;
			
			// Add to stage
			addChild( _menu );
		}
		
		override public function onInit(): void
		{
			// Add status text on the background
			_status = new TextField();
			
			_status.type = TextFieldType.DYNAMIC;
			_status.selectable = false;
			_status.autoSize = TextFieldAutoSize.LEFT;
			_status.mouseEnabled = false;
			
			addChild( _status );
		}
		
		override public function onRemovedFromStage(event:Event) : void
		{
			// Remove events
			stage.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDownEvent );
			stage.removeEventListener( MouseEvent.MOUSE_UP, onMouseUpEvent );
			stage.removeEventListener( Event.RESIZE, onResizeEvent );
		}
		
		private function drawBackground(): void
		{
			// Draw background
			graphics.beginFill( BACKGROUND_COLOR );
			graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
			graphics.endFill()
		}
		
		private function onMouseDownEvent( event:MouseEvent ): void
		{
			_mouseClick = event.target == this;
		}
		
		private function onMouseUpEvent( event:MouseEvent ): void
		{
			// Check if the click was over the stage
			if ( _mouseClick )
			{
				if ( _menu && event.target == this )
				{
					// Menu is opened, close it
					closeMenu();
				}
				else if ( _menu == null )
				{
					// Menu is closed, open it
					openMenu( new Point( event.localX, event.localY ) );
				}
			}
			
			// Reset mouse click flag
			_mouseClick = false;
		}
		
		private function onItemClickEvent( event:RadialMenuEvent ): void
		{
			_status.text = "Click on item id " + event.id + "\n" + _status.text;
		}
		
		private function onResizeEvent( event:Event ): void
		{
			// Redraw background
			drawBackground();
			
			// Dispatch event
			dispatchEvent( new StageViewEvent( StageViewEvent.RESIZE ) );
		}
		
		private function closeMenu(): void
		{
			// Close the menu
			_menu.removeEventListener( RadialMenuEvent.ITEM_CLICK, onItemClickEvent );
			
			removeChild( _menu );
			
			// Save rotation before dispose
			_menuRotation = _menu.rotation;
			
			// Dispose menu
			_menu.dispose();
			
			_menu = null
		}
	}
}