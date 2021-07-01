import json
import os

DEFAULT_CONFIG_FILE_PATH = os.path.join(os.path.dirname(os.path.realpath(__file__)), "config_base.json")


class TokenizerConfig:
    ignore_modules: bool
    
    def __init__(self, ignore_modules: bool, **trash):
        self.ignore_modules = ignore_modules


class DocumenterConfig:
    single_out_module: bool
    print_module_namespace: bool
    reference_module_in_header: bool
    
    def __init__(self, single_out_module: bool, print_module_namespace: bool, reference_module_in_header: bool, **trash):
        self.single_out_module = single_out_module
        self.print_module_namespace = print_module_namespace
        self.reference_module_in_header = reference_module_in_header


class IndexerConfig:
    title: str
    version: str
    authors: str
    
    def __init__(self, title: str, version: str, authors: str, **trash):
        self.title = title
        self.version = version
        self.authors = authors


class FormatterConfig:
    colors: dict
    add_home_to_footer_links: bool
    footer_links: list
    
    default_color: str = "#FF7F00"
    
    def __init__(self, colors: dict, add_home_to_footer_links: bool, footer_links: list, **trash):
        self.colors = colors
        self.add_home_to_footer_links = add_home_to_footer_links
        self.footer_links = footer_links


def load_config_files(custom_config_path: str) -> tuple[TokenizerConfig, DocumenterConfig, IndexerConfig, FormatterConfig]:
    # Checking the custom config file
    if custom_config_path is not None:
        if not (os.path.exists(custom_config_path) and os.path.isfile(custom_config_path)):
            raise IOError("The file '{}' does not exist or is a folder !".format(custom_config_path))
    
    # Checking the default config file
    if not (os.path.exists(DEFAULT_CONFIG_FILE_PATH) and os.path.isfile(DEFAULT_CONFIG_FILE_PATH)):
        raise IOError("The file '{}' does not exist or is a folder !".format(DEFAULT_CONFIG_FILE_PATH))
    
    config_file = open(DEFAULT_CONFIG_FILE_PATH)
    default_config_json = json.load(config_file)
    config_file.close()
    
    if custom_config_path is not None:
        config_file = open(custom_config_path)
        custom_config_json = json.load(config_file)
        config_file.close()
    else:
        custom_config_json = {}
    
    merged_tokenizer_config = dict()
    merged_tokenizer_config.update(default_config_json["tokeniser"])
    if "tokeniser" in custom_config_json:
        merged_tokenizer_config.update(custom_config_json["tokeniser"])
    
    merged_documenter_config = dict()
    merged_documenter_config.update(default_config_json["documenter"])
    if "documenter" in custom_config_json:
        merged_documenter_config.update(custom_config_json["documenter"])
    
    merged_indexer_config = dict()
    merged_indexer_config.update(default_config_json["indexer"])
    if "indexer" in custom_config_json:
        merged_indexer_config.update(custom_config_json["indexer"])
    
    merged_formatter_config = dict()
    merged_formatter_config.update(default_config_json["formatter"])
    if "formatter" in custom_config_json:
        merged_formatter_config.update(custom_config_json["formatter"])
    
    final_tokenizer_config = TokenizerConfig(**merged_tokenizer_config)
    final_documenter_config = DocumenterConfig(**merged_documenter_config)
    final_indexer_config = IndexerConfig(**merged_indexer_config)
    final_formatter_config = FormatterConfig(**merged_formatter_config)
    
    return final_tokenizer_config, final_documenter_config, final_indexer_config, final_formatter_config
