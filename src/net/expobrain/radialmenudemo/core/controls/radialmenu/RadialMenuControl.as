/**
 * $Id: RadialMenuControl.as 1044 2010-03-05 11:04:53Z expo $
 * $Author Daniele Esposti $
 * $Rev: 1044 $ $LastChangedDate: 2010-03-05 11:04:53 +0000 (Fri, 05 Mar 2010) $
 * $URL: svn+ssh://ubuntu/media/expo/iomega/svn/prodigyt/radialmenu/src/net/expobrain/radialmenudemo/core/controls/radialmenu/RadialMenuControl.as $
 * 
 */


package net.expobrain.radialmenudemo.core.controls.radialmenu
{
	import caurina.transitions.Tweener;
	
	import flash.display.Sprite;
	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	
	import net.expobrain.radialmenudemo.core.BaseSprite;
	import net.expobrain.radialmenudemo.core.ISprite;
	
	public class RadialMenuControl extends BaseSprite implements ISprite
	{
		[Embed(source="libs/courierBold.ttf", fontFamily="CourierBoldEmbedded", fontWeight="bold", embedAsCFF="false")]
		public static var fontCourierEmbedded:Class;
		
		public static const STATUS_TEXT_LOADING:String	= "LOADING...";
		public static const STATUS_TEXT_OK:String		= "OK";
		public static const STATUS_TEXT_ERROR:String	= "ERROR !!!";
		
		public static const MAX_MENU_LEVEL:uint		= 3;
		public static const ZOOM_MIN:Number			= 1;
		public static const ZOOM_MAX:Number			= 2;
		public static const ZOOM_DELAY:Number		= .75;
		public static const FADE_IN_DELAY:Number	= 1;
		public static const ROTATION_SPINOFF:Number	= .5;
		public static const MOVE_SPINOFF:Number		= 1;
		
		public static const DEFAULT_INTERNAL_RADIUS:uint	= 50;
		public static const	DEFAULT_RING_THICKNESS:uint		= 50;
		public static const DEFAULT_BACKGROUND_COLOR:uint	= 0xbbbbbb;
		
		private var _rotateInertia:Number;
		private var _moveInertia:Vector.<Vector3D>;
		private var _lastMousePosition:Point;
		private var _rotationOffset:Number;
		
		private var _centerSprite:Sprite;
		private var _clickTime:uint;
		private var _statusText:TextField;
		private var _configUrl:String;
		private var _config:XML; 
		private var _configLoader:URLLoader;
		private var _items:Vector.<RadialMenuItem>;
		private var _navigationPath:Vector.<RadialMenuItem> = new Vector.<RadialMenuItem>();
		private var _navigationArcs:Dictionary = new Dictionary;	// Dictionary of sprites for every item id
																	// Item id is the key and sprite the value
		
		public var internalRadius:uint = DEFAULT_INTERNAL_RADIUS;
		public var ringThickness:uint = DEFAULT_RING_THICKNESS;
		public var backgroundColor:uint = DEFAULT_BACKGROUND_COLOR;
		
		[Event(name="itemClick", type="net.expobrain.radialmenudemo.core.controls.radialmenu.RadialMenuEvent")]
		[Event(name="error", type="flash.events.ErrorEvent")]
		[Event(name="complete", type="flash.events.Event")]
		public function RadialMenuControl( configUrl:String )
		{
			_configUrl = configUrl;
			
			super();
		}
		
		override public function onInit():void
		{
			// Create font format
			var format:TextFormat = new TextFormat();
			
			format.font = "CourierBoldEmbedded";
			format.size = 12;
			format.align = TextFormatAlign.CENTER;
			
			// Create root ring
			var externalRadius:uint = internalRadius + ringThickness;
			var sprite:Sprite = new Sprite();
			
			sprite.graphics.beginFill( backgroundColor );
			sprite.graphics.drawCircle( externalRadius, externalRadius, internalRadius );
			sprite.graphics.drawCircle( externalRadius, externalRadius, externalRadius );
			sprite.graphics.endFill();
			
			sprite.x = -externalRadius;
			sprite.y = -externalRadius;
			
			addChild( sprite );
			
			_navigationArcs[0] = sprite;
			
			// Create control's center
			_centerSprite = new Sprite();
			
			_centerSprite.graphics.beginFill( backgroundColor );
			_centerSprite.graphics.drawCircle( externalRadius, externalRadius, internalRadius * .9 );
			_centerSprite.graphics.endFill();
			
			_centerSprite.x = -externalRadius;
			_centerSprite.y = -externalRadius;
			_centerSprite.doubleClickEnabled = true;
			
			addChild( _centerSprite );
			
			// Create status text field
			_statusText = new TextField();
			
			_statusText.embedFonts = true;
			_statusText.selectable = false;
			_statusText.autoSize = TextFieldAutoSize.CENTER;
			_statusText.mouseEnabled = false;
			_statusText.defaultTextFormat = format;
			_statusText.text = STATUS_TEXT_LOADING;
			
			_statusText.x =  - _statusText.width / 2;
			_statusText.y =  - _statusText.height / 2;
			
			addChild( _statusText );
			
			// Load config XML in background
			_configLoader = new URLLoader();
			
			_configLoader.addEventListener( Event.COMPLETE, onLoaderCompleteEvent );
			_configLoader.addEventListener( IOErrorEvent.IO_ERROR, onLoaderErrorEvent );
			_configLoader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onLoaderSecurityError );
			
			_configLoader.load( new URLRequest( _configUrl ) );
		}
		
		private function onLoaderCompleteEvent( event:Event ): void
		{
			// Save config XML
			_config = XML( _configLoader.data );
			
			// Remove events and loader
			removeLoaderEvents();

			_configLoader = null;
				
			// Change status text
			_statusText.text = STATUS_TEXT_OK;
			
			// Load menu items
			_items = getMenuItems( _config.menuitems, null, 0 );
			
			// Place root items distant equally on the root ring
			var radius:Number = internalRadius + ringThickness / 2;
			var origin:Number = internalRadius + ringThickness;
			
			for ( var i:uint = 0; i < _items.length; ++i ) 
			{
				// Set position
				var item:RadialMenuItem = _items[i];
				var angle:Number = ( ( 2 * Math.PI ) / _items.length * i + Math.PI / 2 );
				
				item.x = origin + radius * Math.cos( angle );
				item.y = origin + radius * Math.sin( angle );
				item.rotation = angle * 180 / Math.PI;
				
				_navigationArcs[0].addChild( item );
				
				// Add events
				item.addEventListener( MouseEvent.CLICK, onMenuItemClick );
			}
			
			// Dispatch event
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		/**
		 * Close item submenu and all children
		 * 
		 * @throws ErrorEvent
		 */
		private function closeItemSubmenu( item:RadialMenuItem = null ): void
		{
			// Find start index
			var index:int;
			
			if ( item == null )
			{
				index = 0;
			}
			else
			{
				index = _navigationPath.indexOf( item );
			
				if ( index == -1 )
				{
					throw new ErrorEvent( ErrorEvent.ERROR, false, false, "Item id " + item.id + " not in list" );
				}
			}
			
			// Remove submenu
			for ( var i:int = _navigationPath.length; i > index; --i )
			{
				var submenu:RadialMenuSubmenu = _navigationArcs[ i ];
				
				// Remove items events
				if ( submenu.hasChildren )
				{
					for each ( var child:RadialMenuItem in submenu.children )
					{
						child.removeEventListener( MouseEvent.CLICK, onMenuItemClick );
					}
				}
				
				// Remove submenu event
				submenu.removeEventListener( MouseEvent.MOUSE_DOWN, onMenuMouseDown );
				
				// Remove submenu
				removeChild( submenu );
				
				delete _navigationArcs[ i ];
				
				// Show item  and siblings titles
				if ( item )
				{
					item.showTitle = true;
				}
			}
			
			// Remove items id from navigation path
			_navigationPath.splice( index, _navigationPath.length - index ); 
		}
		
		/**
		 * Show item submenu
		 */
		private function showItemSubmenu( item:RadialMenuItem): void
		{
			// Add item to navigation path
			_navigationPath.push( item );

			// Get global coordinates
			var origin:Point = new Point();
			var itemCenter:Point = new Point( item.x , item.y );
			
			origin = _navigationArcs[0].parent.localToGlobal( origin );
			itemCenter = item.parent.localToGlobal( itemCenter );
			
			// Calculate item angle
			// You must take care of widget rotation
			var itemAngle:Number;
			
			itemAngle = Math.atan2( itemCenter.y - origin.y, itemCenter.x - origin.x );
			itemAngle -= rotation * Math.PI / 180;
			
			// Hide item text
			item.showTitle = false;
			
			// Add submenu arc
			var submenu:RadialMenuSubmenu = new RadialMenuSubmenu();
			
			submenu.radius		= internalRadius + ringThickness * _navigationPath.length;
			submenu.itemAngle	= itemAngle;
			submenu.children	= item.children;
			
			// Add the submenu before the last menu so the tooltip will be always on top
			addChild( submenu );
			_navigationArcs[ _navigationPath.length ] = submenu;
			
			// Add events
			submenu.addEventListener( MouseEvent.MOUSE_DOWN, onMenuMouseDown );
			
			for each ( var child:RadialMenuItem in submenu.children )
			{
				child.addEventListener( MouseEvent.CLICK, onMenuItemClick );
			}
		}
		
		/**
		 * Check if the item is already opened
		 * To do this I check if the last node in navigation path is the item id
		 * 
		 * @throws ErrorEvent
		 */
		private function itemIsOpened( item:RadialMenuItem ): Boolean 
		{
			// You cannot call this method if the item has no children
			// or item is null
			if ( item == null )
			{
				throw new ErrorEvent( ErrorEvent.ERROR, false, false, "Item is null" );
			}
			
			if ( !item.hasChildren )
			{
				throw new ErrorEvent( ErrorEvent.ERROR, false, false, "Item id " + item.id + " dosn't have children" );
			}
			
			// End
			return _navigationPath.length > 0 && _navigationPath.indexOf( item ) > -1;
		}
		
		/**
		 * Returns the id of the last opened item
		 * or null if no items are opened
		 */
		private function lastOpenedItem(): RadialMenuItem
		{
			if ( _navigationPath.length == 0 )
			{
				return null;
			}
			else
			{
				return _navigationPath[ _navigationPath.length - 1 ];
			}
		}
		
		/**
		 * Closes all opend items
		 */
		private function closeAllSubmenus(): void
		{
			closeItemSubmenu( null );
		}
		
		private function onMenuItemClick( event:MouseEvent ): void
		{
			// Stop tweens
			Tweener.removeTweens( this );
			
			var item:RadialMenuItem = RadialMenuItem( event.currentTarget );

			// If item has children manage its submenu
			if ( item.hasChildren )
			{
				if ( itemIsOpened( item ) ) 
				{
					closeItemSubmenu( item );
				}
				else
				{
					if ( item.parentItem && itemIsOpened( item.parentItem ) && lastOpenedItem() != item.parentItem )
					{
						closeItemSubmenu( lastOpenedItem() );
					}
					else if ( item.parentItem == null || !itemIsOpened( item.parentItem ) )
					{
						closeAllSubmenus();
					}
					
					// Show items
					showItemSubmenu( item );
				}
			}
			else
			{
				dispatchEvent( new RadialMenuEvent( RadialMenuEvent.ITEM_CLICK, item.id ) );
			}
		}
		
		private function onLoaderErrorEvent( event:IOErrorEvent ): void
		{
			// Remove events
			removeLoaderEvents();
			
			// Remove loader
			_configLoader.close();
			_configLoader = null
			
			// Change status text
			_statusText.text = STATUS_TEXT_ERROR;
			
			// Dispatch event
			dispatchEvent( event.clone() );
		}
		
		private function onLoaderSecurityError( event:SecurityErrorEvent ): void
		{
			// Remove events
			removeLoaderEvents();
			
			// Remove loader
			_configLoader.close();
			_configLoader = null
			
			// Change status text
			_statusText.text = STATUS_TEXT_ERROR;
			
			// Dispatch event
			dispatchEvent( event.clone() );
		}
		
		/**
		 * Load a level of menu items and call itself recursively 
		 * if a node has children
		 * Stops if menu level is greater than MAX_MENU_LEVEL 
		 */ 
		private function getMenuItems( configXml:XMLList, parentItem:RadialMenuItem, level:uint ): Vector.<RadialMenuItem>
		{
			var items:Vector.<RadialMenuItem> = new Vector.<RadialMenuItem>();
			
			if ( level < MAX_MENU_LEVEL ) 
			{
				for each ( var menuitemNode:XML in configXml.menuitem ) 
				{
					var item:RadialMenuItem = new RadialMenuItem();
				
					item.parentItem		= parentItem;
					item.id				= menuitemNode.@id;
					item.iconUrl		= menuitemNode.icon.text();
					item.title			= menuitemNode.title.text();
					item.tooltip		= menuitemNode.tooltip.text();
					item.children		= getMenuItems( menuitemNode.menuitems, item, level + 1 );
					
					items.push( item );
				}
			}
			
			// End
			return items;
		}
		
		override public function dispose(): void
		{
			super.dispose();
			
			// Remove loader if not null
			if ( _configLoader != null ) {
				// Remove events
				removeLoaderEvents();
				
				// Close connection
				// Catch IOError if connection it's not started
				// or throw error if another type of exception
				try {
					_configLoader.close();
				}
				catch ( error:IOError ) {}
				catch ( error:* ) {
					throw error;
				}
				
				// Remove Loader instance
				_configLoader = null;
			}
			
			// Dispose all items
			for each ( var item:RadialMenuItem in _items )
			{
				item.dispose();
			}
		}
		
		private function removeLoaderEvents(): void
		{
			// Remove events
			_configLoader.removeEventListener( Event.COMPLETE, onLoaderCompleteEvent );
			_configLoader.removeEventListener( IOErrorEvent.IO_ERROR, onLoaderErrorEvent );
			_configLoader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, onLoaderSecurityError );
		}
		
		override public function onAddedToStage(event:Event):void
		{
			// Set properties
			alpha = 0;
			
			// Add events
			_centerSprite.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			_centerSprite.addEventListener( MouseEvent.MOUSE_UP, onMouseUp);
			_centerSprite.addEventListener( MouseEvent.DOUBLE_CLICK, onMouseDClick );
			
			_navigationArcs[0].addEventListener( MouseEvent.MOUSE_DOWN, onMenuMouseDown );
			
			// Add tweens
			Tweener.addTween( this, { alpha:1, time:FADE_IN_DELAY } );
		}
		
		/**
		 * Starts follow the mouse and rotate the control accordly to mouse position
		 */
		private function onMenuMouseDown( event:MouseEvent ): void
		{
			// Start follow the mouse position
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onMenuMouseMove );
			stage.addEventListener( MouseEvent.MOUSE_UP, onMenuMouseUp );
			
			// Calculate rotation start
			var origin:Point = localToGlobal( new Point() );
			var angle:Number;

			angle = Math.atan2( event.stageY - origin.y, event.stageX - origin.x );
			angle = angle * 180 / Math.PI;
			
			_rotationOffset = angle - rotation;
		}
		
		/**
		 * Stop rotation behavior
		 */
		private function onMenuMouseUp( event:MouseEvent ): void
		{
			// I use the event.currentTarget becuse here I'm not sure the widget
			// is on the stage anymore
			// Using the currentTraget I'm sure the event listener will ber removed
			// even if the control is removed from the stage
			event.currentTarget.removeEventListener( MouseEvent.MOUSE_UP, onMenuMouseUp );
			event.currentTarget.removeEventListener( MouseEvent.MOUSE_MOVE, onMenuMouseMove );
			
			// Simulate inertia
			var finalRotation:Number = rotation + _rotateInertia / ROTATION_SPINOFF;
			
			Tweener.addTween( this, { rotation:finalRotation, time:ROTATION_SPINOFF, transition:"easeOutCirc" } );
		}
		
		private function onMenuMouseMove( event:MouseEvent ): void
		{
			// Calculate rotation delta
			var origin:Point = localToGlobal( new Point() );
			var angle:Number;
			var lastRotation:Number = rotation;
			
			angle = Math.atan2( event.stageY - origin.y, event.stageX - origin.x );
			angle = angle * 180 / Math.PI;
			
			// Apply rotation
			rotation = angle - _rotationOffset;
			
			// Calculate inertia
			_rotateInertia = Math.abs( angle - _rotationOffset - lastRotation );
			
			if ( rotation < lastRotation )
			{
				_rotateInertia = -1 * _rotateInertia;
			}
		}

		/**
		 * This events executes zoom in/out effect and
		 * mantains the center fo the widget
		 */
		private function onMouseDClick( event:MouseEvent ): void
		{
			// Apply zoom in/out
			if ( scaleX == ZOOM_MAX )
			{
				Tweener.addTween( this, { scaleX:ZOOM_MIN, scaleY:ZOOM_MIN, time:ZOOM_DELAY, transition:"easeOutElastic" } );
			}
			else
			{
				Tweener.addTween( this, { scaleX:ZOOM_MAX, scaleY:ZOOM_MAX, time:ZOOM_DELAY, transition:"easeOutElastic" } );
			}
		}
		
		private function onMouseDown( event:MouseEvent ): void
		{
			// Enable cache and start drag
			cacheAsBitmap = true;
			
			startDrag();
			
			// Reset move vector and save current mouse position
			_moveInertia = new Vector.<Vector3D>();
			_lastMousePosition = new Point( event.stageX, event.stageY );
			
			// Add events
			addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
		}
		
		private function onMouseUp( event:MouseEvent ): void
		{
			// Disable cache and stop drag
			cacheAsBitmap = false;
			
			stopDrag();
			
			// Remove events
			removeEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			
			// Calculate mouse vector by average
			var mouseVector:Vector3D = new Vector3D();
			
			if ( _moveInertia.length > 10 )
			{
				_moveInertia = _moveInertia.splice( _moveInertia.length - 10, _moveInertia.length );
			}
			
			for ( var i:uint = 0; i < _moveInertia.length; ++i )
			{
				mouseVector.x += _moveInertia[i].x;
				mouseVector.y += _moveInertia[i].y;
			}
			
			mouseVector.x = mouseVector.x;
			mouseVector.y = mouseVector.y;
			
			// Simulate move inertia
			var finalPosition:Point = new Point();
			
			finalPosition.x = x + mouseVector.x / MOVE_SPINOFF;
			finalPosition.y = y + mouseVector.y / MOVE_SPINOFF;
			
			// Add tweens
			Tweener.addTween( this, { x:finalPosition.x, y:finalPosition.y, time:MOVE_SPINOFF, transition:"easeOutSine" } );
		}
		
		private function onMouseMove( event:MouseEvent ): void
		{
			// Stop tweens
			Tweener.removeTweens( this, "x", "y" );
			
			// Calculate vector
			var mouseVector:Vector3D = new Vector3D();
			
			mouseVector.x = event.stageX - _lastMousePosition.x;
			mouseVector.y = event.stageY - _lastMousePosition.y;
			
			_moveInertia.push( mouseVector );
				
			// Save last mouse position
			_lastMousePosition = new Point( event.stageX, event.stageY );
		}
		
		override public function onRemovedFromStage(event:Event):void
		{
			// Remove events
			_centerSprite.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			_centerSprite.removeEventListener( MouseEvent.MOUSE_UP, onMouseUp);
			_centerSprite.removeEventListener( MouseEvent.DOUBLE_CLICK, onMouseDClick );
			
			_navigationArcs[0].removeEventListener( MouseEvent.MOUSE_DOWN, onMenuMouseDown );
				
			// Remove tweens
			Tweener.removeTweens( this );
		}
	}
}