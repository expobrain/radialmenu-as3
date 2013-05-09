/**
 * $Id: RadialMenuItem.as 1042 2010-03-05 07:58:41Z expo $
 * $Author Daniele Esposti $
 * $Rev: 1042 $ $LastChangedDate: 2010-03-05 07:58:41 +0000 (Fri, 05 Mar 2010) $
 * $URL: svn+ssh://ubuntu/media/expo/iomega/svn/prodigyt/radialmenu/src/net/expobrain/radialmenudemo/core/controls/radialmenu/RadialMenuItem.as $
 * 
 */


package net.expobrain.radialmenudemo.core.controls.radialmenu
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	import net.expobrain.radialmenudemo.core.BaseSprite;
	
	public class RadialMenuItem extends BaseSprite implements IRadialMenuItem
	{
		[Embed(source="libs/courier.ttf", fontFamily="CourierEmbedded", fontWeight="normal", embedAsCFF="false")]
		public static var fontCourierEmbedded:Class;
		
		public static const DEFAULT_SIZE:uint		= 24;
		public static const TOOLTIP_DELAY:Number	= 2000;
		public static const TOOLTIP_TIMEOUT:Number	= 5000;
		
		public var id:uint;
		public var parentItem:RadialMenuItem;
		public var iconUrl:String;
		public var title:String;
		public var tooltip:String
		public var children:Vector.<RadialMenuItem> = new Vector.<RadialMenuItem>();
		public var ringThickness:uint = RadialMenuControl.DEFAULT_RING_THICKNESS;
		
		private var _tooltipTimer:Timer;
		private var _tooltipSprite:RadialMenuTooltip;
		private var _titleSprite:TextField;
		private var _loader:Loader;
		private var _throbberSprite:Sprite;
		private var _iconSprite:Sprite;
		private var _showTitle:Boolean;
		
		private function removeLoaderEvents(): void
		{
			// Remove events
			_loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, onLoaderCompleteEvent );
			_loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, onLoaderErrorEvent );
			_loader.contentLoaderInfo.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, onLoaderSecurityError );
		}
		
		private function onIconMouseOutEvent( event:MouseEvent ): void
		{
			// Remove effects
			_iconSprite.filters = [];
			
			// Remove timer and tooltip
			removeTooltipTimer();
			removeTooltipSprite();
		}
		
		/**
		 * Removes tooltip timer and related events if timer is set
		 */
		private function removeTooltipTimer(): void
		{
			if ( _tooltipTimer )
			{
				_tooltipTimer.stop();
				_tooltipTimer.removeEventListener( TimerEvent.TIMER_COMPLETE, onTooltipTimerEvent );
				
				_tooltipTimer = null;
			}
		}
		
		/**
		 * Removes tooltip if present
		 */
		private function removeTooltipSprite(): void
		{
			if ( _tooltipSprite )
			{
				stage.removeChild( _tooltipSprite );
				
				_tooltipSprite = null;
			}
		}

		private function onTooltipTimerEvent( event:TimerEvent ): void
		{
			// Remove current timer
			removeTooltipTimer();
			
			// If tootlip is on stage, starts timout timer else open it
			if ( _tooltipSprite )
			{
				// Remove tooltip
				removeTooltipSprite();
			}
			else
			{
				// Show tooltip
				// Tooltip is placed over the stage and translated/rotated to match the item position
				// so it will always be over all the widget's body
				
				// Calculate item rotation by stage perspective
				var point1:Point = new Point( _iconSprite.x, _iconSprite.y );
				var point2:Point = new Point( _iconSprite.x + _iconSprite.width, _iconSprite.y );
				var angle:Number;
				
				point1 = localToGlobal( point1 );
				point2 = localToGlobal( point2 );
				
				angle = Math.atan2( point2.y - point1.y, point2.x - point1.x );
				
				// calculate item scale ratio
				var side:Number = Math.sqrt( 
					Math.pow( point2.x - point1.x, 2 ) + Math.pow( point2.y - point1.y, 2 ) 
				);
				var scale:Number = side / _iconSprite.width;
				
				// Create tooltip sprite
				var point:Point = localToGlobal( new Point() );
				var matrix:Matrix = new Matrix();
				
				_tooltipSprite = new RadialMenuTooltip( tooltip );

				matrix.translate( 0, - _tooltipSprite.height - _iconSprite.height / 2 );
				matrix.rotate( angle );
				matrix.scale( scale, scale );
				matrix.translate( point.x, point.y );
				
				_tooltipSprite.transform.matrix = matrix;
				
				stage.addChild( _tooltipSprite );
				
				// Add timeout timer
				_tooltipTimer = new Timer( TOOLTIP_TIMEOUT, 1 );
				
				_tooltipTimer.addEventListener( TimerEvent.TIMER_COMPLETE, onTooltipTimerEvent );
				
				_tooltipTimer.start();
			}
		}
		
		private function onIconMouseOverEvent( event:MouseEvent ): void
		{
			// Apply effects
			_iconSprite.filters = [ new GlowFilter( 0xffffff, .5 ) ];
			
			// Start tooltip delay timer
			_tooltipTimer = new Timer( TOOLTIP_DELAY, 1 );
			
			_tooltipTimer.addEventListener( TimerEvent.TIMER_COMPLETE, onTooltipTimerEvent );
			
			_tooltipTimer.start();
		}
		
		override public function dispose(): void
		{
			// Remove timer and tooltip
			removeTooltipTimer();
			removeTooltipSprite(); 
			
			// Remove loader if not null
			if ( _loader != null ) {
				// Remove events
				removeLoaderEvents();
				
				// Close connection
				// Catch IOError if connection it's not started
				// or throw error if another type of exception
				try {
					_loader.close();
				}
				catch ( error:IOError ) {}
				catch ( error:* ) {
					throw error;
				}
				
				// Remove Loader instance
				_loader = null;
			}
			
			// Remove icons event if present
			if ( _iconSprite )
			{
				_iconSprite.removeEventListener( MouseEvent.MOUSE_OUT, onIconMouseOutEvent );
				_iconSprite.removeEventListener( MouseEvent.MOUSE_OVER, onIconMouseOverEvent );
			}
		}
		
		override public function onInit(): void
		{
			// Draw throbber
			_throbberSprite = getThrobber();
			
			_throbberSprite.x = - _throbberSprite.width / 2;
			_throbberSprite.y = - _throbberSprite.height / 2;
			
			addChild( _throbberSprite );
		}
		
		override public function onAddedToStage( event:Event ): void
		{
			// Create font format
			var format:TextFormat = new TextFormat();
			
			format.font = "CourierEmbedded";
			format.size = 12;
			format.align = TextFormatAlign.LEFT;
			
			// Create title
			_titleSprite = new TextField();

			_titleSprite.embedFonts = true;
			_titleSprite.selectable = false;
			_titleSprite.autoSize = TextFieldAutoSize.LEFT;
			_titleSprite.defaultTextFormat = format;
			_titleSprite.text = title;

			_titleSprite.x = ringThickness * 2 / 3;
			_titleSprite.y = -_titleSprite.height / 2;
			
			addChild( _titleSprite );
			
			// Start loading icon
			if ( _iconSprite == null )
			{
				_loader = new Loader();
				
				_loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onLoaderCompleteEvent );
				_loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onLoaderErrorEvent );
				_loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onLoaderSecurityError );
				
				_loader.load( new URLRequest( iconUrl ), new LoaderContext( true ) );
			}
			
			// Add events
			addEventListener( MouseEvent.MOUSE_DOWN, onMOuseDownEvent );
		}
		
		private function onMOuseDownEvent( event:MouseEvent ): void
		{
			// Remove timer and tooltip
			removeTooltipTimer();
			removeTooltipSprite();
		}	
		
		override public function onRemovedFromStage( event:Event ): void
		{
			// Remove events
			removeEventListener( MouseEvent.MOUSE_DOWN, onMOuseDownEvent );
			
			// Remove timer and tooltip
			removeTooltipTimer();
			removeTooltipSprite();
		}
		
		/**
		 * Return throbber to display when waiting for icon
		 */
		private function getThrobber(): Sprite
		{
			var sprite:Sprite = new Sprite();
			
			sprite.graphics.beginFill( 0x000000 );
			sprite.graphics.drawRect( 0, 0, DEFAULT_SIZE, DEFAULT_SIZE );
			sprite.graphics.endFill();
			
			return sprite;
		}
		
		/**
		 * Return icon
		 */
		private function getIcon( icon:BitmapData ): Sprite
		{
			var sprite:Sprite = new Sprite();
			
			sprite.graphics.beginBitmapFill( icon );
			sprite.graphics.drawRect( 0, 0, icon.width, icon.height );
			sprite.graphics.endFill();
			
			return sprite;
		}
		
		private function onLoaderCompleteEvent( event:Event ): void
		{
			// Replace throbber with icon
			_iconSprite = getIcon( Bitmap( _loader.content ).bitmapData );
			
			_iconSprite.x = - _iconSprite.width / 2;
			_iconSprite.y = - _iconSprite.height / 2;
			
			removeChild( _throbberSprite );
			addChild( _iconSprite );
			
			_throbberSprite = null;
			
			// Remove events
			removeLoaderEvents();
			
			// Add events
			_iconSprite.addEventListener( MouseEvent.MOUSE_OVER, onIconMouseOverEvent );
			_iconSprite.addEventListener( MouseEvent.MOUSE_OUT, onIconMouseOutEvent );
		}
		
		private function onLoaderErrorEvent( event:IOErrorEvent ): void
		{
			// Remove events
			removeLoaderEvents();
		}
		
		private function onLoaderSecurityError( event:SecurityErrorEvent ): void
		{
			// Remove events
			removeLoaderEvents();
		}
		
		public function get hasChildren(): Boolean
		{
			return children && children.length > 0;
		}

		public function getChildren():Vector.<RadialMenuItem>
		{
			return children;
		}

		public function get showTitle():Boolean
		{
			return _showTitle;
		}

		public function set showTitle(value:Boolean):void
		{
			_showTitle = value;
			
			if ( _titleSprite )
			{
				_titleSprite.visible = _showTitle;
			}
		}
	}
}