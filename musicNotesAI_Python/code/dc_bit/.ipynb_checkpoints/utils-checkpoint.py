from typing import Dict
from pathlib import Path
from PIL import Image
from ast import literal_eval
import numpy as np
import sys

import torch
from torch.utils.data import DataLoader
import torchvision

#sys.path.append("..")
from data_loader import for_pytorch


def get_model(
        path_to_weights: Path,
        device: torch.device,
        n_classes: int,
        load_head: bool
):
    model = torchvision.models.resnet18(pretrained=False)

    if not load_head:
        model.load_state_dict(torch.load(str(path_to_weights)))

    # for n, m in resnet18.named_modules():
    #     if type(m) == torch.nn.modules.batchnorm.BatchNorm2d:
    #         m.momentum = 0.1
    model.fc = torch.nn.Sequential(
        torch.nn.Dropout(0.5),
        torch.nn.Linear(512, n_classes)
    )

    if load_head:
        model.load_state_dict(torch.load(str(path_to_weights)))

    return model.to(device)


def get_predictions(model: torch.nn.Module, img: Image, device: torch.device) -> np.ndarray:
    img_tensor = for_pytorch(img)
    img_tensor = img_tensor.to(device)
    img_tensor = img_tensor.unsqueeze(0)
    output = model(img_tensor)
    preds = torch.nn.Softmax(dim=1)(output)
    return preds.cpu().numpy().squeeze()


def read_label_encoding(path_to_label_encoding: Path) -> Dict[int, str]:
    with open(str(path_to_label_encoding)) as file:
        return literal_eval(file.read())


def create_label_encoding(data_loader: DataLoader) -> Dict[int, str]:
    return {i: lbl for i, lbl in enumerate(data_loader.dataset.classes)}


def choose_device() -> torch.device:
    return torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
