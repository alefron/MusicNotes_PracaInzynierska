from typing import Dict
import argparse
from pathlib import Path


from utils import get_model
from data_loader import create_data_loader, LoaderParams
from trainer import Trainer, TrainingParams

import torch


def get_args():
    parser = argparse.ArgumentParser()

    # Model related arguments

    parser.add_argument(
        '--path_to_pretrained',
        required=True,
        type=str,
        help='path to weights of a pretrained model'
    )

    # Data loader parameters

    parser.add_argument(
        '--path_to_data',
        required=True,
        help='path to the data directory'
    )

    parser.add_argument(
        '--augment',
        required=False,
        action='store_true',
        help='whether to augment training images'
    )

    parser.add_argument(
        '--batch_size',
        required=False,
        default=50,
        type=int,
        help="number of images in one data batch"
    )

    parser.add_argument(
        '--train_workers',
        required=False,
        default=4,
        type=int,
        help="number of processes spawned by the training data loader"
    )

    parser.add_argument(
        '--valid_workers',
        required=False,
        default=4,
        type=int,
        help="number of processes spawned by the validation data loader"
    )

    # Training parameters

    parser.add_argument(
        '--learning_rate',
        required=False,
        default=0.001,
        type=float,
        help="learning rate for stochastic gradient descent"
    )

    parser.add_argument(
        '--n_epochs',
        required=False,
        default=100,
        type=int,
        help="how many times to iterate over the data"
    )

    parser.add_argument(
        '--train_batches_per_validation',
        required=False,
        default=10,
        type=int,
        help="number of training batches before each validation step"
    )

    # Other arguments

    parser.add_argument(
        '--path_to_model_weights',
        required=True,
        help='path to the trained model'
    )

    parser.add_argument(
        '--neptune',
        required=False,
        action='store_true',
        help="whether to use Netpune"
    )

    return parser.parse_args()


def extract_train_loader_params(args: argparse.Namespace) -> LoaderParams:
    return LoaderParams(
        path_to_data=Path(args.path_to_data) / 'train',
        batch_size=args.batch_size,
        n_workers=args.train_workers,
        shuffle=True,
        augment=args.augment
    )


def extract_valid_loader_params(args: argparse.Namespace) -> LoaderParams:
    return LoaderParams(
        path_to_data=Path(args.path_to_data) / 'valid',
        batch_size=args.batch_size,
        n_workers=args.valid_workers,
        shuffle=False,
        augment=False
    )


def extract_training_params(args: argparse.Namespace) -> TrainingParams:
    return TrainingParams(
        learning_rate=args.learning_rate,
        n_epochs=args.n_epochs,
        train_batches_per_validation=args.train_batches_per_validation,
        path_to_model_weights=Path(args.path_to_model_weights)
    )


def create_trainer(args: argparse.Namespace, device: torch.device, code_to_label: Dict[int, str]) -> Trainer:
    if args.neptune:
        from deepsense import neptune
        from dc_bit.neptune_trainer import NeptuneTrainer
        return NeptuneTrainer(
            device=device,
            training_params=extract_training_params(args),
            ctx=neptune.Context(),
            code_to_label=code_to_label,
        )
    else:
        return Trainer(
            device=device,
            training_params=extract_training_params(args)
        )


def save_classes(args, code_to_label: Dict[int, str]):
    path_to_model_weights = Path(args.path_to_model_weights)
    path_to_model_weights.parent.mkdir(exist_ok=True, parents=True)
    path_to_classes = path_to_model_weights.parent / 'classes.txt'
    with open(str(path_to_classes), 'w') as file:
        file.write(repr(code_to_label))


def main():
    args = get_args()
    device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")

    dl_train = create_data_loader(extract_train_loader_params(args))
    dl_valid = create_data_loader(extract_valid_loader_params(args))
    
    images, labels = next(iter(dl_valid))
    print("")
    print(len(images))
    if len(images) > 0:
        print(images[0].shape)

    model = get_model(
        path_to_weights=Path(args.path_to_pretrained),
        device=device,
        n_classes=len(dl_train.dataset.classes),
        load_head=False
    )

    code_to_label = {i: lbl for i, lbl in enumerate(dl_train.dataset.classes)}
    save_classes(args, code_to_label)

    trainer = create_trainer(args, device, code_to_label)
    
   
    
    
    #trainer.train(
     #   model=model,
     #   train_loader=dl_train,
     #   valid_loader=dl_valid
    #)
    
    


if __name__ == "__main__":
    main()
