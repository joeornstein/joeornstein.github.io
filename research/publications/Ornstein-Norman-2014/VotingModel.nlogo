globals [
  ;;These are the indices in the three-candidate election profile
  ABC
  ACB
  BAC
  BCA
  CAB
  CBA
  ;;;;;;;;;;;;;;;;;
  ;Counters
  ;;;;;;;;;;;;;;;;;
  winner
  eliminated-candidate
  is-competitive
  competitive-ratio
  violates-upward
  majority-cyclic-triple
  num-voted
  upward-violations
  competitive-elections
  cyclic-triples
  tie?
  ;;;;;;;;;;;;;;;
  ] 

breed [voters voter]
breed [candidates candidate]
candidates-own [name poll-numbers]
voters-own [party]
patches-own []

to setup
  
  clear-all
  ask patches [ set pcolor black ]
  reset-election-profile
  let num-candidates 3
  
  ;;Initialize Counters
  set competitive-elections 0
  set upward-violations 0
  set cyclic-triples 0
  
  set-default-shape candidates "person"
  create-candidates num-candidates  ;; create the candiates, then initialize their variables
  [
    set size 2  ;; easier to see
  ]  
  ask candidate 0 [set name "A" set color red set-position-candidate]
  ask candidate 1 [set name "B" set color blue set-position-candidate]
  ask candidate 2 [set name "C" set color green set-position-candidate]

  set-default-shape voters "person"
  create-voters num-voters  ;; create the voters, then initialize their variables
  [
    set color white
    set-position-voter
  ]

  show "Num-Voted, ABC, ACB, BAC, BCA, CAB, CBA, Competitive Ratio, Violates-Upward, Majority Cyclic Triple"
  
  reset-ticks
  
end


to go
  
  reset-election-profile
  
  ask voters 
  [
    set-position-voter
  ]
  
  set-position-candidate
  
  set num-voted num-voters
  ask voters
  [
    vote
  ]
  tick
  update-globals
  show (word num-voted "," ABC "," ACB "," BAC "," BCA "," CAB "," CBA "," competitive-ratio "," violates-upward "," majority-cyclic-triple)
  
end

to reset-election-profile
  set ABC 0
  set ACB 0
  set BAC 0
  set BCA 0
  set CAB 0
  set CBA 0
  set winner ""
  set eliminated-candidate ""
  set tie? true ;;switch to be sure there are no ties
  set is-competitive false
  set violates-upward false
  set majority-cyclic-triple false
  set competitive-ratio 0.0
end

to set-position-voter
  
  if (voter-distribution = "Base Case")
  [
    let x random-normal 0 25
    while [x > 50 or x < -50] [set x random-normal 0 25]
    let y random-normal 0 25
    while [y > 50 or y < -50] [set y random-normal 0 25]
    setxy x y
  ]
  
  if (voter-distribution = "Balanced Polarized")
  [
    ifelse (random 2 = 0)
    [
      let x random-normal 25 10
      while [x > 50 or x < -50] [set x random-normal 25 10]
      let y random-normal 25 10
      while [y > 50 or y < -50] [set y random-normal 25 10]
      setxy x y
    ]
    [
      let x random-normal -25 10
      while [x > 50 or x < -50] [set x random-normal -25 10]
      let y random-normal -25 10
      while [y > 50 or y < -50] [set y random-normal -25 10]
      setxy x y
    ]
  ]
  
  if (voter-distribution = "Unbalanced Polarized")
  [
    ifelse (random 10 < 4)
    [
      let x random-normal 25 10
      while [x > 50 or x < -50] [set x random-normal 25 10]
      let y random-normal 25 10
      while [y > 50 or y < -50] [set y random-normal 25 10]
      setxy x y
    ]
    [
      let x random-normal -25 10
      while [x > 50 or x < -50] [set x random-normal -25 10]
      let y random-normal -25 10
      while [y > 50 or y < -50] [set y random-normal -25 10]
      setxy x y
    ]
  ]
  
  if (voter-distribution = "Multiparty")
  [
    let r random 4
    if (r = 0)
    [
      let x random-normal 25 10
      while [x > 50 or x < -50] [set x random-normal 25 10]
      let y random-normal 25 10
      while [y > 50 or y < -50] [set y random-normal 25 10]
      setxy x y
    ]
    if (r = 1)
    [
      let x random-normal -25 10
      while [x > 50 or x < -50] [set x random-normal -25 10]
      let y random-normal -25 10
      while [y > 50 or y < -50] [set y random-normal -25 10]
      setxy x y
    ]
    if (r = 2)
    [
      ifelse (random 2 = 0)
      [
        let x random-normal -25 10
        while [x > 50 or x < -50] [set x random-normal -25 10]
        let y random-normal 25 10
        while [y > 50 or y < -50] [set y random-normal 25 10]
        setxy x y
      ]
      [
        let x random-normal 25 10
        while [x > 50 or x < -50] [set x random-normal 25 10]
        let y random-normal -25 10
        while [y > 50 or y < -50] [set y random-normal -25 10]
        setxy x y
      ]
    ]
    if (r = 3)
    [
      let x random-normal 0 10
      while [x > 50 or x < -50] [set x random-normal 0 10]
      let y random-normal 0 10
      while [y > 50 or y < -50] [set y random-normal 0 10]
      setxy x y
    ]
  ]

