(def filepath "./assets/18.txt")

(defn read-file [filepath]
  (clojure.string/split (slurp filepath) #"\n"))

(defn content-to-list [content]
  (let [counter (atom 0)]
  (->> content
       (map #(clojure.string/split % #" "))
       (map (fn [[d s c]]
             [d (Integer/parseInt s) c ]))
       (into ()))))

(def content
  (content-to-list
  (read-file filepath)))

(def estimated-size 500)

(def dig-map
  (make-array Character/TYPE estimated-size estimated-size))

(def copy-map
  (make-array Character/TYPE estimated-size estimated-size))

(aset dig-map (/ estimated-size 2) (/ estimated-size 2) \#)

(defn dig [x y direction steps]
  (doseq [i (range 1 (+ 1 steps))]
    (if (= "U" direction) (aset dig-map (- x i) y \#))
    (if (= "D" direction) (aset dig-map (+ x i) y \#))
    (if (= "L" direction) (aset dig-map x (- y i) \#))
    (if (= "R" direction) (aset dig-map x (+ y i) \#))
    )
  (if (= "U" direction) (def start [(- x steps) y]))
  (if (= "D" direction) (def start [(+ x steps) y]))
  (if (= "L" direction) (def start [x (- y steps)]))
  (if (= "R" direction) (def start [x (+ y steps)]))
  start)

(defn has-two-neighbours [x y]
  (def n 0)
  (if (= \# (aget dig-map (- x 1) y)) (def n (+ n 1)))
  (if (= \# (aget dig-map (+ x 1) y)) (def n (+ n 1)))
  (if (= \# (aget dig-map x (+ y 1))) (def n (+ n 1)))
  (if (= \# (aget dig-map x (- y 1))) (def n (+ n 1)))
  (def sym \#)
  (if (= 2 n)
    (do
    (if (= \# (aget dig-map (- x 1) y))
      (do
      (if (= \# (aget dig-map x (- y 1))) (def sym \J))
      (if (= \# (aget dig-map x (+ y 1))) (def sym \L))
      (if (= \# (aget dig-map (+ x 1) y )) (def sym \|))))
    (if (= \# (aget dig-map (+ x 1) y))
      (do
      (if (= \# (aget dig-map x (- y 1))) (def sym \7))
      (if (= \# (aget dig-map x (+ y 1))) (def sym \F))))
    (if (= \# (aget dig-map x (- y 1)))
      (if (= \# (aget dig-map x (+ y 1))) (def sym \-)))
    (aset copy-map x y sym))))

(def start [(quot estimated-size 2) (quot estimated-size 2)])

(doseq [item content]
  (def start (dig (nth start 0) (nth start 1) (nth item 0) (nth item 1))))

(doseq [i (range 1 (- estimated-size 1))
      j (range 1 (- estimated-size 1))]
  (if (= \# (aget dig-map i j)) (has-two-neighbours i j)))

(def counter 0)
(doseq [row copy-map]
  (def digging false)
  (def substate \ )
  (doseq [cell row]
    (cond
      (= cell \-) (def counter (+ 1 counter))
      (= cell \|) (do (def counter (+ 1 counter)) (def digging (not digging)))
      (= cell \L) (do (def counter (+ 1 counter)) (def digging (not digging)) (def substate \L))
      (= cell \F) (do (def counter (+ 1 counter)) (def digging (not digging)) (def substate \F))
      (= cell \J) (do (def counter (+ 1 counter)) (if (= \L substate) (def digging (not digging))))
      (= cell \7) (do (def counter (+ 1 counter)) (if (= \F substate) (def digging (not digging))))
      (= cell \u0000) (if (true? digging) (def counter (+ 1 counter))))))
(println counter)
