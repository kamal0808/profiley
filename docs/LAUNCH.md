# Launching Profiley

Prep for topc-social/finicky-picker-tasks#4, written 2026-10-19. Reddit wasn't searched (it blocks plain fetches and the browser wasn't used), so the main place where Mac users talk about this is still unread.

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

- Hacker News: the two Show HNs for this kind of app got 4 points ([Yojam](https://news.ycombinator.com/item?id=47822198)) and 1 point ([Turnstile](https://news.ycombinator.com/item?id=48296321)). Not a good place.
- Brave community: "it then opens a new Brave window with my work profile instead" ([thread, July 2022](https://community.brave.app/t/hyperlinks-opens-in-the-wrong-profile/417575)). Proof the pain exists, too old to reply to.
- Reddit (r/macapps, r/chrome, r/perplexity_ai for Comet): not read. Likely the right place, but unverified, including house rules on self-promotion.

No fresh thread was found to reply to.

## Angle: what it does, in one line

Kamal ruled out a Comet-only angle (2026-10-19): it has to work with whatever browser people use. The site's line is the pitch: **"Open every link in the right browser profile."** It picks up the browser you already use (Chrome, Comet, Brave, Edge, Vivaldi) and its profiles on install. What's actually ours against LinkPrism/Choosy/Velja: no rules to write and no extension; it asks once per site with your real profile pictures and remembers.

Draft post (r/macapps or similar, once its self-promotion rules are checked):

> **Work links kept opening in my personal Chrome, so I made a tiny Mac app for it**
>
> Click a link in Slack, WhatsApp or Mail and it opens in whichever browser profile was last in front. Profiley opens every link in the right profile instead. The first time it sees a site it asks which profile (press 1, 2, 3), tick "always" and it never asks again. Hold Option to change your mind.
>
> It picks up your browser and profiles by itself (Chrome, Comet, Brave, Edge, Vivaldi). Free, open source, built in public: https://profiley.topc.social
>
> If you try it, tell me which links still land in the wrong place.

## Yes-line

Within 7 days of the post: at least 10 downloads beyond the count on the day of posting (GitHub's release download count), and at least 3 strangers who comment, open an issue or say they use it. Friends don't count.

## Before posting

1. Notarize the release (topc-social/finicky-picker-tasks#8; Sayan's team, via a clean Apple ID). Until then friends install with the Open Anyway steps on /install.
2. Read the target subreddit's rules.
