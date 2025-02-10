# Dataset Zoo API [¶](\#dataset-zoo-api "Permalink to this headline")

You can interact with the Dataset Zoo either via the Python library or the CLI:

## Listing zoo datasets [¶](\#listing-zoo-datasets "Permalink to this headline")

## Getting information about zoo datasets [¶](\#getting-information-about-zoo-datasets "Permalink to this headline")

## Downloading zoo datasets [¶](\#downloading-zoo-datasets "Permalink to this headline")

## Loading zoo datasets [¶](\#loading-zoo-datasets "Permalink to this headline")

## Loading zoo datasets with manual downloads [¶](\#loading-zoo-datasets-with-manual-downloads "Permalink to this headline")

Some zoo datasets such as
[`BDD100K`](../../api/fiftyone.zoo.datasets.base.html#fiftyone.zoo.datasets.base.BDD100KDataset "fiftyone.zoo.datasets.base.BDD100KDataset")
and [`Cityscapes`](../../api/fiftyone.zoo.datasets.base.html#fiftyone.zoo.datasets.base.CityscapesDataset "fiftyone.zoo.datasets.base.CityscapesDataset") require
that you create accounts on a website and manually download the source files.
In such cases, the [`ZooDataset`](../../api/fiftyone.zoo.datasets.html#fiftyone.zoo.datasets.ZooDataset "fiftyone.zoo.datasets.ZooDataset") class
will provide additional argument(s) that let you specify the paths to these
files that you have manually downloaded on disk.

You can load these datasets into FiftyOne by first calling
[`download_zoo_dataset()`](../../api/fiftyone.zoo.datasets.html#fiftyone.zoo.datasets.download_zoo_dataset "fiftyone.zoo.datasets.download_zoo_dataset")
with the appropriate keyword arguments (which are passed to the underlying
[`ZooDataset`](../../api/fiftyone.zoo.datasets.html#fiftyone.zoo.datasets.ZooDataset "fiftyone.zoo.datasets.ZooDataset") constructor) to wrangle
the raw download into FiftyOne format, and then calling
[`load_zoo_dataset()`](../../api/fiftyone.zoo.datasets.html#fiftyone.zoo.datasets.load_zoo_dataset "fiftyone.zoo.datasets.load_zoo_dataset") or using
[fiftyone zoo datasets load](../../cli/index.md#cli-fiftyone-zoo-datasets-load) to load the
dataset into FiftyOne.

For example, the following snippet shows how to load the BDD100K dataset from
the zoo:

```python
import fiftyone.zoo as foz

# First parse the manually downloaded files in `source_dir`
foz.download_zoo_dataset(
    "bdd100k", source_dir="/path/to/dir-with-bdd100k-files"
)

# Now load into FiftyOne
dataset = foz.load_zoo_dataset("bdd100k", split="validation")

```

## Controlling where zoo datasets are downloaded [¶](\#controlling-where-zoo-datasets-are-downloaded "Permalink to this headline")

By default, zoo datasets are downloaded into subdirectories of
`fiftyone.config.dataset_zoo_dir` corresponding to their names.

You can customize this backend by modifying the `dataset_zoo_dir` setting
of your [FiftyOne config](../../fiftyone_concepts/config.md#configuring-fiftyone).

## Deleting zoo datasets [¶](\#deleting-zoo-datasets "Permalink to this headline")

## Adding datasets to the zoo [¶](\#adding-datasets-to-the-zoo "Permalink to this headline")

We frequently add new built-in datasets to the Dataset Zoo, which will
automatically become accessible to you when you update your FiftyOne package.

Note

FiftyOne is open source! You are welcome to contribute datasets to the
public dataset zoo by submitting a pull request to
[the GitHub repository](https://github.com/voxel51/fiftyone).

You can also add your own datasets to your local dataset zoo, enabling you to
work with these datasets via the [`fiftyone.zoo.datasets`](../../api/fiftyone.zoo.datasets.html#module-fiftyone.zoo.datasets "fiftyone.zoo.datasets") package and the
CLI using the same syntax that you would with publicly available datasets.

To add dataset(s) to your local zoo, you simply write a JSON manifest file in
the format below to tell FiftyOne about the dataset. For example, the manifest
below adds a second copy of the `quickstart` dataset to the zoo under the
alias `quickstart-copy`:

```python
{
    "custom": {
        "quickstart-copy": "fiftyone.zoo.datasets.base.QuickstartDataset"
    }
}

```

In the above, `custom` specifies the source of the dataset, which can be an
arbitrary string and simply controls the column of the
[fiftyone zoo datasets list](../../cli/index.md#cli-fiftyone-zoo-datasets-list) listing in
which the dataset is annotated; `quickstart-copy` is the name of the new
dataset; and `fiftyone.zoo.datasets.base.QuickstartDataset` is the
fully-qualified class name of the
[`ZooDataset class`](../../api/fiftyone.zoo.datasets.html#fiftyone.zoo.datasets.ZooDataset "fiftyone.zoo.datasets.ZooDataset") for the dataset,
which specifies how to download and load the dataset into FiftyOne. This class
can be defined anywhere that is importable at runtime in your environment.

Finally, expose your new dataset(s) to FiftyOne by adding your manifest to the
`dataset_zoo_manifest_paths` parameter of your
[FiftyOne config](../../fiftyone_concepts/config.md#configuring-fiftyone). One way to do this is to set the
`FIFTYONE_DATASET_ZOO_MANIFEST_PATHS` environment variable:

```python
export FIFTYONE_DATASET_ZOO_MANIFEST_PATHS=/path/to/custom/manifest.json

```

Now you can access the `quickstart-copy` dataset as you would any other zoo
dataset:

```python
# Will contain `quickstart-copy`
fiftyone zoo datasets list

# Load custom dataset into FiftyOne
fiftyone zoo datasets load quickstart-copy

```

## Customizing your ML backend [¶](\#customizing-your-ml-backend "Permalink to this headline")

Behind the scenes, FiftyOne uses either
[TensorFlow Datasets](https://www.tensorflow.org/datasets) or
[TorchVision Datasets](https://pytorch.org/vision/stable/datasets.html)
libraries to download and wrangle some zoo datasets, depending on which ML
library you have installed. In order to load datasets using TF, you must have
the [tensorflow-datasets](https://pypi.org/project/tensorflow-datasets)
package installed on your machine. In order to load datasets using PyTorch, you
must have the [torch](https://pypi.org/project/torch) and
[torchvision](https://pypi.org/project/torchvision) packages installed.

Note that the ML backends may expose different datasets.

For datasets that require an ML backend, FiftyOne will use whichever ML backend
is necessary to download the requested zoo dataset. If a dataset is available
through both backends, it will use the backend specified by the
`fo.config.default_ml_backend` setting in your FiftyOne config.

You can customize this backend by modifying the `default_ml_backend` setting
of your [FiftyOne config](../../fiftyone_concepts/config.md#configuring-fiftyone).

