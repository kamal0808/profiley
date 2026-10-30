// The default browser. A link to a saved site opens straight in its profile;
// any other link (or any link while Option is held) shows a popup to pick one.
import AppKit
import ServiceManagement

struct Browser {
    let name: String       // app name, as `open -a` knows it
    let bundleId: String
    let support: String    // folder holding "Local State"
}

let browsers = [
    Browser(name: "Comet", bundleId: "ai.perplexity.comet", support: "Comet"),
    Browser(name: "Google Chrome", bundleId: "com.google.Chrome", support: "Google/Chrome"),
    Browser(name: "Brave Browser", bundleId: "com.brave.Browser", support: "BraveSoftware/Brave-Browser"),
    Browser(name: "Microsoft Edge", bundleId: "com.microsoft.edgemac", support: "Microsoft Edge"),
    Browser(name: "Vivaldi", bundleId: "com.vivaldi.Vivaldi", support: "Vivaldi"),
]

let home = ProcessInfo.processInfo.environment["HOME"] ?? NSHomeDirectory()
let finickyConfig = home + "/.finicky.js"
let storeDir = home + "/Library/Application Support/Profiley"
let sitesFile = storeDir + "/sites.json"

// `defaults write com.kamalkhatwani.profiley browser "Google Chrome"`, else the default
// browser at first launch (saved, since Profiley then takes its place), else the one an old
// ~/.finicky.js named (`const pickerBrowser = "...";`), else the first one installed.
var browser: Browser = {
    if let name = UserDefaults.standard.string(forKey: "browser"),
       let b = browsers.first(where: { $0.name == name }) { return b }
    if let url = NSWorkspace.shared.urlForApplication(toOpen: URL(string: "https://example.com")!),
       let id = Bundle(url: url)?.bundleIdentifier,
       let b = browsers.first(where: { $0.bundleId == id }) {
        UserDefaults.standard.set(b.name, forKey: "browser")
        return b
    }
    if let src = try? String(contentsOfFile: finickyConfig, encoding: .utf8),
       let m = src.range(of: #"const pickerBrowser = "([^"]+)""#, options: .regularExpression) {
        let name = src[m].split(separator: "\"")[1]
        if let b = browsers.first(where: { $0.name == name }) { return b }
    }
    return browsers.first { NSWorkspace.shared.urlForApplication(withBundleIdentifier: $0.bundleId) != nil } ?? browsers[0]
}()

func supportDir(_ b: Browser) -> String { home + "/Library/Application Support/" + b.support }
let feedbackURL = "https://profiley.topc.social/feedback"
let cometResources = "/Applications/Comet.app/Contents/Frameworks/Comet Framework.framework/Resources/"
// Resource ids of Comet's avatar art, found by dumping its packs (Comet 154).
// Picked avatars: IDR_PROFILE_AVATAR_N is id avatarBaseId + N in chrome_200_percent.pak.
// The default avatar is a separate image in chrome_100_percent.pak.
let avatarBaseId = 14386
let defaultAvatarId = 338

// Saved sites: domain -> profile name. A domain also covers its subdomains.
func loadSites() -> [String: String] {
    guard let d = FileManager.default.contents(atPath: sitesFile),
          let json = try? JSONSerialization.jsonObject(with: d) as? [String: String] else { return [:] }
    return json
}

func saveSites(_ sites: [String: String]) {
    try? FileManager.default.createDirectory(atPath: storeDir, withIntermediateDirectories: true)
    if let d = try? JSONSerialization.data(withJSONObject: sites, options: [.prettyPrinted, .sortedKeys]) {
        try? d.write(to: URL(fileURLWithPath: sitesFile), options: .atomic)
    }
}

// Links Profiley has opened, kept on this Mac only.
func countOpen() { UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "linksOpened") + 1, forKey: "linksOpened") }
func linksOpened() -> String {
    let n = UserDefaults.standard.integer(forKey: "linksOpened")
    return "\(n.formatted()) link\(n == 1 ? "" : "s")"
}

// Anonymous usage count on PostHog: "app_install" once, then "app_active" at most once a day,
// with a random ID and the app version, no person profile.
// Off: `defaults write com.kamalkhatwani.profiley analytics -bool false`.
let posthogKey = "phc_CappPjX82qb8tAk4hH7oSYccrSnw2YT7QrQkKrN7F5Gf"  // public project key, safe to ship

let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"

// "1.10" is newer than "1.9": compare number by number, not as text.
func isNewer(_ a: String, than b: String) -> Bool {
    let x = a.split(separator: ".").map { Int($0) ?? 0 }, y = b.split(separator: ".").map { Int($0) ?? 0 }
    for i in 0..<max(x.count, y.count) {
        let l = i < x.count ? x[i] : 0, r = i < y.count ? y[i] : 0
        if l != r { return l > r }
    }
    return false
}

// Once a day, ask GitHub for the latest release and remember its version for the popup to mention.
func checkForUpdate() {
    assert(isNewer("1.10", than: "1.9") && !isNewer("1.7", than: "1.7") && isNewer("2", than: "1.9.9"))
    let d = UserDefaults.standard, today = String(ISO8601DateFormatter().string(from: Date()).prefix(10))
    guard d.string(forKey: "updateCheckDay") != today,
          let url = URL(string: "https://api.github.com/repos/kamal0808/profiley/releases/latest") else { return }
    d.set(today, forKey: "updateCheckDay")
    URLSession.shared.dataTask(with: url) { data, _, _ in
        guard let data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let tag = json["tag_name"] as? String else { return }
        d.set(tag.hasPrefix("v") ? String(tag.dropFirst()) : tag, forKey: "latestVersion")
    }.resume()
}

func ping() {
    let d = UserDefaults.standard
    guard !posthogKey.isEmpty, d.object(forKey: "analytics") as? Bool != false else { return }
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd"
    let today = f.string(from: Date()), last = d.string(forKey: "pingDay")
    guard last != today else { return }
    d.set(today, forKey: "pingDay")
    let id = d.string(forKey: "pingID") ?? UUID().uuidString
    d.set(id, forKey: "pingID")
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "dev"
    let event: [String: Any] = ["api_key": posthogKey, "event": last == nil ? "app_install" : "app_active", "distinct_id": id,
                                "properties": ["app": "profiley", "$app_version": version, "$process_person_profile": false]]
    guard let body = try? JSONSerialization.data(withJSONObject: event), let json = String(data: body, encoding: .utf8) else { return }
    // curl, not URLSession: Profiley often quits right after opening a link, and curl outlives it.
    let t = Process()
    t.executableURL = URL(fileURLWithPath: "/usr/bin/curl")
    t.arguments = ["-s", "-m", "10", "-o", "/dev/null", "-H", "Content-Type: application/json",
                   "-d", json, "https://us.i.posthog.com/i/v0/e/"]
    try? t.run()
}

