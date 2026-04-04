extends Resource
class_name CutoffBuckets

var input_cutoffs: Array[float]
var outputs: Array[float] # needs to be of length [input_cutoffs.size() + 1] if allow_beyond, otherwise the same as input_cutoffs
var allow_beyond: bool # returns a sort of default if input is bigger than all buckets, otherwise returns the last bucket

static func create(input_cutoffs_in: Array[float], outputs_in: Array[float], allow_beyond_in: bool = true) -> CutoffBuckets:
	var required_size: int = input_cutoffs_in.size()
	if allow_beyond_in:
		required_size += 1
	
	if not (outputs_in.size() == required_size and input_cutoffs_in.size() > 0):
		return null
	
	var new_cutoff: CutoffBuckets = CutoffBuckets.new()
	
	new_cutoff.input_cutoffs = input_cutoffs_in
	new_cutoff.outputs = outputs_in
	new_cutoff.allow_beyond = allow_beyond_in
	
	return new_cutoff

func add_bucket(input: float, output: float, overflow: float = -INF) -> CutoffBuckets:
	if outputs.size() == 0 and allow_beyond:
		outputs.push_front(overflow)
	
	var insertion_position: int = 0
	while insertion_position < input_cutoffs.size() and input_cutoffs[insertion_position] < input:
		insertion_position += 1
	
	input_cutoffs.insert(insertion_position, input)
	outputs.insert(insertion_position, output)
	
	return self

func get_output(input: float) -> float:
	var get_index: int = 0
	while get_index < input_cutoffs.size() and input_cutoffs[get_index] < input:
		get_index += 1
	
	if get_index < input_cutoffs.size():
		return outputs[get_index]
	
	if not allow_beyond:
		return outputs.back()
	
	return outputs[get_index]
