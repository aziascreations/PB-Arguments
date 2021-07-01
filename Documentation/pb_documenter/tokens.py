from abc import ABC


class Token(ABC):
    pass


class IndexToken(Token, ABC):
    pass


class PureBasicToken(Token, ABC):
    sub_tokens: list[Token]


class PureBasicTextToken(PureBasicToken):
    text: str
    
    def __init__(self, text=None):
        self.text = text


class PureBasicAttributeToken(PureBasicTextToken):
    name: str
    
    def __init__(self, name, text=None):
        super().__init__(text)
        self.name = name