// First run: bring over the sites an older Finicky-based setup saved in ~/.finicky.js.
func migrateFromFinicky() {
    guard !FileManager.default.fileExists(atPath: sitesFile) else { return }
    var sites: [String: String] = [:]
    if let src = try? String(contentsOfFile: finickyConfig, encoding: .utf8),
       let a = src.range(of: "const learned = "), let b = src.range(of: ";\n// learned:end"),
       let json = try? JSONSerialization.jsonObject(with: Data(src[a.upperBound..<b.lowerBound].utf8)) as? [String: String] {
        sites = json
    }
    saveSites(sites)
}

// "https://www.App.Example.com/x" or "*.example.com" -> "app.example.com" / "example.com".
func siteName(_ s: String) -> String {
    var h = s.trimmingCharacters(in: .whitespaces).lowercased()
    if let u = URL(string: h), let host = u.host { h = host }
    else if let u = URL(string: "https://" + h), let host = u.host { h = host }
    for prefix in ["*.", "www."] where h.hasPrefix(prefix) { h.removeFirst(prefix.count) }
    return h
}

// "https://meet.google.com/abc-defg-hij?x=1" -> ["meet.google.com", "meet.google.com/abc-defg-hij"]: the site, then each path level.
func linkLevels(_ url: String) -> [String] {
    guard let u = URL(string: url), let host = u.host.map(siteName) else { return [] }
    var levels = [host], path = host
    for seg in u.pathComponents where seg != "/" {
        path += "/" + seg
        levels.append(path)
    }
    return levels
}

// The saved rule covering this link: its longest saved path level, else its host or closest parent domain.
func savedMatch(_ url: String, in sites: [String: String]) -> (site: String, profile: String)? {
    let levels = linkLevels(url)
    for l in levels.dropFirst().reversed() { if let p = sites[l] { return (l, p) } }
    var h = levels.first ?? ""
    while !h.isEmpty {
        if let p = sites[h] { return (h, p) }
        guard let dot = h.firstIndex(of: ".") else { break }
        h = String(h[h.index(after: dot)...])
    }
    return nil
}

// Two links count as the same open tab when they differ only by #anchor or a trailing slash.
func tabKey(_ url: String) -> String {
    var s = url.components(separatedBy: "#")[0]
    while s.hasSuffix("/") { s.removeLast() }
    return s
}

func sameSite(_ a: String, _ b: String) -> Bool {
    guard let u = URL(string: a), let t = URL(string: b) else { return false }
    return u.scheme == t.scheme && u.host == t.host && u.port == t.port
}

// For sites ticked "Reuse open tab": focus a tab already showing this link, else load it in an open tab
// on the same site (scheme, host and port), in any window of the running browser.
func focusOpenTab(_ url: String) -> Bool {
    guard NSRunningApplication.runningApplications(withBundleIdentifier: browser.bundleId).first != nil else { return false }
    let app = "tell application \"\(browser.name)\" to "
    var err: NSDictionary?
    guard let ids = NSAppleScript(source: app + "get id of every window")?.executeAndReturnError(&err),
          let urls = NSAppleScript(source: app + "get URL of tabs of every window")?.executeAndReturnError(&err),
          ids.numberOfItems == urls.numberOfItems, ids.numberOfItems > 0 else {
        if let err = err { NSLog("Reuse tab: %@", err) }
        return false
    }
    var other: (id: Int32, tab: Int)?
    for w in 1...ids.numberOfItems {
        guard let tabs = urls.atIndex(w), tabs.numberOfItems > 0, let id = ids.atIndex(w)?.int32Value else { continue }
        for t in 1...tabs.numberOfItems {
            let open = tabs.atIndex(t)?.stringValue ?? ""
            if tabKey(open) == tabKey(url) { return focusTab(id, t, load: nil) }
            if other == nil && sameSite(url, open) { other = (id, t) }
        }
    }
    if let o = other { return focusTab(o.id, o.tab, load: url) }
    return false
}

func focusTab(_ id: Int32, _ tab: Int, load url: String?) -> Bool {
    let load = url.map { "set URL of tab \(tab) of window id \(id) to \"\($0.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\""))\"\n" } ?? ""
    var err: NSDictionary?
    let ok = NSAppleScript(source: "tell application \"\(browser.name)\"\n\(load)set active tab index of window id \(id) to \(tab)\nset index of window id \(id) to 1\nend tell")?
        .executeAndReturnError(&err) != nil
    if let err = err { NSLog("Reuse tab: %@", err) }
    return ok
}

func isDefaultBrowser() -> Bool {
    NSWorkspace.shared.urlForApplication(toOpen: URL(string: "https://example.com")!)?.standardizedFileURL
        == Bundle.main.bundleURL.standardizedFileURL
}

// The "Private" card in the popup: an incognito window of the main browser, never saved.
let privateDir = "__private__"

struct Profile {
    let dir: String
    let name: String
    let color: NSColor
    let avatar: NSImage?
}

func argb(_ v: Any?) -> NSColor? {
    guard let n = (v as? NSNumber)?.int64Value else { return nil }
    let u = UInt32(truncatingIfNeeded: n)
    return NSColor(srgbRed: CGFloat((u >> 16) & 0xff) / 255, green: CGFloat((u >> 8) & 0xff) / 255,
                   blue: CGFloat(u & 0xff) / 255, alpha: 1)
}

func pakImage(_ b: Browser, _ pak: String, _ id: Int) -> NSImage? {
    guard b.name == "Comet", let d = FileManager.default.contents(atPath: cometResources + pak), d.count > 12 else { return nil }
    func u16(_ o: Int) -> Int { Int(d[o]) | Int(d[o + 1]) << 8 }
    func u32(_ o: Int) -> Int { u16(o) | u16(o + 2) << 16 }
    guard u32(0) == 5 else { return nil }
    let count = u16(8)
    for i in 0..<count where u16(12 + i * 6) == id {
        let start = u32(14 + i * 6), end = u32(20 + i * 6)
        return NSImage(data: d.subdata(in: start..<end))
    }
    return nil
}

func loadProfiles(_ b: Browser = browser) -> [Profile] {
    let browserSupport = supportDir(b)
    guard let data = FileManager.default.contents(atPath: browserSupport + "/Local State"),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let cache = (json["profile"] as? [String: Any])?["info_cache"] as? [String: [String: Any]]
    else { return [] }
    return cache.sorted { ($0.value["name"] as? String ?? $0.key).localizedStandardCompare($1.value["name"] as? String ?? $1.key) == .orderedAscending }.map { dir, info in
        var avatar: NSImage?
        if let pic = info["gaia_picture_file_name"] as? String, !pic.isEmpty, (info["use_gaia_picture"] as? Bool) == true {
            avatar = NSImage(contentsOfFile: "\(browserSupport)/\(dir)/\(pic)")
        } else if (info["is_using_default_avatar"] as? Bool) == true {
            avatar = pakImage(b, "chrome_100_percent.pak", defaultAvatarId)
        } else if let icon = info["avatar_icon"] as? String,
                  let n = Int(icon.replacingOccurrences(of: "chrome://theme/IDR_PROFILE_AVATAR_", with: "")) {
            avatar = pakImage(b, "chrome_200_percent.pak", avatarBaseId + n)
        }
        return Profile(dir: dir, name: info["name"] as? String ?? dir,
                       color: argb(info["profile_color_seed"]) ?? .systemGray, avatar: avatar)
    }
}

