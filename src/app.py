import chainlit as cl
from anthropic import Anthropic
from chainlit.input_widget import Select
from dotenv import load_dotenv

load_dotenv()
client = Anthropic()
MAX_TOKENS = 1000

# todo: add auth callback
@cl.password_auth_callback  # type: ignore
def auth_callback(username: str, password: str):
    # Fetch the user matching username from your database
    # and compare the hashed password with the value stored in the database
    if (username, password) == ("admin", "admin"):
        return cl.User(
            identifier="admin", metadata={"role": "admin", "provider": "credentials"}
        )
    else:
        return None


@cl.on_chat_resume
async def on_chat_resume(thread):
    pass


@cl.on_chat_start
async def on_chat_start():
    # * initialise settings
    settings = await cl.ChatSettings(
        [
            Select(
                id="claude-model",
                label="Model",
                values=[
                    "claude-sonnet-4-20250514",
                    "claude-opus-4-20250514",
                ],
                initial_index=0,
            ),
        ]
    ).send()

    cl.user_session.set("settings", settings)

    # * initialise message history
    cl.user_session.set(
        "message_history",
        [],
    )
    await cl.Message(
        """
        
        Hello! 😄
        
        """
    ).send()


@cl.on_settings_update
async def on_settings_update(settings):
    cl.user_session.set("settings", settings)



@cl.on_message
async def main(message: cl.Message):
    settings = cl.user_session.get("settings", {})

    message_history: list = cl.user_session.get("message_history", [])  # type: ignore

    message_history.append({"role": "user", "content": message.content})

    msg = cl.Message(content="")
    output_text = ""
    with client.messages.stream(
        messages=message_history,  # type: ignore
        max_tokens=MAX_TOKENS,
        model=settings["claude-model"],  # type: ignore
    ) as stream:
        for event in stream:
            if event.type == "content_block_delta":
                if event.delta.type == "text_delta":
                    output_text += event.delta.text
                    await msg.stream_token(event.delta.text)


    message_history.append({"role": "assistant", "content": msg.content})
    await msg.update()

if __name__ == "__main__":
    from chainlit.cli import run_chainlit
    run_chainlit(__file__)