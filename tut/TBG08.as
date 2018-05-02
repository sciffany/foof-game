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
	public class TBG08 extends Object {
		//declare variables
		private var maps:Object;
		private var curMap:Array;
		private var complexTiles:Array;
		private var doors:Object;
		private var mapW:int;
		private var mapH:int;
		private var ts:int;
		private var myParent:Sprite;
		private var tilesBmp:Bitmap;
		private var tSheet:BitmapData;
		private var hero:Hero;
		private var keys:Object;

		//class constructor function
		public function TBG08 (s:Sprite) {
			myParent = s;
			prepareGame ();
		}
		//start the game by preparing stuff
		private function prepareGame ():void {
			ts = 32;
			doors = new Object();
			maps = new Object();
			//new map
			maps.mapArr0=[
			[0,0,0,0,0,0,0,0],
			[0,101,101,101,101,101,101,0],
			[0,101,0,101,101,101,101,0],
			[0,101,101,101,101,0,101,0],
			[0,101,101,101,101,101,101,102],
			[0,0,0,0,0,0,0,0]
			];
			//nextmap
			maps.mapArr1=[
			[0,0,0,0,0,0,0,0],
			[0,101,101,101,101,101,101,0],
			[0,0,0,101,101,0,101,0],
			[0,101,101,101,0,101,0,0],
			[102,101,101,101,101,101,101,0],
			[0,0,0,0,0,0,0,0]
			];
			//set up the doors
			doors["0_7_4"] = [1,1,4];
			doors["1_0_4"] = [0,6,4];
			
			complexTiles = new Array();
			complexTiles[102] = createComplexTile(1, [2]);

			//get the tilesheet
			tSheet = new TileSheet(0,0);
			tilesBmp = new Bitmap();
			//add new hero instance
			hero = new Hero(0, 24, 2, 1);
			hero.speed = 3;
			hero.mymap = 0;
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
			curMap = maps["mapArr" + hero.mymap];
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
			hero.bmp.bitmapData = getImageFromSheet (hero.sprNum, hero).bitmapData;
			moveObject (hero);
			//add hero to the screen
			myParent.addChild (hero.bmp);
			//reset keys
			for each (var keyOb in keys) {
				keyOb.down = false;
			}
		}
		//this is main game function that is run at enterframe event
		private function runGame (ev:Event):void {
			var moveOb:Object = new Object();
			//find if any movement key is down
			for each (var keyOb in keys) {
				//yep, arrow key is down
				if (keyOb.down == true) {
					//check if tile is walkable
					if (getMyCorners(hero.x + keyOb.dirx * hero.speed, hero.y + keyOb.diry * hero.speed, hero) == true) {
						moveOb = keyOb;
					}else{
						//we have hit the wall, place near it
						if(keyOb.dirx < 0){
							hero.x = hero.xtile * ts;
						}else if(keyOb.dirx > 0){
							hero.xtile = Math.floor((hero.x + hero.speed) / ts);
							hero.x = (hero.xtile + 1) * ts - hero.ts;
						}else if(keyOb.diry < 0){
							hero.y = hero.ytile * ts;
						}else if(keyOb.diry > 0){
							hero.ytile = Math.floor((hero.y + hero.speed) / ts);
							hero.y = (hero.ytile + 1) * ts - hero.ts;
						}
						moveOb.dirx = 0;
						moveOb.diry = 0;
						moveOb.sprNum = keyOb.sprNum;
						//try to move hero around the wall tiles
						if(keyOb.dirx != 0){
							var ytc:int = Math.floor((hero.y + hero.ts/2) / ts);
							if(isWalkable(hero.xtile + keyOb.dirx, ytc)){
								//align vertically
								var centerY:int = ytc * ts + (ts - hero.ts) / 2;
								if(hero.y > centerY){
									//move up
									hero.y--;
								}else if(hero.y < centerY){
									//move down
									hero.y++;
								}
							}
						}else{
							var xtc:int = Math.floor((hero.x + hero.ts/2) / ts);
							if(isWalkable(xtc, hero.ytile + keyOb.diry)){
								//align horisontal
								var centerX:int = xtc * ts + (ts - hero.ts) / 2;
								if(hero.x > centerX){
									//move left
									hero.x--;
								}else if(hero.x < centerX){
									hero.x++;
								}
							}
						}
					}
					break;
				}
			}
			if(moveOb.dirx != null){
				//move the hero
				moveObject (hero, moveOb);
			}
			//get the focus to the main clip to keys are detected
			if (myParent.stage.focus != myParent) {
				myParent.stage.focus = myParent;
			}
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
				//check if graphics need to change
				if (ob.moveOb != moveOb) {
					//change sprite
					ob.moveOb = moveOb;
					ob.sprNum = moveOb.sprNum;
					ob.bmp.bitmapData = getImageFromSheet (ob.sprNum, ob).bitmapData;
				}
			}else{
				//find new coordinates
				ob.x = ob.xtile * ts + (ts - ob.ts) / 2;
				ob.y = ob.ytile * ts + (ts - ob.ts) / 2;
			}
			//update tile
			ob.xtile = Math.floor(ob.x / ts);
			ob.ytile = Math.floor(ob.y / ts);
			//place the graphics
			ob.bmp.x = ob.x;
			ob.bmp.y = ob.y;
			checkDoor (ob);
		}
		//this function will check for door
		private function checkDoor (ob:*):void {
			//center tile
			var ytc:int = Math.floor((ob.y + ob.ts/2) / ts);
			var xtc:int = Math.floor((ob.x + ob.ts/2) / ts);
			var tileName:String = ob.mymap + "_" + xtc + "_" + ytc;
			//check if door exist
			if (doors[tileName] != null) {
				//change map
				ob.mymap = doors[tileName][0];
				//change position of hero
				ob.xtile = doors[tileName][1];
				ob.ytile = doors[tileName][2];
				buildMap ();
			}
		}
		private function getMyCorners (x:Number, y:Number, ob:Object):Boolean {
			//find corner points
			var upY:Number = Math.floor(y / ts);
			var downY:Number = Math.floor((y + ob.ts - 1) / ts);
			var leftX:Number = Math.floor(x / ts);
			var rightX:Number = Math.floor((x + ob.ts - 1) / ts);
			if (upY < 0 || downY >= mapH || leftX < 0 || rightX >= mapW) {
				return false;
			}
			//check if they are walls
			var ul:Boolean = isWalkable (leftX, upY);
			var dl:Boolean = isWalkable (leftX, downY);
			var ur:Boolean = isWalkable (rightX, upY);
			var dr:Boolean = isWalkable (rightX, downY);
			return ul && dl && ur && dr;
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