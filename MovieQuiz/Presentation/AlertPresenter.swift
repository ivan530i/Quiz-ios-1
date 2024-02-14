
import Foundation
import UIKit

final class AlertPresenter {
    private weak var presentViewController : UIViewController?
    
    init(presentViewController: UIViewController?) {
        self.presentViewController = presentViewController
    }
    
    func presentAlert(with model: AlertModel, extraInfo: String) {
        guard let presentViewController = presentViewController else {
            return
        }
        
        let alert = UIAlertController(title: model.title, message: model.message + extraInfo, preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion?()
        }
        alert.addAction(action)
        
        presentViewController.present(alert, animated: true, completion: nil)
    }
}
