package 
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Main extends MovieClip
	{

		public var mapDimensions:Rectangle = new Rectangle(0,0,9,9);
		public var map:Array = new Array();
		public var rooms:Vector.<Room> = new Vector.<Room>();
		public var mapMC:MovieClip;
		private var generatingMap:Boolean = false;
		private var roomsToBeProcessed:Vector.<Room> = new Vector.<Room>();
		private var currentGenRoom:Room;

		static public var instance:Main;

		public static const RIGHT:uint = 1;
		public static const LEFT:uint = 2;
		public static const UP:uint = 3;
		public static const DOWN:uint = 4;

		public function Main()
		{
			instance = this;

			initMap(9, 9);

			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function onEnterFrame(e:Event):void
		{
			if (generatingMap)
			{
				genMapStep();
			}
		}

		private function genMapStep():void
		{
			for (var i:uint = 0; i < roomsToBeProcessed.length; i++)
			{
				var room:Room = roomsToBeProcessed[i];
				for (var j:uint = 0; j < room.exits.length; j++)
				{
					var exit:Exit = room.exits[j];
					//Check if connecting room's exit is valid
					var exitSpot:Point = exit.getExitLoc(new Point(room.loc.x + exit.loc.x,room.loc.y + exit.loc.y),exit.dir);
					if (exitSpot != null && mapDimensions.containsPoint(exitSpot))
					{
						var targRoom:Room = map[exitSpot.y][exitSpot.x];
						if (targRoom == null)
						{
							var newRoom:Room = placeRoom(exit,exitSpot);
							roomsToBeProcessed.push(newRoom);
						}
						else
						{
							var linkSpot:Point = new Point(exitSpot.x - targRoom.loc.x,exitSpot.y - targRoom.loc.y);
							var success:Boolean = targRoom.addExit(new Exit(linkSpot,exit.getOppositeDir(exit.dir)),targRoom.exits);
						}
					}
					else
					{
						room.exits.pop();
						j--;
					}
				}
				roomsToBeProcessed.splice(i, 1);
			}
			if (roomsToBeProcessed.length == 0)
			{
				generatingMap = false;
			}
			if (mapMC.parent)
			{
				removeChild(mapMC);
			}
			mapMC = new MovieClip();
			mapMC.x +=  30;
			mapMC.y +=  30;
			for (var col:uint = 0; col < 9; col++)
			{
				for (var row:uint = 0; row < 9; row++)
				{
					var newSq:MovieClip = new sq();
					newSq.gotoAndStop(1);
					newSq.alpha = 0.2;
					newSq.x = row * 25;
					newSq.y = col * 25;
					mapMC.addChild(newSq);

				}
			}
			for each (var roomD:Room in rooms)
			{
				roomD.drawMe();
				roomD.mc.x = roomD.loc.x * 25;
				roomD.mc.y = roomD.loc.y * 25;
				mapMC.addChild(roomD.mc);
			}
			addChild(mapMC);
		}

		private function initMap(w:uint, h:uint):void
		{
			currentGenRoom = null;
			mapMC = new MovieClip();
			mapMC.x +=  30;
			mapMC.y +=  30;
			addChild(mapMC);
			//Setup arrays
			for (var col:uint = 0; col < h; col++)
			{
				map[col] = new Vector.<Room > (w,true);
				for (var row:uint = 0; row < w; row++)
				{
					map[col][row] = null;
				}
			}
			var firstRoom:Room = new Room(1,1,new Point(0,0));
			firstRoom.exits.push(new Exit(new Point(0, 0), Exit.RIGHT));
			map[0][0] = firstRoom;
			rooms.push(firstRoom);

			generatingMap = true;
			//currentGenRoom = recurseRoom(firstRoom);
			roomsToBeProcessed.push(firstRoom);
		}

		private function placeRoom(prevExit:Exit, s:Point):Room
		{
			//Check if neighboring spot is free
			var newRoom:Room;

			//Check possible configs
			var possibleSizes:Vector.<Point> = new Vector.<Point>();
			var dimX:Point = new Point(0,0);
			var dimY:Point = new Point(0,0);
			var i:int;
			var j:int;

			trace("Consider spot:" + s);
			for (i = -2; i < 3; i++)
			{
				if (s.x + i >= 0 && s.x + i < mapDimensions.width && map[s.y][s.x + i] == null)
				{
					trace("This row one is free!" + map[s.y][s.x + i]);
					dimX.x = Math.min(dimX.x,i);
					dimX.y = Math.max(dimX.y,i);
				}
				else
				{
					if (i == -1)
					{
						dimX.x = 0;
					}
					else if (i == 1)
					{
						dimX.y = 0;
						break;
					}
				}
			}
			for (i = -2; i < 3; i++)
			{
				if (s.y + i >= 0 && s.y + i < mapDimensions.height && map[s.y + i][s.x] == null)
				{
					trace("This col one is free!" + map[s.y + i][s.x]);
					dimY.x = Math.min(dimY.x,i);
					dimY.y = Math.max(dimY.y,i);
				}
				else
				{
					if (i == -1)
					{
						dimY.x = 0;
					}
					else if (i == 1)
					{
						dimY.y = 0;
						break;
					}
				}
			}
			for (i = dimX.x; i <= dimX.y; i++)
			{
				for (j = dimY.x; j <= dimY.y; j++)
				{
					if (map[s.y + j][s.x + i] == null) {
						possibleSizes.push(new Point(i, j));
					}
				}
			}

			trace(possibleSizes + "\n");
			var chosenDim:Point = possibleSizes[Math.floor(Math.random() * possibleSizes.length)];

			var newStart:Point = s.clone();
			if (chosenDim.x < 0)
			{
				newStart.x +=  chosenDim.x;
			}
			if (chosenDim.y < 0)
			{
				newStart.y +=  chosenDim.y;
			}

			newRoom = new Room(Math.abs(chosenDim.x) + 1,Math.abs(chosenDim.y) + 1,newStart);
			var localStart:Point = new Point(s.x - newStart.x,s.y - newStart.y);
			var connectingExit:Exit = new Exit(localStart,prevExit.getOppositeDir(prevExit.dir));
			newRoom.exits.push(connectingExit);
			newRoom.assignRandomExits(1);

			//i = chosenDim.x;
			//j = chosenDim.y;
			trace("start point: " + s);
			trace("chosenDim: " + chosenDim);
			if (chosenDim.x >= 0)
			{
				for (i = 0; i <=chosenDim.x; i++)
				{
					if (chosenDim.y >= 0)
					{
						for (j = 0; j <=chosenDim.y; j++)
						{
							map[s.y + j][s.x + i] = newRoom;
						}
					}
					else
					{
						for (j = 0; j >=chosenDim.y; j--)
						{
							map[s.y + j][s.x + i] = newRoom;
						}
					}
				}
			}
			else
			{
				for (i = 0; i >=chosenDim.x; i--)
				{
					if (chosenDim.y >= 0)
					{
						for (j = 0; j <=chosenDim.y; j++)
						{
							map[s.y + j][s.x + i] = newRoom;
						}
					}
					else
					{
						for (j = 0; j >=chosenDim.y; j--)
						{
							map[s.y + j][s.x + i] = newRoom;
						}
					}
				}
			}

			printMap();
			/*if (s.x + 1 < mapDimensions.width && map[s.y][s.x + 1] == null) {
			
			   newRoom = new Room(2, 1, s);
			   var connectingExit:Exit = new Exit(new Point(0, 0), prevExit.getOppositeDir(prevExit.dir));
			   newRoom.exits.push(connectingExit);
			   newRoom.assignRandomExits(1);
			   map[s.y][s.x] = newRoom;
			   map[s.y][s.x + 1] = newRoom;
			
			   } else if (chance < 0.6 && s.x - 1 >= 0 && map[s.y][s.x - 1] == null) {
			   var newStart:Point = s.clone();
			   newStart.x--;
			
			   newRoom = new Room(2, 1, newStart);
			   var connectingExit:Exit = new Exit(new Point(1, 0), prevExit.getOppositeDir(prevExit.dir));
			   newRoom.exits.push(connectingExit);
			   newRoom.assignRandomExits(1);
			   map[s.y][s.x] = newRoom;
			   map[s.y][s.x - 1] = newRoom;
			
			   } else {
			   newRoom = new Room(1, 1, s);
			   var connectingExit:Exit = new Exit(new Point(0, 0), prevExit.getOppositeDir(prevExit.dir));
			   newRoom.exits.push(connectingExit);
			   newRoom.assignRandomExits(1);
			   map[s.y][s.x] = newRoom;
			 }*/
			if (newRoom != null)
			{
				rooms.push(newRoom);
				return newRoom;
			}
			return null;
		}

		private function printMap():void
		{
			for (var col:uint = 0; col < 9; col++)
			{
				var line:String = col + ":";
				for (var row:uint = 0; row < 9; row++)
				{
					line +=  "\t" + map[col][row];
				}
				trace(line);
			}
		}

		private function clickHandler(e:MouseEvent)
		{

			removeChild(mapMC);
				rooms = new Vector.<Room>();
				roomsToBeProcessed = new Vector.<Room>();
				initMap(9, 9);
		}


	}
}