using System;
using System.IO;
using System.Linq;
using System.Collections.Generic;

namespace puzzle16 {
	class AoC {
		static public object[][] contraptionMap;
		static public int width;
		static public int height;
		static public Dictionary<(int,int),List<string>> energized;

		static object[][] readInput(string filepath) {
			string[] lines = File.ReadAllLines(filepath);
			height = lines.Length;
			width  = lines[0].Length;
			object[][] content = new object[lines.Length][];
			for (int i = 0; i < lines.Length; i++) {
				object[] line = new object[lines[i].Length];
				int index = 0;
				foreach (char c in lines[i]) {
					line[index] = c;
					index+=1;
				}
				content[i] = line;
			}
			return content;
		}

		static bool isOnGrid(Beam beam) {
			if (beam.coordinates.Item1 < 0 || beam.coordinates.Item1 >= height) {return false;}
			if (beam.coordinates.Item2 < 0 || beam.coordinates.Item2 >= width) {return false;}
			return true;
		}

		static bool isMirror((int,int) coordinates) {
			if (contraptionMap[coordinates.Item1][coordinates.Item2].ToString() == ".") {
				return false;
			}
			return true;
		}

		static void travelOnContraption(Beam beam) {
			while (isOnGrid(beam)) {
				if (energized.ContainsKey(beam.coordinates)) {
					if (energized[beam.coordinates].Contains(beam.direction)) {
						break;
					} else {
						energized[beam.coordinates].Add(beam.direction);
					}
				} else {
					List<string> populate = new List<string>();
					populate.Add(beam.direction);
					energized[beam.coordinates] = populate;
				}
				if (isMirror(beam.coordinates)) {
					Mirror currentMirror = new Mirror(beam.coordinates,beam.direction);
					List<((int,int),string)> currentReflections = currentMirror.reflections;
					foreach (var reflection in currentReflections ) {
						Beam new_beam = new Beam(reflection.Item1, reflection.Item2);
						travelOnContraption(new_beam);
					}
				} else {
					beam.move();
				}
			}
		}

		static void Main(string[] args) {
			string filepath = "./assets/16.txt";
			contraptionMap = readInput(filepath);
			List<int> result = new List<int>();

			// Lazy thinking...
			for (int i = 0; i < width; i++) { // Top edge
				energized = new Dictionary<(int,int),List<string>>();
				Beam initBeam = new Beam((0,i),"down");
				travelOnContraption(initBeam);
				result.Add(energized.Count);
			}
			for (int i = 0; i < width; i++) { // Bottom
				energized = new Dictionary<(int,int),List<string>>();
				Beam initBeam = new Beam((height-1,i),"up");
				travelOnContraption(initBeam);
				result.Add(energized.Count);
			}
			for (int i = 0; i < width; i++) { // Left
				energized = new Dictionary<(int,int),List<string>>();
				Beam initBeam = new Beam((i,0),"right");
				travelOnContraption(initBeam);
				result.Add(energized.Count);
			}
			for (int i = 0; i < width; i++) { // Right
				energized = new Dictionary<(int,int),List<string>>();
				Beam initBeam = new Beam((i,0),"left");
				travelOnContraption(initBeam);
				result.Add(energized.Count);
			}
			Console.WriteLine(result.Max());
		}
	}

	public class Map {
		public object[][] contraption {get;private set;}
		public Map(object[][] contraptionMap) {
			this.contraption = contraptionMap;
		}
	}

	public class Beam {
		// Properties
		public string direction { get; private set; }
		public (int,int) coordinates { get; private set; }

		// Constructor
		public Beam((int,int) coordinates, string direction) {
			this.direction = direction;
			this.coordinates = coordinates;
		}

		public void move() {
			if (this.direction == "right") {
				this.coordinates = (this.coordinates.Item1,this.coordinates.Item2 + 1);
			} else if (this.direction == "left") {
				this.coordinates = (this.coordinates.Item1,this.coordinates.Item2 - 1);
			} else if (this.direction == "down") {
				this.coordinates = (this.coordinates.Item1 + 1,this.coordinates.Item2);
			} else if (this.direction == "up") {
				this.coordinates = (this.coordinates.Item1 - 1,this.coordinates.Item2);
			}
		}
	}

	public class Mirror {
		public (int,int) coordinates {get;private set;}
		public string symbol {get;private set;}
		public string directionOfHitSource {get;private set;}
		public List<((int,int),string)> reflections {get;private set;}

		public Mirror((int,int) coordinates, string directionOfHitSource) {
			this.directionOfHitSource = directionOfHitSource;
			this.coordinates = coordinates;
			this.symbol = AoC.contraptionMap[this.coordinates.Item1][this.coordinates.Item2].ToString();
			this.reflections = reflectsTo(this.symbol,this.directionOfHitSource);
		}

		public List<((int,int),string)> reflectsTo(string symbol,string directionOfHitSource) {
			var reflections = new List<((int,int),string)>();
			if (symbol == "/") {
				if (directionOfHitSource == "down") {
					reflections.Add(((this.coordinates.Item1,this.coordinates.Item2 - 1),"left"));
				} else if (directionOfHitSource == "up") {
					reflections.Add(((this.coordinates.Item1,this.coordinates.Item2 + 1),"right"));
				} else {
					if (directionOfHitSource == "right") {
						reflections.Add(((this.coordinates.Item1 - 1,this.coordinates.Item2),"up"));
					} else if (directionOfHitSource == "left")  {
						reflections.Add(((this.coordinates.Item1 + 1,this.coordinates.Item2),"down"));
					}
				}
			} else if (symbol == "\\") {
				if (directionOfHitSource == "down") {
					reflections.Add(((this.coordinates.Item1,this.coordinates.Item2 + 1),"right"));
				} else if (directionOfHitSource == "up") {
					reflections.Add(((this.coordinates.Item1,this.coordinates.Item2 - 1),"left"));
				} else {
					if (directionOfHitSource == "right") {
						reflections.Add(((this.coordinates.Item1 + 1,this.coordinates.Item2),"down"));
					} else if (directionOfHitSource == "left")  {
						reflections.Add(((this.coordinates.Item1 - 1,this.coordinates.Item2),"up"));
					}
				}
			} else if (symbol == "-") {
				if (directionOfHitSource == "down" || directionOfHitSource == "up") {
					reflections.Add(((this.coordinates.Item1,this.coordinates.Item2 - 1),"left"));
					reflections.Add(((this.coordinates.Item1,this.coordinates.Item2 + 1),"right"));
				} else {
					if (directionOfHitSource == "right") {
						reflections.Add(((this.coordinates.Item1,this.coordinates.Item2 + 1),"right"));
					} else if (directionOfHitSource == "left")  {
						reflections.Add(((this.coordinates.Item1,this.coordinates.Item2 - 1),"left"));
					}
				}
			} else if (symbol == "|") {
				if (directionOfHitSource == "down") {
					reflections.Add(((this.coordinates.Item1 + 1,this.coordinates.Item2),"down"));
				} else if (directionOfHitSource == "up") {
					reflections.Add(((this.coordinates.Item1 - 1,this.coordinates.Item2),"up"));
				} else {
					reflections.Add(((this.coordinates.Item1 - 1,this.coordinates.Item2),"up"));
					reflections.Add(((this.coordinates.Item1 + 1,this.coordinates.Item2),"down"));
				}
			}
			return reflections;
		}
	}
}
