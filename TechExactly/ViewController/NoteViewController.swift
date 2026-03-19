//
//  NoteViewController.swift
//  TechExactly
//
//  Created by Pawan Kushwaha on 19/03/26.
//

import UIKit

class NoteViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var noteTitle: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    
    // MARK: - Variables
    var noteId: UUID?
    var viewModel: NoteViewModel?
    let checklistFont = UIFont.systemFont(ofSize: 16)
    
    // MARK: - Controller functions
    override func viewDidLoad() {
        super.viewDidLoad()
        bindingViewModel()
        setupView()
        loadNote()
    }
    
    // MARK: - Actions
    @IBAction func boldPressAction(_ sender: UIButton) {
        let range = noteTextView.selectedRange
        guard range.length > 0 else { return }
        let mutableAttrText = NSMutableAttributedString(attributedString: noteTextView.attributedText)
        mutableAttrText.toggleFontTrait(.traitBold, in: range)
        noteTextView.attributedText = mutableAttrText
        noteTextView.selectedRange = range
    }
    
    @IBAction func italicPressAction(_ sender: UIButton) {
        let range = noteTextView.selectedRange
        guard range.length > 0 else { return }
        let mutableAttrText = NSMutableAttributedString(attributedString: noteTextView.attributedText)
        mutableAttrText.toggleFontTrait(.traitItalic, in: range)
        noteTextView.attributedText = mutableAttrText
        noteTextView.selectedRange = range
    }
    
    @IBAction func underlinePressAction(_ sender: UIButton) {
        let range = noteTextView.selectedRange
        guard range.length > 0 else { return }
        let mutableAttrText = NSMutableAttributedString(attributedString: noteTextView.attributedText)
        mutableAttrText.toggleUnderlineStyle(in: range)
        noteTextView.attributedText = mutableAttrText
        noteTextView.selectedRange = range
    }
    
    @objc func saveNoteAction(_ sender: UIBarButtonItem) {
        if let noteId {
            viewModel?.update(id: noteId, title: noteTitle.text ?? "New Note", content: noteTextView.attributedText)
        } else {
            viewModel?.add(title: noteTitle.text ?? "New Note", content: noteTextView.attributedText)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc func checklistNoteAction(_ sender: UIBarButtonItem) {
        insertChecklistItem()
    }
    
    private func insertChecklistItem() {
        let attrText = NSMutableAttributedString(attributedString: noteTextView.attributedText ?? NSAttributedString())
        let range = noteTextView.selectedRange

        let checkbox = uncheckedAttachment()

        let space = NSAttributedString(string: " ", attributes: [.font: checklistFont])

        let newItem = NSMutableAttributedString()
        newItem.append(checkbox)
        newItem.append(space)

        if range.location > 0 {
            newItem.insert(NSAttributedString(string: "\n", attributes: [.font: checklistFont]), at: 0)
        }

        attrText.insert(newItem, at: range.location)

        noteTextView.attributedText = attrText
        noteTextView.selectedRange = NSRange(location: range.location + newItem.length, length: 0)
    }
    
    @objc private func handleChecklistTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: noteTextView)
        
        guard let position = noteTextView.closestPosition(to: location) else { return }
        let index = noteTextView.offset(from: noteTextView.beginningOfDocument, to: position)
        
        let attrText = noteTextView.attributedText ?? NSAttributedString()
        
        guard index < attrText.length else { return }
        
        if let _ = attrText.attribute(.attachment, at: index, effectiveRange: nil) as? NSTextAttachment {
            toggleAttachment(at: index)
        }
    }

    private func toggleAttachment(at index: Int) {
        let attrText = NSMutableAttributedString(attributedString: noteTextView.attributedText)
        
        guard index < attrText.length else { return }
        
        let attribute = attrText.attribute(.attachment, at: index, effectiveRange: nil)
        
        guard attribute is NSTextAttachment else { return }
        
        let currentAttachment = attribute as! NSTextAttachment
        let image = currentAttachment.image
        
        let newAttachment: NSAttributedString
        
        if image == UIImage(systemName: "circle") {
            newAttachment = checkedAttachment()
        } else {
            newAttachment = uncheckedAttachment()
        }
        
        attrText.replaceCharacters(in: NSRange(location: index, length: 1), with: newAttachment)
        
        noteTextView.attributedText = attrText
    }
    
    // MARK: - Custom Functions
    private func bindingViewModel() {
        let repository = NoteRepository()
        viewModel = NoteViewModel(repository: repository)
    }
    
    private func setupView() {
        // Navigation Bar
        title = "Note"
        let saveButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveNoteAction(_ :)))
        let checklistButton = UIBarButtonItem(image: UIImage(systemName: "checklist"), style: .plain, target: self, action: #selector(checklistNoteAction(_ :)))
        navigationItem.rightBarButtonItems = [saveButton, checklistButton]
        
        // Text Title Delegates
        noteTitle.delegate = self
        
        // Text View Delegates
        noteTextView.delegate = self
        noteTextView.autocorrectionType = .no
        
        // toggle checks
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleChecklistTap(_:)))
        noteTextView.addGestureRecognizer(tapGesture)
    }
    
    func uncheckedAttachment() -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: "circle")
        attachment.bounds = CGRect(x: 0, y: -3, width: 18, height: 18)
        return NSAttributedString(attachment: attachment)
    }

    func checkedAttachment() -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: "checkmark.circle.fill")
        attachment.bounds = CGRect(x: 0, y: -3, width: 18, height: 18)
        return NSAttributedString(attachment: attachment)
    }
    
    private func loadNote() {
        if let id = noteId {
            viewModel?.fetchNote(id: id)
        }
        noteTitle.text = viewModel?.note?.title
        let attrText = viewModel?.note?.content.attributedStr ?? NSAttributedString()
        let currentText = NSMutableAttributedString(attributedString: attrText)
        currentText.addAttribute(.font, value: checklistFont, range: NSRange(location: 0, length: currentText.length))
        noteTextView.attributedText = currentText
    }
}

