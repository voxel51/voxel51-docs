# Model Interface [¶](\#model-interface "Permalink to this headline")

All models in the Model Zoo are exposed via the [`Model`](../../api/fiftyone.core.models.html#fiftyone.core.models.Model "fiftyone.core.models.Model") class, which defines a
common interface for loading models and generating predictions with defined
input and output data formats.

Note

If you write a wrapper for your custom model that implements the [`Model`](../../api/fiftyone.core.models.html#fiftyone.core.models.Model "fiftyone.core.models.Model")
interface, then you can pass your models to built-in methods like
[`apply_model()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.apply_model "fiftyone.core.collections.SampleCollection.apply_model")
and
[`compute_embeddings()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.compute_embeddings "fiftyone.core.collections.SampleCollection.compute_embeddings")
too!

FiftyOne provides classes that make it easy to deploy models in custom
frameworks easy. For example, if you have a PyTorch model that processes
images, you can likely use
`TorchImageModel` to run it
using FiftyOne.

## Prediction [¶](\#prediction "Permalink to this headline")

Inside built-in methods like
[`apply_model()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.apply_model "fiftyone.core.collections.SampleCollection.apply_model"),
predictions of a [`Model`](../../api/fiftyone.core.models.html#fiftyone.core.models.Model "fiftyone.core.models.Model") instance are generated using the following pattern:

By convention, [`Model`](../../api/fiftyone.core.models.html#fiftyone.core.models.Model "fiftyone.core.models.Model") instances must implement the context manager interface,
which handles any necessary setup and teardown required to use the model.

Predictions are generated via the
[`Model.predict()`](../../api/fiftyone.core.models.html#fiftyone.core.models.Model "fiftyone.core.models.Model") interface method, which
takes an image/video as input and returns the predictions.

In order to be compatible with built-in methods like
[`apply_model()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.apply_model "fiftyone.core.collections.SampleCollection.apply_model"),
models should support the following basic signature of running inference and
storing the output labels:

```python
labels = model.predict(arg)
sample.add_labels(labels, label_field=label_field)

```

where the model should, at minimum, support `arg` values that are:

- _Image models:_ uint8 numpy arrays (HWC)

- _Video models:_ `eta.core.video.VideoReader` instances


and the output `labels` can be any of the following:

- A [`Label`](../../api/fiftyone.core.labels.html#fiftyone.core.labels.Label "fiftyone.core.labels.Label") instance, in which case the labels are directly saved in the
specified `label_field` of the sample


```python
# Single sample-level label
sample[label_field] = labels

```

- A dict mapping keys to [`Label`](../../api/fiftyone.core.labels.html#fiftyone.core.labels.Label "fiftyone.core.labels.Label") instances. In this case, the labels are
added as follows:


```python
# Multiple sample-level labels
for key, value in labels.items():
    sample[label_key(key)] = value

```

- A dict mapping frame numbers to [`Label`](../../api/fiftyone.core.labels.html#fiftyone.core.labels.Label "fiftyone.core.labels.Label") instances. In this case, the
provided labels are interpreted as frame-level labels that should be added
as follows:


```python
# Single set of per-frame labels
sample.frames.merge(
    {
        frame_number: {label_field: label}
        for frame_number, label in labels.items()
    }
)

```

- A dict mapping frame numbers to dicts mapping keys to [`Label`](../../api/fiftyone.core.labels.html#fiftyone.core.labels.Label "fiftyone.core.labels.Label") instances. In
this case, the provided labels are interpreted as frame-level labels that
should be added as follows:


```python
# Multiple per-frame labels
sample.frames.merge(
    {
        frame_number: {label_key(k): v for k, v in frame_dict.items()}
        for frame_number, frame_dict in labels.items()
    }
)

```

In the above snippets, the `label_key` function maps label dict keys to field
names, and is defined from `label_field` as follows:

```python
if isinstance(label_field, dict):
    label_key = lambda k: label_field.get(k, k)
elif label_field is not None:
    label_key = lambda k: label_field + "_" + k
else:
    label_key = lambda k: k

```

For models that support batching, the [`Model`](../../api/fiftyone.core.models.html#fiftyone.core.models.Model "fiftyone.core.models.Model") interface also provides a
[`predict_all()`](../../api/fiftyone.core.models.html#fiftyone.core.models.Model.predict_all "fiftyone.core.models.Model.predict_all") method that can
provide an efficient implementation of predicting on a batch of data.

Note

Built-in methods like
[`apply_model()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.apply_model "fiftyone.core.collections.SampleCollection.apply_model")
provide a `batch_size` parameter that can be used to control the batch
size used when performing inference with models that support efficient
batching.

Note

PyTorch models can implement the [`TorchModelMixin`](../../api/fiftyone.core.models.html#fiftyone.core.models.TorchModelMixin "fiftyone.core.models.TorchModelMixin") mixin, in which case
[DataLoaders](https://pytorch.org/docs/stable/data.html#torch.utils.data.DataLoader)
are used to efficiently feed data to the models during inference.

## Embeddings [¶](\#embeddings "Permalink to this headline")

Models that can compute embeddings for their input data can expose this
capability by implementing the [`EmbeddingsMixin`](../../api/fiftyone.core.models.html#fiftyone.core.models.EmbeddingsMixin "fiftyone.core.models.EmbeddingsMixin") mixin.

Inside built-in methods like
[`compute_embeddings()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.compute_embeddings "fiftyone.core.collections.SampleCollection.compute_embeddings"),
embeddings for a collection of samples are generated using an analogous pattern
to the prediction code shown above, except that the embeddings are generated
using [`Model.embed()`](../../api/fiftyone.core.models.html#fiftyone.core.models.EmbeddingsMixin.embed "fiftyone.core.models.EmbeddingsMixin.embed") in
place of [`Model.predict()`](../../api/fiftyone.core.models.html#fiftyone.core.models.Model.predict "fiftyone.core.models.Model.predict").

By convention,
[`Model.embed()`](../../api/fiftyone.core.models.html#fiftyone.core.models.EmbeddingsMixin.embed "fiftyone.core.models.EmbeddingsMixin.embed") should
return a numpy array containing the embedding.

Note

Embeddings are typically 1D vectors, but this is not strictly required.

For models that support batching, the [`EmbeddingsMixin`](../../api/fiftyone.core.models.html#fiftyone.core.models.EmbeddingsMixin "fiftyone.core.models.EmbeddingsMixin") interface also provides
a [`embed_all()`](../../api/fiftyone.core.models.html#fiftyone.core.models.Model.predict_all "fiftyone.core.models.Model.predict_all") method that can
provide an efficient implementation of embedding a batch of data.

## Logits [¶](\#logits "Permalink to this headline")

Models that generate logits for their predictions can expose them to FiftyOne
by implementing the [`LogitsMixin`](../../api/fiftyone.core.models.html#fiftyone.core.models.LogitsMixin "fiftyone.core.models.LogitsMixin") mixin.

Inside built-in methods like
[`apply_model()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.apply_model "fiftyone.core.collections.SampleCollection.apply_model"),
if the user requests logits, the model’s
[`store_logits`](../../api/fiftyone.core.models.html#fiftyone.core.models.LogitsMixin.store_logits "fiftyone.core.models.LogitsMixin.store_logits")
property is set to indicate that the model should store logits in the [`Label`](../../api/fiftyone.core.labels.html#fiftyone.core.labels.Label "fiftyone.core.labels.Label")
instances that it produces during inference.

## Custom models [¶](\#custom-models "Permalink to this headline")

FiftyOne provides a
`TorchImageModel`
class that you can use to load your own custom Torch model and pass it to
built-in methods like
[`apply_model()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.apply_model "fiftyone.core.collections.SampleCollection.apply_model")
and
[`compute_embeddings()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.compute_embeddings "fiftyone.core.collections.SampleCollection.compute_embeddings").

For example, the snippet below loads a pretrained model from `torchvision`
and uses it both as a classifier and to generate image embeddings:

```python
import os
import eta

import fiftyone as fo
import fiftyone.zoo as foz
import fiftyone.utils.torch as fout

dataset = foz.load_zoo_dataset("quickstart")

labels_path = os.path.join(
    eta.constants.RESOURCES_DIR, "imagenet-labels-no-background.txt"
)
config = fout.TorchImageModelConfig(
    {
        "entrypoint_fcn": "torchvision.models.mobilenet.mobilenet_v2",
        "entrypoint_args": {"weights": "MobileNet_V2_Weights.DEFAULT"},
        "output_processor_cls": "fiftyone.utils.torch.ClassifierOutputProcessor",
        "labels_path": labels_path,
        "image_min_dim": 224,
        "image_max_dim": 2048,
        "image_mean": [0.485, 0.456, 0.406],
        "image_std": [0.229, 0.224, 0.225],
        "embeddings_layer": "<classifier.1",
    }
)
model = fout.TorchImageModel(config)

dataset.apply_model(model, label_field="imagenet")
embeddings = dataset.compute_embeddings(model)

```

The necessary configuration is provided via the
`TorchImageModelConfig`
class, which exposes a number of built-in mechanisms for defining the model to
load and any necessary preprocessing and post-processing.

Under the hood, the torch model is loaded via:

```python
torch_model = entrypoint_fcn(**entrypoint_args)

```

which is assumed to return a [`torch.nn.Module`](https://pytorch.org/docs/stable/generated/torch.nn.Module.html#torch.nn.Module "(in PyTorch v2.5)") whose `__call__()`
method directly accepts Torch tensors (NCHW) as input.

The `TorchImageModelConfig`
class provides a number of built-in mechanisms for specifying the required
preprocessing for your model, such as resizing and normalization. In the above
example, `image_min_dim`, `image_max_dim`, `image_mean`, and `image_std` are
used.

The `output_processor_cls` parameter of
`TorchImageModelConfig`
must be set to the fully-qualified class name of an
`OutputProcessor` subclass that
defines how to translate the model’s raw output into the suitable FiftyOne
[`Label`](../../api/fiftyone.core.labels.html#fiftyone.core.labels.Label "fiftyone.core.labels.Label") types, and is instantiated as follows:

```python
output_processor = output_processor_cls(classes=classes, **output_processor_args)

```

where your model’s classes can be specified via any of the `classes`,
`labels_string`, or `labels_path` parameters of
`TorchImageModelConfig`.

The following built-in output processors are available for use:

- `ClassifierOutputProcessor`

- `DetectorOutputProcessor`

- `InstanceSegmenterOutputProcessor`

- `KeypointDetectorOutputProcessor`

- `SemanticSegmenterOutputProcessor`


or you can write your own
`OutputProcessor` subclass.

Finally, if you would like to pass your custom model to methods like
[`compute_embeddings()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.compute_embeddings "fiftyone.core.collections.SampleCollection.compute_embeddings"),
set the `embeddings_layer` parameter to the name of a layer whose output to
expose as embeddings (or prepend `<` to use the input tensor instead).

Note

Did you know? You can also
[register your custom model](api.md#model-zoo-add) under a name of your
choice so that it can be loaded and used as follows:

```python
model = foz.load_zoo_model("your-custom-model")
dataset.apply_model(model, label_field="predictions")

```

