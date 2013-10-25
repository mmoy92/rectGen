package {
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Michael M
	 */
	public class Room {
		public var height:uint;
		public var width:uint;
		
		public var loc:Point = new Point(0, 0);
		public var exits:Vector.<Exit> = new Vector.<Exit>();
		
		public var mc:MovieClip;
		
		public function Room(w:uint, h:uint, l:Point) {
			width = w;
			height = h;
			loc = l;
		}
		
		public function assignRandomExits(num:uint):void {
			
			var possibleExits:Vector.<Exit> = new Vector.<Exit>();
			for (var col:uint = 0; col < height; col++) {
				for (var row:uint = 0; row < width; row++) {
					var curLoc:Point = new Point(row, col);
					if (loc.y + col != 0 && col == 0) {
						possibleExits.push(new Exit(curLoc, Exit.UP));
					}
					if (loc.y + col != Main.instance.height - 1 && col == height - 1) {
						possibleExits.push(new Exit(curLoc, Exit.DOWN));
					}
					if (loc.x + row != 0 && row == 0) {
						possibleExits.push(new Exit(curLoc, Exit.LEFT));
					}
					if (loc.x + row != Main.instance.width - 1 && row == width - 1) {
						possibleExits.push(new Exit(curLoc, Exit.RIGHT));
					}
				}
			}
			var n:uint = num;
			while (n > 0) {
				if (possibleExits.length == 0) {
					return;
				}
				var randIndex:int = Math.floor(Math.random() * possibleExits.length);
				var randomPotentialExit:Exit = possibleExits[randIndex];
				if (addExit(randomPotentialExit, exits)) {
					possibleExits.splice(randIndex, 1);
					n--;
				}
			}
		}
		
		/**
		 * Adds a given exit to the given vector. Fails if exit already exists.
		 * @param	newExit
		 * @param	vect
		 */
		public function addExit(newExit:Exit, vect:Vector.<Exit>):Boolean {
			for each (var myExit:Exit in vect) {
				if (newExit.equals(myExit)) {
					return false;
				}
			}
			vect.push(newExit);
			return true;
		}
		
		public function toString():String {
			return "[" + loc.x + "," + loc.y + "]";
		}
		
		public function drawMe():void {
			mc = new sq();
			if (width == 1) {
				if (height == 1) {
					mc.gotoAndStop(1);
				} else if (height == 2) {
					mc.gotoAndStop(2);
				} else if (height == 3) {
					mc.gotoAndStop(3);
				}
			}  else if (width == 2) {
				if (height == 1) {
					mc.gotoAndStop(4);
				} else if (height == 2) {
					mc.gotoAndStop(5);
				} else if (height == 3) {
					mc.gotoAndStop(6);
				}
			} else if (width == 3) {
				if (height == 1) {
					mc.gotoAndStop(7);
				} else if (height == 2) {
					mc.gotoAndStop(8);
				} else if (height == 3) {
					mc.gotoAndStop(9);
				}
			} 
			
			for each (var myExit:Exit in exits) {
				var newDo:MovieClip = new dor();
				newDo.x = myExit.loc.x * 25;
				newDo.y = myExit.loc.y * 25;
				if (myExit.dir == Exit.UP) {
					newDo.y += (-25 / 2) + newDo.height / 2;
				} else if (myExit.dir == Exit.DOWN) {
					newDo.y += (25 / 2) - newDo.height / 2;
				} else if (myExit.dir == Exit.RIGHT) {
					newDo.x += (25 / 2) - newDo.width / 2;
				} else if (myExit.dir == Exit.LEFT) {
					newDo.x += (-25 / 2) + newDo.width / 2;
				}
				mc.addChild(newDo);
			}
		}
	}
}