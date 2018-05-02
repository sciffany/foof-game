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
	public class TBG08a extends Object {
		//declare variables
		private var maps:Object;
		private var curMap:Array;
		private var mapW:int;
		private var mapH:int;
		private var ts:int;
		private var myParent:Sprite;
		private var tilesBmp:Bitmap;
		private var tSheet:BitmapData;
		private var hero:Hero;
		private var keys:Object;

		//class constructor function
		public function TBG08a (s:Sprite) {
			myParent = s;
			prepareGame ();
		}
		//start the game by preparing stuff
		private function prepareGame ():void {
			ts = 32;
			//new map
			maps = new Object();
			maps.mapArr0_0=[
			[0,0,0,0,0,0,0,0],
			[0,101,101,101,101,101,101,0],
			[0,101,0,101,101,101,101,101],
			[0,101,101,101,101,0,101,0],
			[0,101,101,101,101,101,101,101],
			[0,101,101,0,0,0,0,0]
			];
			//nextmap
			maps.mapArr1_0=[
			[0,0,0,0,0,0,0,0],
			[0,101,101,101,101,101,101,0],
			[101,101,0,101,101,0,101,0],
			[0,101,101,101,0,101,0,0],
			[101,101,101,101,101,101,101,0],
			[0,0,101,0,101,0,101,0]
			];
			maps.mapArr0_1=[
			[0,101,101,0,0,0,0,0],
			[0,101,101,101,101,101,101,101],
			[0,101,101,101,101,101,101,101],
			[0,101,101,0,101,101,101,101],
			[0,101,101,101,101,101,101,101],
			[0,0,0,0,0,0,0,0]
			];
			//nextmap
			maps.mapArr1_1=[
			[0,0,101,0,101,0,101,0],
			[101,101,101,0,101,101,101,0],
			[101,101,101,0,101,0,101,0],
			[101,101,101,0,101,0,101,0],
			[101,101,101,101,101,101,101,0],
			[0,0,0,0,0,0,0,0]
			];

			//get the tilesheet
			tSheet = new TileSheet(0,0);
			tilesBmp = new Bitmap();
			//add new hero instance
			hero = new Hero(0, 24, 2, 1);
			hero.speed = 3;
			hero.mapx = 0;
			hero.mapy = 0;
			hero.moveOb = new Object();
			hero.bmp = new Bitmap();
			//set up keys object
			keys = new Object();
			//fill the object with arrow keys
			keys[Keyboard.UP] = {down:false, dirx:0, diry:-1, sprNum:1};
			keys[Keyboard.DOWN] = {down:false, dirx:0, diry:1, sprNum:0};
			keys[Keyboard.LEFT] = {down:false, dirx:-1, diry:0, sprNum:3};
			keys[Keyboard.RIGHT] = {down:false, dirx:1, diry:0, sprNum:2};
			//create map
			buildMap ();
			//add key listeners to tilesclip
			myParent.addEventListener (KeyboardEvent.KEY_DOWN, downKeys);
			myParent.addEventListener (KeyboardEvent.KEY_UP, upKeys);
			myParent.addEventListener (Event.ENTER_FRAME, runGame);
			//hide ugly yellow rectangle around objects
			myParent.stage.stageFocusRect = false;
		}
		private function buildMap ():void {
			//set up current map array
			curMap = maps["mapArr" + hero.mapx + "_" + hero.mapy];
			//get map dimensions
			mapW = curMap[0].length;
			mapH = curMap.length;
			//main bitmap to be shown on screen
			tilesBmp.bitmapData = new Bitmap(new BitmapData(ts * mapW, ts * mapH)).bitmapData;
			//add this clip to stage
			myParent.addChild (tilesBmp);
			//loop to place tiles on stage
			for (var yt:int = 0; yt < mapH; yt++) {
				for (var xt:int = 0; xt < mapW; xt++) {
					var s:int = curMap[yt][xt];
					if (s >= 100) {
						s = s - 100;
					}
					//put image on screen
					drawTile (s, xt, yt);
				}
			}
			
			//add graphics to hero
			hero.bmp.bitmapData = getImageFromSheet (hero.sprNum, hero).bitmapData;
			moveObject (hero);
			//add hero to the screen
			myParent.addChild (hero.bmp);
			//reset keys
			for each (var keyOb:Object in keys) {
				keyOb.down = false;
			}
		}
		//this is main game function that is run at enterframe event
		private function runGame (ev:Event):void {
			if (hero.dist == 0) {
				//find if any movement key is down
				for each (var keyOb:Object in keys) {
					//yep, arrow key is down
					if (keyOb.down == true) {
						if(checkDoor(keyOb) == true){
							buildMap ();
							break;
						}
						//check if tile is walkable
						if (checkDir (hero, keyOb) == true) {
							//save move direction
							hero.dist = ts;
							if (hero.moveOb != keyOb) {
								//change sprite
								hero.sprNum = keyOb.sprNum;
								hero.bmp.bitmapData = getImageFromSheet (hero.sprNum, hero).bitmapData;
							}
							hero.moveOb = keyOb;
							//we have moved, dont look for other keys 
							break;
						}
					}
				}
			}
			if (hero.dist > 0) {
				moveObject (hero, hero.moveOb);
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
				ob.x += moveOb.dirx * ob.speed;
				ob.y += moveOb.diry * ob.speed;
				ob.dist -= ob.speed;
				if (ob.dist <= 0) {
					ob.xtile += moveOb.dirx;
					ob.ytile += moveOb.diry;
					ob.x = ob.xtile * ts;
					ob.y = ob.ytile * ts;
					ob.dist = 0;
				}
			}else{
				//find new coordinates
				ob.x = ob.xtile * ts;
				ob.y = ob.ytile * ts;
			}
			//place the graphics
			ob.bmp.x = ob.x + (ts - ob.ts) / 2;
			ob.bmp.y = ob.y + (ts - ob.ts) / 2;
		}
		//this function will check for door
		private function checkDoor (moveOb:Object):Boolean {
			//check for door
			if (hero.xtile == 0 && moveOb.dirx == -1) {
				hero.mapx--;
				hero.xtile = mapW - 1;
				return true;
			} else if (hero.xtile == mapW-1 && moveOb.dirx == 1) {
				hero.mapx++;
				hero.xtile = 0;
				return true;
			} else if (hero.ytile == 0 && moveOb.diry == -1) {
				hero.mapy--;
				hero.ytile = mapH - 1;
				return true;
			} else if (hero.ytile == mapH-1 && moveOb.diry == 1) {
				hero.mapy++;
				hero.ytile = 0;
				return true;
			}
			return false;
		}
		//this function gets image from tilesheet
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
	}
}