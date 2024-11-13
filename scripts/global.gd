extends Node

var gameStarted: bool

var playerBody: CharacterBody2D 
var playerDamageZone: Area2D
var playerDamageAmount : int
var playerHitbox: Area2D
var playerAlive: bool

var goblinDamageZone: Area2D
var goblinDamageAmount: int

var EyeDamageZone: Area2D
var EyeDamageAmount: int

var current_wave: int
var moving_next_wave: bool

var high_score = 0
var current_score: int
var prev_score: int