end

to set-position-candidate
  
  ;Initial Placement
  ask candidates
  [
    ;Special Placement for Polarized, otherwise, place along with voters
    ifelse (voter-distribution = "Unbalanced Polarized" or voter-distribution = "Balanced Polarized")
    [
      ifelse name = "A"
      [
        let x random-normal 25 10
        while [x > 50 or x < -50] [set x random-normal 25 10]
        let y random-normal 25 10
        while [y > 50 or y < -50] [set y random-normal 25 10]
        setxy x y
      ]
      [
        let x random-normal -25 10
        while [x > 50 or x < -50] [set x random-normal -25 10]
        let y random-normal -25 10
        while [y > 50 or y < -50] [set y random-normal -25 10]
        setxy x y
      ]
    ]
    [
      ;Set initial position based on voter distribution
      set-position-voter
    ]
  ]    
  
  ;Set Poll Numbers
  set-poll-numbers
  
  ;Reposition Adaptively
  let time-remaining campaign-length
  while [time-remaining > 0]
  [
    ask candidates
    [
      let best-x xcor
      let best-y ycor
      let best-poll poll-numbers
      let current-orientation 0
      
      ;Rotate in 45 degree increments, move foward, check out the spot, and log which is best
      while [current-orientation <= 360]
      [
        rt 45
        fd 1
        set-poll-numbers
        if (best-poll < poll-numbers)
        [
          set best-x xcor
          set best-y ycor
          set best-poll poll-numbers
        ]
        rt 180
        fd 1
        rt 180
        set current-orientation current-orientation + 45
      ]
      setxy best-x best-y
    ]
    set time-remaining time-remaining - 1    
  ]
end
    
to vote
  ;;A is closest
  if (distance candidate 0 < distance candidate 1 and distance candidate 0 < distance candidate 2)
  [
    ifelse (distance candidate 1 < distance candidate 2)
    [
      set ABC ABC + 1
    ]
    [
      set ACB ACB + 1
    ]
  ]
  ;;B is closest
  if (distance candidate 1 < distance candidate 0 and distance candidate 1 < distance candidate 2)
  [
    ifelse (distance candidate 0 < distance candidate 2)
    [
      set BAC BAC + 1
    ]
    [
      set BCA BCA + 1
    ]
  ]
  ;;C is closest
  if (distance candidate 2 < distance candidate 1 and distance candidate 2 < distance candidate 0)
  [
    ifelse (distance candidate 0 < distance candidate 1)
    [
      set CAB CAB + 1
    ]
    [
      set CBA CBA + 1
    ]
  ]
end


to set-poll-numbers
  ask candidates [set poll-numbers 0]
  ask voters
  [
    if (distance candidate 0 < distance candidate 1 and distance candidate 0 < distance candidate 2)
    [
      ask candidate 0 [set poll-numbers poll-numbers + 1]
    ]
    if (distance candidate 1 < distance candidate 0 and distance candidate 1 < distance candidate 2)
    [
      ask candidate 1 [set poll-numbers poll-numbers + 1]
    ]
    if (distance candidate 2 < distance candidate 0 and distance candidate 2 < distance candidate 1)
    [
      ask candidate 2 [set poll-numbers poll-numbers + 1]
    ]
  ]
  
end

