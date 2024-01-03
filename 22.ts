import * as fs from 'fs';
const content = fs.readFileSync('./assets/22.txt', 'utf-8').split("\n");

class Brick {
	name: string;
	x: [number,number]; y: [number,number]; z: [number,number];
	x0: number; x1: number; y0: number; y1: number; z0: number; z1: number;
	aboveNeighbour: Brick[]; belowNeighbour: Brick[];
	removable: boolean; falling: boolean;
	constructor(cx:[number,number],cy:[number,number],cz:[number,number]) {
		this.name = "";
		this.x = cx
		this.y = cy;
		this.z = cz;
		[this.x0, this.x1] = this.x;
		[this.y0, this.y1] = this.y;
		[this.z0, this.z1] = this.z;
		this.aboveNeighbour = []; this.belowNeighbour = [];
		this.removable = true; this.falling = false;
	}

	goDown() {
		this.z = [this.z0-1,this.z1-1];
		[this.z0,this.z1] = this.z;
	}
	canGoDown() {
		let cannot: boolean = false;
		for (let y = this.y0; y < this.y1 + 1; y++) {
			for (let x = this.x0; x < this.x1 + 1; x++) {
				if (MAP_XYZ[x][y][this.z0-1] == 'x') {return false;};
				if (MAP_XYZ[x][y][this.z0-1].length != 0 && ! this.belowNeighbour.includes(MAP_XYZ[x][y][this.z0-1])) {
					this.belowNeighbour.push(MAP_XYZ[x][y][this.z0-1]);
					if (! MAP_XYZ[x][y][this.z0-1].aboveNeighbour.includes(this)) {
						MAP_XYZ[x][y][this.z0-1].aboveNeighbour.push(this);
					}
					cannot = true;
				}
			}
		}
		if (cannot) {return false;}
		return true;
	}
	placeTheLowest() {
		while (this.canGoDown()) {this.goDown()}
		this.placeOnXYZ();
		this.saveInBrickMap();
	}
	saveInBrickMap() {
		BRICK_MAP.set(this.name,this);
	}
	placeOnXYZ() {
		for (let z = this.z0; z < this.z1 + 1; z++) {
			for (let y = this.y0; y < this.y1 + 1; y++) {
				for (let x = this.x0; x < this.x1 + 1; x++) {
					MAP_XYZ[x][y][z] = this;
				}
			}
		}
	}
}

let BRICKS: Brick[] = [];
content.forEach ( line => {
	if (line == "") {return;}
	let [X,Y]: string[] = line.split("~");
	let [x0,y0,z0]: string[] = X.split(",");
	let [x1,y1,z1]: string[] = Y.split(",");
	let x: [number,number] = [parseInt(x0),parseInt(x1)];
	let y: [number,number] = [parseInt(y0),parseInt(y1)];
	let z: [number,number] = [parseInt(z0),parseInt(z1)];
	BRICKS.push(new Brick(x,y,z));
});

// Sort bricks by Z (ascending)
BRICKS.sort((a,b) => Math.min(...a.z) - Math.min(...b.z));

for (let i = 0; i < BRICKS.length; i++) { BRICKS[i].name = i.toString() }

let HEIGHT : number = 335;
let WIDTH_X: number = 10;
let WIDTH_Y: number = 10;
let BRICK_MAP = new Map<string,Brick>();
let MAP_XYZ: any[][][] = [];
for (let x = 0; x < WIDTH_X; x++) {
	MAP_XYZ[x] = []
	for (let y = 0; y < WIDTH_Y; y++) {
		MAP_XYZ[x][y] = []
		for (let z = 0; z < HEIGHT; z++) {
			MAP_XYZ[x][y][z] = [];
		}
	}
}
for (let x = 0; x < WIDTH_X; x++) {
	for (let y = 0; y < WIDTH_Y; y++) {
		MAP_XYZ[x][y][0] = ['x'];
	}
}

BRICKS.forEach( brick => { brick.placeTheLowest() });

BRICKS.forEach( brick => {
	brick.aboveNeighbour.forEach( (above) => {
		if (above.belowNeighbour.length == 1) {
			brick.removable = false;
		}
	})
})

let c: number = 0;
BRICKS.forEach( brick => {
	if (brick.removable == true) {
		c+=1;
	};
})

console.log(c);
