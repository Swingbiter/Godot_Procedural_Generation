# Attach this script to a Node2D child of a TileMap node.
extends Node2D

# export vars
export(int) var map_width = 80
export(int) var map_height = 50

# export vars - Open Simplex Noise
export(String) var world_seed = "Hello World!" # change this for 'different' generation each time.
export(int) var noise_octaves = 3 # controls how much detail in the noise
export(int) var noise_period = 3 # determines the frequency of noise low == high and vice versa
export(float) var noise_persistance = 0.7 # determines how quickly the amplitudes diminish
export(float) var noise_lacunarity = 0.4 # 'gappiness'
export(float) var noise_threshold = 0.5 # use this determine what gets filled in on tilemap

# check and uncheck this in the editor during runtime to redraw tilemap 
export(bool) var redraw setget redraw 

# signals
signal finished_generation
signal cleared

# runtime vars
var tile_map : TileMap
var simple_noise : OpenSimplexNoise = OpenSimplexNoise.new()


func _ready() -> void:
	tile_map = get_parent() as TileMap
	clear()
	generate()


func redraw(value = null) -> void:
	# used to redraw map during runtime after params have been changed.
	# triggered when the export var redraw gets modified
	if self.tile_map == null:
		return
	clear()
	generate()
	

func clear() -> void:
	self.tile_map.clear()
	self.emit_signal("cleared")


func generate() -> void:
	# generates simple noise tilemap
	self.simple_noise.seed = self.world_seed.hash()
	self.simple_noise.octaves = self.noise_octaves
	self.simple_noise.period = self.noise_period
	self.simple_noise.persistence = self.noise_persistance
	self.simple_noise.lacunarity = self.noise_lacunarity
	
	# half in neg and positive, is "centered" on tilemap 0,0
	for x in range(-self.map_width / 2, self.map_width / 2):
		for y in range(-self.map_height / 2, self.map_height / 2):
			if self.simple_noise.get_noise_2d(x,y) < self.noise_threshold:
				self._set_autotile(x, y)
	
	self.tile_map.update_dirty_quadrants()
	self.emit_signal("finished_generation")


func _set_autotile(x: int, y: int) -> void:
	self.tile_map.set_cell(
		x, 
		y, 
		self.tile_map.get_tileset().get_tiles_ids()[0], # assume only one autotile in tileset
		false,
		false,
		false,
		self.tile_map.get_cell_autotile_coord(x, y)
		)
	self.tile_map.update_bitmask_area(Vector2(x,y))