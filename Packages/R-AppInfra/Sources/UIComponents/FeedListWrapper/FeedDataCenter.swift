import Foundation


// MARK: - FeedDataCenter Protocol

public protocol FeedDataCenter: AnyObject {
    func currentSectionBeans() -> [FeedListSectionBean]

    func loadData(completion: @escaping (Result<[FeedListSectionBean], any Error>) -> Void)
    func loadMoreData(completion: @escaping (Result<[FeedListSectionBean], any Error>) -> Void)

    func insertData(_ newData: [FeedListSectionBean], at index: Int)
    func deleteData(at indices: IndexSet)
    func updateData(_ updatedData: [FeedListSectionBean], at indices: IndexSet)
}

// MARK: - FeedDataCenter Default Implementation

public extension FeedDataCenter {
    func currentSectionBeans() -> [FeedListSectionBean] {
        return []
    }

    func loadData(completion: @escaping (Result<[FeedListSectionBean], any Error>) -> Void) {
        completion(.success([]))
    }

    func loadMoreData(completion: @escaping (Result<[FeedListSectionBean], any Error>) -> Void) {
        completion(.success([]))
    }

    func insertData(_: [FeedListSectionBean], at _: Int) {}

    func deleteData(at _: IndexSet) {}

    func updateData(_: [FeedListSectionBean], at _: IndexSet) {}
}

// MARK: - BaseFeedDataCenter

open class BaseFeedDataCenter: FeedDataCenter {
    public var _sectionBeans: [FeedListSectionBean] = []

    public init() {}

    open func currentSectionBeans() -> [FeedListSectionBean] {
        return _sectionBeans
    }

    open func loadData(completion: @escaping (Result<[FeedListSectionBean], any Error>) -> Void) {
        completion(.success(_sectionBeans))
    }

    open func loadMoreData(completion: @escaping (Result<[FeedListSectionBean], any Error>) -> Void) {
        completion(.success(_sectionBeans))
    }

    open func insertData(_ newData: [FeedListSectionBean], at index: Int) {
        _sectionBeans.insert(contentsOf: newData, at: index)
    }

    open func deleteData(at indices: IndexSet) {
        // todo
//        _sectionBeans.remove(atOffsets: indices)
    }

    open func updateData(_ updatedData: [FeedListSectionBean], at indices: IndexSet) {
        for (index, updatedBean) in zip(indices, updatedData) {
            _sectionBeans[index] = updatedBean
        }
    }
}
