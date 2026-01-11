import SwiftUI
import TodoUseCase
import TodoUI

public struct TodoDetailView: View {
    @State public var viewModel: TodoDetailViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: TodoDetailViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            Form {
                detailsSection
                dueDateSection
                prioritySection

                if !viewModel.availableCategories.isEmpty {
                    categoriesSection
                }
            }
            .navigationTitle(viewModel.existingTodo == nil ? "New Todo" : "Edit Todo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Button("Save") {
                            viewModel.save()
                        }
                        .disabled(!viewModel.isValid)
                    }
                }
            }
            .onAppear {
                viewModel.loadCategories()
            }
            .onChange(of: viewModel.state) { _, newState in
                if case .saved = newState {
                    dismiss()
                }
            }
            .alert("Error", isPresented: errorBinding) {
                Button("OK", role: .cancel) {
                    // Return to editing state
                    viewModel.state = .editing(viewModel.formData)
                }
            } message: {
                if case .error(let message) = viewModel.state {
                    Text(message)
                }
            }
        }
    }

    // MARK: - Form Sections

    private var detailsSection: some View {
        Section("Details") {
            TextField("Title", text: titleBinding)
                .autocorrectionDisabled()

            TextField("Notes", text: notesBinding, axis: .vertical)
                .lineLimit(3...6)
                .autocorrectionDisabled()
        }
    }

    private var dueDateSection: some View {
        Section("Due Date") {
            Toggle("Set due date", isOn: hasDueDateBinding)

            if viewModel.formData.hasDueDate {
                DatePicker(
                    "Date",
                    selection: dueDateBinding,
                    displayedComponents: [.date]
                )
            }
        }
    }

    private var prioritySection: some View {
        Section("Priority") {
            Picker("Priority", selection: priorityBinding) {
                ForEach(TodoPriority.allCases, id: \.self) { priority in
                    Label {
                        Text(priority.displayName)
                    } icon: {
                        if !priority.systemImageName.isEmpty {
                            Image(systemName: priority.systemImageName)
                        }
                    }
                    .tag(priority)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var categoriesSection: some View {
        Section("Categories") {
            ForEach(viewModel.availableCategories) { category in
                Button(action: { viewModel.toggleCategory(category) }) {
                    HStack {
                        Circle()
                            .fill(category.color)
                            .frame(width: 12, height: 12)

                        Text(category.name)
                            .foregroundStyle(.primary)

                        Spacer()

                        if viewModel.formData.selectedCategoryIds.contains(category.id) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: {
                if case .error = viewModel.state { return true }
                return false
            },
            set: { _ in }
        )
    }

    // MARK: - Custom Bindings

    private var titleBinding: Binding<String> {
        Binding(
            get: { viewModel.formData.title },
            set: { newValue in
                viewModel.formData.title = newValue
            }
        )
    }

    private var notesBinding: Binding<String> {
        Binding(
            get: { viewModel.formData.notes },
            set: { newValue in
                viewModel.formData.notes = newValue
            }
        )
    }

    private var hasDueDateBinding: Binding<Bool> {
        Binding(
            get: { viewModel.formData.hasDueDate },
            set: { newValue in
                viewModel.formData.hasDueDate = newValue
            }
        )
    }

    private var dueDateBinding: Binding<Date> {
        Binding(
            get: { viewModel.formData.dueDate ?? Date() },
            set: { newValue in
                viewModel.formData.dueDate = newValue
            }
        )
    }

    private var priorityBinding: Binding<TodoPriority> {
        Binding(
            get: { viewModel.formData.priority },
            set: { newValue in
                viewModel.formData.priority = newValue
            }
        )
    }
}
