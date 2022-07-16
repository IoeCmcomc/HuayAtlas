import os
import os.path as os_path
import matplotlib.pyplot as plt
import numpy as np

from os import walk, listdir, remove
from pprint import pprint
from json import dump

os.chdir('../project/resources/map_tiles')

delete_import_files = input("Delete .import files: ")

def image_has_only_one_color(arr, color):
    return np.all(arr[:, :, 0] == color[0]) and np.all(arr[:, :, 1] == color[1]) \
            and np.all(arr[:, :, 2] == color[2])

def clean_up(base_path):
    tile_id_dict = {}
    preloaded_tiles = []
    tile_refs = {}
    tile_row_count = len(listdir(os_path.join(base_path, listdir(base_path)[0])))

    for root, dirs, files in walk(base_path):
        for file in files:
            path = os_path.join(root, file)
            if file.endswith('.png'):
                pic = plt.imread(path)
                try:
                    if (len(pic.shape) == 2) or (pic[:, :, 3] == 0).all():
                        print("Removing transparent image:", path)
                        remove(path)
                        pass
                    else:
                        first_pixel = pic[0, 0]
                        if image_has_only_one_color(pic, first_pixel):
                            key = first_pixel.tobytes()
                            tile_x = int(os_path.normpath(root).split(os_path.sep)[-1])
                            tile_y = int(file.split('.')[0])
                            tile_id = int(os_path.normpath(root).split(os_path.sep)[-1]) * tile_row_count + int(file.split('.')[0])
                            if not key in tile_id_dict:
                                tile_id_dict[key] = (tile_id, path)
                                preloaded_tiles.append([tile_x, tile_y])
                            else:
                                tile_refs[tile_id] = tile_id_dict[key][0]
                                print("Removing duplicated image:", path)
                                remove(path)
                except IndexError:
                    continue # Source image is already optimized
            elif file.endswith('.import') and delete_import_files:
                remove(path)

    if preloaded_tiles:
        with open(f'{base_path}/tile_refs.json', 'w', encoding='utf-8') as f:
            dump({'tiles': preloaded_tiles, 'refs': tile_refs}, f)
    pprint(tile_id_dict)

if __name__ == '__main__':
    clean_up("transportation/6")
    clean_up("transportation/7")
    clean_up("transportation/8")
    clean_up("transportation/9")
    clean_up("transportation/10")
    