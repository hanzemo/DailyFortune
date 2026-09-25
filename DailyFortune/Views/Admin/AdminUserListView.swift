import SwiftUI

struct AdminUserListView: View {
    @State private var users: [UserMeProfile] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var editingUser: UserMeProfile?

    var body: some View {
        List {
            if isLoading && users.isEmpty {
                ProgressView()
            }
            ForEach(users) { user in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(user.displayName).font(.headline)
                        if user.role == "admin" {
                            Text("管理员")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(4)
                        }
                        Spacer()
                        Text(user.status)
                            .font(.caption)
                            .foregroundColor(user.status == "active" ? .green : .red)
                    }
                    Text("@\(user.username) · \(user.email)")
                        .font(.caption).foregroundColor(.secondary)
                    HStack {
                        Text("抽签 \(user.totalDraws)")
                        if user.isHidden { Text("已隐藏").foregroundColor(.orange) }
                        if !user.tags.isEmpty {
                            Text(user.tags.joined(separator: ",")).foregroundColor(.blue)
                        }
                    }
                    .font(.caption2)
                }
                .contentShape(Rectangle())
                .onTapGesture { editingUser = user }
            }
        }
        .navigationTitle("用户管理")
        .refreshable { await loadUsers() }
        .task { await loadUsers() }
        .confirmationDialog(
            "操作用户",
            isPresented: Binding(
                get: { editingUser != nil },
                set: { if !$0 { editingUser = nil } }
            ),
            presenting: editingUser
        ) { user in
            Button(user.status == "active" ? "禁用账号" : "启用账号") {
                Task { await toggleStatus(user) }
            }
            Button(user.isHidden ? "取消隐藏" : "隐藏用户") {
                Task { await toggleVisibility(user) }
            }
            Button("取消", role: .cancel) {}
        }
        .alert("错误", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("确定") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    func loadUsers() async {
        isLoading = true
        defer { isLoading = false }
        do {
            users = try await APIService.shared.getAllUsers()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleStatus(_ user: UserMeProfile) async {
        let newStatus = user.status == "active" ? "inactive" : "active"
        do {
            try await APIService.shared.updateUserStatus(userId: user.id, status: newStatus)
            await loadUsers()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleVisibility(_ user: UserMeProfile) async {
        do {
            try await APIService.shared.updateUserVisibility(userId: user.id, isHidden: !user.isHidden)
            await loadUsers()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
