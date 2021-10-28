import Foundation

/// Combined version and build number
let versionAndBuild: String = {
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String

    var versionString = "Version: "
    if let app = appVersion {
        versionString += app
    }
    if let build = buildVersion {
        versionString += ", build: \(build)"
    }
    return versionString
}()
