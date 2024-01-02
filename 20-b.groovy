String filepath = "./assets/20.txt"

List readFile(String filepath) {
  def content = []
  File file = new File(filepath)
  file.withReader { reader ->
    while ((line = reader.readLine()) != null) {
      content.add([line.replaceAll("\n","")])
    }
  }
  return content
}

String identifyLabel(String label) {
  if (flipflopsLabels.containsKey(label)) {
    return "Flipflop"
  } else if (conjunctionsLabels.containsKey(label)) {
    return "Conjunction"
  } else {
    return "Untyped"
  }
}

def initializeOutputsForAll() {
  conjunctionsList.each { conj ->
    conj.setOutputs(conjunctions)
  }
  flipflopsList.each { flip ->
    flip.setOutputs(flipflops)
  }
}

def initializeInputsForAllConjunctions() {
  conjunctionsList.each { conj ->
    conj.setInputs(broadcastLabels,flipflops,flipflopsLabels,conjunctionsLabels)
  }
}

void setFlipflopOrConj(String label, String t) {
  if (t == "F") {
    T = new Flipflop(label)
    flipflopsList.add(T)
    }
  if (t == "C") {
    T = new Conjunction(label)
    conjunctionsList.add(T)
    }
  if (t == "U") {
    T = new Untyped(label)
    }
  for (int i in 0..broadcast.size()) { if (broadcast[i] == label) { broadcast[i] = T } }
  for (k in flipflopsLabels.keySet()) {
    for (int i in 0..flipflopsLabels[k].size()) {
      if (flipflopsLabels[k][i] == label) {flipflops[k][i] = T}
    }
  }
  for (k in conjunctionsLabels.keySet()) {
    for (int i in 0..conjunctionsLabels[k].size()) {
      if (conjunctionsLabels[k][i] == label) {conjunctions[k][i] = T}
    }
  }
}

void populateHashmaps(List content) {
  List labels = []
  content.each { line ->
    line = line[0].split(" -> ")
    String identifier = line[0]
    List rest = line[1].split(", ")
    if (identifier[0] == '%') {
      flipflopsLabels[identifier[1..identifier.size()-1]] = rest
    } else if (identifier[0] == '&') {
      conjunctionsLabels[identifier[1..identifier.size()-1]] = rest
    } else {
      broadcastLabels = rest
      rest.each { r ->
	broadcast.add(r)
      }
    }
    if (! labels.contains(identifier[1..identifier.size()-1]) && identifier != "broadcaster") {
      labels.add(identifier[1..identifier.size()-1])
    }
    rest.each { lab ->
      if (! labels.contains(lab)) {labels.add(lab)}
    }
  }
  for (k in flipflopsLabels.keySet()) {
    flipflops[k] = (1..flipflopsLabels[k].size()).collect { [] }
  }
  for (k in conjunctionsLabels.keySet()) {
    conjunctions[k] = (1..conjunctionsLabels[k].size()).collect { [] }
  }
  labels.each { l ->
    if      (identifyLabel(l) == "Flipflop")    {setFlipflopOrConj(l,"F")}
    else if (identifyLabel(l) == "Conjunction") {setFlipflopOrConj(l,"C")}
    else if (identifyLabel(l) == "Untyped")     {setFlipflopOrConj(l,"U")}
  }
}

class Flipflop {
   String label
   int state = 0
   def toSendNext = null
   boolean blocked = false
   List outputs = []

   Flipflop(String label) {
    this.label = label
   }

   void setOutputs(flipflops) {
    for (o in flipflops[this.label]) {
      this.outputs.add(o)
    }
   }

   void flip() {
    if (this.state == 0) { this.state = 1 }
    else if (this.state == 1) {this.state = 0}
   }

   void send() {
       for (output in this.outputs) {
	output.receive(this.label,this.toSendNext)
       }
   }

   void receive(String INPUT_LABEL, int RECEIVED) {
    if (RECEIVED == 1) {
      this.blocked = true
      return
    }
    if (this.state == 0) {
      this.blocked = false
      flip()
      this.toSendNext = 1
    } else {
      this.blocked = false
      flip()
      this.toSendNext = 0
    }
   }
}

class Conjunction {
   String label
   def toSendNext = null
   boolean blocked = false
   def inputs = [:]
   def outputs = []

   Conjunction(String label) {
    this.label = label
   }

