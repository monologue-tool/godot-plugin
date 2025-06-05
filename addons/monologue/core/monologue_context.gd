class_name MonologueContext extends Node


var timeline: MonologueTimeline
var settings: MonologueProcessSettings

var nodes: Array :
	get: return timeline.node_list
var next_node_id: String = ""

var options: Dictionary :
	get: return timeline.options
var variables: Dictionary :
	get: return timeline.variables
var characters: Array :
	get: return timeline.characters
var images: MonologueResourceManager :
	get: return timeline.images
var audios: MonologueResourceManager :
	get: return timeline.audios


func get_next_node() -> Dictionary:
	return timeline.get_node_from_id(next_node_id)


func display_text(text: String, speaker_name: String = "", override_speed: int = settings.text_speed) -> void:
	timeline.text_box.display(text, speaker_name, override_speed)
	await timeline.text_box.display_finished


func get_node_from_id(node_id: String) -> Dictionary: return timeline.get_node_from_id(node_id)
func get_nodes_from_type(type: String) -> Array: return timeline.get_nodes_from_type(type)
func get_character_from_idx(character_idx: int) -> Dictionary:
	for character in characters:
		if character.get("EditorIndex", -1) == character_idx:
			return character
	return {}

## Example:
## {{ if <variable> then "true" else "false" }}
## {{ if <variable> == <value> then "true" else "false" }}
func process_conditional_text(text: String) -> String:
	var regex = RegEx.new()
	regex.compile("(?<=\\{{)(.*?)(?=\\}})")
	var results = regex.search_all(text)
	for result in results:
		var target = result.get_string()
		var replacement = str(evaluate_expression(substitute_variables(target)))
		if target != replacement:
			text = text.replace("{{" + target + "}}", replacement)
	return text


func evaluate_expression(expression: String) -> Variant:
	if expression.contains("if"):
		# split into two parts from "then" clause
		var t_split = expression.split("then", false, 1)
		if t_split.size() > 1:
			# the first element is the "if <<variable>>" clause
			var check = t_split[0].strip_edges().trim_prefix("if").lstrip(" ")

			# evaluate condition check to has_passed
			var has_passed = false
			var checker = Expression.new()
			if checker.parse(check) == OK:
				var conditional = checker.execute([], checker, false)
				if not checker.has_execute_failed() and conditional:
					has_passed = bool(conditional)

			# select then or else clause depending on has_passed
			var e_split = t_split[1].rsplit("else", false, 1)
			if has_passed:
				var then_value = e_split[0].strip_edges().trim_prefix("then")
				return evaluate_expression(then_value.lstrip(" "))
			else:
				var else_value = e_split[1] if e_split.size() > 1 else ""
				return evaluate_expression(else_value.strip_edges())

	var parser = Expression.new()
	var result = null
	if expression:
		parser.parse(expression)
		result = parser.execute([], parser, false)
	return expression if parser.has_execute_failed() or not result else result


func substitute_variables(expression: String) -> String:
	var subber = RegEx.new()
	subber.compile("['\"]?[a-zA-Z][\\w]*['\"]?")
	var results = subber.search_all(expression)
	var start = 0
	var builder = ""

	for result in results:
		var text = result.get_string()
		if text.contains('"') or text.contains("'"):
			continue

		var variable = variables.get(text)
		if variable:
			var value = str(variable.get("Value"))
			# encase value in quotes if type is String
			if variable.get("Type") == "String":
				value = '"' + value + '"'
			builder += expression.substr(start, result.get_start() - start)
			builder += value
			start = result.get_end()

	builder += expression.substr(start, expression.length() - start)
	return builder