final class AvatarView: NSView {
    let profile: Profile
    init(_ p: Profile) { profile = p; super.init(frame: NSRect(x: 0, y: 0, width: 72, height: 72)) }
    required init?(coder: NSCoder) { fatalError() }
    override func draw(_ dirtyRect: NSRect) {
        let ring = NSBezierPath(ovalIn: bounds.insetBy(dx: 1.5, dy: 1.5))
        ring.lineWidth = 3
        let inner = bounds.insetBy(dx: 6, dy: 6)
        if let img = profile.avatar {
            NSGraphicsContext.saveGraphicsState()
            NSBezierPath(ovalIn: inner).addClip()
            img.draw(in: inner)
            NSGraphicsContext.restoreGraphicsState()
        } else {
            profile.color.setFill()
            NSBezierPath(ovalIn: inner).fill()
        }
        if profile.dir == privateDir {
            NSColor(white: 0.12, alpha: 1).setFill()
            NSBezierPath(ovalIn: inner).fill()
            let cfg = NSImage.SymbolConfiguration(pointSize: 26, weight: .semibold).applying(.init(paletteColors: [.white]))
            if let g = NSImage(systemSymbolName: "eyeglasses", accessibilityDescription: "Private window")?.withSymbolConfiguration(cfg) {
                g.draw(in: NSRect(x: bounds.midX - g.size.width / 2, y: bounds.midY - g.size.height / 2, width: g.size.width, height: g.size.height))
            }
            NSColor.white.withAlphaComponent(0.25).setStroke()
            ring.stroke()
            return
        }
        let letter = NSAttributedString(string: String(profile.name.prefix(1)).uppercased(), attributes: [
            .font: NSFont.systemFont(ofSize: 26, weight: .semibold), .foregroundColor: NSColor.white,
            .shadow: { let s = NSShadow(); s.shadowBlurRadius = 3; s.shadowColor = .black.withAlphaComponent(0.5); return s }(),
        ])
        let size = letter.size()
        letter.draw(at: NSPoint(x: bounds.midX - size.width / 2, y: bounds.midY - size.height / 2))
        NSColor.white.withAlphaComponent(0.25).setStroke()
        ring.stroke()
    }
}

final class ProfileButton: NSButton {
    var onHover: ((Bool) -> Void)?
    override func updateTrackingAreas() {
        trackingAreas.forEach(removeTrackingArea)
        addTrackingArea(NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self))
    }
    override func mouseEntered(with event: NSEvent) { onHover?(true) }
    override func mouseExited(with event: NSEvent) { onHover?(false) }
}

