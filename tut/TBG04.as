package {
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	import flash.ui.Keyboard;

	//class declaration
	public class TBG04 extends Object {
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
		private var keys:Object;

		//class constructor function
		public function TBG04 (s:Sprite) {
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
			//set up keys object
			keys = new Array();
			//fill the object with arrow keys
			keys[Keyboard.UP] = {down:false, dirx:0, diry:-1};
			keys[Keyboard.DOWN] = {down:false, dirx:0, diry:1};
			keys[Keyboard.LEFT] = {down:false, dirx:-1, diry:0};
			keys[Keyboard.RIGHT] = {down:false, dirx:1, diry:0};
			//create map
			buildMap ();
			//add key listeners to tilesclip
			myParent.addEventListener (KeyboardEvent.KEY_DOWN, downKeys);
			myParent.addEventListener (KeyboardEvent.KEY_UP, upKeys);
			myParent.addEventListener (Event.ENTER_FRAME, runGame);
			//hide ugly yellow rectangle around objects
			myParent.stage.stageFocusRect = false;
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
			moveObject (hero);
			//add hero to the screen
			myParent.addChild (hero.bmp);
		}
		//this is main game function that is run at enterframe event
		private function runGame (ev:Event):void {
			if(hero.moveOb != null && hero.moveOb.down == true){
				if (checkDir (hero, hero.moveOb) == true) {
					//move the hero
					moveObject (hero, hero.moveOb);
				}
			}else{
				//find if any movement key is down
				for each (var keyOb:Object in keys) {
					//yep, arrow key is down
					if (keyOb.down == true) {
						//check if tile is walkable
						if (checkDir (hero, keyOb) == true) {
							//move the hero
							moveObject (hero, keyOb);
							//we have moved, dont look for other keys 
							break;
						}
					}
				}
			}
			//get the focus to the main clip to keys are detected
			if (myParent.stage.focus != myParent) {
				myParent.stage.focus = myParent;
			}
		}
		//check if can move in direction of moveOb
		private function checkDir (ob:Object, moveOb:Object):Boolean {
			return isWalkable (ob.xtile + moveOb.dirx, ob.ytile + moveOb.diry);
		}
		//this function will finds if tile is walkable
		private function isWalkable (xt:int, yt:int):Boolean {
			if(curMap[yt][xt] >= 100){
				return true;
			}else{
				return false;
			}
		}
		//this function will detect keys that are being pressed
		private function downKeys (ev:KeyboardEvent):void {
			//check if the is arrow key
			if (keys[ev.keyCode] != null) {
				//set the key to true
				keys[ev.keyCode].down = true;
			}
		}
		//this function will detect keys that are being released
		private function upKeys (ev:KeyboardEvent):void {
			//check if the is arrow key
			if (keys[ev.keyCode] != null) {
				//set the key to false
				keys[ev.keyCode].down = false;
			}
		}
		//this function will move object
		private function moveObject (ob:*, moveOb:* = null):void {
			if(moveOb != null){
				//change tile
				ob.xtile += moveOb.dirx;
				ob.ytile += moveOb.diry;
			}
			//find new coordinates
			ob.x = ob.xtile * ts;
			ob.y = ob.ytile * ts;
			//place the graphics
			ob.bmp.x = ob.x;
			ob.bmp.y = ob.y;
			ob.moveOb = moveOb;
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