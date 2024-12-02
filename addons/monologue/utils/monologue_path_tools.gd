class_name MonologuePathTool extends RefCounted


static func split_path(path: String) -> PackedStringArray:
	var splt_path: String = path.replace(path.get_file(), "")
	splt_path = splt_path.replace("\\", "/")
	splt_path = splt_path.replace("//", "/")
	return splt_path.split("/", false)


static func relative_to_absolute(path: String, base_path: String) -> String:
	if path.is_absolute_path():
		return path
	
	var root_array: PackedStringArray = split_path(base_path)
	var path_array: PackedStringArray = split_path(path)
	
	var back_count = path.count("..")
	var core_path = Array(root_array).slice(0, root_array.size()-back_count)
	var to_file = Array(path_array).slice(back_count)
	var final_path = Array(core_path) + to_file
	
	final_path.append(path.get_file())
	var absolute_path = ""
	for step in final_path:
		absolute_path = absolute_path.path_join(step)
	
	# if root path is not a Windows drive letter, prepend "/" linux root
	var drive_matcher = RegEx.new()
	drive_matcher.compile("[a-zA-Z]:")
	var drive_result = root_array.size() > 0 and drive_matcher.search(root_array[0])
	if not drive_result:
		absolute_path = "/" + absolute_path
	
	return absolute_path
