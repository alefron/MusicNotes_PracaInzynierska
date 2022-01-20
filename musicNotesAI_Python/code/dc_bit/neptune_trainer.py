from typing import Dict
from PIL import Image

import torch

from deepsense import neptune


from trainer import Trainer, TrainingParams
from data_loader import from_pytorch


class NeptuneTrainer(Trainer):
    """Extension of Trainer that sends additional data to Neptune."""

    def __init__(self,
                 device: torch.device,
                 training_params: TrainingParams,
                 ctx: neptune.Context,
                 code_to_label: Dict[int, str]):
        super().__init__(
            device=device,
            training_params=training_params
        )
        self.ctx = ctx
        self.code_to_label = code_to_label

    def _post_train_batch(self, d: dict):
        super()._post_train_batch(d)
        self.ctx.channel_send("[train] loss", self.batch_nr, d['loss'])
        self.ctx.channel_send("[train] acc", self.batch_nr, d['acc'])

        img, code = d['img_sample']
        self._send_image(
            'batch_sample',
            from_pytorch(img),
            self.code_to_label[code]
        )

    def _post_validation(self, d: dict):
        super()._post_validation(d)
        self.ctx.channel_send("[valid] loss", self.batch_nr, d['loss'])
        self.ctx.channel_send("[valid] acc", self.batch_nr, d['acc'])

    def _send_image(self, channel_name: str, img: Image, label: str):
        img = img.resize((100, 100))
        neptune_img = neptune.Image(
            name=channel_name,
            description='Label: {}'.format(label),
            data=img
        )
        self.ctx.channel_send(channel_name, neptune_img)