to update-globals
  
  ;;If no outright majority, eliminate a candidate.
  ifelse (ABC + ACB < num-voted / 2 and BAC + BCA < num-voted / 2 and CAB + CBA < num-voted / 2)
  [
    ;;A is eliminated
    if (ABC + ACB < BAC + BCA and ABC + ACB < CAB + CBA)
    [
      set eliminated-candidate "A"
      ifelse (BAC + BCA + ABC > CAB + CBA + ACB) [set winner "B"] [set winner "C"]
      set tie? false
    ]
    ;;B is eliminated
    if (BAC + BCA < ABC + ACB and BAC + BCA < CAB + CBA)
    [
      set eliminated-candidate "B"
      ifelse (ABC + ACB + BAC > CAB + CBA + BCA) [set winner "A"] [set winner "C"]
      set tie? false
    ]
    ;;C is eliminated
    if (CAB + CBA < BAC + BCA and CAB + CBA < ABC + ACB)
    [
      set eliminated-candidate "C"
      ifelse (ABC + ACB + CAB > BAC + BCA + CBA) [set winner "A"] [set winner "B"]
      set tie? false
    ]
    ;;2nd/3rd place tie
    if (tie?)
    [
      resolve-tie
    ]
  ]
  ;;There was an outright majority. Select the majority-vote winner.
  [
    if (ABC + ACB > num-voted / 2) [set winner "A"]
    if (BAC + BCA > num-voted / 2) [set winner "B"]
    if (CAB + CBA > num-voted / 2) [set winner "C"]
  ]
  
  ;;Is the election competitive?
  if (ABC + ACB > (num-voted + 2) / 4 and BAC + BCA > (num-voted + 2) / 4 and CAB + CBA > (num-voted + 2) / 4)
  [set is-competitive true set competitive-elections competitive-elections + 1]
  
  ;;Does the election violate upward monotonicity?
  if (is-competitive)
  [
    ;;If the profile is competitive and the STV winner is not the Condorcet winner,
    ;;it violates upward monotonicity
    if (winner = "A")
    [
      if (ABC + ACB + BAC < CAB + CBA + BCA or ABC + ACB + CAB < BAC + BCA + CBA)
      [set violates-upward true set upward-violations upward-violations + 1]
    ]
    if (winner = "B")
    [
      if (BAC + BCA + CBA < ABC + ACB + CAB or BAC + BCA + ABC < CAB + CBA + ACB)
      [set violates-upward true set upward-violations upward-violations + 1]
    ]
    if (winner = "C")
    [
      if (CAB + CBA + BCA < ABC + ACB + BAC or CAB + CBA + ACB < BAC + BCA + ABC)
      [set violates-upward true set upward-violations upward-violations + 1]
    ]
  ]
  
  ;;Does the profile contain a majority cyclic triple?
  if (ABC + ACB + CAB > BAC + BCA + CBA and BAC + BCA + ABC > ACB + CAB + CBA and CAB + CBA + BCA > ABC + ACB + BAC)
  [ set majority-cyclic-triple true set cyclic-triples cyclic-triples + 1]
  if (ABC + ACB + CAB < BAC + BCA + CBA and BAC + BCA + ABC < ACB + CAB + CBA and CAB + CBA + BCA < ABC + ACB + BAC)
  [ set majority-cyclic-triple true set cyclic-triples cyclic-triples + 1]
  
  ;;Calculate competitive ratio
  
  ;;A is smallest
  if (ABC + ACB <= BAC + BCA and ABC + ACB <= CAB + CBA and ABC + ACB != 0)
  [
    ifelse (BAC + BCA >= CAB + CBA) 
    [set competitive-ratio (ABC + ACB) / (BAC + BCA)]  
    [set competitive-ratio (ABC + ACB) / (CAB + CBA)]
  ]
  ;;B is smallest
  if (BAC + BCA <= ABC + ACB and BAC + BCA <= CAB + CBA and BAC + BCA != 0)
  [
    ifelse (ABC + ACB >= CAB + CBA) 
    [set competitive-ratio (BAC + BCA) / (ABC + ACB)] 
    [set competitive-ratio (BAC + BCA) / (CAB + CBA)]
  ]
  ;;C is smallest
  if (CAB + CBA <= BAC + BCA and CAB + CBA <= ABC + ACB and CAB + CBA != 0)
  [
    ifelse (ABC + ACB >= BAC + BCA) 
    [set competitive-ratio (CAB + CBA) / (ABC + ACB)] 
    [set competitive-ratio (CAB + CBA) / (BAC + BCA)]
  ]
  
end

