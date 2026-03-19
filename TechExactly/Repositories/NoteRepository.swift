//
//  NoteRepository.swift
//  TechExactly
//
//  Created by Pawan Kushwaha on 19/03/26.
//

import UIKit
import CoreData

protocol NoteRepositoryProtocol {
    func add(title: String, _ content: NSAttributedString?) -> Note?
    func update(id: UUID, title: String, _ content: NSAttributedString?) -> Note?
    func get(id: UUID) -> Note?
}

class NoteRepository: NoteRepositoryProtocol {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer.viewContext) {
        self.context = context
    }
    
    func add(title: String, _ content: NSAttributedString? = nil) -> Note? {
        let newNote = Note(context: context)
        newNote.id = UUID()
        newNote.title = title

        if let attributedText = content {
            do {
                newNote.content = try NSKeyedArchiver.archivedData(
                    withRootObject: attributedText, requiringSecureCoding: false
                )
            } catch {
                print("Error archiving content: \(error)")
                return nil
            }
        }

        do {
            try context.save()
            return newNote
        } catch {
            print("Error saving note: \(error)")
            return nil
        }
    }
    
    func update(id: UUID, title: String, _ content: NSAttributedString? = nil) -> Note? {
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let existingNote = try context.fetch(fetchRequest).first {
                existingNote.title = title
                
                if let attributedText = content {
                    let archivedData = try NSKeyedArchiver.archivedData(
                        withRootObject: attributedText,
                        requiringSecureCoding: false
                    )
                    existingNote.content = archivedData
                }
                
                try context.save()
                return existingNote
            } else {
                print("Note with id \(id) not found")
                return nil
            }
        } catch {
            print("Error updating note: \(error)")
            return nil
        }
    }
    
    func get(id: UUID) -> Note? {
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Failed to fetch Note with id \(id): \(error)")
            return nil
        }
    }
}
