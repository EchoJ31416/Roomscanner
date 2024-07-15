import Foundation
import RoomPlan

class ViewModel: NSObject, ObservableObject {
    @Published var selectedDevice: Device?
    @Published var deviceList: [Device] = []
    var Index: Int = 0
    
    var title: String {
        "\(selectedDevice?.getTag())" ?? ""
    }

    func selectNextDevice() {
        changeSelection(offset: 1)
    }

    func selectPreviousDevice() {
        changeSelection(offset: -1)
    }

    func clearSelection() {
        selectedDevice = nil
    }

    private func changeSelection(offset: Int) {
        let newIndex = Index + offset

        if newIndex < 0 {
            Index = deviceList.endIndex-1
        } else if newIndex < deviceList.endIndex {
            Index = newIndex
        } else {
            Index = 0
        }
        self.selectedDevice = deviceList[Index]
    }
}
