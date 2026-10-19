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

## Suggested angle: Comet users

The one gap nobody else fills. Comet users with several profiles hit exactly this, and no router mentions Comet.

Draft post (for r/perplexity_ai or a Comet community, once its rules are checked):

> **Links from Slack/WhatsApp open in whatever Comet profile is in front. I made a small fix.**
>
> I keep work and personal in separate Comet profiles, and every link from Slack, WhatsApp or Claude landed in whichever one I'd used last. None of the link-router apps I found mention Comet, so I built one.
>
> Profiley becomes your default browser. A link from another app shows your Comet profiles with their avatars; press 1, 2, 3. Tick "always open this site this way" and it stops asking for that site. Option-click to get the popup anyway.
>
> Free and open source: github.com/kamal0808/profiley. Works with Chrome too.
>
> If you try it, I'd love to know which links still end up in the wrong place.

## Yes-line

Within 7 days of the post: at least 10 downloads beyond today's 3 (GitHub's release download count), and at least 3 strangers who comment, open an issue or say they use it. Friends don't count.

## Before posting

1. Notarize the release (Sayan's Apple Developer account, a Neki task per release, or TOPC's own $99 account).
2. A 10-second GIF of the popup for the post and the README.
3. Read the target subreddit's rules.
