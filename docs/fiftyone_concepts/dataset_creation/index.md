# Loading data into FiftyOne [¶](\#loading-data-into-fiftyone "Permalink to this headline")

The first step to using FiftyOne is to load your data into a
[dataset](../using_datasets.md#using-datasets). FiftyOne supports automatic loading of
datasets stored in various [common formats](datasets.md#supported-import-formats).
If your dataset is stored in a custom format, don’t worry, FiftyOne also
provides support for easily loading datasets in
[custom formats](#loading-custom-datasets).

Check out the sections below to see which import pattern is the best fit for
your data.

Note

Did you know? You can import media and/or labels from within the FiftyOne
App by installing the
[@voxel51/io](https://github.com/voxel51/fiftyone-plugins/tree/main/plugins/io)
plugin!

Note

When you create a [`Dataset`](../../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset"), its samples and all of their fields (metadata,
labels, custom fields, etc.) are written to FiftyOne’s backing database.

**Important:** Samples only store the `filepath` to the media, not the
raw media itself. FiftyOne does not create duplicate copies of your data!

## Common formats [¶](\#common-formats "Permalink to this headline")

If your data is stored on disk in one of the
[many common formats](datasets.md#supported-import-formats) supported natively by
FiftyOne, then you can automatically load your data into a [`Dataset`](../../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") via the
following simple pattern:

```python
import fiftyone as fo

# A name for the dataset
name = "my-dataset"

# The directory containing the dataset to import
dataset_dir = "/path/to/dataset"

# The type of the dataset being imported
dataset_type = fo.types.COCODetectionDataset  # for example

dataset = fo.Dataset.from_dir(
    dataset_dir=dataset_dir,
    dataset_type=dataset_type,
    name=name,
)

```

Note

Check out [this page](datasets.md#loading-datasets-from-disk) for more details
about loading datasets from disk in common formats!

## Custom formats [¶](\#custom-formats "Permalink to this headline")

The simplest and most flexible approach to loading your data into FiftyOne is
to iterate over your data in a simple Python loop, create a [`Sample`](../../api/fiftyone.core.sample.html#fiftyone.core.sample.Sample "fiftyone.core.sample.Sample") for each
data + label(s) pair, and then add those samples to a [`Dataset`](../../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset").

FiftyOne provides [label types](../using_datasets.md#using-labels) for common tasks such as
classification, detection, segmentation, and many more. The examples below
give you a sense of the basic workflow for a few tasks:

Note that using [`Dataset.add_samples()`](../../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset.add_samples "fiftyone.core.dataset.Dataset.add_samples")
to add batches of samples to your datasets can be significantly more efficient
than adding samples one-by-one via
[`Dataset.add_sample()`](../../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset.add_sample "fiftyone.core.dataset.Dataset.add_sample").

Note

If you use the same custom data format frequently in your workflows, then
writing a [custom dataset importer](datasets.md#custom-dataset-importer) is a
great way to abstract and streamline the loading of your data into
FiftyOne.

## Loading images [¶](\#loading-images "Permalink to this headline")

If you’re just getting started with a project and all you have is a bunch of
image files, you can easily load them into a FiftyOne dataset and start
visualizing them [in the App](../app.md#fiftyone-app):

## Loading videos [¶](\#loading-videos "Permalink to this headline")

If you’re just getting started with a project and all you have is a bunch of
video files, you can easily load them into a FiftyOne dataset and start
visualizing them [in the App](../app.md#fiftyone-app):

## Model predictions [¶](\#model-predictions "Permalink to this headline")

Once you’ve created a dataset and ground truth labels, you can easily add model
predictions to take advantage of FiftyOne’s
[evaluation capabilities](../evaluation.md#evaluating-models).

## Need data? [¶](\#need-data "Permalink to this headline")

The [FiftyOne Dataset Zoo](../../data/dataset_zoo/index.md#dataset-zoo) contains dozens of popular public
datasets that you can load into FiftyOne in a single line of code:

```python
import fiftyone.zoo as foz

# List available datasets
print(foz.list_zoo_datasets())
# ['coco-2014', ...,  'kitti', ..., 'voc-2012', ...]

# Load a split of a zoo dataset
dataset = foz.load_zoo_dataset("cifar10", split="train")

```

Note

Check out the [available zoo datasets](../../data/dataset_zoo/datasets.md#dataset-zoo-datasets)!
