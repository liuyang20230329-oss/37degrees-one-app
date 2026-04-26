import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ProfileViewModel()

    @State private var name: String = ""
    @State private var gender: User.Gender = .undisclosed
    @State private var birthYear: Int = 2000
    @State private var birthMonth: Int = 1
    @State private var city: String = ""
    @State private var signature: String = ""
    @State private var selectedAvatarKey: String = "aurora"
    @State private var showBirthYearPicker = false
    @State private var showBirthMonthPicker = false
    @State private var showGenderPicker = false
    @State private var hasInitialized = false

    private let avatarOptions = ["aurora", "sunset", "ocean", "forest", "flame", "crystal"]
    private let years = Array(1960...2010)
    private let months = Array(1...12)

    var body: some View {
        ScrollView {
            VStack(spacing: .spaceLG) {
                avatarSection
                formSection
            }
            .padding(.horizontal, .spaceLG)
            .padding(.bottom, 100)
        }
        .background(Color.bgPrimary)
        .navigationTitle("编辑资料")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") { Task { await saveProfile() } }
                    .font(.label)
                    .foregroundStyle(.brandPrimary)
                    .disabled(viewModel.isUpdating)
            }
        }
        .overlay {
            if viewModel.isUpdating {
                ProgressView()
                    .tint(.brandPrimary)
            }
        }
        .task {
            if !hasInitialized {
                await viewModel.loadProfile()
                populateFields()
                hasInitialized = true
            }
        }
    }

    private var avatarSection: some View {
        VStack(spacing: .spaceMD) {
            Text("头像主题")
                .font(.headline)
                .foregroundStyle(.textPrimary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: .spaceMD) {
                ForEach(avatarOptions, id: \.self) { key in
                    avatarOptionCard(key: key)
                }
            }
        }
        .padding(.top, .spaceLG)
    }

    private func avatarOptionCard(key: String) -> some View {
        let isSelected = selectedAvatarKey == key
        return Button {
            withAnimation(.appFast) { selectedAvatarKey = key }
        } label: {
            VStack(spacing: .spaceXS) {
                Circle()
                    .fill(avatarColor(for: key))
                    .frame(width: 64, height: 64)
                    .overlay {
                        if isSelected {
                            Circle()
                                .stroke(Color.brandPrimary, lineWidth: 3)
                        }
                        Image(systemName: "person.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.white)
                    }
                Text(key.capitalized)
                    .font(.caption)
                    .foregroundStyle(isSelected ? .brandPrimary : .textSecondary)
            }
        }
    }

    private var formSection: some View {
        VStack(spacing: 0) {
            formRow(label: "昵称", value: name.isEmpty ? "未设置" : name) {
                EditableFieldSheet(title: "昵称", text: $name, maxLength: 20)
            }

            divider

            formRow(label: "性别", value: gender.displayName, showChevron: true) {
                showGenderPicker = true
            }

            divider

            formRow(label: "出生年份", value: birthYear > 0 ? "\(birthYear)年" : "未设置", showChevron: true) {
                showBirthYearPicker = true
            }

            divider

            formRow(label: "出生月份", value: birthMonth > 0 ? "\(birthMonth)月" : "未设置", showChevron: true) {
                showBirthMonthPicker = true
            }

            divider

            formRow(label: "城市", value: city.isEmpty ? "未设置" : city) {
                EditableFieldSheet(title: "城市", text: $city, maxLength: 30)
            }

            divider

            formRow(label: "个性签名", value: signature.isEmpty ? "未设置" : signature, isMultiline: true) {
                EditableFieldSheet(title: "个性签名", text: $signature, maxLength: 100)
            }
        }
        .background(Color.bgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: .radiusMD))
        .sheet(isPresented: $showGenderPicker) {
            genderPickerSheet
        }
        .sheet(isPresented: $showBirthYearPicker) {
            yearPickerSheet
        }
        .sheet(isPresented: $showBirthMonthPicker) {
            monthPickerSheet
        }
    }

    private func formRow(label: String, value: String, isMultiline: Bool = false, showChevron: Bool = false, destination: @escaping () -> some View) -> some View {
        Button {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let root = windowScene.windows.first?.rootViewController {
                let hostingController = UIHostingController(rootView: destination())
                hostingController.view.backgroundColor = .clear
                if let sheet = hostingController.sheetPresentationController {
                    sheet.detents = [.medium()]
                    sheet.cornerRadius = 20
                }
                root.present(hostingController, animated: true)
            }
        } label: {
            HStack(spacing: .spaceMD) {
                Text(label)
                    .font(.bodyMedium)
                    .foregroundStyle(.textPrimary)
                    .frame(width: 80, alignment: .leading)

                Text(value)
                    .font(.bodyMedium)
                    .foregroundStyle(value == "未设置" ? .textTertiary : .textSecondary)
                    .lineLimit(isMultiline ? 2 : 1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.textTertiary)
                }
            }
            .padding(.horizontal, .spaceLG)
            .frame(minHeight: 52)
        }
    }

    private var divider: some View {
        Rectangle().fill(Color.dividerColor).frame(height: 0.5).padding(.leading, 96)
    }

    private var genderPickerSheet: some View {
        NavigationStack {
            VStack(spacing: .spaceSM) {
                ForEach(User.Gender.allCases, id: \.self) { option in
                    Button {
                        gender = option
                        showGenderPicker = false
                    } label: {
                        HStack {
                            Text(option.displayName)
                                .font(.bodyMedium)
                                .foregroundStyle(.textPrimary)
                            Spacer()
                            if gender == option {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.brandPrimary)
                            }
                        }
                        .padding(.horizontal, .spaceLG)
                        .frame(height: 48)
                        .background(Color.bgSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: .radiusSM))
                    }
                }
                Spacer()
            }
            .padding(.spaceLG)
            .navigationTitle("选择性别")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { showGenderPicker = false }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var yearPickerSheet: some View {
        NavigationStack {
            Picker("出生年份", selection: $birthYear) {
                ForEach(years.reversed(), id: \.self) { year in
                    Text("\(year)").tag(year)
                }
            }
            .pickerStyle(.wheel)
            .navigationTitle("出生年份")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { showBirthYearPicker = false }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var monthPickerSheet: some View {
        NavigationStack {
            Picker("出生月份", selection: $birthMonth) {
                ForEach(months, id: \.self) { month in
                    Text("\(month)月").tag(month)
                }
            }
            .pickerStyle(.wheel)
            .navigationTitle("出生月份")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { showBirthMonthPicker = false }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func populateFields() {
        guard let user = viewModel.user else { return }
        name = user.name
        gender = user.gender
        birthYear = user.birthYear ?? 2000
        birthMonth = user.birthMonth ?? 1
        city = user.city ?? ""
        signature = user.signature ?? ""
        selectedAvatarKey = user.avatarKey ?? "aurora"
    }

    private func saveProfile() async {
        var fields: [String: Any] = [
            "name": name,
            "avatarKey": selectedAvatarKey,
            "birthYear": birthYear,
            "birthMonth": birthMonth,
            "city": city,
            "signature": signature
        ]
        if gender != .undisclosed {
            fields["gender"] = gender.rawValue
        }
        let success = await viewModel.updateProfile(fields: fields)
        if success { dismiss() }
    }

    private func avatarColor(for key: String) -> Color {
        switch key {
        case "aurora": return .purple.opacity(0.6)
        case "sunset": return .orange.opacity(0.6)
        case "ocean": return .blue.opacity(0.6)
        case "forest": return .green.opacity(0.6)
        case "flame": return .red.opacity(0.6)
        case "crystal": return .cyan.opacity(0.6)
        default: return .gray.opacity(0.3)
        }
    }
}

struct EditableFieldSheet: View {
    let title: String
    @Binding var text: String
    let maxLength: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: .spaceLG) {
                AppTextField(
                    placeholder: "请输入\(title)",
                    text: $text,
                    maxLength: maxLength
                )

                Spacer()
            }
            .padding(.spaceLG)
            .background(Color.bgPrimary)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
