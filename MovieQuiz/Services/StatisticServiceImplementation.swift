
import Foundation

class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount, totalCorrectAnswers
    }
    
    func store(correct count: Int, total amount: Int) {
        
        var playedGamesCount = gamesCount
        playedGamesCount += 1
        userDefaults.set(playedGamesCount, forKey: Keys.gamesCount.rawValue)
        
        let totalCorrect = userDefaults.integer(forKey: Keys.totalCorrectAnswers.rawValue) + count
        userDefaults.set(totalCorrect, forKey: Keys.totalCorrectAnswers.rawValue)
        
        let totalQuestions = userDefaults.integer(forKey: Keys.total.rawValue) + amount
        userDefaults.set(totalQuestions, forKey: Keys.total.rawValue)
        
        let currentGameRecord = GameRecord(correct: count, total: amount, date: Date())
        let bestGameRecord = bestGame
        
        if currentGameRecord.isBetterThan(bestGameRecord) {
            bestGame = currentGameRecord
        }
    }
    
    var totalAccuracy: Double {
        let totalCorrect = userDefaults.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        let totalQuestions = userDefaults.integer(forKey: Keys.total.rawValue)
        
        guard totalQuestions > 0 else {
            return 0.0
        }
        
        return Double(totalCorrect) / Double(totalQuestions) * 100.0
    }
    
    var gamesCount: Int {
        return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return GameRecord(correct: 0, total: 0, date: Date())
            }
            
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
}

