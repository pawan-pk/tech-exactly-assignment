//
//  NotesRepository.swift
//  TechExactly
//
//  Created by Pawan Kushwaha on 19/03/26.
//

import UIKit
import CoreData

protocol NotesRepositoryProtocol {
    func delete(note: Note) -> Bool
    func fetchNotesList() -> [Note]
}

class NotesRepository: NotesRepositoryProtocol {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer.viewContext) {
        self.context = context
    }

    func delete(note: Note) -> Bool {
        context.delete(note)
        do {
            try context.save()
            return true
        } catch {
            print("Delete note error: \(error)")
            return false
        }
    }
    
    func fetchNotesList() -> [Note] {
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        do {
            let notes = try context.fetch(fetchRequest)
            return notes
        } catch {
            print("Fetch error: \(error)")
        }
        return []
    }
}

