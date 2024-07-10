import Foundation
import RoomPlan

class ViewModel: NSObject, ObservableObject {
    @Published var selectedSensor: Sensor?
    @Published var sensorList: [Sensor] = []
    var Index: Int = 0
    
    var title: String {
        "\(selectedSensor?.getTag())" ?? ""
    }

    func selectNextSensor() {
        changeSelection(offset: 1)
    }

    func selectPreviousSensor() {
        changeSelection(offset: -1)
    }

    func clearSelection() {
        selectedSensor = nil
    }

    private func changeSelection(offset: Int) {
        let newIndex = Index + offset

        if newIndex < 0 {
            Index = sensorList.endIndex-1
        } else if newIndex < sensorList.endIndex {
            Index = newIndex
        } else {
            Index = 0
        }
        self.selectedSensor = sensorList[Index]
    }
}
