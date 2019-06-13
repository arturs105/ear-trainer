protocol ViewModelLocator {
    func getLessonListViewModel() -> ExerciseListViewModel
    func getLessonViewModel(for exercise: SingleNoteExercise, and instrument: Instrument) -> ExerciseViewModel
}

class DefaultViewModelLocator : ViewModelLocator {
    private let audioService = DefaultAudioService()
    
    func getLessonListViewModel() -> ExerciseListViewModel {
        return ExerciseListViewModel(audioService: audioService)
    }
    
    func getLessonViewModel(for exercise: SingleNoteExercise, and instrument: Instrument) -> ExerciseViewModel {
        return ExerciseViewModel(for: exercise, instrument: instrument, audioService: audioService)
    }
}
