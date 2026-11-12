# Shelved iOS Port Plan

Source of truth: `shelved-android` (Kotlin + Compose). It is read-only.
Target: native iOS app built with SwiftUI. It uses Liquid Glass wherever the system provides it and copies the Android app's look and behavior everywhere else.

Status: planning only. No app code has been written yet.

---

## 1. Feature inventory

Each item has a one-line acceptance description. "Same as Android" means the same copy, the same order, and the same edge cases.

### App shell
| # | Feature | Acceptance |
|---|---|---|
| A1 | Dark theme | The app is always dark (`.preferredColorScheme(.dark)`). The 8 palette colors live in the asset catalog. Screen backgrounds use `#0C0C0E`. |
| A2 | Tab navigation | A native `TabView` with Backlog, Search, Stats, and Profile. The selected tab survives the app moving to the background. |
| A3 | Tab bar minimize | The tab bar minimizes when you scroll down in Backlog only (see §2.4 for the gotcha). |
| A4 | Root routing | Onboarding shows until it is completed. After that, the main tabs show. "Sign in to save trial" opens a full-screen account flow over the tabs. |
| A5 | Image cleanup | On launch, orphaned profile and cover image files that the persistent library no longer references are deleted. |

### Backlog (`ui/backlog`)
| # | Feature | Acceptance |
|---|---|---|
| B1 | Grid | 3 columns. Each card shows the cover (2:3 crop, rounded 11 pt, gamepad placeholder), the name (2 lines), and stars if rated. The order is the repository order (newest first). |
| B2 | Status filter | Pills for All, Backlog, Playing, and Completed. Selecting one filters the grid. |
| B3 | Shelf search | The search toggle shows a field labeled "Search your shelf…". Matching is a case-insensitive substring match on the trimmed query. Hiding the field clears the query. |
| B4 | Sort | Five options: Recently added, Name A–Z, Name Z–A, Rating high→low, Rating low→high. Unrated games always sort last, with ties broken by name. The sort icon is accent-colored when the sort is not the default. |
| B5 | Empty states | With no filter: "Your shelf is empty" plus an "Add your first game" button. With a filter: "Nothing in this section". With a query: "No games found" plus "Nothing on your shelf matches “q”." |
| B6 | Multi-select delete | Long-pressing a game enters selection mode. The title becomes "N SELECTED" and the toolbar shows Clear and Delete. Tapping cards toggles them. Delete shows a confirmation ("Delete N game(s)?"). Deleting also removes the games' managed covers and drops them from favorites. |
| B7 | Edit game sheet | Shows the cover header, Status picker, Hours played (digits only), rating and review, notes, and Save. Nothing is written until you tap Save. Dismissing discards changes. |
| B8 | Ratings | 1–5 stars with a Clear button. The card shows a read-only star row with the VoiceOver label "N out of 5 stars". |
| B9 | Review | Free text with "Private to you." beneath it. It is trimmed on save. |
| B10 | Notes | A list of timestamped notes formatted as "MMM d, yyyy · h:mm a". A timestamp of 0 shows "Previously added". The draft field is shown first when there are no notes. "Add note" is disabled while the draft is blank, and "Add another note" reveals the field again. |
| B11 | Add game | The toolbar button opens a catalog search sheet → Game details sheet → status picker → "Add to Shelved". The new game goes to the top. Duplicate IDs are ignored. |

### Cover crop (Backlog editor, built in slice 5)
| # | Feature | Acceptance |
|---|---|---|
| C1 | Pick image | PhotosPicker, images only. "Choose new cover" changes to "Change cover" after a custom cover is set. |
| C2 | Crop sheet | A 2:3 viewport with an accent border. Drag pans, pinch zooms, and a slider zooms from 1× to 4×. Pan is clamped so the image always fills the viewport. The confirm button is disabled until the image has loaded or if it failed to load. |
| C3 | Save | The output is 1200×1800 JPEG at 0.9 quality, with the source capped at 50 MB and EXIF orientation respected. The new cover is a draft until Save. |
| C4 | Draft lifecycle | Dismissing deletes the draft file. Saving deletes the previously committed file. "Use original" clears the custom cover, but the committed file is deleted only after Save. Errors show "Couldn’t use that image…". |

### Search (`ui/search`)
| # | Feature | Acceptance |
|---|---|---|
| S1 | Query | 300 ms debounce. A blank query resets to Idle ("Find your next game / Search the IGDB game database."). Works signed out. |
| S2 | States | Loading spinner. Ready with no results shows "No games found.". Errors show the connection message or the unavailable message, each with Retry. |
| S3 | Results | Each row shows a thumbnail, the name, and the year. Tapping opens the details sheet. |
| S4 | Details sheet | Shows the basic info immediately, then loads `/v1/games/{id}`. Shows "Loading game details…". The About section clamps to 4 lines, with Read more / Show less when the text is over 240 characters. Shows up to 4 platforms joined by "  •  ". If the details request fails, the error appears inline and the sheet stays usable. |
| S5 | Add | Status picker defaulting to Backlog. Shows "Add to Shelved", or "Already in Shelved" (disabled) when the game is already in the library. |
| S6 | Catalog client | Sends GET with `X-Firebase-AppCheck`. A 401 refreshes the token once and retries. The Worker's `{"error"}` message is kept with the HTTP status. Legacy non-`igdb:` IDs skip the details request. LRU cache of 50 searches, keyed by the trimmed, lowercased query. |

### Stats (`ui/stats`)
| # | Feature | Acceptance |
|---|---|---|
| T1 | Summary | Games, Hours, Completed, Completion %. |
| T2 | Progress | A segmented bar (Backlog `#55555E`, Playing `#55C2A4`, Completed accent) plus legend rows with count and rounded %. |
| T3 | Playtime | "Avg. tracked game" (at most 1 decimal, "—" when 0) and "Top platform" (alphabetical tie-break, "—" when none). |
| T4 | Most played | Top 3 by hours, with ties broken by name, shown as rank, thumbnail, name, status, and "Nh". The section is hidden when empty. |
| T5 | Empty | Shows the empty-library state when there are no games. |

