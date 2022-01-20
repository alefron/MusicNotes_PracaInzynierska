from typing import Callable, NamedTuple
from pathlib import Path
from PIL.Image import Image

import torchvision
from torch import Tensor
from torch.utils.data import DataLoader


ImgTransform = Callable[[Image], Image]

LoaderParams = NamedTuple('LoaderParams', [
    ('path_to_data', Path),
    ('batch_size', int),
    ('n_workers', int),
    ('shuffle', bool),
    ('augment', bool)
])

for_pytorch = torchvision.transforms.Compose([
    torchvision.transforms.Resize((224, 224)),
    torchvision.transforms.ToTensor(),
    torchvision.transforms.Normalize(  # https://pytorch.org/docs/stable/torchvision/models.html
        mean=[0.485, 0.456, 0.406],
        std=[0.229, 0.224, 0.225]
    )
])


def denormalize(tensor: Tensor) -> Tensor:
    tensor = tensor * Tensor([0.229, 0.224, 0.225])[:, None, None]
    tensor = tensor + Tensor([0.485, 0.456, 0.406])[:, None, None]
    return tensor


to_pil_image = torchvision.transforms.ToPILImage()


def from_pytorch(img: Tensor) -> Image:
    img = img.cpu()
    return to_pil_image(denormalize(img))


def _build_augmentations() -> ImgTransform:
    print("_build_augmentations")
    return torchvision.transforms.Compose([
        torchvision.transforms.RandomRotation(30),
        torchvision.transforms.Resize((256, 256)),
        torchvision.transforms.RandomCrop((224, 224)),
        torchvision.transforms.RandomChoice([
            torchvision.transforms.ColorJitter(brightness=0.5),
            torchvision.transforms.ColorJitter(contrast=0.5),
            torchvision.transforms.ColorJitter(saturation=0.5),
            torchvision.transforms.ColorJitter(hue=0.5),
        ])
    ])


def create_data_loader(params: LoaderParams) -> DataLoader:
    transform = for_pytorch

    if params.augment:
        transform = torchvision.transforms.Compose([
            _build_augmentations(),
            transform
        ])

    ds = torchvision.datasets.ImageFolder(
        root=str(params.path_to_data),
        transform=transform
    )
    dl = DataLoader(
        ds,
        batch_size=params.batch_size,
        shuffle=params.shuffle,
        num_workers=params.n_workers
    )
    return dl
