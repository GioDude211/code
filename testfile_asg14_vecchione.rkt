#lang racket/gui

(require racket/draw)
(require colors)


(define imageWidth 2048)
(define imageHeight 1152)
; variable to keep track of the polygons drawn
(define numPoly 0)

; Create a new bitmap of size 2048 x 1152
(define my-bitmap (make-bitmap imageWidth imageHeight))
; Create a drawing context for the bitmap
(define my-dc (new bitmap-dc% [bitmap my-bitmap]))

; Set the brush and pen for the drawing context
(define my-pen (make-pen #:color "white" #:width 1))
(define my-brush (make-brush #:color "purple"))

(send my-dc set-pen my-pen)
(send my-dc set-brush my-brush)

(send my-dc draw-rectangle 0 0 imageHeight imageWidth)

(define (draw-branch my-dc x y length angle depth)
  (when (> depth 0)
    (define x2 (+ x (* length (cos angle))))
    (define y2 (+ y (* length (sin angle))))
    (send my-dc draw-line x y x2 y2)
    (draw-branch my-dc x2 y2 (* length 0.7) (+ angle (/ pi 4)) (- depth 1))
    (draw-branch my-dc x2 y2 (* length 0.7) (- angle (/ pi 4)) (- depth 1))))

(define (draw-tree)
  (define frame  (new frame% [label "Fractal Drawing"]
                          [width imageWidth]
                          [height imageHeight]))
                          
  (define canvas (new canvas% [parent frame]
                     [paint-callback
                      (λ (canvas my-dc)
                        (draw-branch my-dc 200 400 100 (- (/ pi 2)) 10))]))
  (send frame show #t))

(draw-tree)

(display "Number of polygons drawn: ")
(display numPoly)
(newline)

;ATTEMPTED SCALING GRID, needless to say without knowing a way to draw its pointless
#|
; Let's assume the world size is 20x20
(define worldWidth 20)
(define worldHeight 20)

; Calculate scale factors
(define xScale (/ imageWidth worldWidth))
(define yScale (/ imageHeight worldHeight))

; Conversion function from world to screen coordinates
(define (world-to-screen wx wy)
  (let ((sx (+ (* wx xScale) (/ imageWidth 2)))
        (sy (- (/ imageHeight 2) (* wy yScale))))
    (values sx sy)))

; Conversion function from screen to world coordinates
(define (screen-to-world sx sy)
  (let ((wx (/ (- sx (/ imageWidth 2)) xScale))
        (wy (/ (- (/ imageHeight 2) sy) yScale)))
    (values wx wy)))
  
;NOTE: wx and wy are world, while sx and sy are screen



; DUPLICATE POLYGON FUNCTION
(define (duplicatePolygon inputPolygon)
  (let ((newPolygon (new dc-path%))) ; create a new polygon
    ; Add the same points to the new polygon
    (send newPolygon move-to 0 0) ; input points (works like x-axis and y-axis)
    (send newPolygon line-to 50 0)
    (send newPolygon line-to 50 100)
    (send newPolygon line-to 0 100)
    (send newPolygon close)
    newPolygon)) ; return the new polygon

;Possible revision of duplicate polygon and drawToScreen
; Polygon points instead of lines
(define polygon-points '((0 0) (50 0) (50 100) (0 100)))

; Function to create a polygon from a list of points
(define (createPolygon points)
  (let ((path (new dc-path%)))
    (for ([pt (in-list points)])
      (match-define (list x y) pt)
      (if (equal? pt (first points))
          (send path move-to x y)
          (send path line-to x y)))
    (send path close)
    path))

; Function to draw the polygon
(define (drawToScreen polygon x2 y2)
  ; Create a new temporary polygon for drawing
  (define tempPolygon (createPolygon polygon-points))
  (send tempPolygon translate x2 y2) ; Translate
  ; Set the brush and pen for the drawing context
  (send my-dc set-pen "white" 2 'solid)
  (send my-dc set-brush "purple" 'solid)
  ; Draw the translated polygon
  (send my-dc draw-path tempPolygon))

; Use createPolygon to create your initial polygon
(define myPolygon (createPolygon polygon-points))


;THIS ENDED UP WORKING WELL--------

;drawToScreen FUNCTION -NOTHING WRONG HERE
(define (drawToScreen dc myPolygon)
  (let ([xTrans 800]
        [yTrans 800]
        [xScale .15]
        [yScale .15])
    ; Convert the polygon to screen coordinates
    (send myPolygon scale xScale yScale)
    (send myPolygon translate xTrans yTrans)
    
    ; Draw the polygon in screen coordinates
    (send dc set-pen "black" 2 'solid) ; set the line color 
    (send dc set-brush (make-color 25 22 16) 'solid) ; set color for filling
    (send dc draw-path myPolygon)
    
    ; Convert the polygon back to world coordinates
    (send myPolygon translate (- xTrans) (- yTrans))
    (send myPolygon scale (/ 1.0 xScale) (/ 1.0 yScale))))

    
|#