### Profile (`ui/profile`)
| # | Feature | Acceptance |
|---|---|---|
| P1 | Identity | Avatar (90 pt circle, accent border; shows the initial, or 🎮 if there is no name). Shows the name or "Add your name", plus "N game(s) shelved". |
| P2 | Sections | Bio, Favorite platforms (accent chips), Favorite games (up to 6, rows of 3), and Account card, each with its Android placeholder copy. |
| P3 | Edit profile sheet | Photo, display name, bio, platform multi-select (5 platforms), and favorite games picker (max 6, shown as a "· n/6" counter). Text is trimmed on save. |
| P4 | Profile photo | PhotosPicker → center square crop → 512×512 JPEG at 0.88, with the source capped at 20 MB. Draft/commit lifecycle is the same as C4. Shows "Saving photo…" and an error message on failure. |
| P5 | Menu | The ⋯ button opens a sheet with "Settings" and "About Shelved". On Android these do nothing yet (see decision D9). |
| P6 | Account card | Signed in: shows "Signed in as" with the email, "Email verification pending" when unverified, and Sign out. Trial: shows "You’re trying Shelved" with its body text and "Save my trial". |

### Onboarding (`ui/onboarding`)
| # | Feature | Acceptance |
|---|---|---|
| O1 | Welcome | An animated "S" mark (spring scale + fade), eyebrow, title, body, and "Get started". |
| O2 | Features | 3 feature cards and Continue. |
| O3 | Account choice | Sign in with Apple (replaces Google), "Continue with email", "Already have an account? Sign in", "Try Shelved first", and the trial fine print. |
| O4 | Email | A Create/Sign-in mode toggle with email, password (show/hide), and confirmation. "Forgot password?" in sign-in mode, the password note in create mode. Feedback cards for errors and notices. Return-key submit. |
| O5 | Verify | "Check your email." with the copy for each delivery state, "Continue to Shelved", and "Send the email again". |
| O6 | Chrome | Progress dots (3) and a Back button on Features, Account, and Email. Back is disabled while loading. Feedback clears on back and on edits. |
| O7 | Completion | Completion persists. "Try Shelved first" signs out, then completes onboarding. |

### Account (`ui/account`, signing in from a trial)
| # | Feature | Acceptance |
|---|---|---|
| AC1 | Screen | Full-screen with Back and the header "Account". Uses the "Save your library." or "Welcome back." copy, Sign in with Apple, "OR CONTINUE WITH EMAIL", and the same email form. Back is blocked while loading. |
| AC2 | Result | Success closes the screen. If verification is required, it shows the verification content instead of closing. Sign out clears the session in the UI immediately. |

### Try mode and library sessions
| # | Feature | Acceptance |
|---|---|---|
| L1 | Trial | When signed out, an in-memory library is used. It is never written to disk or Firestore, and it is gone when the process ends. |
| L2 | Import on sign-in | The trial's games and profile are merged into the account's library (the local copy wins for shared IDs and non-blank profile fields). The trial is then cleared. |
| L3 | Account switch | If the persistent library belongs to a different user, it is excluded from the import and replaced. |
| L4 | Sign out | The UI switches to a fresh empty trial. The persistent library stays on disk under its owner's ID. |

### Cloud sync (signed in)
| # | Feature | Acceptance |
|---|---|---|
| Y1 | Restore | On sign-in or launch, the cloud library is loaded, merged with local, and the merged result is written locally and backed up. |
| Y2 | Backup | Local changes are debounced by 500 ms and turned into diffs (profile, gameOrder, upserts, deletes) that are batched in chunks of up to 450. Device-only paths are never uploaded. |
| Y3 | Schema | Same as Android exactly. See §6. |

---

## 2. Android → iOS mapping

### 2.1 Architecture
| Android | iOS | Why / React analogy |
|---|---|---|
| `AppContainer` (manual DI) | `AppContainer` `@MainActor final class`, created once in `ShelvedApp` and handed to root views through init or `@Environment` | Same idea, no DI framework. Like a top-level React context provider. |
| `ViewModel` + `StateFlow` + `combine/stateIn` | `@Observable @MainActor final class …ViewModel` with stored `var`s and computed properties | Observation tracks exactly which properties a view reads. Derived state such as `visibleGames` is a computed property, like `useMemo` without the dependency array. |
| `collectAsStateWithLifecycle()` | Nothing. Reading an `@Observable` property inside `body` subscribes automatically. | Like a store with selectors built in. |
| `*Contract.kt` UiState | State lives as properties on the view model. Pure value types (`BacklogSort`, `SearchStatus`, `AuthMessage`, `StatsSummary`) become Swift `enum`s and `struct`s. | Swift enums with associated values are TypeScript discriminated unions. |
| `*Contract.kt` Action sealed interfaces | Plain methods on the view model (`selectGame(_:)`, `confirmDelete()`), see decision D4 | Idiomatic SwiftUI MVVM. Tests call the methods directly. |
| `isXSheetVisible` booleans | `var isSortPresented: Bool` / `var editingGame: Game?`, bound with `.sheet(isPresented:)` / `.sheet(item:)` | `@Bindable var vm` gives you `$vm.isSortPresented`, like passing `[value, setValue]`. |
| `remember { mutableStateOf }` (local view state such as editor drafts) | `@State private var` | `@State` is `useState`. |
| `viewModelScope.launch` / `Job.cancel()` | `Task { }` stored in a property, then `task?.cancel()` | Swift structured concurrency. Cancellation is cooperative, like `AbortController`. |
| `MutableStateFlow` repositories | `@Observable` repositories with `private(set) var games: [Game]` | Views and view models read the properties directly. |
| `combine(...).debounce(500ms).collect` (sync) | `Observations { repo.snapshot }` (iOS 26 `AsyncSequence`) plus a manual debounce with `Task.sleep` | Verified in the Apple `Observations` docs. No swift-async-algorithms dependency. |
| `OrderedWriteQueue` (Channel) | `OrderedWriteQueue<Value: Sendable>` built on `AsyncStream` with one consuming `Task` | 1:1 port, so both tests port unchanged. |
| `SharedPreferences` (onboarding, owner ID) | `UserDefaults` behind small protocols (`OnboardingCompletionStore`, `LibraryOwnerStore`) | The protocols are what make the code testable. |
| `SharedPreferences` JSON library | Codable JSON file in Application Support (decision D1) | |
| `callbackFlow` auth listener | `AsyncStream<AuthSession>` wrapping `Auth.auth().addStateDidChangeListener` | |
| `HttpURLConnection` + `org.json` | `URLSession.data(for:)` + `Codable` DTOs | |
| `LinkedHashMap(accessOrder=true)` LRU | Small `LRUCache<Key, Value>` struct, owned by an `actor CatalogSearchCache` | An actor gives the cache a thread-safe boundary without locks. |
| `Throwable.toSearchFailure()` | `Error.toSearchFailure()` mapping `URLError.Code`: `.notConnectedToInternet`, `.cannotFindHost`, `.cannotConnectToHost`, `.dnsLookupFailed`, `.networkConnectionLost` → noConnection, everything else → serviceUnavailable | Also walks `NSUnderlyingErrorKey` for wrapped errors. |
| Coil `AsyncImage` | `AsyncImage` for remote URLs; `Image(uiImage:)` loaded off the main thread for local covers | Rule: no image library. Tradeoff: no memory cache across scrolls (URLCache does cache on disk). Revisit in Polish only if scrolling stutters. |
| `ImageDecoder` / `BitmapFactory` + EXIF | ImageIO `CGImageSourceCreateThumbnailAtIndex` with `kCGImageSourceCreateThumbnailWithTransform` and `kCGImageSourceThumbnailMaxPixelSize` | One call downsamples and applies EXIF rotation. |
| `PickVisualMedia` | `PhotosPicker` (PhotosUI) with `Transferable` `Data` | Needs no photo-library permission prompt. |
| `strings.xml` | String Catalog `Localizable.xcstrings` (copy is verbatim) | |
| Firebase Android SDK | `firebase-ios-sdk` via Swift Package Manager (dependency, added in slice 4) | |

