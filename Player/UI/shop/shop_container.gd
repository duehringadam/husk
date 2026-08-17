extends GridContainer

func adjust_column_count():
	self.columns = int(get_parent().size.x/100)
