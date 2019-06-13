protocol ViewModelLocator {
    func getLessonListViewModel() -> ExerciseListViewModel
    func getChooseInstrumentViewModel() -> ChooseInstrumentViewModel
    func getLessonViewModel(for exercise: Exercise) -> ExerciseViewModel
}

class DefaultViewModelLocator : ViewModelLocator {
    private let audioService = DefaultAudioService()
    private let instrumentService = DefaultInstrumentService()
    
    func getLessonListViewModel() -> ExerciseListViewModel {
        return ExerciseListViewModel(audioService: audioService)
    }
    
    func getLessonViewModel(for exercise: Exercise) -> ExerciseViewModel {
        return try! ExerciseViewModel(for: exercise, instrumentService: instrumentService, audioService: audioService)
    }
    
    func getChooseInstrumentViewModel() -> ChooseInstrumentViewModel {
        return ChooseInstrumentViewModel(instrumentService: instrumentService)
    }
}
