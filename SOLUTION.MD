# Applaudo iOS Challenge — Solution

## Overview

The application was developed as a cat breed explorer that allows users to:

- Fetch breeds from The Cat API.
- Navigate to the details of each breed.
- Register cats through a three-step form.
- Persist registered cats locally.
- View and delete cats stored on the device.

## Architecture

The application uses **MVVM** because it provides a simple and appropriate solution for the scope and complexity of the project. It also integrates naturally with SwiftUI and Combine, keeping presentation, state management, and data operations separated.

### Responsibilities

#### Views

Views are responsible only for composing and presenting SwiftUI interfaces. They observe state published by ViewModels and communicate user actions.

#### ViewModels

ViewModels manage UI events and the state required to render each screen. They also coordinate data retrieval and persistence through services, keeping those responsibilities out of the views.

#### Services

Services encapsulate the application's data sources:

- Network services retrieve breed information.
- A local service saves, retrieves, and deletes registered cats.

#### Models

Models represent the data used throughout the application. They remain simple data structures without complex business logic.

## State Management and Networking

**Combine** connects network services to ViewModels and publishes state changes observed by SwiftUI.

Combine was an appropriate choice because it is a reactive solution that integrates with SwiftUI. In a UIKit-based implementation, alternatives such as delegates or callbacks could also be considered depending on the required flow.

The breed list handles loading, empty, and error states. It also implements incremental pagination: previously loaded results remain visible while the next page is requested, and a progress indicator is displayed during that operation.

## Local Persistence

Registered cats are encoded as JSON and stored in the app's **Application Support** directory.

This approach was selected for its practicality and its ability to handle collections without relying on `UserDefaults`, which is better suited for preferences or small amounts of data.

Core Data or SwiftData would be more appropriate for a domain containing multiple entities, relationships, and complex queries. This application only needs to persist a collection of a single entity type, so introducing that level of infrastructure would add complexity without providing a proportional benefit.

Writes are performed atomically to reduce the risk of leaving partially written data. The local service also supports injecting a different file location, allowing persistence to be tested without using the application's real storage.

## User Experience Decisions

In addition to the requested functionality, a **My Cats** section was added. The requirements specified that cats should be stored locally but did not define where users could view them afterward.

This section allows users to:

- View registered cats.
- Access all collected information from a detail screen.
- Delete an individual stored cat.
- Open the registration form from the empty state.

The registration form is divided into three clearly identified stages:

1. Required basic information.
2. Optional additional information.
3. A read-only summary and confirmation.

Validation errors are displayed next to their corresponding fields. Numeric fields restrict input to digits, and users cannot proceed while the current step contains invalid information.

## Testing

Tests cover the application's and networking module's primary behaviors, including:

- Building and validating local cat profiles.
- Persisting and deleting cats.
- Moving through the form stages.
- Paginating the breed list.
- Building network requests.
- Decoding responses and mapping errors.

## Trade-offs and Simplifications

Due to the available development time, the following items were kept out of scope:

- Creating, retrieving, and deleting cats through remote services.
- Selecting and persisting an image for each registered cat.
- Additional functionality available through The Cat API.

The implementation prioritizes a complete core flow, reliable local persistence, clear UI states, and application stability.

## Future Improvements

With more time, the application could be expanded with:

- Advanced filters and search for breeds and registered cats.
- Pet synchronization through the API.
- Uploading and downloading pet information and images.
- Editing registered cats.
- Pet analysis or tracking tools.
- Broader UI and integration test coverage.
- Additional accessibility improvements.
- Configuration and credential management through untracked files or environment variables.
