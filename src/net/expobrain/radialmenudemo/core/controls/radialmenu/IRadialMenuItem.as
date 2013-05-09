package net.expobrain.radialmenudemo.core.controls.radialmenu
{
	import net.expobrain.radialmenudemo.core.ISprite;
	
	public interface IRadialMenuItem extends ISprite
	{
		/**
		 * Tell if a menu item has children
		 */
		function get hasChildren(): Boolean;
		
		/**
		 * Returns children vector
		 */
		function getChildren(): Vector.<RadialMenuItem>;
		
		/**
		 * Show title property
		 */
		function get showTitle(): Boolean;
		function set showTitle( value:Boolean ): void;
	}
}