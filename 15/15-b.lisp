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
  (char-code (char letter 0)))

(defun hash-algo (current-value char-in-read)
    (mod (* (+ current-value (char-to-ascii-dec char-in-read)) 17) 256))

(defun iterate-single-step (S sum)
  (loop for c across S
	do
	(setq sum (hash-algo sum (string c))))
  sum)

(defun iterate-through-all-steps (steps sum)
  (loop for x in steps
	do
	( incf sum (iterate-single-step x sum) ))
  sum)

(defun is-equal-op (label)
  (search "=" label))

(defun equal-op (label box-number)
  (multiple-value-bind (val status) (gethash box-number *boxes*)
    (if status
      (if (not (member label val :test #'equal))
        (setf (gethash box-number *boxes*) (reverse (cons label (reverse val)))))
      (setf (gethash box-number *boxes*) (list label)))))

(defun dash-op (label box-number)
  (multiple-value-bind (val status) (gethash box-number *boxes*)
    (if status
      (if (member label val :test #'equal)
	(setf (gethash box-number *boxes*) (delete label val :test #'equal))))))

(defun extract-details (S)
  (if (is-equal-op S)
    ( progn
      (setq label (first (split-content S #\=)))
      (setq focal-length (parse-integer (first (rest (split-content S #\=)))))
      (setf (gethash label *lenses*) focal-length))
    ( progn
      (setq label (first (split-content S #\-)))
      (setq focal-length -1)))
  (setq label-value (iterate-single-step label 0))
  (list label label-value focal-length))

(defun place-lenses (steps)
  (loop for x in steps
	do
	(setq details (extract-details x))
	(if (is-equal-op x)
	  (equal-op label label-value)
	  (dash-op label label-value))))

(defun compute (boxes lenses)
  (setq whole-sum 0)
  (loop for box-number being the hash-keys of boxes collect box-number
	do
	(setq i 1)
	(setq lenses (gethash box-number boxes))
	(if (not (eq 'NIL lenses))
	  (progn
	    (loop for lense in lenses
		  do
		  (setq lense-slot-number i)
		  (setq focal-length (gethash lense *lenses*))
		  (setq i (+ i 1))
		  (setq whole-sum (+ whole-sum (* (+ box-number 1) (* lense-slot-number focal-length))))))))
   (write whole-sum))

(setf content (first (read-file "./assets/15.txt")))
(setq all-steps (split-content content #\,))

(defparameter *lenses* (make-hash-table :test #'equal))
(defparameter *boxes* (make-hash-table :test #'equal))

(place-lenses all-steps)
(compute *boxes* *lenses*)
