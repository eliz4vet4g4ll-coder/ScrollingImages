import Foundation

extension Array {
    // возвращает копию массива с замененным элементом
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
        var array = self
        array[index] = newValue
        return array
    }
}
