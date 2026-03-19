//
//  NoteViewModel.swift
//  TechExactly
//
//  Created by Pawan Kushwaha on 19/03/26.
//

import Foundation

class NoteViewModel: NSObject {
    var repository: NoteRepositoryProtocol?
    var changeHandler: (() -> Void)?
    var note: Note? = nil

    init(repository: NoteRepositoryProtocol? = nil) {
        self.repository = repository
    }
    
    func emit() {
        if let changeHandler = changeHandler {
            changeHandler()
        }
    }

    func add(title: String, content: NSAttributedString?) {
        note = repository?.add(title: title, content)
    }
    
    func update(id: UUID, title: String, content: NSAttributedString?) {
        note = repository?.update(id: id, title: title, content)
    }
    
    func fetchNote(id: UUID) {
        note = repository?.get(id: id)
    }
}