extension NoteViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            guard let attrText = textView.attributedText else { return true }
            let nsText = attrText.string as NSString
            let lineRange = nsText.lineRange(for: range)

            guard lineRange.location < attrText.length else {
                let mutable = NSMutableAttributedString(attributedString: attrText)
                let newLine = NSAttributedString(string: "\n", attributes: [.font: UIFont.systemFont(ofSize: 16)])
                mutable.append(newLine)
                textView.attributedText = mutable
                textView.selectedRange = NSRange(location: mutable.length, length: 0)
                return false
            }

            let hasAttachment = attrText.attribute(.attachment, at: lineRange.location, effectiveRange: nil) is NSTextAttachment

            if hasAttachment {
                let lineText = nsText.substring(with: lineRange).trimmingCharacters(in: .whitespacesAndNewlines)

                if lineText.isEmpty || lineText == "￼" {
                    let mutable = NSMutableAttributedString(attributedString: attrText)
                    mutable.replaceCharacters(in: lineRange, with: NSAttributedString(string: "\n", attributes: [.font: UIFont.systemFont(ofSize: 16)]))
                    textView.attributedText = mutable
                    textView.selectedRange = NSRange(location: lineRange.location + 1, length: 0)
                    return false
                }

                let mutable = NSMutableAttributedString(attributedString: attrText)
                let newLine = NSMutableAttributedString(string: "\n", attributes: [.font: UIFont.systemFont(ofSize: 16)])
                newLine.append(uncheckedAttachment())
                newLine.append(NSAttributedString(string: " ", attributes: [.font: UIFont.systemFont(ofSize: 16)]))

                mutable.replaceCharacters(in: range, with: newLine)
                textView.attributedText = mutable
                textView.selectedRange = NSRange(location: range.location + newLine.length, length: 0)
                return false
            }
        }

        return true
    }
}


extension NoteViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            noteTextView.becomeFirstResponder()
            return false
        }
        
        return true
    }
}
