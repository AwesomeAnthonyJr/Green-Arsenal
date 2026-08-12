extends Node

var player_package = preload("res://scenes/player_package.tscn")
var room_loader = preload("res://scenes/room_loader.tscn")
var main_menu = preload("res://scenes/main_menu.tscn")

const bullet_base = preload("res://scenes/Bullet.tscn")
const bullet_seed = preload("res://scenes/bullet_seed.tscn")
const blaze_seed = preload("res://scenes/blaze_seed.tscn")
const bounce_seed = preload("res://scenes/bounce_seed.tscn")
const life_seed = preload("res://scenes/life_seed.tscn")
const platform_seed = preload("res://scenes/platform_seed.tscn")
const seeker_seed = preload("res://scenes/seeker_seed.tscn")
const propeller_seed = preload("res://scenes/propeller_seed.tscn")
const heavy_seed = preload("res://scenes/heavy_seed.tscn")

const bullet_sprout = preload("res://scenes/bullet_sprout.tscn")
const blaze_flower = preload("res://scenes/blaze_flower.tscn")
const spring_vine = preload("res://scenes/spring_vine.tscn")
const life_fruit = preload("res://scenes/life_fruit.tscn")
const platform_lilypad = preload("res://scenes/platform_lilypad.tscn")
const propeller_flower = preload("res://scenes/propeller_flower.tscn")
const seeker_flower = preload("res://scenes/seeker_flower.tscn")
const boulder_fruit = preload("res://scenes/boulder_fruit.tscn")

const fireball = preload("res://scenes/fireball.tscn")

const splash_particles = preload("res://scenes/splash_particles.tscn")
const small_splash_particles = preload("res://scenes/small_splash_particles.tscn")
const explosion_particles = preload("res://scenes/particle_explosion.tscn")

const gameplay_music_01 = preload("res://sound/music/gameplay.wav")
const gameplay_music_02 = preload("res://sound/music/gameplay_02.wav")
const gameplay_music_03 = preload("res://sound/music/gameplay_03.ogg")
const gameplay_music_04 = preload("res://sound/music/gameplay_reversed.wav")
const silence = preload("res://sound/music/genuinely_silence.wav")
const main_theme = preload("res://sound/music/theme.mp3")
const easter_egg_music = preload("res://sound/music/easter_egg_2.wav")

const pure_black_mat = preload("res://materials/pure_black.tres")
