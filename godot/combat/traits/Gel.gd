extends Trait

func validate():
	.validate()
	assert(host.has_method('is_escapable'))
	if host.is_escapable():
		assert(host.has_method('get_half_angle'))
	
