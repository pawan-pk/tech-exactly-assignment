//
//  NotesViewController.swift
//  TechExactly
//
//  Created by Pawan Kushwaha on 17/03/26.
//

import UIKit

class NotesViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noNotes: UILabel!
    
    // MARK: - Variables
    var viewModel: NotesViewModel?
    
    // MARK: - Controller functions
    override func viewDidLoad() {
        super.viewDidLoad()
        bindingViewModel()
        setupView()
        viewModelChange()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel?.fetchList()
    }

    // MARK: - Actions
    @objc func addNewNoteAction(_ sender: UIBarButtonItem) {
        let vc = NoteViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Custom Functions
    private func setupView() {
        // Navigation Bar
        title = "All Notes"
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewNoteAction(_ :)))
        navigationItem.rightBarButtonItem = addButton
        
        // Table View Setup
        tableView.register(UINib(nibName: "NoteTableViewCell", bundle: nil), forCellReuseIdentifier: "NoteTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func bindingViewModel() {
        let repository = NotesRepository()
        viewModel = NotesViewModel(repository: repository)
    }
    
    private func viewModelChange() {
        viewModel?.changeHandler = { [weak self] in
            self?.reloadTableView()
            self?.needShowEmptyMessage()
        }
    }
    
    private func reloadTableView() {
        tableView.reloadData()
    }
    
    private func needShowEmptyMessage() {
        noNotes.isHidden = !(viewModel?.notes.isEmpty ?? false)
    }
}

// MARK: - UITableViewDataSource
extension NotesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.notes.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteTableViewCell", for: indexPath) as! NoteTableViewCell
        cell.title?.text =  viewModel?.notes[indexPath.row].title
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = NoteViewController()
        let note = viewModel?.notes[indexPath.row]
        vc.noteId = note?.id
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDelegate
extension NotesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            viewModel?.deleteSelectedNote(index: indexPath.row)
        }
    }
}
