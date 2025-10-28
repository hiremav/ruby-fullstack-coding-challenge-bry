# frozen_string_literal: true

class SpectreOpenaiJob
  include Sidekiq::Job

  def perform(prompt)
    messages = [
      { role: "system", content: "You are a concise assistant." },
      { role: "user",   content: prompt }
    ]

    result = Spectre.provider_module::Completions.create(
      messages: messages,
      model: "gpt-4",
      openai: { max_tokens: 60 }
    )

    Turbo::StreamsChannel.broadcast_append_to(
      "chat",
      target:  "messages",
      partial: "chats/chat",
      locals:  { user_prompt: result[:content] }
    )
  end
end
