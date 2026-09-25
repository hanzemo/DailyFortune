import SwiftUI

struct AdminEditUserView: View {
    let user: UserMeProfile
    let onSave: () -> Void

    @Environment(\.dismiss) var dismiss
    @State private var displayName: String
    @State private var bio: String
    @State private var avatarUrl: String
    @State private var qq: String
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(user: UserMeProfile, onSave: @escaping () -> Void) {
        self.user = user
        self.onSave = onSave
        _displayName = State(initialValue: user.displayName)
        _bio = State(initialValue: user.bio)
        _avatarUrl = State(initialValue: user.avatarUrl)
        _qq = State(initialValue: user.qq.map(String.init) ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("显示名", text: $displayName)
                TextField("简介", text: $bio, axis: .vertical)
                TextField("头像 URL", text: $avatarUrl).keyboardType(.URL)
                TextField("QQ", text: $qq).keyboardType(.numberPad)

                if let msg = errorMessage {
                    Text(msg).foregroundColor(.red)
                }
            }
            .navigationTitle("编辑 \(user.username)")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Task { await save() }
                    }
                    .disabled(isSaving)
                }
            }
        }
    }

    func save() async {
        isSaving = true
        defer { isSaving = false }

        var payload = UserUpdatePayload()
        if displayName != user.displayName { payload.displayName = displayName }
        if bio != user.bio { payload.bio = bio }
        if avatarUrl != user.avatarUrl { payload.avatarUrl = avatarUrl }
        let qqInt = Int(qq)
        if qqInt != user.qq { payload.qq = qqInt }

        do {
            try await APIService.shared.adminUpdateUser(userId: user.id, payload: payload)
            onSave()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
