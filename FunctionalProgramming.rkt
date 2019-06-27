;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname ccc) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp") (lib "dir.rkt" "teachpack" "htdp"))) (htdp-settings #(#t constructor repeating-decimal #t #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp") (lib "dir.rkt" "teachpack" "htdp")) #f)))
(require 2htdp/image)
(require 2htdp/universe)
(define TITLE "OYUN")
; the width of the screen
(define WIDTH 1500)
; the height of the screen
(define HEIGHT 750)
; the x-coordinate of the player
(define CENTERX (/ WIDTH 2))
; the y-coordinate of the player
(define CENTERY (/ HEIGHT 2))
; the player's starting and max health points
(define PLAYERHP 100)
; the amount of damage the player's bullets deal to enemies
(define PLAYERDAMAGE 50)
; the amout of damage the enemies' bullets deal to the player
(define ENEMYDAMAGE 10)
; the amount of damage homing enemies deal to the player if they touch him
(define ENEMYRUSHDAMAGE 25)
; the speed of the player
(define PLAYERSPEED 20)
; the speed at which enemies move
(define ENEMSPEED 10)
; the speed of the player's bullets
(define BULLETSPEED 50)
; the speed of enemy homing bullets
(define ENEMBULLETSPEED1 10)
; the speed of normal enemy bullets
(define ENEMBULLETSPEED2 20)
; the time it takes the player to reload
(define PLAYERRELOAD 5)
; the time it takes enemeis to reload
(define ENEMYRELOAD 40)
; the number of ticks that will typically pass before an enemy spawns
(define TICKSPERENEMY 14)
; the number of tocks that must typically pass before a healthpack is spawned
; the player's kills are added to this, so healthpacks will spawn less frequently
; as the player gets more kills
(define TICKSPERHEALTHPACK 100)
; the radius of the player
(define PLAYERRAD 15)
; the radius of the enemies
(define ENEMRAD 25)
; the radius of healthpacks
(define HEALTHPACKRAD 15)
; the key that moves the player up
(define UP "w")
; the key that moves the player left
(define LEFT "a")
; the key that moves the player down
(define DOWN "s")
; the key that moves the player right
(define RIGHT "d")
; the key that swaps enemies and enemy projectiles
(define SWAP " ")
; the key that pauses the game
(define PAUSE "q")
; the number of tocks for which the player will appear DAMAGECOLOR after taking damage
(define PLAYERDAMAGETIME  5)
; the number of tocks for which enemies will appear DAMAGECOLOR after taking damage
(define ENEMYDAMAGETIME 5)
; the distance from the screen enemies must be before they are deleted
(define ENEMYRANGE 500)
; the distance from the screen projectiles must be before they are deleted
(define PROJECTILERANGE 200)
; the distance from the screen healthpacks must be before they are deleted
(define HEALTHPACKRANGE 800)
; the length of the player's bullets
(define LASERLENGTH 40)
; the length of the enemies' bullets
(define BULLETLENGTH 30)
; the length of the player's gun
(define GUNLENGTH 20)
; the size of the kill count
(define KILLCOUNTSIZE 70)
; the width of the health bar
(define HEALTHBARWIDTH  50)
; the color of the background
(define BACKROUNDCOLOR 'Aqua)
; the color of the text in the menu
(define TEXTCOLOR 'DarkGreen)
; the color the player and enemies turn when they are damaged
(define DAMAGECOLOR 'Olive)
; the color of normal enemies
(define ENEMYCOLOR1 'Chocolate)
; the color of homing enemies
(define ENEMYCOLOR2 'LightPink)
; the color of the health bar
(define HEALTHBARCOLOR 'Fuchsia)
; the color of the kill count
(define KILLCOUNTCOLOR 'red)
; Number, Number, Boolean -> Image
; the image of the player. damagetime is used to determine
; if the player should be drawn normally or in DAMAGECOLOR and
; reloadtime and shooting? are used to determine if the gun
; should be drawn in the recoiled position
(define (player damagetime reloadtime shooting?) (if (> damagetime 0)
                        (underlay/xy
                        (underlay/xy
                          (circle GUNLENGTH 'solid (color 255 255 255 0))
                          (- GUNLENGTH PLAYERRAD)
                          (- GUNLENGTH PLAYERRAD)
                          (circle PLAYERRAD 'solid DAMAGECOLOR))
                         (if (and shooting? (> reloadtime 1)) (- GUNLENGTH 5) GUNLENGTH)
                         (- GUNLENGTH 3)
                         (rectangle GUNLENGTH 6 'solid DAMAGECOLOR))
                        (underlay/xy
                        (underlay/xy
                          (circle GUNLENGTH 'solid (color 255 255 255 0))
                          (- GUNLENGTH PLAYERRAD)
                          (- GUNLENGTH PLAYERRAD)
                          (circle PLAYERRAD 'solid 'RoyalBlue))
                         (if (and shooting? (> reloadtime 1)) (- GUNLENGTH 5) GUNLENGTH)
                         (- GUNLENGTH 3)
                         (rectangle GUNLENGTH 6 'solid 'black))))
; Number -> Image
; the image of the normal enemies. damagetime is used to
; determine if the enemy should be drawn normally or in
; DAMAGECOLOR
(define (enemy1 damagetime) (if (> damagetime 0)
                        (circle ENEMRAD 'solid DAMAGECOLOR)
                        (circle ENEMRAD 'solid ENEMYCOLOR1)))
; Number -> Image
; the image of the homing enemies. damagetime is used to
; determine if the enemy should be drawn normally or in
; DAMAGECOLOR
(define (enemy2 damagetime) (if (> damagetime 0)
                        (circle ENEMRAD 'solid DAMAGECOLOR)
                        (circle ENEMRAD 'solid ENEMYCOLOR2)))
; String -> Image
; fragments make up explosions. they are different colors because
; the enemies that explode are different colors
(define (fragment color)
  (triangle/sss 20 30 40 'solid color))
; specks are randomly generated tiny squares that give the
; player a feeling of movement even when nothing is on the screen
(define SPECK (square 3 'solid 'black))
; the image of player's bullets
(define LASER (underlay/xy (circle LASERLENGTH 'solid (color 255 255 255 0))
                           LASERLENGTH LASERLENGTH
                           (rectangle LASERLENGTH 6 'solid 'red)))
; the image of enemies' homing bullets
(define ENEMYBULLET1 (underlay/xy (circle BULLETLENGTH 'solid (color 255 255 255 0)) BULLETLENGTH 20
             (overlay/xy (rectangle 20 20 'solid 'DarkRed) 10 0
                         (circle 10 'solid 'FireBrick))))
; the image of enemies' normal bullets
(define ENEMYBULLET2 (underlay/xy (circle BULLETLENGTH 'solid (color 255 255 255 0)) BULLETLENGTH 20
             (overlay/xy (rectangle 20 20 'solid 'DarkGreen) 10 0
                         (circle 10 'solid 'SeaGreen))))
; the image of healthpacks
(define HEALTHPACK (overlay (rectangle HEALTHPACKRAD 5 'solid 'red)
                            (rectangle 5 HEALTHPACKRAD 'solid 'red)
                            (circle HEALTHPACKRAD 'solid 'snow)))
; the worldstate:
; dx = the negative of the player's speed in the x direction
; dy = the negative of the player's speed in the y direction
; (these are only negative for convenience: in all the "move" functions,
; they can be added to enemies' and projectiles' coordinates instead of subtracted)
; enemies = a list of lists of enemies
; projectiles = a list of lists of bullets or fragments
; specks = a list of posn's that represent specks
; healthpacks = a list of posn's that represent healthpacks
; keysdown = a list of strings of the currently pressed keys
; (only used to keep the player from accidentally starting a new game
; immediately after he dies because he is still holding keys down)
; shooting = a boolean that is true if the playing is shooting and false
; if he is not
; aimangle = a number that is the number of degrees in the angle between the player
; and his cursor. used for drawing the player and making new player bullets
; hp = a number: the player's health points
; damagetime = a number: the number of tocks for which the player will be displayed
; in DAMAGECOLOR
; reloadtime = a number; the number of tocks until the player can shoot again
; kills = the number of enemies the player has killed in the current game
; state = a number that has represents the current state of the game:
; 0 : main menu
; 1 : game is running
; 2 : game is paused
; 3 : game is over
(define-struct WS (dx dy cursor enemies projectiles specks healthpacks keysdown shooting? aimangle hp damagetime reloadtime kills state))
; projectile structure: used for fragments and all bullets
; x = the x-coordinate of the projectile
; y = the y-coordinate of the projectile
; dx = the speed of the projectile in the x direction
; dy = the speed of the projectile in the y direction
; angle = the angle of projectile's travel
; color = a string: the projectile's color
; (only used for fragments)
(define-struct PR (x y dx dy angle color))
; the enemy structure
; x = the x-coordinate of the enemy
; y = the y-coordinate of the enemy
; dx = the speed of the enemy in the x direction
; dy = the speed of the enemy in the y direction
; damagetime = the number of tocks for which the
; enemy will be drawn in DAMAGECOLOR
; reloadtime = the number of tocks until the
; enemy can shoot again
(define-struct EN (x y dx dy hp damagetime reloadtime))
; this worldstate is used both when the game is first launched and whenever
; a new game is started
(define initial-ws (make-WS 0 0 (make-posn 0 0)
                            (list empty empty)
                            (list empty (list empty empty) empty)
                            (list (make-posn (* WIDTH 0.1) (* HEIGHT 0.2))
                                  (make-posn (* WIDTH 0.2) (* HEIGHT 0.6))
                                  (make-posn (* WIDTH 0.4) (* HEIGHT 0.5))
                                  (make-posn (* WIDTH 0.7) (* HEIGHT 0.8))
                                  (make-posn (* WIDTH 0.9) (* HEIGHT 0.7))
                                  (make-posn (* WIDTH 0.3) (* HEIGHT 0.4))
                                  (make-posn (* WIDTH 0.8) (* HEIGHT 0.1))) empty empty #false 90 PLAYERHP 0 0 0 0))
; Worldstate, Number -> WorldState
; Changes the dx of the given worldstate to dx and keeps it within the range -PLAYERSPEED - PLAYERSPEED
(define (setDx ws dx) (make-WS (max (min dx PLAYERSPEED) (- PLAYERSPEED)) (WS-dy ws) (WS-cursor ws) (WS-enemies ws) (WS-projectiles ws)
                             (WS-specks ws) (WS-healthpacks ws) (WS-keysdown  ws) (WS-shooting? ws) (WS-aimangle ws)
                             (WS-hp ws) (WS-damagetime ws)  (WS-reloadtime ws) (WS-kills ws) (WS-state ws)))
; Worldstate, Number -> WorldState
; Changes the dy of the given worldstate to dy and keeps it within the range -PLAYERSPEED - PLAYERSPEED
(define (setDy ws dy) (make-WS (WS-dx ws) (max (min dy PLAYERSPEED) (- PLAYERSPEED)) (WS-cursor ws) (WS-enemies ws) (WS-projectiles ws)
                             (WS-specks ws) (WS-healthpacks ws) (WS-keysdown  ws) (WS-shooting? ws) (WS-aimangle ws)
                             (WS-hp ws) (WS-damagetime ws)  (WS-reloadtime ws) (WS-kills ws) (WS-state ws)))
; Worldstate, Posn -> WorldState
; Changes the cursor location in the given worldstate to cursor
(define (setCursor ws cursor) (make-WS (WS-dx ws) (WS-dy ws) cursor (WS-enemies ws) (WS-projectiles ws)
                           (WS-specks ws) (WS-healthpacks ws) (WS-keysdown  ws) (WS-shooting? ws) (get-angle cursor ws)
                           (WS-hp ws) (WS-damagetime ws)  (WS-reloadtime ws) (WS-kills ws) (WS-state ws)))
; Worldstate, List of List -> Worldstate
; Changes the enemies in the given worldstate to enemies
(define (setEnemies ws enemies) (make-WS (WS-dx ws) (WS-dy ws) (WS-cursor ws) enemies (WS-projectiles ws)
                           (WS-specks ws) (WS-healthpacks ws) (WS-keysdown  ws) (WS-shooting? ws) (WS-aimangle ws)
                           (WS-hp ws) (WS-damagetime ws)  (WS-reloadtime ws) (WS-kills ws) (WS-state ws)))
; Worldstate, List of List -> Worldstate
; Change the projectiles in the given worldstate to projectiles
(define (setProjectiles ws projectiles) (make-WS (WS-dx ws) (WS-dy ws) (WS-cursor ws) (WS-enemies ws) projectiles
                                                 (WS-specks ws) (WS-healthpacks ws) (WS-keysdown  ws) (WS-shooting? ws) (WS-aimangle ws)
                                                 (WS-hp ws) (WS-damagetime ws)  (WS-reloadtime ws) (WS-kills ws) (WS-state ws)))
; Worldstate, Boolean -> Worldstate
; Change the shooting? in the given worldstate to shooting
(define (setShooting ws shooting) (make-WS (WS-dx ws) (WS-dy ws) (WS-cursor ws) (WS-enemies ws) (WS-projectiles ws)
                           (WS-specks ws) (WS-healthpacks ws) (WS-keysdown  ws) shooting (WS-aimangle ws)
                           (WS-hp ws) (WS-damagetime ws)  (WS-reloadtime ws) (WS-kills ws) (WS-state ws)))
; Worldstate, List of Posn -> Worldstate
; Change the specks in the given worldstate to specks
(define (sSpecks ws specks)
  (make-WS (WS-dx ws) (WS-dy ws) (WS-cursor ws) (WS-enemies ws) (WS-projectiles ws)
           specks (WS-healthpacks ws) (WS-keysdown  ws) (WS-shooting? ws) (WS-aimangle ws)
           (WS-hp ws) (WS-damagetime ws) (WS-reloadtime ws) (WS-kills ws) (WS-state ws)))
; Worldstate, List of Posn -> Worldstate
; Change the healthpacks in the given worldstate to healthpacks
(define (setHealthpacks ws healthpacks) (make-WS (WS-dx ws) (WS-dy ws) (WS-cursor ws) (WS-enemies ws) (WS-projectiles ws)
                           (WS-specks ws) healthpacks (WS-keysdown  ws) (WS-shooting? ws) (WS-aimangle ws)
                           (WS-hp ws) (WS-damagetime ws)  (WS-reloadtime ws) (WS-kills ws) (WS-state ws)))
; Worldstate, String -> Worldstate
; Adds key to keysdown in the given worldstate if it is not already in keysdown
(define (addkeysdown ws key) (make-WS (WS-dx ws) (WS-dy ws) (WS-cursor ws) (WS-enemies ws) (WS-projectiles ws)
                           (WS-specks ws) (WS-healthpacks ws) (insert-unique key (WS-keysdown  ws)) (WS-shooting? ws) (WS-aimangle ws)
                           (WS-hp ws) (WS-damagetime ws)  (WS-reloadtime ws) (WS-kills ws) (WS-state ws)))
; Worldstate, String -> Worldstate
; Removes key from keysdown of the given worldstate
(define (removekeysdown ws key) (make-WS (WS-dx ws) (WS-dy ws) (WS-cursor ws) (WS-enemies ws) (WS-projectiles ws)
                           (WS-specks ws) (WS-healthpacks ws) (remove key (WS-keysdown  ws)) (WS-shooting? ws) (WS-aimangle ws)
                           (WS-hp ws) (WS-damagetime ws)  (WS-reloadtime ws) (WS-kills ws) (WS-state ws)))
; Worldstate, Number -> Worldstate
; Sets the hp in the given worldstate equal to hp if hp is within the range 0 - PLAYERHP
(define (setHp ws hp) (make-WS (WS-dx ws) (WS-dy ws) (WS-cursor ws) (WS-enemies ws) (WS-projectiles ws)
                             (WS-specks ws) (WS-healthpacks ws) (WS-keysdown  ws) (WS-shooting? ws) (WS-aimangle ws)
                             (min (max hp 0) PLAYERHP) (WS-damagetime ws) (WS-reloadtime ws) (WS-kills ws) (WS-state ws)))
; Worldstate, Number -> Worldstate
; Sets the damagetime of the given worldstate to damagetime and keeps it from falling below zero
(define (setDamageTime ws damagetime) (make-WS (WS-dx ws) (WS-dy ws) (WS-cursor ws) (WS-enemies ws) (WS-projectiles ws)
                             (WS-specks ws) (WS-healthpacks ws) (WS-keysdown  ws) (WS-shooting? ws) (WS-aimangle ws)
                             (WS-hp ws) (max damagetime 0) (WS-reloadtime ws) (WS-kills ws) (WS-state ws)))
; Worldstate -> Worldstate
; Sets the reloadtime of the given worldstate to PLAYERRELOAD
(define (setReloadTime ws) (make-WS (WS-dx ws) (WS-dy ws) (WS-cursor ws) (WS-enemies ws) (WS-projectiles ws)
                          (WS-specks ws) (WS-healthpacks ws) (WS-keysdown  ws) (WS-shooting? ws) (WS-aimangle ws)
                          (WS-hp ws) (WS-damagetime ws) PLAYERRELOAD (WS-kills ws) (WS-state ws)))
; Worldstate -> Worldstate
; Increases kills of the given worldstate by 1
(define (addKill ws)
  (make-WS (WS-dx ws) (WS-dy ws) (WS-cursor ws) (WS-enemies ws) (WS-projectiles ws)
           (WS-specks ws) (WS-healthpacks ws) (WS-keysdown  ws) (WS-shooting? ws) (WS-aimangle ws)
           (WS-hp ws) (WS-damagetime ws) (WS-reloadtime ws) (+ (WS-kills ws) 1) (WS-state ws)))
; Worldstate, List of List -> Worldstate
; Changes the list element of the projectiles of the given worldstate that corresponds
; to enemy projectiles to enemyprojectiles
(define (setEnemyProjectiles ws enemyprojectiles) (setProjectiles ws (list
                                                                      (first (WS-projectiles ws))
                                                                      enemyprojectiles
                                                                      (third (WS-projectiles ws)))))
; Number -> Number
; Converts the given degrees into radians
(define (rad d) (* pi (/ d 180)))
(check-within (rad 180) pi 0.01)
(check-within (rad 90) (/ pi 2) 0.01)
; Number -> Number
; Converts the given radians into degrees
(define (deg r) (* 180 (/ r pi)))
(check-within (deg pi) 180 0.01)
(check-within (deg (/ pi 2)) 90 0.01)
; Posn, Worldstate -> Number
; Return the angle between the given cursor location and the center of the screen
(define (get-angle cursor ws)
  (get-angle-helper (- (posn-x cursor) CENTERX) (- CENTERY (posn-y cursor))))
; Number, Number -> Number
; Returns the resultant angle of displacements x and y
(define (get-angle-helper x y)
  (if (= x 0) (if (positive? y) 90 270)
      (+ (deg (atan (/ y x)))
         (cond
          [(and (negative? x) (negative? y)) 180]
          [(and (positive? x) (negative? y)) 360]
          [(and (negative? x) (positive? y)) 180]
          [else 0]))))
(check-within (get-angle-helper 10 10) 45 0.01)
(check-within (get-angle-helper 10 -10) 315 0.01)
(check-within (get-angle-helper -10 10) 135 0.01)
(check-within (get-angle-helper -10 -10) 225 0.01)
; Worldstate -> Worldstate
; Sets the state of the given worldstate equal to 2, which means
; the game is paused
(define (pause ws) (make-WS (WS-dx ws) (WS-dy ws) (WS-cursor ws) (WS-enemies ws) (WS-projectiles ws)
                             (WS-specks ws) (WS-healthpacks ws) (WS-keysdown  ws) (WS-shooting? ws) (WS-aimangle ws)
                             (WS-hp ws) (WS-damagetime ws)  (WS-reloadtime ws) (WS-kills ws) 2))
; Worldstate -> Worldstate
; Sets the state of the given worldstate equal to 1, which means
; the game is running
(define (resume ws)
  (make-WS (WS-dx ws) (WS-dy ws) (WS-cursor ws) (WS-enemies ws) (WS-projectiles ws)
                             (WS-specks ws) (WS-healthpacks ws) (WS-keysdown  ws) (WS-shooting? ws) (WS-aimangle ws)
                             (WS-hp ws) (WS-damagetime ws)  (WS-reloadtime ws) (WS-kills ws) 1))
; Worldstate -> Worldstate
; Sets the state of the given worldstate equal to 3, which means
; the game is over
(define (game-over ws) (make-WS (WS-dx ws) (WS-dy ws) (WS-cursor ws) (WS-enemies ws) (WS-projectiles ws)
                             (WS-specks ws) (WS-healthpacks ws) (WS-keysdown  ws) (WS-shooting? ws) (WS-aimangle ws)
                             (WS-hp ws) (WS-damagetime ws)  (WS-reloadtime ws) (WS-kills ws) 3))
; Worldstate -> Worldstate
; Decides if and how the game state of the given worldstate should be changed
(define (play ws) (if
                   (= (length (WS-keysdown  ws)) 0)
                   (cond
                    [(= (WS-state ws) 1) ws]
                    [(= (WS-state ws) 2) (resume ws)]
                    [(= (WS-state ws) 0) (resume ws)]
                    [else initial-ws])
                   ws))
; Worldstate -> Worldstate
; Decreases the damagetime and reloadtime of the given worldstate by 1,
; but keeps them from falling below 0
(define (depreciate-player ws)
  (make-WS (WS-dx ws) (WS-dy ws) (WS-cursor ws) (WS-enemies ws) (WS-projectiles ws)
           (WS-specks ws) (WS-healthpacks ws) (WS-keysdown  ws) (WS-shooting? ws) (WS-aimangle ws)
           (WS-hp ws) (max (- (WS-damagetime ws) 1) 0) (max (- (WS-reloadtime ws) 1) 0) (WS-kills ws) (WS-state ws)))
; EN -> EN
; Decreases the damagetime and reloadtime of the given enemy by 1,
; but keeps them from falling below 0
(define (depreciate-enemy en)
  (make-EN (EN-x en) (EN-y en) (EN-dx en) (EN-dy en) (EN-hp en) (max (- (EN-damagetime en) 1) 0) (max (- (EN-reloadtime en) 1) 0)))
; String, List of String -> List of String
; Adds str to the end of los if str is not
; already  in los
(define (insert-unique str los)
  (cond
    [(empty? los) (list str)]
    [(string=? str (first los)) los]
    [else (cons (first los) (insert-unique str (rest los)))]))
(check-expect (insert-unique "hi" (list "i" "am" "video" "game")) (list "i" "am" "video" "game" "hi"))
(check-expect (insert-unique "am" (list "i" "am" "video" "game")) (list "i" "am" "video" "game"))
; Worldstate -> Worldstate
; Calls run-game if the game is running and does nothing
; if it is paused, over, or hasn't started
(define (tock ws)
  (if (= (WS-state ws) 1) (run-game ws) ws))
; Worldstate -> Worldstate
; Calls all the functions on the given worldstate
; that advance the game by 1 tick
(define (run-game ws)
  (healthpack-collisions (player-collisions (en-collisions
                      (refresh-specks
                        (delete-healthpacks (delete-en (delete-pr
                                  (move-stuff
                                   (add-healthpacks (add-enemies (reload-enemies (add-projectiles (depreciate-stuff ws))))))))))))))
; Worldstate -> Worldstate
; Decreases the reloadtimes and damagetimes of the player and all enemies by 1
(define (depreciate-stuff ws)
  (setEnemies (depreciate-player ws) (list (map depreciate-enemy (first (WS-enemies ws)))
                                           (map depreciate-enemy (second (WS-enemies ws))))))
; Worldstate -> Worldstate
; Replaces out-of-bounds specks with new ones
(define (refresh-specks ws)
  (sSpecks ws (map new-speck? (WS-specks ws))))
; Posn -> Posn
; Makes a new posn if posn speck is out of bounds
(define (new-speck? speck)
  (cond
    [(<= (posn-x speck) 0) (make-posn WIDTH (random HEIGHT))]
    [(<= (posn-y speck) 0) (make-posn (random WIDTH) HEIGHT)]
    [(>= (posn-x speck) WIDTH) (make-posn 0 (random HEIGHT))]
    [(>= (posn-y speck) HEIGHT) (make-posn (random WIDTH) 0)]
    [else speck]))
(check-expect (new-speck? (make-posn 50 50)) (make-posn 50 50))
; Worldstate, String -> Worldstate
; Changes dx or dy if movement keys are pressed,
; swaps enemies and projectiles if swap key is pressed,
; pauses the game if pause key is pressed. Adds pressed keys
; to keysdown of the given worldstate.
; (also triggers game starting and resuming if the game
; isn't already running)
(define (key-down ws a-key)
  (addkeysdown  (cond
    [(key=? a-key RIGHT) (setDx (play ws) (- (WS-dx ws) PLAYERSPEED))]
    [(key=? a-key UP)    (setDy (play ws) (+ (WS-dy ws) PLAYERSPEED))]
    [(key=? a-key LEFT)  (setDx (play ws) (+ (WS-dx ws) PLAYERSPEED))]
    [(key=? a-key DOWN)  (setDy (play ws) (- (WS-dy ws) PLAYERSPEED))]
    [(key=? a-key SWAP)  (setEnemyProjectiles (setEnemies (play ws) (reverse (WS-enemies ws)))
                              (reverse (second (WS-projectiles ws))))]
        [(key=? a-key PAUSE)  (if (= (WS-state ws) 2) (play ws) (pause ws))]
    [else (play ws)]) a-key))
; Worldstate, String -> Worldstate
; Reduces dx or dy if a movement key is released
; and removes the a-key from keysdown of the given worldstate
(define (key-up ws a-key)
  (removekeysdown  (cond
    [(key=? a-key RIGHT) (setDx ws (+ (WS-dx ws) PLAYERSPEED))]
    [(key=? a-key UP)    (setDy ws (- (WS-dy ws) PLAYERSPEED))]
    [(key=? a-key LEFT)  (setDx ws (- (WS-dx ws) PLAYERSPEED))]
    [(key=? a-key DOWN)  (setDy ws (+ (WS-dy ws) PLAYERSPEED))]
    [else ws]) a-key))
; Worldstate, Number, Number, String -> Worldstate
; Sets the cursor in the given worldstate equal to a posn of x and y
; and changes shooting? to true if it was false and false if it was true
(define (mouse-handler ws x y e)
  (if
   (= (WS-state ws) 1)
  (cond
    [(mouse=? e "move") (setCursor ws (make-posn x y))]
    [(mouse=? e "drag") (setCursor ws (make-posn x y))]
    [(mouse=? e "button-down") (setShooting ws (not (WS-shooting? ws)))]
    [else ws])
  ws))
; Worldstate -> Worldstate
; Adds player bullets and enemy bullets to the appropriate
; elements of the list of projectiles in the given worldstate
(define (add-projectiles ws)
  (player-need-reload (setProjectiles ws (list (add-player-bullets ws) (add-enemy-bullets ws) (third (WS-projectiles ws))))))
; Worldstate -> List of PR
; Adds new PR's to the list element of the worldstate's projectiles
; that corresponds to the player's bullets. This only happens
; if the player is shooting and there is no player reloadtime left
(define (add-player-bullets ws)
  (if (and (WS-shooting? ws) (= (WS-reloadtime ws) 0))
      (cons
          (make-PR CENTERX CENTERY
                (* BULLETSPEED (cos (rad (WS-aimangle ws))))
                (- (* BULLETSPEED (sin (rad (WS-aimangle ws)))))
                (WS-aimangle ws) "")
             (first (WS-projectiles ws)))
       (first (WS-projectiles ws))))
; Worldstate -> List of List
; Adds new PR's to the list element of the worldstate's projectiles
; that corresponds to the enemies' bullets. One projectile is added for
; each enemy that is on-screen and has no reloadtime left
(define (add-enemy-bullets ws)
  (list (append (add-enemy-bullets-1 ws) (first (second (WS-projectiles ws))))
        (append (add-enemy-bullets-2 ws) (second (second (WS-projectiles ws))))))
; Worldstate -> List of PR
; Creates new PR's for each normal enemy that is on-screen and has no reloadtime left
(define (add-enemy-bullets-1 ws)
  (map make-ep (filter en-in-bounds? (filter en-reloaded? (first (WS-enemies ws))))))
; Worldstate -> List of PR
; Creates new PR's for each homing enemy that is on-screen and has no reloadtime left
(define (add-enemy-bullets-2 ws)
  (map make-ep (filter en-in-bounds? (filter en-reloaded? (second (WS-enemies ws))))))
; EN -> PR
; Creates a PR that starts from the given enemy and is aimed towards the player
(define (make-ep en)
  (local [(define a (+ 180 (get-angle-helper (- (EN-x en) CENTERX) (- CENTERY (EN-y en)))))]
  (make-PR (EN-x en) (EN-y en)
        (* ENEMBULLETSPEED2 (cos (rad a)))
        (- (* ENEMBULLETSPEED2 (sin (rad a))))
        a "")))
; EN -> Boolean
; Returns true if the given enemy has zero reloadtime
; and false if it does not
(define (en-reloaded? en)
  (= (EN-reloadtime en) 0))
; Worldstate -> Worldstate
; Sets enemies' reload time to ENEMYRELOAD if it is zero
(define (reload-enemies ws)
  (setEnemies ws (list
          (map need-reload (first (WS-enemies ws)))
          (map need-reload (second (WS-enemies ws))))))
; EN -> EN
; Sets the given enemy's reload time to ENEMYRELOAD if it is zero
(define (need-reload en)
  (if (= (EN-reloadtime en) 0)
  (make-EN (EN-x en) (EN-y en) (EN-dx en) (EN-dy en) (EN-hp en) (EN-damagetime en) ENEMYRELOAD)
  en))
; Worldstate -> Worldstate
; Sets the player's reloadtime to PLAYERRELOAD if it is zero
(define (player-need-reload ws)
  (if (= (WS-reloadtime ws) 0 )
      (setReloadTime ws)
      ws))
; Worldstate -> Worldstate
; Adds an enemy to the given worldstate if the random
; function returns zero
(define (add-enemies ws)
  (if (= (random TICKSPERENEMY) 0)
      (add-enemy ws)
      ws))
; Worldstate -> Worldstate
; Chooses which edge of the screen a new enemy should
; be spawned on
(define (add-enemy ws)
  (cond
    [(> (WS-dx ws) 0) (left-enemy ws)]
    [(< (WS-dx ws) 0) (right-enemy ws)]
    [(> (WS-dy ws) 0) (top-enemy ws)]
    [(< (WS-dy ws) 0) (bottom-enemy ws)]
    [else (random-edge-enemy ws)]))
; Worldstate -> Worldstate
; Randomly picks an edge of the screen on which to spawn an enemy
(define (random-edge-enemy ws)
  (local [(define rand (random 4))]
    (cond
      [(= rand 0) (left-enemy ws)]
      [(= rand 1) (right-enemy ws)]
      [(= rand 2) (top-enemy ws)]
      [(= rand 3) (bottom-enemy ws)])))
; Worldstate -> Worldstate
; Spawns an enemy on the left side of the screen
(define (left-enemy ws)
  (enemy-switch ws
                (make-EN 0 (random HEIGHT) (random ENEMSPEED) (random ENEMSPEED) 100 0 ENEMYRELOAD)))
; Worldstate -> Worldstate
; Spawns an enemy on the right side of the screen
(define (right-enemy ws)
  (enemy-switch ws
                (make-EN WIDTH (random HEIGHT) (- (random ENEMSPEED)) (random ENEMSPEED) 100 0 ENEMYRELOAD)))
; Worldstate -> Worldstate
; Spawns an enemy on the top of the screen
(define (top-enemy ws)
  (enemy-switch ws
                (make-EN (random WIDTH) 0 (random ENEMSPEED) (random ENEMSPEED) 100 0 ENEMYRELOAD)))
; Worldstate -> Worldstate
; Spawns an enemy on the bottom of the screen
(define (bottom-enemy ws)
  (enemy-switch ws
                (make-EN (random WIDTH) HEIGHT (random ENEMSPEED) (- (random ENEMSPEED)) 100 0 ENEMYRELOAD)))
; Worldstate -> Worldstate
; Randomly chooses whether a homing or normal enemy will be spawned
(define (enemy-switch ws en)
  (if (= (random 2) 0)
      (add-enemy-1 ws en)
      (add-enemy-2 ws en)))
; Worldstate, EN -> Worldstate
; Adds the given enemy to the list of normal enemies
; in the given worldstate
(define (add-enemy-1 ws en)
  (setEnemies ws (list
              (cons
               en
               (first (WS-enemies ws)))
              (second (WS-enemies ws)))))
; Worldstate, EN -> Worldstate
; Adds the given enemy to the list of homing enemies
; in the given worldstate
(define (add-enemy-2 ws en)
  (setEnemies ws (list
              (first (WS-enemies ws))
              (cons
               en
               (second (WS-enemies ws))))))
; Worldstate -> Worldstate
; Adds a healthpack to the healthpacks of the
; given worldstate if the random function returns zero
(define (add-healthpacks ws)
  (if (= (random (+ TICKSPERHEALTHPACK (WS-kills ws))) 0)
      (setHealthpacks ws (cons (new-healthpack ws) (WS-healthpacks ws)))
      ws))
; Worldstate -> Posn
; Decides which edge of the screen on which to spawn a healthpack
(define (new-healthpack ws)
  (cond
    [(> (WS-dy ws) 0) (make-posn (random WIDTH) 0)]
    [(< (WS-dy ws) 0) (make-posn (random WIDTH) HEIGHT)]
    [(> (WS-dx ws) 0) (make-posn 0 (random HEIGHT))]
    [(< (WS-dx ws) 0) (make-posn WIDTH (random HEIGHT))]
    [else (random-edge-healthpack ws)]))
; Worldstate -> Posn
; Randomly picks which edge of the screen on which to spawn a healthpack
(define (random-edge-healthpack ws)
  (local [(define ran (random 4))]
  (cond
    [(= ran 0) (make-posn (random WIDTH) 0)]
    [(= ran 1) (make-posn (random WIDTH) HEIGHT)]
    [(= ran 2) (make-posn 0 (random HEIGHT))]
    [(= ran 3) (make-posn WIDTH (random HEIGHT))])))
; Worldstate -> Worldstate
; Moves all projectiles, enemies, and posn's according to
; their own speeds and the player's movement
(define (move-stuff ws)
  (local [
; The negative of the player's speed in the x direction
(define x (WS-dx ws))
; The negative of the player's speed in the y direction
(define y (WS-dy ws))
; List of PR -> List of PR
; Moves all the PR in the given list by
; x and y and their dx and dy's
(define (move-p p)
  (if (cons? p) (map move-pr p) p))
; List of PR -> List of PR
; Moves all the PR in the given list so
; they move towards the player
(define (move-ep-1 ep)
  (if (cons? ep) (map home-pr ep) ep))
; List of EN -> List of EN
; Moves each EN in the given list by
; x and y and its dx and dy
(define (move-enemy-1 e1)
  (if (cons? e1) (map move-e-helper1 e1) e1))
; List of EN -> List of EN
; Moves each EN in the given list so that
; they move towards the player
(define (move-enemy-2 e2)
  (if (cons? e2) (map move-e-helper2 e2) e2))
; EN -> EN
; Moves the given en by x and y and its dx and dy
(define (move-e-helper1 en)
  (make-EN (+ (EN-x en) (EN-dx en) x) (+ (EN-y en) (EN-dy en) y) (EN-dx en) (EN-dy en) (EN-hp en) (EN-damagetime en) (EN-reloadtime en)))
; EN -> EN
; Moves the given en so that is moves
; towards the player
(define (move-e-helper2 en)
  (local [(define a (rad (+ 180 (get-angle-helper (- (EN-x en) CENTERX) (- CENTERY (EN-y en))))))
          (define dx (* ENEMSPEED (cos a)))
          (define dy (- (* ENEMSPEED (sin a))))]
  (make-EN (+ (EN-x en) dx x) (+ (EN-y en) dy y) dx dy (EN-hp en) (EN-damagetime en) (EN-reloadtime en))))
; PR -> PR
; Moves the given pr by x and y and its dx and dy
(define (move-pr pr)
  (make-PR (+ (PR-x pr) (PR-dx pr) x) (+ (PR-y pr) (PR-dy pr) y) (PR-dx pr) (PR-dy pr) (PR-angle pr) (PR-color pr)))
; PR -> PR
; Moves the given pr so that it moves towards the player
(define (home-pr pr)
  (local [(define a (+ 180 (get-angle-helper (- (PR-x pr) CENTERX) (- CENTERY (PR-y pr)))))
          (define dx (* ENEMBULLETSPEED1 (cos (rad a))))
          (define dy (- (* ENEMBULLETSPEED1 (sin (rad a)))))]
  (make-PR (+ (PR-x pr) dx x) (+ (PR-y pr) dy y) dx dy a "")))
; Posn -> Posn
; Moves the given posn by x and y
(define (move-a-posn p)
  (make-posn (+ (posn-x p) x) (+ (posn-y p) y)))
; Worldstate -> Worldstate
; Moves all projectiles in the given worldstate
(define (move-projectiles ws)
  (setProjectiles ws (list
                      (move-p (first (WS-projectiles ws)))
                      (list
                       (move-ep-1 (first (second (WS-projectiles ws))))
                       (move-p (second (second (WS-projectiles ws)))))
                      (move-p (third (WS-projectiles ws))))))
; Worldstate -> Worldstate
; Moves all the enemies in the given worldstate
(define (move-enemies ws)
  (setEnemies ws (list
          (move-enemy-1 (first (WS-enemies ws)))
          (move-enemy-2 (second (WS-enemies ws))))))
; Worldstate -> Worldstate
; Moves all the specks in the given worldstate
(define (move-specks ws)
  (sSpecks ws (map move-a-posn (WS-specks ws))))
; Worldstate -> Worldstate
; Moves all the healthpacks in the given worldstate
(define (move-healthpacks ws)
  (if
   (cons? (WS-healthpacks ws))
   (setHealthpacks ws (map move-a-posn (WS-healthpacks ws)))
   ws))]
    
  (move-healthpacks (move-specks (move-enemies (move-projectiles ws))))))
; Worldstate -> Worldstate
; Deletes enemy bullets if they are off screen and player bullets if they
; are farther away from the screen than PROJECTILERANGE
(define (delete-pr ws)
  (setProjectiles ws (list
                      (filter p-in-bounds? (first (WS-projectiles ws)))
                      (list
                       (filter ep-in-bounds? (first (second (WS-projectiles ws))))
                       (filter ep-in-bounds? (second (second (WS-projectiles ws)))))
                      (filter p-in-bounds? (third (WS-projectiles ws))))))
; Worldstate -> Worldstate
; Deletes all enemies in the given worldstate that
; are farther away from the screen than ENEMYRANGE
(define (delete-en ws)
  (setEnemies ws (list
          (filter en-in-range? (first (WS-enemies ws)))
          (filter en-in-range? (second (WS-enemies ws))))))
; Worldstate -> Worldstate
; Deletes all healthpacks in the given worldstate that
; are farther away from the screen than HEALTHPACKRANGE
(define (delete-healthpacks ws)
  (setHealthpacks ws (filter healthpack-in-range? (WS-healthpacks ws))))
; Posn -> Boolean
; Returns true if the given posn is closer to
; the screen than HEALTHPACKRANGE and false if it is not
(define (healthpack-in-range? p)
  (cond
    [(< (posn-x p) (- HEALTHPACKRANGE)) #false]
    [(< (posn-y p) (- HEALTHPACKRANGE)) #false]
    [(> (posn-x p) (+ WIDTH HEALTHPACKRANGE)) #false]
    [(> (posn-y p) (+ HEIGHT HEALTHPACKRANGE)) #false]
    [else #true]))
(check-expect (healthpack-in-range? (make-posn -9000 0)) #false)
(check-expect (healthpack-in-range? (make-posn 0 -9000)) #false)
(check-expect (healthpack-in-range? (make-posn 0 0)) #true)
(check-expect (healthpack-in-range? (make-posn WIDTH HEIGHT)) #true)
; PR -> Boolean
; Returns true if the given pr is on screen and false if it is not
(define (ep-in-bounds? pr)
  (cond
    [(< (PR-x pr) BULLETLENGTH) #false]
    [(< (PR-y pr) BULLETLENGTH) #false]
    [(> (PR-x pr) WIDTH) #false]
    [(> (PR-y pr) HEIGHT) #false]
    [else #true]))
(check-expect (ep-in-bounds? (make-PR 0 0 10 -10 5 "")) #false)
(check-expect (ep-in-bounds? (make-PR WIDTH HEIGHT 10 -10 5 "")) #true)
; PR -> Boolean
; Returns true if the given pr is closer to
; the screen than PROJECTILERANGE and false if it is not
(define (p-in-bounds? pr)
  (cond
    [(< (PR-x pr) (- PROJECTILERANGE)) #false]
    [(< (PR-y pr) (- PROJECTILERANGE)) #false]
    [(> (PR-x pr) (+ WIDTH PROJECTILERANGE)) #false]
    [(> (PR-y pr) (+ HEIGHT PROJECTILERANGE)) #false]
    [else #true]))
(check-expect (p-in-bounds? (make-PR 0 0 10 -10 5 "")) #true)
(check-expect (p-in-bounds? (make-PR WIDTH HEIGHT 10 -10 5 "")) #true)
(check-expect (p-in-bounds? (make-PR -9000 0 10 -10 5 "")) #false)
; EN -> Boolean
; Returns true if the given en is on screen and
; false if it is not
(define (en-in-bounds? en)
  (cond
    [(< (EN-x en) 0) #false]
    [(< (EN-y en) 0) #false]
    [(> (EN-x en) WIDTH) #false]
    [(> (EN-y en) HEIGHT) #false]
    [else #true]))
(check-expect (en-in-bounds? (make-EN 0 0 10 -10 5 0 0)) #true)
(check-expect (en-in-bounds? (make-EN 0 9000 10 -10 5 0 0)) #false)
(check-expect (en-in-bounds? (make-EN -9000 0 10 -10 5 0 0)) #false)
; EN -> Boolean
; Returns true if the given en is closer to the screen than
; ENEMYRANGE and false if it is not
(define (en-in-range? en)
  (cond
    [(< (EN-x en) (- ENEMYRANGE)) #false]
    [(< (EN-y en) (- ENEMYRANGE)) #false]
    [(> (EN-x en) (+ ENEMYRANGE WIDTH)) #false]
    [(> (EN-y en) (+ ENEMYRANGE HEIGHT)) #false]
    [else #true]))
(check-expect (en-in-range? (make-EN 0 0 10 -10 5 0 0)) #true)
(check-expect (en-in-range? (make-EN 0 ENEMYRANGE 10 -10 5 0 0)) #true)
(check-expect (en-in-range? (make-EN (- -1 ENEMYRANGE) 0 10 -10 5 0 0)) #false)
; Worldstate -> Worldstate
; Checks for collisions between healthpacks and the player
; if the player has lost hp
(define (healthpack-collisions ws)
  (if (< (WS-hp ws) PLAYERHP) (collide-healthpacks ws) ws))
; Worldstate -> Worldstate
; Deletes healthpacks that the player is touching and
; resets his hp to PLAYERHP if he has touched at least one
(define (collide-healthpacks ws)
  (local [(define numPacks (length (WS-healthpacks ws)))
          (define newPacks (filter pack-not-touching-player? (WS-healthpacks ws)))]
    (if
     (< (length newPacks) numPacks)
     (setHp (setHealthpacks ws newPacks) PLAYERHP)
     ws)))
; Posn -> Boolean
; Returns true if given healthpack p is not touching the player
; and false if it is touching the player
(define (pack-not-touching-player? p)
  (> (distance (posn-x p) (posn-y p) CENTERX CENTERY) (+ PLAYERRAD HEALTHPACKRAD)))
(check-expect (pack-not-touching-player? (make-posn CENTERX CENTERY)) #false)
(check-expect (pack-not-touching-player? (make-posn 0 0)) #true)
; Worldstate -> Worldstate
; Checks for collisions between the player and both types of enemies
(define (en-collisions ws)
  (en-collision-helper
   (en-collision-helper ws (first (WS-enemies ws)) setEnemies1 ENEMYCOLOR1)
                       (second (WS-enemies ws)) setEnemies2 ENEMYCOLOR2))
; Worldstate, EN, (Worldstate, List of EN -> List of List), String -> Worldstate
; Handles collisions for the given list of enemies and uses setFunction
; to set the finished list of enemies to the correct list of enemies in the worldstate.
; color is used to make fragments of the correct color for any enemies that are killed.
(define (en-collision-helper ws en setFunction color)
  (if
   (and (cons? en) (cons? (first (WS-projectiles ws))))
   (en-collide empty (first (WS-projectiles ws)) empty en ws setFunction color)
   ws))
; List of PR, List of PR, List of EN, List of EN, Worldstate, (Worldstate, List of EN -> List of List), String -> Worldstate
; Handles collisions for the list of projectiles unchecked-pp and the list of enemies unchecked-en.
; checked-pp and checked-en pass along the bullets and enemies that have already been checked.
; setFunction is used to set the correct list of enemies to the processed enemies
; once the collision handling is complete. color is used to make fragments of the correct
; color if any enemies are killed
; The function also changes ws whenever a collision is detected:
; it will add 1 kill to the worldstate's kills if an enemy dies
(define (en-collide checked-pp unchecked-pp checked-en unchecked-en ws setFunction color)
  (cond
    [(empty? unchecked-pp) (setEnemies (setProjectiles ws (cons checked-pp (rest (WS-projectiles ws)))) (setFunction ws (append checked-en unchecked-en)))]
    [(empty? unchecked-en) (en-collide (cons (first unchecked-pp) checked-pp) (rest unchecked-pp) empty checked-en ws setFunction color)]
    [(en-collision? (first unchecked-en) (first unchecked-pp))
     (if (> (EN-hp (first unchecked-en)) PLAYERDAMAGE)
         (en-collide checked-pp (rest unchecked-pp) (cons (damage-enemy (first unchecked-en)) checked-en) (rest unchecked-en) ws setFunction color)
         (en-collide checked-pp (rest unchecked-pp) checked-en (rest unchecked-en)
                 (addKill (add-explosion ws (EN-x (first unchecked-en)) (EN-y (first unchecked-en)) color)) setFunction color))]
    [else (en-collide checked-pp unchecked-pp (cons (first unchecked-en) checked-en) (rest unchecked-en) ws setFunction color)]))
; EN -> EN
; Reduces the given enemy's hp by PLAYERDAMAGE and sets
; its damagetime to ENEMYDAMAGETIME
(define (damage-enemy en)
  (make-EN (EN-x en) (EN-y en) (EN-dx en) (EN-dy en) (- (EN-hp en) PLAYERDAMAGE) ENEMYDAMAGETIME (EN-reloadtime en)))
; Worldstate, List of EN -> Worldstate
; Set the normal enemies in the given worldstate to enemies
(define (setEnemies1 ws enemies)
  (list enemies (second (WS-enemies ws))))
; Worldstate, List of EN -> Worldstate
; Set the homing enemies in the given worldstate to enemies
(define (setEnemies2 ws enemies)
  (list (first (WS-enemies ws)) enemies))
; EN, PR -> Boolean
; Returns true if the given EN and PR are touching
; and false if they are not
(define (en-collision? en pr)
  (< (distance (EN-x en) (EN-y en) (PR-x pr) (PR-y pr)) (+ ENEMRAD LASERLENGTH)))
; Number, Number, Number, Number -> Number
; Returns the distance between locations x1,y1 and x2,y2
(define (distance x1 y1 x2 y2)
  (sqrt (+ (sqr (- x1 x2)) (sqr (- y1 y2)))))
(check-expect (distance 0 0 3 4) 5)
(check-within (distance 0 0 1 -1) (sqrt 2) 0.01)
; Worldstate -> Worldstate
; Handles collisions between the player and homing enemies or enemy bullets
(define (player-collisions ws)
  (collide-player/enemies (collide-player/bullets ws)))
; Worldstate -> Worldstate
; Handles collisions between the player and homing enemies
; if homing enemies exist
(define (collide-player/enemies ws)
  (if
   (cons? (second (WS-enemies ws)))
   (player/enemies-collision empty (second (WS-enemies ws)) ws)
  ws))
; List of EN, List of EN -> Worldstate
; Checks if any homing enemies in checked-enemies are touching the player
; and deletes them if they are reduces the player's hp by ENEMYRUSHDAMAGE
(define (player/enemies-collision checked-enemies unchecked-enemies ws)
  (cond
    [(empty? unchecked-enemies) (setEnemies ws (list (first (WS-enemies ws)) checked-enemies))]
    [(player-enemy-collision? (first unchecked-enemies))
     (player/enemies-collision checked-enemies (rest unchecked-enemies)
                               (maybe-end-game (enemy-hit-player ws)))]
    [else (player/enemies-collision (cons (first unchecked-enemies) checked-enemies) (rest unchecked-enemies) ws)]))
; Worldstate -> Worldstate
; Handles collisions between the player and enemy bullets
(define (collide-player/bullets ws)
  (player/bullet-collision-helper
   (second (second (WS-projectiles ws)))
   (player/bullet-collision-helper (first (second (WS-projectiles ws))) ws setEnemyBullets1)
   setEnemyBullets2))
; Worldstate, (Worldstate, List of PR -> Worldstate) -> Worldstate
; Handles collisions between the player and bullets if bullets isn't empty
(define (player/bullet-collision-helper bullets ws setFunction)
  (if
   (cons? bullets)
   (player/bullet-collision empty bullets ws setFunction)
    ws))
; List of PR, List of PR, Worldstate, (Worldstate, List of PR -> Worldstate) -> Worldstate
; Handles collisions between unchecked-bullets and the player.
; checked-bullets is used to pass along bullets that have already been checked for collision.
; The player's health is reduced by ENEMYDAMAGE for each bullet that is touching him
; the touching bullets are deleted.
; setFunction is used to set the appropriate list of PR's in the worldstate to
; the processed list of bullets
(define (player/bullet-collision checked-bullets unchecked-bullets ws setFunction)
  (cond
    [(empty? unchecked-bullets) (setFunction ws checked-bullets)]
    [(player-collision? (first unchecked-bullets))
     (player/bullet-collision checked-bullets (rest unchecked-bullets)
                              (maybe-end-game (bullet-hit-player ws)) setFunction)]
    [else (player/bullet-collision (cons (first unchecked-bullets) checked-bullets)
                                   (rest unchecked-bullets) ws setFunction)]))
; Worldstate, List of PR -> Worldstate
; Sets the homing bullets in ws to bullets
(define (setEnemyBullets1 ws bullets)
  (setProjectiles ws (list (first (WS-projectiles ws))
                           (list bullets
                             (second (second (WS-projectiles ws))))
                           (third (WS-projectiles ws)))))
; Worldstate, List of PR -> Worldstate
; Sets the normal bullets in ws to bullets
(define (setEnemyBullets2 ws bullets)
  (setProjectiles ws (list (first (WS-projectiles ws))
                           (list (first (second (WS-projectiles ws)))
                              bullets)
                           (third (WS-projectiles ws)))))
; PR -> Boolean
; Returns true if bullet is touching the player and false if it is not
(define (player-collision? bullet)
  (< (distance (PR-x bullet) (PR-y bullet) CENTERX CENTERY) (+ PLAYERRAD BULLETLENGTH)))
(check-expect (player-collision? (make-PR CENTERX CENTERY -90 90 4 "")) #true)
(check-expect (player-collision? (make-PR 0 0 -90 90 4 "")) #false)
; EN -> Boolean
; Returns true if enemy is touching the player and false if it is not
(define (player-enemy-collision? enemy)
  (< (distance (EN-x enemy) (EN-y enemy) CENTERX CENTERY) (+ PLAYERRAD ENEMRAD)))
(check-expect (player-enemy-collision? (make-EN CENTERX CENTERY -90 90 4 0 0)) #true)
(check-expect (player-enemy-collision? (make-EN 0 0 -90 90 4 0 0)) #false)
; Worldstate -> Worldstate
; Reduces the player's hp by ENEMYDAMAGE
(define (bullet-hit-player ws)
  (setHp (setDamageTime ws PLAYERDAMAGETIME ) (- (WS-hp ws) ENEMYDAMAGE)))
; Worldstate -> Worldstate
; Reduces the player's hp by ENEMYRUSHDAMAGE
(define (enemy-hit-player ws)
  (setHp (setDamageTime ws PLAYERDAMAGETIME ) (- (WS-hp ws) ENEMYRUSHDAMAGE)))
; Worldstate, Number, Number, String -> Worldstate
; Adds PR's to the list of fragments in ws with starting
; locations x,y and color color
(define (add-explosion ws x y color)
  (setProjectiles ws (list
             (first (WS-projectiles ws))
             (second (WS-projectiles ws))
      (append
       (list
          (make-PR x y -30 6 2 color)
          (make-PR x y -20 -25 12 color)
          (make-PR x y -10 13 34 color)
          (make-PR x y -17 12 57 color)
          (make-PR x y -15 -19 89 color)
          (make-PR x y 9 25 123 color)
          (make-PR x y 19 -17 168 color)
          (make-PR x y 25 24 190 color)
          (make-PR x y 45 -45 231 color)
          (make-PR x y 32 29 267 color)
          (make-PR x y 5 -45 299 color)
          (make-PR x y 23 25 332 color)
          (make-PR x y 4 -51 357 color))
          (third (WS-projectiles ws))))))
; Worldstate -> Worldstate
; Sets the worldstate's state to 3 if the player
; has no hp
(define (maybe-end-game ws)
  (if (= (WS-hp ws) 0) (game-over ws) ws))
; Worldstate -> Image
; Decides which screen to draw based on the worldstate's state
(define (render ws)
  (cond
    [(= (WS-state ws) 0) (welcome-screen ws)]
    [(= (WS-state ws) 1) (draw-game ws)]
    [(= (WS-state ws) 2) (pause-screen ws)]
    [(= (WS-state ws) 3) (death-screen ws)]))
; Worldstate -> Image
; Draws the welcome screen
(define (welcome-screen ws)
  (underlay/xy
   (overlay (rectangle WIDTH HEIGHT 'solid (color 255 255 255 150))
           (draw-game ws))
   100
   200
   (above (text TITLE 220 TEXTCOLOR)
          (square 100 'solid (color 255 255 255 0))
          (text (string-append "hareketler: " UP "-" LEFT "-" DOWN "-" RIGHT) 40 TEXTCOLOR)
          (text "fare ile ateş edebilirsin" 40 TEXTCOLOR)
          ;(text (string-append "press " (if (string=? SWAP " ") "space" SWAP) " if you want") 40 TEXTCOLOR)
          (text "başlamak için klavyeden bir tuşa basın" 40 TEXTCOLOR))))
; Worldstate -> Image
; Draws the pause screen
; (text is placed on top of the game's normal rendering)
(define (pause-screen ws)
  (underlay/xy
   (overlay (rectangle WIDTH HEIGHT 'solid (color 255 255 255 150))
           (draw-game ws))
   50
   100
   (above (text TITLE 220 TEXTCOLOR)
          (square 100 'solid (color 255 255 255 0))
          (text "oyun durduruldu" 40 TEXTCOLOR)
          (text "devam etmek için klavyeden bir tuşa basın" 40 TEXTCOLOR))))
; Worldstate -> Image
; Draws the death screen
; (text is placed on top of the game's normal rendering)
(define (death-screen ws)
  (underlay/xy
   (overlay (rectangle WIDTH HEIGHT 'solid (color 255 255 255 150))
           (draw-game ws))
   200
   100
   (above (text "BAŞARISIZ" 255 TEXTCOLOR)
          (square 100 'solid (color 255 255 255 0))
          (text (string-append "toplam öldürme sayısı: " (number->string (WS-kills ws)) " !!") 40 TEXTCOLOR)
          (square 100 'solid (color 255 255 255 0))
          (text "tekrar oynamak için klavyeden bir tuşa basın" 40 TEXTCOLOR))))
; Worldstate -> Image
; Draws the game
(define (draw-game ws)
  (draw-ui ws (draw-explosions ws (draw-p ws (draw-en-2 ws
     (draw-en-1 ws (draw-pp ws (draw-ep-2 ws (draw-ep-1 ws
        (draw-specks ws (draw-healthpacks ws (rectangle WIDTH HEIGHT 'solid BACKROUNDCOLOR))))))))))))
; Worldstate, Image -> Image
; Draws all on-screen healthpacks on i
(define (draw-healthpacks ws i)
  (if (cons? (WS-healthpacks ws))
      (foldl draw-healthpack-helper i (filter draw-healthpack? (WS-healthpacks ws)))
      i))
; Worldstate, Image -> Image
; Draws all normal enemy bullets on i
(define (draw-ep-1 ws i)
  (if (cons? (first (second (WS-projectiles ws))))
      (foldl draw-ep-helper-1 i (first (second (WS-projectiles ws))))
      i))
; Worldstate, Image -> Image
; Draws all homing enemy bullets on i
(define (draw-ep-2 ws i)
  (if (cons? (second (second (WS-projectiles ws))))
      (foldl draw-ep-helper-2 i (second (second (WS-projectiles ws))))
      i))
; PR, Image -> Image
; Draws all on-screen player bullets on i
(define (draw-pp ws i)
  (if (cons? (first (WS-projectiles ws)))
      (foldl draw-pp-helper i (filter draw-pp? (first (WS-projectiles ws))))
      i))
; Worldstate, Image -> Image
; Draws all on-screen normal enemies in ws on i
(define (draw-en-1 ws i)
  (if (cons? (first (WS-enemies ws)))
      (foldl draw-e-helper-1 i (filter draw-en? (first (WS-enemies ws))))
      i))
; Worldstate, Image -> Image
; Draws all on-screen homing enemies in ws on i
(define (draw-en-2 ws i)
  (if (cons? (second (WS-enemies ws)))
      (foldl draw-e-helper-2 i (filter draw-en? (second (WS-enemies ws))))
      i))
; Worldstate, Image -> Image
; Draws all on-screen fragments on i
(define (draw-explosions ws i)
  (if (cons? (third (WS-projectiles ws)))
      (foldl draw-ex-helper i (filter draw-f? (third (WS-projectiles ws))))
      i))
; Worldstate, Image -> Image
; Draws all specks in ws on i
(define (draw-specks ws i)
  (foldl draw-specks-helper i (WS-specks ws)))
; Posn, Image -> Image
; Draws a healthpack on i
(define (draw-healthpack-helper p i)
  (underlay/xy
   i
   (- (posn-x p) HEALTHPACKRAD)
   (- (posn-y p) HEALTHPACKRAD)
   HEALTHPACK))
; EN, Image -> Image
; Draws a normal enemy on i
(define (draw-ep-helper-1 ep i)
  (underlay/xy
   i
   (- (PR-x ep) BULLETLENGTH)
   (- (PR-y ep) BULLETLENGTH)
   (rotate (PR-angle ep) ENEMYBULLET1)))
; EN, Image -> Image
; Draws a homing enemy on i
(define (draw-ep-helper-2 ep i)
  (underlay/xy
   i
   (- (PR-x ep) BULLETLENGTH)
   (- (PR-y ep) BULLETLENGTH)
   (rotate (PR-angle ep) ENEMYBULLET2)))
; EN, Image -> Image
; Draws a player bullet on i
(define (draw-pp-helper pp i)
  (underlay/xy
   i
   (- (PR-x pp) LASERLENGTH)
   (- (PR-y pp) LASERLENGTH)
   (rotate (PR-angle pp) LASER)))
; Worldstate -> Image
; Draws the player on i
(define (draw-p ws i)
  (underlay/xy
   i
   (- CENTERX GUNLENGTH)
   (- CENTERY GUNLENGTH)
   (rotate (WS-aimangle ws) (player (WS-damagetime ws) (WS-reloadtime ws) (WS-shooting? ws)))))
; Posn -> Boolean
; Returns true if healthpack p can be drawn
; without exceeding the screen boundaries
; and false if it cannot
(define (draw-healthpack? p)
  (and
   (> (posn-x p) HEALTHPACKRAD)
   (> (posn-y p) HEALTHPACKRAD)
   (< (posn-x p) WIDTH)
   (< (posn-y p) HEIGHT)))
(check-expect (draw-healthpack? (make-posn 0 0)) #false)
(check-expect (draw-healthpack? (make-posn 400 400)) #true)
(check-expect (draw-healthpack? (make-posn 4000 4000)) #false)
(check-expect (draw-healthpack? (make-posn (+ HEALTHPACKRAD 1) (+ HEALTHPACKRAD 1))) #true)
; Posn -> Boolean
; Returns true if enemy en can be drawn
; without exceeding the screen boundaries
; and false if it cannot
(define (draw-en? en)
  (and
   (> (EN-x en) ENEMRAD)
   (> (EN-y en) ENEMRAD)
   (< (EN-x en) WIDTH)
   (< (EN-y en) HEIGHT)))
(check-expect (draw-en? (make-EN 0 0 -90 90 3 0 0)) #false)
(check-expect (draw-en? (make-EN -9000 0 -90 90 3 0 0)) #false)
(check-expect (draw-en? (make-EN ENEMRAD ENEMRAD -90 90 3 0 0)) #false)
(check-expect (draw-en? (make-EN (+ ENEMRAD 1) (+ ENEMRAD 1) -90 90 3 0 0)) #true)
; Posn -> Boolean
; Returns true if bullet pr can be drawn
; without exceeding the screen boundaries
; and false if it cannot
(define (draw-pp? pr)
  (and
   (> (PR-x pr) LASERLENGTH)
   (> (PR-y pr) LASERLENGTH)
   (< (PR-x pr) WIDTH)
   (< (PR-y pr) HEIGHT)))
(check-expect (draw-pp? (make-PR 0 0 -90 90 3 "")) #false)
(check-expect (draw-pp? (make-PR -9000 0 -90 90 3 "")) #false)
(check-expect (draw-pp? (make-PR LASERLENGTH LASERLENGTH -90 90 3 "")) #false)
(check-expect (draw-pp? (make-PR (+ LASERLENGTH 1) (+ LASERLENGTH 1) -90 90 3 "")) #true)
; Posn -> Boolean
; Returns true if fragment pr can be drawn
; without exceeding the screen boundaries
; and false if it cannot
(define (draw-f? pr)
  (and
   (> (PR-x pr) 0)
   (> (PR-y pr) 0)
   (< (PR-x pr) WIDTH)
   (< (PR-y pr) HEIGHT)))
(check-expect (draw-f? (make-PR 0 0 -90 90 3 "")) #false)
(check-expect (draw-f? (make-PR -9000 0 -90 90 3 "")) #false)
(check-expect (draw-f? (make-PR 0 -9000 -90 90 3 "")) #false)
(check-expect (draw-f? (make-PR 1 1 -90 90 3 "")) #true)
; EN, Image -> Image
; Draws normal enemy en on i
(define (draw-e-helper-1 en i)
  (underlay/xy
   i
   (- (EN-x en) ENEMRAD)
   (- (EN-y en) ENEMRAD)
   (enemy1 (EN-damagetime en))))
; EN, Image -> Image
; Draws homing enemy en on i
(define (draw-e-helper-2 en i)
  (underlay/xy
   i
   (- (EN-x en) ENEMRAD)
   (- (EN-y en) ENEMRAD)
  (enemy2 (EN-damagetime en))))
; PR, Image -> Image
; Draws fragment f on i
(define (draw-ex-helper f i)
  (underlay/xy
   i
   (PR-x f)
   (PR-y f)
   (rotate (PR-angle f) (fragment (PR-color f)))))
; Posn, Image -> Image
; Draws speck on i
(define (draw-specks-helper speck i)
  (underlay/xy
   i
   (posn-x speck)
   (posn-y speck)
   SPECK))
; Worldstate, Image -> Image
; Draws the kill counter and health bar on i
(define (draw-ui ws i)
  (underlay/xy (kill-count ws i) 0 0
    (rectangle (* (/ (WS-hp ws) PLAYERHP) WIDTH) HEALTHBARWIDTH  'solid HEALTHBARCOLOR)))
; Worldstate, Image -> Image
; Draws the kill counter on i
(define (kill-count ws i)
  (underlay/xy
   i
   (* WIDTH 0.9)
   (* HEIGHT 0.85)
   (text (number->string (WS-kills ws)) KILLCOUNTSIZE KILLCOUNTCOLOR)))
; big-bang: actually call all the functions
(big-bang initial-ws (on-tick tock) (on-key key-down) (on-mouse mouse-handler) (on-release key-up) (to-draw render) (display-mode 'fullscreen))
