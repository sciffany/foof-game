﻿package {
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.display.Bitmap;
	import flash.display.BitmapData;

	//class declaration
	public class TBG03 extends Object {
		//declare variables
		private var mapArr:Array;
		private var curMap:Array;
		private var complexTiles:Array;
		private var mapW:int;
		private var mapH:int;
		private var ts:int;
		private var myParent:Sprite;
		private var tilesBmp:Bitmap;
		private var tSheet:BitmapData;
		private var hero:Hero;
		
		//class constructor function
		public function TBG03 (s:Sprite) {
			myParent = s;
			prepareGame ();
		}
		//start the game by preparing stuff
		private function prepareGame ():void {
			ts = 32;
			//we set new map data and call buildMap function
			mapArr = [
			[  0,  0,  0,  0,  0,  0,  0,  0],
			[  0,101,101,101,101,101,101,  0],
			[  0,101,  0,101,101,101,101,  0],
			[  0,101,101,101,101,  0,101,  0],
			[  0,101,101,101,101,101,102,  0],
			[  0,  0,  0,  0,  0,  0,  0,  0]
			];
			complexTiles = new Array();
			complexTiles[102] = createComplexTile(1, [2]);
			//get the tilesheet
			tSheet = new TileSheet(0,0);
			//set up current map array
			curMap = mapArr;
			//add new hero instance
			hero = new Hero(0, 24, 2, 1);
			//create map
			buildMap ();
		}
		//build new map
		private function buildMap ():void {
			//get map dimensions
			mapW = curMap[0].length;
			mapH = curMap.length;
			//main bitmap to be shown on screen
			tilesBmp = new Bitmap(new BitmapData(ts * mapW, ts * mapH));
			//add this clip to stage
			myParent.addChild (tilesBmp);
			//loop to place tiles on stage
			for (var yt:int = 0; yt < mapH; yt++) {
				for (var xt:int = 0; xt < mapW; xt++) {
					var s:int = curMap[yt][xt];
					//check for complex tile type
					var cT:Object = complexTiles[s];
					if (cT != null) {
						//draw one image
						drawTile (cT.baseSpr, xt, yt);
						//second image to be drawn later
						s = cT.anim[0];
					}else if (s >= 100) {
						s = s - 100;
					}
					//put image on screen
					drawTile (s, xt, yt);
				}
			}
			
			//add graphics to hero
			hero.bmp = getImageFromSheet (hero.sprNum, hero);
			//find the coordinates
			hero.x = hero.xtile * ts;
			hero.y = hero.ytile * ts;
			hero.bmp.x = hero.x;
			hero.bmp.y = hero.y;
			//add hero to the screen
			myParent.addChild (hero.bmp);
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