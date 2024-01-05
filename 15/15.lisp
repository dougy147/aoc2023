(defun read-file (filename)
  (with-open-file (stream filename)
    (loop for line = (read-line stream nil)
	  while line collect line)))


(defun split-content (string delimitor)
  (loop for i = 0 then (1+ j)
	as j = (position delimitor string :start i)
	collect (subseq string i j)
	while j))

(defun char-to-ascii-dec (letter)
  (char-code letter))

(defun hash-algo (current-value char-value)
    (mod (* (+ current-value char-value) 17) 256))

(defun iterate-single-step (S sum)
  (loop for c across S
	do
	(setq sum (hash-algo sum (char-to-ascii-dec c))))
  sum)

(defun iterate-through-all-steps (steps)
  (setq sum 0)
  (loop for step in steps
	do
	(setq step-val (iterate-single-step step 0))
	( incf sum step-val))
  sum)

(setf content (first (read-file "./assets/15.txt")))
(setq all-steps (split-content content #\,))

(write (iterate-through-all-steps all-steps))
