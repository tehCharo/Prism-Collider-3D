@tool
class_name PrismCollider3D
extends CollisionShape3D


	# Visual Representation:
	#         --- Top Point Radius
	#        /\                      ---|
	#       /  \        Top Point       |
	#      /____\                       |
	#     |      |                      |
	#     |      |      Middle Body     |- Total Height
	#     |      |                      |
	#      \¯¯¯¯/                       |
	#       \  /        Bottom Point    |
	#        \/                      ---|
	#         --- Bottom Point Radius
	#


const MIN_BODY_WIDTH := 0.001
const MAX_BODY_WIDTH := 100.0
const MIN_BODY_DEPTH := 0.001
const MAX_BODY_DEPTH := 100.0
const MIN_BODY_RADIUS := 0.001
const MAX_BODY_RADIUS := 100.0
const MIN_POINT_RADIUS := 0.000
const MAX_POINT_RADIUS := 100.0
const MIN_HEIGHT := 0.001
const MAX_HEIGHT := 100.0
const MAX_POINT_HEIGHT := 100.0
const MIN_RADIAL_SEGMENTS := 3
const MAX_RADIAL_SEGMENTS := 64
const DEFAULT_TOP_RADIUS := 0.0
const DEFAULT_MIDDLE_RADIUS := 0.5
const DEFAULT_BOTTOM_RADIUS := 0.0
const DEFAULT_TOTAL_HEIGHT := 2.0
const DEFAULT_BODY_WIDTH := 1.0
const DEFAULT_BODY_DEPTH := 1.0
const DEFAULT_BOTTOM_RING_HEIGHT := 0.5
const DEFAULT_TOP_RING_HEIGHT := 0.5
const DEFAULT_RADIAL_SEGMENTS := 16


enum CrossSection {
	## Cylindrical prism
	CIRCLE,
	## Box prism
	SQUARE,
}


## Cross-section shape for the main prism body (circle or square).
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NO_EDITOR)
var cross_section: CrossSection = CrossSection.CIRCLE : set = _set_cross_section

## Total height of the prism collider, including top and bottom points.
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NO_EDITOR)
var total_height : float = DEFAULT_TOTAL_HEIGHT : set = _set_total_height

# -- Circle Options --

## Radius of prism collider.
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NO_EDITOR)
var body_radius : float = DEFAULT_MIDDLE_RADIUS : set = _set_body_radius

@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NO_EDITOR)
var radial_segments: int = DEFAULT_RADIAL_SEGMENTS : set = _set_radial_segments

# -- Square Options --

## Width of prism collider
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NO_EDITOR)
var body_width : float = DEFAULT_BODY_WIDTH : set = _set_body_width

## Depth of prism collider
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NO_EDITOR)
var body_depth : float = DEFAULT_BODY_DEPTH : set = _set_body_depth

# -- Top Point Options --

## Radius of the top point of the prism collider, if zero it is a single point.
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NO_EDITOR)
var top_radius : float = DEFAULT_TOP_RADIUS : set = _set_top_radius

## Height of the top point of the prism collider, if zero there is no top point.
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NO_EDITOR)
var top_height : float = DEFAULT_TOP_RING_HEIGHT : set = _set_top_height

# -- Bottom Point Options --

## Radius of the bottom point of the prism collider, if zero it is a single point.
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NO_EDITOR)
var bottom_radius : float = DEFAULT_BOTTOM_RADIUS : set = _set_bottom_radius

## Height of the bottom point of the prism collider, if zero there is no bottom point.
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NO_EDITOR)
var bottom_height : float = DEFAULT_BOTTOM_RING_HEIGHT : set = _set_bottom_height


var new_shape: ConvexPolygonShape3D = ConvexPolygonShape3D.new()


func _ready() -> void:
	_update_collision_shape()


func _set_total_height(value: float) -> void:
	total_height = clampf(value, MIN_HEIGHT, MAX_HEIGHT)
	_update_collision_shape()


func _set_top_radius(new_radius: float) -> void:
	top_radius = max(new_radius, MIN_POINT_RADIUS)
	_update_collision_shape()


func _set_body_radius(new_radius: float) -> void:
	body_radius = max(new_radius, MIN_BODY_RADIUS)
	_update_collision_shape()


func _set_body_width(new_width: float) -> void:
	body_width = max(new_width, MIN_BODY_WIDTH)
	_update_collision_shape()


func _set_body_depth(new_depth: float) -> void:
	body_depth = max(new_depth, MIN_BODY_DEPTH)
	_update_collision_shape()


func _set_bottom_radius(new_radius: float) -> void:
	bottom_radius = max(new_radius, MIN_POINT_RADIUS)
	_update_collision_shape()


func _set_top_height(new_height: float) -> void:
	top_height = clampf(new_height, 0.0, MAX_POINT_HEIGHT)
	_update_collision_shape()


func _set_bottom_height(new_height: float) -> void:
	bottom_height = clampf(new_height, 0.0, MAX_POINT_HEIGHT)
	_update_collision_shape()


func _set_radial_segments(new_radial_segments: int) -> void:
	radial_segments = clamp(new_radial_segments, MIN_RADIAL_SEGMENTS, MAX_RADIAL_SEGMENTS)
	_update_collision_shape()


