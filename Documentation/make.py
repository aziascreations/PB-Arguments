#!/usr/bin/python

import json
import os

from pb_documenter import tokenizer, indexer, formatter
# documenter
from pb_documenter.tokens import Token, IndexToken
import pb_documenter.config as pb_config

CUSTOM_CONFIG_FILE_PATH = os.path.join(os.path.dirname(os.path.realpath(__file__)), "config_project.json")
FILE_DATA_PATH = os.path.join(os.path.dirname(os.path.realpath(__file__)), "files.json")


def main():
    # Reading config_project.json
    (token_config, documenter_config, indexer_config, formatter_config) = \
        pb_config.load_config_files(CUSTOM_CONFIG_FILE_PATH)

    # Reading files.json
    input_file_data: list[list[str, str, str]]
    input_file_data_file = open(FILE_DATA_PATH)
    input_file_data = json.load(input_file_data_file)
    input_file_data_file.close()

    # Tokenizing
    root_token_list: list[Token] = list()
    for file_data in input_file_data:
        if file_data[1] != "":
            root_token_list.append(tokenizer.tokenize(config=token_config, pb_file=os.path.abspath(file_data[1])))
        else:
            root_token_list.append(IndexToken())
    
    pass


if __name__ == "__main__":
    main()
    os.system("pause")
