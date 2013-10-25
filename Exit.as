package {
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Michael M
	 */
	public class Exit {
		static public const UP = 0;
		static public const RIGHT = 1;
		static public const LEFT = 2;
		static public const DOWN = 3;
		
		public var loc:Point;
		public var dir:uint;
		
		public function Exit(p:Point, d:uint) {
			loc = p;
			dir = d;
		}
		
		public function equals(other:Exit):Boolean {
			return (loc.x == other.loc.x && loc.y == other.loc.y && dir == other.dir);
		}
		/**
		 * Returns the location of an adjacent block, depending on exit direction
		 * @param	loc Location of the block containing the exit.
		 * @param	dir Exit direction.
		 * @return
		 */
		public function getExitLoc(loc:Point, dir:uint):Point {
			var out:Point = loc.clone();
			switch (dir) {
				case UP: 
					out.y--;
					break;
				case DOWN: 
					out.y++;
					break;
				case RIGHT: 
					out.x++;
					break;
				case LEFT: 
					out.x--;
					break;
			}
			if (out.y < 0 || out.x < 0) {
				return null;
			}
			return out;
		}
		
		public function getOppositeDir(dir:uint):uint {
			if (dir == UP) {
				return DOWN;
			} else if (dir == DOWN) {
				return UP;
			} else if (dir == RIGHT) {
				return LEFT;
			} else {
				return RIGHT;
			}
		}
		
		public function toString():String {
			return "(" + loc.x + "," + loc.y + ")" + dirToString(dir);
		}
		public function dirToString(dir:uint):String {
			var out:String = "?";
			switch (dir) {
				case UP: 
					out = "U";
					break;
				case DOWN: 
					out = "D";
					break;
				case RIGHT: 
					out = "R";
					break;
				case LEFT: 
					out = "L";
					break;
			}
			return out;
		}
	}

}