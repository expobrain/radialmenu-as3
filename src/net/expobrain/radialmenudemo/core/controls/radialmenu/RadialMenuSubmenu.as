package net.expobrain.radialmenudemo.core.controls.radialmenu
{
	import caurina.transitions.Tweener;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	import net.expobrain.radialmenudemo.core.BaseSprite;
	import net.expobrain.radialmenudemo.core.ISprite;
	
	public class RadialMenuSubmenu extends BaseSprite implements ISprite, IRadialMenuSubmenu
	{
		public static const FADE_IN_DELAY:Number = 1;
		
		public var ringThickness:Number = RadialMenuControl.DEFAULT_RING_THICKNESS;
		public var backgroundColor:Number = RadialMenuControl.DEFAULT_BACKGROUND_COLOR;
		
		public var itemAngle:Number;
		public var radius:Number;
		public var children:Vector.<RadialMenuItem> = new Vector.<RadialMenuItem>();
		
		public function RadialMenuSubmenu()
		{
		}
		
		override public function onRemovedFromStage(event:Event): void
		{
			// Remove tweens
			Tweener.removeTweens( this );
		}
		
		/**
		 * Draws a circonference arc between two angles
		 */
		public function drawArcHelper( sprite:Sprite, origin:Point, angleFrom:Number, angleTo:Number, radius:Number, clockwise:Boolean = true ): void
		{
			var steps:uint = Math.abs( ( angleFrom - angleTo ) * 180 / Math.PI );
			
			// Move to start point
			sprite.graphics.lineTo(
				origin.x + radius * Math.cos( angleFrom ), 
				origin.y + radius * Math.sin( angleFrom ) 
			);
			
			// Draw steps for every degree
			var angle:Number;
			
			for ( var i:uint = 0; i < steps; ++i )
			{
				if ( clockwise )
				{
					angle = angleFrom + (i + 1) * Math.PI / 180;
				}
				else
				{
					angle = angleFrom - (i + 1) * Math.PI / 180;
				}
				
				sprite.graphics.lineTo(
					origin.x + radius * Math.cos( angle ),
					origin.y + radius * Math.sin( angle )
				);
			}
			
			// Draw last step
			sprite.graphics.lineTo( 
				origin.x + radius * Math.cos( angleTo ), 
				origin.y + radius * Math.sin( angleTo ) 
			);
		}
		
		override public function onAddedToStage(event:Event):void
		{
			// Set properties
			alpha = 0;
			
			// Draw submenu background
			var origin:Point = new Point();
			var arcAngle:Number = (ringThickness * children.length) / radius;
			var angleFrom:Number = itemAngle - arcAngle / 2;
			var angleTo:Number = angleFrom + arcAngle;
			
			var sprite:Sprite = new Sprite();
			
			sprite.graphics.beginFill( backgroundColor );
			sprite.graphics.moveTo( 
				origin.x + radius * Math.cos( angleFrom ), 
				origin.y + radius * Math.sin( angleFrom ) 
			);
			drawArcHelper( sprite, origin, angleFrom, angleTo, radius );
			sprite.graphics.lineTo( 
				origin.x + (radius + ringThickness) * Math.cos( angleTo ), 
				origin.y + (radius + ringThickness) * Math.sin( angleTo ) 
			);
			drawArcHelper( sprite, origin, angleTo, angleFrom, radius + ringThickness, false );
			sprite.graphics.lineTo( 
				origin.x + radius * Math.cos( angleFrom ), 
				origin.y + radius * Math.sin( angleFrom ) 
			);
			sprite.graphics.endFill();
			
			addChild( sprite );
			
			// Add children
			var childRadius:Number = radius + ringThickness / 2;
			
			for ( var i:uint = 0; i < children.length; ++i )
			{
				// Create child
				var child:RadialMenuItem = children[i];
				var angle:Number;
				
				angle = angleFrom + arcAngle / children.length / 2
				angle += arcAngle / children.length * i;
				
				child.x = origin.x + childRadius * Math.cos( angle );
				child.y = origin.y + childRadius * Math.sin( angle );
				child.rotation = angle * 180 / Math.PI;
				
				addChild( child );
			}
			
			// Add tweens
			Tweener.addTween( this, { alpha:1, time:FADE_IN_DELAY } );
		}
		
		public function get hasChildren(): Boolean
		{
			return children && children.length > 0;
		}
		
		public function getChildren():Vector.<RadialMenuItem>
		{
			return children;
		}
		
		public function get centerX(): Number
		{
			return x + width / 2;
		}
		
		public function get centerY(): Number
		{
			return y + height / 2;
		}
	}
}