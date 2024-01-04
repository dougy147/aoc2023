import scala.io.Source
import scala.collection.mutable.HashMap
import scala.collection.mutable.HashSet
import scala.collection.mutable.PriorityQueue // PriorityQueue : https://rosettacode.org/wiki/Priority_queue#Scala

val filepath = "./assets/23.txt"
val trailMap = Source.fromFile(filepath).getLines().toArray

val HEIGHT: Int = trailMap.length
val WIDTH: Int = trailMap(0).length
val BEGIN: (Int,Int) = (0,1)
val END : (Int,Int) = (HEIGHT-1,WIDTH-2)

class Myself(var coord: (Int,Int), var direction: String, var steps: Int = 0, var lastRoundabout:(Int,Int) = BEGIN, var ended: Boolean = false, var force: Boolean = false) extends Ordered[Myself] {
  var x = coord._1
  var y = coord._2
  if (coord == END) {ended = true} else {ended = false}
  var choice = false
  var blocked = false

  def compare(that: Myself)={that.steps compare this.steps}

  def canGoTo(): List[String] = {
    if (ended) { return List() }
    var symAbove, symUnder, symRight, symLeft: Char = '#'
    if (x-1 >= 0)     { symAbove = trailMap(x-1)(y) } else {symAbove = '#'}
    if (x+1 < HEIGHT) { symUnder = trailMap(x+1)(y) } else {symUnder = '#'}
    if (y+1 < WIDTH)  { symRight = trailMap(x)(y+1) } else {symRight = '#'}
    if (y-1 >= 0)     { symLeft  = trailMap(x)(y-1) } else {symLeft  = '#'}
    var directions = List[String]()
    if (symAbove != '#') { if (direction != "down")  { directions = directions :+ "up" } }
    if (symLeft != '#')  { if (direction != "right") { directions = directions :+ "left" } }
    if (symUnder != '#') { if (direction != "up")    { directions = directions :+ "down" } }
    if (symRight != '#') { if (direction != "left")  { directions = directions :+ "right" } }
    return directions
  }

  def move(): Unit = {
    val moves = HashMap(
      "up" -> Array(-1,0),
      "down" -> Array(+1,0),
      "right" -> Array(0,+1),
      "left" -> Array(0,-1)
    )
    var canGo = canGoTo()
    choice = false
    if (canGo.length == 1) {
      x += moves(canGo(0))(0)
      y += moves(canGo(0))(1)
      coord = (x,y)
      direction = canGo(0)
      steps += 1
      if (coord == END) { ended = true }
    } else if (force == true) {
      force = false
      x += moves(direction)(0)
      y += moves(direction)(1)
      coord = (x,y)
      steps += 1
      if (coord == END) { ended = true }
    } else if (canGo.length > 1) {
      choice = true
    } else {
      blocked = true
    }
  }
}

class Node(var coord: (Int,Int)) {
  var neighbours: HashMap[Node,Int] = HashMap()
}

var VISITED: HashMap[((Int,Int),(Int,Int)),Int] = HashMap()
var q=PriorityQueue[Myself]()
q.enqueue(new Myself((0,1),"down"))
// Visit all roundabouts and store their respective distances
while (q.nonEmpty) {
  var me = q.dequeue()
  while (me.choice != true && me.ended != true && me.blocked != true) { me.move() }
  if (!me.blocked) {
    if (!VISITED.contains((me.coord,me.lastRoundabout))) {
      VISITED += ((me.coord,me.lastRoundabout) -> me.steps)
      for (way <- me.canGoTo()) {
        q.enqueue(new Myself(me.coord,way,force=true,lastRoundabout=me.coord))
      }
    }
  }
}

// Construct a map of : key = roundabout, value = map(key = neighbour_coord, value = distance)
var NODES_MAP: HashMap[(Int,Int),HashMap[(Int,Int),Int]] = HashMap()
for (key <- VISITED.keys) {
  var (dest,source) = key
  if (!NODES_MAP.contains(source)) {
    NODES_MAP += (source -> HashMap(dest -> VISITED(key)))
  } else {
    NODES_MAP(source) += (dest -> VISITED(key))
  }
  if (!NODES_MAP.contains(dest)) {
    NODES_MAP += (dest -> HashMap(source -> VISITED(key)))
  } else {
    NODES_MAP(dest) += (source -> VISITED(key))
  }
}

// Make each node an object of the class Nodes and populate it with its neighbours (as objects too)
var NODES_LIST: HashSet[Node] = new HashSet[Node]()
for (n <- NODES_MAP.keys) { NODES_LIST.add(new Node(n)) }
for (n <- NODES_LIST) {
  for (neighbour <- NODES_MAP(n.coord).keys) {
    for (n2 <- NODES_LIST) {
        if (n2.coord == neighbour) {
          n.neighbours += (n2 -> NODES_MAP(n.coord)(neighbour))
        }
    }
  }
}

var pathsLength: HashSet[Int] = HashSet[Int]()

def longestPath(NODES_LIST: HashSet[Node], start: Node, length: Int = 0,visited: Set[Node] = Set.empty): Unit = {
  // Listen to this during bruteforce : https://piped.video/watch?v=a3ww0gwEszo
  for (neigh <- start.neighbours.keys) {
    if (! visited.contains(neigh)) {
        if (neigh.coord == END) { pathsLength.add(length+neigh.neighbours(start)) }
        longestPath(NODES_LIST,start=neigh,length=length+neigh.neighbours(start),visited+start)
    }
  }
}

longestPath(NODES_LIST,NODES_LIST.find(_.coord == BEGIN).orNull)
println(pathsLength.max)