final class Picker: NSObject, NSApplicationDelegate, NSWindowDelegate, NSMenuDelegate {
    var panel: NSPanel?
    var url = ""
    var host = ""
    var remember: NSButton!
    var rememberPop: NSPopUpButton!
    var savedLabel: NSTextField!
    var profiles: [Profile] = []
    var savedSite: String?
    var gotURL = false
    var launchedAtLogin = false
    var lastURLAt = Date.distantPast
    var others: [URL] = []
    var pending: [String] = []
    var manager: NSWindow?
    var addField: NSTextField?
    var addPop: NSPopUpButton?
    var setup: NSWindow?
    var setupBrowser = browser
    var statusItem: NSStatusItem?
    let countItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    let updateItem = NSMenuItem(title: "", action: #selector(getUpdate), keyEquivalent: "")
    let feedbackItem = NSMenuItem(title: "Send feedback…", action: #selector(sendFeedback), keyEquivalent: "")

    func applicationWillFinishLaunching(_ n: Notification) {
        let e = NSAppleEventManager.shared().currentAppleEvent
        launchedAtLogin = e?.eventID == kAEOpenApplication
            && e?.paramDescriptor(forKeyword: keyAEPropData)?.enumCodeValue == keyAELaunchedAsLogInItem
    }

    func applicationDidFinishLaunching(_ n: Notification) {
        let args = CommandLine.arguments
        if args.contains("--self-test") {
            let s = ["google.com": "A", "meet.google.com": "B", "meet.google.com/abc-defg-hij": "C", "docs.google.com/document/d/X": "D"]
            precondition(savedMatch("https://meet.google.com/abc-defg-hij?authuser=1", in: s)! == ("meet.google.com/abc-defg-hij", "C"))
            precondition(savedMatch("https://meet.google.com/zzz-zzzz-zzz", in: s)! == ("meet.google.com", "B"))
            precondition(savedMatch("https://www.docs.google.com/document/d/X/edit#h", in: s)! == ("docs.google.com/document/d/X", "D"))
            precondition(savedMatch("https://docs.google.com/document/d/XY", in: s)! == ("google.com", "A"))
            precondition(savedMatch("https://example.com/a", in: s) == nil)
            precondition(tabKey("http://localhost:3003/projects/x/#tasks") == tabKey("http://localhost:3003/projects/x"))
            precondition(tabKey("https://a.com/?q=1") != tabKey("https://a.com/?q=2"))
            precondition(savedMatch("http://localhost:3003/projects/x", in: ["localhost": "K"])! == ("localhost", "K"))
            precondition(sameSite("http://localhost:3003/projects/x", "http://localhost:3003/feed"))
            precondition(!sameSite("http://localhost:3003/", "http://localhost:4311/feed"))
            print("self-test ok")
            exit(0)
        }
        migrateFromFinicky()
        if let i = args.firstIndex(of: "--reuse-test"), i + 2 < args.count {
            try? "\(focusOpenTab(args[i + 1]))".write(toFile: args[i + 2], atomically: true, encoding: .utf8)
            exit(0)
        }
        if let i = args.firstIndex(of: "--preview"), i + 1 < args.count {
            let u = args.firstIndex(of: "--url").flatMap { $0 + 1 < args.count ? args[$0 + 1] : nil }
            show(url: u ?? "https://example.com/some/page", preview: args[i + 1])
            return
        }
        if let i = args.firstIndex(of: "--manage-preview"), i + 1 < args.count {
            showManager(preview: args[i + 1])
            return
        }
        if let i = args.firstIndex(of: "--setup-preview"), i + 1 < args.count {
            showSetup(preview: args[i + 1], done: args.contains("--done"))
            return
        }
        if args.contains("--make-default") {
            makeDefault { NSApp.terminate(nil) }
            return
        }
        startAtLogin()
        updateStatusItem()
        // Opened by hand rather than by a link: show the saved sites.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard !self.gotURL && self.panel == nil && !self.launchedAtLogin else { return }
            ping()
            checkForUpdate()
            if UserDefaults.standard.bool(forKey: "setupDone") { self.showManager(preview: nil) } else { self.showSetup(preview: nil, done: false) }
        }
    }

    // Links (and .html files) sent to us as the default browser.
    func application(_ app: NSApplication, open urls: [URL]) {
        gotURL = true
        lastURLAt = Date()
        ping()
        checkForUpdate()
        let forcePicker = NSEvent.modifierFlags.contains(.option)
        let sites = loadSites()
        let all = loadProfiles()
        for u in urls {
            if !forcePicker, let m = savedMatch(u.absoluteString, in: sites),
               m.profile.hasPrefix("app:"), let app = NSWorkspace.shared.urlForApplication(withBundleIdentifier: String(m.profile.dropFirst(4))) {
                NSWorkspace.shared.open([u], withApplicationAt: app, configuration: NSWorkspace.OpenConfiguration())
                countOpen()
            } else if !forcePicker, let m = savedMatch(u.absoluteString, in: sites),
               let p = all.first(where: { $0.name == m.profile }) {
                if (UserDefaults.standard.stringArray(forKey: "reuseTabSites") ?? []).contains(m.site) && focusOpenTab(u.absoluteString) {
                    countOpen()
                    bringBrowserForward()
                } else {
                    openInBrowser(u.absoluteString, p)
                }
            } else {
                pending.append(u.absoluteString)
            }
        }
        if panel == nil { next() }
    }

    // Shows the popup for the next waiting link, or quits once nothing is left on screen.
    func next() {
        panel?.orderOut(nil)
        panel = nil
        if !pending.isEmpty { show(url: pending.removeFirst(), preview: nil) }
    }

    @objc func cancel() { next() }

    func show(url: String, preview: String?) {
        self.url = url
        host = URL(string: url)?.host.map(siteName) ?? ""
        profiles = loadProfiles()

        let content = NSView()
        let title = NSTextField(labelWithString: "Open \(host.isEmpty ? "link" : host) in")
        title.font = .systemFont(ofSize: 15, weight: .semibold)
        let sub = NSTextField(labelWithString: url)
        sub.font = .systemFont(ofSize: 11)
        sub.textColor = .secondaryLabelColor
        sub.lineBreakMode = .byTruncatingMiddle

        let row = NSStackView()
        row.spacing = 12
        for (i, p) in profiles.enumerated() {
            row.addArrangedSubview(card(p, index: i))
        }
        row.addArrangedSubview(card(Profile(dir: privateDir, name: "Private", color: .black, avatar: nil), index: profiles.count))

        remember = NSButton(checkboxWithTitle: "Always open", target: nil, action: nil)
        remember.state = preview != nil && CommandLine.arguments.contains("--ticked") ? .on : .off
        remember.font = .systemFont(ofSize: 12)
        rememberPop = NSPopUpButton()
        rememberPop.controlSize = .small
        rememberPop.font = .systemFont(ofSize: 12)
        rememberPop.addItems(withTitles: linkLevels(url))
        if preview != nil, CommandLine.arguments.contains("--exact") { rememberPop.selectItem(at: rememberPop.numberOfItems - 1) }
        let tail = NSTextField(labelWithString: "this way")
        tail.font = .systemFont(ofSize: 12)
        let rememberRow = NSStackView(views: [remember, rememberPop, tail])
        rememberRow.spacing = 4
        var views: [NSView] = [title, sub, row]
        others = otherBrowsers()
        if !others.isEmpty {
            let label = NSTextField(labelWithString: "Or open in")
            label.font = .systemFont(ofSize: 12)
            label.textColor = .secondaryLabelColor
            let otherRow = NSStackView(views: [label])
            otherRow.spacing = 6
            for (i, app) in others.enumerated() {
                let b = NSButton(title: FileManager.default.displayName(atPath: app.path).replacingOccurrences(of: ".app", with: ""), target: self, action: #selector(openOther(_:)))
                b.image = NSWorkspace.shared.icon(forFile: app.path)
                b.image?.size = NSSize(width: 18, height: 18)
                b.imagePosition = .imageLeading
                b.bezelStyle = .inline
                b.tag = i
                otherRow.addArrangedSubview(b)
            }
            views.append(otherRow)
        }
        views.append(rememberRow)
        if let latest = UserDefaults.standard.string(forKey: "latestVersion"), isNewer(latest, than: currentVersion) {
            let b = NSButton(title: "Profiley \(latest) is out · Get it", target: self, action: #selector(getUpdate))
            b.bezelStyle = .inline
            b.controlSize = .small
            b.attributedTitle = NSAttributedString(string: "↑ Profiley \(latest) is out · Get it", attributes: [
                .foregroundColor: NSColor(srgbRed: 0.78, green: 0.95, blue: 0.31, alpha: 1), .font: NSFont.systemFont(ofSize: 12, weight: .semibold)])
            views.append(b)
        }
        savedSite = nil
        if let m = savedMatch(url, in: loadSites()) {
            savedSite = m.site
            savedLabel = NSTextField(labelWithString: "Saved: \(m.site) always opens in \(savedTitle(m.profile))")
            savedLabel.font = .systemFont(ofSize: 12)
            savedLabel.textColor = .secondaryLabelColor
            let forget = NSButton(title: "Forget", target: self, action: #selector(forgetSaved(_:)))
            forget.bezelStyle = .inline
            forget.controlSize = .small
            let savedRow = NSStackView(views: [savedLabel, forget])
            savedRow.spacing = 8
            views.append(savedRow)
        }
        let hint = NSTextField(labelWithString: "Press 1–\(profiles.count + 1) · hold ⌥ while clicking a link to change a saved site")
        hint.font = .systemFont(ofSize: 11)
        hint.textColor = .tertiaryLabelColor

        let cancel = NSButton(title: "Cancel", target: self, action: #selector(cancel))
        cancel.bezelStyle = .rounded
        cancel.keyEquivalent = "\u{1b}"
        let manage = NSButton(title: "Saved sites…", target: self, action: #selector(openManager))
        manage.bezelStyle = .inline
        manage.controlSize = .small
        let buttons = NSStackView(views: [cancel, manage])
        buttons.spacing = 10
        views.append(buttons)
        views.append(hint)
        let stack = NSStackView(views: views)
        stack.orientation = .vertical
        stack.alignment = .centerX
        stack.spacing = 10
        stack.setCustomSpacing(4, after: title)
        stack.setCustomSpacing(16, after: sub)
        stack.setCustomSpacing(16, after: row)
        stack.edgeInsets = NSEdgeInsets(top: 22, left: 24, bottom: 18, right: 24)
        stack.translatesAutoresizingMaskIntoConstraints = false
        sub.widthAnchor.constraint(lessThanOrEqualToConstant: 380).isActive = true

        let blur = NSVisualEffectView()
        blur.material = .hudWindow
        blur.state = .active
        blur.blendingMode = .behindWindow
        blur.wantsLayer = true
        blur.layer?.cornerRadius = 16
        blur.addSubview(stack)
        content.addSubview(blur)
        blur.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: blur.leadingAnchor), stack.trailingAnchor.constraint(equalTo: blur.trailingAnchor),
            stack.topAnchor.constraint(equalTo: blur.topAnchor), stack.bottomAnchor.constraint(equalTo: blur.bottomAnchor),
            blur.leadingAnchor.constraint(equalTo: content.leadingAnchor), blur.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            blur.topAnchor.constraint(equalTo: content.topAnchor), blur.bottomAnchor.constraint(equalTo: content.bottomAnchor),
        ])

        let p = KeyPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        p.picker = self
        p.contentView = content
        p.isOpaque = false
        p.backgroundColor = .clear
        p.hasShadow = true
        p.level = .floating
        p.setContentSize(content.fittingSize)
        p.center()
        panel = p

        if let out = preview {
            p.appearance = NSAppearance(named: .darkAqua)
            p.orderFront(nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let v = p.contentView!
                if let rep = v.bitmapImageRepForCachingDisplay(in: v.bounds) {
                    v.cacheDisplay(in: v.bounds, to: rep)
                    try? rep.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: out))
                }
                NSApp.terminate(nil)
            }
            return
        }
        // Activating the app would also raise a Saved sites or setup window left open, so tuck those away first.
        manager?.orderOut(nil)
        setup?.orderOut(nil)
        p.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
        p.makeKey()
        // Nothing picked in 2 minutes: drop the link rather than leave a stray popup.
        DispatchQueue.main.asyncAfter(deadline: .now() + 120) { if self.panel === p { self.next() } }
    }

    func card(_ p: Profile, index: Int) -> NSView {
        let avatar = AvatarView(p)
        avatar.translatesAutoresizingMaskIntoConstraints = false
        let name = NSTextField(labelWithString: p.name)
        name.font = .systemFont(ofSize: 13, weight: .medium)
        let key = NSTextField(labelWithString: "\(index + 1)")
        key.font = .monospacedDigitSystemFont(ofSize: 10, weight: .regular)
        key.textColor = .tertiaryLabelColor
        let v = NSStackView(views: [avatar, name, key])
        v.orientation = .vertical
        v.spacing = 6
        v.edgeInsets = NSEdgeInsets(top: 12, left: 14, bottom: 8, right: 14)
        v.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([avatar.widthAnchor.constraint(equalToConstant: 72), avatar.heightAnchor.constraint(equalToConstant: 72)])

        let b = ProfileButton(title: "", target: self, action: #selector(picked(_:)))
        b.tag = index
        b.isBordered = false
        b.wantsLayer = true
        b.layer?.cornerRadius = 12
        b.addSubview(v)
        NSLayoutConstraint.activate([
            v.leadingAnchor.constraint(equalTo: b.leadingAnchor), v.trailingAnchor.constraint(equalTo: b.trailingAnchor),
            v.topAnchor.constraint(equalTo: b.topAnchor), v.bottomAnchor.constraint(equalTo: b.bottomAnchor),
            b.widthAnchor.constraint(greaterThanOrEqualToConstant: 104),
        ])
        b.onHover = { [weak b] on in b?.layer?.backgroundColor = on ? NSColor.white.withAlphaComponent(0.12).cgColor : nil }
        return b
    }

    @objc func forgetSaved(_ sender: NSButton) {
        guard let site = savedSite else { return }
        var sites = loadSites()
        sites[site] = nil
        saveSites(sites)
        savedLabel.stringValue = "Forgotten: \(site) will ask again"
        sender.isHidden = true
        reloadManager()
    }

    @objc func picked(_ sender: NSButton) { choose(sender.tag) }

    // Every other installed browser, for links that belong in a different one (Safari for Apple's sites, say).
    func otherBrowsers() -> [URL] {
        let known = ["com.apple.Safari", "com.google.Chrome", "ai.perplexity.comet", "com.brave.Browser", "com.microsoft.edgemac",
                     "com.vivaldi.Vivaldi", "org.mozilla.firefox", "company.thebrowser.Browser", "com.openai.atlas",
                     "com.operasoftware.Opera", "com.kagi.kagimacOS", "app.zen-browser.zen"]
        return known.filter { $0 != browser.bundleId }.compactMap { NSWorkspace.shared.urlForApplication(withBundleIdentifier: $0) }
    }

    // Incognito in the main browser; never saved as a site's choice.
    // Opens the download page in the user's own browser (not through Profiley, which would ask again).
    @objc func getUpdate() { openInMainBrowser("https://profiley.topc.social/install") }

    // The menu bar's feedback item: same route as the update link.
    @objc func sendFeedback() { openInMainBrowser(feedbackURL) }

    func openInMainBrowser(_ link: String) {
        guard let page = URL(string: link),
              let app = NSWorkspace.shared.urlForApplication(withBundleIdentifier: browser.bundleId) else { return }
        next()
        NSWorkspace.shared.open([page], withApplicationAt: app, configuration: NSWorkspace.OpenConfiguration())
    }

    func openPrivate() {
        let link = url
        next()
        launchBrowser(["--incognito", link])
        countOpen()
        bringBrowserForward()
    }

    @objc func openOther(_ sender: NSButton) {
        guard others.indices.contains(sender.tag), let u = URL(string: url) else { return }
        let app = others[sender.tag]
        if remember.state == .on && !host.isEmpty, let id = Bundle(url: app)?.bundleIdentifier {
            var sites = loadSites()
            sites[rememberPop.titleOfSelectedItem ?? host] = "app:" + id
            saveSites(sites)
            reloadManager()
        }
        NSWorkspace.shared.open([u], withApplicationAt: app, configuration: NSWorkspace.OpenConfiguration())
        countOpen()
        next()
    }

    // A saved site holds a profile name, or "app:<bundle id>" for another browser.
    func savedTitle(_ value: String) -> String {
        guard value.hasPrefix("app:") else { return value }
        let id = String(value.dropFirst(4))
        guard let app = NSWorkspace.shared.urlForApplication(withBundleIdentifier: id) else { return id }
        return FileManager.default.displayName(atPath: app.path).replacingOccurrences(of: ".app", with: "")
    }

    // Menu of everything a site can open in: this browser's profiles, then the other browsers.
    func choiceMenu(selecting value: String?) -> NSPopUpButton {
        let pop = NSPopUpButton(frame: .zero, pullsDown: false)
        for p in profiles { pop.addItem(withTitle: p.name); pop.lastItem?.representedObject = p.name }
        let apps = otherBrowsers().compactMap { Bundle(url: $0)?.bundleIdentifier }.map { "app:" + $0 }
        if !apps.isEmpty { pop.menu?.addItem(.separator()) }
        for v in apps { pop.addItem(withTitle: savedTitle(v)); pop.lastItem?.representedObject = v }
        if let value {
            if pop.itemArray.first(where: { $0.representedObject as? String == value }) == nil {
                pop.addItem(withTitle: savedTitle(value)); pop.lastItem?.representedObject = value  // a profile or app that's gone
            }
            pop.select(pop.itemArray.first { $0.representedObject as? String == value })
        }
        return pop
    }

    @objc func openManager() {
        panel?.orderOut(nil)
        panel = nil
        showManager(preview: nil)
    }

    // The menu bar icon: the link count, Saved sites and Quit, since the app has no Dock icon or menu of its own.
    func updateStatusItem() {
        if UserDefaults.standard.bool(forKey: "hideMenuBarIcon") {
            if let s = statusItem { NSStatusBar.system.removeStatusItem(s) }
            statusItem = nil
            return
        }
        guard statusItem == nil else { return }
        let s = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        s.button?.image = NSImage(systemSymbolName: "person.2.circle", accessibilityDescription: "Profiley")
        let menu = NSMenu()
        menu.delegate = self
        menu.addItem(countItem)
        menu.addItem(updateItem)
        menu.addItem(.separator())
        menu.addItem(feedbackItem)
        menu.addItem(withTitle: "Saved sites…", action: #selector(openManager), keyEquivalent: "").target = self
        menu.addItem(withTitle: "Hide menu bar icon", action: #selector(hideStatusItem), keyEquivalent: "").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit Profiley", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        s.menu = menu
        statusItem = s
    }

    func menuWillOpen(_ menu: NSMenu) {
        countItem.title = "\(linksOpened()) opened"
        let latest = UserDefaults.standard.string(forKey: "latestVersion") ?? ""
        updateItem.isHidden = !isNewer(latest, than: currentVersion)
        updateItem.title = "Profiley \(latest) is out · Get it"
        updateItem.target = self
        feedbackItem.target = self
    }

    @objc func hideStatusItem() {
        UserDefaults.standard.set(true, forKey: "hideMenuBarIcon")
        updateStatusItem()
        reloadManager()
    }

    @objc func toggleStatusItem(_ sender: NSButton) {
        UserDefaults.standard.set(sender.state == .off, forKey: "hideMenuBarIcon")
        updateStatusItem()
    }

    // A window listing saved sites: change the profile each one opens in, or remove it.
    func showManager(preview: String?) {
        if profiles.isEmpty { profiles = loadProfiles() }
        let w = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 600, height: 380),
                         styleMask: [.titled, .closable], backing: .buffered, defer: false)
        w.title = "Profiley — Saved sites"
        w.isReleasedWhenClosed = false
        w.delegate = self
        manager = w
        reloadManager()
        w.center()

        if let out = preview {
            w.appearance = NSAppearance(named: .aqua)
            w.orderFront(nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let v = w.contentView!
                if let rep = v.bitmapImageRepForCachingDisplay(in: v.bounds) {
                    v.cacheDisplay(in: v.bounds, to: rep)
                    try? rep.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: out))
                }
                NSApp.terminate(nil)
            }
            return
        }
        NSApp.activate(ignoringOtherApps: true)
        w.makeKeyAndOrderFront(nil)
    }

