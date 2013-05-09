/**
 * $Id: RadialMenuTooltip.as 1039 2010-03-04 23:55:12Z expo $
 * $Author Daniele Esposti $
 * $Rev: 1039 $ $LastChangedDate: 2010-03-04 23:55:12 +0000 (Thu, 04 Mar 2010) $
 * $URL: svn+ssh://ubuntu/media/expo/iomega/svn/prodigyt/radialmenu/src/net/expobrain/radialmenudemo/core/controls/radialmenu/RadialMenuTooltip.as $
 * 
 */


package net.expobrain.radialmenudemo.core.controls.radialmenu
{
	import caurina.transitions.Tweener;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import net.expobrain.radialmenudemo.core.BaseSprite;
	import net.expobrain.radialmenudemo.core.ISprite;
	
	public class RadialMenuTooltip extends BaseSprite implements ISprite
	{
		[Embed(source="libs/courierBold.ttf", fontFamily="CourierBoldEmbedded", fontWeight="bold", embedAsCFF="false")]
		public static var fontCourierBoldEmbedded:Class;
		
		public static const TOOLTIP_WIDTH:uint		= 150;
		public static const TOOLTIP_ALPHA:Number	=.3;
		public static const FADE_IN_DELAY:Number	= .25;
		
		private var _text:String;
		
		public function RadialMenuTooltip( text:String )
		{
			_text = text;
			
			super();
		}
		
		override public function onInit():void
		{
			// Create font format
			var format:TextFormat = new TextFormat();
			
			format.font = "CourierBoldEmbedded";
			format.size = 12;
			format.color = 0xffffff;
			format.align = TextFormatAlign.LEFT;
			
			// Create text field
			var _textfield:TextField = new TextField();
			
			_textfield.embedFonts = true;
			_textfield.selectable = false;
			_textfield.multiline = true;
			_textfield.wordWrap = true;
			_textfield.autoSize = TextFieldAutoSize.LEFT;
			_textfield.width = TOOLTIP_WIDTH;
			_textfield.text = _text;

			_textfield.setTextFormat( format );
			
			addChild( _textfield );
			
			// Draw background
			var sprite:Sprite = new Sprite();
			
			sprite.graphics.beginFill( 0x000000 );
			sprite.graphics.drawRect( 0, 0, _textfield.width, _textfield.height );
			sprite.graphics.moveTo( 0, _textfield.height );
			sprite.graphics.lineTo( 0, _textfield.height + 8 );
			sprite.graphics.lineTo( 8, _textfield.height );
			sprite.graphics.endFill();
			
			sprite.alpha = TOOLTIP_ALPHA;
			
			addChildAt( sprite, getChildIndex( _textfield ) );
		}
		
		override public function onAddedToStage(event:Event):void
		{
			// Set properties
			mouseEnabled = false;
			alpha = 0;
			
			// Add tweener
			Tweener.addTween( this, { alpha:1, time:FADE_IN_DELAY, transition:"linear" } );
		}
		
		override public function onRemovedFromStage(event:Event):void
		{
			Tweener.removeTweens( this );
		}
	}
}