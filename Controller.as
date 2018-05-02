package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	import flash.system.System;
	
	//fixing map codes
	
	public class Controller extends Sprite{
		
		var TS:int= 64;
		var centerX:int = 4;
		var centerY:int = 3;
		
		var myParent:MovieClip;
		var tilesBmp:Bitmap;
		var lefoof:MovieClip;
		var mcSheet:MovieClip;
		
		var xLoc:int;
		var yLoc:int;
		var speed:int=16;
		var dir:String="O";
		var facing:String="O";
		
		var curMap:Array;
		var mapW:int;
		var mapH:int;
		var transArray:Vector.<String>;
		//var s
		
		var walkingLR:Boolean=false;
		var walkingUD:Boolean=false;
		var lefoofX:int;
		var lefoofY:int;
		var tilesBmpX:int;
		var tilesBmpY:int;
		
		public function Controller(rootClip:MovieClip, mapToMove:Bitmap, characterToMove:MovieClip, mcToMove:MovieClip)
		{
			myParent=rootClip;
			tilesBmp=mapToMove;
			lefoof=characterToMove;
			mcSheet=mcToMove;
			curMap=myParent.leMap.curMap;
			mapH=curMap.length;
			mapW=curMap[0].length;
			transArray=myParent.leMap.transArray;
			
			xLoc=myParent.startX;
			yLoc=myParent.startY;
			
			addEventListener(Event.ADDED_TO_STAGE, stageAddHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, remove);
			
		}
		
		
		function stageAddHandler(e:Event){
			stage.addEventListener(KeyboardEvent.KEY_DOWN, getLoc);
			getPos();
			position();
		}
		
		function getLoc(e:KeyboardEvent):void
		{
			var xAdvLoc:int = xLoc;
			var yAdvLoc:int = yLoc;
			if (!walkingLR && !walkingUD && myParent.newMessage.alpha==0)
			{
				switch (e.keyCode){
					case Keyboard.RIGHT:
					if(xAdvLoc<mapW-1)
					{
						dir="R";
						xAdvLoc++;
					}
					break;
					
					case Keyboard.LEFT:
					if(xAdvLoc>0)
					{
						dir="L";
						xAdvLoc--;
					}
					break;
					
					case Keyboard.DOWN:
					if(yAdvLoc<mapH-1)
					{
						dir="D";
						yAdvLoc++;
					}
					break;
					
					case Keyboard.UP:
					if(yAdvLoc>0)
					{
						dir="U";
						yAdvLoc--;
					}
					break;
					
					case Keyboard.SPACE:
					interact();
					break;
					
					case Keyboard.S:
					saveGame();
					break;
					
					case Keyboard.I:
					myParent.myInv.openInv();
					break;
				}
			}
			
			//if the location you want to visit has tileType 1 or 2, entry is denied
			if (tileType(yAdvLoc, xAdvLoc)!=1 && tileType(yAdvLoc, xAdvLoc)!=2){
				xLoc=xAdvLoc;
				yLoc=yAdvLoc;
			}
			getPos();
			this.addEventListener(Event.ENTER_FRAME, animate);
			
		}
		
		function saveGame()
		{
			var xCoord:int=(lefoof.x-tilesBmp.x)/64;
			var yCoord:int=(lefoof.y-tilesBmp.y)/64;
			
			myParent.newMessage.appear("Saving game...");
			
			myParent.sData.data.uname = myParent.uname;
			myParent.sData.data.xCoord=xCoord;
			myParent.sData.data.yCoord=yCoord;
			myParent.sData.data.mapName = myParent.mapName;
			
			myParent.sData.data.invDic=new Object();
			for (var id:String in myParent.myInv.invDic)
			{
				myParent.sData.data.invDic[id] = myParent.myInv.invDic[id];
			}
			myParent.sData.flush();
			myParent.newMessage.addWords("Game successfully saved!\n<Used up " + myParent.sData.size+" memory units.>");
		}
		
		function animate(e:Event)
		{
			if(!walkingUD && !walkingLR)
			{
				var xCoord:int=(lefoof.x-tilesBmp.x)/64;
				var yCoord:int=(lefoof.y-tilesBmp.y)/64;

				//check if he is stepping on a transporter (tiletype3)
				if (tileType(yCoord, xCoord)==3)
				{
					renewMap(transArray[tileCode(yCoord, xCoord)]);
				}
				
				
			}
			
			if (lefoof.x<lefoofX*TS)
			{
				lefoof.x+=speed;
			}
			
			if (tilesBmp.x<tilesBmpX*TS)
			{
				tilesBmp.x+=speed;
				mcSheet.x+=speed;
			}
			
			
			if (lefoof.x>lefoofX*TS)
			{
				lefoof.x-=speed;
			}
			
			if (tilesBmp.x>tilesBmpX*TS)
			{
				tilesBmp.x-=speed;
				mcSheet.x-=speed;
			}
			
			if (lefoof.x!=lefoofX*TS || tilesBmp.x!= tilesBmpX*TS)
			{
				walkingLR = true;
			}
			else
			{
				walkingLR=false;
			}
			
			if (lefoof.y<lefoofY*TS)
			{
				lefoof.y+=speed;
			}
			
			if (tilesBmp.y<tilesBmpY*TS)
			{
				tilesBmp.y+=speed;
				mcSheet.y+=speed;
			}
			
			
			if (lefoof.y>lefoofY*TS)
			{
				lefoof.y-=speed;
			}
			
			if (tilesBmp.y>tilesBmpY*TS)
			{
				tilesBmp.y-=speed;
				mcSheet.y-=speed;
			}
			
			if (lefoof.y!=lefoofY*TS || tilesBmp.y!= tilesBmpY*TS)
			{
				walkingUD = true;
			}
			else
			{
				walkingUD=false;
			}
			
			
		}
		
		//get position of lefoof and tilesBmp given foof's relative position
		function getPos():void
		{
			
			if(xLoc<centerX)
			{
				lefoofX=xLoc;
			}
			
			else if (xLoc>mapW-centerX-2)
			{
				tilesBmpX=stage.stageWidth/TS-mapW;
				lefoofX=xLoc-mapW+centerX+centerX+2;
			}
			
			else
			{
				lefoofX=centerX;
				tilesBmpX=centerX-xLoc;
			}
			
			if(yLoc<centerY)
			{
				lefoofY=yLoc;
			}
			
			else if (yLoc>mapH-centerY-2)
			{
				tilesBmpY=stage.stageHeight/TS-mapH;
				lefoofY=yLoc-mapH+centerY+centerY+2;
			}
			
			else
			{
				lefoofY=centerY;
				tilesBmpY=centerY-yLoc;
			
			}

		}
		
		//place foof and tilesBmp in the correct spot at the start of the game
		function position():void
		{
			lefoof.x=lefoofX*TS;
			lefoof.y=lefoofY*TS;
			tilesBmp.x=tilesBmpX*TS;
			tilesBmp.y=tilesBmpY*TS;
			mcSheet.x=tilesBmpX*TS;
			mcSheet.y=tilesBmpY*TS;

		}
		
		
		//load a new map
		function renewMap(transData:String)
		{		
			var transDataS:Array = transData.split(',');
			myParent.mapName=transDataS[0];
			myParent.startX=(int)(transDataS[1]);
			myParent.startY=(int)(transDataS[2]);
			this.removeEventListener(Event.ENTER_FRAME, animate)
			myParent.clearMap();
		}
		
		
		//remove event listener when removed from stage
		function remove(e:Event)
		{	
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, getLoc);
		}
		
		function interact()
		{
			//check the tile foof is facing			
			var tileFacedX:int=(lefoof.x-tilesBmp.x)/64;
			var tileFacedY:int=(lefoof.y-tilesBmp.y)/64;
			facing = lefoof.facing;
			switch(facing)
			{
				case "F":
				tileFacedY++;
				break;
				
				case "B":
				tileFacedY--;
				break;
				
				case "L":
				tileFacedX--;
				break;
				
				case "R":
				tileFacedX++;
				break;
				
			}
			
			//if facing an item tiie,
			if (tileType(tileFacedY, tileFacedX)==2)
			{
				
				var mcname:String = myParent.leMap.itemDic[(tileCode(tileFacedY, tileFacedX))]
				
				myParent.myInv.addStuff(mcname);
				
				var mccode:String = myParent.leMap.itemDic[(tileCode(tileFacedY, tileFacedX))] + "_" + tileFacedY + "x" + tileFacedX;
				myParent.mySwitch.pickedUp(mccode);
				
				mcSheet.removeChild(myParent.leMap.mcSheet[mccode]);
				
				curMap[tileFacedY][tileFacedX] -= 200;
				
				
			}
		}
		
		function tileType (yCoord:int, xCoord:int):int
		{
			return (int)((curMap[yCoord][xCoord]%1000)/100);
		}
		
		function tileCode (yCoord:int, xCoord:int):int
		{
			return (int)(curMap[yCoord][xCoord]/1000);
		}
	}
	
}