    func reloadManager() {
        guard let w = manager else { return }
        let saved = loadSites().sorted { $0.key < $1.key }
        let reuse = Set(UserDefaults.standard.stringArray(forKey: "reuseTabSites") ?? [])

        let rows = NSStackView()
        rows.orientation = .vertical
        rows.alignment = .leading
        rows.spacing = 8
        rows.edgeInsets = NSEdgeInsets(top: 18, left: 20, bottom: 18, right: 20)
        let count = NSTextField(labelWithString: "Profiley has opened \(linksOpened()) for you")
        count.font = .systemFont(ofSize: 13, weight: .semibold)
        rows.addArrangedSubview(count)
        let note = NSTextField(wrappingLabelWithString: saved.isEmpty
            ? "No saved sites yet. Tick \"Always open this site this way\" in the popup, or add one below."
            : "These sites (and their subdomains) and links (and everything under them) open straight in the profile or browser shown. The longest match wins.")
        note.font = .systemFont(ofSize: 12)
        note.textColor = .secondaryLabelColor
        note.preferredMaxLayoutWidth = 560
        rows.addArrangedSubview(note)
        rows.setCustomSpacing(14, after: note)

        for (site, profile) in saved {
            let id = NSUserInterfaceItemIdentifier(site)
            let label = NSTextField(labelWithString: site)
            label.font = .systemFont(ofSize: 13)
            label.lineBreakMode = .byTruncatingMiddle
            label.toolTip = site
            label.widthAnchor.constraint(equalToConstant: 200).isActive = true
            let pop = choiceMenu(selecting: profile)
            pop.identifier = id
            pop.target = self
            pop.action = #selector(changeSaved(_:))
            let remove = NSButton(title: "Remove", target: self, action: #selector(removeSaved(_:)))
            remove.bezelStyle = .rounded
            remove.identifier = id
            let tab = NSButton(checkboxWithTitle: "Reuse open tab", target: self, action: #selector(toggleReuseTab(_:)))
            tab.identifier = id
            tab.state = reuse.contains(site) ? .on : .off
            tab.toolTip = "If this site is already open in a tab, jump to it instead of opening another"
            let row = NSStackView(views: [label, pop, tab, remove])
            row.spacing = 10
            rows.addArrangedSubview(row)
        }

        let field = NSTextField(string: addField?.stringValue ?? "")
        field.placeholderString = "Site or link, e.g. example.com"
        field.font = .systemFont(ofSize: 13)
        field.widthAnchor.constraint(equalToConstant: 200).isActive = true
        field.target = self
        field.action = #selector(addSite)
        let pop = choiceMenu(selecting: nil)
        let add = NSButton(title: "Add", target: self, action: #selector(addSite))
        add.bezelStyle = .rounded
        addField = field
        addPop = pop
        let addRow = NSStackView(views: [field, pop, add])
        addRow.spacing = 10
        if let last = rows.arrangedSubviews.last { rows.setCustomSpacing(16, after: last) }
        rows.addArrangedSubview(addRow)

        let showIcon = NSButton(checkboxWithTitle: "Show Profiley in the menu bar", target: self, action: #selector(toggleStatusItem(_:)))
        showIcon.state = UserDefaults.standard.bool(forKey: "hideMenuBarIcon") ? .off : .on
        rows.setCustomSpacing(20, after: addRow)
        rows.addArrangedSubview(showIcon)

        if !isDefaultBrowser() {
            let note = NSTextField(wrappingLabelWithString: "Profiley isn't your default browser yet, so links from other apps won't come here.")
            note.font = .systemFont(ofSize: 12)
            note.textColor = .secondaryLabelColor
            note.preferredMaxLayoutWidth = 560
            let make = NSButton(title: "Make default browser", target: self, action: #selector(makeDefaultPressed))
            make.bezelStyle = .rounded
            rows.setCustomSpacing(20, after: showIcon)
            rows.addArrangedSubview(note)
            rows.addArrangedSubview(make)
        }

        let content = NSView()
        rows.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(rows)
        NSLayoutConstraint.activate([
            rows.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            rows.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            rows.topAnchor.constraint(equalTo: content.topAnchor),
            rows.bottomAnchor.constraint(lessThanOrEqualTo: content.bottomAnchor),
        ])
        w.contentView = content
        w.setContentSize(NSSize(width: 600, height: max(160, rows.fittingSize.height)))
    }

    @objc func changeSaved(_ sender: NSPopUpButton) {
        guard let site = sender.identifier?.rawValue, let profile = sender.selectedItem?.representedObject as? String else { return }
        var sites = loadSites()
        sites[site] = profile
        saveSites(sites)
    }

    @objc func toggleReuseTab(_ sender: NSButton) {
        guard let site = sender.identifier?.rawValue else { return }
        var sites = Set(UserDefaults.standard.stringArray(forKey: "reuseTabSites") ?? [])
        if sender.state == .on { sites.insert(site) } else { sites.remove(site) }
        UserDefaults.standard.set(sites.sorted(), forKey: "reuseTabSites")
    }

    @objc func removeSaved(_ sender: NSButton) {
        guard let site = sender.identifier?.rawValue else { return }
        var sites = loadSites()
        sites[site] = nil
        saveSites(sites)
        reloadManager()
    }

    @objc func addSite() {
        guard let field = addField, let profile = addPop?.selectedItem?.representedObject as? String else { return }
        let typed = field.stringValue.trimmingCharacters(in: .whitespaces)
        let site = typed.contains("/") ? linkLevels(typed.contains("://") ? typed : "https://" + typed).last ?? "" : siteName(typed)
        guard site.contains(".") || site.hasPrefix("localhost"), !site.contains(" ") else { NSSound.beep(); return }
        var sites = loadSites()
        sites[site] = profile
        saveSites(sites)
        field.stringValue = ""
        reloadManager()
    }

    // First run: confirm the browser and its profiles, become the default, then try a link.
    func showSetup(preview: String?, done: Bool) {
        let w = setup ?? NSWindow(contentRect: NSRect(x: 0, y: 0, width: 520, height: 300),
                                  styleMask: [.titled, .closable], backing: .buffered, defer: false)
        w.title = "Welcome to Profiley"
        w.isReleasedWhenClosed = false
        w.delegate = self
        setup = w
        reloadSetup(done: done)
        w.center()
        if let out = preview {
            w.appearance = NSAppearance(named: .aqua)
            w.orderFront(nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let v = w.contentView!
                if let rep = v.bitmapImageRepForCachingDisplay(in: v.bounds) {
                    v.cacheDisplay(in: v.bounds, to: rep)
                    try? rep.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: out))
                }
                NSApp.terminate(nil)
            }
            return
        }
        NSApp.activate(ignoringOtherApps: true)
        w.makeKeyAndOrderFront(nil)
    }

    func reloadSetup(done: Bool) {
        guard let w = setup else { return }
        func label(_ s: String, size: CGFloat = 13, weight: NSFont.Weight = .regular, color: NSColor = .labelColor) -> NSTextField {
            let t = NSTextField(wrappingLabelWithString: s)
            t.font = .systemFont(ofSize: size, weight: weight)
            t.textColor = color
            t.preferredMaxLayoutWidth = 460
            return t
        }
        var views: [NSView]
        if done {
            let link = NSButton(title: "", target: self, action: #selector(tryLink))
            link.isBordered = false
            link.attributedTitle = NSAttributedString(string: "Open link to give feedback", attributes: [
                .font: NSFont.systemFont(ofSize: 13), .foregroundColor: NSColor.linkColor,
                .underlineStyle: NSUnderlineStyle.single.rawValue])
            link.toolTip = feedbackURL
            link.keyEquivalent = "\r"
            views = [label("You're set.", size: 17, weight: .semibold),
                     label("Try it: click the link below. Profiley will ask which profile to open it in, the same way it will for links from Slack, WhatsApp or Mail. It goes to the feedback page, so tell us how it went."),
                     link,
                     label("Open Profiley from Spotlight any time to see your saved sites.", size: 11, color: .tertiaryLabelColor)]
        } else {
            let installed = browsers.filter { NSWorkspace.shared.urlForApplication(withBundleIdentifier: $0.bundleId) != nil }
            let pop = NSPopUpButton(frame: .zero, pullsDown: false)
            pop.addItems(withTitles: installed.map(\.name))
            pop.selectItem(withTitle: setupBrowser.name)
            pop.target = self
            pop.action = #selector(setupBrowserChanged(_:))
            let profiles = loadProfiles(setupBrowser)
            let row = NSStackView()
            row.spacing = 16
            for p in profiles {
                let avatar = AvatarView(p)
                avatar.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([avatar.widthAnchor.constraint(equalToConstant: 56), avatar.heightAnchor.constraint(equalToConstant: 56)])
                let name = NSTextField(labelWithString: p.name)
                name.font = .systemFont(ofSize: 12)
                let card = NSStackView(views: [avatar, name])
                card.orientation = .vertical
                card.spacing = 6
                row.addArrangedSubview(card)
            }
            let go = NSButton(title: "Looks great", target: self, action: #selector(finishSetup))
            go.bezelStyle = .rounded
            go.keyEquivalent = "\r"
            go.isEnabled = !profiles.isEmpty
            views = [label("Links from other apps will open in the right profile of", size: 15, weight: .semibold), pop,
                     profiles.isEmpty ? label("No profiles found. Open \(setupBrowser.name) once, then come back.", color: .secondaryLabelColor) : row,
                     label("A link to a site you haven't saved shows these profiles to pick from. Tick \"Always open this site this way\" and it stops asking.", size: 12, color: .secondaryLabelColor),
                     label("Next, your Mac will ask to make Profiley your default browser. Say yes: that's how links reach Profiley. It doesn't show pages itself, it passes every link straight on to \(setupBrowser.name), in the right profile.", size: 12, color: .secondaryLabelColor),
                     go]
            if installed.isEmpty {
                views = [label("Profiley works with Comet, Google Chrome, Brave, Microsoft Edge and Vivaldi. None of them is installed.")]
            }
        }
        let stack = NSStackView(views: views)
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 14
        stack.edgeInsets = NSEdgeInsets(top: 22, left: 24, bottom: 22, right: 24)
        stack.translatesAutoresizingMaskIntoConstraints = false
        let content = NSView()
        content.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            stack.topAnchor.constraint(equalTo: content.topAnchor),
        ])
        w.contentView = content
        w.setContentSize(NSSize(width: 520, height: stack.fittingSize.height))
    }

    @objc func setupBrowserChanged(_ sender: NSPopUpButton) {
        guard let b = browsers.first(where: { $0.name == sender.titleOfSelectedItem }) else { return }
        setupBrowser = b
        reloadSetup(done: false)
    }

    @objc func finishSetup() {
        browser = setupBrowser
        UserDefaults.standard.set(browser.name, forKey: "browser")
        profiles = []
        makeDefault {
            guard isDefaultBrowser() else { return }  // they declined macOS's prompt; the button stays
            UserDefaults.standard.set(true, forKey: "setupDone")
            self.startAtLogin()
            self.reloadSetup(done: true)
        }
    }

    // Already running at login, so the first link of the day skips a cold start.
    func startAtLogin() {
        guard isDefaultBrowser(), #available(macOS 13.0, *), SMAppService.mainApp.status != .enabled else { return }
        do { try SMAppService.mainApp.register() } catch { NSLog("Couldn't add login item: %@", error.localizedDescription) }
    }

    @objc func tryLink() {
        setup?.close()
        NSWorkspace.shared.open(URL(string: feedbackURL)!)
    }

    @objc func makeDefaultPressed() { makeDefault { self.reloadManager() } }

    // macOS asks the user to confirm before the change takes effect.
    func makeDefault(then done: @escaping () -> Void) {
        guard #available(macOS 12.0, *) else { return done() }
        let ws = NSWorkspace.shared, me = Bundle.main.bundleURL
        ws.setDefaultApplication(at: me, toOpenURLsWithScheme: "http") { e in
            if let e { NSLog("Couldn't become the default browser: %@", e.localizedDescription) }
            ws.setDefaultApplication(at: me, toOpenURLsWithScheme: "https") { _ in
                DispatchQueue.main.async(execute: done)
            }
        }
    }

    func windowWillClose(_ n: Notification) {
        if n.object as? NSWindow === setup { setup = nil } else { manager = nil }
    }

    // Stays running between links so the next one skips a cold start; opening it again shows its window.
    // macOS also sends a reopen alongside each link to a running app, so only a reopen with no link around it shows a window.
    func applicationShouldHandleReopen(_ app: NSApplication, hasVisibleWindows: Bool) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard Date().timeIntervalSince(self.lastURLAt) > 1, self.panel == nil else { return }
            if let w = self.setup ?? self.manager { NSApp.activate(ignoringOtherApps: true); w.makeKeyAndOrderFront(nil); return }
            if UserDefaults.standard.bool(forKey: "setupDone") { self.showManager(preview: nil) } else { self.showSetup(preview: nil, done: false) }
        }
        return false
    }

    func choose(_ i: Int) {
        if i == profiles.count { return openPrivate() }
        guard profiles.indices.contains(i) else { return }
        let p = profiles[i], link = url
        if remember.state == .on && !host.isEmpty {
            var sites = loadSites()
            sites[rememberPop.titleOfSelectedItem ?? host] = p.name
            saveSites(sites)
            reloadManager()
        }
        next()
        openInBrowser(link, p)
    }

    func openInBrowser(_ url: String, _ p: Profile) {
        NSLog("Opening %@ in %@ profile %@", url, browser.name, p.name)
        launchBrowser(["--profile-directory=\(p.dir)", url])
        countOpen()
        bringBrowserForward()
    }

    // The browser sometimes opens the tab without coming forward, so hand focus to it explicitly.
    func bringBrowserForward() {
        let id = browser.bundleId
        if #available(macOS 14.0, *) { NSApp.yieldActivation(toApplicationWithBundleIdentifier: id) }
        for delay in [0.0, 0.3, 1.5] {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                NSRunningApplication.runningApplications(withBundleIdentifier: id).first?.activate(options: [.activateAllWindows])
            }
        }
    }

