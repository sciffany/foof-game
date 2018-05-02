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
	public class TBG07a extends Object {
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
		private var hero:Hero;
		private var keys:Object;
		
		//class constructor function
		public function TBG07a (s:Sprite) {
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
			[  0,101,101,101,101,101,102,  0],
			[  0,  0,  0,  0,  0,  0,  0,  0]
			];
			complexTiles = new Array();
			complexTiles[102] = createComplexTile(1, [3,10,4,10,5,10]);
			//set up array for all animated things
			animatedObjects = new Array();
			//get the tilesheet
			tSheet = new TileSheet(0,0);
			//set up current map array
			curMap = mapArr;
			//add new hero instance
			hero = new Hero(0, 24, 2, 1);
			hero.speed = 3;
			hero.moveOb = new Object();
			//add hero to animations
			animatedObjects.push(hero);
			//set up keys object
			keys = new Object();
			//fill the object with arrow keys
			keys[Keyboard.UP] = {down:false, dirx:0, diry:-1, sprNum:1, anim:[1,5,5,5,1,5,9,5]};
			keys[Keyboard.DOWN] = {down:false, dirx:0, diry:1, sprNum:0, anim:[0,5,4,5,0,5,8,5]};
			keys[Keyboard.LEFT] = {down:false, dirx:-1, diry:0, sprNum:3, anim:[3,5,7,5,3,5,11,5]};
			keys[Keyboard.RIGHT] = {down:false, dirx:1, diry:0, sprNum:2, anim:[2,5,6,5,2,5,10,5]};
			
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
		private function buildMap () {
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
			//add graphics to hero
			hero.bmp = getImageFromSheet (hero.sprNum, hero);
			moveObject (hero);
			//add hero to the screen
			myParent.addChild (hero.bmp);
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
						moveOb.anim = [];
						//try to move hero around the wall tiles
						if(keyOb.dirx != 0){
							var ytc:int = Math.floor((hero.y + hero.ts/2) / ts);
							if(isWalkable(hero.xtile + keyOb.dirx, ytc)){
								//align vertically
								var centerY:int = ytc * ts + (ts - hero.ts) / 2;
								if(hero.y > centerY){
									//move up
									hero.y--;
									moveOb.anim = keyOb.anim;
								}else if(hero.y < centerY){
									//move down
									hero.y++;
									moveOb.anim = keyOb.anim;
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
									moveOb.anim = keyOb.anim;
								}else if(hero.x < centerX){
									hero.x++;
									moveOb.anim = keyOb.anim;
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
			}else{
				hero.anim = [];
			}
			//get the focus to the main clip to keys are detected
			if (myParent.stage.focus != myParent) {
				myParent.stage.focus = myParent;
			}
			//animate the objects
			animateSprite ();
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
			if (keys[ev.keyCode] != undefined) {
				//set the key to true
				keys[ev.keyCode].down = true;
			}
		}
		//this function will detect keys that are being released
		private function upKeys (ev:KeyboardEvent):void {
			//check if the is arrow key
			if (keys[ev.keyCode] != undefined) {
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
					if(ob.anim != moveOb.anim){
						ob.animTime = 0;
						ob.animCount = 0;
						ob.anim = moveOb.anim;
					}
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
		//this function will animate all the objects
		private function animateSprite ():void {
			//run through all objects needing the animation
			for (var n:int = 0; n < animatedObjects.length; n++) {
				var ob:Object = animatedObjects[n];
				if(ob.anim.length > 0){
					//add 1 to time counter
					ob.animTime++;
					var reachedEnd:Boolean = false;
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
							ob.sprNum = ob.anim[ob.animCount];
							ob.bmp.bitmapData = getImageFromSheet (ob.sprNum, ob).bitmapData;
						}
						//reset animation timer
						ob.animTime = 0;
					}
				}
			}
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