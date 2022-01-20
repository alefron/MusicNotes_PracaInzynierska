from typing import NamedTuple
from pathlib import Path

import torch
from torch import Tensor
from torch import nn
from torch.utils.data import DataLoader


TrainingParams = NamedTuple('TrainingParams', [
    ('learning_rate', float),
    ('n_epochs', int),
    ('train_batches_per_validation', int),
    ('path_to_model_weights', Path)
])


class Trainer:
    def __init__(
            self,
            device: torch.device,
            training_params: TrainingParams
    ):
        self.tp = training_params
        self.device = device

        self.loss_fun = nn.CrossEntropyLoss()
        self.op = None
        self.batch_nr = 0
        self.best_loss = float("inf")

    def train(
            self,
            model: nn.Module,
            train_loader: DataLoader,
            valid_loader: DataLoader
    ):
        self._prepare_optimizer(model)
        self.batch_nr = 0
        print("number of epochs: ")
        print(self.tp.n_epochs)
        print(range(self.tp.n_epochs))
        is_end = False
        for epoch_nr in range(self.tp.n_epochs):
            print("EPOCH NUMBER")
            print(epoch_nr)
            for img_batch, lbl_batch in train_loader:
                self._train_one_batch(model, img_batch, lbl_batch)
                self.batch_nr += 1
                if self.batch_nr % self.tp.train_batches_per_validation == 0:
                    is_end = self._validate(model, valid_loader)
                    if is_end:
                        break
            if is_end:
                print("koniec treningu - early stopping")
                break

    def _prepare_optimizer(self, model):
        self.op = torch.optim.SGD(
            params=model.parameters(),
            lr=self.tp.learning_rate,
            momentum=0.9
        )

    def _train_one_batch(
            self,
            model: nn.Module,
            img_batch: Tensor,
            lbl_batch: Tensor
    ):
        model.train()
        img_batch = img_batch.to(self.device)
        lbl_batch = lbl_batch.to(self.device)
        logits = model(img_batch)
        loss = self.loss_fun(logits, lbl_batch)
        self.op.zero_grad()
        loss.backward() 
        self.op.step()

        self._post_train_batch({
            'loss': loss.item(),
            'acc': Trainer._calc_guessed_count(logits, lbl_batch) / len(lbl_batch),
            'img_sample': (img_batch[0], lbl_batch[0].item())
        })

    def _validate(
            self,
            model: nn.Module,
            valid_loader: DataLoader,
    ) -> bool:
        is_end = False
        model.eval()
        loss_sum = 0.0
        guessed_sum = 0
        img_batch = None
        lbl_batch = None
        with torch.no_grad():
            for img_batch, lbl_batch in valid_loader:
                img_batch = img_batch.to(self.device)
                lbl_batch = lbl_batch.to(self.device)
                logits = model(img_batch)
                loss = self.loss_fun(logits, lbl_batch)
                loss_sum += loss.item() * len(img_batch)
                guessed_sum += Trainer._calc_guessed_count(logits, lbl_batch)

        is_end = self._post_validation({
            'loss': loss_sum / len(valid_loader.dataset),
            'acc': guessed_sum / len(valid_loader.dataset),
            'img_sample': (img_batch[0], lbl_batch[0].item()),
            'state_dict': model.state_dict()
        })
        return is_end

    @staticmethod
    def _calc_guessed_count(logits, lbl_batch):
        guesses = torch.argmax(logits, dim=1)
        return torch.sum(guesses == lbl_batch).item()

    def _post_train_batch(self, d: dict):
        print("Training [{}]: loss={:.4f}, acc={:.1%}".format(
            self.batch_nr, d['loss'], d['acc']))

    def _post_validation(self, d: dict) -> bool:
        print("Validation [{}]: loss={:.4f}, acc={:.1%}".format(
            self.batch_nr, d['loss'], d['acc']))
        if d['loss'] < self.best_loss:
            self.best_loss = d['loss']
            print("Best loss so far.")
            torch.save(d['state_dict'], str(self.tp.path_to_model_weights))
            return False
        else:
            print("Didn't beat the best loss ({:.4f})".format(self.best_loss))
            return True
            