func _update_collision_shape() -> void:
	var points: PackedVector3Array = _generate_collider_points()
	new_shape.points = points
	shape = new_shape


func _set_cross_section(value: CrossSection) -> void:
	cross_section = value
	_update_collision_shape()
	notify_property_list_changed()


func _add_circle_ring(points: PackedVector3Array, y: float, radius: float) -> void:
	for i in range(radial_segments):
		var angle := TAU * float(i) / radial_segments
		points.append(Vector3(
			cos(angle) * radius,
			y,
			sin(angle) * radius
		))


func _add_square_ring(points: PackedVector3Array, y: float, half_width: float, half_depth: float) -> void:
	points.append(Vector3(-half_width, y, -half_depth))
	points.append(Vector3( half_width, y, -half_depth))
	points.append(Vector3( half_width, y,  half_depth))
	points.append(Vector3(-half_width, y,  half_depth))


func _add_ring_points(points: PackedVector3Array, y: float, radius: float, width: float = 1.0, depth: float = 1.0) -> void:
	match cross_section:
		CrossSection.CIRCLE:
			_add_circle_ring(points, y, radius)
		CrossSection.SQUARE:
			_add_square_ring(points, y, width * 0.5, depth * 0.5)


func _generate_collider_points() -> PackedVector3Array:
	var points: PackedVector3Array = []

	var body_height := total_height - (top_height + bottom_height)
	var half_height := total_height * 0.5
	var body_top_y := half_height - top_height
	var body_bottom_y := -half_height + bottom_height

	if (is_zero_approx(body_height)):
		# If body height is zero, collapse to a single ring
		body_top_y = 0.0
		body_bottom_y = 0.0
		_add_ring_points(points, 0.0, body_radius)
	else:
		# Add ring of points for top point
		_add_ring_points(points, body_top_y, body_radius, body_width, body_depth)

		# Add ring of points for bottom point
		_add_ring_points(points, body_bottom_y, body_radius, body_width, body_depth)

	if (is_zero_approx(top_radius)):
		# If top radius is zero, add center point
		points.append(Vector3(0, body_top_y + top_height, 0))
	else:
		# Add ring of points at top height
		_add_ring_points(points, body_top_y + top_height, top_radius, top_radius, top_radius)

	if (is_zero_approx(bottom_radius)):
		# If bottom radius is zero, add center point
		points.append(Vector3(0, body_bottom_y - bottom_height, 0))
	else:
		# Add ring of points at bottom height
		_add_ring_points(points, body_bottom_y - bottom_height, bottom_radius, bottom_radius, bottom_radius)

	return points

func _get_property_list() -> Array:
	var props = []

	props.append({
		"name": &"Shape Setting",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_SUBGROUP
	})

	props.append({
		"name": &"cross_section",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": &"Circle,Square",
		"usage": PROPERTY_USAGE_DEFAULT,
		"category": &"Shape Options"
	})

	props.append({
		"name": &"total_height",
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": &"%d,%d,0.001" % [MIN_HEIGHT, MAX_HEIGHT],
		"usage": PROPERTY_USAGE_DEFAULT,
		"category": &"Shape Options"
	})

	if (cross_section == CrossSection.CIRCLE):
		props.append({
			"name": &"body_radius",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": &"%d,%d,0.001" % [MIN_BODY_RADIUS, MAX_BODY_RADIUS],
			"usage": PROPERTY_USAGE_DEFAULT,
		})

		props.append({
			"name": &"radial_segments",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": &"%d,%d,1" % [MIN_RADIAL_SEGMENTS, MAX_RADIAL_SEGMENTS],
			"usage": PROPERTY_USAGE_DEFAULT,
		})
	else:
		props.append({
			"name": &"body_width",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": &"%d,%d,0.001" % [MIN_BODY_WIDTH, MAX_BODY_WIDTH],
			"usage": PROPERTY_USAGE_DEFAULT,
		})

		props.append({
			"name": &"body_depth",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": &"%d,%d,0.001" % [MIN_BODY_DEPTH, MAX_BODY_DEPTH],
			"usage": PROPERTY_USAGE_DEFAULT,
			"category": &"Shape Options"
		})

	props.append({
		"name": &"Top Point Settings",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_SUBGROUP
	})

	props.append({
			"name": &"top_radius",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": &"%d,%d,0.001" % [MIN_POINT_RADIUS, MAX_POINT_RADIUS],
			"usage": PROPERTY_USAGE_DEFAULT,
	})

	props.append({
			"name": &"top_height",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": &"0,%d,0.001" % MAX_POINT_HEIGHT,
			"usage": PROPERTY_USAGE_DEFAULT,
	})

	props.append({
		"name": &"Bottom Point Settings",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_SUBGROUP
	})

	props.append({
			"name": &"bottom_radius",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": &"%d,%d,0.001" % [MIN_POINT_RADIUS, MAX_POINT_RADIUS],
			"usage": PROPERTY_USAGE_DEFAULT,
	})

	props.append({
			"name": &"bottom_height",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": &"0,%d,0.001" % MAX_POINT_HEIGHT,
			"usage": PROPERTY_USAGE_DEFAULT,
	})

	return props
