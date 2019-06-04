//
//  CSVExporterVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 6/2/19.
//  Copyright © 2019 Alexander Koryttsev. All rights reserved.
//

import Foundation

class CSVExporterVM : BaseVM {
    let monthes : [LocalDate]
    var selectedMothes = [LocalDate().trimDay]
    unowned let router : MyGraphRouter

    init(_ router: MyGraphRouter) {
        self.router = router
        var mutableMonthes = [LocalDate]()
        var month = LocalDate().trimDay
        for _ in 1...12 {
            mutableMonthes.append(month)
            month = month.add(months: -1)
        }
        monthes = mutableMonthes
        super.init()
    }

    func select(month:LocalDate) {
        if selectedMothes.contains(month) {
            selectedMothes.remove(at: selectedMothes.index(of: month)!)
        }
        else {
            selectedMothes.append(month)
        }
    }

    func generateCSV() -> [URL] {
        let user = Main.service.currentUser!
        var urls = [URL]()

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.zero
        dateFormatter.dateFormat = "LL_YY"

        for month in selectedMothes.sorted().reversed() {
            let fileName = "\(user.name)-\("sadhana".localized)-\(dateFormatter.string(from: month.date)).csv"
            let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
            var csvText = "🗓"

            if user.wakeUpTimeEnabled {
                csvText.appendCSV("☀️")
            }

            csvText.appendCSV("🎹")
            csvText.appendCSV("📖")

            if user.serviceEnabled {
                csvText.appendCSV("🦶")
            }
            if user.exerciseEnabled {
                csvText.appendCSV("🧘‍♂️")
            }
            if user.lectionsEnabled {
                csvText.appendCSV("🎧")
            }
            if user.bedTimeEnabled {
                csvText.appendCSV("🌙")
            }
            csvText.appendCSV("7:30")
            csvText.appendCSV("10:00")
            csvText.appendCSV("18:00")
            csvText.appendCSV("00:00")

            for entry in Local.service.viewContext.fetchEntries(by: month, userID: user.ID) {
                var newLine = "\n\(entry.localDate.day)"

                if user.wakeUpTimeEnabled {
                    newLine.appendCSV(string(from:entry.wakeUpTime))
                }

                newLine.appendCSV(string(from:entry.kirtan))
                newLine.appendCSV(string(from:entry.reading.rawValue))

                if user.serviceEnabled {
                    newLine.appendCSV(string(from:entry.service))
                }
                if user.exerciseEnabled {
                    newLine.appendCSV(string(from:entry.yoga))
                }
                if user.lectionsEnabled {
                    newLine.appendCSV(string(from:entry.lections))
                }
                if user.bedTimeEnabled {
                    newLine.appendCSV(string(from:entry.bedTime))
                }

                newLine.appendCSV(string(from:entry.japaCount7_30))
                newLine.appendCSV(string(from:entry.japaCount10))
                newLine.appendCSV(string(from:entry.japaCount18))
                newLine.appendCSV(string(from:entry.japaCount24))

                csvText.append(newLine)
            }

            log("CSV text:\n \(csvText)")

            do {
                try csvText.write(to: path, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                print("Failed to create file")
                print("\(error)")
            }

            urls.append(path)
        }
        return urls
    }

    @objc func close() {
        router.hideCSVExport()
    }

    @objc func done() {
        router.doneCSVExport(with: generateCSV())
    }

    func string(from bool: Bool) -> String {
        return bool ? "✔️" : ""
    }

    func string(from time: Time?) -> String {
        return time?.string ?? ""
    }

    func string(from int: Int16) -> String {
        return int > 0 ? int.description : ""
    }
}
