package  {
	import flash.net.*;
	import flash.events.*;
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.*;
	
	public class mapMaker{
		
		//LABELLING SO THAT THIS GAME MAY PERPETUATE
		
		
		var mapW:int;
		var mapH:int;
		var ts:int=64;
		var tSheet:BitmapData;//holds bitmap data of the original tile sheet
		var mcDic:Vector.<String> = new Vector.<String>;//dictionary telling you which number stands for which movieclip
		var tileSource:String;
		var myParent:MovieClip;
		
		public var curMap:Array = [];// 2D integer array to code for tiles
		public var tilesBmp:Bitmap;// bmp to place the map
		public var transArray:Vector.<String>=new Vector.<String>; // holds string data for transporter destination (map name and coordinates)
		public var itemDic:Vector.<String> = new Vector.<String>;// holds name of item for every item number
		public var mcSheet:MovieClip = new MovieClip(); //movieclip containing all movieclips with names
		public var falseIList:Vector.<String>=new Vector.<String>;//set of pickupable items with coordinates
		public var trueIList:Vector.<String>=new Vector.<String>;
		
		public function mapMaker(rootClip:MovieClip, mapArray:Array) {
			
			myParent=rootClip;
			//parse the mapArray
			makeNewMap(mapArray);
			
			//make a bmp out of the curMap or the 2D number array
			prepareGame();
			
		}
		
		private function makeNewMap(mapArray:Array)
		{
			//parsing mapArray...

			//parsing mcList...make a dictionary which pairs letter to movieclip name
			var i:int=0;
			if (mapArray[i] == "mcList")
			{
				i++;
				while(mapArray[i] != "END")
				{
					mcDic.push(mapArray[i]);
					i++;
				}
				i++;
			}
			
			
			//parsing itemList makes a string vector of items in the map
			if (mapArray[i] == "itemList")
			{
				i++;
				while(mapArray[i] != "END")
				{
					itemDic.push(mapArray[i]);
					i++;
				}
				i++;
			}
			
			//parsing transList...lists all the transporter data in a string vector
			if (mapArray[i] == "transList")
			{
				i++;
				while(mapArray[i] != "END")
				{
					transArray.push(mapArray[i]);
					i++;
				}
				i++;
			}
			
			//parsing the bulk of map...making a 2D number array coding for tile numbers
			var n:int=0;// this is the counter for the row number
			while(mapArray[i].indexOf("END")<0)
			{
				var lineArray:Array = mapArray[i].split(", ");
				for (var j:int=0;j<lineArray.length;j++)
				{
					var dataArray:Array=lineArray[j].split(".");
					lineArray[j]=(int)(dataArray[0]);
					
					var mcname:String = new String();
					var mccode:String = new String();
					
					//this is when there is a dot after the tile number...there must be a movieclip
					if (dataArray[1])
					{
						//makes a new movieclip based on the mc number
						mcname = mcDic[(int)(dataArray[1])];
						
					}
					
					//when the tilecode is 2, the tile contains an item
					if ((int)(lineArray[j]%1000/100)==2)
					{
						//find what movieclip is due based on the itemList
						mcname = itemDic[(int)(lineArray[j]/1000)];
						
						//gives a specific name for the item and places it in falseIList
						mccode = mcname + "_"+ n.toString() + "x" + j.toString();
						
						falseIList.push(mccode);
						
					}
					
					//if the trueIList is empty or if the item is not found on the trueIList;
					var placeOnMap:Boolean = myParent.mySwitch.mTrueIList[myParent.mapName] == undefined || myParent.mySwitch.mTrueIList[myParent.mapName].indexOf(mccode)<0
					
					//if there is a movieclip supposed to be placed on that tile, then put it in the mcSheet
					if (mcname && placeOnMap)
					{
						//makes a movieclip based on its name
						var ClassName:Object = getDefinitionByName(mcname);
						var mc:MovieClip = new ClassName();
						
						//places it in its position on the map
						mc.x=j*ts;
						mc.y=n*ts;
						
						//adds the movieclip onto the mcSheet
						mcSheet.addChild(mc);
						
						if (mccode)
						{
							mcSheet[mccode] = mc;
						}
					}
					
					else if (mcname)
					{
						lineArray[j] -=200
					}
				}
				
				//after finishing one line, places the array of numbers in that line in the 2D number array, curMap
				curMap.push(lineArray);
				i++;
				n++;
			}
			
			i++;
			if (mapArray[i] == "source")
			{
				i++;
				tileSource=mapArray[i]
				i++;
			}
			
			//if the falseList is still empty in the masterlist, append the new falseList and truelist
			if (myParent.mySwitch.mFalseIList[myParent.mapName]==null)
			{
			 	myParent.mySwitch.appendLists(falseIList, trueIList);			
			}
		}
		
		//makes a bmp out of the 2D number array
		function prepareGame ():void {
			
			var ClassName:Object = getDefinitionByName(tileSource);
			tSheet = new ClassName();
			
			mapW = curMap[0].length;
			mapH = curMap.length;
		
			tilesBmp = new Bitmap(new BitmapData(ts * mapW, ts * mapH));
			
			for (var yt:int = 0; yt < mapH; yt++) {
				for (var xt:int = 0; xt < mapW; xt++) {
					var s:int = curMap[yt][xt];
					if (s >= 100) {
						s = s % 100;
					}
					drawTile (s, xt, yt);
				}
			}
			
			
		}
		
		//given the tile number and position, it draws small square to fill up the main bmp
		function drawTile (s:Number, xt:int, yt:int):void {
			var bmp:Bitmap = getImageFromSheet (s);
			var rect:Rectangle = new Rectangle(0, 0, ts, ts);
			var pt:Point = new Point(xt * ts, yt * ts);
			tilesBmp.bitmapData.copyPixels (bmp.bitmapData, rect, pt);
		}
		
		//given the tile number, it returns a bitmap of the tile
		function getImageFromSheet (s:Number):Bitmap {
			
			var sheetColumns:int = tSheet.width / ts;
			var col:int = s % sheetColumns;
			var row:int = Math.floor(s / sheetColumns);
			var rect:Rectangle = new Rectangle(col * ts, row * ts, ts, ts);
			var pt:Point = new Point(0, 0);
			var bmp:Bitmap =  new Bitmap(new BitmapData(ts, ts));
			bmp.bitmapData.copyPixels (tSheet, rect, pt);
			return bmp;
		}
		
	}
	
}
