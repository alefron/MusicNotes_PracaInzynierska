import os
import glob
import argparse
import random
from pathlib import Path


def shuffle(images) -> []:

    return shuffled_images


def main(args):
    if os.path.exists(args.directory_path):
        new_idx = 1
        images = glob.glob(os.path.join(args.directory_path, "*.jpg"))
        while not len(images) == 0:
            idx = random.randint(0, len(images) - 1)
            img = images[idx]
            old_path = Path(img)
            new_name = os.path.join(old_path.parent.absolute(), str(new_idx) + "_" + os.path.basename(old_path))
            os.rename(old_path, new_name)
            images.remove(img)
            new_idx = new_idx + 1




if __name__ == "__main__":
    parser = argparse.ArgumentParser(argument_default=argparse.SUPPRESS)
    parser.add_argument(
        "--directory_path", nargs='?', type=str, required=True,
        help="directory containing images to be shuffled."
    )
    main(parser.parse_args())
