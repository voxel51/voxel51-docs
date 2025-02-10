# Model Zoo API Reference [¶](\#model-zoo-api-reference "Permalink to this headline")

You can interact with the Model Zoo either via the Python library or the CLI.

## Listing zoo models [¶](\#listing-zoo-models "Permalink to this headline")

## Getting information about zoo models [¶](\#getting-information-about-zoo-models "Permalink to this headline")

## Downloading zoo models [¶](\#downloading-zoo-models "Permalink to this headline")

## Installing zoo model requirements [¶](\#installing-zoo-model-requirements "Permalink to this headline")

## Loading zoo models [¶](\#loading-zoo-models "Permalink to this headline")

You can load a zoo model via
[`load_zoo_model()`](../../api/fiftyone.zoo.models.html#fiftyone.zoo.models.load_zoo_model "fiftyone.zoo.models.load_zoo_model").

By default, the model will be automatically downloaded from the web the first
time you access it if it is not already downloaded:

```python
import fiftyone.zoo as foz

# The model will be downloaded from the web the first time you access it
model = foz.load_zoo_model("faster-rcnn-resnet50-fpn-coco-torch")

```

You can also provide additional arguments to
[`load_zoo_model()`](../../api/fiftyone.zoo.models.html#fiftyone.zoo.models.load_zoo_model "fiftyone.zoo.models.load_zoo_model") to customize
the import behavior:

```python
# Load the zoo model and install any necessary requirements in order to
# use it (logging warnings if any issues arise)
model = foz.load_zoo_model(
    "faster-rcnn-resnet50-fpn-coco-torch",
    install_requirements=True,
    error_level=1,
)

```

Note

By default, FiftyOne will attempt to ensure that any requirements such as
Python packages or CUDA versions are satisfied before loading the model,
and an error will be raised if a requirement is not satisfied.

You can customize this behavior via the `error_level` argument to
[`load_zoo_model()`](../../api/fiftyone.zoo.models.html#fiftyone.zoo.models.load_zoo_model "fiftyone.zoo.models.load_zoo_model"), or you can
permanently adjust this behavior by setting the `requirement_error_level`
parameter of your [FiftyOne config](../../fiftyone_concepts/config.md#configuring-fiftyone).

An `error_level` of `0` will raise an error if a requirement is not
satisfied, `1` will log a warning if the requirement is not satisfied,
and `2` will ignore unsatisfied requirements.

If you are using a `conda` environment, it is recommended you use an
`error_level` of `1` or `2`, since FiftyOne uses `pip` to check for
requirements.

## Applying zoo models [¶](\#applying-zoo-models "Permalink to this headline")

## Generating embeddings with zoo models [¶](\#generating-embeddings-with-zoo-models "Permalink to this headline")

## Controlling where zoo models are downloaded [¶](\#controlling-where-zoo-models-are-downloaded "Permalink to this headline")

By default, zoo models are downloaded into subdirectories of
`fiftyone.config.model_zoo_dir` corresponding to their names.

You can customize this backend by modifying the `model_zoo_dir` setting of
your [FiftyOne config](../../fiftyone_concepts/config.md#configuring-fiftyone).

## Deleting zoo models [¶](\#deleting-zoo-models "Permalink to this headline")

## Adding models to the zoo [¶](\#adding-models-to-the-zoo "Permalink to this headline")

We frequently add new models to the Model Zoo, which will automatically become
accessible to you when you update your FiftyOne package.

Note

FiftyOne is open source! You are welcome to contribute models to the public
model zoo by submitting a pull request to
[the GitHub repository](https://github.com/voxel51/fiftyone).

You can also add your own models to your local model zoo, enabling you to work
with these models via the [`fiftyone.zoo`](../../api/fiftyone.zoo.html#module-fiftyone.zoo "fiftyone.zoo") package and the CLI using the
same syntax that you would with publicly available models.

To add model(s) to your local zoo, you simply write a JSON manifest file in
the format below to tell FiftyOne about the model(s). For example, the manifest
below adds a second copy of the `yolo-v2-coco-tf1` model to the zoo under the
alias `yolo-v2-coco-tf1-high-conf` that only returns predictions whose
confidence is at least 0.5:

```python
{
    "models": [\
        {\
            "base_name": "yolo-v2-coco-tf1-high-conf",\
            "base_filename": "yolo-v2-coco-high-conf.weights",\
            "version": null,\
            "description": "A YOLOv2 model with confidence threshold set to 0.5",\
            "manager": {\
                "type": "fiftyone.core.models.ModelManager",\
                "config": {\
                    "google_drive_id": "1ajuPZws47SOw3xJc4Wvk1yuiB3qv8ycr"\
                }\
            },\
            "default_deployment_config_dict": {\
                "type": "fiftyone.utils.eta.ETAModel",\
                "config": {\
                    "type": "eta.detectors.YOLODetector",\
                    "config": {\
                        "config_dir": "{{eta}}/tensorflow/darkflow/cfg/",\
                        "config_path": "{{eta}}/tensorflow/darkflow/cfg/yolo.cfg",\
                        "confidence_thresh": 0.5\
                    }\
                }\
            },\
            "requirements": {\
                "cpu": {\
                    "support": true,\
                    "packages": ["tensorflow<2"]\
                },\
                "gpu": {\
                    "support": true,\
                    "packages": ["tensorflow-gpu<2"]\
                }\
            },\
            "tags": ["detection", "coco", "tf1"],\
            "date_added": "2020-12-11 13:45:51"\
        }\
    ]
}

```

Note

Adjusting the hard-coded threshold of the above model is possible via
JSON-only changes in this case because the underlying
[eta.detectors.YOLODetector](https://github.com/voxel51/eta/blob/develop/eta/detectors/yolo.py)
class exposes this as a parameter.

In practice, there is no need to hard-code confidence thresholds in models,
since the
[`apply_model()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.apply_model "fiftyone.core.collections.SampleCollection.apply_model")
method supports supplying an optional confidence threshold that is applied
post-facto to the predictions generated by any model.

Models manifest JSON files should have a `models` key that contains a list
of serialized
[`ZooModel class definitions`](../../api/fiftyone.zoo.models.html#fiftyone.zoo.models.ZooModel "fiftyone.zoo.models.ZooModel") that
describe how to download and load the model.

Finally, expose your new models(s) to FiftyOne by adding your manifest to the
`model_zoo_manifest_paths` parameter of your
[FiftyOne config](../../fiftyone_concepts/config.md#configuring-fiftyone). One way to do this is to set the
`FIFTYONE_MODEL_ZOO_MANIFEST_PATHS` environment variable:

```python
export FIFTYONE_MODEL_ZOO_MANIFEST_PATHS=/path/to/custom/manifest.json

```

Now you can load and apply the `yolo-v2-coco-tf1-high-conf` model as you
would any other zoo model:

```python
import fiftyone as fo
import fiftyone.zoo as foz

# Load custom model
model = foz.load_zoo_model("yolo-v2-coco-tf1-high-conf")

# Apply model to a dataset
dataset = fo.load_dataset(...)
dataset.apply_model(model, label_field="predictions")

```