   void setInputs(broadcastLabels,flipflops,flipflopsLabels,conjunctionsLabels) {
    for (int i in 0..broadcastLabels.size()-1) {
      if (broadcastLabels[i] == this.label) {
        this.inputs[broadcastLabels[i]] = 0
      }
    }
    for (k in flipflops.keySet()) {
      for (l in 0..flipflopsLabels[k].size()-1) {
        if (flipflopsLabels[k][l] == this.label) {
  	this.inputs[k] = 0
        }
      }
    }
    for (k in conjunctionsLabels.keySet()) {
      for (l in 0..conjunctionsLabels[k].size()-1) {
        if (conjunctionsLabels[k][l] == this.label) {
  	this.inputs[k] = 0
        }
      }
    }
   }

   void setOutputs(conjunctions) {
    for (output in conjunctions[this.label]) {
      this.outputs.add(output)
    }
   }

   void send() {
    for (output in this.outputs) {
      output.receive(this.label,this.toSendNext)
    }
   }

   void receive(String INPUT_LABEL, int RECEIVED) {
    this.inputs[INPUT_LABEL] = RECEIVED
    for (k in this.inputs.keySet()) {
      if (this.inputs[k] == 0) {
	this.toSendNext = 1
	return
      }
    }
    this.toSendNext = 0
   }
}

class Untyped {
   String label
   def toSendNext = null
   boolean blocked = true

   Untyped(String label) {
    this.label = label
    }

   void receive(String INPUT_LABEL, int RECEIVED) { }
}

def getConjunctionInputs(label) {
  inputs = [:]
  for (int i in 0..broadcastLabels.size()) {
    if (broadcastLabels[i] == label) {
      inputs[broadcastLabels[i]] = 0
    }
  }
  for (k in flipflops.keySet()) {
    for (l in 0..flipflopsLabels[k].size()) {
      if (flipflopsLabels[k][l] == label) {
	inputs[k] = 0
      }
    }
  }
  for (k in conjunctionsLabels.keySet()) {
    for (l in 0..conjunctionsLabels[k].size()) {
      if (conjunctionsLabels[k][l] == label) {
	inputs[k] = 0
      }
    }
  }
  return inputs
}

void push(currentOutput) {
  toProcessNext = []
  for (elem in broadcast) {
    elem.receive("broadcast",0)
    if (elem.blocked != true) {
      toProcessNext.add(elem)
    }
  }
  while (toProcessNext != []) {
    todo = toProcessNext.pop()
    todo.send()
    for (o in todo.outputs) {
      for (neededInput in depenciesInputs[currentOutput]) {
	if (todo.label == neededInput && todo.toSendNext == 1 && o.label == currentOutput) {
	  if (! cycling.containsKey(neededInput)) {
	    cycling[neededInput] = iterations
	  }
	}
      }
      if (o.blocked == false) {
	toProcessNext.add(o)
      }
    }
  }
}

flipflops           = [:]
conjunctions        = [:]
broadcast           = []
broadcastLabels    = []
flipflopsList      = []
flipflopsLabels    = [:]
conjunctionsList   = []
conjunctionsLabels = [:]

populateHashmaps(readFile(filepath))
initializeInputsForAllConjunctions()
initializeOutputsForAll()

// Modules 'rx' depends on :
modules = []
for (k in flipflops.keySet())    { for (output in flipflops[k])    { if (output.label == "rx") { modules.add(k) } } }
for (k in conjunctions.keySet()) { for (output in conjunctions[k]) { if (output.label == "rx") { modules.add(k) } } }

depenciesInputs = [:]
nbInputsNeeded = 0
for (m in modules) {
  depenciesInputs[m] = []
  for (k in flipflops.keySet())    { for (input in flipflops[k])    { if (input.label == m) { depenciesInputs[m].add(k); nbInputsNeeded+=1 } } }
  for (k in conjunctions.keySet()) { for (input in conjunctions[k]) { if (input.label == m) { depenciesInputs[m].add(k); nbInputsNeeded+=1 } } }
} // Fortunately, there's only one dependency for 'rx' and it is a Conjunction ('gf')

cycling = [:]

for (k in depenciesInputs.keySet()) {
  iterations = 1
  while (cycling.size() != nbInputsNeeded) {
    push(k)
    iterations += 1
  }
}

// Luckily again, all numbers are prime (we don't have to compute the lowest common div)
BigInteger mult = 1
for (k in cycling.keySet()) { mult *= cycling[k] }
print(mult)
