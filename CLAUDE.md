# Shelved iOS

Native SwiftUI port of the Shelved Android app. The Android repo is the source of truth for behavior and is READ-ONLY: never modify it. Android repo path: ~/Developer/Apps/shelved-android (file permissions are read-only). Plan: docs/PORT_PLAN.md.

## Collaboration
- The owner reviews every change. Work directly on main (solo project, no feature branches or PRs). Keep commits small and focused.
- NEVER commit, push, open a PR, or change git remotes without the owner's explicit approval in chat.
- Claude implements every slice. After each slice, give a short summary of what changed, any choices the owner should know about, and how to try it. No teaching walkthroughs or check questions.
- Ask before deciding anything listed under Open decisions in PORT_PLAN.md. Say so before adding any dependency.
- Always use the industry-standard pattern; no throwaway simplified versions.
- Slices 6 (auth) and 7 (cloud sync) get an extra review: security for 6, data loss and privacy for 7.

## Architecture
- MVVM. Views are layout only. View models are @Observable and @MainActor. No networking or persistence in views.
- The folder structure mirrors Android's data/ and ui/ feature boundaries (see PORT_PLAN §3).
- Keep functions small and code simple. No speculative abstractions.

## Behavior parity
- Statuses: backlog, playing, completed. Ratings 1–5. Notes, reviews, stats, profile, and 5 platforms: PlayStation, Xbox, Nintendo, PC, PC Handheld.
- Try mode: an in-memory library, discarded when the app process ends, that never touches Firestore. Signing in during a trial imports its games and profile into the account.
- Port every Android test case to Swift Testing. A slice is not done until its ported tests pass.

## Cloud and catalog
- The Firestore schema matches Android exactly: users/{uid} with a profile map, a gameOrder array, schemaVersion 2, and a games subcollection. Batch writes in chunks of 450 or fewer. Data stays private per user.
- Game IDs use the igdb:<id> namespace. Legacy RAWG numeric IDs work for display only. Custom covers and profile photos stay on the device and are stored as file names, not absolute paths.
- Catalog: Cloudflare Worker at https://shelved-game-api.paulyd0123.workers.dev. GET /v1/search?query= and GET /v1/games/{id}, with the App Check token in the X-Firebase-AppCheck header. In-memory LRU search cache. Search works without signing in.
- Never commit secrets or API keys. GoogleService-Info.plist stays out of git.

## Auth
- Email plus Sign in with Apple. No Google sign-in on iOS.

## Design
- Always dark. Asset-catalog colors: Background #0C0C0E, Surface #16161A, Elevated #1E1E22, Accent #1D9E75, AccentText #04342C, Text #FFFFFF, Muted #8A8A92, Border #333338.
- Prefer native components (TabView with Tab, toolbars, sheets, searchable). They adopt Liquid Glass on iOS 26+. Use .glassEffect only for custom floating controls, wrap sibling glass views in GlassEffectContainer, and never put glass on game covers or cards. Use .tabBarMinimizeBehavior(.onScrollDown) only while the Backlog tab is selected.
- Do not rebuild the Android floating nav bar. Verify glass APIs against Apple's current docs and cite the pages used.
- Support Dynamic Type, Reduce Transparency, Increase Contrast, and VoiceOver labels.

## Git
- Commit messages: a short imperative subject; for larger commits, a body with one bullet per file or area and which tests passed.
- No AI attribution anywhere: no Co-Authored-By trailers, no "Generated with Claude Code", no session links, in commits, code comments, or docs. Commit messages are plain imperative, written as the owner.
