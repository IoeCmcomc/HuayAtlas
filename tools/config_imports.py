import os
import os.path as os_path

from os import walk, listdir, remove
from pprint import pprint
from json import dump
from re import compile

os.chdir('../project/resources/map_tiles')

SOURCE_EXT_REGEX = compile(r'source_file=".+(\.\w+)')

COMPRESS_MODE_REGEX = compile(r"compress/mode=.")

def config_imports():

    for root, dirs, files in walk('.'):
        for file in files:
            path = os_path.join(root, file)
            if file.endswith('.import'):
                file_text = None
                with open(path, 'r') as f:
                    file_text = f.read()
                
                source_ext = SOURCE_EXT_REGEX.search(file_text).group(1)
                
                if source_ext == '.jpg':
                    file_text = COMPRESS_MODE_REGEX.sub("compress/mode=1", file_text)
                
                with open(path, 'w') as f:
                    f.write(file_text)

if __name__ == '__main__':
    config_imports()