# Introduction
ChitChat is a playground where you talk to yourself... kind of.

![chitchat](https://github.com/JamStop/chitchat/assets/9709734/2cce2f39-362d-47c4-819b-49e0ba6c6182)

Developed with the intention of being endlessly extensible to play with new messaging ideas and features.
In it's current state, the basic messaging flow and client-server architecture are complete. The skeleton
for app structure, data flow, networking, tests, and navigation are all there.
This means that there are reference points for feature development from this point onwards. The most important
goal of this first release is to make it so that even if I stopped working on this and went off the grid,
another engineer could pick it up and reason their way through it.

## Getting Started
The project is plug-and-play if you only intend to build it for previews.

For simulator and device runs, you'll need a **GoogleService-Info.plist** file with the proper firebase configs.
If you're seeing this, I've most likely sent you a valid one. Simply unzip and place it in the project root:

<img src="https://github.com/JamStop/chitchat/assets/9709734/e4471e85-7485-42e0-a54c-76327fdc7937" width="200" />

ChitChat runs off of an unsecured firebase cloud functions proxy I made for the OpenAI API, so leaking this config
isn't ideal.

With this file in place, you should be able to run, test, and everything.

## Features
The app currently supports text messages. You can have the chat bot send you a followup message by tapping
their icon on the top-left. The chat is contextually aware of the message thread, and is designed to hold
a conversation.

The primary focus of this release is to have a solid core messaging flow. The ideal experience is messaging
on a physical device, where you can experience the haptic feedback / application sounds.

# Architecture Walk-Through
## Project Layout
The project is heavily modularized, with most of the source code under the Packages/ folder and managed by SPM.
Modularizing your code early saves a huge headache when you inevitably need to do it later. Swift by nature makes it
unnatural to separate public interfaces from private implementation, and as your apps and teams grow your code becomes harder
and harder to reason through. Moving your app logic into modules forces you to think about what you're exposing and where you're
exposing it. I also like how clear a Package.swift is compared to the obtuse inner workings of the Xcode dependency GUI.

Pros:
- Code organization is instantly cleaner. Forcing function for the team to be mindful and intentional about what they're doing.
- Future features can pick and choose their dependencies. No need to think about the graph / the build system handles it for you
- SPM is better for big teams. Hooks in neatly with build tools.

Cons:
- The setup process is difficult if you don't know what you're doing. Wiring the basic flow for this to work can be painful at first.
- Inability to completely rely on SPM and in-text build pipelines is a heartbreaker. Still have to use Xcode for the main target and wiring.
- Modules have some growing pains that are solved by tribal knowledge (see my Image Bundle.module hack). Many bugs and headaches that could
be avoided if we just stuck to Xcode.

## The Composable Architecture / Elephant-in-the-Room
This app was built with [TCA, the SwiftUI equivalent of Redux.](https://github.com/pointfreeco/swift-composable-architecture)
This architecture pattern is rock solid for maintaining large codebases with many contributors, as once it's set up it's very
difficult to make features that break the dataflow.

Pros:
- Naturally solves SwiftUI's navigation problem similar to how coordinator / router patterns (MVVM-C) do. Because all of the app logic
comes from a top-level store that also handles navigation events, we have the pleasure of dead-simple and clear navigation and the ability
to build a ton of build tools / analysis due to centralized state.
- Logic and separation of concerns / state are readable at a glance. Not to say you can't do this with view models, but TCA by nature enforces
proper separation.
- TCA comes bundled with the entire Pointfree catalogue. You can (and should) pull these in regardless of whether you choose to lean into this
architecture, but it's nice to have it first-class. The callouts here are 1. swift-dependencies for incredible dependency injection and the best
stubbing for tests and previews that I've ever seen, 2. snapshot-testing for meaningful UI tests, and 3. swift-ui-navigation for an alternative
to Apple's struggle to make reasonable SwiftUI navigation, 4. @Perceptible brings SwiftUI's @Observable functionality backported to iOS 13 (??? I forget),
which is an incredible community service by Pointfree.
- The reducer model creates a clear unidirectional dataflow. This cannot be overstated.
- Once you pick it up, it's hard to picture building a personal project without TCA. Incredibly fast iteration, and things *just work* because
of the forced structure.

Cons:
- The learning curve is steep and the resources are non-existent. For personal use this is already rough, but for a company this could be
a huge mistake as new engineers would take much longer to ramp up. To be honest, I would probably stick with something like MVVM-C + Pointfree Dependencies
for corporate use, as the Apple APIs are documented much better. You can still have unidirectional dataflow, clean modularization, and proper dependency injection
without TCA (and without MVVM).
- There is so much boilerplate and know-how required to get things to work. Even more to get things optimized.
- The ever-changing API and third-party nature docks some huge points. It's always nicer to be closer to metal.

## Testing
Didn't have much time to get into this, as building the core of the app was a priority. Nevertheless, I wanted to show the bare minimum of two testing flows.
Snapshot testing is a great way of getting actual value out of UI tests, and unit tests for important core functions are mandatory. I didn't quite get to
integration tests, which are the happy medium, but this acts as a basic scaffold for testing.

## Data and Networking
Proxy server on Firebase Cloud Functions. Inquire if you want to see that bit of Node.js code.
This is necessary to avoid leaking my OpenAI API key. Bad practice aside, they revoke your key the moment it's on Github. Proxy servers are a bare minimum for third-party
APIs.

# All-in-All
Didn't quite get as much out as I wanted, but this is the 80-20 of software to me.
Features that barely couldn't make it:
- Emoji reactions to messages
- Message theming
- Test coverage, of course
- Precommit hooks + CI
- Other secret fun stuff

Will revisit this soon.