to resolve-tie
  ;;Tie between A and B
  if (ABC + ACB = BAC + BCA)
  [
    ifelse (random 2 = 0) 
    [  
      set eliminated-candidate "A"
      ifelse (BAC + BCA + ABC > CAB + CBA + ACB) [set winner "B"] [set winner "C"]
    ]
    [
      set eliminated-candidate "B"
      ifelse (ABC + ACB + BAC > CAB + CBA + BCA) [set winner "A"] [set winner "C"]
    ]
  ]
  ;;Tie between A and C
  if (ABC + ACB = CAB + CBA)
  [
    ifelse (random 2 = 0) 
    [  
      set eliminated-candidate "A"
      ifelse (BAC + BCA + ABC > CAB + CBA + ACB) [set winner "B"] [set winner "C"]
    ]
    [
      set eliminated-candidate "C"
      ifelse (ABC + ACB + CAB > BAC + BCA + CBA) [set winner "A"] [set winner "B"]
    ]
  ]
  ;;Tie between B and C
  if (BAC + BCA = CAB + CBA)
  [
    ifelse (random 2 = 0) 
    [  
      set eliminated-candidate "B"
      ifelse (ABC + ACB + BAC > CAB + CBA + BCA) [set winner "A"] [set winner "C"]
    ]
    [
      set eliminated-candidate "C"
      ifelse (ABC + ACB + CAB > BAC + BCA + CBA) [set winner "A"] [set winner "B"]
    ]
  ]
end


; Copyright 2013 Joseph T. Ornstein. All rights reserved.
; The full copyright notice is in the Information tab.
@#$#@#$#@
GRAPHICS-WINDOW
284
10
647
394
50
50
3.5
1
10
1
1
1
0
0
0
1
-50
50
-50
50
0
0
1
ticks
30.0

BUTTON
11
10
75
43
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
84
11
147
44
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
13
53
163
71
Election Profile:
11
0.0
1

MONITOR
6
69
56
114
NIL
ABC
17
1
11

MONITOR
48
69
98
114
NIL
ACB
17
1
11

MONITOR
93
69
143
114
NIL
BAC
17
1
11

MONITOR
135
69
185
114
NIL
BCA
17
1
11

MONITOR
14
118
91
163
IRV Winner
winner
17
1
11

MONITOR
97
118
166
163
Eliminated
eliminated-candidate
17
1
11

MONITOR
178
69
228
114
NIL
CAB
17
1
11

MONITOR
221
69
271
114
NIL
CBA
17
1
11

BUTTON
157
11
220
44
Step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
171
118
241
163
Competitive?
is-competitive
17
1
11

MONITOR
444
407
529
452
% Competitive
competitive-elections / ticks * 100
3
1
11

MONITOR
332
407
438
452
UMF (% of total)
upward-violations / ticks * 100
3
1
11

MONITOR
532
407
658
452
UMF (% of competive)
upward-violations / competitive-elections * 100
3
1
11

MONITOR
228
407
326
452
Upward MF?
violates-upward
17
1
11

MONITOR
7
407
123
452
Majority Cyclic Triple?
majority-cyclic-triple
17
1
11

MONITOR
126
407
222
452
# Cyclic Triples
cyclic-triples
17
1
11

CHOOSER
8
179
174
224
Voter-Distribution
Voter-Distribution
"Base Case" "Balanced Polarized" "Unbalanced Polarized" "Multiparty"
0

MONITOR
88
359
194
404
competitive-ratio
competitive-ratio
3
1
11

MONITOR
7
358
80
403
NIL
num-voted
17
1
11

SLIDER
8
271
180
304
num-voters
num-voters
15
3001
1001
2
1
NIL
HORIZONTAL

SLIDER
8
231
180
264
campaign-length
campaign-length
0
200
60
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This is a spatial model of voting and elections, used to estimate the rate of monotonicity failure under Instant Runoff Voting.

## HOW IT WORKS

Voters and candidates are placed into a two-dimensional issue space based on one of four stylized probability distribution functions. Voters ranked-order the candidates based on distance, and candidates attempt to maximize their first-place vote by moving in discrete increments if doing so increases their number of supporters. At the end of a specified number of rounds (Campaign-Length), the final ballot is computed and tested for monotonicity failure.

## CREDITS AND REFERENCES

Ornstein JT, Norman RZ (2013). Frequency of monotonicity failure under Instant Runoff Voting: estimates based on a spatial model of elections. Public Choice.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
