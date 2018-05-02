package {
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;

	//class declaration
	public class TBG07 extends Object {
		//declare variables
		private var mapArr:Array;
		private var curMap:Array;
		private var complexTiles:Array;
		private var animatedObjects:Array;
		private var mapW:int;
		private var mapH:int;
		private var ts:int;
		private var myParent:Sprite;
		private var tilesBmp:Bitmap;
		private var tSheet:BitmapData;
		
		//class constructor function
		public function TBG07 (s:Sprite) {
			myParent = s;
			prepareGame ();
		}
		//start the game by preparing stuff
		private function prepareGame () {
			ts = 32;
			//we set new map data and call buildMap function
			mapArr = [
			[  0,  0,  0,  0,  0,  0,  0,  0],
			[  0,101,101,101,101,101,101,  0],
			[  0,101,  0,101,101,101,101,  0],
			[  0,101,101,101,101,  0,101,  0],
			[  0,106,102,103,104,105,101,  0],
			[  0,  0,  0,  0,  0,  0,  0,  0]
			];
			complexTiles = new Array();
			complexTiles[102] = createComplexTile(1, [3,10,4,10,5,10]);
			complexTiles[103] = createComplexTile(1, [3,5,4,5,5,5]);
			complexTiles[104] = createComplexTile(1, [5,10,4,10,3,10,2,100]);
			complexTiles[105] = createComplexTile(1, [3,10,4,5,3,10,4,5,5,10,4,5,5,10,4,5]);
			complexTiles[106] = createComplexTile(1, [5]);
			//set up array for all animated things
			animatedObjects = new Array();
			//get the tilesheet
			tSheet = new TileSheet(0,0);
			//set up current map array
			curMap = mapArr;
			//create map
			buildMap ();
			
			myParent.addEventListener (Event.ENTER_FRAME, runGame);
		}
		//build new map
		private function buildMap () {
			//get map dimensions
			mapW = curMap[0].length;
			mapH = curMap.length;
			//main bitmap to be shown on screen
			tilesBmp = new Bitmap(new BitmapData(ts * mapW, ts * mapH));
			//add this clip to stage
			myParent.addChild (tilesBmp);
			
			for (var yt:int = 0; yt < mapH; yt++) {
				for (var xt:int = 0; xt < mapW; xt++) {
					var s:int = curMap[yt][xt];
					//check for complex tile type
					var cT:Object = complexTiles[s];
					if (cT != null) {
						//draw one image
						drawTile (cT.baseSpr, xt, yt);
						//check for animated image
						if(cT.anim.length > 1){
							var ob:Object = new Object();
							ob.anim = cT.anim;
							ob.baseSpr = cT.baseSpr;
							//reset animation counters
							ob.animCount = 0;
							ob.animTime = 0;
							ob.xt = xt;
							ob.yt = yt;
							//add to animated objects array
							animatedObjects.push(ob);
						}else{
							//second image to be drawn later
							s = cT.anim[0];
						}
						//second image to be drawn later
						s = cT.anim[0];
					}else if (s >= 100) {
						s = s - 100;
					}
					//put image on screen
					drawTile (s, xt, yt);
				}
			}
		}
		//this is main game function that is run at enterframe event
		private function runGame (ev:Event):void {
			//animate the objects
			animateSprite ();
		}
		//this function will animate all the objects
		private function animateSprite ():void {
			tilesBmp.bitmapData.lock();
			//run through all objects needing the animation
			for (var n:int = 0; n < animatedObjects.length; n++) {
				var ob:Object = animatedObjects[n];
				//add 1 to time counter
				ob.animTime++;
				//check if the time has counted up
				if(ob.animTime == ob.anim[ob.animCount + 1]){
					//add to current image counter
					ob.animCount += 2;
					//check if end of animation is reached
					if(ob.animCount == ob.anim.length){
						//reset to start
						ob.animCount = 0;
					}
					//check if its tile or separate object like hero
					if(ob.bmp == null){
						//clear the current tile image
						var rect:Rectangle = new Rectangle(ob.xt * ts, ob.yt * ts, ts, ts);
						tilesBmp.bitmapData.fillRect (rect, 0x00000000);
						//change the image if time is right
						ob.s = ob.anim[ob.animCount];
						drawTile (ob.baseSpr, ob.xt, ob.yt);
						drawTile (ob.s, ob.xt, ob.yt);
					}else{
						//its hero
						ob.bmp.bitmapData = getImageFromSheet (ob.sprNum, ob).bitmapData;
					}
					//reset animation timer
					ob.animTime = 0;
				}
			}
			tilesBmp.bitmapData.unlock();
		}
		private function getImageFromSheet (s:Number, ob:* = null):Bitmap {
			var tsize:int = ts;
			var sheet:BitmapData = tSheet;
			if(ob != null){
				tsize = ob.ts;
				sheet = ob.sheet;
			}
			//number of columns in tilesheet
			var sheetColumns:int = tSheet.width / tsize;
			//position where to take graphics from
			var col:int = s % sheetColumns;
			var row:int = Math.floor(s / sheetColumns);
			//rectangle that defines tile graphics
			var rect:Rectangle = new Rectangle(col * tsize, row * tsize, tsize, tsize);
			var pt:Point = new Point(0, 0);
			//get the tile graphics from tilesheet
			var bmp:Bitmap =  new Bitmap(new BitmapData(tsize, tsize, true, 0));
			bmp.bitmapData.copyPixels (sheet, rect, pt, null, null, true);
			return bmp;
		}
		private function drawTile (s:Number, xt:int, yt:int):void {
			var bmp:Bitmap = getImageFromSheet (s);
			//rectangle has size of tile and it starts from 0,0
			var rect:Rectangle = new Rectangle(0, 0, ts, ts);
			//point on screen where the tile goes
			var pt:Point = new Point(xt * ts, yt * ts);
			//copy tile bitmap to main bitmap
			tilesBmp.bitmapData.copyPixels (bmp.bitmapData, rect, pt, null, null, true);
		}
		private function createComplexTile (spr1:int, animArr:Array, st:String = ""):Object {
			//create new object
			var ob:Object = new Object();
			//base graphics, will always remain same
			ob.baseSpr = spr1;
			//array of animation graphics
			ob.anim = animArr;
			//tile could be some special type
			ob.specialType = st;
			return ob;
		}
	}
}