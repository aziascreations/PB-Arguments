from abc import ABC
import os
import sys


class PureBasicBlock:
    text: list[str]
    
    def __init__(self):
        self.text = list()
    
    def add_text(self, text):
        self.text.append(text)


class PureBasicProcedure(PureBasicBlock):
    PROCEDURE_DEFAULT = 0b0000_0001
    PROCEDURE_C = 0b0000_0010
    PROCEDURE_DLL = 0b0000_0100
    PROCEDURE_CDLL = PROCEDURE_C | PROCEDURE_DLL
    
    procedure_type: int
    
    def __init__(self, procedure_type: int):
        super().__init__()
        self.procedure_type = procedure_type


class DocumentationToken:
    token_type: PureBasicCodeBlock
    raw_content: str
    
    def __init__(self, token_type: PureBasicCodeBlock, raw_content: str):
        self.token_type = token_type
        self.raw_content = raw_content


def main(filename) -> int:
    if not (os.path.exists(filename) and os.path.isfile(filename)):
        print("File does not exist or is a directory !")
        return 2

    with open(filename) as f:
        lines = f.readlines()
    lines = [x.strip() for x in lines]
    
    tokens: list[PureBasicCodeBlock] = list()
    for line in lines:
        print(line)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        exit(main(sys.argv[1]))
    else:
        print("No input file !")
        exit(1)
