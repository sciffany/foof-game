package  {
	import flash.events.*;
	import flash.display.*;
	
	public class Switch {

		public var mFalseIList:Object = {};
		public var mTrueIList:Object = {};
		
		
		public var trueList:Vector.<String> = new Vector.<String>;
		public var falseList:Vector.<String> = new Vector.<String>;
		
		var myParent:MovieClip;
		
		public function Switch(rootClip:MovieClip) {
			myParent = rootClip;
			
		}
		
		public function appendLists(fList:Vector.<String>, tList:Vector.<String>)
		{
			mFalseIList[myParent.mapName] = new Vector.<String>;
			for (var i:int=0; i<fList.length;i++)
			{
				mFalseIList[myParent.mapName][i] = fList[i];
			}
			mTrueIList[myParent.mapName] = new Vector.<String>;
			for (var k:int=0; k<tList.length;k++)
			{
				mTrueIList[myParent.mapName][k] = tList[k];
			}
			
		}
		//given the mccode, return a boolean if it can be found in truelist of current map
		public function inTrueList(switchName:String)
		{
			var trueIList:Vector.<String> =  mTrueIList[myParent.mapName];
			/**var switchIndex:int =trueIList.indexOf(switchName);

			trace(switchIndex);
			if (switchIndex>=0)
			{
				return true;
			}
			
			else
			{
				return false;
			}**/
			
		}
		
		
		public function pickedUp(switchName:String)
		{
			
			var falseIList:Vector.<String> = mFalseIList[myParent.mapName];
			var trueIList:Vector.<String> = mTrueIList[myParent.mapName];
			
			var lastItem:String = falseIList.pop();
						
			if (lastItem!=switchName)
			{			
				//find the name of the item in falseIList
				var switchIndex:int = falseIList.indexOf(switchName);
				
				if (switchIndex>=0)
				{
					falseIList[switchIndex] = lastItem;
					trueIList.push(switchName);
				}		
			
			}
			
			else
			{
				trueIList.push(switchName);
			}
		
		}
		
		//place attribute in the truelist and remove it from the falseList
		function turnOn(switchName:String)
		{
			var switchIndex:int = falseList.indexOf(switchName);
			if (switchIndex>=0)
			{
				var lastItem:String = falseList.pop();
				trueList.push(switchName);
			}
			
		}

	}
	
}
