package godebug

func New(str string) *Settings {
	return &Settings{}
}

type Settings struct {
}

func (s *Settings) Value() string {
	return ""
}

func (s *Settings) IncNonDefault() {
	
}
