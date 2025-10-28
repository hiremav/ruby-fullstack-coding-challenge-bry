# Overview

Web chat interface to chatGPT

# System Design

## Chat Interface System Sequence Diagram
![Chat Architecture Diagram](./doc/chat-interface-ssdiagram.svg)

```mermaid
sequenceDiagram
    participant F as 🧑‍💻 Frontend (Turbo)
    participant C as 🎯 ChatController (Rails)
    participant W as ⚙️ Sidekiq Worker
    participant O as 🤖 OpenAI (Spectre)
    participant D as 🗄️ Database (Chat Table)
    participant T as 📡 Turbo Stream Channel

    %% 1. Controller creates or updates session chat record
    F->>C: 1️⃣ Send message via POST
    C->>D: Create or update chat session record

    %% 2. Controller sends message to worker
    C->>W: Enqueue job with message payload

    %% 3. Worker sends message to OpenAI
    W->>O: Send user message via Spectre API

    %% 4. OpenAI responds
    O-->>W: Return generated AI response

    %% 5. Worker saves message to DB
    W->>D: Save AI response message record

    %% 6. Worker broadcasts to Turbo Stream
    W->>T: Broadcast Turbo Stream update
    T-->>F: Realtime update (new AI message displayed)
```

## Design Decisions

### Decision: Session Handling Strategy

A unique SecureRandom.uuid will be generated per-browser session.

The SecureRandom.uuid will be stored in session[conversation_id].

Effectively, each chat will be tied to a per-browser session[conversation_id].


# Integration & External Services

The chat interface uses Ruby Spectre gem to interface with the OpenAI foundation model.

# Future Work

- Add Roadauth user authentication and user table, tie chats to user
- Add chat session tab feature with new data table modeling (chat, questions, responses)
- Add Tailwind for nice UI layout