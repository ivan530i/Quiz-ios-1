import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var shouldShowBorder = false
    private let questionsAmount: Int = 10
    private var isAnswerProcessing = false
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestions: QuizQuestion?
    private var statisticService: StatisticService = StatisticServiceImplementation()
    private lazy var alertPresenter: AlertPresenter = {
        return AlertPresenter(presentViewController: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()
        questionFactory?.delegate = self
        resetImageBorder()
        showLoadingIndicator()
        questionFactory?.loadData()
        questionFactory?.requestNextQuestion()
    }
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        isAnswerProcessing = false
        guard let question = question else {
            return
        }
        
        currentQuestions = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter.presentAlert(with: model, extraInfo: "")
    }
    
    private func updateButtonState(isEnabled: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.yesButton.isEnabled = isEnabled
            self?.noButton.isEnabled = isEnabled
        }
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestions, !isAnswerProcessing else {
            return
        }
        isAnswerProcessing = true
        let humanAnswer = true
        
        showAnswerResult(isCorrect: humanAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestions, !isAnswerProcessing else {
            return
        }
        isAnswerProcessing = true
        let humanAnswer = false
        showAnswerResult(isCorrect: humanAnswer == currentQuestion.correctAnswer)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        shouldShowBorder = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let text = correctAnswers == questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10!" :
            "Ваш результат: \(correctAnswers)/\(questionsAmount)"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        resetImageBorder()
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let playedGamesCount = statisticService.gamesCount
        let bestGameRecord = statisticService.bestGame
        let totalAccuracy = statisticService.totalAccuracy
        
        var extraInfo = "\nКоличество сыгранных квизов: \(playedGamesCount)"
        extraInfo += "\nРекорд: \(bestGameRecord.correct)/\(bestGameRecord.total) (\(bestGameRecord.date.dateTimeString))"
        
        extraInfo += "\nСредняя точность: \(String(format: "%.2f", totalAccuracy))%"
        
        let alertModel = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.shouldShowBorder = false
            self.resetImageBorder()
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter.presentAlert(with: alertModel, extraInfo: extraInfo)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    private func resetImageBorder() {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
    }
}
