# FiftyOne Model Zoo [¶](\#fiftyone-model-zoo "Permalink to this headline")

The FiftyOne Model Zoo provides a powerful interface for downloading models
and applying them to your FiftyOne datasets.

It provides native access to hundreds of pre-trained models, and it also
supports downloading arbitrary public or private models whose definitions are
provided via GitHub repositories or URLs.

Note

Zoo models may require additional packages such as PyTorch or TensorFlow
(or specific versions of them) in order to be used. See
[this section](api.md#model-zoo-requirements) for more information on
viewing/installing package requirements for models.

If you try to load a zoo model without the proper packages installed, you
will receive an error message that will explain what you need to install.

Depending on your compute environment, some package requirement failures
may be erroneous. In such cases, you can
[suppress error messages](api.md#model-zoo-load).

## Built-in models [¶](\#built-in-models "Permalink to this headline")

The Model Zoo provides built-in access to hundreds of pre-trained models that
you can apply to your datasets with a few simple commands.

[Explore the models in the zoo](models.md)

Note

Did you know? You can also pass
[custom models](design.md#model-zoo-custom-models) to methods like
[`apply_model()`](../../api/fiftyone.core.collections.html#apply_model "fiftyone.core.collections.SampleCollection.apply_model")
and [`compute_embeddings()`](../../api/fiftyone.core.collections.html#compute_embeddings "fiftyone.core.collections.SampleCollection.compute_embeddings")!

## Remotely-sourced models [¶](\#remotely-sourced-models "Permalink to this headline")

The Model Zoo also supports downloading and applying models whose definitions
are provided via GitHub repositories or URLs.

[Learn how to download remote models](remote.md)

## Model interface [¶](\#model-interface "Permalink to this headline")

All models in the Model Zoo are exposed via the [`Model`](../../api/fiftyone.core.models.html#fiftyone.core.models.Model "fiftyone.core.models.Model") class, which defines a
common interface for loading models and generating predictions with
defined input and output data formats.

[Grok the Model interface](design.md)

## API reference [¶](\#api-reference "Permalink to this headline")

The Model Zoo can be accessed via the Python library and the CLI. Consult the
API reference below to see how to download, apply, and manage zoo models.

[Check out the API reference](api.md)

## Basic recipe [¶](\#basic-recipe "Permalink to this headline")

Methods for working with the Model Zoo are conveniently exposed via the Python
library and the CLI. The basic recipe is that you load a model from the zoo and
then apply it to a dataset (or a subset of the dataset specified by a
[`DatasetView`](../../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView")) using methods such as
[`apply_model()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.apply_model "fiftyone.core.collections.SampleCollection.apply_model")
and
[`compute_embeddings()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.compute_embeddings "fiftyone.core.collections.SampleCollection.compute_embeddings").

### Prediction [¶](\#prediction "Permalink to this headline")

The Model Zoo provides a number of convenient methods for generating
predictions with zoo models for your datasets.

For example, the code sample below shows a self-contained example of loading a
Faster R-CNN model from the model zoo and adding its predictions to the
COCO-2017 dataset from the [Dataset Zoo](../../data/dataset_zoo/index.md#dataset-zoo):

```python
import fiftyone as fo
import fiftyone.zoo as foz

# List available zoo models
print(foz.list_zoo_models())

# Download and load a model
model = foz.load_zoo_model("faster-rcnn-resnet50-fpn-coco-torch")

# Load some samples from the COCO-2017 validation split
dataset = foz.load_zoo_dataset(
    "coco-2017",
    split="validation",
    dataset_name="coco-2017-validation-sample",
    max_samples=50,
    shuffle=True,
)

#
# Choose some samples to process. This can be the entire dataset, or a
# subset of the dataset. In this case, we'll choose some samples at
# random
#
samples = dataset.take(25)

#
# Generate predictions for each sample and store the results in the
# `faster_rcnn` field of the dataset, discarding all predictions with
# confidence below 0.5
#
samples.apply_model(model, label_field="faster_rcnn", confidence_thresh=0.5)
print(samples)

# Visualize predictions in the App
session = fo.launch_app(view=samples)

```

### Embeddings [¶](\#embeddings "Permalink to this headline")

Many models in the Model Zoo expose embeddings for their predictions:

```python
import fiftyone.zoo as foz

# Load zoo model
model = foz.load_zoo_model("inception-v3-imagenet-torch")

# Check if model exposes embeddings
print(model.has_embeddings)  # True

```

For models that expose embeddings, you can generate embeddings for all
samples in a dataset (or a subset of it specified by a [`DatasetView`](../../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView")) by
calling
[`compute_embeddings()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.compute_embeddings "fiftyone.core.collections.SampleCollection.compute_embeddings"):

```python
import fiftyone.zoo as foz

# Load zoo model
model = foz.load_zoo_model("inception-v3-imagenet-torch")
print(model.has_embeddings)  # True

# Load zoo dataset
dataset = foz.load_zoo_dataset("imagenet-sample")

# Select some samples to process
samples = dataset.take(10)

#
# Option 1: Generate embeddings for each sample and return them in a
# `num_samples x dim` array
#
embeddings = samples.compute_embeddings(model)

#
# Option 2: Generate embeddings for each sample and store them in an
# `embeddings` field of the dataset
#
samples.compute_embeddings(model, embeddings_field="embeddings")

```

You can also use
[`compute_patch_embeddings()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.compute_patch_embeddings "fiftyone.core.collections.SampleCollection.compute_patch_embeddings")
to generate embeddings for image patches defined by another label field, e.g,.
the detections generated by a detection model.

### Logits [¶](\#logits "Permalink to this headline")

Many classifiers in the Model Zoo can optionally store logits for their
predictions.

Note

Storing logits for predictions enables you to run Brain methods such as
[label mistakes](../../fiftyone_concepts/brain.md#brain-label-mistakes) and
[sample hardness](../../fiftyone_concepts/brain.md#brain-sample-hardness) on your datasets!

You can check if a model exposes logits via
[`has_logits()`](../../api/fiftyone.core.models.html#fiftyone.core.models.Model.has_logits "fiftyone.core.models.Model.has_logits"):

```python
import fiftyone.zoo as foz

# Load zoo model
model = foz.load_zoo_mod[index.md](index.md)el("inception-v3-imagenet-torch")

# Check if model has logits
print(model.has_logits)  # True

```

For models that expose logits, you can store logits for all predictions
generated by
[`apply_model()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.apply_model "fiftyone.core.collections.SampleCollection.apply_model")
by passing the optional `store_logits=True` argument:

```python
import fiftyone.zoo as foz

# Load zoo model
model = foz.load_zoo_model("inception-v3-imagenet-torch")
print(model.has_logits)  # True

# Load zoo dataset
dataset = foz.load_zoo_dataset("imagenet-sample")

# Select some samples to process
samples = dataset.take(10)

# Generate predictions and populate their `logits` fields
samples.apply_model(model, store_logits=True)

```