    // Any new browser process, even one that just forwards the link and quits, can leave a ghost icon in the Dock.
    // So a running browser gets the link over its own singleton socket, as a second instance would send it.
    func launchBrowser(_ args: [String]) {
        if sendToRunningBrowser(args) { return }
        if let exe = NSWorkspace.shared.urlForApplication(withBundleIdentifier: browser.bundleId)
            .flatMap({ Bundle(url: $0)?.executablePath }) {
            run(exe, args)
        } else {
            run("/usr/bin/open", ["-na", browser.name, "--args"] + args)
        }
    }

    // Chromium's protocol: "START\0<cwd>\0<argv0>\0<args…>", answered with "ACK".
    func sendToRunningBrowser(_ args: [String]) -> Bool {
        let path = home + "/Library/Application Support/" + browser.support + "/SingletonSocket"
        let fd = socket(AF_UNIX, SOCK_STREAM, 0)
        guard fd >= 0 else { return false }
        defer { close(fd) }
        var tv = timeval(tv_sec: 2, tv_usec: 0)
        setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &tv, socklen_t(MemoryLayout<timeval>.size))
        var addr = sockaddr_un()
        addr.sun_family = sa_family_t(AF_UNIX)
        guard let target = try? FileManager.default.destinationOfSymbolicLink(atPath: path),
              target.utf8.count < MemoryLayout.size(ofValue: addr.sun_path) else { return false }
        withUnsafeMutableBytes(of: &addr.sun_path) { buf in
            for (i, b) in target.utf8.enumerated() { buf[i] = b }
        }
        let connected = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { connect(fd, $0, socklen_t(MemoryLayout<sockaddr_un>.size)) }
        }
        guard connected == 0 else { return false }
        let msg = (["START", FileManager.default.currentDirectoryPath, "browser"] + args).joined(separator: "\0")
        let sent = msg.utf8CString.withUnsafeBufferPointer { write(fd, $0.baseAddress, $0.count - 1) }
        guard sent == msg.utf8.count else { return false }
        shutdown(fd, SHUT_WR)
        var reply = [UInt8](repeating: 0, count: 16)
        let n = read(fd, &reply, reply.count)
        return n >= 3 && String(decoding: reply[0..<3], as: UTF8.self) == "ACK"
    }

    func run(_ path: String, _ args: [String]) {
        let t = Process()
        t.executableURL = URL(fileURLWithPath: path)
        t.arguments = args
        try? t.run()
    }
}

final class KeyPanel: NSPanel {
    weak var picker: Picker?
    override var canBecomeKey: Bool { true }
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { picker?.next(); return }
        if let c = event.characters, let n = Int(c) { picker?.choose(n - 1); return }
        super.keyDown(with: event)
    }
}

let app = NSApplication.shared
let delegate = Picker()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
