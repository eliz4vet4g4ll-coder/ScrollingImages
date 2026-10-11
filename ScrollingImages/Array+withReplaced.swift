import Foundation

extension Array {
    // возвращает копию массива, в которой элемент по индексу index заменён на newValue
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
        var array = self
        array[index] = newValue
        return array
    }
}
