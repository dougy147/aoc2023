(def filepath "./assets/18.txt")

(defn read-file [filepath]
  (clojure.string/split (slurp filepath) #"\n"))

(defn content-to-list [content]
  (let [counter (atom 0)]
  (->> content
       (map #(clojure.string/split % #" "))
       (map (fn [[d s c]]
             {:direction (case (subs c (- (count c) 2) (- (count c) 1)) "0" "R" "1" "D" "2" "L" "3" "U")
              :steps (read-string (str "0x" (subs c 2 (- (count c) 2))))
              :color c }))
       (into ()))))

(def instructions
  (content-to-list
  (read-file filepath)))

(def dig-map [])
(defn build-map [instructions]
  (def start [0 0])
  (doseq [inst instructions]
    ;(println inst)
    (def x (nth start 0))
    (def y (nth start 1))
    (let [new-inst (case (inst :direction)
      "R" {:x x :y (+ y (inst :steps))}
      "L" {:x x :y (- y (inst :steps))}
      "D" {:x (+ x (inst :steps)) :y y}
      "U" {:x (- x (inst :steps)) :y y}
      )]
      (do
        (def dig-map (conj dig-map new-inst))
        (def start [(new-inst :x) (new-inst :y)])))))

(build-map instructions)

(defn get-perimeter [instructions]
  (->> instructions
       (map :steps)
       (reduce +)))
(def perimeter (get-perimeter instructions))

(defn compute-ab [instr1 instr2]
  (def xayb (* (instr1 :x) (instr2 :y)))
  (def xbya (* (instr2 :x) (instr1 :y)))
  (def res (- xayb xbya))
  res)

(defn get-area [dig-map]
  (def a 0) ; area
  (doseq [i (range (count dig-map))]
    (if (= i (- (count dig-map) 1))
      (def a (+ a (compute-ab (nth dig-map i) (nth dig-map 0))))
      (def a (+ a (compute-ab (nth dig-map i) (nth dig-map (+ i 1)))))))
  (def a (/ a 2))
  (abs a))

(def area (get-area dig-map))

; Using Pick's theorem
(def i (- (- (- (/ perimeter 2) 1) area)))
(def number-of-holes (+ i perimeter))
(println number-of-holes)