### 2.2 Screens
| Compose | SwiftUI |
|---|---|
| `ShelvedApp` (onboarding gate) | `RootView` switches on `onboardingViewModel.isCompleted` |
| `MainApp` + `FloatingNavigation` + `Scaffold` | `MainTabView`: `TabView(selection:)` with `Tab(...)`. The floating nav is not rebuilt. |
| `ShelvedScreen` (custom header row) | `NavigationStack` + `.navigationTitle` + `.toolbar { ToolbarItem }`. Toolbars get Liquid Glass automatically. |
| `BacklogScreen` / `BacklogHeader` / `BacklogGrid` | `BacklogView` / toolbar content / `LazyVGrid(columns: 3)` |
| `ShelvedSheet` (ModalBottomSheet, skipPartiallyExpanded) | `.sheet` + `.presentationDetents([.large])` (sort uses `[.medium]`) + `.presentationDragIndicator(.visible)`. A close button goes in the sheet's toolbar. |
| `AlertDialog` (delete) | `.alert` with a `.destructive` button |
| `EditGameSheet` + header, notes, review sections | `EditGameSheet` with `GameEditorHeader`, `GameNotesSection`, `GameReviewSection` |
| `GameCoverCropSheet` (`detectTransformGestures`) | `CoverCropSheet` using `MagnifyGesture` + `DragGesture` (simultaneous) + `Slider` |
| `SearchScreen` / `SearchField` | `SearchView` in `Tab(role: .search)` with `.searchable` (decision D8) |
| `CatalogGameSheet` | `CatalogGameSheet` (shared by Search and Add Game) |
| `StatsScreen` + components | `StatsView` + `StatsSummaryCard`, `LibraryProgressCard`, `PlaytimeInsights`, `MostPlayedRow` |
| `ProfileScreen` / `EditProfileSheet` / `ProfileAvatar` / `ProfileAccountCard` | Same names as `View`s |
| `OnboardingScreen` (AnimatedContent pager) | `OnboardingView`: `NavigationStack(path:)` pushing pages. You get native back and swipe-back for free, with the dots in the toolbar's principal slot. |
| `AccountAuthScreen` | `AccountAuthView` presented with `.fullScreenCover` |
| `GoogleSignInButton` | `SignInWithAppleButton(.signIn)` with `.signInWithAppleButtonStyle(.white)` (Apple's HIG requires the system button) |
| `StarRatingPicker` | `StarRatingPicker` exposed to VoiceOver as one adjustable element (`.accessibilityAdjustableAction`) instead of 5 buttons |

### 2.3 Data models
| Kotlin | Swift |
|---|---|
| `enum GameStatus { BACKLOG… }` | `enum GameStatus: String, Codable, CaseIterable { case backlog = "BACKLOG", playing = "PLAYING", completed = "COMPLETED" }`. The raw values must match Firestore exactly. |
| `enum Platform(label)` | `enum Platform: String, Codable, CaseIterable { case playstation = "PLAYSTATION", xbox = "XBOX", nintendo = "NINTENDO", pc = "PC", handheld = "HANDHELD" }` plus `var label` |
| `data class Game` with a `require` on rating | `struct Game: Identifiable, Hashable, Codable, Sendable`. The rating invariant is enforced by `struct Rating { init?(_ value: Int) }`: invalid values cannot be constructed, and decoders drop invalid values to nil. |
| `GameNote(text, createdAtEpochMillis: Long)` | `struct GameNote { text: String; createdAtEpochMillis: Int64 }`. The epoch-millis field name is kept for schema parity. |
| `Profile` | `struct Profile` (same fields) |
| `LibrarySnapshot` / `LibraryChanges` | Same, as `struct`s, with `withoutDeviceOnlyData()` and `changes(since:)` |
| `customCoverImagePath` / `profileImagePath` (absolute paths) | **File names only** (`cover_<uuid>.jpg`), resolved against the managed directory at read time. iOS changes the app container path on updates and reinstalls, so absolute paths would break. |

### 2.4 Liquid Glass placement (verified against Apple docs, see §8)

**Gets glass automatically (native components, no custom code):**
- Tab bar (`TabView` + `Tab`). It replaces `FloatingNavigation`.
- Navigation bars and toolbar buttons on every tab: Backlog search/sort/add, selection-mode Clear/Delete, Profile Edit/Menu.
- Sheets: the edit game, add game, catalog details, sort, edit profile, crop, and menu sheets. Per Apple's *Adopting Liquid Glass* guide, these **do not** set a custom `presentationBackground`. This is the one visible change from Android's flat `#16161A` sheets.
- The search field (`.searchable`), and the search tab when it uses `Tab(role: .search)`.
- Alerts and `confirmationDialog`.
- Primary toolbar action: the Backlog "+" uses `.buttonStyle(.glassProminent)` + `.tint(.accent)`.

**Stays solid, exactly like Android (content layer, never glass):** game covers and cards, filter and status pills, stat cards, feature cards, avatar, note entries, text fields, onboarding CTA buttons, and the crop viewport.

**Custom `.glassEffect`:** none planned. Apple says to use it "sparingly" for "the most important functional elements", and native toolbars already cover every floating control in this app. If we later add a custom floating control (for example, a selection-mode action bar), it gets `.glassEffect` and is wrapped with any glass siblings in a `GlassEffectContainer`.

**Gotcha found in the docs:** `.tabBarMinimizeBehavior(_:)` is set on the `TabView`, not on a single tab. To limit minimizing to Backlog, use `.tabBarMinimizeBehavior(selectedTab == .backlog ? .onScrollDown : .never)`.

**Accessibility:** native glass adapts on its own to Reduce Transparency and Increase Contrast. Check every custom color in both settings (§5.8).

---

## 3. Proposed folder structure

Xcode 26 and later uses folder-synchronized groups, so folders on disk are the groups. The layout mirrors Android's `data/` and `ui/` feature boundaries.

```text
shelved-ios/
├─ CLAUDE.md
├─ .gitignore                      # includes GoogleService-Info.plist, xcuserdata, DerivedData
├─ docs/
│  ├─ PORT_PLAN.md
│  └─ LEARNING_NOTES.md
├─ shelved-ios.xcodeproj
├─ shelved-ios/                  # app target folder (module name shelved_ios)
│  ├─ App/
│  │  ├─ ShelvedApp.swift          # @main, creates AppContainer
│  │  ├─ AppContainer.swift
│  │  └─ RootView.swift            # onboarding gate + account cover
│  ├─ Data/
│  │  ├─ Model/                    # Game, GameNote, Rating, GameStatus, Profile, Platform
│  │  ├─ Library/                  # LibraryRepository protocol, Persistent/InMemory/Active repos,
│  │  │                            # LibraryFileStore, OrderedWriteQueue, StoredLibraryCodec
│  │  ├─ Catalog/                  # GameCatalog protocol, CloudflareGameCatalog, LRUCache, DTOs
│  │  ├─ Auth/                     # AuthGateway, AuthSessionProvider, AuthModels, FirebaseAuthRepository,
│  │  │                            # AppleSignInNonce, AuthFailureMapper
│  │  ├─ Images/                   # ManagedImageDirectory, ImageDownsampler, CoverImageStore,
│  │  │                            # ProfileImageStore, CoverCropMath
│  │  ├─ Sync/                     # LibrarySnapshot, LibraryChanges, LibraryMerge, LibraryOwnerStore,
│  │  │                            # LibrarySessionCoordinator, LibrarySyncCoordinator,
│  │  │                            # CloudLibraryStore, FirestoreCloudLibraryStore, FirestoreGameCodec
│  │  └─ Preferences/              # OnboardingCompletionStore (UserDefaults)
│  ├─ UI/
│  │  ├─ Navigation/               # MainTabView, AppTab
│  │  ├─ Backlog/                  # BacklogView, BacklogViewModel, BacklogSort+filter, EditGameSheet,
│  │  │                            # GameEditorHeader, GameNotesSection, GameReviewSection, CoverCropSheet
│  │  ├─ Search/                   # SearchView, SearchViewModel, GameSearchController, SearchFailure,
│  │  │                            # AddGameSheet
│  │  ├─ Stats/                    # StatsView, StatsMapper, StatsSummary, Stats components
│  │  ├─ Profile/                  # ProfileView, ProfileViewModel, EditProfileSheet, ProfileAvatar,
│  │  │                            # ProfileAccountCard
│  │  ├─ Onboarding/               # OnboardingView, OnboardingViewModel, pages
│  │  ├─ Account/                  # AccountAuthView, AccountViewModel
│  │  ├─ Auth/                     # AuthMessage, validation, shared auth fields/buttons/verification
│  │  ├─ Components/               # GameCard, GameCover, FilterPill, StatusPicker, SectionLabel,
│  │  │                            # PrimaryButton, ShelvedField, StarRating, EmptyLibrary, CatalogGameSheet
│  │  └─ Theme/                    # Color+Shelved.swift (typed accessors for asset-catalog colors), typography
│  ├─ Resources/
│  │  ├─ Assets.xcassets           # colors (+ High Contrast variants), AppIcon
│  │  └─ Localizable.xcstrings
│  └─ PrivacyInfo.xcprivacy        # required privacy manifest (UserDefaults reason codes)
├─ shelved-iosTests/              # mirrors shelved-ios/: Data/…, UI/…, plus Fakes/
└─ shelved-iosUITests/            # template target; unused unless we add UI tests
```

---

## 4. Test inventory (22 test files, 68 cases; plus the `MainDispatcherRule` helper = 23 files)

Framework: Swift Testing (`@Test`, `#expect`), see decision D6. `MainDispatcherRule` has no equivalent: view model tests are marked `@MainActor` and await the view model's stored `Task` instead of calling `advanceUntilIdle()`.

| Android file | Cases | iOS test (slice) |
|---|---|---|
| `data/model/GameTest` | ratingMustBeBetweenOneAndFive: 0 and 6 are rejected, 5 is accepted, nil is OK | `RatingTests` (1) |
| `data/GameJsonCodecTest` | ratingAndPrivateReviewSurviveDeviceStorageRoundTrip (every field, including notes and custom cover); olderStoredGamesDefaultToNoRatingOrReview (missing keys → nil rating, "" review) | `StoredLibraryCodecTests` (1) |
| `data/InMemoryLibraryRepositoryTest` | aNewTrialRepositoryAlwaysStartsEmpty | `InMemoryLibraryRepositoryTests` (1) |
| `data/ActiveLibraryRepositoryTest` | switchingLibrariesUpdatesReadsAndRoutesFutureWrites | `ActiveLibraryRepositoryTests` (1) |
| `data/OrderedWriteQueueTest` | writesFinishInTheSameOrderTheyWereEnqueued (a slow first write still finishes first); failedWriteDoesNotStopLaterWrites | `OrderedWriteQueueTests` (1) |
| `ui/stats/StatsMapperTest` | emptyLibraryProducesEmptyStats; derivesSummaryProgressAndPlaytimeMetrics (5 games: 70 h, 40 %, 3 tracked, avg 70/3, Xbox, Halo/Forza/Celeste); platformAndPlaytimeTiesUseAlphabeticalOrder | `StatsMapperTests` (2) |
| `ui/backlog/BacklogFilterTest` | recentlyAddedPreservesRepositoryOrder; statusAndQueryAreCombined; alphabeticalSortIsCaseInsensitiveInBothDirections; ratingSortWorksInBothDirectionsAndKeepsUnratedGamesLast | `BacklogFilterTests` (3) |
| `data/CloudflareGameCatalogTest` | searchMapsGamesAndSendsAppCheckToken; unauthorizedResponseRefreshesAppCheckTokenOnce (token calls `[false, true]`, 2 requests); workerErrorMessageIsPreserved (429 + message) | `CloudflareGameCatalogTests` using a `URLProtocol` stub instead of a local HTTP server (4) |
| `ui/search/SearchFailureTest` | missingNetworkMapsToConnectionMessage; timeoutMapsToTemporaryServiceMessage; wrappedNetworkErrorsAreRecognized | `SearchFailureTests` with `URLError` codes (4) |
| `ui/backlog/BacklogSearchTest` | retryImmediatelyRepeatsTheCurrentQuery (fails once with a timeout → error state → retry → Ready, 2 calls) | `AddGameSearchTests` (4) |
| `data/cover/GameCoverCropTest` | landscapeImageGetsCenteredTwoByThreeCrop (3000×2000 → 1333×2000 @834,0); zoomAndOffsetsRemainInsideSourceImage; zoomIsClampedToSupportedRange; decodeResolutionGrowsWithZoomButRemainsMemoryBounded | `CoverCropMathTests` (5) |
| `data/image/ManagedImageDirectoryTest` | pruneKeepsReferencedFileAndDeletesOnlyManagedOrphans; removeCannotDeleteFileOutsideManagedDirectory | `ManagedImageDirectoryTests` using a temp directory. The second case also covers `../` names. (5) |
| `data/profile/ProfileImageStoreTest` | smallImagesDecodeAtOriginalResolution (800×600 → 1); largeLandscapeAndPortraitImagesAreSampledByLongestEdge (6000×1000 / 1000×6000 → 4) | `ImageDownsamplerTests`: the same pure `sampleSize(width:height:target:)` math decides the ImageIO max pixel size, so the inputs and outputs are identical (5) |
| `ui/backlog/GameCoverLifecycleTest` | croppedCoverStaysDraftUntilGameIsSaved; dismissingEditorDeletesDraftAndKeepsSavedCover; useOriginalOnlyDeletesCommittedCoverAfterSave; deletingGameAlsoDeletesItsManagedCover | `GameCoverLifecycleTests` (5) |
| `ui/profile/ProfileViewModelTest` | selectingImageCreatesDraftWithoutChangingSavedProfile; saveCommitsDraftAndRemovesPreviousImage; dismissDiscardsDraftAndKeepsSavedProfile; useDefaultOnlyDeletesSavedImageAfterSave | `ProfileViewModelTests` (5) |
| `ui/auth/AuthValidationTest` | createAccountRequiresValidMatchingCredentials; signInAllowsExistingPasswordsButRejectsMissingValues; resetRequiresAnEmailAddress | `AuthValidationTests` (6) |
| `ui/onboarding/OnboardingViewModelTest` | completedPreferenceSkipsOnboarding; localModeSignsOutAndPersistsCompletion; verifiedEmailSignInCompletesOnboarding (trims); failedVerificationDeliveryKeepsAccountAndOffersRetry; resendUpdatesVerificationDelivery; googleCancellation… → **appleCancellationReturnsToIdleWithoutAnError**; googleSignIn… → **appleSignInCompletesAndPassesCredentialToAuth** | `OnboardingViewModelTests` (6) |
| `ui/account/AccountViewModelTest` | existingSessionIsShownImmediately; emailSignInTrimsEmailAndClosesScreen; createAccountTrimsEmailAndShowsVerificationBeforeClosing; mismatchedCreateAccountPasswordsStayOnScreen; invalidCredentialsStayOnScreen; googleCancellation → **appleCancellationReturnsToIdle**; googleSuccess → **appleSuccessPassesCredentialAndClosesScreen**; resendUpdatesVerificationState; signOutClearsSessionWithoutWaitingForListener | `AccountViewModelTests` (6) |
| `data/sync/LibrarySessionCoordinatorTest` | signedOutSessionStartsWithAFreshTrialAndNeverSynchronizes; signingInImportsAndClearsTheTrialLibrary; signedOutToSignedInTransitionImportsGamesAddedDuringTheTrial (keeps rating and review); accountSwitchImportsTrialButExcludesThePreviousAccountsLibrary | `LibrarySessionCoordinatorTests` (6) |
| `data/sync/LibraryMergeTest` | firstSignInKeepsLocalGamesAndRestoresMissingCloudGames (6); deviceOnlyImagePathsNeverEnterCloudChanges (7); changingShelfOrderCreatesAnOrderUpdateWithoutRewritingGames (7); changingRatingOrReviewCreatesACloudGameUpdate (7) | `LibraryMergeTests` (6), `LibraryChangesTests` (7) |
| `data/sync/FirestoreGameCodecTest` | ratingAndPrivateReviewSurviveCloudRoundTrip (no `customCoverImagePath` key); olderAndInvalidCloudRatingsLoadAsUnrated | `FirestoreGameCodecTests` (7) |
| `data/sync/LibrarySyncCoordinatorTest` | restoresCloudLibraryIntoAnEmptyDevice (no writes); localChangesAreBackedUpAfterInitialMerge (initial upsert, then a second upsert after the debounce) | `LibrarySyncCoordinatorTests` (7) |

New iOS-only tests (no Android counterpart, added because the logic is new): `LRUCache` eviction (4), `coverTranslationLimit` clamp (5), Firestore 450-operation chunking (7), Apple nonce SHA-256 (6), and file-name-only image references (5).

---

## 5. Slices

Each slice is one branch and one PR. A slice is done when its ported tests pass. Nothing is committed or pushed without your go-ahead.

### Slice 0: Project setup (me, with you): no PR, or a tiny "chore" PR
Done: project linked to GitHub, `.gitignore` updated, iPhone-only portrait. Remaining: point `xcode-select` at Xcode, folder skeleton, asset-catalog colors, test target, CLAUDE.md, and these docs.

### Slice 1: Foundation (DELEGATE)
Models, `Rating`, stored JSON codec, `OrderedWriteQueue`, `LibraryFileStore`, Persistent/InMemory/Active repositories, `AppContainer`, theme colors. Tests: Rating, StoredLibraryCodec, InMemory, Active, OrderedWriteQueue (7 cases).
**Study:** WWDC23 *Discover Observation in SwiftUI*; WWDC21 *Meet async/await in Swift*; WWDC22 *Eliminate data races using Swift Concurrency*; WWDC24 *Meet Swift Testing*; docs: *Encoding and Decoding Custom Types*, *Observation*, `FileManager` / `Data.write(to:options:)`.
**You should be able to explain:**
1. Why `Game` is a `struct` (value semantics) and repositories are `@Observable` classes.
2. How `Codable` plus explicit `CodingKeys` keeps the on-disk JSON shape stable.
3. What `@MainActor` guarantees and why the write queue runs its I/O off the main actor.
4. How `ActiveLibraryRepository` switches libraries without the views noticing.
5. How a Swift Testing `@Test` and `#expect` differ from XCTest assertions.

### Slice 2: Stats (mapper DELEGATE, VM + views GUIDED)
`StatsMapper` + `StatsSummary` + tests (3 cases). Then you build `StatsViewModel`, `StatsView`, the cards, the progress bar, and the most-played rows.
**Study:** WWDC23 *Discover Observation in SwiftUI*; WWDC20 *Data Essentials in SwiftUI*; WWDC22 *Compose custom layouts with SwiftUI*; docs: *Text*, `LazyVStack`, `Grid`, *Previews in Xcode*, `FormatStyle`.
**You should be able to explain:**
1. Why the mapper is a pure function, and how that makes it trivial to test.
2. How a view re-renders when an `@Observable` property it reads changes.
3. `HStack`/`VStack`/`frame(maxWidth:)` versus Compose `Row`/`Column`/`weight`.
4. How `#Preview` with fake data replaces running the app.
5. How `.formatted(.number.precision(...))` localizes numbers.

### Slice 3: Backlog (GUIDED)
Grid, filters, shelf search, sort sheet, empty states, multi-select delete with alert, and the edit sheet (status, hours, rating, review, notes). Add-game is only stubbed as a sheet flag; its content arrives in slice 4. Tests: BacklogFilter (4 cases).
**Study:** WWDC25 *Build a SwiftUI app with the new design*; WWDC25 *Meet Liquid Glass*; WWDC22 *The SwiftUI cookbook for navigation*; docs: `LazyVGrid`, `.sheet` / `presentationDetents`, `.toolbar`, `.searchable`, `.alert`, `@Bindable`, `tabBarMinimizeBehavior`.
**You should be able to explain:**
1. `@State` versus `@Bindable` versus a plain `let` view model, and when to use each.
2. How `.sheet(item:)` drives the editor from optional state.
3. Why the editor uses local `@State` drafts and commits only on Save.
4. Which parts of the screen got Liquid Glass and why you added no code for it.
5. How the long-press selection mode is modeled as state, not as navigation.

### Slice 4: Search (client + cache DELEGATE, screen GUIDED)
Firebase dependency (Core + AppCheck), `CloudflareGameCatalog`, LRU cache, `SearchFailure`, `GameSearchController` (debounce, retry), and tests (catalog 3, failure 3, retry 1). Then you build `SearchView`, `CatalogGameSheet`, and `AddGameSheet`.
**Study:** WWDC21 *Use async/await with URLSession*; WWDC21 *Protect mutable state with Swift actors*; WWDC25 *Build a SwiftUI app with the new design* (search tab); docs: `URLSession`, `URLError`, `.searchable`, `TabRole.search`, `AsyncImage`; Firebase *App Check with App Attest on Apple platforms*.
**You should be able to explain:**
1. How `Task` cancellation implements debounce (compare it to `AbortController` + `setTimeout`).
2. Why the LRU cache sits inside an `actor`.
3. What App Check proves to the Worker, and why the token is sent as a header, not stored.
4. How `Tab(role: .search)` changes the tab bar layout.
5. How the 401 → refresh → retry flow avoids infinite loops.

### Slice 5: Profile + images (GUIDED)
`ManagedImageDirectory`, `ImageDownsampler`, the cover and profile image stores, cover-crop math, `ProfileViewModel`, `ProfileView`, `EditProfileSheet`, `ProfileAvatar`, the account card (with a placeholder session), `CoverCropSheet`, and the cover draft lifecycle in `BacklogViewModel`. Tests: CoverCrop 4, ManagedImageDirectory 2, Downsampler 2, GameCoverLifecycle 4, ProfileViewModel 4.
**Study:** WWDC23 *What's new in PhotosUI*; WWDC22 *Meet Transferable*; WWDC18 *Image and Graphics Best Practices* (downsampling); WWDC23 *Meet SwiftUI gestures*; docs: `PhotosPicker`, `MagnifyGesture`, `DragGesture`, `CGImageSourceCreateThumbnailAtIndex`.
**You should be able to explain:**
1. Why images are downsampled with ImageIO instead of loading a full `UIImage`.
2. Why only file names are stored, never absolute paths.
3. How the draft/commit lifecycle avoids orphaned files and early deletes.
4. How simultaneous magnify + drag gestures share one transform state.
5. Why the photo picker needs no permission prompt.

### Slice 6: Onboarding + auth (DELEGATE, plus a security review)
Firebase Auth, the email flows, Sign in with Apple (with nonce), the auth failure mapping, `OnboardingViewModel`, `AccountViewModel`, the onboarding pages, `AccountAuthView`, `LibrarySessionCoordinator`, `LibraryMerge`, and the owner store. Real Try-mode switching turns on here. Tests: AuthValidation 3, Onboarding 7, Account 9, SessionCoordinator 4, LibraryMerge 1. **Security review:** nonce handling, no credential logging, error messages that don't enumerate accounts, Keychain-backed Firebase session, account-exists-with-different-credential handling, and Apple token revocation on account deletion (D7).
**Study:** WWDC19 *Introducing Sign In with Apple*; WWDC20 *Get the most out of Sign in with Apple*; HIG *Sign in with Apple*; WWDC22 *The SwiftUI cookbook for navigation*; docs: `SignInWithAppleButton`, `ASAuthorizationAppleIDCredential`; Firebase *Authenticate Using Apple on Apple Platforms*.
**You should be able to explain:**
1. Why the Apple sign-in nonce is hashed before it is sent and kept raw for Firebase.
2. How `NavigationStack(path:)` drives onboarding pages as state.
3. How signing in during a trial merges and then clears the trial library.
4. Why cancellation is not an error.
5. What App Store guideline 4.8 and 5.1.1(v) require of this app.

### Slice 7: Cloud sync (DELEGATE, plus a data-loss and privacy review)
FirebaseFirestore, `FirestoreGameCodec`, `FirestoreCloudLibraryStore` (450-operation chunks), `LibraryChanges`, `LibrarySyncCoordinator` (Observations + debounce), and a cross-platform round trip with Android. Tests: Firestore codec 2, changes 3, sync coordinator 2. **Review:** the known Android behaviors in §7.3, offline launch, account switch, and that no device paths or other users' data are uploaded.
**Study:** WWDC21 *Meet AsyncSequence*; Apple docs: `Observations`; Firebase *Add data to Cloud Firestore* (batched writes), *Access data offline*, *Security Rules*.
**You should be able to explain:**
1. Why sync diffs snapshots instead of uploading the whole library.
2. Why batches are capped at 450 operations (Firestore limit 500, with headroom).
3. What happens to the merge when a game is edited on two devices.
4. How `Observations` + debounce compares to `combine().debounce().collect()`.
5. Why the Firestore schema must match Android byte-for-byte.

### Slice 8: Polish + accessibility (GUIDED)
Dynamic Type pass, Reduce Transparency, Increase Contrast color variants, VoiceOver labels and grouping, haptics (`.sensoryFeedback`), new app icon (Icon Composer), privacy manifest check, and launch screen.
**Study:** WWDC24 *Catch up on accessibility in SwiftUI*; WWDC23 *Build accessible apps with SwiftUI and UIKit*; WWDC25 *Say hello to the new look of app icons* + *Create icons with Icon Composer*; HIG *Accessibility*, *Typography*; docs: `accessibilityReduceTransparency`, `colorSchemeContrast`, `ScaledMetric`.
**You should be able to explain:**
1. Why fixed point sizes break Dynamic Type, and how text styles fix it.
2. How the asset catalog serves a High Contrast color variant automatically.
3. When to combine elements for VoiceOver (`.accessibilityElement(children: .combine)`).
4. What changes in native glass when Reduce Transparency is on.
5. How layered app icons differ from flat PNG icons.

### 5.8 Accessibility notes found during planning
- `#04342C` (accent text) on `#1D9E75` (accent) measures **4.04:1**, which is below WCAG AA 4.5:1 for the 13 pt pill text. For the High Contrast variant I suggest black (6.2:1). The default look stays as Android.
- Muted `#8A8A92` passes on every surface (4.85–5.71:1). The accent on the background measures 5.77:1.
- Android uses fixed `sp` sizes. iOS maps them to the nearest text styles (11→caption2, 12→caption, 13→footnote, 14–15→subheadline, 16–17→body/callout, 20–22→title3/title2, 34–36→largeTitle) so Dynamic Type works.

---

## 6. Firestore schema (must match Android exactly)

```text
users/{uid}
  schemaVersion: 2                (int64)
  updatedAt:     serverTimestamp
  gameOrder:     [String]         (game IDs in shelf order)
  profile: {
    displayName: String, bio: String,
    favoritePlatforms: [String]   ("PLAYSTATION" | "XBOX" | "NINTENDO" | "PC" | "HANDHELD"),
    favoriteGameIds: [String],
    visibility: "private"
  }                               (no profileImagePath, ever)
users/{uid}/games/{gameId}        (gameId like "igdb:1942" or a legacy RAWG "3498")
  name, coverImageUrl|null, status ("BACKLOG"|"PLAYING"|"COMPLETED"),
  hoursPlayed|null, rating|null (1–5), review, notes: [{text, createdAtEpochMillis}],
  released|null, playtime|null, platforms: [String], description|null,
  updatedAt: serverTimestamp      (no customCoverImagePath, ever)
```
The user document is written with `merge: true`. Game documents are fully replaced. Android writes explicit `null`s, so the iOS codec is a hand-written `[String: Any]` mapping using `NSNull()`. Codable would omit the keys instead.

---

## 7. Open decisions (each needs your answer before its slice)

**D1. Local storage: Codable JSON file (recommended) vs SwiftData.** **Decided 2026-11-12: Codable JSON file.** The SwiftData template files (`Item.swift`, template `ContentView`) are removed in slice 1.
- JSON file (`Application Support/library.json`, atomic writes, file protection `.completeUntilFirstUserAuthentication`): mirrors Android's whole-snapshot model (`replaceLibrary`, snapshot diffs for sync), has value types end to end, makes the tests trivial, needs no migrations, and a few hundred games is only a few hundred KB. Downside: every change rewrites the file, which is fine at this size.
- SwiftData: indexed queries, incremental writes, and good tooling. But `@Model` classes are reference types, which fights snapshot diffing and merging. It also needs a ModelContext per actor, migration plans, and heavier test setup. It adds nothing this app uses.

**D2. Minimum iOS: 26.0 (recommended, matches your lean).** **Decided 2026-11-12: iOS 26.0 on all targets.**
- Every Liquid Glass API, `Observations`, `tabBarMinimizeBehavior`, and `.glassProminent` is iOS 26+ (verified in the docs). There are no `#available` branches. iOS 27 is out and supports the same devices as 26 (iPhone 11+), so 26 covers both.
- Tradeoff: excludes iOS 18 users. Given the active-device share by late 2026, that is a small group.

**D3. Concurrency defaults: keep Xcode's new-project defaults (recommended).** **Decided 2026-11-12: Swift 6 language mode, MainActor default isolation, Approachable Concurrency on.** That means Swift 6 language mode, *Default Actor Isolation = MainActor*, and *Approachable Concurrency = Yes*. UI code needs no annotations. Pure models are marked `nonisolated` and `Sendable`, and I/O lives in `actor`s. The alternative (nonisolated default) needs `@MainActor` on every view model and view, which is more boilerplate for the same safety.

**D4. View model API: plain methods + bindable properties (recommended) vs keeping Android's `Action` enums with `send(_:)`.** Plain methods are idiomatic SwiftUI and read well at call sites (`vm.confirmDelete()`). Action enums give 1:1 diffs against Android and mirror Redux reducers. Tests port cleanly either way.

**D5. Cross-platform sign-in gap (important).** Android offers Google sign-in, but iOS will not. A user who signed up with Google on Android **cannot reach that account on iOS.** Options:
- (a) Add Sign in with Apple to Android later, plus Firebase account linking. Most consistent long-term.
- (b) Allow Google sign-in on iOS. This contradicts your auth rule, and App Store guideline 4.8 is already satisfied because Apple sign-in is offered.
- (c) Accept the gap for v1 and document "use email + password to sync across devices".
- Recommendation: (c) for v1, (a) as an Android follow-up. Also needed: handle `accountExistsWithDifferentCredential` when an Apple email matches an existing email-and-password account.

**D6. Test framework: Swift Testing (recommended) vs XCTest.** **Decided 2026-11-12: Swift Testing (the Xcode template already uses it).** It is Apple's current standard: parameterized tests, `#expect`, and async-first. Use XCTest only for UI tests, if we ever add them.

**D7. Account deletion (required for the App Store).** Guideline 5.1.1(v) requires in-app account deletion for any app that creates accounts, and Android doesn't have it. Proposal for slice 6/7: Profile → "Delete account" → reauthenticate → delete `users/{uid}/games/*` and `users/{uid}` (the rules already allow it) → revoke the Apple token → `user.delete()` → local wipe. Needs your approval, and it would ideally land on Android too.

**D8. Native vs parity UI choices.** Recommended defaults:
- Search tab uses `Tab(role: .search)`. The system moves it to the trailing end (Backlog, Stats, Profile, 🔍), which differs from Android's order. **Recommend native.**
- Backlog shelf search: use `.searchable` instead of a toggled custom field. **Recommend native.**
- Sort: a sheet at `.medium` detent (parity) vs a toolbar `Menu` with a `Picker` (more native). **Recommend the sheet, for parity.**
- Selection: long-press enters selection mode with a haptic (parity), not a context menu.
- Sheets: system glass background instead of flat `#16161A`. **Recommend system.**

**D9. Profile menu "Settings" / "About Shelved".** On Android these do nothing. Options: port as-is, hide them, or make About show the version and licenses. **Recommend replacing them with a working About and the Delete account action (D7).**

**D10. Android quirks: port them as-is or fix?** Recommend fixing the first two, which are tiny and user-visible, and porting the rest as-is:
- In Backlog → Add game, the details sheet never shows "Already in Shelved". Duplicates are silently ignored.
- In Backlog → Add game, details aren't fetched, so the sheet shows no description or playtime (Search fetches them).
- Hours played silently clears when the number overflows `Int`.

**D11. Legacy local migrations.** Android maps old keys (`favoritePlatform`, `SWITCH`, `STEAM_DECK`, notes stored as a string). No iOS install has old data, so **recommend skipping them locally**. The "missing keys → defaults" behavior is still ported and tested.

**D12. Apple Developer Program.** Sign in with Apple, App Attest, TestFlight, and on-device App Check all need a paid membership. Are you enrolled? Slices 1–3 work without it in the simulator.

**D13. App icon.** You don't like the current mark. A new layered icon goes in slice 8 via Icon Composer. Who designs it?

### 7.3 Known Android sync behaviors (keep for parity; flag in the slice 7 review)
- There is no live listener, so changes from another device appear only on the next launch or sign-in.
- Deletes can come back: a device that still has a game locally merges it back up on its next sync.
- If the initial cloud load fails (offline), backup is skipped for the rest of that session.
- On an account switch, the previous user's unsynced local changes are discarded (their cloud copy remains).
- On first sign-in, the local profile fields win over the cloud ones when they are non-blank.

---

## 8. Backend changes needed (listed only, not made)

1. **Worker: accept the iOS Firebase App ID.** `worker/src/env.ts` has a single `FIREBASE_APP_ID`, and `validateClaims` checks `claims.sub !== appId`. Change it to an allowlist (for example `FIREBASE_APP_IDS = "1:575171978673:android:…,1:575171978673:ios:…"`), check `allowed.includes(claims.sub)`, update `wrangler.jsonc` vars, and add a Worker test for both IDs plus rejection of an unknown ID.
2. **Worker rate limit (optional, existing issue).** The limiter key is the app ID, so *every* Android user shares one 30-requests-per-10-seconds bucket, and iOS would get its own shared bucket. Consider keying by `CF-Connecting-IP` (or IP + app ID).
3. **Firebase console: register the iOS app** (bundle ID, for example `com.paulrod.shelved`), then download `GoogleService-Info.plist`. Keep it out of git.
4. **Firebase App Check:** register the iOS app with **App Attest** (needs the App Attest capability and entitlement). Add simulator debug tokens under *Manage debug tokens*, and never commit them.
5. **Firebase Auth:** enable the **Apple** provider and configure what token revocation needs for account deletion (Team ID, Key ID, private key, per Firebase docs). Email/password is already enabled.
6. **Apple Developer:** App ID with the *Sign in with Apple* and *App Attest* capabilities.
7. **Firestore rules:** no change needed. They are already per-uid private, and delete is allowed for account deletion.
8. **Android follow-ups (optional):** Sign in with Apple (D5a) and account deletion (D7).

---

## 9. Apple documentation used to verify the APIs
- Adopting Liquid Glass: https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass
- Applying Liquid Glass to custom views: https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views
- `glassEffect(_:in:)`: https://developer.apple.com/documentation/swiftui/view/glasseffect(_:in:)
- `GlassEffectContainer`: https://developer.apple.com/documentation/swiftui/glasseffectcontainer
- `Glass`: https://developer.apple.com/documentation/swiftui/glass
- `tabBarMinimizeBehavior(_:)`: https://developer.apple.com/documentation/swiftui/view/tabbarminimizebehavior(_:)
- `Tab`: https://developer.apple.com/documentation/swiftui/tab · `TabRole.search`: https://developer.apple.com/documentation/swiftui/tabrole/search
- `glassProminent`: https://developer.apple.com/documentation/swiftui/primitivebuttonstyle/glassprominent
- `scrollEdgeEffectStyle(_:for:)`: https://developer.apple.com/documentation/swiftui/view/scrolledgeeffectstyle(_:for:)
- `Observations`: https://developer.apple.com/documentation/observation/observations
- `tabViewBottomAccessory(content:)` (not used, reviewed)
