import scala.io.Source
import scala.collection.mutable.HashMap
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
  var blocked = false
  if (coord == BEGIN && direction != "down") {var blocked = true}
  if (coord == END) {ended = true} else {ended = false}
  var choice = false

  def compare(that: Myself)={that.steps compare this.steps}

  def canGoTo(): List[String] = {
    if (ended) { return List() }
    var symAbove, symUnder, symRight, symLeft: Char = '#'
    if (x-1 >= 0)     { symAbove = trailMap(x-1)(y) }
    if (x+1 < HEIGHT) { symUnder = trailMap(x+1)(y) }
    if (y+1 < WIDTH)  { symRight = trailMap(x)(y+1) }
    if (y-1 >= 0)     { symLeft  = trailMap(x)(y-1) }
    var directions = List[String]()
    if (symAbove != '#' && symAbove != 'v') { if (direction != "down")  { directions = directions :+ "up" } }
    if (symLeft  != '#' && symLeft != '>')  { if (direction != "right") { directions = directions :+ "left" } }
    if (symUnder != '#') { if (direction != "up")   { directions = directions :+ "down" } }
    if (symRight != '#') { if (direction != "left") { directions = directions :+ "right" } }
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
    }
  }
}

def hike(me: Myself): Unit = {
  while (me.ended != true && me.blocked != true) {
    me.move()
    if (me.ended == true) { pathSteps = pathSteps :+ me.steps }
    else if (me.choice == true) {
      for (possibleDir <- me.canGoTo()) {
        hike(new Myself(coord=me.coord,direction=possibleDir,steps=me.steps,force=true))
      }
      return
    }
  }
  if (me.ended == true) { pathSteps = pathSteps :+ me.steps }
}

var pathSteps: List[Int] = List()
hike(new Myself(BEGIN,"down"))
println(pathSteps.max)
