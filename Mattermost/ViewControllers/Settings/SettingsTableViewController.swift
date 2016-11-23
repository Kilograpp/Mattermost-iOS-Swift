//
//  SettingsViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 30.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

// CODEREVIEW: Финализировать не забываем
class SettingsTableViewController: UITableViewController {

// CODEREVIEW: Лишняя марка. Они должны оглавлять только extensions
//MARK: - Properties
    
    // CODEREVIEW: Нужно сделать UISwitch force unwrapped типа
    @IBOutlet weak var imagesCompressSwitch: UISwitch?
    
// CODEREVIEW: Лишняя марка
//MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialSetup()
        // Do any additional setup after loading the view.
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.menuContainerViewController.panMode = .init(3)
        
        super.viewWillDisappear(animated)
    }
}


//MARK: - Setup
// CODEREVIEW: Лишняя новая строка. Марка должна прилипать к extension
// CODEREVIEW: Нужен протокол для  extensions. Либо внешений, либо внутренний

extension SettingsTableViewController {
    // CODEREVIEW: Метод должен быть fileprivate
    func initialSetup() {
        // CODEREVIEW: Код в комментах - зло. Git все помнит, можно смело удалять. Либо починить причину коммента
       // setupimagesCompressSwitch()
        self.menuContainerViewController.panMode = .init(0)
    }
    
    // CODEREVIEW: Опечатка, images с большой буквы должно быть.
    // CODEREVIEW: Метод должен быть fileprivate
    func setupimagesCompressSwitch() {
        self.imagesCompressSwitch?.setOn((Preferences.sharedInstance.shouldCompressImages?.boolValue)!, animated: false)
    }
}


//MARK: - Private
// CODEREVIEW: Нужен протокол
extension SettingsTableViewController {
    // CODEREVIEW: Метод должен быть fileprivate
    func toggleShouldCompressValue() {
        // CODEREVIEW: в слове init нет небходимости
        // CODEREVIEW: лишние кастование к булу
        // CODEREVIEW: shouldCompressImages в PReferences нужно сделать булом, оно умеет с ними работать
        Preferences.sharedInstance.shouldCompressImages = NSNumber.init(value: (self.imagesCompressSwitch?.isOn)! as Bool)
        // CODEREVIEW: save не должен быть в момент изменения данных, только когда точно надо сохранить, по выходу с контроллера, например
        Preferences.sharedInstance.save()
    }
}


//MARK: - Actions
// CODEREVIEW: Нужен протокол
extension SettingsTableViewController {
    // CODEREVIEW: Метод должен быть fileprivate
    func backAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shouldCompressValueChanged(_ sender: AnyObject) {
        toggleShouldCompressValue()
    }
}


//MARK: - UITableViewDelegate
// CODEREVIEW: Нужен протокол, в данном случае внешний: UITableViewDelegate
extension SettingsTableViewController {
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        // CODEREVIEW: Два одинаковых куска кода. Объединить в один метод
        let footer = view as! UITableViewHeaderFooterView
        footer.textLabel!.font = UIFont.kg_regular13Font()
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel!.font = UIFont.kg_regular13Font()
    }
}

