# DC BIT Image Classification

The repository contains a template project for image recognition.

## Usage
To start training we must provide at least path to model's pretrained weights,
target path to newly fitted model's weights and path to the data directory (images).
An example command would look like this:

```
python dc_bit/run_training.py \
    --path_to_pretrained /mnt/ml-team/homes/grzegorz.los/models/pretrained/resnet18-5c106cde.pth \
    --path_to_model_weights /mnt/ml-team/homes/grzegorz.los/workdir/resnet18_dogs.pth \
    --path_to_data /mnt/ml-team/homes/grzegorz.los/datasets/dogs/
```
It is possible to specify quite a few other script parameters, run `python dc_bit/run_training.py --help` for details.
