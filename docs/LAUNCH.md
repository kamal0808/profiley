# Launching Profiley

Prep for topc-social/finicky-picker-tasks#4, written 2026-10-19; Reddit read on 2026-10-20 for #16.

## Where things stand

- v1.0 zip: 3 downloads, 0 stars on GitHub.
- Signed ad-hoc only (`build.sh`), not notarized. Every stranger gets macOS's "can't check it for malware" warning and has to go to Privacy & Security → Open Anyway. That alone will lose most downloads from a public post.

## Who else does this

The problem is real: several people built their own app for it this year. That also means a crowded shelf.

| App | What it does | Overlap with Profiley | Source |
|---|---|---|---|
| LinkPrism | Menu bar app plus a Chrome extension; profile picker with "Don't ask again for this URL"; macOS 14+ | Nearly the same popup-that-learns. Doesn't mention Comet | [dev.to, Mar 1](https://dev.to/badaverse/i-built-a-macos-app-to-stop-links-from-opening-in-the-wrong-chrome-profile-3e1f) |
| Yojam | Default-browser router; rules by domain, regex or source app; picker at the cursor; strips trackers | Rules-first, profiles as targets | [Show HN, 2026-04-19, 4 points](https://news.ycombinator.com/item?id=47822198) |
| Choosy | Rules, prompt as a fallback, Chrome/Edge/Brave/Vivaldi profiles; $10 | Remembering means writing a rule | [choosy.app](https://choosy.app/help/settings/rules) |
| Velja, Finicky, OpenIn | Rule-based routers | You write the rules | [shiftplus.app](https://shiftplus.app/blog/open-links-in-specific-chrome-profile-mac/) |
| Chrome Profile Switcher | A Dock icon per profile, $49; doesn't route links | Different job | [zwaystudios.com](https://zwaystudios.com/blog/open-links-in-specific-chrome-profile-mac) |

Profiley's edge, honestly: **Comet** (none of the others mention it), no browser extension needed, macOS 12+, and the profile avatars in the popup. The popup-that-learns itself isn't unique (LinkPrism has it).

## Where people talk about it

Reddit was read on 2026-10-20 (topc-social/finicky-picker-tasks#16), through the Reddit API: about 45 searches over the past year, then the threads below opened with their comments.

**What Reddit actually holds.** Almost nobody posts "my links open in the wrong profile" as a question. What shows up instead is a steady stream of people who had the problem and built their own fix: BrowBro, AltBrowse, Switchlet, SwitchBoard, Chowser, Proxly, a Linux "Browser Picker", BrowSel for Windows, all in the last eight months. The pain is real (every one of them opens with it), but the audience is people who browse Mac apps, not people asking for help.

**The place: r/macapps.** It's where Mac users go to find small utilities, it passed 250,000 members ([mods' post, 2026-09-22](https://www.reddit.com/r/macapps/comments/1wncput/congratulations_to_rmacapps_for_reaching_250000/)), and browser pickers land there and get read: AltBrowse 12 comments, Coherence X6 (Chrome link rules) 56, Proxly 24, Orbit (juggling Google accounts) 65. Its monthly promo thread, [The App Pile, October 2026](https://www.reddit.com/r/macapps/comments/1wuoav5/megathread_the_app_pile_october_2026/), had 309 comments by Oct 20, and the mods list their top 5 picks from it at the start of the next month.

House rules that matter ([rules](https://www.reddit.com/r/macapps/about/rules), [Phase 3 post](https://www.reddit.com/r/macapps/comments/1ryaeex/rmacapps_mods_went_too_far_whats_changing_phase_3/)):
- **10 karma in r/macapps first**, earned without links or promotion. Kamal's account (u/Popular-Stay-2637) has low karma, so this is step one.
- Profiley isn't on the Mac App Store and the repo is under a year old with 0 stars, so it goes in **The App Pile megathread**, not the main feed. The main feed opens up (Tier 2) if the post links a real identity (LinkedIn) and the site has a **Privacy Policy and Terms**; profiley.topc.social has neither yet (`/privacy` and `/terms` are 404).
- **PCP format**: Problem, Comparison (name a competitor or two, and something they do better), Pricing. Screenshot or video needed to be considered for the top picks. Prefix open source with [OS].
- Once per 30 days, megathread included. Always say you're the developer.
- Promoting in comments only after 10 karma, and "in poor taste when hijacking another developer's promotion".
- AI-formatted text (em dashes and the like) gets auto-removed more often. Post in Kamal's own words.

Second place, smaller: **r/MacOSApps** ([SwitchBoard](https://www.reddit.com/r/MacOSApps/comments/1ufac91/i_built_switchboard_a_native_swiftui_utility_to/), [Switchlet](https://www.reddit.com/r/MacOSApps/comments/1txl20b/free_switchlet_open_links_in_the_right_browserapp/) launched there). Needs 5 karma there, and the post must say who you are, whether the app is notarized, link a privacy policy and disclose AI use.

Not here: r/mac bans all promotion, even free apps you made. Hacker News: Show HNs for this kind of app got 1 to 4 points.

### Fresh threads (open, not archived; Reddit archives at 6 months)

1. **r/brave_browser, 2026-07-28**: [Is there a way to open a link into a specific container/profile?](https://www.reddit.com/r/brave_browser/comments/1v8u92u/is_there_a_way_to_open_a_link_into_a_specific/) "I'd like to right-click a link (or apply a rule) so it opens in a specific container or profile rather than my default." Brave says per-profile links are planned, no date. Brave is supported, so Profiley fits for links from other apps.

   > On a Mac you can do the "rule" part today for links you click in other apps (Slack, Mail, WhatsApp). An app sits in as your default browser and hands each link to the Brave profile you want. Finicky and Velja do it with rules you write. I made a free one called Profiley that asks once per site which profile and then remembers: https://profiley.topc.social (it's mine, open source). For right-clicking links inside Brave itself, the containers feature is the real answer.

2. **r/macapps, 2026-09-20**: [AltBrowse: a Mac menubar browser picker](https://www.reddit.com/r/macapps/comments/1wlhloy/altbrowse_a_mac_menubar_browser_picker_default/). A user asked "Does it support individual Chrome or Brave profiles too? Being able to open work links in the right Google account would make this especially useful." The developer said it can't. This is another developer's promo thread, so only after 10 karma, and the reply names other apps too, so it answers the question rather than hijacks:

   > A few pickers do profiles: Velja and Choosy (paid), BrowBro (free, open source), and Profiley, which I made (free, open source, asks once per site and remembers): https://profiley.topc.social

3. **r/diabrowser, 2026-08-05**: [Two blockers for going 100% Dia: per-profile link routing](https://www.reddit.com/r/diabrowser/comments/1vgfmge/two_blockers_for_going_100_dia_teams_pwa_install/). "The per-profile link routing would aid me so much too... Our VPN uses SSO, and if that opens in my personal profile it fails." Two more Dia threads asked the same in April ([1](https://www.reddit.com/r/diabrowser/comments/1sex9p3/is_there_a_way_to_force_certain_links_to_open_in/), [2](https://www.reddit.com/r/diabrowser/comments/1so2mvy/please_give_us_a_option_to_open_links_on_specific/), archived). **No reply**: Profiley doesn't support Dia, and a commenter says Dia has no `--profile` launch flag, so no outside app can route to its profiles yet. Worth knowing as demand if Dia ever adds one.

That's all that's fresh and fits. Other on-topic threads were other developers' launches ([BrowBro](https://www.reddit.com/r/browsers/comments/1upk0j4/browbro_a_free_opensource_browser_chooser_for/), [Linux Browser Picker](https://www.reddit.com/r/omarchy/comments/1vr7h7k/i_got_tired_of_links_opening_in_the_wrong_browser/), [BrowSel](https://www.reddit.com/r/sideprojects/comments/1x8973j/i_built_browsel_a_free_windows_tool_that_asks/)), already solved ([Stream Deck button for a Chrome profile](https://www.reddit.com/r/elgato/comments/1t5fpvo/google_chrome_profile_advice_mac/)), or archived. Replies alone won't carry the launch; the megathread post is the main move.

### A risk found on the way

[r/mac, 2026-09-29](https://www.reddit.com/r/mac/comments/1wt9vps/choosy_not_detecting_chrome_profiles_after_macos/): after updating to macOS 27, Choosy stopped seeing Chrome profiles until it got Full Disk Access. Profiley reads the same file (Chrome's `Local State` under `~/Library/Application Support`), so it may hit the same wall on macOS 27. Untested: Kamal's Mac is on macOS 26.

### More apps doing this (add to the table above)

| App | What it does | Source |
|---|---|---|
| BrowBro | Free, open source picker; Chrome profiles; keys 1 to 9 | [r/browsers, 2026-07-07](https://www.reddit.com/r/browsers/comments/1upk0j4/browbro_a_free_opensource_browser_chooser_for/) |
| Switchlet | Free; finds Chrome, Firefox, Arc, Safari profiles; per-domain rules | [r/MacOSApps, 2026-06-05](https://www.reddit.com/r/MacOSApps/comments/1txl20b/free_switchlet_open_links_in_the_right_browserapp/) |
| SwitchBoard | Rules by source app and domain; profiles are Pro | [r/MacOSApps, 2026-06-25](https://www.reddit.com/r/MacOSApps/comments/1ufac91/i_built_switchboard_a_native_swiftui_utility_to/) |
| AltBrowse | Browser picker, no profiles | [r/macapps, 2026-09-20](https://www.reddit.com/r/macapps/comments/1wlhloy/altbrowse_a_mac_menubar_browser_picker_default/) |
| Chowser | Free, open source, rule-based, Brave profiles | [r/developersIndia, 2026-02-24](https://www.reddit.com/r/developersIndia/comments/1rd5cn2/if_youre_someone_like_me_who_uses_multiple/) |

The ask-once-then-remember idea isn't unique either: the Linux Browser Picker offers to make a site permanent after three picks. What's left as Profiley's own: one pick is enough, no rules screen, real profile pictures in the popup, and Comet.

## Angle: what it does, in one line

Kamal ruled out a Comet-only angle (2026-10-19): it has to work with whatever browser people use. The site's line is the pitch: **"Open every link in the right browser profile."** It picks up the browser you already use (Chrome, Comet, Brave, Edge, Vivaldi) and its profiles on install. What's actually ours against LinkPrism/Choosy/Velja: no rules to write and no extension; it asks once per site with your real profile pictures and remembers.

Draft post for The App Pile megathread (r/macapps), in PCP format. Attach the demo video (`site/demo.mp4`). Kamal: put it in your own words before posting, and check the AI line is true.

> **[OS] Profiley: open every link in the right browser profile**
>
> I'm the developer, Kamal.
>
> **Problem:** I keep a work and a personal Chrome profile. Links from Slack, WhatsApp and Mail open in whichever profile was last in front, so work docs keep landing in my personal account. Profiley sits in as your default browser. The first time it sees a site it asks which profile (press 1, 2, 3) and remembers. Hold Option to change your mind. It finds your browser and its profiles by itself: Chrome, Comet, Brave, Edge or Vivaldi.
>
> **Comparison:** Velja and Choosy can do this too, but you write the rules yourself. Profiley learns from one pick per site. BrowBro (also free) is better if you live in several browsers' profiles at once; Profiley works with the profiles of the browser you already use, and can send a site to Safari, Firefox or any other browser you have.
>
> **Pricing:** Free, MIT licensed. Not notarized yet (Apple's fee is ₹8,700 a year); the site shows the one-time Open Anyway step. Built with a lot of help from Claude Code. https://profiley.topc.social
>
> If a link still lands in the wrong place, tell me which.

The same post works for r/MacOSApps once there's a privacy page to link (rule 12).

## Yes-line

Within 7 days of the post: at least 10 downloads beyond the count on the day of posting (GitHub's release download count), and at least 3 strangers who comment, open an issue or say they use it. Friends don't count.

## Before posting

1. ~~Notarize the release first.~~ Decided 2026-10-21 (Kamal): launch unsigned. Signing is parked (topc-social/finicky-picker-tasks#8: Sayan's individual team can't give out the certificate). The site's Download button opens a short wizard that explains the one-time Open Anyway with a video, so strangers know what's coming. Say it plainly in every post (r/MacOSApps requires it).
2. Start now: earn 10 karma in r/macapps with honest, link-free comments on threads Kamal has a real view on.
3. Add a privacy page to profiley.topc.social (kamal0808/profiley#12, open) (Profiley collects nothing; the feedback form goes to Netlify). Needed for r/MacOSApps, and with a terms page it opens the r/macapps main feed.
4. Check Profiley on macOS 27 (see the risk above).
5. Post early in the month: November's App Pile opens around Nov 1, and a full month in the thread beats ten days left in October.
