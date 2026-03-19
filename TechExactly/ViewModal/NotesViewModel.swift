//
//  NotesViewModel.swift
//  TechExactly
//
//  Created by Pawan Kushwaha on 19/03/26.
//
import Foundation

class NotesViewModel: NSObject {
    var repository: NotesRepositoryProtocol?
    var changeHandler: (() -> Void)?
    private(set) var notes: [Note] = []

    init(repository: NotesRepositoryProtocol? = nil) {
        self.repository = repository
    }
    
    func fetchList() {
        notes = repository?.fetchNotesList() ?? []
        print("Notes count: \(notes.count)")
        emit()
    }
    
    func emit() {
        if let changeHandler = changeHandler {
            changeHandler()
        }
    }

    func deleteSelectedNote(index: Int) {
        let status = repository?.delete(note: notes[index])
        print("note successfully deleted: \(status ?? false)")
        notes.remove(at: index)
        emit()
    }
}
