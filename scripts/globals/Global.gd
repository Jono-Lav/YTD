extends Node

var player_name : String = ""

var score : int = 0 # used to track the score
var score2d : int = 0 # used to track the score specifaclly in the 2d world

var playpickupsound2d : bool  = false # when true plays the pickup sound in the 2d world

var o1 : bool  = true # decideds if the orbs should spawn when entering the scene
var o2 : bool  = true
var o3 : bool  = true
var o4 : bool  = true
var o5 : bool  = true
var o6 : bool  = true

var previousScene : Node # stores the previous scenes for the orbs
var dialugefinishedo6 : bool  = false

var o6permission : bool  = false #decideds if you have permissions to enter orb 6
var o5permission : bool  = true
var o4permission : bool  = true
var o3permission : bool  = true
var o2permission : bool  = true
var o1permission : bool  = true

var playerStop  : bool = false #when true player stops, when false player doesnt stop
var canSprint : bool = true #decides if the player can sprint or not
var canJump : bool = true # decides if the player can jump or not
var mouse_captured : bool = true

var entered1 : bool = false #move x when touch y
var onceCutScene : bool = true #makes sure the cutscene in floor 1 after the death part is only once

var fell : bool = false # decides if you entered the scene by falling from aother scene
var elevator : bool = false #decides when you enter a world through an elevator
var showText : bool = false #decides if to show a text whenever entering a word (usually through an elevator)
var prompt : String = "" # the prompt the text will show

var player_rotation : Vector3 # this is used to save the player rotation before changing scens in the elevator so it can be copied to the next scene to make the transition seem seamless
var player_head_rotation : Vector3 # does the same as above but for the head rotation instead of the overall body rotation
var player_relative_position : Vector3 # same as the above, saves player location in the elevator

var missionFailed : bool = false
var missionCompleted : bool = false

#intro
var StartTextAnim : bool = false #start text
var PearAnim : bool = false
var canDel : bool = false
var canStare : bool = false
var canStep : bool = false
var canDrawn : bool = false
