package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	//class declaration
	public class Hero {
		public var sprNum:Number;
		public var sheet:BitmapData;
		public var ts:int;
		public var xtile:int;
		public var ytile:int;
		public var bmp:Bitmap;
		public var x:Number;
		public var y:Number;
		public var dist:Number;
		public var speed:Number;
		public var moveOb:Object;
		public var anim:Array;
		public var animCount:int;
		public var animTime:int;
		public var mymap:int;
		public var mapy:int;
		public var mapx:int;
		public var jumpSpeed:Number;
		public var jumpStart:Number;
		public var gravity:Number;
		public var onLadder:Boolean;
		public var xtc:int;
		public var ytc:int;
		
		//class constructor function
		public function Hero (spr:Number, tileSize:int, xt:int, yt:int) {
			sprNum = spr;
			//pointer to tilesheet
			sheet = new HeroSheet(0,0);
			ts = tileSize;
			xtile = xt;
			ytile = yt;
			dist = 0;
			//set default animation for hero
			anim = new Array();
			animCount = 0;
			animTime = 0;
			jumpSpeed = Infinity;
			onLadder = false;
		}
	}
}